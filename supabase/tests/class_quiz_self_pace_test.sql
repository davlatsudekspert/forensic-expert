-- «Sinfda test» — «Har kim o'z tezligida» (pace = 'self', migration 20261031000000):
--   * pace is chosen at creation; the old 4-argument RPC still makes a host session;
--   * every student has their OWN question, OWN timer (server clock, from the
--     moment the student opens the question) and their OWN question order;
--   * a fast student moving on never moves anybody else; no auto-advance
--     (class_next_mine refuses while the question is open and unanswered);
--   * the correct answer reaches a student only after their own answer was
--     confirmed (or their own time ran out), future questions are never sent;
--   * one answer per question, server-side time limit, 403 for outsiders;
--   * a student sees nobody else's progress; the teacher sees everyone's;
--   * own results appear once the student finished, rank only after the
--     teacher closed the session; host-mode behaviour is untouched.
-- Runs after class_quiz_test.sql (roles, helpers and the 'demo-topic' bank exist).
\set ON_ERROR_STOP 1
reset role;

create function pg_temp.sp_sub(uid text) returns void language sql as $$
  select set_config('request.jwt.claim.sub', uid, false); $$;
create function pg_temp.sp_check(ok boolean, label text) returns void language plpgsql as $$
begin
  if not coalesce(ok, false) then raise exception 'FAIL: %', label; end if;
  raise notice 'PASS: %', label;
end $$;
create function pg_temp.sp_state(q text) returns text language plpgsql as $$
begin
  execute q;
  return 'OK';
exception when others then
  return sqlstate;
end $$;
grant execute on function pg_temp.sp_state(text) to anon, authenticated;
-- Runs `q` as a client role; returns the SQLSTATE ('OK' when it succeeds).
create function pg_temp.sp_as_state(rl text, uid text, q text) returns text language plpgsql as $$
declare st text;
begin
  perform set_config('request.jwt.claim.sub', uid, false);
  perform set_config('request.jwt.claims', '{}', false);
  perform set_config('role', rl, false);
  st := pg_temp.sp_state(q);
  perform set_config('role', 'postgres', false);
  return st;
end $$;
-- The student confirms an answer to their current question (right or wrong).
create function pg_temp.sp_answer(uid text, sid uuid, want_right boolean) returns jsonb
language plpgsql as $$
declare v_idx int; v_c int;
begin
  perform set_config('request.jwt.claim.sub', uid, false);
  v_idx := (public.class_session_state(sid) -> 'question' ->> 'index')::int;
  select correct_index into v_c from public.class_session_questions
    where session_id = sid and idx = v_idx;
  return public.class_submit_answer(sid, v_idx,
    case when want_right then 'o' || v_c else 'o' || ((v_c + 1) % 4) end);
end $$;

-- t1 owning teacher, t2 another teacher, s1..s3 students, x outsider, p plain user.
insert into auth.users (id, email, created_at, email_confirmed_at) values
 ('79000000-0000-0000-0000-0000000000d1', 'sp-teacher-one@secret.example', now(), now()),
 ('79000000-0000-0000-0000-0000000000d2', 'sp-teacher-two@secret.example', now(), now()),
 ('79000000-0000-0000-0000-0000000000d3', 'sp-student-one@secret.example', now(), now()),
 ('79000000-0000-0000-0000-0000000000d4', 'sp-student-two@secret.example', now(), now()),
 ('79000000-0000-0000-0000-0000000000d5', 'sp-student-three@secret.example', now(), now()),
 ('79000000-0000-0000-0000-0000000000d6', 'sp-outsider@secret.example', now(), now()),
 ('79000000-0000-0000-0000-0000000000d9', 'sp-plain@secret.example', now(), now());
insert into account_roles (user_id, role, granted_by) values
 ('79000000-0000-0000-0000-0000000000d1', 'teacher', null),
 ('79000000-0000-0000-0000-0000000000d2', 'teacher', null);

-- ------------------------------------------------------------- creating
select pg_temp.sp_check((select data_type = 'text' and column_default like '%host%'
  from information_schema.columns
  where table_schema = 'public' and table_name = 'class_sessions' and column_name = 'pace'),
  'class_sessions.pace exists and defaults to host');
select pg_temp.sp_check(pg_temp.sp_as_state('authenticated', '79000000-0000-0000-0000-0000000000d3',
  $$select public.class_create_session_pace('demo-topic', 5, 10, 30, 'self')$$) = '42501',
  'a student cannot create a self-paced session (403)');
select pg_temp.sp_check(pg_temp.sp_as_state('authenticated', '79000000-0000-0000-0000-0000000000d9',
  $$select public.class_create_session_pace('demo-topic', 5, 10, 30, 'self')$$) = '42501',
  'a user without the teacher role cannot create one (403)');
select pg_temp.sp_check(pg_temp.sp_as_state('anon', '',
  $$select public.class_create_session_pace('demo-topic', 5, 10, 30, 'self')$$) <> 'OK',
  'anon cannot create one');

select pg_temp.sp_sub('79000000-0000-0000-0000-0000000000d1');
select pg_temp.sp_check((public.class_create_session_pace('demo-topic', 5, 10, 30, 'fast')->>'error') = 'invalid_settings',
  'an unknown pace is refused');
select pg_temp.sp_check((public.class_create_session_pace('demo-topic', 4, 10, 30, 'self')->>'error') = 'invalid_settings',
  'the usual settings checks still apply (4 questions)');
select pg_temp.sp_check((public.class_create_session_pace('tiny-topic', 5, 10, 30, 'self')->>'error') = 'not_enough_questions',
  'a topic with too few questions is still refused');
select public.class_create_session_pace('demo-topic', 5, 10, 30, 'self')->'session' as selfres \gset
select (:'selfres'::jsonb)->>'id' as sid \gset
select (:'selfres'::jsonb)->>'pace' as space \gset
select pg_temp.sp_check(:'space' = 'self', 'the self-paced session reports pace = self');
select public.class_create_session('demo-topic', 5, 10, 30)->'session' as hostres \gset
select (:'hostres'::jsonb)->>'id' as hid \gset
select pg_temp.sp_check(((:'hostres'::jsonb)->>'pace') = 'host',
  'the old 4-argument class_create_session still makes a host session');
select pg_temp.sp_check((public.class_create_session_pace('demo-topic', 5, 10, 30)->'session'->>'pace') = 'host',
  'the pace argument defaults to host');
select pg_temp.sp_check((select count(*) = 3 from jsonb_array_elements(public.class_my_sessions()) e
  where e->>'pace' in ('host', 'self')), 'class_my_sessions carries pace');
select code as scode from public.class_sessions where id = :'sid' \gset
select code as hcode from public.class_sessions where id = :'hid' \gset

-- --------------------------------------------------------------- joining
select pg_temp.sp_sub('79000000-0000-0000-0000-0000000000d3');
select public.class_join_session(:'scode', 'Aziza')->>'participant_id' as p1 \gset
select pg_temp.sp_sub('79000000-0000-0000-0000-0000000000d4');
select public.class_join_session(:'scode', 'Bobur')->>'participant_id' as p2 \gset
select pg_temp.sp_sub('79000000-0000-0000-0000-0000000000d5');
select public.class_join_session(:'scode', 'Cavhar')->>'participant_id' as p3 \gset
select pg_temp.sp_check((public.class_join_session(:'scode', 'Cavhar')->'session'->>'pace') = 'self',
  'joining returns the session pace');
select pg_temp.sp_sub('79000000-0000-0000-0000-0000000000d4');
select public.class_join_session(:'hcode', 'Bobur')->>'participant_id' as hp2 \gset

select pg_temp.sp_sub('79000000-0000-0000-0000-0000000000d1');
select pg_temp.sp_check((public.class_start(:'sid')->>'ok')::boolean, 'the owner starts the self-paced session');
select pg_temp.sp_check((public.class_start(:'hid')->>'ok')::boolean, 'the owner starts the host session');

-- ---------------------------------------------- teacher controls are host-only
select pg_temp.sp_check((public.class_next(:'sid')->>'error') = 'bad_state',
  'the teacher «Next» is refused in a self-paced session');
select pg_temp.sp_check((public.class_close_question(:'sid')->>'error') = 'bad_state',
  'the teacher «close question» is refused in a self-paced session');
select pg_temp.sp_check((select current_index = 0 and status = 'running'
  from public.class_sessions where id = :'sid'), 'the refused calls changed nothing');

-- ------------------------------------------------- ready: nothing is revealed yet
select pg_temp.sp_sub('79000000-0000-0000-0000-0000000000d3');
select public.class_session_state(:'sid') as st \gset
select pg_temp.sp_check((:'st'::jsonb->>'stage') = 'ready' and not (:'st'::jsonb ? 'question')
  and (:'st'::jsonb->>'pace') = 'self',
  'before opening, the student sees stage=ready and NO question text');
select pg_temp.sp_check((public.class_submit_answer(:'sid', 0, 'o0')->>'error') = 'not_current',
  'cannot answer before opening the first question');
select pg_temp.sp_check((select question_started_at is null from public.class_participants where id = :'p1'),
  'the timer has not started before the student opens the question');

-- Everyone opens at a different moment: the timer starts per student.
select pg_temp.sp_check((public.class_next_mine(:'sid')->>'ok')::boolean, 's1 opens the first question');
select pg_sleep(0.3);
select pg_temp.sp_sub('79000000-0000-0000-0000-0000000000d4');
select pg_temp.sp_check((public.class_next_mine(:'sid')->>'ok')::boolean, 's2 opens the first question');
select pg_temp.sp_check((select p2.question_started_at > p1.question_started_at
  from public.class_participants p1, public.class_participants p2
  where p1.id = :'p1' and p2.id = :'p2'), 'each student has their own start time (server clock)');

select pg_temp.sp_sub('79000000-0000-0000-0000-0000000000d3');
select public.class_session_state(:'sid') as st1 \gset
select pg_temp.sp_check((:'st1'::jsonb->>'stage') = 'question' and (:'st1'::jsonb->>'phase') = 'open'
  and jsonb_array_length(:'st1'::jsonb->'question'->'options') = 4
  and (:'st1'::jsonb->>'my_position') = '0',
  'after opening: an open question with four options at position 0');
select pg_temp.sp_check(:'st1' !~ 'correct_(option|index)|my_correct|explanation|reveal',
  'the open question carries no correct answer, explanation or reveal');
select pg_temp.sp_check(:'st1' !~ 'Bobur|Cavhar' and not (:'st1'::jsonb ? 'rank')
  and not (:'st1'::jsonb ? 'leaderboard'),
  'the student sees no other nickname, rank or leaderboard');
select pg_temp.sp_check((:'st1'::jsonb->>'remaining_ms')::int between 25000 and 30000,
  'the countdown is the student''s own (about the full 30 s)');

-- per-student question order: deterministic, and not the same for everyone
select pg_temp.sp_check(private.class_self_order(:'sid', :'p1') = private.class_self_order(:'sid', :'p1')
  and cardinality(private.class_self_order(:'sid', :'p1')) = 5
  and (select array_agg(x order by x) from unnest(private.class_self_order(:'sid', :'p1')) x) = array[0,1,2,3,4],
  'the order is a deterministic permutation of all five questions');
select pg_temp.sp_check((select count(distinct private.class_self_order(:'sid', x)) > 1
  from unnest(array[:'p1', :'p2', :'p3']::uuid[]) x),
  'students get different question orders');
select pg_temp.sp_check((:'st1'::jsonb->'question'->>'index')::int = (private.class_self_order(:'sid', :'p1'))[1],
  'the first question is the first one of the student''s own order');

-- ------------------------------------------- confirming an answer (own question only)
select pg_temp.sp_check((public.class_next_mine(:'sid')->>'error') = 'not_closed',
  'no auto-advance: «next» is refused while the question is open and unanswered');
select pg_temp.sp_check((select current_index = 0 from public.class_participants where id = :'p1'),
  'the refused «next» did not move the student');
select (select ((private.class_self_order(:'sid', :'p1'))[2])) as other_idx \gset
select pg_temp.sp_check((public.class_submit_answer(:'sid', :'other_idx'::int, 'o0')->>'error') = 'not_current',
  'a student cannot answer a question that is not their current one');
select pg_temp.sp_check((public.class_submit_answer(:'sid', (:'st1'::jsonb->'question'->>'index')::int, 'o9')->>'error') = 'bad_option',
  'a made-up option id is refused');
select pg_temp.sp_check((pg_temp.sp_answer('79000000-0000-0000-0000-0000000000d3', :'sid'::uuid, true)) = '{"ok": true}'::jsonb,
  's1 confirms a right answer; the reply does not say whether it was right');
select pg_temp.sp_check((pg_temp.sp_answer('79000000-0000-0000-0000-0000000000d3', :'sid'::uuid, false)->>'error') = 'already_answered',
  'a second answer to the same question is refused');
select public.class_session_state(:'sid') as st1b \gset
select pg_temp.sp_check((:'st1b'::jsonb->'reveal'->>'my_correct')::boolean
  and (:'st1b'::jsonb->'reveal'->>'my_points')::int >= 990
  and (:'st1b'::jsonb->'reveal'->>'correct_option') is not null
  and (:'st1b'::jsonb->>'phase') = 'closed',
  'right after the confirmed answer the student sees the result (about 1000 points)');

-- s2 has not answered: their question is still open and untouched by s1
select pg_temp.sp_sub('79000000-0000-0000-0000-0000000000d4');
select public.class_session_state(:'sid') as st2 \gset
select pg_temp.sp_check((:'st2'::jsonb->>'phase') = 'open' and not (:'st2'::jsonb ? 'reveal')
  and (:'st2'::jsonb->>'my_position') = '0' and (:'st2'::jsonb->>'my_option') is null,
  's1 having answered does not close or move s2''s question');

-- s1 moves on at once; s2 still on question 1 (no waiting for anybody)
select pg_temp.sp_sub('79000000-0000-0000-0000-0000000000d3');
select pg_temp.sp_check((public.class_next_mine(:'sid')->>'finished')::boolean = false,
  's1 moves to the second question by themselves');
select public.class_session_state(:'sid') as st1c \gset
select pg_temp.sp_check((:'st1c'::jsonb->>'my_position') = '1' and (:'st1c'::jsonb->>'phase') = 'open'
  and (:'st1c'::jsonb->'question'->>'index')::int = (private.class_self_order(:'sid', :'p1'))[2]
  and not (:'st1c'::jsonb ? 'reveal') and (:'st1c'::jsonb->>'my_option') is null,
  's1 sees their second question, fresh, with no reveal');
select pg_temp.sp_check((public.class_next_mine(:'sid')->>'error') = 'not_closed',
  'a double tap on «next» cannot skip the new question');
select pg_temp.sp_check((select current_index = 0 from public.class_participants where id = :'p2'),
  'the other student''s position is still 0');

-- own time window: back-date s1 by 20 s (s2 is untouched) and answer
update public.class_participants set question_started_at = clock_timestamp() - interval '20 seconds'
  where id = :'p1';
select pg_temp.sp_check((pg_temp.sp_answer('79000000-0000-0000-0000-0000000000d3', :'sid'::uuid, true)) = '{"ok": true}'::jsonb,
  's1 answers the second question after 20 s on their own clock');
select pg_temp.sp_check((select points between 650 and 667 and elapsed_ms between 20000 and 21500
  from public.class_answers where participant_id = :'p1'
    and question_index = (private.class_self_order(:'sid', :'p1'))[2]),
  'the score uses the student''s own elapsed time (about 666 for 20 s of 30)');
select pg_temp.sp_check((pg_temp.sp_answer('79000000-0000-0000-0000-0000000000d4', :'sid'::uuid, true)) = '{"ok": true}'::jsonb,
  's2 answers their first question later and still gets the full window');
select pg_temp.sp_check((select points >= 990 from public.class_answers
  where participant_id = :'p2' and question_index = (private.class_self_order(:'sid', :'p2'))[1]),
  's2 is not penalised for s1 having been faster');

-- ------------------------------------------------------- time over (own clock)
select pg_temp.sp_sub('79000000-0000-0000-0000-0000000000d5');
select pg_temp.sp_check((public.class_next_mine(:'sid')->>'ok')::boolean, 's3 opens the first question');
update public.class_participants set question_started_at = clock_timestamp() - interval '30.4 seconds'
  where id = :'p3';
select public.class_session_state(:'sid') as st3 \gset
select pg_temp.sp_check((:'st3'::jsonb->>'phase') = 'closed' and not (:'st3'::jsonb ? 'reveal'),
  'time is up for s3 (30.4 s): closed, but the answer is not revealed yet (grace period)');
update public.class_participants set question_started_at = clock_timestamp() - interval '32 seconds'
  where id = :'p3';
select pg_temp.sp_check((pg_temp.sp_answer('79000000-0000-0000-0000-0000000000d5', :'sid'::uuid, true)->>'error') = 'time_over',
  'an answer after the own time limit + 1 s is refused (server time)');
select public.class_session_state(:'sid') as st3b \gset
select pg_temp.sp_check((:'st3b'::jsonb->'reveal'->>'correct_option') is not null
  and not (:'st3b'::jsonb->'reveal'->>'my_correct')::boolean
  and (:'st3b'::jsonb->>'my_option') is null,
  'after the own time ran out the result is shown: no answer, 0 points');
select pg_temp.sp_check((public.class_next_mine(:'sid')->>'ok')::boolean, 'after the time ran out s3 may move on');
select pg_temp.sp_check((select count(*) = 0 from public.class_answers where participant_id = :'p3'),
  'the timed-out question left no answer row');

-- ----------------------------------------------------------- outsiders / roles
select pg_temp.sp_check(pg_temp.sp_as_state('authenticated', '79000000-0000-0000-0000-0000000000d6',
  format($$select public.class_next_mine(%L)$$, :'sid')) = '42501',
  'an outsider cannot use class_next_mine (403)');
select pg_temp.sp_check(pg_temp.sp_as_state('authenticated', '79000000-0000-0000-0000-0000000000d6',
  format($$select public.class_session_state(%L)$$, :'sid')) = '42501',
  'an outsider cannot read the state (403)');
select pg_temp.sp_check(pg_temp.sp_as_state('authenticated', '79000000-0000-0000-0000-0000000000d1',
  format($$select public.class_next_mine(%L)$$, :'sid')) = '42501',
  'the teacher is not a participant: class_next_mine is refused (403)');
select pg_temp.sp_check(pg_temp.sp_as_state('anon', '',
  format($$select public.class_next_mine(%L)$$, :'sid')) <> 'OK',
  'anon cannot call class_next_mine');
select pg_temp.sp_check(pg_temp.sp_as_state('authenticated', '79000000-0000-0000-0000-0000000000d3',
  format($$select public.class_teacher_dashboard(%L)$$, :'sid')) = '42501',
  'a student cannot open the teacher dashboard (nobody else''s progress)');
select pg_temp.sp_check(pg_temp.sp_as_state('authenticated', '79000000-0000-0000-0000-0000000000d2',
  format($$select public.class_teacher_dashboard(%L)$$, :'sid')) = '42501',
  'another teacher cannot see this session''s dashboard');
select pg_temp.sp_check(pg_temp.sp_as_state('authenticated', '79000000-0000-0000-0000-0000000000d3',
  $$select * from public.class_participants$$) <> 'OK',
  'a student cannot read class_participants (progress columns) directly');
select pg_temp.sp_check(pg_temp.sp_as_state('authenticated', '79000000-0000-0000-0000-0000000000d3',
  $$select private.class_self_order(gen_random_uuid(), gen_random_uuid())$$) <> 'OK',
  'private order helper is not callable by clients');

-- ---------------------------------------------------------- teacher dashboard
select pg_temp.sp_sub('79000000-0000-0000-0000-0000000000d1');
select public.class_teacher_dashboard(:'sid') as dash \gset
select pg_temp.sp_check((:'dash'::jsonb->>'pace') = 'self' and not (:'dash'::jsonb ? 'current')
  and (:'dash'::jsonb->'self'->>'opened') = '3' and (:'dash'::jsonb->'self'->>'done') = '0',
  'dashboard: pace=self, no shared "current question", 3 opened / 0 done');
select pg_temp.sp_check((select bool_and(p ? 'position' and p ? 'answered_count' and p ? 'correct_count' and p ? 'done')
  from jsonb_array_elements(:'dash'::jsonb->'participants') p),
  'dashboard: every participant row has position / answered / correct / done');
select pg_temp.sp_check((select (p->>'position')::int = 2 and (p->>'answered_count')::int = 2
    and (p->>'correct_count')::int = 2
  from jsonb_array_elements(:'dash'::jsonb->'participants') p where p->>'id' = :'p1'),
  'dashboard: s1 is on question 2 with 2 answered, 2 correct');
select pg_temp.sp_check((select (p->>'position')::int = 1 and (p->>'answered_count')::int = 1
  from jsonb_array_elements(:'dash'::jsonb->'participants') p where p->>'id' = :'p2'),
  'dashboard: s2 is on question 1 with 1 answered');
select pg_temp.sp_check((select (p->>'position')::int = 2 and (p->>'answered_count')::int = 0
  from jsonb_array_elements(:'dash'::jsonb->'participants') p where p->>'id' = :'p3'),
  'dashboard: s3 moved on after a timeout (position 2, 0 answered)');
select pg_temp.sp_check(jsonb_array_length(:'dash'::jsonb->'leaderboard') = 3
  and (:'dash'::jsonb->'leaderboard'->0->>'nickname') = 'Aziza',
  'dashboard: live leaderboard (nickname only), s1 leads');
select pg_temp.sp_check(:'dash' !~ 'secret\.example' and :'dash' !~ 'user_id',
  'dashboard: no e-mail or account id');

-- ------------------------------------------ finishing own questions, own results
-- s1 plays the rest (3 more questions: right, wrong, right)
select pg_temp.sp_sub('79000000-0000-0000-0000-0000000000d3');
select public.class_next_mine(:'sid');
select pg_temp.sp_answer('79000000-0000-0000-0000-0000000000d3', :'sid'::uuid, true);
select public.class_next_mine(:'sid');
select pg_temp.sp_answer('79000000-0000-0000-0000-0000000000d3', :'sid'::uuid, false);
select public.class_next_mine(:'sid');
select pg_temp.sp_answer('79000000-0000-0000-0000-0000000000d3', :'sid'::uuid, true);
select pg_temp.sp_check((public.class_my_results(:'sid')->>'error') = 'not_finished',
  'own results stay closed while the student still has a question to go');
select pg_temp.sp_check((public.class_next_mine(:'sid')->>'finished')::boolean,
  'after the last question «next» finishes the student');
select pg_temp.sp_check((public.class_next_mine(:'sid')->>'finished')::boolean,
  'finishing again is harmless (idempotent)');
select public.class_session_state(:'sid') as st1d \gset
select pg_temp.sp_check((:'st1d'::jsonb->>'stage') = 'done' and not (:'st1d'::jsonb ? 'question')
  and (:'st1d'::jsonb->>'answered')::int = 5 and (:'st1d'::jsonb->>'correct')::int = 4,
  'state: stage=done, no question, 5 answered, 4 correct');
select pg_temp.sp_check((public.class_submit_answer(:'sid', 0, 'o0')->>'error') = 'not_current',
  'no answers after the student finished');
select public.class_my_results(:'sid') as res1 \gset
select pg_temp.sp_check((:'res1'::jsonb->>'ok')::boolean and (:'res1'::jsonb->>'correct') = '4'
  and (:'res1'::jsonb->>'total') = '5' and jsonb_array_length(:'res1'::jsonb->'items') = 5
  and (:'res1'::jsonb->>'rank') is null,
  'a finished student sees own results before the session ends; no rank yet');
select pg_temp.sp_check((select bool_and((i->>'index')::int = ord - 1)
  from jsonb_array_elements(:'res1'::jsonb->'items') with ordinality t(i, ord)),
  'results are numbered in the student''s own order (0..4)');
select pg_temp.sp_check((:'res1'::jsonb->'items'->0->>'text') = (select question
  from public.class_session_questions
  where session_id = :'sid' and idx = (private.class_self_order(:'sid', :'p1'))[1]),
  'the first result item is the first question of the student''s own order');
select pg_temp.sp_check(:'res1' !~ 'Bobur|Cavhar', 'own results mention no other student');

-- another student, who has not finished, still gets nothing
select pg_temp.sp_sub('79000000-0000-0000-0000-0000000000d4');
select pg_temp.sp_check((public.class_my_results(:'sid')->>'error') = 'not_finished',
  'an unfinished student cannot read results (and so no answers)');

-- teacher: s1 done, finishing closes the session for everybody
select pg_temp.sp_sub('79000000-0000-0000-0000-0000000000d1');
select pg_temp.sp_check((public.class_teacher_dashboard(:'sid')->'self'->>'done') = '1',
  'dashboard: one student is done');
select pg_temp.sp_check((public.class_finish(:'sid')->>'ok')::boolean, 'the teacher closes the session');
select pg_temp.sp_sub('79000000-0000-0000-0000-0000000000d4');
select public.class_session_state(:'sid') as st2f \gset
select pg_temp.sp_check((:'st2f'::jsonb->>'status') = 'finished' and (:'st2f'::jsonb->>'rank') is not null
  and jsonb_array_length(:'st2f'::jsonb->'leaderboard') = 3,
  'after the teacher closed the session an unfinished student gets rank and leaderboard');
select pg_temp.sp_check((public.class_my_results(:'sid')->>'ok')::boolean
  and (public.class_my_results(:'sid')->>'rank') is not null,
  'after the session ended every student can read results, with rank');
select pg_temp.sp_check((public.class_next_mine(:'sid')->>'error') = 'bad_state',
  'class_next_mine is refused once the session is finished');
select pg_temp.sp_sub('79000000-0000-0000-0000-0000000000d1');
select pg_temp.sp_check((public.class_hardest_detail(:'sid')->>'ok')::boolean
  and jsonb_array_length(public.class_hardest_detail(:'sid')->'items') > 0,
  'hardest-question detail works for a self-paced session (answers keep the real question idx)');
select pg_temp.sp_check((select (e->>'answered')::int = 5 from jsonb_array_elements(
  public.class_export_results(:'sid')->'rows') e where e->>'nickname' = 'Aziza'),
  'export counts all answers of a self-paced session');

-- ------------------------------------------------------- host regression
select pg_temp.sp_sub('79000000-0000-0000-0000-0000000000d4');
select pg_temp.sp_check((public.class_next_mine(:'hid')->>'error') = 'bad_state',
  'class_next_mine is refused in a host-paced session');
select public.class_session_state(:'hid') as hst \gset
select pg_temp.sp_check((:'hst'::jsonb->>'pace') = 'host' and not (:'hst'::jsonb ? 'stage')
  and (:'hst'::jsonb->>'phase') = 'open' and (:'hst'::jsonb->'question'->>'index') = '0',
  'host session: shared question 0, phase open, no self-pace stage');
select pg_temp.sp_check((pg_temp.sp_answer('79000000-0000-0000-0000-0000000000d4', :'hid'::uuid, true)) = '{"ok": true}'::jsonb,
  'host session: answering works as before');
select pg_temp.sp_sub('79000000-0000-0000-0000-0000000000d1');
select pg_temp.sp_check((public.class_teacher_dashboard(:'hid') ? 'current')
  and (public.class_teacher_dashboard(:'hid')->>'remaining_ms')::int > 0
  and not ((public.class_teacher_dashboard(:'hid')->'participants'->0) ? 'position'),
  'host dashboard: shared current question and countdown, no self-pace fields');
select pg_temp.sp_check((public.class_next(:'hid')->>'finished')::boolean = false,
  'host session: the teacher «Next» succeeds');
select pg_temp.sp_check((select current_index = 1 from public.class_sessions where id = :'hid'),
  'host session: «Next» advanced the shared question');

-- ------------------------------------------------------- kicked student
select pg_temp.sp_sub('79000000-0000-0000-0000-0000000000d1');
select public.class_create_session_pace('demo-topic', 5, 10, 30, 'self')->'session'->>'id' as ksid \gset
select code as kcode from public.class_sessions where id = :'ksid' \gset
select pg_temp.sp_sub('79000000-0000-0000-0000-0000000000d3');
select public.class_join_session(:'kcode', 'Kicked')->>'participant_id' as kp \gset
select pg_temp.sp_sub('79000000-0000-0000-0000-0000000000d1');
select public.class_start(:'ksid');
select public.class_kick(:'ksid', :'kp');
select pg_temp.sp_check(pg_temp.sp_as_state('authenticated', '79000000-0000-0000-0000-0000000000d3',
  format($$select public.class_next_mine(%L)$$, :'ksid')) = '42501',
  'a kicked student cannot open or move questions (403)');

\echo ALL CLASS QUIZ SELF-PACE TESTS PASSED
