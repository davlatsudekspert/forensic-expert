-- FORENSIC EXPERT — Q&A service API (Edge Function entry points).
--
-- PostgREST only exposes `public`, so the three Edge Function entry points
-- granted in 20261011000000 (private.qa_set_expert_status,
-- private.qa_verify_attempt, private.qa_translation_put) are unreachable
-- over HTTP. This migration adds thin `public` wrappers granted to
-- service_role ONLY — the same pattern the referral server functions use.
--
-- Nothing here is callable by anon or authenticated: a user can neither
-- verify themselves nor write another user's badge. The document file is
-- never a parameter: only the verdict (status + short machine reason) is.
--
-- Rollback: supabase/rollback/20261011010000_qa_service_api_down.sql

-- The document check counter (3 per day, owner's rule). Returns the
-- attempt number; raises `rate limit` on the fourth call in one day.
create function public.qa_service_verify_attempt(p_user uuid) returns int
language sql security definer set search_path = '' as $$
  select private.qa_verify_attempt(p_user)
$$;

-- Writes the verdict. `p_reason` is a short machine code
-- ('document_ok', 'not_a_credential', 'unreadable', 'manual_check'),
-- never free text read out of the document.
create function public.qa_service_set_status(
  p_user uuid, p_role text, p_country text, p_status text,
  p_reason text, p_manual boolean default false) returns jsonb
language sql security definer set search_path = '' as $$
  select private.qa_set_expert_status(p_user, p_role, p_country, p_status,
                                      p_reason, p_manual)
$$;

-- Fills the machine-translation cache (one row per post and language).
create function public.qa_service_translation_put(
  p_target_type text, p_target_id uuid, p_lang text, p_title text,
  p_body text, p_engine text) returns void
language sql security definer set search_path = '' as $$
  select private.qa_translation_put(p_target_type, p_target_id, p_lang,
                                    p_title, p_body, p_engine)
$$;

-- Per-user daily counter for server-side work the app triggers
-- (translations). Raises `rate limit` past p_limit.
create function public.qa_service_bump(p_user uuid, p_kind text, p_limit int)
returns void language sql security definer set search_path = '' as $$
  select private.qa_bump(p_user, p_kind, p_limit)
$$;

-- Reads the post text to translate. Only published posts, and only the
-- fields that go to the translation engine — no author id, no e-mail.
create function public.qa_service_translatable(p_target_type text, p_target_id uuid)
returns jsonb language plpgsql stable security definer set search_path = '' as $$
declare v jsonb;
begin
  if p_target_type = 'question' then
    select jsonb_build_object('lang', q.lang, 'title', q.title, 'body', q.body)
    into v from public.qa_questions q
    where q.id = p_target_id and q.status = 'published';
  elsif p_target_type = 'answer' then
    select jsonb_build_object('lang', a.lang, 'title', null, 'body', a.body)
    into v from public.qa_answers a
    where a.id = p_target_id and a.status = 'published';
  else
    raise exception 'bad target';
  end if;
  return v;
end $$;

-- The owner's own badge: hand-checked, set server-side, idempotent.
-- The e-mail is a call-time argument used for the auth lookup only; it is
-- never stored by this function (qa_profiles keeps user_id, role, country,
-- status, short reason, dates — nothing else).
create function private.qa_seed_manual_expert(
  p_email text, p_role text, p_country text) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare v_user uuid;
begin
  select u.id into v_user from auth.users u
  where lower(u.email) = lower(btrim(p_email)) limit 1;
  if v_user is null then
    return jsonb_build_object('seeded', false, 'reason', 'no_such_account');
  end if;
  perform private.qa_set_expert_status(v_user, p_role, p_country, 'verified',
                                       'manual_check', true);
  return jsonb_build_object('seeded', true);
end $$;

create function public.qa_service_seed_manual_expert(
  p_email text, p_role text, p_country text) returns jsonb
language sql security definer set search_path = '' as $$
  select private.qa_seed_manual_expert(p_email, p_role, p_country)
$$;

-- ---------------------------------------------------------------- grants
-- Supabase grants EXECUTE to anon/authenticated/service_role by default:
-- revoke explicitly, then grant to service_role alone.
revoke execute on function public.qa_service_verify_attempt(uuid)
  from public, anon, authenticated;
revoke execute on function public.qa_service_set_status(uuid, text, text, text, text, boolean)
  from public, anon, authenticated;
revoke execute on function public.qa_service_translation_put(text, uuid, text, text, text, text)
  from public, anon, authenticated;
revoke execute on function public.qa_service_translatable(text, uuid)
  from public, anon, authenticated;
revoke execute on function public.qa_service_bump(uuid, text, int)
  from public, anon, authenticated;
revoke execute on function public.qa_service_seed_manual_expert(text, text, text)
  from public, anon, authenticated;
revoke execute on function private.qa_seed_manual_expert(text, text, text)
  from public, anon, authenticated, service_role;

grant execute on function public.qa_service_verify_attempt(uuid),
  public.qa_service_set_status(uuid, text, text, text, text, boolean),
  public.qa_service_translation_put(text, uuid, text, text, text, text),
  public.qa_service_translatable(text, uuid),
  public.qa_service_bump(uuid, text, int),
  public.qa_service_seed_manual_expert(text, text, text)
  to service_role;
