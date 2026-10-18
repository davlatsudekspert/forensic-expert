-- FORENSIC EXPERT — «Sinfda test» audit tuzatishlari (2026-10-18).
-- Additiv: faqat `create or replace function` (imzolar o'zgarmagan) va bitta
-- yangi private yordamchi. Jadval o'zgarmaydi, ma'lumot o'chirilmaydi.
--
--  1. Ball/o'rin/to'g'ri soni ochiq savol davomida oshkor bo'lmaydi:
--     private.class_scores faqat «ko'rinadigan» javoblarni sanaydi —
--     question_index < current_index, yoki joriy savol private.class_revealed()
--     bo'lgach, yoki sessiya tugagan. class_session_state, ustoz paneli
--     reytingi, eksport va natijalar shu bitta qoidaga bo'ysunadi.
--  2. Universitet Wi-Fi / CGNAT: IP bo'yicha hisoblagich faqat MUVAFFAQIYATSIZ
--     (kod taxmini: bad_code / not_found) urinishlarni sanaydi; muvaffaqiyatli
--     qo'shilish va qayta kirish IP hisobiga kirmaydi. Hisob bo'yicha 30/soat
--     cheklovi o'zgarmagan.
--  3. Ustoz paneli JSON'iga `revealed` qo'shildi (private.class_revealed):
--     katta ekran to'g'ri javob/sonlar/izohni faqat shunda ochadi (javob
--     qabul qilish muddat + 1 s gacha davom etadi). «Eng qiyin savollar» ham
--     joriy savolni faqat revealed bo'lgach hisoblaydi.
--  5. Tugagan sessiyaga mavjud (chiqarilmagan) ishtirokchi qayta kirsa —
--     ok + session (status finished): ilova natijalar ekranini ochadi.
--  6. Reyting: o'rtacha vaqt faqat TO'G'RI javoblar bo'yicha, `nulls last`
--     (javob bermagan talaba noto'g'ri javob berganidan yuqori turmaydi).
--     Eksportdagi avg_ms (javob_vaqti_s) avvalgidek barcha ko'rinadigan
--     javoblar bo'yicha.
--  7. Laqab filtri: 'еба' / 'ebal' / 'ebat' substring stem'lari real ismlarni
--     (Себастьян, Глеба, Ebaldiyev, Rebalance) to'sardi. Endi bu shakllar
--     faqat so'z boshida (prefix) yoki to'liq so'z sifatida tekshiriladi.
--     Dart nusxasi: ClassNickname (apps/mobile) — bir xil ro'yxat.
--
-- ROLLBACK (qo'lda): 20261017010000_class_quiz.sql va
-- 20261018010000_class_quiz_dashboard_answered.sql dagi funksiya tanalarini
-- qayta `create or replace` qilish; private.class_join_fail_ip ni drop qilish.

-- ------------------------------------------------------------ 7. laqab
create or replace function private.class_nick_check(p text) returns text
language plpgsql immutable set search_path = '' as $$
declare
  t text := btrim(coalesce(p, ''));
  norm text;
  -- Istalgan joyda (so'zlar orasida yashirilsa ham) ushlanadi.
  stems text[] := array['fuck', 'shit', 'bitch', 'cunt', 'nigger', 'nigga', 'whore',
    'slut', 'pussy', 'asshole', 'blyat', 'blyad', 'pidor', 'pidar', 'mudak', 'pizd',
    'gandon', 'jalab', 'qanjiq', 'onangni', 'sikaman', 'сука',
    'блядь', 'бляд', 'пизд', 'хуй', 'мудак', 'пидор', 'гандон', 'долбоеб', 'долбоёб'];
  -- Faqat so'z BOSHIDA (Глеба, Себастьян, Ebaldiyev o'tadi).
  prefixes text[] := array['ебат', 'ебал', 'ебан', 'ебло', 'еблан', 'ебуч', 'ебну',
    'ёбан', 'ёбну', 'заеб', 'заёб', 'уеба', 'уебо', 'уёб', 'yebat', 'yeban', 'yebal',
    'zaeb', 'zayeb'];
  -- Faqat to'liq so'z.
  exact text[] := array['sik', 'huy', 'xuy', 'hui', 'suka', 'sex',
    'ebal', 'ebat', 'eban', 'ebalo', 'еб', 'ёб'];
  s text;
  w text;
  nw text;
begin
  if char_length(t) < 2 or char_length(t) > 20 then return 'length'; end if;
  if t ~ '[[:cntrl:]<>{}\[\]\\|^~;"`]' then return 'chars'; end if;
  if t !~ '[^[:space:]_.''’-]' then return 'chars'; end if;
  norm := private.class_nick_norm(t);
  foreach s in array stems loop
    if position(s in norm) > 0 then return 'blocked'; end if;
  end loop;
  -- So'zlar: tinish belgilari bo'yicha VA faqat bo'shliq bo'yicha (е.б.а.т.ь).
  foreach w in array regexp_split_to_array(lower(t), '[^[:alpha:]0-9@$]+')
                     || regexp_split_to_array(lower(t), '[[:space:]]+') loop
    nw := private.class_nick_norm(w);
    continue when nw = '';
    if nw = any (exact) then return 'blocked'; end if;
    foreach s in array prefixes loop
      if left(nw, char_length(s)) = s then return 'blocked'; end if;
    end loop;
  end loop;
  return 'ok';
end $$;

-- ---------------------------------------------------- 2. join cheklovi
-- Hisob bo'yicha har urinish sanaladi (30/soat). IP bo'yicha faqat
-- muvaffaqiyatsiz urinishlar (private.class_join_fail_ip) — bu yerda faqat
-- o'qiladi, oshirilmaydi.
create or replace function private.class_join_bump(p_user uuid) returns boolean
language plpgsql security definer set search_path = '' as $$
declare
  hr timestamptz := date_trunc('hour', clock_timestamp());
  hdr jsonb;
  ip text;
  v int;
  ok boolean := true;
begin
  insert into public.class_join_attempts as a (key, hour, n)
  values ('u:' || p_user::text, hr, 1)
  on conflict (key, hour) do update set n = a.n + 1
  returning n into v;
  if v > 30 then ok := false; end if;
  begin
    hdr := nullif(current_setting('request.headers', true), '')::jsonb;
  exception when others then hdr := null;
  end;
  ip := nullif(btrim(split_part(coalesce(hdr ->> 'x-forwarded-for', ''), ',', 1)), '');
  if ip is not null then
    select a.n into v from public.class_join_attempts a
      where a.key = 'f:' || md5(ip) and a.hour = hr;
    -- Bitta tarmoqdan (sinf Wi-Fi) soatiga 100 ta noto'g'ri kod.
    if coalesce(v, 0) >= 100 then ok := false; end if;
  end if;
  return ok;
end $$;

-- Noto'g'ri/topilmagan kod: IP (bor bo'lsa) hisobiga +1.
create or replace function private.class_join_fail_ip() returns void
language plpgsql security definer set search_path = '' as $$
declare
  hdr jsonb;
  ip text;
begin
  begin
    hdr := nullif(current_setting('request.headers', true), '')::jsonb;
  exception when others then hdr := null;
  end;
  ip := nullif(btrim(split_part(coalesce(hdr ->> 'x-forwarded-for', ''), ',', 1)), '');
  if ip is null then return; end if;
  insert into public.class_join_attempts as a (key, hour, n)
  values ('f:' || md5(ip), date_trunc('hour', clock_timestamp()), 1)
  on conflict (key, hour) do update set n = a.n + 1;
end $$;

-- ------------------------------------------------ 1 + 6. ball va reyting
create or replace function private.class_scores(p_session uuid)
returns table (participant_id uuid, nickname text, score int, correct int,
               answered int, avg_ms int, rk int)
language plpgsql stable security definer set search_path = '' as $$
declare
  s public.class_sessions;
  v_rev boolean;
begin
  select * into s from public.class_sessions x where x.id = p_session;
  if not found then return; end if;
  v_rev := private.class_revealed(s);
  return query
  with vis as (
    -- Ko'rinadigan javoblar: yopilgan savollar, joriysi faqat revealed bo'lgach.
    select a.* from public.class_answers a
    where a.session_id = s.id
      and (s.status = 'finished' or a.question_index < s.current_index
           or (a.question_index = s.current_index and v_rev))),
  t as (
    select p.id, p.nickname,
           coalesce(sum(a.points), 0)::int as score,
           (count(*) filter (where a.is_correct))::int as correct,
           count(a.id)::int as answered,
           (avg(a.elapsed_ms) filter (where a.is_correct))::int as avg_ms
    from public.class_participants p
    left join vis a on a.participant_id = p.id
    where p.session_id = s.id and p.kicked_at is null
    group by p.id, p.nickname)
  select t.id, t.nickname, t.score, t.correct, t.answered, t.avg_ms,
         (rank() over (order by t.score desc, t.correct desc, t.avg_ms asc nulls last))::int
  from t;
end $$;

-- ------------------------------------------- 5. tugagan sessiyaga qaytish
create or replace function public.class_join_session(p_code text, p_nickname text) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  v_code text := regexp_replace(coalesce(p_code, ''), '[\s-]', '', 'g');
  s public.class_sessions;
  part public.class_participants;
  chk text;
  v_nick text;
  v_count int;
begin
  if me is null then raise exception 'forbidden' using errcode = '42501'; end if;
  if not private.class_join_bump(me) then
    return jsonb_build_object('ok', false, 'error', 'rate_limited');
  end if;
  if v_code !~ '^[0-9]{6}$' then
    perform private.class_join_fail_ip();
    return jsonb_build_object('ok', false, 'error', 'bad_code');
  end if;
  select * into s from public.class_sessions where code = v_code for update;
  if not found then
    perform private.class_join_fail_ip();
    return jsonb_build_object('ok', false, 'error', 'not_found');
  end if;
  if s.teacher_id = me then
    return jsonb_build_object('ok', false, 'error', 'own_session');
  end if;
  select * into part from public.class_participants
    where session_id = s.id and user_id = me;
  if found then
    if part.kicked_at is not null then
      return jsonb_build_object('ok', false, 'error', 'kicked');
    end if;
    -- Qayta kirish (ulanish uzilgan yoki ilova qayta ochilgan; tugagan
    -- sessiya ham — natijalar ekrani uchun): laqab o'zgarmaydi.
    return jsonb_build_object('ok', true, 'session_id', s.id,
      'participant_id', part.id, 'nickname', part.nickname,
      'session', private.class_session_json(s));
  end if;
  if s.status = 'finished' then
    return jsonb_build_object('ok', false, 'error', 'finished');
  end if;
  if s.status <> 'lobby' then
    return jsonb_build_object('ok', false, 'error', 'already_started');
  end if;
  chk := private.class_nick_check(p_nickname);
  if chk <> 'ok' then
    return jsonb_build_object('ok', false,
      'error', case chk when 'blocked' then 'nick_blocked'
                        when 'chars' then 'nick_chars' else 'nick_length' end);
  end if;
  select count(*) into v_count from public.class_participants
    where session_id = s.id and kicked_at is null;
  if v_count >= coalesce((s.settings ->> 'student_limit')::int, 0) then
    return jsonb_build_object('ok', false, 'error', 'full');
  end if;
  v_nick := private.class_unique_nick(s.id, p_nickname);
  insert into public.class_participants (session_id, user_id, nickname)
  values (s.id, me, v_nick) returning * into part;
  return jsonb_build_object('ok', true, 'session_id', s.id,
    'participant_id', part.id, 'nickname', part.nickname,
    'session', private.class_session_json(s));
end $$;

-- ------------------------------------------------ 3. ustoz paneli: revealed
create or replace function public.class_teacher_dashboard(p_session uuid) returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare
  s public.class_sessions;
  q public.class_session_questions;
  v_joined int;
  v_answered int;
  v_correct int;
  v_revealed boolean;
  v_out jsonb;
begin
  s := private.class_owned(p_session, false);
  v_revealed := private.class_revealed(s);
  select count(*) into v_joined from public.class_participants p
    where p.session_id = s.id and p.kicked_at is null;
  v_out := private.class_session_json(s) || jsonb_build_object(
    'ok', true, 'phase', private.class_phase(s), 'revealed', v_revealed,
    'remaining_ms', private.class_remaining_ms(s), 'joined', v_joined,
    'reports', (select count(*) from public.class_reports r where r.session_id = s.id),
    'participants', coalesce((select jsonb_agg(jsonb_build_object(
        'id', p.id, 'nickname', p.nickname,
        -- Katta ekran: joriy savolga javob berganmi (to'g'riligi emas).
        'answered', s.status = 'running' and exists (select 1 from public.class_answers a
          where a.participant_id = p.id and a.question_index = s.current_index))
        order by p.joined_at)
      from public.class_participants p
      where p.session_id = s.id and p.kicked_at is null), '[]'::jsonb),
    -- Reyting: private.class_scores — ochiq savol ballari hali kirmaydi.
    'leaderboard', coalesce((select jsonb_agg(jsonb_build_object(
        'participant_id', t.participant_id, 'nickname', t.nickname, 'score', t.score,
        'correct', t.correct, 'rank', t.rk) order by t.rk, t.nickname)
      from (select * from private.class_scores(s.id) order by rk, nickname limit 10) t),
      '[]'::jsonb),
    -- Eng qiyin savollar: yopilgan (joriysi — revealed bo'lgach) savollardan.
    'hardest', coalesce((select jsonb_agg(jsonb_build_object(
        'index', h.idx, 'text', h.question, 'answered', h.n,
        'correct_pct', h.pct) order by h.pct, h.idx)
      from (select sq.idx, sq.question, count(a.id)::int as n,
                   round(100.0 * count(*) filter (where a.is_correct) / nullif(count(a.id), 0))::int as pct
            from public.class_session_questions sq
            join public.class_answers a on a.session_id = sq.session_id
                                       and a.question_index = sq.idx
            where sq.session_id = s.id
              and (s.status = 'finished' or sq.idx < s.current_index
                   or (sq.idx = s.current_index and v_revealed))
            group by sq.idx, sq.question
            order by pct, sq.idx limit 3) h), '[]'::jsonb));
  if s.status = 'running' then
    select * into q from public.class_session_questions
      where session_id = s.id and idx = s.current_index;
    select count(*)::int, (count(*) filter (where a.is_correct))::int
      into v_answered, v_correct
      from public.class_answers a
      join public.class_participants p on p.id = a.participant_id and p.kicked_at is null
      where a.session_id = s.id and a.question_index = s.current_index;
    v_out := v_out || jsonb_build_object('current', jsonb_build_object(
      'index', q.idx, 'text', q.question,
      'correct_option', 'o' || q.correct_index::text,
      'explanation', q.explanation,
      'answered', v_answered, 'correct_count', v_correct,
      'options', (select jsonb_agg(jsonb_build_object('id', 'o' || (o.ord - 1)::text,
          'text', o.val,
          'count', (select count(*) from public.class_answers a2
                    join public.class_participants p2
                      on p2.id = a2.participant_id and p2.kicked_at is null
                    where a2.session_id = s.id and a2.question_index = s.current_index
                      and a2.option_id = 'o' || (o.ord - 1)::text)) order by o.ord)
        from jsonb_array_elements_text(q.options) with ordinality o(val, ord))));
  end if;
  return v_out;
end $$;

-- ------------------------------------------- 6. eksport: avg_ms avvalgidek
-- class_scores.avg_ms endi faqat to'g'ri javoblar bo'yicha (reyting uchun);
-- CSV dagi «javob_vaqti_s» barcha ko'rinadigan javoblar bo'yicha qoladi.
create or replace function public.class_export_results(p_session uuid) returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare
  s public.class_sessions;
  v_rev boolean;
begin
  s := private.class_owned(p_session, false);
  v_rev := private.class_revealed(s);
  return jsonb_build_object('ok', true, 'session', private.class_session_json(s),
    'rows', coalesce((select jsonb_agg(jsonb_build_object(
        'nickname', t.nickname, 'score', t.score, 'correct', t.correct,
        'answered', t.answered,
        'avg_ms', coalesce((select avg(a.elapsed_ms)::int from public.class_answers a
                   where a.participant_id = t.participant_id
                     and (s.status = 'finished' or a.question_index < s.current_index
                          or (a.question_index = s.current_index and v_rev))), 0),
        'rank', t.rk)
        order by t.rk, t.nickname)
      from private.class_scores(s.id) t), '[]'::jsonb));
end $$;

-- ---------------------------------------------------------------- grants
-- create or replace mavjud huquqlarni saqlaydi; yangi yordamchi yopiladi.
revoke execute on function private.class_join_fail_ip() from public, anon, authenticated;
revoke execute on function private.class_nick_check(text) from public, anon, authenticated;
revoke execute on function private.class_join_bump(uuid) from public, anon, authenticated;
revoke execute on function private.class_scores(uuid) from public, anon, authenticated;
revoke execute on function public.class_join_session(text, text) from public, anon;
revoke execute on function public.class_teacher_dashboard(uuid) from public, anon;
revoke execute on function public.class_export_results(uuid) from public, anon;
grant execute on function public.class_join_session(text, text),
  public.class_teacher_dashboard(uuid), public.class_export_results(uuid)
  to authenticated;
