-- Egasi: «dars ham kerak emas» (2026-11-02) — 20261102120000 bekor qilinadi.
-- Funksiyalar avvalgi holatiga qaytadi, qo‘shimcha ustun olib tashlanadi.

create or replace function private.teacher_card_json(c public.teacher_cards, p_owner boolean)
returns jsonb language sql stable set search_path = '' as $$
  select jsonb_build_object(
    'teacher_id', c.user_id,
    'display_name', c.display_name,
    'workplace', c.workplace,
    'category', c.category,
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
end $function$;

drop function if exists public.teacher_card_set_extras(boolean);
drop function if exists private.teacher_card_extras_json(public.teacher_cards);
drop function if exists private.teacher_extras(uuid);
alter table public.teacher_cards drop column if exists show_courses;
