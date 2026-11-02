-- Ustoz kartasi: ixtiyoriy fon (cover) rasmi (egasi, 2026-11-02).
-- Yo‘l: <uid>/cover-<uuid>.<jpg|png|webp>, xuddi shu xususiy `teacher-cards`
-- bucket (1 MB). Tavsiya: 1500×500 px (3:1). Ko‘rinish qoidalari rasm bilan
-- bir xil (ommaviy karta + katalog yoki guruh a’zosi).

alter table public.teacher_cards
  add column if not exists cover_path text
    check (cover_path is null or char_length(cover_path) <= 120);

create or replace function private.teacher_card_storage_write_ok(p_name text)
returns boolean language plpgsql stable security definer set search_path to '' as $function$
declare me uuid := auth.uid();
begin
  if me is null or not private.class_is_teacher(me) then return false; end if;
  if p_name !~ ('^' || me::text
      || '/(photo|logo|cover)-[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\.(jpg|png|webp)$') then
    return false;
  end if;
  return (select count(*) from storage.objects o
          where o.bucket_id = 'teacher-cards'
            and (storage.foldername(o.name))[1] = me::text) < 10;
end $function$;

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
  return c.catalog_visible or private.teacher_card_member(me, c.user_id);
end $function$;

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
    'cover_path', c.cover_path,
    'socials', c.socials,
    'updated_at', c.updated_at)
  || case when p_owner then jsonb_build_object(
       'visible', c.visible, 'hidden_by_admin', c.hidden_by_admin,
       'consent_at', c.consent_at)
     else '{}'::jsonb end
$$;

-- Fonni qo‘yish/olib tashlash (null). Qaytadi: {ok, old_path} — ilova eski
-- obyektni Storage’dan o‘chiradi.
create or replace function public.teacher_card_set_cover(p_path text)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  v_path text := nullif(btrim(coalesce(p_path, '')), '');
  v_old text;
begin
  if me is null then raise exception 'forbidden' using errcode = '42501'; end if;
  if v_path is not null and not private.teacher_card_path_ok(me, 'cover', v_path) then
    return jsonb_build_object('ok', false, 'error', 'invalid_path');
  end if;
  select cover_path into v_old from public.teacher_cards where user_id = me;
  if not found then return jsonb_build_object('ok', false, 'error', 'no_card'); end if;
  update public.teacher_cards set cover_path = v_path, updated_at = now()
   where user_id = me;
  return jsonb_build_object('ok', true,
    'old_path', case when v_old is distinct from v_path then v_old end);
end $$;
revoke all on function public.teacher_card_set_cover(text) from public, anon;
grant execute on function public.teacher_card_set_cover(text) to authenticated;

create or replace function public.teacher_card_delete() returns jsonb
language plpgsql security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  c public.teacher_cards;
begin
  if me is null then raise exception 'forbidden' using errcode = '42501'; end if;
  delete from public.teacher_cards x where x.user_id = me returning * into c;
  return jsonb_build_object('ok', true, 'deleted', c.user_id is not null,
    'photo_path', c.photo_path, 'logo_path', c.logo_path,
    'cover_path', c.cover_path);
end $$;

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
