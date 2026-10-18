-- Rollback for 20261018050000_class_groups.sql (manual, owner-approved).
-- Deletes ALL «Ustoz–talaba testi» data (groups, members, assignments, attempts).
-- private.nick_fold stays referenced by class_nick_check / class_unique_nick:
-- restore their bodies from 20261018040000_class_quiz_fixes.sql and
-- 20261017010000_class_quiz.sql first if nick_fold must be dropped too.
drop function if exists public.group_assignment_result(uuid);
drop function if exists public.group_assignment_submit(uuid, jsonb);
drop function if exists public.group_assignment_save(uuid, jsonb);
drop function if exists public.group_assignment_open(uuid);
drop function if exists public.group_leave(uuid);
drop function if exists public.group_join(text, text, uuid);
drop function if exists public.group_assignment_preview(uuid);
drop function if exists public.group_assignment_board(uuid);
drop function if exists public.group_assignment_close(uuid);
drop function if exists public.group_assignment_create(uuid, text, int, int, timestamptz, boolean, text);
drop function if exists public.group_remove_member(uuid, uuid);
drop function if exists public.group_detail(uuid);
drop function if exists public.group_list();
drop function if exists public.group_create(text);
drop function if exists private.group_clean_answers(public.class_assignment_attempts, jsonb);
drop function if exists private.group_attempt_json(public.class_assignments, public.class_assignment_attempts);
drop function if exists private.group_assignment_json(public.class_assignments);
drop function if exists private.group_json(public.class_groups, boolean);
drop function if exists private.group_finalize_expired(uuid);
drop function if exists private.group_finalize(uuid, uuid, text);
drop function if exists private.group_grace();
drop function if exists private.group_window_end(public.class_assignments, timestamptz);
drop function if exists private.group_revealed(public.class_assignments);
drop function if exists private.group_assignment_member(uuid);
drop function if exists private.group_assignment_owned(uuid);
drop function if exists private.group_owned(uuid);
drop function if exists private.group_join_bump(uuid);
drop function if exists private.group_bump(text, int);
drop function if exists private.group_variant_draw(text, text, text[], int);
drop function if exists private.group_new_code();
drop function if exists private.group_code_check(text);
drop function if exists private.group_code_norm(text);
drop table if exists public.class_assignment_attempts;
drop table if exists public.class_assignment_questions;
drop table if exists public.class_assignments;
drop table if exists public.class_group_members;
drop table if exists public.class_groups;
delete from public.class_join_attempts where key like 'g_:%';
