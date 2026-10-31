-- FORENSIC EXPERT — «Sinfda test»: «Har kim o'z tezligida» (self-paced) rejimi
-- (egasi talabi, 2026-10-31: «Jonli sinfda ham har kim o'z tezligida bo'lsin»).
--
-- Muammo: jonli sinf testida savol va vaqt hammaga umumiy (ustoz «Keyingi»
-- bosadi, soat sessiyada). Endi sessiya ikki rejimdan birida yaratiladi:
--   * pace = 'host' (STANDART, avvalgidek): ustoz boshqaradi. Bu rejimdagi
--     hech bir funksiya natijasi o'zgarmaydi.
--   * pace = 'self': HAR ISHTIROKCHINING o'z progressi — class_participants.
--     current_index (o'z tartibidagi o'rni), question_started_at (o'z savolini
--     ochgan SERVER vaqti), finished_at (hammasini tugatgan).
--
-- Self rejim qoidalari (hammasi serverda):
--   * Ustoz «Boshlash» bosadi (sessiya running). Talaba o'zi «Boshlash» bosadi
--     (class_next_mine — birinchi savolni ochadi, TAYMER SHU PAYTDAN), javobni
--     tanlaydi va alohida «Tasdiqlash» (class_submit_answer — javob shu bilan
--     serverga ketadi), so'ng o'zi «Keyingi» (class_next_mine) bosadi.
--     Savol yopilmaguncha (javob berilmagan va vaqt tugamagan) keyingisiga
--     o'tib bo'lmaydi (not_closed) — avto-o'tish yo'q.
--   * Savollar tartibi HAR TALABAGA alohida, deterministik:
--     md5(participant_id || ':' || idx) bo'yicha (private.class_self_order).
--     Yonidagi talaba telefoniga qarab ko'chirish qiyinlashadi. Javoblar
--     baribir ASL savol idx'i bilan saqlanadi (unique(participant_id,
--     question_index) o'zgarmagan), shuning uchun savol bo'yicha agregatlar
--     («eng qiyin savollar») to'g'ri ishlaydi.
--   * Vaqt serverda: har savolga mavjud `seconds`; muddat + 1 s (tarmoq
--     kechikishi) dan keyingi javob rad etiladi (time_over); takroriy javob
--     taqiqlangan (already_answered); talaba faqat O'Z hozirgi savoliga javob
--     bera oladi (boshqasi — not_current).
--   * To'g'ri javob talabaga FAQAT shu savol uning uchun yopilgach beriladi:
--     o'z javobi tasdiqlangach (u o'zgarmaydi) yoki o'z vaqti tugab +1.5 s
--     o'tgach. Keyingi savollar matni oldindan berilmaydi (har safar faqat
--     bitta, o'zining hozirgi savoli).
--   * Talaba boshqa talabaning javobini/progressini/o'rnini KO'RMAYDI;
--     o'z o'rni (rank) faqat sessiya tugagach. Ustoz (class_teacher_dashboard)
--     har talabaning progressini (nechanchi savolda, nechta javob, nechta
--     to'g'ri, tugatdimi) va jonli reytingni ko'radi; «Keyingi savol» /
--     «Savolni yopish» self rejimda yo'q (bad_state); ustoz sessiyani
--     class_finish bilan yopadi.
--   * Talaba o'z savollarini tugatgach (finished_at) o'z natijasini
--     (class_my_results: xatolar, tushuntirish, manba) sessiya tugamasdan ham
--     ko'radi.
--
-- Orqaga moslik: mavjud RPC imzolari o'zgarmaydi (faqat create or replace,
-- tanalar host yo'li uchun avvalgidek). Yangi: class_create_session_pace
-- (pace tanlab yaratish; eski 4 argumentli class_create_session host
-- sessiya yaratadi) va class_next_mine. Eski mijoz yangi serverda ishlayveradi;
-- yangi mijoz host rejimda eski RPC'ni chaqiradi (migratsiya qo'llanmagan
-- serverda ham host ishlaydi), self rejimda esa yangi RPC kerak (yo'q bo'lsa
-- 404 → «xizmat ulanmagan»).
--
-- Xavfsizlik uslubi mavjudlariga mos: jadval huquqi YO'Q, hamma narsa
-- SECURITY DEFINER (search_path = '') RPC orqali; private yordamchilar
-- mijozga yopiq; huquq xatosi 42501; kutilgan xatolar {ok:false,error}.
--
-- ROLLBACK (qo'lda, egasi ruxsati bilan):
--   supabase/rollback/20261031000000_class_quiz_self_pace_down.sql

-- ----------------------------------------------------------------- jadvallar

alter table public.class_sessions
  add column if not exists pace text not null default 'host'
    check (pace in ('host', 'self'));

alter table public.class_participants
  add column if not exists current_index int not null default 0
    check (current_index >= 0),
  add column if not exists question_started_at timestamptz,
  add column if not exists finished_at timestamptz;

-- ----------------------------------------------------------------- yordamchilar

-- Ishtirokchining savollar tartibi (asl idx lar ro'yxati). Deterministik.
create function private.class_self_order(p_session uuid, p_part uuid)
returns int[]
language sql stable security definer set search_path = '' as $$
  select coalesce(array_agg(q.idx order by md5(p_part::text || ':' || q.idx::text) collate "C",
                            q.idx), '{}'::int[])
  from public.class_session_questions q
  where q.session_id = p_session
$$;

-- Faza: self rejimda sessiya umumiy fazasi 'open' (har kimning oynasi o'zida).
create or replace function private.class_phase(s public.class_sessions) returns text
language sql volatile set search_path = '' as $$
  select case s.status
    when 'lobby' then 'lobby'
    when 'finished' then 'finished'
    else case when s.pace = 'self' then 'open'
              when private.class_elapsed_ms(s.question_started_at)
                    < coalesce((s.settings ->> 'seconds')::int, 30) * 1000
              then 'open' else 'closed' end
  end
$$;

create or replace function private.class_remaining_ms(s public.class_sessions) returns int
language sql volatile set search_path = '' as $$
  select case when s.status <> 'running' or s.pace = 'self' then 0
    else greatest(coalesce((s.settings ->> 'seconds')::int, 30) * 1000
                  - private.class_elapsed_ms(s.question_started_at), 0) end
$$;

-- Umumiy «ochilgan» bayrog'i faqat host rejim uchun mantiqli; self rejimda
-- to'g'ri javob har talabaga o'z oynasi yopilgach (class_self_state) beriladi.
create or replace function private.class_revealed(s public.class_sessions) returns boolean
language sql volatile set search_path = '' as $$
  select s.status = 'finished' or (s.status = 'running' and s.pace <> 'self'
    and private.class_elapsed_ms(s.question_started_at)
        >= coalesce((s.settings ->> 'seconds')::int, 30) * 1000 + 1500)
$$;

create or replace function private.class_session_json(s public.class_sessions) returns jsonb
language sql stable set search_path = '' as $$
  select jsonb_build_object(
    'id', s.id, 'code', s.code, 'topic_id', s.topic_id, 'topic_title', s.topic_title,
    'status', s.status, 'current_index', s.current_index,
    'total', coalesce((s.settings ->> 'question_count')::int, 0),
    'question_count', coalesce((s.settings ->> 'question_count')::int, 0),
    'student_limit', coalesce((s.settings ->> 'student_limit')::int, 0),
    'seconds', coalesce((s.settings ->> 'seconds')::int, 30),
    'pace', s.pace,
    'created_at', s.created_at)
$$;

-- Reyting: host rejimda avvalgidek; self rejimda javob berilgan har savol
-- ko'rinadi (javob yakuniy va o'sha talabaga darrov ochiladi).
create or replace function private.class_scores(p_session uuid)
returns table (participant_id uuid, nickname text, score int, correct int,
               answered int, avg_ms int, rk int)
language plpgsql stable security definer set search_path = '' as $$
declare
  s public.class_sessions;
  v_rev boolean;
begin
  select * into s from public.class_sessions x where x.id = p_session;
  if not found then return; end if;
  v_rev := private.class_revealed(s);
  return query
  with vis as (
    select a.* from public.class_answers a
    where a.session_id = s.id
      and (s.pace = 'self' or s.status = 'finished' or a.question_index < s.current_index
           or (a.question_index = s.current_index and v_rev))),
  t as (
    select p.id, p.nickname,
           coalesce(sum(a.points), 0)::int as score,
           (count(*) filter (where a.is_correct))::int as correct,
           count(a.id)::int as answered,
           (avg(a.elapsed_ms) filter (where a.is_correct))::int as avg_ms
    from public.class_participants p
    left join vis a on a.participant_id = p.id
    where p.session_id = s.id and p.kicked_at is null
    group by p.id, p.nickname)
  select t.id, t.nickname, t.score, t.correct, t.answered, t.avg_ms,
         (rank() over (order by t.score desc, t.correct desc, t.avg_ms asc nulls last))::int
  from t;
end $$;

-- Talabaning self rejimdagi holati (faqat o'zining progressi va hozirgi savoli).
-- stage: ready (hali birinchi savolni ochmagan) | question | done.
create function private.class_self_state(s public.class_sessions,
  part public.class_participants) returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare
  q public.class_session_questions;
  a public.class_answers;
  v_order int[];
  v_idx int;
  v_limit_ms int := coalesce((s.settings ->> 'seconds')::int, 30) * 1000;
  v_elapsed int;
  v_score int;
  v_correct int;
  v_answered int;
  v_phase text;
  v_out jsonb;
begin
  select coalesce(sum(x.points), 0)::int, (count(*) filter (where x.is_correct))::int,
         count(*)::int
    into v_score, v_correct, v_answered
    from public.class_answers x where x.participant_id = part.id;
  v_out := private.class_session_json(s) || jsonb_build_object(
    'ok', true, 'kicked', false, 'nickname', part.nickname,
    'current_index', part.current_index, 'my_position', part.current_index,
    'joined', (select count(*) from public.class_participants p
               where p.session_id = s.id and p.kicked_at is null),
    'score', v_score, 'correct', v_correct, 'answered', v_answered);
  if part.finished_at is not null then
    return v_out || jsonb_build_object('stage', 'done', 'phase', 'closed',
                                       'remaining_ms', 0);
  end if;
  if part.question_started_at is null then
    return v_out || jsonb_build_object('stage', 'ready', 'phase', 'closed',
                                       'remaining_ms', 0);
  end if;
  v_order := private.class_self_order(s.id, part.id);
  v_idx := v_order[part.current_index + 1];
  select * into q from public.class_session_questions
    where session_id = s.id and idx = v_idx;
  select * into a from public.class_answers
    where participant_id = part.id and question_index = v_idx;
  v_elapsed := private.class_elapsed_ms(part.question_started_at);
  v_phase := case when a.id is null and v_elapsed < v_limit_ms then 'open' else 'closed' end;
  -- Savol matni va variantlar (correct_index YO'Q).
  v_out := v_out || jsonb_build_object(
    'stage', 'question', 'phase', v_phase,
    'remaining_ms', case when a.id is null then greatest(v_limit_ms - v_elapsed, 0) else 0 end,
    'question', jsonb_build_object('index', q.idx, 'text', q.question,
      'options', (select jsonb_agg(jsonb_build_object('id', 'o' || (o.ord - 1)::text, 'text', o.val)
                                   order by o.ord)
                  from jsonb_array_elements_text(q.options) with ordinality o(val, ord))),
    'my_option', a.option_id);
  -- To'g'ri javob: o'z javobi tasdiqlangach (u endi o'zgarmaydi) yoki o'z vaqti
  -- tugab, qabul imtiyozi (+1 s) ham o'tgach.
  if a.id is not null or v_elapsed >= v_limit_ms + 1500 then
    v_out := v_out || jsonb_build_object('reveal', jsonb_build_object(
      'correct_option', 'o' || q.correct_index::text,
      'explanation', q.explanation,
      'my_correct', coalesce(a.is_correct, false),
      'my_points', coalesce(a.points, 0)));
  end if;
  return v_out;
end $$;

-- ------------------------------------------------------------ public API (yangi)

-- Rejim tanlab sessiya yaratish. Eski 4 argumentli class_create_session host
-- sessiya yaratadi (o'zgarmagan); bu funksiya uni chaqirib, kerak bo'lsa
-- pace ni belgilaydi (barcha tekshiruvlar/chegaralar bir joyda qoladi).
create function public.class_create_session_pace(p_topic text, p_question_count int,
  p_student_limit int, p_seconds int, p_pace text default 'host') returns jsonb
language plpgsql security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  v jsonb;
  v_id uuid;
begin
  if me is null or not private.class_is_teacher(me) then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  if p_pace is null or p_pace not in ('host', 'self') then
    return jsonb_build_object('ok', false, 'error', 'invalid_settings');
  end if;
  v := public.class_create_session(p_topic, p_question_count, p_student_limit, p_seconds);
  if (v ->> 'ok') is distinct from 'true' then
    return v;
  end if;
  v_id := (v -> 'session' ->> 'id')::uuid;
  update public.class_sessions set pace = p_pace where id = v_id and teacher_id = me;
  return jsonb_build_object('ok', true, 'session', private.class_session_json(
    (select x from public.class_sessions x where x.id = v_id)));
end $$;

-- Self rejimda talabaning o'zi: birinchi savolni ochadi (taymer shu paytdan)
-- yoki yopilgan savoldan keyingisiga o'tadi; oxirgisidan keyin tugatadi.
-- Savol yopilmagan (javob yo'q, vaqt bor) bo'lsa — not_closed. Takror bosish
-- zararsiz: yangi savol hali yopilmagan, demak keyingisiga o'tmaydi.
create function public.class_next_mine(p_session uuid) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  part public.class_participants;
  s public.class_sessions;
  v_total int;
  v_idx int;
  v_limit_ms int;
  v_closed boolean;
begin
  if me is null then raise exception 'forbidden' using errcode = '42501'; end if;
  select * into part from public.class_participants
    where session_id = p_session and user_id = me for update;
  if not found or part.kicked_at is not null then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  select * into s from public.class_sessions where id = p_session;
  if s.pace <> 'self' or s.status <> 'running' then
    return jsonb_build_object('ok', false, 'error', 'bad_state');
  end if;
  if part.finished_at is not null then
    return jsonb_build_object('ok', true, 'finished', true);
  end if;
  if part.question_started_at is null then
    update public.class_participants
       set current_index = 0, question_started_at = clock_timestamp()
     where id = part.id;
    return jsonb_build_object('ok', true, 'finished', false);
  end if;
  select count(*) into v_total from public.class_session_questions
    where session_id = s.id;
  v_idx := (private.class_self_order(s.id, part.id))[part.current_index + 1];
  v_limit_ms := coalesce((s.settings ->> 'seconds')::int, 30) * 1000;
  v_closed := exists (select 1 from public.class_answers a
                      where a.participant_id = part.id and a.question_index = v_idx)
           or private.class_elapsed_ms(part.question_started_at) >= v_limit_ms;
  if not v_closed then
    return jsonb_build_object('ok', false, 'error', 'not_closed');
  end if;
  if part.current_index + 1 >= v_total then
    update public.class_participants set finished_at = now() where id = part.id;
    return jsonb_build_object('ok', true, 'finished', true);
  end if;
  update public.class_participants
     set current_index = current_index + 1, question_started_at = clock_timestamp()
   where id = part.id;
  return jsonb_build_object('ok', true, 'finished', false);
end $$;

-- ------------------------------------------- mavjud RPC lar (host yo'li o'zgarmagan)

-- Ustoz boshqaruvi faqat host rejimda.
create or replace function public.class_next(p_session uuid) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare s public.class_sessions; v_total int;
begin
  s := private.class_owned(p_session, true);
  if s.status <> 'running' or s.pace = 'self' then
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

create or replace function public.class_close_question(p_session uuid) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare s public.class_sessions;
begin
  s := private.class_owned(p_session, true);
  if s.status <> 'running' or s.pace = 'self' then
    return jsonb_build_object('ok', false, 'error', 'bad_state');
  end if;
  update public.class_sessions
     set question_started_at = clock_timestamp()
       - make_interval(secs => coalesce((s.settings ->> 'seconds')::int, 30) + 2)
   where id = s.id;
  return jsonb_build_object('ok', true);
end $$;

create or replace function public.class_submit_answer(p_session uuid, p_index int, p_option text)
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
  v_expected int;
  v_started timestamptz;
begin
  if me is null then raise exception 'forbidden' using errcode = '42501'; end if;
  select * into part from public.class_participants
    where session_id = p_session and user_id = me;
  if not found or part.kicked_at is not null then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  select * into s from public.class_sessions where id = p_session;
  if s.status <> 'running' then
    return jsonb_build_object('ok', false, 'error', 'not_current');
  end if;
  if s.pace = 'self' then
    -- O'z progressi: qatorni qulflab qayta o'qiymiz (Keyingi bilan poyga yo'q).
    select * into part from public.class_participants where id = part.id for update;
    if part.finished_at is not null or part.question_started_at is null then
      return jsonb_build_object('ok', false, 'error', 'not_current');
    end if;
    v_expected := (private.class_self_order(s.id, part.id))[part.current_index + 1];
    v_started := part.question_started_at;
  else
    v_expected := s.current_index;
    v_started := s.question_started_at;
  end if;
  if v_expected is distinct from p_index then
    return jsonb_build_object('ok', false, 'error', 'not_current');
  end if;
  if p_option is null or p_option !~ '^o[0-3]$' then
    return jsonb_build_object('ok', false, 'error', 'bad_option');
  end if;
  v_limit_ms := coalesce((s.settings ->> 'seconds')::int, 30) * 1000;
  v_elapsed := private.class_elapsed_ms(v_started);
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

create or replace function public.class_session_state(p_session uuid) returns jsonb
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
  -- Self rejim, sessiya ketmoqda: faqat o'zining progressi (boshqalarniki yo'q).
  if s.pace = 'self' and s.status = 'running' then
    return private.class_self_state(s, part);
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

-- Natija: sessiya tugagach (hamma rejim) yoki self rejimda talaba o'z savollarini
-- tugatgach. Self rejimda savollar talabaning O'Z tartibida (index = o'rni).
create or replace function public.class_my_results(p_session uuid) returns jsonb
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
  if s.status <> 'finished'
     and not (s.pace = 'self' and s.status = 'running' and part.finished_at is not null) then
    return jsonb_build_object('ok', false, 'error', 'not_finished');
  end if;
  select * into sc from private.class_scores(s.id) x where x.participant_id = part.id;
  return jsonb_build_object('ok', true, 'nickname', part.nickname,
    'score', coalesce(sc.score, 0),
    -- Boshqalar hali tugatmagan: o'rin faqat sessiya tugagach.
    'rank', case when s.status = 'finished' then sc.rk else null end,
    'correct', coalesce(sc.correct, 0),
    'total', (select count(*) from public.class_session_questions where session_id = s.id),
    'participants', (select count(*) from public.class_participants p
                     where p.session_id = s.id and p.kicked_at is null),
    'items', coalesce((
      with qs as (
        select x.*,
               case when s.pace = 'self'
                    then (row_number() over (order by md5(part.id::text || ':' || x.idx::text) collate "C",
                                             x.idx))::int - 1
                    else x.idx end as disp
        from public.class_session_questions x where x.session_id = s.id)
      select jsonb_agg(jsonb_build_object(
        'index', q.disp, 'text', q.question,
        'options', (select jsonb_agg(jsonb_build_object('id', 'o' || (o.ord - 1)::text, 'text', o.val)
                                     order by o.ord)
                    from jsonb_array_elements_text(q.options) with ordinality o(val, ord)),
        'my_option', a.option_id,
        'correct_option', 'o' || q.correct_index::text,
        'is_correct', coalesce(a.is_correct, false),
        'points', coalesce(a.points, 0),
        'explanation', q.explanation, 'source', q.source) order by q.disp)
      from qs q
      left join public.class_answers a
        on a.session_id = q.session_id and a.question_index = q.idx
       and a.participant_id = part.id), '[]'::jsonb));
end $$;

-- Ustoz paneli. Host rejim: avvalgi (20261018040000) bilan bir xil. Self rejim:
-- har ishtirokchining progressi (position = nechanchi savolda, 0 — hali
-- boshlamagan; answered_count; correct_count; done), `self` yig'indisi, joriy
-- savol bloki yo'q, «answered» = tugatgan.
create or replace function public.class_teacher_dashboard(p_session uuid) returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare
  s public.class_sessions;
  q public.class_session_questions;
  v_joined int;
  v_answered int;
  v_correct int;
  v_revealed boolean;
  v_out jsonb;
begin
  s := private.class_owned(p_session, false);
  v_revealed := private.class_revealed(s);
  select count(*) into v_joined from public.class_participants p
    where p.session_id = s.id and p.kicked_at is null;
  v_out := private.class_session_json(s) || jsonb_build_object(
    'ok', true, 'phase', private.class_phase(s), 'revealed', v_revealed,
    'remaining_ms', private.class_remaining_ms(s), 'joined', v_joined,
    'reports', (select count(*) from public.class_reports r where r.session_id = s.id),
    'participants', coalesce((select jsonb_agg(jsonb_build_object(
        'id', p.id, 'nickname', p.nickname,
        'answered', case when s.pace = 'self' then p.finished_at is not null
          else s.status = 'running' and exists (select 1 from public.class_answers a
            where a.participant_id = p.id and a.question_index = s.current_index) end)
        || case when s.pace = 'self' then jsonb_build_object(
          'position', case when p.question_started_at is null then 0 else p.current_index + 1 end,
          'answered_count', (select count(*) from public.class_answers a
                             where a.participant_id = p.id),
          'correct_count', (select count(*) from public.class_answers a
                            where a.participant_id = p.id and a.is_correct),
          'done', p.finished_at is not null) else '{}'::jsonb end
        order by p.joined_at)
      from public.class_participants p
      where p.session_id = s.id and p.kicked_at is null), '[]'::jsonb),
    'leaderboard', coalesce((select jsonb_agg(jsonb_build_object(
        'participant_id', t.participant_id, 'nickname', t.nickname, 'score', t.score,
        'correct', t.correct, 'rank', t.rk) order by t.rk, t.nickname)
      from (select * from private.class_scores(s.id) order by rk, nickname limit 10) t),
      '[]'::jsonb),
    'hardest', coalesce((select jsonb_agg(jsonb_build_object(
        'index', h.idx, 'text', h.question, 'answered', h.n,
        'correct_pct', h.pct) order by h.pct, h.idx)
      from (select sq.idx, sq.question, count(a.id)::int as n,
                   round(100.0 * count(*) filter (where a.is_correct) / nullif(count(a.id), 0))::int as pct
            from public.class_session_questions sq
            join public.class_answers a on a.session_id = sq.session_id
                                       and a.question_index = sq.idx
            where sq.session_id = s.id
              and (s.pace = 'self' or s.status = 'finished' or sq.idx < s.current_index
                   or (sq.idx = s.current_index and v_revealed))
            group by sq.idx, sq.question
            order by pct, sq.idx limit 3) h), '[]'::jsonb));
  if s.pace = 'self' then
    v_out := v_out || jsonb_build_object('self', jsonb_build_object(
      'opened', (select count(*) from public.class_participants p
                 where p.session_id = s.id and p.kicked_at is null
                   and p.question_started_at is not null),
      'done', (select count(*) from public.class_participants p
               where p.session_id = s.id and p.kicked_at is null
                 and p.finished_at is not null)));
  elsif s.status = 'running' then
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

create or replace function public.class_export_results(p_session uuid) returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare
  s public.class_sessions;
  v_rev boolean;
begin
  s := private.class_owned(p_session, false);
  v_rev := private.class_revealed(s);
  return jsonb_build_object('ok', true, 'session', private.class_session_json(s),
    'rows', coalesce((select jsonb_agg(jsonb_build_object(
        'nickname', t.nickname, 'score', t.score, 'correct', t.correct,
        'answered', t.answered,
        'avg_ms', coalesce((select avg(a.elapsed_ms)::int from public.class_answers a
                   where a.participant_id = t.participant_id
                     and (s.pace = 'self' or s.status = 'finished'
                          or a.question_index < s.current_index
                          or (a.question_index = s.current_index and v_rev))), 0),
        'rank', t.rk)
        order by t.rk, t.nickname)
      from private.class_scores(s.id) t), '[]'::jsonb));
end $$;

-- ---------------------------------------------------------------- grants
-- create or replace mavjud huquqlarni saqlaydi; yangilari yopiladi/ochiladi.
revoke execute on function private.class_self_order(uuid, uuid) from public, anon, authenticated;
revoke execute on function private.class_self_state(public.class_sessions, public.class_participants)
  from public, anon, authenticated;
revoke execute on function private.class_phase(public.class_sessions) from public, anon, authenticated;
revoke execute on function private.class_remaining_ms(public.class_sessions) from public, anon, authenticated;
revoke execute on function private.class_revealed(public.class_sessions) from public, anon, authenticated;
revoke execute on function private.class_session_json(public.class_sessions) from public, anon, authenticated;
revoke execute on function private.class_scores(uuid) from public, anon, authenticated;

revoke execute on function public.class_create_session_pace(text, int, int, int, text) from public, anon;
revoke execute on function public.class_next_mine(uuid) from public, anon;
revoke execute on function public.class_next(uuid) from public, anon;
revoke execute on function public.class_close_question(uuid) from public, anon;
revoke execute on function public.class_submit_answer(uuid, int, text) from public, anon;
revoke execute on function public.class_session_state(uuid) from public, anon;
revoke execute on function public.class_my_results(uuid) from public, anon;
revoke execute on function public.class_teacher_dashboard(uuid) from public, anon;
revoke execute on function public.class_export_results(uuid) from public, anon;

grant execute on function public.class_create_session_pace(text, int, int, int, text),
  public.class_next_mine(uuid), public.class_next(uuid),
  public.class_close_question(uuid), public.class_submit_answer(uuid, int, text),
  public.class_session_state(uuid), public.class_my_results(uuid),
  public.class_teacher_dashboard(uuid), public.class_export_results(uuid)
  to authenticated;
