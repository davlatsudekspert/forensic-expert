-- «Guruh testi» — group_assignment_hardest_detail (migration 20261024020000):
-- anon / student / plain user / another teacher are refused; the owning teacher
-- gets options, correct answer, explanation and source only after the test is
-- closed (or past its due date); no nicknames or ids in the answer; variant
-- mode (different questions per student) is counted per question.
-- Runs after class_groups_test.sql / class_groups_e2e.sql (roles and helpers exist).
\set ON_ERROR_STOP 1
reset role;
-- Earlier test files grant table privileges for their own checks; restore
-- the migration's state.
revoke all on public.class_groups, public.class_group_members, public.class_assignments,
  public.class_assignment_questions, public.class_assignment_attempts from anon, authenticated;

create function pg_temp.gh_as(uid text) returns void language plpgsql as $$
begin
  perform set_config('request.jwt.claim.sub', uid, false);
  perform set_config('request.jwt.claims', '{}', false);
  perform set_config('role', 'authenticated', false);
end $$;
create function pg_temp.gh_check(ok boolean, label text) returns void language plpgsql as $$
begin
  if not coalesce(ok, false) then raise exception 'FAIL: %', label; end if;
  raise notice 'PASS: %', label;
end $$;
create function pg_temp.gh_state(q text) returns text language plpgsql as $$
begin
  execute q;
  return 'OK';
exception when others then
  return sqlstate;
end $$;
grant execute on function pg_temp.gh_as(text), pg_temp.gh_check(boolean, text),
  pg_temp.gh_state(text) to anon, authenticated;
-- Runs `q` as a client role; returns the SQLSTATE ('OK' when it succeeds).
create function pg_temp.gh_as_state(rl text, uid text, q text) returns text language plpgsql as $$
declare st text;
begin
  perform set_config('request.jwt.claim.sub', uid, false);
  perform set_config('request.jwt.claims', '{}', false);
  perform set_config('role', rl, false);
  st := pg_temp.gh_state(q);
  perform set_config('role', 'postgres', false);
  return st;
end $$;

\set t1 '7b000000-0000-0000-0000-0000000000a1'
\set t2 '7b000000-0000-0000-0000-0000000000a2'
\set s1 '7b000000-0000-0000-0000-0000000000b1'
\set s2 '7b000000-0000-0000-0000-0000000000b2'
\set s3 '7b000000-0000-0000-0000-0000000000b3'
\set s4 '7b000000-0000-0000-0000-0000000000b4'
\set p1 '7b000000-0000-0000-0000-0000000000c1'
insert into auth.users (id, email, created_at, email_confirmed_at) values
 (:'t1', 'gh-teacher-one@secret.example', now(), now()),
 (:'t2', 'gh-teacher-two@secret.example', now(), now()),
 (:'s1', 'gh-student-one@secret.example', now(), now()),
 (:'s2', 'gh-student-two@secret.example', now(), now()),
 (:'s3', 'gh-student-three@secret.example', now(), now()),
 (:'s4', 'gh-student-four@secret.example', now(), now()),
 (:'p1', 'gh-plain@secret.example', now(), now());
insert into account_roles (user_id, role, granted_by) values
 (:'t1', 'teacher', null), (:'t2', 'teacher', null);

-- Bank: 'ghd-topic' — 12 questions, correct index = g % 4.
insert into public.class_quiz_questions
  (topic_id, topic_title, position, question, options, correct_index, explanation, source)
select 'ghd-topic', 'Qiyin mavzu', g, 'Qiyin savol raqami ' || g,
       jsonb_build_array('A' || g, 'B' || g, 'C' || g, 'D' || g), (g % 4)::smallint,
       'Izoh ' || g, '{"author":"Muallif","title":"Darslik","page":"77"}'::jsonb
from generate_series(1, 12) g;

select pg_temp.gh_as(:'t1');
select (public.group_create('Qiyin guruh') -> 'group') ->> 'id' as gid \gset
reset role;
select code as gcode from public.class_groups where id = :'gid' \gset
select pg_temp.gh_as(:'t1');
-- Variant mode: 4 of 12 questions per student (different sets).
select (public.group_assignment_create(:'gid', 'ghd-topic', 4, 15, null, true, 'after_close')
        -> 'assignment' ->> 'id') as av \gset
select pg_temp.gh_as(:'s1');
select public.group_join(:'gcode', 'Gh Bir');
select pg_temp.gh_as(:'s2');
select public.group_join(:'gcode', 'Gh Ikki');
select pg_temp.gh_as(:'s3');
select public.group_join(:'gcode', 'Gh Uch');
select pg_temp.gh_as(:'s4');
select public.group_join(:'gcode', 'Gh Tort');
select pg_temp.gh_as(:'s1');
select public.group_assignment_open(:'av');
select pg_temp.gh_as(:'s2');
select public.group_assignment_open(:'av');
select pg_temp.gh_as(:'s3');
select public.group_assignment_open(:'av');
-- s4 never opens the test.

reset role;
select pg_temp.gh_check((select count(distinct question_ids) from public.class_assignment_attempts
  where assignment_id = :'av') >= 2, 'variant mode: students got different question sets');
-- s1: everything right; s2 and s3: everything wrong, always the same wrong option.
select jsonb_object_agg(q.qid, q.correct_index) as a1
  from public.class_assignment_attempts t join public.class_assignment_questions q
    on q.assignment_id = t.assignment_id and q.qid = any (t.question_ids)
  where t.assignment_id = :'av' and t.user_id = :'s1' \gset
select jsonb_object_agg(q.qid, (q.correct_index + 1) % 4) as a2
  from public.class_assignment_attempts t join public.class_assignment_questions q
    on q.assignment_id = t.assignment_id and q.qid = any (t.question_ids)
  where t.assignment_id = :'av' and t.user_id = :'s2' \gset
select jsonb_object_agg(q.qid, (q.correct_index + 1) % 4) as a3
  from public.class_assignment_attempts t join public.class_assignment_questions q
    on q.assignment_id = t.assignment_id and q.qid = any (t.question_ids)
  where t.assignment_id = :'av' and t.user_id = :'s3' \gset
select pg_temp.gh_as(:'s1');
select public.group_assignment_submit(:'av', :'a1'::jsonb);
select pg_temp.gh_as(:'s2');
select public.group_assignment_submit(:'av', :'a2'::jsonb);
select pg_temp.gh_as(:'s3');
-- s3 saves but never submits: still counted (answers saved) once the test is closed.
select public.group_assignment_save(:'av', :'a3'::jsonb);

-- ---- open test: nothing is disclosed
select pg_temp.gh_as(:'t1');
select pg_temp.gh_check((public.group_assignment_hardest_detail(:'av')->>'ok')::boolean = false
  and (public.group_assignment_hardest_detail(:'av')->>'error') = 'not_finished'
  and public.group_assignment_hardest_detail(:'av')::text !~ 'correct_index',
  'open test: not_finished, no correct answer disclosed');

-- ---- roles (still open: the role check comes first)
select pg_temp.gh_check(pg_temp.gh_as_state('anon', '',
    format($$select public.group_assignment_hardest_detail(%L)$$, :'av')) in ('42501', '42883'),
  'anon is refused');
select pg_temp.gh_check(pg_temp.gh_as_state('authenticated', :'s1',
    format($$select public.group_assignment_hardest_detail(%L)$$, :'av')) = '42501',
  'a student of this very group is refused');
select pg_temp.gh_check(pg_temp.gh_as_state('authenticated', :'p1',
    format($$select public.group_assignment_hardest_detail(%L)$$, :'av')) = '42501',
  'a plain signed-in user is refused');
select pg_temp.gh_check(pg_temp.gh_as_state('authenticated', :'t2',
    format($$select public.group_assignment_hardest_detail(%L)$$, :'av')) = '42501',
  'another teacher is refused');
select pg_temp.gh_check(pg_temp.gh_as_state('authenticated', :'t1',
    format($$select public.group_assignment_hardest_detail(%L)$$, :'av')) = 'OK',
  'the owning teacher is allowed');
select pg_temp.gh_check(not has_function_privilege('anon',
      'public.group_assignment_hardest_detail(uuid, int)', 'execute')
  and has_function_privilege('authenticated',
      'public.group_assignment_hardest_detail(uuid, int)', 'execute'),
  'execute: authenticated only');

-- ---- close, then the detail is available
select pg_temp.gh_as(:'t1');
select pg_temp.gh_check((public.group_assignment_close(:'av')->>'ok')::boolean, 'teacher closes the test');
select public.group_assignment_hardest_detail(:'av', 10) as hd \gset
select pg_temp.gh_check((:'hd'::jsonb->>'ok')::boolean and jsonb_array_length(:'hd'::jsonb->'items') >= 1,
  'closed test: items are listed');
-- every item: four options, 0..100 %, sums agree with the stored answers
reset role;
select pg_temp.gh_check((select bool_and(
      jsonb_array_length(i->'options') = 4
      and (i->>'correct_pct')::int between 0 and 100
      and (i->>'answered')::int = (select count(*) from public.class_assignment_attempts t
            where t.assignment_id = :'av' and (t.answers ->> (i->>'qid')) is not null)
      and (select sum(c::int) from jsonb_array_elements_text(i->'option_counts') c) = (i->>'answered')::int
      and (i->>'correct_index')::int = (select q.correct_index from public.class_assignment_questions q
            where q.assignment_id = :'av' and q.qid = i->>'qid')
      and (i->>'explanation') <> ''
      and (i->'source'->>'page') = '77')
    from jsonb_array_elements(:'hd'::jsonb->'items') i),
  'items: answered/option counts/correct index/explanation/source come from the assignment copy');
-- the saved-but-unsubmitted s3 is counted: total answers = 3 students x 4 questions
select pg_temp.gh_check((select sum((i->>'answered')::int) from jsonb_array_elements(:'hd'::jsonb->'items') i) = 12,
  'all 12 saved answers counted (including the student who did not press submit)');
-- ordering: lowest correct % first; positions are 0..n-1
select pg_temp.gh_check((select bool_and((i->>'correct_pct')::int >= coalesce(lag_pct, 0))
    from (select i, lag((i->>'correct_pct')::int) over (order by (i->>'index')::int) as lag_pct
          from jsonb_array_elements(:'hd'::jsonb->'items') i) x)
  and (:'hd'::jsonb->'items'->0->>'index') = '0',
  'items ordered by the lowest correct % first, index = position');
select pg_temp.gh_check(exists (select 1 from jsonb_array_elements(:'hd'::jsonb->'items') i
    where (i->>'correct_pct')::int = 0), 'a question nobody answered right is listed (0 %)');
select pg_temp.gh_check(:'hd' !~* 'Gh (Bir|Ikki|Uch|Tort)' and :'hd' !~ '@' and :'hd' !~ '7b000000',
  'no nicknames, e-mails or user ids in the detail');
select pg_temp.gh_as(:'t1');
select pg_temp.gh_check(jsonb_array_length(public.group_assignment_hardest_detail(:'av', 0)->'items') = 1
  and jsonb_array_length(public.group_assignment_hardest_detail(:'av', 999)->'items') <= 10
  and jsonb_array_length(public.group_assignment_hardest_detail(:'av', 2)->'items') = 2,
  'p_limit is clamped to 1..10');

-- ---- due date passed: available without closing; nobody answered: empty list
select (public.group_assignment_create(:'gid', 'ghd-topic', 3, null, now() + interval '2 hours', false, 'after_due')
        -> 'assignment' ->> 'id') as ad \gset
select pg_temp.gh_check((public.group_assignment_hardest_detail(:'ad')->>'error') = 'not_finished',
  'open test before the due date: not_finished');
reset role;
update public.class_assignments set due_at = now() - interval '1 minute' where id = :'ad';
select pg_temp.gh_as(:'t1');
select pg_temp.gh_check((public.group_assignment_hardest_detail(:'ad')->>'ok')::boolean
  and jsonb_array_length(public.group_assignment_hardest_detail(:'ad')->'items') = 0,
  'due date passed and nobody answered: ok with an empty list');
reset role;
\echo ALL GROUP HARDEST DETAIL TESTS PASSED
