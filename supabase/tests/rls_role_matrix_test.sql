-- RLS / privilege ROLE MATRIX: anon, STUDENT, EXPERT, MODERATOR, ADMIN.
--
-- Runs on its own fresh database (see run_local.sh): stubs.sql +
-- stubs_supabase_defaults.sql (Supabase-like default table grants, so RLS
-- and the migrations' REVOKEs are the only barrier) + all migrations.
--
-- Roles (auth.users rows; the role is what the server knows, never e-mail):
--   anon      — not signed in (role anon, no JWT subject)
--   STUDENT s — plain authenticated user
--   EXPERT  e — authenticated + professional_profiles row + verification
--               VERIFIED_PROFESSIONAL (+ a credential document, Pro grant)
--   MOD     m — authenticated + account_roles publication_moderator (NOT admin)
--   ADMIN   a — authenticated + account_roles identity_admin
--
-- Rule checked for every table and role: direct SELECT of rows the role does
-- not own returns nothing (or errors), direct INSERT / UPDATE / DELETE fails
-- or touches 0 rows. Ownership and admin rights are only exercised through
-- the SECURITY DEFINER RPCs, and admin can only do what those RPCs allow.
\set ON_ERROR_STOP 1
\pset tuples_only on
\pset format unaligned
reset role;

create function pg_temp.as_user(uid text) returns void language plpgsql as $$
begin
  perform set_config('request.jwt.claim.sub', uid, false);
  perform set_config('request.jwt.claims', '{}', false);
  perform set_config('role', 'authenticated', false);
end $$;
create function pg_temp.as_anon() returns void language plpgsql as $$
begin
  perform set_config('request.jwt.claim.sub', '', false);
  perform set_config('request.jwt.claims', '{}', false);
  perform set_config('role', 'anon', false);
end $$;
create function pg_temp.check(ok boolean, label text) returns void language plpgsql as $$
begin
  if not coalesce(ok, false) then raise exception 'FAIL: %', label; end if;
  raise notice 'PASS: %', label;
end $$;
-- Must raise (any error).
create function pg_temp.expect_error(q text, label text) returns void language plpgsql as $$
begin
  begin execute q; exception when others then
    raise notice 'PASS (blocked %): %', sqlstate, label; return; end;
  raise exception 'FAIL (allowed): %', label;
end $$;
-- Must raise insufficient_privilege (no grant / RLS WITH CHECK violation).
create function pg_temp.expect_42501(q text, label text) returns void language plpgsql as $$
begin
  begin execute q; exception
    when insufficient_privilege then raise notice 'PASS (42501): %', label; return;
    when others then raise exception 'FAIL (wrong error %: %): %', sqlstate, sqlerrm, label;
  end;
  raise exception 'FAIL (allowed): %', label;
end $$;
-- Must raise, or touch / return zero rows.
create function pg_temp.denied(q text, label text) returns void language plpgsql as $$
declare n bigint;
begin
  begin
    execute q;
    get diagnostics n = row_count;
  exception when others then
    raise notice 'PASS (blocked %): %', sqlstate, label; return;
  end;
  if n > 0 then raise exception 'FAIL (% rows): %', n, label; end if;
  raise notice 'PASS (0 rows): %', label;
end $$;
-- Must succeed and return / touch at least one row.
create function pg_temp.allowed(q text, label text) returns void language plpgsql as $$
declare n bigint;
begin
  execute q;
  get diagnostics n = row_count;
  if n = 0 then raise exception 'FAIL (0 rows): %', label; end if;
  raise notice 'PASS (% rows): %', n, label;
end $$;

-- Every client-facing table. owner: column that marks a row as the caller's
-- (rows matching auth.uid() are excluded from the "not owner" checks);
-- public_read: readable by everyone BY DESIGN (published reviews/records);
-- admin_read: identity_admin has a SELECT policy (verification workflow).
create temp table matrix_tables (t text primary key, owner text, public_read boolean,
  admin_read boolean, col text);
insert into matrix_tables values
 ('public.support_threads',        null,           false, false, 'subject'),
 ('public.support_messages',       null,           false, false, 'body'),
 ('public.access_grants',          null,           false, false, 'tier'),
 ('public.user_devices',           null,           false, false, 'locale'),
 ('public.account_roles',          'user_id',      false, false, 'granted_at'),
 ('public.ai_usage',               'user_id',      false, false, 'created_at'),
 ('public.email_otp_codes',        null,           false, false, 'attempts'),
 ('public.referral_config',        null,           false, false, 'rewards_enabled'),
 ('public.referral_codes',         null,           false, false, 'code'),
 ('public.referrals',              null,           false, false, 'status'),
 ('public.referral_rewards',       null,           false, false, 'status'),
 ('public.publications',           null,           false, false, 'title'),
 ('public.publication_reviews',    null,           false, false, 'comment'),
 ('public.publication_events',     null,           false, false, 'note'),
 ('public.publication_reports',    null,           false, false, 'status'),
 ('public.professional_profiles',  'user_id',      false, true,  'bio'),
 ('public.verification',           'user_id',      false, true,  'status'),
 ('public.credential_documents',   'user_id',      false, true,  'kind'),
 ('public.verification_decisions', 'applicant_id', false, true,  'reason'),
 ('public.verifier_grants',        'user_id',      false, false, 'revoked_at'),
 ('public.reviewer_scopes',        null,           true,  false, 'revoked_at'),
 ('public.professional_reviews',   null,           true,  false, 'created_at'),
 ('public.review_audit',           null,           true,  false, 'at'),
 ('public.content_records',        null,           true,  false, 'record_id'),
 ('private.admin_audit',           null,           false, false, 'action'),
 ('private.admin_settings',        null,           false, false, 'admin_requires_aal2'),
 ('private.referral_secret',       null,           false, false, 'id'),
 ('private.account_email_history', null,           false, false, 'email_hash'),
 ('private.referral_audit',        null,           false, false, 'event'),
 -- «Savol-javob»: no policy at all, so every role is denied directly and
 -- only the SECURITY DEFINER functions let anything through.
 ('public.qa_profiles',            'user_id',      false, false, 'status'),
 ('public.qa_rate',                'user_id',      false, false, 'n'),
 ('public.qa_questions',           'author_id',    false, false, 'title'),
 ('public.qa_answers',             'author_id',    false, false, 'body'),
 ('public.qa_votes',               'voter_id',     false, false, 'value'),
 ('public.qa_reports',             'reporter_id',  false, false, 'reason'),
 ('public.qa_translations',        null,           false, false, 'body');
grant select on matrix_tables to anon, authenticated;

-- Fix the column used for the no-op UPDATE to a real column of each table.
update matrix_tables m set col = (select c.column_name from information_schema.columns c
  where c.table_schema || '.' || c.table_name = m.t order by c.ordinal_position limit 1)
where not exists (select 1 from information_schema.columns c
  where c.table_schema || '.' || c.table_name = m.t and c.column_name = m.col);
select pg_temp.check((select count(*) = 0 from matrix_tables m where not exists
  (select 1 from information_schema.tables x where x.table_schema || '.' || x.table_name = m.t)),
  'matrix lists only existing tables');
select pg_temp.check((select count(*) = 0 from pg_class c join pg_namespace n on n.oid = c.relnamespace
  where c.relkind = 'r' and n.nspname in ('public', 'private')
    and n.nspname || '.' || c.relname not in (select t from matrix_tables)),
  'every public/private table is in the matrix (new tables must be added here)');
select pg_temp.check((select bool_and(c.relrowsecurity) from pg_class c join pg_namespace n
  on n.oid = c.relnamespace where c.relkind = 'r' and n.nspname in ('public', 'private')),
  'RLS enabled on every public/private table');

grant execute on function pg_temp.as_user(text), pg_temp.as_anon(), pg_temp.check(boolean, text),
  pg_temp.expect_error(text, text), pg_temp.expect_42501(text, text),
  pg_temp.denied(text, text), pg_temp.allowed(text, text) to anon, authenticated;

-- Generic per-table checks for the CURRENT role.
create function pg_temp.table_matrix(who text) returns void language plpgsql as $$
declare r record; me uuid := auth.uid(); is_admin boolean; not_mine text;
begin
  is_admin := who = 'ADMIN';
  for r in select * from matrix_tables order by t loop
    not_mine := case when r.owner is null or me is null then 'true'
                     else format('%I is distinct from %L::uuid', r.owner, me) end;
    if not r.public_read and not (is_admin and r.admin_read) then
      perform pg_temp.denied(format('select * from %s where %s', r.t, not_mine),
        format('%s: SELECT others'' rows of %s', who, r.t));
    end if;
    perform pg_temp.denied(format('update %s set %I = %I where %s', r.t, r.col, r.col, not_mine),
      format('%s: UPDATE others'' rows of %s', who, r.t));
    perform pg_temp.denied(format('delete from %s where %s', r.t, not_mine),
      format('%s: DELETE others'' rows of %s', who, r.t));
    -- ai_usage: a signed-in user may append to their OWN counter (by design,
    -- checked explicitly below); every other table refuses inserts.
    if not (r.t = 'public.ai_usage' and me is not null) then
      perform pg_temp.expect_error(format('insert into %s default values', r.t),
        format('%s: INSERT into %s', who, r.t));
    end if;
  end loop;
end $$;
grant execute on function pg_temp.table_matrix(text) to anon, authenticated;

-- ------------------------------------------------------------------ seed
insert into auth.users (id, email, created_at, email_confirmed_at) values
 ('50000000-0000-0000-0000-00000000000a', 'student@matrix.test', now() - interval '3 days', now()),
 ('50000000-0000-0000-0000-00000000000b', 'expert@matrix.test', now() - interval '1 day', now()),
 ('50000000-0000-0000-0000-00000000000c', 'admin@matrix.test', now() - interval '90 days', now()),
 ('50000000-0000-0000-0000-00000000000d', 'moderator@matrix.test', now() - interval '30 days', now());
insert into account_roles (user_id, role, granted_by) values
 ('50000000-0000-0000-0000-00000000000c', 'identity_admin', '50000000-0000-0000-0000-00000000000d'),
 ('50000000-0000-0000-0000-00000000000d', 'publication_moderator', '50000000-0000-0000-0000-00000000000c');
insert into professional_profiles (user_id, display_name, country_code, organization, position,
  primary_specialty, education, work_email, license_number) values
 ('50000000-0000-0000-0000-00000000000b', 'Matrix Expert', 'UZ', 'Lab', 'Chemist',
  'forensicToxicology', 'Pharma institute', 'private@lab.test', 'LIC-123');
insert into verification (user_id, status, decided_by, decided_at, internal_note) values
 ('50000000-0000-0000-0000-00000000000b', 'VERIFIED_PROFESSIONAL',
  '50000000-0000-0000-0000-00000000000c', now(), 'internal reviewer note');
insert into credential_documents (user_id, kind, mime_type, size_bytes, sha256, storage_key) values
 ('50000000-0000-0000-0000-00000000000b', 'diploma', 'application/pdf', 1000, repeat('a', 64),
  '50000000-0000-0000-0000-00000000000b/diploma.pdf');
insert into verification_decisions (applicant_id, approver_id, approver_kind, decision, scope,
  reason, from_status, to_status, checked_documents)
  select '50000000-0000-0000-0000-00000000000b', '50000000-0000-0000-0000-00000000000c', 'identity_admin',
  'VERIFY', (enum_range(null::reviewer_scope))[1], 'Documents checked', 'UNVERIFIED', 'VERIFIED_PROFESSIONAL',
  array[document_id] from credential_documents;
insert into verifier_grants (user_id, scope, granted_by) values
 ('50000000-0000-0000-0000-00000000000b', (enum_range(null::reviewer_scope))[1],
  '50000000-0000-0000-0000-00000000000c');
insert into access_grants (user_id, tier) values ('50000000-0000-0000-0000-00000000000b', 'professionalPro');
insert into ai_usage (user_id) values ('50000000-0000-0000-0000-00000000000a'),
  ('50000000-0000-0000-0000-00000000000b');
insert into email_otp_codes (email, code_hash, expires_at) values
 ('student@matrix.test', repeat('b', 64), now() + interval '10 minutes');
insert into storage.objects (bucket_id, name) values
 ('support-attachments', '50000000-0000-0000-0000-00000000000a/aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa.png'),
 ('support-attachments', '50000000-0000-0000-0000-00000000000b/bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb.jpg'),
 ('credentials', '50000000-0000-0000-0000-00000000000b/diploma.pdf');

create temp table ids (k text primary key, id uuid);
grant all on ids to anon, authenticated;

-- Flows through the RPCs (as each user) create the remaining rows.
\o /dev/null
select pg_temp.as_user('50000000-0000-0000-0000-00000000000a');
insert into ids select 'ts', (create_support_thread('SUGGESTION', 'Dark theme', 'Please add a dark theme.',
  '50000000-0000-0000-0000-00000000000a/aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa.png', true)->>'id')::uuid;
select register_device('android', '0.4.3', 'uz', 'UZ');
select referral_dashboard();
select pg_temp.as_user('50000000-0000-0000-0000-00000000000b');
insert into ids select 'te', (create_support_thread('SCIENTIFIC_ERROR', 'Error in: Ethanol',
  'Half-life differs from the source.', null, true, 'substance:ethanol')->>'id')::uuid;
select register_device('ios', '0.4.3', 'ru', 'KZ');
insert into ids select 'pe', save_draft(null, '{"title":"Ethanol by HS-GC-FID",
  "abstract":"Validation data","discipline_code":"forensic_toxicology","rights_confirmed":true,
  "publication_consent":true,"no_personal_data_confirmed":true}'::jsonb);
select pg_temp.check(submit_publication((select id from ids where k = 'pe')) = 'SUBMITTED', 'seed: expert submits');
select pg_temp.as_user('50000000-0000-0000-0000-00000000000d');
select pg_temp.check(moderate_publication((select id from ids where k = 'pe'), 'SCREENING', null) = 'SCREENING',
  'seed: moderator screens');
select moderate_publication((select id from ids where k = 'pe'), 'IN_REVIEW', null);
select moderate_publication((select id from ids where k = 'pe'), 'APPROVED', 'ok');
select pg_temp.check(moderate_publication((select id from ids where k = 'pe'), 'PUBLISHED', null) = 'PUBLISHED',
  'seed: moderator publishes');
select pg_temp.as_user('50000000-0000-0000-0000-00000000000a');
select pg_temp.check(report_publication((select id from ids where k = 'pe'), 'ABUSE', 'test')
  is not null, 'seed: student reports');
select pg_temp.as_user('50000000-0000-0000-0000-00000000000c');
select pg_temp.check(admin_reply_support((select id from ids where k = 'ts'), 'Thanks, planned.') = 'SENT',
  'seed: admin replies');
\o
reset role;
-- Referral rows (claim rules are covered by referral_test.sql).
insert into referrals (referrer_id, referred_id, code, status)
  select '50000000-0000-0000-0000-00000000000a', '50000000-0000-0000-0000-00000000000b', code, 'VALID'
  from referral_codes where user_id = '50000000-0000-0000-0000-00000000000a';
insert into referral_rewards (referral_id, referrer_id, referred_user_id, reward_percent,
  purchase_amount_minor, reward_amount_minor, currency, source_transaction)
  select id, referrer_id, referred_id, 10, 1000, 100, 'USD', 'matrix-tx-1' from referrals;
insert into private.admin_audit (action) select 'MATRIX_SEED' where not exists (select 1 from private.admin_audit);
insert into private.referral_audit (event) select 'MATRIX_SEED'
  where not exists (select 1 from private.referral_audit);
insert into private.account_email_history (email_hash) select repeat('c', 64)
  where not exists (select 1 from private.account_email_history);
insert into content_records (record_id, published_version) select 'matrix-record', '1' where not exists (select 1 from content_records);

-- «Savol-javob» rows: b is a verified expert, a asks, d reports.
insert into qa_profiles (user_id, role, country_code, status, reason, decided_at)
values ('50000000-0000-0000-0000-00000000000b', 'forensic_chemist', 'UZ', 'verified',
        'document_ok', now());
insert into qa_rate (user_id, day, kind, n)
values ('50000000-0000-0000-0000-00000000000a', current_date, 'ask', 1);
insert into qa_questions (id, author_id, lang, title, body, tags)
values ('60000000-0000-0000-0000-0000000000b1'::uuid,
        '50000000-0000-0000-0000-00000000000a', 'uz',
        'Matritsa testi uchun savol sarlavhasi',
        'Matritsa testi uchun yetarlicha uzun savol matni.', array['methods']);
insert into qa_answers (id, question_id, author_id, lang, body)
values ('60000000-0000-0000-0000-0000000000b2'::uuid,
        '60000000-0000-0000-0000-0000000000b1'::uuid,
        '50000000-0000-0000-0000-00000000000b', 'uz',
        'Matritsa testi uchun yetarlicha uzun javob matni.');
insert into qa_votes (answer_id, voter_id, value)
values ('60000000-0000-0000-0000-0000000000b2'::uuid,
        '50000000-0000-0000-0000-00000000000d', 1);
insert into qa_reports (target_type, target_id, reporter_id, reason)
values ('answer', '60000000-0000-0000-0000-0000000000b2',
        '50000000-0000-0000-0000-00000000000d', 'matritsa testi');
insert into qa_translations (target_type, target_id, lang, title, body, engine)
values ('question', '60000000-0000-0000-0000-0000000000b1'::uuid, 'ru',
        'Вопрос', 'Текст', 'matrix-seed');

-- Every table must hold rows, otherwise "0 rows touched" proves nothing.
do $$
declare r record; n bigint; empty text[] := '{}';
begin
  for r in select t from matrix_tables loop
    execute format('select count(*) from %s', r.t) into n;
    if n = 0 then empty := empty || r.t; end if;
  end loop;
  -- Tables with no client write path and no production rows yet are allowed
  -- to be empty only if listed here explicitly.
  empty := array(select unnest(empty) except select unnest(array[
    'public.professional_reviews', 'public.review_audit', 'public.reviewer_scopes']));
  if cardinality(empty) > 0 then raise exception 'FAIL: matrix tables without seed rows: %', empty; end if;
  raise notice 'PASS: every matrix table has seed rows';
end $$;

-- ============================================================== ANON
select pg_temp.as_anon();
select pg_temp.table_matrix('ANON');
select pg_temp.denied($q$select * from storage.objects where bucket_id in ('support-attachments', 'credentials')$q$,
  'ANON: read storage support-attachments / credentials');
select pg_temp.expect_42501($q$insert into storage.objects (bucket_id, name) values ('support-attachments',
  '50000000-0000-0000-0000-00000000000a/cccccccc-cccc-4ccc-8ccc-cccccccccccc.png')$q$, 'ANON: upload attachment');
select pg_temp.denied($q$delete from storage.objects$q$, 'ANON: delete storage objects');
select pg_temp.expect_error($q$select my_support_threads()$q$, 'ANON: my_support_threads');
select pg_temp.expect_error($q$select create_support_thread('BUG', 'a', 'b', null, true)$q$, 'ANON: create_support_thread');
select pg_temp.expect_error($q$select support_thread((select id from ids where k = 'ts'))$q$, 'ANON: support_thread');
select pg_temp.expect_error($q$select add_support_message((select id from ids where k = 'ts'), 'x', null)$q$, 'ANON: add_support_message');
select pg_temp.expect_error($q$select support_unread_count()$q$, 'ANON: support_unread_count');
select pg_temp.expect_error($q$select my_access()$q$, 'ANON: my_access');
select pg_temp.expect_error($q$select register_device('android', '1', 'uz', 'UZ')$q$, 'ANON: register_device');
select pg_temp.expect_error($q$select referral_dashboard()$q$, 'ANON: referral_dashboard');
select pg_temp.expect_error($q$select claim_referral('ABCDEF')$q$, 'ANON: claim_referral');
select pg_temp.expect_error($q$select my_publications()$q$, 'ANON: my_publications');
select pg_temp.expect_error($q$select save_draft(null, '{}'::jsonb)$q$, 'ANON: save_draft');
select pg_temp.expect_error($q$select moderation_queue()$q$, 'ANON: moderation_queue');
select pg_temp.expect_error($q$select admin_stats()$q$, 'ANON: admin_stats');
select pg_temp.expect_error($q$select admin_dashboard()$q$, 'ANON: admin_dashboard');
select pg_temp.expect_error($q$select admin_support_inbox()$q$, 'ANON: admin_support_inbox');
select pg_temp.expect_error($q$select admin_users()$q$, 'ANON: admin_users');
select pg_temp.expect_error($q$select admin_audit_log(10)$q$, 'ANON: admin_audit_log');
select pg_temp.expect_error($q$select admin_set_access('student@matrix.test', 'studentPro')$q$, 'ANON: admin_set_access');
select pg_temp.expect_error($q$select award_referral_reward('50000000-0000-0000-0000-00000000000b', 'tx', 100, 'USD')$q$,
  'ANON: award_referral_reward (service only)');
-- Public by design: published list (no drafts, no author ids).
select pg_temp.check((select jsonb_array_length(l) = 1 and l::text not ilike '%50000000-0000-0000-0000-00000000000b%'
  from (select list_published() l) x), 'ANON: list_published shows only PUBLISHED, no author id');

-- ============================================================== STUDENT
select pg_temp.as_user('50000000-0000-0000-0000-00000000000a');
select pg_temp.table_matrix('STUDENT');
-- Own rows: only what policies allow.
select pg_temp.check((select count(*) = 0 from account_roles), 'STUDENT: sees no roles (has none)');
select pg_temp.allowed($q$select * from ai_usage$q$, 'STUDENT: reads own ai_usage');
select pg_temp.check((select bool_and(user_id = auth.uid()) from ai_usage), 'STUDENT: ai_usage only own rows');
select pg_temp.allowed($q$insert into ai_usage (user_id) values (auth.uid())$q$, 'STUDENT: may insert own ai_usage (counter)');
select pg_temp.expect_42501($q$insert into ai_usage (user_id) values ('50000000-0000-0000-0000-00000000000b')$q$,
  'STUDENT: cannot insert ai_usage for another user');
select pg_temp.denied($q$delete from ai_usage where user_id = auth.uid()$q$, 'STUDENT: cannot delete own ai_usage (reset quota)');
select pg_temp.denied($q$update ai_usage set created_at = now() - interval '2 days' where user_id = auth.uid()$q$,
  'STUDENT: cannot backdate own ai_usage');
-- Privilege escalation attempts.
select pg_temp.expect_42501($q$insert into account_roles (user_id, role, granted_by) values
  (auth.uid(), 'identity_admin', '50000000-0000-0000-0000-00000000000c')$q$, 'STUDENT: self-grant identity_admin');
select pg_temp.expect_42501($q$insert into account_roles (user_id, role, granted_by) values
  (auth.uid(), 'publication_moderator', '50000000-0000-0000-0000-00000000000c')$q$, 'STUDENT: self-grant publication_moderator');
select pg_temp.expect_42501($q$insert into access_grants (user_id, tier) values (auth.uid(), 'professionalPro')$q$,
  'STUDENT: self-grant Pro');
select pg_temp.expect_42501($q$insert into verification (user_id, status) values (auth.uid(), 'VERIFIED_PROFESSIONAL')$q$,
  'STUDENT: self-verify');
select pg_temp.expect_42501($q$insert into support_messages (thread_id, sender_role, body)
  values ((select id from ids where k = 'ts'), 'ADMIN', 'forged admin reply')$q$, 'STUDENT: forge admin message');
select pg_temp.expect_42501($q$insert into publications (author_id, status, title) values (auth.uid(), 'PUBLISHED', 'x')$q$,
  'STUDENT: publish directly');
select pg_temp.expect_42501($q$insert into referral_rewards (referrer_id, reward_percent, purchase_amount_minor,
  reward_amount_minor, currency, source_transaction) values (auth.uid(), 100, 1, 1, 'USD', 'fake')$q$, 'STUDENT: forge reward');
select pg_temp.expect_42501($q$insert into professional_profiles (user_id, display_name, country_code, organization,
  position, primary_specialty, education) values ('50000000-0000-0000-0000-00000000000b', 'x', 'UZ', 'x', 'x', 'x', 'x')$q$,
  'STUDENT: create a profile for another user');
-- Storage: own folder only, no delete/overwrite of others.
select pg_temp.check((select count(*) = 1 from storage.objects where bucket_id = 'support-attachments'),
  'STUDENT: storage lists only own attachment');
select pg_temp.denied($q$select * from storage.objects where bucket_id = 'credentials'$q$, 'STUDENT: other''s credentials');
select pg_temp.expect_42501($q$insert into storage.objects (bucket_id, name) values ('support-attachments',
  '50000000-0000-0000-0000-00000000000b/dddddddd-dddd-4ddd-8ddd-dddddddddddd.png')$q$, 'STUDENT: upload into expert''s folder');
select pg_temp.allowed($q$insert into storage.objects (bucket_id, name) values ('support-attachments',
  '50000000-0000-0000-0000-00000000000a/eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee.png')$q$, 'STUDENT: upload into own folder');
select pg_temp.denied($q$update storage.objects set name = '50000000-0000-0000-0000-00000000000a/x.png'
  where name like '50000000-0000-0000-0000-00000000000b/%'$q$, 'STUDENT: rename expert''s object');
select pg_temp.denied($q$delete from storage.objects where name like '50000000-0000-0000-0000-00000000000b/%'$q$,
  'STUDENT: delete expert''s object');
-- RPC ownership.
select pg_temp.check(jsonb_array_length(my_support_threads()) = 1, 'STUDENT: my_support_threads = own only');
select pg_temp.check((select support_thread((select id from ids where k = 'ts')) is not null), 'STUDENT: opens own thread');
select pg_temp.expect_error($q$select support_thread((select id from ids where k = 'te'))$q$, 'STUDENT: open expert''s thread');
select pg_temp.check(add_support_message((select id from ids where k = 'te'), 'hijack', null) = 'NOT_FOUND',
  'STUDENT: post into expert''s thread');
select pg_temp.expect_error($q$select mark_support_read((select id from ids where k = 'te'))$q$, 'STUDENT: mark expert''s thread');
select pg_temp.check(create_support_thread('BUG', 'x', 'y',
  '50000000-0000-0000-0000-00000000000b/bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb.jpg', true)->>'result' = 'INVALID',
  'STUDENT: attach expert''s file');
select pg_temp.check((select (a->>'is_admin')::boolean = false and a->>'tier' is null from (select my_access() a) x),
  'STUDENT: my_access not admin, no tier');
select pg_temp.check(not can_moderate_publications(), 'STUDENT: cannot moderate');
select pg_temp.expect_error($q$select moderation_queue()$q$, 'STUDENT: moderation_queue');
select pg_temp.expect_error($q$select moderate_publication((select id from ids where k = 'pe'), 'RETRACTED', 'x')$q$,
  'STUDENT: moderate_publication');
select pg_temp.expect_error($q$select save_draft((select id from ids where k = 'pe'), '{"title":"hijack"}'::jsonb)$q$,
  'STUDENT: edit expert''s publication');
select pg_temp.check((select bool_and(p->>'id' <> (select id::text from ids where k = 'pe'))
  or count(*) = 0 from jsonb_array_elements(my_publications()) p), 'STUDENT: my_publications excludes expert''s');
select pg_temp.expect_error($q$select decide_identity('50000000-0000-0000-0000-00000000000b', 'SUSPEND',
  (enum_range(null::reviewer_scope))[1], '{}', 'malicious', null)$q$, 'STUDENT: decide_identity');
select pg_temp.expect_error($q$select award_referral_reward('50000000-0000-0000-0000-00000000000b', 'tx2', 100, 'USD')$q$,
  'STUDENT: award_referral_reward');
select pg_temp.expect_error($q$select set_referral_reward_status('matrix-tx-1', 'APPROVED')$q$,
  'STUDENT: set_referral_reward_status');
select pg_temp.expect_error($q$select private.admin_guard()$q$, 'STUDENT: private.admin_guard');
select pg_temp.expect_error($q$select private.admin_log(auth.uid(), 'FAKE', null, null, '{}')$q$, 'STUDENT: private.admin_log');
select pg_temp.check((select d->>'code' is not null from (select referral_dashboard() d) x), 'STUDENT: own referral dashboard');
-- Every admin RPC is refused.
select pg_temp.expect_error($q$select admin_stats()$q$, 'STUDENT: admin_stats');
select pg_temp.expect_error($q$select admin_dashboard()$q$, 'STUDENT: admin_dashboard');
select pg_temp.expect_error($q$select admin_support_inbox()$q$, 'STUDENT: admin_support_inbox');
select pg_temp.expect_error($q$select admin_reply_support((select id from ids where k = 'te'), 'x')$q$, 'STUDENT: admin_reply_support');
select pg_temp.expect_error($q$select admin_set_support_status((select id from ids where k = 'ts'), 'CLOSED')$q$,
  'STUDENT: admin_set_support_status (even own thread)');
select pg_temp.expect_error($q$select admin_users()$q$, 'STUDENT: admin_users');
select pg_temp.expect_error($q$select admin_audit_log(10)$q$, 'STUDENT: admin_audit_log');
select pg_temp.expect_error($q$select admin_set_access('student@matrix.test', 'professionalPro')$q$,
  'STUDENT: admin_set_access (self)');

-- ============================================================== EXPERT
select pg_temp.as_user('50000000-0000-0000-0000-00000000000b');
select pg_temp.table_matrix('EXPERT');
select pg_temp.allowed($q$select * from professional_profiles where user_id = auth.uid()$q$, 'EXPERT: reads own profile');
select pg_temp.allowed($q$update professional_profiles set bio = 'Toxicologist' where user_id = auth.uid()$q$,
  'EXPERT: updates own profile');
select pg_temp.allowed($q$select * from verification where user_id = auth.uid()$q$, 'EXPERT: reads own verification');
select pg_temp.denied($q$update verification set status = 'VERIFIED_PROFESSIONAL', internal_note = null
  where user_id = auth.uid()$q$, 'EXPERT: cannot change own verification');
select pg_temp.denied($q$delete from verification where user_id = auth.uid()$q$, 'EXPERT: cannot delete own verification');
select pg_temp.allowed($q$select * from credential_documents where user_id = auth.uid()$q$, 'EXPERT: reads own documents');
select pg_temp.denied($q$delete from credential_documents where user_id = auth.uid()$q$,
  'EXPERT: cannot delete own documents directly');
select pg_temp.allowed($q$select * from verifier_grants where user_id = auth.uid()$q$, 'EXPERT: reads own verifier grant');
select pg_temp.denied($q$update verifier_grants set revoked_at = null where user_id = auth.uid()$q$,
  'EXPERT: cannot edit own verifier grant');
select pg_temp.denied($q$select * from access_grants$q$, 'EXPERT: access_grants not readable even own (my_access only)');
select pg_temp.denied($q$update access_grants set expires_at = null$q$, 'EXPERT: cannot extend own Pro');
select pg_temp.expect_42501($q$insert into account_roles (user_id, role, granted_by) values
  (auth.uid(), 'identity_admin', '50000000-0000-0000-0000-00000000000c')$q$, 'EXPERT: self-grant identity_admin');
select pg_temp.check((select (a->>'is_admin')::boolean = false and a->>'tier' = 'professionalPro'
  from (select my_access() a) x), 'EXPERT: my_access Pro but not admin');
select pg_temp.check(not can_moderate_publications(), 'EXPERT: verified professional is not a moderator');
select pg_temp.expect_error($q$select moderation_queue()$q$, 'EXPERT: moderation_queue');
select pg_temp.expect_error($q$select moderate_publication((select id from ids where k = 'pe'), 'RETRACTED', 'x')$q$,
  'EXPERT: moderate own publication');
select pg_temp.check(jsonb_array_length(my_support_threads()) = 1, 'EXPERT: my_support_threads = own only');
select pg_temp.expect_error($q$select support_thread((select id from ids where k = 'ts'))$q$, 'EXPERT: open student''s thread');
select pg_temp.check(add_support_message((select id from ids where k = 'ts'), 'hijack', null) = 'NOT_FOUND',
  'EXPERT: post into student''s thread');
select pg_temp.check((select count(*) = 1 from storage.objects where bucket_id = 'support-attachments'),
  'EXPERT: storage lists only own attachment');
select pg_temp.allowed($q$select * from storage.objects where bucket_id = 'credentials'$q$, 'EXPERT: own credentials file');
select pg_temp.expect_error($q$select admin_stats()$q$, 'EXPERT: admin_stats');
select pg_temp.expect_error($q$select admin_support_inbox()$q$, 'EXPERT: admin_support_inbox');
select pg_temp.expect_error($q$select admin_users()$q$, 'EXPERT: admin_users');
select pg_temp.expect_error($q$select admin_audit_log(10)$q$, 'EXPERT: admin_audit_log');
select pg_temp.expect_error($q$select admin_set_access('expert@matrix.test', null)$q$, 'EXPERT: admin_set_access');
select pg_temp.expect_error($q$select admin_reply_support((select id from ids where k = 'te'), 'self reply as team')$q$,
  'EXPERT: admin_reply_support on own thread');

-- ============================================================== MODERATOR (not admin)
select pg_temp.as_user('50000000-0000-0000-0000-00000000000d');
select pg_temp.table_matrix('MODERATOR');
select pg_temp.check(can_moderate_publications(), 'MODERATOR: can moderate publications');
select pg_temp.check((select moderation_queue() is not null), 'MODERATOR: moderation_queue');
select pg_temp.check((select (a->>'is_admin')::boolean = false from (select my_access() a) x), 'MODERATOR: my_access not admin');
select pg_temp.denied($q$select * from publications$q$, 'MODERATOR: publications table not readable directly');
select pg_temp.denied($q$select * from publication_reports$q$, 'MODERATOR: reports table not readable directly');
select pg_temp.expect_error($q$select admin_stats()$q$, 'MODERATOR: admin_stats');
select pg_temp.expect_error($q$select admin_dashboard()$q$, 'MODERATOR: admin_dashboard');
select pg_temp.expect_error($q$select admin_support_inbox()$q$, 'MODERATOR: admin_support_inbox');
select pg_temp.expect_error($q$select support_thread((select id from ids where k = 'ts'))$q$, 'MODERATOR: open a user''s thread');
select pg_temp.expect_error($q$select admin_reply_support((select id from ids where k = 'ts'), 'x')$q$, 'MODERATOR: admin_reply_support');
select pg_temp.expect_error($q$select admin_users()$q$, 'MODERATOR: admin_users');
select pg_temp.expect_error($q$select admin_audit_log(10)$q$, 'MODERATOR: admin_audit_log');
select pg_temp.expect_error($q$select admin_set_access('moderator@matrix.test', 'professionalPro')$q$,
  'MODERATOR: admin_set_access');
select pg_temp.expect_error($q$select decide_identity('50000000-0000-0000-0000-00000000000b', 'SUSPEND',
  (enum_range(null::reviewer_scope))[1], '{}', 'not my job', null)$q$, 'MODERATOR: decide_identity');
select pg_temp.check((select count(*) = 0 from storage.objects where bucket_id = 'support-attachments'),
  'MODERATOR: cannot read users'' attachments');
select pg_temp.denied($q$select * from professional_profiles$q$, 'MODERATOR: cannot read profiles');
select pg_temp.expect_42501($q$insert into account_roles (user_id, role, granted_by) values
  (auth.uid(), 'identity_admin', '50000000-0000-0000-0000-00000000000c')$q$, 'MODERATOR: self-promote to admin');

-- ============================================================== ADMIN
select pg_temp.as_user('50000000-0000-0000-0000-00000000000c');
select pg_temp.table_matrix('ADMIN');
-- Admin RPCs work …
select pg_temp.check((select (a->>'is_admin')::boolean from (select my_access() a) x), 'ADMIN: my_access is_admin');
select pg_temp.check((select admin_stats() is not null), 'ADMIN: admin_stats');
select pg_temp.check((select admin_dashboard() is not null), 'ADMIN: admin_dashboard');
select pg_temp.check((select (i->>'total')::int = 2 from (select admin_support_inbox() i) x), 'ADMIN: inbox sees all threads');
select pg_temp.check((select t->>'author_email' = 'expert@matrix.test'
  from (select support_thread((select id from ids where k = 'te')) t) x), 'ADMIN: opens any thread (audited)');
select pg_temp.check(admin_reply_support((select id from ids where k = 'te'), 'We will fix it.') = 'SENT', 'ADMIN: reply');
select pg_temp.check(admin_set_support_status((select id from ids where k = 'te'), 'CLOSED') = 'CLOSED', 'ADMIN: close thread');
select pg_temp.check((select (u->>'total')::int = 4 from (select admin_users() u) x), 'ADMIN: users list');
select pg_temp.check((select u::text not ilike '%private@lab.test%' and u::text not ilike '%LIC-123%'
  and u::text not ilike '%internal reviewer note%' from (select admin_users() u) x),
  'ADMIN: users list has no private profile fields');
select pg_temp.check((select jsonb_array_length(a) >= 1 from (select admin_audit_log(50) a) x), 'ADMIN: audit log');
select pg_temp.check(admin_set_access('student@matrix.test', 'studentPro') = 'GRANTED', 'ADMIN: grant Pro via RPC');
select pg_temp.check(admin_set_access('student@matrix.test', null) = 'REVOKED', 'ADMIN: revoke Pro via RPC');
select pg_temp.check(moderate_publication((select id from ids where k = 'pe'), 'RETRACTED', 'retract') = 'RETRACTED',
  'ADMIN: identity_admin may moderate publications');
select pg_temp.check((select count(*) = 3 from storage.objects where bucket_id = 'support-attachments'),
  'ADMIN: reads all support attachments');
select pg_temp.allowed($q$select * from professional_profiles where user_id <> auth.uid()$q$,
  'ADMIN: reads professional profiles (verification review policy)');
-- … but nothing outside the RPCs.
select pg_temp.denied($q$select * from support_threads$q$, 'ADMIN: support_threads not readable directly');
select pg_temp.denied($q$select * from support_messages$q$, 'ADMIN: support_messages not readable directly');
select pg_temp.denied($q$select * from private.admin_audit$q$, 'ADMIN: audit table not readable directly');
select pg_temp.denied($q$delete from private.admin_audit$q$, 'ADMIN: cannot erase audit');
select pg_temp.denied($q$update private.admin_settings set admin_requires_aal2 = false$q$, 'ADMIN: cannot switch off MFA setting');
select pg_temp.expect_42501($q$insert into account_roles (user_id, role, granted_by) values
  ('50000000-0000-0000-0000-00000000000a', 'identity_admin', auth.uid())$q$, 'ADMIN: cannot grant roles from the app');
select pg_temp.denied($q$delete from account_roles where user_id = '50000000-0000-0000-0000-00000000000d'$q$,
  'ADMIN: cannot revoke roles from the app');
select pg_temp.expect_42501($q$insert into access_grants (user_id, tier) values
  ('50000000-0000-0000-0000-00000000000a', 'professionalPro')$q$, 'ADMIN: access_grants only via admin_set_access');
select pg_temp.denied($q$select * from email_otp_codes$q$, 'ADMIN: cannot read OTP codes');
select pg_temp.denied($q$select * from ai_usage where user_id <> auth.uid()$q$, 'ADMIN: no direct ai_usage of others');
select pg_temp.denied($q$select * from referral_rewards$q$, 'ADMIN: no direct referral rewards');
select pg_temp.expect_error($q$select award_referral_reward('50000000-0000-0000-0000-00000000000b', 'tx3', 100, 'USD')$q$,
  'ADMIN: award_referral_reward is service-only');
select pg_temp.expect_error($q$select set_referral_reward_status('matrix-tx-1', 'APPROVED')$q$,
  'ADMIN: set_referral_reward_status is service-only');
select pg_temp.denied($q$update verification set status = 'SUSPENDED' where user_id = '50000000-0000-0000-0000-00000000000b'$q$,
  'ADMIN: verification only via decide_identity');
select pg_temp.denied($q$update professional_profiles set bio = 'edited by admin'$q$, 'ADMIN: cannot edit others'' profiles');
select pg_temp.expect_42501($q$insert into storage.objects (bucket_id, name) values ('support-attachments',
  '50000000-0000-0000-0000-00000000000a/ffffffff-ffff-4fff-8fff-ffffffffffff.png')$q$, 'ADMIN: cannot upload into a user''s folder');
select pg_temp.denied($q$delete from storage.objects where bucket_id = 'support-attachments'$q$,
  'ADMIN: cannot delete users'' attachments');
select pg_temp.expect_42501($q$insert into support_messages (thread_id, sender_role, body)
  values ((select id from ids where k = 'ts'), 'USER', 'impersonated user')$q$, 'ADMIN: cannot write messages directly');
select pg_temp.expect_error($q$select private.admin_log(auth.uid(), 'FAKE', null, null, '{}')$q$, 'ADMIN: private.admin_log');
-- The admin's identity never reaches the author.
select pg_temp.as_user('50000000-0000-0000-0000-00000000000b');
select pg_temp.check((select t::text not ilike '%admin@matrix.test%'
  and t::text not ilike '%50000000-0000-0000-0000-00000000000c%'
  from (select support_thread((select id from ids where k = 'te')) t) x), 'EXPERT: admin identity hidden in reply');
select pg_temp.check(add_support_message((select id from ids where k = 'te'), 'more', null) = 'CLOSED',
  'EXPERT: cannot write into a closed thread');

reset role;
select pg_temp.check((select count(*) >= 1 from private.admin_audit where action = 'SUPPORT_THREAD_VIEW'
  and actor_id = '50000000-0000-0000-0000-00000000000c'), 'admin thread view audited');
select pg_temp.check((select count(*) = 2 from private.admin_audit where action = 'ACCESS_SET'), 'admin access changes audited');
select pg_temp.check((select count(*) = 0 from account_roles where user_id = '50000000-0000-0000-0000-00000000000a'),
  'no role was granted to the student');
select pg_temp.check((select count(*) = 0 from access_grants where user_id = '50000000-0000-0000-0000-00000000000a'),
  'student holds no Pro grant after the matrix');
select 'ALL RLS ROLE MATRIX TESTS PASSED' as result;
