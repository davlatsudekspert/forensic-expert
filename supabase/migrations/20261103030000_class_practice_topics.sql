-- Dars oxiridagi «Shu mavzu bo‘yicha test boshlash» tugmasi talabada ham
-- yonishi uchun: qaysi mavzularda savol borligini HAR BIR kirgan foydalanuvchi
-- bilishi kerak. `class_topics()` faqat ustozga javob beradi (talabaga
-- 'forbidden') — natijada talabada tugma o‘chiq qolgan edi (egasi, 2026-11-03).
-- Faqat o‘qish: mavzu id, sarlavha va savollar SONI. Savol matni, to‘g‘ri javob
-- qaytmaydi; demo savollar chiqarilmaydi.
create or replace function public.class_practice_topics() returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare me uuid := auth.uid();
begin
  if me is null then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  return coalesce((select jsonb_agg(jsonb_build_object(
      'topic_id', t.topic_id, 'title', t.title, 'count', t.n,
      'is_demo', false, 'course', '') order by t.title)
    from (select q.topic_id, max(q.topic_title) as title, count(*)::int as n
            from public.class_quiz_questions q
           where not q.is_demo
           group by q.topic_id) t), '[]'::jsonb);
end $$;

revoke execute on function public.class_practice_topics() from public, anon;
grant execute on function public.class_practice_topics() to authenticated;
