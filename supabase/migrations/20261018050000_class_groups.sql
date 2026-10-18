-- FORENSIC EXPERT — «Ustoz–talaba testi» (guruhlar va asinxron mavzu testlari).
--
-- Oqim (egasi topshirig'i, 2026-10-18):
--   1. USTOZ (private.class_is_teacher) guruh yaratadi va «Mavzu testi berish»:
--      mavzu (class_quiz_questions banki), savollar soni, vaqt chegarasi
--      (1–180 daqiqa yoki chegarasiz), muddat, variant rejimi va to'g'ri
--      javoblar qachon ochilishi.
--   2. Hammaga bir xil QR: forensicexpert://app/g/<KOD>?a=<topshiriq>.
--   3. TALABA (faqat kirgan hisob, anonim yo'q) QR'ni o'qiydi; birinchi marta
--      taxallus so'raladi (group_join), keyin test ochiladi.
--   4. Ballni server hisoblaydi (group_assignment_submit / private.group_finalize).
--   5. Ustoz ekrani va katta ekran (group_assignment_board): har talaba qatori
--      «qo'shildi → yechmoqda → tugatdi + ball», ilova ~3 s polling qiladi.
--   6. To'g'ri javoblar muddat tugagach yoki ustoz testni yopgach ochiladi
--      (private.group_revealed).
--
-- Xavfsizlik (class_quiz bilan bir xil model):
--   * Hamma jadvalda RLS yoqilgan, anon/authenticated'ga jadval huquqi YO'Q;
--     faqat SECURITY DEFINER (search_path = '') RPC. Huquq xatosi — 42501.
--   * Kutilgan xatolar {ok:false,error} (EXCEPTION emas) — rate limit
--     hisoblagichi rollback bo'lmaydi.
--   * Ustoz faqat o'z guruhlarini boshqaradi; talaba faqat o'z urinishini
--     ko'radi; to'g'ri javob ochilishdan oldin hech qaysi talaba javobida yo'q.
--   * Guruhga ko'pi bilan 200 talaba. Kod — 8 belgi, 0/O/1/I/L YO'Q alifbo.
--   * Taxallus: private.class_nick_check (2–20 belgi, filtr), iPhone
--     apostroflari (’ ‘ ʻ ʼ ` ´ ′) oddiy ' ga keltiriladi (private.nick_fold);
--     shu tuzatish «Sinfda test» laqabiga ham qo'llanadi.
--   * Variant: savollar SHA-256("<assignmentId>:<userId>") asosida
--     (private.group_variant_draw). Ilova nusxasi — lib/domain/class_groups/
--     variant_draw.dart; umumiy test vektorlari —
--     apps/mobile/test/fixtures/class_group_variant_vectors.json.
--   * Vaqt: urinish boshlanishi server soati (started_at); tugash =
--     least(due_at, started_at + time_limit, closed_at) + 30 s imtiyoz.
--     Javoblar har savoldan keyin saqlanadi (group_assignment_save), vaqt
--     tugasa server oxirgi saqlangan javoblar bilan yakunlaydi.
--
-- Bu fayl ADDITIV: yangi jadvallar/funksiyalar; class_nick_check va
-- class_unique_nick tanalari apostrof normalizatsiyasi bilan almashtiriladi
-- (imzo o'zgarmagan). Production'ga faqat egasi/lead qo'llaydi.
-- ROLLBACK: supabase/rollback/20261018050000_class_groups_down.sql

-- ------------------------------------------------------------- jadvallar

create table public.class_groups (
  id uuid primary key default gen_random_uuid(),
  teacher_id uuid not null references auth.users (id) on delete cascade,
  name text not null check (char_length(name) between 2 and 60),
  -- 8 belgi; alifboda 0, O, 1, I, L yo'q (qo'lda adashtirilmasin).
  code text not null unique check (code ~ '^[A-HJKMNP-Z2-9]{8}$'),
  created_at timestamptz not null default now()
);
alter table public.class_groups enable row level security;
create index class_groups_teacher on public.class_groups (teacher_id, created_at desc);

create table public.class_group_members (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references public.class_groups (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  nickname text not null check (char_length(nickname) between 2 and 20),
  joined_at timestamptz not null default now(),
  unique (group_id, user_id)
);
alter table public.class_group_members enable row level security;
create unique index class_group_members_nick
  on public.class_group_members (group_id, lower(nickname));
create index class_group_members_user on public.class_group_members (user_id);

create table public.class_assignments (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references public.class_groups (id) on delete cascade,
  topic_id text not null check (char_length(topic_id) between 1 and 80),
  topic_title text not null default '',
  question_count int not null check (question_count between 1 and 200),
  -- «Umumiy test»: tanlangan mavzular (bitta mavzuda — o'sha mavzu).
  topics text[],
  -- NULL — vaqt chegarasi yo'q.
  time_limit_min int check (time_limit_min between 1 and 180),
  due_at timestamptz,
  variant_mode boolean not null default false,
  -- after_due: muddat tugagach (yoki ustoz yopgach); after_close: faqat ustoz yopgach.
  reveal_policy text not null default 'after_close'
    check (reveal_policy in ('after_due', 'after_close')),
  status text not null default 'open' check (status in ('open', 'closed')),
  created_at timestamptz not null default now(),
  closed_at timestamptz,
  check (reveal_policy <> 'after_due' or due_at is not null)
);
alter table public.class_assignments enable row level security;
create index class_assignments_group on public.class_assignments (group_id, created_at desc);

-- Mavzu hovuzining nusxasi (bank keyin o'zgarsa ham test o'zgarmaydi).
-- Variantlar nusxalashda bir marta aralashtiriladi.
create table public.class_assignment_questions (
  assignment_id uuid not null references public.class_assignments (id) on delete cascade,
  qid text not null check (char_length(qid) between 1 and 80),
  question text not null,
  options jsonb not null,
  correct_index smallint not null check (correct_index between 0 and 3),
  explanation text not null default '',
  source jsonb not null default '{}'::jsonb,
  topic_id text,
  primary key (assignment_id, qid)
);
alter table public.class_assignment_questions enable row level security;

create table public.class_assignment_attempts (
  assignment_id uuid not null references public.class_assignments (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  -- Shu talabaga tushgan savollar (tanlash tartibida).
  question_ids text[] not null,
  started_at timestamptz not null default now(),
  -- {qid: variant indeksi 0..3}; faqat server hisoblaydi.
  answers jsonb not null default '{}'::jsonb,
  submitted_at timestamptz,
  score int check (score >= 0),
  total int check (total >= 0),
  -- submitted: talaba yubordi; expired: vaqt/muddat tugab server yakunladi.
  finish_reason text check (finish_reason in ('submitted', 'expired')),
  primary key (assignment_id, user_id)
);
alter table public.class_assignment_attempts enable row level security;
create index class_assignment_attempts_user on public.class_assignment_attempts (user_id);

-- Defense in depth: jadval huquqi tasodifan berilsa ham faqat o'z qatori.
create policy class_groups_teacher_read on public.class_groups
  for select using (teacher_id = auth.uid());
create policy class_group_members_self_read on public.class_group_members
  for select using (user_id = auth.uid());
create policy class_assignment_attempts_self_read on public.class_assignment_attempts
  for select using (user_id = auth.uid());

-- ---------------------------------------------------- taxallus: apostroflar

-- iPhone Smart Punctuation ' ni ’ ga almashtiradi; o'zbekcha oʻ/gʻ ham turli
-- belgilar bilan yoziladi. Hammasi oddiy ' ga keltiriladi, bo'shliqlar
-- qisqartiriladi (Dart: ClassNickname.fold — bir xil ro'yxat).
create function private.nick_fold(p text) returns text
language sql immutable set search_path = '' as $$
  select regexp_replace(btrim(translate(coalesce(p, ''),
    E'’‘ʻʼ`´′', repeat('''', 7))), '\s+', ' ', 'g')
$$;

-- «Sinfda test» laqabi ham shu normalizatsiyadan o'tadi (20261018040000 dagi
-- tana + nick_fold). class_join_session o'zgarmaydi: u shu ikki funksiyani chaqiradi.
create or replace function private.class_nick_check(p text) returns text
language plpgsql immutable set search_path = '' as $$
declare
  t text := private.nick_fold(p);
  norm text;
  stems text[] := array['fuck', 'shit', 'bitch', 'cunt', 'nigger', 'nigga', 'whore',
    'slut', 'pussy', 'asshole', 'blyat', 'blyad', 'pidor', 'pidar', 'mudak', 'pizd',
    'gandon', 'jalab', 'qanjiq', 'onangni', 'sikaman', 'сука',
    'блядь', 'бляд', 'пизд', 'хуй', 'мудак', 'пидор', 'гандон', 'долбоеб', 'долбоёб'];
  prefixes text[] := array['ебат', 'ебал', 'ебан', 'ебло', 'еблан', 'ебуч', 'ебну',
    'ёбан', 'ёбну', 'заеб', 'заёб', 'уеба', 'уебо', 'уёб', 'yebat', 'yeban', 'yebal',
    'zaeb', 'zayeb'];
  exact text[] := array['sik', 'huy', 'xuy', 'hui', 'suka', 'sex',
    'ebal', 'ebat', 'eban', 'ebalo', 'еб', 'ёб'];
  s text;
  w text;
  nw text;
begin
  if char_length(t) < 2 or char_length(t) > 20 then return 'length'; end if;
  if t ~ '[[:cntrl:]<>{}\[\]\\|^~;"`]' then return 'chars'; end if;
  if t !~ '[^[:space:]_.''-]' then return 'chars'; end if;
  norm := private.class_nick_norm(t);
  foreach s in array stems loop
    if position(s in norm) > 0 then return 'blocked'; end if;
  end loop;
  foreach w in array regexp_split_to_array(lower(t), '[^[:alpha:]0-9@$]+')
                     || regexp_split_to_array(lower(t), '[[:space:]]+') loop
    nw := private.class_nick_norm(w);
    continue when nw = '';
    if nw = any (exact) then return 'blocked'; end if;
    foreach s in array prefixes loop
      if left(nw, char_length(s)) = s then return 'blocked'; end if;
    end loop;
  end loop;
  return 'ok';
end $$;

create or replace function private.class_unique_nick(p_session uuid, p_nick text) returns text
language plpgsql security definer set search_path = '' as $$
declare
  base text := private.nick_fold(p_nick);
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

-- ------------------------------------------------------------- yordamchilar

-- Kod: katta harf, bo'shliq/chiziqcha olib tashlanadi.
create function private.group_code_norm(p text) returns text
language sql immutable set search_path = '' as $$
  select upper(regexp_replace(coalesce(p, ''), '[\s-]', '', 'g'))
$$;

-- 'ok' | 'ambiguous' (0/O/1/I/L — alifboda yo'q) | 'bad'.
create function private.group_code_check(p text) returns text
language sql immutable set search_path = '' as $$
  select case
    when private.group_code_norm(p) ~ '^[A-HJKMNP-Z2-9]{8}$' then 'ok'
    when char_length(private.group_code_norm(p)) = 8
         and private.group_code_norm(p) ~ '^[A-Z0-9]{8}$'
         and private.group_code_norm(p) ~ '[01OIL]' then 'ambiguous'
    else 'bad' end
$$;

-- 8 belgili kod, CSPRNG (gen_random_uuid) baytlaridan.
create function private.group_new_code() returns text
language plpgsql volatile set search_path = '' as $$
declare
  alphabet constant text := 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
  h text := replace(gen_random_uuid()::text, '-', '');
  out text := '';
  i int;
begin
  for i in 0..7 loop
    out := out || substr(alphabet,
      (('x' || substr(h, i * 2 + 1, 2))::bit(8)::int % 31) + 1, 1);
  end loop;
  return out;
end $$;

-- Variant tanlovi (Dart: drawVariant — AYNAN bir xil):
--   seed  = hex(SHA-256(utf8("<assignmentId>:<userId>")))
--   kalit = hex(SHA-256(utf8(seed || ":" || savolId)))
--   hovuz kalit (teng bo'lsa — id) bo'yicha o'sish tartibida, birinchi N ta.
-- Satrlar bayt (C) tartibida taqqoslanadi. Umumiy (variantsiz) to'plam —
-- userId o'rniga '*'.
create function private.group_variant_draw(p_assignment text, p_user text,
  p_pool text[], p_n int) returns text[]
language sql immutable set search_path = '' as $$
  with s as (
    select encode(sha256(convert_to(p_assignment || ':' || p_user, 'UTF8')), 'hex') as seed),
  k as (
    select q, encode(sha256(convert_to(s.seed || ':' || q, 'UTF8')), 'hex') as key
    from s, unnest(coalesce(p_pool, '{}'::text[])) q),
  pick as (
    select q, key from k
    order by key collate "C", q collate "C"
    limit greatest(coalesce(p_n, 0), 0))
  select coalesce(array_agg(q order by key collate "C", q collate "C"), '{}'::text[])
  from pick
$$;

-- Soatlik hisoblagich (class_join_attempts jadvali; kalitlar 'g?:' bilan).
create function private.group_bump(p_key text, p_limit int) returns boolean
language plpgsql security definer set search_path = '' as $$
declare v int;
begin
  insert into public.class_join_attempts as a (key, hour, n)
  values (p_key, date_trunc('hour', clock_timestamp()), 1)
  on conflict (key, hour) do update set n = a.n + 1
  returning n into v;
  return v <= p_limit;
end $$;

-- Qo'shilish urinishi: hisob bo'yicha 30/soat, IP bo'yicha muvaffaqiyatsiz
-- urinishlar (private.class_join_fail_ip, «Sinfda test» bilan umumiy) 100/soat.
create function private.group_join_bump(p_user uuid) returns boolean
language plpgsql security definer set search_path = '' as $$
declare
  hdr jsonb;
  ip text;
  v int;
  ok boolean;
begin
  ok := private.group_bump('gj:' || p_user::text, 30);
  begin
    hdr := nullif(current_setting('request.headers', true), '')::jsonb;
  exception when others then hdr := null;
  end;
  ip := nullif(btrim(split_part(coalesce(hdr ->> 'x-forwarded-for', ''), ',', 1)), '');
  if ip is not null then
    select a.n into v from public.class_join_attempts a
      where a.key = 'f:' || md5(ip) and a.hour = date_trunc('hour', clock_timestamp());
    if coalesce(v, 0) >= 100 then ok := false; end if;
  end if;
  return ok;
end $$;

-- Ustoz va guruh egasi; aks holda 42501.
create function private.group_owned(p_group uuid) returns public.class_groups
language plpgsql security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  g public.class_groups;
begin
  if me is null or not private.class_is_teacher(me) then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  select * into g from public.class_groups where id = p_group;
  if not found or g.teacher_id <> me then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  return g;
end $$;

create function private.group_assignment_owned(p_assignment uuid)
returns public.class_assignments
language plpgsql security definer set search_path = '' as $$
declare a public.class_assignments;
begin
  select * into a from public.class_assignments where id = p_assignment;
  if not found then raise exception 'forbidden' using errcode = '42501'; end if;
  perform private.group_owned(a.group_id);
  return a;
end $$;

-- Talaba a'zo bo'lgan topshiriq; aks holda 42501.
create function private.group_assignment_member(p_assignment uuid)
returns public.class_assignments
language plpgsql security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  a public.class_assignments;
begin
  if me is null then raise exception 'forbidden' using errcode = '42501'; end if;
  select * into a from public.class_assignments where id = p_assignment;
  if not found or not exists (select 1 from public.class_group_members m
      where m.group_id = a.group_id and m.user_id = me) then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  return a;
end $$;

-- To'g'ri javoblar talabaga ochiqmi.
create function private.group_revealed(a public.class_assignments) returns boolean
language sql stable set search_path = '' as $$
  select a.status = 'closed'
      or (a.reveal_policy = 'after_due' and a.due_at is not null and now() >= a.due_at)
$$;

-- Urinish oynasining oxiri (imtiyozsiz): muddat, vaqt chegarasi, yopilish.
create function private.group_window_end(a public.class_assignments, p_started timestamptz)
returns timestamptz
language sql stable set search_path = '' as $$
  select least(a.due_at,
               case when a.time_limit_min is null then null
                    else p_started + make_interval(mins => a.time_limit_min) end,
               a.closed_at)
$$;

-- Tarmoq kechikishi uchun imtiyoz.
create function private.group_grace() returns interval
language sql immutable set search_path = '' as $$ select interval '30 seconds' $$;

-- Urinishni yakunlaydi (ball — faqat server). Qaytaradi: yangilangan qator.
create function private.group_finalize(p_assignment uuid, p_user uuid, p_reason text)
returns public.class_assignment_attempts
language plpgsql security definer set search_path = '' as $$
declare t public.class_assignment_attempts;
begin
  update public.class_assignment_attempts x
     set submitted_at = now(), finish_reason = p_reason,
         total = cardinality(x.question_ids),
         score = (select count(*)::int from public.class_assignment_questions q
                  where q.assignment_id = x.assignment_id
                    and q.qid = any (x.question_ids)
                    and (x.answers ->> q.qid) = q.correct_index::text)
   where x.assignment_id = p_assignment and x.user_id = p_user
     and x.submitted_at is null
  returning * into t;
  if not found then
    select * into t from public.class_assignment_attempts x
      where x.assignment_id = p_assignment and x.user_id = p_user;
  end if;
  return t;
end $$;

-- Vaqti tugagan, yuborilmagan urinishlarni oxirgi saqlangan javoblar bilan yakunlaydi.
create function private.group_finalize_expired(p_assignment uuid) returns void
language plpgsql security definer set search_path = '' as $$
declare
  a public.class_assignments;
  r record;
begin
  select * into a from public.class_assignments where id = p_assignment;
  if not found then return; end if;
  for r in select x.user_id from public.class_assignment_attempts x
           where x.assignment_id = a.id and x.submitted_at is null
             and private.group_window_end(a, x.started_at) is not null
             and private.group_window_end(a, x.started_at) + private.group_grace() < now() loop
    perform private.group_finalize(a.id, r.user_id, 'expired');
  end loop;
end $$;

create function private.group_json(g public.class_groups, p_with_code boolean)
returns jsonb
language sql stable set search_path = '' as $$
  select jsonb_build_object('id', g.id, 'name', g.name, 'created_at', g.created_at,
    'member_count', (select count(*) from public.class_group_members m where m.group_id = g.id),
    'member_limit', 200)
    || case when p_with_code then jsonb_build_object('code', g.code) else '{}'::jsonb end
$$;

create function private.group_assignment_json(a public.class_assignments) returns jsonb
language sql stable set search_path = '' as $$
  select jsonb_build_object('id', a.id, 'group_id', a.group_id,
    'topic_id', a.topic_id, 'topic_title', a.topic_title,
    'question_count', a.question_count, 'time_limit_min', a.time_limit_min,
    'topics', coalesce(to_jsonb(a.topics), '[]'::jsonb),
    'due_at', a.due_at, 'variant_mode', a.variant_mode,
    'reveal_policy', a.reveal_policy, 'status', a.status,
    'created_at', a.created_at, 'closed_at', a.closed_at,
    'revealed', private.group_revealed(a), 'server_now', now(),
    'pool_size', (select count(*) from public.class_assignment_questions q
                  where q.assignment_id = a.id))
$$;

-- -------------------------------------------------------------- ustoz API

create function public.group_create(p_name text) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  v_name text := regexp_replace(btrim(coalesce(p_name, '')), '\s+', ' ', 'g');
  v_code text;
  g public.class_groups;
  tries int := 0;
begin
  if me is null or not private.class_is_teacher(me) then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  if not private.group_bump('gc:' || me::text, 20) then
    return jsonb_build_object('ok', false, 'error', 'rate_limited');
  end if;
  if char_length(v_name) not between 2 and 60 then
    return jsonb_build_object('ok', false, 'error', 'bad_name');
  end if;
  if (select count(*) from public.class_groups x where x.teacher_id = me) >= 30 then
    return jsonb_build_object('ok', false, 'error', 'too_many_groups');
  end if;
  loop
    v_code := private.group_new_code();
    exit when not exists (select 1 from public.class_groups x where x.code = v_code);
    tries := tries + 1;
    if tries > 30 then return jsonb_build_object('ok', false, 'error', 'try_again'); end if;
  end loop;
  insert into public.class_groups (teacher_id, name, code)
  values (me, v_name, v_code) returning * into g;
  return jsonb_build_object('ok', true, 'group', private.group_json(g, true));
end $$;

-- Ustoz: o'z guruhlari (kod bilan); talaba: a'zo guruhlari (kodsiz).
create function public.group_list() returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare me uuid := auth.uid();
begin
  if me is null then raise exception 'forbidden' using errcode = '42501'; end if;
  return jsonb_build_object('ok', true,
    'is_teacher', private.class_is_teacher(me),
    'teaching', case when private.class_is_teacher(me) then coalesce((
        select jsonb_agg(private.group_json(g, true) order by g.created_at desc)
        from public.class_groups g where g.teacher_id = me), '[]'::jsonb)
      else '[]'::jsonb end,
    'member', coalesce((
        select jsonb_agg(private.group_json(g, false)
          || jsonb_build_object('nickname', m.nickname) order by m.joined_at desc)
        from public.class_group_members m
        join public.class_groups g on g.id = m.group_id
        where m.user_id = me), '[]'::jsonb));
end $$;

-- Guruh sahifasi. Ustoz-egasi: a'zolar (faqat taxallus) va topshiriqlar
-- (statistika bilan). A'zo talaba: o'z taxallusi va o'z holati. Boshqa — 42501.
create function public.group_detail(p_group uuid) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  g public.class_groups;
  m public.class_group_members;
  a record;
begin
  if me is null then raise exception 'forbidden' using errcode = '42501'; end if;
  select * into g from public.class_groups where id = p_group;
  if not found then raise exception 'forbidden' using errcode = '42501'; end if;
  for a in select x.id from public.class_assignments x where x.group_id = g.id loop
    perform private.group_finalize_expired(a.id);
  end loop;
  if g.teacher_id = me and private.class_is_teacher(me) then
    return jsonb_build_object('ok', true, 'role', 'teacher',
      'group', private.group_json(g, true),
      'members', coalesce((select jsonb_agg(jsonb_build_object(
          'id', x.id, 'nickname', x.nickname, 'joined_at', x.joined_at)
          order by lower(x.nickname))
        from public.class_group_members x where x.group_id = g.id), '[]'::jsonb),
      'assignments', coalesce((select jsonb_agg(private.group_assignment_json(x)
          || jsonb_build_object(
            'started', (select count(*) from public.class_assignment_attempts t
                        where t.assignment_id = x.id),
            'finished', (select count(*) from public.class_assignment_attempts t
                         where t.assignment_id = x.id and t.submitted_at is not null))
          order by x.created_at desc)
        from public.class_assignments x where x.group_id = g.id), '[]'::jsonb));
  end if;
  select * into m from public.class_group_members x
    where x.group_id = g.id and x.user_id = me;
  if not found then raise exception 'forbidden' using errcode = '42501'; end if;
  return jsonb_build_object('ok', true, 'role', 'student',
    'group', private.group_json(g, false), 'nickname', m.nickname,
    'assignments', coalesce((select jsonb_agg(private.group_assignment_json(x)
        || jsonb_build_object(
          'my_state', case when t.user_id is null then 'not_started'
                           when t.submitted_at is null then 'solving'
                           else 'finished' end,
          'my_score', t.score, 'my_total', t.total)
        order by x.created_at desc)
      from public.class_assignments x
      left join public.class_assignment_attempts t
        on t.assignment_id = x.id and t.user_id = me
      where x.group_id = g.id), '[]'::jsonb));
end $$;

-- Talabani guruhdan chiqarish (UGC: nomaqbul taxallus). Uning shu guruhdagi
-- urinishlari ham o'chiriladi.
create function public.group_remove_member(p_group uuid, p_member uuid) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare
  g public.class_groups;
  v_user uuid;
begin
  g := private.group_owned(p_group);
  delete from public.class_group_members x
   where x.id = p_member and x.group_id = g.id returning user_id into v_user;
  if v_user is null then return jsonb_build_object('ok', false, 'error', 'not_found'); end if;
  delete from public.class_assignment_attempts t
   using public.class_assignments a
   where t.assignment_id = a.id and a.group_id = g.id and t.user_id = v_user;
  return jsonb_build_object('ok', true);
end $$;

-- Mavzu testi (bitta mavzu) va «Umumiy test» (bir nechta mavzu) — bitta yo'l.
--  * Bitta mavzu: hovuz — mavzuning hamma savoli (ko'pi bilan 200).
--  * Bir nechta mavzu: savollar mavzulardan NAVBATMA-NAVBAT (round-robin)
--    olinadi: har mavzu ichida tasodifiy tartib, so'ng 1-qatlam (har
--    mavzudan bittadan), 2-qatlam, … — id bo'yicha takrorlanmaydi. Hovuz
--    hajmi: variantsiz — N, variantli — 2N (har talaba undan N tasini oladi).
--    Mavzular bo'yicha taqsimot private.group_round_robin_counts bilan bir xil
--    (Dart: roundRobinCounts).
create function private.group_assignment_make(p_group uuid, p_title text,
  p_topics text[], p_count int, p_time_limit_min int, p_due_at timestamptz,
  p_variant boolean, p_reveal text)
returns jsonb
language plpgsql security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  g public.class_groups;
  a public.class_assignments;
  v_topics text[];
  v_pool int;
  v_title text;
  v_take int;
  q record;
  perm int[];
begin
  g := private.group_owned(p_group);
  if not private.group_bump('ga:' || me::text, 60) then
    return jsonb_build_object('ok', false, 'error', 'rate_limited');
  end if;
  -- Takrorsiz, tartib saqlangan mavzular ro'yxati.
  select array_agg(t order by o) into v_topics from (
    select t, min(o) as o from unnest(coalesce(p_topics, '{}'::text[])) with ordinality u(t, o)
    where t is not null and char_length(t) between 1 and 80 group by t) x;
  if p_count is null or p_count not between 1 and 200
     or (p_time_limit_min is not null and p_time_limit_min not between 1 and 180)
     or p_reveal is null or p_reveal not in ('after_due', 'after_close')
     or v_topics is null or cardinality(v_topics) > 100 then
    return jsonb_build_object('ok', false, 'error', 'invalid_settings');
  end if;
  if p_due_at is not null and (p_due_at < now() + interval '1 minute'
                               or p_due_at > now() + interval '366 days') then
    return jsonb_build_object('ok', false, 'error', 'bad_due');
  end if;
  if p_reveal = 'after_due' and p_due_at is null then
    return jsonb_build_object('ok', false, 'error', 'reveal_needs_due');
  end if;
  select count(*)::int, max(topic_title) into v_pool, v_title
    from public.class_quiz_questions where topic_id = any (v_topics);
  if v_pool < p_count then
    return jsonb_build_object('ok', false, 'error', 'not_enough_questions',
                              'available', v_pool);
  end if;
  -- Variant: hovuz kamida 2 × N bo'lishi shart (aks holda to'plamlar deyarli bir xil).
  if coalesce(p_variant, false) and v_pool < 2 * p_count then
    return jsonb_build_object('ok', false, 'error', 'variant_pool_small',
                              'available', v_pool, 'needed', 2 * p_count);
  end if;
  if (select count(*) from public.class_assignments x
      where x.group_id = g.id and x.status = 'open') >= 50 then
    return jsonb_build_object('ok', false, 'error', 'too_many_assignments');
  end if;
  v_title := coalesce(nullif(regexp_replace(btrim(coalesce(p_title, '')), '\s+', ' ', 'g'), ''),
                      v_title, '');
  insert into public.class_assignments (group_id, topic_id, topic_title, topics,
    question_count, time_limit_min, due_at, variant_mode, reveal_policy)
  values (g.id, case when cardinality(v_topics) = 1 then v_topics[1] else 'mixed' end,
          left(v_title, 200), v_topics, p_count, p_time_limit_min, p_due_at,
          coalesce(p_variant, false), p_reveal)
  returning * into a;
  v_take := case when cardinality(v_topics) = 1 then 200
                 when coalesce(p_variant, false) then least(v_pool, 2 * p_count)
                 else p_count end;
  for q in
    with t as (select tt, o from unnest(v_topics) with ordinality u(tt, o)),
    r as (select x.*, t.o,
                 row_number() over (partition by x.topic_id order by random()) as rn
          from public.class_quiz_questions x join t on t.tt = x.topic_id)
    select * from r order by rn, o limit v_take loop
    select array_agg(i order by random()) into perm from generate_series(0, 3) i;
    insert into public.class_assignment_questions
      (assignment_id, qid, question, options, correct_index, explanation, source, topic_id)
    values (a.id, q.id::text, q.question,
            jsonb_build_array(q.options -> perm[1], q.options -> perm[2],
                              q.options -> perm[3], q.options -> perm[4]),
            array_position(perm, q.correct_index::int) - 1, q.explanation, q.source,
            q.topic_id)
    on conflict do nothing;
  end loop;
  return jsonb_build_object('ok', true, 'assignment', private.group_assignment_json(a));
end $$;

-- Navbatma-navbat taqsimot: mavzu hajmlari [p_sizes] va jami [p_n] dan har
-- mavzuga nechta savol tushadi (Dart roundRobinCounts bilan bir xil).
create function private.group_round_robin_counts(p_sizes int[], p_n int) returns int[]
language plpgsql immutable set search_path = '' as $$
declare
  c int[] := array_fill(0, array[cardinality(p_sizes)]);
  left_n int := greatest(coalesce(p_n, 0), 0);
  progressed boolean;
  i int;
begin
  if cardinality(p_sizes) = 0 then return '{}'; end if;
  loop
    progressed := false;
    for i in 1 .. cardinality(p_sizes) loop
      exit when left_n = 0;
      if c[i] < p_sizes[i] then
        c[i] := c[i] + 1;
        left_n := left_n - 1;
        progressed := true;
      end if;
    end loop;
    exit when left_n = 0 or not progressed;
  end loop;
  return c;
end $$;

create function public.group_assignment_create(p_group uuid, p_topic text, p_count int,
  p_time_limit_min int, p_due_at timestamptz, p_variant boolean, p_reveal text)
returns jsonb
language sql security definer set search_path = '' as $$
  select private.group_assignment_make(p_group, null, array[p_topic], p_count,
    p_time_limit_min, p_due_at, p_variant, p_reveal)
$$;

-- «Umumiy test berish»: bir nechta mavzu, tahrirlanadigan nom.
create function public.group_assignment_create_mixed(p_group uuid, p_title text,
  p_topics text[], p_count int, p_time_limit_min int, p_due_at timestamptz,
  p_variant boolean, p_reveal text)
returns jsonb
language sql security definer set search_path = '' as $$
  select private.group_assignment_make(p_group, p_title, p_topics, p_count,
    p_time_limit_min, p_due_at, p_variant, p_reveal)
$$;

-- Testni yopish: yangi urinish boshlanmaydi; boshlaganlar 30 s ichida yuboradi,
-- qolganlari oxirgi saqlangan javoblar bilan yakunlanadi; javoblar ochiladi.
create function public.group_assignment_close(p_assignment uuid) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare a public.class_assignments;
begin
  a := private.group_assignment_owned(p_assignment);
  update public.class_assignments set status = 'closed', closed_at = now()
   where id = a.id and status = 'open';
  return jsonb_build_object('ok', true);
end $$;

-- Ustoz jonli paneli / katta ekran: har a'zo — bitta qator.
create function public.group_assignment_board(p_assignment uuid) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare
  a public.class_assignments;
  g public.class_groups;
begin
  a := private.group_assignment_owned(p_assignment);
  perform private.group_finalize_expired(a.id);
  select * into a from public.class_assignments where id = p_assignment;
  select * into g from public.class_groups where id = a.group_id;
  return jsonb_build_object('ok', true,
    'assignment', private.group_assignment_json(a),
    'group', private.group_json(g, true),
    'rows', coalesce((select jsonb_agg(jsonb_build_object(
        'member_id', m.id, 'nickname', m.nickname, 'joined_at', m.joined_at,
        'state', case when t.user_id is null then 'joined'
                      when t.submitted_at is null then 'solving'
                      else 'finished' end,
        'score', t.score, 'total', t.total,
        'started_at', t.started_at, 'submitted_at', t.submitted_at,
        'answered', case when t.user_id is null then 0
                         else (select count(*) from jsonb_object_keys(t.answers)) end)
        order by (t.submitted_at is null), t.score desc nulls last,
                 (t.user_id is null), t.submitted_at, lower(m.nickname))
      from public.class_group_members m
      left join public.class_assignment_attempts t
        on t.assignment_id = a.id and t.user_id = m.user_id
      where m.group_id = a.group_id), '[]'::jsonb));
end $$;

-- «Talaba ko'rinishida sinash»: ustozga hovuz (to'g'ri javoblar bilan) — sinov
-- faqat ilova xotirasida, javoblar serverga yuborilmaydi.
create function public.group_assignment_preview(p_assignment uuid) returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare a public.class_assignments;
begin
  a := private.group_assignment_owned(p_assignment);
  return jsonb_build_object('ok', true, 'assignment', private.group_assignment_json(a),
    'pool', coalesce((select jsonb_agg(jsonb_build_object('id', q.qid,
        'text', q.question, 'options', q.options, 'correct_index', q.correct_index,
        'explanation', q.explanation, 'source', q.source) order by q.qid collate "C")
      from public.class_assignment_questions q where q.assignment_id = a.id), '[]'::jsonb));
end $$;

-- ------------------------------------------------------------- talaba API

-- Kod (+ ixtiyoriy taxallus va topshiriq) bilan qo'shilish. Anonim — 42501.
--  * ustoz o'z kodini ochsa — ok, role 'teacher' (a'zo qilinmaydi);
--  * a'zo — ok, role 'student' (taxallus o'zgarmaydi);
--  * yangi talaba taxallussiz — {ok:false, error:'nickname_required', group_name}.
create function public.group_join(p_code text, p_nickname text default null,
  p_assignment uuid default null) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  v_check text := private.group_code_check(p_code);
  g public.class_groups;
  m public.class_group_members;
  v_nick text := private.nick_fold(p_nickname);
  chk text;
  v_aid uuid;
begin
  if me is null then raise exception 'forbidden' using errcode = '42501'; end if;
  if not private.group_join_bump(me) then
    return jsonb_build_object('ok', false, 'error', 'rate_limited');
  end if;
  if v_check <> 'ok' then
    perform private.class_join_fail_ip();
    return jsonb_build_object('ok', false,
      'error', case v_check when 'ambiguous' then 'code_ambiguous' else 'bad_code' end);
  end if;
  select * into g from public.class_groups
    where code = private.group_code_norm(p_code) for update;
  if not found then
    perform private.class_join_fail_ip();
    return jsonb_build_object('ok', false, 'error', 'not_found');
  end if;
  select x.id into v_aid from public.class_assignments x
    where x.id = p_assignment and x.group_id = g.id;
  if g.teacher_id = me then
    return jsonb_build_object('ok', true, 'role', 'teacher',
      'group', private.group_json(g, true), 'assignment_id', v_aid);
  end if;
  select * into m from public.class_group_members x
    where x.group_id = g.id and x.user_id = me;
  if found then
    return jsonb_build_object('ok', true, 'role', 'student', 'already_member', true,
      'group', private.group_json(g, false), 'nickname', m.nickname,
      'assignment_id', v_aid);
  end if;
  if v_nick = '' then
    return jsonb_build_object('ok', false, 'error', 'nickname_required',
      'group_name', g.name);
  end if;
  if (select count(*) from public.class_group_members x where x.group_id = g.id) >= 200 then
    return jsonb_build_object('ok', false, 'error', 'group_full');
  end if;
  chk := private.class_nick_check(v_nick);
  if chk <> 'ok' then
    return jsonb_build_object('ok', false,
      'error', case chk when 'blocked' then 'nick_blocked'
                        when 'chars' then 'nick_chars' else 'nick_length' end);
  end if;
  if exists (select 1 from public.class_group_members x
             where x.group_id = g.id and lower(x.nickname) = lower(v_nick)) then
    return jsonb_build_object('ok', false, 'error', 'nick_taken');
  end if;
  insert into public.class_group_members (group_id, user_id, nickname)
  values (g.id, me, v_nick) returning * into m;
  return jsonb_build_object('ok', true, 'role', 'student', 'already_member', false,
    'group', private.group_json(g, false), 'nickname', m.nickname,
    'assignment_id', v_aid);
end $$;

create function public.group_leave(p_group uuid) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare me uuid := auth.uid();
begin
  if me is null then raise exception 'forbidden' using errcode = '42501'; end if;
  delete from public.class_group_members where group_id = p_group and user_id = me;
  if not found then raise exception 'forbidden' using errcode = '42501'; end if;
  return jsonb_build_object('ok', true);
end $$;

-- Urinish holati (savollar to'g'ri javobsiz). Birinchi ochilishda urinish
-- yaratiladi: started_at — server soati, savollar — variant tanlovi.
create function private.group_attempt_json(a public.class_assignments,
  t public.class_assignment_attempts) returns jsonb
language sql stable set search_path = '' as $$
  select jsonb_build_object('ok', true,
    'state', case when t.submitted_at is null then 'solving' else 'finished' end,
    'assignment', private.group_assignment_json(a),
    'started_at', t.started_at,
    'ends_at', private.group_window_end(a, t.started_at),
    'grace_seconds', extract(epoch from private.group_grace())::int,
    'server_now', now(),
    'answers', t.answers,
    'score', t.score, 'total', t.total, 'submitted_at', t.submitted_at,
    'finish_reason', t.finish_reason,
    'questions', case when t.submitted_at is not null then '[]'::jsonb else
      coalesce((select jsonb_agg(jsonb_build_object('id', q.qid, 'text', q.question,
          'options', q.options) order by o.ord)
        from unnest(t.question_ids) with ordinality o(qid, ord)
        join public.class_assignment_questions q
          on q.assignment_id = a.id and q.qid = o.qid), '[]'::jsonb) end)
$$;

create function public.group_assignment_open(p_assignment uuid) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  a public.class_assignments;
  t public.class_assignment_attempts;
  v_pool text[];
begin
  a := private.group_assignment_member(p_assignment);
  perform private.group_finalize_expired(a.id);
  select * into t from public.class_assignment_attempts x
    where x.assignment_id = a.id and x.user_id = me;
  if not found then
    if a.status <> 'open' then
      return jsonb_build_object('ok', false, 'error', 'closed');
    end if;
    if a.due_at is not null and now() >= a.due_at then
      return jsonb_build_object('ok', false, 'error', 'past_due');
    end if;
    select array_agg(q.qid order by q.qid collate "C") into v_pool
      from public.class_assignment_questions q where q.assignment_id = a.id;
    insert into public.class_assignment_attempts (assignment_id, user_id, question_ids)
    values (a.id, me, private.group_variant_draw(a.id::text,
              case when a.variant_mode then me::text else '*' end,
              v_pool, a.question_count))
    on conflict do nothing;
    select * into t from public.class_assignment_attempts x
      where x.assignment_id = a.id and x.user_id = me;
  end if;
  return private.group_attempt_json(a, t);
end $$;

-- Javoblarni saqlash: {qid: 0..3}. Faqat o'z savollari; oynadan keyin — rad.
create function private.group_clean_answers(t public.class_assignment_attempts, p jsonb)
returns jsonb
language sql immutable set search_path = '' as $$
  select coalesce(jsonb_object_agg(e.key, (e.value #>> '{}')::int), '{}'::jsonb)
  from jsonb_each(case when jsonb_typeof(p) = 'object' then p else '{}'::jsonb end) e
  where e.key = any (t.question_ids)
    and jsonb_typeof(e.value) = 'number'
    and (e.value #>> '{}') in ('0', '1', '2', '3')
$$;

create function public.group_assignment_save(p_assignment uuid, p_answers jsonb) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  a public.class_assignments;
  t public.class_assignment_attempts;
  v_end timestamptz;
begin
  a := private.group_assignment_member(p_assignment);
  select * into t from public.class_assignment_attempts x
    where x.assignment_id = a.id and x.user_id = me for update;
  if not found then return jsonb_build_object('ok', false, 'error', 'not_started'); end if;
  if t.submitted_at is not null then
    return jsonb_build_object('ok', false, 'error', 'already_submitted');
  end if;
  v_end := private.group_window_end(a, t.started_at);
  if v_end is not null and now() > v_end + private.group_grace() then
    return jsonb_build_object('ok', false, 'error', 'time_over');
  end if;
  update public.class_assignment_attempts x
     set answers = x.answers || private.group_clean_answers(t, p_answers)
   where x.assignment_id = a.id and x.user_id = me;
  return jsonb_build_object('ok', true);
end $$;

-- Yuborish: oyna ichida — javoblar saqlanib, ball hisoblanadi. Oyna tugagan
-- bo'lsa — yangi javoblar QABUL QILINMAYDI, oxirgi saqlanganlar bilan
-- yakunlanadi (late = true). To'g'ri/xato faqat ochilgach.
create function public.group_assignment_submit(p_assignment uuid, p_answers jsonb) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  a public.class_assignments;
  t public.class_assignment_attempts;
  v_end timestamptz;
  v_late boolean;
begin
  a := private.group_assignment_member(p_assignment);
  select * into t from public.class_assignment_attempts x
    where x.assignment_id = a.id and x.user_id = me for update;
  if not found then return jsonb_build_object('ok', false, 'error', 'not_started'); end if;
  if t.submitted_at is not null then
    return jsonb_build_object('ok', false, 'error', 'already_submitted');
  end if;
  v_end := private.group_window_end(a, t.started_at);
  v_late := v_end is not null and now() > v_end + private.group_grace();
  if not v_late then
    update public.class_assignment_attempts x
       set answers = x.answers || private.group_clean_answers(t, p_answers)
     where x.assignment_id = a.id and x.user_id = me;
  end if;
  t := private.group_finalize(a.id, me, case when v_late then 'expired' else 'submitted' end);
  return jsonb_build_object('ok', true, 'late', v_late,
    'score', t.score, 'total', t.total, 'submitted_at', t.submitted_at,
    'revealed', private.group_revealed(a));
end $$;

-- O'z natijasi. To'g'ri javob, izoh va manba — faqat ochilgach.
create function public.group_assignment_result(p_assignment uuid) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  a public.class_assignments;
  t public.class_assignment_attempts;
  v_rev boolean;
begin
  a := private.group_assignment_member(p_assignment);
  perform private.group_finalize_expired(a.id);
  select * into t from public.class_assignment_attempts x
    where x.assignment_id = a.id and x.user_id = me;
  if not found or t.submitted_at is null then
    return jsonb_build_object('ok', false, 'error', 'not_submitted');
  end if;
  v_rev := private.group_revealed(a);
  return jsonb_build_object('ok', true, 'assignment', private.group_assignment_json(a),
    'score', t.score, 'total', t.total, 'submitted_at', t.submitted_at,
    'finish_reason', t.finish_reason, 'revealed', v_rev,
    'items', coalesce((select jsonb_agg(
        jsonb_build_object('id', q.qid, 'text', q.question, 'options', q.options,
          'my_answer', (t.answers ->> q.qid)::int)
        || case when v_rev then jsonb_build_object(
             'correct_index', q.correct_index,
             'is_correct', (t.answers ->> q.qid) = q.correct_index::text,
             'explanation', q.explanation, 'source', q.source)
           else '{}'::jsonb end
        order by o.ord)
      from unnest(t.question_ids) with ordinality o(qid, ord)
      join public.class_assignment_questions q
        on q.assignment_id = a.id and q.qid = o.qid), '[]'::jsonb));
end $$;

-- ---------------------------------------------------------------- huquqlar

revoke all on public.class_groups, public.class_group_members, public.class_assignments,
  public.class_assignment_questions, public.class_assignment_attempts
  from anon, authenticated;

revoke execute on function private.nick_fold(text) from public, anon, authenticated;
revoke execute on function private.class_nick_check(text) from public, anon, authenticated;
revoke execute on function private.class_unique_nick(uuid, text) from public, anon, authenticated;
revoke execute on function private.group_code_norm(text) from public, anon, authenticated;
revoke execute on function private.group_code_check(text) from public, anon, authenticated;
revoke execute on function private.group_new_code() from public, anon, authenticated;
revoke execute on function private.group_variant_draw(text, text, text[], int) from public, anon, authenticated;
revoke execute on function private.group_bump(text, int) from public, anon, authenticated;
revoke execute on function private.group_join_bump(uuid) from public, anon, authenticated;
revoke execute on function private.group_owned(uuid) from public, anon, authenticated;
revoke execute on function private.group_assignment_owned(uuid) from public, anon, authenticated;
revoke execute on function private.group_assignment_member(uuid) from public, anon, authenticated;
revoke execute on function private.group_revealed(public.class_assignments) from public, anon, authenticated;
revoke execute on function private.group_window_end(public.class_assignments, timestamptz) from public, anon, authenticated;
revoke execute on function private.group_grace() from public, anon, authenticated;
revoke execute on function private.group_finalize(uuid, uuid, text) from public, anon, authenticated;
revoke execute on function private.group_finalize_expired(uuid) from public, anon, authenticated;
revoke execute on function private.group_json(public.class_groups, boolean) from public, anon, authenticated;
revoke execute on function private.group_assignment_json(public.class_assignments) from public, anon, authenticated;
revoke execute on function private.group_attempt_json(public.class_assignments, public.class_assignment_attempts) from public, anon, authenticated;
revoke execute on function private.group_clean_answers(public.class_assignment_attempts, jsonb) from public, anon, authenticated;

revoke execute on function public.group_create(text) from public, anon;
revoke execute on function public.group_list() from public, anon;
revoke execute on function public.group_detail(uuid) from public, anon;
revoke execute on function public.group_remove_member(uuid, uuid) from public, anon;
revoke execute on function public.group_assignment_create(uuid, text, int, int, timestamptz, boolean, text) from public, anon;
revoke execute on function public.group_assignment_create_mixed(uuid, text, text[], int, int, timestamptz, boolean, text) from public, anon;
revoke execute on function private.group_assignment_make(uuid, text, text[], int, int, timestamptz, boolean, text) from public, anon, authenticated;
revoke execute on function private.group_round_robin_counts(int[], int) from public, anon, authenticated;
revoke execute on function public.group_assignment_close(uuid) from public, anon;
revoke execute on function public.group_assignment_board(uuid) from public, anon;
revoke execute on function public.group_assignment_preview(uuid) from public, anon;
revoke execute on function public.group_join(text, text, uuid) from public, anon;
revoke execute on function public.group_leave(uuid) from public, anon;
revoke execute on function public.group_assignment_open(uuid) from public, anon;
revoke execute on function public.group_assignment_save(uuid, jsonb) from public, anon;
revoke execute on function public.group_assignment_submit(uuid, jsonb) from public, anon;
revoke execute on function public.group_assignment_result(uuid) from public, anon;

grant execute on function public.group_create(text), public.group_list(),
  public.group_detail(uuid), public.group_remove_member(uuid, uuid),
  public.group_assignment_create(uuid, text, int, int, timestamptz, boolean, text),
  public.group_assignment_create_mixed(uuid, text, text[], int, int, timestamptz, boolean, text),
  public.group_assignment_close(uuid), public.group_assignment_board(uuid),
  public.group_assignment_preview(uuid), public.group_join(text, text, uuid),
  public.group_leave(uuid), public.group_assignment_open(uuid),
  public.group_assignment_save(uuid, jsonb), public.group_assignment_submit(uuid, jsonb),
  public.group_assignment_result(uuid)
  to authenticated;
