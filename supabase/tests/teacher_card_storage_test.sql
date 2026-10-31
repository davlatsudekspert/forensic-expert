-- «Ustoz kartasi» Storage RLS (fe_matrix: Supabase-like default grants,
-- storage.objects API rollariga ochiq — faqat siyosatlar to'siq).
\set ON_ERROR_STOP 1
reset role;
create function pg_temp.as_user(uid text) returns void language plpgsql as $$
begin
  perform set_config('request.jwt.claim.sub', uid, false);
  perform set_config('request.jwt.claims', '{}', false);
  perform set_config('role', 'authenticated', false);
end $$;
create function pg_temp.as_anon() returns void language plpgsql as $$
begin
  perform set_config('request.jwt.claim.sub', '', false);
  perform set_config('request.jwt.claims', '{}', false);
  perform set_config('role', 'anon', false);
end $$;
create function pg_temp.check(ok boolean, label text) returns void language plpgsql as $$
begin
  if not coalesce(ok, false) then raise exception 'FAIL: %', label; end if;
  raise notice 'PASS: %', label;
end $$;
create function pg_temp.expect_42501(q text, label text) returns void language plpgsql as $$
begin
  begin execute q; exception
    when insufficient_privilege then raise notice 'PASS (42501): %', label; return;
    when others then raise exception 'FAIL (wrong error %: %): %', sqlstate, sqlerrm, label;
  end;
  raise exception 'FAIL (allowed): %', label;
end $$;
create function pg_temp.rows(q text) returns bigint language plpgsql as $$
declare n bigint;
begin execute 'select count(*) from (' || q || ') x' into n; return n; end $$;
create function pg_temp.del(q text) returns bigint language plpgsql as $$
declare n bigint;
begin execute q; get diagnostics n = row_count; return n; end $$;
grant execute on function pg_temp.as_user(text), pg_temp.as_anon(), pg_temp.check(boolean, text),
  pg_temp.expect_42501(text, text), pg_temp.rows(text), pg_temp.del(text) to anon, authenticated;

\set t1 '8d000000-0000-0000-0000-0000000000a1'
\set t2 '8d000000-0000-0000-0000-0000000000a2'
\set s1 '8d000000-0000-0000-0000-0000000000b1'
\set s2 '8d000000-0000-0000-0000-0000000000b2'
\set g1 '8d000000-0000-0000-0000-0000000000e1'
insert into auth.users (id, email) values (:'t1', 'sa@x'), (:'t2', 'sb@x'), (:'s1', 'sc@x'), (:'s2', 'sd@x');
insert into account_roles (user_id, role, granted_by) values (:'t1', 'teacher', null), (:'t2', 'teacher', null);
insert into class_groups (id, teacher_id, name, code) values (:'g1', :'t1', 'Guruh', 'TSTRA234');
insert into class_group_members (group_id, user_id, nickname) values (:'g1', :'s1', 'Talaba');

-- Ustoz yuklaydi (Storage API shu INSERT'ni bajaradi).
select pg_temp.as_user(:'t1');
insert into storage.objects (bucket_id, name)
  values ('teacher-cards', '8d000000-0000-0000-0000-0000000000a1/photo-11111111-1111-4111-8111-111111111111.jpg');
select pg_temp.check(true, 'ustoz o''z papkasiga rasm yukladi');
insert into storage.objects (bucket_id, name)
  values ('teacher-cards', '8d000000-0000-0000-0000-0000000000a1/logo-22222222-2222-4222-8222-222222222222.png');
select pg_temp.expect_42501($q$insert into storage.objects (bucket_id, name)
  values ('teacher-cards', '8d000000-0000-0000-0000-0000000000a2/photo-33333333-3333-4333-8333-333333333333.jpg')$q$,
  'ustoz boshqa ustoz papkasiga yoza olmaydi');
select pg_temp.expect_42501($q$insert into storage.objects (bucket_id, name)
  values ('teacher-cards', '8d000000-0000-0000-0000-0000000000a1/evil.php')$q$, 'noto''g''ri nom rad');
select pg_temp.expect_42501($q$insert into storage.objects (bucket_id, name)
  values ('teacher-cards', '8d000000-0000-0000-0000-0000000000a1/photo-11111111-1111-4111-8111-111111111112.gif')$q$, 'noto''g''ri kengaytma rad');
select pg_temp.expect_42501($q$insert into storage.objects (bucket_id, name)
  values ('teacher-cards', '8d000000-0000-0000-0000-0000000000a1/sub/photo-11111111-1111-4111-8111-111111111113.jpg')$q$, 'ichki papka rad');
-- 8 ta chegara (2 ta bor: yana 6 ta mumkin, 9-chisi rad)
insert into storage.objects (bucket_id, name) select 'teacher-cards',
  '8d000000-0000-0000-0000-0000000000a1/photo-aaaaaaaa-aaaa-4aaa-8aaa-00000000000' || g || '.jpg' from generate_series(1, 6) g;
select pg_temp.expect_42501($q$insert into storage.objects (bucket_id, name)
  values ('teacher-cards', '8d000000-0000-0000-0000-0000000000a1/photo-aaaaaaaa-aaaa-4aaa-8aaa-000000000009.jpg')$q$, '9-obyekt rad (limit 8)');
select pg_temp.check(pg_temp.del($q$delete from storage.objects where bucket_id = 'teacher-cards'
  and name like '8d000000-0000-0000-0000-0000000000a1/photo-aaaaaaaa%'$q$) = 6, 'egasi o''z obyektlarini o''chira oladi');

-- Talaba (ustoz emas) yoza olmaydi
select pg_temp.as_user(:'s1');
select pg_temp.expect_42501($q$insert into storage.objects (bucket_id, name)
  values ('teacher-cards', '8d000000-0000-0000-0000-0000000000b1/photo-55555555-5555-4555-8555-555555555555.jpg')$q$,
  'talaba (ustoz emas) yoza olmaydi');

-- O'qish: karta hali yo'q/yashirin
select pg_temp.check(pg_temp.rows($q$select 1 from storage.objects where bucket_id = 'teacher-cards'$q$) = 0,
  'karta yo''q: a''zo rasmni o''qiy olmaydi');
select pg_temp.as_user(:'t1');
select pg_temp.check(pg_temp.rows($q$select 1 from storage.objects where bucket_id = 'teacher-cards'$q$) = 2,
  'egasi o''z rasmlarini ko''radi');
select pg_temp.check(teacher_card_upsert('Ustoz Bir', '', '',
  '8d000000-0000-0000-0000-0000000000a1/photo-11111111-1111-4111-8111-111111111111.jpg', null, '{}', false)->>'ok' = 'true', 'karta (yashirin) saqlandi');
select pg_temp.as_user(:'s1');
select pg_temp.check(pg_temp.rows($q$select 1 from storage.objects where bucket_id = 'teacher-cards'$q$) = 0,
  'visible=false: a''zo rasmni o''qiy olmaydi');
select pg_temp.as_user(:'t1');
select pg_temp.check(teacher_card_upsert('Ustoz Bir', '', '',
  '8d000000-0000-0000-0000-0000000000a1/photo-11111111-1111-4111-8111-111111111111.jpg', null, '{}', true)->>'ok' = 'true', 'karta ko''rinadigan qilindi');
select pg_temp.as_user(:'s1');
select pg_temp.check(pg_temp.rows($q$select 1 from storage.objects where bucket_id = 'teacher-cards'$q$) = 1,
  'visible=true: a''zo faqat kartadagi joriy rasmni o''qiydi (logo kartada yo''q)');
select pg_temp.as_user(:'s2');
select pg_temp.check(pg_temp.rows($q$select 1 from storage.objects where bucket_id = 'teacher-cards'$q$) = 0,
  'a''zo bo''lmagan talaba rasmni o''qiy olmaydi');
select pg_temp.as_user(:'t2');
select pg_temp.check(pg_temp.rows($q$select 1 from storage.objects where bucket_id = 'teacher-cards'$q$) = 0,
  'boshqa ustoz rasmni o''qiy olmaydi');
select pg_temp.as_anon();
select pg_temp.check(pg_temp.rows($q$select 1 from storage.objects where bucket_id = 'teacher-cards'$q$) = 0,
  'anon rasmni o''qiy olmaydi');
select pg_temp.expect_42501($q$insert into storage.objects (bucket_id, name)
  values ('teacher-cards', '8d000000-0000-0000-0000-0000000000a1/photo-66666666-6666-4666-8666-666666666666.jpg')$q$, 'anon yoza olmaydi');
-- Talaba o'chira/yangilay olmaydi
select pg_temp.as_user(:'s1');
select pg_temp.check(pg_temp.del($q$delete from storage.objects where bucket_id = 'teacher-cards'$q$) = 0, 'talaba o''chira olmaydi');
select pg_temp.check(pg_temp.del($q$update storage.objects set name = name || 'x' where bucket_id = 'teacher-cards'$q$) = 0, 'talaba nomini o''zgartira olmaydi');
select pg_temp.as_user(:'t1');
select pg_temp.check(pg_temp.del($q$update storage.objects set name = name || 'x' where bucket_id = 'teacher-cards'$q$) = 0, 'egasi ham nom o''zgartira olmaydi (update siyosati yo''q)');
-- Admin yashirsa rasm ham yopiladi
reset role;
select pg_temp.as_user(:'t1');
reset role;
update public.teacher_cards set hidden_by_admin = true, visible = false where user_id = :'t1';
select pg_temp.as_user(:'s1');
select pg_temp.check(pg_temp.rows($q$select 1 from storage.objects where bucket_id = 'teacher-cards'$q$) = 0,
  'admin yashirgach rasm ham yopiladi');
-- Karta o'chirilsa (hisob o'chsa) a'zo rasmni ko'ra olmaydi
reset role;
update public.teacher_cards set hidden_by_admin = false, visible = true where user_id = :'t1';
select pg_temp.as_user(:'s1');
select pg_temp.check(pg_temp.rows($q$select 1 from storage.objects where bucket_id = 'teacher-cards'$q$) = 1, 'qayta ochilgach ko''rinadi');
reset role;
delete from auth.users where id = :'t1';
select pg_temp.as_user(:'s1');
select pg_temp.check(pg_temp.rows($q$select 1 from storage.objects where bucket_id = 'teacher-cards'$q$) = 0,
  'hisob o''chgach a''zo rasmni ko''ra olmaydi');
select 'ALL TEACHER CARD STORAGE TESTS PASSED' as result;
