-- Rollback for 20261011010000_qa_service_api.sql (one line per object).
drop function if exists public.qa_service_bump(uuid, text, int);
drop function if exists public.qa_service_seed_manual_expert(text, text, text);
drop function if exists private.qa_seed_manual_expert(text, text, text);
drop function if exists public.qa_service_translatable(text, uuid);
drop function if exists public.qa_service_translation_put(text, uuid, text, text, text, text);
drop function if exists public.qa_service_set_status(uuid, text, text, text, text, boolean);
drop function if exists public.qa_service_verify_attempt(uuid);
