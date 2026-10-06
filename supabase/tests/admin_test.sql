-- Admin panel + server access grants (after security_test.sql / referral_test.sql).
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

insert into auth.users (id, email, created_at, email_confirmed_at) values
 ('20000000-0000-0000-0000-00000000000a', 'owner-admin@x', now(), now()),
 ('20000000-0000-0000-0000-00000000000b', 'plain-user@x', now(), now());
insert into account_roles (user_id, role, granted_by) values
 ('20000000-0000-0000-0000-00000000000a', 'identity_admin', null);

-- Devices: own only, sanitised.
select pg_temp.as_user('20000000-0000-0000-0000-00000000000b');
select register_device('android', '0.4.1', 'uz', 'uz');
select register_device('ios', '0.4.1', 'ru', 'NOT-A-REGION');
select register_device('android', '0.4.2', 'uz', null);
reset role;
select pg_temp.check((select count(*) = 2 from user_devices where user_id = '20000000-0000-0000-0000-00000000000b'), 'one row per platform');
select pg_temp.check((select region = 'UZ' and app_version = '0.4.2' from user_devices
  where user_id = '20000000-0000-0000-0000-00000000000b' and platform = 'android'), 'region normalised, kept on null update');
select pg_temp.check((select region is null from user_devices
  where user_id = '20000000-0000-0000-0000-00000000000b' and platform = 'ios'), 'invalid region dropped');

-- Plain user: no admin, no grant, no direct table access.
select pg_temp.as_user('20000000-0000-0000-0000-00000000000b');
select pg_temp.check((select (a->>'is_admin')::boolean = false and a->>'tier' is null from (select my_access() a) x), 'plain user access');
select pg_temp.expect_error($q$select admin_dashboard()$q$, 'non-admin dashboard');
select pg_temp.expect_error($q$select admin_set_access('plain-user@x', 'professionalPro')$q$, 'non-admin self-grant');
select pg_temp.expect_error($q$insert into access_grants(user_id, tier) values ('20000000-0000-0000-0000-00000000000b', 'professionalPro')$q$, 'client writes grant');
select pg_temp.check((select count(*) = 0 from user_devices), 'devices not client-readable');
set role anon;
select pg_temp.expect_error($q$select my_access()$q$, 'anon my_access');
reset role;

-- Admin: dashboard and grants.
select pg_temp.as_user('20000000-0000-0000-0000-00000000000a');
select pg_temp.check((select (a->>'is_admin')::boolean from (select my_access() a) x), 'admin flag');
select pg_temp.check(admin_set_access('PLAIN-USER@x', 'professionalPro') = 'GRANTED', 'admin grants by email');
select pg_temp.check(admin_set_access('nobody@x', 'professionalPro') = 'NOT_FOUND', 'unknown email');
select pg_temp.check(admin_set_access('plain-user@x', 'gold') = 'INVALID_TIER', 'invalid tier');
select pg_temp.check((select (d->'totals'->>'android')::int >= 1 and (d->'totals'->>'ios')::int >= 1
  and jsonb_array_length(d->'users') >= 2 and (d->'totals'->>'pro_grants')::int >= 1
  from (select admin_dashboard() d) x), 'dashboard totals and users');
select pg_temp.check((select exists (select 1 from jsonb_array_elements(d->'regions') r where r->>'region' = 'UZ')
  from (select admin_dashboard() d) x), 'dashboard regions');
select pg_temp.as_user('20000000-0000-0000-0000-00000000000b');
select pg_temp.check((select a->>'tier' = 'professionalPro' from (select my_access() a) x), 'grant visible to user');
select pg_temp.as_user('20000000-0000-0000-0000-00000000000a');
select pg_temp.check(admin_set_access('plain-user@x', null) = 'REVOKED', 'admin revokes');
select pg_temp.as_user('20000000-0000-0000-0000-00000000000b');
select pg_temp.check((select a->>'tier' is null from (select my_access() a) x), 'revoked');
reset role;
-- Account deletion removes devices and grants.
insert into access_grants (user_id, tier) values ('20000000-0000-0000-0000-00000000000b', 'studentPro');
delete from auth.users where id = '20000000-0000-0000-0000-00000000000b';
select pg_temp.check((select count(*) = 0 from user_devices where user_id = '20000000-0000-0000-0000-00000000000b')
  and (select count(*) = 0 from access_grants where user_id = '20000000-0000-0000-0000-00000000000b'), 'deletion cascades');
select 'ALL ADMIN TESTS PASSED' as result;
