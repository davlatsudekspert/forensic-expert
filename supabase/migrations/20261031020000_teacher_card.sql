-- FORENSIC EXPERT — «Ustoz kartasi» (egasi talabi, 2026-10-31).
--
-- Ustoz o'z profilida rasm, ism, ish joyi (+ logotip), qisqa «o'zim haqimda»
-- va ijtimoiy tarmoq havolalarini kiritadi; karta FAQAT ustozning o'z
-- guruhlari a'zolariga ko'rinadi (talabalar guruh sahifasida ko'radi).
--
-- Model (class_groups bilan bir xil):
--   * public.teacher_cards: RLS yoqilgan, anon/authenticated'ga jadval huquqi
--     YO'Q. Hamma narsa SECURITY DEFINER (search_path = '') RPC orqali.
--   * visible DEFAULT false: ustoz rozilik matni bilan «Talabalarimga
--     ko'rsatish»ni yoqmaguncha hech kim (hatto guruh a'zosi ham) ko'rmaydi.
--     Rozilik vaqti consent_at'da saqlanadi.
--   * Havola validatsiyasi SERVERDA (private.teacher_card_url_ok): faqat https,
--     har tarmoq uchun o'z domeni (t.me/telegram.me, instagram.com,
--     youtube.com/youtu.be, facebook.com, linkedin.com, tiktok.com; «website»
--     — istalgan https domen, 255 belgigacha). javascript:, data:, http:,
--     userinfo (user@host), port, IP va noma'lum domenlar rad etiladi.
--   * Rasm/logotip — xususiy `teacher-cards` bucket (1 MB, jpeg/png/webp),
--     yo'l `<uid>/(photo|logo)-<uuid>.<ext>`. Yozish: faqat egasi (ustoz roli,
--     o'z papkasiga, ko'pi bilan 8 obyekt). O'qish: egasi YOKI kartasi
--     ko'rinadigan (visible, admin yashirmagan) ustozning guruhi a'zosi —
--     Storage RLS siyosati orqali; imzolangan URL yoki ommaviy bucket YO'Q
--     (karta yashirilsa yoki talaba guruhdan chiqsa, rasmga kirish darhol
--     to'xtaydi). Eski rasmni egasi o'zi o'chiradi (delete siyosati).
--   * UGC (Apple 1.2 / Play): talaba kartadan «Shikoyat qilish» orqali mavjud
--     support mexanizmiga o'tadi (related_entity = teacher_card:<uid>);
--     admin admin_teacher_card_hide() bilan kartani yashiradi (audit log'da),
--     ustoz uni o'zi qayta yoqa olmaydi.
--   * Hisob o'chirilganda jadval qatori ON DELETE CASCADE bilan o'chadi;
--     Storage obyektlari delete-account Edge Function'da o'chiriladi.
--
-- Bu fayl ADDITIV. Production'ga faqat egasi qo'llaydi.
-- ROLLBACK: supabase/rollback/20261031020000_teacher_card_down.sql

-- ---------------------------------------------------------------- jadval
create table public.teacher_cards (
  user_id uuid primary key references auth.users (id) on delete cascade,
  display_name text not null check (char_length(display_name) between 2 and 60),
  workplace text not null default '' check (char_length(workplace) <= 120),
  bio text not null default '' check (char_length(bio) <= 300),
  photo_path text check (photo_path is null or char_length(photo_path) <= 120),
  logo_path text check (logo_path is null or char_length(logo_path) <= 120),
  socials jsonb not null default '{}'::jsonb check (jsonb_typeof(socials) = 'object'),
  visible boolean not null default false,
  -- Ustoz «Talabalarimga ko'rsatish»ni yoqqan vaqt (rozilik izi).
  consent_at timestamptz,
  -- Admin (shikoyat bo'yicha) yashirgan: ustoz o'zi qayta yoqa olmaydi.
  hidden_by_admin boolean not null default false,
  updated_at timestamptz not null default now()
);
alter table public.teacher_cards enable row level security;

-- Defense in depth: jadval huquqi tasodifan berilsa ham faqat o'z qatori.
create policy teacher_cards_self_read on public.teacher_cards
  for select using (user_id = auth.uid());

-- ---------------------------------------------------------------- yordamchilar

-- Havola tekshiruvi (Dart nusxasi: lib/domain/class_groups/teacher_card.dart).
create function private.teacher_card_url_ok(p_key text, p_url text) returns boolean
language plpgsql immutable set search_path = '' as $$
declare
  v_host text;
  v_allowed text[];
begin
  if p_key is null or p_url is null or char_length(p_url) > 255 then
    return false;
  end if;
  -- Faqat https://host[/yo'l]; bo'shliq, boshqaruv belgilari, <>"'\ yo'q.
  if p_url !~* '^https://[a-z0-9.-]+(/[^[:space:][:cntrl:]<>"''\\]*)?$' then
    return false;
  end if;
  v_host := lower(substring(p_url from '^[Hh][Tt][Tt][Pp][Ss]://([^/]+)'));
  -- Host: nuqta bilan ajratilgan toza yorliqlar, oxirgisi harf bilan boshlanadi
  -- (IP manzil, «localhost» va port rad etiladi).
  if v_host !~ '^([a-z0-9]([a-z0-9-]*[a-z0-9])?\.)+[a-z][a-z0-9-]{1,23}$' then
    return false;
  end if;
  v_allowed := case p_key
    when 'telegram'  then array['t.me', 'telegram.me']
    when 'instagram' then array['instagram.com', 'www.instagram.com']
    when 'youtube'   then array['youtube.com', 'www.youtube.com', 'm.youtube.com', 'youtu.be']
    when 'facebook'  then array['facebook.com', 'www.facebook.com', 'm.facebook.com']
    when 'linkedin'  then array['linkedin.com', 'www.linkedin.com']
    when 'tiktok'    then array['tiktok.com', 'www.tiktok.com']
    when 'website'   then null
    else array[]::text[]
  end;
  if p_key = 'website' then return true; end if;
  return v_host = any (v_allowed);
end $$;

-- Rasm yo'li: <uid>/(photo|logo)-<uuid>.<jpg|png|webp> va bucket'da mavjud.
create function private.teacher_card_path_ok(p_uid uuid, p_kind text, p_path text)
returns boolean language sql stable security definer set search_path = '' as $$
  select p_path ~ ('^' || p_uid::text || '/' || p_kind
      || '-[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\.(jpg|png|webp)$')
    and exists (select 1 from storage.objects o
                where o.bucket_id = 'teacher-cards' and o.name = p_path)
$$;

-- Karta talabalarga ko'rinadimi (karta holati; guruh a'zoligi alohida).
create function private.teacher_card_public(c public.teacher_cards) returns boolean
language sql stable security definer set search_path = '' as $$
  select c.visible and not c.hidden_by_admin and private.class_is_teacher(c.user_id)
$$;

-- p_viewer — p_teacher guruhlaridan birining a'zosimi.
create function private.teacher_card_member(p_viewer uuid, p_teacher uuid)
returns boolean language sql stable security definer set search_path = '' as $$
  select p_viewer is not null and exists (
    select 1 from public.class_group_members m
    join public.class_groups g on g.id = m.group_id
    where m.user_id = p_viewer and g.teacher_id = p_teacher)
$$;

create function private.teacher_card_json(c public.teacher_cards, p_owner boolean)
returns jsonb language sql stable set search_path = '' as $$
  select jsonb_build_object(
    'teacher_id', c.user_id,
    'display_name', c.display_name,
    'workplace', c.workplace,
    'bio', c.bio,
    'photo_path', c.photo_path,
    'logo_path', c.logo_path,
    'socials', c.socials,
    'updated_at', c.updated_at)
  || case when p_owner then jsonb_build_object(
       'visible', c.visible, 'hidden_by_admin', c.hidden_by_admin,
       'consent_at', c.consent_at)
     else '{}'::jsonb end
$$;

-- Storage siyosatlari uchun (siyosat funksiyani chaqiruvchi huquqida bajariladi,
-- shuning uchun bu ikkisi SECURITY DEFINER va faqat auth.uid() bilan ishlaydi —
-- parametr orqali boshqa foydalanuvchi nomidan so'rab bo'lmaydi).
create function private.teacher_card_storage_write_ok(p_name text)
returns boolean language plpgsql stable security definer set search_path = '' as $$
declare me uuid := auth.uid();
begin
  if me is null or not private.class_is_teacher(me) then return false; end if;
  if p_name !~ ('^' || me::text
      || '/(photo|logo)-[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\.(jpg|png|webp)$') then
    return false;
  end if;
  -- Spamga qarshi: bitta ustozda ko'pi bilan 8 ta obyekt.
  return (select count(*) from storage.objects o
          where o.bucket_id = 'teacher-cards'
            and (storage.foldername(o.name))[1] = me::text) < 8;
end $$;

create function private.teacher_card_storage_read_ok(p_name text)
returns boolean language plpgsql stable security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  v_folder text := (storage.foldername(p_name))[1];
  c public.teacher_cards;
begin
  if me is null or v_folder is null then return false; end if;
  if v_folder = me::text then return true; end if;
  if v_folder !~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$' then
    return false;
  end if;
  select * into c from public.teacher_cards x where x.user_id = v_folder::uuid;
  if not found or not private.teacher_card_public(c) then return false; end if;
  -- Faqat kartada ko'rsatilgan joriy rasm/logotip o'qiladi.
  if p_name is distinct from c.photo_path and p_name is distinct from c.logo_path then
    return false;
  end if;
  return private.teacher_card_member(me, c.user_id);
end $$;

-- ---------------------------------------------------------------- ustoz RPC

-- Ustozning o'z kartasi (rozilik holati bilan). Rol shart emas: roli
-- olingan ustoz ham o'z ma'lumotini ko'ra va o'chira oladi.
create function public.teacher_card_get_mine() returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  c public.teacher_cards;
begin
  if me is null then raise exception 'forbidden' using errcode = '42501'; end if;
  select * into c from public.teacher_cards x where x.user_id = me;
  if not found then
    return jsonb_build_object('ok', true, 'card', null,
      'is_teacher', private.class_is_teacher(me));
  end if;
  return jsonb_build_object('ok', true, 'card', private.teacher_card_json(c, true),
    'is_teacher', private.class_is_teacher(me));
end $$;

-- Yaratish / yangilash. Faqat ustoz roli (42501). Kutilgan xatolar
-- {ok:false, error, field?}: invalid_name | invalid_workplace | invalid_bio |
-- invalid_photo | invalid_logo | invalid_social (field = tarmoq kaliti) |
-- hidden_by_admin.
create function public.teacher_card_upsert(
  p_display_name text,
  p_workplace text default '',
  p_bio text default '',
  p_photo_path text default null,
  p_logo_path text default null,
  p_socials jsonb default '{}'::jsonb,
  p_visible boolean default false
) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  v_name text := btrim(coalesce(p_display_name, ''));
  v_work text := btrim(coalesce(p_workplace, ''));
  v_bio text := btrim(coalesce(p_bio, ''));
  v_photo text := nullif(btrim(coalesce(p_photo_path, '')), '');
  v_logo text := nullif(btrim(coalesce(p_logo_path, '')), '');
  v_soc jsonb := '{}'::jsonb;
  v_vis boolean := coalesce(p_visible, false);
  v_in jsonb := coalesce(p_socials, '{}'::jsonb);
  old public.teacher_cards;
  r record;
  s text;
  v_row public.teacher_cards;
begin
  if me is null or not private.class_is_teacher(me) then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  if char_length(v_name) not between 2 and 60
     or v_name ~ E'[\\x01-\\x1f\\x7f]' then
    return jsonb_build_object('ok', false, 'error', 'invalid_name');
  end if;
  if char_length(v_work) > 120 or v_work ~ E'[\\x01-\\x1f\\x7f]' then
    return jsonb_build_object('ok', false, 'error', 'invalid_workplace');
  end if;
  if char_length(v_bio) > 300 or v_bio ~ E'[\\x01-\\x09\\x0b-\\x1f\\x7f]' then
    return jsonb_build_object('ok', false, 'error', 'invalid_bio');
  end if;
  if v_photo is not null and not private.teacher_card_path_ok(me, 'photo', v_photo) then
    return jsonb_build_object('ok', false, 'error', 'invalid_photo');
  end if;
  if v_logo is not null and not private.teacher_card_path_ok(me, 'logo', v_logo) then
    return jsonb_build_object('ok', false, 'error', 'invalid_logo');
  end if;
  if jsonb_typeof(v_in) <> 'object' then
    return jsonb_build_object('ok', false, 'error', 'invalid_social');
  end if;
  for r in select key, value from jsonb_each(v_in) loop
    if r.key not in ('telegram', 'instagram', 'youtube', 'facebook', 'linkedin',
                     'tiktok', 'website') then
      return jsonb_build_object('ok', false, 'error', 'invalid_social', 'field', r.key);
    end if;
    if jsonb_typeof(r.value) = 'null' then continue; end if;
    if jsonb_typeof(r.value) <> 'string' then
      return jsonb_build_object('ok', false, 'error', 'invalid_social', 'field', r.key);
    end if;
    s := btrim(r.value #>> '{}');
    if s = '' then continue; end if;
    if not private.teacher_card_url_ok(r.key, s) then
      return jsonb_build_object('ok', false, 'error', 'invalid_social', 'field', r.key);
    end if;
    v_soc := v_soc || jsonb_build_object(r.key, s);
  end loop;
  select * into old from public.teacher_cards x where x.user_id = me for update;
  if v_vis and found and old.hidden_by_admin then
    return jsonb_build_object('ok', false, 'error', 'hidden_by_admin');
  end if;
  insert into public.teacher_cards as t (user_id, display_name, workplace, bio,
    photo_path, logo_path, socials, visible, consent_at, updated_at)
  values (me, v_name, v_work, v_bio, v_photo, v_logo, v_soc, v_vis,
          case when v_vis then now() end, now())
  on conflict (user_id) do update set
    display_name = excluded.display_name, workplace = excluded.workplace,
    bio = excluded.bio, photo_path = excluded.photo_path,
    logo_path = excluded.logo_path, socials = excluded.socials,
    visible = excluded.visible,
    -- Rozilik vaqti faqat o'chiq → yoqiq o'tishda yangilanadi.
    consent_at = case when excluded.visible and not t.visible then now()
                      when excluded.visible then coalesce(t.consent_at, now())
                      else null end,
    updated_at = now()
  returning * into v_row;
  return jsonb_build_object('ok', true, 'card', private.teacher_card_json(v_row, true));
end $$;

-- Talaba ko'rinishi (teacher_id bo'yicha). Faqat o'sha ustozning guruhi a'zosi
-- YOKI ustozning o'zi; boshqa — 42501. Karta yo'q yoki yashirin (visible=false,
-- admin yashirgan, rol olingan) bo'lsa — {ok:true, card:null} (hech narsa
-- sizmaydi; egasi ham: o'z to'liq kartasi uchun teacher_card_get_mine).
create function public.teacher_card_get(p_teacher uuid) returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  c public.teacher_cards;
begin
  if me is null then raise exception 'forbidden' using errcode = '42501'; end if;
  if p_teacher is null
     or not (me = p_teacher or private.teacher_card_member(me, p_teacher)) then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  select * into c from public.teacher_cards x where x.user_id = p_teacher;
  if not found or not private.teacher_card_public(c) then
    return jsonb_build_object('ok', true, 'card', null);
  end if;
  return jsonb_build_object('ok', true, 'card', private.teacher_card_json(c, false));
end $$;

-- Guruh sahifasi uchun: guruh egasi-ustozni topib teacher_card_get qoidasi
-- bilan qaytaradi (ilova ustoz identifikatorini oldindan bilmaydi).
-- Guruh a'zosi yoki egasi bo'lmasa — 42501.
create function public.teacher_card_for_group(p_group uuid) returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  g public.class_groups;
begin
  if me is null then raise exception 'forbidden' using errcode = '42501'; end if;
  select * into g from public.class_groups x where x.id = p_group;
  if not found or not (g.teacher_id = me or exists (
      select 1 from public.class_group_members m
      where m.group_id = g.id and m.user_id = me)) then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  return public.teacher_card_get(g.teacher_id);
end $$;

-- O'chirish. Qaytadi: {ok:true, photo_path, logo_path} — ilova shu Storage
-- obyektlarini o'chiradi (SQL orqali storage.objects'ni o'chirib bo'lmaydi).
create function public.teacher_card_delete() returns jsonb
language plpgsql security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  c public.teacher_cards;
begin
  if me is null then raise exception 'forbidden' using errcode = '42501'; end if;
  delete from public.teacher_cards x where x.user_id = me returning * into c;
  return jsonb_build_object('ok', true, 'deleted', c.user_id is not null,
    'photo_path', c.photo_path, 'logo_path', c.logo_path);
end $$;

-- ---------------------------------------------------------------- admin (UGC)

-- Shikoyat bo'yicha kartani yashirish / qaytarish (faqat identity_admin,
-- MFA qoidasi admin_guard'da, audit log'ga yoziladi).
create function public.admin_teacher_card_hide(p_teacher uuid,
  p_hide boolean default true, p_reason text default null) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare
  me uuid := private.admin_guard();
  n int;
begin
  update public.teacher_cards
     set hidden_by_admin = coalesce(p_hide, true),
         visible = case when coalesce(p_hide, true) then false else visible end,
         updated_at = now()
   where user_id = p_teacher;
  get diagnostics n = row_count;
  perform private.admin_log(me,
    case when coalesce(p_hide, true) then 'TEACHER_CARD_HIDE' else 'TEACHER_CARD_UNHIDE' end,
    'teacher_card', p_teacher::text,
    jsonb_build_object('reason', left(coalesce(p_reason, ''), 300), 'found', n > 0));
  return jsonb_build_object('ok', true, 'found', n > 0);
end $$;

-- ---------------------------------------------------------------- storage
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('teacher-cards', 'teacher-cards', false, 1048576,
        array['image/jpeg', 'image/png', 'image/webp'])
on conflict (id) do update set public = false, file_size_limit = 1048576,
  allowed_mime_types = array['image/jpeg', 'image/png', 'image/webp'];

drop policy if exists teacher_cards_owner_upload on storage.objects;
create policy teacher_cards_owner_upload on storage.objects
  for insert to authenticated
  with check (bucket_id = 'teacher-cards'
    and private.teacher_card_storage_write_ok(name));
drop policy if exists teacher_cards_read on storage.objects;
create policy teacher_cards_read on storage.objects
  for select to authenticated
  using (bucket_id = 'teacher-cards'
    and private.teacher_card_storage_read_ok(name));
drop policy if exists teacher_cards_owner_delete on storage.objects;
create policy teacher_cards_owner_delete on storage.objects
  for delete to authenticated
  using (bucket_id = 'teacher-cards'
    and (storage.foldername(name))[1] = auth.uid()::text);
-- update siyosati YO'Q: fayl nomlari o'zgarmas (yangi rasm — yangi nom).

-- ---------------------------------------------------------------- huquqlar
revoke all on public.teacher_cards from anon, authenticated;

revoke execute on function private.teacher_card_url_ok(text, text) from public, anon, authenticated;
revoke execute on function private.teacher_card_path_ok(uuid, text, text) from public, anon, authenticated;
revoke execute on function private.teacher_card_public(public.teacher_cards) from public, anon, authenticated;
revoke execute on function private.teacher_card_member(uuid, uuid) from public, anon, authenticated;
revoke execute on function private.teacher_card_json(public.teacher_cards, boolean) from public, anon, authenticated;
-- Storage siyosatlari chaqiruvchi huquqida bajariladi: authenticated'ga EXECUTE
-- kerak; funksiyalar faqat auth.uid() uchun boolean qaytaradi (private sxema
-- PostgREST'da ochiq emas).
revoke execute on function private.teacher_card_storage_write_ok(text) from public, anon;
revoke execute on function private.teacher_card_storage_read_ok(text) from public, anon;
grant execute on function private.teacher_card_storage_write_ok(text) to authenticated;
grant execute on function private.teacher_card_storage_read_ok(text) to authenticated;

revoke execute on function public.teacher_card_get_mine() from public, anon;
revoke execute on function public.teacher_card_upsert(text, text, text, text, text, jsonb, boolean) from public, anon;
revoke execute on function public.teacher_card_get(uuid) from public, anon;
revoke execute on function public.teacher_card_for_group(uuid) from public, anon;
revoke execute on function public.teacher_card_delete() from public, anon;
revoke execute on function public.admin_teacher_card_hide(uuid, boolean, text) from public, anon;
grant execute on function public.teacher_card_get_mine() to authenticated;
grant execute on function public.teacher_card_upsert(text, text, text, text, text, jsonb, boolean) to authenticated;
grant execute on function public.teacher_card_get(uuid) to authenticated;
grant execute on function public.teacher_card_for_group(uuid) to authenticated;
grant execute on function public.teacher_card_delete() to authenticated;
grant execute on function public.admin_teacher_card_hide(uuid, boolean, text) to authenticated;
