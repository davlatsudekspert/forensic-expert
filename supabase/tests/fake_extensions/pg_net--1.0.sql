-- TEST-ONLY pg_net stand-in: http_post returns a fake request id.
create schema if not exists net;
create function net.http_post(url text, body jsonb default '{}'::jsonb,
  params jsonb default '{}'::jsonb, headers jsonb default '{}'::jsonb,
  timeout_milliseconds int default 5000)
returns bigint language sql as $$ select 1::bigint $$;
