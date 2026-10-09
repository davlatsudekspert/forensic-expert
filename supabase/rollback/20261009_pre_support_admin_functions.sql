-- Production definitions captured 2026-10-09 BEFORE migration
-- 20261009000000_support_and_admin.sql (read-only pg_get_functiondef).
-- Rollback step: after dropping the new objects, re-run this file to restore
-- admin_dashboard() and admin_set_access() exactly as they were.

CREATE OR REPLACE FUNCTION public.admin_dashboard()
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare me uuid := auth.uid();
begin
  if me is null or not private.has_role(me, 'identity_admin') then
    raise exception 'forbidden';
  end if;
  return jsonb_build_object(
    'generated_at', now(),
    'totals', jsonb_build_object(
      'users', (select count(*) from auth.users),
      'confirmed', (select count(*) from auth.users where email_confirmed_at is not null),
      'signups_7d', (select count(*) from auth.users where created_at > now() - interval '7 days'),
      'signups_30d', (select count(*) from auth.users where created_at > now() - interval '30 days'),
      'active_7d', (select count(*) from auth.users where last_sign_in_at > now() - interval '7 days'),
      'android', (select count(distinct user_id) from public.user_devices where platform = 'android'),
      'ios', (select count(distinct user_id) from public.user_devices where platform = 'ios'),
      'ai_requests', (select count(*) from public.ai_usage),
      'ai_requests_7d', (select count(*) from public.ai_usage where created_at > now() - interval '7 days'),
      'referrals', (select count(*) from public.referrals where status = 'VALID'),
      'pro_grants', (select count(*) from public.access_grants
                      where expires_at is null or expires_at > now())),
    'regions', coalesce((select jsonb_agg(x order by x.users desc, x.region) from (
        select coalesce(d.region, '??') as region, count(distinct d.user_id) as users
          from public.user_devices d group by 1 limit 50) x), '[]'::jsonb),
    'daily', coalesce((select jsonb_agg(x order by x.day) from (
        select to_char(date_trunc('day', created_at), 'YYYY-MM-DD') as day, count(*) as signups
          from auth.users where created_at > now() - interval '30 days' group by 1) x), '[]'::jsonb),
    'users', coalesce((select jsonb_agg(x order by x.created_at desc) from (
        select u.email, u.created_at, u.last_sign_in_at,
               (u.email_confirmed_at is not null) as confirmed,
               (select string_agg(d.platform, ',' order by d.platform)
                  from public.user_devices d where d.user_id = u.id) as platforms,
               (select d.region from public.user_devices d where d.user_id = u.id
                  order by d.last_seen desc limit 1) as region,
               (select g.tier from public.access_grants g where g.user_id = u.id
                  and (g.expires_at is null or g.expires_at > now())) as tier,
               private.has_role(u.id, 'identity_admin') as is_admin
          from auth.users u order by u.created_at desc limit 500) x), '[]'::jsonb)
  );
end $function$;

CREATE OR REPLACE FUNCTION public.admin_set_access(p_email text, p_tier text)
 RETURNS text
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare me uuid := auth.uid(); target uuid;
begin
  if me is null or not private.has_role(me, 'identity_admin') then
    raise exception 'forbidden';
  end if;
  select id into target from auth.users where lower(email) = lower(trim(p_email));
  if target is null then return 'NOT_FOUND'; end if;
  if p_tier is null then
    delete from public.access_grants where user_id = target;
    return 'REVOKED';
  end if;
  if p_tier not in ('studentPro', 'professionalPro') then return 'INVALID_TIER'; end if;
  insert into public.access_grants (user_id, tier, granted_by, note)
  values (target, p_tier, me, 'admin panel')
  on conflict (user_id) do update
    set tier = excluded.tier, granted_by = me, granted_at = now(), expires_at = null;
  return 'GRANTED';
end $function$;
