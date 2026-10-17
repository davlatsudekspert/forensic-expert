-- Rollback for 20261017000000_class_quiz.sql (manual, owner-approved).
-- Deletes ALL class-quiz data (sessions, participants, answers, question bank).
-- If pg_cron was scheduled: select cron.unschedule('class_quiz_cleanup');
drop function if exists public.class_report_nickname(uuid, uuid, text);
drop function if exists public.class_export_results(uuid);
drop function if exists public.class_teacher_dashboard(uuid);
drop function if exists public.class_my_results(uuid);
drop function if exists public.class_session_state(uuid);
drop function if exists public.class_submit_answer(uuid, int, text);
drop function if exists public.class_kick(uuid, uuid);
drop function if exists public.class_finish(uuid);
drop function if exists public.class_close_question(uuid);
drop function if exists public.class_next(uuid);
drop function if exists public.class_start(uuid);
drop function if exists public.class_join_session(text, text);
drop function if exists public.class_my_sessions();
drop function if exists public.class_create_session(text, int, int, int);
drop function if exists public.class_topics();
drop function if exists public.class_status();
drop function if exists private.class_cleanup();
drop function if exists private.class_session_json(public.class_sessions);
drop function if exists private.class_scores(uuid);
drop function if exists private.class_revealed(public.class_sessions);
drop function if exists private.class_remaining_ms(public.class_sessions);
drop function if exists private.class_phase(public.class_sessions);
drop function if exists private.class_owned(uuid, boolean);
drop function if exists private.class_join_bump(uuid);
drop function if exists private.class_unique_nick(uuid, text);
drop function if exists private.class_nick_check(text);
drop function if exists private.class_nick_norm(text);
drop function if exists private.class_points(boolean, int, int);
drop function if exists private.class_elapsed_ms(timestamptz);
drop function if exists private.class_is_teacher(uuid);
drop table if exists public.class_join_attempts, public.class_reports,
  public.class_answers, public.class_participants, public.class_session_questions,
  public.class_sessions, public.class_quiz_questions;
delete from public.account_roles where role = 'teacher';
-- The enum value 'teacher' cannot be dropped from public.account_role without
-- recreating the type; it is harmless to keep.
