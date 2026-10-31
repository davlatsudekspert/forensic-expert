-- Rollback for 20261031040000_student_card.sql (manual, owner-approved).
-- Talaba kartalari, yashirishlar va rasmlar O'CHADI (foydalanuvchi ma'lumoti):
-- avval kerak bo'lsa nusxa oling. Storage obyektlari SQL bilan emas, Storage
-- API / dashboard orqali bo'shatiladi (bucket ichi bo'sh bo'lmasa bucket
-- o'chirilmaydi):
--   1) `student-cards` bucket ichini bo'shating (Dashboard → Storage);
--   2) quyidagi skriptni ishga tushiring.

drop policy if exists student_cards_owner_upload on storage.objects;
drop policy if exists student_cards_read on storage.objects;
drop policy if exists student_cards_owner_delete on storage.objects;

drop function if exists public.admin_student_card_hide(uuid, boolean, text);
drop function if exists public.group_student_card_hide(uuid, uuid, boolean, text);
drop function if exists public.student_card_hide_for_me(uuid, boolean);
drop function if exists public.student_cards_for_group(uuid);
drop function if exists public.student_card_get(uuid);
drop function if exists public.student_card_delete();
drop function if exists public.student_card_upsert(text, text, text, boolean);
drop function if exists public.student_card_get_mine();

drop function if exists private.student_card_storage_read_ok(text);
drop function if exists private.student_card_storage_write_ok(text);
drop function if exists private.student_card_json(public.student_cards, text, boolean);
drop function if exists private.student_card_visible_to(uuid, public.student_cards);
drop function if exists private.student_card_hidden_by(uuid, uuid);
drop function if exists private.student_card_public(public.student_cards);
drop function if exists private.student_card_related(uuid, uuid);
drop function if exists private.student_card_groupmate(uuid, uuid);
drop function if exists private.student_card_teacher_of(uuid, uuid);
drop function if exists private.student_card_path_ok(uuid, text);
drop function if exists private.student_card_text_ok(text);

drop table if exists private.student_card_audit;
drop table if exists public.student_card_group_hides;
drop table if exists public.student_card_hides;
drop table if exists public.student_cards;

delete from storage.buckets where id = 'student-cards';  -- bucket bo'sh bo'lgach
