-- FORENSIC EXPERT — «Darslar»: ma'ruza prezentatsiyalari faqat ustozlar uchun
-- (2026-10-18). Slaydlar ilovada chiziladi (JSON), fayl yuklab olinmaydi.
--
-- lesson_decks   — bitta prezentatsiya (deck JSON: slides[], sources[]; mcq yo'q).
-- lesson_topics  — o'quv rejasidagi har bir mavzu → qaysi deck ochiladi
--                  (sarlavhasi bir xil mavzular bitta deckni ochadi).
-- Kirish faqat private.class_is_teacher() orqali (teacher yoki identity_admin).
-- Jadvallarga to'g'ridan-to'g'ri kirish yo'q; faqat ikki RPC.
-- Additiv: hech narsa o'chirilmaydi.

create table public.lesson_decks (
  deck_id text primary key check (char_length(deck_id) between 1 and 80),
  title text not null check (char_length(title) between 1 and 400),
  deck jsonb not null check (jsonb_typeof(deck) = 'object' and deck ? 'slides'),
  slide_count int not null default 0,
  search_text text not null default '',
  source_lang text not null default 'uz',
  updated_at timestamptz not null default now()
);
alter table public.lesson_decks enable row level security;

create table public.lesson_topics (
  topic_id text primary key check (char_length(topic_id) between 1 and 80),
  deck_id text not null references public.lesson_decks (deck_id),
  course text not null default '' check (char_length(course) <= 120),
  title text not null check (char_length(title) between 1 and 400),
  position int not null default 0
);
alter table public.lesson_topics enable row level security;
create index lesson_topics_course on public.lesson_topics (course, position);

revoke all on public.lesson_decks, public.lesson_topics from anon, authenticated;

-- Ro'yxat: kurs bo'yicha guruhlangan mavzular; qidiruv sarlavha va slayd
-- matni bo'yicha (LIKE belgilari ekranlanadi).
create function public.lesson_list(p_query text default null) returns jsonb
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
    where q is null
       or t.title ilike '%' || q || '%' escape '\'
       or d.search_text ilike '%' || q || '%' escape '\'), '[]'::jsonb);
end $$;

-- Bitta prezentatsiya (faqat ustoz). Test savollari (mcq) qaytarilmaydi.
create function public.lesson_get(p_topic_id text) returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  r record;
begin
  if me is null or not private.class_is_teacher(me) then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  select t.topic_id, t.title, t.course, d.deck_id, d.deck, d.source_lang
    into r
    from public.lesson_topics t join public.lesson_decks d on d.deck_id = t.deck_id
   where t.topic_id = p_topic_id;
  if not found then
    return jsonb_build_object('ok', false, 'error', 'not_found');
  end if;
  return jsonb_build_object('ok', true, 'topic_id', r.topic_id, 'title', r.title,
    'course', r.course, 'deck_id', r.deck_id, 'source_lang', r.source_lang,
    'deck', r.deck - 'mcq');
end $$;

revoke execute on function public.lesson_list(text) from public, anon;
revoke execute on function public.lesson_get(text) from public, anon;
grant execute on function public.lesson_list(text), public.lesson_get(text) to authenticated;
