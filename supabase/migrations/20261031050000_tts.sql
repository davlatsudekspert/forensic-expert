-- FORENSIC EXPERT — Gemini TTS (o‘zbekcha ovoz) server qismi.
--
-- * `tts_usage`: per-user daily counter for the `tts` Edge Function. Only the
--   user id, time and character count are stored (never the text). Written and
--   read ONLY by the function with the service role: RLS is on and clients get
--   no policy and no grant.
-- * `tts-cache` bucket: generated WAV files keyed by
--   sha256(model|voice|style|text). Private; only the service role touches it
--   (no storage policies), the function streams the bytes to signed-in users.
create table if not exists public.tts_usage (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  chars integer not null check (chars between 0 and 20000),
  created_at timestamptz not null default now()
);
create index if not exists tts_usage_user_time on public.tts_usage (user_id, created_at desc);
alter table public.tts_usage enable row level security;
revoke all on public.tts_usage from anon, authenticated;

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('tts-cache', 'tts-cache', false, 20971520, array['audio/wav'])
on conflict (id) do update set public = false, file_size_limit = 20971520,
  allowed_mime_types = array['audio/wav'];
