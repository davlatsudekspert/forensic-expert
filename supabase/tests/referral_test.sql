-- Referral + FORENSIC Credits security tests (run after security_test.sql,
-- which grants table privileges to `authenticated` like Supabase does: RLS
-- must still block every direct client access).
\set ON_ERROR_STOP 1
reset role;
grant select, insert, update, delete on all tables in schema public to authenticated;

create function pg_temp.as_user(uid text) returns void language plpgsql as $$
begin
  perform set_config('request.jwt.claim.sub', uid, false);
  perform set_config('role', 'authenticated', false);
end $$;
create function pg_temp.expect_error(q text, label text) returns void language plpgsql as $$
begin
  begin execute q; exception when others then
    raise notice 'PASS (blocked): %', label; return; end;
  raise exception 'FAIL (allowed): %', label;
end $$;
create function pg_temp.check(ok boolean, label text) returns void language plpgsql as $$
begin
  if not coalesce(ok, false) then raise exception 'FAIL: %', label; end if;
  raise notice 'PASS: %', label;
end $$;

-- Users: A referrer, B/C/G new, D old account, F code guesser.
insert into auth.users (id, email, created_at, email_confirmed_at) values
 ('10000000-0000-0000-0000-00000000000a', 'ref-a@x', now(), now()),
 ('10000000-0000-0000-0000-00000000000b', 'ref-b@x', now(), null),
 ('10000000-0000-0000-0000-00000000000c', 'ref-c@x', now(), now()),
 ('10000000-0000-0000-0000-00000000000d', 'ref-d@x', now() - interval '60 days', now()),
 ('10000000-0000-0000-0000-00000000000f', 'ref-f@x', now(), now()),
 ('10000000-0000-0000-0000-000000000011', 'ref-g@x', now(), null);
grant select on auth.users to authenticated;

-- 1) Unique server-generated code, stable per account.
select pg_temp.as_user('10000000-0000-0000-0000-00000000000a');
create temp table a_code as select referral_dashboard()->>'code' as code;
select pg_temp.check((select code from a_code) ~ '^[A-HJ-NP-Z2-9]{8}$', 'code format (no 0/O/1/I)');
select pg_temp.check((select referral_dashboard()->>'code') = (select code from a_code), 'code stable per account');
select pg_temp.as_user('10000000-0000-0000-0000-00000000000c');
create temp table c_code as select referral_dashboard()->>'code' as code;
select pg_temp.check((select code from c_code) <> (select code from a_code), 'codes unique per account');
reset role;
select pg_temp.check((select count(*) = count(distinct code) from referral_codes), 'UNIQUE constraint on codes');
grant select on a_code, c_code to authenticated;

-- 2) Self-referral blocked.
select pg_temp.as_user('10000000-0000-0000-0000-00000000000a');
select pg_temp.check(claim_referral((select code from a_code)) = 'SELF_REFERRAL', 'self-referral blocked');

-- 3) Unverified signup → PENDING_VERIFICATION, not counted as verified.
select pg_temp.as_user('10000000-0000-0000-0000-00000000000b');
select pg_temp.check(claim_referral(lower((select code from a_code))) = 'PENDING_VERIFICATION', 'unverified signup is pending');
select pg_temp.as_user('10000000-0000-0000-0000-00000000000a');
select pg_temp.check((select (d->>'joined')::int = 1 and (d->>'pending')::int = 1 and (d->>'verified')::int = 0
  from (select referral_dashboard() d) x), 'dashboard: 1 joined, 1 pending, 0 verified');

-- 4) Email confirmed → VALID (server trigger).
reset role;
update auth.users set email_confirmed_at = now() where id = '10000000-0000-0000-0000-00000000000b';
select pg_temp.check((select status = 'VALID' from referrals where referred_id = '10000000-0000-0000-0000-00000000000b'), 'confirmed email validates referral');

-- 5) Duplicate / second referrer blocked; one referrer per user.
select pg_temp.as_user('10000000-0000-0000-0000-00000000000b');
select pg_temp.check(claim_referral((select code from c_code)) = 'ALREADY_ATTRIBUTED', 'second referrer blocked');
select pg_temp.check(claim_referral((select code from a_code)) = 'ALREADY_ATTRIBUTED', 'duplicate claim blocked');
reset role;
select pg_temp.check((select count(*) = 1 from referrals where referred_id = '10000000-0000-0000-0000-00000000000b'), 'exactly one referrer');
select pg_temp.expect_error($q$insert into referrals(referrer_id, referred_id, code, status) values
  ('10000000-0000-0000-0000-00000000000c','10000000-0000-0000-0000-00000000000b','AAAAAAAA','VALID')$q$, 'UNIQUE referred_id at DB level');

-- 6) Circular A<->B blocked (B invites A).
select pg_temp.as_user('10000000-0000-0000-0000-00000000000b');
create temp table b_code as select referral_dashboard()->>'code' as code;
grant select on b_code to authenticated;
select pg_temp.as_user('10000000-0000-0000-0000-00000000000a');
select pg_temp.check(claim_referral((select code from b_code)) = 'NOT_ELIGIBLE', 'circular referral blocked');

-- 7) Existing (old) account cannot be attributed.
select pg_temp.as_user('10000000-0000-0000-0000-00000000000d');
select pg_temp.check(claim_referral((select code from a_code)) = 'NOT_ELIGIBLE', 'old account not eligible');

-- 8) Deleted & recreated account abuse blocked.
reset role;
insert into auth.users (id, email) values ('10000000-0000-0000-0000-000000000020', 'again@x');
update private.account_email_history set first_seen_at = now() - interval '3 days'
 where email_hash = private.email_hash('again@x');
delete from auth.users where id = '10000000-0000-0000-0000-000000000020';
insert into auth.users (id, email, email_confirmed_at) values ('10000000-0000-0000-0000-000000000021', 'Again@x', now());
select pg_temp.as_user('10000000-0000-0000-0000-000000000021');
select pg_temp.check(claim_referral((select code from a_code)) = 'NOT_ELIGIBLE', 'recreated account blocked');

-- 9) Invalid / unknown codes; brute-force attempt limit.
select pg_temp.as_user('10000000-0000-0000-0000-00000000000f');
select pg_temp.check(claim_referral('not a code') = 'INVALID_CODE', 'malformed code');
select pg_temp.check(claim_referral('ZZZZZZZZ') = 'INVALID_CODE', 'unknown code');
select claim_referral('ZZZZZZZ' || n::text) from generate_series(2, 9) n;
select pg_temp.check(claim_referral((select code from a_code)) = 'RATE_LIMITED', 'claim attempts rate-limited');

-- 10) Direct client access is blocked by RLS (even with table grants).
select pg_temp.as_user('10000000-0000-0000-0000-00000000000b');
select pg_temp.check((select count(*) = 0 from referrals), 'referrals not readable by clients');
select pg_temp.check((select count(*) = 0 from referral_codes), 'other codes not enumerable');
select pg_temp.check((select count(*) = 0 from referral_config), 'config not client-readable');
select pg_temp.expect_error($q$insert into referrals(referrer_id, referred_id, code, status) values
  ('10000000-0000-0000-0000-00000000000b','10000000-0000-0000-0000-00000000000f','AAAAAAAA','VALID')$q$, 'client insert of referral');
select pg_temp.expect_error($q$insert into referral_rewards(referrer_id, reward_percent, purchase_amount_minor, reward_amount_minor, currency, status, source_transaction)
  values ('10000000-0000-0000-0000-00000000000b', 100, 1000, 1000, 'USD', 'APPROVED', 'fake-tx-1')$q$, 'client write of approved reward');
select pg_temp.expect_error($q$select award_referral_reward('10000000-0000-0000-0000-00000000000b','gp:FAKE-1',1000,'USD')$q$, 'client calls award function');
select pg_temp.expect_error($q$select set_referral_reward_status('gp:FAKE-1','APPROVED')$q$, 'client approves reward');
update referral_config set reward_percent = 50;
select pg_temp.expect_error($q$insert into referral_config default values$q$, 'client inserts config');
update referrals set referrer_id = '10000000-0000-0000-0000-00000000000f';
reset role;
select pg_temp.check((select referrer_id = '10000000-0000-0000-0000-00000000000a' from referrals
  where referred_id = '10000000-0000-0000-0000-00000000000b'), 'client cannot rewrite attribution');
select pg_temp.check((select count(*) = 1 and min(reward_percent) = 10 from referral_config), 'client cannot change reward config');
select pg_temp.expect_error($q$update referrals set referrer_id = '10000000-0000-0000-0000-00000000000c'
  where referred_id = '10000000-0000-0000-0000-00000000000b'$q$, 'attribution immutable (trigger)');
set role anon;
select pg_temp.expect_error($q$select referral_dashboard()$q$, 'anon dashboard');
reset role;

-- 11) Rewards: disabled until paid services launch; no reward for signup.
select pg_temp.check((select count(*) = 0 from referral_rewards), 'no reward for registration');
set role service_role;
select pg_temp.check(award_referral_reward('10000000-0000-0000-0000-00000000000b','gp:ORDER-0001',1000,'USD')->>'status' = 'DISABLED', 'rewards disabled by default');
reset role;
update referral_config set rewards_enabled = true;
set role service_role;
-- 10 % of an eligible $10.00 purchase = $1.00 credit (minor units).
select pg_temp.check((select r->>'status' = 'PENDING' and (r->>'reward_amount_minor')::bigint = 100
  from (select award_referral_reward('10000000-0000-0000-0000-00000000000b','gp:ORDER-0001',1000,'USD') r) x), '10% reward calculated');
select pg_temp.check(award_referral_reward('10000000-0000-0000-0000-00000000000b','gp:ORDER-0001',1000,'USD')->>'status' = 'DUPLICATE', 'replayed purchase idempotent');
select pg_temp.check(award_referral_reward('10000000-0000-0000-0000-00000000000b','gp:ORDER-0002',0,'USD')->>'status' = 'INVALID', 'zero purchase rejected');
select pg_temp.check(award_referral_reward('10000000-0000-0000-0000-00000000000b','gp:ORDER-0003',-500,'USD')->>'status' = 'INVALID', 'negative purchase rejected');
select pg_temp.check(award_referral_reward('10000000-0000-0000-0000-00000000000b','gp:ORDER-0004',1000,'usd!')->>'status' = 'INVALID', 'bad currency rejected');
select pg_temp.check(award_referral_reward('10000000-0000-0000-0000-00000000000b','',1000,'USD')->>'status' = 'INVALID', 'missing transaction rejected');
select pg_temp.check(award_referral_reward('10000000-0000-0000-0000-00000000000d','gp:ORDER-0005',1000,'USD')->>'status' = 'NO_REFERRAL', 'buyer without referral');
reset role;
-- Pending (unverified) referral earns nothing.
select pg_temp.as_user('10000000-0000-0000-0000-000000000011');
select pg_temp.check(claim_referral((select code from c_code)) = 'PENDING_VERIFICATION', 'G pending');
reset role; set role service_role;
select pg_temp.check(award_referral_reward('10000000-0000-0000-0000-000000000011','gp:ORDER-0006',1000,'USD')->>'status' = 'NO_REFERRAL', 'unverified referral earns nothing');
reset role;
-- Percentage is server-configurable (no app update).
update referral_config set reward_percent = 15;
set role service_role;
select pg_temp.check((award_referral_reward('10000000-0000-0000-0000-00000000000b','as:TX-0007',1999,'USD')->>'reward_amount_minor')::bigint = 299, 'configured 15% (floor)');
-- Approve / reverse transitions.
select pg_temp.check(set_referral_reward_status('gp:ORDER-0001','APPROVED') = 'APPROVED', 'approve reward');
select pg_temp.expect_error($q$select set_referral_reward_status('gp:ORDER-0001','PENDING')$q$, 'approved cannot go back to pending');
select pg_temp.check(set_referral_reward_status('as:TX-0007','REVERSED') = 'REVERSED', 'refund reverses reward');
select pg_temp.expect_error($q$select set_referral_reward_status('as:TX-0007','APPROVED')$q$, 'reversed cannot be re-approved');
reset role;
update referral_config set reward_percent = 10;
select pg_temp.expect_error($q$update referral_config set reward_percent = 90$q$, 'percent bounded (<=50)');

-- 12) Dashboard: aggregate only, no referred identities.
select pg_temp.as_user('10000000-0000-0000-0000-00000000000a');
select pg_temp.check((select (d->>'verified')::int = 1 and (d->>'credits_earned_minor')::bigint = 100
  and (d->>'credits_pending_minor')::bigint = 0 and (d->>'reward_percent')::numeric = 10
  and d::text not like '%@%' and d::text not like '%10000000-0000-0000-0000-00000000000b%'
  from (select referral_dashboard() d) x), 'dashboard aggregates, no referred identity');

-- 13) Referrer daily cap.
reset role;
update referral_config set max_valid_per_referrer_per_day = 2;
insert into auth.users (id, email, email_confirmed_at) values ('10000000-0000-0000-0000-000000000030', 'cap@x', now());
select pg_temp.as_user('10000000-0000-0000-0000-000000000030');
select pg_temp.check(claim_referral((select code from c_code)) = 'VALID', 'C second referral ok');
reset role;
insert into auth.users (id, email, email_confirmed_at) values ('10000000-0000-0000-0000-000000000031', 'cap2@x', now());
select pg_temp.as_user('10000000-0000-0000-0000-000000000031');
select pg_temp.check(claim_referral((select code from c_code)) = 'RATE_LIMITED', 'referrer daily cap');
reset role;

-- 14) Audit trail exists for attempts and rewards.
select pg_temp.check((select count(*) >= 10 from private.referral_audit), 'audit trail written');
select pg_temp.check((select count(*) = 1 from private.referral_audit where event = 'reward_created'
  and (detail->>'amount_minor')::bigint = 100), 'reward audited');

-- 15) Account deletion: referred user deleted → attribution removed, earned
-- credit kept without identity; referrer deleted → code/credits removed.
delete from auth.users where id = '10000000-0000-0000-0000-00000000000b';
select pg_temp.check((select count(*) = 0 from referrals where referred_id = '10000000-0000-0000-0000-00000000000b'), 'referred deletion removes attribution');
select pg_temp.check((select count(*) = 2 and bool_and(referred_user_id is null) from referral_rewards), 'rewards keep no deleted identity');
delete from auth.users where id = '10000000-0000-0000-0000-00000000000a';
select pg_temp.check((select count(*) = 0 from referral_codes where user_id = '10000000-0000-0000-0000-00000000000a')
  and (select count(*) = 0 from referral_rewards), 'referrer deletion removes code and credits');
select pg_temp.check((select count(*) > 0 from private.account_email_history where email_hash = private.email_hash('ref-b@x')),
  'salted email hash kept to block re-registration abuse');

select 'ALL REFERRAL TESTS PASSED' as result;
