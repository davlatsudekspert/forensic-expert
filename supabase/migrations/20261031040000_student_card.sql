-- FORENSIC EXPERT — «Talaba kartasi» (egasi qarori, 2026-10-31, 1-bosqich).
--
-- Talaba (har qanday kirgan hisob) ixtiyoriy ravishda taxallus/ism, qisqa
-- «o'zim haqimda» va rasm kiritadi. Karta FAQAT guruh doirasida ko'rinadi:
-- yoqish, layk yo'q, obuna yo'q, ommaviy ko'rinish yo'q, HAVOLA YO'Q
-- (talabalar voyaga yetmagan bo'lishi mumkin).
--
-- Ko'rinish qoidasi (private.student_card_visible_to). Karta ko'ruvchiga
-- ko'rinadi FAQAT agar: visible = true VA admin yashirmagan VA ko'ruvchi
-- uni o'zi uchun yashirmagan (student_card_hides) VA ko'ruvchi:
--   (a) egasi (o'z kartasini student_card_get_mine orqali ko'radi), YOKI
--   (b) talaba a'zo bo'lgan guruhning USTOZI (ustoz moderator: guruhdan
--       yashirilgan kartani ham ko'radi va qaytara oladi), YOKI
--   (c) talaba bilan kamida bitta umumiy guruhdagi boshqa a'zo, va shu
--       guruhda karta ustoz tomonidan yashirilmagan (student_card_group_hides).
-- Boshqa hech kimga (guruhdan tashqari talabalar, anon, boshqa ustozlar).
--
-- Moderatsiya (Apple 1.2 / Google UGC):
--   * SERVER MATN FILTRI (private.student_card_text_ok): ism va bio'da
--     havola (http, www, domen, t.me), @username/email, telefon raqami va
--     ijtimoiy tarmoq nomlari RAD ETILADI ({ok:false, error:'contact_info'});
--     boshqaruv belgilari va uzunlik chegarasi alohida.
--   * Shikoyat: ilova mavjud support oqimiga yuboradi (related_entity =
--     student_card:<uid>), yangi backend kerak emas.
--   * Bloklash/yashirish: student_card_hide_for_me (har bir ko'ruvchi o'zi
--     uchun) — yashirilgan karta unga HECH QACHON ko'rinmaydi; qaytarish bor.
--   * Ustoz moderatsiyasi: group_student_card_hide (faqat guruh ustozi,
--     audit yozuvi private.student_card_audit'da); egasi buni qayta yoqa olmaydi.
--   * Admin: admin_student_card_hide (identity_admin, audit log), egasi
--     o'zi qayta yoqa olmaydi.
--   * Hisob o'chirilsa hamma narsa ON DELETE CASCADE bilan o'chadi; Storage
--     obyektlari delete-account Edge Function'da o'chiriladi.
--
-- Xavfsizlik uslubi ustoz kartasi bilan bir xil: RLS yoqilgan, jadvallarga
-- huquq YO'Q, hammasi SECURITY DEFINER (search_path = '') RPC; xususiy bucket
-- + Storage RLS (imzolangan/ommaviy URL yo'q).
--
-- Bu fayl ADDITIV. Production'ga faqat egasi qo'llaydi.
-- ROLLBACK: supabase/rollback/20261031040000_student_card_down.sql

-- ---------------------------------------------------------------- jadvallar
create table public.student_cards (
  user_id uuid primary key references auth.users (id) on delete cascade,
  display_name text not null check (char_length(display_name) between 2 and 40),
  bio text not null default '' check (char_length(bio) <= 150),
  photo_path text check (photo_path is null or char_length(photo_path) <= 120),
  visible boolean not null default false,
  consent_at timestamptz,
  hidden_by_admin boolean not null default false,
  updated_at timestamptz not null default now()
);
alter table public.student_cards enable row level security;
create policy student_cards_self_read on public.student_cards
  for select using (user_id = auth.uid());

-- Ko'ruvchi boshqa talabaning kartasini o'zi uchun yashiradi.
create table public.student_card_hides (
  viewer_id uuid not null references auth.users (id) on delete cascade,
  student_id uuid not null references auth.users (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (viewer_id, student_id),
  check (viewer_id <> student_id)
);
alter table public.student_card_hides enable row level security;
create policy student_card_hides_self_read on public.student_card_hides
  for select using (viewer_id = auth.uid());

-- Guruh ustozi kartani shu guruh a'zolaridan yashiradi.
create table public.student_card_group_hides (
  group_id uuid not null references public.class_groups (id) on delete cascade,
  student_id uuid not null references auth.users (id) on delete cascade,
  hidden_by uuid references auth.users (id) on delete set null,
  reason text not null default '' check (char_length(reason) <= 300),
  created_at timestamptz not null default now(),
  primary key (group_id, student_id)
);
alter table public.student_card_group_hides enable row level security;

-- Ustoz moderatsiyasi jurnali (faqat qo'shiladi; hech kimga ochiq emas).
create table private.student_card_audit (
  id bigint generated always as identity primary key,
  actor_id uuid references auth.users (id) on delete set null,
  action text not null check (action in ('GROUP_HIDE', 'GROUP_UNHIDE')),
  group_id uuid,
  student_id uuid,
  reason text not null default '' check (char_length(reason) <= 300),
  created_at timestamptz not null default now()
);
alter table private.student_card_audit enable row level security;

-- ---------------------------------------------------------------- yordamchilar

-- Maxfiy aloqa ma'lumoti filtri (ism va bio uchun). Rad etiladi: havola
-- (http, ://, www, domen oxiri, t.me), @ (email / @username), ijtimoiy
-- tarmoq/messenjer nomlari va telefon raqami (7+ raqam, +raqam, 9+ raqamli
-- guruhlar). Sodda filtr: "nol to'qqiz nol" kabi so'z bilan yozilgan raqamni
-- ushlay olmaydi — qolgan himoya: shikoyat, yashirish, ustoz/admin moderatsiyasi.
create function private.student_card_text_ok(p_text text) returns boolean
language plpgsql immutable set search_path = '' as $$
declare
  t text := lower(coalesce(p_text, ''));
  m text[];
  digits text;
  ngroups int;
begin
  if t = '' then return true; end if;
  if t ~ '[@＠]' then return false; end if;
  if t ~ 'http|://|\ywww\y|www\.' then return false; end if;
  if t ~ '[a-z0-9-]\s?\.\s?(com|net|org|uz|ru|me|io|ly|tv|gg|info|biz|xyz|app|dev|co|kz|tj|kg|edu|gov|by|ua|link|site|online|store|shop|page)\y' then
    return false;
  end if;
  if t ~ 'telegram|instagram|whatsapp|tiktok|snapchat|facebook|youtube|телеграм|инстаграм|ватсап|вацап|вайбер|фейсбук|тикток|ютуб|\y(insta|viber|discord|wechat|skype|snap|tg|t\.me)\y' then
    return false;
  end if;
  if t ~ '\+\s*\(?\s*[0-9]' then return false; end if;
  for m in select regexp_matches(t, '[0-9][0-9 ().-]*[0-9]', 'g') loop
    digits := regexp_replace(m[1], '[^0-9]', '', 'g');
    ngroups := coalesce(array_length(regexp_split_to_array(btrim(m[1]), '[^0-9]+'), 1), 1);
    if char_length(digits) >= 9 or (char_length(digits) >= 7 and ngroups <> 2) then
      return false;
    end if;
  end loop;
  return true;
end $$;

-- Rasm yo'li: <uid>/photo-<uuid>.<jpg|png|webp> va bucket'da mavjud.
create function private.student_card_path_ok(p_uid uuid, p_path text)
returns boolean language sql stable security definer set search_path = '' as $$
  select p_path ~ ('^' || p_uid::text
      || '/photo-[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\.(jpg|png|webp)$')
    and exists (select 1 from storage.objects o
                where o.bucket_id = 'student-cards' and o.name = p_path)
$$;

-- p_viewer — p_student a'zo bo'lgan guruhlardan birining USTOZI.
create function private.student_card_teacher_of(p_viewer uuid, p_student uuid)
returns boolean language sql stable security definer set search_path = '' as $$
  select p_viewer is not null and exists (
    select 1 from public.class_group_members m
    join public.class_groups g on g.id = m.group_id
    where m.user_id = p_student and g.teacher_id = p_viewer)
$$;

-- p_viewer va p_student umumiy guruhda a'zo va karta u guruhda ustoz
-- tomonidan yashirilmagan.
create function private.student_card_groupmate(p_viewer uuid, p_student uuid)
returns boolean language sql stable security definer set search_path = '' as $$
  select p_viewer is not null and p_viewer <> p_student and exists (
    select 1 from public.class_group_members a
    join public.class_group_members b on b.group_id = a.group_id
    where a.user_id = p_student and b.user_id = p_viewer
      and not exists (select 1 from public.student_card_group_hides x
                      where x.group_id = a.group_id and x.student_id = p_student))
$$;

-- Aloqa bor (ustoz yoki umumiy guruh), yashirishlarga qaramasdan.
create function private.student_card_related(p_viewer uuid, p_student uuid)
returns boolean language sql stable security definer set search_path = '' as $$
  select p_viewer is not null and p_viewer <> p_student and (
    private.student_card_teacher_of(p_viewer, p_student) or exists (
      select 1 from public.class_group_members a
      join public.class_group_members b on b.group_id = a.group_id
      where a.user_id = p_student and b.user_id = p_viewer))
$$;

-- Karta holati (egasi tomonidan ochilgan, admin yashirmagan).
create function private.student_card_public(c public.student_cards) returns boolean
language sql immutable set search_path = '' as $$
  select c.visible and not c.hidden_by_admin
$$;

create function private.student_card_hidden_by(p_viewer uuid, p_student uuid)
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (select 1 from public.student_card_hides h
                 where h.viewer_id = p_viewer and h.student_id = p_student)
$$;

-- Egasidan boshqa ko'ruvchi uchun to'liq qoida.
create function private.student_card_visible_to(p_viewer uuid, c public.student_cards)
returns boolean language sql stable security definer set search_path = '' as $$
  select p_viewer is not null and p_viewer <> c.user_id
    and private.student_card_public(c)
    and not private.student_card_hidden_by(p_viewer, c.user_id)
    and (private.student_card_teacher_of(p_viewer, c.user_id)
         or private.student_card_groupmate(p_viewer, c.user_id))
$$;

-- p_mode: 'owner' (rozilik holati bilan), 'teacher' (guruhdan yashirilganlik
-- belgisi bilan), boshqa — oddiy ko'ruvchi.
create function private.student_card_json(c public.student_cards, p_mode text,
  p_group_hidden boolean default false)
returns jsonb language sql stable security definer set search_path = '' as $$
  select jsonb_build_object(
    'student_id', c.user_id,
    'display_name', c.display_name,
    'bio', c.bio,
    'photo_path', c.photo_path,
    'updated_at', c.updated_at)
  || case when p_mode = 'owner' then jsonb_build_object(
       'visible', c.visible, 'hidden_by_admin', c.hidden_by_admin,
       'consent_at', c.consent_at,
       'hidden_in_groups', (select count(*) from public.student_card_group_hides x
                            where x.student_id = c.user_id))
     when p_mode = 'teacher' then jsonb_build_object('group_hidden', p_group_hidden)
     else '{}'::jsonb end
$$;

-- Storage siyosatlari (auth.uid() bilan; parametr orqali boshqa nomdan so'rab
-- bo'lmaydi).
create function private.student_card_storage_write_ok(p_name text)
returns boolean language plpgsql stable security definer set search_path = '' as $$
declare me uuid := auth.uid();
begin
  if me is null then return false; end if;
  if p_name !~ ('^' || me::text
      || '/photo-[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\.(jpg|png|webp)$') then
    return false;
  end if;
  -- Spamga qarshi: bitta foydalanuvchida ko'pi bilan 4 ta obyekt.
  return (select count(*) from storage.objects o
          where o.bucket_id = 'student-cards'
            and (storage.foldername(o.name))[1] = me::text) < 4;
end $$;

create function private.student_card_storage_read_ok(p_name text)
returns boolean language plpgsql stable security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  v_folder text := (storage.foldername(p_name))[1];
  c public.student_cards;
begin
  if me is null or v_folder is null then return false; end if;
  if v_folder = me::text then return true; end if;
  if v_folder !~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$' then
    return false;
  end if;
  select * into c from public.student_cards x where x.user_id = v_folder::uuid;
  if not found then return false; end if;
  -- Faqat kartadagi joriy rasm o'qiladi.
  if p_name is distinct from c.photo_path then return false; end if;
  return private.student_card_visible_to(me, c);
end $$;

-- ---------------------------------------------------------------- egasi RPC

create function public.student_card_get_mine() returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  c public.student_cards;
begin
  if me is null then raise exception 'forbidden' using errcode = '42501'; end if;
  select * into c from public.student_cards x where x.user_id = me;
  if not found then return jsonb_build_object('ok', true, 'card', null); end if;
  return jsonb_build_object('ok', true, 'card', private.student_card_json(c, 'owner'));
end $$;

-- Yaratish / yangilash (har qanday kirgan hisob). Xatolar {ok:false, error,
-- field?}: invalid_name | invalid_bio | invalid_photo |
-- contact_info (field = name|bio) | hidden_by_admin.
create function public.student_card_upsert(
  p_display_name text,
  p_bio text default '',
  p_photo_path text default null,
  p_visible boolean default false
) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  v_name text := btrim(coalesce(p_display_name, ''));
  v_bio text := btrim(coalesce(p_bio, ''));
  v_photo text := nullif(btrim(coalesce(p_photo_path, '')), '');
  v_vis boolean := coalesce(p_visible, false);
  old public.student_cards;
  v_row public.student_cards;
begin
  if me is null then raise exception 'forbidden' using errcode = '42501'; end if;
  if char_length(v_name) not between 2 and 40 or v_name ~ E'[\\x01-\\x1f\\x7f]' then
    return jsonb_build_object('ok', false, 'error', 'invalid_name');
  end if;
  if char_length(v_bio) > 150 or v_bio ~ E'[\\x01-\\x09\\x0b-\\x1f\\x7f]' then
    return jsonb_build_object('ok', false, 'error', 'invalid_bio');
  end if;
  if v_photo is not null and not private.student_card_path_ok(me, v_photo) then
    return jsonb_build_object('ok', false, 'error', 'invalid_photo');
  end if;
  if not private.student_card_text_ok(v_name) then
    return jsonb_build_object('ok', false, 'error', 'contact_info', 'field', 'name');
  end if;
  if not private.student_card_text_ok(v_bio) then
    return jsonb_build_object('ok', false, 'error', 'contact_info', 'field', 'bio');
  end if;
  select * into old from public.student_cards x where x.user_id = me for update;
  if v_vis and found and old.hidden_by_admin then
    return jsonb_build_object('ok', false, 'error', 'hidden_by_admin');
  end if;
  insert into public.student_cards as t (user_id, display_name, bio, photo_path,
    visible, consent_at, updated_at)
  values (me, v_name, v_bio, v_photo, v_vis, case when v_vis then now() end, now())
  on conflict (user_id) do update set
    display_name = excluded.display_name, bio = excluded.bio,
    photo_path = excluded.photo_path, visible = excluded.visible,
    consent_at = case when excluded.visible and not t.visible then now()
                      when excluded.visible then coalesce(t.consent_at, now())
                      else null end,
    updated_at = now()
  returning * into v_row;
  return jsonb_build_object('ok', true, 'card', private.student_card_json(v_row, 'owner'));
end $$;

create function public.student_card_delete() returns jsonb
language plpgsql security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  c public.student_cards;
begin
  if me is null then raise exception 'forbidden' using errcode = '42501'; end if;
  delete from public.student_cards x where x.user_id = me returning * into c;
  return jsonb_build_object('ok', true, 'deleted', c.user_id is not null,
    'photo_path', c.photo_path);
end $$;

-- ---------------------------------------------------------------- ko'ruvchi RPC

-- Bitta karta (ustoz guruh a'zosiniki yoki umumiy guruh a'zosi). Aloqa yo'q —
-- 42501. Karta yo'q/yashirin/yashirilgan — {ok:true, card:null}; ko'ruvchi
-- o'zi yashirgan bo'lsa hidden_by_me:true (kartaning o'zi berilmaydi).
create function public.student_card_get(p_student uuid) returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  c public.student_cards;
begin
  if me is null then raise exception 'forbidden' using errcode = '42501'; end if;
  if p_student is null then raise exception 'forbidden' using errcode = '42501'; end if;
  if p_student = me then
    return public.student_card_get_mine();
  end if;
  if not private.student_card_related(me, p_student) then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  select * into c from public.student_cards x where x.user_id = p_student;
  if not found or not private.student_card_public(c) then
    return jsonb_build_object('ok', true, 'card', null);
  end if;
  if private.student_card_hidden_by(me, p_student) then
    return jsonb_build_object('ok', true, 'card', null, 'hidden_by_me', true);
  end if;
  if not private.student_card_visible_to(me, c) then
    return jsonb_build_object('ok', true, 'card', null);
  end if;
  return jsonb_build_object('ok', true, 'card', private.student_card_json(c,
    case when private.student_card_teacher_of(me, p_student) then 'teacher' else 'viewer' end,
    exists (select 1 from public.student_card_group_hides x
            join public.class_groups g on g.id = x.group_id
            where x.student_id = p_student and g.teacher_id = me)));
end $$;

-- Guruh sahifasi: shu guruh a'zolarining ko'rinadigan kartalari (ko'pi bilan
-- 200). Faqat guruh a'zosi yoki ustozi (aks holda 42501). Ustoz guruhdan
-- yashirilgan kartalarni ham ko'radi (group_hidden:true) — qaytarish uchun —
-- va har kartada member_id (class_group_members.id: ustoz a'zolar ro'yxati
-- bilan moslashtiradi); talabaga member_id berilmaydi.
-- hidden_ids — ko'ruvchi o'zi yashirgan (aks holda ko'rinadigan) kartalar
-- egalarining id lari: ilova ularni «Yashirilgan karta · Qaytarish» deb
-- ko'rsatadi; ularning mazmuni berilmaydi.
create function public.student_cards_for_group(p_group uuid) returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  g public.class_groups;
  v_teacher boolean;
  v_cards jsonb;
  v_hidden jsonb;
begin
  if me is null then raise exception 'forbidden' using errcode = '42501'; end if;
  select * into g from public.class_groups x where x.id = p_group;
  v_teacher := found and g.teacher_id = me;
  if not found or not (v_teacher or exists (
      select 1 from public.class_group_members m
      where m.group_id = g.id and m.user_id = me)) then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  with eligible as (
    select c.*, m.id as member_id,
           exists (select 1 from public.student_card_group_hides x
                   where x.group_id = g.id and x.student_id = c.user_id) as ghid
      from public.student_cards c
      join public.class_group_members m on m.user_id = c.user_id and m.group_id = g.id
     where c.user_id <> me and private.student_card_public(c)
       and (v_teacher or not exists (select 1 from public.student_card_group_hides x
                                     where x.group_id = g.id and x.student_id = c.user_id))
  ), shown as (
    select * from eligible e
     where not private.student_card_hidden_by(me, e.user_id)
     order by lower(e.display_name), e.user_id limit 200
  )
  select coalesce((select jsonb_agg(private.student_card_json(
            (select x from public.student_cards x where x.user_id = s.user_id),
            case when v_teacher then 'teacher' else 'viewer' end, s.ghid)
            || case when v_teacher then jsonb_build_object('member_id', s.member_id)
                    else '{}'::jsonb end
            order by lower(s.display_name), s.user_id) from shown s), '[]'::jsonb),
         coalesce((select jsonb_agg(e.user_id order by e.user_id) from eligible e
                   where private.student_card_hidden_by(me, e.user_id)), '[]'::jsonb)
    into v_cards, v_hidden;
  return jsonb_build_object('ok', true, 'cards', v_cards, 'hidden_ids', v_hidden);
end $$;

-- Ko'ruvchi kartani o'zi uchun yashiradi / qaytaradi. Yashirish uchun aloqa
-- (ustoz yoki umumiy guruh) kerak, aks holda 42501; qaytarish har doim
-- mumkin. Bitta ko'ruvchida ko'pi bilan 500 ta yashirish.
create function public.student_card_hide_for_me(p_student uuid,
  p_hide boolean default true) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare me uuid := auth.uid();
begin
  if me is null or p_student is null or p_student = me then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  if coalesce(p_hide, true) then
    if not private.student_card_related(me, p_student) then
      raise exception 'forbidden' using errcode = '42501';
    end if;
    if (select count(*) from public.student_card_hides h where h.viewer_id = me) >= 500 then
      return jsonb_build_object('ok', false, 'error', 'limit');
    end if;
    insert into public.student_card_hides (viewer_id, student_id)
    values (me, p_student) on conflict do nothing;
  else
    delete from public.student_card_hides h
     where h.viewer_id = me and h.student_id = p_student;
  end if;
  return jsonb_build_object('ok', true);
end $$;

-- ---------------------------------------------------------------- moderatsiya

-- Guruh ustozi a'zo kartasini shu guruh uchun yashiradi / qaytaradi. Faqat
-- guruh egasi (aks holda 42501); talaba shu guruh a'zosi bo'lishi shart
-- ({ok:false, error:'not_found'}). Audit: private.student_card_audit.
-- Karta egasi buni o'zi qayta yoqa olmaydi (unga RPC yo'q).
create function public.group_student_card_hide(p_group uuid, p_student uuid,
  p_hide boolean default true, p_reason text default null) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  g public.class_groups;
  v_hide boolean := coalesce(p_hide, true);
  v_reason text := left(btrim(coalesce(p_reason, '')), 300);
begin
  if me is null then raise exception 'forbidden' using errcode = '42501'; end if;
  select * into g from public.class_groups x where x.id = p_group;
  if not found or g.teacher_id <> me then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  if p_student is null or not exists (select 1 from public.class_group_members m
      where m.group_id = g.id and m.user_id = p_student) then
    return jsonb_build_object('ok', false, 'error', 'not_found');
  end if;
  if v_hide then
    insert into public.student_card_group_hides (group_id, student_id, hidden_by, reason)
    values (g.id, p_student, me, v_reason)
    on conflict (group_id, student_id) do update
      set hidden_by = me, reason = excluded.reason, created_at = now();
  else
    delete from public.student_card_group_hides x
     where x.group_id = g.id and x.student_id = p_student;
  end if;
  insert into private.student_card_audit (actor_id, action, group_id, student_id, reason)
  values (me, case when v_hide then 'GROUP_HIDE' else 'GROUP_UNHIDE' end,
          g.id, p_student, v_reason);
  return jsonb_build_object('ok', true);
end $$;

-- Shikoyat bo'yicha admin kartani butunlay yashiradi / qaytaradi.
create function public.admin_student_card_hide(p_student uuid,
  p_hide boolean default true, p_reason text default null) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare
  me uuid := private.admin_guard();
  n int;
begin
  update public.student_cards
     set hidden_by_admin = coalesce(p_hide, true),
         visible = case when coalesce(p_hide, true) then false else visible end,
         updated_at = now()
   where user_id = p_student;
  get diagnostics n = row_count;
  perform private.admin_log(me,
    case when coalesce(p_hide, true) then 'STUDENT_CARD_HIDE' else 'STUDENT_CARD_UNHIDE' end,
    'student_card', p_student::text,
    jsonb_build_object('reason', left(coalesce(p_reason, ''), 300), 'found', n > 0));
  return jsonb_build_object('ok', true, 'found', n > 0);
end $$;

-- ---------------------------------------------------------------- storage
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('student-cards', 'student-cards', false, 1048576,
        array['image/jpeg', 'image/png', 'image/webp'])
on conflict (id) do update set public = false, file_size_limit = 1048576,
  allowed_mime_types = array['image/jpeg', 'image/png', 'image/webp'];

drop policy if exists student_cards_owner_upload on storage.objects;
create policy student_cards_owner_upload on storage.objects
  for insert to authenticated
  with check (bucket_id = 'student-cards'
    and private.student_card_storage_write_ok(name));
drop policy if exists student_cards_read on storage.objects;
create policy student_cards_read on storage.objects
  for select to authenticated
  using (bucket_id = 'student-cards'
    and private.student_card_storage_read_ok(name));
drop policy if exists student_cards_owner_delete on storage.objects;
create policy student_cards_owner_delete on storage.objects
  for delete to authenticated
  using (bucket_id = 'student-cards'
    and (storage.foldername(name))[1] = auth.uid()::text);
-- update siyosati YO'Q: fayl nomlari o'zgarmas (yangi rasm — yangi nom).

-- ---------------------------------------------------------------- huquqlar
revoke all on public.student_cards from anon, authenticated;
revoke all on public.student_card_hides from anon, authenticated;
revoke all on public.student_card_group_hides from anon, authenticated;
revoke all on private.student_card_audit from anon, authenticated;

revoke execute on function private.student_card_text_ok(text) from public, anon, authenticated;
revoke execute on function private.student_card_path_ok(uuid, text) from public, anon, authenticated;
revoke execute on function private.student_card_teacher_of(uuid, uuid) from public, anon, authenticated;
revoke execute on function private.student_card_groupmate(uuid, uuid) from public, anon, authenticated;
revoke execute on function private.student_card_related(uuid, uuid) from public, anon, authenticated;
revoke execute on function private.student_card_public(public.student_cards) from public, anon, authenticated;
revoke execute on function private.student_card_hidden_by(uuid, uuid) from public, anon, authenticated;
revoke execute on function private.student_card_visible_to(uuid, public.student_cards) from public, anon, authenticated;
revoke execute on function private.student_card_json(public.student_cards, text, boolean) from public, anon, authenticated;
revoke execute on function private.student_card_storage_write_ok(text) from public, anon;
revoke execute on function private.student_card_storage_read_ok(text) from public, anon;
grant execute on function private.student_card_storage_write_ok(text) to authenticated;
grant execute on function private.student_card_storage_read_ok(text) to authenticated;

revoke execute on function public.student_card_get_mine() from public, anon;
revoke execute on function public.student_card_upsert(text, text, text, boolean) from public, anon;
revoke execute on function public.student_card_delete() from public, anon;
revoke execute on function public.student_card_get(uuid) from public, anon;
revoke execute on function public.student_cards_for_group(uuid) from public, anon;
revoke execute on function public.student_card_hide_for_me(uuid, boolean) from public, anon;
revoke execute on function public.group_student_card_hide(uuid, uuid, boolean, text) from public, anon;
revoke execute on function public.admin_student_card_hide(uuid, boolean, text) from public, anon;
grant execute on function public.student_card_get_mine() to authenticated;
grant execute on function public.student_card_upsert(text, text, text, boolean) to authenticated;
grant execute on function public.student_card_delete() to authenticated;
grant execute on function public.student_card_get(uuid) to authenticated;
grant execute on function public.student_cards_for_group(uuid) to authenticated;
grant execute on function public.student_card_hide_for_me(uuid, boolean) to authenticated;
grant execute on function public.group_student_card_hide(uuid, uuid, boolean, text) to authenticated;
grant execute on function public.admin_student_card_hide(uuid, boolean, text) to authenticated;
