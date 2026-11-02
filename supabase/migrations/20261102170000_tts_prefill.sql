-- Background pre-generation of lesson narration audio (edge function
-- `tts-prefill`, hourly via pg_cron). The queue is server-only: RLS on, no
-- policies, no grants to anon/authenticated. Reversible: drop the cron job,
-- the table, the function and the Vault secret.
create extension if not exists pg_cron;
create extension if not exists pg_net;

create table if not exists public.tts_prefill_queue (
  id bigint generated always as identity primary key,
  prio int not null default 100,
  deck_id text not null,
  slide int not null,
  text text not null,
  style text not null default '',
  done_at timestamptz,
  fail_count int not null default 0,
  last_error text,
  model text,
  created_at timestamptz not null default now(),
  unique (deck_id, slide, style)
);
create index if not exists tts_prefill_queue_next
  on public.tts_prefill_queue (prio, id) where done_at is null;
alter table public.tts_prefill_queue enable row level security;
revoke all on public.tts_prefill_queue from anon, authenticated;

-- Token compared inside the database; the value itself never leaves Vault
-- except to the pg_cron job and the operator who created it.
create or replace function public.tts_prefill_token_ok(p_token text)
returns boolean
language sql
security definer
set search_path = ''
as $$
  select exists (
    select 1 from vault.decrypted_secrets
    where name = 'tts_prefill_token' and decrypted_secret = p_token
  );
$$;
revoke all on function public.tts_prefill_token_ok(text) from public, anon, authenticated;
grant execute on function public.tts_prefill_token_ok(text) to service_role;
