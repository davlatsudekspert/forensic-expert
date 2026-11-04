-- Guruhni arxivlash / o'chirish (ustoz). Production'ga 2026-11-04 da qo'llangan.
alter table public.class_groups add column if not exists archived_at timestamptz;

create or replace function public.group_list()
 returns jsonb language plpgsql stable security definer set search_path to ''
as $function$
declare me uuid := auth.uid();
begin
  if me is null then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  return jsonb_build_object('ok', true, 'is_teacher', private.class_is_teacher(me),
    'teaching', case when private.class_is_teacher(me) then coalesce((
        select jsonb_agg(private.group_json(g, true) order by g.created_at desc)
          from public.class_groups g
         where g.teacher_id = me and g.archived_at is null), '[]'::jsonb)
      else '[]'::jsonb end,
    'member', coalesce((
        select jsonb_agg(private.group_json(g, false) || jsonb_build_object('nickname', m.nickname)
                         order by m.joined_at desc)
          from public.class_group_members m
          join public.class_groups g on g.id = m.group_id
         where m.user_id = me and g.archived_at is null), '[]'::jsonb));
end $function$;

create or replace function public.group_set_archived(p_group uuid, p_archived boolean)
 returns jsonb language plpgsql security definer set search_path to ''
as $function$
declare g public.class_groups;
begin
  g := private.group_owned(p_group);
  update public.class_groups set archived_at = case when p_archived then now() else null end
   where id = g.id;
  return jsonb_build_object('ok', true, 'archived', p_archived);
end $function$;
revoke all on function public.group_set_archived(uuid, boolean) from public, anon;
grant execute on function public.group_set_archived(uuid, boolean) to authenticated;

create or replace function public.group_delete(p_group uuid)
 returns jsonb language plpgsql security definer set search_path to ''
as $function$
declare g public.class_groups;
begin
  g := private.group_owned(p_group);
  delete from public.class_groups where id = g.id;
  return jsonb_build_object('ok', true);
end $function$;
revoke all on function public.group_delete(uuid) from public, anon;
grant execute on function public.group_delete(uuid) to authenticated;
