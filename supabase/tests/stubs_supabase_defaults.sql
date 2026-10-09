-- Supabase-like default privileges (loaded AFTER stubs.sql and BEFORE the
-- migrations, only for the RLS role matrix database).
--
-- On a real Supabase project every table created in `public` is granted
-- ALL to anon / authenticated / service_role by default, and
-- storage.objects is granted to the API roles. Row Level Security (and the
-- migrations' explicit REVOKEs) are then the only barrier. stubs.sql does not
-- emulate this, so the matrix database adds it to test the realistic case.
alter default privileges in schema public grant all on tables to anon, authenticated, service_role;
alter default privileges in schema public grant all on sequences to anon, authenticated, service_role;
grant all on storage.objects to anon, authenticated, service_role;
grant select on storage.buckets to anon, authenticated, service_role;
