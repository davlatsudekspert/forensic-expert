-- FORENSIC EXPERT — colleague referrals + FORENSIC Credits ledger.
--
-- Security model (enforced HERE; the Flutter client is never trusted):
--   * Codes are generated server-side (8 chars, no 0/O/1/I), one per account.
--   * Attribution only via claim_referral(): signed-in caller, code exists,
--     not self, caller has no referrer yet (UNIQUE referred_id), caller is a
--     NEW account (attribution window), the email was never registered before
--     (deleted/recreated account abuse), no circular A<->B, per-hour attempt
--     limit (code guessing) and per-referrer daily cap.
--   * Referral becomes VALID only when the referred email is confirmed
--     (FORENSIC EXPERT's own OTP confirms it; a trigger promotes PENDING).
--   * Attribution is immutable (trigger) and has no client write path
--     (RLS on, no policies, privileges revoked).
--   * Rewards: no reward for registration. award_referral_reward() is callable
--     ONLY by the service role (server-side purchase verification) and is
--     idempotent per store transaction (UNIQUE source_transaction).
--     Reward = floor(purchase × reward_percent / 100), percent configurable in
--     referral_config (default 10 %, rewards disabled until paid services
--     launch). Credits are internal promotional credit, NOT cash.
--   * Clients only see their own aggregate counts (referral_dashboard());
--     referred users' identities/emails are never exposed.
--   * Every attempt and reward is written to private.referral_audit.

create type public.referral_status as enum ('PENDING_VERIFICATION', 'VALID', 'REVOKED');
create type public.referral_reward_status as enum ('PENDING', 'APPROVED', 'REVERSED');

-- ---------------------------------------------------------------- config
create table public.referral_config (
  id boolean primary key default true check (id),
  reward_type text not null default 'FORENSIC_CREDIT' check (reward_type in ('FORENSIC_CREDIT')),
  reward_percent numeric(5, 2) not null default 10 check (reward_percent >= 0 and reward_percent <= 50),
  currency text not null default 'USD' check (currency ~ '^[A-Z]{3}$'),
  rewards_enabled boolean not null default false,
  attribution_window_days int not null default 14 check (attribution_window_days between 1 and 90),
  max_valid_per_referrer_per_day int not null default 20 check (max_valid_per_referrer_per_day > 0),
  max_claim_attempts_per_hour int not null default 10 check (max_claim_attempts_per_hour > 0),
  updated_at timestamptz not null default now()
);
insert into public.referral_config default values;

-- ---------------------------------------------------------------- tables
create table public.referral_codes (
  user_id uuid primary key references auth.users (id) on delete cascade,
  code text not null unique check (code ~ '^[A-HJ-NP-Z2-9]{8}$'),
  created_at timestamptz not null default now()
);

create table public.referrals (
  id bigint generated always as identity primary key,
  referrer_id uuid not null references auth.users (id) on delete cascade,
  referred_id uuid not null unique references auth.users (id) on delete cascade,
  code text not null,
  status public.referral_status not null,
  created_at timestamptz not null default now(),
  validated_at timestamptz,
  check (referrer_id <> referred_id)
);
create index referrals_referrer on public.referrals (referrer_id, status);

create table public.referral_rewards (
  id bigint generated always as identity primary key,
  referral_id bigint references public.referrals (id) on delete set null,
  referrer_id uuid not null references auth.users (id) on delete cascade,
  referred_user_id uuid references auth.users (id) on delete set null,
  reward_type text not null default 'FORENSIC_CREDIT',
  reward_percent numeric(5, 2) not null,
  purchase_amount_minor bigint not null check (purchase_amount_minor > 0),
  reward_amount_minor bigint not null check (reward_amount_minor >= 0),
  currency text not null check (currency ~ '^[A-Z]{3}$'),
  status public.referral_reward_status not null default 'PENDING',
  source_transaction text not null unique check (length(source_transaction) between 6 and 200),
  created_at timestamptz not null default now(),
  decided_at timestamptz
);
create index referral_rewards_referrer on public.referral_rewards (referrer_id, status);

-- Private (not exposed via PostgREST): salted email hashes kept after account
-- deletion ONLY to stop deleted/recreated-account referral abuse, and the
-- audit trail.
create table private.referral_secret (
  id boolean primary key default true check (id),
  salt text not null default replace(gen_random_uuid()::text || gen_random_uuid()::text, '-', '')
);
insert into private.referral_secret default values;

create table private.account_email_history (
  email_hash text primary key,
  first_seen_at timestamptz not null default now()
);

create table private.referral_audit (
  id bigint generated always as identity primary key,
  event text not null,
  actor uuid references auth.users (id) on delete set null,
  referral_id bigint,
  detail jsonb not null default '{}',
  created_at timestamptz not null default now()
);
create index referral_audit_actor on private.referral_audit (actor, created_at desc);

alter table public.referral_config enable row level security;
alter table public.referral_codes enable row level security;
alter table public.referrals enable row level security;
alter table public.referral_rewards enable row level security;
alter table private.referral_secret enable row level security;
alter table private.account_email_history enable row level security;
alter table private.referral_audit enable row level security;
-- No policies: clients can neither read nor write these tables directly.
revoke all on public.referral_config, public.referral_codes, public.referrals,
  public.referral_rewards from anon, authenticated;
revoke all on private.referral_secret, private.account_email_history,
  private.referral_audit from anon, authenticated;

-- ---------------------------------------------------------------- helpers
create function private.email_hash(p_email text) returns text
language sql stable security definer set search_path = '' as $$
  select encode(sha256(convert_to((select salt from private.referral_secret)
    || lower(trim(coalesce(p_email, ''))), 'UTF8')), 'hex')
$$;

create function private.referral_log(p_event text, p_actor uuid,
  p_referral bigint default null, p_detail jsonb default '{}')
returns void language sql security definer set search_path = '' as $$
  insert into private.referral_audit (event, actor, referral_id, detail)
  values (p_event, p_actor, p_referral, coalesce(p_detail, '{}'))
$$;

create function private.new_referral_code() returns text
language plpgsql volatile set search_path = '' as $$
declare
  alphabet constant text := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  b bytea := decode(replace(gen_random_uuid()::text, '-', ''), 'hex');
  s text := '';
  i int;
begin
  -- UUIDv4 bytes 0-5 and 10-11 are fully random; 256 % 32 = 0 → uniform.
  foreach i in array array[0, 1, 2, 3, 4, 5, 10, 11] loop
    s := s || substr(alphabet, (get_byte(b, i) % 32) + 1, 1);
  end loop;
  return s;
end $$;

-- Immutability of attribution (even for SECURITY DEFINER code paths).
create function private.referrals_immutable() returns trigger
language plpgsql set search_path = '' as $$
begin
  if new.referrer_id <> old.referrer_id or new.referred_id <> old.referred_id
     or new.code <> old.code or new.created_at <> old.created_at then
    raise exception 'referral attribution is immutable';
  end if;
  if old.status = 'VALID' and new.status = 'PENDING_VERIFICATION' then
    raise exception 'invalid referral transition';
  end if;
  if old.status = 'REVOKED' and new.status <> 'REVOKED' then
    raise exception 'invalid referral transition';
  end if;
  return new;
end $$;
create trigger referrals_immutable before update on public.referrals
  for each row execute function private.referrals_immutable();

-- New account: remember the (salted) email hash; confirmed email: promote a
-- pending referral to VALID.
create function private.on_auth_user_created() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  if new.email is not null then
    insert into private.account_email_history (email_hash, first_seen_at)
    values (private.email_hash(new.email), now())
    on conflict (email_hash) do nothing;
  end if;
  return new;
end $$;
create trigger fe_referral_email_history after insert on auth.users
  for each row execute function private.on_auth_user_created();

create function private.on_auth_user_confirmed() returns trigger
language plpgsql security definer set search_path = '' as $$
declare rid bigint;
begin
  if new.email_confirmed_at is not null and old.email_confirmed_at is null then
    update public.referrals set status = 'VALID', validated_at = now()
     where referred_id = new.id and status = 'PENDING_VERIFICATION'
    returning id into rid;
    if rid is not null then
      perform private.referral_log('referral_validated', new.id, rid);
    end if;
  end if;
  return new;
end $$;
create trigger fe_referral_email_confirmed after update of email_confirmed_at on auth.users
  for each row execute function private.on_auth_user_confirmed();

-- Existing accounts count as "seen" (they are not new referrals).
insert into private.account_email_history (email_hash, first_seen_at)
select private.email_hash(email), coalesce(created_at, now())
  from auth.users where email is not null
on conflict (email_hash) do nothing;

-- ---------------------------------------------------------------- client RPCs
create function private.ensure_referral_code(p_user uuid) returns text
language plpgsql security definer set search_path = '' as $$
declare v text;
begin
  select code into v from public.referral_codes where user_id = p_user;
  if found then return v; end if;
  for i in 1..8 loop
    begin
      insert into public.referral_codes (user_id, code)
      values (p_user, private.new_referral_code())
      on conflict (user_id) do nothing;
      select code into v from public.referral_codes where user_id = p_user;
      return v;
    exception when unique_violation then
      null; -- code collision: retry with a new random code
    end;
  end loop;
  raise exception 'could not allocate referral code';
end $$;

-- Own code + aggregate counts only (no referred identities).
create function public.referral_dashboard() returns jsonb
language plpgsql security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  cfg public.referral_config;
  res jsonb;
begin
  if me is null then raise exception 'not signed in'; end if;
  select * into cfg from public.referral_config;
  select jsonb_build_object(
    'code', private.ensure_referral_code(me),
    'joined', (select count(*) from public.referrals r
                where r.referrer_id = me and r.status <> 'REVOKED'),
    'verified', (select count(*) from public.referrals r
                  where r.referrer_id = me and r.status = 'VALID'),
    'pending', (select count(*) from public.referrals r
                 where r.referrer_id = me and r.status = 'PENDING_VERIFICATION'),
    'credits_earned_minor', (select coalesce(sum(w.reward_amount_minor), 0)
      from public.referral_rewards w where w.referrer_id = me and w.status = 'APPROVED'),
    'credits_pending_minor', (select coalesce(sum(w.reward_amount_minor), 0)
      from public.referral_rewards w where w.referrer_id = me and w.status = 'PENDING'),
    'currency', cfg.currency,
    'reward_percent', cfg.reward_percent,
    'rewards_enabled', cfg.rewards_enabled,
    'has_referrer', exists (select 1 from public.referrals r where r.referred_id = me)
  ) into res;
  return res;
end $$;

-- Returns one of: VALID, PENDING_VERIFICATION, INVALID_CODE, SELF_REFERRAL,
-- ALREADY_ATTRIBUTED, NOT_ELIGIBLE, RATE_LIMITED.
create function public.claim_referral(p_code text) returns text
language plpgsql security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  v_code text := upper(trim(coalesce(p_code, '')));
  cfg public.referral_config;
  v_owner uuid;
  v_created timestamptz;
  v_confirmed timestamptz;
  v_email text;
  v_seen timestamptz;
  v_status public.referral_status;
  rid bigint;
begin
  if me is null then raise exception 'not signed in'; end if;
  select * into cfg from public.referral_config;

  if (select count(*) from private.referral_audit a
       where a.actor = me and a.event like 'claim%'
         and a.created_at > now() - interval '1 hour') >= cfg.max_claim_attempts_per_hour then
    return 'RATE_LIMITED';
  end if;

  if v_code !~ '^[A-HJ-NP-Z2-9]{8}$' then
    perform private.referral_log('claim_invalid_code', me);
    return 'INVALID_CODE';
  end if;
  select user_id into v_owner from public.referral_codes where code = v_code;
  if v_owner is null then
    perform private.referral_log('claim_invalid_code', me);
    return 'INVALID_CODE';
  end if;
  if v_owner = me then
    perform private.referral_log('claim_self', me);
    return 'SELF_REFERRAL';
  end if;
  if exists (select 1 from public.referrals where referred_id = me) then
    perform private.referral_log('claim_duplicate', me);
    return 'ALREADY_ATTRIBUTED';
  end if;
  if exists (select 1 from public.referrals
              where referrer_id = me and referred_id = v_owner) then
    perform private.referral_log('claim_circular', me);
    return 'NOT_ELIGIBLE';
  end if;

  select u.created_at, u.email_confirmed_at, u.email
    into v_created, v_confirmed, v_email
    from auth.users u where u.id = me;
  if v_created is null
     or v_created < now() - make_interval(days => cfg.attribution_window_days) then
    perform private.referral_log('claim_existing_account', me);
    return 'NOT_ELIGIBLE';
  end if;
  select first_seen_at into v_seen from private.account_email_history
   where email_hash = private.email_hash(v_email);
  if v_seen is not null and v_seen < v_created - interval '1 minute' then
    perform private.referral_log('claim_recreated_account', me);
    return 'NOT_ELIGIBLE';
  end if;

  if (select count(*) from public.referrals
       where referrer_id = v_owner and created_at > now() - interval '1 day')
     >= cfg.max_valid_per_referrer_per_day then
    perform private.referral_log('claim_referrer_cap', me);
    return 'RATE_LIMITED';
  end if;

  v_status := case when v_confirmed is not null then 'VALID'
                   else 'PENDING_VERIFICATION' end;
  insert into public.referrals (referrer_id, referred_id, code, status, validated_at)
  values (v_owner, me, v_code, v_status,
          case when v_status = 'VALID' then now() end)
  on conflict (referred_id) do nothing
  returning id into rid;
  if rid is null then
    perform private.referral_log('claim_duplicate', me);
    return 'ALREADY_ATTRIBUTED';
  end if;
  perform private.referral_log('claim_ok', me, rid,
    jsonb_build_object('status', v_status));
  return v_status::text;
end $$;

-- ---------------------------------------------------------------- server-only
-- Called by the server-side purchase verifier (service role) AFTER the store
-- receipt is verified. Idempotent per store transaction id.
-- Returns {status: INVALID|DISABLED|NO_REFERRAL|DUPLICATE|PENDING, ...}.
create function public.award_referral_reward(p_buyer uuid, p_transaction text,
  p_amount_minor bigint, p_currency text)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  cfg public.referral_config;
  r public.referrals;
  v_reward bigint;
  wid bigint;
begin
  if p_buyer is null or p_amount_minor is null or p_amount_minor <= 0
     or coalesce(p_currency, '') !~ '^[A-Z]{3}$'
     or length(coalesce(p_transaction, '')) not between 6 and 200 then
    return jsonb_build_object('status', 'INVALID');
  end if;
  select * into cfg from public.referral_config;
  if not cfg.rewards_enabled then
    return jsonb_build_object('status', 'DISABLED');
  end if;
  select * into r from public.referrals
   where referred_id = p_buyer and status = 'VALID';
  if not found then
    return jsonb_build_object('status', 'NO_REFERRAL');
  end if;
  v_reward := floor(p_amount_minor * cfg.reward_percent / 100);
  insert into public.referral_rewards (referral_id, referrer_id, referred_user_id,
    reward_type, reward_percent, purchase_amount_minor, reward_amount_minor,
    currency, source_transaction)
  values (r.id, r.referrer_id, p_buyer, cfg.reward_type, cfg.reward_percent,
    p_amount_minor, v_reward, p_currency, p_transaction)
  on conflict (source_transaction) do nothing
  returning id into wid;
  if wid is null then
    return jsonb_build_object('status', 'DUPLICATE');
  end if;
  perform private.referral_log('reward_created', null, r.id,
    jsonb_build_object('reward_id', wid, 'amount_minor', v_reward,
      'percent', cfg.reward_percent));
  return jsonb_build_object('status', 'PENDING', 'reward_id', wid,
    'reward_amount_minor', v_reward, 'reward_percent', cfg.reward_percent);
end $$;

-- Approve after the refund window, or reverse on refund/chargeback/fraud.
create function public.set_referral_reward_status(p_transaction text,
  p_status public.referral_reward_status)
returns public.referral_reward_status
language plpgsql security definer set search_path = '' as $$
declare cur public.referral_reward_status; wid bigint;
begin
  select id, status into wid, cur from public.referral_rewards
   where source_transaction = p_transaction for update;
  if wid is null then raise exception 'unknown transaction'; end if;
  if not ((cur = 'PENDING' and p_status in ('APPROVED', 'REVERSED'))
       or (cur = 'APPROVED' and p_status = 'REVERSED')) then
    raise exception 'invalid reward transition';
  end if;
  update public.referral_rewards set status = p_status, decided_at = now()
   where id = wid;
  perform private.referral_log('reward_' || lower(p_status::text), null, null,
    jsonb_build_object('reward_id', wid));
  return p_status;
end $$;

-- ---------------------------------------------------------------- grants
-- Supabase's default privileges grant EXECUTE directly to anon /
-- authenticated / service_role (not only PUBLIC): revoke explicitly.
revoke execute on function public.referral_dashboard() from public, anon, authenticated;
revoke execute on function public.claim_referral(text) from public, anon, authenticated;
revoke execute on function public.award_referral_reward(uuid, text, bigint, text) from public, anon, authenticated;
revoke execute on function public.set_referral_reward_status(text, public.referral_reward_status) from public, anon, authenticated;
revoke execute on function private.email_hash(text) from public, anon, authenticated;
revoke execute on function private.referral_log(text, uuid, bigint, jsonb) from public, anon, authenticated;
revoke execute on function private.new_referral_code() from public, anon, authenticated;
revoke execute on function private.ensure_referral_code(uuid) from public, anon, authenticated;
revoke execute on function private.on_auth_user_created() from public, anon, authenticated;
revoke execute on function private.on_auth_user_confirmed() from public, anon, authenticated;
revoke execute on function private.referrals_immutable() from public, anon, authenticated;
grant execute on function public.referral_dashboard() to authenticated;
grant execute on function public.claim_referral(text) to authenticated;
grant execute on function public.award_referral_reward(uuid, text, bigint, text) to service_role;
grant execute on function public.set_referral_reward_status(text, public.referral_reward_status) to service_role;
