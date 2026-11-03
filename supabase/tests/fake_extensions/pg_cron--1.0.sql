-- TEST-ONLY pg_cron stand-in: same call signatures, no scheduling.
create schema if not exists cron;
create function cron.schedule(job_name text, schedule text, command text)
returns bigint language sql as $$ select 1::bigint $$;
create function cron.schedule(schedule text, command text)
returns bigint language sql as $$ select 1::bigint $$;
create function cron.unschedule(job_name text)
returns boolean language sql as $$ select true $$;
create function cron.unschedule(job_id bigint)
returns boolean language sql as $$ select true $$;
