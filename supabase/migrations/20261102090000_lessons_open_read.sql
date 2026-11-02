-- 2026-11-02 (egasi so'rovi): talaba hamma mavzuni o'qiy olsin. Darslar
-- (slayd matni + manbalar) hisobga kirgan har kimga ochiq; «Ustoz
-- eslatmalari» (teacher_notes: vaqt, muhokama, tipik xato) va mcq faqat
-- ustoz roliga beriladi. Yashirin mavzular avvalgidek yashirin. Additiv:
-- avvalgi holatga qaytarish — 20261024040000_lesson_topics_audience.sql.

create or replace function public.lesson_list(p_query text default null) returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  q text := private.like_escape(nullif(btrim(left(coalesce(p_query, ''), 100)), ''));
begin
  if me is null then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  return coalesce((select jsonb_agg(jsonb_build_object(
      'topic_id', t.topic_id, 'deck_id', t.deck_id, 'course', t.course,
      'title', t.title, 'slides', d.slide_count)
      order by t.course, t.position, t.topic_id)
    from public.lesson_topics t
    join public.lesson_decks d on d.deck_id = t.deck_id
    where not t.hidden
      and (q is null
       or t.title ilike '%' || q || '%' escape '\'
       or d.search_text ilike '%' || q || '%' escape '\')), '[]'::jsonb);
end $$;

create or replace function public.lesson_get(p_topic_id text) returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  r record;
  v_deck jsonb;
begin
  if me is null then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  select t.topic_id, t.title, t.course, t.hidden, d.deck_id, d.deck, d.source_lang
    into r
    from public.lesson_topics t join public.lesson_decks d on d.deck_id = t.deck_id
   where t.topic_id = p_topic_id;
  if not found then
    return jsonb_build_object('ok', false, 'error', 'not_found');
  end if;
  v_deck := r.deck - 'mcq';
  if not private.class_is_teacher(me) then
    if r.hidden then
      return jsonb_build_object('ok', false, 'error', 'not_found');
    end if;
    if jsonb_typeof(v_deck -> 'slides') = 'array' then
      v_deck := jsonb_set(v_deck, '{slides}', coalesce((
        select jsonb_agg(s - 'teacher_notes' order by i)
          from jsonb_array_elements(v_deck -> 'slides') with ordinality x(s, i)),
        '[]'::jsonb));
    end if;
  end if;
  return jsonb_build_object('ok', true, 'topic_id', r.topic_id, 'title', r.title,
    'course', r.course, 'deck_id', r.deck_id, 'source_lang', r.source_lang,
    'deck', v_deck);
end $$;

revoke execute on function public.lesson_list(text), public.lesson_get(text) from public, anon;
grant execute on function public.lesson_list(text), public.lesson_get(text) to authenticated;
