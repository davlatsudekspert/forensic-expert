-- AI imtihon paytida yopiq: jonli test va og‘zaki bilet; o‘rganishda ochiq.
\set ON_ERROR_STOP 1
reset role;
create function pg_temp.al_as(uid text) returns void language plpgsql as $$
begin
  perform set_config('request.jwt.claim.sub', uid, false);
  perform set_config('request.jwt.claims', '{}', false);
  perform set_config('role', 'authenticated', false);
end $$;
create function pg_temp.al_check(ok boolean, label text) returns void language plpgsql as $$
begin
  if ok is not true then raise exception 'FAIL: %', label; end if;
  raise notice 'PASS: %', label;
end $$;

insert into auth.users (id, email, created_at, email_confirmed_at) values
  ('9b000000-0000-0000-0000-00000000000a', 'al-t@test.uz', now(), now()),
  ('9b000000-0000-0000-0000-0000000000b1', 'al-s1@test.uz', now(), now()),
  ('9b000000-0000-0000-0000-0000000000b2', 'al-s2@test.uz', now(), now()),
  ('9b000000-0000-0000-0000-0000000000b3', 'al-s3@test.uz', now(), now()),
  ('9b000000-0000-0000-0000-0000000000b4', 'al-s4@test.uz', now(), now());
insert into public.class_sessions (id, teacher_id, code, topic_id, topic_title, status, settings)
values ('9b000000-0000-0000-0000-0000000000c1', '9b000000-0000-0000-0000-00000000000a',
        '987651', 'demo-topic', 'T', 'running', '{}'::jsonb),
       ('9b000000-0000-0000-0000-0000000000c2', '9b000000-0000-0000-0000-00000000000a',
        '987652', 'demo-topic', 'T', 'finished', '{}'::jsonb);
insert into public.class_participants (session_id, user_id, nickname) values
  ('9b000000-0000-0000-0000-0000000000c1', '9b000000-0000-0000-0000-0000000000b1', 'S1'),
  ('9b000000-0000-0000-0000-0000000000c2', '9b000000-0000-0000-0000-0000000000b2', 'S2');
insert into public.oral_sessions (id, teacher_id, code, title, settings, status) values
  ('9b000000-0000-0000-0000-0000000000d1', '9b000000-0000-0000-0000-00000000000a', '987653', '',
   '{"ticket_count":2,"prep_seconds":0}'::jsonb, 'open');
insert into public.oral_tickets (session_id, no, questions) values
  ('9b000000-0000-0000-0000-0000000000d1', 1, '[{"id":"q","text":"t"}]'::jsonb),
  ('9b000000-0000-0000-0000-0000000000d1', 2, '[{"id":"q","text":"t"}]'::jsonb);
insert into public.oral_participants (session_id, user_id, name, ticket_no) values
  ('9b000000-0000-0000-0000-0000000000d1', '9b000000-0000-0000-0000-0000000000b3', 'S3', 1),
  ('9b000000-0000-0000-0000-0000000000d1', '9b000000-0000-0000-0000-0000000000b4', 'S4', 2);

-- jonli testdagi talaba — AI yopiq
select pg_temp.al_as('9b000000-0000-0000-0000-0000000000b1');
select pg_temp.al_check(public.ai_exam_lock(), 'jonli testdagi talaba: AI yopiq');
reset role;
-- tugagan testdagi talaba — ochiq
select pg_temp.al_as('9b000000-0000-0000-0000-0000000000b2');
select pg_temp.al_check(not public.ai_exam_lock(), 'tugagan testdan keyin AI ochiq');
reset role;
-- og‘zaki bilet (baholanmagan) — yopiq
select pg_temp.al_as('9b000000-0000-0000-0000-0000000000b3');
select pg_temp.al_check(public.ai_exam_lock(), 'bilet olgan talaba: AI yopiq');
reset role;
-- baholangach ochiladi
update public.oral_participants set graded_at = now(), scores = array[10,10]::smallint[]
 where user_id = '9b000000-0000-0000-0000-0000000000b3';
select pg_temp.al_as('9b000000-0000-0000-0000-0000000000b3');
select pg_temp.al_check(not public.ai_exam_lock(), 'baholangach AI ochiq');
reset role;
-- chetlatilgan (kicked) — ochiq
update public.oral_participants set kicked_at = now() where user_id = '9b000000-0000-0000-0000-0000000000b4';
select pg_temp.al_as('9b000000-0000-0000-0000-0000000000b4');
select pg_temp.al_check(not public.ai_exam_lock(), 'chetlatilgan talabada AI ochiq');
reset role;
-- ustoz ishtirokchi emas — ochiq
select pg_temp.al_as('9b000000-0000-0000-0000-00000000000a');
select pg_temp.al_check(not public.ai_exam_lock(), 'ustozda AI ochiq');
reset role;
-- 6 soatdan eski qoldiq — ochiq
update public.class_sessions set created_at = now() - interval '7 hours'
 where id = '9b000000-0000-0000-0000-0000000000c1';
select pg_temp.al_as('9b000000-0000-0000-0000-0000000000b1');
select pg_temp.al_check(not public.ai_exam_lock(), 'eski (tashlab ketilgan) sessiya bloklamaydi');
reset role;
-- anonim chaqira olmaydi
select pg_temp.al_as('9b000000-0000-0000-0000-0000000000b1');
set role anon;
do $$ begin
  begin perform public.ai_exam_lock(); raise exception 'FAIL: anon chaqira oldi';
  exception when insufficient_privilege then raise notice 'PASS: anon chaqira olmaydi'; end;
end $$;
reset role;
