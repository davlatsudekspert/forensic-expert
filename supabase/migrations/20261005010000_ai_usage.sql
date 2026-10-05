-- FORENSIC EXPERT — AI usage counter (per-user hourly rate limit for the
-- `ai-answer` Edge Function). Stores only user id + timestamp: no question,
-- answer or case text is persisted.
create table if not exists public.ai_usage (
  id bigint generated always as identity primary key,
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  created_at timestamptz not null default now()
);
create index if not exists ai_usage_user_time on public.ai_usage (user_id, created_at desc);
alter table public.ai_usage enable row level security;

create policy ai_usage_own_insert on public.ai_usage
  for insert to authenticated with check (user_id = auth.uid());
create policy ai_usage_own_read on public.ai_usage
  for select to authenticated using (user_id = auth.uid());
-- No update/delete for clients.
revoke all on public.ai_usage from anon;
