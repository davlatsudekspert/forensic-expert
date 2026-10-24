-- «Apparatlar bilan ishlash» darslari mutaxassislarga ham ochiq (egasi qarori,
-- 2026-10-24): lesson_topics.audience — 'teacher' (standart) yoki 'all'
-- (har qanday kirgan foydalanuvchi). Ustoz hamma darsni ko'radi; boshqalar —
-- faqat audience = 'all'. Kirmagan (anon) — avvalgidek forbidden. Additiv.
-- Production'ga 2026-10-24 qo'llangan.

alter table public.lesson_topics
  add column if not exists audience text not null default 'teacher'
  check (audience in ('teacher', 'all'));

update public.lesson_topics set audience = 'all'
 where course = 'Apparatlar bilan ishlash';

create or replace function public.lesson_list(p_query text default null) returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  teacher boolean;
  q text := private.like_escape(nullif(btrim(left(coalesce(p_query, ''), 100)), ''));
begin
  if me is null then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  teacher := private.class_is_teacher(me);
  return coalesce((select jsonb_agg(jsonb_build_object(
      'topic_id', t.topic_id, 'deck_id', t.deck_id, 'course', t.course,
      'title', t.title, 'slides', d.slide_count)
      order by t.course, t.position, t.topic_id)
    from public.lesson_topics t
    join public.lesson_decks d on d.deck_id = t.deck_id
    where not t.hidden
      and (teacher or t.audience = 'all')
      and (q is null
       or t.title ilike '%' || q || '%' escape '\'
       or d.search_text ilike '%' || q || '%' escape '\')), '[]'::jsonb);
end $$;

create or replace function public.lesson_get(p_topic_id text) returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  r record;
begin
  if me is null then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  select t.topic_id, t.title, t.course, t.audience, d.deck_id, d.deck, d.source_lang
    into r
    from public.lesson_topics t join public.lesson_decks d on d.deck_id = t.deck_id
   where t.topic_id = p_topic_id;
  if not found then
    return jsonb_build_object('ok', false, 'error', 'not_found');
  end if;
  if r.audience <> 'all' and not private.class_is_teacher(me) then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  return jsonb_build_object('ok', true, 'topic_id', r.topic_id, 'title', r.title,
    'course', r.course, 'deck_id', r.deck_id, 'source_lang', r.source_lang,
    'deck', r.deck - 'mcq');
end $$;

revoke execute on function public.lesson_list(text), public.lesson_get(text) from public, anon;
grant execute on function public.lesson_list(text), public.lesson_get(text) to authenticated;
