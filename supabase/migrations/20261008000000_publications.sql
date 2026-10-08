-- FORENSIC EXPERT — Expert Publications («Ekspert maqolalari»).
--
-- Security model (enforced HERE; the Flutter client is never trusted):
--   * Four tables, RLS on, NO policies and NO table privileges for anon /
--     authenticated. Every read/write goes through SECURITY DEFINER RPCs that
--     check auth.uid().
--   * Workflow (server-checked, private.publication_transition_ok):
--       DRAFT -> SUBMITTED                      (author, submit_publication)
--       SUBMITTED -> SCREENING -> IN_REVIEW     (moderator)
--       IN_REVIEW -> APPROVED | REJECTED        (moderator)
--       APPROVED -> PUBLISHED                   (moderator)
--       PUBLISHED -> RETRACTED | SUPERSEDED     (moderator)
--       REJECTED -> DRAFT                       (author edits a rejected text)
--     No state can be skipped. Every status change (including creation) is
--     written to publication_events.
--   * Moderators: identity_admin or the new role publication_moderator
--     (account_roles, granted by the owner out-of-band). A moderator can
--     never moderate their own publication, so an author cannot publish their
--     own article.
--   * submit_publication requires all three confirmations (rights, consent to
--     publish, no personal data) and a title, abstract and discipline.
--   * Paid subscription / access grants are NOT consulted anywhere here:
--     approval depends only on moderation.
--   * Submission (and even publication) never means scientific verification;
--     the app shows that notice on every publication.
--   * list_published() is public (anon too): PUBLISHED rows only, safe columns
--     only — no author_id, no email.
--
-- ROLLBACK (manual, owner-approved; destroys all publication data):
--   drop function if exists public.save_draft(uuid, jsonb);
--   drop function if exists public.submit_publication(uuid);
--   drop function if exists public.my_publications();
--   drop function if exists public.list_published(text, text, int);
--   drop function if exists public.report_publication(uuid, text, text);
--   drop function if exists public.can_moderate_publications();
--   drop function if exists public.moderation_queue();
--   drop function if exists public.moderate_publication(uuid, text, text);
--   drop function if exists private.publication_can_moderate(uuid);
--   drop function if exists private.publication_transition_ok(text, text);
--   drop function if exists private.publication_log(uuid, uuid, text, text, text);
--   drop function if exists private.publication_json(public.publications, boolean);
--   drop table if exists public.publication_reports, public.publication_events,
--     public.publication_reviews, public.publications;
--   delete from public.account_roles where role = 'publication_moderator';
--   -- The enum value 'publication_moderator' cannot be dropped from
--   -- public.account_role without recreating the type; it is harmless to keep.

alter type public.account_role add value if not exists 'publication_moderator';

-- ---------------------------------------------------------------- tables
create table public.publications (
  id uuid primary key default gen_random_uuid(),
  author_id uuid not null references auth.users (id) on delete cascade,
  status text not null default 'DRAFT' check (status in ('DRAFT', 'SUBMITTED',
    'SCREENING', 'IN_REVIEW', 'APPROVED', 'REJECTED', 'PUBLISHED', 'RETRACTED',
    'SUPERSEDED')),
  title text not null default '' check (length(title) <= 300),
  abstract text not null default '' check (length(abstract) <= 5000),
  keywords text[] not null default '{}' check (cardinality(keywords) <= 20),
  language text not null default 'uz' check (language in ('uz', 'ru', 'en')),
  discipline_code text check (discipline_code ~ '^[a-z_]{2,60}$'),
  coauthors jsonb not null default '[]'::jsonb
    check (jsonb_typeof(coauthors) = 'array' and jsonb_array_length(coauthors) <= 30),
  affiliation text check (length(affiliation) <= 300),
  doi text check (length(doi) <= 200 and doi ~* '^10\.[0-9]{4,9}/\S+$'),
  reference_list text check (length(reference_list) <= 20000),
  external_url text check (length(external_url) <= 500 and external_url ~* '^https://\S{3,}$'),
  rights_confirmed boolean not null default false,
  publication_consent boolean not null default false,
  no_personal_data_confirmed boolean not null default false,
  version int not null default 1 check (version >= 1),
  supersedes uuid references public.publications (id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  published_at timestamptz
);
create index publications_author on public.publications (author_id, updated_at desc);
create index publications_status on public.publications (status, published_at desc);

create table public.publication_reviews (
  id uuid primary key default gen_random_uuid(),
  publication_id uuid not null references public.publications (id) on delete cascade,
  reviewer_id uuid references auth.users (id) on delete set null,
  decision text not null check (decision in ('SCREENING', 'IN_REVIEW',
    'APPROVED', 'REJECTED', 'PUBLISHED', 'RETRACTED', 'SUPERSEDED')),
  comment text check (length(comment) <= 4000),
  created_at timestamptz not null default now()
);
create index publication_reviews_pub on public.publication_reviews (publication_id, created_at);

create table public.publication_events (
  id bigint generated always as identity primary key,
  publication_id uuid not null references public.publications (id) on delete cascade,
  actor_id uuid references auth.users (id) on delete set null,
  from_status text,
  to_status text not null,
  note text check (length(note) <= 4000),
  created_at timestamptz not null default now()
);
create index publication_events_pub on public.publication_events (publication_id, id);

create table public.publication_reports (
  id uuid primary key default gen_random_uuid(),
  publication_id uuid not null references public.publications (id) on delete cascade,
  reporter_id uuid not null references auth.users (id) on delete cascade,
  reason text not null check (reason in ('PLAGIARISM', 'PERSONAL_DATA',
    'COPYRIGHT', 'MISINFORMATION', 'ABUSE', 'OTHER')),
  details text check (length(details) <= 2000),
  status text not null default 'OPEN' check (status in ('OPEN', 'CLOSED')),
  created_at timestamptz not null default now(),
  unique (publication_id, reporter_id)
);

alter table public.publications enable row level security;
alter table public.publication_reviews enable row level security;
alter table public.publication_events enable row level security;
alter table public.publication_reports enable row level security;
revoke all on public.publications, public.publication_reviews,
  public.publication_events, public.publication_reports from anon, authenticated;

-- ---------------------------------------------------------------- private
-- plpgsql (not sql): the new enum value is only resolved at call time, after
-- this migration has committed.
create function private.publication_can_moderate(uid uuid) returns boolean
language plpgsql stable security definer set search_path = '' as $$
begin
  return uid is not null and (private.has_role(uid, 'identity_admin')
    or private.has_role(uid, 'publication_moderator'));
end $$;

create function private.publication_transition_ok(p_from text, p_to text)
returns boolean language sql immutable set search_path = '' as $$
  select (p_from, p_to) in (
    ('DRAFT', 'SUBMITTED'),
    ('SUBMITTED', 'SCREENING'),
    ('SCREENING', 'IN_REVIEW'),
    ('IN_REVIEW', 'APPROVED'),
    ('IN_REVIEW', 'REJECTED'),
    ('APPROVED', 'PUBLISHED'),
    ('PUBLISHED', 'RETRACTED'),
    ('PUBLISHED', 'SUPERSEDED'),
    ('REJECTED', 'DRAFT'))
$$;

create function private.publication_log(p_pub uuid, p_actor uuid,
  p_from text, p_to text, p_note text) returns void
language sql security definer set search_path = '' as $$
  insert into public.publication_events (publication_id, actor_id, from_status, to_status, note)
  values (p_pub, p_actor, p_from, p_to, left(p_note, 4000))
$$;

-- Row -> JSON. p_full adds author-/moderator-only fields (status, timeline,
-- moderator comments, confirmations). author_id/email are never included.
create function private.publication_json(p public.publications, p_full boolean)
returns jsonb language sql stable security definer set search_path = '' as $$
  select jsonb_build_object(
    'id', p.id, 'status', p.status, 'title', p.title, 'abstract', p.abstract,
    'keywords', to_jsonb(p.keywords), 'language', p.language,
    'discipline_code', p.discipline_code, 'coauthors', p.coauthors,
    'affiliation', p.affiliation, 'doi', p.doi,
    'reference_list', p.reference_list, 'external_url', p.external_url,
    'version', p.version, 'supersedes', p.supersedes,
    'published_at', p.published_at)
  || case when p_full then jsonb_build_object(
    'rights_confirmed', p.rights_confirmed,
    'publication_consent', p.publication_consent,
    'no_personal_data_confirmed', p.no_personal_data_confirmed,
    'created_at', p.created_at, 'updated_at', p.updated_at,
    'events', coalesce((select jsonb_agg(jsonb_build_object(
        'from', e.from_status, 'to', e.to_status, 'note', e.note,
        'at', e.created_at) order by e.id)
      from public.publication_events e where e.publication_id = p.id), '[]'::jsonb),
    'reviews', coalesce((select jsonb_agg(jsonb_build_object(
        'decision', r.decision, 'comment', r.comment, 'at', r.created_at)
        order by r.created_at)
      from public.publication_reviews r where r.publication_id = p.id), '[]'::jsonb))
  else '{}'::jsonb end
$$;

-- ---------------------------------------------------------------- author
-- Create (p_id null) or edit own DRAFT/REJECTED publication. Editing a
-- REJECTED one moves it back to DRAFT (logged). p_data keys: title,
-- abstract, keywords[], language, discipline_code, coauthors[], affiliation,
-- doi, reference_list, external_url, rights_confirmed, publication_consent,
-- no_personal_data_confirmed; on create also supersedes (own PUBLISHED id).
create function public.save_draft(p_id uuid, p_data jsonb)
returns uuid language plpgsql security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  cur public.publications;
  v_id uuid := p_id;
  v_kw text[];
  v_sup public.publications;
  d jsonb := coalesce(p_data, '{}'::jsonb);
begin
  if me is null then raise exception 'not signed in'; end if;
  v_kw := coalesce(array(select left(btrim(x), 60)
    from jsonb_array_elements_text(case when jsonb_typeof(d->'keywords') = 'array'
      then d->'keywords' else '[]'::jsonb end) x
    where btrim(x) <> '' limit 20), '{}');
  if v_id is null then
    if (select count(*) from public.publications where author_id = me
        and created_at > now() - interval '1 day') >= 20 then
      raise exception 'rate limited';
    end if;
    if d ? 'supersedes' and nullif(d->>'supersedes', '') is not null then
      select * into v_sup from public.publications
        where id = (d->>'supersedes')::uuid and author_id = me and status = 'PUBLISHED';
      if v_sup.id is null then raise exception 'invalid supersedes'; end if;
    end if;
    insert into public.publications (author_id, supersedes, version)
    values (me, v_sup.id, coalesce(v_sup.version + 1, 1)) returning id into v_id;
    perform private.publication_log(v_id, me, null, 'DRAFT', null);
  else
    select * into cur from public.publications where id = v_id for update;
    if cur.id is null or cur.author_id <> me then raise exception 'not found'; end if;
    if cur.status not in ('DRAFT', 'REJECTED') then raise exception 'not editable'; end if;
    if cur.status = 'REJECTED' then
      update public.publications set status = 'DRAFT' where id = v_id;
      perform private.publication_log(v_id, me, 'REJECTED', 'DRAFT', 'revised by author');
    end if;
  end if;
  update public.publications set
    title = left(btrim(coalesce(d->>'title', '')), 300),
    abstract = left(btrim(coalesce(d->>'abstract', '')), 5000),
    keywords = v_kw,
    language = case when d->>'language' in ('uz', 'ru', 'en') then d->>'language' else 'uz' end,
    discipline_code = case when d->>'discipline_code' ~ '^[a-z_]{2,60}$'
      then d->>'discipline_code' end,
    coauthors = case when jsonb_typeof(d->'coauthors') = 'array'
      and jsonb_array_length(d->'coauthors') <= 30 then d->'coauthors' else '[]'::jsonb end,
    affiliation = left(nullif(btrim(d->>'affiliation'), ''), 300),
    doi = case when btrim(d->>'doi') ~* '^10\.[0-9]{4,9}/\S+$' and length(d->>'doi') <= 200 then btrim(d->>'doi') end,
    reference_list = left(nullif(btrim(d->>'reference_list'), ''), 20000),
    external_url = case when btrim(d->>'external_url') ~* '^https://\S{3,}$'
      and length(d->>'external_url') <= 500 then btrim(d->>'external_url') end,
    rights_confirmed = coalesce((d->>'rights_confirmed')::boolean, false),
    publication_consent = coalesce((d->>'publication_consent')::boolean, false),
    no_personal_data_confirmed = coalesce((d->>'no_personal_data_confirmed')::boolean, false),
    updated_at = now()
  where id = v_id;
  return v_id;
end $$;

-- DRAFT -> SUBMITTED. Returns SUBMITTED | NOT_FOUND | INVALID_STATE |
-- CONFIRMATIONS_REQUIRED | INCOMPLETE.
create function public.submit_publication(p_id uuid)
returns text language plpgsql security definer set search_path = '' as $$
declare me uuid := auth.uid(); cur public.publications;
begin
  if me is null then raise exception 'not signed in'; end if;
  select * into cur from public.publications where id = p_id for update;
  if cur.id is null or cur.author_id <> me then return 'NOT_FOUND'; end if;
  if not private.publication_transition_ok(cur.status, 'SUBMITTED') then
    return 'INVALID_STATE';
  end if;
  if not (cur.rights_confirmed and cur.publication_consent
          and cur.no_personal_data_confirmed) then
    return 'CONFIRMATIONS_REQUIRED';
  end if;
  if cur.title = '' or cur.abstract = '' or cur.discipline_code is null then
    return 'INCOMPLETE';
  end if;
  update public.publications set status = 'SUBMITTED', updated_at = now() where id = p_id;
  perform private.publication_log(p_id, me, cur.status, 'SUBMITTED', null);
  return 'SUBMITTED';
end $$;

create function public.my_publications() returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare me uuid := auth.uid();
begin
  if me is null then raise exception 'not signed in'; end if;
  return coalesce((select jsonb_agg(private.publication_json(p, true) order by p.updated_at desc)
    from public.publications p where p.author_id = me), '[]'::jsonb);
end $$;

-- ---------------------------------------------------------------- public
create function public.list_published(p_query text default null,
  p_discipline text default null, p_limit int default 50)
returns jsonb language plpgsql stable security definer set search_path = '' as $$
declare q text := nullif(btrim(left(coalesce(p_query, ''), 100)), '');
begin
  return coalesce((select jsonb_agg(private.publication_json(p, false)
      order by p.published_at desc nulls last)
    from (select * from public.publications p
      where p.status = 'PUBLISHED'
        and (p_discipline is null or p.discipline_code = p_discipline)
        and (q is null or p.title ilike '%' || q || '%' or p.abstract ilike '%' || q || '%'
             or exists (select 1 from unnest(p.keywords) k where k ilike '%' || q || '%'))
      order by p.published_at desc nulls last
      limit least(greatest(coalesce(p_limit, 50), 1), 200)) p), '[]'::jsonb);
end $$;

-- Any signed-in user may report a PUBLISHED publication (once).
-- Returns REPORTED | ALREADY_REPORTED | NOT_FOUND | INVALID_REASON.
create function public.report_publication(p_id uuid, p_reason text, p_details text)
returns text language plpgsql security definer set search_path = '' as $$
declare me uuid := auth.uid();
begin
  if me is null then raise exception 'not signed in'; end if;
  if p_reason is null or p_reason not in ('PLAGIARISM', 'PERSONAL_DATA', 'COPYRIGHT',
      'MISINFORMATION', 'ABUSE', 'OTHER') then
    return 'INVALID_REASON';
  end if;
  if not exists (select 1 from public.publications where id = p_id and status = 'PUBLISHED') then
    return 'NOT_FOUND';
  end if;
  insert into public.publication_reports (publication_id, reporter_id, reason, details)
  values (p_id, me, p_reason, left(nullif(btrim(p_details), ''), 2000))
  on conflict (publication_id, reporter_id) do nothing;
  return case when found then 'REPORTED' else 'ALREADY_REPORTED' end;
end $$;

-- ---------------------------------------------------------------- moderation
create function public.can_moderate_publications() returns boolean
language plpgsql stable security definer set search_path = '' as $$
begin
  return private.publication_can_moderate(auth.uid());
end $$;

-- Open work + reported publications. Author identity is not included
-- (moderators judge the text; self-moderation is blocked server-side).
create function public.moderation_queue() returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare me uuid := auth.uid();
begin
  if not private.publication_can_moderate(me) then raise exception 'forbidden'; end if;
  return jsonb_build_object(
    'items', coalesce((select jsonb_agg(private.publication_json(p, true)
        || jsonb_build_object('own', p.author_id = me) order by p.updated_at)
      from public.publications p
      where p.status in ('SUBMITTED', 'SCREENING', 'IN_REVIEW', 'APPROVED')), '[]'::jsonb),
    'reports', coalesce((select jsonb_agg(jsonb_build_object(
        'publication_id', r.publication_id, 'title', p.title, 'status', p.status,
        'reason', r.reason, 'details', r.details, 'at', r.created_at)
        order by r.created_at desc)
      from public.publication_reports r join public.publications p on p.id = r.publication_id
      where r.status = 'OPEN'), '[]'::jsonb));
end $$;

-- Moderator transition. Returns the new status or FORBIDDEN_OWN |
-- NOT_FOUND | INVALID_TRANSITION | COMMENT_REQUIRED.
create function public.moderate_publication(p_id uuid, p_to text, p_comment text)
returns text language plpgsql security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  cur public.publications;
  v_comment text := left(nullif(btrim(p_comment), ''), 4000);
begin
  if not private.publication_can_moderate(me) then raise exception 'forbidden'; end if;
  select * into cur from public.publications where id = p_id for update;
  if cur.id is null then return 'NOT_FOUND'; end if;
  if cur.author_id = me then return 'FORBIDDEN_OWN'; end if;
  -- REJECTED -> DRAFT is the author's path (save_draft), never a moderator's.
  if p_to = 'DRAFT' or not private.publication_transition_ok(cur.status, p_to) then
    return 'INVALID_TRANSITION';
  end if;
  if p_to in ('REJECTED', 'RETRACTED') and v_comment is null then
    return 'COMMENT_REQUIRED';
  end if;
  update public.publications set status = p_to, updated_at = now(),
    published_at = case when p_to = 'PUBLISHED' then now() else published_at end
  where id = p_id;
  insert into public.publication_reviews (publication_id, reviewer_id, decision, comment)
  values (p_id, me, p_to, v_comment);
  perform private.publication_log(p_id, me, cur.status, p_to, v_comment);
  if p_to in ('RETRACTED', 'SUPERSEDED') then
    update public.publication_reports set status = 'CLOSED'
      where publication_id = p_id and status = 'OPEN';
  end if;
  -- A newer version going live supersedes the version it replaces.
  if p_to = 'PUBLISHED' and cur.supersedes is not null then
    update public.publications set status = 'SUPERSEDED', updated_at = now()
      where id = cur.supersedes and status = 'PUBLISHED';
    if found then
      perform private.publication_log(cur.supersedes, me, 'PUBLISHED', 'SUPERSEDED',
        'superseded by ' || p_id::text);
    end if;
  end if;
  return p_to;
end $$;

-- ---------------------------------------------------------------- grants
revoke execute on function private.publication_can_moderate(uuid) from public, anon, authenticated;
revoke execute on function private.publication_transition_ok(text, text) from public, anon, authenticated;
revoke execute on function private.publication_log(uuid, uuid, text, text, text) from public, anon, authenticated;
revoke execute on function private.publication_json(public.publications, boolean) from public, anon, authenticated;
revoke execute on function public.save_draft(uuid, jsonb) from public, anon, authenticated;
revoke execute on function public.submit_publication(uuid) from public, anon, authenticated;
revoke execute on function public.my_publications() from public, anon, authenticated;
revoke execute on function public.list_published(text, text, int) from public, anon, authenticated;
revoke execute on function public.report_publication(uuid, text, text) from public, anon, authenticated;
revoke execute on function public.can_moderate_publications() from public, anon, authenticated;
revoke execute on function public.moderation_queue() from public, anon, authenticated;
revoke execute on function public.moderate_publication(uuid, text, text) from public, anon, authenticated;
grant execute on function public.save_draft(uuid, jsonb) to authenticated;
grant execute on function public.submit_publication(uuid) to authenticated;
grant execute on function public.my_publications() to authenticated;
grant execute on function public.list_published(text, text, int) to anon, authenticated;
grant execute on function public.report_publication(uuid, text, text) to authenticated;
grant execute on function public.can_moderate_publications() to authenticated;
grant execute on function public.moderation_queue() to authenticated;
grant execute on function public.moderate_publication(uuid, text, text) to authenticated;
