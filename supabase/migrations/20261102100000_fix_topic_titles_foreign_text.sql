-- 2026-11-02 (egasi tasdig'i «xa tuzat»): ikki dars sarlavhasiga KTP'dan
-- begona pedagogika matni («Kasbiy aks ettirishning psixologik va akmeologik
-- asoslari…») qo'shilib qolgan edi. Faqat shu qism olib tashlandi; mavzu
-- tarkibi slaydlar rejasiga (lesson_decks.deck->>'topic') mos.
-- Eski qiymatlar: public.lesson_topics_title_fix_20261102 jadvalida.

create table if not exists public.lesson_topics_title_fix_20261102 as
  select topic_id, title, now() as saved_at from public.lesson_topics
   where topic_id in ('ktp26-davolash-M6', 'ktp26-stomatologiya-M3');
alter table public.lesson_topics_title_fix_20261102 enable row level security;
revoke all on public.lesson_topics_title_fix_20261102 from anon, authenticated;

update public.lesson_topics set title =
  'Ayrim fizik omillarning organizmga ta’siri. Tirik shaxslarning sud-tibbiy ekspertizasi. 1. Asosiy maqsadlar 2. O‘tkazish tartibi, natijalarni taqdim etish'
 where topic_id = 'ktp26-davolash-M6' and title ilike '%akmeolog%';

update public.lesson_topics set title =
  'Sud tibbiy toksikologiyasi. 1. Asosiy maqsadlar 2. Zaharli moddalar tasnifi 3. Kimyoviy tahlil usullari 4. Zaharlanish belgilari 5. Ekspert baholashining o‘ziga xos jihatlari. Ayrim fizik omillarning organizmga ta’siri. Tirik shaxslarning sud-tibbiy ekspertizasi'
 where topic_id = 'ktp26-stomatologiya-M3' and title ilike '%akmeolog%';
