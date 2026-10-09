-- «Taklif va murojaatlar» + admin panel (after publications_test.sql).
\set ON_ERROR_STOP 1
reset role;
-- Earlier test files grant table DML to authenticated for their own checks;
-- restore the migration's state (no direct table privileges).
revoke all on public.support_threads, public.support_messages from anon, authenticated;
revoke all on public.access_grants, public.user_devices from anon, authenticated;
create function pg_temp.as_user(uid text) returns void language plpgsql as $$
begin
  perform set_config('request.jwt.claim.sub', uid, false);
  perform set_config('request.jwt.claims', '{}', false);
  perform set_config('role', 'authenticated', false);
end $$;
create function pg_temp.as_anon() returns void language plpgsql as $$
begin
  perform set_config('request.jwt.claim.sub', '', false);
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

-- a, b = ordinary users; x = identity_admin; m = publication_moderator only.
insert into auth.users (id, email, created_at, email_confirmed_at) values
 ('40000000-0000-0000-0000-00000000000a', 'student-a@x', now(), now()),
 ('40000000-0000-0000-0000-00000000000b', 'expert-b@x', now() - interval '20 days', now()),
 ('40000000-0000-0000-0000-00000000000c', 'owner-admin@x', now() - interval '40 days', now()),
 ('40000000-0000-0000-0000-00000000000d', 'moderator@x', now(), null);
insert into account_roles (user_id, role, granted_by) values
 ('40000000-0000-0000-0000-00000000000c', 'identity_admin', null),
 ('40000000-0000-0000-0000-00000000000d', 'publication_moderator', '40000000-0000-0000-0000-00000000000c');
select pg_temp.check((select count(*) = 2 from private.admin_audit
  where action = 'ROLE_GRANTED' and target_id in ('40000000-0000-0000-0000-00000000000c',
    '40000000-0000-0000-0000-00000000000d')), 'role grants audited by trigger');
insert into access_grants (user_id, tier) values ('40000000-0000-0000-0000-00000000000b', 'professionalPro');
insert into ai_usage (user_id) values ('40000000-0000-0000-0000-00000000000a'),
  ('40000000-0000-0000-0000-00000000000a');
-- An uploaded screenshot (storage row) under a's folder and one under b's.
insert into storage.objects (bucket_id, name) values
 ('support-attachments', '40000000-0000-0000-0000-00000000000a/11111111-1111-4111-8111-111111111111.jpg'),
 ('support-attachments', '40000000-0000-0000-0000-00000000000b/22222222-2222-4222-8222-222222222222.png');

create temp table ids (k text primary key, id uuid);
grant all on ids to authenticated, anon;

-- ---------------------------------------------------------------- user A
select pg_temp.as_user('40000000-0000-0000-0000-00000000000a');
select pg_temp.check(create_support_thread('BUG', 'Crash', 'It crashes', null, false)->>'result'
  = 'CONSENT_REQUIRED', 'consent required');
select pg_temp.check(create_support_thread('BUG', 'Crash', 'It crashes', null, null)->>'result'
  = 'CONSENT_REQUIRED', 'null consent rejected');
select pg_temp.check(create_support_thread('SPAM', 'x', 'y', null, true)->>'result'
  = 'INVALID', 'unknown category rejected');
select pg_temp.check(create_support_thread('BUG', repeat('s', 201), 'y', null, true)->>'result'
  = 'INVALID', 'subject > 200 rejected');
select pg_temp.check(create_support_thread('BUG', 'ok', repeat('b', 4001), null, true)->>'result'
  = 'INVALID', 'body > 4000 rejected');
select pg_temp.check(create_support_thread('BUG', '   ', 'y', null, true)->>'result'
  = 'INVALID', 'blank subject rejected');
select pg_temp.check(create_support_thread('BUG', 'ok', 'y',
  '40000000-0000-0000-0000-00000000000b/22222222-2222-4222-8222-222222222222.png', true)->>'result'
  = 'INVALID', 'cannot attach another user''s file');
select pg_temp.check(create_support_thread('BUG', 'ok', 'y',
  '40000000-0000-0000-0000-00000000000a/33333333-3333-4333-8333-333333333333.jpg', true)->>'result'
  = 'INVALID', 'cannot reference a missing upload');
select pg_temp.check(create_support_thread('BUG', 'ok', 'y',
  '40000000-0000-0000-0000-00000000000a/../x.jpg', true)->>'result'
  = 'INVALID', 'path traversal rejected');
insert into ids select 'ta', (create_support_thread('BUG', '  App crashes on search  ',
  'Steps: open search, type morphine.',
  '40000000-0000-0000-0000-00000000000a/11111111-1111-4111-8111-111111111111.jpg', true)->>'id')::uuid;
select pg_temp.check((select id is not null from ids where k = 'ta'), 'thread created with own attachment');
select pg_temp.check((select t->>'subject' = 'App crashes on search' and t->>'status' = 'NEW'
  and (t->>'message_count')::int = 1 and (t->>'unread')::int = 0
  from jsonb_array_elements(my_support_threads()) t), 'own list: trimmed, NEW, 1 message');
select pg_temp.check(support_unread_count() = 0, 'no unread yet');
select pg_temp.expect_error($q$select * from support_threads$q$, 'no direct table read');
select pg_temp.expect_error($q$select * from support_messages$q$, 'no direct message read');
select pg_temp.expect_error($q$insert into support_messages (thread_id, sender_role, body)
  values ((select id from ids where k = 'ta'), 'ADMIN', 'fake admin')$q$, 'cannot forge admin message');
select pg_temp.expect_error($q$update support_threads set status = 'CLOSED'$q$, 'no direct update');
select pg_temp.expect_error($q$select * from private.admin_audit$q$, 'audit not readable');
select pg_temp.expect_error($q$update private.admin_settings set admin_requires_aal2 = false$q$,
  'MFA setting not writable');
-- Non-admin: every admin RPC is refused.
select pg_temp.expect_error($q$select admin_support_inbox()$q$, 'user: inbox');
select pg_temp.expect_error($q$select admin_reply_support((select id from ids where k = 'ta'), 'hi')$q$, 'user: reply');
select pg_temp.expect_error($q$select admin_set_support_status((select id from ids where k = 'ta'), 'CLOSED')$q$, 'user: status');
select pg_temp.expect_error($q$select admin_stats()$q$, 'user: stats');
select pg_temp.expect_error($q$select admin_users()$q$, 'user: users');
select pg_temp.expect_error($q$select admin_audit_log(10)$q$, 'user: audit log');
select pg_temp.expect_error($q$select admin_dashboard()$q$, 'user: dashboard');
-- Storage: own folder only.
select pg_temp.expect_error($q$insert into storage.objects (bucket_id, name) values
  ('support-attachments', '40000000-0000-0000-0000-00000000000b/44444444-4444-4444-8444-444444444444.jpg')$q$,
  'upload into another user''s folder');
insert into storage.objects (bucket_id, name) values
  ('support-attachments', '40000000-0000-0000-0000-00000000000a/55555555-5555-4555-8555-555555555555.png');
select pg_temp.check((select count(*) = 2 from storage.objects where bucket_id = 'support-attachments'),
  'storage: user sees only own files');

-- ---------------------------------------------------------------- user B
select pg_temp.as_user('40000000-0000-0000-0000-00000000000b');
select pg_temp.check(jsonb_array_length(my_support_threads()) = 0, 'B does not see A''s threads');
select pg_temp.expect_error($q$select support_thread((select id from ids where k = 'ta'))$q$,
  'B cannot open A''s thread');
select pg_temp.check(add_support_message((select id from ids where k = 'ta'), 'hijack', null) = 'NOT_FOUND',
  'B cannot post into A''s thread');
select pg_temp.expect_error($q$select mark_support_read((select id from ids where k = 'ta'))$q$,
  'B cannot mark A''s thread');
select pg_temp.check((select count(*) = 1 from storage.objects where bucket_id = 'support-attachments'),
  'storage: B sees only own file');
insert into ids select 'tb', (create_support_thread('SCIENTIFIC_ERROR', 'Morphine half-life',
  'The value looks outdated.', null, true, 'substance:morphine')->>'id')::uuid;
select pg_temp.check((select t->>'related_entity' = 'substance:morphine'
  from jsonb_array_elements(my_support_threads()) t), 'scientific error keeps related entity');
select pg_temp.check(create_support_thread('SCIENTIFIC_ERROR', 'x', 'y', null, true,
  'bad entity <script>')->>'result' = 'INVALID', 'related entity must be an identifier');

-- Anonymous: nothing.
select pg_temp.as_anon();
select pg_temp.expect_error($q$select my_support_threads()$q$, 'anon: my threads');
select pg_temp.expect_error($q$select create_support_thread('BUG', 'a', 'b', null, true)$q$, 'anon: create');
select pg_temp.expect_error($q$select admin_stats()$q$, 'anon: stats');

-- Publication moderator is NOT a support admin.
select pg_temp.as_user('40000000-0000-0000-0000-00000000000d');
select pg_temp.expect_error($q$select admin_support_inbox()$q$, 'moderator: inbox');
select pg_temp.expect_error($q$select support_thread((select id from ids where k = 'ta'))$q$, 'moderator: thread');

-- ---------------------------------------------------------------- admin
select pg_temp.as_user('40000000-0000-0000-0000-00000000000c');
select pg_temp.check((select (i->>'total')::int = 2 from (select admin_support_inbox() i) x), 'admin inbox total');
select pg_temp.check((select (i->>'total')::int = 1 and i->'items'->0->>'category' = 'SCIENTIFIC_ERROR'
  from (select admin_support_inbox(null, 'SCIENTIFIC_ERROR') i) x), 'inbox category filter');
select pg_temp.check((select (i->>'total')::int = 1 and i->'items'->0->>'author_email' = 'student-a@x'
  and (i->'items'->0->>'has_attachment')::boolean and (i->'items'->0->>'unread')::int = 1
  from (select admin_support_inbox(null, null, 'student-a') i) x), 'inbox search by email');
select pg_temp.check((select (i->>'total')::int = 2 from (select admin_support_inbox('AWAITING') i) x), 'awaiting filter');
select pg_temp.check((select jsonb_array_length(i->'items') = 1 and (i->>'total')::int = 2
  from (select admin_support_inbox(null, null, null, 1, 1) i) x), 'inbox pagination');
select pg_temp.check((select t->>'author_email' = 'student-a@x' and jsonb_array_length(t->'messages') = 1
  from (select support_thread((select id from ids where k = 'ta')) t) x), 'admin opens thread');
select pg_temp.check(mark_support_read((select id from ids where k = 'ta')), 'admin marks read');
select pg_temp.check(admin_reply_support((select id from ids where k = 'ta'), '') = 'INVALID', 'empty reply rejected');
select pg_temp.check(admin_reply_support((select id from ids where k = 'ta'), repeat('r', 4001)) = 'INVALID', 'long reply rejected');
select pg_temp.check(admin_reply_support((select id from ids where k = 'ta'),
  'Thanks — fixed in the next version.') = 'SENT', 'admin replies');
select pg_temp.check(add_support_message((select id from ids where k = 'tb'), 'We are checking the source.', null) = 'SENT',
  'admin replies via add_support_message');
select pg_temp.check(admin_set_support_status((select id from ids where k = 'tb'), 'IN_REVIEW') = 'IN_REVIEW', 'admin sets status');
select pg_temp.check(admin_set_support_status((select id from ids where k = 'tb'), 'DELETED') = 'INVALID_STATUS', 'invalid status');
select pg_temp.check(admin_set_support_status('00000000-0000-0000-0000-000000000999', 'CLOSED') = 'NOT_FOUND', 'unknown thread');
reset role;
select pg_temp.check((select count(*) = 1 from private.admin_audit where action = 'SUPPORT_THREAD_VIEW'), 'audit: thread view');
select pg_temp.check((select count(*) = 2 from private.admin_audit where action = 'SUPPORT_REPLY'
  and actor_id = '40000000-0000-0000-0000-00000000000c'), 'audit: replies');
select pg_temp.check((select count(*) = 1 from private.admin_audit where action = 'SUPPORT_STATUS'
  and detail->>'to' = 'IN_REVIEW'), 'audit: status change');
select pg_temp.check((select not exists (select 1 from private.admin_audit
  where detail::text ilike '%fixed in the next%' or detail::text ilike '%checking the source%')),
  'audit holds no message text');
select pg_temp.as_user('40000000-0000-0000-0000-00000000000c');
-- Admin can read attachments in the private bucket.
select pg_temp.check((select count(*) = 3 from storage.objects where bucket_id = 'support-attachments'),
  'storage: admin reads all attachments');
-- Stats: aggregated counts only, no free text.
select pg_temp.check((select (s->'users'->>'total')::int >= 4 and (s->'users'->>'new_today')::int >= 2
  and (s->'users'->>'new_30d')::int >= 3
  and s->'modes'->'students' = 'null'::jsonb and (s->'modes'->>'stored_server_side')::boolean = false
  and (s->'tiers'->>'pro')::int >= 1 and (s->'support'->>'awaiting')::int = 1
  and (s->'support'->>'answered')::int = 1 and (s->'ai'->>'d7')::int >= 2
  and (s->'active'->>'d7')::int >= 1 and jsonb_array_length(s->'daily') = 14
  from (select admin_stats() s) x), 'stats counts');
select pg_temp.check((select s::text not ilike '%crashes%' and s::text not ilike '%morphine%'
  and s::text not ilike '%@x%' and s::text not ilike '%fixed in%'
  from (select admin_stats() s) x), 'stats contain no free text or emails');
-- Users list.
select pg_temp.check((select (u->>'total')::int >= 4 from (select admin_users() u) x), 'users list');
select pg_temp.check((select (u->>'total')::int = 1 and u->'items'->0->>'tier' = 'professionalPro'
  and u->'items'->0->>'status' = 'ACTIVE'
  from (select admin_users('expert-b') u) x), 'users search + tier');
select pg_temp.check((select bool_and(i->'roles' ? 'identity_admin')
  from (select admin_users(null, 'admin') u) x, jsonb_array_elements(u->'items') i), 'users role filter');
select pg_temp.check((select bool_and(i->>'tier' is not null)
  from (select admin_users(null, null, 'pro') u) x, jsonb_array_elements(u->'items') i), 'users tier filter');
select pg_temp.check((select i->>'status' = 'UNCONFIRMED'
  from (select admin_users('moderator@x') u) x, jsonb_array_elements(u->'items') i
  where i->>'id' = '40000000-0000-0000-0000-00000000000d'), 'unconfirmed status');
select pg_temp.check((select u::text not ilike '%password%' and u::text not ilike '%token%'
  and u::text not ilike '%encrypted%' from (select admin_users() u) x), 'users: no secrets');
select pg_temp.check((select (i->>'last_activity') is not null
  from (select admin_users('student-a') u) x, jsonb_array_elements(u->'items') i), 'users: last activity from ai_usage');
reset role;
select pg_temp.check((select count(*) >= 1 from private.admin_audit where action = 'USERS_VIEW'), 'audit: users view');
select pg_temp.as_user('40000000-0000-0000-0000-00000000000c');
-- Access grants are audited.
select pg_temp.check(admin_set_access('student-a@x', 'studentPro') = 'GRANTED', 'grant');
reset role;
select pg_temp.check((select count(*) = 1 from private.admin_audit where action = 'ACCESS_SET'
  and target_id = '40000000-0000-0000-0000-00000000000a' and detail->>'result' = 'GRANTED'), 'audit: access grant');
select pg_temp.as_user('40000000-0000-0000-0000-00000000000c');
select pg_temp.check((select jsonb_array_length(a) >= 5 and a->0->>'actor_email' is not null
  from (select admin_audit_log(50) a) x), 'admin reads audit log');

-- ---------------------------------------------------------------- user A again
select pg_temp.as_user('40000000-0000-0000-0000-00000000000a');
select pg_temp.check(support_unread_count() = 1, 'unread admin reply');
select pg_temp.check((select t->>'status' = 'ANSWERED' and (t->>'unread')::int = 1
  from jsonb_array_elements(my_support_threads()) t), 'list shows ANSWERED + unread');
select pg_temp.check((select t->'messages'->1->>'sender_role' = 'ADMIN'
  and not (t->'messages'->1->>'mine')::boolean and (t->'messages'->0->>'mine')::boolean
  and not (t ? 'author_email') and t::text not ilike '%owner-admin%'
  and t::text not ilike '%40000000-0000-0000-0000-00000000000c%'
  from (select support_thread((select id from ids where k = 'ta')) t) x), 'author sees reply, admin identity hidden');
select pg_temp.check(mark_support_read((select id from ids where k = 'ta')), 'author marks read');
select pg_temp.check(support_unread_count() = 0, 'unread cleared');
select pg_temp.check(add_support_message((select id from ids where k = 'ta'), 'Still crashes on 0.4.2', null) = 'SENT',
  'author follow-up');
select pg_temp.check((select t->>'status' = 'NEW' from jsonb_array_elements(my_support_threads()) t),
  'follow-up re-opens answered thread');
select pg_temp.check(add_support_message((select id from ids where k = 'ta'), '', null) = 'INVALID', 'empty follow-up');
reset role;
update support_threads set status = 'CLOSED' where id = (select id from ids where k = 'ta');
select pg_temp.as_user('40000000-0000-0000-0000-00000000000a');
select pg_temp.check(add_support_message((select id from ids where k = 'ta'), 'more', null) = 'CLOSED', 'closed thread');

-- ---------------------------------------------------------------- rate limits
-- Threads: 10 per 24 h (A already has 1).
select create_support_thread('GENERAL', 'n' || g, 'body', null, true) from generate_series(1, 9) g;
select pg_temp.check(create_support_thread('GENERAL', 'eleventh', 'body', null, true)->>'result'
  = 'RATE_LIMITED', 'thread rate limit (10/day)');
-- Messages: 60 per hour (B has 1 so far).
select pg_temp.as_user('40000000-0000-0000-0000-00000000000b');
reset role;
update support_threads set status = 'IN_REVIEW' where id = (select id from ids where k = 'tb');
select pg_temp.as_user('40000000-0000-0000-0000-00000000000b');
select add_support_message((select id from ids where k = 'tb'), 'm' || g, null) from generate_series(1, 59) g;
select pg_temp.check(add_support_message((select id from ids where k = 'tb'), 'one too many', null)
  = 'RATE_LIMITED', 'message rate limit (60/hour)');
select pg_temp.check(create_support_thread('GENERAL', 'x', 'y', null, true)->>'result'
  = 'RATE_LIMITED', 'message limit also blocks new threads');

-- ---------------------------------------------------------------- MFA (aal2)
reset role;
update private.admin_settings set admin_requires_aal2 = true;
select pg_temp.as_user('40000000-0000-0000-0000-00000000000c');
select pg_temp.expect_error($q$select admin_stats()$q$, 'aal1 admin blocked when MFA required');
select pg_temp.expect_error($q$select admin_set_access('student-a@x', null)$q$, 'aal1 grant blocked when MFA required');
select set_config('request.jwt.claims', '{"aal":"aal2"}', false);
select pg_temp.check((select admin_stats() is not null), 'aal2 admin allowed');
reset role;
update private.admin_settings set admin_requires_aal2 = false;

-- ---------------------------------------------------------------- deletion
-- Deleting A removes A's threads/messages; the admin's audit rows stay.
delete from auth.users where id = '40000000-0000-0000-0000-00000000000a';
select pg_temp.check((select count(*) = 0 from support_threads where author_id = '40000000-0000-0000-0000-00000000000a'),
  'account deletion removes threads');
select pg_temp.check((select count(*) = 0 from support_messages m where not exists
  (select 1 from support_threads t where t.id = m.thread_id)), 'no orphan messages');
-- Deleting the admin keeps their replies in B's thread (sender unknown) and audit rows.
-- (account_roles.granted_by has no ON DELETE action — pre-existing schema.)
delete from account_roles where granted_by = '40000000-0000-0000-0000-00000000000c';
delete from auth.users where id = '40000000-0000-0000-0000-00000000000c';
select pg_temp.check((select count(*) >= 1 from private.admin_audit where action = 'ROLE_REVOKED'),
  'role revocation audited by trigger');
select pg_temp.check((select count(*) >= 1 from support_messages where sender_role = 'ADMIN' and sender_id is null),
  'admin replies kept with sender removed');
select pg_temp.check((select count(*) >= 5 from private.admin_audit where actor_id is null), 'audit kept');
select 'ALL SUPPORT/ADMIN TESTS PASSED' as result;
