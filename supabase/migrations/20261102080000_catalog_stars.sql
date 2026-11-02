-- 2026-11-02 (egasi so'rovi): «Ustozlar va mutaxassislar» katalogi + bitta
-- yulduzcha (like). Katalogda chiqish — alohida rozilik (DEFAULT o'chiq):
-- ustoz kartasining «talabalarga ko'rinadi» roziligi faqat o'z guruhi uchun.
-- Yulduzcha: hisobga kirgan har kim, bitta hisob — bitta nishonga bitta,
-- o'ziga bosib bo'lmaydi; kim bosgani hech kimga ko'rsatilmaydi (faqat soni).

alter table public.teacher_cards
  add column if not exists catalog_visible boolean not null default false;
alter table public.professional_profiles
  add column if not exists catalog_visible boolean not null default false;

create table if not exists public.catalog_stars (
  target uuid not null references auth.users (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (target, user_id),
  check (target <> user_id)
);
alter table public.catalog_stars enable row level security;
create index if not exists catalog_stars_user on public.catalog_stars (user_id);

-- Katalogdagi ustoz: karta ommaviy (rozilik + admin yashirmagan + rol) va
-- katalog roziligi.
create or replace function private.catalog_teacher_ok(p_user uuid)
returns boolean language sql stable security definer set search_path to '' as $$
  select exists (select 1 from public.teacher_cards c
    where c.user_id = p_user and c.catalog_visible
      and private.teacher_card_public(c))
$$;

-- Katalogdagi mutaxassis: tasdiqlangan + profil + katalog roziligi.
create or replace function private.catalog_expert_ok(p_user uuid)
returns boolean language sql stable security definer set search_path to '' as $$
  select private.is_verified_professional(p_user) and exists (
    select 1 from public.professional_profiles p
    where p.user_id = p_user and p.catalog_visible
      and char_length(btrim(p.display_name)) >= 2)
$$;

create or replace function public.catalog_list(
  p_kind text, p_query text default null, p_limit int default 100)
returns jsonb language plpgsql stable security definer set search_path to '' as $$
declare
  me uuid := auth.uid();
  q text := private.like_escape(nullif(btrim(left(coalesce(p_query, ''), 100)), ''));
  v_limit int := least(greatest(coalesce(p_limit, 100), 1), 200);
begin
  if me is null then raise exception 'forbidden' using errcode = '42501'; end if;
  if p_kind = 'teacher' then
    return coalesce((select jsonb_agg(j order by stars desc, name) from (
      select jsonb_build_object(
          'id', c.user_id, 'kind', 'teacher', 'name', c.display_name,
          'subtitle', c.workplace, 'category', c.category, 'bio', c.bio,
          'photo_path', c.photo_path, 'socials', c.socials,
          'stars', (select count(*) from public.catalog_stars s where s.target = c.user_id),
          'starred', exists (select 1 from public.catalog_stars s
                             where s.target = c.user_id and s.user_id = me),
          'mine', c.user_id = me) j,
        (select count(*) from public.catalog_stars s where s.target = c.user_id) stars,
        c.display_name name
      from public.teacher_cards c
      where c.catalog_visible and private.teacher_card_public(c)
        and (q is null or c.display_name ilike '%' || q || '%' escape '\'
             or c.workplace ilike '%' || q || '%' escape '\')
      order by 2 desc, 3 limit v_limit) x), '[]'::jsonb);
  elsif p_kind = 'expert' then
    return coalesce((select jsonb_agg(j order by stars desc, name) from (
      select jsonb_build_object(
          'id', p.user_id, 'kind', 'expert', 'name', p.display_name,
          'subtitle', btrim(concat_ws(' · ', nullif(p.position, ''),
                       case when p.show_organization then nullif(p.organization, '') end)),
          'category', null, 'bio', coalesce(p.bio, ''), 'photo_path', null,
          'socials', '{}'::jsonb,
          'stars', (select count(*) from public.catalog_stars s where s.target = p.user_id),
          'starred', exists (select 1 from public.catalog_stars s
                             where s.target = p.user_id and s.user_id = me),
          'mine', p.user_id = me) j,
        (select count(*) from public.catalog_stars s where s.target = p.user_id) stars,
        p.display_name name
      from public.professional_profiles p
      where private.catalog_expert_ok(p.user_id)
        and (q is null or p.display_name ilike '%' || q || '%' escape '\'
             or coalesce(p.position, '') ilike '%' || q || '%' escape '\')
      order by 2 desc, 3 limit v_limit) x), '[]'::jsonb);
  end if;
  return '[]'::jsonb;
end $$;

-- Yulduzcha: bosish/qaytarish. Natija: {ok, starred, stars}.
create or replace function public.catalog_star_toggle(p_target uuid)
returns jsonb language plpgsql security definer set search_path to '' as $$
declare
  me uuid := auth.uid();
  v_on boolean;
begin
  if me is null then raise exception 'forbidden' using errcode = '42501'; end if;
  if p_target is null or p_target = me then
    return jsonb_build_object('ok', false, 'error', 'self');
  end if;
  if not (private.catalog_teacher_ok(p_target) or private.catalog_expert_ok(p_target)) then
    return jsonb_build_object('ok', false, 'error', 'not_found');
  end if;
  delete from public.catalog_stars where target = p_target and user_id = me;
  if found then
    v_on := false;
  else
    insert into public.catalog_stars (target, user_id) values (p_target, me);
    v_on := true;
  end if;
  return jsonb_build_object('ok', true, 'starred', v_on,
    'stars', (select count(*) from public.catalog_stars s where s.target = p_target));
end $$;

-- O'z yulduzchalari soni va katalog roziliklari (profil uchun).
create or replace function public.catalog_me()
returns jsonb language sql stable security definer set search_path to '' as $$
  select jsonb_build_object(
    'stars', (select count(*) from public.catalog_stars s where s.target = auth.uid()),
    'teacher_catalog', coalesce((select c.catalog_visible from public.teacher_cards c
                                 where c.user_id = auth.uid()), false),
    'expert_catalog', coalesce((select p.catalog_visible from public.professional_profiles p
                                where p.user_id = auth.uid()), false),
    'expert_eligible', private.is_verified_professional(auth.uid()))
  where auth.uid() is not null
$$;

-- Katalog roziligini yoqish/o'chirish.
create or replace function public.catalog_set_visible(p_kind text, p_on boolean)
returns jsonb language plpgsql security definer set search_path to '' as $$
declare me uuid := auth.uid();
begin
  if me is null then raise exception 'forbidden' using errcode = '42501'; end if;
  if p_kind = 'teacher' then
    update public.teacher_cards set catalog_visible = coalesce(p_on, false),
      updated_at = now() where user_id = me;
    if not found then return jsonb_build_object('ok', false, 'error', 'no_card'); end if;
  elsif p_kind = 'expert' then
    if coalesce(p_on, false) and not private.is_verified_professional(me) then
      return jsonb_build_object('ok', false, 'error', 'not_verified');
    end if;
    update public.professional_profiles set catalog_visible = coalesce(p_on, false)
      where user_id = me;
    if not found then return jsonb_build_object('ok', false, 'error', 'no_profile'); end if;
  else
    return jsonb_build_object('ok', false, 'error', 'invalid_kind');
  end if;
  return jsonb_build_object('ok', true);
end $$;

-- Katalogdagi ustoz rasmini hisobga kirgan har kim o'qiy oladi (rozilik bilan).
create or replace function private.teacher_card_storage_read_ok(p_name text)
returns boolean language plpgsql stable security definer set search_path to '' as $$
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
  if p_name is distinct from c.photo_path and p_name is distinct from c.logo_path then
    return false;
  end if;
  return c.catalog_visible or private.teacher_card_member(me, c.user_id);
end $$;

revoke execute on function public.catalog_list(text, text, int) from public, anon;
revoke execute on function public.catalog_star_toggle(uuid) from public, anon;
revoke execute on function public.catalog_me() from public, anon;
revoke execute on function public.catalog_set_visible(text, boolean) from public, anon;
grant execute on function public.catalog_list(text, text, int) to authenticated;
grant execute on function public.catalog_star_toggle(uuid) to authenticated;
grant execute on function public.catalog_me() to authenticated;
grant execute on function public.catalog_set_visible(text, boolean) to authenticated;
revoke execute on function private.catalog_teacher_ok(uuid) from public, anon, authenticated;
revoke execute on function private.catalog_expert_ok(uuid) from public, anon, authenticated;
