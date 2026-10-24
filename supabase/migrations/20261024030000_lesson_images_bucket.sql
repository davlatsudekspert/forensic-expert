-- «Darslar» slayd rasmlari (docs/lessons/DECK_SPEC_V2.md §2a).
-- Ommaviy o'qiladigan `lesson-images` bucket: anon/authenticated faqat O'QIYDI;
-- yozish/o'chirish — faqat service role (yuklash skripti), klient siyosati yo'q.
-- Faqat raster (PNG/JPG), 2 MB gacha. PRODUCTION'GA QO'LLANMAGAN (egasi tasdig'i kerak).
--
-- Rollback:
--   drop policy if exists lesson_images_public_read on storage.objects;
--   -- (avval bucket ichini bo'shating) delete from storage.buckets where id = 'lesson-images';

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('lesson-images', 'lesson-images', true, 2097152,
        array['image/png', 'image/jpeg'])
on conflict (id) do update set public = true, file_size_limit = 2097152,
  allowed_mime_types = array['image/png', 'image/jpeg'];

drop policy if exists lesson_images_public_read on storage.objects;
create policy lesson_images_public_read on storage.objects
  for select to anon, authenticated
  using (bucket_id = 'lesson-images');
-- insert/update/delete uchun siyosat YO'Q: RLS yoqilgan, shuning uchun anon va
-- authenticated yoza olmaydi; service role RLS'ni chetlab o'tadi.
