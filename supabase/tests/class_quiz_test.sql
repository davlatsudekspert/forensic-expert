-- «Sinfda test» — roles, answer secrecy, one answer per question, server-side
-- timing, nickname privacy, kick, rate limit, 30-day cleanup.
-- Runs after the other test files (roles and helpers already exist there).
--
-- Every class_* table has RLS on and no table privilege, so rows are inspected
-- as the superuser (`reset role`) and ids are carried in psql variables.
\set ON_ERROR_STOP 1
reset role;
revoke all on public.class_quiz_questions, public.class_sessions,
  public.class_session_questions, public.class_participants, public.class_answers,
  public.class_reports, public.class_join_attempts from anon, authenticated;

create function pg_temp.cq_as(uid text) returns void language plpgsql as $$
begin
  perform set_config('request.jwt.claim.sub', uid, false);
  perform set_config('request.jwt.claims', '{}', false);
  perform set_config('role', 'authenticated', false);
end $$;
create function pg_temp.cq_anon() returns void language plpgsql as $$
begin
  perform set_config('request.jwt.claim.sub', '', false);
  perform set_config('role', 'anon', false);
end $$;
create function pg_temp.cq_check(ok boolean, label text) returns void language plpgsql as $$
begin
  if not coalesce(ok, false) then raise exception 'FAIL: %', label; end if;
  raise notice 'PASS: %', label;
end $$;
-- SQLSTATE of a statement ('OK' when it succeeds).
create function pg_temp.cq_state(q text) returns text language plpgsql as $$
begin
  execute q;
  return 'OK';
exception when others then
  return sqlstate;
end $$;
create function pg_temp.cq_forbidden(q text, label text) returns void language plpgsql as $$
declare st text;
begin
  st := pg_temp.cq_state(q);
  if st <> '42501' then raise exception 'FAIL (expected 42501, got %): %', st, label; end if;
  raise notice 'PASS (403): %', label;
end $$;
create function pg_temp.cq_blocked(q text, label text) returns void language plpgsql as $$
begin
  begin execute q; exception when others then
    raise notice 'PASS (blocked): %', label; return; end;
  raise exception 'FAIL (allowed): %', label;
end $$;
grant execute on function pg_temp.cq_as(text), pg_temp.cq_anon(),
  pg_temp.cq_check(boolean, text), pg_temp.cq_state(text),
  pg_temp.cq_forbidden(text, text), pg_temp.cq_blocked(text, text)
  to anon, authenticated;

-- t1 teacher, t2 another teacher, ad identity_admin (may host too),
-- s1..s6 students, n1 an ordinary user, out outsider.
insert into auth.users (id, email, created_at, email_confirmed_at) values
 ('79000000-0000-0000-0000-0000000000a1', 'teacher-one@secret.example', now(), now()),
 ('79000000-0000-0000-0000-0000000000a2', 'teacher-two@secret.example', now(), now()),
 ('79000000-0000-0000-0000-0000000000a3', 'admin@secret.example', now(), now()),
 ('79000000-0000-0000-0000-0000000000b1', 'student-one@secret.example', now(), now()),
 ('79000000-0000-0000-0000-0000000000b2', 'student-two@secret.example', now(), now()),
 ('79000000-0000-0000-0000-0000000000b3', 'student-three@secret.example', now(), now()),
 ('79000000-0000-0000-0000-0000000000b4', 'student-four@secret.example', now(), now()),
 ('79000000-0000-0000-0000-0000000000b5', 'student-five@secret.example', now(), now()),
 ('79000000-0000-0000-0000-0000000000b6', 'student-six@secret.example', now(), now()),
 ('79000000-0000-0000-0000-0000000000c1', 'plain@secret.example', now(), now()),
 ('79000000-0000-0000-0000-0000000000c2', 'outsider@secret.example', now(), now());
insert into account_roles (user_id, role, granted_by) values
 ('79000000-0000-0000-0000-0000000000a1', 'teacher', null),
 ('79000000-0000-0000-0000-0000000000a2', 'teacher', null),
 ('79000000-0000-0000-0000-0000000000a3', 'identity_admin', null);

-- Question bank: 8 DEMO questions in topic 'demo-topic', 2 in 'tiny-topic'.
insert into public.class_quiz_questions
  (topic_id, topic_title, position, question, options, correct_index, explanation, source, is_demo)
select 'demo-topic', 'DEMO mavzu', g, 'DEMO savol raqami ' || g,
       jsonb_build_array('javob A' || g, 'javob B' || g, 'javob C' || g, 'javob D' || g),
       (g % 4)::smallint, 'DEMO izoh ' || g,
       '{"author":"DEMO","title":"DEMO manba","page":"1"}'::jsonb, true
from generate_series(1, 8) g;
insert into public.class_quiz_questions
  (topic_id, topic_title, position, question, options, correct_index, explanation, source, is_demo)
select 'tiny-topic', 'Kichik mavzu', g, 'Kichik mavzu savoli ' || g,
       '["a","b","c","d"]'::jsonb, 0, 'izoh',
       '{"author":"DEMO","title":"DEMO","page":"-"}'::jsonb, true
from generate_series(1, 2) g;

-- ---------------------------------------------------------------- schema
select pg_temp.cq_check((select count(*) = 7 from pg_tables
  where schemaname = 'public' and rowsecurity
    and tablename in ('class_quiz_questions', 'class_sessions', 'class_session_questions',
                      'class_participants', 'class_answers', 'class_reports',
                      'class_join_attempts')),
  'row level security is on for all seven class tables');
select pg_temp.cq_check(not exists (select 1 from pg_policies
  where schemaname = 'public'
    and tablename in ('class_quiz_questions', 'class_session_questions',
                      'class_join_attempts', 'class_reports')),
  'the answer-bearing tables have no policy at all');
select pg_temp.cq_check(not exists (
  select 1 from information_schema.columns
  where table_schema = 'public' and table_name like 'class\_%'
    and column_name in ('email', 'full_name', 'display_name', 'phone')),
  'no class column can hold an e-mail or a real name');
select pg_temp.cq_check(private.class_points(true, 0, 30000) = 1000
  and private.class_points(true, 30000, 30000) = 500
  and private.class_points(true, 15000, 30000) = 750
  and private.class_points(true, 99999, 30000) = 500
  and private.class_points(false, 0, 30000) = 0,
  'scoring: 1000 at once, 500 at the deadline, 0 when wrong');
select pg_temp.cq_check(private.class_nick_check('Ali') = 'ok'
  and private.class_nick_check('A') = 'length'
  and private.class_nick_check(repeat('x', 21)) = 'length'
  and private.class_nick_check('   ') = 'length'
  and private.class_nick_check('a<b>') = 'chars'
  and private.class_nick_check('___') = 'chars'
  and private.class_nick_check('f.u.c.k') = 'blocked'
  and private.class_nick_check('Sh1t') = 'blocked'
  and private.class_nick_check('Passenger') = 'ok'
  and private.class_nick_check('Klassik') = 'ok',
  'nickname filter: length, characters, blocklist, no false positive on common words');

-- ------------------------------------------------------------ privileges
select pg_temp.cq_anon();
select pg_temp.cq_blocked($$select public.class_status()$$, 'anon cannot call class_status');
select pg_temp.cq_blocked($$select public.class_join_session('123456', 'Ali')$$,
  'anon cannot join');
reset role;

select pg_temp.cq_as('79000000-0000-0000-0000-0000000000b1');
select pg_temp.cq_blocked($$select * from public.class_sessions$$,
  'a student cannot read class_sessions directly');
select pg_temp.cq_blocked($$select * from public.class_quiz_questions$$,
  'a student cannot read the question bank (correct answers)');
select pg_temp.cq_blocked($$select * from public.class_session_questions$$,
  'a student cannot read session questions directly');
select pg_temp.cq_blocked($$select * from public.class_answers$$,
  'a student cannot read answers directly');
select pg_temp.cq_blocked(
  $$insert into public.class_answers (session_id, participant_id, question_index, option_id, elapsed_ms, is_correct, points)
    values (gen_random_uuid(), gen_random_uuid(), 0, 'o0', 0, true, 1000)$$,
  'a student cannot write an answer or a score directly');
select pg_temp.cq_blocked($$select private.class_points(true, 0, 1)$$,
  'private helpers are not callable');
select pg_temp.cq_check((public.class_status()->>'is_teacher')::boolean = false,
  'a plain user is not a teacher');

-- ------------------------------------------------- teacher-only creating
select pg_temp.cq_forbidden($$select public.class_create_session('demo-topic', 5, 5, 30)$$,
  'a student cannot create a session');
select pg_temp.cq_forbidden($$select public.class_topics()$$,
  'a student cannot list the question topics');
reset role;
select pg_temp.cq_as('79000000-0000-0000-0000-0000000000c1');
select pg_temp.cq_forbidden($$select public.class_create_session('demo-topic', 5, 5, 30)$$,
  'a user without the teacher role cannot create a session (403)');
reset role;

select pg_temp.cq_as('79000000-0000-0000-0000-0000000000a1');
select pg_temp.cq_check((public.class_status()->>'is_teacher')::boolean, 'the teacher role is read from the server');
select pg_temp.cq_check((public.class_topics()->0->>'count')::int in (2, 8),
  'a teacher sees topics with question counts');
select pg_temp.cq_check((public.class_topics()->0) ? 'course',
  'class_topics rows carry a course key (null when the topic has no lesson)');
select pg_temp.cq_check((public.class_create_session('demo-topic', 4, 30, 30)->>'error') = 'invalid_settings',
  'fewer than 5 questions is refused');
select pg_temp.cq_check((public.class_create_session('demo-topic', 5, 4, 30)->>'error') = 'invalid_settings',
  'fewer than 5 students is refused');
select pg_temp.cq_check((public.class_create_session('demo-topic', 5, 30, 20)->>'error') = 'invalid_settings',
  'a time other than 15/30/45/60 is refused');
select pg_temp.cq_check((public.class_create_session('tiny-topic', 5, 30, 30)->>'error') = 'not_enough_questions',
  'a topic with too few questions is refused');
select pg_temp.cq_check((public.class_create_session('missing', 5, 30, 30)->>'error') = 'not_enough_questions',
  'an unknown topic is refused');
select (public.class_create_session('demo-topic', 5, 5, 30))->'session'->>'id' as sid,
       (public.class_create_session('demo-topic', 6, 100, 15))->'session'->>'id' as sid2 \gset
reset role;

select code as scode from public.class_sessions where id = :'sid' \gset
select pg_temp.cq_check(:'scode' ~ '^[0-9]{6}$', 'the session code is six digits');
select pg_temp.cq_check((select count(*) = 5 from public.class_session_questions
  where session_id = :'sid'), 'five questions were copied into the session');
-- the server shuffle must keep the right option pointing at the right text
select pg_temp.cq_check(not exists (
  select 1 from public.class_session_questions sq
  join public.class_quiz_questions bq on bq.question = sq.question
  where sq.session_id = :'sid'
    and (sq.options ->> sq.correct_index) <> (bq.options ->> bq.correct_index)),
  'shuffling the options keeps the correct answer attached to its text');

-- --------------------------------------------------------------- joining
select pg_temp.cq_as('79000000-0000-0000-0000-0000000000b1');
select pg_temp.cq_check((public.class_join_session('12', 'Ali')->>'error') = 'bad_code', 'short code refused');
select pg_temp.cq_check((public.class_join_session('000000', 'Ali')->>'error') = 'not_found' or :'scode' = '000000',
  'unknown code refused');
select pg_temp.cq_check((public.class_join_session(:'scode', 'A')->>'error') = 'nick_length', 'one-letter nickname refused');
select pg_temp.cq_check((public.class_join_session(:'scode', 'Sh1t')->>'error') = 'nick_blocked', 'blocked nickname refused');
select pg_temp.cq_check((public.class_join_session(:'scode', 'a<b>')->>'error') = 'nick_chars', 'markup in a nickname refused');
select public.class_join_session(:'scode', ' Ali ')->>'participant_id' as p1 \gset
select pg_temp.cq_check(:'p1' <> '', 'a student joins with a nickname');
select pg_temp.cq_check((public.class_join_session(:'scode', 'Boshqa')->>'nickname') = 'Ali',
  'joining again re-enters under the same nickname');
reset role;

select pg_temp.cq_as('79000000-0000-0000-0000-0000000000b2');
select public.class_join_session(:'scode', 'ali')->>'participant_id' as p2 \gset
reset role;
select pg_temp.cq_check((select nickname = 'ali2' from public.class_participants where id = :'p2'),
  'a duplicate nickname gets a number appended');
select pg_temp.cq_as('79000000-0000-0000-0000-0000000000b3');
select public.class_join_session(:'scode', 'Gulnora')->>'participant_id' as p3 \gset
reset role;
select pg_temp.cq_as('79000000-0000-0000-0000-0000000000b4');
select public.class_join_session(:'scode', 'Sardor')->>'participant_id' as p4 \gset
reset role;
select pg_temp.cq_as('79000000-0000-0000-0000-0000000000b5');
select public.class_join_session(:'scode', 'Dilnoza')->>'participant_id' as p5 \gset
reset role;
select pg_temp.cq_as('79000000-0000-0000-0000-0000000000b6');
select pg_temp.cq_check((public.class_join_session(:'scode', 'Otabek')->>'error') = 'full',
  'a full class (limit 5) refuses the sixth student');
reset role;
select pg_temp.cq_as('79000000-0000-0000-0000-0000000000a1');
select pg_temp.cq_check((public.class_join_session(:'scode', 'Ustoz')->>'error') = 'own_session',
  'the teacher cannot join their own session as a student');
reset role;

-- the joined participant is bound to the account on the server
select pg_temp.cq_check((select user_id = '79000000-0000-0000-0000-0000000000b1'
  from public.class_participants where id = :'p1'), 'the participant is bound to the account');

-- ---------------------------------------------------------- rate limiting
select pg_temp.cq_as('79000000-0000-0000-0000-0000000000c2');
select pg_temp.cq_check(bool_and((public.class_join_session('99999' || (g % 10), 'Mehmon')->>'error') in ('not_found', 'bad_code', 'finished')),
  'the first 30 wrong-code attempts get ordinary answers')
  from generate_series(1, 30) g;
select pg_temp.cq_check((public.class_join_session('111111', 'Mehmon')->>'error') = 'rate_limited',
  'the 31st attempt within the hour is rate limited');
select pg_temp.cq_check((public.class_join_session(:'scode', 'Mehmon')->>'error') = 'rate_limited',
  'even the right code is refused once the limit is hit');
reset role;
select pg_temp.cq_check((select n >= 31 from public.class_join_attempts
  where key = 'u:79000000-0000-0000-0000-0000000000c2'),
  'failed attempts are counted and survive (no rollback)');

-- ---------------------------------------------------------- start / state
select pg_temp.cq_as('79000000-0000-0000-0000-0000000000b1');
select pg_temp.cq_forbidden(format($$select public.class_start(%L)$$, :'sid'),
  'a student cannot start a session');
select pg_temp.cq_forbidden(format($$select public.class_teacher_dashboard(%L)$$, :'sid'),
  'a student cannot open the teacher dashboard');
select pg_temp.cq_forbidden(format($$select public.class_kick(%L, %L)$$, :'sid', :'p2'),
  'a student cannot kick');
select pg_temp.cq_forbidden(format($$select public.class_export_results(%L)$$, :'sid'),
  'a student cannot export results');
select pg_temp.cq_check((public.class_session_state(:'sid')->>'phase') = 'lobby', 'the lobby phase is visible');
select pg_temp.cq_check(not (public.class_session_state(:'sid') ? 'question'), 'no question before the start');
reset role;

select pg_temp.cq_as('79000000-0000-0000-0000-0000000000a2');
select pg_temp.cq_forbidden(format($$select public.class_start(%L)$$, :'sid'),
  'another teacher cannot start my session');
select pg_temp.cq_forbidden(format($$select public.class_teacher_dashboard(%L)$$, :'sid'),
  'another teacher cannot see my dashboard');
select pg_temp.cq_check((public.class_my_sessions()) = '[]'::jsonb, 'a teacher lists only their own sessions');
reset role;

select pg_temp.cq_as('79000000-0000-0000-0000-0000000000a1');
select pg_temp.cq_check((public.class_start(:'sid2')->>'error') = 'no_participants', 'cannot start an empty class');
select pg_temp.cq_check((public.class_teacher_dashboard(:'sid')->>'joined')::int = 5, 'the dashboard counts five joined');
select pg_temp.cq_check((public.class_start(:'sid')->>'ok')::boolean, 'the owner starts the session');
select pg_temp.cq_check((public.class_start(:'sid')->>'error') = 'bad_state', 'starting twice is refused');
reset role;

-- correct options of the copied questions, for the checks below
select 'o' || correct_index as c0 from public.class_session_questions
  where session_id = :'sid' and idx = 0 \gset
select case when :'c0' = 'o0' then 'o1' else 'o0' end as w0 \gset

-- ------------------------------------------------------ secrecy while open
select pg_temp.cq_as('79000000-0000-0000-0000-0000000000b1');
select pg_temp.cq_check((public.class_session_state(:'sid')->>'phase') = 'open', 'question 0 is open');
select pg_temp.cq_check(jsonb_array_length(public.class_session_state(:'sid')->'question'->'options') = 4,
  'the student gets four options');
select pg_temp.cq_check(public.class_session_state(:'sid')::text !~ 'correct_(option|index)|my_correct',
  'the open question payload carries no correct answer at all');
select pg_temp.cq_check(public.class_session_state(:'sid')::text !~ 'explanation',
  'the open question payload carries no explanation');
select pg_temp.cq_check(public.class_session_state(:'sid')::text !~ '@', 'the student state has no e-mail');
reset role;
select pg_temp.cq_as('79000000-0000-0000-0000-0000000000c2');
select pg_temp.cq_forbidden(format($$select public.class_session_state(%L)$$, :'sid'),
  'an outsider cannot read another session state');
select pg_temp.cq_forbidden(format($$select public.class_submit_answer(%L, 0, 'o0')$$, :'sid'),
  'an outsider cannot answer');
select pg_temp.cq_forbidden(format($$select public.class_my_results(%L)$$, :'sid'),
  'an outsider cannot read results');
reset role;

-- ------------------------------------------------------------- answering
select pg_temp.cq_as('79000000-0000-0000-0000-0000000000b1');
select pg_temp.cq_check((public.class_submit_answer(:'sid', 0, :'c0')) = '{"ok": true}'::jsonb,
  'an answer is accepted and the reply does not say whether it was right');
select pg_temp.cq_check((public.class_submit_answer(:'sid', 0, :'w0')->>'error') = 'already_answered',
  'a second answer to the same question is refused');
select pg_temp.cq_check((public.class_submit_answer(:'sid', 1, :'c0')->>'error') = 'not_current',
  'an answer to a question that is not current is refused');
select pg_temp.cq_check((public.class_submit_answer(:'sid', 0, 'o9')->>'error') in ('bad_option', 'already_answered'),
  'a made-up option id is refused');
select pg_temp.cq_check((public.class_session_state(:'sid')->>'my_option') = :'c0', 'the student sees their own choice');
select pg_temp.cq_check(not (public.class_session_state(:'sid') ? 'reveal'),
  'still no reveal while the question is open');
reset role;
select pg_temp.cq_as('79000000-0000-0000-0000-0000000000b2');
select public.class_submit_answer(:'sid', 0, :'w0');
reset role;
select pg_temp.cq_as('79000000-0000-0000-0000-0000000000b3');
select public.class_submit_answer(:'sid', 0, :'c0');
reset role;

select pg_temp.cq_check((select is_correct and points >= 990 from public.class_answers
  where participant_id = :'p1' and question_index = 0),
  'a right answer given at once earns about 1000 points (computed on the server)');
select pg_temp.cq_check((select not is_correct and points = 0 from public.class_answers
  where participant_id = :'p2' and question_index = 0), 'a wrong answer earns 0');

-- teacher dashboard: live aggregates, nicknames only
select pg_temp.cq_as('79000000-0000-0000-0000-0000000000a1');
select public.class_teacher_dashboard(:'sid')::text as dash \gset
select pg_temp.cq_check((public.class_teacher_dashboard(:'sid')->'current'->>'answered')::int = 3, 'three answers so far');
select pg_temp.cq_check((public.class_teacher_dashboard(:'sid')->'current'->>'correct_count')::int = 2, 'two of them right');
select pg_temp.cq_check(:'dash' !~ '@' and :'dash' !~ '7000000', 'the dashboard shows no e-mail and no user id');
select pg_temp.cq_check(public.class_teacher_dashboard(:'sid')->'leaderboard'->0->>'nickname' in ('Ali', 'Gulnora'),
  'the leaderboard is by nickname');
reset role;

-- time runs out on the server clock
update public.class_sessions set question_started_at = clock_timestamp() - interval '30.5 seconds'
  where id = :'sid';
select pg_temp.cq_as('79000000-0000-0000-0000-0000000000b4');
select pg_temp.cq_check((public.class_session_state(:'sid')->>'phase') = 'closed', 'after 30 s the phase is closed');
select pg_temp.cq_check(not (public.class_session_state(:'sid') ? 'reveal'),
  'the right answer is still held back during the 1.5 s settling window');
select pg_temp.cq_check((public.class_submit_answer(:'sid', 0, :'c0')->>'ok')::boolean,
  'an answer inside the 1 s network grace is still taken');
reset role;
update public.class_sessions set question_started_at = clock_timestamp() - interval '40 seconds'
  where id = :'sid';
select pg_temp.cq_as('79000000-0000-0000-0000-0000000000b5');
select pg_temp.cq_check((public.class_submit_answer(:'sid', 0, :'c0')->>'error') = 'time_over',
  'an answer after the time is refused (server clock)');
select pg_temp.cq_check((public.class_session_state(:'sid')->'reveal'->>'correct_option') = :'c0',
  'once the time is over the right answer and explanation are shown');
select pg_temp.cq_check((public.class_session_state(:'sid')->'reveal'->>'explanation') like 'DEMO izoh%',
  'the explanation is part of the reveal');
reset role;
select pg_temp.cq_check((select count(*) = 4 from public.class_answers where question_index = 0),
  'four stored answers: the late one was not stored');

-- ------------------------------------------------------- next / kick / end
select pg_temp.cq_as('79000000-0000-0000-0000-0000000000a1');
select pg_temp.cq_check((public.class_next(:'sid')->>'finished')::boolean = false, 'next moves to question 1');
select pg_temp.cq_check((public.class_teacher_dashboard(:'sid')->>'current_index')::int = 1, 'current index is 1');
select pg_temp.cq_check((public.class_kick(:'sid', :'p2')->>'ok')::boolean, 'the teacher removes a participant');
select pg_temp.cq_check((public.class_teacher_dashboard(:'sid')->>'joined')::int = 4, 'the kicked participant is not counted');
select pg_temp.cq_check(public.class_teacher_dashboard(:'sid')::text !~ 'ali2', 'the kicked nickname leaves the dashboard');
reset role;
select pg_temp.cq_as('79000000-0000-0000-0000-0000000000b2');
select pg_temp.cq_check((public.class_session_state(:'sid')->>'kicked')::boolean, 'the kicked student sees they were removed');
select pg_temp.cq_forbidden(format($$select public.class_submit_answer(%L, 1, 'o0')$$, :'sid'),
  'a kicked student cannot answer');
select pg_temp.cq_check((public.class_join_session(:'scode', 'ali2')->>'error') = 'kicked',
  'a kicked student cannot rejoin');
reset role;

-- close early, then finish through next
select pg_temp.cq_as('79000000-0000-0000-0000-0000000000a1');
select pg_temp.cq_check((public.class_close_question(:'sid')->>'ok')::boolean, 'the teacher can close a question early');
select pg_temp.cq_check((public.class_teacher_dashboard(:'sid')->>'phase') = 'closed', 'closed right away');
select public.class_next(:'sid'); select public.class_next(:'sid'); select public.class_next(:'sid');
select pg_temp.cq_check((public.class_next(:'sid')->>'finished')::boolean, 'after the last question the session finishes');
select pg_temp.cq_check((public.class_teacher_dashboard(:'sid')->>'status') = 'finished', 'status finished');
reset role;
select pg_temp.cq_check((select expires_at > now() + interval '29 days' and expires_at < now() + interval '31 days'
  from public.class_sessions where id = :'sid'), 'a finished session expires in 30 days');

-- results
select pg_temp.cq_as('79000000-0000-0000-0000-0000000000b1');
select pg_temp.cq_check((public.class_my_results(:'sid')->>'ok')::boolean, 'results are available after the end');
select pg_temp.cq_check(jsonb_array_length(public.class_my_results(:'sid')->'items') = 5, 'one result item per question');
select pg_temp.cq_check((public.class_my_results(:'sid')->'items'->0->>'explanation') like 'DEMO izoh%'
  and (public.class_my_results(:'sid')->'items'->0->'source'->>'author') = 'DEMO',
  'results carry the explanation and the source');
select pg_temp.cq_check(jsonb_array_length(public.class_session_state(:'sid')->'leaderboard') <= 5,
  'the finished state shows at most five leaderboard rows');
select pg_temp.cq_check(public.class_session_state(:'sid')::text !~ '@', 'no e-mail in the leaderboard');
reset role;
select pg_temp.cq_as('79000000-0000-0000-0000-0000000000a1');
select public.class_export_results(:'sid')::text as exp \gset
select pg_temp.cq_check((public.class_export_results(:'sid')->'rows'->0->>'nickname') is not null
  and :'exp' !~ '@', 'the export has nicknames and no e-mail');
select pg_temp.cq_check(jsonb_array_length(public.class_export_results(:'sid')->'rows') = 4,
  'the export lists the four remaining participants');
reset role;

-- a second session is isolated from the first
select pg_temp.cq_as('79000000-0000-0000-0000-0000000000b1');
select pg_temp.cq_forbidden(format($$select public.class_session_state(%L)$$, :'sid2'),
  'a student of one class cannot read another class');
reset role;

-- ------------------------------------------------------------- reporting
select pg_temp.cq_as('79000000-0000-0000-0000-0000000000b3');
select pg_temp.cq_check((public.class_report_nickname(:'sid', :'p4', 'Nomaqbul laqab')->>'ok')::boolean, 'a student reports a nickname');
select public.class_report_nickname(:'sid', :'p4', 'Nomaqbul laqab');
select pg_temp.cq_check((public.class_report_nickname(:'sid', :'p4', 'x')->>'error') = 'bad_reason', 'a too short reason is refused');
reset role;
select pg_temp.cq_check((select count(*) = 1 from public.class_reports), 'a second report by the same student is not duplicated');
select pg_temp.cq_as('79000000-0000-0000-0000-0000000000c2');
select pg_temp.cq_forbidden(format($$select public.class_report_nickname(%L, %L, 'Nomaqbul')$$, :'sid', :'p4'),
  'an outsider cannot report');
reset role;

-- ------------------------------------------------- defence in depth (RLS)
-- If a table privilege were ever granted by mistake, the policies still
-- limit every reader to their own rows and the answer tables stay empty.
grant select on public.class_sessions, public.class_participants, public.class_answers,
  public.class_session_questions, public.class_quiz_questions to authenticated;
select pg_temp.cq_as('79000000-0000-0000-0000-0000000000b1');
select pg_temp.cq_check((select count(*) = 0 from public.class_sessions), 'RLS: a student sees no session rows');
select pg_temp.cq_check((select count(*) = 1 from public.class_participants), 'RLS: a student sees only their own participant row');
select pg_temp.cq_check((select count(*) <= 5 from public.class_answers), 'RLS: a student sees only their own answers');
select pg_temp.cq_check((select count(*) = 0 from public.class_answers
  where participant_id <> :'p1'), 'RLS: no one else''s answer is visible');
select pg_temp.cq_check((select count(*) = 0 from public.class_session_questions), 'RLS: session questions stay closed');
select pg_temp.cq_check((select count(*) = 0 from public.class_quiz_questions), 'RLS: the question bank stays closed');
reset role;
select pg_temp.cq_as('79000000-0000-0000-0000-0000000000a1');
select pg_temp.cq_check((select count(*) = 2 from public.class_sessions), 'RLS: a teacher sees exactly their own sessions');
reset role;
select pg_temp.cq_as('79000000-0000-0000-0000-0000000000a2');
select pg_temp.cq_check((select count(*) = 0 from public.class_sessions), 'RLS: another teacher sees none of them');
reset role;
revoke select on public.class_sessions, public.class_participants, public.class_answers,
  public.class_session_questions, public.class_quiz_questions from authenticated;

-- ----------------------------------------------- identity_admin may host
select pg_temp.cq_as('79000000-0000-0000-0000-0000000000a3');
select pg_temp.cq_check((public.class_create_session('demo-topic', 5, 10, 60)->>'ok')::boolean,
  'identity_admin can host a session too');
reset role;

-- ------------------------------------------------------ 30-day cleanup
update public.class_sessions set expires_at = now() - interval '1 day' where id = :'sid2';
update public.class_sessions set status = 'finished', finished_at = now() - interval '31 days',
  expires_at = now() - interval '1 day' where id = :'sid2';
select pg_temp.cq_check(private.class_cleanup() >= 1, 'the cleanup removes expired sessions');
select pg_temp.cq_check(not exists (select 1 from public.class_sessions where id = :'sid2'),
  'the expired session is gone');
select pg_temp.cq_check(exists (select 1 from public.class_sessions where id = :'sid'),
  'a session that has not expired yet is kept');
update public.class_sessions set expires_at = now() - interval '1 minute' where id = :'sid';
select private.class_cleanup();
select pg_temp.cq_check(not exists (select 1 from public.class_participants where session_id = :'sid')
  and not exists (select 1 from public.class_answers where session_id = :'sid')
  and not exists (select 1 from public.class_session_questions where session_id = :'sid'),
  'cleanup also removes participants, answers and the copied questions');

-- a teacher who loses the role loses the control at once
delete from account_roles where user_id = '79000000-0000-0000-0000-0000000000a2' and role = 'teacher';
select pg_temp.cq_as('79000000-0000-0000-0000-0000000000a2');
select pg_temp.cq_forbidden($$select public.class_create_session('demo-topic', 5, 5, 30)$$,
  'a revoked teacher cannot create sessions');
reset role;

-- ============================================ audit regressions (2026-10-18)
-- Migration 20261018040000_class_quiz_fixes.sql. Logic checks run as the
-- superuser with the JWT subject set (grants are covered above).
create function pg_temp.cq_sub(uid text) returns void language sql as $$
  select set_config('request.jwt.claim.sub', uid, false); $$;
insert into auth.users (id, email, created_at, email_confirmed_at)
select ('79000000-0000-0000-0000-000000000d' || lpad(g::text, 2, '0'))::uuid,
       'class-d' || g || '@secret.example', now(), now()
from generate_series(1, 40) g;

-- 7. nickname filter: real names pass, profanity is still blocked
select pg_temp.cq_check(private.class_nick_check('Себастьян') = 'ok'
  and private.class_nick_check('Глеба') = 'ok'
  and private.class_nick_check('Глеб') = 'ok'
  and private.class_nick_check('Ebaldiyev') = 'ok'
  and private.class_nick_check('Rebalance') = 'ok'
  and private.class_nick_check('Sikl') = 'ok'
  and private.class_nick_check('Sexta') = 'ok',
  'nickname filter: Себастьян, Глеба, Ebaldiyev, Rebalance are not blocked');
select pg_temp.cq_check(private.class_nick_check('сука') = 'blocked'
  and private.class_nick_check('СУКА') = 'blocked'
  and private.class_nick_check('Ебать') = 'blocked'
  and private.class_nick_check('ебанат') = 'blocked'
  and private.class_nick_check('Ali заебал') = 'blocked'
  and private.class_nick_check('е.б.а.т.ь') = 'blocked'
  and private.class_nick_check('ebal') = 'blocked'
  and private.class_nick_check('Ali ebal') = 'blocked'
  and private.class_nick_check('yebat') = 'blocked'
  and private.class_nick_check('долбоеб') = 'blocked'
  and private.class_nick_check('f.u.c.k') = 'blocked'
  and private.class_nick_check('PIDOR') = 'blocked',
  'nickname filter: real profanity is still blocked');

reset role;
select pg_temp.cq_sub('79000000-0000-0000-0000-0000000000a1');
select (public.class_create_session('demo-topic', 5, 50, 30))->'session'->>'id' as sid3 \gset
select code as code3 from public.class_sessions where id = :'sid3' \gset

-- 2. 35 students behind one NAT / university Wi-Fi IP all get in
select set_config('request.headers', '{"x-forwarded-for":"203.0.113.9, 10.0.0.1"}', false);
create temp table cq_joins (n int, err text);
do $$ declare g int; r jsonb; begin
  for g in 1..35 loop
    perform set_config('request.jwt.claim.sub',
      '79000000-0000-0000-0000-000000000d' || lpad(g::text, 2, '0'), false);
    r := public.class_join_session(
      (select code from public.class_sessions s
        where s.teacher_id = '79000000-0000-0000-0000-0000000000a1'
        order by s.created_at desc limit 1), 'Talaba ' || g);
    insert into cq_joins values (g, coalesce(r->>'error', 'ok'));
  end loop; end $$;
select pg_temp.cq_check((select count(*) = 35 from cq_joins where err = 'ok'),
  'IP limit: 35 students joining from one shared IP all get in');
-- rejoin (app restart) from the same IP is not counted against the IP either
select pg_temp.cq_sub('79000000-0000-0000-0000-000000000d01');
select pg_temp.cq_check((public.class_join_session(:'code3', 'Boshqa')->>'ok')::boolean,
  'IP limit: a rejoin from the shared IP still works');
select pg_temp.cq_check(not exists (select 1 from public.class_join_attempts
  where key = 'f:' || md5('203.0.113.9')),
  'IP limit: successful joins and rejoins leave no failure count on the IP');
-- wrong codes are counted per IP
select pg_temp.cq_sub('79000000-0000-0000-0000-000000000d36');
select public.class_join_session('12', 'Ali');
select public.class_join_session('000001', 'Ali');
select pg_temp.cq_check((select n = 2 from public.class_join_attempts
  where key = 'f:' || md5('203.0.113.9')),
  'IP limit: bad_code / not_found attempts are counted on the IP')
  where :'code3' <> '000001';
update public.class_join_attempts set n = 100 where key = 'f:' || md5('203.0.113.9');
select pg_temp.cq_sub('79000000-0000-0000-0000-000000000d37');
select pg_temp.cq_check((public.class_join_session(:'code3', 'Mehmon')->>'error') = 'rate_limited',
  'IP limit: 100 wrong codes from one IP within the hour block that IP');
select set_config('request.headers', '', false);
select pg_temp.cq_check((public.class_join_session(:'code3', 'Mehmon')->>'ok')::boolean,
  'IP limit: the same student from another network gets in');
-- the per-account limit still applies (30 per hour, every attempt)
select pg_temp.cq_check((select n = 2 from public.class_join_attempts
  where key = 'u:79000000-0000-0000-0000-000000000d37'),
  'account limit: every attempt is still counted on the account');

-- 1. no score / rank / correct-count while the question is open
select pg_temp.cq_sub('79000000-0000-0000-0000-0000000000a1');
select pg_temp.cq_check((public.class_start(:'sid3')->>'ok')::boolean, 'regression session starts');
select 'o' || correct_index as c3 from public.class_session_questions
  where session_id = :'sid3' and idx = 0 \gset
select case when :'c3' = 'o0' then 'o1' else 'o0' end as w3 \gset
select pg_temp.cq_sub('79000000-0000-0000-0000-000000000d01');
select public.class_submit_answer(:'sid3', 0, :'c3');
select pg_temp.cq_sub('79000000-0000-0000-0000-000000000d02');
select public.class_submit_answer(:'sid3', 0, :'w3');
select pg_temp.cq_sub('79000000-0000-0000-0000-000000000d01');
select pg_temp.cq_check((public.class_session_state(:'sid3')->>'score')::int = 0
  and (public.class_session_state(:'sid3')->>'correct')::int = 0,
  'open question: a right answer does not show up in score/correct yet');
select pg_temp.cq_sub('79000000-0000-0000-0000-000000000d02');
select x->>'rank' as r_wrong_open from (select public.class_session_state(:'sid3') x) t \gset
select pg_temp.cq_sub('79000000-0000-0000-0000-000000000d01');
select x->>'rank' as r_right_open from (select public.class_session_state(:'sid3') x) t \gset
select pg_temp.cq_check(:'r_wrong_open' = :'r_right_open',
  'open question: right and wrong answerers have the same rank (nothing leaks)');
select pg_temp.cq_sub('79000000-0000-0000-0000-0000000000a1');
select pg_temp.cq_check(not exists (select 1 from jsonb_array_elements(
    public.class_teacher_dashboard(:'sid3')->'leaderboard') r where (r->>'score')::int > 0),
  'open question: the teacher (projector) leaderboard has no points yet');
select pg_temp.cq_check((public.class_teacher_dashboard(:'sid3')->>'revealed')::boolean = false,
  'open question: the dashboard says revealed = false');
-- 3. deadline passed but answers still accepted (grace): not revealed yet
reset role;
update public.class_sessions set question_started_at = clock_timestamp() - interval '30.3 seconds'
  where id = :'sid3';
select pg_temp.cq_sub('79000000-0000-0000-0000-0000000000a1');
select pg_temp.cq_check((public.class_teacher_dashboard(:'sid3')->>'phase') = 'closed'
  and (public.class_teacher_dashboard(:'sid3')->>'revealed')::boolean = false,
  'grace window: phase closed but revealed = false (projector keeps the answer hidden)');
select pg_temp.cq_check(not exists (select 1 from jsonb_array_elements(
    public.class_teacher_dashboard(:'sid3')->'leaderboard') r where (r->>'score')::int > 0)
  and jsonb_array_length(public.class_teacher_dashboard(:'sid3')->'hardest') = 0,
  'grace window: no points and no hardest-question stats yet');
select pg_temp.cq_sub('79000000-0000-0000-0000-000000000d01');
select pg_temp.cq_check((public.class_session_state(:'sid3')->>'score')::int = 0,
  'grace window: the student score is still held back');
select pg_temp.cq_sub('79000000-0000-0000-0000-000000000d03');
select pg_temp.cq_check((public.class_submit_answer(:'sid3', 0, :'w3')->>'ok')::boolean,
  'grace window: a late answer is still taken');
reset role;
update public.class_sessions set question_started_at = clock_timestamp() - interval '32 seconds'
  where id = :'sid3';
select pg_temp.cq_sub('79000000-0000-0000-0000-0000000000a1');
select pg_temp.cq_check((public.class_teacher_dashboard(:'sid3')->>'revealed')::boolean,
  'after the settling window the dashboard says revealed = true');
select pg_temp.cq_check((public.class_teacher_dashboard(:'sid3')->'leaderboard'->0->>'nickname') = 'Talaba 1'
  and (public.class_teacher_dashboard(:'sid3')->'leaderboard'->0->>'score')::int > 0,
  'after reveal the leaderboard counts the question');
select pg_temp.cq_sub('79000000-0000-0000-0000-000000000d01');
select pg_temp.cq_check((public.class_session_state(:'sid3')->>'score')::int > 0
  and (public.class_session_state(:'sid3')->>'correct')::int = 1
  and (public.class_session_state(:'sid3')->>'rank')::int = 1,
  'after reveal the student sees score, correct and rank');
-- 6. a non-answerer does not rank above a wrong answerer
select pg_temp.cq_sub('79000000-0000-0000-0000-0000000000a1');
select pg_temp.cq_check(
  (select (r->>'rank')::int from jsonb_array_elements(public.class_export_results(:'sid3')->'rows') r
    where r->>'nickname' = 'Talaba 2')
  = (select (r->>'rank')::int from jsonb_array_elements(public.class_export_results(:'sid3')->'rows') r
    where r->>'nickname' = 'Talaba 4'),
  'ranking: a wrong answerer and a non-answerer (both 0 points) share the rank');
select pg_temp.cq_check((select rk from private.class_scores(:'sid3') where nickname = 'Talaba 1')
  < (select rk from private.class_scores(:'sid3') where nickname = 'Talaba 2'),
  'ranking: a right answer ranks above a wrong one');
select pg_temp.cq_check((select avg_ms is null from private.class_scores(:'sid3') where nickname = 'Talaba 2')
  and (select avg_ms is not null from private.class_scores(:'sid3') where nickname = 'Talaba 1'),
  'ranking: average time is over right answers only (none → null, sorted last)');
select pg_temp.cq_check((select (r->>'avg_ms')::int > 0 from jsonb_array_elements(
    public.class_export_results(:'sid3')->'rows') r where r->>'nickname' = 'Talaba 2'),
  'export: the CSV answer time still averages all visible answers');

-- 5. a participant reopens a finished session after an app restart
select pg_temp.cq_check((public.class_kick(:'sid3', (select id from public.class_participants
    where session_id = :'sid3' and nickname = 'Talaba 5'))->>'ok')::boolean, 'kick one before the end');
select pg_temp.cq_check((public.class_finish(:'sid3')->>'ok')::boolean, 'regression session finishes');
select pg_temp.cq_sub('79000000-0000-0000-0000-000000000d01');
select pg_temp.cq_check((public.class_join_session(:'code3', 'Talaba 1')->>'ok')::boolean
  and (public.class_join_session(:'code3', 'Talaba 1')->'session'->>'status') = 'finished'
  and (public.class_join_session(:'code3', 'Talaba 1')->>'nickname') = 'Talaba 1',
  'finished session: an existing participant rejoins (ok, status finished)');
select pg_temp.cq_check((public.class_my_results(:'sid3')->>'ok')::boolean,
  'finished session: the rejoined student can open the results');
select pg_temp.cq_sub('79000000-0000-0000-0000-000000000d05');
select pg_temp.cq_check((public.class_join_session(:'code3', 'Talaba 5')->>'error') = 'kicked',
  'finished session: a kicked participant still cannot rejoin');
select pg_temp.cq_sub('79000000-0000-0000-0000-000000000d38');
select pg_temp.cq_check((public.class_join_session(:'code3', 'Yangi')->>'error') = 'finished',
  'finished session: a new student still cannot join');
select pg_temp.cq_sub('');
select pg_temp.cq_check(not has_function_privilege('authenticated', 'private.class_join_fail_ip()', 'execute')
  and not has_function_privilege('anon', 'private.class_join_fail_ip()', 'execute'),
  'the new IP-failure helper is not callable by clients');
\echo ALL CLASS QUIZ TESTS PASSED
