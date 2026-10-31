-- FORENSIC EXPERT — anti-cheat (server): erkin soniya + «ilovadan chiqdi» hodisasi
-- (egasi talabi, 2026-10-31).
--
-- 1) ERKIN SONIYA (jonli sinf): class_create_session endi p_seconds ni 5..300
--    oralig'ida (butun son) qabul qiladi (avval faqat 15/30/45/60). Imzo va
--    boshqa tekshiruvlar o'zgarmagan; chegaradan tashqarisi — {ok:false,
--    error:'invalid_settings'}. class_create_session_pace shu funksiyani
--    chaqiradi (o'zgarmagan). Vaqt mantig'i (class_phase, class_remaining_ms,
--    class_revealed, class_submit_answer, class_next_mine, class_close_question
--    ...) soniyani `settings->>'seconds'` dan o'qiydi — qiymatga bog'liq emas.
--
-- 2) «ILOVADAN CHIQDI» (talaba test paytida ilovani fonga o'tkazdi):
--    * class_participants.leave_count / last_left_at; yangi
--      public.class_report_leave(p_session) — faqat shu sessiyaning
--      ishtirokchisi (kicked emas; aks holda 42501), sessiya `running` va
--      (self rejimda) talaba test savolini ochgan va hali tugatmagan bo'lsa
--      leave_count += 1. Aks holda zararsiz {ok:true,counted:false}.
--      Suiiste'mol: bir ishtirokchi uchun 1 soniyada bir martadan ko'p
--      sanalmaydi (UPDATE ... WHERE last_left_at <= clock_timestamp()-1s —
--      bitta atomik buyruq, parallel chaqiruvlar ham ikki marta sanalmaydi).
--    * class_assignment_attempts.leave_count / last_left_at; yangi
--      public.group_report_leave(p_assignment) — a'zo talaba, urinish
--      boshlangan va YUBORILMAGAN bo'lsa sanaydi; xuddi shu 1 s limit.
--    * Faqat USTOZ ko'radi: class_teacher_dashboard.participants[] va
--      group_assignment_board.rows[] ga leave_count + last_left_at qo'shildi
--      (boshqa kalitlar va tartib o'zgarmagan). Talaba RPC'lari (class_session_state,
--      class_my_results, group_assignment_result ...) bu maydonlarni QAYTARMAYDI.
--    * Jadval huquqi yo'q (RLS + revoke all), RPC'lar SECURITY DEFINER,
--      search_path = ''; anon uchun execute yo'q.
--
-- Orqaga mos: eski mijozlar yangi RPC'ni chaqirmaydi; qo'shimcha JSON kalitlarini
-- e'tiborsiz qoldiradi. Host rejimi natijalari o'zgarmagan.
-- ROLLBACK (qo'lda, egasi ruxsati bilan):
--   supabase/rollback/20261031010000_anti_cheat_seconds_leave_down.sql

-- ----------------------------------------------------------------- jadvallar

alter table public.class_participants
  add column if not exists leave_count int not null default 0 check (leave_count >= 0),
  add column if not exists last_left_at timestamptz;

alter table public.class_assignment_attempts
  add column if not exists leave_count int not null default 0 check (leave_count >= 0),
  add column if not exists last_left_at timestamptz;

-- ------------------------------------------------------- 1) erkin soniya

-- 20261017010000_class_quiz.sql dagi tanasi (boshqa migratsiya o'zgartirmagan);
-- yagona farq: p_seconds 5..300 (avval in (15, 30, 45, 60)).
create or replace function public.class_create_session(p_topic text, p_question_count int,
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
     or p_seconds is null or p_seconds not between 5 and 300
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

-- --------------------------------------------- 2a) jonli sinf: «chiqdi» hodisasi

-- Talaba test paytida ilovani tark etdi. Faqat sanaydi; hech qanday jazo yo'q,
-- natijaga ta'sir qilmaydi — ustoz dashboardida ko'rinadi.
create function public.class_report_leave(p_session uuid) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  part public.class_participants;
  s public.class_sessions;
  v_rows int;
begin
  if me is null then raise exception 'forbidden' using errcode = '42501'; end if;
  select * into part from public.class_participants
    where session_id = p_session and user_id = me;
  if not found or part.kicked_at is not null then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  select * into s from public.class_sessions where id = p_session;
  if not found or s.status <> 'running' then
    return jsonb_build_object('ok', true, 'counted', false);
  end if;
  -- Bitta atomik UPDATE: qator qulflanadi, shuning uchun parallel chaqiruvlar
  -- ham 1 soniyada ikki marta sanalmaydi. Self rejimda — savol ochilgan va
  -- test hali tugamagan bo'lishi shart.
  update public.class_participants x
     set leave_count = x.leave_count + 1, last_left_at = clock_timestamp()
   where x.id = part.id and x.kicked_at is null
     and (s.pace <> 'self' or (x.finished_at is null and x.question_started_at is not null))
     and (x.last_left_at is null
          or x.last_left_at <= clock_timestamp() - interval '1 second');
  get diagnostics v_rows = row_count;
  return jsonb_build_object('ok', true, 'counted', v_rows > 0);
end $$;

-- Ustoz dashboardi: 20261031000000_class_quiz_self_pace.sql dagi tana + ishtirokchida
-- leave_count va last_left_at (host va self ikkalasida).
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
        'leave_count', p.leave_count, 'last_left_at', p.last_left_at,
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

-- --------------------------------------------- 2b) guruh testi: «chiqdi» hodisasi

create function public.group_report_leave(p_assignment uuid) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  a public.class_assignments;
  v_rows int;
begin
  a := private.group_assignment_member(p_assignment);
  -- Urinish boshlangan va yuborilmagan bo'lsa; 1 soniyalik atomik limit.
  update public.class_assignment_attempts x
     set leave_count = x.leave_count + 1, last_left_at = clock_timestamp()
   where x.assignment_id = a.id and x.user_id = me and x.submitted_at is null
     and (x.last_left_at is null
          or x.last_left_at <= clock_timestamp() - interval '1 second');
  get diagnostics v_rows = row_count;
  return jsonb_build_object('ok', true, 'counted', v_rows > 0);
end $$;

-- Ustoz «jonli natijalar» (board): 20261018050000_class_groups.sql dagi tana +
-- rows[].leave_count va last_left_at (urinish boshlanmagan bo'lsa 0 / null).
create or replace function public.group_assignment_board(p_assignment uuid) returns jsonb
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
                         else (select count(*) from jsonb_object_keys(t.answers)) end,
        'leave_count', coalesce(t.leave_count, 0), 'last_left_at', t.last_left_at)
        order by (t.submitted_at is null), t.score desc nulls last,
                 (t.user_id is null), t.submitted_at, lower(m.nickname))
      from public.class_group_members m
      left join public.class_assignment_attempts t
        on t.assignment_id = a.id and t.user_id = m.user_id
      where m.group_id = a.group_id), '[]'::jsonb));
end $$;

-- «Talaba ko'rinishida sinash»: ustozga hovuz (to'g'ri javoblar bilan) — sinov

-- ---------------------------------------------------------------- grants
-- create or replace mavjud huquqlarni saqlaydi; yangilari yopiladi/ochiladi.
revoke execute on function public.class_report_leave(uuid) from public, anon;
revoke execute on function public.group_report_leave(uuid) from public, anon;
grant execute on function public.class_report_leave(uuid),
  public.group_report_leave(uuid) to authenticated;
