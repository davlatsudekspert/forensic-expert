-- FORENSIC EXPERT — own email OTP (6 digits) sent by the `email-otp` Edge
-- Function through FORENSIC EXPERT's own Resend sender. Codes are stored only
-- as HMAC hashes; the table has RLS with NO policies, so only the service role
-- (Edge Function) can touch it. Pattern reviewed (read-only) from another
-- product; no code, data, keys or identity shared.
create table if not exists public.email_otp_codes (
  id          bigint generated always as identity primary key,
  email       text not null check (length(email) between 3 and 254),
  code_hash   text not null check (code_hash ~ '^[0-9a-f]{64}$'),
  ip_hash     text,
  expires_at  timestamptz not null,
  attempts    int not null default 0,
  used        boolean not null default false,
  created_at  timestamptz not null default now()
);
create index if not exists email_otp_codes_email on public.email_otp_codes (email, created_at desc);
create index if not exists email_otp_codes_ip on public.email_otp_codes (ip_hash, created_at desc);
alter table public.email_otp_codes enable row level security;
revoke all on public.email_otp_codes from anon, authenticated;

-- First identity admin is granted by the owner from the SQL console
-- (granted_by NULL = owner bootstrap). Clients can never insert roles.
alter table public.account_roles alter column granted_by drop not null;
