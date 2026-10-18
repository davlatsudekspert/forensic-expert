-- «Ustoz–talaba testi»: to'liq e2e (lokal PostgreSQL, haqiqiy RPC'lar).
-- 1 ustoz + 3 talaba: guruh → variantli mavzu testi → QR kodi bilan
-- qo'shilish (taxallus, iPhone apostrofi bilan) → yechish → ustoz paneli →
-- yopish → javoblar ochiladi. Har talabaga boshqa savollar tushganini va
-- natijalar ustoz panelida chiqqanini tekshiradi; qisqa hisobot chiqaradi.
\set ON_ERROR_STOP 1
reset role;
create function pg_temp.e2e_as(uid text) returns void language plpgsql as $$
begin
  perform set_config('request.jwt.claim.sub', uid, false);
  perform set_config('request.jwt.claims', '{}', false);
  perform set_config('role', 'authenticated', false);
end $$;
create function pg_temp.e2e_check(ok boolean, label text) returns void language plpgsql as $$
begin
  if not coalesce(ok, false) then raise exception 'E2E FAIL: %', label; end if;
  raise notice 'E2E PASS: %', label;
end $$;
grant execute on function pg_temp.e2e_as(text), pg_temp.e2e_check(boolean, text) to authenticated;

\set teacher '7e000000-0000-0000-0000-0000000000a1'
\set st1 '7e000000-0000-0000-0000-0000000000b1'
\set st2 '7e000000-0000-0000-0000-0000000000b2'
\set st3 '7e000000-0000-0000-0000-0000000000b3'
insert into auth.users (id, email) values
 (:'teacher', 'e2e-teacher@secret.example'), (:'st1', 'e2e-s1@secret.example'),
 (:'st2', 'e2e-s2@secret.example'), (:'st3', 'e2e-s3@secret.example');
insert into account_roles (user_id, role, granted_by) values (:'teacher', 'teacher', null);
insert into public.class_quiz_questions
  (topic_id, topic_title, position, question, options, correct_index, explanation, source)
select 'e2e-tox', 'Toksikologiya: CO zaharlanishi', g, 'E2E savol ' || g,
       jsonb_build_array('A' || g, 'B' || g, 'C' || g, 'D' || g), (g % 4)::smallint,
       'Izoh ' || g, '{"author":"Muallif","title":"Darslik","page":"41"}'::jsonb
from generate_series(1, 20) g;

-- 1. Ustoz: guruh va «Mavzu testi berish» (20 savoldan har talabaga 5, 15 daqiqa).
select pg_temp.e2e_as(:'teacher');
select (public.group_create('4-kurs, 2-guruh') -> 'group') as grp \gset
select :'grp'::jsonb ->> 'id' as gid, :'grp'::jsonb ->> 'code' as gcode \gset
select (public.group_assignment_create(:'gid', 'e2e-tox', 5, 15, now() + interval '1 day', true, 'after_due')
        -> 'assignment' ->> 'id') as aid \gset
\echo 'QR (hammaga bir xil):' forensicexpert://app/g/:gcode?a=:aid

-- 2. Talabalar QR'ni o'qiydi: birinchi marta taxallus so'raladi.
select pg_temp.e2e_as(:'st1');
select pg_temp.e2e_check((public.group_join(:'gcode', null, :'aid') ->> 'error') = 'nickname_required', 'st1: nickname asked');
select pg_temp.e2e_check((public.group_join(:'gcode', 'G’ayrat', :'aid') ->> 'assignment_id') = :'aid', 'st1 joined (iPhone apostrophe)');
select pg_temp.e2e_as(:'st2');
select pg_temp.e2e_check((public.group_join(lower(:'gcode'), 'Oʻtkir', :'aid') ->> 'nickname') = 'O''tkir', 'st2 joined (lower-case code, ʻ)');
select pg_temp.e2e_as(:'st3');
select pg_temp.e2e_check((public.group_join(:'gcode', 'Lola', :'aid') ->> 'role') = 'student', 'st3 joined');

-- 3. Ustoz panelida hammasi «qo'shildi».
select pg_temp.e2e_as(:'teacher');
select pg_temp.e2e_check((select bool_and(r ->> 'state' = 'joined') and count(*) = 3
  from jsonb_array_elements(public.group_assignment_board(:'aid') -> 'rows') r), 'board: 3 joined');

-- 4. Talabalar testni ochadi → «Yechmoqda».
select pg_temp.e2e_as(:'st1');
select public.group_assignment_open(:'aid') ->> 'state' as x \gset
select pg_temp.e2e_as(:'st2');
select public.group_assignment_open(:'aid') ->> 'state' as x \gset
select pg_temp.e2e_as(:'st3');
select public.group_assignment_open(:'aid') ->> 'state' as x \gset
select pg_temp.e2e_as(:'teacher');
select pg_temp.e2e_check((select bool_and(r ->> 'state' = 'solving')
  from jsonb_array_elements(public.group_assignment_board(:'aid') -> 'rows') r), 'board: 3 solving');

reset role;
select pg_temp.e2e_check((select count(distinct question_ids) = 3 from class_assignment_attempts
  where assignment_id = :'aid'), 'every student got a different question set');
\echo 'Har talabaga tushgan savollar (variant):'
select m.nickname, array_to_string(array(select q.question from unnest(t.question_ids) with ordinality o(id, ord)
         join class_assignment_questions q on q.assignment_id = t.assignment_id and q.qid = o.id
         order by o.ord), ' | ') as savollar
from class_assignment_attempts t join class_group_members m
  on m.user_id = t.user_id and m.group_id = :'gid'
where t.assignment_id = :'aid' order by m.nickname;

-- 5. Yechish: st1 — 5 to'g'ri, st2 — 3 to'g'ri (har savoldan keyin saqlab), st3 — 1 to'g'ri.
create temp table e2e_key as
select t.user_id, o.ord, q.qid, q.correct_index
from class_assignment_attempts t, unnest(t.question_ids) with ordinality o(qid, ord)
join class_assignment_questions q on q.qid = o.qid
where q.assignment_id = t.assignment_id and t.assignment_id = :'aid';
grant select on e2e_key to authenticated;
select jsonb_object_agg(qid, correct_index) as a1 from e2e_key where user_id = :'st1' \gset
select jsonb_object_agg(qid, case when ord <= 3 then correct_index else (correct_index + 1) % 4 end) as a2
  from e2e_key where user_id = :'st2' \gset
select jsonb_object_agg(qid, case when ord <= 1 then correct_index else (correct_index + 1) % 4 end) as a3
  from e2e_key where user_id = :'st3' \gset
select pg_temp.e2e_as(:'st1');
select pg_temp.e2e_check((public.group_assignment_submit(:'aid', :'a1'::jsonb) ->> 'score')::int = 5, 'st1 5/5');
select pg_temp.e2e_as(:'st2');
select pg_temp.e2e_check((select bool_and((public.group_assignment_save(:'aid', jsonb_build_object(k, v)) ->> 'ok')::boolean)
  from jsonb_each(:'a2'::jsonb) e(k, v)), 'st2 saves after each answer');
select pg_temp.e2e_check((public.group_assignment_submit(:'aid', '{}'::jsonb) ->> 'score')::int = 3, 'st2 3/5 (saved answers)');
select pg_temp.e2e_check((public.group_assignment_result(:'aid') ->> 'revealed')::boolean = false, 'st2: answers hidden before due/close');

-- 6. Ustoz paneli: st1 va st2 tugatdi, st3 yechmoqda.
select pg_temp.e2e_as(:'teacher');
\echo 'Ustoz paneli (jonli):'
select r ->> 'nickname' as taxallus, r ->> 'state' as holat,
       coalesce((r ->> 'score') || '/' || (r ->> 'total'), '—') as ball
from jsonb_array_elements(public.group_assignment_board(:'aid') -> 'rows') r;
select pg_temp.e2e_as(:'st3');
select pg_temp.e2e_check((public.group_assignment_submit(:'aid', :'a3'::jsonb) ->> 'score')::int = 1, 'st3 1/5');

-- 7. Ustoz yopadi → natijalar va to'g'ri javoblar ochiladi.
select pg_temp.e2e_as(:'teacher');
select pg_temp.e2e_check((public.group_assignment_close(:'aid') ->> 'ok')::boolean, 'teacher closes the test');
select public.group_assignment_board(:'aid') as fin \gset
select pg_temp.e2e_check((select string_agg((r ->> 'nickname') || '=' || (r ->> 'score'), ',')
  from jsonb_array_elements(:'fin'::jsonb -> 'rows') r) = 'G''ayrat=5,O''tkir=3,Lola=1',
  'teacher sees all results ordered by score');
\echo 'Yakuniy natijalar:'
select r ->> 'nickname' as taxallus, r ->> 'state' as holat, (r ->> 'score') || '/' || (r ->> 'total') as ball
from jsonb_array_elements(:'fin'::jsonb -> 'rows') r;
select pg_temp.e2e_as(:'st2');
select pg_temp.e2e_check((public.group_assignment_result(:'aid') ->> 'revealed')::boolean
  and (select count(*) filter (where (i ->> 'is_correct')::boolean) = 3
       from jsonb_array_elements(public.group_assignment_result(:'aid') -> 'items') i),
  'st2 sees revealed answers: 3 correct');
reset role;
\echo ALL CLASS GROUPS E2E CHECKS PASSED
