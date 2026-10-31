-- Rollback for 20261031010000_anti_cheat_seconds_leave.sql (manual, owner-approved).
-- Restores the previous bodies of the changed functions (build 30 state, i.e. from
-- 20261017010000_class_quiz.sql, 20261031000000_class_quiz_self_pace.sql and
-- 20261018050000_class_groups.sql), drops the new functions and the leave
-- columns. The «leave» counters are lost; nothing else is touched.
-- Sessions already created with a free seconds value (e.g. 20 or 90) keep it in
-- their settings and keep working (the time logic reads settings->>'seconds'
-- without any whitelist); only NEW sessions are limited to 15/30/45/60 again.
-- Order matters: old bodies first (no reference to the columns left), then drops.

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
                         else (select count(*) from jsonb_object_keys(t.answers)) end)
        order by (t.submitted_at is null), t.score desc nulls last,
                 (t.user_id is null), t.submitted_at, lower(m.nickname))
      from public.class_group_members m
      left join public.class_assignment_attempts t
        on t.assignment_id = a.id and t.user_id = m.user_id
      where m.group_id = a.group_id), '[]'::jsonb));
end $$;

-- «Talaba ko'rinishida sinash»: ustozga hovuz (to'g'ri javoblar bilan) — sinov

drop function if exists public.class_report_leave(uuid);
drop function if exists public.group_report_leave(uuid);

alter table public.class_participants
  drop column if exists leave_count,
  drop column if exists last_left_at;
alter table public.class_assignment_attempts
  drop column if exists leave_count,
  drop column if exists last_left_at;
