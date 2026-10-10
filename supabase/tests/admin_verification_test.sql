-- Admin «Tasdiqlash arizalari» inbox (after support_admin_test.sql).
\set ON_ERROR_STOP 1
reset role;
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
grant execute on function pg_temp.as_user(text), pg_temp.as_anon(),
  pg_temp.expect_error(text, text), pg_temp.check(boolean, text) to anon, authenticated;

-- 1 = admin (also has a pending application of their own), 2 = plain user,
-- 3 = applicant with two documents, 4 = verified peer with a verifier grant,
-- 5 = applicant already decided (must not be listed).
insert into auth.users (id, email, created_at, email_confirmed_at) values
 ('50000000-0000-0000-0000-000000000001', 'vadmin@x', now(), now()),
 ('50000000-0000-0000-0000-000000000002', 'vplain@x', now(), now()),
 ('50000000-0000-0000-0000-000000000003', 'vapplicant@x', now(), now()),
 ('50000000-0000-0000-0000-000000000004', 'vpeer@x', now(), now()),
 ('50000000-0000-0000-0000-000000000005', 'vdecided@x', now(), now());
insert into account_roles (user_id, role, granted_by) values
 ('50000000-0000-0000-0000-000000000001', 'identity_admin', null);
insert into professional_profiles (user_id, display_name, country_code, organization,
  position, primary_specialty, education, work_email, license_number, bio) values
 ('50000000-0000-0000-0000-000000000001', 'Admin Self', 'UZ', 'Lab A', 'Head', 'forensicChemistry', 'MSc', 'priv@x', 'LIC-SELF', 'bio-self'),
 ('50000000-0000-0000-0000-000000000003', 'Applicant Three', 'UZ', 'RSTEIAM', 'Expert', 'forensicToxicology', 'MD', 'priv3@x', 'LIC-3', 'bio-3'),
 ('50000000-0000-0000-0000-000000000004', 'Peer Four', 'UZ', 'Lab B', 'Expert', 'forensicToxicology', 'MD', null, null, null),
 ('50000000-0000-0000-0000-000000000005', 'Decided Five', 'UZ', 'Lab C', 'Expert', 'forensicMedicine', 'MD', null, null, null);
insert into verification (user_id, status, submitted_at) values
 ('50000000-0000-0000-0000-000000000001', 'APPLICATION_PENDING', now() - interval '1 day'),
 ('50000000-0000-0000-0000-000000000003', 'APPLICATION_PENDING', now() - interval '2 days'),
 ('50000000-0000-0000-0000-000000000004', 'VERIFIED_PROFESSIONAL', now() - interval '9 days'),
 ('50000000-0000-0000-0000-000000000005', 'REJECTED', now() - interval '5 days');
insert into verifier_grants (user_id, scope, granted_by) values
 ('50000000-0000-0000-0000-000000000004', 'FORENSIC_TOXICOLOGY', '50000000-0000-0000-0000-000000000001');
insert into credential_documents (document_id, user_id, kind, mime_type, size_bytes, sha256, storage_key) values
 ('51000000-0000-4000-8000-000000000031', '50000000-0000-0000-0000-000000000003', 'diploma', 'application/pdf', 1234, repeat('a', 64), '50000000-0000-0000-0000-000000000003/51000000-0000-4000-8000-000000000031'),
 ('51000000-0000-4000-8000-000000000032', '50000000-0000-0000-0000-000000000003', 'employmentEvidence', 'image/png', 99, repeat('b', 64), '50000000-0000-0000-0000-000000000003/51000000-0000-4000-8000-000000000032'),
 ('51000000-0000-4000-8000-000000000011', '50000000-0000-0000-0000-000000000001', 'diploma', 'application/pdf', 10, repeat('c', 64), '50000000-0000-0000-0000-000000000001/51000000-0000-4000-8000-000000000011');

-- Admin sees pending applications (oldest first), only APPLICATION_PENDING.
select pg_temp.as_user('50000000-0000-0000-0000-000000000001');
select pg_temp.check((admin_pending_verifications()->>'total')::int = 2, 'admin: total counts pending only');
select pg_temp.check(admin_pending_verifications()->'items'->0->>'applicant_id'
  = '50000000-0000-0000-0000-000000000003', 'admin: oldest application first');
select pg_temp.check(jsonb_array_length(admin_pending_verifications()->'items'->0->'credential_documents') = 2,
  'admin: credential document list returned');
select pg_temp.check(admin_pending_verifications()->'items'->0->'credential_documents'->0->>'sha256'
  = repeat('a', 64) and admin_pending_verifications()->'items'->0->'credential_documents'->0->>'kind' = 'diploma',
  'admin: document metadata (kind, sha256)');
select pg_temp.check(not (admin_pending_verifications()::text like '%storage_key%')
  and not (admin_pending_verifications()::text like '%priv3@x%')
  and not (admin_pending_verifications()::text like '%LIC-3%')
  and not (admin_pending_verifications()::text like '%bio-3%'),
  'admin: no storage key / private profile fields leaked');
select pg_temp.check(not (admin_pending_verifications()::text like '%Decided Five%'),
  'admin: decided applications are not listed');
select pg_temp.check((admin_pending_verifications()->'items'->1->>'is_self')::boolean
  and not (admin_pending_verifications()->'items'->0->>'is_self')::boolean,
  'admin: own application flagged is_self');
select pg_temp.check((admin_pending_verifications(1, 0)->'items')::text <> '[]'
  and jsonb_array_length(admin_pending_verifications(1, 1)->'items') = 1, 'admin: paging');
reset role;
select pg_temp.check((select count(*) >= 1 from private.admin_audit
  where action = 'VERIFICATIONS_VIEW' and actor_id = '50000000-0000-0000-0000-000000000001'),
  'admin view audited');
select pg_temp.check(not exists (select 1 from private.admin_audit
  where action = 'VERIFICATIONS_VIEW' and detail::text like '%Applicant Three%'), 'audit holds no names');

-- Self approval is refused even for the admin.
select pg_temp.as_user('50000000-0000-0000-0000-000000000001');
select pg_temp.expect_error($q$select decide_identity('50000000-0000-0000-0000-000000000001','VERIFY','FORENSIC_CHEMISTRY',
  array['51000000-0000-4000-8000-000000000011'::uuid],'self approve attempt','m')$q$, 'admin cannot approve own application');
select pg_temp.expect_error($q$select decide_identity('50000000-0000-0000-0000-000000000003','VERIFY','FORENSIC_TOXICOLOGY',
  '{}'::uuid[],'no document checked','m')$q$, 'VERIFY without a checked credential refused');

-- Ordinary user, verified peer, anonymous: no list.
select pg_temp.as_user('50000000-0000-0000-0000-000000000002');
select pg_temp.expect_error($q$select admin_pending_verifications()$q$, 'plain user cannot list applications');
select pg_temp.as_user('50000000-0000-0000-0000-000000000004');
select pg_temp.expect_error($q$select admin_pending_verifications()$q$, 'verified peer is not served by the admin inbox');
select pg_temp.as_anon();
select pg_temp.expect_error($q$select admin_pending_verifications()$q$, 'anon cannot list applications');

-- Admin decides another user's application; it leaves the inbox.
select pg_temp.as_user('50000000-0000-0000-0000-000000000001');
select pg_temp.check(decide_identity('50000000-0000-0000-0000-000000000003','VERIFY','FORENSIC_TOXICOLOGY',
  array['51000000-0000-4000-8000-000000000031'::uuid],'diploma and employer checked','welcome') = 'VERIFIED_PROFESSIONAL',
  'admin approves another user');
select pg_temp.check((admin_pending_verifications()->>'total')::int = 1
  and not (admin_pending_verifications()::text like '%Applicant Three%'), 'approved application leaves the inbox');
reset role;
