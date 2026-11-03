-- «Guruh og‘zaki imtihoni» — rollar, bilet taqsimoti, talaba faqat o‘zini
-- ko‘radi, ball faqat ustozdan, chetlatish, yopish, jadvalga to‘g‘ridan-to‘g‘ri
-- kirish yo‘q. class_quiz_test.sql dan keyin ishlaydi (rollar, yordamchilar).
\set ON_ERROR_STOP 1
reset role;
-- Oldingi test fayllari jadval huquqlarini o‘zgartiradi (class_quiz_test kabi).
revoke all on public.oral_sessions, public.oral_tickets, public.oral_participants
  from anon, authenticated;

create function pg_temp.or_as(uid text) returns void language plpgsql as $$
begin
  perform set_config('request.jwt.claim.sub', uid, false);
  perform set_config('request.jwt.claims', '{}', false);
  perform set_config('role', 'authenticated', false);
end $$;
create function pg_temp.or_anon() returns void language plpgsql as $$
begin
  perform set_config('request.jwt.claim.sub', '', false);
  perform set_config('role', 'anon', false);
end $$;
create function pg_temp.or_check(ok boolean, label text) returns void language plpgsql as $$
begin
  if not coalesce(ok, false) then raise exception 'FAIL: %', label; end if;
  raise notice 'PASS: %', label;
end $$;
create function pg_temp.or_state(q text) returns text language plpgsql as $$
begin
  execute q;
  return 'OK';
exception when others then
  return sqlstate;
end $$;
create function pg_temp.or_denied(q text, label text) returns void language plpgsql as $$
declare st text;
begin
  st := pg_temp.or_state(q);
  if st not in ('42501') then raise exception 'FAIL (expected 42501, got %): %', st, label; end if;
  raise notice 'PASS (denied): %', label;
end $$;
grant execute on function pg_temp.or_as(text), pg_temp.or_anon(),
  pg_temp.or_check(boolean, text), pg_temp.or_state(text),
  pg_temp.or_denied(text, text) to anon, authenticated;

-- o1/o2 ustozlar, p1..p5 talabalar.
insert into auth.users (id, email, created_at, email_confirmed_at) values
 ('9a000000-0000-0000-0000-0000000000a1', 'oral-teacher-one@secret.example', now(), now()),
 ('9a000000-0000-0000-0000-0000000000a2', 'oral-teacher-two@secret.example', now(), now()),
 ('9a000000-0000-0000-0000-0000000000b1', 'oral-s1@secret.example', now(), now()),
 ('9a000000-0000-0000-0000-0000000000b2', 'oral-s2@secret.example', now(), now()),
 ('9a000000-0000-0000-0000-0000000000b3', 'oral-s3@secret.example', now(), now()),
 ('9a000000-0000-0000-0000-0000000000b4', 'oral-s4@secret.example', now(), now()),
 ('9a000000-0000-0000-0000-0000000000b5', 'oral-s5@secret.example', now(), now());
insert into account_roles (user_id, role, granted_by) values
 ('9a000000-0000-0000-0000-0000000000a1', 'teacher', null),
 ('9a000000-0000-0000-0000-0000000000a2', 'teacher', null);

-- ---------------------------------------------------------------- schema
select pg_temp.or_check((select count(*) = 3 from pg_tables
  where schemaname = 'public' and rowsecurity
    and tablename in ('oral_sessions', 'oral_tickets', 'oral_participants')),
  'RLS is on for all three oral tables');
select pg_temp.or_check(not exists (select 1 from pg_policies
  where schemaname = 'public' and tablename like 'oral\_%'),
  'oral tables have no policy (RPC only)');

-- ------------------------------------------------------------ anon / roles
select pg_temp.or_anon();
select pg_temp.or_denied($q$select public.oral_join_session('123456', 'Ali Valiyev')$q$,
  'anon cannot join');
select pg_temp.or_denied($q$select public.oral_report_leave(gen_random_uuid())$q$,
  'anon cannot report a leave');
select pg_temp.or_denied($q$select public.oral_create_session('x', '[[{"id":"a","text":"b"}]]', 0)$q$,
  'anon cannot create');
select pg_temp.or_denied($q$select count(*) from public.oral_sessions$q$,
  'anon cannot read the sessions table');
reset role;

select pg_temp.or_as('9a000000-0000-0000-0000-0000000000b1');
select pg_temp.or_denied($q$select public.oral_create_session('x', '[[{"id":"a","text":"b"}]]', 0)$q$,
  'a student (no teacher role) cannot create a session');
select pg_temp.or_denied($q$select count(*) from public.oral_participants$q$,
  'authenticated cannot read the participants table directly');
reset role;

-- ------------------------------------------------------------ create
select pg_temp.or_as('9a000000-0000-0000-0000-0000000000a1');
select pg_temp.or_check(
  (public.oral_create_session('t', '[]', 0) ->> 'error') = 'invalid_settings',
  'zero tickets rejected');
select pg_temp.or_check(
  (public.oral_create_session('t', '[[]]', 0) ->> 'error') = 'invalid_ticket',
  'empty ticket rejected');
select pg_temp.or_check(
  (public.oral_create_session('t', jsonb_build_array((select jsonb_agg(jsonb_build_object('id', 'q' || g, 'text', 'savol')) from generate_series(1, 11) g)), 0) ->> 'error') = 'invalid_ticket',
  'a ticket with 11 questions rejected');
select pg_temp.or_check(
  (public.oral_create_session('t', jsonb_build_array(jsonb_build_array(jsonb_build_object('id', 'q', 'text', repeat('x', 501)))), 0) ->> 'error') = 'invalid_ticket',
  'a question longer than 500 characters rejected');
select pg_temp.or_check(
  (public.oral_create_session('t', '[[{"id":"a","text":"b"}]]', 4000) ->> 'error') = 'invalid_settings',
  'preparation time above one hour rejected');

create temp table oral_ids (k text primary key, v text);
grant all on oral_ids to authenticated;
insert into oral_ids
select 'created', public.oral_create_session('Sud-tibbiy toksikologiya', $j$[
  [{"id":"d1#1","text":"Zahar tushunchasi"},{"id":"d1#2","text":"Zaharlanish turlari"},{"id":"d1#3","text":"Toksikokinetika"}],
  [{"id":"d1#4","text":"Is gazi"},{"id":"d1#5","text":"Metil spirti"},{"id":"d1#6","text":"Etil spirti"}],
  [{"id":"d1#7","text":"Kislotalar"},{"id":"d1#8","text":"Ishqorlar"},{"id":"d1#9","text":"Simob"}]
]$j$, 900)::text;
select pg_temp.or_check((select (v::jsonb ->> 'ok')::boolean from oral_ids where k = 'created'),
  'teacher creates a session with 3 tickets');
insert into oral_ids select 'sid', v::jsonb -> 'session' ->> 'id' from oral_ids where k = 'created';
insert into oral_ids select 'code', v::jsonb -> 'session' ->> 'code' from oral_ids where k = 'created';
select pg_temp.or_check((select v ~ '^[0-9]{6}$' from oral_ids where k = 'code'), 'six-digit code');
select pg_temp.or_check((select (v::jsonb -> 'session' ->> 'prep_seconds')::int = 900
  and (v::jsonb -> 'session' ->> 'ticket_count')::int = 3 from oral_ids where k = 'created'),
  'settings returned');
select pg_temp.or_check(
  (public.oral_join_session((select v from oral_ids where k = 'code'), 'Ustoz') ->> 'error') = 'own_session',
  'the teacher cannot join their own session');
reset role;

-- ------------------------------------------------------------ join
select pg_temp.or_as('9a000000-0000-0000-0000-0000000000b1');
select pg_temp.or_check(
  (public.oral_join_session('12', 'Ali Valiyev') ->> 'error') = 'bad_code', 'bad code');
select pg_temp.or_check(
  (public.oral_join_session((select v from oral_ids where k = 'code'), 'A') ->> 'error') = 'name_length',
  'one-letter name rejected');
select pg_temp.or_check(
  (public.oral_join_session((select v from oral_ids where k = 'code'), 'Qanjiq bola') ->> 'error') = 'name_blocked',
  'blocked word rejected');
select pg_temp.or_check(
  (public.oral_join_session((select v from oral_ids where k = 'code'), 'Abdurahmonov Alisher Baxtiyor o‘g‘li') ->> 'ok')::boolean,
  'student 1 joins with a long Uzbek full name (apostrophes allowed)');
select pg_temp.or_check(
  (select (public.oral_my_state((select v::uuid from oral_ids where k = 'sid')) ->> 'ticket_no')::int between 1 and 3),
  'student 1 got a ticket 1..3');
select pg_temp.or_check(
  (select jsonb_array_length(public.oral_my_state((select v::uuid from oral_ids where k = 'sid')) -> 'questions') = 3),
  'student 1 sees the 3 questions of their ticket right away');
select pg_temp.or_check(
  (select public.oral_my_state((select v::uuid from oral_ids where k = 'sid')) -> 'scores' = 'null'::jsonb),
  'no score before grading');
select pg_temp.or_check(
  (public.oral_join_session((select v from oral_ids where k = 'code'), 'Boshqa ism') ->> 'ok')::boolean
  and (select (public.oral_my_state((select v::uuid from oral_ids where k = 'sid')) ->> 'name') = 'Abdurahmonov Alisher Baxtiyor o‘g‘li'),
  're-join keeps the same participant, name and ticket');
select pg_temp.or_denied($q$select public.oral_teacher_state((select v::uuid from oral_ids where k = 'sid'))$q$,
  'a student cannot read the teacher state');
select pg_temp.or_denied($q$select public.oral_grade((select v::uuid from oral_ids where k = 'sid'), gen_random_uuid(), array[20,20,20])$q$,
  'a student cannot grade');
select pg_temp.or_check((public.oral_report_leave((select v::uuid from oral_ids where k = 'sid')) ->> 'leave_count')::int = 1,
  'student 1 leaves the app once: counted');
select pg_temp.or_check((public.oral_report_leave((select v::uuid from oral_ids where k = 'sid')) ->> 'leave_count')::int = 2,
  'second leave counted');
select pg_temp.or_check((public.oral_my_state((select v::uuid from oral_ids where k = 'sid')) ->> 'leave_count')::int = 2,
  'the student sees their own leave count');
select pg_temp.or_check((public.oral_ready((select v::uuid from oral_ids where k = 'sid')) ->> 'ok')::boolean,
  'student 1 marks ready');
reset role;

select pg_temp.or_as('9a000000-0000-0000-0000-0000000000b2');
select pg_temp.or_check((public.oral_join_session((select v from oral_ids where k = 'code'), 'Malika') ->> 'ok')::boolean,
  'student 2 joins');
reset role;
select pg_temp.or_as('9a000000-0000-0000-0000-0000000000b3');
select pg_temp.or_check((public.oral_join_session((select v from oral_ids where k = 'code'), 'Sardor') ->> 'ok')::boolean,
  'student 3 joins');
reset role;
select pg_temp.or_check((select count(distinct ticket_no) = 3 from public.oral_participants
  where session_id = (select v::uuid from oral_ids where k = 'sid')),
  'three students hold three different tickets');
select pg_temp.or_as('9a000000-0000-0000-0000-0000000000b4');
select pg_temp.or_check(
  (public.oral_join_session((select v from oral_ids where k = 'code'), 'Nodira') ->> 'error') = 'full',
  'a fourth student gets "full" (3 tickets)');
reset role;

-- ------------------------------------------------------------ teacher
select pg_temp.or_as('9a000000-0000-0000-0000-0000000000a2');
select pg_temp.or_denied($q$select public.oral_teacher_state((select v::uuid from oral_ids where k = 'sid'))$q$,
  'another teacher cannot read this session');
reset role;

select pg_temp.or_as('9a000000-0000-0000-0000-0000000000a1');
select pg_temp.or_check(
  (select jsonb_array_length(public.oral_teacher_state((select v::uuid from oral_ids where k = 'sid')) -> 'participants') = 3),
  'teacher sees three students');
select pg_temp.or_check(
  (select public.oral_teacher_state((select v::uuid from oral_ids where k = 'sid')) -> 'participants' -> 0 ->> 'name'
    = 'Abdurahmonov Alisher Baxtiyor o‘g‘li'),
  'the ready student is first in the queue');
insert into oral_ids select 'p1', public.oral_teacher_state((select v::uuid from oral_ids where k = 'sid')) -> 'participants' -> 0 ->> 'id';
select pg_temp.or_check(
  (select (public.oral_teacher_state((select v::uuid from oral_ids where k = 'sid')) -> 'participants' -> 0 ->> 'leave_count')::int = 2
     and public.oral_teacher_state((select v::uuid from oral_ids where k = 'sid')) -> 'participants' -> 0 ->> 'last_left_at' is not null),
  'teacher sees how many times student 1 left the app');
select pg_temp.or_check(
  (public.oral_call((select v::uuid from oral_ids where k = 'sid'), (select v::uuid from oral_ids where k = 'p1')) ->> 'ok')::boolean,
  'teacher calls student 1');
select pg_temp.or_check(
  (public.oral_grade((select v::uuid from oral_ids where k = 'sid'), (select v::uuid from oral_ids where k = 'p1'), array[20, 15]) ->> 'error') = 'invalid_scores',
  'wrong number of scores rejected');
select pg_temp.or_check(
  (public.oral_grade((select v::uuid from oral_ids where k = 'sid'), (select v::uuid from oral_ids where k = 'p1'), array[20, 15, 21]) ->> 'error') = 'invalid_scores',
  'a score above 20 rejected');
select pg_temp.or_check(
  (public.oral_grade((select v::uuid from oral_ids where k = 'sid'), (select v::uuid from oral_ids where k = 'p1'), array[20, 15, 10]) ->> 'total')::int = 45,
  'teacher grades student 1: total 45');
select pg_temp.or_check(
  (select public.oral_teacher_state((select v::uuid from oral_ids where k = 'sid')) -> 'participants' -> 2 ->> 'id')
    = (select v from oral_ids where k = 'p1'),
  'graded students move to the end of the queue');
reset role;

select pg_temp.or_as('9a000000-0000-0000-0000-0000000000b1');
select pg_temp.or_check(
  (select (public.oral_my_state((select v::uuid from oral_ids where k = 'sid')) ->> 'total')::int = 45
    and public.oral_my_state((select v::uuid from oral_ids where k = 'sid')) -> 'scores' = '[20, 15, 10]'::jsonb),
  'student 1 sees their own scores and total');
select pg_temp.or_check(
  (public.oral_ready((select v::uuid from oral_ids where k = 'sid')) ->> 'error') = 'not_allowed',
  'a graded student cannot re-queue');
select pg_temp.or_check(
  (public.oral_report_leave((select v::uuid from oral_ids where k = 'sid')) ->> 'error') = 'not_allowed',
  'leaving after grading is not counted');
reset role;

select pg_temp.or_as('9a000000-0000-0000-0000-0000000000b2');
select pg_temp.or_check(
  (select public.oral_my_state((select v::uuid from oral_ids where k = 'sid')) -> 'scores' = 'null'::jsonb
    and public.oral_my_state((select v::uuid from oral_ids where k = 'sid')) ->> 'name' = 'Malika'),
  'student 2 sees only their own (ungraded) state');
select pg_temp.or_check(
  position('Abdurahmonov' in public.oral_my_state((select v::uuid from oral_ids where k = 'sid'))::text) = 0,
  'student 2 cannot see student 1''s name');
reset role;

-- ------------------------------------------------------------ kick, finish
select pg_temp.or_as('9a000000-0000-0000-0000-0000000000a1');
insert into oral_ids select 'p3', p ->> 'id'
  from jsonb_array_elements(public.oral_teacher_state((select v::uuid from oral_ids where k = 'sid')) -> 'participants') p
  where p ->> 'name' = 'Sardor';
select pg_temp.or_check(
  (public.oral_kick((select v::uuid from oral_ids where k = 'sid'), (select v::uuid from oral_ids where k = 'p3')) ->> 'ok')::boolean,
  'teacher removes student 3');
reset role;
select pg_temp.or_as('9a000000-0000-0000-0000-0000000000b3');
select pg_temp.or_check(
  (public.oral_join_session((select v from oral_ids where k = 'code'), 'Sardor') ->> 'error') = 'kicked',
  'a removed student cannot re-join');
reset role;
select pg_temp.or_as('9a000000-0000-0000-0000-0000000000b4');
select pg_temp.or_check(
  (public.oral_join_session((select v from oral_ids where k = 'code'), 'Nodira') ->> 'ok')::boolean,
  'the freed ticket goes to a new student');
reset role;

select pg_temp.or_as('9a000000-0000-0000-0000-0000000000a1');
select pg_temp.or_check(
  (public.oral_finish((select v::uuid from oral_ids where k = 'sid')) ->> 'ok')::boolean, 'teacher finishes');
select pg_temp.or_check(
  (select jsonb_array_length(public.oral_my_sessions()) >= 1
     and (public.oral_my_sessions() -> 0 ->> 'graded')::int = 1),
  'my sessions lists the session with one graded student');
reset role;
select pg_temp.or_as('9a000000-0000-0000-0000-0000000000b5');
select pg_temp.or_check(
  (public.oral_join_session((select v from oral_ids where k = 'code'), 'Kechikkan') ->> 'error') = 'finished',
  'no joining after finish');
reset role;
select pg_temp.or_as('9a000000-0000-0000-0000-0000000000b2');
select pg_temp.or_check(
  (public.oral_ready((select v::uuid from oral_ids where k = 'sid')) ->> 'error') = 'not_allowed',
  'no queueing after finish');
select pg_temp.or_check(
  (public.oral_report_leave((select v::uuid from oral_ids where k = 'sid')) ->> 'error') = 'not_allowed',
  'no leave counting after finish');
reset role;

-- 30 kunlik tozalash.
update public.oral_sessions set expires_at = now() - interval '1 minute'
 where id = (select v::uuid from oral_ids where k = 'sid');
select pg_temp.or_check(private.oral_cleanup() >= 1, 'cleanup deletes the expired session');
select pg_temp.or_check(not exists (select 1 from public.oral_participants
                  where session_id = (select v::uuid from oral_ids where k = 'sid'))
  and not exists (select 1 from public.oral_tickets
                  where session_id = (select v::uuid from oral_ids where k = 'sid')),
  'its tickets and students are gone too');

\echo ALL ORAL SESSION TESTS PASSED
