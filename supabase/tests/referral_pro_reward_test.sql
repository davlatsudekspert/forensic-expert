-- «3 do‘st Pro sotib olsa = 1 oy Pro» (20261031070000_referral_pro_reward.sql).
-- Runs after plans_test.sql. Purchases go through the REAL path: plan_apply_store (service role)
-- -> private.plan_events 'STORE_APPLIED' -> trigger -> private.referral_on_purchase.
\set ON_ERROR_STOP 1
reset role;
select set_config('request.headers', '', false);
create function pg_temp.as_user(uid text) returns void language plpgsql as $$
begin
  perform set_config('request.jwt.claim.sub', uid, false);
  perform set_config('request.jwt.claims', '{}', false);
  perform set_config('role', 'authenticated', false);
end $$;
create function pg_temp.as_anon() returns void language plpgsql as $$
begin
  perform set_config('request.jwt.claim.sub', '', false);
  perform set_config('request.jwt.claims', '{}', false);
  perform set_config('role', 'anon', false);
end $$;
create function pg_temp.as_service() returns void language plpgsql as $$
begin
  perform set_config('request.jwt.claim.sub', '', false);
  perform set_config('request.jwt.claims', '{"role":"service_role"}', false);
  perform set_config('role', 'service_role', false);
end $$;
create function pg_temp.expect_error(q text, label text) returns void language plpgsql as $$
begin
  begin execute q; exception when others then
    raise notice 'PASS (blocked): % [%]', label, sqlerrm; return; end;
  raise exception 'FAIL (allowed): %', label;
end $$;
create function pg_temp.check(ok boolean, label text) returns void language plpgsql as $$
begin
  if not coalesce(ok, false) then raise exception 'FAIL: %', label; end if;
  raise notice 'PASS: %', label;
end $$;
-- Store purchase of a premium monthly subscription (service role path).
create function pg_temp.buy(uid text, ref text) returns jsonb language sql as $$
  select public.plan_apply_store(uid::uuid, 'ios', 'fe_premium_monthly', ref, now() + interval '30 days', true)
$$;
-- Superuser-side readers (private tables).
create function pg_temp.pool(uid text) returns bigint language sql security definer as $$
  select count(*) from private.referral_purchases where referrer_id = uid::uuid and status = 'PAID' and reward_id is null $$;
create function pg_temp.rewards(uid text, st text default null) returns bigint language sql security definer as $$
  select count(*) from private.referral_pro_rewards where referrer_id = uid::uuid and (st is null or status = st) $$;
create function pg_temp.audits(ev text) returns bigint language sql security definer as $$
  select count(*) from private.referral_audit where event = ev $$;
create function pg_temp.plan_of(uid text) returns public.plans language sql security definer as $$
  select * from public.plans where user_id = uid::uuid $$;
grant execute on function pg_temp.as_user(text), pg_temp.as_anon(), pg_temp.as_service(),
  pg_temp.expect_error(text, text), pg_temp.check(boolean, text), pg_temp.buy(text, text),
  pg_temp.pool(text), pg_temp.rewards(text, text), pg_temp.audits(text), pg_temp.plan_of(text)
  to anon, authenticated, service_role;

-- Users: referrers r1..r5, buyers b01..b20, stranger s1 (no referral).
insert into auth.users (id, email, created_at, email_confirmed_at)
select ('72000000-0000-0000-0000-0000000001' || lpad(i::text, 2, '0'))::uuid, 'rpr' || i || '@x', now(), now()
  from generate_series(1, 5) i;
insert into auth.users (id, email, created_at, email_confirmed_at)
select ('72000000-0000-0000-0000-0000000002' || lpad(i::text, 2, '0'))::uuid, 'rpb' || i || '@x', now(), now()
  from generate_series(1, 20) i;
insert into auth.users (id, email, created_at, email_confirmed_at)
values ('72000000-0000-0000-0000-000000000301', 'rps1@x', now(), now());
-- r1 <- b01..b08, r2 <- b09..b12, r3 <- b13..b15, r4 <- b16..b18, r5 <- b19 (PENDING_VERIFICATION b20)
insert into public.referrals (referrer_id, referred_id, code, status, validated_at)
select ('72000000-0000-0000-0000-0000000001' || lpad(case when i<=8 then 1 when i<=12 then 2 when i<=15 then 3 when i<=18 then 4 else 5 end::text, 2, '0'))::uuid,
       ('72000000-0000-0000-0000-0000000002' || lpad(i::text, 2, '0'))::uuid,
       'CODE' || lpad(i::text, 4, '0'), 'VALID', now()
  from generate_series(1, 19) i;
insert into public.referrals (referrer_id, referred_id, code, status)
values ('72000000-0000-0000-0000-000000000105', '72000000-0000-0000-0000-000000000220', 'CODE0020', 'PENDING_VERIFICATION');
update public.referral_config set rewards_enabled = true;

-- ============================================================ 2 buyers -> no reward
select pg_temp.as_service();
select pg_temp.buy('72000000-0000-0000-0000-000000000201', 'tx-b01');
select pg_temp.buy('72000000-0000-0000-0000-000000000202', 'tx-b02');
reset role;
select pg_temp.check(pg_temp.pool('72000000-0000-0000-0000-000000000101') = 2, '2 buyers: pool = 2');
select pg_temp.check(pg_temp.rewards('72000000-0000-0000-0000-000000000101') = 0
  and pg_temp.plan_of('72000000-0000-0000-0000-000000000101') is null, '2 buyers: no reward, referrer has no plan');
select pg_temp.as_user('72000000-0000-0000-0000-000000000101');
select pg_temp.check(public.my_referral_reward_progress() =
  '{"qualified_buyers":2,"needed":3,"next_reward_at":1,"rewards_granted":0,"rewards_enabled":true}'::jsonb,
  'progress RPC: 2/3, 0 granted, enabled');

-- ============================================================ duplicate purchase event
select pg_temp.as_service();
select pg_temp.buy('72000000-0000-0000-0000-000000000201', 'tx-b01');   -- renewal / re-verify
select pg_temp.buy('72000000-0000-0000-0000-000000000201', 'tx-b01');
reset role;
select pg_temp.check(pg_temp.pool('72000000-0000-0000-0000-000000000101') = 2
  and pg_temp.audits('pro_purchase_counted') = 2, 'duplicate purchase event: still 2 buyers, counted audit once per buyer');
select pg_temp.check((select count(*) from private.plan_events where action = 'STORE_APPLIED') >= 4,
  'duplicate purchase event: STORE_APPLIED events were really written (hook ran each time)');

-- ============================================================ 3rd buyer -> +30 days once
select pg_temp.as_service();
select pg_temp.buy('72000000-0000-0000-0000-000000000203', 'tx-b03');
reset role;
select pg_temp.check(pg_temp.rewards('72000000-0000-0000-0000-000000000101', 'GRANTED') = 1
  and pg_temp.pool('72000000-0000-0000-0000-000000000101') = 0, '3rd buyer: exactly 1 reward, pool consumed');
select pg_temp.check((pg_temp.plan_of('72000000-0000-0000-0000-000000000101')).plan = 'premium'
  and (pg_temp.plan_of('72000000-0000-0000-0000-000000000101')).source = 'referral'
  and (pg_temp.plan_of('72000000-0000-0000-0000-000000000101')).expires_at
      between now() + interval '29 days 23 hours' and now() + interval '30 days 1 hour',
  '3rd buyer: referrer has premium/referral plan for ~30 days');
select pg_temp.check(pg_temp.audits('pro_reward_granted') = 1
  and (select count(*) from private.plan_events where action = 'REFERRAL_REWARD') = 1,
  '3rd buyer: reward audited (referral_audit + plan_events)');
select pg_temp.as_user('72000000-0000-0000-0000-000000000101');
select pg_temp.check(public.my_plan(null)->>'plan' = 'premium' and public.my_plan(null)->>'source' = 'referral',
  'referrer: my_plan shows premium via referral');
select pg_temp.check(public.my_referral_reward_progress() =
  '{"qualified_buyers":0,"needed":3,"next_reward_at":3,"rewards_granted":1,"rewards_enabled":true}'::jsonb, 'progress RPC after reward');
-- repeat of 3rd purchase: no second reward, expiry unchanged
reset role;
create temp table t_exp as select (pg_temp.plan_of('72000000-0000-0000-0000-000000000101')).expires_at as e;
select pg_temp.as_service();
select pg_temp.buy('72000000-0000-0000-0000-000000000203', 'tx-b03');
reset role;
select pg_temp.check(pg_temp.rewards('72000000-0000-0000-0000-000000000101') = 1
  and (pg_temp.plan_of('72000000-0000-0000-0000-000000000101')).expires_at = (select e from t_exp),
  'repeat of 3rd purchase: idempotent (1 reward, expiry unchanged)');

-- ============================================================ refund before reward (r2: b09..b12)
select pg_temp.as_service();
select pg_temp.buy('72000000-0000-0000-0000-000000000209', 'tx-b09');
select pg_temp.buy('72000000-0000-0000-0000-000000000210', 'tx-b10');
select public.referral_purchase_refunded('72000000-0000-0000-0000-000000000209', 'tx-b09');
select pg_temp.buy('72000000-0000-0000-0000-000000000211', 'tx-b11');
reset role;
select pg_temp.check(pg_temp.pool('72000000-0000-0000-0000-000000000102') = 2
  and pg_temp.rewards('72000000-0000-0000-0000-000000000102') = 0
  and pg_temp.plan_of('72000000-0000-0000-0000-000000000102') is null,
  'refund before reward: refunded friend does not count (2 paid + 1 refunded) -> no reward');
select pg_temp.check(pg_temp.audits('pro_purchase_refunded') = 1, 'refund before reward: audited');
select pg_temp.as_service();
select public.referral_purchase_refunded('72000000-0000-0000-0000-000000000209', 'tx-b09');  -- duplicate refund
select pg_temp.buy('72000000-0000-0000-0000-000000000209', 'tx-b09');     -- same refunded tx again: stays refunded
reset role;
select pg_temp.check(pg_temp.pool('72000000-0000-0000-0000-000000000102') = 2
  and pg_temp.audits('pro_purchase_refunded') = 1, 'refund: duplicate refund / replay of refunded tx is a no-op');
select pg_temp.as_service();
select pg_temp.buy('72000000-0000-0000-0000-000000000209', 'tx-b09y');     -- buys again (new transaction)
reset role;
select pg_temp.check(pg_temp.rewards('72000000-0000-0000-0000-000000000102', 'GRANTED') = 1,
  'refunded friend buys again with a new transaction -> counts again, 3 paid -> reward');

-- ============================================================ refund after reward (r1: b01 refunded)
select pg_temp.as_service();
select public.referral_purchase_refunded('72000000-0000-0000-0000-000000000201', 'tx-b01');
reset role;
select pg_temp.check(pg_temp.rewards('72000000-0000-0000-0000-000000000101', 'REVERSED') = 1
  and (pg_temp.plan_of('72000000-0000-0000-0000-000000000101')).expires_at = (select e from t_exp),
  'refund after reward: reward marked REVERSED, time NOT clawed back');
select pg_temp.check(pg_temp.audits('pro_reward_reversed') = 1, 'refund after reward: reversal audited');
select pg_temp.as_service();
select pg_temp.buy('72000000-0000-0000-0000-000000000204', 'tx-b04');
select pg_temp.buy('72000000-0000-0000-0000-000000000205', 'tx-b05');
reset role;
select pg_temp.check(pg_temp.pool('72000000-0000-0000-0000-000000000101') = 2
  and pg_temp.rewards('72000000-0000-0000-0000-000000000101') = 1,
  'after reversed reward: consumed friends are not reused (new friends b04,b05 = 2/3)');
select pg_temp.as_service();
select pg_temp.buy('72000000-0000-0000-0000-000000000206', 'tx-b06');
reset role;
select pg_temp.check(pg_temp.rewards('72000000-0000-0000-0000-000000000101') = 2
  and (pg_temp.plan_of('72000000-0000-0000-0000-000000000101')).expires_at
      between (select e from t_exp) + interval '29 days 23 hours' and (select e from t_exp) + interval '30 days 1 hour',
  '2nd reward extends from existing referral expiry (+30 days on top)');

-- ============================================================ self-referral ignored
select pg_temp.expect_error($q$insert into public.referrals (referrer_id, referred_id, code, status)
  values ('72000000-0000-0000-0000-000000000301', '72000000-0000-0000-0000-000000000301', 'SELFSELF', 'VALID')$q$,
  'self-referral row cannot exist (CHECK)');
select pg_temp.check(private.referral_on_purchase('72000000-0000-0000-0000-000000000301', 'tx-self')->>'status' = 'NO_REFERRAL',
  'stranger / self purchase: NO_REFERRAL, not counted');
select pg_temp.as_service();
select pg_temp.buy('72000000-0000-0000-0000-000000000301', 'tx-s1');
select pg_temp.buy('72000000-0000-0000-0000-000000000101', 'tx-r1');   -- referrer buys Pro herself
reset role;
select pg_temp.check((select count(*) from private.referral_purchases
  where buyer_id in ('72000000-0000-0000-0000-000000000301', '72000000-0000-0000-0000-000000000101')) = 0,
  'self/unreferred purchases never recorded');
-- Unverified referred account (PENDING_VERIFICATION) purchase is not counted.
select pg_temp.as_service();
select pg_temp.buy('72000000-0000-0000-0000-000000000220', 'tx-b20');
reset role;
select pg_temp.check(pg_temp.pool('72000000-0000-0000-0000-000000000105') = 0, 'PENDING_VERIFICATION friend not counted');
-- One receipt cannot qualify two accounts.
select pg_temp.as_service();
select pg_temp.buy('72000000-0000-0000-0000-000000000219', 'tx-b19');
reset role;
select pg_temp.check(private.referral_on_purchase('72000000-0000-0000-0000-000000000213', 'tx-b19')->>'status' = 'INVALID'
  and pg_temp.pool('72000000-0000-0000-0000-000000000105') = 1, 'shared receipt: only first account counted (unique purchase_ref)');
select pg_temp.check(private.referral_on_purchase('72000000-0000-0000-0000-000000000209', 'tx-b19')->>'status' = 'DUPLICATE',
  'purchase_ref reuse on another referred buyer: no double count');

-- ============================================================ rewards_enabled = false
update public.referral_config set rewards_enabled = false;
select pg_temp.as_service();
select pg_temp.buy('72000000-0000-0000-0000-000000000213', 'tx-b13');
select pg_temp.buy('72000000-0000-0000-0000-000000000214', 'tx-b14');
select pg_temp.buy('72000000-0000-0000-0000-000000000215', 'tx-b15');
reset role;
select pg_temp.check(pg_temp.pool('72000000-0000-0000-0000-000000000103') = 3
  and pg_temp.rewards('72000000-0000-0000-0000-000000000103') = 0
  and pg_temp.plan_of('72000000-0000-0000-0000-000000000103') is null,
  'rewards_enabled=false: progress computed (3), NOTHING granted');
select pg_temp.as_user('72000000-0000-0000-0000-000000000103');
select pg_temp.check(public.my_referral_reward_progress() =
  '{"qualified_buyers":3,"needed":3,"next_reward_at":3,"rewards_granted":0,"rewards_enabled":false}'::jsonb,
  'rewards_enabled=false: RPC reports enabled=false (client hides the line)');
select pg_temp.as_service();
select pg_temp.check(public.referral_reward_backfill() = 0, 'backfill while disabled grants nothing');
reset role;
update public.referral_config set rewards_enabled = true;
select pg_temp.as_service();
select pg_temp.check(public.referral_reward_backfill() = 1, 'enabled later: backfill grants the accumulated reward');
select pg_temp.check(public.referral_reward_backfill() = 0, 'backfill is idempotent');
reset role;
select pg_temp.check(pg_temp.rewards('72000000-0000-0000-0000-000000000103', 'GRANTED') = 1
  and (pg_temp.plan_of('72000000-0000-0000-0000-000000000103')).source = 'referral', 'backfill result: 1 reward + referral plan');

-- ============================================================ referrer already has a store plan
select pg_temp.as_service();
select public.plan_apply_store('72000000-0000-0000-0000-000000000104', 'ios', 'fe_expert_monthly', 'tx-r4', now() + interval '10 days', true);
select pg_temp.buy('72000000-0000-0000-0000-000000000216', 'tx-b16');
select pg_temp.buy('72000000-0000-0000-0000-000000000217', 'tx-b17');
select pg_temp.buy('72000000-0000-0000-0000-000000000218', 'tx-b18');
reset role;
select pg_temp.check((pg_temp.plan_of('72000000-0000-0000-0000-000000000104')).source = 'store'
  and (pg_temp.plan_of('72000000-0000-0000-0000-000000000104')).alt_source = 'referral'
  and (pg_temp.plan_of('72000000-0000-0000-0000-000000000104')).alt_expires_at
      between now() + interval '39 days 23 hours' and now() + interval '40 days 1 hour',
  'referrer with active store plan: referral time queued behind it (store end + 30 days)');
update public.plans set expires_at = now() - interval '1 day' where user_id = '72000000-0000-0000-0000-000000000104';
select pg_temp.as_user('72000000-0000-0000-0000-000000000104');
select pg_temp.check(public.my_plan(null)->>'plan' = 'premium' and public.my_plan(null)->>'source' = 'referral',
  'store plan ended: referral premium takes over');


-- ============================================================ cumulative: 6 buyers -> +60 days, two audit rows
reset role;
insert into auth.users (id, email, created_at, email_confirmed_at)
select ('72000000-0000-0000-0000-0000000004' || lpad(i::text, 2, '0'))::uuid, 'rpc' || i || '@x', now(), now()
  from generate_series(0, 6) i;
insert into public.referrals (referrer_id, referred_id, code, status, validated_at)
select '72000000-0000-0000-0000-000000000400', ('72000000-0000-0000-0000-0000000004' || lpad(i::text, 2, '0'))::uuid,
       'CUMU' || lpad(i::text, 4, '0'), 'VALID', now() from generate_series(1, 6) i;
select pg_temp.as_service();
select pg_temp.buy('72000000-0000-0000-0000-0000000004' || lpad(i::text, 2, '0'), 'tx-cu' || i) from generate_series(1, 6) i;
reset role;
select pg_temp.check(pg_temp.rewards('72000000-0000-0000-0000-000000000400', 'GRANTED') = 2
  and (select count(*) from private.referral_audit where event = 'pro_reward_granted'
        and actor = '72000000-0000-0000-0000-000000000400') = 2, '6 buyers: two rewards, two audit rows');
select pg_temp.check((pg_temp.plan_of('72000000-0000-0000-0000-000000000400')).expires_at
  between now() + interval '59 days 23 hours' and now() + interval '60 days 1 hour', '6 buyers: +60 days total');
select pg_temp.as_user('72000000-0000-0000-0000-000000000400');
select pg_temp.check(public.my_referral_reward_progress() =
  '{"qualified_buyers":0,"needed":3,"next_reward_at":3,"rewards_granted":2,"rewards_enabled":true}'::jsonb, '6 buyers: progress RPC');
reset role;

-- ============================================================ grants / privacy
select pg_temp.as_anon();
select pg_temp.expect_error($q$select public.my_referral_reward_progress()$q$, 'anon: progress RPC');
select pg_temp.as_user('72000000-0000-0000-0000-000000000102');
select pg_temp.expect_error($q$select public.referral_purchase_refunded('72000000-0000-0000-0000-000000000209', null)$q$,
  'authenticated: cannot refund-hook');
select pg_temp.expect_error($q$select public.referral_reward_backfill()$q$, 'authenticated: cannot backfill');
select pg_temp.expect_error($q$select private.referral_on_purchase('72000000-0000-0000-0000-000000000209', 'zzz')$q$,
  'authenticated: private hook not callable');
select pg_temp.expect_error($q$select * from private.referral_purchases$q$, 'authenticated: purchases table hidden');
select pg_temp.expect_error($q$select * from private.referral_pro_rewards$q$, 'authenticated: rewards table hidden');
select pg_temp.check(public.my_referral_reward_progress()->>'rewards_granted' = '1', 'progress RPC shows only own numbers (r2: 1 reward)');
select pg_temp.as_user('72000000-0000-0000-0000-000000000201');
select pg_temp.check(public.my_referral_reward_progress() =
  '{"qualified_buyers":0,"needed":3,"next_reward_at":3,"rewards_granted":0,"rewards_enabled":true}'::jsonb, 'a buyer sees zero progress of others');
reset role;
-- A failing hook must never block a purchase.
alter table private.referral_purchases add constraint tmp_break check (false) not valid;
select pg_temp.as_service();
select pg_temp.check(pg_temp.buy('72000000-0000-0000-0000-000000000212', 'tx-b12')->>'result' = 'APPLIED',
  'hook failure does not block plan_apply_store');
reset role;
alter table private.referral_purchases drop constraint tmp_break;
select pg_temp.check(pg_temp.audits('pro_hook_error') = 1, 'hook error path audited (pro_hook_error)');
\echo ALL referral_pro_reward TESTS PASSED
