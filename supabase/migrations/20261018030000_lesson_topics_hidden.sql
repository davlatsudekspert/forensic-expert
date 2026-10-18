-- FORENSIC EXPERT — «Darslar» fakultet bo'yicha (egasi qarori, 2026-10-18).
-- Eski kurs rejalari va KTP 2026 bitta fakultet guruhiga birlashtiriladi;
-- bir xil prezentatsiyani ochadigan takror mavzular ro'yxatda yashiriladi
-- (o'chirilmaydi: lesson_get ularni ham ochadi). Additiv.

alter table public.lesson_topics add column hidden boolean not null default false;

create or replace function public.lesson_list(p_query text default null) returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  q text := private.like_escape(nullif(btrim(left(coalesce(p_query, ''), 100)), ''));
begin
  if me is null or not private.class_is_teacher(me) then
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

revoke execute on function public.lesson_list(text) from public, anon;
grant execute on function public.lesson_list(text) to authenticated;
