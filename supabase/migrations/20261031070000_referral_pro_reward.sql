-- «3 do‘st Pro sotib olsa = 1 oy Pro» (egasi qarori 2026-10-31, docs/DECISIONS.md «Taklif mukofoti»).
--
-- * Do‘st hisoblanadi FAQAT serverda tasdiqlangan do‘kon xaridi bilan
--   (plan_apply_store -> private.plan_events 'STORE_APPLIED'); ro‘yxatdan o‘tish hisoblanmaydi.
-- * Purchase hook: AFTER INSERT trigger on private.plan_events (verify-purchase Edge Function
--   faqat plan_apply_store ni chaqiradi, shuning uchun SQL ichida kancha shu yerda). Kancha xatosi
--   xaridni qo‘llashni hech qachon to‘xtatmaydi (exception -> audit 'pro_hook_error').
-- * Har 3 ta (hali mukofotga ishlatilmagan, qaytarilmagan) xaridor -> referrer'ga +30 kun
--   plan 'premium', source 'referral' (mavjud eng uzoq muddatdan boshlab uzaytiriladi).
-- * Refund: private.referral_on_refund / public.referral_purchase_refunded (service_role).
--   Mukofot hali berilmagan bo‘lsa — shunchaki hisoblanmaydi; berilgan bo‘lsa — mukofot
--   REVERSED deb belgilanadi (vaqt avtomatik QAYTARIB OLINMAYDI, admin hal qiladi).
-- * Bir xarid (purchase_ref) bitta xaridorga; o‘z-o‘zini taklif hisoblanmaydi.
-- * Hammasi private.referral_audit ga yoziladi. rewards_enabled=false bo‘lsa hech narsa
--   BERILMAYDI (progress hisoblanadi). Yoqilgandan keyin: public.referral_reward_backfill().
--
-- Rollback:
--   drop trigger if exists fe_referral_pro_purchase on private.plan_events;
--   drop function if exists public.my_referral_reward_progress(), public.referral_purchase_refunded(uuid, text),
--     public.referral_reward_backfill(), private.referral_on_purchase(uuid, text),
--     private.referral_on_refund(uuid, text), private.referral_try_grant(uuid),
--     private.referral_grant_pro_days(uuid, int), private.referral_plan_event_hook();
--   drop table if exists private.referral_purchases, private.referral_pro_rewards;
--   alter table public.referral_config drop column pro_reward_buyers_needed, drop column pro_reward_days;
--   (plans.source/alt_source 'referral' qatorlari avval o‘chirilsin, so‘ng eski constraint qaytariladi.)

-- ---------------------------------------------------------------- plans: yangi manba
alter table public.plans drop constraint plans_source_check,
  add constraint plans_source_check check (source in ('store', 'admin', 'trial', 'referral'));
alter table public.plans drop constraint plans_alt_source_check,
  add constraint plans_alt_source_check check (alt_source in ('admin', 'trial', 'referral'));

-- ---------------------------------------------------------------- config
alter table public.referral_config
  add column pro_reward_buyers_needed int not null default 3 check (pro_reward_buyers_needed between 1 and 20),
  add column pro_reward_days int not null default 30 check (pro_reward_days between 1 and 366);

-- ---------------------------------------------------------------- tables
create table private.referral_pro_rewards (
  id bigint generated always as identity primary key,
  referrer_id uuid not null references auth.users (id) on delete cascade,
  buyers uuid[] not null,
  days int not null,
  granted_until timestamptz,          -- null: referrer allaqachon cheksiz rejada (vaqt qo‘shilmadi)
  status text not null default 'GRANTED' check (status in ('GRANTED', 'REVERSED')),
  granted_at timestamptz not null default now(),
  reversed_at timestamptz,
  reversed_reason text
);
create index referral_pro_rewards_referrer on private.referral_pro_rewards (referrer_id);

create table private.referral_purchases (
  buyer_id uuid primary key references auth.users (id) on delete cascade,
  referrer_id uuid not null references auth.users (id) on delete cascade,
  referral_id bigint,
  purchase_ref text not null check (length(purchase_ref) between 1 and 200),
  status text not null default 'PAID' check (status in ('PAID', 'REFUNDED')),
  counted_at timestamptz not null default now(),
  refunded_at timestamptz,
  reward_id bigint references private.referral_pro_rewards (id) on delete set null,
  check (buyer_id <> referrer_id)
);
create unique index referral_purchases_ref on private.referral_purchases (purchase_ref);
create index referral_purchases_referrer on private.referral_purchases (referrer_id, status);

alter table private.referral_pro_rewards enable row level security;
alter table private.referral_purchases enable row level security;
revoke all on private.referral_pro_rewards, private.referral_purchases from anon, authenticated;

-- ---------------------------------------------------------------- plan berish
-- +p_days kun «premium» (source 'referral'). Yangi muddat qaytariladi (null = cheksiz, o‘zgarmadi).
create function private.referral_grant_pro_days(p_user uuid, p_days int) returns timestamptz
language plpgsql security definer set search_path = '' as $$
declare r public.plans; v_base timestamptz; v_until timestamptz;
  v_primary_active boolean; v_alt_active boolean;
begin
  select * into r from public.plans where user_id = p_user for update;
  if not found or private.plan_effective(r) is null then
    v_until := now() + make_interval(days => p_days);
    insert into public.plans (user_id, plan, source, platform, expires_at, auto_renew, note, updated_at)
    values (p_user, 'premium', 'referral', 'other', v_until, false, 'referral reward', now())
    on conflict (user_id) do update
      set plan = 'premium', source = 'referral', platform = 'other', product_id = null,
          original_transaction_id = null, started_at = now(), expires_at = v_until,
          auto_renew = false, note = 'referral reward', alt_plan = null, alt_source = null,
          alt_expires_at = null, updated_at = now();
    return v_until;
  end if;
  v_primary_active := r.expires_at is null or r.expires_at > now();
  v_alt_active := r.alt_plan is not null and (r.alt_expires_at is null or r.alt_expires_at > now());
  -- Cheksiz (muddatsiz) faol reja bor — qo‘shiladigan vaqt yo‘q.
  if (v_primary_active and r.expires_at is null)
     or (not v_primary_active and v_alt_active and r.alt_expires_at is null) then
    return null;
  end if;
  if v_primary_active and r.source = 'referral' then
    v_until := r.expires_at + make_interval(days => p_days);
    update public.plans set expires_at = v_until, updated_at = now() where user_id = p_user;
    return v_until;
  end if;
  -- Boshqa faol reja (store/admin/trial) bor: referral muddati uning ORQASIDA (alt) turadi.
  v_base := greatest(now(),
    case when v_primary_active then r.expires_at end,
    case when v_alt_active then r.alt_expires_at end);
  v_until := v_base + make_interval(days => p_days);
  -- (Asosiy qator tugagan va alt faol bo‘lsa ham: referral alt ga yoziladi, avvalgi alt auditda qoladi.)
  update public.plans set alt_plan = 'premium', alt_source = 'referral', alt_expires_at = v_until,
    updated_at = now() where user_id = p_user;
  return v_until;
end $$;

-- ---------------------------------------------------------------- mukofot berish
create function private.referral_try_grant(p_referrer uuid) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare cfg public.referral_config; v_pool uuid[]; v_n int := 0; v_rid bigint; v_until timestamptz;
  v_prev jsonb;
begin
  select * into cfg from public.referral_config;
  if not cfg.rewards_enabled then
    return jsonb_build_object('status', 'DISABLED');
  end if;
  loop
    select coalesce(array_agg(x.buyer_id order by x.counted_at, x.buyer_id), '{}') into v_pool
      from (select buyer_id, counted_at from private.referral_purchases
             where referrer_id = p_referrer and status = 'PAID' and reward_id is null
             order by counted_at, buyer_id limit cfg.pro_reward_buyers_needed) x;
    exit when coalesce(cardinality(v_pool), 0) < cfg.pro_reward_buyers_needed;
    select to_jsonb(p) - 'user_id' into v_prev from public.plans p where p.user_id = p_referrer;
    v_until := private.referral_grant_pro_days(p_referrer, cfg.pro_reward_days);
    insert into private.referral_pro_rewards (referrer_id, buyers, days, granted_until)
    values (p_referrer, v_pool, cfg.pro_reward_days, v_until) returning id into v_rid;
    update private.referral_purchases set reward_id = v_rid where buyer_id = any (v_pool);
    perform private.plan_event(p_referrer, null, 'REFERRAL_REWARD', 'premium', 'referral', v_until,
      jsonb_build_object('reward_id', v_rid, 'days', cfg.pro_reward_days));
    perform private.referral_log('pro_reward_granted', p_referrer, null,
      jsonb_build_object('reward_id', v_rid, 'days', cfg.pro_reward_days, 'buyers', v_pool,
        'until', v_until, 'plan_before', v_prev));
    v_n := v_n + 1;
  end loop;
  return jsonb_build_object('status', case when v_n > 0 then 'GRANTED' else 'PROGRESS' end, 'granted', v_n);
end $$;

-- ---------------------------------------------------------------- xarid kanchasi
create function private.referral_on_purchase(p_buyer uuid, p_purchase_ref text) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare r public.referrals; pp private.referral_purchases; v_other uuid;
begin
  if p_buyer is null or length(coalesce(p_purchase_ref, '')) not between 1 and 200 then
    return jsonb_build_object('status', 'INVALID');
  end if;
  select * into r from public.referrals where referred_id = p_buyer and status = 'VALID';
  if not found then return jsonb_build_object('status', 'NO_REFERRAL'); end if;
  if r.referrer_id = p_buyer then
    perform private.referral_log('pro_purchase_self_ignored', p_buyer, r.id);
    return jsonb_build_object('status', 'SELF');
  end if;
  perform pg_advisory_xact_lock(hashtextextended('referral_pro:' || r.referrer_id::text, 0));
  select * into pp from private.referral_purchases where buyer_id = p_buyer for update;
  if found then
    if pp.status = 'PAID' then return jsonb_build_object('status', 'DUPLICATE'); end if;
    if pp.purchase_ref = p_purchase_ref then
      return jsonb_build_object('status', 'DUPLICATE_REFUNDED');
    end if;
    -- Qaytarilgandan keyin YANGI xarid: qayta hisoblanadi (ishlatilgan bo‘lsa reward_id saqlanadi).
    select buyer_id into v_other from private.referral_purchases where purchase_ref = p_purchase_ref;
    if v_other is not null then
      perform private.referral_log('pro_purchase_ref_shared', p_buyer, r.id,
        jsonb_build_object('other_buyer', v_other));
      return jsonb_build_object('status', 'INVALID');
    end if;
    update private.referral_purchases set status = 'PAID', purchase_ref = p_purchase_ref,
      refunded_at = null where buyer_id = p_buyer;
    perform private.referral_log('pro_purchase_recounted', p_buyer, r.id);
  else
    select buyer_id into v_other from private.referral_purchases where purchase_ref = p_purchase_ref;
    if v_other is not null then
      perform private.referral_log('pro_purchase_ref_shared', p_buyer, r.id,
        jsonb_build_object('other_buyer', v_other));
      return jsonb_build_object('status', 'INVALID');
    end if;
    insert into private.referral_purchases (buyer_id, referrer_id, referral_id, purchase_ref)
    values (p_buyer, r.referrer_id, r.id, p_purchase_ref);
    perform private.referral_log('pro_purchase_counted', p_buyer, r.id,
      jsonb_build_object('referrer', r.referrer_id));
  end if;
  return jsonb_build_object('status', 'COUNTED') || private.referral_try_grant(r.referrer_id);
end $$;

-- ---------------------------------------------------------------- refund kanchasi
create function private.referral_on_refund(p_buyer uuid, p_purchase_ref text default null) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare pp private.referral_purchases;
begin
  select * into pp from private.referral_purchases where buyer_id = p_buyer;
  if not found then return jsonb_build_object('status', 'NOT_COUNTED'); end if;
  perform pg_advisory_xact_lock(hashtextextended('referral_pro:' || pp.referrer_id::text, 0));
  select * into pp from private.referral_purchases where buyer_id = p_buyer for update;
  if p_purchase_ref is not null and pp.purchase_ref <> p_purchase_ref then
    return jsonb_build_object('status', 'REF_MISMATCH');
  end if;
  if pp.status = 'REFUNDED' then return jsonb_build_object('status', 'DUPLICATE'); end if;
  update private.referral_purchases set status = 'REFUNDED', refunded_at = now() where buyer_id = p_buyer;
  perform private.referral_log('pro_purchase_refunded', p_buyer, pp.referral_id,
    jsonb_build_object('referrer', pp.referrer_id, 'reward_id', pp.reward_id));
  if pp.reward_id is not null then
    update private.referral_pro_rewards set status = 'REVERSED', reversed_at = now(),
      reversed_reason = 'buyer refund' where id = pp.reward_id and status = 'GRANTED';
    perform private.referral_log('pro_reward_reversed', pp.referrer_id, pp.referral_id,
      jsonb_build_object('reward_id', pp.reward_id, 'buyer', p_buyer,
        'note', 'time NOT clawed back; admin decides'));
    return jsonb_build_object('status', 'REFUNDED_REWARD_FLAGGED', 'reward_id', pp.reward_id);
  end if;
  return jsonb_build_object('status', 'REFUNDED');
end $$;

-- ---------------------------------------------------------------- plan_events trigger
create function private.referral_plan_event_hook() returns trigger
language plpgsql security definer set search_path = '' as $$
declare v_ref text; v_src text;
begin
  if new.action <> 'STORE_APPLIED' or new.user_id is null then return new; end if;
  -- Faqat hozir faol, haqiqiy do‘kon xaridi (eski/tugagan hisobotni tiklash hisoblanmaydi).
  if new.expires_at is null or new.expires_at <= now() then return new; end if;
  begin
    select p.original_transaction_id, p.source into v_ref, v_src
      from public.plans p where p.user_id = new.user_id;
    if v_src = 'store' and v_ref is not null then
      perform private.referral_on_purchase(new.user_id, v_ref);
    end if;
  exception when others then
    perform private.referral_log('pro_hook_error', new.user_id, null,
      jsonb_build_object('sqlstate', sqlstate, 'message', left(sqlerrm, 200)));
  end;
  return new;
end $$;
create trigger fe_referral_pro_purchase after insert on private.plan_events
  for each row execute function private.referral_plan_event_hook();

-- ---------------------------------------------------------------- public RPC
create function public.my_referral_reward_progress() returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare me uuid := auth.uid(); cfg public.referral_config; v_pool bigint;
begin
  if me is null then raise exception 'not signed in'; end if;
  select * into cfg from public.referral_config;
  select count(*) into v_pool from private.referral_purchases p
   where p.referrer_id = me and p.status = 'PAID' and p.reward_id is null;
  -- Mukofotlar KUMULYATIV, cheksiz: har 3 xaridor = +30 kun. next_reward_at = keyingi mukofotgacha
  -- yana nechta xaridor kerak (1..needed).
  return jsonb_build_object(
    'qualified_buyers', v_pool,
    'needed', cfg.pro_reward_buyers_needed,
    'next_reward_at', cfg.pro_reward_buyers_needed - (v_pool % cfg.pro_reward_buyers_needed),
    'rewards_granted', (select count(*) from private.referral_pro_rewards w where w.referrer_id = me),
    'rewards_enabled', cfg.rewards_enabled);
end $$;

-- service_role: store server notification (REFUND / REVOKE) shu yerga ulanadi.
create function public.referral_purchase_refunded(p_buyer uuid, p_purchase_ref text default null)
returns jsonb language sql security definer set search_path = '' as $$
  select private.referral_on_refund(p_buyer, p_purchase_ref)
$$;

-- service_role: rewards_enabled yoqilgandan keyin yig‘ilib qolgan mukofotlarni beradi.
create function public.referral_reward_backfill() returns int
language plpgsql security definer set search_path = '' as $$
declare v_ref uuid; v_total int := 0; v_res jsonb;
begin
  for v_ref in select distinct referrer_id from private.referral_purchases
                where status = 'PAID' and reward_id is null loop
    perform pg_advisory_xact_lock(hashtextextended('referral_pro:' || v_ref::text, 0));
    v_res := private.referral_try_grant(v_ref);
    v_total := v_total + coalesce((v_res->>'granted')::int, 0);
  end loop;
  return v_total;
end $$;

-- ---------------------------------------------------------------- grants
revoke execute on function private.referral_grant_pro_days(uuid, int) from public, anon, authenticated;
revoke execute on function private.referral_try_grant(uuid) from public, anon, authenticated;
revoke execute on function private.referral_on_purchase(uuid, text) from public, anon, authenticated;
revoke execute on function private.referral_on_refund(uuid, text) from public, anon, authenticated;
revoke execute on function private.referral_plan_event_hook() from public, anon, authenticated;
revoke execute on function public.my_referral_reward_progress() from public, anon, authenticated;
revoke execute on function public.referral_purchase_refunded(uuid, text) from public, anon, authenticated;
revoke execute on function public.referral_reward_backfill() from public, anon, authenticated;
grant execute on function public.my_referral_reward_progress() to authenticated;
grant execute on function public.referral_purchase_refunded(uuid, text) to service_role;
grant execute on function public.referral_reward_backfill() to service_role;
