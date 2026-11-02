-- Bitta odam — bitta katalog profili (egasi, 2026-11-02): mutaxassis profili
-- bor odam «Mutaxassislar»da chiqadi (ustoz kartasi ma’lumotlari bilan) va
-- «Ustozlar»da takrorlanmaydi. Ikki «Katalogda ko‘rsatish»dan biri yoqilsa
-- yetarli.

create or replace function private.catalog_expert_ok(p_user uuid)
returns boolean language sql stable security definer set search_path to '' as $function$
  select exists (
    select 1 from public.professional_profiles p
    where p.user_id = p_user
      and char_length(btrim(p.display_name)) >= 2
      and (p.catalog_visible or exists (
        select 1 from public.teacher_cards c
        where c.user_id = p_user and c.catalog_visible)))
$function$;

create or replace function private.teacher_card_storage_read_ok(p_name text)
returns boolean language plpgsql stable security definer set search_path to '' as $function$
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
  if p_name is distinct from c.photo_path and p_name is distinct from c.logo_path
     and p_name is distinct from c.cover_path then
    return false;
  end if;
  return c.catalog_visible or private.catalog_expert_ok(c.user_id)
      or private.teacher_card_member(me, c.user_id);
end $function$;

create or replace function public.catalog_list(p_kind text, p_query text default null, p_limit integer default 100)
returns jsonb language plpgsql stable security definer set search_path to '' as $function$
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
          'photo_path', c.photo_path, 'cover_path', c.cover_path,
          'socials', c.socials,
          'stars', (select count(*) from public.catalog_stars s where s.target = c.user_id),
          'starred', exists (select 1 from public.catalog_stars s
                             where s.target = c.user_id and s.user_id = me),
          'mine', c.user_id = me) j,
        (select count(*) from public.catalog_stars s where s.target = c.user_id) stars,
        c.display_name name
      from public.teacher_cards c
      where c.catalog_visible and private.teacher_card_public(c)
        and not exists (select 1 from public.professional_profiles pp
                        where pp.user_id = c.user_id)
        and (q is null or c.display_name ilike '%' || q || '%' escape '\'
             or c.workplace ilike '%' || q || '%' escape '\')
      order by 2 desc, 3 limit v_limit) x), '[]'::jsonb);
  elsif p_kind = 'expert' then
    -- Bitta odam — bitta profil: ustoz kartasi bo‘lsa, rasm/ish joyi/toifa/
    -- ma’lumot/tarmoqlar shu kartadan (egasi, 2026-11-02).
    return coalesce((select jsonb_agg(j order by stars desc, name) from (
      select jsonb_build_object(
          'id', p.user_id, 'kind', 'expert',
          'name', coalesce(nullif(btrim(c.display_name), ''), p.display_name),
          'subtitle', coalesce(nullif(btrim(c.workplace), ''),
                       btrim(concat_ws(' · ', nullif(p.position, ''),
                       case when p.show_organization then nullif(p.organization, '') end))),
          'category', c.category,
          'bio', coalesce(nullif(c.bio, ''), coalesce(p.bio, '')),
          'photo_path', c.photo_path, 'cover_path', c.cover_path,
          'socials', coalesce(c.socials, '{}'::jsonb),
          'stars', (select count(*) from public.catalog_stars s where s.target = p.user_id),
          'starred', exists (select 1 from public.catalog_stars s
                             where s.target = p.user_id and s.user_id = me),
          'mine', p.user_id = me,
          'verified', private.is_verified_professional(p.user_id)) j,
        (select count(*) from public.catalog_stars s where s.target = p.user_id) stars,
        p.display_name name
      from public.professional_profiles p
      left join public.teacher_cards c
        on c.user_id = p.user_id and private.teacher_card_public(c)
      where private.catalog_expert_ok(p.user_id)
        and (q is null or p.display_name ilike '%' || q || '%' escape '\'
             or coalesce(c.display_name, '') ilike '%' || q || '%' escape '\'
             or coalesce(p.position, '') ilike '%' || q || '%' escape '\')
      order by 2 desc, 3 limit v_limit) x), '[]'::jsonb);
  end if;
  return '[]'::jsonb;
end $function$;
