-- Rollback for 20261031020000_teacher_card.sql (manual, owner-approved).
-- Ustoz kartalari va ularning rasmlari O'CHADI (foydalanuvchi ma'lumoti):
-- avval kerak bo'lsa nusxa oling. Storage obyektlari SQL bilan emas, Storage
-- API / dashboard orqali bo'shatiladi (bucket ichi bo'sh bo'lmasa bucket
-- o'chirilmaydi):
--   1) `teacher-cards` bucket ichini bo'shating (Dashboard → Storage);
--   2) quyidagi skriptni ishga tushiring.

drop policy if exists teacher_cards_owner_upload on storage.objects;
drop policy if exists teacher_cards_read on storage.objects;
drop policy if exists teacher_cards_owner_delete on storage.objects;

drop function if exists public.admin_teacher_card_hide(uuid, boolean, text);
drop function if exists public.teacher_card_delete();
drop function if exists public.teacher_card_for_group(uuid);
drop function if exists public.teacher_card_get(uuid);
drop function if exists public.teacher_card_upsert(text, text, text, text, text, jsonb, boolean);
drop function if exists public.teacher_card_get_mine();

drop function if exists private.teacher_card_storage_read_ok(text);
drop function if exists private.teacher_card_storage_write_ok(text);
drop function if exists private.teacher_card_json(public.teacher_cards, boolean);
drop function if exists private.teacher_card_member(uuid, uuid);
drop function if exists private.teacher_card_public(public.teacher_cards);
drop function if exists private.teacher_card_path_ok(uuid, text, text);
drop function if exists private.teacher_card_url_ok(text, text);

drop table if exists public.teacher_cards;

delete from storage.buckets where id = 'teacher-cards';  -- bucket bo'sh bo'lgach
