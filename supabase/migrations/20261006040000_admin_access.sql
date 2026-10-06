-- FORENSIC EXPERT — owner admin panel + server-granted access.
--
-- * Table access_grants holds complimentary or staff access (for example the
--   owner). The app unlocks Pro ONLY from this server table or a verified store purchase —
--   never from a client flag. Clients cannot read or write the table; they
--   get their own tier via my_access().
-- * user_devices: platform (android/ios), app version, UI locale and device
--   region, reported by the signed-in app via register_device(). No IP, no
--   precise location, no device identifiers. Shown to admins only.
-- * admin_dashboard() / admin_set_access(): identity_admin role only
--   (account_roles, granted by the owner out-of-band).

create table public.access_grants (
  user_id uuid primary key references auth.users (id) on delete cascade,
  tier text not null check (tier in ('studentPro', 'professionalPro')),
  note text check (length(note) <= 200),
  granted_by uuid references auth.users (id) on delete set null,
  granted_at timestamptz not null default now(),
  expires_at timestamptz
);

create table public.user_devices (
  user_id uuid not null references auth.users (id) on delete cascade,
  platform text not null check (platform in ('android', 'ios', 'other')),
  app_version text check (length(app_version) <= 40),
  locale text check (length(locale) <= 20),
  region text check (region ~ '^[A-Z]{2}$'),
  first_seen timestamptz not null default now(),
  last_seen timestamptz not null default now(),
  primary key (user_id, platform)
);

alter table public.access_grants enable row level security;
alter table public.user_devices enable row level security;
revoke all on public.access_grants, public.user_devices from anon, authenticated;

-- ---------------------------------------------------------------- client
create function public.register_device(p_platform text, p_version text,
  p_locale text, p_region text)
returns void language plpgsql security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  v_platform text := case when p_platform in ('android', 'ios') then p_platform else 'other' end;
  v_region text := case when upper(coalesce(p_region, '')) ~ '^[A-Z]{2}$'
                        then upper(p_region) end;
begin
  if me is null then raise exception 'not signed in'; end if;
  insert into public.user_devices (user_id, platform, app_version, locale, region)
  values (me, v_platform, left(p_version, 40), left(p_locale, 20), v_region)
  on conflict (user_id, platform) do update
    set app_version = excluded.app_version, locale = excluded.locale,
        region = coalesce(excluded.region, public.user_devices.region),
        last_seen = now();
end $$;

-- Own server-side access only: {tier: null|studentPro|professionalPro, is_admin}.
create function public.my_access() returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare me uuid := auth.uid();
begin
  if me is null then raise exception 'not signed in'; end if;
  return jsonb_build_object(
    'tier', (select g.tier from public.access_grants g where g.user_id = me
              and (g.expires_at is null or g.expires_at > now())),
    'is_admin', private.has_role(me, 'identity_admin'));
end $$;

-- ---------------------------------------------------------------- admin
create function public.admin_dashboard() returns jsonb
language plpgsql stable security definer set search_path = '' as $$
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
end $$;

-- Grant (tier) or revoke (null) complimentary access by email. Admin only.
create function public.admin_set_access(p_email text, p_tier text)
returns text language plpgsql security definer set search_path = '' as $$
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
end $$;

revoke execute on function public.register_device(text, text, text, text) from public, anon, authenticated;
revoke execute on function public.my_access() from public, anon, authenticated;
revoke execute on function public.admin_dashboard() from public, anon, authenticated;
revoke execute on function public.admin_set_access(text, text) from public, anon, authenticated;
grant execute on function public.register_device(text, text, text, text) to authenticated;
grant execute on function public.my_access() to authenticated;
grant execute on function public.admin_dashboard() to authenticated;
grant execute on function public.admin_set_access(text, text) to authenticated;
