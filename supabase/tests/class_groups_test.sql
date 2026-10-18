-- «Ustoz–talaba testi» (guruhlar + mavzu testlari): qo'shilish, taxallus
-- normalizatsiyasi (iPhone apostroflari), kod alifbosi, 200 chegara, variantlar
-- (umumiy test vektorlari), ruxsatlar, vaqt chegarasi + imtiyoz, javoblarni
-- ochish qoidalari, rate limit.
--
-- run_local.sh `-v fixture=<.../class_group_variant_vectors.json>` beradi.
\set ON_ERROR_STOP 1
reset role;
-- Earlier test files grant table privileges for their own checks; restore
-- the migration's state (the RLS matrix runs on a fresh database too).
revoke all on public.class_groups, public.class_group_members, public.class_assignments,
  public.class_assignment_questions, public.class_assignment_attempts from anon, authenticated;

create function pg_temp.gq_as(uid text) returns void language plpgsql as $$
begin
  perform set_config('request.jwt.claim.sub', uid, false);
  perform set_config('request.jwt.claims', '{}', false);
  perform set_config('role', 'authenticated', false);
end $$;
create function pg_temp.gq_anon() returns void language plpgsql as $$
begin
  perform set_config('request.jwt.claim.sub', '', false);
  perform set_config('role', 'anon', false);
end $$;
create function pg_temp.gq_check(ok boolean, label text) returns void language plpgsql as $$
begin
  if not coalesce(ok, false) then raise exception 'FAIL: %', label; end if;
  raise notice 'PASS: %', label;
end $$;
create function pg_temp.gq_state(q text) returns text language plpgsql as $$
begin
  execute q;
  return 'OK';
exception when others then
  return sqlstate;
end $$;
create function pg_temp.gq_forbidden(q text, label text) returns void language plpgsql as $$
declare st text;
begin
  st := pg_temp.gq_state(q);
  if st <> '42501' then raise exception 'FAIL (expected 42501, got %): %', st, label; end if;
  raise notice 'PASS (403): %', label;
end $$;
grant execute on function pg_temp.gq_as(text), pg_temp.gq_anon(),
  pg_temp.gq_check(boolean, text), pg_temp.gq_state(text),
  pg_temp.gq_forbidden(text, text) to anon, authenticated;

-- t1 ustoz (egasi), t2 boshqa ustoz, s1..s4 talabalar, n1 oddiy hisob, rl — limit sinovi.
\set t1 '7a000000-0000-0000-0000-0000000000a1'
\set t2 '7a000000-0000-0000-0000-0000000000a2'
\set s1 '7a000000-0000-0000-0000-0000000000b1'
\set s2 '7a000000-0000-0000-0000-0000000000b2'
\set s3 '7a000000-0000-0000-0000-0000000000b3'
\set s4 '7a000000-0000-0000-0000-0000000000b4'
\set n1 '7a000000-0000-0000-0000-0000000000c1'
\set rl '7a000000-0000-0000-0000-0000000000c2'
insert into auth.users (id, email) values
 (:'t1', 'g-teacher-one@secret.example'), (:'t2', 'g-teacher-two@secret.example'),
 (:'s1', 'g-student-one@secret.example'), (:'s2', 'g-student-two@secret.example'),
 (:'s3', 'g-student-three@secret.example'), (:'s4', 'g-student-four@secret.example'),
 (:'n1', 'g-plain@secret.example'), (:'rl', 'g-rate@secret.example');
insert into account_roles (user_id, role, granted_by) values
 (:'t1', 'teacher', null), (:'t2', 'teacher', null);

-- Bank: 'grp-topic' — 12 savol, 'grp-small' — 5 savol.
insert into public.class_quiz_questions
  (topic_id, topic_title, position, question, options, correct_index, explanation, source)
select 'grp-topic', 'Guruh mavzusi', g, 'Guruh savoli raqami ' || g,
       jsonb_build_array('A' || g, 'B' || g, 'C' || g, 'D' || g), (g % 4)::smallint,
       'Izoh ' || g, '{"author":"Muallif","title":"Darslik","page":"12"}'::jsonb
from generate_series(1, 12) g;
insert into public.class_quiz_questions
  (topic_id, topic_title, position, question, options, correct_index, explanation, source)
select 'grp-small', 'Kichik mavzu', g, 'Kichik savol raqami ' || g,
       jsonb_build_array('A', 'B', 'C', 'D'), 1, '',
       '{"author":"Muallif","title":"Darslik","page":"3"}'::jsonb
from generate_series(1, 5) g;

-- ============================================== 1. variant: umumiy vektorlar
\set vec `cat :fixture`
select pg_temp.gq_check(
  (select bool_and(private.group_variant_draw(c ->> 'assignment_id', c ->> 'user_id',
        array(select jsonb_array_elements_text(c -> 'pool')), (c ->> 'n')::int)
      = array(select jsonb_array_elements_text(c -> 'expected')))
   from jsonb_array_elements(:'vec'::jsonb -> 'cases') c)
  and jsonb_array_length(:'vec'::jsonb -> 'cases') >= 10,
  'variant draw == shared fixture (Python/Dart/SQL)');
select pg_temp.gq_check(
  (select bool_and(encode(sha256(convert_to((c ->> 'assignment_id') || ':' || (c ->> 'user_id'),
      'UTF8')), 'hex') = c ->> 'seed') from jsonb_array_elements(:'vec'::jsonb -> 'cases') c),
  'variant seed = sha256("<assignmentId>:<userId>")');
-- Tartib pool tartibiga bog'liq emas.
select pg_temp.gq_check(
  private.group_variant_draw('x', 'y', array['c','a','b','d'], 3)
  = private.group_variant_draw('x', 'y', array['d','b','a','c'], 3),
  'variant draw ignores pool order');

-- ======================================== 2. taxallus: iPhone apostroflari
select pg_temp.gq_check(private.nick_fold('G’ayrat') = 'G''ayrat', 'fold ’');
select pg_temp.gq_check(private.nick_fold('G‘ayrat') = 'G''ayrat', 'fold ‘');
select pg_temp.gq_check(private.nick_fold('Gʻayrat') = 'G''ayrat', 'fold ʻ');
select pg_temp.gq_check(private.nick_fold('Gʼayrat') = 'G''ayrat', 'fold ʼ');
select pg_temp.gq_check(private.nick_fold('G`ayrat') = 'G''ayrat', 'fold `');
select pg_temp.gq_check(private.nick_fold('G´ayrat') = 'G''ayrat', 'fold ´');
select pg_temp.gq_check(private.nick_fold('G′ayrat') = 'G''ayrat', 'fold ′');
select pg_temp.gq_check(private.nick_fold('  O’tkir   Ali  ') = 'O''tkir Ali', 'fold trims spaces');
-- «Sinfda test» laqabi ham shu normalizatsiyadan o'tadi.
select pg_temp.gq_check(private.class_nick_check('G`ayrat') = 'ok', 'live quiz: backtick nickname folded, accepted');
select pg_temp.gq_check(private.class_nick_check('Oʻtkir') = 'ok', 'live quiz: ʻ accepted');

-- ============================================== 3. kod alifbosi va formati
select pg_temp.gq_check(private.group_code_check('ABCD2345') = 'ok', 'code ok');
select pg_temp.gq_check(private.group_code_check(' abcd-2345 ') = 'ok', 'code: lower case, dash, spaces');
select pg_temp.gq_check(private.group_code_check('ABCD0345') = 'ambiguous', 'code with 0 → ambiguous');
select pg_temp.gq_check(private.group_code_check('ABCO2345') = 'ambiguous', 'code with O → ambiguous');
select pg_temp.gq_check(private.group_code_check('ABC12345') = 'ambiguous', 'code with 1 → ambiguous');
select pg_temp.gq_check(private.group_code_check('ABCI2345') = 'ambiguous', 'code with I → ambiguous');
select pg_temp.gq_check(private.group_code_check('ABCL2345') = 'ambiguous', 'code with L → ambiguous');
select pg_temp.gq_check(private.group_code_check('ABC') = 'bad', 'short code → bad');
select pg_temp.gq_check((select bool_and(private.group_new_code() ~ '^[A-HJKMNP-Z2-9]{8}$')
  from generate_series(1, 300)), 'generated codes never contain 0/O/1/I/L');

-- ================================================== 4. ruxsatlar: anon/oddiy
select pg_temp.gq_anon();
select pg_temp.gq_forbidden($$select public.group_join('ABCD2345', 'Ali')$$, 'anon cannot join (no anonymous join)');
select pg_temp.gq_forbidden($$select public.group_list()$$, 'anon cannot list');
select pg_temp.gq_forbidden($$select public.group_create('Anon')$$, 'anon cannot create');
select pg_temp.gq_as(:'n1');
select pg_temp.gq_forbidden($$select public.group_create('Oddiy')$$, 'non-teacher cannot create a group');

-- ================================================================ 5. guruh
select pg_temp.gq_as(:'t1');
select pg_temp.gq_check((public.group_create('X') ->> 'error') = 'bad_name', 'group name too short');
select (public.group_create('  4-kurs   davolash ') -> 'group') as g1 \gset
select :'g1'::jsonb ->> 'id' as g1id, :'g1'::jsonb ->> 'code' as g1code \gset
select pg_temp.gq_check(:'g1'::jsonb ->> 'name' = '4-kurs davolash', 'group created, name cleaned');
select pg_temp.gq_check(:'g1code' ~ '^[A-HJKMNP-Z2-9]{8}$', 'group code format');

-- Boshqa ustoz begona guruhni ko'rmaydi/boshqarmaydi.
select pg_temp.gq_as(:'t2');
select pg_temp.gq_forbidden(format('select public.group_detail(%L)', :'g1id'), 'other teacher: detail');
select pg_temp.gq_forbidden(format($q$select public.group_assignment_create(%L, 'grp-topic', 3, null, null, false, 'after_close')$q$, :'g1id'),
  'other teacher: give test');
select pg_temp.gq_check(jsonb_array_length(public.group_list() -> 'teaching') = 0, 'other teacher lists only own groups');

-- ================================================================ 6. qo'shilish
select pg_temp.gq_as(:'s1');
select pg_temp.gq_check((public.group_join(:'g1code') ->> 'error') = 'nickname_required',
  'first join without nickname asks for one');
select pg_temp.gq_check((public.group_join(:'g1code') ->> 'group_name') = '4-kurs davolash',
  'nickname_required carries group name');
select pg_temp.gq_check((public.group_join(lower(:'g1code'), 'G’ayrat') ->> 'nickname') = 'G''ayrat',
  'iPhone ’ nickname accepted and stored as ''');
select pg_temp.gq_check((public.group_join(:'g1code') ->> 'already_member')::boolean,
  'rejoin: already member, no nickname needed');
select pg_temp.gq_check(not (public.group_join(:'g1code') -> 'group' ? 'code'),
  'student never receives the group code');
select pg_temp.gq_as(:'s2');
select pg_temp.gq_check((public.group_join(:'g1code', 'gʻayrat') ->> 'error') = 'nick_taken',
  'same nickname with another apostrophe/case is taken');
select pg_temp.gq_check((public.group_join(:'g1code', 'A') ->> 'error') = 'nick_length', 'nick too short');
select pg_temp.gq_check((public.group_join(:'g1code', 'a<b>') ->> 'error') = 'nick_chars', 'nick bad chars');
select pg_temp.gq_check((public.group_join(:'g1code', 'suka') ->> 'error') = 'nick_blocked', 'nick filter');
select pg_temp.gq_check((public.group_join(:'g1code', 'Bobur') ->> 'role') = 'student', 's2 joined');
select pg_temp.gq_as(:'s3');
select pg_temp.gq_check((public.group_join(:'g1code', 'Lola') ->> 'role') = 'student', 's3 joined');
select pg_temp.gq_check((public.group_join('ABCO2345', 'Lola') ->> 'error') = 'code_ambiguous', 'ambiguous code error');
select pg_temp.gq_check((public.group_join('ZZ', 'Lola') ->> 'error') = 'bad_code', 'malformed code error');
select pg_temp.gq_check((public.group_join('ZZZZZZZZ', 'Lola') ->> 'error') = 'not_found', 'unknown code error');
-- Ustoz o'z kodini ochadi: a'zo qilinmaydi, role teacher.
select pg_temp.gq_as(:'t1');
select pg_temp.gq_check((public.group_join(:'g1code', 'Ustoz') ->> 'role') = 'teacher', 'teacher opening own code → role teacher');
reset role;
select pg_temp.gq_check(not exists (select 1 from class_group_members where user_id = :'t1'),
  'teacher is not added as a member');

-- Talaba: guruh sahifasida kod va boshqa a'zolar yo'q.
select pg_temp.gq_as(:'s1');
select pg_temp.gq_check((public.group_detail(:'g1id') ->> 'role') = 'student'
  and not (public.group_detail(:'g1id') ? 'members')
  and not (public.group_detail(:'g1id') -> 'group' ? 'code'),
  'student detail: no code, no member list');
select pg_temp.gq_as(:'s4');
select pg_temp.gq_forbidden(format('select public.group_detail(%L)', :'g1id'), 'non-member: detail');
-- Ustoz: a'zolar faqat taxallus bilan (email/user_id yo'q).
select pg_temp.gq_as(:'t1');
select pg_temp.gq_check(jsonb_array_length(public.group_detail(:'g1id') -> 'members') = 3, 'teacher sees 3 members');
select pg_temp.gq_check(public.group_detail(:'g1id')::text !~ '(@|7a000000-0000-0000-0000-0000000000b)',
  'teacher detail has no e-mail or user id');

-- ========================================================= 7. 200 chegara
select pg_temp.gq_as(:'t1');
select (public.group_create('Katta oqim') -> 'group' ->> 'id') as g2id \gset
reset role;
select code as g2code from class_groups where id = :'g2id' \gset
insert into auth.users (id, email)
select ('7b000000-0000-0000-0000-' || lpad(g::text, 12, '0'))::uuid, 'bulk' || g || '@secret.example'
from generate_series(1, 199) g;
insert into class_group_members (group_id, user_id, nickname)
select :'g2id', ('7b000000-0000-0000-0000-' || lpad(g::text, 12, '0'))::uuid, 'Talaba ' || g
from generate_series(1, 199) g;
select pg_temp.gq_as(:'s3');
select pg_temp.gq_check((public.group_join(:'g2code', 'Lola') ->> 'role') = 'student', '200th member joins');
select pg_temp.gq_as(:'s4');
select pg_temp.gq_check((public.group_join(:'g2code', 'Kamola') ->> 'error') = 'group_full', '201st member: group_full');

-- ========================================================= 8. rate limit
select pg_temp.gq_as(:'rl');
select pg_temp.gq_check((select count(*) from generate_series(1, 30) i
  where public.group_join('ZZZZZZZZ', 'Hacker') ->> 'error' = 'not_found') = 30, '30 guesses allowed per hour');
select pg_temp.gq_check((public.group_join(:'g1code', 'Hacker') ->> 'error') = 'rate_limited',
  '31st join attempt: rate_limited (even with a valid code)');
reset role;
select pg_temp.gq_check(exists (select 1 from class_join_attempts where key = 'gj:' || :'rl' and n > 30),
  'rate counter is kept (no rollback)');

-- ==================================================== 9. topshiriq sozlamalari
select pg_temp.gq_as(:'t1');
select pg_temp.gq_check((public.group_assignment_create(:'g1id', 'grp-topic', 7, null, null, true, 'after_close') ->> 'error')
  = 'variant_pool_small', 'variant needs pool >= 2N (12 < 14) — server refuses');
select pg_temp.gq_check((public.group_assignment_create(:'g1id', 'grp-topic', 7, null, null, true, 'after_close') ->> 'needed')::int
  = 14, 'variant refusal explains the needed pool size');
select pg_temp.gq_check((public.group_assignment_create(:'g1id', 'grp-topic', 13, null, null, false, 'after_close') ->> 'error')
  = 'not_enough_questions', 'more questions than the topic has');
select pg_temp.gq_check((public.group_assignment_create(:'g1id', 'grp-topic', 5, 181, null, false, 'after_close') ->> 'error')
  = 'invalid_settings', 'time limit 181 rejected');
select pg_temp.gq_check((public.group_assignment_create(:'g1id', 'grp-topic', 5, 0, null, false, 'after_close') ->> 'error')
  = 'invalid_settings', 'time limit 0 rejected');
select pg_temp.gq_check((public.group_assignment_create(:'g1id', 'grp-topic', 5, null, null, false, 'after_due') ->> 'error')
  = 'reveal_needs_due', 'after_due without due date rejected');
select pg_temp.gq_check((public.group_assignment_create(:'g1id', 'grp-topic', 5, null, now() - interval '1 hour', false, 'after_close') ->> 'error')
  = 'bad_due', 'due in the past rejected');

-- Variantli test (12 savol, har talabaga 4), 10 daqiqa.
select (public.group_assignment_create(:'g1id', 'grp-topic', 4, 10, null, true, 'after_close')
        -> 'assignment' ->> 'id') as av \gset
-- Oddiy test (hammaga bir xil 4 savol).
select (public.group_assignment_create(:'g1id', 'grp-topic', 4, null, null, false, 'after_close')
        -> 'assignment' ->> 'id') as ac \gset
select pg_temp.gq_check((public.group_assignment_board(:'av') -> 'assignment' ->> 'pool_size')::int = 12, 'pool copied');

-- Talaba ustoz amallarini bajara olmaydi.
select pg_temp.gq_as(:'s1');
select pg_temp.gq_forbidden(format('select public.group_assignment_board(%L)', :'av'), 'student: board');
select pg_temp.gq_forbidden(format('select public.group_assignment_preview(%L)', :'av'), 'student: preview (answer key)');
select pg_temp.gq_forbidden(format('select public.group_assignment_close(%L)', :'av'), 'student: close');
select pg_temp.gq_as(:'t2');
select pg_temp.gq_forbidden(format('select public.group_assignment_board(%L)', :'av'), 'other teacher: board');
select pg_temp.gq_as(:'s4');
select pg_temp.gq_forbidden(format('select public.group_assignment_open(%L)', :'av'), 'non-member: open test');
select pg_temp.gq_anon();
select pg_temp.gq_forbidden(format('select public.group_assignment_open(%L)', :'av'), 'anon: open test');

-- ============================================================ 10. variantlar
select pg_temp.gq_as(:'s1');
select public.group_assignment_open(:'av') as o1 \gset
select pg_temp.gq_check(:'o1'::jsonb ->> 'state' = 'solving', 's1 started');
select pg_temp.gq_check(:'o1'::text !~ 'correct', 'open payload has no correct answers');
select pg_temp.gq_check(jsonb_array_length(:'o1'::jsonb -> 'questions') = 4, 's1 got 4 questions');
select pg_temp.gq_as(:'s2');
select public.group_assignment_open(:'av') as o2 \gset
select pg_temp.gq_as(:'s3');
select public.group_assignment_open(:'av') as o3 \gset
reset role;
select pg_temp.gq_check((select bool_and(t.question_ids = private.group_variant_draw(:'av', t.user_id::text,
    array(select q.qid from class_assignment_questions q where q.assignment_id = :'av' order by q.qid collate "C"), 4))
  from class_assignment_attempts t where t.assignment_id = :'av') , 'each attempt = draw(assignment, user)');
select pg_temp.gq_check((select count(distinct t.question_ids) from class_assignment_attempts t
  where t.assignment_id = :'av') = 3, 'variant: three students, three different question sets');
-- Qayta ochish: o'sha savollar, o'sha started_at.
select pg_temp.gq_as(:'s1');
select pg_temp.gq_check((public.group_assignment_open(:'av') -> 'questions') = (:'o1'::jsonb -> 'questions')
  and (public.group_assignment_open(:'av') ->> 'started_at') = (:'o1'::jsonb ->> 'started_at'),
  'reopen keeps questions and server start time');
-- Oddiy test: hammaga bir xil.
select public.group_assignment_open(:'ac') as c1 \gset
select pg_temp.gq_as(:'s2');
select pg_temp.gq_check((public.group_assignment_open(:'ac') -> 'questions') = (:'c1'::jsonb -> 'questions'),
  'non-variant: same set for everybody');

-- ======================================================== 11. ball va maxfiylik
-- s1: hammasi to'g'ri; s2: hammasi noto'g'ri (to'g'ri javoblar superuser'dan).
reset role;
select jsonb_object_agg(q.qid, q.correct_index) as s1ans
  from class_assignment_attempts t join class_assignment_questions q
    on q.assignment_id = t.assignment_id and q.qid = any (t.question_ids)
  where t.assignment_id = :'av' and t.user_id = :'s1' \gset
select jsonb_object_agg(q.qid, (q.correct_index + 1) % 4) as s2ans
  from class_assignment_attempts t join class_assignment_questions q
    on q.assignment_id = t.assignment_id and q.qid = any (t.question_ids)
  where t.assignment_id = :'av' and t.user_id = :'s2' \gset
select pg_temp.gq_as(:'s1');
select pg_temp.gq_check((public.group_assignment_save(:'av', '{"not-mine": 1}'::jsonb) ->> 'ok')::boolean,
  'save ignores foreign question ids');
select public.group_assignment_submit(:'av', :'s1ans'::jsonb) as r1 \gset
select pg_temp.gq_check((:'r1'::jsonb ->> 'score')::int = 4 and (:'r1'::jsonb ->> 'total')::int = 4, 's1 scored 4/4 (server)');
select pg_temp.gq_check(not (:'r1'::jsonb ->> 'revealed')::boolean, 'not revealed before close');
select pg_temp.gq_check((public.group_assignment_submit(:'av', :'s1ans'::jsonb) ->> 'error') = 'already_submitted', 'no double submit');
select pg_temp.gq_check(public.group_assignment_result(:'av')::text !~ '(correct_index|is_correct|explanation)',
  'result before reveal: no correct answers / explanations');
select pg_temp.gq_check(public.group_assignment_result(:'av')::text !~ 'Bobur|Lola',
  'student result never contains other students');
select pg_temp.gq_as(:'s2');
select pg_temp.gq_check((public.group_assignment_submit(:'av', :'s2ans'::jsonb) ->> 'score')::int = 0, 's2 scored 0/4');
-- Ustoz paneli: qo'shildi / yechmoqda / tugatdi.
select pg_temp.gq_as(:'t1');
select public.group_assignment_board(:'av') as b1 \gset
select pg_temp.gq_check((select count(*) from jsonb_array_elements(:'b1'::jsonb -> 'rows') r
  where r ->> 'state' = 'finished') = 2
  and (select count(*) from jsonb_array_elements(:'b1'::jsonb -> 'rows') r where r ->> 'state' = 'solving') = 1,
  'board: 2 finished, 1 solving');
select pg_temp.gq_check((:'b1'::jsonb -> 'rows' -> 0 ->> 'nickname') = 'G''ayrat'
  and (:'b1'::jsonb -> 'rows' -> 0 ->> 'score')::int = 4, 'board ordered by score');
select pg_temp.gq_check(:'b1'::text !~ '(@|7a000000-0000-0000-0000-0000000000b)', 'board has no e-mail / user id');
-- Ustoz yopadi → javoblar ochiladi.
select pg_temp.gq_check((public.group_assignment_close(:'av') ->> 'ok')::boolean, 'teacher closes');
select pg_temp.gq_as(:'s1');
select public.group_assignment_result(:'av') as res1 \gset
select pg_temp.gq_check((:'res1'::jsonb ->> 'revealed')::boolean
  and (:'res1'::jsonb -> 'items' -> 0) ? 'correct_index'
  and (:'res1'::jsonb -> 'items' -> 0 ->> 'is_correct')::boolean, 'after close: correct answers revealed');
select pg_temp.gq_as(:'s4');
reset role;
-- Yopilgan testni yangi talaba boshlay olmaydi.
insert into class_group_members (group_id, user_id, nickname) values (:'g1id', :'s4', 'Kamola');
select pg_temp.gq_as(:'s4');
select pg_temp.gq_check((public.group_assignment_open(:'av') ->> 'error') = 'closed', 'closed test cannot be started');
-- s3 yopilgandan keyin 30 s imtiyoz ichida yubora oladi.
select pg_temp.gq_as(:'s3');
select pg_temp.gq_check((public.group_assignment_submit(:'av', '{}'::jsonb) ->> 'late')::boolean = false,
  'started before close: submit within grace accepted');

-- ===================================================== 12. vaqt chegarasi
select pg_temp.gq_as(:'t1');
select (public.group_assignment_create(:'g1id', 'grp-topic', 3, 1, null, false, 'after_close')
        -> 'assignment' ->> 'id') as at1 \gset
select pg_temp.gq_as(:'s1');
select public.group_assignment_open(:'at1') as ta \gset
select pg_temp.gq_check((:'ta'::jsonb ->> 'ends_at')::timestamptz
  = (:'ta'::jsonb ->> 'started_at')::timestamptz + interval '1 minute', 'ends_at = server start + limit');
select pg_temp.gq_as(:'s2');
select public.group_assignment_open(:'at1') as tb \gset
reset role;
-- s1: 1 daqiqa + 20 s o'tdi (imtiyoz ichida); s2: 2 daqiqa (imtiyozdan tashqari).
update class_assignment_attempts set started_at = now() - interval '80 seconds'
 where assignment_id = :'at1' and user_id = :'s1';
select jsonb_object_agg(q.qid, q.correct_index) as at1ans
  from class_assignment_attempts t join class_assignment_questions q
    on q.assignment_id = t.assignment_id and q.qid = any (t.question_ids)
  where t.assignment_id = :'at1' and t.user_id = :'s2' \gset
select pg_temp.gq_as(:'s2');
-- s2 bitta javobni vaqtida saqlagan.
select pg_temp.gq_check((public.group_assignment_save(:'at1',
  (select jsonb_build_object(k, v) from jsonb_each(:'at1ans'::jsonb) e(k, v) limit 1)) ->> 'ok')::boolean,
  'save within time');
reset role;
update class_assignment_attempts set started_at = now() - interval '2 minutes'
 where assignment_id = :'at1' and user_id = :'s2';
select pg_temp.gq_as(:'s1');
select pg_temp.gq_check((public.group_assignment_submit(:'at1', '{}'::jsonb) ->> 'late')::boolean = false,
  'submit 20 s after the limit: accepted (grace)');
select pg_temp.gq_as(:'s2');
select pg_temp.gq_check((public.group_assignment_save(:'at1', :'at1ans'::jsonb) ->> 'error') = 'time_over',
  'save after limit + grace rejected');
select public.group_assignment_submit(:'at1', :'at1ans'::jsonb) as late \gset
select pg_temp.gq_check((:'late'::jsonb ->> 'late')::boolean and (:'late'::jsonb ->> 'score')::int = 1,
  'late submit: new answers ignored, last saved answers scored (1/3)');
-- Boshlab, yubormay ketgan talaba: panel o'qilganda server yakunlaydi.
select pg_temp.gq_as(:'s3');
select public.group_assignment_open(:'at1') as tc \gset
reset role;
update class_assignment_attempts set started_at = now() - interval '5 minutes'
 where assignment_id = :'at1' and user_id = :'s3';
select pg_temp.gq_as(:'t1');
select pg_temp.gq_check((select r ->> 'state' from jsonb_array_elements(public.group_assignment_board(:'at1') -> 'rows') r
  where r ->> 'nickname' = 'Lola') = 'finished', 'expired attempt finalized by the server');
reset role;
select pg_temp.gq_check((select finish_reason from class_assignment_attempts
  where assignment_id = :'at1' and user_id = :'s3') = 'expired', 'finish_reason = expired');

-- ============================================ 13. muddat va «muddat tugagach»
select pg_temp.gq_as(:'t1');
select (public.group_assignment_create(:'g1id', 'grp-small', 2, null, now() + interval '2 hours', false, 'after_due')
        -> 'assignment' ->> 'id') as ad \gset
select pg_temp.gq_as(:'s1');
select public.group_assignment_open(:'ad') as da \gset
select pg_temp.gq_check((:'da'::jsonb ->> 'ends_at')::timestamptz = (:'da'::jsonb -> 'assignment' ->> 'due_at')::timestamptz,
  'no time limit: window ends at the due date');
select pg_temp.gq_check(not (public.group_assignment_submit(:'ad', '{}'::jsonb) ->> 'revealed')::boolean,
  'after_due: hidden before the due date');
reset role;
update class_assignments set due_at = now() - interval '1 minute' where id = :'ad';
select pg_temp.gq_as(:'s2');
select pg_temp.gq_check((public.group_assignment_open(:'ad') ->> 'error') = 'past_due', 'past due: cannot start');
select pg_temp.gq_as(:'s1');
select pg_temp.gq_check((public.group_assignment_result(:'ad') ->> 'revealed')::boolean, 'after_due: revealed once due passed');

-- ================================================= 14. chiqarish va chiqish
select pg_temp.gq_as(:'t1');
select (select r ->> 'id' from jsonb_array_elements(public.group_detail(:'g1id') -> 'members') r
        where r ->> 'nickname' = 'Lola') as lola \gset
select pg_temp.gq_check((public.group_remove_member(:'g1id', :'lola') ->> 'ok')::boolean, 'teacher removes a member');
select pg_temp.gq_as(:'t2');
select pg_temp.gq_forbidden(format('select public.group_remove_member(%L, %L)', :'g1id', :'lola'), 'other teacher cannot remove');
select pg_temp.gq_as(:'s3');
select pg_temp.gq_forbidden(format('select public.group_detail(%L)', :'g1id'), 'removed member loses access');
select pg_temp.gq_as(:'s2');
select pg_temp.gq_check((public.group_leave(:'g1id') ->> 'ok')::boolean, 'student leaves');
select pg_temp.gq_check(jsonb_array_length(public.group_list() -> 'member') = 0, 'left group not listed');

-- ================================================ 15. jadvallar yopiq
select pg_temp.gq_as(:'s1');
select pg_temp.gq_forbidden('select * from public.class_assignment_questions', 'answer key table closed');
select pg_temp.gq_forbidden('select * from public.class_assignment_attempts', 'attempts table closed');
select pg_temp.gq_forbidden('select * from public.class_groups', 'groups table closed');
select pg_temp.gq_forbidden($$select private.group_variant_draw('a','b','{x}',1)$$, 'private helpers closed');
reset role;

-- ======================================== 16. «Umumiy test» (bir nechta mavzu)
select pg_temp.gq_check(
  (select bool_and(private.group_round_robin_counts(
        array(select (jsonb_array_elements_text(c -> 'sizes'))::int), (c ->> 'n')::int)
      = array(select (jsonb_array_elements_text(c -> 'expected'))::int))
   from jsonb_array_elements(:'vec'::jsonb -> 'round_robin') c),
  'round-robin counts == shared fixture');
reset role;
insert into public.class_quiz_questions
  (topic_id, topic_title, position, question, options, correct_index, explanation, source)
select 'grp-big', 'Katta mavzu', g, 'Katta savol raqami ' || g,
       jsonb_build_array('A', 'B', 'C', 'D'), 2, '',
       '{"author":"Muallif","title":"Darslik","page":"7"}'::jsonb
from generate_series(1, 60) g;
select pg_temp.gq_as(:'t1');
select (public.group_assignment_create_mixed(:'g1id', '  Umumiy   test: Guruh · Kichik  ',
          array['grp-topic', 'grp-small', 'grp-topic', 'grp-big'], 20, 10,
          now() + interval '1 day', false, 'after_due') -> 'assignment') as mx \gset
select pg_temp.gq_check(:'mx'::jsonb ->> 'topic_title' = 'Umumiy test: Guruh · Kichik'
  and :'mx'::jsonb ->> 'topic_id' = 'mixed'
  and :'mx'::jsonb -> 'topics' = '["grp-topic","grp-small","grp-big"]'::jsonb,
  'mixed: title cleaned, topics de-duplicated in order');
reset role;
select pg_temp.gq_check((select array_agg(n order by o) from (
    select t.o, count(q.qid)::int as n
    from unnest(array['grp-topic', 'grp-small', 'grp-big']) with ordinality t(tt, o)
    left join class_assignment_questions q
      on q.assignment_id = (:'mx'::jsonb ->> 'id')::uuid and q.topic_id = t.tt
    group by t.o) x) = private.group_round_robin_counts(array[12, 5, 60], 20),
  'mixed (no variant): pool = N, spread round-robin across topics [7,5,8]');
select pg_temp.gq_check((select count(*) = count(distinct qid) from class_assignment_questions
  where assignment_id = (:'mx'::jsonb ->> 'id')::uuid), 'mixed: no duplicate question ids');
select pg_temp.gq_as(:'t1');
select (public.group_assignment_create_mixed(:'g1id', null, array['grp-topic', 'grp-big'],
          30, null, null, true, 'after_close') -> 'assignment' ->> 'id') as mv \gset
reset role;
select pg_temp.gq_check((select count(*) from class_assignment_questions where assignment_id = :'mv') = 60,
  'mixed + variant: pool = 2N');
select pg_temp.gq_as(:'t1');
select pg_temp.gq_check((public.group_assignment_create_mixed(:'g1id', 'x', array['grp-topic', 'grp-small'],
  10, null, null, true, 'after_close') ->> 'error') = 'variant_pool_small', 'mixed: variant needs 2N');
select pg_temp.gq_check((public.group_assignment_create(:'g1id', 'grp-big', 60, null, null, false, 'after_close')
  -> 'assignment' ->> 'question_count')::int = 60, 'custom count above 50 allowed (<= pool)');
select pg_temp.gq_check((public.group_assignment_create(:'g1id', 'grp-big', 201, null, null, false, 'after_close')
  ->> 'error') = 'invalid_settings', 'count above 200 rejected');
select pg_temp.gq_as(:'t2');
select pg_temp.gq_forbidden(format($q$select public.group_assignment_create_mixed(%L, 'x', array['grp-big'], 5, null, null, false, 'after_close')$q$, :'g1id'),
  'other teacher: mixed test');
reset role;
\echo ALL CLASS GROUPS TESTS PASSED
