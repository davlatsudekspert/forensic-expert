-- Premium (hammasi ochiq) rejasi: plans.plan / alt_plan / trial_devices.plan
-- qiymatlari ro'yxatiga 'premium' qo'shiladi; mahsulot: fe_premium_{monthly,yearly}.
-- Qo'shimcha o'zgarish (additive): jadval ustunlari va funksiyalar imzosi o'zgarmaydi.
-- Rollback:
--   alter table public.plans drop constraint plans_plan_check,
--     add constraint plans_plan_check check (plan in ('student','teacher','expert')); (va hokazo;
--   'premium' qatorlari avval o'chirilishi kerak) — funksiyalarni 20261025000000_plans.sql dan qayta yarating.

alter table public.plans drop constraint plans_plan_check,
  add constraint plans_plan_check check (plan in ('student', 'teacher', 'expert', 'premium'));
alter table public.plans drop constraint plans_alt_plan_check,
  add constraint plans_alt_plan_check check (alt_plan in ('student', 'teacher', 'expert', 'premium'));
alter table public.trial_devices drop constraint trial_devices_plan_check,
  add constraint trial_devices_plan_check check (plan in ('student', 'teacher', 'expert', 'premium'));

create or replace function public.my_plan(p_device_hash text default null) returns jsonb
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
create or replace function public.plan_claim_trial(p_device_hash text, p_plan text) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare me uuid := auth.uid(); r public.plans; v_exp timestamptz := now() + interval '30 days';
begin
  if me is null then raise exception 'not signed in'; end if;
  if p_device_hash is null or p_device_hash !~ '^[0-9a-f]{64}$'
     or p_plan is null or p_plan not in ('student', 'teacher', 'expert', 'premium') then
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
create or replace function public.plan_apply_store(p_user_id uuid, p_platform text, p_product_id text,
  p_original_transaction_id text, p_expires_at timestamptz, p_auto_renew boolean) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare v_plan text; r public.plans; v_alt_plan text; v_alt_src text; v_alt_exp timestamptz;
begin
  if p_user_id is null or not exists (select 1 from auth.users where id = p_user_id)
     or p_platform is null or p_platform not in ('ios', 'android')
     or p_product_id is null or p_product_id !~ '^fe_(student|teacher|expert|premium)_(monthly|yearly)$'
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
create or replace function public.admin_set_plan(p_email text, p_plan text, p_until timestamptz)
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
  elsif p_plan not in ('student', 'teacher', 'expert', 'premium')
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
create or replace function public.admin_list_plans(p_query text default null, p_limit int default 50)
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
create or replace function public.admin_plan_stats() returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare me uuid := private.admin_guard();
begin
  return (with eff as (select private.plan_effective(p) as e from public.plans p)
    select jsonb_build_object(
      'active', jsonb_build_object(
        'student', count(*) filter (where e->>'plan' = 'student'),
        'teacher', count(*) filter (where e->>'plan' = 'teacher'),
        'expert',  count(*) filter (where e->>'plan' = 'expert'),
        'premium', count(*) filter (where e->>'plan' = 'premium')),
      'trials_active', count(*) filter (where e->>'source' = 'trial'),
      'store_active',  count(*) filter (where e->>'source' = 'store'),
      'admin_active',  count(*) filter (where e->>'source' = 'admin'))
    from eff where e is not null);
end $$;

