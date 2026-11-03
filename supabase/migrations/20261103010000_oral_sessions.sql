-- «Guruh og‘zaki imtihoni» (egasi qarori, 2026-11-03).
-- Ustoz mavzu(lar)ni tanlab N ta bilet tuzadi (savollar ustoz ilovasida dars
-- slaydlaridan; javob kaliti SERVERGA YUBORILMAYDI — faqat ustoz telefonida).
-- Doskada QR/6 xonali kod; talaba ismini yozib qo‘shiladi va tasodifiy bo‘sh
-- biletni oladi (savollarini darhol ko‘radi, ixtiyoriy tayyorlanish vaqti),
-- «Javobga tayyorman» bosadi → ustoz navbatdan tanlaydi, eshitadi, har savolga
-- 0–20 ball qo‘yadi. Talaba faqat O‘Z balini ko‘radi; boshqa talabalar va
-- doskada ballar yo‘q.
--
-- Xavfsizlik: hamma jadvalda RLS yoqilgan, jadval huquqi yo‘q; kirish faqat
-- SECURITY DEFINER RPC orqali (class_* bilan bir xil tartib). Ustoz roli —
-- private.class_is_teacher. Qo‘shilish urinishlari — private.class_join_bump.

create table public.oral_sessions (
  id uuid primary key default gen_random_uuid(),
  teacher_id uuid not null references auth.users (id) on delete cascade,
  code text not null unique check (code ~ '^[0-9]{6}$'),
  title text not null default '' check (char_length(title) <= 300),
  -- {ticket_count, prep_seconds}
  settings jsonb not null,
  status text not null default 'open' check (status in ('open', 'finished')),
  created_at timestamptz not null default now(),
  finished_at timestamptz,
  -- Tugagach 30 kun (private.oral_cleanup o‘chiradi).
  expires_at timestamptz
);
alter table public.oral_sessions enable row level security;
create index oral_sessions_teacher on public.oral_sessions (teacher_id, created_at desc);
create index oral_sessions_expiry on public.oral_sessions (expires_at)
  where expires_at is not null;

-- Biletlar: [{id, text}] (id — dars slaydi kaliti, text — savol matni).
create table public.oral_tickets (
  session_id uuid not null references public.oral_sessions (id) on delete cascade,
  no int not null check (no between 1 and 200),
  questions jsonb not null check (jsonb_typeof(questions) = 'array'
    and jsonb_array_length(questions) between 1 and 10),
  primary key (session_id, no)
);
alter table public.oral_tickets enable row level security;

create table public.oral_participants (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references public.oral_sessions (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  name text not null check (char_length(name) between 2 and 40),
  ticket_no int not null,
  joined_at timestamptz not null default now(),
  ready_at timestamptz,
  called_at timestamptz,
  -- Har savolga 0..20; faqat ustoz RPC orqali yozadi.
  scores smallint[],
  graded_at timestamptz,
  kicked_at timestamptz,
  -- Ilovadan chiqish (boshqa ilova/AI): har chiqish — bitta hisob (anti-cheat).
  leave_count int not null default 0 check (leave_count >= 0),
  last_left_at timestamptz,
  unique (session_id, user_id),
  foreign key (session_id, ticket_no) references public.oral_tickets (session_id, no)
    on delete cascade
);
alter table public.oral_participants enable row level security;
-- Bitta bilet — bitta (chetlatilmagan) talaba.
create unique index oral_participants_ticket
  on public.oral_participants (session_id, ticket_no) where kicked_at is null;

revoke all on public.oral_sessions, public.oral_tickets, public.oral_participants
  from anon, authenticated;

-- --------------------------------------------------------------- helpers

-- Ism: 2..40 belgi; taqiqlangan so‘z va belgilar — class_nick_check qoidasi
-- (u 20 belgigacha tekshiradi: boshi va oxiri alohida — 40 gacha to‘liq qoplaydi).
create function private.oral_name_check(p text) returns text
language plpgsql immutable set search_path = '' as $$
declare
  t text := regexp_replace(btrim(coalesce(p, '')), '\s+', ' ', 'g');
  a text;
  b text;
begin
  if char_length(t) < 2 or char_length(t) > 40 then return 'length'; end if;
  a := private.class_nick_check(left(t, 20));
  if a <> 'ok' then return a; end if;
  if char_length(t) > 20 then
    b := private.class_nick_check(right(t, 20));
    if b <> 'ok' then return b; end if;
  end if;
  return 'ok';
end $$;

create function private.oral_owned(p_session uuid) returns public.oral_sessions
language plpgsql security definer set search_path = '' as $$
declare s public.oral_sessions;
begin
  select * into s from public.oral_sessions where id = p_session;
  if not found or s.teacher_id is distinct from auth.uid() then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  return s;
end $$;

create function private.oral_session_json(s public.oral_sessions) returns jsonb
language sql stable security definer set search_path = '' as $$
  select jsonb_build_object('id', s.id, 'code', s.code, 'title', s.title,
    'status', s.status, 'ticket_count', (s.settings ->> 'ticket_count')::int,
    'prep_seconds', coalesce((s.settings ->> 'prep_seconds')::int, 0),
    'created_at', s.created_at, 'finished_at', s.finished_at)
$$;

-- Talabaga: biletning faqat savol matni (id ham — ustoz kalitini moslash uchun
-- kerak emas, lekin yashirin ma’lumot ham emas).
create function private.oral_ticket_questions(p_session uuid, p_no int) returns jsonb
language sql stable security definer set search_path = '' as $$
  select coalesce((select jsonb_agg(jsonb_build_object('id', q ->> 'id', 'text', q ->> 'text')
                                    order by ord)
                   from public.oral_tickets t,
                        jsonb_array_elements(t.questions) with ordinality as e(q, ord)
                   where t.session_id = p_session and t.no = p_no), '[]'::jsonb)
$$;

create function private.oral_cleanup() returns int
language plpgsql security definer set search_path = '' as $$
declare n int;
begin
  delete from public.oral_sessions where expires_at is not null and expires_at < now();
  get diagnostics n = row_count;
  -- Tashlab ketilgan ochiq sessiyalar: 2 kundan keyin yopiladi (30 kun saqlanadi).
  update public.oral_sessions set status = 'finished', finished_at = now(),
         expires_at = now() + interval '30 days'
   where status = 'open' and created_at < now() - interval '2 days';
  return n;
end $$;

-- --------------------------------------------------------------- teacher

-- p_tickets: [[{id, text}, …], …] — har biri 1..10 savol, jami 1..200 bilet.
create function public.oral_create_session(p_title text, p_tickets jsonb,
  p_prep_seconds int) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  v_code text;
  v_id uuid;
  v_n int;
  tk jsonb;
  q jsonb;
  i int := 0;
  tries int := 0;
begin
  if me is null or not private.class_is_teacher(me) then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  perform private.oral_cleanup();
  if p_tickets is null or jsonb_typeof(p_tickets) <> 'array' then
    return jsonb_build_object('ok', false, 'error', 'invalid_settings');
  end if;
  v_n := jsonb_array_length(p_tickets);
  if v_n not between 1 and 200
     or p_prep_seconds is null or p_prep_seconds not between 0 and 3600
     or char_length(coalesce(p_title, '')) > 300 then
    return jsonb_build_object('ok', false, 'error', 'invalid_settings');
  end if;
  for tk in select value from jsonb_array_elements(p_tickets) loop
    if jsonb_typeof(tk) <> 'array' or jsonb_array_length(tk) not between 1 and 10 then
      return jsonb_build_object('ok', false, 'error', 'invalid_ticket');
    end if;
    for q in select value from jsonb_array_elements(tk) loop
      if jsonb_typeof(q) <> 'object'
         or char_length(coalesce(q ->> 'id', '')) not between 1 and 160
         or char_length(coalesce(q ->> 'text', '')) not between 1 and 500 then
        return jsonb_build_object('ok', false, 'error', 'invalid_ticket');
      end if;
    end loop;
  end loop;
  if (select count(*) from public.oral_sessions s
      where s.teacher_id = me and s.status = 'open') >= 10 then
    return jsonb_build_object('ok', false, 'error', 'too_many_sessions');
  end if;
  -- 6 xonali kod (CSPRNG); «Guruh testi» kodlari bilan ham to‘qnashmaydi.
  loop
    v_code := lpad((('x' || substr(replace(gen_random_uuid()::text, '-', ''), 1, 8))::bit(32)::bigint
                    % 1000000)::text, 6, '0');
    exit when not exists (select 1 from public.oral_sessions where code = v_code)
          and not exists (select 1 from public.class_sessions where code = v_code);
    tries := tries + 1;
    if tries > 30 then
      return jsonb_build_object('ok', false, 'error', 'try_again');
    end if;
  end loop;
  insert into public.oral_sessions (teacher_id, code, title, settings)
  values (me, v_code, coalesce(btrim(p_title), ''),
          jsonb_build_object('ticket_count', v_n, 'prep_seconds', p_prep_seconds))
  returning id into v_id;
  for tk in select value from jsonb_array_elements(p_tickets) loop
    i := i + 1;
    insert into public.oral_tickets (session_id, no, questions)
    select v_id, i, jsonb_agg(jsonb_build_object('id', x ->> 'id', 'text', btrim(x ->> 'text'))
                              order by ord)
      from jsonb_array_elements(tk) with ordinality as e(x, ord);
  end loop;
  return jsonb_build_object('ok', true,
    'session', private.oral_session_json((select s from public.oral_sessions s where s.id = v_id)));
end $$;

create function public.oral_my_sessions() returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare me uuid := auth.uid();
begin
  if me is null then raise exception 'forbidden' using errcode = '42501'; end if;
  return coalesce((select jsonb_agg(private.oral_session_json(s)
      || jsonb_build_object(
           'joined', (select count(*) from public.oral_participants p
                      where p.session_id = s.id and p.kicked_at is null),
           'graded', (select count(*) from public.oral_participants p
                      where p.session_id = s.id and p.kicked_at is null
                        and p.graded_at is not null))
      order by s.created_at desc)
    from public.oral_sessions s where s.teacher_id = me), '[]'::jsonb);
end $$;

-- Ustoz: sessiya, biletlar (id + matn) va talabalar (ism, bilet, holat, ball).
create function public.oral_teacher_state(p_session uuid) returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare s public.oral_sessions;
begin
  s := private.oral_owned(p_session);
  return jsonb_build_object('ok', true,
    'session', private.oral_session_json(s),
    'tickets', coalesce((select jsonb_agg(jsonb_build_object('no', t.no,
                 'questions', private.oral_ticket_questions(s.id, t.no)) order by t.no)
               from public.oral_tickets t where t.session_id = s.id), '[]'::jsonb),
    'participants', coalesce((select jsonb_agg(jsonb_build_object(
                 'id', p.id, 'name', p.name, 'ticket_no', p.ticket_no,
                 'joined_at', p.joined_at, 'ready_at', p.ready_at,
                 'called_at', p.called_at, 'scores', to_jsonb(p.scores),
                 'graded_at', p.graded_at, 'leave_count', p.leave_count,
                 'last_left_at', p.last_left_at)
               order by (p.graded_at is not null), p.ready_at nulls last, p.joined_at)
               from public.oral_participants p
               where p.session_id = s.id and p.kicked_at is null), '[]'::jsonb));
end $$;

-- Ustoz talabani chaqirdi (talaba telefonida «Navbatingiz keldi»).
create function public.oral_call(p_session uuid, p_participant uuid) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare s public.oral_sessions;
begin
  s := private.oral_owned(p_session);
  update public.oral_participants set called_at = coalesce(called_at, now())
   where id = p_participant and session_id = s.id and kicked_at is null;
  if not found then return jsonb_build_object('ok', false, 'error', 'not_found'); end if;
  return jsonb_build_object('ok', true);
end $$;

-- Ball: har savolga 0..20, soni bilet savollari soniga teng. Qayta baholash mumkin.
create function public.oral_grade(p_session uuid, p_participant uuid, p_scores int[])
returns jsonb
language plpgsql security definer set search_path = '' as $$
declare
  s public.oral_sessions;
  p public.oral_participants;
  v_n int;
begin
  s := private.oral_owned(p_session);
  select * into p from public.oral_participants
   where id = p_participant and session_id = s.id and kicked_at is null for update;
  if not found then return jsonb_build_object('ok', false, 'error', 'not_found'); end if;
  select jsonb_array_length(t.questions) into v_n from public.oral_tickets t
   where t.session_id = s.id and t.no = p.ticket_no;
  if p_scores is null or coalesce(array_length(p_scores, 1), 0) <> v_n
     or exists (select 1 from unnest(p_scores) x where x is null or x not between 0 and 20) then
    return jsonb_build_object('ok', false, 'error', 'invalid_scores');
  end if;
  update public.oral_participants
     set scores = p_scores::smallint[], graded_at = now(),
         called_at = coalesce(called_at, now())
   where id = p.id;
  return jsonb_build_object('ok', true,
    'total', (select sum(x) from unnest(p_scores) x));
end $$;

create function public.oral_kick(p_session uuid, p_participant uuid) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare s public.oral_sessions;
begin
  s := private.oral_owned(p_session);
  update public.oral_participants set kicked_at = now()
   where id = p_participant and session_id = s.id and kicked_at is null;
  if not found then return jsonb_build_object('ok', false, 'error', 'not_found'); end if;
  return jsonb_build_object('ok', true);
end $$;

create function public.oral_finish(p_session uuid) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare s public.oral_sessions;
begin
  s := private.oral_owned(p_session);
  update public.oral_sessions set status = 'finished',
         finished_at = coalesce(finished_at, now()),
         expires_at = coalesce(expires_at, now() + interval '30 days')
   where id = s.id;
  return jsonb_build_object('ok', true);
end $$;

-- --------------------------------------------------------------- student

create function public.oral_join_session(p_code text, p_name text) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  v_code text := regexp_replace(coalesce(p_code, ''), '[\s-]', '', 'g');
  v_name text := regexp_replace(btrim(coalesce(p_name, '')), '\s+', ' ', 'g');
  s public.oral_sessions;
  part public.oral_participants;
  chk text;
  v_no int;
begin
  if me is null then raise exception 'forbidden' using errcode = '42501'; end if;
  if not private.class_join_bump(me) then
    return jsonb_build_object('ok', false, 'error', 'rate_limited');
  end if;
  if v_code !~ '^[0-9]{6}$' then
    return jsonb_build_object('ok', false, 'error', 'bad_code');
  end if;
  select * into s from public.oral_sessions where code = v_code for update;
  if not found then return jsonb_build_object('ok', false, 'error', 'not_found'); end if;
  if s.teacher_id = me then
    return jsonb_build_object('ok', false, 'error', 'own_session');
  end if;
  select * into part from public.oral_participants
   where session_id = s.id and user_id = me;
  if found then
    if part.kicked_at is not null then
      return jsonb_build_object('ok', false, 'error', 'kicked');
    end if;
    -- Qayta kirish (ulanish uzilgan): bilet va ism o‘zgarmaydi.
    return jsonb_build_object('ok', true, 'participant_id', part.id,
      'session', private.oral_session_json(s));
  end if;
  if s.status <> 'open' then
    return jsonb_build_object('ok', false, 'error', 'finished');
  end if;
  chk := private.oral_name_check(v_name);
  if chk <> 'ok' then
    return jsonb_build_object('ok', false,
      'error', case chk when 'blocked' then 'name_blocked'
                        when 'chars' then 'name_chars' else 'name_length' end);
  end if;
  -- Tasodifiy bo‘sh bilet.
  select t.no into v_no from public.oral_tickets t
   where t.session_id = s.id
     and not exists (select 1 from public.oral_participants p
                     where p.session_id = s.id and p.ticket_no = t.no
                       and p.kicked_at is null)
   order by random() limit 1;
  if v_no is null then return jsonb_build_object('ok', false, 'error', 'full'); end if;
  insert into public.oral_participants (session_id, user_id, name, ticket_no)
  values (s.id, me, v_name, v_no) returning * into part;
  return jsonb_build_object('ok', true, 'participant_id', part.id,
    'session', private.oral_session_json(s));
end $$;

-- Talaba: o‘z bileti, holati va (baholangan bo‘lsa) o‘z bali. Boshqa talabalar yo‘q.
create function public.oral_my_state(p_session uuid) returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  s public.oral_sessions;
  p public.oral_participants;
begin
  if me is null then raise exception 'forbidden' using errcode = '42501'; end if;
  select * into s from public.oral_sessions where id = p_session;
  if not found then return jsonb_build_object('ok', false, 'error', 'not_found'); end if;
  select * into p from public.oral_participants
   where session_id = s.id and user_id = me and kicked_at is null;
  if not found then return jsonb_build_object('ok', false, 'error', 'not_joined'); end if;
  return jsonb_build_object('ok', true,
    'session', private.oral_session_json(s),
    'name', p.name, 'ticket_no', p.ticket_no,
    'questions', private.oral_ticket_questions(s.id, p.ticket_no),
    'joined_at', p.joined_at, 'ready_at', p.ready_at, 'called_at', p.called_at,
    'graded_at', p.graded_at, 'leave_count', p.leave_count,
    'scores', case when p.graded_at is null then null else to_jsonb(p.scores) end,
    'total', case when p.graded_at is null then null
                  else (select sum(x) from unnest(p.scores) x) end,
    'server_now', now());
end $$;

create function public.oral_ready(p_session uuid) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare me uuid := auth.uid();
begin
  if me is null then raise exception 'forbidden' using errcode = '42501'; end if;
  update public.oral_participants p set ready_at = coalesce(p.ready_at, now())
   where p.session_id = p_session and p.user_id = me and p.kicked_at is null
     and p.graded_at is null
     and exists (select 1 from public.oral_sessions s
                 where s.id = p_session and s.status = 'open');
  if not found then return jsonb_build_object('ok', false, 'error', 'not_allowed'); end if;
  return jsonb_build_object('ok', true);
end $$;

-- Talaba bilet ekranidan chiqdi (ilova fonga o‘tdi). Faqat ochiq sessiyada,
-- baholanmagan va chetlatilmagan talaba uchun hisoblanadi.
create function public.oral_report_leave(p_session uuid) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  v_count int;
begin
  if me is null then raise exception 'forbidden' using errcode = '42501'; end if;
  update public.oral_participants p
     set leave_count = p.leave_count + 1, last_left_at = now()
   where p.session_id = p_session and p.user_id = me and p.kicked_at is null
     and p.graded_at is null
     and exists (select 1 from public.oral_sessions s
                 where s.id = p_session and s.status = 'open')
  returning p.leave_count into v_count;
  if not found then return jsonb_build_object('ok', false, 'error', 'not_allowed'); end if;
  return jsonb_build_object('ok', true, 'leave_count', v_count);
end $$;

-- --------------------------------------------------------------- grants

revoke execute on function private.oral_name_check(text) from public, anon, authenticated;
revoke execute on function private.oral_owned(uuid) from public, anon, authenticated;
revoke execute on function private.oral_session_json(public.oral_sessions) from public, anon, authenticated;
revoke execute on function private.oral_ticket_questions(uuid, int) from public, anon, authenticated;
revoke execute on function private.oral_cleanup() from public, anon, authenticated;

revoke execute on function public.oral_create_session(text, jsonb, int) from public, anon;
revoke execute on function public.oral_my_sessions() from public, anon;
revoke execute on function public.oral_teacher_state(uuid) from public, anon;
revoke execute on function public.oral_call(uuid, uuid) from public, anon;
revoke execute on function public.oral_grade(uuid, uuid, int[]) from public, anon;
revoke execute on function public.oral_kick(uuid, uuid) from public, anon;
revoke execute on function public.oral_finish(uuid) from public, anon;
revoke execute on function public.oral_join_session(text, text) from public, anon;
revoke execute on function public.oral_my_state(uuid) from public, anon;
revoke execute on function public.oral_ready(uuid) from public, anon;
revoke execute on function public.oral_report_leave(uuid) from public, anon;

grant execute on function public.oral_create_session(text, jsonb, int),
  public.oral_my_sessions(), public.oral_teacher_state(uuid),
  public.oral_call(uuid, uuid), public.oral_grade(uuid, uuid, int[]),
  public.oral_kick(uuid, uuid), public.oral_finish(uuid),
  public.oral_join_session(text, text), public.oral_my_state(uuid),
  public.oral_ready(uuid), public.oral_report_leave(uuid)
  to authenticated;
