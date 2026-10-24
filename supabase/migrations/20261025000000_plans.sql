-- Pro 0.4.0 plans (docs/PRO_IMPL_0.4.0.md §2). Additive: access_grants,
-- admin_set_access and my_access are NOT touched.
--
-- * public.plans: ONE row per user (student | teacher | expert). The row is
--   the strongest/latest source; when a store subscription is written over
--   an admin grant that outlasts it, the admin grant is kept in the alt_*
--   columns and takes over again when the store period ends.
-- * public.trial_devices: a device hash gets a 30-day trial once, forever.
--   user_id is nullable / set null on account deletion so deleting and
--   re-creating an account does not give a second trial on the same device.
-- * private.plan_events: audit of every plan change.
-- * No table privileges for clients: everything goes through RPCs.
-- * plan_apply_store takes p_user_id (first argument) because the Edge
--   Function calls it with the service-role key, where auth.uid() is null.
--
-- Rollback:
--   drop function if exists public.admin_plan_stats(), public.admin_list_plans(text, int),
--     public.admin_set_plan(text, text, timestamptz),
--     public.plan_apply_store(uuid, text, text, text, timestamptz, boolean),
--     public.plan_claim_trial(text, text), public.my_plan(text);
--   drop function if exists private.plan_effective(public.plans);
--   drop table if exists private.plan_events, public.trial_devices, public.plans;

create table public.plans (
  user_id uuid primary key references auth.users (id) on delete cascade,
  plan text not null check (plan in ('student', 'teacher', 'expert')),
  source text not null check (source in ('store', 'admin', 'trial')),
  platform text check (platform in ('ios', 'android', 'other')),
  product_id text check (length(product_id) <= 100),
  original_transaction_id text check (length(original_transaction_id) <= 200),
  started_at timestamptz not null default now(),
  expires_at timestamptz,
  auto_renew boolean not null default false,
  note text check (length(note) <= 200),
  -- Admin/trial grant that outlasts a store period written over it.
  alt_plan text check (alt_plan in ('student', 'teacher', 'expert')),
  alt_source text check (alt_source in ('admin', 'trial')),
  alt_expires_at timestamptz,
  updated_at timestamptz not null default now()
);
create index plans_original_tx_idx on public.plans (original_transaction_id)
  where original_transaction_id is not null;
alter table public.plans enable row level security;

create table public.trial_devices (
  device_hash text primary key check (device_hash ~ '^[0-9a-f]{64}$'),
  user_id uuid references auth.users (id) on delete set null,
  plan text not null check (plan in ('student', 'teacher', 'expert')),
  claimed_at timestamptz not null default now()
);
create index trial_devices_user_idx on public.trial_devices (user_id);
alter table public.trial_devices enable row level security;

create table private.plan_events (
  id bigint generated always as identity primary key,
  user_id uuid,
  actor_id uuid,
  action text not null,
  plan text,
  source text,
  expires_at timestamptz,
  meta jsonb not null default '{}'::jsonb,
  at timestamptz not null default now()
);
alter table private.plan_events enable row level security;
-- No policies: clients can neither read nor write these tables directly.
revoke all on public.plans, public.trial_devices from anon, authenticated;
revoke all on private.plan_events from anon, authenticated;

-- Effective (currently active) plan of a row as jsonb, or null.
create function private.plan_effective(p public.plans) returns jsonb
language sql stable security definer set search_path = '' as $$
  select case
    when p.user_id is null then null
    when p.expires_at is null or p.expires_at > now() then
      jsonb_build_object('plan', p.plan, 'source', p.source, 'expires_at', p.expires_at,
        'auto_renew', p.auto_renew, 'product_id', p.product_id)
    when p.alt_plan is not null and (p.alt_expires_at is null or p.alt_expires_at > now()) then
      jsonb_build_object('plan', p.alt_plan, 'source', p.alt_source, 'expires_at', p.alt_expires_at,
        'auto_renew', false, 'product_id', null)
    else null end
$$;

create function private.plan_event(p_user uuid, p_actor uuid, p_action text, p_plan text,
  p_source text, p_expires timestamptz, p_meta jsonb) returns void
language sql security definer set search_path = '' as $$
  insert into private.plan_events (user_id, actor_id, action, plan, source, expires_at, meta)
  values (p_user, (select u.id from auth.users u where u.id = p_actor),
          p_action, p_plan, p_source, p_expires, coalesce(p_meta, '{}'::jsonb))
$$;

-- ---------------------------------------------------------------- my_plan
create function public.my_plan(p_device_hash text default null) returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare me uuid := auth.uid(); r public.plans; eff jsonb; avail boolean;
begin
  if me is null then raise exception 'not signed in'; end if;
  select * into r from public.plans where user_id = me;
  eff := case when found then private.plan_effective(r) else null end;
  avail := p_device_hash is not null and p_device_hash ~ '^[0-9a-f]{64}$'
    and not exists (select 1 from public.trial_devices d
                    where d.device_hash = p_device_hash or d.user_id = me);
  return jsonb_build_object(
    'plan', eff->>'plan',
    'source', eff->>'source',
    'expires_at', eff->'expires_at',
    'auto_renew', coalesce((eff->>'auto_renew')::boolean, false),
    'product_id', eff->>'product_id',
    'trial_available', avail);
end $$;

-- -------------------------------------------------------- plan_claim_trial
create function public.plan_claim_trial(p_device_hash text, p_plan text) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare me uuid := auth.uid(); r public.plans; v_exp timestamptz := now() + interval '30 days';
begin
  if me is null then raise exception 'not signed in'; end if;
  if p_device_hash is null or p_device_hash !~ '^[0-9a-f]{64}$'
     or p_plan is null or p_plan not in ('student', 'teacher', 'expert') then
    return jsonb_build_object('result', 'INVALID', 'expires_at', null);
  end if;
  -- Serialize concurrent claims of the same device / account.
  perform pg_advisory_xact_lock(hashtextextended('plan_trial:' || p_device_hash, 0));
  perform pg_advisory_xact_lock(hashtextextended('plan_trial:' || me::text, 0));
  if exists (select 1 from public.trial_devices where user_id = me) then
    return jsonb_build_object('result', 'ALREADY_USED_ACCOUNT', 'expires_at', null);
  end if;
  if exists (select 1 from public.trial_devices where device_hash = p_device_hash) then
    return jsonb_build_object('result', 'ALREADY_USED_DEVICE', 'expires_at', null);
  end if;
  select * into r from public.plans where user_id = me;
  if found and private.plan_effective(r) is not null then
    return jsonb_build_object('result', 'HAS_PLAN', 'expires_at', null);
  end if;
  insert into public.trial_devices (device_hash, user_id, plan) values (p_device_hash, me, p_plan);
  insert into public.plans (user_id, plan, source, platform, expires_at, auto_renew, note, updated_at)
  values (me, p_plan, 'trial', 'other', v_exp, false, 'trial 30d', now())
  on conflict (user_id) do update
    set plan = excluded.plan, source = 'trial', platform = 'other', product_id = null,
        original_transaction_id = null, started_at = now(), expires_at = v_exp,
        auto_renew = false, note = 'trial 30d', alt_plan = null, alt_source = null,
        alt_expires_at = null, updated_at = now();
  perform private.plan_event(me, me, 'TRIAL_GRANTED', p_plan, 'trial', v_exp, '{}'::jsonb);
  return jsonb_build_object('result', 'GRANTED', 'expires_at', v_exp);
end $$;

-- -------------------------------------------------------- plan_apply_store
-- SERVICE ROLE ONLY (verify-purchase Edge Function, after the store receipt
-- was verified). Product id decides the plan: fe_<plan>_(monthly|yearly).
create function public.plan_apply_store(p_user_id uuid, p_platform text, p_product_id text,
  p_original_transaction_id text, p_expires_at timestamptz, p_auto_renew boolean) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare v_plan text; r public.plans; v_alt_plan text; v_alt_src text; v_alt_exp timestamptz;
begin
  if p_user_id is null or not exists (select 1 from auth.users where id = p_user_id)
     or p_platform is null or p_platform not in ('ios', 'android')
     or p_product_id is null or p_product_id !~ '^fe_(student|teacher|expert)_(monthly|yearly)$'
     or p_original_transaction_id is null or length(p_original_transaction_id) not between 1 and 200
     or p_expires_at is null then
    return jsonb_build_object('result', 'INVALID');
  end if;
  v_plan := split_part(p_product_id, '_', 2);
  perform pg_advisory_xact_lock(hashtextextended('plan_store:' || p_original_transaction_id, 0));
  -- A subscription belongs to one account: refuse a still-active copy on
  -- another account (expired ones may move, e.g. after re-registration).
  if exists (select 1 from public.plans x where x.original_transaction_id = p_original_transaction_id
      and x.user_id <> p_user_id and x.source = 'store' and x.platform = p_platform
      and (x.expires_at is null or x.expires_at > now())) then
    return jsonb_build_object('result', 'INVALID', 'reason', 'LINKED_ELSEWHERE');
  end if;
  select * into r from public.plans where user_id = p_user_id;
  if found then
    if r.source = 'store' then
      v_alt_plan := r.alt_plan; v_alt_src := r.alt_source; v_alt_exp := r.alt_expires_at;
    elsif r.expires_at is null or r.expires_at > now() then
      v_alt_plan := r.plan; v_alt_src := r.source; v_alt_exp := r.expires_at;
    else
      v_alt_plan := r.alt_plan; v_alt_src := r.alt_source; v_alt_exp := r.alt_expires_at;
    end if;
    -- Keep the older grant only if it outlasts this store period.
    if v_alt_plan is not null and v_alt_exp is not null and v_alt_exp <= p_expires_at then
      v_alt_plan := null; v_alt_src := null; v_alt_exp := null;
    end if;
    -- An already-expired store report must not displace an active grant.
    if p_expires_at <= now() and private.plan_effective(r) is not null
       and r.source <> 'store' then
      perform private.plan_event(p_user_id, null, 'STORE_IGNORED_EXPIRED', v_plan, 'store',
        p_expires_at, jsonb_build_object('platform', p_platform, 'product_id', p_product_id));
      return jsonb_build_object('result', 'APPLIED', 'plan', private.plan_effective(r)->>'plan');
    end if;
  end if;
  insert into public.plans (user_id, plan, source, platform, product_id, original_transaction_id,
    expires_at, auto_renew, note, alt_plan, alt_source, alt_expires_at, updated_at)
  values (p_user_id, v_plan, 'store', p_platform, p_product_id, p_original_transaction_id,
    p_expires_at, coalesce(p_auto_renew, false), null, v_alt_plan, v_alt_src, v_alt_exp, now())
  on conflict (user_id) do update
    set plan = excluded.plan, source = 'store', platform = excluded.platform,
        product_id = excluded.product_id,
        original_transaction_id = excluded.original_transaction_id,
        started_at = case when public.plans.original_transaction_id
                           is not distinct from excluded.original_transaction_id
                           and public.plans.source = 'store'
                          then public.plans.started_at else now() end,
        expires_at = excluded.expires_at, auto_renew = excluded.auto_renew, note = null,
        alt_plan = excluded.alt_plan, alt_source = excluded.alt_source,
        alt_expires_at = excluded.alt_expires_at, updated_at = now();
  perform private.plan_event(p_user_id, null, 'STORE_APPLIED', v_plan, 'store', p_expires_at,
    jsonb_build_object('platform', p_platform, 'product_id', p_product_id,
                       'auto_renew', coalesce(p_auto_renew, false)));
  return jsonb_build_object('result', 'APPLIED', 'plan', v_plan);
end $$;

-- ---------------------------------------------------------- admin_set_plan
create function public.admin_set_plan(p_email text, p_plan text, p_until timestamptz)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare me uuid := private.admin_guard(); target uuid; v_result text; r public.plans;
  store_active boolean;
begin
  select id into target from auth.users where lower(email) = lower(trim(p_email));
  if target is null then
    v_result := 'NOT_FOUND';
  elsif p_plan is null then
    select * into r from public.plans where user_id = target;
    if found and r.source = 'store' and (r.expires_at is null or r.expires_at > now()) then
      -- Active paid subscription stays; only the admin grant behind it goes.
      update public.plans set alt_plan = null, alt_source = null, alt_expires_at = null,
        updated_at = now() where user_id = target;
    else
      delete from public.plans where user_id = target;
    end if;
    v_result := 'REVOKED';
  elsif p_plan not in ('student', 'teacher', 'expert')
        or (p_until is not null and p_until <= now()) then
    v_result := 'INVALID';
  else
    select * into r from public.plans where user_id = target;
    store_active := found and r.source = 'store' and (r.expires_at is null or r.expires_at > now());
    if store_active then
      -- Store wins while it lasts; keep the grant only if it outlasts it.
      if p_until is null or r.expires_at is null or p_until > r.expires_at then
        update public.plans set alt_plan = p_plan, alt_source = 'admin', alt_expires_at = p_until,
          updated_at = now() where user_id = target;
      end if;
    else
      insert into public.plans (user_id, plan, source, platform, expires_at, auto_renew, note, updated_at)
      values (target, p_plan, 'admin', 'other', p_until, false, 'admin panel', now())
      on conflict (user_id) do update
        set plan = excluded.plan, source = 'admin', platform = 'other', product_id = null,
            original_transaction_id = null, started_at = now(), expires_at = excluded.expires_at,
            auto_renew = false, note = 'admin panel', alt_plan = null, alt_source = null,
            alt_expires_at = null, updated_at = now();
    end if;
    v_result := 'GRANTED';
  end if;
  perform private.plan_event(target, me, 'ADMIN_' || v_result, p_plan, 'admin', p_until, '{}'::jsonb);
  perform private.admin_log(me, 'PLAN_SET', 'user', target::text,
    jsonb_build_object('plan', p_plan, 'until', p_until, 'result', v_result));
  return jsonb_build_object('result', v_result);
end $$;

-- --------------------------------------------------------- admin_list_plans
create function public.admin_list_plans(p_query text default null, p_limit int default 50)
returns jsonb language plpgsql stable security definer set search_path = '' as $$
declare me uuid := private.admin_guard(); v_lim int := least(greatest(coalesce(p_limit, 50), 1), 200);
  q text := lower(trim(coalesce(p_query, '')));
begin
  return coalesce((select jsonb_agg(to_jsonb(x) order by x.updated_at desc) from (
    select u.email, e->>'plan' as plan, e->>'source' as source, e->'expires_at' as expires_at,
           p.updated_at
      from public.plans p
      join auth.users u on u.id = p.user_id
      cross join lateral (select private.plan_effective(p) as e) f
     where e is not null
       and (q = '' or position(q in lower(coalesce(u.email, ''))) > 0)
     order by p.updated_at desc limit v_lim) x), '[]'::jsonb);
end $$;

-- --------------------------------------------------------- admin_plan_stats
create function public.admin_plan_stats() returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare me uuid := private.admin_guard();
begin
  return (with eff as (select private.plan_effective(p) as e from public.plans p)
    select jsonb_build_object(
      'active', jsonb_build_object(
        'student', count(*) filter (where e->>'plan' = 'student'),
        'teacher', count(*) filter (where e->>'plan' = 'teacher'),
        'expert',  count(*) filter (where e->>'plan' = 'expert')),
      'trials_active', count(*) filter (where e->>'source' = 'trial'),
      'store_active',  count(*) filter (where e->>'source' = 'store'),
      'admin_active',  count(*) filter (where e->>'source' = 'admin'))
    from eff where e is not null);
end $$;

-- ---------------------------------------------------------------- grants
revoke execute on function private.plan_effective(public.plans) from public, anon, authenticated;
revoke execute on function private.plan_event(uuid, uuid, text, text, text, timestamptz, jsonb) from public, anon, authenticated;
revoke execute on function public.my_plan(text) from public, anon, authenticated;
revoke execute on function public.plan_claim_trial(text, text) from public, anon, authenticated;
revoke execute on function public.plan_apply_store(uuid, text, text, text, timestamptz, boolean) from public, anon, authenticated;
revoke execute on function public.admin_set_plan(text, text, timestamptz) from public, anon, authenticated;
revoke execute on function public.admin_list_plans(text, int) from public, anon, authenticated;
revoke execute on function public.admin_plan_stats() from public, anon, authenticated;
grant execute on function public.my_plan(text) to authenticated;
grant execute on function public.plan_claim_trial(text, text) to authenticated;
grant execute on function public.plan_apply_store(uuid, text, text, text, timestamptz, boolean) to service_role;
grant execute on function public.admin_set_plan(text, text, timestamptz) to authenticated;
grant execute on function public.admin_list_plans(text, int) to authenticated;
grant execute on function public.admin_plan_stats() to authenticated;
