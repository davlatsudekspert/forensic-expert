-- «Test o'tkazish» mavzu ro'yxati: har mavzuga kurs nomi (lesson_topics.course)
-- qo'shiladi, shunda ilova «Boshqa mavzular» o'rniga kurslar bo'yicha guruhlaydi.
-- Qo'shimcha (additive): yangi `course` kaliti; eski ilovalar uni e'tiborsiz qoldiradi.
-- Bir mavzu bir necha fakultetda bo'lsa — alifbo bo'yicha birinchi kurs (Davolash ishi ...).
-- Rollback: 20261016...class_topics ta'rifini (course'siz) qayta yarating.
create or replace function public.class_topics()
returns jsonb
language plpgsql
stable security definer
set search_path to ''
as $function$
declare me uuid := auth.uid();
begin
  if me is null or not private.class_is_teacher(me) then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  return coalesce((select jsonb_agg(jsonb_build_object(
      'topic_id', t.topic_id, 'title', t.title, 'count', t.n, 'is_demo', t.demo,
      'course', (select l.course from public.lesson_topics l
                  where l.deck_id = split_part(t.topic_id, '~', 1) and not l.hidden
                  order by l.course limit 1))
      order by t.title)
    from (select q.topic_id, max(q.topic_title) as title, count(*)::int as n,
                 bool_or(q.is_demo) as demo
          from public.class_quiz_questions q group by q.topic_id) t), '[]'::jsonb);
end $function$;
