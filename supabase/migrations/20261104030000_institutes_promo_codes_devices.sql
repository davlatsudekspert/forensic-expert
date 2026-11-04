-- Institut kodi / sovg‘a promokod / qurilmalar limiti (egasi qarori 2026-11-04,
-- docs/DECISIONS.md «Institut/promokod: yakuniy loyiha»). Faqat QO‘SHILADI:
-- mavjud plans / admin_set_plan / my_plan hisoblash mantig‘i o‘zgarmaydi
-- (my_plan faqat qo‘shimcha `label` kalitini qaytaradi — eski ilovalar uni e’tiborsiz qoldiradi).
--
-- * public.institutes: shartnoma ma’lumotlari (nomi, rekvizit, o‘rinlar, muddat, narx). Faqat admin RPC.
-- * public.promo_codes: bir martalik kod (institut yoki sovg‘a). Kodni foydalanuvchi Profilda kiritadi.
-- * Kod qabul qilinsa: Ustoz Pro (plan 'teacher', source 'admin') institut muddati tugaguncha
--   (yoki sovg‘a kunlari), plans.note = «institut: <nomi>» / «sovg‘a: <kim bergan>».
-- * public.account_devices: bitta hisobdan 3 tagacha qurilma (faqat Pro/institut hisoblari uchun majburiy).
--
-- Rollback:
--   drop function if exists public.admin_institute_create(text,int,int,numeric,timestamptz,text,date,text,text,text,text,text,text,text),
--     public.admin_list_institutes(), public.admin_institute_codes(uuid), public.admin_institute_get(uuid),
--     public.admin_gift_codes_create(text,int,int,text), public.admin_revoke_code(text),
--     public.redeem_promo_code(text), public.register_device(text,text), public.my_devices(),
--     public.remove_my_device(text), private.grant_admin_plan(uuid,text,timestamptz,text,uuid),
--     private.new_promo_code();
--   drop table if exists private.promo_attempts, public.account_devices, public.promo_codes, public.institutes;
--   (my_plan: oldingi ta’rifni qayta tiklang — `label` kalitini olib tashlang.)

create table public.institutes (
  id uuid primary key default gen_random_uuid(),
  name text not null check (length(name) between 2 and 200),
  address text check (length(address) <= 300),
  stir text check (length(stir) <= 30),
  bank text check (length(bank) <= 120),
  account text check (length(account) <= 40),
  mfo text check (length(mfo) <= 10),
  director text check (length(director) <= 120),
  phone text check (length(phone) <= 40),
  contract_no text check (length(contract_no) <= 40),
  contract_date date,
  seats int not null check (seats between 1 and 500),
  months int check (months between 1 and 60),
  price_per_seat numeric check (price_per_seat >= 0),
  term_start timestamptz not null default now(),
  term_end timestamptz not null,
  note text check (length(note) <= 300),
  created_by uuid,
  created_at timestamptz not null default now()
);

create table public.promo_codes (
  id bigint generated always as identity primary key,
  code text not null unique check (code ~ '^[A-Z0-9]{10}$'),
  kind text not null check (kind in ('institute', 'gift')),
  institute_id uuid references public.institutes (id) on delete cascade,
  gift_from text check (length(gift_from) <= 100),
  plan text not null default 'teacher' check (plan in ('teacher', 'expert', 'premium', 'student')),
  days int check (days between 1 and 1100),
  redeemed_by uuid references auth.users (id) on delete set null,
  redeemed_at timestamptz,
  revoked boolean not null default false,
  created_by uuid,
  created_at timestamptz not null default now(),
  check ((kind = 'institute' and institute_id is not null)
      or (kind = 'gift' and gift_from is not null and days is not null))
);
create index promo_codes_institute_idx on public.promo_codes (institute_id);

create table public.account_devices (
  user_id uuid not null references auth.users (id) on delete cascade,
  device_hash text not null check (device_hash ~ '^[0-9a-f]{64}$'),
  label text check (length(label) <= 60),
  first_seen timestamptz not null default now(),
  last_seen timestamptz not null default now(),
  primary key (user_id, device_hash)
);

create table private.promo_attempts (
  id bigint generated always as identity primary key,
  user_id uuid not null,
  at timestamptz not null default now()
);
create index promo_attempts_user_idx on private.promo_attempts (user_id, at);

alter table public.institutes enable row level security;
alter table public.promo_codes enable row level security;
alter table public.account_devices enable row level security;
alter table private.promo_attempts enable row level security;
revoke all on public.institutes, public.promo_codes, public.account_devices from anon, authenticated;
revoke all on private.promo_attempts from anon, authenticated;

-- ------------------------------------------------------------ yordamchilar
create function private.new_promo_code() returns text
language sql volatile security definer set search_path = '' as $$
  select upper(substr(replace(gen_random_uuid()::text, '-', ''), 1, 10));
$$;

-- admin_set_plan ning «berish» tarmog‘i (guard’siz; faqat boshqa SECURITY DEFINER funksiyalar chaqiradi).
create function private.grant_admin_plan(p_target uuid, p_plan text, p_until timestamptz, p_note text, p_actor uuid)
returns void language plpgsql security definer set search_path = '' as $$
declare r public.plans; store_active boolean; keep_existing boolean;
begin
  select * into r from public.plans where user_id = p_target for update;
  store_active := found and r.source = 'store' and (r.expires_at is null or r.expires_at > now());
  keep_existing := found and r.source = 'admin' and r.plan = p_plan
    and (r.expires_at is null or r.expires_at > now())
    and (r.expires_at is null or (p_until is not null and r.expires_at >= p_until));
  if keep_existing then
    null; -- mavjud admin berilgani uzoqroq (yoki cheksiz): qisqartirmaymiz
  elsif store_active then
    if p_until is null or r.expires_at is null or p_until > r.expires_at then
      update public.plans set alt_plan = p_plan, alt_source = 'admin', alt_expires_at = p_until,
        updated_at = now() where user_id = p_target;
    end if;
  else
    insert into public.plans (user_id, plan, source, platform, expires_at, auto_renew, note, updated_at)
    values (p_target, p_plan, 'admin', 'other', p_until, false, left(p_note, 200), now())
    on conflict (user_id) do update
      set plan = excluded.plan, source = 'admin', platform = 'other', product_id = null,
          original_transaction_id = null, started_at = now(), expires_at = excluded.expires_at,
          auto_renew = false, note = excluded.note, alt_plan = null, alt_source = null,
          alt_expires_at = null, updated_at = now();
  end if;
  if p_plan = 'teacher' then
    insert into public.account_roles (user_id, role, granted_by)
    values (p_target, 'teacher', case when p_target <> p_actor then p_actor end)
    on conflict (user_id, role) do nothing;
  end if;
end $$;

-- ------------------------------------------------------------ admin RPC
create function public.admin_institute_create(
  p_name text, p_seats int, p_months int, p_price numeric, p_term_start timestamptz,
  p_contract_no text, p_contract_date date, p_director text, p_phone text,
  p_stir text, p_bank text, p_account text, p_mfo text, p_address text)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare me uuid := private.admin_guard(); v_id uuid; v_start timestamptz; v_codes text[] := '{}'; v_code text; i int := 0;
begin
  if p_name is null or length(trim(p_name)) < 2 or p_seats is null or p_seats not between 1 and 500
     or p_months is null or p_months not between 1 and 60 then
    return jsonb_build_object('result', 'INVALID');
  end if;
  v_start := coalesce(p_term_start, now());
  insert into public.institutes (name, address, stir, bank, account, mfo, director, phone, contract_no,
      contract_date, seats, months, price_per_seat, term_start, term_end, created_by)
  values (trim(p_name), p_address, p_stir, p_bank, p_account, p_mfo, p_director, p_phone, p_contract_no,
      p_contract_date, p_seats, p_months, p_price, v_start, v_start + make_interval(months => p_months), me)
  returning id into v_id;
  while i < p_seats loop
    v_code := private.new_promo_code();
    begin
      insert into public.promo_codes (code, kind, institute_id, plan, created_by)
      values (v_code, 'institute', v_id, 'teacher', me);
      v_codes := v_codes || v_code; i := i + 1;
    exception when unique_violation then null;
    end;
  end loop;
  perform private.admin_log(me, 'INSTITUTE_CREATE', 'institute', v_id::text,
    jsonb_build_object('name', trim(p_name), 'seats', p_seats, 'months', p_months));
  return jsonb_build_object('result', 'OK', 'institute_id', v_id, 'codes', to_jsonb(v_codes));
end $$;

create function public.admin_list_institutes() returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare me uuid := private.admin_guard();
begin
  return coalesce((select jsonb_agg(jsonb_build_object(
      'id', i.id, 'name', i.name, 'seats', i.seats, 'term_start', i.term_start, 'term_end', i.term_end,
      'contract_no', i.contract_no, 'price_per_seat', i.price_per_seat,
      'redeemed', (select count(*) from public.promo_codes c where c.institute_id = i.id and c.redeemed_by is not null),
      'revoked', (select count(*) from public.promo_codes c where c.institute_id = i.id and c.revoked))
      order by i.created_at desc) from public.institutes i), '[]'::jsonb);
end $$;

create function public.admin_institute_get(p_id uuid) returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare me uuid := private.admin_guard();
begin
  return (select to_jsonb(i) from public.institutes i where i.id = p_id);
end $$;

create function public.admin_institute_codes(p_id uuid) returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare me uuid := private.admin_guard();
begin
  return coalesce((select jsonb_agg(jsonb_build_object(
      'n', t.rn, 'code', t.code, 'revoked', t.revoked, 'redeemed_at', t.redeemed_at, 'email', t.email)
      order by t.rn) from (
        select row_number() over (order by c.id) rn, c.code, c.revoked, c.redeemed_at, u.email
        from public.promo_codes c left join auth.users u on u.id = c.redeemed_by
        where c.institute_id = p_id) t), '[]'::jsonb);
end $$;

create function public.admin_gift_codes_create(p_from text, p_count int, p_days int, p_plan text default 'teacher')
returns jsonb language plpgsql security definer set search_path = '' as $$
declare me uuid := private.admin_guard(); v_codes text[] := '{}'; v_code text; i int := 0;
begin
  if p_from is null or length(trim(p_from)) < 2 or p_count is null or p_count not between 1 and 50
     or p_days is null or p_days not between 1 and 1100 or p_plan not in ('teacher', 'expert', 'premium', 'student') then
    return jsonb_build_object('result', 'INVALID');
  end if;
  while i < p_count loop
    v_code := private.new_promo_code();
    begin
      insert into public.promo_codes (code, kind, gift_from, plan, days, created_by)
      values (v_code, 'gift', trim(p_from), p_plan, p_days, me);
      v_codes := v_codes || v_code; i := i + 1;
    exception when unique_violation then null;
    end;
  end loop;
  perform private.admin_log(me, 'GIFT_CODES_CREATE', 'promo', trim(p_from),
    jsonb_build_object('count', p_count, 'days', p_days, 'plan', p_plan));
  return jsonb_build_object('result', 'OK', 'codes', to_jsonb(v_codes));
end $$;

create function public.admin_revoke_code(p_code text) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare me uuid := private.admin_guard(); n int;
begin
  update public.promo_codes set revoked = true
    where code = upper(trim(p_code)) and redeemed_by is null;
  get diagnostics n = row_count;
  perform private.admin_log(me, 'PROMO_REVOKE', 'promo', upper(trim(p_code)), jsonb_build_object('n', n));
  return jsonb_build_object('result', case when n > 0 then 'REVOKED' else 'NOT_FOUND_OR_USED' end);
end $$;

-- ------------------------------------------------------------ foydalanuvchi RPC
create function public.redeem_promo_code(p_code text) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare me uuid := auth.uid(); c public.promo_codes; i public.institutes; v_until timestamptz;
  v_label text; fails int; v_code text := upper(regexp_replace(coalesce(p_code, ''), '[^A-Za-z0-9]', '', 'g'));
begin
  if me is null then return jsonb_build_object('result', 'NOT_SIGNED'); end if;
  select count(*) into fails from private.promo_attempts where user_id = me and at > now() - interval '1 hour';
  if fails >= 10 then return jsonb_build_object('result', 'TOO_MANY'); end if;
  select * into c from public.promo_codes where code = v_code for update;
  if not found then
    insert into private.promo_attempts (user_id) values (me);
    return jsonb_build_object('result', 'INVALID');
  end if;
  if c.revoked then return jsonb_build_object('result', 'REVOKED'); end if;
  if c.redeemed_by is not null then
    return jsonb_build_object('result', case when c.redeemed_by = me then 'ALREADY_YOURS' else 'USED' end);
  end if;
  if c.kind = 'institute' then
    select * into i from public.institutes where id = c.institute_id;
    v_until := i.term_end; v_label := 'institut: ' || i.name;
    if v_until <= now() then return jsonb_build_object('result', 'EXPIRED'); end if;
  else
    v_until := now() + make_interval(days => c.days); v_label := 'sovg‘a: ' || c.gift_from;
  end if;
  perform private.grant_admin_plan(me, c.plan, v_until, v_label, me);
  update public.promo_codes set redeemed_by = me, redeemed_at = now() where id = c.id;
  perform private.plan_event(me, me, 'PROMO_REDEEMED', c.plan, 'admin', v_until,
    jsonb_build_object('kind', c.kind, 'code_id', c.id));
  return jsonb_build_object('result', 'OK', 'kind', c.kind, 'label', v_label, 'until', v_until, 'plan', c.plan);
end $$;

-- my_plan: eski maydonlar o‘zgarmaydi; `label` qo‘shildi (institut/sovg‘a yozuvi).
create or replace function public.my_plan(p_device_hash text default null) returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare me uuid := auth.uid(); r public.plans; eff jsonb; avail boolean;
begin
  if me is null then raise exception 'not signed in'; end if;
  select * into r from public.plans where user_id = me;
  eff := case when found then private.plan_effective(r) else null end;
  avail := p_device_hash is not null and p_device_hash ~ '^[0-9a-f]{64}$'
    and not exists (select 1 from public.trial_devices d
                    where d.device_hash = p_device_hash or d.user_id = me);
  return jsonb_build_object(
    'plan', eff->>'plan',
    'source', eff->>'source',
    'expires_at', eff->'expires_at',
    'auto_renew', coalesce((eff->>'auto_renew')::boolean, false),
    'product_id', eff->>'product_id',
    'trial_available', avail,
    'label', case when eff->>'source' = 'admin' and r.note ~ '^(institut|sovg‘a): ' then r.note end);
end $$;

-- ------------------------------------------------------------ qurilmalar (3 ta)
create function public.register_device(p_device_hash text, p_label text default null) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare me uuid := auth.uid(); r public.plans; eff jsonb; n int; enforce boolean;
begin
  if me is null then return jsonb_build_object('ok', true, 'limit', 3); end if;
  if p_device_hash is null or p_device_hash !~ '^[0-9a-f]{64}$' then
    return jsonb_build_object('ok', true, 'limit', 3);
  end if;
  select * into r from public.plans where user_id = me;
  eff := case when found then private.plan_effective(r) else null end;
  enforce := eff is not null and (eff->>'plan') in ('teacher', 'expert', 'premium');
  if exists (select 1 from public.account_devices where user_id = me and device_hash = p_device_hash) then
    update public.account_devices set last_seen = now(), label = coalesce(left(p_label, 60), label)
      where user_id = me and device_hash = p_device_hash;
    return jsonb_build_object('ok', true, 'limit', 3);
  end if;
  select count(*) into n from public.account_devices where user_id = me;
  if enforce and n >= 3 then
    return jsonb_build_object('ok', false, 'limit', 3, 'devices', (
      select coalesce(jsonb_agg(jsonb_build_object('hash', device_hash, 'label', label, 'last_seen', last_seen)
        order by last_seen desc), '[]'::jsonb) from public.account_devices where user_id = me));
  end if;
  insert into public.account_devices (user_id, device_hash, label) values (me, p_device_hash, left(p_label, 60));
  return jsonb_build_object('ok', true, 'limit', 3);
end $$;

create function public.my_devices() returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare me uuid := auth.uid();
begin
  if me is null then return '[]'::jsonb; end if;
  return coalesce((select jsonb_agg(jsonb_build_object('hash', device_hash, 'label', label, 'last_seen', last_seen)
    order by last_seen desc) from public.account_devices where user_id = me), '[]'::jsonb);
end $$;

create function public.remove_my_device(p_device_hash text) returns void
language plpgsql security definer set search_path = '' as $$
begin
  if auth.uid() is null then return; end if;
  delete from public.account_devices where user_id = auth.uid() and device_hash = p_device_hash;
end $$;

revoke all on function public.admin_institute_create(text,int,int,numeric,timestamptz,text,date,text,text,text,text,text,text,text),
  public.admin_list_institutes(), public.admin_institute_get(uuid), public.admin_institute_codes(uuid),
  public.admin_gift_codes_create(text,int,int,text), public.admin_revoke_code(text),
  public.redeem_promo_code(text), public.register_device(text,text), public.my_devices(),
  public.remove_my_device(text) from public, anon;
grant execute on function public.admin_institute_create(text,int,int,numeric,timestamptz,text,date,text,text,text,text,text,text,text),
  public.admin_list_institutes(), public.admin_institute_get(uuid), public.admin_institute_codes(uuid),
  public.admin_gift_codes_create(text,int,int,text), public.admin_revoke_code(text),
  public.redeem_promo_code(text), public.register_device(text,text), public.my_devices(),
  public.remove_my_device(text) to authenticated;
revoke all on function private.new_promo_code(), private.grant_admin_plan(uuid,text,timestamptz,text,uuid) from public, anon, authenticated;
