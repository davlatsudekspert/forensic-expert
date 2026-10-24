-- Pro 0.4.0 plans (20261025000000_plans.sql): my_plan, trial, store, admin.
-- Runs after admin_extension_test.sql / group_hardest_detail_test.sql.
\set ON_ERROR_STOP 1
reset role;
select set_config('request.headers', '', false);
revoke all on public.plans, public.trial_devices from anon, authenticated;
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
create function pg_temp.expect_42501(q text, label text) returns void language plpgsql as $$
begin
  begin execute q; exception
    when insufficient_privilege then raise notice 'PASS (42501): %', label; return;
    when others then raise exception 'FAIL (wrong error %: %): %', sqlstate, sqlerrm, label;
  end;
  raise exception 'FAIL (allowed): %', label;
end $$;
create function pg_temp.check(ok boolean, label text) returns void language plpgsql as $$
begin
  if not coalesce(ok, false) then raise exception 'FAIL: %', label; end if;
  raise notice 'PASS: %', label;
end $$;
-- Superuser-side helper: move a plan row's expiry (simulates time passing).
create function pg_temp.set_expiry(uid uuid, ts timestamptz) returns void
language sql security definer as $$ update public.plans set expires_at = ts where user_id = uid $$;
create function pg_temp.set_alt_expiry(uid uuid, ts timestamptz) returns void
language sql security definer as $$ update public.plans set alt_expires_at = ts where user_id = uid $$;
create function pg_temp.events(act text) returns bigint
language sql security definer as $$ select count(*) from private.plan_events where action = act $$;
create function pg_temp.audits(act text) returns bigint
language sql security definer as $$ select count(*) from private.admin_audit where action = act $$;
grant execute on function pg_temp.as_user(text), pg_temp.as_anon(), pg_temp.as_service(),
  pg_temp.expect_error(text, text), pg_temp.expect_42501(text, text),
  pg_temp.check(boolean, text), pg_temp.set_expiry(uuid, timestamptz),
  pg_temp.set_alt_expiry(uuid, timestamptz), pg_temp.events(text), pg_temp.audits(text)
  to anon, authenticated, service_role;

insert into auth.users (id, email, created_at, email_confirmed_at) values
 ('71000000-0000-0000-0000-0000000000a1', 'plan-admin@x', now(), now()),
 ('71000000-0000-0000-0000-0000000000b1', 'plan-student@x', now(), now()),
 ('71000000-0000-0000-0000-0000000000b2', 'plan-other@x', now(), now()),
 ('71000000-0000-0000-0000-0000000000b3', 'plan-third@x', now(), now()),
 ('71000000-0000-0000-0000-0000000000b4', 'plan-fourth@x', now(), now());
insert into account_roles (user_id, role, granted_by) values
 ('71000000-0000-0000-0000-0000000000a1', 'identity_admin', null);

-- ============================================================ anon
select pg_temp.as_anon();
select pg_temp.expect_error($q$select public.my_plan(null)$q$, 'anon: my_plan');
select pg_temp.expect_error($q$select public.plan_claim_trial(repeat('a', 64), 'student')$q$, 'anon: plan_claim_trial');
select pg_temp.expect_error($q$select public.admin_plan_stats()$q$, 'anon: admin_plan_stats');
select pg_temp.expect_error($q$select * from public.plans$q$, 'anon: plans table');

-- ============================================================ student
select pg_temp.as_user('71000000-0000-0000-0000-0000000000b1');
select pg_temp.check((public.my_plan(null)->>'plan') is null
  and public.my_plan(null)->'plan' = 'null'::jsonb, 'student: my_plan plan is null');
select pg_temp.check((public.my_plan(null)->>'trial_available')::boolean = false,
  'student: no device hash -> trial_available false');
select pg_temp.check((public.my_plan(repeat('a', 64))->>'trial_available')::boolean,
  'student: fresh device + account -> trial_available true');
select pg_temp.expect_42501($q$select * from public.plans$q$, 'student: plans table not readable');
select pg_temp.expect_42501($q$insert into public.plans (user_id, plan, source)
  values (auth.uid(), 'expert', 'admin')$q$, 'student: cannot write own plan');
select pg_temp.expect_42501($q$select * from public.trial_devices$q$, 'student: trial_devices not readable');
select pg_temp.expect_42501($q$select * from private.plan_events$q$, 'student: plan_events not readable');
select pg_temp.expect_error($q$select public.admin_set_plan('plan-student@x', 'expert', null)$q$,
  'student: admin_set_plan forbidden');
select pg_temp.expect_error($q$select public.admin_list_plans(null, 10)$q$, 'student: admin_list_plans forbidden');
select pg_temp.expect_error($q$select public.admin_plan_stats()$q$, 'student: admin_plan_stats forbidden');
select pg_temp.expect_42501(
  $q$select public.plan_apply_store('71000000-0000-0000-0000-0000000000b1', 'ios', 'fe_expert_yearly', 'tx1', now() + interval '1 year', true)$q$,
  'student: plan_apply_store has no grant');

-- trial
select pg_temp.check(public.plan_claim_trial('zz', 'student')->>'result' = 'INVALID', 'trial: bad hash INVALID');
select pg_temp.check(public.plan_claim_trial(repeat('a', 64), 'god')->>'result' = 'INVALID', 'trial: bad plan INVALID');
select pg_temp.check(public.plan_claim_trial(repeat('a', 64), 'student')->>'result' = 'GRANTED', 'trial: GRANTED');
select pg_temp.check((public.plan_claim_trial(repeat('a', 64), 'student')->>'result') = 'ALREADY_USED_ACCOUNT',
  'trial: same account again -> ALREADY_USED_ACCOUNT');
select pg_temp.check(public.my_plan(null)->>'plan' = 'student' and public.my_plan(null)->>'source' = 'trial'
  and (public.my_plan(null)->>'expires_at')::timestamptz between now() + interval '29 days 23 hours'
                                                              and now() + interval '30 days 1 hour',
  'trial: my_plan student/trial, ~30 days');
select pg_temp.check((public.my_plan(repeat('b', 64))->>'trial_available')::boolean = false,
  'trial: account used -> trial_available false even on a new device');
select pg_temp.as_user('71000000-0000-0000-0000-0000000000b2');
select pg_temp.check(public.plan_claim_trial(repeat('a', 64), 'expert')->>'result' = 'ALREADY_USED_DEVICE',
  'trial: other account on same device -> ALREADY_USED_DEVICE');
select pg_temp.check((public.my_plan(repeat('a', 64))->>'trial_available')::boolean = false,
  'trial: device used -> trial_available false');
select pg_temp.check(public.plan_claim_trial(repeat('c', 64), 'teacher')->>'result' = 'GRANTED',
  'trial: other account, other device -> GRANTED');
select pg_temp.check(public.my_plan(null)->>'plan' = 'teacher', 'trial: teacher plan');
-- expired trial -> plan null, still no second trial.
reset role;
select pg_temp.set_expiry('71000000-0000-0000-0000-0000000000b1', now() - interval '1 minute');
select pg_temp.as_user('71000000-0000-0000-0000-0000000000b1');
select pg_temp.check(public.my_plan(null)->'plan' = 'null'::jsonb, 'expired trial -> plan null');
select pg_temp.check(public.plan_claim_trial(repeat('d', 64), 'student')->>'result' = 'ALREADY_USED_ACCOUNT',
  'expired trial cannot be re-claimed (account)');

-- ============================================================ admin
select pg_temp.as_user('71000000-0000-0000-0000-0000000000a1');
select pg_temp.check(public.admin_set_plan('nobody@x', 'student', null)->>'result' = 'NOT_FOUND', 'admin: NOT_FOUND');
select pg_temp.check(public.admin_set_plan('plan-third@x', 'god', null)->>'result' = 'INVALID', 'admin: bad plan INVALID');
select pg_temp.check(public.admin_set_plan('plan-third@x', 'expert', now() - interval '1 day')->>'result' = 'INVALID',
  'admin: past until INVALID');
select pg_temp.check(public.admin_set_plan(' PLAN-THIRD@x ', 'expert', now() + interval '10 days')->>'result' = 'GRANTED',
  'admin: GRANTED (case/space-insensitive email)');
select pg_temp.check(jsonb_array_length(public.admin_list_plans('plan-third', 10)) = 1
  and public.admin_list_plans('plan-third', 10)->0->>'plan' = 'expert'
  and public.admin_list_plans('plan-third', 10)->0->>'source' = 'admin', 'admin: list shows grant');
select pg_temp.check(jsonb_array_length(public.admin_list_plans('%', 10)) = 0, 'admin: list search is literal (%)');
select pg_temp.check((public.admin_plan_stats()->'active'->>'expert')::int >= 1
  and (public.admin_plan_stats()->>'admin_active')::int >= 1
  and (public.admin_plan_stats()->>'trials_active')::int >= 1, 'admin: stats count active');
select pg_temp.check(pg_temp.audits('PLAN_SET') >= 4, 'admin: admin_log written');
select pg_temp.as_user('71000000-0000-0000-0000-0000000000b3');
select pg_temp.check(public.my_plan(null)->>'plan' = 'expert' and public.my_plan(null)->>'source' = 'admin',
  'admin grant visible to the user');
select pg_temp.as_user('71000000-0000-0000-0000-0000000000a1');
select pg_temp.check(public.admin_set_plan('plan-third@x', null, null)->>'result' = 'REVOKED', 'admin: REVOKED');
select pg_temp.as_user('71000000-0000-0000-0000-0000000000b3');
select pg_temp.check(public.my_plan(null)->'plan' = 'null'::jsonb, 'revoked -> plan null');
-- admin grant on an account with an active plan blocks the trial.
select pg_temp.as_user('71000000-0000-0000-0000-0000000000a1');
select public.admin_set_plan('plan-third@x', 'student', null);
select pg_temp.as_user('71000000-0000-0000-0000-0000000000b3');
select pg_temp.check(public.plan_claim_trial(repeat('e', 64), 'student')->>'result' = 'HAS_PLAN',
  'trial: active admin plan -> HAS_PLAN');
select pg_temp.as_user('71000000-0000-0000-0000-0000000000a1');
select public.admin_set_plan('plan-third@x', null, null);

-- ============================================================ store
select pg_temp.as_service();
select pg_temp.check(public.plan_apply_store('71000000-0000-0000-0000-0000000000b4', 'ios', 'fe_bogus', 'tx-a',
  now() + interval '30 days', true)->>'result' = 'INVALID', 'store: bad product INVALID');
select pg_temp.check(public.plan_apply_store('71000000-0000-0000-0000-0000000000b4', 'web', 'fe_student_monthly', 'tx-a',
  now() + interval '30 days', true)->>'result' = 'INVALID', 'store: bad platform INVALID');
select pg_temp.check(public.plan_apply_store('71000000-0000-0000-0000-0000000000ff', 'ios', 'fe_student_monthly', 'tx-a',
  now() + interval '30 days', true)->>'result' = 'INVALID', 'store: unknown user INVALID');
select pg_temp.check(public.plan_apply_store('71000000-0000-0000-0000-0000000000b4', 'ios', 'fe_student_monthly', 'tx-a',
  now() + interval '30 days', true)->>'result' = 'APPLIED', 'store: service_role -> APPLIED');
select pg_temp.as_user('71000000-0000-0000-0000-0000000000b4');
select pg_temp.check(public.my_plan(null)->>'plan' = 'student' and public.my_plan(null)->>'source' = 'store'
  and (public.my_plan(null)->>'auto_renew')::boolean and public.my_plan(null)->>'product_id' = 'fe_student_monthly',
  'store: my_plan reflects store row');
-- Subscription cannot be claimed by a second account while active.
select pg_temp.as_service();
select pg_temp.check(public.plan_apply_store('71000000-0000-0000-0000-0000000000b2', 'ios', 'fe_student_monthly', 'tx-a',
  now() + interval '30 days', true)->>'reason' = 'LINKED_ELSEWHERE', 'store: active tx on another account refused');
-- Store beats admin; admin's longer grant survives the store period.
select pg_temp.as_user('71000000-0000-0000-0000-0000000000a1');
select public.admin_set_plan('plan-fourth@x', 'expert', now() + interval '90 days');
select pg_temp.check(public.admin_list_plans('plan-fourth', 5)->0->>'plan' = 'student'
  and public.admin_list_plans('plan-fourth', 5)->0->>'source' = 'store',
  'store wins over a later admin grant while active');
select pg_temp.as_service();
select pg_temp.check(public.plan_apply_store('71000000-0000-0000-0000-0000000000b4', 'ios', 'fe_teacher_yearly', 'tx-a',
  now() + interval '365 days', false)->>'plan' = 'teacher', 'store: upgrade to teacher');
reset role;
select pg_temp.check((select alt_plan is null from public.plans where user_id = '71000000-0000-0000-0000-0000000000b4'),
  'store outlasting admin grant drops the shorter admin grant');
select pg_temp.as_user('71000000-0000-0000-0000-0000000000a1');
select public.admin_set_plan('plan-fourth@x', 'expert', null);  -- forever, outlasts store
select pg_temp.as_user('71000000-0000-0000-0000-0000000000b4');
select pg_temp.check(public.my_plan(null)->>'plan' = 'teacher' and public.my_plan(null)->>'source' = 'store',
  'store ustun: admin forever-grant behind an active store row');
reset role;
select pg_temp.set_expiry('71000000-0000-0000-0000-0000000000b4', now() - interval '1 minute');
select pg_temp.as_user('71000000-0000-0000-0000-0000000000b4');
select pg_temp.check(public.my_plan(null)->>'plan' = 'expert' and public.my_plan(null)->>'source' = 'admin',
  'store expired -> admin grant takes over');
select pg_temp.as_user('71000000-0000-0000-0000-0000000000a1');
select public.admin_set_plan('plan-fourth@x', null, null);
select pg_temp.as_user('71000000-0000-0000-0000-0000000000b4');
select pg_temp.check(public.my_plan(null)->'plan' = 'null'::jsonb, 'revoke removes the fallback too');
-- Expired store report -> row stored but no plan.
select pg_temp.as_service();
select pg_temp.check(public.plan_apply_store('71000000-0000-0000-0000-0000000000b4', 'android', 'fe_expert_monthly', 'tx-b',
  now() - interval '1 day', false)->>'result' = 'APPLIED', 'store: expired report APPLIED');
select pg_temp.as_user('71000000-0000-0000-0000-0000000000b4');
select pg_temp.check(public.my_plan(null)->'plan' = 'null'::jsonb, 'store: expired -> plan null');
-- Revoking an active store plan keeps it.
select pg_temp.as_service();
select public.plan_apply_store('71000000-0000-0000-0000-0000000000b4', 'android', 'fe_expert_yearly', 'tx-b',
  now() + interval '300 days', true);
select pg_temp.as_user('71000000-0000-0000-0000-0000000000a1');
select pg_temp.check(public.admin_set_plan('plan-fourth@x', null, null)->>'result' = 'REVOKED'
  and public.admin_list_plans('plan-fourth', 5)->0->>'source' = 'store', 'admin revoke does not cancel a paid store plan');
select pg_temp.check(pg_temp.events('STORE_APPLIED') >= 4 and pg_temp.events('TRIAL_GRANTED') = 2
  and pg_temp.events('ADMIN_GRANTED') >= 3, 'plan_events audit rows written');

reset role;
select set_config('request.jwt.claim.sub', '', false);
\echo ALL PLAN TESTS PASSED
