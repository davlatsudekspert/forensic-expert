-- FORENSIC EXPERT — «Sinfda test» (Kahoot uslubidagi jonli sinf testi).
--
-- Oqim (egasi topshirig'i, 2026-10-17):
--   * USTOZ (account_roles.role = 'teacher', yoki identity_admin) mavzu tanlaydi,
--     savollar soni / talaba chegarasi / har savolga vaqtni belgilaydi → 6 xonali
--     KOD va QR chiqadi.
--   * TALABA (kirgan hisob) kod yoki QR bilan LAQAB yozib qo'shiladi. Server
--     tomonida user_id bilan bog'lanadi, lekin ustozga FAQAT laqab ko'rinadi
--     (ism / email hech qaysi javobda yo'q).
--   * Ustoz «Boshlash» va «Keyingi savol» bosadi; vaqt tugashi SERVER vaqti bilan
--     aniqlanadi (question_started_at + seconds); talaba faqat bir marta javob
--     beradi; to'g'ri javob (correct_index) savol vaqti tugamaguncha KLIENTGA
--     HECH QACHON berilmaydi.
--   * Tugagach 30 kundan keyin sessiya va uning javoblari avtomatik o'chiriladi.
--
-- Xavfsizlik modeli (support_threads / qa_* bilan bir xil):
--   * Hamma jadvalda RLS yoqilgan, anon/authenticated'ga jadval huquqi YO'Q —
--     o'qish ham, yozish ham faqat SECURITY DEFINER (search_path = '') RPC orqali.
--   * Himoya qatlami uchun, agar kimdir jadval huquqini tasodifan qaytarsa ham,
--     RLS siyosatlari faqat O'Z qatorlarini ko'rsatadi (ustoz — o'z sessiyalari,
--     talaba — o'z ishtirokchi/javob qatori). class_session_questions va
--     class_quiz_questions uchun siyosat YO'Q (to'g'ri javob hech qachon ochilmaydi).
--   * Ustoz roli faqat server tomonida: account_roles ('teacher'), egasi SQL
--     konsolda beradi (audit trigger'i ROLE_GRANTED yozadi). Email mosligi huquq
--     bermaydi. Admin ≠ ilmiy reviewer; bu rol faqat sinf testini boshqaradi.
--   * Kod taxmin qilishdan himoya: join urinishlari foydalanuvchi va IP bo'yicha
--     soatiga 30 ta (class_join_attempts). Kutilgan xatolar (noto'g'ri kod, to'lgan
--     sinf, ...) EXCEPTION emas, jsonb {ok:false,error:...} qaytaradi — shunda
--     urinish hisoblagichi rollback bo'lib ketmaydi.
--   * Huquq xatolari SQLSTATE 42501 (PostgREST: HTTP 403) bilan ko'tariladi.
--
-- Realtime: ilova 2 s polling ishlatadi (RPC class_teacher_dashboard /
-- class_session_state). Sabab: ilova SDK'siz REST mijoz, RLS jadvallarni yopiq
-- ushlaydi (postgres_changes hodisalari yetib bormaydi), polling oddiy va
-- ishonchli. Qarang: docs/CLASS_QUIZ.md §Realtime.
--
-- Savol banki: class_quiz_questions (mijozga huquq yo'q). Import formati va
-- tools/slides mcq bilan moslik — docs/CLASS_QUIZ.md. Bank bo'sh bo'lsa ustoz
-- «savollar yo'q» holatini ko'radi (hech narsa to'qilmaydi).
--
-- 30 kunlik tozalash: private.class_cleanup() — pg_cron orqali kuniga bir marta
-- (jadvalga qo'yish BU FAYLDA BAJARILMAYDI; qadam docs/CLASS_QUIZ.md da). Zaxira
-- sifatida class_create_session ham uni chaqiradi.
--
-- ROLLBACK (qo'lda, egasi ruxsati bilan): supabase/rollback/20261017010000_class_quiz_down.sql

alter type public.account_role add value if not exists 'teacher';

-- ---------------------------------------------------------------- tables

-- Savol banki. Format: {question, options[4], correct_index, explanation,
-- source{author,title,page}} (tools/slides mcq bilan bir xil).
create table public.class_quiz_questions (
  id uuid primary key default gen_random_uuid(),
  topic_id text not null check (char_length(topic_id) between 1 and 80),
  topic_title text not null default '' check (char_length(topic_title) <= 200),
  position int not null default 0,
  question text not null check (char_length(question) between 5 and 600),
  options jsonb not null check (jsonb_typeof(options) = 'array'
    and jsonb_array_length(options) = 4),
  correct_index smallint not null check (correct_index between 0 and 3),
  explanation text not null default '' check (char_length(explanation) <= 1200),
  source jsonb not null check (jsonb_typeof(source) = 'object'
    and source ? 'author' and source ? 'title' and source ? 'page'),
  is_demo boolean not null default false,
  created_at timestamptz not null default now()
);
alter table public.class_quiz_questions enable row level security;
create index class_quiz_questions_topic on public.class_quiz_questions (topic_id);

create table public.class_sessions (
  id uuid primary key default gen_random_uuid(),
  teacher_id uuid not null references auth.users (id) on delete cascade,
  code text not null unique check (code ~ '^[0-9]{6}$'),
  topic_id text not null,
  topic_title text not null default '',
  status text not null default 'lobby'
    check (status in ('lobby', 'running', 'finished')),
  -- {question_count, student_limit, seconds}
  settings jsonb not null,
  current_index int not null default -1,
  question_started_at timestamptz,
  created_at timestamptz not null default now(),
  started_at timestamptz,
  finished_at timestamptz,
  -- Tugagach 30 kun (private.class_cleanup o'chiradi).
  expires_at timestamptz
);
alter table public.class_sessions enable row level security;
create index class_sessions_teacher on public.class_sessions (teacher_id, created_at desc);
create index class_sessions_expiry on public.class_sessions (expires_at)
  where expires_at is not null;

-- Savollar sessiyaga NUSXALANADI (bank keyin o'zgarsa ham o'tayotgan test
-- o'zgarmaydi). Variantlar nusxalashda serverda aralashtiriladi; option id =
-- 'o' || indeks.
create table public.class_session_questions (
  session_id uuid not null references public.class_sessions (id) on delete cascade,
  idx int not null check (idx >= 0),
  question text not null,
  options jsonb not null,
  correct_index smallint not null check (correct_index between 0 and 3),
  explanation text not null default '',
  source jsonb not null default '{}'::jsonb,
  primary key (session_id, idx)
);
alter table public.class_session_questions enable row level security;

create table public.class_participants (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references public.class_sessions (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  nickname text not null check (char_length(nickname) between 2 and 20),
  joined_at timestamptz not null default now(),
  kicked_at timestamptz,
  unique (session_id, user_id)
);
alter table public.class_participants enable row level security;
create unique index class_participants_nick
  on public.class_participants (session_id, lower(nickname));

create table public.class_answers (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references public.class_sessions (id) on delete cascade,
  participant_id uuid not null references public.class_participants (id) on delete cascade,
  question_index int not null check (question_index >= 0),
  option_id text not null check (option_id ~ '^o[0-3]$'),
  answered_at timestamptz not null default now(),
  elapsed_ms int not null check (elapsed_ms >= 0),
  -- Faqat server hisoblaydi. Mijoz hech qachon yozmaydi.
  is_correct boolean not null,
  points int not null check (points >= 0),
  unique (participant_id, question_index)
);
alter table public.class_answers enable row level security;
create index class_answers_session on public.class_answers (session_id, question_index);

-- Laqab shikoyatlari (UGC, App Store 1.2): bitta ishtirokchiga bitta reporter bir marta.
create table public.class_reports (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references public.class_sessions (id) on delete cascade,
  participant_id uuid not null references public.class_participants (id) on delete cascade,
  reporter_id uuid not null references auth.users (id) on delete cascade,
  reason text not null check (char_length(reason) between 3 and 200),
  created_at timestamptz not null default now(),
  unique (participant_id, reporter_id)
);
alter table public.class_reports enable row level security;

-- Kod taxmin qilish hisoblagichi: kalit 'u:<user id>' yoki 'i:<md5(ip)>'.
create table public.class_join_attempts (
  key text not null,
  hour timestamptz not null,
  n int not null default 0,
  primary key (key, hour)
);
alter table public.class_join_attempts enable row level security;

-- Defense in depth: jadval huquqi berilmasa ham, berilib ketsa ham faqat o'zi.
create policy class_sessions_teacher_read on public.class_sessions
  for select using (teacher_id = auth.uid());
create policy class_participants_self_read on public.class_participants
  for select using (user_id = auth.uid());
create policy class_answers_self_read on public.class_answers
  for select using (exists (select 1 from public.class_participants p
    where p.id = participant_id and p.user_id = auth.uid()));

-- --------------------------------------------------------------- helpers

create function private.class_is_teacher(p_user uuid) returns boolean
language plpgsql stable security definer set search_path = '' as $$
begin
  if p_user is null then return false; end if;
  return private.has_role(p_user, 'teacher')
      or private.has_role(p_user, 'identity_admin');
end $$;

-- Vaqt (millisekund) — server soati.
create function private.class_elapsed_ms(p_started timestamptz) returns int
language sql volatile set search_path = '' as $$
  select case when p_started is null then 0
    else least(greatest((extract(epoch from (clock_timestamp() - p_started)) * 1000)::bigint, 0),
               2147483647)::int end
$$;

-- Ball: to'g'ri bo'lsa 500 + tezlik bonusi (0..500), noto'g'ri bo'lsa 0.
-- Mijoz formulasi bilan bir xil (ClassScoring.points).
create function private.class_points(p_correct boolean, p_elapsed_ms int, p_limit_ms int)
returns int language sql immutable set search_path = '' as $$
  select case when not p_correct or p_limit_ms <= 0 then 0
    else 500 + (500 * greatest(p_limit_ms - least(greatest(p_elapsed_ms, 0), p_limit_ms), 0)) / p_limit_ms
  end
$$;

-- Laqab tekshiruvi: 'ok' | 'length' | 'chars' | 'blocked'.
-- Ro'yxat sodda va qasddan qisqa; ustoz o'chirishi va shikoyat qo'shimcha qatlam.
-- (Dart nusxasi: ClassNickname — bir xil qoida, test bilan sinxron.)
create function private.class_nick_norm(p text) returns text
language sql immutable set search_path = '' as $$
  select regexp_replace(translate(lower(coalesce(p, '')), '01345@$', 'oieasas'),
                        '[^[:alpha:]]', '', 'g')
$$;

create function private.class_nick_check(p text) returns text
language plpgsql immutable set search_path = '' as $$
declare
  t text := btrim(coalesce(p, ''));
  norm text;
  stems text[] := array['fuck', 'shit', 'bitch', 'cunt', 'nigger', 'nigga', 'whore',
    'slut', 'pussy', 'asshole', 'blyat', 'blyad', 'pidor', 'pidar', 'mudak', 'pizd',
    'ebat', 'ebal', 'gandon', 'jalab', 'qanjiq', 'onangni', 'sikaman', 'сука',
    'блядь', 'бляд', 'пизд', 'хуй', 'еба', 'мудак', 'пидор', 'гандон'];
  exact text[] := array['sik', 'huy', 'xuy', 'hui', 'suka', 'sex'];
  s text;
  w text;
begin
  if char_length(t) < 2 or char_length(t) > 20 then return 'length'; end if;
  if t ~ '[[:cntrl:]<>{}\[\]\\|^~;"`]' then return 'chars'; end if;
  if t !~ '[^[:space:]_.''’-]' then return 'chars'; end if;
  norm := private.class_nick_norm(t);
  foreach s in array stems loop
    if position(s in norm) > 0 then return 'blocked'; end if;
  end loop;
  foreach w in array regexp_split_to_array(lower(t), '[^[:alpha:]0-9@$]+') loop
    if private.class_nick_norm(w) = any (exact) then return 'blocked'; end if;
  end loop;
  return 'ok';
end $$;

-- Takror laqab: oxiriga 2, 3, ... qo'shiladi (20 belgidan oshmaydi).
create function private.class_unique_nick(p_session uuid, p_nick text) returns text
language plpgsql security definer set search_path = '' as $$
declare
  base text := regexp_replace(btrim(p_nick), '\s+', ' ', 'g');
  cand text := base;
  n int := 1;
begin
  while exists (select 1 from public.class_participants x
                where x.session_id = p_session and lower(x.nickname) = lower(cand)) loop
    n := n + 1;
    cand := left(base, 20 - char_length(n::text)) || n::text;
  end loop;
  return cand;
end $$;

-- Urinishni sanaydi; ruxsat bo'lsa true. Kalitlar: foydalanuvchi va (bor bo'lsa) IP.
create function private.class_join_bump(p_user uuid) returns boolean
language plpgsql security definer set search_path = '' as $$
declare
  hr timestamptz := date_trunc('hour', clock_timestamp());
  hdr jsonb;
  ip text;
  k text;
  v int;
  ok boolean := true;
begin
  begin
    hdr := nullif(current_setting('request.headers', true), '')::jsonb;
  exception when others then hdr := null;
  end;
  ip := nullif(btrim(split_part(coalesce(hdr ->> 'x-forwarded-for', ''), ',', 1)), '');
  foreach k in array array['u:' || p_user::text,
                           case when ip is null then null else 'i:' || md5(ip) end] loop
    continue when k is null;
    insert into public.class_join_attempts as a (key, hour, n) values (k, hr, 1)
    on conflict (key, hour) do update set n = a.n + 1
    returning n into v;
    if v > 30 then ok := false; end if;
  end loop;
  return ok;
end $$;

-- Sessiya ustoziga tegishli ekanini va ustoz rolini tekshiradi; qatorni qulflaydi.
create function private.class_owned(p_session uuid, p_lock boolean default false)
returns public.class_sessions
language plpgsql security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  s public.class_sessions;
begin
  if me is null or not private.class_is_teacher(me) then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  if p_lock then
    select * into s from public.class_sessions where id = p_session for update;
  else
    select * into s from public.class_sessions where id = p_session;
  end if;
  if not found or s.teacher_id <> me then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  return s;
end $$;

-- Hozirgi savol fazasi: lobby | open | closed | finished.
create function private.class_phase(s public.class_sessions) returns text
language sql volatile set search_path = '' as $$
  select case s.status
    when 'lobby' then 'lobby'
    when 'finished' then 'finished'
    else case when private.class_elapsed_ms(s.question_started_at)
                    < coalesce((s.settings ->> 'seconds')::int, 30) * 1000
              then 'open' else 'closed' end
  end
$$;

create function private.class_remaining_ms(s public.class_sessions) returns int
language sql volatile set search_path = '' as $$
  select case when s.status <> 'running' then 0
    else greatest(coalesce((s.settings ->> 'seconds')::int, 30) * 1000
                  - private.class_elapsed_ms(s.question_started_at), 0) end
$$;

-- To'g'ri javob faqat vaqt tugab, +1.5 s o'tgach ochiladi (javob qabul qilish
-- 1 s imtiyozi bilan kesishmasligi uchun).
create function private.class_revealed(s public.class_sessions) returns boolean
language sql volatile set search_path = '' as $$
  select s.status = 'finished' or (s.status = 'running'
    and private.class_elapsed_ms(s.question_started_at)
        >= coalesce((s.settings ->> 'seconds')::int, 30) * 1000 + 1500)
$$;

create function private.class_scores(p_session uuid)
returns table (participant_id uuid, nickname text, score int, correct int,
               answered int, avg_ms int, rk int)
language sql stable security definer set search_path = '' as $$
  with s as (
    select p.id, p.nickname,
           coalesce(sum(a.points), 0)::int as score,
           (count(*) filter (where a.is_correct))::int as correct,
           count(a.id)::int as answered,
           coalesce(avg(a.elapsed_ms), 0)::int as avg_ms
    from public.class_participants p
    left join public.class_answers a on a.participant_id = p.id
    where p.session_id = p_session and p.kicked_at is null
    group by p.id, p.nickname)
  select s.id, s.nickname, s.score, s.correct, s.answered, s.avg_ms,
         (rank() over (order by s.score desc, s.correct desc, s.avg_ms asc))::int
  from s
$$;

create function private.class_session_json(s public.class_sessions) returns jsonb
language sql stable set search_path = '' as $$
  select jsonb_build_object(
    'id', s.id, 'code', s.code, 'topic_id', s.topic_id, 'topic_title', s.topic_title,
    'status', s.status, 'current_index', s.current_index,
    'total', coalesce((s.settings ->> 'question_count')::int, 0),
    'question_count', coalesce((s.settings ->> 'question_count')::int, 0),
    'student_limit', coalesce((s.settings ->> 'student_limit')::int, 0),
    'seconds', coalesce((s.settings ->> 'seconds')::int, 30),
    'created_at', s.created_at)
$$;

-- 30 kunlik tozalash + osilib qolgan sessiyalarni yopish. Idempotent.
create function private.class_cleanup() returns int
language plpgsql security definer set search_path = '' as $$
declare n int;
begin
  -- Tugatilmay qolgan sessiyalar 24 soatdan keyin o'zi yopiladi.
  update public.class_sessions
     set status = 'finished', finished_at = now(),
         expires_at = now() + interval '30 days'
   where status <> 'finished' and created_at < now() - interval '24 hours';
  delete from public.class_sessions where expires_at is not null and expires_at < now();
  get diagnostics n = row_count;
  delete from public.class_join_attempts where hour < now() - interval '2 days';
  return n;
end $$;

-- ------------------------------------------------------------ public API

create function public.class_status() returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare me uuid := auth.uid();
begin
  if me is null then raise exception 'forbidden' using errcode = '42501'; end if;
  return jsonb_build_object('is_teacher', private.class_is_teacher(me));
end $$;

create function public.class_topics() returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare me uuid := auth.uid();
begin
  if me is null or not private.class_is_teacher(me) then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  return coalesce((select jsonb_agg(jsonb_build_object(
      'topic_id', t.topic_id, 'title', t.title, 'count', t.n, 'is_demo', t.demo)
      order by t.title)
    from (select q.topic_id, max(q.topic_title) as title, count(*)::int as n,
                 bool_or(q.is_demo) as demo
          from public.class_quiz_questions q group by q.topic_id) t), '[]'::jsonb);
end $$;

create function public.class_create_session(p_topic text, p_question_count int,
  p_student_limit int, p_seconds int) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  v_code text;
  v_id uuid;
  v_title text;
  v_avail int;
  q record;
  perm int[];
  opts jsonb;
  v_new_correct int;
  i int := 0;
  tries int := 0;
begin
  if me is null or not private.class_is_teacher(me) then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  perform private.class_cleanup();
  if p_question_count is null or p_question_count not between 5 and 20
     or p_student_limit is null or p_student_limit not between 5 and 200
     or p_seconds is null or p_seconds not in (15, 30, 45, 60)
     or p_topic is null or char_length(p_topic) not between 1 and 80 then
    return jsonb_build_object('ok', false, 'error', 'invalid_settings');
  end if;
  if (select count(*) from public.class_sessions s
      where s.teacher_id = me and s.status <> 'finished') >= 10 then
    return jsonb_build_object('ok', false, 'error', 'too_many_sessions');
  end if;
  select count(*), max(topic_title) into v_avail, v_title
    from public.class_quiz_questions where topic_id = p_topic;
  if v_avail < p_question_count then
    return jsonb_build_object('ok', false, 'error', 'not_enough_questions',
                              'available', v_avail);
  end if;
  -- 6 xonali kod: CSPRNG (gen_random_uuid) asosida, to'qnashuvda qayta urinish.
  loop
    v_code := lpad((('x' || substr(replace(gen_random_uuid()::text, '-', ''), 1, 8))::bit(32)::bigint
                    % 1000000)::text, 6, '0');
    exit when not exists (select 1 from public.class_sessions where code = v_code);
    tries := tries + 1;
    if tries > 30 then
      return jsonb_build_object('ok', false, 'error', 'try_again');
    end if;
  end loop;
  insert into public.class_sessions (teacher_id, code, topic_id, topic_title, settings)
  values (me, v_code, p_topic, coalesce(v_title, ''),
          jsonb_build_object('question_count', p_question_count,
                             'student_limit', p_student_limit, 'seconds', p_seconds))
  returning id into v_id;
  for q in select * from public.class_quiz_questions
           where topic_id = p_topic order by random() limit p_question_count loop
    select array_agg(x order by random()) into perm from generate_series(0, 3) x;
    opts := jsonb_build_array(q.options -> perm[1], q.options -> perm[2],
                              q.options -> perm[3], q.options -> perm[4]);
    v_new_correct := array_position(perm, q.correct_index::int) - 1;
    insert into public.class_session_questions
      (session_id, idx, question, options, correct_index, explanation, source)
    values (v_id, i, q.question, opts, v_new_correct, q.explanation, q.source);
    i := i + 1;
  end loop;
  return jsonb_build_object('ok', true,
    'session', private.class_session_json(
      (select s from public.class_sessions s where s.id = v_id)));
end $$;

create function public.class_my_sessions() returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare me uuid := auth.uid();
begin
  if me is null or not private.class_is_teacher(me) then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  return coalesce((select jsonb_agg(private.class_session_json(t.s)
      || jsonb_build_object('joined', (select count(*) from public.class_participants p
         where p.session_id = (t.s).id and p.kicked_at is null))
      order by (t.s).created_at desc)
    from (select x as s from public.class_sessions x where x.teacher_id = me
          order by x.created_at desc limit 20) t), '[]'::jsonb);
end $$;

create function public.class_join_session(p_code text, p_nickname text) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  v_code text := regexp_replace(coalesce(p_code, ''), '[\s-]', '', 'g');
  s public.class_sessions;
  part public.class_participants;
  chk text;
  v_nick text;
  v_count int;
begin
  if me is null then raise exception 'forbidden' using errcode = '42501'; end if;
  if not private.class_join_bump(me) then
    return jsonb_build_object('ok', false, 'error', 'rate_limited');
  end if;
  if v_code !~ '^[0-9]{6}$' then
    return jsonb_build_object('ok', false, 'error', 'bad_code');
  end if;
  select * into s from public.class_sessions where code = v_code for update;
  if not found then
    return jsonb_build_object('ok', false, 'error', 'not_found');
  end if;
  if s.teacher_id = me then
    return jsonb_build_object('ok', false, 'error', 'own_session');
  end if;
  if s.status = 'finished' then
    return jsonb_build_object('ok', false, 'error', 'finished');
  end if;
  select * into part from public.class_participants
    where session_id = s.id and user_id = me;
  if found then
    if part.kicked_at is not null then
      return jsonb_build_object('ok', false, 'error', 'kicked');
    end if;
    -- Qayta kirish (ulanish uzilgan): laqab o'zgarmaydi.
    return jsonb_build_object('ok', true, 'session_id', s.id,
      'participant_id', part.id, 'nickname', part.nickname,
      'session', private.class_session_json(s));
  end if;
  if s.status <> 'lobby' then
    return jsonb_build_object('ok', false, 'error', 'already_started');
  end if;
  chk := private.class_nick_check(p_nickname);
  if chk <> 'ok' then
    return jsonb_build_object('ok', false,
      'error', case chk when 'blocked' then 'nick_blocked'
                        when 'chars' then 'nick_chars' else 'nick_length' end);
  end if;
  select count(*) into v_count from public.class_participants
    where session_id = s.id and kicked_at is null;
  if v_count >= coalesce((s.settings ->> 'student_limit')::int, 0) then
    return jsonb_build_object('ok', false, 'error', 'full');
  end if;
  v_nick := private.class_unique_nick(s.id, p_nickname);
  insert into public.class_participants (session_id, user_id, nickname)
  values (s.id, me, v_nick) returning * into part;
  return jsonb_build_object('ok', true, 'session_id', s.id,
    'participant_id', part.id, 'nickname', part.nickname,
    'session', private.class_session_json(s));
end $$;

create function public.class_start(p_session uuid) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare s public.class_sessions;
begin
  s := private.class_owned(p_session, true);
  if s.status <> 'lobby' then
    return jsonb_build_object('ok', false, 'error', 'bad_state');
  end if;
  if not exists (select 1 from public.class_participants p
                 where p.session_id = s.id and p.kicked_at is null) then
    return jsonb_build_object('ok', false, 'error', 'no_participants');
  end if;
  update public.class_sessions
     set status = 'running', current_index = 0, question_started_at = clock_timestamp(),
         started_at = now()
   where id = s.id;
  return jsonb_build_object('ok', true);
end $$;

create function public.class_next(p_session uuid) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare s public.class_sessions; v_total int;
begin
  s := private.class_owned(p_session, true);
  if s.status <> 'running' then
    return jsonb_build_object('ok', false, 'error', 'bad_state');
  end if;
  select count(*) into v_total from public.class_session_questions where session_id = s.id;
  if s.current_index + 1 >= v_total then
    update public.class_sessions
       set status = 'finished', finished_at = now(),
           expires_at = now() + interval '30 days'
     where id = s.id;
    return jsonb_build_object('ok', true, 'finished', true);
  end if;
  update public.class_sessions
     set current_index = current_index + 1, question_started_at = clock_timestamp()
   where id = s.id;
  return jsonb_build_object('ok', true, 'finished', false);
end $$;

-- Hozirgi savolni muddatidan oldin yopadi (natija darrov ochiladi).
create function public.class_close_question(p_session uuid) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare s public.class_sessions;
begin
  s := private.class_owned(p_session, true);
  if s.status <> 'running' then
    return jsonb_build_object('ok', false, 'error', 'bad_state');
  end if;
  update public.class_sessions
     set question_started_at = clock_timestamp()
       - make_interval(secs => coalesce((s.settings ->> 'seconds')::int, 30) + 2)
   where id = s.id;
  return jsonb_build_object('ok', true);
end $$;

create function public.class_finish(p_session uuid) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare s public.class_sessions;
begin
  s := private.class_owned(p_session, true);
  if s.status = 'finished' then
    return jsonb_build_object('ok', true);
  end if;
  update public.class_sessions
     set status = 'finished', finished_at = now(),
         expires_at = now() + interval '30 days'
   where id = s.id;
  return jsonb_build_object('ok', true);
end $$;

create function public.class_kick(p_session uuid, p_participant uuid) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare s public.class_sessions;
begin
  s := private.class_owned(p_session, true);
  update public.class_participants set kicked_at = now()
   where id = p_participant and session_id = s.id and kicked_at is null;
  return jsonb_build_object('ok', found);
end $$;

create function public.class_submit_answer(p_session uuid, p_index int, p_option text)
returns jsonb
language plpgsql security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  part public.class_participants;
  s public.class_sessions;
  q public.class_session_questions;
  v_limit_ms int;
  v_elapsed int;
  v_correct boolean;
  v_rows int;
begin
  if me is null then raise exception 'forbidden' using errcode = '42501'; end if;
  select * into part from public.class_participants
    where session_id = p_session and user_id = me;
  if not found or part.kicked_at is not null then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  select * into s from public.class_sessions where id = p_session;
  if s.status <> 'running' or s.current_index <> p_index then
    return jsonb_build_object('ok', false, 'error', 'not_current');
  end if;
  if p_option is null or p_option !~ '^o[0-3]$' then
    return jsonb_build_object('ok', false, 'error', 'bad_option');
  end if;
  v_limit_ms := coalesce((s.settings ->> 'seconds')::int, 30) * 1000;
  v_elapsed := private.class_elapsed_ms(s.question_started_at);
  -- Server vaqti: muddat + 1 s (tarmoq kechikishi) dan keyin rad.
  if v_elapsed > v_limit_ms + 1000 then
    return jsonb_build_object('ok', false, 'error', 'time_over');
  end if;
  select * into q from public.class_session_questions
    where session_id = s.id and idx = p_index;
  if not found then
    return jsonb_build_object('ok', false, 'error', 'not_current');
  end if;
  v_correct := (p_option = 'o' || q.correct_index::text);
  insert into public.class_answers
    (session_id, participant_id, question_index, option_id, elapsed_ms, is_correct, points)
  values (s.id, part.id, p_index, p_option, least(v_elapsed, v_limit_ms), v_correct,
          private.class_points(v_correct, v_elapsed, v_limit_ms))
  on conflict (participant_id, question_index) do nothing;
  get diagnostics v_rows = row_count;
  if v_rows = 0 then
    return jsonb_build_object('ok', false, 'error', 'already_answered');
  end if;
  -- To'g'ri/noto'g'ri BU YERDA aytilmaydi.
  return jsonb_build_object('ok', true);
end $$;

create function public.class_session_state(p_session uuid) returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  part public.class_participants;
  s public.class_sessions;
  q public.class_session_questions;
  a public.class_answers;
  sc record;
  v_phase text;
  v_revealed boolean;
  v_out jsonb;
begin
  if me is null then raise exception 'forbidden' using errcode = '42501'; end if;
  select * into part from public.class_participants
    where session_id = p_session and user_id = me;
  if not found then raise exception 'forbidden' using errcode = '42501'; end if;
  select * into s from public.class_sessions where id = p_session;
  if part.kicked_at is not null then
    return jsonb_build_object('ok', true, 'kicked', true, 'status', s.status);
  end if;
  v_phase := private.class_phase(s);
  v_revealed := private.class_revealed(s);
  select * into sc from private.class_scores(s.id) x where x.participant_id = part.id;
  v_out := private.class_session_json(s) || jsonb_build_object(
    'ok', true, 'kicked', false, 'nickname', part.nickname, 'phase', v_phase,
    'remaining_ms', private.class_remaining_ms(s),
    'joined', (select count(*) from public.class_participants p
               where p.session_id = s.id and p.kicked_at is null),
    'score', coalesce(sc.score, 0), 'rank', sc.rk, 'correct', coalesce(sc.correct, 0));
  if s.status = 'running' then
    select * into q from public.class_session_questions
      where session_id = s.id and idx = s.current_index;
    select * into a from public.class_answers
      where participant_id = part.id and question_index = s.current_index;
    -- Savol matni va variantlar (correct_index YO'Q).
    v_out := v_out || jsonb_build_object(
      'question', jsonb_build_object('index', q.idx, 'text', q.question,
        'options', (select jsonb_agg(jsonb_build_object('id', 'o' || (o.ord - 1)::text, 'text', o.val)
                                     order by o.ord)
                    from jsonb_array_elements_text(q.options) with ordinality o(val, ord))),
      'my_option', a.option_id);
    if v_revealed then
      v_out := v_out || jsonb_build_object('reveal', jsonb_build_object(
        'correct_option', 'o' || q.correct_index::text,
        'explanation', q.explanation,
        'my_correct', coalesce(a.is_correct, false),
        'my_points', coalesce(a.points, 0)));
    end if;
  elsif s.status = 'finished' then
    v_out := v_out || jsonb_build_object('leaderboard',
      coalesce((select jsonb_agg(jsonb_build_object('participant_id', t.participant_id,
          'nickname', t.nickname, 'score', t.score, 'correct', t.correct, 'rank', t.rk)
          order by t.rk, t.nickname)
        from (select * from private.class_scores(s.id) order by rk, nickname limit 5) t),
        '[]'::jsonb));
  end if;
  return v_out;
end $$;

-- Tugagach talabaning o'z natijasi: har savol bo'yicha javobi, to'g'ri javob,
-- tushuntirish va manba (xato savollarni UI ajratib ko'rsatadi).
create function public.class_my_results(p_session uuid) returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  part public.class_participants;
  s public.class_sessions;
  sc record;
begin
  if me is null then raise exception 'forbidden' using errcode = '42501'; end if;
  select * into part from public.class_participants
    where session_id = p_session and user_id = me and kicked_at is null;
  if not found then raise exception 'forbidden' using errcode = '42501'; end if;
  select * into s from public.class_sessions where id = p_session;
  if s.status <> 'finished' then
    return jsonb_build_object('ok', false, 'error', 'not_finished');
  end if;
  select * into sc from private.class_scores(s.id) x where x.participant_id = part.id;
  return jsonb_build_object('ok', true, 'nickname', part.nickname,
    'score', coalesce(sc.score, 0), 'rank', sc.rk, 'correct', coalesce(sc.correct, 0),
    'total', (select count(*) from public.class_session_questions where session_id = s.id),
    'participants', (select count(*) from public.class_participants p
                     where p.session_id = s.id and p.kicked_at is null),
    'items', coalesce((select jsonb_agg(jsonb_build_object(
        'index', q.idx, 'text', q.question,
        'options', (select jsonb_agg(jsonb_build_object('id', 'o' || (o.ord - 1)::text, 'text', o.val)
                                     order by o.ord)
                    from jsonb_array_elements_text(q.options) with ordinality o(val, ord)),
        'my_option', a.option_id,
        'correct_option', 'o' || q.correct_index::text,
        'is_correct', coalesce(a.is_correct, false),
        'points', coalesce(a.points, 0),
        'explanation', q.explanation, 'source', q.source) order by q.idx)
      from public.class_session_questions q
      left join public.class_answers a
        on a.session_id = q.session_id and a.question_index = q.idx
       and a.participant_id = part.id
      where q.session_id = s.id), '[]'::jsonb));
end $$;

create function public.class_teacher_dashboard(p_session uuid) returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare
  s public.class_sessions;
  q public.class_session_questions;
  v_joined int;
  v_answered int;
  v_correct int;
  v_out jsonb;
begin
  s := private.class_owned(p_session, false);
  select count(*) into v_joined from public.class_participants p
    where p.session_id = s.id and p.kicked_at is null;
  v_out := private.class_session_json(s) || jsonb_build_object(
    'ok', true, 'phase', private.class_phase(s),
    'remaining_ms', private.class_remaining_ms(s), 'joined', v_joined,
    'reports', (select count(*) from public.class_reports r where r.session_id = s.id),
    'participants', coalesce((select jsonb_agg(jsonb_build_object(
        'id', p.id, 'nickname', p.nickname) order by p.joined_at)
      from public.class_participants p
      where p.session_id = s.id and p.kicked_at is null), '[]'::jsonb),
    'leaderboard', coalesce((select jsonb_agg(jsonb_build_object(
        'participant_id', t.participant_id, 'nickname', t.nickname, 'score', t.score,
        'correct', t.correct, 'rank', t.rk) order by t.rk, t.nickname)
      from (select * from private.class_scores(s.id) order by rk, nickname limit 10) t),
      '[]'::jsonb),
    -- Eng qiyin savollar: javob berilgan va yopilganlar orasidan eng past foiz.
    'hardest', coalesce((select jsonb_agg(jsonb_build_object(
        'index', h.idx, 'text', h.question, 'answered', h.n,
        'correct_pct', h.pct) order by h.pct, h.idx)
      from (select sq.idx, sq.question, count(a.id)::int as n,
                   round(100.0 * count(*) filter (where a.is_correct) / nullif(count(a.id), 0))::int as pct
            from public.class_session_questions sq
            join public.class_answers a on a.session_id = sq.session_id
                                       and a.question_index = sq.idx
            where sq.session_id = s.id
              and (s.status = 'finished' or sq.idx < s.current_index
                   or (sq.idx = s.current_index and private.class_phase(s) = 'closed'))
            group by sq.idx, sq.question
            order by pct, sq.idx limit 3) h), '[]'::jsonb));
  if s.status = 'running' then
    select * into q from public.class_session_questions
      where session_id = s.id and idx = s.current_index;
    select count(*)::int, (count(*) filter (where a.is_correct))::int
      into v_answered, v_correct
      from public.class_answers a
      join public.class_participants p on p.id = a.participant_id and p.kicked_at is null
      where a.session_id = s.id and a.question_index = s.current_index;
    v_out := v_out || jsonb_build_object('current', jsonb_build_object(
      'index', q.idx, 'text', q.question,
      'correct_option', 'o' || q.correct_index::text,
      'explanation', q.explanation,
      'answered', v_answered, 'correct_count', v_correct,
      'options', (select jsonb_agg(jsonb_build_object('id', 'o' || (o.ord - 1)::text,
          'text', o.val,
          'count', (select count(*) from public.class_answers a2
                    join public.class_participants p2
                      on p2.id = a2.participant_id and p2.kicked_at is null
                    where a2.session_id = s.id and a2.question_index = s.current_index
                      and a2.option_id = 'o' || (o.ord - 1)::text)) order by o.ord)
        from jsonb_array_elements_text(q.options) with ordinality o(val, ord))));
  end if;
  return v_out;
end $$;

create function public.class_export_results(p_session uuid) returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare s public.class_sessions;
begin
  s := private.class_owned(p_session, false);
  return jsonb_build_object('ok', true, 'session', private.class_session_json(s),
    'rows', coalesce((select jsonb_agg(jsonb_build_object(
        'nickname', t.nickname, 'score', t.score, 'correct', t.correct,
        'answered', t.answered, 'avg_ms', t.avg_ms, 'rank', t.rk)
        order by t.rk, t.nickname)
      from private.class_scores(s.id) t), '[]'::jsonb));
end $$;

-- Laqabga shikoyat: sinf a'zosi (yoki ustoz) boshqa ishtirokchi laqabi haqida.
create function public.class_report_nickname(p_session uuid, p_participant uuid,
  p_reason text) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  v_ok boolean;
  v_reason text := btrim(coalesce(p_reason, ''));
begin
  if me is null then raise exception 'forbidden' using errcode = '42501'; end if;
  v_ok := exists (select 1 from public.class_participants p
                  where p.session_id = p_session and p.user_id = me and p.kicked_at is null)
       or exists (select 1 from public.class_sessions x
                  where x.id = p_session and x.teacher_id = me);
  if not v_ok then raise exception 'forbidden' using errcode = '42501'; end if;
  if char_length(v_reason) not between 3 and 200 then
    return jsonb_build_object('ok', false, 'error', 'bad_reason');
  end if;
  if not exists (select 1 from public.class_participants p
                 where p.id = p_participant and p.session_id = p_session) then
    return jsonb_build_object('ok', false, 'error', 'not_found');
  end if;
  insert into public.class_reports (session_id, participant_id, reporter_id, reason)
  values (p_session, p_participant, me, v_reason)
  on conflict (participant_id, reporter_id) do nothing;
  return jsonb_build_object('ok', true);
end $$;

-- ---------------------------------------------------------------- grants

revoke all on public.class_quiz_questions, public.class_sessions,
  public.class_session_questions, public.class_participants, public.class_answers,
  public.class_reports, public.class_join_attempts from anon, authenticated;

revoke execute on function private.class_is_teacher(uuid) from public, anon, authenticated;
revoke execute on function private.class_elapsed_ms(timestamptz) from public, anon, authenticated;
revoke execute on function private.class_points(boolean, int, int) from public, anon, authenticated;
revoke execute on function private.class_nick_norm(text) from public, anon, authenticated;
revoke execute on function private.class_nick_check(text) from public, anon, authenticated;
revoke execute on function private.class_unique_nick(uuid, text) from public, anon, authenticated;
revoke execute on function private.class_join_bump(uuid) from public, anon, authenticated;
revoke execute on function private.class_owned(uuid, boolean) from public, anon, authenticated;
revoke execute on function private.class_phase(public.class_sessions) from public, anon, authenticated;
revoke execute on function private.class_remaining_ms(public.class_sessions) from public, anon, authenticated;
revoke execute on function private.class_revealed(public.class_sessions) from public, anon, authenticated;
revoke execute on function private.class_scores(uuid) from public, anon, authenticated;
revoke execute on function private.class_session_json(public.class_sessions) from public, anon, authenticated;
revoke execute on function private.class_cleanup() from public, anon, authenticated;

revoke execute on function public.class_status() from public, anon;
revoke execute on function public.class_topics() from public, anon;
revoke execute on function public.class_create_session(text, int, int, int) from public, anon;
revoke execute on function public.class_my_sessions() from public, anon;
revoke execute on function public.class_join_session(text, text) from public, anon;
revoke execute on function public.class_start(uuid) from public, anon;
revoke execute on function public.class_next(uuid) from public, anon;
revoke execute on function public.class_close_question(uuid) from public, anon;
revoke execute on function public.class_finish(uuid) from public, anon;
revoke execute on function public.class_kick(uuid, uuid) from public, anon;
revoke execute on function public.class_submit_answer(uuid, int, text) from public, anon;
revoke execute on function public.class_session_state(uuid) from public, anon;
revoke execute on function public.class_my_results(uuid) from public, anon;
revoke execute on function public.class_teacher_dashboard(uuid) from public, anon;
revoke execute on function public.class_export_results(uuid) from public, anon;
revoke execute on function public.class_report_nickname(uuid, uuid, text) from public, anon;

grant execute on function public.class_status(), public.class_topics(),
  public.class_create_session(text, int, int, int), public.class_my_sessions(),
  public.class_join_session(text, text), public.class_start(uuid), public.class_next(uuid),
  public.class_close_question(uuid), public.class_finish(uuid),
  public.class_kick(uuid, uuid), public.class_submit_answer(uuid, int, text),
  public.class_session_state(uuid), public.class_my_results(uuid),
  public.class_teacher_dashboard(uuid), public.class_export_results(uuid),
  public.class_report_nickname(uuid, uuid, text)
  to authenticated;

-- 30 kunlik tozalashni yoqish (EGASI qo'lda, pg_cron yoqilgach; bu fayl bajarmaydi):
--   select cron.schedule('class_quiz_cleanup', '17 3 * * *',
--                        $$select private.class_cleanup()$$);
