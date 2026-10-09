-- FORENSIC EXPERT — «Taklif va murojaatlar» (suggestions & support inbox)
-- and the hardened admin panel (stats, inbox, users, audit log).
--
-- Security model (enforced HERE; the Flutter client is never trusted):
--   * support_threads / support_messages: RLS on, NO policies, NO table
--     privileges for anon / authenticated. Every read/write goes through the
--     SECURITY DEFINER RPCs below, which check auth.uid().
--   * A user sees ONLY their own threads. Admin replies are shown to the
--     author as sender_role = 'ADMIN' — the admin's identity is never sent.
--   * Admin = private.has_role(uid, 'identity_admin') (account_roles, granted
--     by the owner out-of-band). Never derived from an email address.
--   * private.admin_guard() is the single admin check. When
--     private.admin_settings.admin_requires_aal2 is true it also requires an
--     MFA session (auth.jwt()->>'aal' = 'aal2'). Default: false, so nothing
--     changes until the owner has enrolled TOTP (docs/ADMIN_PANEL.md).
--   * Every admin write (reply, status change, access grant/revoke) and every
--     admin view of personal data (a support thread, the users list) writes a
--     row to private.admin_audit. Audit rows hold ids, statuses and lengths —
--     never message text. Changes to account_roles (made in the SQL console)
--     are audited by trigger.
--   * Limits: subject <= 200, message <= 4000 chars; <= 10 new threads per
--     user per 24 h; <= 60 messages per user per hour. Consent to process the
--     message is required to open a thread (consent_at is stored).
--   * Attachments: private bucket support-attachments (jpeg/png/webp,
--     <= 5 MB). Path <uid>/<uuid>.<ext>; users write/read only their own
--     folder, identity_admin can read. A message may only reference an
--     object that exists under the sender's own folder.
--   * admin_stats() returns aggregated counts only (no free text, no email).
--     Usage mode (student/professional) is NOT stored server-side (it is a
--     device setting), so students/experts are returned as null; the
--     server-side proxies professional_profiles / verified professionals are
--     returned separately and labelled as such.
--   * Account deletion (auth.users delete) cascades to the author's threads
--     and messages; admin-authored messages in other users' threads keep the
--     text with sender_id set to null. Audit rows keep actor_id = null.
--
-- ROLLBACK (manual, owner-approved; destroys all support data and audit):
--   drop trigger if exists account_roles_audit on public.account_roles;
--   drop function if exists private.audit_account_roles();
--   drop function if exists public.create_support_thread(text, text, text, text, boolean, text);
--   drop function if exists public.add_support_message(uuid, text, text);
--   drop function if exists public.my_support_threads();
--   drop function if exists public.support_thread(uuid);
--   drop function if exists public.support_unread_count();
--   drop function if exists public.mark_support_read(uuid);
--   drop function if exists public.admin_support_inbox(text, text, text, int, int);
--   drop function if exists public.admin_reply_support(uuid, text);
--   drop function if exists public.admin_set_support_status(uuid, text);
--   drop function if exists public.admin_stats();
--   drop function if exists public.admin_users(text, text, text, int, int);
--   drop function if exists public.admin_audit_log(int);
--   drop function if exists private.support_attachment_ok(uuid, text);
--   drop function if exists private.admin_log(uuid, text, text, text, jsonb);
--   drop function if exists private.admin_guard();
--   drop policy if exists support_owner_upload on storage.objects;
--   drop policy if exists support_owner_or_admin_read on storage.objects;
--   delete from storage.buckets where id = 'support-attachments';  -- after emptying it
--   drop table if exists public.support_messages, public.support_threads;
--   drop table if exists private.admin_audit, private.admin_settings;
--   -- Then re-apply admin_dashboard() / admin_set_access() from
--   -- 20261006040000_admin_access.sql (they are replaced below to add the
--   -- MFA guard and audit).

-- ---------------------------------------------------------------- tables
create table public.support_threads (
  id uuid primary key default gen_random_uuid(),
  author_id uuid not null references auth.users (id) on delete cascade,
  category text not null check (category in ('SUGGESTION', 'BUG',
    'SCIENTIFIC_ERROR', 'FEATURE_REQUEST', 'TECH_SUPPORT', 'GENERAL')),
  subject text not null check (length(btrim(subject)) between 1 and 200),
  status text not null default 'NEW' check (status in ('NEW', 'IN_REVIEW',
    'ANSWERED', 'CLOSED')),
  -- Content record id (substance / guideline / knowledge entry) for
  -- SCIENTIFIC_ERROR reports. An identifier, not free text.
  related_entity text check (related_entity ~ '^[A-Za-z0-9_.:/-]{1,160}$'),
  consent_at timestamptz not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  last_admin_reply_at timestamptz,
  author_last_read_at timestamptz not null default now(),
  admin_last_read_at timestamptz
);
create index support_threads_author on public.support_threads (author_id, updated_at desc);
create index support_threads_status on public.support_threads (status, updated_at desc);

create table public.support_messages (
  id bigint generated always as identity primary key,
  thread_id uuid not null references public.support_threads (id) on delete cascade,
  sender_id uuid references auth.users (id) on delete set null,
  sender_role text not null check (sender_role in ('USER', 'ADMIN')),
  body text not null check (length(btrim(body)) between 1 and 4000),
  attachment_path text check (length(attachment_path) <= 200),
  created_at timestamptz not null default now()
);
create index support_messages_thread on public.support_messages (thread_id, id);
create index support_messages_sender on public.support_messages (sender_id, created_at desc);

create table private.admin_audit (
  id bigint generated always as identity primary key,
  actor_id uuid references auth.users (id) on delete set null,
  action text not null check (action ~ '^[A-Z_]{3,60}$'),
  target_type text check (length(target_type) <= 40),
  target_id text check (length(target_id) <= 200),
  detail jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);
create index admin_audit_time on private.admin_audit (created_at desc);

-- Single-row settings. Owner turns MFA on in the SQL console AFTER enrolling
-- TOTP:  update private.admin_settings set admin_requires_aal2 = true;
create table private.admin_settings (
  id boolean primary key default true check (id),
  admin_requires_aal2 boolean not null default false
);
insert into private.admin_settings default values;

alter table public.support_threads enable row level security;
alter table public.support_messages enable row level security;
alter table private.admin_audit enable row level security;
alter table private.admin_settings enable row level security;
-- No policies: clients can neither read nor write these tables directly.
revoke all on public.support_threads, public.support_messages from anon, authenticated;
revoke all on private.admin_audit, private.admin_settings from anon, authenticated;

-- ---------------------------------------------------------------- private
-- The only admin check. Returns the admin's uid or raises.
create function private.admin_guard() returns uuid
language plpgsql stable security definer set search_path = '' as $$
declare me uuid := auth.uid();
begin
  if me is null or not private.has_role(me, 'identity_admin') then
    raise exception 'forbidden';
  end if;
  if coalesce((select s.admin_requires_aal2 from private.admin_settings s), false)
     and coalesce(auth.jwt()->>'aal', '') <> 'aal2' then
    raise exception 'mfa required';
  end if;
  return me;
end $$;

create function private.admin_log(p_actor uuid, p_action text,
  p_target_type text, p_target_id text, p_detail jsonb) returns void
language sql security definer set search_path = '' as $$
  insert into private.admin_audit (actor_id, action, target_type, target_id, detail)
  -- actor_id only if the account still exists (e.g. console session claims).
  values ((select u.id from auth.users u where u.id = p_actor), p_action,
          p_target_type, left(p_target_id, 200), coalesce(p_detail, '{}'::jsonb))
$$;

-- Attachment path must be <sender uid>/<uuid>.<jpg|png|webp> and exist in
-- the private bucket.
create function private.support_attachment_ok(p_uid uuid, p_path text)
returns boolean language sql stable security definer set search_path = '' as $$
  select p_path ~ ('^' || p_uid::text
      || '/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\.(jpg|png|webp)$')
    and exists (select 1 from storage.objects o
                where o.bucket_id = 'support-attachments' and o.name = p_path)
$$;

-- Role changes are made out-of-band (SQL console); audit them anyway.
create function private.audit_account_roles() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  if tg_op = 'INSERT' then
    perform private.admin_log(auth.uid(), 'ROLE_GRANTED', 'user',
      new.user_id::text, jsonb_build_object('role', new.role));
    return new;
  elsif tg_op = 'DELETE' then
    perform private.admin_log(auth.uid(), 'ROLE_REVOKED', 'user',
      old.user_id::text, jsonb_build_object('role', old.role));
    return old;
  end if;
  perform private.admin_log(auth.uid(), 'ROLE_CHANGED', 'user',
    new.user_id::text, jsonb_build_object('from', old.role, 'to', new.role));
  return new;
end $$;
create trigger account_roles_audit after insert or update or delete
  on public.account_roles for each row execute function private.audit_account_roles();

-- ---------------------------------------------------------------- user
-- Returns {result: CREATED|CONSENT_REQUIRED|INVALID|RATE_LIMITED, id?}.
create function public.create_support_thread(p_category text, p_subject text,
  p_body text, p_attachment_path text default null, p_consent boolean default false,
  p_related_entity text default null)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  v_subject text := btrim(coalesce(p_subject, ''));
  v_body text := btrim(coalesce(p_body, ''));
  v_att text := nullif(btrim(coalesce(p_attachment_path, '')), '');
  v_rel text := nullif(btrim(coalesce(p_related_entity, '')), '');
  v_id uuid;
begin
  if me is null then raise exception 'not signed in'; end if;
  if p_consent is distinct from true then
    return jsonb_build_object('result', 'CONSENT_REQUIRED');
  end if;
  if p_category is null or p_category not in ('SUGGESTION', 'BUG',
      'SCIENTIFIC_ERROR', 'FEATURE_REQUEST', 'TECH_SUPPORT', 'GENERAL')
     or length(v_subject) not between 1 and 200
     or length(v_body) not between 1 and 4000
     or (v_rel is not null and v_rel !~ '^[A-Za-z0-9_.:/-]{1,160}$')
     or (v_att is not null and not private.support_attachment_ok(me, v_att)) then
    return jsonb_build_object('result', 'INVALID');
  end if;
  if (select count(*) from public.support_threads
      where author_id = me and created_at > now() - interval '1 day') >= 10
     or (select count(*) from public.support_messages
      where sender_id = me and created_at > now() - interval '1 hour') >= 60 then
    return jsonb_build_object('result', 'RATE_LIMITED');
  end if;
  insert into public.support_threads (author_id, category, subject,
    related_entity, consent_at)
  values (me, p_category, v_subject, v_rel, now()) returning id into v_id;
  insert into public.support_messages (thread_id, sender_id, sender_role, body, attachment_path)
  values (v_id, me, 'USER', v_body, v_att);
  return jsonb_build_object('result', 'CREATED', 'id', v_id);
end $$;

-- Author follow-up, or an admin reply (same as admin_reply_support).
-- Returns SENT | NOT_FOUND | CLOSED | INVALID | RATE_LIMITED.
create function public.add_support_message(p_thread_id uuid, p_body text,
  p_attachment_path text default null)
returns text language plpgsql security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  cur public.support_threads;
  v_body text := btrim(coalesce(p_body, ''));
  v_att text := nullif(btrim(coalesce(p_attachment_path, '')), '');
begin
  if me is null then raise exception 'not signed in'; end if;
  select * into cur from public.support_threads where id = p_thread_id for update;
  if cur.id is null then return 'NOT_FOUND'; end if;
  if cur.author_id <> me then
    if not private.has_role(me, 'identity_admin') then return 'NOT_FOUND'; end if;
    if v_att is not null then return 'INVALID'; end if;
    return public.admin_reply_support(p_thread_id, p_body);
  end if;
  if cur.status = 'CLOSED' then return 'CLOSED'; end if;
  if length(v_body) not between 1 and 4000
     or (v_att is not null and not private.support_attachment_ok(me, v_att)) then
    return 'INVALID';
  end if;
  if (select count(*) from public.support_messages
      where sender_id = me and created_at > now() - interval '1 hour') >= 60 then
    return 'RATE_LIMITED';
  end if;
  insert into public.support_messages (thread_id, sender_id, sender_role, body, attachment_path)
  values (p_thread_id, me, 'USER', v_body, v_att);
  -- A follow-up on an answered thread needs the team's attention again.
  update public.support_threads set updated_at = now(), author_last_read_at = now(),
    status = case when status = 'ANSWERED' then 'NEW' else status end
  where id = p_thread_id;
  return 'SENT';
end $$;

create function public.my_support_threads() returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare me uuid := auth.uid();
begin
  if me is null then raise exception 'not signed in'; end if;
  return coalesce((select jsonb_agg(jsonb_build_object(
      'id', t.id, 'category', t.category, 'subject', t.subject,
      'status', t.status, 'related_entity', t.related_entity,
      'created_at', t.created_at, 'updated_at', t.updated_at,
      'last_admin_reply_at', t.last_admin_reply_at,
      'message_count', (select count(*) from public.support_messages m
                         where m.thread_id = t.id),
      'unread', (select count(*) from public.support_messages m
                  where m.thread_id = t.id and m.sender_role = 'ADMIN'
                    and m.created_at > t.author_last_read_at),
      'last_message', (select left(m.body, 140) from public.support_messages m
                        where m.thread_id = t.id order by m.id desc limit 1))
      order by t.updated_at desc)
    from public.support_threads t where t.author_id = me), '[]'::jsonb);
end $$;

-- Author or admin. Admin view adds author_email and is audited.
create function public.support_thread(p_thread_id uuid) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  cur public.support_threads;
  v_admin boolean;
begin
  if me is null then raise exception 'not signed in'; end if;
  select * into cur from public.support_threads where id = p_thread_id;
  if cur.id is null then return null; end if;
  v_admin := cur.author_id <> me;
  if v_admin then
    perform private.admin_guard();
    perform private.admin_log(me, 'SUPPORT_THREAD_VIEW', 'support_thread',
      cur.id::text, '{}'::jsonb);
  end if;
  return jsonb_build_object(
    'id', cur.id, 'category', cur.category, 'subject', cur.subject,
    'status', cur.status, 'related_entity', cur.related_entity,
    'created_at', cur.created_at, 'updated_at', cur.updated_at,
    'last_admin_reply_at', cur.last_admin_reply_at,
    'messages', coalesce((select jsonb_agg(jsonb_build_object(
        'id', m.id, 'sender_role', m.sender_role, 'body', m.body,
        'attachment_path', m.attachment_path, 'created_at', m.created_at,
        'mine', m.sender_id = me) order by m.id)
      from public.support_messages m where m.thread_id = cur.id), '[]'::jsonb))
  || case when v_admin then jsonb_build_object(
    'author_email', (select u.email from auth.users u where u.id = cur.author_id))
  else '{}'::jsonb end;
end $$;

-- Unread admin replies in the caller's own threads.
create function public.support_unread_count() returns int
language plpgsql stable security definer set search_path = '' as $$
declare me uuid := auth.uid();
begin
  if me is null then raise exception 'not signed in'; end if;
  return (select count(*)::int from public.support_messages m
    join public.support_threads t on t.id = m.thread_id
    where t.author_id = me and m.sender_role = 'ADMIN'
      and m.created_at > t.author_last_read_at);
end $$;

-- Author marks own thread read; an admin marks the admin side read.
create function public.mark_support_read(p_thread_id uuid) returns boolean
language plpgsql security definer set search_path = '' as $$
declare me uuid := auth.uid(); cur public.support_threads;
begin
  if me is null then raise exception 'not signed in'; end if;
  select * into cur from public.support_threads where id = p_thread_id;
  if cur.id is null then return false; end if;
  if cur.author_id = me then
    update public.support_threads set author_last_read_at = now() where id = cur.id;
    return true;
  end if;
  perform private.admin_guard();
  update public.support_threads set admin_last_read_at = now() where id = cur.id;
  return true;
end $$;

-- ---------------------------------------------------------------- admin
-- {total, items}. Filters are optional; p_query matches subject or email.
create function public.admin_support_inbox(p_status text default null,
  p_category text default null, p_query text default null,
  p_limit int default 50, p_offset int default 0)
returns jsonb language plpgsql stable security definer set search_path = '' as $$
declare
  q text := nullif(btrim(left(coalesce(p_query, ''), 100)), '');
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
        and (q is null or t.subject ilike '%' || q || '%' or u.email ilike '%' || q || '%'))
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

-- Returns SENT | NOT_FOUND | INVALID.
create function public.admin_reply_support(p_thread_id uuid, p_body text)
returns text language plpgsql security definer set search_path = '' as $$
declare
  me uuid := private.admin_guard();
  cur public.support_threads;
  v_body text := btrim(coalesce(p_body, ''));
begin
  select * into cur from public.support_threads where id = p_thread_id for update;
  if cur.id is null then return 'NOT_FOUND'; end if;
  if length(v_body) not between 1 and 4000 then return 'INVALID'; end if;
  insert into public.support_messages (thread_id, sender_id, sender_role, body)
  values (p_thread_id, me, 'ADMIN', v_body);
  update public.support_threads set status = 'ANSWERED', updated_at = now(),
    last_admin_reply_at = now(), admin_last_read_at = now()
  where id = p_thread_id;
  perform private.admin_log(me, 'SUPPORT_REPLY', 'support_thread', p_thread_id::text,
    jsonb_build_object('from', cur.status, 'to', 'ANSWERED', 'length', length(v_body)));
  return 'SENT';
end $$;

-- Returns the new status | NOT_FOUND | INVALID_STATUS.
create function public.admin_set_support_status(p_thread_id uuid, p_status text)
returns text language plpgsql security definer set search_path = '' as $$
declare me uuid := private.admin_guard(); cur public.support_threads;
begin
  if p_status is null or p_status not in ('NEW', 'IN_REVIEW', 'ANSWERED', 'CLOSED') then
    return 'INVALID_STATUS';
  end if;
  select * into cur from public.support_threads where id = p_thread_id for update;
  if cur.id is null then return 'NOT_FOUND'; end if;
  update public.support_threads set status = p_status, updated_at = now()
  where id = p_thread_id;
  perform private.admin_log(me, 'SUPPORT_STATUS', 'support_thread', p_thread_id::text,
    jsonb_build_object('from', cur.status, 'to', p_status));
  return p_status;
end $$;

-- Aggregated counts only. Definitions are returned in 'definitions'.
create function public.admin_stats() returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare
  today timestamptz := date_trunc('day', now());
  v_users bigint;
  v_pro bigint;
begin
  perform private.admin_guard();
  v_users := (select count(*) from auth.users);
  v_pro := (select count(*) from public.access_grants g
            where g.expires_at is null or g.expires_at > now());
  return jsonb_build_object(
    'generated_at', now(),
    'users', jsonb_build_object(
      'total', v_users,
      'new_today', (select count(*) from auth.users where created_at >= today),
      'new_7d', (select count(*) from auth.users where created_at > now() - interval '7 days'),
      'new_30d', (select count(*) from auth.users where created_at > now() - interval '30 days'),
      'confirmed', (select count(*) from auth.users where email_confirmed_at is not null)),
    'modes', jsonb_build_object(
      'students', null, 'experts', null, 'stored_server_side', false,
      'professional_profiles', (select count(*) from public.professional_profiles),
      'verified_professionals', (select count(*) from public.verification
                                  where status = 'VERIFIED_PROFESSIONAL')),
    'tiers', jsonb_build_object(
      'pro', v_pro, 'free', greatest(v_users - v_pro, 0),
      'student_pro', (select count(*) from public.access_grants g where g.tier = 'studentPro'
                       and (g.expires_at is null or g.expires_at > now())),
      'professional_pro', (select count(*) from public.access_grants g where g.tier = 'professionalPro'
                            and (g.expires_at is null or g.expires_at > now()))),
    'active', jsonb_build_object(
      'd7', (select count(distinct x.uid) from (
          select user_id as uid from public.user_devices where last_seen > now() - interval '7 days'
          union select user_id from public.ai_usage where created_at > now() - interval '7 days'
          union select id from auth.users where last_sign_in_at > now() - interval '7 days') x),
      'd30', (select count(distinct x.uid) from (
          select user_id as uid from public.user_devices where last_seen > now() - interval '30 days'
          union select user_id from public.ai_usage where created_at > now() - interval '30 days'
          union select id from auth.users where last_sign_in_at > now() - interval '30 days') x)),
    'support', jsonb_build_object(
      'new', (select count(*) from public.support_threads where status = 'NEW'),
      'in_review', (select count(*) from public.support_threads where status = 'IN_REVIEW'),
      'answered', (select count(*) from public.support_threads where status = 'ANSWERED'),
      'closed', (select count(*) from public.support_threads where status = 'CLOSED'),
      'awaiting', (select count(*) from public.support_threads where status in ('NEW', 'IN_REVIEW')),
      'by_category', coalesce((select jsonb_object_agg(c.category, c.n) from (
          select category, count(*) as n from public.support_threads group by 1) c), '{}'::jsonb)),
    'publications', jsonb_build_object(
      'awaiting_moderation', (select count(*) from public.publications
          where status in ('SUBMITTED', 'SCREENING', 'IN_REVIEW', 'APPROVED')),
      'open_reports', (select count(*) from public.publication_reports where status = 'OPEN')),
    'ai', jsonb_build_object(
      'total', (select count(*) from public.ai_usage),
      'd7', (select count(*) from public.ai_usage where created_at > now() - interval '7 days')),
    'daily', coalesce((select jsonb_agg(jsonb_build_object('day', d.day,
        'signups', d.signups, 'ai', d.ai) order by d.day) from (
        select to_char(g.day, 'YYYY-MM-DD') as day,
          (select count(*) from auth.users u where u.created_at >= g.day
             and u.created_at < g.day + interval '1 day') as signups,
          (select count(*) from public.ai_usage a where a.created_at >= g.day
             and a.created_at < g.day + interval '1 day') as ai
        from generate_series(today - interval '13 days', today, interval '1 day') g(day)) d),
      '[]'::jsonb),
    'definitions', jsonb_build_object(
      'active', 'distinct users with a device check-in (user_devices.last_seen), an AI request (ai_usage) or a sign-in (auth.users.last_sign_in_at) inside the window',
      'pro', 'active server access_grants only; store purchases are verified on the device and are not counted here',
      'modes', 'student/professional usage mode is a device setting and is not stored server-side'));
end $$;

-- Users list (search by email / display name; filters: role admin|moderator,
-- tier free|pro|studentPro|professionalPro). Never returns secrets.
create function public.admin_users(p_search text default null,
  p_role text default null, p_tier text default null,
  p_limit int default 50, p_offset int default 0)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  me uuid := private.admin_guard();
  q text := nullif(btrim(left(coalesce(p_search, ''), 100)), '');
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
    where (q is null or b.email ilike '%' || q || '%' or b.display_name ilike '%' || q || '%')
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
    'search', q is not null, 'role', p_role, 'tier', p_tier, 'offset', v_offset));
  return v_result;
end $$;

create function public.admin_audit_log(p_limit int default 100) returns jsonb
language plpgsql stable security definer set search_path = '' as $$
begin
  perform private.admin_guard();
  return coalesce((select jsonb_agg(jsonb_build_object(
      'id', a.id, 'action', a.action, 'target_type', a.target_type,
      'target_id', a.target_id, 'detail', a.detail, 'created_at', a.created_at,
      'actor_email', (select u.email from auth.users u where u.id = a.actor_id))
      order by a.id desc)
    from (select * from private.admin_audit order by id desc
          limit least(greatest(coalesce(p_limit, 100), 1), 500)) a), '[]'::jsonb);
end $$;

-- ------------------------------------------- existing admin RPCs: guard + audit
create or replace function public.admin_dashboard() returns jsonb
language plpgsql stable security definer set search_path = '' as $$
begin
  perform private.admin_guard();
  return jsonb_build_object(
    'generated_at', now(),
    'totals', jsonb_build_object(
      'users', (select count(*) from auth.users),
      'confirmed', (select count(*) from auth.users where email_confirmed_at is not null),
      'signups_7d', (select count(*) from auth.users where created_at > now() - interval '7 days'),
      'signups_30d', (select count(*) from auth.users where created_at > now() - interval '30 days'),
      'active_7d', (select count(*) from auth.users where last_sign_in_at > now() - interval '7 days'),
      'android', (select count(distinct user_id) from public.user_devices where platform = 'android'),
      'ios', (select count(distinct user_id) from public.user_devices where platform = 'ios'),
      'ai_requests', (select count(*) from public.ai_usage),
      'ai_requests_7d', (select count(*) from public.ai_usage where created_at > now() - interval '7 days'),
      'referrals', (select count(*) from public.referrals where status = 'VALID'),
      'pro_grants', (select count(*) from public.access_grants
                      where expires_at is null or expires_at > now())),
    'regions', coalesce((select jsonb_agg(x order by x.users desc, x.region) from (
        select coalesce(d.region, '??') as region, count(distinct d.user_id) as users
          from public.user_devices d group by 1 limit 50) x), '[]'::jsonb),
    'daily', coalesce((select jsonb_agg(x order by x.day) from (
        select to_char(date_trunc('day', created_at), 'YYYY-MM-DD') as day, count(*) as signups
          from auth.users where created_at > now() - interval '30 days' group by 1) x), '[]'::jsonb),
    'users', coalesce((select jsonb_agg(x order by x.created_at desc) from (
        select u.email, u.created_at, u.last_sign_in_at,
               (u.email_confirmed_at is not null) as confirmed,
               (select string_agg(d.platform, ',' order by d.platform)
                  from public.user_devices d where d.user_id = u.id) as platforms,
               (select d.region from public.user_devices d where d.user_id = u.id
                  order by d.last_seen desc limit 1) as region,
               (select g.tier from public.access_grants g where g.user_id = u.id
                  and (g.expires_at is null or g.expires_at > now())) as tier,
               private.has_role(u.id, 'identity_admin') as is_admin
          from auth.users u order by u.created_at desc limit 500) x), '[]'::jsonb)
  );
end $$;

create or replace function public.admin_set_access(p_email text, p_tier text)
returns text language plpgsql security definer set search_path = '' as $$
declare me uuid := private.admin_guard(); target uuid; v_result text;
begin
  select id into target from auth.users where lower(email) = lower(trim(p_email));
  if target is null then
    v_result := 'NOT_FOUND';
  elsif p_tier is null then
    delete from public.access_grants where user_id = target;
    v_result := 'REVOKED';
  elsif p_tier not in ('studentPro', 'professionalPro') then
    v_result := 'INVALID_TIER';
  else
    insert into public.access_grants (user_id, tier, granted_by, note)
    values (target, p_tier, me, 'admin panel')
    on conflict (user_id) do update
      set tier = excluded.tier, granted_by = me, granted_at = now(), expires_at = null;
    v_result := 'GRANTED';
  end if;
  perform private.admin_log(me, 'ACCESS_SET', 'user', target::text,
    jsonb_build_object('tier', p_tier, 'result', v_result));
  return v_result;
end $$;

-- ---------------------------------------------------------------- storage
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('support-attachments', 'support-attachments', false, 5242880,
        array['image/jpeg', 'image/png', 'image/webp'])
on conflict (id) do update set public = false, file_size_limit = 5242880,
  allowed_mime_types = array['image/jpeg', 'image/png', 'image/webp'];

create policy support_owner_upload on storage.objects
  for insert to authenticated
  with check (bucket_id = 'support-attachments'
    and (storage.foldername(name))[1] = auth.uid()::text);
create policy support_owner_or_admin_read on storage.objects
  for select to authenticated
  using (bucket_id = 'support-attachments'
    and ((storage.foldername(name))[1] = auth.uid()::text
         or private.has_role(auth.uid(), 'identity_admin')));
-- No update/delete policies for clients: attachments are removed with the
-- account (delete-account Edge Function, service role).

-- ---------------------------------------------------------------- grants
revoke execute on function private.admin_guard() from public, anon, authenticated;
revoke execute on function private.admin_log(uuid, text, text, text, jsonb) from public, anon, authenticated;
revoke execute on function private.support_attachment_ok(uuid, text) from public, anon, authenticated;
revoke execute on function private.audit_account_roles() from public, anon, authenticated;
revoke execute on function public.create_support_thread(text, text, text, text, boolean, text) from public, anon, authenticated;
revoke execute on function public.add_support_message(uuid, text, text) from public, anon, authenticated;
revoke execute on function public.my_support_threads() from public, anon, authenticated;
revoke execute on function public.support_thread(uuid) from public, anon, authenticated;
revoke execute on function public.support_unread_count() from public, anon, authenticated;
revoke execute on function public.mark_support_read(uuid) from public, anon, authenticated;
revoke execute on function public.admin_support_inbox(text, text, text, int, int) from public, anon, authenticated;
revoke execute on function public.admin_reply_support(uuid, text) from public, anon, authenticated;
revoke execute on function public.admin_set_support_status(uuid, text) from public, anon, authenticated;
revoke execute on function public.admin_stats() from public, anon, authenticated;
revoke execute on function public.admin_users(text, text, text, int, int) from public, anon, authenticated;
revoke execute on function public.admin_audit_log(int) from public, anon, authenticated;
revoke execute on function public.admin_dashboard() from public, anon, authenticated;
revoke execute on function public.admin_set_access(text, text) from public, anon, authenticated;
grant execute on function public.create_support_thread(text, text, text, text, boolean, text) to authenticated;
grant execute on function public.add_support_message(uuid, text, text) to authenticated;
grant execute on function public.my_support_threads() to authenticated;
grant execute on function public.support_thread(uuid) to authenticated;
grant execute on function public.support_unread_count() to authenticated;
grant execute on function public.mark_support_read(uuid) to authenticated;
grant execute on function public.admin_support_inbox(text, text, text, int, int) to authenticated;
grant execute on function public.admin_reply_support(uuid, text) to authenticated;
grant execute on function public.admin_set_support_status(uuid, text) to authenticated;
grant execute on function public.admin_stats() to authenticated;
grant execute on function public.admin_users(text, text, text, int, int) to authenticated;
grant execute on function public.admin_audit_log(int) to authenticated;
grant execute on function public.admin_dashboard() to authenticated;
grant execute on function public.admin_set_access(text, text) to authenticated;
