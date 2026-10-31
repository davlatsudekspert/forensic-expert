-- Rollback for 20261031000000_class_quiz_self_pace.sql (manual, owner-approved).
-- Restores the previous bodies of the changed functions (from
-- 20261017010000_class_quiz.sql and 20261018040000_class_quiz_fixes.sql), drops
-- the new functions and the pace/progress columns. Answers of self-paced
-- sessions are kept; running self-paced sessions are first marked finished
-- (the old code cannot run them: it would show one shared question).
-- Order matters: old bodies first (no reference to pace left), then drops.

create or replace function private.class_phase(s public.class_sessions) returns text
language sql volatile set search_path = '' as $$
  select case s.status
    when 'lobby' then 'lobby'
    when 'finished' then 'finished'
    else case when private.class_elapsed_ms(s.question_started_at)
                    < coalesce((s.settings ->> 'seconds')::int, 30) * 1000
              then 'open' else 'closed' end
  end
$$;

create or replace function private.class_remaining_ms(s public.class_sessions) returns int
language sql volatile set search_path = '' as $$
  select case when s.status <> 'running' then 0
    else greatest(coalesce((s.settings ->> 'seconds')::int, 30) * 1000
                  - private.class_elapsed_ms(s.question_started_at), 0) end
$$;

create or replace function private.class_revealed(s public.class_sessions) returns boolean
language sql volatile set search_path = '' as $$
  select s.status = 'finished' or (s.status = 'running'
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
    'created_at', s.created_at)
$$;

create or replace function public.class_next(p_session uuid) returns jsonb
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

create or replace function public.class_close_question(p_session uuid) returns jsonb
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
    -- Ko'rinadigan javoblar: yopilgan savollar, joriysi faqat revealed bo'lgach.
    select a.* from public.class_answers a
    where a.session_id = s.id
      and (s.status = 'finished' or a.question_index < s.current_index
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
        -- Katta ekran: joriy savolga javob berganmi (to'g'riligi emas).
        'answered', s.status = 'running' and exists (select 1 from public.class_answers a
          where a.participant_id = p.id and a.question_index = s.current_index))
        order by p.joined_at)
      from public.class_participants p
      where p.session_id = s.id and p.kicked_at is null), '[]'::jsonb),
    -- Reyting: private.class_scores — ochiq savol ballari hali kirmaydi.
    'leaderboard', coalesce((select jsonb_agg(jsonb_build_object(
        'participant_id', t.participant_id, 'nickname', t.nickname, 'score', t.score,
        'correct', t.correct, 'rank', t.rk) order by t.rk, t.nickname)
      from (select * from private.class_scores(s.id) order by rk, nickname limit 10) t),
      '[]'::jsonb),
    -- Eng qiyin savollar: yopilgan (joriysi — revealed bo'lgach) savollardan.
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
                   or (sq.idx = s.current_index and v_revealed))
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
                     and (s.status = 'finished' or a.question_index < s.current_index
                          or (a.question_index = s.current_index and v_rev))), 0),
        'rank', t.rk)
        order by t.rk, t.nickname)
      from private.class_scores(s.id) t), '[]'::jsonb));
end $$;

drop function if exists public.class_next_mine(uuid);
drop function if exists public.class_create_session_pace(text, int, int, int, text);
drop function if exists private.class_self_state(public.class_sessions, public.class_participants);
drop function if exists private.class_self_order(uuid, uuid);

update public.class_sessions
   set status = 'finished', finished_at = coalesce(finished_at, now()),
       expires_at = coalesce(expires_at, now() + interval '30 days')
 where pace = 'self' and status <> 'finished';

alter table public.class_participants
  drop column if exists current_index,
  drop column if exists question_started_at,
  drop column if exists finished_at;
alter table public.class_sessions drop column if exists pace;
