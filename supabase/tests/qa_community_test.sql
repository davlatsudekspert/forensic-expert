-- «Savol-javob (Hamjamiyat)» — permissions, limits, privacy filter, reports.
-- Runs after the other test files (roles and helpers already exist there).
--
-- Reading rows: every Q&A table has RLS on and no policy, so even a granted
-- role sees nothing. The test therefore inspects rows as the superuser
-- (`reset role`) and carries ids in psql variables.
\set ON_ERROR_STOP 1
reset role;
revoke all on public.qa_profiles, public.qa_rate, public.qa_questions,
  public.qa_answers, public.qa_votes, public.qa_reports, public.qa_translations
  from anon, authenticated;

create function pg_temp.qa_as(uid text) returns void language plpgsql as $$
begin
  perform set_config('request.jwt.claim.sub', uid, false);
  perform set_config('request.jwt.claims', '{}', false);
  perform set_config('role', 'authenticated', false);
end $$;
create function pg_temp.qa_anon() returns void language plpgsql as $$
begin
  perform set_config('request.jwt.claim.sub', '', false);
  perform set_config('role', 'anon', false);
end $$;
create function pg_temp.qa_blocked(q text, label text) returns void language plpgsql as $$
begin
  begin execute q; exception when others then
    raise notice 'PASS (blocked): %', label; return; end;
  raise exception 'FAIL (allowed): %', label;
end $$;
create function pg_temp.qa_check(ok boolean, label text) returns void language plpgsql as $$
begin
  if not coalesce(ok, false) then raise exception 'FAIL: %', label; end if;
  raise notice 'PASS: %', label;
end $$;
grant execute on function pg_temp.qa_as(text), pg_temp.qa_anon(),
  pg_temp.qa_blocked(text, text), pg_temp.qa_check(boolean, text) to anon, authenticated;

-- a1 asks, a2 and a3 are verified experts, a4/a5 ordinary readers,
-- a6 is identity_admin.
insert into auth.users (id, email, created_at, email_confirmed_at) values
 ('50000000-0000-0000-0000-0000000000a1', 'asker@x', now(), now()),
 ('50000000-0000-0000-0000-0000000000a2', 'expert-one@x', now(), now()),
 ('50000000-0000-0000-0000-0000000000a3', 'expert-two@x', now(), now()),
 ('50000000-0000-0000-0000-0000000000a4', 'reader@x', now(), now()),
 ('50000000-0000-0000-0000-0000000000a5', 'reader-two@x', now(), now()),
 ('50000000-0000-0000-0000-0000000000a6', 'qa-admin@x', now(), now());
insert into account_roles (user_id, role, granted_by)
values ('50000000-0000-0000-0000-0000000000a6', 'identity_admin', null);

-- ---------------------------------------------------------------- schema
select pg_temp.qa_check(not exists (
  select 1 from information_schema.columns
  where table_schema = 'public' and table_name like 'qa\_%'
    and (column_name ~* 'file|storage|path|url|image|photo|document|diploma'
         or column_name in ('full_name', 'display_name', 'email'))),
  'no column in the Q&A schema can hold a document, a file path or a name');
select pg_temp.qa_check((select count(*) = 7 from pg_tables
  where schemaname = 'public' and tablename like 'qa\_%' and rowsecurity),
  'row level security is on for all seven Q&A tables');
select pg_temp.qa_check(not exists (
  select 1 from pg_policies where schemaname = 'public' and tablename like 'qa\_%'),
  'the Q&A tables have no policy: everything goes through the functions');

-- ------------------------------------------------------------ privileges
select pg_temp.qa_anon();
select pg_temp.qa_blocked($$select public.qa_feed()$$, 'anon cannot read the feed');
select pg_temp.qa_blocked($$select public.qa_ask('uz','x','y')$$, 'anon cannot ask');
reset role;

select pg_temp.qa_as('50000000-0000-0000-0000-0000000000a1');
select pg_temp.qa_blocked($$select * from public.qa_questions$$,
  'a signed-in user cannot read the table directly');
select pg_temp.qa_blocked(
  $$insert into public.qa_profiles (user_id, role, country_code, status)
    values (auth.uid(), 'forensic_chemist', 'UZ', 'verified')$$,
  'a user cannot write their own badge');
select pg_temp.qa_blocked(
  $$select private.qa_set_expert_status(auth.uid(), 'forensic_chemist', 'UZ', 'verified', 'x')$$,
  'a user cannot call the server-side status setter');
select pg_temp.qa_check((public.qa_status()->'profile'->>'status') = 'unverified',
  'a new user is unverified');

-- --------------------------------------------------------------- asking
select pg_temp.qa_check(
  (public.qa_ask('uz', 'Etanolni aniqlashda ichki standart',
    'Qaysi ichki standart chirigan materialda ishonchli: n-propanol yoki tert-butanol?',
    array['toxicology', 'alcohol', 'not-a-tag'])->>'status') = 'published',
  'a clean question is published');
-- privacy filter: case number, examination number, name, date
select pg_temp.qa_check(
  (public.qa_ask('uz', 'Ish bo‘yicha savol — jinoyat ishi № 12/345',
    'Ekspertiza № 77-2026, Karimov A.B., 12.03.2026 kuni olingan namuna.',
    array['toxicology'])->>'status') = 'moderation',
  'a post with a case number and a name goes to moderation');
select pg_temp.qa_check((public.qa_feed()->>'total')::int = 1,
  'a moderated question is not in the feed');
-- daily limit: five questions a day
select public.qa_ask('uz', 'Uchinchi savol sarlavhasi', 'Yetarlicha uzun matn, uchinchi savol.');
select public.qa_ask('uz', 'To‘rtinchi savol sarlavhasi', 'Yetarlicha uzun matn, to‘rtinchi savol.');
select public.qa_ask('uz', 'Beshinchi savol sarlavhasi', 'Yetarlicha uzun matn, beshinchi savol.');
select pg_temp.qa_blocked(
  $$select public.qa_ask('uz', 'Oltinchi savol sarlavhasi', 'Yetarlicha uzun matn, oltinchi.')$$,
  'the sixth question in a day is refused');
reset role;

select tags = array['alcohol', 'toxicology'] as ok_tags,
       (select cardinality(flags) >= 2 from public.qa_questions
        where status = 'moderation') as ok_flags
from public.qa_questions where status = 'published' order by created_at limit 1 \gset
select pg_temp.qa_check(:'ok_tags'::boolean, 'unknown tags are dropped, known ones kept');
select pg_temp.qa_check(:'ok_flags'::boolean, 'the privacy filter records which rules matched');

select id as qid from public.qa_questions
where status = 'published' order by created_at limit 1 \gset
select id as mod_qid from public.qa_questions where status = 'moderation' \gset

-- ------------------------------------------------------- answering rights
select pg_temp.qa_as('50000000-0000-0000-0000-0000000000a1');
select pg_temp.qa_blocked(
  format($$select public.qa_answer(%L, 'uz', 'Javob matni yetarlicha uzun bo''lsin.')$$, :'qid'),
  'a user without the badge cannot answer');
reset role;

-- the Edge Function path: the service role records the verdict, never the file
set role service_role;
select private.qa_set_expert_status('50000000-0000-0000-0000-0000000000a2',
  'forensic_chemist', 'uz', 'verified', 'document_ok');
select private.qa_set_expert_status('50000000-0000-0000-0000-0000000000a3',
  'forensic_physician', 'UZ', 'verified', 'document_ok');
select private.qa_verify_attempt('50000000-0000-0000-0000-0000000000a4');
select private.qa_verify_attempt('50000000-0000-0000-0000-0000000000a4');
select private.qa_verify_attempt('50000000-0000-0000-0000-0000000000a4');
select pg_temp.qa_blocked(
  $$select private.qa_verify_attempt('50000000-0000-0000-0000-0000000000a4')$$,
  'the fourth document check in a day is refused');
reset role;
select pg_temp.qa_check((select count(*) = 2 from private.admin_audit
  where action = 'QA_STATUS_SET'), 'setting a badge is audited');
select pg_temp.qa_check((select country_code = 'UZ' from public.qa_profiles
  where user_id = '50000000-0000-0000-0000-0000000000a2'),
  'the country code is normalised');

select pg_temp.qa_as('50000000-0000-0000-0000-0000000000a2');
select pg_temp.qa_check((public.qa_status()->>'can_answer')::boolean,
  'a verified expert may answer');
select pg_temp.qa_check(
  (public.qa_answer(:'qid', 'uz',
    'Chirigan materialda n-propanol hosil bo‘lishi mumkin, shuning uchun tert-butanol afzal.')
   ->>'status') = 'published',
  'an expert answer is published');
reset role;
select pg_temp.qa_check((select answer_count = 1 from public.qa_questions where id = :'qid'),
  'the question answer count follows');
select id as aid from public.qa_answers where question_id = :'qid' \gset

select pg_temp.qa_as('50000000-0000-0000-0000-0000000000a2');
select pg_temp.qa_blocked(format($$select public.qa_vote(%L, 1)$$, :'aid'),
  'an expert cannot vote on their own answer');
reset role;

-- --------------------------------------------------------------- voting
select pg_temp.qa_as('50000000-0000-0000-0000-0000000000a3');
select pg_temp.qa_check((public.qa_vote(:'aid', 1)->>'score')::int = 1,
  'a second expert can vote the answer up');
select pg_temp.qa_check((public.qa_vote(:'aid', -1)->>'score')::int = -1,
  'changing the vote replaces it, it does not add');
select public.qa_vote(:'aid', 1);
reset role;
select pg_temp.qa_as('50000000-0000-0000-0000-0000000000a4');
select pg_temp.qa_blocked(format($$select public.qa_vote(%L, 1)$$, :'aid'),
  'a user without the badge cannot vote');
reset role;

-- ----------------------------------------------------------- best answer
select pg_temp.qa_as('50000000-0000-0000-0000-0000000000a3');
select pg_temp.qa_blocked(format($$select public.qa_accept(%L, %L)$$, :'qid', :'aid'),
  'only the asker marks the best answer');
reset role;
select pg_temp.qa_as('50000000-0000-0000-0000-0000000000a1');
select pg_temp.qa_check(
  (public.qa_accept(:'qid', :'aid')->>'accepted_answer_id') is not null,
  'the asker marks the best answer');
select pg_temp.qa_check(
  (public.qa_question(:'qid') -> 'answers' -> 0 ->> 'accepted')::boolean,
  'the accepted answer comes first and is flagged');
reset role;

-- -------------------------------------------------------------- reports
select pg_temp.qa_as('50000000-0000-0000-0000-0000000000a3');
select public.qa_report('answer', :'aid', 'ish ma’lumoti');
reset role;
select pg_temp.qa_as('50000000-0000-0000-0000-0000000000a4');
select pg_temp.qa_check(
  not (public.qa_report('answer', :'aid', 'ish ma’lumoti')->>'hidden')::boolean,
  'two reporters are not enough to hide an answer');
reset role;
select pg_temp.qa_as('50000000-0000-0000-0000-0000000000a5');
select pg_temp.qa_check(
  (public.qa_report('answer', :'aid', 'ish ma’lumoti')->>'hidden')::boolean,
  'three distinct reporters hide the answer');
reset role;
select pg_temp.qa_check((select status = 'moderation' from public.qa_answers where id = :'aid'),
  'the reported answer is in moderation');

-- ---------------------------------------------------------------- admin
select pg_temp.qa_as('50000000-0000-0000-0000-0000000000a1');
select pg_temp.qa_blocked($$select public.qa_admin_queue()$$,
  'an ordinary user cannot open the moderation queue');
select pg_temp.qa_blocked(
  format($$select public.qa_moderate('publish', 'answer', %L)$$, :'aid'),
  'an ordinary user cannot moderate');
reset role;

select pg_temp.qa_as('50000000-0000-0000-0000-0000000000a6');
select pg_temp.qa_check(jsonb_array_length(public.qa_admin_queue()->'answers') = 1,
  'the admin sees the reported answer in the queue');
select pg_temp.qa_check(jsonb_array_length(public.qa_admin_queue()->'questions') = 1,
  'the admin sees the question the privacy filter held');
select public.qa_moderate('publish', 'answer', :'aid');
select public.qa_moderate('remove', 'question', :'mod_qid');
select public.qa_moderate('suspend', 'user', '50000000-0000-0000-0000-0000000000a2', 'reported');
select public.qa_moderate('reinstate', 'user', '50000000-0000-0000-0000-0000000000a2');
select public.qa_moderate('pin', 'question', :'qid');
reset role;
select pg_temp.qa_check((select status = 'published' from public.qa_answers where id = :'aid'),
  'the admin can release an answer');
select pg_temp.qa_check((select status = 'removed' from public.qa_questions where id = :'mod_qid'),
  'the admin can remove a question');
select pg_temp.qa_check((select status = 'verified' from public.qa_profiles
  where user_id = '50000000-0000-0000-0000-0000000000a2'),
  'the admin can suspend and give the badge back');
select pg_temp.qa_check((select pinned from public.qa_questions where id = :'qid'),
  'the admin can pin a question');
select pg_temp.qa_check((select count(*) >= 6 from private.admin_audit
  where action in ('QA_MODERATE', 'QA_QUEUE_VIEW', 'QA_AUTO_HIDDEN')),
  'every moderation step is audited');

-- a suspended expert cannot answer any more
set role service_role;
select private.qa_set_expert_status('50000000-0000-0000-0000-0000000000a3',
  'forensic_physician', 'UZ', 'suspended', 'reported');
reset role;
select pg_temp.qa_as('50000000-0000-0000-0000-0000000000a3');
select pg_temp.qa_blocked(
  format($$select public.qa_answer(%L, 'uz', 'Yana bir javob matni, yetarlicha uzun.')$$, :'qid'),
  'a suspended expert cannot answer');
reset role;

-- ---------------------------------------------------------- translation
select pg_temp.qa_as('50000000-0000-0000-0000-0000000000a1');
select pg_temp.qa_blocked(
  format($$select private.qa_translation_put('question', %L, 'ru', 't', 'b', 'test')$$, :'qid'),
  'a user cannot write the translation cache');
select pg_temp.qa_check(public.qa_translation('question', :'qid', 'ru') is null,
  'an uncached translation reads as nothing');
reset role;
set role service_role;
select private.qa_translation_put('question', :'qid', 'ru', 'Вопрос', 'Текст вопроса', 'test-engine');
reset role;
select pg_temp.qa_as('50000000-0000-0000-0000-0000000000a1');
select pg_temp.qa_check(
  (public.qa_translation('question', :'qid', 'ru')->>'engine') = 'test-engine',
  'the cached translation is served from the cache');
reset role;
