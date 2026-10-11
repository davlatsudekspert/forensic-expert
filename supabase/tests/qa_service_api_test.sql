-- Q&A service API: the Edge Function entry points (public.qa_service_*).
-- Runs after qa_community_test.sql, which created the auth users it reuses.
--
-- What is proven here: only service_role can call these functions; the
-- document never appears as a parameter or a column; the attempt counter and
-- the translation cache behave; the owner's manual badge seed is idempotent
-- and stores no e-mail.
\set ON_ERROR_STOP 1
reset role;

create function pg_temp.sv_check(ok boolean, label text) returns void language plpgsql as $$
begin
  if not coalesce(ok, false) then raise exception 'FAIL: %', label; end if;
  raise notice 'PASS: %', label;
end $$;
create function pg_temp.sv_blocked(q text, label text) returns void language plpgsql as $$
begin
  begin execute q; exception when others then
    raise notice 'PASS (blocked): %', label; return; end;
  raise exception 'FAIL (allowed): %', label;
end $$;
grant execute on function pg_temp.sv_check(boolean, text),
  pg_temp.sv_blocked(text, text) to anon, authenticated, service_role;

create function pg_temp.sv_as_user(uid text) returns void language plpgsql as $$
begin
  perform set_config('request.jwt.claim.sub', uid, false);
  perform set_config('request.jwt.claims', '{}', false);
  perform set_config('role', 'authenticated', false);
end $$;
grant execute on function pg_temp.sv_as_user(text) to anon, authenticated, service_role;

insert into auth.users (id, email, created_at, email_confirmed_at) values
 ('50000000-0000-0000-0000-0000000000b1', 'service-chemist@x', now(), now()),
 ('50000000-0000-0000-0000-0000000000b2', 'service-owner@x', now(), now())
on conflict (id) do nothing;

-- ------------------------------------------------------- shape of the API
select pg_temp.sv_check(not exists (
  select 1 from pg_proc p join pg_namespace n on n.oid = p.pronamespace
  where n.nspname = 'public' and p.proname like 'qa\_service\_%'
    and pg_get_function_arguments(p.oid) ~* 'bytea|document|file|image'),
  'no service entry point takes a document, a file or an image');

select pg_temp.sv_check((select count(*) = 6 from pg_proc p
  join pg_namespace n on n.oid = p.pronamespace
  where n.nspname = 'public' and p.proname like 'qa\_service\_%'),
  'six service entry points exist');

select pg_temp.sv_check(not exists (
  select 1 from pg_proc p join pg_namespace n on n.oid = p.pronamespace
  where n.nspname = 'public' and p.proname like 'qa\_service\_%'
    and (has_function_privilege('anon', p.oid, 'execute')
         or has_function_privilege('authenticated', p.oid, 'execute'))),
  'anon and authenticated cannot execute any service entry point');

select pg_temp.sv_check(not exists (
  select 1 from pg_proc p join pg_namespace n on n.oid = p.pronamespace
  where n.nspname = 'public' and p.proname like 'qa\_service\_%'
    and not has_function_privilege('service_role', p.oid, 'execute')),
  'service_role can execute every service entry point');

select pg_temp.sv_check(not has_function_privilege('service_role',
  'private.qa_seed_manual_expert(text, text, text)', 'execute'),
  'the manual seed in private is reachable only through its public wrapper');

-- A signed-in user must not be able to verify themselves or anyone else.
select pg_temp.sv_as_user('50000000-0000-0000-0000-0000000000b1');
select pg_temp.sv_blocked($$select public.qa_service_set_status(
  '50000000-0000-0000-0000-0000000000b1', 'forensic_chemist', 'UZ', 'verified',
  'document_ok', false)$$, 'a user cannot write their own verified badge');
select pg_temp.sv_blocked($$select public.qa_service_verify_attempt(
  '50000000-0000-0000-0000-0000000000b1')$$,
  'a user cannot count a document check themselves');
select pg_temp.sv_blocked($$select public.qa_service_seed_manual_expert(
  'service-owner@x', 'forensic_physician', 'UZ')$$,
  'a user cannot seed a manual badge');
select pg_temp.sv_blocked($$select public.qa_service_translatable(
  'question', '00000000-0000-0000-0000-000000000000')$$,
  'a user cannot read posts through the service entry point');
reset role;

-- ------------------------------------------------- attempts: 3 per day
set role service_role;
select pg_temp.sv_check(
  public.qa_service_verify_attempt('50000000-0000-0000-0000-0000000000b1') = 1,
  'the first document check of the day is attempt 1');
select pg_temp.sv_check(
  public.qa_service_verify_attempt('50000000-0000-0000-0000-0000000000b1') = 2,
  'the second is attempt 2');
select pg_temp.sv_check(
  public.qa_service_verify_attempt('50000000-0000-0000-0000-0000000000b1') = 3,
  'the third is attempt 3');
select pg_temp.sv_blocked($$select public.qa_service_verify_attempt(
  '50000000-0000-0000-0000-0000000000b1')$$,
  'the fourth document check in one day is refused');

-- ------------------------------------------------- writing the verdict
select pg_temp.sv_check(
  public.qa_service_set_status('50000000-0000-0000-0000-0000000000b1',
    'forensic_chemist', 'uz', 'verified', 'document_ok', false)
    ->> 'status' = 'verified',
  'the service writes the verdict and returns the profile');
reset role;
select pg_temp.sv_check((select status = 'verified' and country_code = 'UZ'
    and manual = false and reason = 'document_ok'
  from public.qa_profiles where user_id = '50000000-0000-0000-0000-0000000000b1'),
  'the stored profile holds only the verdict, the role, the country and the date');
select pg_temp.sv_check(
  private.qa_is_expert('50000000-0000-0000-0000-0000000000b1'),
  'a verified chemist may answer questions');

-- A rejection keeps the row but takes the badge away.
set role service_role;
select public.qa_service_set_status('50000000-0000-0000-0000-0000000000b1',
  'forensic_chemist', 'UZ', 'rejected', 'not_a_credential', false);
reset role;
select pg_temp.sv_check(
  not private.qa_is_expert('50000000-0000-0000-0000-0000000000b1'),
  'a rejected profile may not answer');
set role service_role;
select public.qa_service_set_status('50000000-0000-0000-0000-0000000000b1',
  'forensic_chemist', 'UZ', 'verified', 'document_ok', false);
select pg_temp.sv_blocked($$select public.qa_service_set_status(
  '50000000-0000-0000-0000-0000000000b1', 'forensic_chemist', 'UZ', 'god',
  'x', false)$$, 'an unknown status is refused');
reset role;

-- ------------------------------------------- the owner's manual badge
set role service_role;
select pg_temp.sv_check(
  (public.qa_service_seed_manual_expert('service-owner@x', 'forensic_physician', 'UZ')
    ->> 'seeded')::boolean,
  'the manual badge seed finds the account by e-mail');
select pg_temp.sv_check(
  (public.qa_service_seed_manual_expert('SERVICE-OWNER@x', 'forensic_physician', 'UZ')
    ->> 'seeded')::boolean,
  'the seed is idempotent and case-insensitive');
select pg_temp.sv_check(
  (public.qa_service_seed_manual_expert('nobody@nowhere', 'forensic_physician', 'UZ')
    ->> 'seeded')::boolean = false,
  'seeding an account that does not exist changes nothing');
reset role;
select pg_temp.sv_check((select count(*) = 1 from public.qa_profiles
  where user_id = '50000000-0000-0000-0000-0000000000b2'
    and status = 'verified' and manual and reason = 'manual_check'),
  'the owner has exactly one hand-checked verified profile row');
select pg_temp.sv_check(not exists (
  select 1 from public.qa_profiles p
  where p.reason like '%@%' or p.role like '%@%' or p.country_code like '%@%'),
  'no e-mail is stored in the Q&A profile');

-- An automatic re-check must not quietly drop the hand-checked flag.
set role service_role;
select public.qa_service_set_status('50000000-0000-0000-0000-0000000000b2',
  'forensic_physician', 'UZ', 'verified', 'document_ok', false);
reset role;
select pg_temp.sv_check((select manual from public.qa_profiles
  where user_id = '50000000-0000-0000-0000-0000000000b2'),
  'a later automatic check keeps the hand-checked flag');

-- ------------------------------------------------- translation cache
-- A published question from the community test file.
select id as q_id from public.qa_questions
where status = 'published' order by created_at limit 1
\gset

set role service_role;
select pg_temp.sv_check(
  public.qa_service_translatable('question', :'q_id') ->> 'body' is not null,
  'the service can read a published question for translation');
select pg_temp.sv_check(
  (public.qa_service_translatable('question', :'q_id')) ? 'author_id' = false,
  'the translatable payload carries no author id');
select pg_temp.sv_check(
  public.qa_service_translatable('question',
    '00000000-0000-0000-0000-000000000000') is null,
  'an unknown question is not translatable');
select pg_temp.sv_blocked($$select public.qa_service_translatable('user',
  '00000000-0000-0000-0000-000000000000')$$,
  'only questions and answers are translatable');

select public.qa_service_translation_put('question', :'q_id', 'en',
  'Machine title', 'Machine body', 'cf:@cf/meta/m2m100-1.2b');
select public.qa_service_translation_put('question', :'q_id', 'en',
  'Machine title 2', 'Machine body 2', 'gemini:test');
reset role;
select pg_temp.sv_check((select count(*) = 1 from public.qa_translations
  where target_type = 'question' and target_id = :'q_id' and lang = 'en'),
  'one cache row per post and language');
select pg_temp.sv_check((select body = 'Machine body 2' and engine = 'gemini:test'
  from public.qa_translations
  where target_type = 'question' and target_id = :'q_id' and lang = 'en'),
  'a second translation replaces the cached one');

-- The reader gets the cached text through their own RPC.
select pg_temp.sv_as_user('50000000-0000-0000-0000-0000000000b1');
select pg_temp.sv_check(
  public.qa_translation('question', :'q_id', 'en') ->> 'engine' = 'gemini:test',
  'the app reads the cache through qa_translation and sees which engine wrote it');
select pg_temp.sv_check(
  public.qa_translation('question',
    '00000000-0000-0000-0000-000000000000', 'ru') is null,
  'a post that was never translated has no cache row');
reset role;

-- ------------------------------------------------- the daily work counter
set role service_role;
select public.qa_service_bump('50000000-0000-0000-0000-0000000000b1', 'translate', 2);
select public.qa_service_bump('50000000-0000-0000-0000-0000000000b1', 'translate', 2);
select pg_temp.sv_blocked($$select public.qa_service_bump(
  '50000000-0000-0000-0000-0000000000b1', 'translate', 2)$$,
  'the daily translation cap is enforced server-side');
reset role;
-- The refused call raises, so its own increment is rolled back: the counter
-- stays at the cap instead of drifting past it.
select pg_temp.sv_check((select n = 2 from public.qa_rate
  where user_id = '50000000-0000-0000-0000-0000000000b1'
    and day = current_date and kind = 'translate'),
  'the translation counter is per user, per day and per kind');
select pg_temp.sv_check((select count(*) = 2 from public.qa_rate
  where user_id = '50000000-0000-0000-0000-0000000000b1' and day = current_date),
  'the verify and translate counters are kept apart');

\echo 'qa_service_api_test.sql: all assertions passed'
