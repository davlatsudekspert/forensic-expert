-- «Sinfda test» — class_hardest_detail (migration 20261024010000):
-- anon / student / plain user / another teacher are refused; the owning
-- teacher gets options, correct answer, explanation and source only after the
-- session is finished; no nicknames or ids in the answer.
-- Runs after class_quiz_test.sql (roles, helpers and the 'demo-topic' bank exist).
\set ON_ERROR_STOP 1
reset role;

create function pg_temp.hd_sub(uid text) returns void language sql as $$
  select set_config('request.jwt.claim.sub', uid, false); $$;
create function pg_temp.hd_check(ok boolean, label text) returns void language plpgsql as $$
begin
  if not coalesce(ok, false) then raise exception 'FAIL: %', label; end if;
  raise notice 'PASS: %', label;
end $$;
create function pg_temp.hd_state(q text) returns text language plpgsql as $$
begin
  execute q;
  return 'OK';
exception when others then
  return sqlstate;
end $$;
grant execute on function pg_temp.hd_state(text) to anon, authenticated;
-- Runs `q` as a client role; returns the SQLSTATE ('OK' when it succeeds).
create function pg_temp.hd_as_state(rl text, uid text, q text) returns text language plpgsql as $$
declare st text;
begin
  perform set_config('request.jwt.claim.sub', uid, false);
  perform set_config('request.jwt.claims', '{}', false);
  perform set_config('role', rl, false);
  st := pg_temp.hd_state(q);
  perform set_config('role', 'postgres', false);
  return st;
end $$;

-- t1 owning teacher, t2 another teacher, s1..s3 students, p plain user.
insert into auth.users (id, email, created_at, email_confirmed_at) values
 ('79000000-0000-0000-0000-0000000000e1', 'hd-teacher-one@secret.example', now(), now()),
 ('79000000-0000-0000-0000-0000000000e2', 'hd-teacher-two@secret.example', now(), now()),
 ('79000000-0000-0000-0000-0000000000f1', 'hd-student-one@secret.example', now(), now()),
 ('79000000-0000-0000-0000-0000000000f2', 'hd-student-two@secret.example', now(), now()),
 ('79000000-0000-0000-0000-0000000000f3', 'hd-student-three@secret.example', now(), now()),
 ('79000000-0000-0000-0000-0000000000f9', 'hd-plain@secret.example', now(), now());
insert into account_roles (user_id, role, granted_by) values
 ('79000000-0000-0000-0000-0000000000e1', 'teacher', null),
 ('79000000-0000-0000-0000-0000000000e2', 'teacher', null);

select pg_temp.hd_sub('79000000-0000-0000-0000-0000000000e1');
select (public.class_create_session('demo-topic', 5, 10, 30))->'session'->>'id' as hsid \gset
select code as hcode from public.class_sessions where id = :'hsid' \gset
select pg_temp.hd_sub('79000000-0000-0000-0000-0000000000f1');
select public.class_join_session(:'hcode', 'Hd Bir');
select pg_temp.hd_sub('79000000-0000-0000-0000-0000000000f2');
select public.class_join_session(:'hcode', 'Hd Ikki');
select pg_temp.hd_sub('79000000-0000-0000-0000-0000000000f3');
select public.class_join_session(:'hcode', 'Hd Uch');

select pg_temp.hd_sub('79000000-0000-0000-0000-0000000000e1');
select pg_temp.hd_check((public.class_start(:'hsid')->>'ok')::boolean, 'hardest detail: session starts');

-- while the quiz is running the owning teacher gets nothing (answers stay secret)
select pg_temp.hd_check((public.class_hardest_detail(:'hsid')->>'ok')::boolean = false
  and (public.class_hardest_detail(:'hsid')->>'error') = 'not_finished'
  and public.class_hardest_detail(:'hsid')::text !~ 'correct_index',
  'running session: not_finished, no correct answer disclosed');

-- question 0: s1 right, s2 and s3 wrong
select 'o' || correct_index as hc from public.class_session_questions
  where session_id = :'hsid' and idx = 0 \gset
select case when :'hc' = 'o0' then 'o1' else 'o0' end as hw \gset
select pg_temp.hd_sub('79000000-0000-0000-0000-0000000000f1');
select public.class_submit_answer(:'hsid', 0, :'hc');
select pg_temp.hd_sub('79000000-0000-0000-0000-0000000000f2');
select public.class_submit_answer(:'hsid', 0, :'hw');
select pg_temp.hd_sub('79000000-0000-0000-0000-0000000000f3');
select public.class_submit_answer(:'hsid', 0, :'hw');
select pg_temp.hd_sub('79000000-0000-0000-0000-0000000000e1');
select public.class_close_question(:'hsid');
select public.class_finish(:'hsid');

-- ---- roles
select pg_temp.hd_check(pg_temp.hd_as_state('anon', '',
    format($$select public.class_hardest_detail(%L)$$, :'hsid')) in ('42501', '42883'),
  'anon is refused');
select pg_temp.hd_check(pg_temp.hd_as_state('authenticated', '79000000-0000-0000-0000-0000000000f1',
    format($$select public.class_hardest_detail(%L)$$, :'hsid')) = '42501',
  'a student of this very class is refused');
select pg_temp.hd_check(pg_temp.hd_as_state('authenticated', '79000000-0000-0000-0000-0000000000f9',
    format($$select public.class_hardest_detail(%L)$$, :'hsid')) = '42501',
  'a plain signed-in user is refused');
select pg_temp.hd_check(pg_temp.hd_as_state('authenticated', '79000000-0000-0000-0000-0000000000e2',
    format($$select public.class_hardest_detail(%L)$$, :'hsid')) = '42501',
  'another teacher is refused');
select pg_temp.hd_check(pg_temp.hd_as_state('authenticated', '79000000-0000-0000-0000-0000000000e1',
    format($$select public.class_hardest_detail(%L)$$, :'hsid')) = 'OK',
  'the owning teacher is allowed');
select pg_temp.hd_check(not has_function_privilege('anon', 'public.class_hardest_detail(uuid, int)', 'execute')
  and has_function_privilege('authenticated', 'public.class_hardest_detail(uuid, int)', 'execute'),
  'execute: authenticated only');

-- ---- content
select pg_temp.hd_sub('79000000-0000-0000-0000-0000000000e1');
select public.class_hardest_detail(:'hsid') as hd \gset
select pg_temp.hd_check((:'hd'::jsonb->>'ok')::boolean and jsonb_array_length(:'hd'::jsonb->'items') = 1,
  'finished session: one answered question is listed');
select pg_temp.hd_check((:'hd'::jsonb->'items'->0->>'index')::int = 0
  and (:'hd'::jsonb->'items'->0->>'correct_pct')::int = 33
  and (:'hd'::jsonb->'items'->0->>'answered')::int = 3
  and jsonb_array_length(:'hd'::jsonb->'items'->0->'options') = 4,
  'item: index 0, 33 % correct of 3 answers, four options');
select pg_temp.hd_check((:'hd'::jsonb->'items'->0->>'correct_index')::int =
    (select correct_index from public.class_session_questions where session_id = :'hsid' and idx = 0)
  and (:'hd'::jsonb->'items'->0->>'explanation') <> ''
  and (:'hd'::jsonb->'items'->0->'source'->>'page') is not null,
  'item: correct answer, explanation and source (page) come from the session copy');
select pg_temp.hd_check((:'hd'::jsonb->'items'->0->'option_counts'->>(substr(:'hc', 2)::int))::int = 1
  and (:'hd'::jsonb->'items'->0->'option_counts'->>(substr(:'hw', 2)::int))::int = 2,
  'item: option counts match the answers (1 right, 2 on the same wrong option)');
select pg_temp.hd_check(:'hd' !~* 'Hd (Bir|Ikki|Uch)' and :'hd' !~ '@' and :'hd' !~ '79000000',
  'no nicknames, e-mails or user ids in the detail');
-- dashboard `hardest` and the detail agree on the order/indexes
select pg_temp.hd_check((public.class_teacher_dashboard(:'hsid')->'hardest'->0->>'index')
    = (:'hd'::jsonb->'items'->0->>'index'),
  'detail matches the dashboard hardest list');
select pg_temp.hd_check(jsonb_array_length(public.class_hardest_detail(:'hsid', 0)->'items') <= 1
  and jsonb_array_length(public.class_hardest_detail(:'hsid', 999)->'items') <= 10,
  'p_limit is clamped to 1..10');
\echo ALL HARDEST DETAIL TESTS PASSED
