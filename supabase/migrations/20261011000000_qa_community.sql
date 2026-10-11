-- FORENSIC EXPERT — «Savol-javob (Hamjamiyat)»: forensic experts asking and
-- answering each other inside the app.
--
-- Shape (owner's brief, 2026-10-11):
--   * Anyone signed in may ASK. Only a verified expert may ANSWER or VOTE.
--     The asker marks the best answer. An admin can pin or remove.
--   * Expert status comes from an automatic document check that runs in an
--     Edge Function: the document is read in memory only. NOTHING of the file
--     is stored here — this schema keeps user id, role, country, status, a
--     short reason and the date. No name, no diploma number, no file, no URL.
--   * Case data must never be posted. private.qa_privacy_flags() looks for
--     case/examination numbers, long digit runs, passport patterns, dates and
--     «Surname I.O.» initials; a post that trips it is created in
--     'moderation' and is not shown in the feed until an admin releases it.
--   * Three DISTINCT reporters hide a post, or suspend a badge, until an
--     admin decides.
--   * Machine translation is cached per (post, language) by the Edge Function
--     through a service_role-only entry point; the app only reads it.
--
-- Security model: every table has RLS on and NO policy, and no DML privilege
-- is granted to anon/authenticated — reads and writes both go through the
-- SECURITY DEFINER functions below (the same pattern as support_threads).
-- The client is never trusted: role, limits and ownership are checked here.
--
-- ROLLBACK (manual, owner-approved):
--   drop function if exists public.qa_feed(text, text, int, int);
--   drop function if exists public.qa_question(uuid);
--   drop function if exists public.qa_ask(text, text, text, text[]);
--   drop function if exists public.qa_answer(uuid, text, text);
--   drop function if exists public.qa_vote(uuid, int);
--   drop function if exists public.qa_accept(uuid, uuid);
--   drop function if exists public.qa_report(text, text, text);
--   drop function if exists public.qa_my();
--   drop function if exists public.qa_status();
--   drop function if exists public.qa_admin_queue(int, int);
--   drop function if exists public.qa_moderate(text, text, text, text);
--   drop function if exists public.qa_translation(text, uuid, text);
--   drop function if exists private.qa_set_expert_status(uuid, text, text, text, text, boolean);
--   drop function if exists private.qa_translation_put(text, uuid, text, text, text, text);
--   drop function if exists private.qa_verify_attempt(uuid);
--   drop function if exists private.qa_privacy_flags(text);
--   drop function if exists private.qa_bump(uuid, text, int);
--   drop function if exists private.qa_is_expert(uuid);
--   drop table if exists public.qa_translations, public.qa_reports, public.qa_votes,
--     public.qa_answers, public.qa_questions, public.qa_rate, public.qa_profiles;

-- --------------------------------------------------------------- tables

-- Expert status for the Q&A section. Deliberately separate from the manual
-- `verification` flow: that one is an admin decision on stored documents,
-- this one is an automatic check that stores nothing of the document.
create table public.qa_profiles (
  user_id uuid primary key references auth.users (id) on delete cascade,
  role text not null check (role in
    ('forensic_physician', 'forensic_chemist', 'lab_technician', 'student', 'other')),
  country_code text not null check (country_code ~ '^[A-Z]{2}$'),
  status text not null default 'unverified'
    check (status in ('unverified', 'verified', 'rejected', 'suspended')),
  -- Short machine reason ('document_ok', 'not_a_credential', 'unreadable',
  -- 'reported'). Never free text from the document itself.
  reason text check (reason is null or char_length(reason) <= 64),
  manual boolean not null default false,
  decided_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
alter table public.qa_profiles enable row level security;

-- Daily counters: kind = 'ask' | 'answer' | 'vote' | 'report' | 'verify'.
create table public.qa_rate (
  user_id uuid not null references auth.users (id) on delete cascade,
  day date not null,
  kind text not null,
  n int not null default 0,
  primary key (user_id, day, kind)
);
alter table public.qa_rate enable row level security;

create table public.qa_questions (
  id uuid primary key default gen_random_uuid(),
  author_id uuid not null references auth.users (id) on delete cascade,
  lang text not null check (lang in ('uz', 'ru', 'en')),
  title text not null check (char_length(title) between 10 and 160),
  body text not null check (char_length(body) between 20 and 4000),
  tags text[] not null default '{}',
  status text not null default 'published'
    check (status in ('published', 'moderation', 'removed')),
  flags text[] not null default '{}',
  pinned boolean not null default false,
  accepted_answer_id uuid,
  answer_count int not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
alter table public.qa_questions enable row level security;
create index qa_questions_feed on public.qa_questions (status, pinned desc, created_at desc);
create index qa_questions_tags on public.qa_questions using gin (tags);
create index qa_questions_author on public.qa_questions (author_id);

create table public.qa_answers (
  id uuid primary key default gen_random_uuid(),
  question_id uuid not null references public.qa_questions (id) on delete cascade,
  author_id uuid not null references auth.users (id) on delete cascade,
  lang text not null check (lang in ('uz', 'ru', 'en')),
  body text not null check (char_length(body) between 20 and 6000),
  status text not null default 'published'
    check (status in ('published', 'moderation', 'removed')),
  flags text[] not null default '{}',
  score int not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
alter table public.qa_answers enable row level security;
create index qa_answers_question on public.qa_answers (question_id, status, score desc, created_at);
create index qa_answers_author on public.qa_answers (author_id);

alter table public.qa_questions
  add constraint qa_questions_accepted_fk
  foreign key (accepted_answer_id) references public.qa_answers (id) on delete set null;

create table public.qa_votes (
  answer_id uuid not null references public.qa_answers (id) on delete cascade,
  voter_id uuid not null references auth.users (id) on delete cascade,
  value smallint not null check (value in (-1, 1)),
  created_at timestamptz not null default now(),
  primary key (answer_id, voter_id)
);
alter table public.qa_votes enable row level security;

create table public.qa_reports (
  id uuid primary key default gen_random_uuid(),
  target_type text not null check (target_type in ('question', 'answer', 'user')),
  target_id text not null,
  reporter_id uuid not null references auth.users (id) on delete cascade,
  reason text not null check (char_length(reason) between 3 and 300),
  created_at timestamptz not null default now(),
  unique (target_type, target_id, reporter_id)
);
alter table public.qa_reports enable row level security;
create index qa_reports_target on public.qa_reports (target_type, target_id);

-- Machine translation cache, one row per (post, language).
create table public.qa_translations (
  target_type text not null check (target_type in ('question', 'answer')),
  target_id uuid not null,
  lang text not null check (lang in ('uz', 'ru', 'en')),
  title text,
  body text not null,
  engine text not null,
  created_at timestamptz not null default now(),
  primary key (target_type, target_id, lang)
);
alter table public.qa_translations enable row level security;

-- --------------------------------------------------------------- helpers

-- The tags a question may carry. Kept server-side so the client cannot invent
-- topics; the app shows the localized label for each key.
create function private.qa_tags() returns text[]
language sql immutable set search_path = '' as $$
  select array['toxicology', 'alcohol', 'drugs', 'dna', 'histology',
               'thanatology', 'methods', 'regulations', 'biology',
               'criminalistics', 'documentation']::text[]
$$;

create function private.qa_is_expert(p_user uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (select 1 from public.qa_profiles p
                 where p.user_id = p_user and p.status = 'verified')
$$;

-- Daily limit. Raises when the caller is over it.
create function private.qa_bump(p_user uuid, p_kind text, p_limit int) returns void
language plpgsql security definer set search_path = '' as $$
declare v_n int;
begin
  insert into public.qa_rate (user_id, day, kind, n)
  values (p_user, current_date, p_kind, 1)
  on conflict (user_id, day, kind) do update set n = public.qa_rate.n + 1
  returning n into v_n;
  if v_n > p_limit then
    raise exception 'rate limit';
  end if;
end $$;

-- Case material must never be posted. Returns the rule names that matched;
-- an empty array means the text looked clean. Conservative on purpose: a
-- false positive only sends the post to moderation, a false negative could
-- publish case data.
create function private.qa_privacy_flags(p_text text) returns text[]
language plpgsql immutable set search_path = '' as $$
declare t text := coalesce(p_text, ''); f text[] := '{}';
begin
  -- «ish raqami 123-45», «дело № 12/345», «case no. 7788»
  -- Word boundaries matter: without them «ishonchli» and «propanol» trip the
  -- rule and an ordinary methodology question lands in moderation.
  if t ~* '(\mish\M|\mishi\M|\mdel[oa]\M|\mдел[оа]\M|\mcase\M|уголовн|ekspertiza|экспертиз|заключени)[^.\n]{0,24}(№|#|\mno\.|\mraqam)' then
    f := array_append(f, 'case_number');
  end if;
  -- any number group that looks like a file/registration number
  if t ~ '(№|#)\s?\d{2,}' or t ~ '\m\d{2,}[-/]\d{2,}\M' then
    f := array_append(f, 'reference_number');
  end if;
  -- phone / passport / personal id runs
  if t ~ '\m\d{7,}\M' or t ~ '\m[A-Z]{2}\s?\d{7}\M' or t ~ '\+\d{9,}' then
    f := array_append(f, 'identifier');
  end if;
  -- a date: on its own it is weak, but with a place or a number it is enough
  if t ~ '\m\d{1,2}[./-]\d{1,2}[./-]\d{2,4}\M' then
    f := array_append(f, 'date');
  end if;
  -- «Familiya I.O.» / «Фамилия И.О.»
  if t ~ '\m[A-ZА-ЯЁЎҚҒҲ][a-zа-яёўқғҳ''’]{2,}\s+[A-ZА-ЯЁЎҚҒҲ]\.\s?[A-ZА-ЯЁЎҚҒҲ]\.' then
    f := array_append(f, 'person_name');
  end if;
  if t ~* '\m(f\.?i\.?sh|фио|ism[- ]sharif|familiya[si]*\s*:|ф\.и\.о)' then
    f := array_append(f, 'person_name');
  end if;
  return (select coalesce(array_agg(distinct x), '{}') from unnest(f) x);
end $$;

create function private.qa_profile_json(p_user uuid) returns jsonb
language sql stable security definer set search_path = '' as $$
  select coalesce((select jsonb_build_object(
      'role', p.role, 'country_code', p.country_code, 'status', p.status,
      'reason', p.reason, 'manual', p.manual, 'decided_at', p.decided_at)
    from public.qa_profiles p where p.user_id = p_user),
    jsonb_build_object('status', 'unverified'))
$$;

-- --------------------------------------------------- expert status (server)

-- Called by the Edge Function with the service role AFTER the document was
-- read in memory. The document itself never reaches this function: only the
-- verdict, a short machine reason and the declared role/country.
create function private.qa_set_expert_status(
  p_user uuid, p_role text, p_country text, p_status text, p_reason text,
  p_manual boolean default false) returns jsonb
language plpgsql security definer set search_path = '' as $$
begin
  if p_status not in ('unverified', 'verified', 'rejected', 'suspended') then
    raise exception 'bad status';
  end if;
  insert into public.qa_profiles (user_id, role, country_code, status, reason,
                                  manual, decided_at, updated_at)
  values (p_user, p_role, upper(p_country), p_status, left(p_reason, 64),
          p_manual, now(), now())
  on conflict (user_id) do update set
    role = excluded.role, country_code = excluded.country_code,
    status = excluded.status, reason = excluded.reason,
    manual = public.qa_profiles.manual or excluded.manual,
    decided_at = now(), updated_at = now();
  perform private.admin_log(null, 'QA_STATUS_SET', 'qa_profile', p_user::text,
    jsonb_build_object('status', p_status, 'reason', left(p_reason, 64),
                       'manual', p_manual));
  return private.qa_profile_json(p_user);
end $$;

-- One attempt counter for the document check (3 per day, owner's rule).
create function private.qa_verify_attempt(p_user uuid) returns int
language plpgsql security definer set search_path = '' as $$
declare v_n int;
begin
  insert into public.qa_rate (user_id, day, kind, n)
  values (p_user, current_date, 'verify', 1)
  on conflict (user_id, day, kind) do update set n = public.qa_rate.n + 1
  returning n into v_n;
  if v_n > 3 then
    raise exception 'rate limit';
  end if;
  return v_n;
end $$;

create function private.qa_translation_put(
  p_target_type text, p_target_id uuid, p_lang text, p_title text,
  p_body text, p_engine text) returns void
language sql security definer set search_path = '' as $$
  insert into public.qa_translations (target_type, target_id, lang, title, body, engine)
  values (p_target_type, p_target_id, p_lang, p_title, p_body, p_engine)
  on conflict (target_type, target_id, lang) do update set
    title = excluded.title, body = excluded.body, engine = excluded.engine,
    created_at = now()
$$;

-- --------------------------------------------------------------- reading

create function public.qa_status() returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare me uuid := auth.uid();
begin
  if me is null then raise exception 'forbidden'; end if;
  return jsonb_build_object(
    'profile', private.qa_profile_json(me),
    'tags', to_jsonb(private.qa_tags()),
    'attempts_today', coalesce((select r.n from public.qa_rate r
      where r.user_id = me and r.day = current_date and r.kind = 'verify'), 0),
    'can_answer', private.qa_is_expert(me));
end $$;

create function public.qa_feed(p_tag text default null, p_query text default null,
  p_limit int default 20, p_offset int default 0) returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  v_limit int := least(greatest(coalesce(p_limit, 20), 1), 50);
  v_offset int := greatest(coalesce(p_offset, 0), 0);
  v_q text := nullif(btrim(coalesce(p_query, '')), '');
begin
  if me is null then raise exception 'forbidden'; end if;
  return jsonb_build_object(
    'total', (select count(*) from public.qa_questions q
              where q.status = 'published'
                and (p_tag is null or p_tag = any (q.tags))
                and (v_q is null or q.title ilike '%' || v_q || '%'
                     or q.body ilike '%' || v_q || '%')),
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
              and (p_tag is null or p_tag = any (q.tags))
              and (v_q is null or q.title ilike '%' || v_q || '%'
                   or q.body ilike '%' || v_q || '%')
            order by q.pinned desc, q.created_at desc
            limit v_limit offset v_offset) x), '[]'::jsonb));
end $$;

create function public.qa_question(p_id uuid) returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare me uuid := auth.uid(); q public.qa_questions;
begin
  if me is null then raise exception 'forbidden'; end if;
  select * into q from public.qa_questions where id = p_id;
  if q.id is null or (q.status <> 'published' and q.author_id <> me) then
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
        and (a.status = 'published' or a.author_id = me)), '[]'::jsonb));
end $$;

create function public.qa_my() returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare me uuid := auth.uid();
begin
  if me is null then raise exception 'forbidden'; end if;
  return jsonb_build_object(
    'profile', private.qa_profile_json(me),
    'questions', coalesce((select jsonb_agg(jsonb_build_object(
        'id', q.id, 'title', q.title, 'status', q.status,
        'answer_count', q.answer_count, 'created_at', q.created_at)
        order by q.created_at desc)
      from public.qa_questions q where q.author_id = me), '[]'::jsonb),
    'answers', coalesce((select jsonb_agg(jsonb_build_object(
        'id', a.id, 'question_id', a.question_id, 'status', a.status,
        'score', a.score, 'created_at', a.created_at)
        order by a.created_at desc)
      from public.qa_answers a where a.author_id = me), '[]'::jsonb));
end $$;

create function public.qa_translation(p_target_type text, p_target_id uuid, p_lang text)
returns jsonb language plpgsql stable security definer set search_path = '' as $$
declare me uuid := auth.uid(); v public.qa_translations;
begin
  if me is null then raise exception 'forbidden'; end if;
  select * into v from public.qa_translations t
  where t.target_type = p_target_type and t.target_id = p_target_id and t.lang = p_lang;
  if v.target_id is null then return null; end if;
  return jsonb_build_object('title', v.title, 'body', v.body,
                            'engine', v.engine, 'created_at', v.created_at);
end $$;

-- --------------------------------------------------------------- writing

create function public.qa_ask(p_lang text, p_title text, p_body text,
  p_tags text[] default '{}') returns jsonb
language plpgsql security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  v_tags text[];
  v_flags text[];
  v_status text;
  v_id uuid;
begin
  if me is null then raise exception 'forbidden'; end if;
  if p_lang not in ('uz', 'ru', 'en') then raise exception 'bad language'; end if;
  perform private.qa_bump(me, 'ask', 5);
  v_tags := (select coalesce(array_agg(distinct t), '{}')
             from unnest(coalesce(p_tags, '{}')) t
             where t = any (private.qa_tags()));
  if array_length(v_tags, 1) > 5 then raise exception 'too many tags'; end if;
  v_flags := private.qa_privacy_flags(coalesce(p_title, '') || ' ' || coalesce(p_body, ''));
  v_status := case when array_length(v_flags, 1) > 0 then 'moderation' else 'published' end;
  insert into public.qa_questions (author_id, lang, title, body, tags, status, flags)
  values (me, p_lang, btrim(p_title), btrim(p_body), v_tags, v_status, v_flags)
  returning id into v_id;
  return jsonb_build_object('id', v_id, 'status', v_status, 'flags', to_jsonb(v_flags));
end $$;

create function public.qa_answer(p_question_id uuid, p_lang text, p_body text)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  v_flags text[];
  v_status text;
  v_id uuid;
begin
  if me is null then raise exception 'forbidden'; end if;
  if not private.qa_is_expert(me) then raise exception 'expert only'; end if;
  if p_lang not in ('uz', 'ru', 'en') then raise exception 'bad language'; end if;
  if not exists (select 1 from public.qa_questions q
                 where q.id = p_question_id and q.status = 'published') then
    raise exception 'not found';
  end if;
  perform private.qa_bump(me, 'answer', 20);
  v_flags := private.qa_privacy_flags(p_body);
  v_status := case when array_length(v_flags, 1) > 0 then 'moderation' else 'published' end;
  insert into public.qa_answers (question_id, author_id, lang, body, status, flags)
  values (p_question_id, me, p_lang, btrim(p_body), v_status, v_flags)
  returning id into v_id;
  if v_status = 'published' then
    update public.qa_questions set answer_count = answer_count + 1, updated_at = now()
    where id = p_question_id;
  end if;
  return jsonb_build_object('id', v_id, 'status', v_status, 'flags', to_jsonb(v_flags));
end $$;

create function public.qa_vote(p_answer_id uuid, p_value int)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare me uuid := auth.uid(); v_author uuid; v_score int;
begin
  if me is null then raise exception 'forbidden'; end if;
  if not private.qa_is_expert(me) then raise exception 'expert only'; end if;
  if p_value not in (-1, 0, 1) then raise exception 'bad vote'; end if;
  select a.author_id into v_author from public.qa_answers a
  where a.id = p_answer_id and a.status = 'published';
  if v_author is null then raise exception 'not found'; end if;
  if v_author = me then raise exception 'own answer'; end if;
  perform private.qa_bump(me, 'vote', 100);
  if p_value = 0 then
    delete from public.qa_votes where answer_id = p_answer_id and voter_id = me;
  else
    insert into public.qa_votes (answer_id, voter_id, value)
    values (p_answer_id, me, p_value::smallint)
    on conflict (answer_id, voter_id) do update set value = excluded.value, created_at = now();
  end if;
  update public.qa_answers a
  set score = coalesce((select sum(v.value) from public.qa_votes v where v.answer_id = a.id), 0),
      updated_at = now()
  where a.id = p_answer_id
  returning a.score into v_score;
  return jsonb_build_object('score', v_score, 'my_vote', p_value);
end $$;

create function public.qa_accept(p_question_id uuid, p_answer_id uuid)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare me uuid := auth.uid();
begin
  if me is null then raise exception 'forbidden'; end if;
  if not exists (select 1 from public.qa_questions q
                 where q.id = p_question_id and q.author_id = me) then
    raise exception 'forbidden';
  end if;
  if p_answer_id is not null and not exists (
      select 1 from public.qa_answers a
      where a.id = p_answer_id and a.question_id = p_question_id and a.status = 'published') then
    raise exception 'not found';
  end if;
  update public.qa_questions set accepted_answer_id = p_answer_id, updated_at = now()
  where id = p_question_id;
  return jsonb_build_object('accepted_answer_id', p_answer_id);
end $$;

-- Three DISTINCT reporters hide a post, or suspend a badge, until an admin
-- decides. A reporter can only report the same target once (unique index).
create function public.qa_report(p_target_type text, p_target_id text, p_reason text)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare me uuid := auth.uid(); v_count int; v_acted boolean := false;
begin
  if me is null then raise exception 'forbidden'; end if;
  if p_target_type not in ('question', 'answer', 'user') then raise exception 'bad target'; end if;
  perform private.qa_bump(me, 'report', 10);
  insert into public.qa_reports (target_type, target_id, reporter_id, reason)
  values (p_target_type, p_target_id, me, btrim(p_reason))
  on conflict (target_type, target_id, reporter_id) do nothing;
  select count(distinct r.reporter_id) into v_count from public.qa_reports r
  where r.target_type = p_target_type and r.target_id = p_target_id;
  if v_count >= 3 then
    if p_target_type = 'question' then
      update public.qa_questions set status = 'moderation', updated_at = now()
      where id = p_target_id::uuid and status = 'published';
      v_acted := found;
    elsif p_target_type = 'answer' then
      update public.qa_answers set status = 'moderation', updated_at = now()
      where id = p_target_id::uuid and status = 'published';
      v_acted := found;
    else
      update public.qa_profiles set status = 'suspended', reason = 'reported', updated_at = now()
      where user_id = p_target_id::uuid and status = 'verified';
      v_acted := found;
    end if;
    if v_acted then
      perform private.admin_log(null, 'QA_AUTO_HIDDEN', p_target_type, p_target_id,
        jsonb_build_object('reporters', v_count));
    end if;
  end if;
  return jsonb_build_object('reports', v_count, 'hidden', v_acted);
end $$;

-- --------------------------------------------------------------- admin

create function public.qa_admin_queue(p_limit int default 50, p_offset int default 0)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare me uuid := private.admin_guard();
  v_limit int := least(greatest(coalesce(p_limit, 50), 1), 100);
  v_offset int := greatest(coalesce(p_offset, 0), 0);
  v_result jsonb;
begin
  select jsonb_build_object(
    'questions', coalesce((select jsonb_agg(jsonb_build_object(
        'id', q.id, 'title', q.title, 'body', q.body, 'lang', q.lang,
        'status', q.status, 'flags', to_jsonb(q.flags),
        'reports', (select count(distinct r.reporter_id) from public.qa_reports r
                    where r.target_type = 'question' and r.target_id = q.id::text),
        'created_at', q.created_at) order by q.created_at)
      from public.qa_questions q where q.status = 'moderation'
      limit v_limit offset v_offset), '[]'::jsonb),
    'answers', coalesce((select jsonb_agg(jsonb_build_object(
        'id', a.id, 'question_id', a.question_id, 'body', a.body, 'lang', a.lang,
        'status', a.status, 'flags', to_jsonb(a.flags),
        'reports', (select count(distinct r.reporter_id) from public.qa_reports r
                    where r.target_type = 'answer' and r.target_id = a.id::text),
        'created_at', a.created_at) order by a.created_at)
      from public.qa_answers a where a.status = 'moderation'
      limit v_limit offset v_offset), '[]'::jsonb),
    'suspended', coalesce((select jsonb_agg(jsonb_build_object(
        'user_id', p.user_id, 'role', p.role, 'country_code', p.country_code,
        'reason', p.reason, 'decided_at', p.decided_at) order by p.updated_at)
      from public.qa_profiles p where p.status = 'suspended'
      limit v_limit offset v_offset), '[]'::jsonb))
  into v_result;
  perform private.admin_log(me, 'QA_QUEUE_VIEW', 'qa', null, '{}'::jsonb);
  return v_result;
end $$;

-- action: publish | remove | pin | unpin | reinstate | suspend
create function public.qa_moderate(p_action text, p_target_type text,
  p_target_id text, p_reason text default null)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare me uuid := private.admin_guard();
begin
  if p_target_type not in ('question', 'answer', 'user') then raise exception 'bad target'; end if;
  if p_action in ('publish', 'remove') then
    if p_target_type = 'question' then
      update public.qa_questions
      set status = case p_action when 'publish' then 'published' else 'removed' end,
          updated_at = now()
      where id = p_target_id::uuid;
    elsif p_target_type = 'answer' then
      update public.qa_answers
      set status = case p_action when 'publish' then 'published' else 'removed' end,
          updated_at = now()
      where id = p_target_id::uuid;
      update public.qa_questions q
      set answer_count = (select count(*) from public.qa_answers a
                          where a.question_id = q.id and a.status = 'published'),
          accepted_answer_id = case
            when q.accepted_answer_id = p_target_id::uuid and p_action = 'remove'
            then null else q.accepted_answer_id end
      where q.id = (select a.question_id from public.qa_answers a where a.id = p_target_id::uuid);
    else
      raise exception 'bad action for user';
    end if;
  elsif p_action in ('pin', 'unpin') then
    if p_target_type <> 'question' then raise exception 'bad action'; end if;
    update public.qa_questions set pinned = (p_action = 'pin'), updated_at = now()
    where id = p_target_id::uuid;
  elsif p_action in ('reinstate', 'suspend') then
    if p_target_type <> 'user' then raise exception 'bad action'; end if;
    update public.qa_profiles
    set status = case p_action when 'reinstate' then 'verified' else 'suspended' end,
        reason = left(coalesce(p_reason, p_action), 64), updated_at = now(), decided_at = now()
    where user_id = p_target_id::uuid;
    if p_action = 'reinstate' then
      delete from public.qa_reports where target_type = 'user' and target_id = p_target_id;
    end if;
  else
    raise exception 'bad action';
  end if;
  perform private.admin_log(me, 'QA_MODERATE', p_target_type, p_target_id,
    jsonb_build_object('action', p_action, 'reason', left(coalesce(p_reason, ''), 200)));
  return jsonb_build_object('ok', true);
end $$;

-- --------------------------------------------------------------- privileges

revoke all on public.qa_profiles, public.qa_rate, public.qa_questions,
  public.qa_answers, public.qa_votes, public.qa_reports, public.qa_translations
  from anon, authenticated;

revoke execute on function private.qa_tags() from public, anon, authenticated;
revoke execute on function private.qa_is_expert(uuid) from public, anon, authenticated;
revoke execute on function private.qa_bump(uuid, text, int) from public, anon, authenticated;
revoke execute on function private.qa_privacy_flags(text) from public, anon, authenticated;
revoke execute on function private.qa_profile_json(uuid) from public, anon, authenticated;
revoke execute on function private.qa_set_expert_status(uuid, text, text, text, text, boolean)
  from public, anon, authenticated;
revoke execute on function private.qa_verify_attempt(uuid) from public, anon, authenticated;
revoke execute on function private.qa_translation_put(text, uuid, text, text, text, text)
  from public, anon, authenticated;

-- The Edge Function runs as service_role and needs exactly three entry
-- points: write the verdict, count a document check, fill the translation
-- cache. Nothing else in `private` is granted to it here.
grant usage on schema private to service_role;
grant execute on function private.qa_set_expert_status(uuid, text, text, text, text, boolean),
  private.qa_verify_attempt(uuid),
  private.qa_translation_put(text, uuid, text, text, text, text)
  to service_role;

revoke execute on function public.qa_status() from public, anon;
revoke execute on function public.qa_feed(text, text, int, int) from public, anon;
revoke execute on function public.qa_question(uuid) from public, anon;
revoke execute on function public.qa_my() from public, anon;
revoke execute on function public.qa_translation(text, uuid, text) from public, anon;
revoke execute on function public.qa_ask(text, text, text, text[]) from public, anon;
revoke execute on function public.qa_answer(uuid, text, text) from public, anon;
revoke execute on function public.qa_vote(uuid, int) from public, anon;
revoke execute on function public.qa_accept(uuid, uuid) from public, anon;
revoke execute on function public.qa_report(text, text, text) from public, anon;
revoke execute on function public.qa_admin_queue(int, int) from public, anon;
revoke execute on function public.qa_moderate(text, text, text, text) from public, anon;

grant execute on function public.qa_status(), public.qa_my(),
  public.qa_feed(text, text, int, int), public.qa_question(uuid),
  public.qa_translation(text, uuid, text),
  public.qa_ask(text, text, text, text[]), public.qa_answer(uuid, text, text),
  public.qa_vote(uuid, int), public.qa_accept(uuid, uuid),
  public.qa_report(text, text, text),
  public.qa_admin_queue(int, int), public.qa_moderate(text, text, text, text)
  to authenticated;
