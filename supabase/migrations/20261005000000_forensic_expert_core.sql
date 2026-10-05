-- FORENSIC EXPERT — production schema (Supabase / PostgreSQL 15+).
--
-- Apply to a DEDICATED FORENSIC EXPERT Supabase project (not shared with
-- any other app). Not yet deployed: no project exists for this app.
--
-- Security model (enforced HERE; client flags are never trusted):
--   * auth.users comes from Supabase Auth (email OTP).
--   * Usage mode (student/professional) is NOT stored as a privilege.
--   * VERIFIED_PROFESSIONAL only via decide_identity():
--       - identity_admin (human account role), or
--       - a VERIFIED_PROFESSIONAL holding an explicit, non-revoked
--         CAN_VERIFY_PROFESSIONALS grant for the SAME specialty scope.
--     Never: self-approval, students, unverified/suspended users, service
--     accounts, AI. VERIFY requires >= 1 checked credential owned by the
--     applicant. Every decision is recorded (append-only).
--   * Identity verification grants NO scientific review rights; reviewer
--     scopes are a separate grant (scope_grantor role).
--   * Credential files live in the PRIVATE bucket `credentials`, path
--     <user_id>/<uuid>; no public URL; admins get short signed URLs only via
--     the server. Contents are never logged.
--   * Reviews are append-only and bound to the exact content version.
--   * HUMAN_VERIFIED is computed by policy (2 independent approvals), never
--     set by one review, an admin role, AI or automated checks.

create extension if not exists pgcrypto;

create type public.verification_status as enum (
  'UNVERIFIED', 'APPLICATION_PENDING', 'VERIFIED_PROFESSIONAL',
  'CHANGES_REQUESTED', 'REJECTED', 'SUSPENDED');

create type public.reviewer_scope as enum (
  'FORENSIC_TOXICOLOGY', 'FORENSIC_CHEMISTRY', 'FORENSIC_MEDICINE',
  'LAB_ANALYTICS', 'FORENSIC_BIOCHEMISTRY', 'PATHOLOGY_HISTOLOGY',
  'GENETICS_DNA', 'ANTHROPOLOGY', 'ODONTOLOGY', 'LEGAL_JURISDICTION',
  'TRANSLATION');

create type public.review_action as enum (
  'APPROVE', 'REQUEST_CHANGE', 'FLAG_CONFLICT', 'FLAG_OUTDATED', 'REJECT');

create type public.account_role as enum ('identity_admin', 'scope_grantor');

-- Roles are granted out-of-band by the owner (SQL console), never by RPC
-- from the app.
create table public.account_roles (
  user_id    uuid not null references auth.users(id) on delete cascade,
  role       public.account_role not null,
  granted_by uuid not null references auth.users(id),
  granted_at timestamptz not null default now(),
  primary key (user_id, role),
  check (user_id <> granted_by)
);

create table public.professional_profiles (
  user_id                uuid primary key references auth.users(id) on delete cascade,
  display_name           text not null check (length(btrim(display_name)) between 1 and 120),
  country_code           char(2) not null,
  city                   text check (length(city) <= 160),
  languages              text[] not null default '{}',
  organization           text not null check (length(btrim(organization)) between 1 and 160),
  show_organization      boolean not null default false,
  position               text not null check (length(btrim(position)) between 1 and 160),
  primary_specialty      text not null,
  additional_specialties text[] not null default '{}',
  years_experience       int check (years_experience between 0 and 70),
  education              text not null check (length(btrim(education)) between 1 and 160),
  work_email             text,     -- private
  license_number         text,     -- private, optional, jurisdiction dependent
  bio                    text check (length(bio) <= 600),
  interests              text check (length(interests) <= 300),
  updated_at             timestamptz not null default now()
  -- No passport / national ID columns by design.
);

create table public.verification (
  user_id           uuid primary key references auth.users(id) on delete cascade,
  status            public.verification_status not null default 'UNVERIFIED',
  submitted_at      timestamptz,
  decided_by        uuid references auth.users(id),
  decided_at        timestamptz,
  applicant_message text,          -- visible to the applicant
  internal_note     text,          -- identity reviewers only
  check (decided_by is null or decided_by <> user_id)
);

create table public.credential_documents (
  document_id uuid primary key default gen_random_uuid(),
  user_id     uuid not null references auth.users(id) on delete cascade,
  kind        text not null check (kind in ('professionalCertificate',
                'qualificationCertificate','diploma','employmentEvidence',
                'registrationLicense','trainingCertificate')),
  mime_type   text not null check (mime_type in ('application/pdf','image/jpeg','image/png')),
  size_bytes  int not null check (size_bytes between 1 and 10485760),
  sha256      text not null check (sha256 ~ '^[0-9a-f]{64}$'),
  storage_key text not null unique,
  uploaded_at timestamptz not null default now(),
  check (storage_key like user_id::text || '/%')
);

-- Scientific reviewer scopes (separate from identity verification).
create table public.reviewer_scopes (
  user_id    uuid not null references auth.users(id) on delete cascade,
  scope      public.reviewer_scope not null,
  granted_by uuid not null references auth.users(id),
  granted_at timestamptz not null default now(),
  revoked_at timestamptz,
  primary key (user_id, scope),
  check (user_id <> granted_by)
);

-- CAN_VERIFY_PROFESSIONALS per specialty (separate from reviewer scope and
-- from being verified).
create table public.verifier_grants (
  user_id    uuid not null references auth.users(id) on delete cascade,
  scope      public.reviewer_scope not null,
  granted_by uuid not null references auth.users(id),
  granted_at timestamptz not null default now(),
  revoked_at timestamptz,
  primary key (user_id, scope),
  check (user_id <> granted_by)
);

create table public.verification_decisions (
  decision_id       bigserial primary key,
  applicant_id      uuid not null references auth.users(id),
  approver_id       uuid not null references auth.users(id),
  approver_kind     text not null check (approver_kind in ('identity_admin','verified_peer')),
  decision          text not null check (decision in
                      ('VERIFY','REQUEST_MORE_INFORMATION','REJECT','SUSPEND')),
  scope             public.reviewer_scope not null,
  reason            text not null check (length(btrim(reason)) >= 5),
  from_status       public.verification_status not null,
  to_status         public.verification_status not null,
  checked_documents uuid[] not null default '{}',
  at                timestamptz not null default now(),
  check (approver_id <> applicant_id),
  check (decision <> 'VERIFY' or cardinality(checked_documents) > 0)
);

create table public.professional_reviews (
  review_id                 uuid primary key default gen_random_uuid(),
  record_id                 text not null,
  claim_id                  text,
  content_version           text not null,
  reviewer_user_id          uuid not null references auth.users(id),
  reviewer_display_name     text not null,
  reviewer_specialty        text not null,
  reviewer_organization     text,
  reviewer_scope            public.reviewer_scope not null,
  reviewer_status_at_review public.verification_status not null,
  action                    public.review_action not null,
  review_text               text not null check (length(btrim(review_text)) between 20 and 4000),
  source_reference          text,
  created_at                timestamptz not null default now(),
  withdrawn_at              timestamptz
);

create table public.review_audit (
  entry_id        bigserial primary key,
  record_id       text not null,
  claim_id        text,
  content_version text not null,
  actor_user_id   uuid,
  actor_scope     public.reviewer_scope,
  action          public.review_action,
  note            text,
  review_id       uuid references public.professional_reviews(review_id),
  previous_state  text not null,
  new_state       text not null,
  at              timestamptz not null default now()
);

-- Content-service registry of published record versions and their scopes.
create table public.content_records (
  record_id         text primary key,
  published_version text not null,
  scopes            public.reviewer_scope[] not null default '{}',
  risk              text not null default 'standard' check (risk in ('standard','high'))
);

-- Predicates ----------------------------------------------------------------
create function public.is_verified_professional(uid uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from verification v
                 where v.user_id = uid and v.status = 'VERIFIED_PROFESSIONAL')
$$;

create function public.has_role(uid uuid, r public.account_role) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from account_roles a where a.user_id = uid and a.role = r)
$$;

-- RLS -------------------------------------------------------------------------
alter table public.account_roles          enable row level security;
alter table public.professional_profiles  enable row level security;
alter table public.verification           enable row level security;
alter table public.credential_documents   enable row level security;
alter table public.reviewer_scopes        enable row level security;
alter table public.verifier_grants        enable row level security;
alter table public.verification_decisions enable row level security;
alter table public.professional_reviews   enable row level security;
alter table public.review_audit           enable row level security;
alter table public.content_records        enable row level security;

create policy roles_self_read on public.account_roles
  for select using (user_id = auth.uid());
create policy profile_own on public.professional_profiles
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy profile_identity_admin_read on public.professional_profiles
  for select using (public.has_role(auth.uid(), 'identity_admin'));
-- Status rows: read own (or identity admin); writes ONLY via functions.
create policy verification_read on public.verification
  for select using (user_id = auth.uid() or public.has_role(auth.uid(), 'identity_admin'));
-- Documents: owner inserts metadata for own files; no update/delete by app.
create policy docs_insert_own on public.credential_documents
  for insert with check (user_id = auth.uid()
    and storage_key like auth.uid()::text || '/%');
create policy docs_read on public.credential_documents
  for select using (user_id = auth.uid() or public.has_role(auth.uid(), 'identity_admin'));
create policy scopes_read on public.reviewer_scopes for select using (true);
create policy verifier_read_own on public.verifier_grants
  for select using (user_id = auth.uid());
create policy decisions_read on public.verification_decisions
  for select using (applicant_id = auth.uid() or public.has_role(auth.uid(), 'identity_admin'));
create policy reviews_read on public.professional_reviews for select using (true);
create policy audit_read on public.review_audit for select using (true);
create policy records_read on public.content_records for select using (true);

-- Public professional profile view (no private fields).
create view public.public_professionals with (security_invoker = false) as
  select p.user_id, p.display_name, p.country_code, p.primary_specialty,
         case when p.show_organization then p.organization end as organization,
         p.years_experience,
         (select count(*) from public.professional_reviews r
            where r.reviewer_user_id = p.user_id and r.withdrawn_at is null) as review_count
  from public.professional_profiles p
  join public.verification v on v.user_id = p.user_id
  where v.status = 'VERIFIED_PROFESSIONAL';

-- Application: automatic receipt (no human needed to RECEIVE it).
create function public.submit_application()
returns public.verification_status
language plpgsql security definer set search_path = public as $$
declare cur public.verification_status; p public.professional_profiles;
begin
  if auth.uid() is null then raise exception 'not signed in'; end if;
  select * into p from professional_profiles where user_id = auth.uid();
  if not found then raise exception 'profile incomplete'; end if;
  insert into verification(user_id) values (auth.uid()) on conflict do nothing;
  select status into cur from verification where user_id = auth.uid() for update;
  if cur not in ('UNVERIFIED', 'CHANGES_REQUESTED', 'REJECTED') then
    raise exception 'application not allowed from %', cur;
  end if;
  update verification set status = 'APPLICATION_PENDING', submitted_at = now()
    where user_id = auth.uid();
  return 'APPLICATION_PENDING';
end $$;

-- Identity decision (admin or scoped verified peer). Row lock + state check
-- prevents double decisions / replay.
create function public.decide_identity(applicant uuid, p_decision text,
  p_scope public.reviewer_scope, p_checked uuid[], p_reason text, p_message text)
returns public.verification_status
language plpgsql security definer set search_path = public as $$
declare cur public.verification_status; nxt public.verification_status; kind text;
begin
  if auth.uid() is null then raise exception 'not signed in'; end if;
  if applicant = auth.uid() then raise exception 'self approval'; end if;
  if public.has_role(auth.uid(), 'identity_admin') then
    kind := 'identity_admin';
  elsif public.is_verified_professional(auth.uid()) and exists (
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

-- Review submission: verified + scoped + current version + record scope.
create function public.submit_review(p_record text, p_claim text, p_version text,
  p_scope public.reviewer_scope, p_action public.review_action, p_text text,
  p_source text)
returns uuid
language plpgsql security definer set search_path = public as $$
declare rid uuid; rec public.content_records; prof public.professional_profiles;
begin
  if not public.is_verified_professional(auth.uid()) then raise exception 'not verified'; end if;
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

-- When published content changes, prior reviews remain (history) and the
-- record becomes RE_REVIEW_REQUIRED by version mismatch (computed).
create function public.publish_record_version(p_record text, p_version text,
  p_scopes public.reviewer_scope[], p_risk text)
returns void language plpgsql security definer set search_path = public as $$
declare old text;
begin
  if not public.has_role(auth.uid(), 'scope_grantor') then raise exception 'forbidden'; end if;
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

revoke all on function public.decide_identity from anon;
revoke all on function public.submit_review from anon;
revoke all on function public.submit_application from anon;
revoke all on function public.publish_record_version from anon;

-- Private storage bucket for credentials ----------------------------------------
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('credentials', 'credentials', false, 10485760,
        array['application/pdf','image/jpeg','image/png'])
on conflict (id) do update set public = false;

create policy credentials_owner_upload on storage.objects
  for insert to authenticated
  with check (bucket_id = 'credentials'
    and (storage.foldername(name))[1] = auth.uid()::text
    and (select count(*) from public.credential_documents d
         where d.user_id = auth.uid()) < 5);
create policy credentials_owner_read on storage.objects
  for select to authenticated
  using (bucket_id = 'credentials'
    and ((storage.foldername(name))[1] = auth.uid()::text
         or public.has_role(auth.uid(), 'identity_admin')));
-- No update/delete policies: documents are immutable evidence.
