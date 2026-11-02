-- «O‘zim yechib ko‘rish» (egasi qarori «A», 2026-11-02): kirgan foydalanuvchiga
-- mavzudan tasodifiy N ta savol (javobi bilan, faqat shu qurilmada tekshirish
-- uchun). Savollar telefonga ommaviy yuklanmaydi; har chaqiruvda ≤ 20 ta.
create or replace function public.class_practice_questions(
  p_topic text,
  p_count int default 10
) returns jsonb
language plpgsql
volatile
security definer
set search_path to ''
as $$
declare
  me uuid := auth.uid();
  n int := least(greatest(coalesce(p_count, 10), 1), 20);
  t text := p_topic;
  items jsonb;
begin
  if me is null then
    raise exception 'not_signed_in' using errcode = '28000';
  end if;
  if t is null or length(t) > 120 then
    return jsonb_build_object('ok', false, 'error', 'not_found');
  end if;
  -- Til varianti bo‘lmasa — asl (o‘zbekcha) mavzu.
  if not exists (select 1 from public.class_quiz_questions q
                 where q.topic_id = t and not q.is_demo) then
    t := split_part(t, '~', 1);
  end if;
  select jsonb_agg(jsonb_build_object(
           'id', x.id, 'question', x.question, 'options', x.options,
           'correct_index', x.correct_index, 'explanation', x.explanation,
           'source', x.source, 'topic_title', x.topic_title))
    into items
    from (select q.* from public.class_quiz_questions q
          where q.topic_id = t and not q.is_demo
          order by random() limit n) x;
  if items is null then
    return jsonb_build_object('ok', false, 'error', 'not_enough_questions');
  end if;
  return jsonb_build_object('ok', true, 'items', items);
end $$;

revoke all on function public.class_practice_questions(text, int) from public, anon;
grant execute on function public.class_practice_questions(text, int) to authenticated;
