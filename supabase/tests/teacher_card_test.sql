-- «Ustoz kartasi» (20261031020000_teacher_card.sql): ruxsatlar, ko'rinish
-- qoidalari (visible=false), havola validatsiyasi, hajm, admin yashirishi,
-- rol olinishi, hisob o'chirilsa cascade.
-- Runs after plans_test.sql (fe database).
\set ON_ERROR_STOP 1
reset role;
revoke all on public.teacher_cards from anon, authenticated;

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
create function pg_temp.expect_error(q text, label text) returns void language plpgsql as $$
begin
  begin execute q; exception when others then
    raise notice 'PASS (blocked %): %', sqlstate, label; return; end;
  raise exception 'FAIL (allowed): %', label;
end $$;
grant execute on function pg_temp.as_user(text), pg_temp.as_anon(),
  pg_temp.check(boolean, text), pg_temp.expect_42501(text, text),
  pg_temp.expect_error(text, text) to anon, authenticated;

\set t1 '8c000000-0000-0000-0000-0000000000a1'
\set t2 '8c000000-0000-0000-0000-0000000000a2'
\set s1 '8c000000-0000-0000-0000-0000000000b1'
\set s2 '8c000000-0000-0000-0000-0000000000b2'
\set ad '8c000000-0000-0000-0000-0000000000d1'
\set g1 '8c000000-0000-0000-0000-0000000000e1'
\set g2 '8c000000-0000-0000-0000-0000000000e2'
insert into auth.users (id, email) values
 (:'t1', 'tc-teacher-one@secret.example'), (:'t2', 'tc-teacher-two@secret.example'),
 (:'s1', 'tc-student-one@secret.example'), (:'s2', 'tc-student-two@secret.example');
insert into auth.users (id, email, email_confirmed_at)
 values (:'ad', 'tc-admin@secret.example', now());
insert into account_roles (user_id, role, granted_by) values
 (:'t1', 'teacher', null), (:'t2', 'teacher', null), (:'ad', 'identity_admin', null);
insert into class_groups (id, teacher_id, name, code) values
 (:'g1', :'t1', 'Guruh 1', 'TCARD234'), (:'g2', :'t2', 'Guruh 2', 'TCARD567');
insert into class_group_members (group_id, user_id, nickname) values
 (:'g1', :'s1', 'Talaba Bir'), (:'g2', :'s1', 'Talaba Bir 2');
-- Storage obyektlari (Storage API yuklaydi; bu yerda faqat qatorlar).
insert into storage.objects (bucket_id, name) values
 ('teacher-cards', '8c000000-0000-0000-0000-0000000000a1/photo-11111111-1111-4111-8111-111111111111.jpg'),
 ('teacher-cards', '8c000000-0000-0000-0000-0000000000a1/logo-22222222-2222-4222-8222-222222222222.png'),
 ('teacher-cards', '8c000000-0000-0000-0000-0000000000a2/photo-33333333-3333-4333-8333-333333333333.webp');

-- ------------------------------------------------- havola validatori (to'g'ridan)
create temp table urlcases (k text, u text, ok boolean, why text);
insert into urlcases values
 ('telegram', 'https://t.me/forensic_teacher', true, 't.me'),
 ('telegram', 'https://telegram.me/forensic_teacher', true, 'telegram.me'),
 ('telegram', 'https://instagram.com/x', false, 'telegram kaliti instagram domenida'),
 ('instagram', 'https://www.instagram.com/forensic.teacher/', true, 'instagram www'),
 ('instagram', 'https://instagram.com/forensic.teacher?igsh=abc', true, 'instagram query'),
 ('youtube', 'https://youtube.com/@forensic', true, 'youtube'),
 ('youtube', 'https://youtu.be/abcdefghijk', true, 'youtu.be'),
 ('youtube', 'https://m.youtube.com/@forensic', true, 'm.youtube'),
 ('facebook', 'https://facebook.com/forensic', true, 'facebook'),
 ('facebook', 'https://l.facebook.com/l.php?u=https://evil.example', false, 'facebook redirector subdomeni'),
 ('linkedin', 'https://www.linkedin.com/in/forensic', true, 'linkedin'),
 ('tiktok', 'https://www.tiktok.com/@forensic', true, 'tiktok'),
 ('website', 'https://forensic.uz', true, 'website'),
 ('website', 'https://example.org/a/b?c=d#e', true, 'website yo''l'),
 ('website', 'http://forensic.uz', false, 'http rad'),
 ('website', 'javascript:alert(1)', false, 'javascript:'),
 ('website', 'JAVASCRIPT:alert(1)', false, 'JAVASCRIPT:'),
 ('website', 'data:text/html,<script>1</script>', false, 'data:'),
 ('website', 'ftp://forensic.uz', false, 'ftp'),
 ('website', '//forensic.uz', false, 'sxemasiz'),
 ('website', 'forensic.uz', false, 'sxemasiz domen'),
 ('website', 'https://forensic.uz:8443/x', false, 'port'),
 ('website', 'https://user:pass@forensic.uz/', false, 'userinfo'),
 ('website', 'https://t.me@evil.example/', false, 'userinfo hiyla'),
 ('website', 'https://127.0.0.1/', false, 'IP'),
 ('website', 'https://localhost/', false, 'localhost'),
 ('website', 'https://forensic.uz/a b', false, 'bo''shliq'),
 ('website', 'https://forensic.uz/<x>', false, 'burchak qavs'),
 ('website', 'https://forensic.uz/"x"', false, 'qo''sh tirnoq'),
 ('website', 'https://forensic..uz/', false, 'ketma-ket nuqta'),
 ('website', 'https://-bad.uz/', false, 'tire bilan boshlanadi'),
 ('telegram', 'https://t.me.evil.example/x', false, 't.me prefiksli begona domen'),
 ('telegram', 'https://evilt.me/x', false, 't.me suffiksli begona domen'),
 ('twitter', 'https://x.com/a', false, 'noma''lum kalit'),
 ('website', null, false, 'null');
insert into urlcases values ('website', 'https://forensic.uz/' || repeat('a', 235), true, '255 belgi');
insert into urlcases values ('website', 'https://forensic.uz/' || repeat('a', 236), false, '256 belgi');
select pg_temp.check(private.teacher_card_url_ok(k, u) is not distinct from ok, 'url_ok: ' || why)
  from urlcases;

-- ------------------------------------------------- ruxsat: faqat ustoz yozadi
select pg_temp.as_user(:'s1');
select pg_temp.check(teacher_card_get_mine() = '{"ok": true, "card": null, "is_teacher": false}'::jsonb,
  'talaba: get_mine bo''sh, is_teacher=false');
select pg_temp.expect_42501($q$select teacher_card_upsert('Talaba', '', '', null, null, '{}', false)$q$,
  'talaba karta yoza olmaydi');
select pg_temp.as_user(:'t1');
select pg_temp.check((teacher_card_get_mine()->>'is_teacher')::boolean, 'ustoz: is_teacher=true');
select pg_temp.as_anon();
select pg_temp.expect_error($q$select teacher_card_get_mine()$q$, 'anon get_mine rad');
select pg_temp.expect_error($q$select teacher_card_upsert('Anon Ustoz')$q$, 'anon upsert rad');
select pg_temp.expect_error($q$select teacher_card_get('8c000000-0000-0000-0000-0000000000a1')$q$, 'anon get rad');
select pg_temp.expect_error($q$select teacher_card_for_group('8c000000-0000-0000-0000-0000000000e1')$q$, 'anon for_group rad');
select pg_temp.expect_error($q$select teacher_card_delete()$q$, 'anon delete rad');
select pg_temp.expect_error($q$select admin_teacher_card_hide('8c000000-0000-0000-0000-0000000000a1')$q$, 'anon admin_hide rad');

-- ------------------------------------------------- validatsiya (ustoz t1)
select pg_temp.as_user(:'t1');
select pg_temp.check(teacher_card_upsert('A')->>'error' = 'invalid_name', 'ism 1 belgi rad');
select pg_temp.check(teacher_card_upsert(repeat('a', 61))->>'error' = 'invalid_name', 'ism 61 belgi rad');
select pg_temp.check(teacher_card_upsert(repeat('a', 60))->>'ok' = 'true', 'ism 60 belgi qabul');
select pg_temp.check(teacher_card_upsert(null)->>'error' = 'invalid_name', 'ism null rad');
select pg_temp.check(teacher_card_upsert('Ism', repeat('w', 121))->>'error' = 'invalid_workplace', 'ish joyi 121 rad');
select pg_temp.check(teacher_card_upsert('Ism', repeat('w', 120))->>'ok' = 'true', 'ish joyi 120 qabul');
select pg_temp.check(teacher_card_upsert('Ism', '', repeat('b', 301))->>'error' = 'invalid_bio', 'bio 301 rad');
select pg_temp.check(teacher_card_upsert('Ism', '', repeat('b', 300))->>'ok' = 'true', 'bio 300 qabul');
select pg_temp.check(teacher_card_upsert('Ism', '', E'ikki\nqator')->>'ok' = 'true', 'bio ko''p qatorli');
select pg_temp.check(teacher_card_upsert(E'Is\x01m')->>'error' = 'invalid_name', 'ismda boshqaruv belgisi rad');
select pg_temp.check(teacher_card_upsert('Ism', '', '', '8c000000-0000-0000-0000-0000000000a2/photo-33333333-3333-4333-8333-333333333333.webp')->>'error' = 'invalid_photo',
  'boshqa ustoz rasm yo''lini ishlatib bo''lmaydi');
select pg_temp.check(teacher_card_upsert('Ism', '', '', '8c000000-0000-0000-0000-0000000000a1/photo-44444444-4444-4444-8444-444444444444.jpg')->>'error' = 'invalid_photo',
  'storage''da yo''q rasm rad');
select pg_temp.check(teacher_card_upsert('Ism', '', '', '8c000000-0000-0000-0000-0000000000a1/logo-22222222-2222-4222-8222-222222222222.png')->>'error' = 'invalid_photo',
  'logo yo''li photo o''rnida rad');
select pg_temp.check(teacher_card_upsert('Ism', '', '', null, '8c000000-0000-0000-0000-0000000000a1/photo-11111111-1111-4111-8111-111111111111.jpg')->>'error' = 'invalid_logo',
  'photo yo''li logo o''rnida rad');
select pg_temp.check(teacher_card_upsert('Ism', '', '', '../8c000000-0000-0000-0000-0000000000a1/photo-11111111-1111-4111-8111-111111111111.jpg')->>'error' = 'invalid_photo',
  'yo''l hiylasi (..) rad');
select pg_temp.check(teacher_card_upsert('Ism', '', '', null, null, '{"website":"javascript:alert(1)"}')->>'error' = 'invalid_social', 'javascript: rad');
select pg_temp.check(teacher_card_upsert('Ism', '', '', null, null, '{"website":"javascript:alert(1)"}')->>'field' = 'website', 'xato maydoni ko''rsatiladi');
select pg_temp.check(teacher_card_upsert('Ism', '', '', null, null, '{"website":"http://forensic.uz"}')->>'error' = 'invalid_social', 'http: rad');
select pg_temp.check(teacher_card_upsert('Ism', '', '', null, null, '{"website":"data:text/html,x"}')->>'error' = 'invalid_social', 'data: rad');
select pg_temp.check(teacher_card_upsert('Ism', '', '', null, null, '{"telegram":"https://evil.example/x"}')->>'error' = 'invalid_social', 'noma''lum domen (telegram) rad');
select pg_temp.check(teacher_card_upsert('Ism', '', '', null, null, '{"instagram":"https://t.me/x"}')->>'error' = 'invalid_social', 'tarmoq kaliti va domeni mos emas');
select pg_temp.check(teacher_card_upsert('Ism', '', '', null, null, '{"twitter":"https://x.com/a"}')->>'error' = 'invalid_social', 'noma''lum tarmoq kaliti rad');
select pg_temp.check(teacher_card_upsert('Ism', '', '', null, null, '{"telegram":5}')->>'error' = 'invalid_social', 'son qiymati rad');
select pg_temp.check(teacher_card_upsert('Ism', '', '', null, null, '["https://t.me/x"]')->>'error' = 'invalid_social', 'massiv rad');
select pg_temp.check(teacher_card_upsert('Ism', '', '', null, null, ('{"website":"https://forensic.uz/' || repeat('a', 236) || '"}')::jsonb)->>'error' = 'invalid_social', 'website 256 belgi rad');

-- ------------------------------------------------- saqlash + rozilik (default O'CHIQ)
select pg_temp.as_user(:'t1');
select teacher_card_upsert('Dilshod Karimov', 'Sud ekspertizasi markazi', 'Toksikologiya bo''yicha ustoz.',
  '8c000000-0000-0000-0000-0000000000a1/photo-11111111-1111-4111-8111-111111111111.jpg',
  '8c000000-0000-0000-0000-0000000000a1/logo-22222222-2222-4222-8222-222222222222.png',
  '{"telegram":" https://t.me/dkarimov ","instagram":"","youtube":null,"website":"https://forensic.uz"}') as r \gset
select pg_temp.check(:'r'::jsonb->>'ok' = 'true', 'to''g''ri karta saqlandi');
select pg_temp.check((:'r'::jsonb->'card'->>'visible')::boolean = false, 'DEFAULT visible=false');
select pg_temp.check(:'r'::jsonb->'card'->>'consent_at' is null, 'rozilik yo''q (consent_at null)');
select pg_temp.check(:'r'::jsonb->'card'->'socials' = '{"telegram":"https://t.me/dkarimov","website":"https://forensic.uz"}'::jsonb,
  'bo''sh/null tarmoqlar tashlandi, bo''shliqlar kesildi');
select pg_temp.check(:'r'::jsonb->'card'->>'photo_path' like '%/photo-1111%', 'photo_path saqlandi');

-- visible=false: guruh a'zosi ham ko'rmaydi
select pg_temp.as_user(:'s1');
select pg_temp.check(teacher_card_get(:'t1')->'card' = 'null'::jsonb, 'visible=false: a''zo kartani ko''rmaydi (get)');
select pg_temp.check(teacher_card_for_group(:'g1')->'card' = 'null'::jsonb, 'visible=false: a''zo kartani ko''rmaydi (for_group)');
-- a'zo emas
select pg_temp.as_user(:'s2');
select pg_temp.expect_42501($q$select teacher_card_get('8c000000-0000-0000-0000-0000000000a1')$q$, 'a''zo bo''lmagan talaba: get 403');
select pg_temp.expect_42501($q$select teacher_card_for_group('8c000000-0000-0000-0000-0000000000e1')$q$, 'a''zo bo''lmagan talaba: for_group 403');
-- boshqa ustoz ham ko'ra olmaydi
select pg_temp.as_user(:'t2');
select pg_temp.expect_42501($q$select teacher_card_get('8c000000-0000-0000-0000-0000000000a1')$q$, 'boshqa ustoz t1 kartasini ko''ra olmaydi');
-- ustozning o'zi get'da: yashirin = null, get_mine = to'liq
select pg_temp.as_user(:'t1');
select pg_temp.check(teacher_card_get(:'t1')->'card' = 'null'::jsonb, 'egasi: get yashirin kartani qaytarmaydi');
select pg_temp.check(teacher_card_get_mine()->'card'->>'display_name' = 'Dilshod Karimov', 'egasi: get_mine to''liq');

-- yoqish (rozilik)
select teacher_card_upsert('Dilshod Karimov', 'Sud ekspertizasi markazi', 'Toksikologiya bo''yicha ustoz.',
  '8c000000-0000-0000-0000-0000000000a1/photo-11111111-1111-4111-8111-111111111111.jpg', null,
  '{"telegram":"https://t.me/dkarimov"}', true) as r \gset
select pg_temp.check((:'r'::jsonb->'card'->>'visible')::boolean, 'visible=true saqlandi');
select pg_temp.check(:'r'::jsonb->'card'->>'consent_at' is not null, 'rozilik vaqti yozildi');
select pg_temp.check(:'r'::jsonb->'card'->>'logo_path' is null, 'logotip olib tashlandi');
select teacher_card_get_mine()->'card'->>'consent_at' as c1 \gset
select pg_temp.check((select teacher_card_upsert('Dilshod K.', 'Markaz', '', null, null, '{}', true)->'card'->>'consent_at') = :'c1',
  'qayta saqlashda rozilik vaqti o''zgarmaydi');
select teacher_card_upsert('Dilshod Karimov', 'Sud ekspertizasi markazi', 'Toksikologiya bo''yicha ustoz.',
  '8c000000-0000-0000-0000-0000000000a1/photo-11111111-1111-4111-8111-111111111111.jpg',
  '8c000000-0000-0000-0000-0000000000a1/logo-22222222-2222-4222-8222-222222222222.png',
  '{"telegram":"https://t.me/dkarimov"}', true) as r \gset

-- a'zo endi ko'radi (talaba ko'rinishi: egasiga oid kalitlarsiz)
select pg_temp.as_user(:'s1');
select teacher_card_for_group(:'g1') as v \gset
select pg_temp.check(:'v'::jsonb->'card'->>'display_name' = 'Dilshod Karimov', 'visible=true: a''zo kartani ko''radi');
select pg_temp.check(not (:'v'::jsonb->'card' ? 'visible') and not (:'v'::jsonb->'card' ? 'consent_at')
  and not (:'v'::jsonb->'card' ? 'hidden_by_admin'), 'talaba javobida ichki kalitlar yo''q');
select pg_temp.check((select array_agg(k order by k) from jsonb_object_keys(:'v'::jsonb->'card') k)
  = array['bio','display_name','logo_path','photo_path','socials','teacher_id','updated_at','workplace'],
  'talaba karta kalitlari aniq ro''yxat');
select pg_temp.check(teacher_card_get(:'t1') = :'v'::jsonb, 'get == for_group');
select pg_temp.check(:'v'::text not ilike '%secret.example%', 'email sizmaydi');
-- boshqa ustozning guruhi a'zosi t1 ni ko'ra olmaydi (s1 ikkala guruhda; t2 kartasi yo'q)
select pg_temp.check(teacher_card_for_group(:'g2')->'card' = 'null'::jsonb, 't2 kartasi yo''q: null');
select pg_temp.as_user(:'s2');
select pg_temp.expect_42501($q$select teacher_card_get('8c000000-0000-0000-0000-0000000000a1')$q$, 'a''zo bo''lmagan: hali ham 403');
-- jadvalga to'g'ridan-to'g'ri kirish yo'q
select pg_temp.as_user(:'s1');
select pg_temp.expect_42501($q$select * from public.teacher_cards$q$, 'jadvalni o''qib bo''lmaydi');
select pg_temp.expect_42501($q$insert into public.teacher_cards (user_id, display_name) values ('8c000000-0000-0000-0000-0000000000b1', 'Hack')$q$, 'jadvalga yozib bo''lmaydi');
select pg_temp.expect_42501($q$update public.teacher_cards set visible = true$q$, 'jadvalni yangilab bo''lmaydi');
select pg_temp.expect_42501($q$delete from public.teacher_cards$q$, 'jadvaldan o''chirib bo''lmaydi');

-- guruhdan chiqqach ko'rish to'xtaydi
reset role;
delete from class_group_members where group_id = :'g1' and user_id = :'s1';
select pg_temp.as_user(:'s1');
select pg_temp.expect_42501($q$select teacher_card_get('8c000000-0000-0000-0000-0000000000a1')$q$, 'guruhdan chiqqach: 403');
reset role;
insert into class_group_members (group_id, user_id, nickname) values (:'g1', :'s1', 'Talaba Bir');

-- ------------------------------------------------- admin yashirishi (UGC)
select pg_temp.as_user(:'s1');
select pg_temp.expect_error($q$select admin_teacher_card_hide('8c000000-0000-0000-0000-0000000000a1')$q$, 'talaba admin_hide chaqira olmaydi');
select pg_temp.as_user(:'t1');
select pg_temp.expect_error($q$select admin_teacher_card_hide('8c000000-0000-0000-0000-0000000000a1')$q$, 'ustoz o''zini admin_hide qila olmaydi');
select pg_temp.as_user(:'ad');
select pg_temp.check(admin_teacher_card_hide(:'t1', true, 'nomaqbul rasm')->>'found' = 'true', 'admin kartani yashirdi');
select pg_temp.as_user(:'s1');
select pg_temp.check(teacher_card_get(:'t1')->'card' = 'null'::jsonb, 'admin yashirgan: a''zo ko''rmaydi');
select pg_temp.as_user(:'t1');
select pg_temp.check(teacher_card_get_mine()->'card'->>'hidden_by_admin' = 'true', 'egasi: hidden_by_admin=true');
select pg_temp.check(teacher_card_upsert('Dilshod Karimov', '', '', null, null, '{}', true)->>'error' = 'hidden_by_admin',
  'ustoz admin yashirgan kartani o''zi qayta yoqa olmaydi');
select pg_temp.check(teacher_card_upsert('Dilshod Karimov', '', '', null, null, '{}', false)->>'ok' = 'true',
  'ustoz kartani tahrirlay oladi (yashirin holda)');
select pg_temp.as_user(:'ad');
select pg_temp.check(admin_teacher_card_hide(:'t1', false)->>'ok' = 'true', 'admin qaytardi');
reset role;
select pg_temp.check((select count(*) = 2 from private.admin_audit
  where action in ('TEACHER_CARD_HIDE', 'TEACHER_CARD_UNHIDE') and target_id = :'t1'), 'admin amallari audit log''da');
select pg_temp.check((select visible = false from public.teacher_cards where user_id = :'t1'),
  'unhide kartani avtomatik yoqmaydi (ustoz qayta rozilik beradi)');
select pg_temp.as_user(:'t1');
select teacher_card_upsert('Dilshod Karimov', 'Markaz', '', '8c000000-0000-0000-0000-0000000000a1/photo-11111111-1111-4111-8111-111111111111.jpg', null, '{}', true) as r \gset
select pg_temp.as_user(:'s1');
select pg_temp.check(teacher_card_get(:'t1')->'card'->>'workplace' = 'Markaz', 'qayta yoqilgach a''zo ko''radi');

-- ------------------------------------------------- ustoz roli olinsa
reset role;
delete from account_roles where user_id = :'t1' and role = 'teacher';
select pg_temp.as_user(:'s1');
select pg_temp.check(teacher_card_get(:'t1')->'card' = 'null'::jsonb, 'roli olingan ustoz kartasi ko''rinmaydi');
select pg_temp.as_user(:'t1');
select pg_temp.expect_42501($q$select teacher_card_upsert('Dilshod Karimov')$q$, 'roli olingan ustoz yozolmaydi');
select pg_temp.check(teacher_card_get_mine()->'card'->>'display_name' = 'Dilshod Karimov', 'roli olingan ustoz o''z kartasini ko''radi');
reset role;
insert into account_roles (user_id, role, granted_by) values (:'t1', 'teacher', null);

-- ------------------------------------------------- o'chirish + cascade
select pg_temp.as_user(:'t2');
select teacher_card_upsert('Ikkinchi Ustoz', '', '', '8c000000-0000-0000-0000-0000000000a2/photo-33333333-3333-4333-8333-333333333333.webp') as r \gset
select pg_temp.check(:'r'::jsonb->>'ok' = 'true', 't2 kartasi saqlandi');
select pg_temp.as_user(:'t1');
select teacher_card_delete() as d \gset
select pg_temp.check(:'d'::jsonb->>'deleted' = 'true', 'delete: o''chirildi');
select pg_temp.check(:'d'::jsonb->>'photo_path' like '%/photo-1111%', 'delete: photo_path qaytadi (ilova Storage''dan o''chiradi)');
select pg_temp.check(teacher_card_delete()->>'deleted' = 'false', 'delete: qayta chaqirish zararsiz');
select pg_temp.check(teacher_card_get_mine()->'card' = 'null'::jsonb, 'delete: karta yo''q');
reset role;
select pg_temp.check((select count(*) = 1 from public.teacher_cards where user_id = :'t2'), 't2 kartasi turibdi');
delete from auth.users where id = :'t2';
select pg_temp.check((select count(*) = 0 from public.teacher_cards where user_id = :'t2'), 'hisob o''chirilsa karta cascade bilan o''chadi');
select pg_temp.check((select count(*) = 0 from public.teacher_cards), 'jadvalda ortiqcha qator yo''q');

-- ------------------------------------------------- bucket sozlamalari
select pg_temp.check((select not public and file_size_limit = 1048576
  and allowed_mime_types = array['image/jpeg', 'image/png', 'image/webp']
  from storage.buckets where id = 'teacher-cards'), 'bucket: xususiy, 1 MB, jpeg/png/webp');
select pg_temp.check((select count(*) = 3 from pg_policies where schemaname = 'storage'
  and tablename = 'objects' and policyname like 'teacher_cards_%'), 'storage: 3 siyosat (yozish/o''qish/o''chirish)');
select pg_temp.check(not exists (select 1 from pg_policies where schemaname = 'storage'
  and policyname like 'teacher_cards_%' and (roles::text like '%anon%' or roles::text like '%public%')),
  'storage: anon siyosati yo''q');
select 'ALL TEACHER CARD TESTS PASSED' as result;
