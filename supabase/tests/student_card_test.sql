-- «Talaba kartasi» (20261031040000_student_card.sql): ko'rinish matritsasi
-- (egasi / guruh ustozi / guruhdosh / boshqa guruh talabasi / anon),
-- visible=false, admin yashirishi, «o'zim uchun yashirish», ustoz guruh
-- moderatsiyasi, matn filtri (havola/telefon/email/@), hajm, cascade.
-- Runs after plans_test.sql (fe database).
\set ON_ERROR_STOP 1
reset role;
revoke all on public.student_cards, public.student_card_hides, public.student_card_group_hides from anon, authenticated;

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


\set t1 '8e000000-0000-0000-0000-0000000000a1'
\set t2 '8e000000-0000-0000-0000-0000000000a2'
\set t3 '8e000000-0000-0000-0000-0000000000a3'
\set s1 '8e000000-0000-0000-0000-0000000000b1'
\set s2 '8e000000-0000-0000-0000-0000000000b2'
\set s3 '8e000000-0000-0000-0000-0000000000b3'
\set s4 '8e000000-0000-0000-0000-0000000000b4'
\set s6 '8e000000-0000-0000-0000-0000000000b6'
\set ad '8e000000-0000-0000-0000-0000000000d1'
\set g1 '8e000000-0000-0000-0000-0000000000e1'
\set g2 '8e000000-0000-0000-0000-0000000000e2'
\set g3 '8e000000-0000-0000-0000-0000000000e3'
insert into auth.users (id, email) values
 (:'t1', 'sc-t1@secret.example'), (:'t2', 'sc-t2@secret.example'), (:'t3', 'sc-t3@secret.example'),
 (:'s1', 'sc-s1@secret.example'), (:'s2', 'sc-s2@secret.example'), (:'s3', 'sc-s3@secret.example'),
 (:'s4', 'sc-s4@secret.example'), (:'s6', 'sc-s6@secret.example');
insert into auth.users (id, email, email_confirmed_at) values (:'ad', 'sc-admin@secret.example', now());
insert into account_roles (user_id, role, granted_by) values
 (:'t1', 'teacher', null), (:'t2', 'teacher', null), (:'t3', 'teacher', null), (:'ad', 'identity_admin', null);
-- g1 (t1): s1, s2.  g2 (t3): s1, s6.  g3 (t2): s3.  s4 — hech qaysi guruhda emas.
insert into class_groups (id, teacher_id, name, code) values
 (:'g1', :'t1', 'Guruh 1', 'SCARD234'), (:'g2', :'t3', 'Guruh 2', 'SCARD567'), (:'g3', :'t2', 'Guruh 3', 'SCARD789');
insert into class_group_members (group_id, user_id, nickname) values
 (:'g1', :'s1', 'Talaba Bir'), (:'g1', :'s2', 'Talaba Ikki'),
 (:'g2', :'s1', 'Talaba Bir G2'), (:'g2', :'s6', 'Talaba Olti'),
 (:'g3', :'s3', 'Talaba Uch');
insert into storage.objects (bucket_id, name) values
 ('student-cards', '8e000000-0000-0000-0000-0000000000b1/photo-11111111-1111-4111-8111-111111111111.jpg'),
 ('student-cards', '8e000000-0000-0000-0000-0000000000b2/photo-22222222-2222-4222-8222-222222222222.png');

-- ------------------------------------------------- matn filtri (to'g'ridan)
create temp table txtcases (t text, ok boolean, why text);
insert into txtcases values
 ('Dilshod', true, 'oddiy ism'),
 ('Ali (Toshkent)', true, 'qavs'),
 ('Men 3-kurs talabasiman', true, 'kurs raqami'),
 ('2024-2025 o''quv yili', true, 'yillar oralig''i'),
 ('Dr. Karimov', true, 'nuqtadan keyin bo''shliq va so''z'),
 ('Toksikologiya va kimyo, 2-kurs', true, 'oddiy matn'),
 ('Instantly', true, 'insta so''zning ichida'),
 ('Guruh 12', true, 'qisqa raqam'),
 ('Ali Valiyev', true, 'ism-familiya'),
 ('Олим Каримов', true, 'kirill ism'),
 ('', true, 'bo''sh'),
 ('https://example.org', false, 'https havola'),
 ('HTTP bilan', false, 'http (katta harf)'),
 ('www.site', false, 'www'),
 ('mening saytim site.uz', false, 'domen .uz'),
 ('site . com', false, 'bo''shliqli domen'),
 ('t.me/abc', false, 't.me'),
 ('@ali', false, '@username'),
 ('ali@mail.ru', false, 'email'),
 ('ali＠mail', false, 'to''liq kenglikdagi @'),
 ('Telegram: ali', false, 'telegram nomi'),
 ('instagram ali', false, 'instagram nomi'),
 ('Insta ali', false, 'insta (so''z)'),
 ('whatsapp', false, 'whatsapp'),
 ('Инстаграм', false, 'kirill instagram'),
 ('телеграм', false, 'kirill telegram'),
 ('tg: ali', false, 'tg'),
 ('+998901234567', false, '+998 raqam'),
 ('+998 90 123 45 67', false, '+998 bo''shliqli'),
 ('+7 (999) 123', false, '+ bilan boshlanuvchi'),
 ('90 123 45 67', false, '9 raqam guruhlangan'),
 ('901234567', false, '9 raqam'),
 ('123-45-67', false, 'uy raqami (7 raqam, 3 guruh)'),
 ('1234567', false, '7 ketma-ket raqam'),
 ('tel 12 34 56 78', false, '8 raqam 4 guruh'),
 ('(90) 123-45-67', false, 'qavsli raqam'),
 ('Youtube kanal', false, 'youtube'),
 ('ali dot com', true, 'so''z bilan yozilgan dot (filtr ushlamaydi — hujjatlangan cheklov)');
select pg_temp.check(private.student_card_text_ok(t) is not distinct from ok, 'text_ok: ' || why) from txtcases;

-- ------------------------------------------------- ruxsat
select pg_temp.as_anon();
select pg_temp.expect_error($q$select student_card_get_mine()$q$, 'anon get_mine rad');
select pg_temp.expect_error($q$select student_card_upsert('Anon Talaba')$q$, 'anon upsert rad');
select pg_temp.expect_error($q$select student_card_get('8e000000-0000-0000-0000-0000000000b1')$q$, 'anon get rad');
select pg_temp.expect_error($q$select student_cards_for_group('8e000000-0000-0000-0000-0000000000e1')$q$, 'anon for_group rad');
select pg_temp.expect_error($q$select student_card_delete()$q$, 'anon delete rad');
select pg_temp.expect_error($q$select student_card_hide_for_me('8e000000-0000-0000-0000-0000000000b1')$q$, 'anon hide_for_me rad');
select pg_temp.expect_error($q$select group_student_card_hide('8e000000-0000-0000-0000-0000000000e1', '8e000000-0000-0000-0000-0000000000b1')$q$, 'anon group_hide rad');
select pg_temp.expect_error($q$select admin_student_card_hide('8e000000-0000-0000-0000-0000000000b1')$q$, 'anon admin_hide rad');

-- ------------------------------------------------- validatsiya (s1: har qanday kirgan hisob, ustoz emas)
select pg_temp.as_user(:'s1');
select pg_temp.check(student_card_get_mine() = '{"ok": true, "card": null}'::jsonb, 'get_mine bo''sh');
select pg_temp.check(student_card_upsert('A')->>'error' = 'invalid_name', 'ism 1 belgi rad');
select pg_temp.check(student_card_upsert(repeat('a', 41))->>'error' = 'invalid_name', 'ism 41 belgi rad');
select pg_temp.check(student_card_upsert(repeat('a', 40))->>'ok' = 'true', 'ism 40 belgi qabul (talaba yozadi)');
select pg_temp.check(student_card_upsert('Al')->>'ok' = 'true', 'ism 2 belgi qabul');
select pg_temp.check(student_card_upsert(null)->>'error' = 'invalid_name', 'ism null rad');
select pg_temp.check(student_card_upsert(E'Is\x01m')->>'error' = 'invalid_name', 'ismda boshqaruv belgisi rad');
select pg_temp.check(student_card_upsert('Ism', repeat('b', 151))->>'error' = 'invalid_bio', 'bio 151 rad');
select pg_temp.check(student_card_upsert('Ism', repeat('b', 150))->>'ok' = 'true', 'bio 150 qabul');
select pg_temp.check(student_card_upsert('Ism', E'ikki\nqator')->>'ok' = 'true', 'bio ko''p qatorli');
select pg_temp.check(student_card_upsert('Ism', E'x\x07y')->>'error' = 'invalid_bio', 'bioda boshqaruv belgisi rad');
select pg_temp.check(student_card_upsert('Ism', '', '8e000000-0000-0000-0000-0000000000b2/photo-22222222-2222-4222-8222-222222222222.png')->>'error' = 'invalid_photo',
  'boshqa foydalanuvchi rasm yo''lini ishlatib bo''lmaydi');
select pg_temp.check(student_card_upsert('Ism', '', '8e000000-0000-0000-0000-0000000000b1/photo-44444444-4444-4444-8444-444444444444.jpg')->>'error' = 'invalid_photo',
  'storage''da yo''q rasm rad');
select pg_temp.check(student_card_upsert('Ism', '', '../8e000000-0000-0000-0000-0000000000b1/photo-11111111-1111-4111-8111-111111111111.jpg')->>'error' = 'invalid_photo',
  'yo''l hiylasi rad');
select pg_temp.check(student_card_upsert('Ism', '', '8e000000-0000-0000-0000-0000000000b1/logo-11111111-1111-4111-8111-111111111111.jpg')->>'error' = 'invalid_photo',
  'logo nomi rad (faqat photo-)');
-- aloqa ma'lumoti: ism va bio
select pg_temp.check(student_card_upsert('Ali t.me/ali')->>'error' = 'contact_info', 'ismda havola rad');
select pg_temp.check(student_card_upsert('Ali t.me/ali')->>'field' = 'name', 'contact_info field=name');
select pg_temp.check(student_card_upsert('Ali', 'yoz: @ali')->>'error' = 'contact_info', 'bioda @username rad');
select pg_temp.check(student_card_upsert('Ali', 'yoz: @ali')->>'field' = 'bio', 'contact_info field=bio');
select pg_temp.check(student_card_upsert('Ali', 'https://x.org')->>'error' = 'contact_info', 'bioda havola rad');
select pg_temp.check(student_card_upsert('Ali', 'tel +998 90 111 22 33')->>'error' = 'contact_info', 'bioda telefon rad');
select pg_temp.check(student_card_upsert('Ali', 'a@b.com')->>'error' = 'contact_info', 'bioda email rad');
select pg_temp.check(student_card_upsert('Ali', 'Instagram: ali')->>'error' = 'contact_info', 'bioda tarmoq nomi rad');
select pg_temp.check(student_card_upsert('Ali', 'Kimyo 2-kurs, 2024-2025')->>'ok' = 'true', 'oddiy bio qabul');

-- ------------------------------------------------- saqlash + rozilik (default O'CHIQ)
select student_card_upsert('Dilshod', 'Toksikologiya sevaman.',
  '8e000000-0000-0000-0000-0000000000b1/photo-11111111-1111-4111-8111-111111111111.jpg') as r \gset
select pg_temp.check(:'r'::jsonb->>'ok' = 'true', 'to''g''ri karta saqlandi');
select pg_temp.check((:'r'::jsonb->'card'->>'visible')::boolean = false, 'DEFAULT visible=false');
select pg_temp.check(:'r'::jsonb->'card'->>'consent_at' is null, 'rozilik yo''q (consent_at null)');
select pg_temp.check(:'r'::jsonb->'card'->>'photo_path' like '%/photo-1111%', 'photo_path saqlandi');
select pg_temp.check(not (:'r'::jsonb->'card' ? 'socials') and not (:'r'::jsonb->'card' ? 'workplace'),
  'havola/ijtimoiy tarmoq maydoni YO''Q');
select pg_temp.check((:'r'::jsonb->'card'->>'hidden_in_groups')::int = 0, 'egasi: hidden_in_groups=0');

-- visible=false: hech kim ko'rmaydi (ustoz ham, guruhdosh ham)
select pg_temp.as_user(:'t1');
select pg_temp.check(student_card_get(:'s1')->'card' = 'null'::jsonb, 'visible=false: ustoz ko''rmaydi (get)');
select pg_temp.check(student_cards_for_group(:'g1')->'cards' = '[]'::jsonb, 'visible=false: ustoz ko''rmaydi (for_group)');
select pg_temp.as_user(:'s2');
select pg_temp.check(student_card_get(:'s1')->'card' = 'null'::jsonb, 'visible=false: guruhdosh ko''rmaydi');
select pg_temp.check(student_cards_for_group(:'g1')->'cards' = '[]'::jsonb, 'visible=false: guruhdosh ko''rmaydi (for_group)');

-- yoqish (rozilik)
select pg_temp.as_user(:'s1');
select student_card_upsert('Dilshod', 'Toksikologiya sevaman.',
  '8e000000-0000-0000-0000-0000000000b1/photo-11111111-1111-4111-8111-111111111111.jpg', true) as r \gset
select pg_temp.check((:'r'::jsonb->'card'->>'visible')::boolean, 'visible=true saqlandi');
select pg_temp.check(:'r'::jsonb->'card'->>'consent_at' is not null, 'rozilik vaqti yozildi');
select student_card_get_mine()->'card'->>'consent_at' as c1 \gset
select pg_temp.check((select student_card_upsert('Dilshod K', '', null, true)->'card'->>'consent_at') = :'c1',
  'qayta saqlashda rozilik vaqti o''zgarmaydi');
select student_card_upsert('Dilshod', 'Toksikologiya sevaman.',
  '8e000000-0000-0000-0000-0000000000b1/photo-11111111-1111-4111-8111-111111111111.jpg', true) as r \gset

-- ------------------------------------------------- KO'RINISH MATRITSASI
-- (a) egasi: get(o'zi) = get_mine
select pg_temp.check(student_card_get(:'s1')->'card'->>'display_name' = 'Dilshod', 'egasi: get(o''zi) o''z kartasini beradi');
-- (b) guruh ustozi
select pg_temp.as_user(:'t1');
select student_card_get(:'s1') as v \gset
select pg_temp.check(:'v'::jsonb->'card'->>'display_name' = 'Dilshod', 'ustoz (g1) kartani ko''radi');
select pg_temp.check((:'v'::jsonb->'card'->>'group_hidden')::boolean = false, 'ustoz: group_hidden=false');
select pg_temp.check(student_cards_for_group(:'g1')->'cards'->0->>'student_id' = :'s1', 'ustoz: for_group ro''yxatda s1');
select pg_temp.check(jsonb_array_length(student_cards_for_group(:'g1')->'cards') = 1, 'ustoz: for_group 1 ta karta (s2 kartasi yo''q)');
select student_cards_for_group(:'g1')->'cards'->0->>'member_id' as mid \gset
reset role;
select pg_temp.check(:'mid' = (select id::text from class_group_members where group_id = :'g1' and user_id = :'s1'), 'ustoz: member_id a''zolik id si');
select pg_temp.as_user(:'t1');
-- (c) guruhdosh (s2, g1)
select pg_temp.as_user(:'s2');
select student_card_get(:'s1') as v \gset
select pg_temp.check(:'v'::jsonb->'card'->>'display_name' = 'Dilshod', 'guruhdosh kartani ko''radi');
select pg_temp.check((select array_agg(k order by k) from jsonb_object_keys(:'v'::jsonb->'card') k)
  = array['bio','display_name','photo_path','student_id','updated_at'], 'guruhdosh karta kalitlari aniq ro''yxat');
select pg_temp.check(:'v'::text not ilike '%secret.example%', 'email sizmaydi');
select pg_temp.check(student_cards_for_group(:'g1')->'cards'->0->>'display_name' = 'Dilshod', 'guruhdosh: for_group ko''radi');
select pg_temp.check(not (student_cards_for_group(:'g1')->'cards'->0 ? 'member_id'), 'guruhdosh javobida member_id yo''q');
select pg_temp.check(student_cards_for_group(:'g1') ->'hidden_ids' = '[]'::jsonb, 'hidden_ids bo''sh');
-- boshqa guruh a'zosi, ustozi, guruhsiz talaba, anon — ko'ra olmaydi
select pg_temp.as_user(:'s3');
select pg_temp.expect_42501($q$select student_card_get('8e000000-0000-0000-0000-0000000000b1')$q$, 'boshqa guruh talabasi: get 403');
select pg_temp.expect_42501($q$select student_cards_for_group('8e000000-0000-0000-0000-0000000000e1')$q$, 'boshqa guruh talabasi: for_group 403');
select pg_temp.as_user(:'t2');
select pg_temp.expect_42501($q$select student_card_get('8e000000-0000-0000-0000-0000000000b1')$q$, 'boshqa ustoz: get 403');
select pg_temp.expect_42501($q$select student_cards_for_group('8e000000-0000-0000-0000-0000000000e1')$q$, 'boshqa ustoz: for_group 403');
select pg_temp.as_user(:'s4');
select pg_temp.expect_42501($q$select student_card_get('8e000000-0000-0000-0000-0000000000b1')$q$, 'guruhsiz talaba: get 403');
select pg_temp.expect_42501($q$select student_cards_for_group('8e000000-0000-0000-0000-0000000000e1')$q$, 'guruhsiz talaba: for_group 403');
select pg_temp.expect_42501($q$select student_card_get(null)$q$, 'null id rad');
-- ikkinchi guruhning ustozi (t3, g2: s1 a'zo) ham ko'radi, g3 ustozi yo'q
select pg_temp.as_user(:'t3');
select pg_temp.check(student_card_get(:'s1')->'card'->>'display_name' = 'Dilshod', 'ustoz (g2) ham ko''radi');
-- jadvalga to'g'ridan-to'g'ri kirish yo'q
select pg_temp.as_user(:'s2');
select pg_temp.expect_42501($q$select * from public.student_cards$q$, 'jadvalni o''qib bo''lmaydi');
select pg_temp.expect_42501($q$insert into public.student_cards (user_id, display_name) values ('8e000000-0000-0000-0000-0000000000b2', 'Hack')$q$, 'jadvalga yozib bo''lmaydi');
select pg_temp.expect_42501($q$update public.student_cards set visible = true$q$, 'jadvalni yangilab bo''lmaydi');
select pg_temp.expect_42501($q$delete from public.student_cards$q$, 'jadvaldan o''chirib bo''lmaydi');
select pg_temp.expect_42501($q$select * from public.student_card_hides$q$, 'hides jadvalini o''qib bo''lmaydi');
select pg_temp.expect_42501($q$insert into public.student_card_hides (viewer_id, student_id) values ('8e000000-0000-0000-0000-0000000000b2', '8e000000-0000-0000-0000-0000000000b1')$q$, 'hides jadvaliga yozib bo''lmaydi');
select pg_temp.expect_42501($q$select * from public.student_card_group_hides$q$, 'group_hides jadvalini o''qib bo''lmaydi');
select pg_temp.expect_42501($q$insert into public.student_card_group_hides (group_id, student_id) values ('8e000000-0000-0000-0000-0000000000e1', '8e000000-0000-0000-0000-0000000000b1')$q$, 'group_hides jadvaliga yozib bo''lmaydi');
select pg_temp.expect_42501($q$select * from private.student_card_audit$q$, 'audit jadvalini o''qib bo''lmaydi');

-- guruhdan chiqqach ko'rish to'xtaydi
reset role;
delete from class_group_members where group_id = :'g1' and user_id = :'s2';
select pg_temp.as_user(:'s2');
select pg_temp.expect_42501($q$select student_card_get('8e000000-0000-0000-0000-0000000000b1')$q$, 'guruhdan chiqqach: 403');
reset role;
insert into class_group_members (group_id, user_id, nickname) values (:'g1', :'s2', 'Talaba Ikki');
-- talaba o'zi chiqsa, ustoz ham ko'rmaydi
delete from class_group_members where group_id = :'g1' and user_id = :'s1';
select pg_temp.as_user(:'t1');
select pg_temp.expect_42501($q$select student_card_get('8e000000-0000-0000-0000-0000000000b1')$q$, 'a''zo bo''lmagan talaba kartasi: ustoz 403');
reset role;
insert into class_group_members (group_id, user_id, nickname) values (:'g1', :'s1', 'Talaba Bir');

-- ------------------------------------------------- «o'zim uchun yashirish»
select pg_temp.as_user(:'s2');
select pg_temp.expect_42501($q$select student_card_hide_for_me('8e000000-0000-0000-0000-0000000000b2')$q$, 'o''zini yashirib bo''lmaydi');
select pg_temp.as_user(:'s3');
select pg_temp.expect_42501($q$select student_card_hide_for_me('8e000000-0000-0000-0000-0000000000b1')$q$, 'aloqasiz talaba hide_for_me chaqira olmaydi');
select pg_temp.as_user(:'s2');
select pg_temp.check(student_card_hide_for_me(:'s1')->>'ok' = 'true', 'guruhdosh kartani o''zi uchun yashirdi');
select pg_temp.check(student_card_get(:'s1')->'card' = 'null'::jsonb, 'yashirilgan karta guruhdoshga ko''rinmaydi (get)');
select pg_temp.check(student_card_get(:'s1')->>'hidden_by_me' = 'true', 'get: hidden_by_me=true');
select student_cards_for_group(:'g1') as v \gset
select pg_temp.check(:'v'::jsonb->'cards' = '[]'::jsonb, 'yashirilgan karta ro''yxatda yo''q');
select pg_temp.check(:'v'::jsonb->'hidden_ids' = jsonb_build_array(:'s1'), 'hidden_ids faqat id (mazmunsiz)');
select pg_temp.check(:'v'::text not ilike '%Dilshod%', 'yashirilgan kartaning ismi javobda yo''q');
-- boshqa ko'ruvchiga ta'sir qilmaydi
select pg_temp.as_user(:'t1');
select pg_temp.check(student_card_get(:'s1')->'card'->>'display_name' = 'Dilshod', 'boshqa ko''ruvchiga (ustoz) ta''sir qilmaydi');
select pg_temp.as_user(:'s6');
select pg_temp.check(student_card_get(:'s1')->'card'->>'display_name' = 'Dilshod', 'boshqa guruhdoshga (s6) ta''sir qilmaydi');
-- ustoz ham o'zi uchun yashira oladi
select pg_temp.as_user(:'t1');
select pg_temp.check(student_card_hide_for_me(:'s1')->>'ok' = 'true', 'ustoz o''zi uchun yashirdi');
select pg_temp.check(student_card_get(:'s1')->'card' = 'null'::jsonb, 'ustozga yashirilgan karta ko''rinmaydi');
select pg_temp.check(student_card_hide_for_me(:'s1', false)->>'ok' = 'true', 'ustoz qaytardi');
select pg_temp.check(student_card_get(:'s1')->'card'->>'display_name' = 'Dilshod', 'ustozga qaytdi');
-- storage ham yopiladi (yashirgan ko'ruvchiga)
select pg_temp.as_user(:'s2');
select pg_temp.check(not private.student_card_storage_read_ok('8e000000-0000-0000-0000-0000000000b1/photo-11111111-1111-4111-8111-111111111111.jpg'),
  'yashirilgan karta rasmi ham yopiq');
-- qaytarish
select pg_temp.check(student_card_hide_for_me(:'s1', false)->>'ok' = 'true', 'guruhdosh qaytardi');
select pg_temp.check(student_card_get(:'s1')->'card'->>'display_name' = 'Dilshod', 'qaytarilgach ko''rinadi');
select pg_temp.check(private.student_card_storage_read_ok('8e000000-0000-0000-0000-0000000000b1/photo-11111111-1111-4111-8111-111111111111.jpg'),
  'qaytarilgach rasm ochiq');
select pg_temp.check(student_card_hide_for_me(:'s1', false)->>'ok' = 'true', 'qayta qaytarish zararsiz');
select pg_temp.check(student_card_hide_for_me(:'s1')->>'ok' = 'true', 'yana yashirdi');
select pg_temp.check(student_card_hide_for_me(:'s1')->>'ok' = 'true', 'ikki marta yashirish zararsiz');
select pg_temp.check(student_card_hide_for_me(:'s1', false)->>'ok' = 'true', 'qaytardi');
-- 500 chegara
reset role;
insert into auth.users (id, email)
  select ('8f000000-0000-0000-0000-' || lpad(g::text, 12, '0'))::uuid, 'bulk' || g || '@secret.example'
  from generate_series(1, 500) g;
insert into student_card_hides (viewer_id, student_id)
  select :'s2', ('8f000000-0000-0000-0000-' || lpad(g::text, 12, '0'))::uuid from generate_series(1, 500) g;
select pg_temp.as_user(:'s2');
select pg_temp.check(student_card_hide_for_me(:'s1')->>'error' = 'limit', '501-yashirish rad (limit 500)');
reset role;
delete from auth.users where id::text like '8f000000-%';
select pg_temp.check((select count(*) = 0 from student_card_hides where viewer_id = :'s2'), 'yashirishlar hisob o''chirilganda cascade');

-- ------------------------------------------------- USTOZ moderatsiyasi (guruh bo'yicha)
select pg_temp.as_user(:'s2');
select pg_temp.expect_42501($q$select group_student_card_hide('8e000000-0000-0000-0000-0000000000e1', '8e000000-0000-0000-0000-0000000000b1')$q$, 'talaba group_hide chaqira olmaydi');
select pg_temp.as_user(:'t2');
select pg_temp.expect_42501($q$select group_student_card_hide('8e000000-0000-0000-0000-0000000000e1', '8e000000-0000-0000-0000-0000000000b1')$q$, 'boshqa ustoz group_hide chaqira olmaydi');
select pg_temp.as_user(:'t3');
select pg_temp.expect_42501($q$select group_student_card_hide('8e000000-0000-0000-0000-0000000000e1', '8e000000-0000-0000-0000-0000000000b1')$q$, 'g2 ustozi g1 uchun yashira olmaydi');
select pg_temp.as_user(:'t1');
select pg_temp.check(group_student_card_hide(:'g1', :'s3')->>'error' = 'not_found', 'a''zo bo''lmagan talaba: not_found');
select pg_temp.check(group_student_card_hide(:'g1', null)->>'error' = 'not_found', 'null talaba: not_found');
select pg_temp.check(group_student_card_hide(:'g1', :'s1', true, 'nomaqbul bio')->>'ok' = 'true', 'ustoz kartani guruhdan yashirdi');
select pg_temp.check(student_card_get(:'s1')->'card'->>'display_name' = 'Dilshod', 'ustoz moderator: yashirilgan kartani o''zi ko''radi');
select pg_temp.check((student_card_get(:'s1')->'card'->>'group_hidden')::boolean, 'ustoz: group_hidden=true');
select pg_temp.check((student_cards_for_group(:'g1')->'cards'->0->>'group_hidden')::boolean, 'ustoz ro''yxatida group_hidden=true');
select pg_temp.as_user(:'s2');
select pg_temp.check(student_card_get(:'s1')->'card' = 'null'::jsonb, 'g1 guruhdoshi (faqat g1 da) endi ko''rmaydi');
select pg_temp.check(student_cards_for_group(:'g1')->'cards' = '[]'::jsonb, 'g1 ro''yxatida yo''q');
select pg_temp.check(not private.student_card_storage_read_ok('8e000000-0000-0000-0000-0000000000b1/photo-11111111-1111-4111-8111-111111111111.jpg'),
  'guruhdan yashirilgan karta rasmi guruhdoshga yopiq');
select pg_temp.as_user(:'s6');
select pg_temp.check(student_card_get(:'s1')->'card'->>'display_name' = 'Dilshod', 'g2 guruhdoshi (boshqa umumiy guruh) hamon ko''radi');
select pg_temp.check(student_cards_for_group(:'g2')->'cards'->0->>'student_id' = :'s1', 'g2 ro''yxatida bor');
select pg_temp.as_user(:'t3');
select pg_temp.check((student_card_get(:'s1')->'card'->>'group_hidden')::boolean = false, 'g2 ustozi uchun group_hidden=false (g1 yashirishi uni qamramaydi)');
-- egasi qayta yoqa olmaydi, lekin bilib oladi
select pg_temp.as_user(:'s1');
select pg_temp.check(student_card_upsert('Dilshod', 'Toksikologiya sevaman.', null, true)->>'ok' = 'true', 'egasi saqlay oladi');
select pg_temp.check((student_card_get_mine()->'card'->>'hidden_in_groups')::int = 1, 'egasi: hidden_in_groups=1');
select pg_temp.check(student_card_get_mine()->'card'->>'visible' = 'true', 'egasi visible=true');
select pg_temp.expect_42501($q$select group_student_card_hide('8e000000-0000-0000-0000-0000000000e1', '8e000000-0000-0000-0000-0000000000b1', false)$q$, 'egasi group_hide(false) bilan qayta yoqa olmaydi');
select pg_temp.as_user(:'s2');
select pg_temp.check(student_card_get(:'s1')->'card' = 'null'::jsonb, 'egasi saqlagach ham guruhdoshga yopiq');
-- audit
reset role;
select pg_temp.check((select count(*) = 1 from private.student_card_audit where action = 'GROUP_HIDE'
  and actor_id = :'t1' and group_id = :'g1' and student_id = :'s1' and reason = 'nomaqbul bio'), 'GROUP_HIDE audit yozuvi');
-- qaytarish
select pg_temp.as_user(:'t1');
select pg_temp.check(group_student_card_hide(:'g1', :'s1', false)->>'ok' = 'true', 'ustoz qaytardi');
select pg_temp.as_user(:'s2');
select pg_temp.check(student_card_get(:'s1')->'card'->>'display_name' = 'Dilshod', 'qaytarilgach guruhdosh ko''radi');
reset role;
select pg_temp.check((select count(*) = 1 from private.student_card_audit where action = 'GROUP_UNHIDE'), 'GROUP_UNHIDE audit yozuvi');
-- guruh o'chsa group_hides cascade
insert into class_groups (id, teacher_id, name, code) values ('8e000000-0000-0000-0000-0000000000e9', :'t1', 'Vaqtinchalik', 'SCARDTMP');
insert into class_group_members (group_id, user_id, nickname) values ('8e000000-0000-0000-0000-0000000000e9', :'s1', 'Vaqt');
select pg_temp.as_user(:'t1');
select pg_temp.check(group_student_card_hide('8e000000-0000-0000-0000-0000000000e9', :'s1')->>'ok' = 'true', 'vaqtinchalik guruhda yashirildi');
reset role;
delete from class_groups where id = '8e000000-0000-0000-0000-0000000000e9';
select pg_temp.check((select count(*) = 0 from student_card_group_hides where group_id = '8e000000-0000-0000-0000-0000000000e9'), 'guruh o''chsa group_hides cascade');

-- ------------------------------------------------- admin yashirishi (UGC)
select pg_temp.as_user(:'s2');
select pg_temp.expect_error($q$select admin_student_card_hide('8e000000-0000-0000-0000-0000000000b1')$q$, 'talaba admin_hide chaqira olmaydi');
select pg_temp.as_user(:'t1');
select pg_temp.expect_error($q$select admin_student_card_hide('8e000000-0000-0000-0000-0000000000b1')$q$, 'ustoz admin_hide chaqira olmaydi');
select pg_temp.as_user(:'ad');
select pg_temp.check(admin_student_card_hide(:'s1', true, 'nomaqbul rasm')->>'found' = 'true', 'admin kartani yashirdi');
select pg_temp.as_user(:'s2');
select pg_temp.check(student_card_get(:'s1')->'card' = 'null'::jsonb, 'admin yashirgan: guruhdosh ko''rmaydi');
select pg_temp.as_user(:'t1');
select pg_temp.check(student_card_get(:'s1')->'card' = 'null'::jsonb, 'admin yashirgan: ustoz ko''rmaydi');
select pg_temp.as_user(:'s1');
select pg_temp.check(student_card_get_mine()->'card'->>'hidden_by_admin' = 'true', 'egasi: hidden_by_admin=true');
select pg_temp.check(student_card_upsert('Dilshod', '', null, true)->>'error' = 'hidden_by_admin', 'egasi admin yashirgan kartani qayta yoqa olmaydi');
select pg_temp.check(student_card_upsert('Dilshod', '', null, false)->>'ok' = 'true', 'egasi kartani yashirin holda tahrirlay oladi');
select pg_temp.as_user(:'ad');
select pg_temp.check(admin_student_card_hide(:'s1', false)->>'ok' = 'true', 'admin qaytardi');
reset role;
select pg_temp.check((select count(*) = 2 from private.admin_audit
  where action in ('STUDENT_CARD_HIDE', 'STUDENT_CARD_UNHIDE') and target_id = :'s1'), 'admin amallari audit log''da');
select pg_temp.check((select visible = false from public.student_cards where user_id = :'s1'),
  'unhide kartani avtomatik yoqmaydi (egasi qayta rozilik beradi)');
select pg_temp.as_user(:'s1');
select student_card_upsert('Dilshod', 'Qayta yoqildi', '8e000000-0000-0000-0000-0000000000b1/photo-11111111-1111-4111-8111-111111111111.jpg', true) as r \gset
select pg_temp.as_user(:'s2');
select pg_temp.check(student_card_get(:'s1')->'card'->>'bio' = 'Qayta yoqildi', 'qayta yoqilgach guruhdosh ko''radi');

-- ------------------------------------------------- o'chirish + cascade
select pg_temp.as_user(:'s2');
select student_card_upsert('Ikkinchi', '', '8e000000-0000-0000-0000-0000000000b2/photo-22222222-2222-4222-8222-222222222222.png', true) as r \gset
select pg_temp.check(:'r'::jsonb->>'ok' = 'true', 's2 kartasi saqlandi');
select student_card_hide_for_me(:'s1') as r \gset
select pg_temp.as_user(:'t1');
select group_student_card_hide(:'g1', :'s1') as r \gset
select pg_temp.as_user(:'s1');
select student_card_delete() as d \gset
select pg_temp.check(:'d'::jsonb->>'deleted' = 'true', 'delete: o''chirildi');
select pg_temp.check(:'d'::jsonb->>'photo_path' like '%/photo-1111%', 'delete: photo_path qaytadi (ilova Storage''dan o''chiradi)');
select pg_temp.check(student_card_delete()->>'deleted' = 'false', 'delete: qayta chaqirish zararsiz');
select pg_temp.check(student_card_get_mine()->'card' = 'null'::jsonb, 'delete: karta yo''q');
reset role;
select pg_temp.check((select count(*) = 1 from public.student_cards where user_id = :'s2'), 's2 kartasi turibdi');
-- hisob o'chsa hamma narsa ketadi (karta, yashirishlar, guruh yashirishlari)
select pg_temp.check((select count(*) = 1 from student_card_hides where student_id = :'s1'), 'alohida: s2 -> s1 yashirish bor');
delete from auth.users where id = :'s1';
select pg_temp.check((select count(*) = 0 from student_card_hides where student_id = :'s1' or viewer_id = :'s1'), 'hisob o''chsa hides cascade');
select pg_temp.check((select count(*) = 0 from student_card_group_hides where student_id = :'s1'), 'hisob o''chsa group_hides cascade');
delete from auth.users where id = :'s2';
select pg_temp.check((select count(*) = 0 from public.student_cards), 'hisob o''chsa karta cascade bilan o''chadi');

-- ------------------------------------------------- bucket sozlamalari
select pg_temp.check((select not public and file_size_limit = 1048576
  and allowed_mime_types = array['image/jpeg', 'image/png', 'image/webp']
  from storage.buckets where id = 'student-cards'), 'bucket: xususiy, 1 MB, jpeg/png/webp');
select pg_temp.check((select count(*) = 3 from pg_policies where schemaname = 'storage'
  and tablename = 'objects' and policyname like 'student_cards_%'), 'storage: 3 siyosat (yozish/o''qish/o''chirish)');
select pg_temp.check(not exists (select 1 from pg_policies where schemaname = 'storage'
  and policyname like 'student_cards_%' and (roles::text like '%anon%' or roles::text like '%public%')),
  'storage: anon siyosati yo''q');
select 'ALL STUDENT CARD TESTS PASSED' as result;
