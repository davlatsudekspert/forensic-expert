-- Admin panel extension (20261017000000_admin_extension.sql): bootstrap,
-- reports with rate limit, LIKE-safe user search, role change, suspension,
-- stats, blocks, community-rules acceptance. Runs after support_admin_test.sql.
\set ON_ERROR_STOP 1
reset role;
select set_config('request.headers', '', false);
-- Earlier test files grant table DML to authenticated for their own checks;
-- restore the migration's state (no direct table privileges).
revoke all on public.user_reports, public.user_blocks, public.user_terms,
  public.account_suspensions, public.account_roles from anon, authenticated;
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
create function pg_temp.expect_msg(q text, msg text, label text) returns void language plpgsql as $$
begin
  begin execute q; exception when others then
    if sqlerrm = msg then raise notice 'PASS (blocked): % [%]', label, sqlerrm; return; end if;
    raise exception 'FAIL (wrong error %): %', sqlerrm, label;
  end;
  raise exception 'FAIL (allowed): %', label;
end $$;
create function pg_temp.check(ok boolean, label text) returns void language plpgsql as $$
begin
  if not coalesce(ok, false) then raise exception 'FAIL: %', label; end if;
  raise notice 'PASS: %', label;
end $$;
create function pg_temp.audit_rows() returns setof private.admin_audit
language sql security definer as $$ select * from private.admin_audit $$;
grant execute on function pg_temp.audit_rows() to anon, authenticated, service_role;
grant execute on function pg_temp.as_user(text), pg_temp.as_anon(), pg_temp.as_service(),
  pg_temp.expect_error(text, text), pg_temp.expect_msg(text, text, text),
  pg_temp.check(boolean, text) to anon, authenticated, service_role;

-- Users: adm (admin), adm2 (second admin), unc (admin role, e-mail NOT
-- confirmed), ban (admin role, banned), u1/u2/u3 ordinary, mod (target for
-- publication_moderator), plus two accounts to test literal LIKE search.
insert into auth.users (id, email, created_at, email_confirmed_at, banned_until) values
 ('70000000-0000-0000-0000-0000000000a1', 'ext-admin@x', now() - interval '30 days', now(), null),
 ('70000000-0000-0000-0000-0000000000a2', 'ext-admin2@x', now() - interval '30 days', now(), null),
 ('70000000-0000-0000-0000-0000000000a3', 'ext-unconfirmed-admin@x', now(), null, null),
 ('70000000-0000-0000-0000-0000000000a4', 'ext-banned-admin@x', now(), now(), now() + interval '1 day'),
 ('70000000-0000-0000-0000-0000000000b1', 'ext-user-one@x', now(), now(), null),
 ('70000000-0000-0000-0000-0000000000b2', 'ext-user-two@x', now(), now(), null),
 ('70000000-0000-0000-0000-0000000000b3', 'ext-user-three@x', now(), now(), null),
 ('70000000-0000-0000-0000-0000000000b4', 'ext-moderator-target@x', now(), now(), null),
 ('70000000-0000-0000-0000-0000000000b5', 'ext-unconfirmed-user@x', now(), null, null),
 ('70000000-0000-0000-0000-0000000000c1', 'lk_a_b@x', now(), now(), null),
 ('70000000-0000-0000-0000-0000000000c2', 'lkxaxb@x', now(), now(), null),
 ('70000000-0000-0000-0000-0000000000c3', 'lk100%@x', now(), now(), null);
insert into account_roles (user_id, role, granted_by) values
 ('70000000-0000-0000-0000-0000000000a1', 'identity_admin', null),
 ('70000000-0000-0000-0000-0000000000a2', 'identity_admin', null),
 ('70000000-0000-0000-0000-0000000000a3', 'identity_admin', null),
 ('70000000-0000-0000-0000-0000000000a4', 'identity_admin', null);

-- ============================================================ bootstrap
select pg_temp.check(private.admin_bootstrap(array['EXT-USER-ONE@x ', 'ext-unconfirmed-user@x',
  'nobody@x']) = 1, 'bootstrap grants only the confirmed, existing address (case-insensitive)');
select pg_temp.check(exists (select 1 from account_roles where role = 'identity_admin'
  and user_id = '70000000-0000-0000-0000-0000000000b1'), 'bootstrap admin role stored');
select pg_temp.check(not exists (select 1 from account_roles where role = 'identity_admin'
  and user_id = '70000000-0000-0000-0000-0000000000b5'), 'unconfirmed address is never made admin');
select pg_temp.check(private.admin_bootstrap(array['ext-user-one@x']) = 0, 'bootstrap is idempotent');
select pg_temp.check(exists (select 1 from pg_temp.audit_rows() where action = 'ADMIN_BOOTSTRAP'
  and target_id = '70000000-0000-0000-0000-0000000000b1'), 'bootstrap audited');
-- u1 is only a bootstrap fixture: take the role back so it is an ordinary user.
delete from account_roles where user_id = '70000000-0000-0000-0000-0000000000b1';
select pg_temp.expect_error($$select private.admin_bootstrap(array['a@x','b@x','c@x','d@x','e@x','f@x','g@x','h@x','i@x','j@x','k@x'])$$,
  'bootstrap list is capped');
select pg_temp.as_user('70000000-0000-0000-0000-0000000000b2');
select pg_temp.expect_error($$select public.admin_bootstrap(array['ext-user-two@x'])$$,
  'a signed-in user cannot call the bootstrap entry point');
select pg_temp.expect_error($$select private.admin_bootstrap(array['ext-user-two@x'])$$,
  'a signed-in user cannot call the private bootstrap');
select pg_temp.as_anon();
select pg_temp.expect_error($$select public.admin_bootstrap(array['ext-user-two@x'])$$,
  'anon cannot call the bootstrap entry point');
select pg_temp.as_service();
select pg_temp.check(public.admin_bootstrap(array['ext-user-two@x']) = 1, 'service role can bootstrap');
reset role;
delete from account_roles where user_id = '70000000-0000-0000-0000-0000000000b2';

-- ============================================================ anon / non-admin
select pg_temp.as_anon();
select pg_temp.expect_error($$select public.admin_reports()$$, 'anon: admin_reports');
select pg_temp.expect_error($$select public.admin_stats_ext()$$, 'anon: admin_stats_ext');
select pg_temp.expect_error($$select public.admin_set_role('70000000-0000-0000-0000-0000000000b4', 'publication_moderator', true, 'because')$$, 'anon: admin_set_role');
select pg_temp.expect_error($$select public.admin_set_suspension('70000000-0000-0000-0000-0000000000b4', true, 'because')$$, 'anon: admin_set_suspension');
select pg_temp.expect_error($$select public.admin_resolve_report(gen_random_uuid())$$, 'anon: admin_resolve_report');
select pg_temp.expect_error($$select public.admin_report_note(gen_random_uuid(), 'note')$$, 'anon: admin_report_note');
select pg_temp.expect_error($$select public.my_reports()$$, 'anon: my_reports');
select pg_temp.expect_error($$select public.my_blocks()$$, 'anon: my_blocks');
select pg_temp.expect_error($$select public.accept_terms('ugc_rules', '1')$$, 'anon: accept_terms');
select pg_temp.expect_error($$select public.qa_block_author('question', gen_random_uuid())$$, 'anon: qa_block_author');
select pg_temp.expect_error($$select * from public.user_reports$$, 'anon: no direct table access');

select pg_temp.as_user('70000000-0000-0000-0000-0000000000b1');
select pg_temp.expect_msg($$select public.admin_reports()$$, 'forbidden', 'user: admin_reports 403');
select pg_temp.expect_msg($$select public.admin_stats_ext()$$, 'forbidden', 'user: admin_stats_ext 403');
select pg_temp.expect_msg($$select public.admin_users()$$, 'forbidden', 'user: admin_users 403');
select pg_temp.expect_msg($$select public.admin_set_role('70000000-0000-0000-0000-0000000000b4', 'publication_moderator', true, 'because')$$, 'forbidden', 'user: admin_set_role 403');
select pg_temp.expect_msg($$select public.admin_set_suspension('70000000-0000-0000-0000-0000000000b4', true, 'because')$$, 'forbidden', 'user: admin_set_suspension 403');
select pg_temp.expect_msg($$select public.admin_resolve_report(gen_random_uuid())$$, 'forbidden', 'user: admin_resolve_report 403');
select pg_temp.expect_error($$select * from public.user_reports$$, 'user: no direct table access');
select pg_temp.expect_error($$insert into public.user_blocks (blocker_id, blocked_id) values (auth.uid(), '70000000-0000-0000-0000-0000000000b2')$$, 'user: cannot insert blocks directly');
select pg_temp.expect_error($$insert into public.account_roles (user_id, role) values (auth.uid(), 'identity_admin')$$, 'user: cannot grant roles directly');

-- Admin role without a confirmed e-mail, or banned, is not an admin.
select pg_temp.as_user('70000000-0000-0000-0000-0000000000a3');
select pg_temp.expect_msg($$select public.admin_reports()$$, 'forbidden', 'admin role + unconfirmed e-mail: 403');
select pg_temp.as_user('70000000-0000-0000-0000-0000000000a4');
select pg_temp.expect_msg($$select public.admin_reports()$$, 'forbidden', 'admin role + banned account: 403');

-- ============================================================ reports
select pg_temp.as_anon();
select pg_temp.check(public.submit_report('BUG', 'Ilova ochilmayapti', null, null, 'me@x', 'device-key-0001')->>'result' = 'CREATED',
  'anon can send a report');
select pg_temp.check(public.submit_report('NOPE', 'Ilova ochilmayapti', null, null, null, 'device-key-0001')->>'result' = 'INVALID',
  'unknown kind is invalid');
select pg_temp.check(public.submit_report('BUG', 'qisq', null, null, null, 'device-key-0001')->>'result' = 'INVALID',
  'too short body is invalid');
select pg_temp.check(public.submit_report('BUG', repeat('x', 2001), null, null, null, 'device-key-0001')->>'result' = 'INVALID',
  'too long body is invalid');
select pg_temp.check(public.submit_report('OTHER', 'Maqsad noto‘g‘ri', 'hacker', 'x', null, 'device-key-0001')->>'result' = 'INVALID',
  'unknown target type is invalid');
-- 4 more from the same device key -> 5 in the hour; the 6th is refused.
select public.submit_report('COMPLAINT', 'Shikoyat matni ' || g, null, null, null, 'device-key-0001')
from generate_series(1, 4) g;
select pg_temp.check(public.submit_report('COMPLAINT', 'Oltinchi shikoyat', null, null, null, 'device-key-0001')->>'result' = 'RATE_LIMITED',
  'anon: 6th report within an hour from one device key is refused (5/hour)');
select pg_temp.check(public.submit_report('COMPLAINT', 'Boshqa qurilma shikoyati', null, null, null, 'device-key-0002')->>'result' = 'CREATED',
  'another device key has its own allowance');
-- Behind the proxy: the IP hash limits across changing device keys.
select set_config('request.headers', '{"x-forwarded-for":"203.0.113.9, 10.0.0.1"}', false);
select public.submit_report('ADVERTISING', 'Reklama xabari ' || g, null, null, null, 'device-ip-key-' || g)
from generate_series(1, 5) g;
select pg_temp.check(public.submit_report('ADVERTISING', 'Reklama xabari 6', null, null, null, 'device-ip-key-99')->>'result' = 'RATE_LIMITED',
  'anon: IP hash limit holds even if the device key changes');
select set_config('request.headers', '{"cf-connecting-ip":"198.51.100.7"}', false);
select pg_temp.check(public.submit_report('INAPPROPRIATE_CONTENT', 'Nomaqbul post', 'qa_question', '60000000-0000-0000-0000-0000000000b1', null, null)->>'result' = 'CREATED',
  'a different IP is allowed (no device key needed)');
select set_config('request.headers', '', false);

-- Signed in: limit is per user id.
select pg_temp.as_user('70000000-0000-0000-0000-0000000000b1');
select public.submit_report('BUG', 'Foydalanuvchi xatosi ' || g) from generate_series(1, 5) g;
select pg_temp.check(public.submit_report('BUG', 'Oltinchi xato')->>'result' = 'RATE_LIMITED',
  'user: 6th report within an hour is refused (5/hour)');
select pg_temp.as_user('70000000-0000-0000-0000-0000000000b2');
select pg_temp.check(public.submit_report('OTHER', 'Ikkinchi foydalanuvchi xabari')->>'result' = 'CREATED',
  'another user is not affected by someone else''s limit');
select pg_temp.check(jsonb_array_length(public.my_reports()) = 1 and
  not (public.my_reports()->0 ? 'body') and not (public.my_reports()->0 ? 'admin_note'),
  'a user sees only their own report (no text, no admin note)');
select pg_temp.as_user('70000000-0000-0000-0000-0000000000b1');
select pg_temp.check(jsonb_array_length(public.my_reports()) = 5, 'user one sees exactly their five reports');

-- Raw IPs / device keys are never stored.
reset role;
select pg_temp.check(not exists (select 1 from public.user_reports
  where rate_key like '%203.0.113.9%' or rate_key like '%device-key-0001%' or device_hash like '%device-key%'),
  'raw IP and device key are not stored (salted hashes only)');
-- Global anon ceiling.
insert into public.user_reports (kind, body, rate_key)
select 'OTHER', 'flood ' || g, 'i:flood' || g from generate_series(1, 100) g;
select pg_temp.as_anon();
select set_config('request.headers', '{"cf-connecting-ip":"192.0.2.77"}', false);
select pg_temp.check(public.submit_report('OTHER', 'Global chegara tekshiruvi', null, null, null, null)->>'result' = 'RATE_LIMITED',
  'global anon ceiling (100/hour) holds');
select set_config('request.headers', '', false);
reset role;
delete from public.user_reports where rate_key like 'i:flood%';

-- ---- admin: list, note, resolve, reopen
select pg_temp.as_user('70000000-0000-0000-0000-0000000000a1');
select pg_temp.check((public.admin_reports('OPEN')->>'total')::int >= 13, 'admin sees open reports');
select pg_temp.check(exists (select 1 from jsonb_array_elements(public.admin_reports()->'items') i
  where (i->>'anonymous')::boolean and i->>'contact' = 'me@x'), 'admin sees anonymous report + contact');
select pg_temp.check(exists (select 1 from jsonb_array_elements(public.admin_reports()->'items') i
  where i->>'reporter_email' = 'ext-user-two@x'), 'admin sees reporter e-mail of a signed-in report');
select pg_temp.check((public.admin_reports(null, 'ADVERTISING')->>'total')::int = 5, 'filter by kind');
select pg_temp.check((public.admin_reports(null, null, 'Foydalanuvchi xatosi')->>'total')::int = 5, 'search in body');
select pg_temp.check((public.admin_reports(null, null, '%')->>'total')::int = 0, 'search "%" is literal (matches nothing)');
select pg_temp.check((public.admin_reports(null, null, '_')->>'total')::int = 0, 'search "_" is literal');
select pg_temp.check((public.admin_reports(null, null, '\')->>'total')::int = 0, 'search "\" is literal and does not break the query');
reset role;
select id as rid from public.user_reports where body = 'Ilova ochilmayapti' \gset
select pg_temp.as_user('70000000-0000-0000-0000-0000000000a1');
select pg_temp.check(public.admin_report_note(:'rid', 'Qurilma modelini so‘radik') = 'SAVED', 'admin writes a note');
select pg_temp.check(public.admin_report_note(:'rid', '') = 'INVALID', 'empty note refused');
select pg_temp.check(public.admin_report_note(gen_random_uuid(), 'x') = 'NOT_FOUND', 'unknown report');
select pg_temp.check(public.admin_resolve_report(:'rid', true, 'Tuzatildi, 1.2.3 versiyada') = 'RESOLVED', 'admin resolves a report');
select pg_temp.check((select i->>'status' = 'RESOLVED' and i->>'admin_note' = 'Tuzatildi, 1.2.3 versiyada'
  and i->>'resolved_at' is not null from jsonb_array_elements(public.admin_reports()->'items') i
  where i->>'id' = :'rid'), 'resolved status, note and time stored');
select pg_temp.check((public.admin_reports('RESOLVED')->>'total')::int = 1, 'filter resolved');
select pg_temp.check(public.admin_resolve_report(:'rid', false) = 'REOPENED', 'admin reopens a report');
select pg_temp.check(public.admin_resolve_report(:'rid', true) = 'RESOLVED', 'resolved again');
select pg_temp.check(public.admin_resolve_report(gen_random_uuid()) = 'NOT_FOUND', 'unknown report on resolve');
select pg_temp.check((select count(*) >= 4 from pg_temp.audit_rows() where action in
  ('REPORT_NOTE', 'REPORT_RESOLVED', 'REPORT_REOPENED')), 'report actions audited');
-- the reporter (signed-in) sees the status change, not the note
select pg_temp.as_user('70000000-0000-0000-0000-0000000000b2');
select pg_temp.check(public.my_reports()->0->>'status' = 'OPEN', 'reporter sees status only');

-- ============================================================ users search
select pg_temp.as_user('70000000-0000-0000-0000-0000000000a1');
select pg_temp.check((public.admin_users('lk_a_b')->>'total')::int = 1, 'search "_" matches literally (lk_a_b)');
select pg_temp.check((public.admin_users('lk_')->>'total')::int = 1, 'search "lk_" does not wildcard lkxaxb');
select pg_temp.check((public.admin_users('100%')->>'total')::int = 1, 'search "100%" matches literally');
select pg_temp.check((public.admin_users('%')->>'total')::int = 1, 'search "%" matches only addresses containing a percent sign');
select pg_temp.check((public.admin_users('\')->>'total')::int = 0, 'search "\" is safe');
select pg_temp.check((public.admin_users('ext-user-t')->>'total')::int = 2, 'plain search still works');
select pg_temp.check((public.admin_support_inbox(null, null, '%')->>'total')::int = 0, 'support inbox search "%" is literal');

-- ============================================================ roles
select pg_temp.check(public.admin_set_role('70000000-0000-0000-0000-0000000000b4', 'publication_moderator', true, 'Tahrir ishlari uchun') = 'GRANTED',
  'admin grants publication_moderator');
select pg_temp.check(public.admin_set_role('70000000-0000-0000-0000-0000000000b4', 'publication_moderator', true, 'Tahrir ishlari uchun') = 'UNCHANGED',
  'repeat grant is a no-op');
select pg_temp.check(exists (select 1 from jsonb_array_elements(public.admin_users('moderator-target')->'items') i
  where i->'roles' ? 'publication_moderator'), 'role visible in the user list');
select pg_temp.check(public.admin_set_role('70000000-0000-0000-0000-0000000000b4', 'scope_grantor', true, 'Reviewer qilish') = 'FORBIDDEN_ROLE',
  'reviewer authority (scope_grantor) cannot be granted from the panel');
select pg_temp.check(public.admin_set_role('70000000-0000-0000-0000-0000000000b4', 'nonsense', true, 'Reviewer qilish') = 'FORBIDDEN_ROLE', 'unknown role refused');
select pg_temp.check(public.admin_set_role('70000000-0000-0000-0000-0000000000b4', 'identity_admin', true, 'Yangi admin kerak') = 'FORBIDDEN_ROLE',
  'granting admin from the app is off by default');
select pg_temp.check(public.admin_set_role('70000000-0000-0000-0000-0000000000b4', 'publication_moderator', true, 'ab') = 'INVALID', 'reason too short');
select pg_temp.check(public.admin_set_role(gen_random_uuid(), 'publication_moderator', true, 'Sabab bor') = 'NOT_FOUND', 'unknown user');
select pg_temp.check(public.admin_set_role('70000000-0000-0000-0000-0000000000a1', 'identity_admin', false, 'O‘zimni olib tashlayman') = 'SELF_ADMIN_CHANGE',
  'admin cannot change their own admin role');
select pg_temp.check(public.admin_set_role('70000000-0000-0000-0000-0000000000b4', 'publication_moderator', false, 'Muddat tugadi') = 'REVOKED',
  'admin revokes publication_moderator');
select pg_temp.check((select count(*) = 3 from pg_temp.audit_rows() where action = 'ADMIN_ROLE_SET'
  and target_id = '70000000-0000-0000-0000-0000000000b4' and detail ? 'reason'), 'role changes audited with reason');
select pg_temp.check((select count(*) >= 2 from pg_temp.audit_rows() where action in ('ROLE_GRANTED', 'ROLE_REVOKED')
  and target_id = '70000000-0000-0000-0000-0000000000b4'), 'trigger audit also recorded');
-- Owner flips the setting in the SQL console; then admin grant works, but only
-- to a confirmed e-mail.
reset role;
update private.admin_settings set allow_admin_grant_in_app = true;
select pg_temp.as_user('70000000-0000-0000-0000-0000000000a1');
select pg_temp.check(public.admin_set_role('70000000-0000-0000-0000-0000000000b5', 'identity_admin', true, 'Yangi admin kerak') = 'EMAIL_UNCONFIRMED',
  'admin role needs a confirmed e-mail');
select pg_temp.check(public.admin_set_role('70000000-0000-0000-0000-0000000000b3', 'identity_admin', true, 'Yangi admin kerak') = 'GRANTED',
  'with the owner setting on, an admin can be granted');
select pg_temp.check(public.admin_set_role('70000000-0000-0000-0000-0000000000b3', 'identity_admin', false, 'Endi kerak emas') = 'REVOKED',
  'another admin can be revoked');
reset role;
update private.admin_settings set allow_admin_grant_in_app = false;

-- ============================================================ suspension
insert into auth.sessions (id, user_id) values
 ('71000000-0000-0000-0000-000000000001', '70000000-0000-0000-0000-0000000000b2'),
 ('71000000-0000-0000-0000-000000000002', '70000000-0000-0000-0000-0000000000b2'),
 ('71000000-0000-0000-0000-000000000003', '70000000-0000-0000-0000-0000000000b3');
insert into auth.refresh_tokens (user_id, session_id) values
 ('70000000-0000-0000-0000-0000000000b2', '71000000-0000-0000-0000-000000000001'),
 ('70000000-0000-0000-0000-0000000000b2', '71000000-0000-0000-0000-000000000002'),
 ('70000000-0000-0000-0000-0000000000b3', '71000000-0000-0000-0000-000000000003');
select pg_temp.as_user('70000000-0000-0000-0000-0000000000a1');
select pg_temp.check(public.admin_set_suspension('70000000-0000-0000-0000-0000000000a2', true, 'Sinov uchun sabab') = 'CANNOT_SUSPEND_ADMIN',
  'an admin cannot be suspended');
select pg_temp.check(public.admin_set_suspension('70000000-0000-0000-0000-0000000000a1', true, 'Sinov uchun sabab') = 'CANNOT_SUSPEND_SELF',
  'nobody suspends themselves');
select pg_temp.check(public.admin_set_suspension('70000000-0000-0000-0000-0000000000b2', true, 'xx') = 'INVALID', 'suspension needs a reason');
select pg_temp.check(public.admin_set_suspension(gen_random_uuid(), true, 'Sinov uchun sabab') = 'NOT_FOUND', 'unknown user');
select pg_temp.check(public.admin_set_suspension('70000000-0000-0000-0000-0000000000b2', true, 'Spam yuborgan') = 'SUSPENDED', 'admin suspends a user');
select pg_temp.check(public.admin_set_suspension('70000000-0000-0000-0000-0000000000b2', true, 'Spam yuborgan') = 'UNCHANGED', 'second suspend is a no-op');
reset role;
select pg_temp.check((select banned_until > now() + interval '10 years' from auth.users
  where id = '70000000-0000-0000-0000-0000000000b2'), 'auth ban set (sign-in and refresh refused by Auth)');
select pg_temp.check(not exists (select 1 from auth.sessions where user_id = '70000000-0000-0000-0000-0000000000b2')
  and not exists (select 1 from auth.refresh_tokens where user_id = '70000000-0000-0000-0000-0000000000b2'),
  'the suspended user''s sessions and refresh tokens are deleted');
select pg_temp.check(exists (select 1 from auth.sessions where user_id = '70000000-0000-0000-0000-0000000000b3'),
  'other users'' sessions untouched');
select pg_temp.as_user('70000000-0000-0000-0000-0000000000b2');
select pg_temp.expect_msg($$select public.qa_feed()$$, 'suspended', 'suspended user: Q&A feed refused even with a still-valid token');
select pg_temp.expect_msg($$select public.accept_terms('ugc_rules', '1')$$, 'suspended', 'suspended user: accept_terms refused');
select pg_temp.check(public.submit_report('BUG', 'Hisob to‘xtatilgan', null, null, null, null)->>'result' = 'SUSPENDED',
  'suspended user: report refused');
select pg_temp.as_user('70000000-0000-0000-0000-0000000000a1');
select pg_temp.check(exists (select 1 from jsonb_array_elements(public.admin_users('ext-user-two')->'items') i
  where i->>'status' = 'BANNED'), 'admin list shows the account as BANNED');
select pg_temp.check(public.admin_set_suspension('70000000-0000-0000-0000-0000000000b2', false, 'Xato bo‘lgan ekan') = 'RESTORED', 'admin restores the account');
select pg_temp.check(public.admin_set_suspension('70000000-0000-0000-0000-0000000000b2', false, 'Xato bo‘lgan ekan') = 'UNCHANGED', 'restore twice is a no-op');
reset role;
select pg_temp.check((select banned_until is null from auth.users where id = '70000000-0000-0000-0000-0000000000b2'), 'ban lifted');
select pg_temp.as_user('70000000-0000-0000-0000-0000000000b2');
select pg_temp.check(public.accept_terms('ugc_rules', '1') = 'ACCEPTED', 'restored user can use the app again');
select pg_temp.check((select count(*) = 4 from pg_temp.audit_rows() where action in ('USER_SUSPENDED', 'USER_RESTORED')
  and target_id = '70000000-0000-0000-0000-0000000000b2'), 'suspend and restore audited');

-- ============================================================ stats
select pg_temp.as_user('70000000-0000-0000-0000-0000000000a1');
select pg_temp.check((public.admin_stats_ext()->'reports'->>'open')::int >= 1
  and (public.admin_stats_ext()->'roles'->>'identity_admin')::int >= 2, 'stats: reports and role counts');
select pg_temp.check((public.admin_stats_ext()->'online_now'->>'available')::boolean = false
  and (public.admin_stats_ext()->'sales'->>'available')::boolean = false
  and (public.admin_stats_ext()->'sales'->>'payment_system')::boolean = false
  and (public.admin_stats_ext()->'downloads'->>'available')::boolean = false
  and (public.admin_stats_ext()->'casebooks'->>'stored_server_side')::boolean = false,
  'stats: unknowable numbers are reported as unavailable, not invented');
select pg_temp.check(public.admin_stats_ext()::text !~ '@x', 'stats: no e-mail or text, aggregates only');

-- ============================================================ blocks / terms
select pg_temp.as_user('70000000-0000-0000-0000-0000000000b1');
select pg_temp.expect_msg($$select public.qa_ask('uz', 'Birinchi savol sarlavhasi', 'Yetarlicha uzun matn, birinchi savol.')$$, 'terms_required',
  'posting a question needs accepted community rules (server side)');
select pg_temp.check(public.accept_terms('nope', '1') = 'INVALID', 'unknown document refused');
select pg_temp.check(public.accept_terms('ugc_rules', '') = 'INVALID', 'empty version refused');
select pg_temp.check(public.accept_terms('ugc_rules', '2026-10-17') = 'ACCEPTED', 'rules accepted');
select pg_temp.check(public.my_terms()->0->>'version' = '2026-10-17', 'acceptance recorded with version');
select public.qa_ask('uz', 'Birinchi savol sarlavhasi', 'Yetarlicha uzun matn, birinchi savol.');
reset role;
select id as qid from public.qa_questions limit 1 \gset
select pg_temp.as_user('70000000-0000-0000-0000-0000000000b3');
select pg_temp.check((public.qa_feed()->>'total')::int = 1, 'reader sees the question before blocking');
select pg_temp.check(public.qa_block_author('question', gen_random_uuid()) = 'NOT_FOUND', 'unknown post');
select pg_temp.check(public.qa_block_author('user', gen_random_uuid()) = 'INVALID', 'only question/answer targets');
select pg_temp.check(public.qa_block_author('question', (public.qa_feed()->'items'->0->>'id')::uuid) = 'BLOCKED', 'reader blocks the author');
select pg_temp.check(public.qa_block_author('question', :'qid') = 'ALREADY', 'second block is a no-op');
select pg_temp.check((public.qa_feed()->>'total')::int = 0 and jsonb_array_length(public.qa_feed()->'items') = 0,
  'blocked author''s posts disappear from the feed');
select pg_temp.expect_msg(format('select public.qa_question(%L)', :'qid'::text), 'not found',
  'blocked author''s question cannot be opened');
select pg_temp.check(jsonb_array_length(public.my_blocks()) = 1
  and (select array_agg(k order by k) from jsonb_object_keys(public.my_blocks()->0) k) = array['created_at', 'id'],
  'block list is opaque (id + date only, the author is not revealed)');
select pg_temp.as_user('70000000-0000-0000-0000-0000000000b4');
select pg_temp.check((public.qa_feed()->>'total')::int = 1, 'other readers still see the question (block is per user)');
select pg_temp.check(public.qa_block_author('question', :'qid') = 'BLOCKED', 'second reader blocks');
select pg_temp.as_user('70000000-0000-0000-0000-0000000000b1');
select pg_temp.check(public.qa_block_author('question', :'qid') = 'SELF', 'cannot block yourself');
select pg_temp.check((public.qa_feed()->>'total')::int = 1, 'the blocked author still sees their own post');
select pg_temp.as_user('70000000-0000-0000-0000-0000000000b3');
select pg_temp.check(public.qa_unblock((public.my_blocks()->0->>'id')::uuid), 'unblock works');
select pg_temp.check((public.qa_feed()->>'total')::int = 1, 'after unblock the post is back');
select pg_temp.as_user('70000000-0000-0000-0000-0000000000b4');
select pg_temp.check(public.qa_unblock((public.my_blocks()->0->>'id')::uuid), 'a block handle works for its owner');
select pg_temp.as_user('70000000-0000-0000-0000-0000000000b3');
select pg_temp.check(not public.qa_unblock(gen_random_uuid()), 'unblock of a foreign/unknown handle changes nothing');

-- Answers by a blocked author are hidden inside a question that stays visible.
reset role;
insert into user_terms (user_id, doc, version) values
 ('70000000-0000-0000-0000-0000000000c1', 'ugc_rules', 't'),
 ('70000000-0000-0000-0000-0000000000c2', 'ugc_rules', 't');
insert into qa_answers (id, question_id, author_id, lang, body)
select '72000000-0000-0000-0000-000000000001', id, '70000000-0000-0000-0000-0000000000c1', 'uz',
  'Birinchi javob uchun yetarlicha uzun matn.' from qa_questions limit 1;
insert into qa_answers (id, question_id, author_id, lang, body)
select '72000000-0000-0000-0000-000000000002', id, '70000000-0000-0000-0000-0000000000c2', 'uz',
  'Ikkinchi javob uchun yetarlicha uzun matn.' from qa_questions limit 1;
select pg_temp.as_user('70000000-0000-0000-0000-0000000000b3');
select pg_temp.check(jsonb_array_length(public.qa_question(:'qid')->'answers') = 2, 'both answers visible');
select pg_temp.check(public.qa_block_author('answer', '72000000-0000-0000-0000-000000000001') = 'BLOCKED', 'block the author of an answer');
select pg_temp.check(jsonb_array_length(public.qa_question(:'qid')->'answers') = 1, 'blocked author''s answer is hidden');
select pg_temp.check((select (a->>'id') = '72000000-0000-0000-0000-000000000002' from jsonb_array_elements(
  public.qa_question(:'qid')->'answers') a), 'the other answer stays');

-- Search wildcards in the Q&A feed are literal too.
select pg_temp.as_user('70000000-0000-0000-0000-0000000000b4');
select pg_temp.check((public.qa_feed(null, '%')->>'total')::int = 0, 'Q&A search "%" is literal');
reset role;
-- Leave the Q&A tables empty for qa_community_test.sql.
delete from qa_answers;
delete from qa_questions;
delete from user_blocks;

select 'ALL ADMIN EXTENSION TESTS PASSED' as result;
