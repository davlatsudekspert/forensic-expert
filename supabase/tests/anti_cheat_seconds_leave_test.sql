-- Anti-cheat (server), migration 20261031010000:
--   1. free per-question seconds (5..300) for the live class quiz; the server time
--      logic works with free values (host and self pace);
--   2. «left the app» counters: class_report_leave / group_report_leave
--      (permissions, state rules, 1-second rate limit, teacher-only visibility).
-- Runs after class_groups_test.sql (roles and helpers are created here again).
\set ON_ERROR_STOP 1
reset role;
-- Earlier test files grant table privileges for their own checks; restore the
-- migration's state (all class tables are closed to clients).
revoke all on public.class_quiz_questions, public.class_sessions,
  public.class_session_questions, public.class_participants, public.class_answers,
  public.class_reports, public.class_groups, public.class_group_members,
  public.class_assignments, public.class_assignment_questions,
  public.class_assignment_attempts from anon, authenticated;

create function pg_temp.ac_sub(uid text) returns void language sql as $$
  select set_config('request.jwt.claim.sub', uid, false); $$;
create function pg_temp.ac_check(ok boolean, label text) returns void language plpgsql as $$
begin
  if not coalesce(ok, false) then raise exception 'FAIL: %', label; end if;
  raise notice 'PASS: %', label;
end $$;
create function pg_temp.ac_state(q text) returns text language plpgsql as $$
begin
  execute q;
  return 'OK';
exception when others then
  return sqlstate;
end $$;
grant execute on function pg_temp.ac_state(text) to anon, authenticated;
-- Runs `q` as a client role; returns the SQLSTATE ('OK' when it succeeds).
create function pg_temp.ac_as_state(rl text, uid text, q text) returns text language plpgsql as $$
declare st text;
begin
  perform set_config('request.jwt.claim.sub', uid, false);
  perform set_config('request.jwt.claims', '{}', false);
  perform set_config('role', rl, false);
  st := pg_temp.ac_state(q);
  perform set_config('role', 'postgres', false);
  return st;
end $$;
-- The student confirms an answer to their current question (self pace).
create function pg_temp.ac_answer(uid text, sid uuid) returns jsonb
language plpgsql as $$
declare v_idx int; v_c int;
begin
  perform set_config('request.jwt.claim.sub', uid, false);
  v_idx := (public.class_session_state(sid) -> 'question' ->> 'index')::int;
  select correct_index into v_c from public.class_session_questions
    where session_id = sid and idx = v_idx;
  return public.class_submit_answer(sid, v_idx, 'o' || v_c);
end $$;

-- t1 owning teacher, t2 another teacher, s1..s3 students, k kicked, x outsider.
\set t1 '7d000000-0000-0000-0000-0000000000a1'
\set t2 '7d000000-0000-0000-0000-0000000000a2'
\set s1 '7d000000-0000-0000-0000-0000000000b1'
\set s2 '7d000000-0000-0000-0000-0000000000b2'
\set s3 '7d000000-0000-0000-0000-0000000000b3'
\set k  '7d000000-0000-0000-0000-0000000000b4'
\set x  '7d000000-0000-0000-0000-0000000000c1'
insert into auth.users (id, email, created_at, email_confirmed_at) values
 (:'t1', 'ac-teacher-one@secret.example', now(), now()),
 (:'t2', 'ac-teacher-two@secret.example', now(), now()),
 (:'s1', 'ac-student-one@secret.example', now(), now()),
 (:'s2', 'ac-student-two@secret.example', now(), now()),
 (:'s3', 'ac-student-three@secret.example', now(), now()),
 (:'k',  'ac-kicked@secret.example', now(), now()),
 (:'x',  'ac-outsider@secret.example', now(), now());
insert into account_roles (user_id, role, granted_by) values
 (:'t1', 'teacher', null), (:'t2', 'teacher', null);

-- Own question bank (does not depend on other test files).
insert into public.class_quiz_questions
  (topic_id, topic_title, position, question, options, correct_index, explanation, source)
select 'ac-topic', 'Anti-cheat mavzu', g, 'AC savol raqami ' || g,
       jsonb_build_array('A' || g, 'B' || g, 'C' || g, 'D' || g), (g % 4)::smallint,
       'Izoh ' || g, '{"author":"Muallif","title":"Darslik","page":"12"}'::jsonb
from generate_series(1, 8) g;

-- ============================================== 1. free seconds (5..300)
select pg_temp.ac_sub(:'t1');
select pg_temp.ac_check((public.class_create_session('ac-topic', 5, 10, 20)->>'ok')::boolean
  and (public.class_create_session('ac-topic', 5, 10, 20)->'session'->>'seconds')::int = 20,
  'seconds = 20 accepted and reported back');
select pg_temp.ac_check((public.class_create_session('ac-topic', 5, 10, 5)->'session'->>'seconds')::int = 5,
  'lower bound 5 accepted');
select pg_temp.ac_check((public.class_create_session('ac-topic', 5, 10, 300)->'session'->>'seconds')::int = 300,
  'upper bound 300 accepted');
select pg_temp.ac_check((public.class_create_session('ac-topic', 5, 10, 90)->'session'->>'seconds')::int = 90,
  '90 accepted');
select pg_temp.ac_check((public.class_create_session('ac-topic', 5, 10, 4)->>'error') = 'invalid_settings',
  '4 seconds refused (invalid_settings)');
select pg_temp.ac_check((public.class_create_session('ac-topic', 5, 10, 301)->>'error') = 'invalid_settings',
  '301 seconds refused');
select pg_temp.ac_check((public.class_create_session('ac-topic', 5, 10, 0)->>'error') = 'invalid_settings',
  '0 seconds refused');
select pg_temp.ac_check((public.class_create_session('ac-topic', 5, 10, -30)->>'error') = 'invalid_settings',
  'negative seconds refused');
select pg_temp.ac_check((public.class_create_session('ac-topic', 5, 10, null)->>'error') = 'invalid_settings',
  'null seconds refused');
select pg_temp.ac_check((public.class_create_session('ac-topic', 4, 10, 30)->>'error') = 'invalid_settings'
  and (public.class_create_session('ac-topic', 5, 4, 30)->>'error') = 'invalid_settings'
  and (public.class_create_session('', 5, 10, 30)->>'error') = 'invalid_settings',
  'the other settings checks are unchanged (question_count, student_limit, topic)');
select pg_temp.ac_check((public.class_create_session('ac-topic', 5, 10, 15)->>'ok')::boolean
  and (public.class_create_session('ac-topic', 5, 10, 45)->>'ok')::boolean,
  'the old fixed values (15, 45) still work');
-- Sessions created above fill the 10-session cap; free the owner's slots.
reset role;
update public.class_sessions set status = 'finished', finished_at = now() where teacher_id = :'t1';
select pg_temp.ac_sub(:'t1');
select pg_temp.ac_check((public.class_create_session_pace('ac-topic', 5, 10, 20, 'self')->'session'->>'seconds')::int = 20
  and (public.class_create_session_pace('ac-topic', 5, 10, 20, 'self')->'session'->>'pace') = 'self',
  'class_create_session_pace passes a free value (20, self) through');
select pg_temp.ac_check((public.class_create_session_pace('ac-topic', 5, 10, 301, 'self')->>'error') = 'invalid_settings'
  and (public.class_create_session_pace('ac-topic', 5, 10, 4, 'host')->>'error') = 'invalid_settings',
  'class_create_session_pace: 301 and 4 refused');
select pg_temp.ac_check(pg_temp.ac_as_state('authenticated', :'s1',
  $$select public.class_create_session('ac-topic', 5, 10, 20)$$) = '42501',
  'a student still cannot create a session (403)');
select pg_temp.ac_check(pg_temp.ac_as_state('anon', '',
  $$select public.class_create_session('ac-topic', 5, 10, 20)$$) <> 'OK',
  'anon still cannot create a session');
reset role;
update public.class_sessions set status = 'finished', finished_at = now() where teacher_id = :'t1';

-- ---- host mode with free seconds: the clock uses settings->>'seconds'
select pg_temp.ac_sub(:'t1');
select public.class_create_session('ac-topic', 5, 10, 5)->'session'->>'id' as h5 \gset
select public.class_create_session('ac-topic', 5, 10, 300)->'session'->>'id' as h300 \gset
select code as h5code from public.class_sessions where id = :'h5' \gset
select code as h300code from public.class_sessions where id = :'h300' \gset
select pg_temp.ac_sub(:'s1');
select public.class_join_session(:'h5code', 'Aziza') ->> 'ok' as _j1 \gset
select public.class_join_session(:'h300code', 'Aziza') ->> 'ok' as _j2 \gset
select pg_temp.ac_sub(:'t1');
select public.class_start(:'h5') ->> 'ok' as _s1 \gset
select public.class_start(:'h300') ->> 'ok' as _s2 \gset
select pg_temp.ac_sub(:'s1');
select public.class_session_state(:'h5') as st5 \gset
select pg_temp.ac_check((:'st5'::jsonb->>'seconds')::int = 5 and (:'st5'::jsonb->>'phase') = 'open'
  and (:'st5'::jsonb->>'remaining_ms')::int between 1 and 5000,
  'host, 5 s: phase open, remaining_ms within 5000');
select public.class_session_state(:'h300') as st300 \gset
select pg_temp.ac_check((:'st300'::jsonb->>'seconds')::int = 300 and (:'st300'::jsonb->>'phase') = 'open'
  and (:'st300'::jsonb->>'remaining_ms')::int between 295000 and 300000,
  'host, 300 s: phase open, remaining_ms ~ 300000');
select pg_sleep(5.3);
select public.class_session_state(:'h5') as st5b \gset
select pg_temp.ac_check((:'st5b'::jsonb->>'phase') = 'closed' and (:'st5b'::jsonb->>'remaining_ms')::int = 0,
  'host, 5 s: after 5.3 s the phase is closed (real wait)');
select pg_sleep(1.1);  -- the server allows a 1 s network grace after the limit
select pg_temp.ac_check((public.class_submit_answer(:'h5', 0, 'o0')->>'error') = 'time_over',
  'host, 5 s: an answer after 5 s + grace is refused (time_over)');
-- 300 s: backdate the shared question start (superuser) instead of waiting.
reset role;
update public.class_sessions set question_started_at = clock_timestamp() - interval '299 seconds' where id = :'h300';
select pg_temp.ac_sub(:'s1');
select pg_temp.ac_check((public.class_session_state(:'h300')->>'phase') = 'open'
  and (public.class_submit_answer(:'h300', 0, 'o1')->>'ok')::boolean,
  'host, 300 s: still open and the answer accepted at 299 s');
reset role;
update public.class_sessions set question_started_at = clock_timestamp() - interval '303 seconds' where id = :'h300';
delete from public.class_answers where session_id = :'h300';
select pg_temp.ac_sub(:'s1');
select pg_temp.ac_check((public.class_session_state(:'h300')->>'phase') = 'closed'
  and (public.class_submit_answer(:'h300', 0, 'o1')->>'error') = 'time_over',
  'host, 300 s: closed and refused (time_over) at 303 s');

-- ---- self pace with free seconds (20): per-student clock
select pg_temp.ac_sub(:'t1');
select public.class_create_session_pace('ac-topic', 5, 10, 20, 'self')->'session'->>'id' as p20 \gset
select code as p20code from public.class_sessions where id = :'p20' \gset
select pg_temp.ac_sub(:'s1');
select public.class_join_session(:'p20code', 'Aziza') ->> 'ok' as _j3 \gset
select pg_temp.ac_sub(:'t1');
select public.class_start(:'p20') ->> 'ok' as _s3 \gset
select pg_temp.ac_sub(:'s1');
select public.class_next_mine(:'p20') ->> 'ok' as _n1 \gset
select public.class_session_state(:'p20') as sp \gset
select pg_temp.ac_check((:'sp'::jsonb->>'phase') = 'open'
  and (:'sp'::jsonb->>'remaining_ms')::int between 15000 and 20000,
  'self, 20 s: own timer open, remaining_ms within 20000');
reset role;
update public.class_participants set question_started_at = clock_timestamp() - interval '19 seconds'
  where session_id = :'p20';
select pg_temp.ac_sub(:'s1');
select pg_temp.ac_check((pg_temp.ac_answer(:'s1', :'p20')->>'ok')::boolean,
  'self, 20 s: an answer at 19 s is accepted');
select pg_temp.ac_check((public.class_next_mine(:'p20')->>'ok')::boolean,
  'self, 20 s: the student moves on after answering');
reset role;
update public.class_participants set question_started_at = clock_timestamp() - interval '22.5 seconds'
  where session_id = :'p20';
select pg_temp.ac_sub(:'s1');
select pg_temp.ac_check((pg_temp.ac_answer(:'s1', :'p20')->>'error') = 'time_over',
  'self, 20 s: an answer at 22.5 s is refused (time_over)');
select pg_temp.ac_check((public.class_session_state(:'p20')->>'phase') = 'closed'
  and (public.class_next_mine(:'p20')->>'ok')::boolean,
  'self, 20 s: the expired question is closed, the student may move on');

-- ---- self pace with 90 s
select pg_temp.ac_sub(:'t1');
select public.class_create_session_pace('ac-topic', 5, 10, 90, 'self')->'session'->>'id' as p90 \gset
select code as p90code from public.class_sessions where id = :'p90' \gset
select pg_temp.ac_sub(:'s1');
select public.class_join_session(:'p90code', 'Aziza') ->> 'ok' as _j4 \gset
select pg_temp.ac_sub(:'t1');
select public.class_start(:'p90') ->> 'ok' as _s4 \gset
select pg_temp.ac_sub(:'s1');
select public.class_next_mine(:'p90') ->> 'ok' as _n2 \gset
reset role;
update public.class_participants set question_started_at = clock_timestamp() - interval '80 seconds'
  where session_id = :'p90';
select pg_temp.ac_sub(:'s1');
select pg_temp.ac_check((public.class_session_state(:'p90')->>'remaining_ms')::int between 5000 and 10000
  and (public.class_next_mine(:'p90')->>'error') = 'not_closed',
  'self, 90 s: at 80 s the question is still open (not_closed)');
reset role;
update public.class_participants set question_started_at = clock_timestamp() - interval '92 seconds'
  where session_id = :'p90';
select pg_temp.ac_sub(:'s1');
select pg_temp.ac_check((pg_temp.ac_answer(:'s1', :'p90')->>'error') = 'time_over',
  'self, 90 s: an answer at 92 s is refused (time_over)');

-- ============================================== 2a. live class: leave counter
-- Fresh host session (20 s) with s1, s2, a kicked student k.
select pg_temp.ac_sub(:'t1');
select public.class_create_session('ac-topic', 5, 10, 20)->'session'->>'id' as lh \gset
select code as lhcode from public.class_sessions where id = :'lh' \gset
select pg_temp.ac_sub(:'s1');
select public.class_join_session(:'lhcode', 'Lola') ->> 'participant_id' as lp1 \gset
select pg_temp.ac_sub(:'s2');
select public.class_join_session(:'lhcode', 'Bobur') ->> 'participant_id' as lp2 \gset
select pg_temp.ac_sub(:'k');
select public.class_join_session(:'lhcode', 'Kicked') ->> 'participant_id' as lpk \gset

-- permissions
select pg_temp.ac_check(pg_temp.ac_as_state('anon', '',
  format($$select public.class_report_leave(%L)$$, :'lh')) <> 'OK',
  'anon cannot call class_report_leave');
select pg_temp.ac_check(pg_temp.ac_as_state('anon', '',
  format($$select public.group_report_leave(%L)$$, gen_random_uuid())) <> 'OK',
  'anon cannot call group_report_leave');
select pg_temp.ac_check(
  not has_function_privilege('anon', 'public.class_report_leave(uuid)', 'execute')
  and not has_function_privilege('anon', 'public.group_report_leave(uuid)', 'execute')
  and has_function_privilege('authenticated', 'public.class_report_leave(uuid)', 'execute')
  and has_function_privilege('authenticated', 'public.group_report_leave(uuid)', 'execute'),
  'execute: authenticated yes, anon no (both RPCs)');
select pg_temp.ac_check(pg_temp.ac_as_state('authenticated', :'x',
  format($$select public.class_report_leave(%L)$$, :'lh')) = '42501',
  'an outsider (not a participant) gets 403');
select pg_temp.ac_check(pg_temp.ac_as_state('authenticated', :'t2',
  format($$select public.class_report_leave(%L)$$, :'lh')) = '42501',
  'another teacher gets 403');
select pg_temp.ac_check(pg_temp.ac_as_state('authenticated', :'s1',
  $$select public.class_report_leave(gen_random_uuid())$$) = '42501',
  'an unknown session id gets 403');

-- lobby: harmless, not counted
select pg_temp.ac_sub(:'s1');
select pg_temp.ac_check((public.class_report_leave(:'lh')->>'ok')::boolean
  and not (public.class_report_leave(:'lh')->>'counted')::boolean,
  'lobby: {ok:true, counted:false}');
select pg_temp.ac_sub(:'t1');
select public.class_start(:'lh') ->> 'ok' as _s5 \gset
select public.class_kick(:'lh', :'lpk') ->> 'ok' as _kk \gset
select pg_temp.ac_check(pg_temp.ac_as_state('authenticated', :'k',
  format($$select public.class_report_leave(%L)$$, :'lh')) = '42501',
  'a kicked student gets 403');

-- running: counted once per second per participant
select pg_temp.ac_sub(:'s1');
select pg_temp.ac_check((public.class_report_leave(:'lh')->>'counted')::boolean,
  'running: the first report is counted');
select pg_temp.ac_check(not (public.class_report_leave(:'lh')->>'counted')::boolean
  and (public.class_report_leave(:'lh')->>'ok')::boolean,
  'rate limit: a second report within 1 s is not counted');
select pg_temp.ac_check((select leave_count = 1 and last_left_at is not null
  from public.class_participants where id = :'lp1'),
  'leave_count = 1 after a burst of calls');
select pg_sleep(1.1);
select pg_temp.ac_check((public.class_report_leave(:'lh')->>'counted')::boolean,
  'after 1.1 s the next report is counted again');
select pg_temp.ac_check((select leave_count = 2 from public.class_participants where id = :'lp1'),
  'leave_count = 2');
-- the limit is per participant: s2 is not throttled by s1
select pg_temp.ac_sub(:'s2');
select pg_temp.ac_check((public.class_report_leave(:'lh')->>'counted')::boolean,
  'the 1 s limit is per participant (s2 counted right after s1)');

-- the counter never changes scores, answers or the session
select pg_temp.ac_check((select count(*) = 0 from public.class_answers where session_id = :'lh'),
  'a leave creates no answers / points');

-- visibility: teacher yes, student no
select pg_temp.ac_sub(:'t1');
select public.class_teacher_dashboard(:'lh') as dh \gset
select pg_temp.ac_check((select (e->>'leave_count')::int = 2 and (e->>'last_left_at') is not null
    from jsonb_array_elements(:'dh'::jsonb->'participants') e where e->>'nickname' = 'Lola')
  and (select (e->>'leave_count')::int = 1
    from jsonb_array_elements(:'dh'::jsonb->'participants') e where e->>'nickname' = 'Bobur'),
  'dashboard (host): participants[].leave_count / last_left_at (2 and 1)');
select pg_temp.ac_check((select every(e ? 'leave_count' and e ? 'last_left_at' and e ? 'answered' and e ? 'id')
    from jsonb_array_elements(:'dh'::jsonb->'participants') e)
  and (:'dh'::jsonb ? 'leaderboard') and (:'dh'::jsonb ? 'hardest') and (:'dh'::jsonb ? 'current'),
  'dashboard (host): existing keys are all still present');
select pg_temp.ac_check(pg_temp.ac_as_state('authenticated', :'s1',
  format($$select public.class_teacher_dashboard(%L)$$, :'lh')) = '42501',
  'a student cannot read the dashboard (403)');
select pg_temp.ac_check(pg_temp.ac_as_state('authenticated', :'t2',
  format($$select public.class_teacher_dashboard(%L)$$, :'lh')) = '42501',
  'another teacher cannot read the dashboard (403)');
select pg_temp.ac_sub(:'s1');
select pg_temp.ac_check(public.class_session_state(:'lh')::text !~ 'leave'
  and public.class_my_results(:'lh')::text !~ 'leave',
  'student payloads (class_session_state, class_my_results) carry no leave data');
select pg_temp.ac_check(pg_temp.ac_as_state('authenticated', :'s1',
  'select leave_count from public.class_participants') = '42501'
  and pg_temp.ac_as_state('authenticated', :'s1',
  format($$update public.class_participants set leave_count = 0 where id = %L$$, :'lp1')) = '42501',
  'no table privilege: a student can neither read nor reset leave_count directly');
select pg_temp.ac_sub(:'t1');
select pg_temp.ac_check((public.class_export_results(:'lh')::text !~ 'leave'), 'export is unchanged (no leave keys)');

-- finished session: not counted
select public.class_finish(:'lh') ->> 'ok' as _f1 \gset
select pg_temp.ac_sub(:'s1');
select pg_sleep(1.1);
select pg_temp.ac_check(not (public.class_report_leave(:'lh')->>'counted')::boolean
  and (select leave_count = 2 from public.class_participants where id = :'lp1'),
  'finished session: not counted, counter unchanged');

-- ---- self pace: counted only while the student is solving
select pg_temp.ac_sub(:'t1');
select public.class_create_session_pace('ac-topic', 5, 10, 30, 'self')->'session'->>'id' as ls \gset
select code as lscode from public.class_sessions where id = :'ls' \gset
select pg_temp.ac_sub(:'s1');
select public.class_join_session(:'lscode', 'Lola') ->> 'participant_id' as sp1 \gset
select pg_temp.ac_sub(:'s2');
select public.class_join_session(:'lscode', 'Bobur') ->> 'participant_id' as sp2 \gset
select pg_temp.ac_sub(:'s3');
select public.class_join_session(:'lscode', 'Cavhar') ->> 'participant_id' as sp3 \gset
select pg_temp.ac_sub(:'t1');
select public.class_start(:'ls') ->> 'ok' as _s6 \gset
select pg_temp.ac_sub(:'s1');
select pg_temp.ac_check(not (public.class_report_leave(:'ls')->>'counted')::boolean,
  'self: before the student opens the first question nothing is counted');
select public.class_next_mine(:'ls') ->> 'ok' as _n3 \gset
select pg_temp.ac_check((public.class_report_leave(:'ls')->>'counted')::boolean,
  'self: while solving the leave is counted');
select pg_temp.ac_check(not (public.class_report_leave(:'ls')->>'counted')::boolean,
  'self: the 1 s limit applies');
-- s1 finishes all 5 questions (answer + next, five times)
select pg_temp.ac_answer(:'s1', :'ls') ->> 'ok' as _a1 \gset
select public.class_next_mine(:'ls') ->> 'ok' as _x1 \gset
select pg_temp.ac_answer(:'s1', :'ls') ->> 'ok' as _a2 \gset
select public.class_next_mine(:'ls') ->> 'ok' as _x2 \gset
select pg_temp.ac_answer(:'s1', :'ls') ->> 'ok' as _a3 \gset
select public.class_next_mine(:'ls') ->> 'ok' as _x3 \gset
select pg_temp.ac_answer(:'s1', :'ls') ->> 'ok' as _a4 \gset
select public.class_next_mine(:'ls') ->> 'ok' as _x4 \gset
select pg_temp.ac_answer(:'s1', :'ls') ->> 'ok' as _a5 \gset
select public.class_next_mine(:'ls') ->> 'ok' as _x5 \gset
select pg_temp.ac_check((select finished_at is not null from public.class_participants where id = :'sp1'),
  'self: s1 finished all questions');
select pg_sleep(1.1);
select pg_temp.ac_check(not (public.class_report_leave(:'ls')->>'counted')::boolean
  and (select leave_count = 1 from public.class_participants where id = :'sp1'),
  'self: after the student finished a leave is not counted (counter stays 1)');
select pg_temp.ac_sub(:'s2');
select public.class_next_mine(:'ls') ->> 'ok' as _n4 \gset
select pg_temp.ac_check((public.class_report_leave(:'ls')->>'counted')::boolean,
  'self: s2 (still solving) is counted independently of s1');
select pg_temp.ac_sub(:'t1');
select public.class_teacher_dashboard(:'ls') as ds \gset
select pg_temp.ac_check((select (e->>'leave_count')::int = 1 and (e->>'done')::boolean
    from jsonb_array_elements(:'ds'::jsonb->'participants') e where e->>'nickname' = 'Lola')
  and (select (e->>'leave_count')::int = 1 and not (e->>'done')::boolean
    from jsonb_array_elements(:'ds'::jsonb->'participants') e where e->>'nickname' = 'Bobur')
  and (select (e->>'leave_count')::int = 0 and (e->>'last_left_at') is null
    from jsonb_array_elements(:'ds'::jsonb->'participants') e where e->>'nickname' = 'Cavhar'),
  'dashboard (self): leave_count/last_left_at per participant (1, 1, 0/null)');
select pg_temp.ac_check((select every(e ? 'position' and e ? 'answered_count' and e ? 'correct_count' and e ? 'done')
    from jsonb_array_elements(:'ds'::jsonb->'participants') e)
  and (:'ds'::jsonb->'self' ? 'opened') and (:'ds'::jsonb->'self' ? 'done'),
  'dashboard (self): existing keys are all still present');
select pg_temp.ac_sub(:'s2');
select pg_temp.ac_check(public.class_session_state(:'ls')::text !~ 'leave'
  and public.class_next_mine(:'ls')::text !~ 'leave',
  'student payloads in self pace carry no leave data');

-- ============================================== 2b. group test: leave counter
select pg_temp.ac_sub(:'t1');
select public.group_create('AC guruh') -> 'group' ->> 'id' as gid \gset
select code as gcode from public.class_groups where id = :'gid' \gset
select pg_temp.ac_sub(:'s1');
select public.group_join(:'gcode', 'Lola') ->> 'role' as _g1 \gset
select pg_temp.ac_sub(:'s2');
select public.group_join(:'gcode', 'Bobur') ->> 'role' as _g2 \gset
select pg_temp.ac_sub(:'s3');
select public.group_join(:'gcode', 'Cavhar') ->> 'role' as _g3 \gset
select pg_temp.ac_sub(:'t1');
select (public.group_assignment_create(:'gid', 'ac-topic', 5, null, null, false, 'after_close')
        -> 'assignment' ->> 'id') as ga \gset

select pg_temp.ac_check(pg_temp.ac_as_state('anon', '',
  format($$select public.group_report_leave(%L)$$, :'ga')) <> 'OK',
  'anon cannot call group_report_leave on a real assignment');
select pg_temp.ac_check(pg_temp.ac_as_state('authenticated', :'x',
  format($$select public.group_report_leave(%L)$$, :'ga')) = '42501',
  'group: a non-member gets 403');
select pg_temp.ac_check(pg_temp.ac_as_state('authenticated', :'t2',
  format($$select public.group_report_leave(%L)$$, :'ga')) = '42501',
  'group: another teacher gets 403');
select pg_temp.ac_check(pg_temp.ac_as_state('authenticated', :'s1',
  $$select public.group_report_leave(gen_random_uuid())$$) = '42501',
  'group: an unknown assignment id gets 403');

-- before opening the test there is no attempt: nothing to count
select pg_temp.ac_sub(:'s1');
select pg_temp.ac_check((public.group_report_leave(:'ga')->>'ok')::boolean
  and not (public.group_report_leave(:'ga')->>'counted')::boolean,
  'group: no attempt yet -> {ok:true, counted:false}');
select public.group_assignment_open(:'ga') ->> 'state' as _o1 \gset
select pg_temp.ac_check((public.group_report_leave(:'ga')->>'counted')::boolean,
  'group: attempt in progress -> counted');
select pg_temp.ac_check(not (public.group_report_leave(:'ga')->>'counted')::boolean,
  'group: 1 s rate limit (burst not counted)');
select pg_sleep(1.1);
select pg_temp.ac_check((public.group_report_leave(:'ga')->>'counted')::boolean,
  'group: counted again after 1.1 s');
select pg_temp.ac_check((select t.leave_count = 2 and t.last_left_at is not null
       from public.class_assignment_attempts t where t.assignment_id = :'ga' and t.user_id = :'s1'),
  'group: leave_count = 2 and last_left_at set');
select pg_temp.ac_sub(:'s2');
select public.group_assignment_open(:'ga') ->> 'state' as _o2 \gset
select pg_temp.ac_check((public.group_report_leave(:'ga')->>'counted')::boolean,
  'group: s2 counted independently');

-- teacher sees it on the live board; students never do
select pg_temp.ac_sub(:'t1');
select public.group_assignment_board(:'ga') as gb \gset
select pg_temp.ac_check((select (e->>'leave_count')::int = 2 and (e->>'last_left_at') is not null
    from jsonb_array_elements(:'gb'::jsonb->'rows') e where e->>'nickname' = 'Lola')
  and (select (e->>'leave_count')::int = 1
    from jsonb_array_elements(:'gb'::jsonb->'rows') e where e->>'nickname' = 'Bobur')
  and (select (e->>'leave_count')::int = 0 and (e->>'last_left_at') is null
    from jsonb_array_elements(:'gb'::jsonb->'rows') e where e->>'nickname' = 'Cavhar'),
  'board: rows[].leave_count / last_left_at (2, 1, 0/null for not started)');
select pg_temp.ac_check((select every(e ? 'member_id' and e ? 'state' and e ? 'score' and e ? 'answered'
      and e ? 'started_at' and e ? 'submitted_at' and e ? 'joined_at')
    from jsonb_array_elements(:'gb'::jsonb->'rows') e)
  and (:'gb'::jsonb ? 'assignment') and (:'gb'::jsonb ? 'group'),
  'board: existing keys are all still present');
select pg_temp.ac_check(pg_temp.ac_as_state('authenticated', :'s1',
  format($$select public.group_assignment_board(%L)$$, :'ga')) = '42501'
  and pg_temp.ac_as_state('authenticated', :'t2',
  format($$select public.group_assignment_board(%L)$$, :'ga')) = '42501',
  'board: a student and another teacher get 403');
select pg_temp.ac_sub(:'s1');
select pg_temp.ac_check(public.group_assignment_open(:'ga')::text !~ 'leave'
  and public.group_assignment_result(:'ga')::text !~ 'leave',
  'student payloads (group_assignment_open / _result) carry no leave data');
select pg_temp.ac_check(pg_temp.ac_as_state('authenticated', :'s1',
  'select leave_count from public.class_assignment_attempts') = '42501'
  and pg_temp.ac_as_state('authenticated', :'s1',
  format($$update public.class_assignment_attempts set leave_count = 0 where assignment_id = %L$$, :'ga')) = '42501',
  'no table privilege on class_assignment_attempts either');

-- after submit: not counted
select public.group_assignment_submit(:'ga', '{}'::jsonb) ->> 'ok' as _sub \gset
select pg_sleep(1.1);
select pg_temp.ac_check(not (public.group_report_leave(:'ga')->>'counted')::boolean
  and (select t.leave_count = 2 from public.class_assignment_attempts t
       where t.assignment_id = :'ga' and t.user_id = :'s1'),
  'group: after submitting nothing is counted (counter stays 2)');
select pg_temp.ac_sub(:'t1');
select pg_temp.ac_check((select (e->>'leave_count')::int = 2 and e->>'state' = 'finished'
    from jsonb_array_elements(public.group_assignment_board(:'ga')->'rows') e
    where e->>'nickname' = 'Lola'),
  'board: a finished attempt keeps its leave_count');

-- private helpers used by the touched RPCs stay closed to clients
select pg_temp.ac_check(
  not exists (select 1 from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'private'
      and (p.proname like 'class\_%' or p.proname like 'group\_%')
      and (has_function_privilege('anon', p.oid, 'execute')
           or has_function_privilege('authenticated', p.oid, 'execute'))),
  'no private.class_* / private.group_* function is executable by clients');
select pg_temp.ac_check((select every(p.prosecdef and p.proconfig @> array['search_path=""'])
    from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public' and p.proname in ('class_report_leave', 'group_report_leave',
      'class_create_session', 'class_teacher_dashboard', 'group_assignment_board')),
  'touched RPCs are SECURITY DEFINER with search_path = empty');

\echo ALL ANTI-CHEAT SECONDS/LEAVE TESTS PASSED
