-- Katalog (egasi, 2026-11-02): mutaxassislar ro‘yxatida tasdiqlanmaganlar ham
-- (o‘zi «Katalogda ko‘rsatish»ni yoqsa) chiqadi; tasdiqlanganlarda belgi
-- (`verified: true`). Ustoz/Mutaxassis rejimi bo‘yicha ajratish — ilovada.

create or replace function private.catalog_expert_ok(p_user uuid)
returns boolean language sql stable security definer set search_path to '' as $function$
  select exists (
    select 1 from public.professional_profiles p
    where p.user_id = p_user and p.catalog_visible
      and char_length(btrim(p.display_name)) >= 2)
$function$;

create or replace function public.catalog_set_visible(p_kind text, p_on boolean)
returns jsonb language plpgsql security definer set search_path to '' as $function$
declare me uuid := auth.uid();
begin
  if me is null then raise exception 'forbidden' using errcode = '42501'; end if;
  if p_kind = 'teacher' then
    update public.teacher_cards set catalog_visible = coalesce(p_on, false),
      updated_at = now() where user_id = me;
    if not found then return jsonb_build_object('ok', false, 'error', 'no_card'); end if;
  elsif p_kind = 'expert' then
    update public.professional_profiles set catalog_visible = coalesce(p_on, false)
      where user_id = me;
    if not found then return jsonb_build_object('ok', false, 'error', 'no_profile'); end if;
  else
    return jsonb_build_object('ok', false, 'error', 'invalid_kind');
  end if;
  return jsonb_build_object('ok', true);
end $function$;

create or replace function public.catalog_me()
returns jsonb language sql stable security definer set search_path to '' as $function$
  select jsonb_build_object(
    'stars', (select count(*) from public.catalog_stars s where s.target = auth.uid()),
    'teacher_catalog', coalesce((select c.catalog_visible from public.teacher_cards c
                                 where c.user_id = auth.uid()), false),
    'expert_catalog', coalesce((select p.catalog_visible from public.professional_profiles p
                                where p.user_id = auth.uid()), false),
    'expert_eligible', exists (select 1 from public.professional_profiles p
                               where p.user_id = auth.uid()),
    'expert_verified', private.is_verified_professional(auth.uid()))
  where auth.uid() is not null
$function$;

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
          'mine', p.user_id = me,
          'verified', private.is_verified_professional(p.user_id)) j,
        (select count(*) from public.catalog_stars s where s.target = p.user_id) stars,
        p.display_name name
      from public.professional_profiles p
      where private.catalog_expert_ok(p.user_id)
        and (q is null or p.display_name ilike '%' || q || '%' escape '\'
             or coalesce(p.position, '') ilike '%' || q || '%' escape '\')
      order by 2 desc, 3 limit v_limit) x), '[]'::jsonb);
  end if;
  return '[]'::jsonb;
end $function$;
