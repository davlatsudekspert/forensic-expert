-- «Talaba kartasi» Storage RLS (fe_matrix: Supabase-like default grants,
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

\set s1 '8d100000-0000-0000-0000-0000000000b1'
\set s2 '8d100000-0000-0000-0000-0000000000b2'
\set s3 '8d100000-0000-0000-0000-0000000000b3'
\set s4 '8d100000-0000-0000-0000-0000000000b4'
\set t1 '8d100000-0000-0000-0000-0000000000a1'
\set t2 '8d100000-0000-0000-0000-0000000000a2'
\set g1 '8d100000-0000-0000-0000-0000000000e1'
insert into auth.users (id, email) values (:'s1', 'sa@x'), (:'s2', 'sb@x'), (:'s3', 'sc@x'), (:'s4', 'sd@x'),
  (:'t1', 'se@x'), (:'t2', 'sf@x');
insert into account_roles (user_id, role, granted_by) values (:'t1', 'teacher', null), (:'t2', 'teacher', null);
-- g1 (t1): s1 (karta egasi), s2 (guruhdosh). s3 — boshqa guruhda, s4 — guruhsiz.
insert into class_groups (id, teacher_id, name, code) values (:'g1', :'t1', 'Guruh', 'SSTRA234');
insert into class_group_members (group_id, user_id, nickname) values (:'g1', :'s1', 'Talaba Bir'), (:'g1', :'s2', 'Talaba Ikki');
insert into class_groups (id, teacher_id, name, code) values ('8d100000-0000-0000-0000-0000000000e2', :'t2', 'Boshqa', 'SSTRB234');
insert into class_group_members (group_id, user_id, nickname) values ('8d100000-0000-0000-0000-0000000000e2', :'s3', 'Talaba Uch');

-- Talaba (ustoz roli yo'q) yuklaydi.
select pg_temp.as_user(:'s1');
insert into storage.objects (bucket_id, name)
  values ('student-cards', '8d100000-0000-0000-0000-0000000000b1/photo-11111111-1111-4111-8111-111111111111.jpg');
select pg_temp.check(true, 'talaba o''z papkasiga rasm yukladi');
select pg_temp.expect_42501($q$insert into storage.objects (bucket_id, name)
  values ('student-cards', '8d100000-0000-0000-0000-0000000000b2/photo-33333333-3333-4333-8333-333333333333.jpg')$q$,
  'talaba boshqa talaba papkasiga yoza olmaydi');
select pg_temp.expect_42501($q$insert into storage.objects (bucket_id, name)
  values ('student-cards', '8d100000-0000-0000-0000-0000000000b1/evil.php')$q$, 'noto''g''ri nom rad');
select pg_temp.expect_42501($q$insert into storage.objects (bucket_id, name)
  values ('student-cards', '8d100000-0000-0000-0000-0000000000b1/logo-11111111-1111-4111-8111-111111111112.jpg')$q$, 'logo- nomi rad (faqat photo-)');
select pg_temp.expect_42501($q$insert into storage.objects (bucket_id, name)
  values ('student-cards', '8d100000-0000-0000-0000-0000000000b1/photo-11111111-1111-4111-8111-111111111112.gif')$q$, 'noto''g''ri kengaytma rad');
select pg_temp.expect_42501($q$insert into storage.objects (bucket_id, name)
  values ('student-cards', '8d100000-0000-0000-0000-0000000000b1/sub/photo-11111111-1111-4111-8111-111111111113.jpg')$q$, 'ichki papka rad');
-- 4 ta chegara (1 ta bor: yana 3 ta mumkin, 5-chisi rad)
insert into storage.objects (bucket_id, name) select 'student-cards',
  '8d100000-0000-0000-0000-0000000000b1/photo-aaaaaaaa-aaaa-4aaa-8aaa-00000000000' || g || '.jpg' from generate_series(1, 3) g;
select pg_temp.expect_42501($q$insert into storage.objects (bucket_id, name)
  values ('student-cards', '8d100000-0000-0000-0000-0000000000b1/photo-aaaaaaaa-aaaa-4aaa-8aaa-000000000009.jpg')$q$, '5-obyekt rad (limit 4)');
select pg_temp.check(pg_temp.del($q$delete from storage.objects where bucket_id = 'student-cards'
  and name like '8d100000-0000-0000-0000-0000000000b1/photo-aaaaaaaa%'$q$) = 3, 'egasi o''z obyektlarini o''chira oladi');

-- O'qish: karta hali yo'q/yashirin
select pg_temp.as_user(:'s2');
select pg_temp.check(pg_temp.rows($q$select 1 from storage.objects where bucket_id = 'student-cards'$q$) = 0,
  'karta yo''q: guruhdosh rasmni o''qiy olmaydi');
select pg_temp.as_user(:'s1');
select pg_temp.check(pg_temp.rows($q$select 1 from storage.objects where bucket_id = 'student-cards'$q$) = 1,
  'egasi o''z rasmini ko''radi');
select pg_temp.check(student_card_upsert('Talaba Bir', '',
  '8d100000-0000-0000-0000-0000000000b1/photo-11111111-1111-4111-8111-111111111111.jpg', false)->>'ok' = 'true', 'karta (yashirin) saqlandi');
select pg_temp.as_user(:'s2');
select pg_temp.check(pg_temp.rows($q$select 1 from storage.objects where bucket_id = 'student-cards'$q$) = 0,
  'visible=false: guruhdosh rasmni o''qiy olmaydi');
select pg_temp.as_user(:'t1');
select pg_temp.check(pg_temp.rows($q$select 1 from storage.objects where bucket_id = 'student-cards'$q$) = 0,
  'visible=false: ustoz rasmni o''qiy olmaydi');
select pg_temp.as_user(:'s1');
select pg_temp.check(student_card_upsert('Talaba Bir', '',
  '8d100000-0000-0000-0000-0000000000b1/photo-11111111-1111-4111-8111-111111111111.jpg', true)->>'ok' = 'true', 'karta ko''rinadigan qilindi');
-- ikkinchi (hozirgi kartada yo'q) rasm yuklanadi: o'qib bo'lmaydi
insert into storage.objects (bucket_id, name)
  values ('student-cards', '8d100000-0000-0000-0000-0000000000b1/photo-55555555-5555-4555-8555-555555555555.png');
select pg_temp.as_user(:'s2');
select pg_temp.check(pg_temp.rows($q$select 1 from storage.objects where bucket_id = 'student-cards'$q$) = 1,
  'visible=true: guruhdosh faqat kartadagi joriy rasmni o''qiydi');
select pg_temp.as_user(:'t1');
select pg_temp.check(pg_temp.rows($q$select 1 from storage.objects where bucket_id = 'student-cards'$q$) = 1,
  'visible=true: guruh ustozi joriy rasmni o''qiydi');
select pg_temp.as_user(:'s3');
select pg_temp.check(pg_temp.rows($q$select 1 from storage.objects where bucket_id = 'student-cards'$q$) = 0,
  'boshqa guruh talabasi rasmni o''qiy olmaydi');
select pg_temp.as_user(:'s4');
select pg_temp.check(pg_temp.rows($q$select 1 from storage.objects where bucket_id = 'student-cards'$q$) = 0,
  'guruhsiz talaba rasmni o''qiy olmaydi');
select pg_temp.as_user(:'t2');
select pg_temp.check(pg_temp.rows($q$select 1 from storage.objects where bucket_id = 'student-cards'$q$) = 0,
  'boshqa ustoz rasmni o''qiy olmaydi');
select pg_temp.as_anon();
select pg_temp.check(pg_temp.rows($q$select 1 from storage.objects where bucket_id = 'student-cards'$q$) = 0,
  'anon rasmni o''qiy olmaydi');
select pg_temp.expect_42501($q$insert into storage.objects (bucket_id, name)
  values ('student-cards', '8d100000-0000-0000-0000-0000000000b1/photo-66666666-6666-4666-8666-666666666666.jpg')$q$, 'anon yoza olmaydi');
-- guruhdosh o'chira/yangilay olmaydi
select pg_temp.as_user(:'s2');
select pg_temp.check(pg_temp.del($q$delete from storage.objects where bucket_id = 'student-cards'$q$) = 0, 'guruhdosh o''chira olmaydi');
select pg_temp.check(pg_temp.del($q$update storage.objects set name = name || 'x' where bucket_id = 'student-cards'$q$) = 0, 'guruhdosh nomini o''zgartira olmaydi');
select pg_temp.as_user(:'t1');
select pg_temp.check(pg_temp.del($q$delete from storage.objects where bucket_id = 'student-cards'$q$) = 0, 'ustoz ham o''chira olmaydi');
select pg_temp.as_user(:'s1');
select pg_temp.check(pg_temp.del($q$update storage.objects set name = name || 'x' where bucket_id = 'student-cards'$q$) = 0, 'egasi ham nom o''zgartira olmaydi (update siyosati yo''q)');

-- Ko'ruvchi yashirsa rasm yopiladi, qaytarsa ochiladi
select pg_temp.as_user(:'s2');
select pg_temp.check(student_card_hide_for_me(:'s1')->>'ok' = 'true', 'guruhdosh kartani yashirdi');
select pg_temp.check(pg_temp.rows($q$select 1 from storage.objects where bucket_id = 'student-cards'$q$) = 0,
  'o''zi yashirgan karta rasmi yopiq');
select pg_temp.check(student_card_hide_for_me(:'s1', false)->>'ok' = 'true', 'qaytardi');
select pg_temp.check(pg_temp.rows($q$select 1 from storage.objects where bucket_id = 'student-cards'$q$) = 1, 'qaytargach rasm ochiq');
-- Ustoz guruhdan yashirsa guruhdoshga yopiladi, ustozning o'zi ko'radi
select pg_temp.as_user(:'t1');
select pg_temp.check(group_student_card_hide(:'g1', :'s1')->>'ok' = 'true', 'ustoz guruhdan yashirdi');
select pg_temp.check(pg_temp.rows($q$select 1 from storage.objects where bucket_id = 'student-cards'$q$) = 1,
  'ustoz moderator rasmni ko''radi');
select pg_temp.as_user(:'s2');
select pg_temp.check(pg_temp.rows($q$select 1 from storage.objects where bucket_id = 'student-cards'$q$) = 0,
  'guruhdan yashirilgan karta rasmi guruhdoshga yopiq');
reset role;
delete from student_card_group_hides;
-- Admin yashirsa rasm ham yopiladi
update public.student_cards set hidden_by_admin = true, visible = false where user_id = :'s1';
select pg_temp.as_user(:'s2');
select pg_temp.check(pg_temp.rows($q$select 1 from storage.objects where bucket_id = 'student-cards'$q$) = 0,
  'admin yashirgach rasm ham yopiladi');
select pg_temp.as_user(:'t1');
select pg_temp.check(pg_temp.rows($q$select 1 from storage.objects where bucket_id = 'student-cards'$q$) = 0,
  'admin yashirgach ustoz ham ko''rmaydi');
reset role;
update public.student_cards set hidden_by_admin = false, visible = true where user_id = :'s1';
select pg_temp.as_user(:'s2');
select pg_temp.check(pg_temp.rows($q$select 1 from storage.objects where bucket_id = 'student-cards'$q$) = 1, 'qayta ochilgach ko''rinadi');
-- Guruhdan chiqsa
reset role;
delete from class_group_members where group_id = :'g1' and user_id = :'s2';
select pg_temp.as_user(:'s2');
select pg_temp.check(pg_temp.rows($q$select 1 from storage.objects where bucket_id = 'student-cards'$q$) = 0,
  'guruhdan chiqqach rasm yopiladi');
reset role;
delete from auth.users where id = :'s1';
select pg_temp.as_user(:'t1');
select pg_temp.check(pg_temp.rows($q$select 1 from storage.objects where bucket_id = 'student-cards'$q$) = 0,
  'hisob o''chgach ustoz rasmni ko''ra olmaydi');
select 'ALL STUDENT CARD STORAGE TESTS PASSED' as result;
