-- Ustoz kartasi: ixtiyoriy «Dars beradigan kurslarim» (egasi, 2026-11-02).
-- Standart o‘chiq; faqat ustoz yoqsa katalog/guruh kartasida ko‘rinadi.
-- Faqat kurs (fakultet) nomlari — ustoz o‘tkazgan test mavzularidan.

alter table public.teacher_cards
  add column if not exists show_courses boolean not null default false;

-- Ustoz test o‘tkazgan mavzular kurslari.
create or replace function private.teacher_extras(p_teacher uuid)
returns jsonb language sql stable security definer set search_path = '' as $$
  with topics as (
    select s.topic_id from public.class_sessions s where s.teacher_id = p_teacher
    union
    select a.topic_id from public.class_assignments a
      join public.class_groups g on g.id = a.group_id
     where g.teacher_id = p_teacher
    union
    -- Aralash (bir nechta mavzuli) topshiriqlar.
    select unnest(a.topics) from public.class_assignments a
      join public.class_groups g on g.id = a.group_id
     where g.teacher_id = p_teacher
  )
  select jsonb_build_object(
    'courses', coalesce((
      select jsonb_agg(c order by c) from (
        select distinct lt.course c from public.lesson_topics lt
         where lt.topic_id in (select topic_id from topics where topic_id is not null)
           and coalesce(lt.course, '') <> '') x), '[]'::jsonb))
$$;
revoke all on function private.teacher_extras(uuid) from public, anon, authenticated;

create or replace function private.teacher_card_extras_json(c public.teacher_cards)
returns jsonb language sql stable security definer set search_path = '' as $$
  select case when c.show_courses
    then jsonb_build_object('courses', private.teacher_extras(c.user_id)->'courses')
    else '{}'::jsonb end
$$;
revoke all on function private.teacher_card_extras_json(public.teacher_cards) from public, anon, authenticated;

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
  || private.teacher_card_extras_json(c)
  || case when p_owner then jsonb_build_object(
       'visible', c.visible, 'hidden_by_admin', c.hidden_by_admin,
       'consent_at', c.consent_at,
       'show_courses', c.show_courses)
     else '{}'::jsonb end
$$;

create or replace function public.teacher_card_set_extras(p_show_courses boolean)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare me uuid := auth.uid();
begin
  if me is null then raise exception 'forbidden' using errcode = '42501'; end if;
  update public.teacher_cards
     set show_courses = coalesce(p_show_courses, false),
         updated_at = now()
   where user_id = me;
  if not found then return jsonb_build_object('ok', false, 'error', 'no_card'); end if;
  return jsonb_build_object('ok', true);
end $$;
revoke all on function public.teacher_card_set_extras(boolean) from public, anon;
grant execute on function public.teacher_card_set_extras(boolean) to authenticated;

-- Katalog: ustoz yoqqan qo‘shimchalar (kurslar, sonlar) kartada.
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
          'mine', c.user_id = me) || private.teacher_card_extras_json(c) j,
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
