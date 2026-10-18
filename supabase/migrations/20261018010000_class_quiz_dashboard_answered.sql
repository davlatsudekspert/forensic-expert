-- FORENSIC EXPERT — «Sinfda test» katta ekran: har qatnashchi uchun joriy
-- savolga javob berganligi (2026-10-18). Faqat bayroq; tanlangan variant yoki
-- to'g'riligi qaytarilmaydi. Additiv (create or replace, imzo o'zgarmagan).

create or replace function public.class_teacher_dashboard(p_session uuid) returns jsonb
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
        'id', p.id, 'nickname', p.nickname,
        -- Katta ekran: joriy savolga javob berganmi (to'g'riligi emas).
        'answered', s.status = 'running' and exists (select 1 from public.class_answers a
          where a.participant_id = p.id and a.question_index = s.current_index))
        order by p.joined_at)
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
