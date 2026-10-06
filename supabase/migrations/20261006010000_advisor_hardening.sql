-- Supabase security advisor hardening.
-- 1) Internal predicates move to a non-exposed schema (not reachable via
--    /rest/v1/rpc). Policies keep working (they reference the functions by OID).
create schema if not exists private;
grant usage on schema private to anon, authenticated;
alter function public.is_verified_professional(uuid) set schema private;
alter function public.has_role(uuid, public.account_role) set schema private;
revoke execute on function private.is_verified_professional(uuid) from public;
revoke execute on function private.has_role(uuid, public.account_role) from public;
grant execute on function private.is_verified_professional(uuid) to anon, authenticated;
grant execute on function private.has_role(uuid, public.account_role) to anon, authenticated;

-- Function bodies reference the predicates by name: re-point them.
create or replace function public.decide_identity(applicant uuid, p_decision text,
  p_scope public.reviewer_scope, p_checked uuid[], p_reason text, p_message text)
returns public.verification_status
language plpgsql security definer set search_path = public as $$
declare cur public.verification_status; nxt public.verification_status; kind text;
begin
  if auth.uid() is null then raise exception 'not signed in'; end if;
  if applicant = auth.uid() then raise exception 'self approval'; end if;
  if private.has_role(auth.uid(), 'identity_admin') then
    kind := 'identity_admin';
  elsif private.is_verified_professional(auth.uid()) and exists (
      select 1 from verifier_grants g where g.user_id = auth.uid()
        and g.scope = p_scope and g.revoked_at is null) then
    kind := 'verified_peer';
  else
    raise exception 'forbidden';
  end if;
  if p_decision = 'SUSPEND' and kind <> 'identity_admin' then
    raise exception 'forbidden';
  end if;
  select status into cur from verification where user_id = applicant for update;
  if not found then raise exception 'no application'; end if;
  nxt := case
    when cur = 'APPLICATION_PENDING' and p_decision = 'VERIFY' then 'VERIFIED_PROFESSIONAL'
    when cur = 'APPLICATION_PENDING' and p_decision = 'REQUEST_MORE_INFORMATION' then 'CHANGES_REQUESTED'
    when cur = 'APPLICATION_PENDING' and p_decision = 'REJECT' then 'REJECTED'
    when cur = 'VERIFIED_PROFESSIONAL' and p_decision = 'SUSPEND' then 'SUSPENDED'
    when cur = 'SUSPENDED' and p_decision = 'VERIFY' and kind = 'identity_admin'
      then 'VERIFIED_PROFESSIONAL'
    else null end::public.verification_status;
  if nxt is null then raise exception 'invalid transition'; end if;
  if p_decision = 'VERIFY' then
    if coalesce(cardinality(p_checked), 0) = 0 then raise exception 'no credential checked'; end if;
    if exists (select 1 from unnest(p_checked) c where not exists (
        select 1 from credential_documents d
        where d.document_id = c and d.user_id = applicant)) then
      raise exception 'unknown credential';
    end if;
  end if;
  update verification set status = nxt, decided_by = auth.uid(), decided_at = now(),
    applicant_message = p_message where user_id = applicant;
  insert into verification_decisions(applicant_id, approver_id, approver_kind,
    decision, scope, reason, from_status, to_status, checked_documents)
  values (applicant, auth.uid(), kind, p_decision, p_scope, p_reason, cur, nxt,
    coalesce(p_checked, '{}'));
  return nxt;
end $$;

create or replace function public.submit_review(p_record text, p_claim text, p_version text,
  p_scope public.reviewer_scope, p_action public.review_action, p_text text,
  p_source text)
returns uuid
language plpgsql security definer set search_path = public as $$
declare rid uuid; rec public.content_records; prof public.professional_profiles;
begin
  if not private.is_verified_professional(auth.uid()) then raise exception 'not verified'; end if;
  if not exists (select 1 from reviewer_scopes s where s.user_id = auth.uid()
                 and s.scope = p_scope and s.revoked_at is null) then
    raise exception 'scope not granted';
  end if;
  select * into rec from content_records where record_id = p_record;
  if not found or not (p_scope = any(rec.scopes)) then raise exception 'scope mismatch'; end if;
  if p_version <> rec.published_version then raise exception 'stale version'; end if;
  select * into prof from professional_profiles where user_id = auth.uid();
  insert into professional_reviews(record_id, claim_id, content_version,
    reviewer_user_id, reviewer_display_name, reviewer_specialty,
    reviewer_organization, reviewer_scope, reviewer_status_at_review, action,
    review_text, source_reference)
  values (p_record, p_claim, p_version, auth.uid(), prof.display_name,
    prof.primary_specialty,
    case when prof.show_organization then prof.organization end,
    p_scope, 'VERIFIED_PROFESSIONAL', p_action, p_text, p_source)
  returning review_id into rid;
  insert into review_audit(record_id, claim_id, content_version, actor_user_id,
    actor_scope, action, note, review_id, previous_state, new_state)
  values (p_record, p_claim, p_version, auth.uid(), p_scope, p_action, p_text,
    rid, 'see_policy', 'see_policy');
  return rid;
end $$;

create or replace function public.publish_record_version(p_record text, p_version text,
  p_scopes public.reviewer_scope[], p_risk text)
returns void language plpgsql security definer set search_path = public as $$
declare old text;
begin
  if not private.has_role(auth.uid(), 'scope_grantor') then raise exception 'forbidden'; end if;
  select published_version into old from content_records where record_id = p_record;
  insert into content_records(record_id, published_version, scopes, risk)
    values (p_record, p_version, p_scopes, p_risk)
    on conflict (record_id) do update
      set published_version = excluded.published_version,
          scopes = excluded.scopes, risk = excluded.risk;
  if old is not null and old <> p_version then
    insert into review_audit(record_id, content_version, actor_user_id,
      previous_state, new_state)
    values (p_record, p_version, auth.uid(), 'any', 'RE_REVIEW_REQUIRED');
  end if;
end $$;

-- 2) The SECURITY DEFINER view moves to the non-exposed schema; clients use
--    an explicit function returning ONLY public fields of VERIFIED
--    professionals (no email, licence, documents).
alter view public.public_professionals set schema private;
revoke all on private.public_professionals from anon, authenticated;
create function public.public_professionals()
returns table (user_id uuid, display_name text, country_code char(2),
               primary_specialty text, organization text,
               years_experience int, review_count bigint)
language sql stable security definer set search_path = public as $$
  select user_id, display_name, country_code, primary_specialty, organization,
         years_experience, review_count from private.public_professionals
$$;
