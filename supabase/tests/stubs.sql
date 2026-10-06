-- Minimal stand-ins for Supabase-provided schemas (local verification only).
create role anon nologin;
create role authenticated nologin;
create role service_role nologin bypassrls;
create schema auth;
create table auth.users (id uuid primary key, email text,
  created_at timestamptz not null default now(), email_confirmed_at timestamptz);
create function auth.uid() returns uuid language sql stable as $$
  select nullif(current_setting('request.jwt.claim.sub', true), '')::uuid
$$;
create schema storage;
create table storage.buckets (id text primary key, name text, public boolean,
  file_size_limit bigint, allowed_mime_types text[]);
create table storage.objects (id uuid primary key default gen_random_uuid(),
  bucket_id text, name text);
alter table storage.objects enable row level security;
create function storage.foldername(name text) returns text[] language sql as $$
  select string_to_array(name, '/')
$$;
grant usage on schema public, auth, storage to authenticated, anon, service_role;
-- Like Supabase: new functions/tables get privileges for API roles directly.
alter default privileges in schema public grant execute on functions to anon, authenticated, service_role;
