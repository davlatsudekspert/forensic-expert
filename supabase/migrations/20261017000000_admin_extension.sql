-- FORENSIC EXPERT — admin panel extension (2026-10-17).
--
-- What this migration adds (all server-side; the Flutter client is never
-- trusted):
--   1. Admin bootstrap: private.admin_bootstrap(emails[]) gives the
--      identity_admin role to the owner's e-mail-CONFIRMED account(s). The
--      list comes from the ADMIN_EMAILS secret of the `admin-bootstrap` Edge
--      Function (or is typed once in the SQL console). An e-mail address never
--      grants rights by itself and is never consulted on a normal request —
--      every admin RPC re-checks the role through private.admin_guard(),
--      which now also requires a confirmed e-mail and a non-banned account.
--   2. Reports (complaint / inappropriate content / bug / advertising /
--      other): public.submit_report() works for anon AND signed-in users, is
--      limited to 5 per hour per user id (or per IP/device key hash for anon),
--      and admins list, annotate and resolve them. A user sees only their own.
--   3. Users (admin): LIKE-safe search (% _ \ are escaped), role change
--      (publication_moderator; identity_admin only if the owner switches
--      private.admin_settings.allow_admin_grant_in_app on), account suspension
--      (auth ban + sessions deleted) and restore. An admin cannot be
--      suspended, nobody can suspend themselves, the last admin cannot be
--      demoted. All audited.
--   4. admin_stats_ext(): role counts, report counts, Q&A object counts. What
--      the server cannot know (downloads, sales, casebooks on devices, "online
--      now") is returned as null/false — never invented.
--   5. Apple 1.2: user_blocks (block the AUTHOR of a Q&A post without ever
--      learning who it is), terms acceptance record, and a trigger that
--      refuses a new Q&A question/answer until the rules were accepted.
--
-- No billing, paywall or flag is added.
--
-- ROLLBACK (manual, owner-approved):
--   drop trigger if exists qa_questions_terms on public.qa_questions;
--   drop trigger if exists qa_answers_terms on public.qa_answers;
--   drop function if exists private.qa_terms_required();
--   drop function if exists public.accept_terms(text, text);
--   drop function if exists public.my_terms();
--   drop function if exists public.qa_block_author(text, uuid);
--   drop function if exists public.qa_unblock(uuid);
--   drop function if exists public.my_blocks();
--   drop function if exists public.submit_report(text, text, text, text, text, text);
--   drop function if exists public.my_reports();
--   drop function if exists public.admin_reports(text, text, text, int, int);
--   drop function if exists public.admin_report_note(uuid, text);
--   drop function if exists public.admin_resolve_report(uuid, boolean, text);
--   drop function if exists public.admin_set_role(uuid, text, boolean, text);
--   drop function if exists public.admin_set_suspension(uuid, boolean, text);
--   drop function if exists public.admin_stats_ext();
--   drop function if exists public.admin_bootstrap(text[]);
--   drop function if exists private.admin_bootstrap(text[]);
--   drop function if exists private.assert_active(uuid);
--   drop function if exists private.like_escape(text);
--   drop table if exists public.user_reports, public.user_blocks,
--     public.user_terms, public.account_suspensions;
--   alter table private.admin_settings drop column if exists allow_admin_grant_in_app,
--     drop column if exists report_salt;
--   -- Re-apply private.admin_guard(), admin_users(), admin_support_inbox(),
--   -- qa_feed(), qa_question() from the earlier migrations.

-- ------------------------------------------------------------ settings
alter table private.admin_settings
  add column allow_admin_grant_in_app boolean not null default false,
  -- Salt for IP / device-key hashes in user_reports (never leaves the DB).
  add column report_salt text not null default gen_random_uuid()::text;

-- ------------------------------------------------------------ helpers
-- Escape LIKE wildcards so a search for "100%" or "a_b" matches literally.
-- Use with:  col ilike '%' || private.like_escape(q) || '%' escape '\'
create function private.like_escape(p text) returns text
language sql immutable set search_path = '' as $$
  select replace(replace(replace(p, '\', '\\'), '%', '\%'), '_', '\_')
$$;

-- The single admin check, now also requiring a CONFIRMED e-mail and an
-- account that is not banned. Rights still come only from account_roles.
create or replace function private.admin_guard() returns uuid
language plpgsql stable security definer set search_path = '' as $$
declare me uuid := auth.uid();
begin
  if me is null or not private.has_role(me, 'identity_admin') then
    raise exception 'forbidden';
  end if;
  if not exists (select 1 from auth.users u where u.id = me
                 and u.email_confirmed_at is not null
                 and (u.banned_until is null or u.banned_until <= now())) then
    raise exception 'forbidden';
  end if;
  if coalesce((select s.admin_requires_aal2 from private.admin_settings s), false)
     and coalesce(auth.jwt()->>'aal', '') <> 'aal2' then
    raise exception 'mfa required';
  end if;
  return me;
end $$;

-- ------------------------------------------------------- suspensions
create table public.account_suspensions (
  user_id uuid primary key references auth.users (id) on delete cascade,
  reason text not null check (length(btrim(reason)) between 5 and 500),
  suspended_by uuid references auth.users (id) on delete set null,
  suspended_at timestamptz not null default now()
);
alter table public.account_suspensions enable row level security;
revoke all on public.account_suspensions from anon, authenticated;

-- Raises for a suspended account. Used by every RPC added or rewritten here
-- (the auth ban stops sign-in and refresh; this closes the access-token
-- window of up to jwt_expiry for those RPCs).
create function private.assert_active(p_uid uuid) returns void
language plpgsql stable security definer set search_path = '' as $$
begin
  if p_uid is not null and (
       exists (select 1 from public.account_suspensions s where s.user_id = p_uid)
       or exists (select 1 from auth.users u where u.id = p_uid
                  and u.banned_until is not null and u.banned_until > now())) then
    raise exception 'suspended';
  end if;
end $$;

-- ------------------------------------------------------ admin bootstrap
-- Owner bootstrap: grant identity_admin to e-mail-CONFIRMED accounts whose
-- address is in the list. Unconfirmed or unknown addresses are skipped.
-- Returns how many NEW admin roles were granted. Not callable by the app.
create function private.admin_bootstrap(p_emails text[]) returns int
language plpgsql security definer set search_path = '' as $$
declare v_list text[]; v_n int := 0; r record;
begin
  select coalesce(array_agg(distinct lower(btrim(e))), '{}') into v_list
  from unnest(coalesce(p_emails, '{}')) e
  where btrim(e) <> '' and length(btrim(e)) <= 254;
  if cardinality(v_list) > 10 then raise exception 'too many addresses'; end if;
  for r in select u.id from auth.users u
           where lower(u.email) = any (v_list) and u.email_confirmed_at is not null
  loop
    insert into public.account_roles (user_id, role, granted_by)
    values (r.id, 'identity_admin', null) on conflict do nothing;
    if found then
      v_n := v_n + 1;
      perform private.admin_log(null, 'ADMIN_BOOTSTRAP', 'user', r.id::text,
        jsonb_build_object('source', 'ADMIN_EMAILS'));
    end if;
  end loop;
  return v_n;
end $$;

-- Thin entry point for the `admin-bootstrap` Edge Function (service role
-- only: the JWT role must be service_role AND the grant is service_role only).
create function public.admin_bootstrap(p_emails text[]) returns int
language plpgsql security definer set search_path = '' as $$
begin
  if coalesce(auth.jwt()->>'role', '') <> 'service_role' then
    raise exception 'forbidden';
  end if;
  return private.admin_bootstrap(p_emails);
end $$;

-- ------------------------------------------------------------ reports
create table public.user_reports (
  id uuid primary key default gen_random_uuid(),
  kind text not null check (kind in ('COMPLAINT', 'INAPPROPRIATE_CONTENT',
    'BUG', 'ADVERTISING', 'OTHER')),
  body text not null check (length(btrim(body)) between 5 and 2000),
  -- Optional reply address for a signed-out reporter.
  contact text check (contact is null or length(contact) <= 200),
  target_type text check (target_type in ('qa_question', 'qa_answer', 'qa_user',
    'publication', 'other')),
  target_id text check (target_id ~ '^[A-Za-z0-9_.:/-]{1,80}$'),
  reporter_id uuid references auth.users (id) on delete set null,
  -- 'u:<sha256(uid)>' for signed-in users, 'i:<sha256(ip)>' / 'd:<sha256(device)>'
  -- for anon. Hashes are salted; the raw id / IP / device key is never stored.
  rate_key text not null,
  device_hash text,
  status text not null default 'OPEN' check (status in ('OPEN', 'RESOLVED')),
  admin_note text check (admin_note is null or length(admin_note) <= 2000),
  resolved_by uuid references auth.users (id) on delete set null,
  resolved_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index user_reports_status on public.user_reports (status, created_at desc);
create index user_reports_rate on public.user_reports (rate_key, created_at desc);
create index user_reports_device on public.user_reports (device_hash, created_at desc)
  where device_hash is not null;
create index user_reports_reporter on public.user_reports (reporter_id, created_at desc)
  where reporter_id is not null;
alter table public.user_reports enable row level security;
revoke all on public.user_reports from anon, authenticated;

-- Returns {result: CREATED|INVALID|RATE_LIMITED|SUSPENDED, id?}.
-- Anon allowed. Limit: 5 per hour per user id, or per IP hash / device-key
-- hash for anon (any of them reaching 5 blocks), plus a global anon ceiling.
create function public.submit_report(p_kind text, p_body text,
  p_target_type text default null, p_target_id text default null,
  p_contact text default null, p_device_key text default null)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  v_body text := btrim(coalesce(p_body, ''));
  v_contact text := nullif(btrim(coalesce(p_contact, '')), '');
  v_tt text := nullif(btrim(coalesce(p_target_type, '')), '');
  v_tid text := nullif(btrim(coalesce(p_target_id, '')), '');
  v_salt text := (select s.report_salt from private.admin_settings s);
  v_hdr jsonb;
  v_ip text;
  v_key text;
  v_dev text;
  v_id uuid;
begin
  if p_kind is null or p_kind not in ('COMPLAINT', 'INAPPROPRIATE_CONTENT',
       'BUG', 'ADVERTISING', 'OTHER')
     or length(v_body) not between 5 and 2000
     or (v_contact is not null and length(v_contact) > 200)
     or (v_tt is not null and v_tt not in ('qa_question', 'qa_answer', 'qa_user',
       'publication', 'other'))
     or (v_tid is not null and v_tid !~ '^[A-Za-z0-9_.:/-]{1,80}$') then
    return jsonb_build_object('result', 'INVALID');
  end if;
  begin perform private.assert_active(me);
  exception when others then return jsonb_build_object('result', 'SUSPENDED'); end;

  -- Device key: client-generated random string; ignored if malformed.
  if p_device_key ~ '^[A-Za-z0-9_-]{8,64}$' then
    v_dev := encode(sha256(convert_to(v_salt || ':d:' || p_device_key, 'UTF8')), 'hex');
  end if;
  if me is not null then
    -- Hashed too: the raw user id must not outlive the account in this table.
    v_key := 'u:' || encode(sha256(convert_to(v_salt || ':u:' || me::text, 'UTF8')), 'hex');
  else
    begin
      v_hdr := nullif(current_setting('request.headers', true), '')::jsonb;
    exception when others then v_hdr := null; end;
    v_ip := nullif(btrim(coalesce(v_hdr->>'cf-connecting-ip', v_hdr->>'x-real-ip',
      split_part(coalesce(v_hdr->>'x-forwarded-for', ''), ',', 1), '')), '');
    v_key := case
      when v_ip is not null then
        'i:' || encode(sha256(convert_to(v_salt || ':i:' || v_ip, 'UTF8')), 'hex')
      when v_dev is not null then 'd:' || v_dev
      else 'anon:unknown' end;
    if (select count(*) from public.user_reports r
        where r.reporter_id is null and r.created_at > now() - interval '1 hour') >= 100 then
      return jsonb_build_object('result', 'RATE_LIMITED');
    end if;
  end if;
  if (select count(*) from public.user_reports r
      where r.created_at > now() - interval '1 hour'
        and (r.rate_key = v_key
             or (v_dev is not null and r.device_hash = v_dev))) >= 5 then
    return jsonb_build_object('result', 'RATE_LIMITED');
  end if;
  insert into public.user_reports (kind, body, contact, target_type, target_id,
    reporter_id, rate_key, device_hash)
  values (p_kind, v_body, left(v_contact, 200), v_tt, v_tid, me, v_key, v_dev)
  returning id into v_id;
  return jsonb_build_object('result', 'CREATED', 'id', v_id);
end $$;

-- Own reports only (id, kind, status, dates). Never the admin note.
create function public.my_reports() returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare me uuid := auth.uid();
begin
  if me is null then raise exception 'not signed in'; end if;
  return coalesce((select jsonb_agg(jsonb_build_object(
      'id', r.id, 'kind', r.kind, 'status', r.status,
      'created_at', r.created_at, 'resolved_at', r.resolved_at)
      order by r.created_at desc)
    from (select * from public.user_reports where reporter_id = me
          order by created_at desc limit 50) r), '[]'::jsonb);
end $$;

create function public.admin_reports(p_status text default null,
  p_kind text default null, p_query text default null,
  p_limit int default 25, p_offset int default 0)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  me uuid := private.admin_guard();
  q text := private.like_escape(nullif(btrim(left(coalesce(p_query, ''), 100)), ''));
  v_limit int := least(greatest(coalesce(p_limit, 25), 1), 100);
  v_offset int := greatest(coalesce(p_offset, 0), 0);
  v_result jsonb;
begin
  with f as (
      select r.*, u.email as reporter_email from public.user_reports r
        left join auth.users u on u.id = r.reporter_id
      where (p_status is null or r.status = p_status)
        and (p_kind is null or r.kind = p_kind)
        and (q is null or r.body ilike '%' || q || '%' escape '\'
             or r.contact ilike '%' || q || '%' escape '\'
             or u.email ilike '%' || q || '%' escape '\'))
    select jsonb_build_object(
      'total', (select count(*) from f),
      'items', coalesce((select jsonb_agg(jsonb_build_object(
          'id', x.id, 'kind', x.kind, 'body', x.body, 'contact', x.contact,
          'target_type', x.target_type, 'target_id', x.target_id,
          'reporter_email', x.reporter_email, 'anonymous', x.reporter_id is null,
          'status', x.status, 'admin_note', x.admin_note,
          'created_at', x.created_at, 'resolved_at', x.resolved_at)
          order by (x.status = 'OPEN') desc, x.created_at desc)
        from (select * from f order by (f.status = 'OPEN') desc, f.created_at desc
              limit v_limit offset v_offset) x), '[]'::jsonb))
  into v_result;
  -- Reporter e-mails / contacts are personal data: viewing the list is audited
  -- (ids and filters only, like USERS_VIEW).
  perform private.admin_log(me, 'REPORTS_VIEW', 'user_reports', null, jsonb_build_object(
    'status', p_status, 'kind', p_kind, 'search', q is not null, 'offset', v_offset));
  return v_result;
end $$;

-- Returns SAVED | NOT_FOUND | INVALID.
create function public.admin_report_note(p_id uuid, p_note text)
returns text language plpgsql security definer set search_path = '' as $$
declare me uuid := private.admin_guard(); v_note text := btrim(coalesce(p_note, ''));
begin
  if length(v_note) not between 1 and 2000 then return 'INVALID'; end if;
  update public.user_reports set admin_note = v_note, updated_at = now() where id = p_id;
  if not found then return 'NOT_FOUND'; end if;
  perform private.admin_log(me, 'REPORT_NOTE', 'user_report', p_id::text,
    jsonb_build_object('length', length(v_note)));
  return 'SAVED';
end $$;

-- Returns RESOLVED | REOPENED | NOT_FOUND | INVALID. A note (optional) is
-- saved together with the decision.
create function public.admin_resolve_report(p_id uuid,
  p_resolved boolean default true, p_note text default null)
returns text language plpgsql security definer set search_path = '' as $$
declare
  me uuid := private.admin_guard();
  v_note text := nullif(btrim(coalesce(p_note, '')), '');
begin
  if v_note is not null and length(v_note) > 2000 then return 'INVALID'; end if;
  update public.user_reports set
    status = case when coalesce(p_resolved, true) then 'RESOLVED' else 'OPEN' end,
    resolved_by = case when coalesce(p_resolved, true) then me end,
    resolved_at = case when coalesce(p_resolved, true) then now() end,
    admin_note = coalesce(v_note, admin_note), updated_at = now()
  where id = p_id;
  if not found then return 'NOT_FOUND'; end if;
  perform private.admin_log(me, case when coalesce(p_resolved, true)
      then 'REPORT_RESOLVED' else 'REPORT_REOPENED' end,
    'user_report', p_id::text, jsonb_build_object('note', v_note is not null));
  return case when coalesce(p_resolved, true) then 'RESOLVED' else 'REOPENED' end;
end $$;

-- ------------------------------------------------- role / suspension
-- Returns GRANTED | REVOKED | UNCHANGED | NOT_FOUND | INVALID | FORBIDDEN_ROLE
-- | EMAIL_UNCONFIRMED | SELF_ADMIN_CHANGE | LAST_ADMIN.
-- Only publication_moderator and identity_admin can be changed here;
-- scope_grantor (reviewer authority) is never granted from the panel: admin
-- is not a scientific reviewer. identity_admin can be GRANTED in-app only
-- when the owner enabled private.admin_settings.allow_admin_grant_in_app.
create function public.admin_set_role(p_user uuid, p_role text,
  p_grant boolean, p_reason text)
returns text language plpgsql security definer set search_path = '' as $$
declare
  me uuid := private.admin_guard();
  v_reason text := btrim(coalesce(p_reason, ''));
  v_result text;
begin
  if p_role is null or p_role not in ('identity_admin', 'publication_moderator') then
    return 'FORBIDDEN_ROLE';
  end if;
  if p_grant is null or length(v_reason) not between 5 and 300 then return 'INVALID'; end if;
  if not exists (select 1 from auth.users where id = p_user) then return 'NOT_FOUND'; end if;
  if p_role = 'identity_admin' then
    if p_user = me then return 'SELF_ADMIN_CHANGE'; end if;
    if p_grant and not (select s.allow_admin_grant_in_app from private.admin_settings s) then
      return 'FORBIDDEN_ROLE';
    end if;
  end if;
  if p_grant then
    if p_role = 'identity_admin' and not exists (select 1 from auth.users
         where id = p_user and email_confirmed_at is not null) then
      return 'EMAIL_UNCONFIRMED';
    end if;
    insert into public.account_roles (user_id, role, granted_by)
    values (p_user, p_role::public.account_role, me) on conflict do nothing;
    v_result := case when found then 'GRANTED' else 'UNCHANGED' end;
  else
    if p_role = 'identity_admin' and
       (select count(*) from public.account_roles where role = 'identity_admin') <= 1 then
      return 'LAST_ADMIN';
    end if;
    delete from public.account_roles where user_id = p_user and role = p_role::public.account_role;
    v_result := case when found then 'REVOKED' else 'UNCHANGED' end;
  end if;
  perform private.admin_log(me, 'ADMIN_ROLE_SET', 'user', p_user::text,
    jsonb_build_object('role', p_role, 'grant', p_grant, 'result', v_result,
      'reason', v_reason));
  return v_result;
end $$;

-- Suspend (p_suspend = true) or restore an account. Suspension: the auth ban
-- (auth.users.banned_until, honoured by sign-in AND token refresh) plus every
-- session / refresh token of the user deleted. An access token already issued
-- stays valid until it expires (jwt_expiry, 1 h) for RPCs that do not call
-- private.assert_active(); the new RPCs here do.
-- Returns SUSPENDED | RESTORED | UNCHANGED | NOT_FOUND | INVALID
-- | CANNOT_SUSPEND_ADMIN | CANNOT_SUSPEND_SELF.
create function public.admin_set_suspension(p_user uuid, p_suspend boolean,
  p_reason text)
returns text language plpgsql security definer set search_path = '' as $$
declare
  me uuid := private.admin_guard();
  v_reason text := btrim(coalesce(p_reason, ''));
  v_was boolean;
begin
  if p_suspend is null or length(v_reason) not between 5 and 500 then return 'INVALID'; end if;
  if not exists (select 1 from auth.users where id = p_user) then return 'NOT_FOUND'; end if;
  if p_suspend then
    if p_user = me then return 'CANNOT_SUSPEND_SELF'; end if;
    if private.has_role(p_user, 'identity_admin') then return 'CANNOT_SUSPEND_ADMIN'; end if;
    v_was := exists (select 1 from public.account_suspensions where user_id = p_user);
    insert into public.account_suspensions (user_id, reason, suspended_by)
    values (p_user, v_reason, me)
    on conflict (user_id) do update set reason = excluded.reason,
      suspended_by = me, suspended_at = now();
    update auth.users set banned_until = now() + interval '36500 days' where id = p_user;
    delete from auth.refresh_tokens where user_id = p_user::text;
    delete from auth.sessions where user_id = p_user;
    perform private.admin_log(me, 'USER_SUSPENDED', 'user', p_user::text,
      jsonb_build_object('reason', v_reason));
    return case when v_was then 'UNCHANGED' else 'SUSPENDED' end;
  end if;
  v_was := exists (select 1 from public.account_suspensions where user_id = p_user);
  delete from public.account_suspensions where user_id = p_user;
  update auth.users set banned_until = null where id = p_user;
  perform private.admin_log(me, 'USER_RESTORED', 'user', p_user::text,
    jsonb_build_object('reason', v_reason));
  return case when v_was then 'RESTORED' else 'UNCHANGED' end;
end $$;

-- ---------------------------------------------------------------- stats
-- Counts only. Anything the server cannot know is null / false, never a guess.
create function public.admin_stats_ext() returns jsonb
language plpgsql stable security definer set search_path = '' as $$
begin
  perform private.admin_guard();
  return jsonb_build_object(
    'generated_at', now(),
    'roles', jsonb_build_object(
      'identity_admin', (select count(*) from public.account_roles where role = 'identity_admin'),
      'publication_moderator', (select count(*) from public.account_roles where role = 'publication_moderator'),
      'scope_grantor', (select count(*) from public.account_roles where role = 'scope_grantor')),
    'suspended', (select count(*) from public.account_suspensions),
    'reports', jsonb_build_object(
      'open', (select count(*) from public.user_reports where status = 'OPEN'),
      'resolved', (select count(*) from public.user_reports where status = 'RESOLVED'),
      'by_kind', coalesce((select jsonb_object_agg(k.kind, k.n) from (
          select kind, count(*) as n from public.user_reports group by 1) k), '{}'::jsonb)),
    'qa', jsonb_build_object(
      'questions', (select count(*) from public.qa_questions where status = 'published'),
      'answers', (select count(*) from public.qa_answers where status = 'published'),
      'in_moderation', (select count(*) from public.qa_questions where status = 'moderation')
                     + (select count(*) from public.qa_answers where status = 'moderation')),
    'blocks', (select count(*) from public.user_blocks),
    -- Not on the server: casebooks live on the device; downloads and store
    -- sales are in App Store Connect / Google Play Console; there is no
    -- payment system; user_devices.last_seen is a start-up check-in, not a
    -- heartbeat, so "online in the last 15 minutes" cannot be computed.
    'casebooks', jsonb_build_object('stored_server_side', false),
    'downloads', jsonb_build_object('available', false),
    'sales', jsonb_build_object('available', false, 'payment_system', false),
    'online_now', jsonb_build_object('available', false));
end $$;

-- ------------------------------------------- Apple 1.2: blocks, terms
create table public.user_blocks (
  id uuid primary key default gen_random_uuid(),
  blocker_id uuid not null references auth.users (id) on delete cascade,
  blocked_id uuid not null references auth.users (id) on delete cascade,
  created_at timestamptz not null default now(),
  unique (blocker_id, blocked_id),
  check (blocker_id <> blocked_id)
);
alter table public.user_blocks enable row level security;
revoke all on public.user_blocks from anon, authenticated;

create table public.user_terms (
  user_id uuid not null references auth.users (id) on delete cascade,
  doc text not null check (doc in ('ugc_rules')),
  version text not null check (length(version) between 1 and 40),
  accepted_at timestamptz not null default now(),
  primary key (user_id, doc)
);
alter table public.user_terms enable row level security;
revoke all on public.user_terms from anon, authenticated;

-- Records acceptance of the community rules. Returns ACCEPTED | INVALID.
create function public.accept_terms(p_doc text, p_version text) returns text
language plpgsql security definer set search_path = '' as $$
declare me uuid := auth.uid();
begin
  if me is null then raise exception 'not signed in'; end if;
  perform private.assert_active(me);
  if p_doc is distinct from 'ugc_rules' or length(btrim(coalesce(p_version, ''))) not between 1 and 40 then
    return 'INVALID';
  end if;
  insert into public.user_terms (user_id, doc, version) values (me, p_doc, btrim(p_version))
  on conflict (user_id, doc) do update set version = excluded.version, accepted_at = now();
  return 'ACCEPTED';
end $$;

create function public.my_terms() returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare me uuid := auth.uid();
begin
  if me is null then raise exception 'not signed in'; end if;
  return coalesce((select jsonb_agg(jsonb_build_object(
      'doc', t.doc, 'version', t.version, 'accepted_at', t.accepted_at))
    from public.user_terms t where t.user_id = me), '[]'::jsonb);
end $$;

-- A new Q&A question / answer needs accepted community rules (server side:
-- an old or modified client cannot skip the agreement).
create function private.qa_terms_required() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  if not exists (select 1 from public.user_terms t
                 where t.user_id = new.author_id and t.doc = 'ugc_rules') then
    raise exception 'terms_required';
  end if;
  return new;
end $$;
create trigger qa_questions_terms before insert on public.qa_questions
  for each row execute function private.qa_terms_required();
create trigger qa_answers_terms before insert on public.qa_answers
  for each row execute function private.qa_terms_required();

-- Block the author of a post WITHOUT learning who it is. Returns
-- BLOCKED | ALREADY | NOT_FOUND | SELF | INVALID.
create function public.qa_block_author(p_target_type text, p_target_id uuid)
returns text language plpgsql security definer set search_path = '' as $$
declare me uuid := auth.uid(); v_author uuid;
begin
  if me is null then raise exception 'forbidden'; end if;
  perform private.assert_active(me);
  if p_target_type = 'question' then
    select author_id into v_author from public.qa_questions where id = p_target_id;
  elsif p_target_type = 'answer' then
    select author_id into v_author from public.qa_answers where id = p_target_id;
  else
    return 'INVALID';
  end if;
  if v_author is null then return 'NOT_FOUND'; end if;
  if v_author = me then return 'SELF'; end if;
  if (select count(*) from public.user_blocks where blocker_id = me) >= 500 then
    return 'INVALID';
  end if;
  insert into public.user_blocks (blocker_id, blocked_id) values (me, v_author)
  on conflict do nothing;
  return case when found then 'BLOCKED' else 'ALREADY' end;
end $$;

-- Blocks as opaque handles: id + date. The blocked person is never revealed.
create function public.my_blocks() returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare me uuid := auth.uid();
begin
  if me is null then raise exception 'forbidden'; end if;
  return coalesce((select jsonb_agg(jsonb_build_object(
      'id', b.id, 'created_at', b.created_at) order by b.created_at desc)
    from public.user_blocks b where b.blocker_id = me), '[]'::jsonb);
end $$;

create function public.qa_unblock(p_block_id uuid) returns boolean
language plpgsql security definer set search_path = '' as $$
declare me uuid := auth.uid();
begin
  if me is null then raise exception 'forbidden'; end if;
  delete from public.user_blocks where id = p_block_id and blocker_id = me;
  return found;
end $$;

-- qa_feed / qa_question: hide posts of authors the caller blocked, refuse a
-- suspended caller, and search literally (LIKE wildcards escaped).
create or replace function public.qa_feed(p_tag text default null, p_query text default null,
  p_limit int default 20, p_offset int default 0) returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  v_limit int := least(greatest(coalesce(p_limit, 20), 1), 50);
  v_offset int := greatest(coalesce(p_offset, 0), 0);
  v_q text := private.like_escape(nullif(btrim(coalesce(p_query, '')), ''));
begin
  if me is null then raise exception 'forbidden'; end if;
  perform private.assert_active(me);
  return jsonb_build_object(
    'total', (select count(*) from public.qa_questions q
              where q.status = 'published'
                and not exists (select 1 from public.user_blocks b
                                where b.blocker_id = me and b.blocked_id = q.author_id)
                and (p_tag is null or p_tag = any (q.tags))
                and (v_q is null or q.title ilike '%' || v_q || '%' escape '\'
                     or q.body ilike '%' || v_q || '%' escape '\')),
    'items', coalesce((select jsonb_agg(jsonb_build_object(
        'id', x.id, 'lang', x.lang, 'title', x.title,
        'excerpt', left(x.body, 240), 'tags', to_jsonb(x.tags),
        'pinned', x.pinned, 'answer_count', x.answer_count,
        'has_accepted', x.accepted_answer_id is not null,
        'is_mine', x.author_id = me,
        'author_role', (select p.role from public.qa_profiles p
                        where p.user_id = x.author_id and p.status = 'verified'),
        'created_at', x.created_at)
        order by x.pinned desc, x.created_at desc)
      from (select q.* from public.qa_questions q
            where q.status = 'published'
              and not exists (select 1 from public.user_blocks b
                              where b.blocker_id = me and b.blocked_id = q.author_id)
              and (p_tag is null or p_tag = any (q.tags))
              and (v_q is null or q.title ilike '%' || v_q || '%' escape '\'
                   or q.body ilike '%' || v_q || '%' escape '\')
            order by q.pinned desc, q.created_at desc
            limit v_limit offset v_offset) x), '[]'::jsonb));
end $$;

create or replace function public.qa_question(p_id uuid) returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare me uuid := auth.uid(); q public.qa_questions;
begin
  if me is null then raise exception 'forbidden'; end if;
  perform private.assert_active(me);
  select * into q from public.qa_questions where id = p_id;
  if q.id is null or (q.status <> 'published' and q.author_id <> me)
     or (q.author_id <> me and exists (select 1 from public.user_blocks b
           where b.blocker_id = me and b.blocked_id = q.author_id)) then
    raise exception 'not found';
  end if;
  return jsonb_build_object(
    'id', q.id, 'lang', q.lang, 'title', q.title, 'body', q.body,
    'tags', to_jsonb(q.tags), 'status', q.status, 'pinned', q.pinned,
    'is_mine', q.author_id = me, 'created_at', q.created_at,
    'accepted_answer_id', q.accepted_answer_id,
    'answers', coalesce((select jsonb_agg(jsonb_build_object(
        'id', a.id, 'lang', a.lang, 'body', a.body, 'score', a.score,
        'created_at', a.created_at, 'is_mine', a.author_id = me,
        'accepted', a.id = q.accepted_answer_id,
        'author_role', (select p.role from public.qa_profiles p
                        where p.user_id = a.author_id and p.status = 'verified'),
        'my_vote', coalesce((select v.value from public.qa_votes v
                             where v.answer_id = a.id and v.voter_id = me), 0))
        order by (a.id = q.accepted_answer_id) desc, a.score desc, a.created_at)
      from public.qa_answers a
      where a.question_id = q.id
        and (a.status = 'published' or a.author_id = me)
        and not exists (select 1 from public.user_blocks b
                        where b.blocker_id = me and b.blocked_id = a.author_id
                          and a.author_id <> me)), '[]'::jsonb));
end $$;

-- ----------------------------------- LIKE-safe admin search (rewritten)
create or replace function public.admin_users(p_search text default null,
  p_role text default null, p_tier text default null,
  p_limit int default 50, p_offset int default 0)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  me uuid := private.admin_guard();
  q text := private.like_escape(nullif(btrim(left(coalesce(p_search, ''), 100)), ''));
  q_raw text := nullif(btrim(left(coalesce(p_search, ''), 100)), '');
  v_limit int := least(greatest(coalesce(p_limit, 50), 1), 200);
  v_offset int := greatest(coalesce(p_offset, 0), 0);
  v_result jsonb;
begin
  with base as (
    select u.id, u.email, u.created_at, u.last_sign_in_at,
      u.email_confirmed_at, u.banned_until, p.display_name, p.primary_specialty,
      p.languages, v.status::text as verification,
      (select g.tier from public.access_grants g where g.user_id = u.id
         and (g.expires_at is null or g.expires_at > now())) as tier,
      coalesce((select array_agg(r.role::text order by r.role::text)
         from public.account_roles r where r.user_id = u.id), '{}') as roles
    from auth.users u
    left join public.professional_profiles p on p.user_id = u.id
    left join public.verification v on v.user_id = u.id),
  f as (
    select * from base b
    where (q is null or b.email ilike '%' || q || '%' escape '\' or b.display_name ilike '%' || q || '%' escape '\')
      and (p_role is null
           or (p_role = 'admin' and 'identity_admin' = any (b.roles))
           or (p_role = 'moderator' and 'publication_moderator' = any (b.roles)))
      and (p_tier is null
           or (p_tier = 'free' and b.tier is null)
           or (p_tier = 'pro' and b.tier is not null)
           or b.tier = p_tier))
  select jsonb_build_object(
    'total', (select count(*) from f),
    'items', coalesce((select jsonb_agg(jsonb_build_object(
        'id', x.id, 'email', x.email, 'display_name', x.display_name,
        'created_at', x.created_at, 'last_sign_in_at', x.last_sign_in_at,
        'specialty', x.primary_specialty, 'languages', to_jsonb(x.languages),
        'locale', (select d.locale from public.user_devices d where d.user_id = x.id
                    order by d.last_seen desc limit 1),
        'platforms', (select string_agg(d.platform, ',' order by d.platform)
                       from public.user_devices d where d.user_id = x.id),
        'verification', x.verification, 'tier', x.tier, 'roles', to_jsonb(x.roles),
        'last_activity', greatest(x.last_sign_in_at,
            (select max(d.last_seen) from public.user_devices d where d.user_id = x.id),
            (select max(a.created_at) from public.ai_usage a where a.user_id = x.id)),
        'status', case when x.banned_until is not null and x.banned_until > now() then 'BANNED'
                       when x.email_confirmed_at is null then 'UNCONFIRMED'
                       else 'ACTIVE' end)
        order by x.created_at desc)
      from (select * from f order by f.created_at desc
            limit v_limit offset v_offset) x), '[]'::jsonb))
  into v_result;
  perform private.admin_log(me, 'USERS_VIEW', 'users', null, jsonb_build_object(
    'search', q_raw is not null, 'role', p_role, 'tier', p_tier, 'offset', v_offset));
  return v_result;
end $$;

create or replace function public.admin_support_inbox(p_status text default null,
  p_category text default null, p_query text default null,
  p_limit int default 50, p_offset int default 0)
returns jsonb language plpgsql stable security definer set search_path = '' as $$
declare
  q text := private.like_escape(nullif(btrim(left(coalesce(p_query, ''), 100)), ''));
  v_limit int := least(greatest(coalesce(p_limit, 50), 1), 200);
  v_offset int := greatest(coalesce(p_offset, 0), 0);
begin
  perform private.admin_guard();
  return (with f as (
      select t.*, u.email from public.support_threads t
        left join auth.users u on u.id = t.author_id
      where (p_status is null or t.status = p_status
             or (p_status = 'AWAITING' and t.status in ('NEW', 'IN_REVIEW')))
        and (p_category is null or t.category = p_category)
        and (q is null or t.subject ilike '%' || q || '%' escape '\' or u.email ilike '%' || q || '%' escape '\'))
    select jsonb_build_object(
      'total', (select count(*) from f),
      'items', coalesce((select jsonb_agg(jsonb_build_object(
          'id', x.id, 'category', x.category, 'subject', x.subject,
          'status', x.status, 'related_entity', x.related_entity,
          'author_email', x.email, 'created_at', x.created_at,
          'updated_at', x.updated_at, 'last_admin_reply_at', x.last_admin_reply_at,
          'message_count', (select count(*) from public.support_messages m
                             where m.thread_id = x.id),
          'has_attachment', exists (select 1 from public.support_messages m
                             where m.thread_id = x.id and m.attachment_path is not null),
          'unread', (select count(*) from public.support_messages m
                      where m.thread_id = x.id and m.sender_role = 'USER'
                        and m.created_at > coalesce(x.admin_last_read_at, '-infinity'::timestamptz)))
          order by x.updated_at desc)
        from (select * from f order by f.updated_at desc
              limit v_limit offset v_offset) x), '[]'::jsonb)));
end $$;

-- ---------------------------------------------------------------- grants
revoke execute on function private.like_escape(text) from public, anon, authenticated;
revoke execute on function private.assert_active(uuid) from public, anon, authenticated;
revoke execute on function private.admin_bootstrap(text[]) from public, anon, authenticated;
revoke execute on function private.qa_terms_required() from public, anon, authenticated;
revoke execute on function public.admin_bootstrap(text[]) from public, anon, authenticated;
grant execute on function public.admin_bootstrap(text[]) to service_role;

revoke execute on function public.submit_report(text, text, text, text, text, text) from public, anon, authenticated;
revoke execute on function public.my_reports() from public, anon, authenticated;
revoke execute on function public.admin_reports(text, text, text, int, int) from public, anon, authenticated;
revoke execute on function public.admin_report_note(uuid, text) from public, anon, authenticated;
revoke execute on function public.admin_resolve_report(uuid, boolean, text) from public, anon, authenticated;
revoke execute on function public.admin_set_role(uuid, text, boolean, text) from public, anon, authenticated;
revoke execute on function public.admin_set_suspension(uuid, boolean, text) from public, anon, authenticated;
revoke execute on function public.admin_stats_ext() from public, anon, authenticated;
revoke execute on function public.accept_terms(text, text) from public, anon, authenticated;
revoke execute on function public.my_terms() from public, anon, authenticated;
revoke execute on function public.qa_block_author(text, uuid) from public, anon, authenticated;
revoke execute on function public.my_blocks() from public, anon, authenticated;
revoke execute on function public.qa_unblock(uuid) from public, anon, authenticated;

-- The ONE function anon may call: sending a report without signing in.
grant execute on function public.submit_report(text, text, text, text, text, text) to anon, authenticated;
grant execute on function public.my_reports() to authenticated;
grant execute on function public.admin_reports(text, text, text, int, int) to authenticated;
grant execute on function public.admin_report_note(uuid, text) to authenticated;
grant execute on function public.admin_resolve_report(uuid, boolean, text) to authenticated;
grant execute on function public.admin_set_role(uuid, text, boolean, text) to authenticated;
grant execute on function public.admin_set_suspension(uuid, boolean, text) to authenticated;
grant execute on function public.admin_stats_ext() to authenticated;
grant execute on function public.accept_terms(text, text) to authenticated;
grant execute on function public.my_terms() to authenticated;
grant execute on function public.qa_block_author(text, uuid) to authenticated;
grant execute on function public.my_blocks() to authenticated;
grant execute on function public.qa_unblock(uuid) to authenticated;
