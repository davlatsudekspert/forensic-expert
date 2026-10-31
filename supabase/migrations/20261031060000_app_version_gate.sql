-- FORENSIC EXPERT — eski ilova versiyalarini boshqarish (majburiy yangilash).
--
-- * public.app_config (bitta qator): min_build / latest_build / do‘kon havolalari.
--   min_build = 0 → hech narsa cheklanmaydi (standart; o‘rnatilganda xatti-harakat o‘zgarmaydi).
-- * public.app_version_info(): ilova ishga tushganda o‘qiydi (anon ham chaqira oladi).
-- * private.check_app_build(): PostgREST `db_pre_request` — HAR bir REST/RPC so‘rovidan
--   oldin ishlaydi. min_build > 0 bo‘lsa, `x-fe-build` sarlavhasi yo‘q (build ≤ 34, ya’ni
--   bu himoyadan oldingi APK’lar) yoki min_build dan kichik so‘rov HTTP 426 bilan rad etiladi
--   (SQLSTATE PT426, xabar UPDATE_REQUIRED). Istisnolar: service_role, Edge Function’lar ichidagi
--   supabase-js (ular o‘zi tekshiradi) va app_version_info’ning o‘zi.
-- * `x-fe-check: probe` — faqat shu so‘rovni 426 bilan rad etadi (jonli sinov uchun; boshqa
--   foydalanuvchilarga ta’sir qilmaydi).
-- Qo‘llash: update public.app_config set min_build = <N>, updated_at = now();
create table if not exists public.app_config (
  id boolean primary key default true check (id),
  min_build integer not null default 0 check (min_build >= 0),
  latest_build integer not null default 0 check (latest_build >= 0),
  android_url text,
  ios_url text,
  updated_at timestamptz not null default now()
);
insert into public.app_config (id) values (true) on conflict (id) do nothing;
alter table public.app_config enable row level security;
revoke all on public.app_config from anon, authenticated;

create or replace function public.app_version_info()
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select jsonb_build_object(
    'min_build', c.min_build,
    'latest_build', c.latest_build,
    'android_url', c.android_url,
    'ios_url', c.ios_url)
  from public.app_config c
  where c.id;
$$;
revoke all on function public.app_version_info() from public;
grant execute on function public.app_version_info() to anon, authenticated, service_role;

create or replace function private.check_app_build()
returns void
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  hdr jsonb := coalesce(nullif(current_setting('request.headers', true), ''), '{}')::jsonb;
  claims jsonb := coalesce(nullif(current_setting('request.jwt.claims', true), ''), '{}')::jsonb;
  path text := coalesce(current_setting('request.path', true), '');
  min_b integer;
  raw text;
begin
  if hdr->>'x-fe-check' = 'probe' then
    raise sqlstate 'PT426' using message = 'UPDATE_REQUIRED', detail = 'probe';
  end if;
  if path like '%/rpc/app_version_info' then return; end if;
  if claims->>'role' = 'service_role' then return; end if;
  if coalesce(hdr->>'x-client-info', '') like 'supabase-js-deno%' then return; end if;
  select c.min_build into min_b from public.app_config c where c.id;
  if coalesce(min_b, 0) <= 0 then return; end if;
  raw := hdr->>'x-fe-build';
  if raw is null or raw !~ '^[0-9]{1,9}$' or raw::integer < min_b then
    raise sqlstate 'PT426' using message = 'UPDATE_REQUIRED',
      detail = format('min_build=%s', min_b);
  end if;
end;
$$;
revoke all on function private.check_app_build() from public;
grant execute on function private.check_app_build() to anon, authenticated, service_role;

alter role authenticator set pgrst.db_pre_request = 'private.check_app_build';
notify pgrst, 'reload config';
