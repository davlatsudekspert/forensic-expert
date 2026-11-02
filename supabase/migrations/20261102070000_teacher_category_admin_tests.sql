-- 2026-11-02 (egasi so'rovi):
-- 1) Ustoz kartasiga «toifa» (malaka toifasi) — profil boshida ism va ish joyi
--    ostida ko'rsatiladi. Eski ilovalar p_category yubormaydi: NULL — eski
--    qiymat saqlanadi; '' — tozalanadi.
-- 2) Admin panel: o'tkazilgan testlar ro'yxati (jonli sinf + guruh vazifalari)
--    va bitta test natijalari. Faqat identity_admin (private.admin_guard),
--    batafsil ko'rish audit jurnaliga yoziladi.

alter table public.teacher_cards
  add column if not exists category text
  check (category is null or category in ('higher', 'first', 'second', 'none'));

create or replace function private.teacher_card_json(c public.teacher_cards, p_owner boolean)
returns jsonb
language sql
stable
set search_path to ''
as $$
  select jsonb_build_object(
    'teacher_id', c.user_id,
    'display_name', c.display_name,
    'workplace', c.workplace,
    'category', c.category,
    'bio', c.bio,
    'photo_path', c.photo_path,
    'logo_path', c.logo_path,
    'socials', c.socials,
    'updated_at', c.updated_at)
  || case when p_owner then jsonb_build_object(
       'visible', c.visible, 'hidden_by_admin', c.hidden_by_admin,
       'consent_at', c.consent_at)
     else '{}'::jsonb end
$$;

drop function if exists public.teacher_card_upsert(text, text, text, text, text, jsonb, boolean);

create function public.teacher_card_upsert(
  p_display_name text,
  p_workplace text default '',
  p_bio text default '',
  p_photo_path text default null,
  p_logo_path text default null,
  p_socials jsonb default '{}'::jsonb,
  p_visible boolean default false,
  p_category text default null)
returns jsonb
language plpgsql
security definer
set search_path to ''
as $$
declare
  me uuid := auth.uid();
  v_name text := btrim(coalesce(p_display_name, ''));
  v_work text := btrim(coalesce(p_workplace, ''));
  v_bio text := btrim(coalesce(p_bio, ''));
  v_photo text := nullif(btrim(coalesce(p_photo_path, '')), '');
  v_logo text := nullif(btrim(coalesce(p_logo_path, '')), '');
  v_cat text := nullif(btrim(coalesce(p_category, '')), '');
  v_soc jsonb := '{}'::jsonb;
  v_vis boolean := coalesce(p_visible, false);
  v_in jsonb := coalesce(p_socials, '{}'::jsonb);
  old public.teacher_cards;
  r record;
  s text;
  v_row public.teacher_cards;
begin
  if me is null or not private.class_is_teacher(me) then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  if char_length(v_name) not between 2 and 60
     or v_name ~ E'[\\x01-\\x1f\\x7f]' then
    return jsonb_build_object('ok', false, 'error', 'invalid_name');
  end if;
  if char_length(v_work) > 120 or v_work ~ E'[\\x01-\\x1f\\x7f]' then
    return jsonb_build_object('ok', false, 'error', 'invalid_workplace');
  end if;
  if char_length(v_bio) > 300 or v_bio ~ E'[\\x01-\\x09\\x0b-\\x1f\\x7f]' then
    return jsonb_build_object('ok', false, 'error', 'invalid_bio');
  end if;
  if v_cat is not null and v_cat not in ('higher', 'first', 'second', 'none') then
    return jsonb_build_object('ok', false, 'error', 'invalid_category');
  end if;
  if v_photo is not null and not private.teacher_card_path_ok(me, 'photo', v_photo) then
    return jsonb_build_object('ok', false, 'error', 'invalid_photo');
  end if;
  if v_logo is not null and not private.teacher_card_path_ok(me, 'logo', v_logo) then
    return jsonb_build_object('ok', false, 'error', 'invalid_logo');
  end if;
  if jsonb_typeof(v_in) <> 'object' then
    return jsonb_build_object('ok', false, 'error', 'invalid_social');
  end if;
  for r in select key, value from jsonb_each(v_in) loop
    if r.key not in ('telegram', 'instagram', 'youtube', 'facebook', 'linkedin',
                     'tiktok', 'website') then
      return jsonb_build_object('ok', false, 'error', 'invalid_social', 'field', r.key);
    end if;
    if jsonb_typeof(r.value) = 'null' then continue; end if;
    if jsonb_typeof(r.value) <> 'string' then
      return jsonb_build_object('ok', false, 'error', 'invalid_social', 'field', r.key);
    end if;
    s := btrim(r.value #>> '{}');
    if s = '' then continue; end if;
    if not private.teacher_card_url_ok(r.key, s) then
      return jsonb_build_object('ok', false, 'error', 'invalid_social', 'field', r.key);
    end if;
    v_soc := v_soc || jsonb_build_object(r.key, s);
  end loop;
  select * into old from public.teacher_cards x where x.user_id = me for update;
  if v_vis and found and old.hidden_by_admin then
    return jsonb_build_object('ok', false, 'error', 'hidden_by_admin');
  end if;
  insert into public.teacher_cards as t (user_id, display_name, workplace, bio,
    photo_path, logo_path, socials, visible, consent_at, updated_at, category)
  values (me, v_name, v_work, v_bio, v_photo, v_logo, v_soc, v_vis,
          case when v_vis then now() end, now(), v_cat)
  on conflict (user_id) do update set
    display_name = excluded.display_name, workplace = excluded.workplace,
    bio = excluded.bio, photo_path = excluded.photo_path,
    logo_path = excluded.logo_path, socials = excluded.socials,
    visible = excluded.visible,
    consent_at = case when excluded.visible and not t.visible then now()
                      when excluded.visible then coalesce(t.consent_at, now())
                      else null end,
    -- p_category berilmagan (eski ilova) — eski qiymat; '' — tozalash.
    category = case when p_category is null then t.category else excluded.category end,
    updated_at = now()
  returning * into v_row;
  return jsonb_build_object('ok', true, 'card', private.teacher_card_json(v_row, true));
end $$;

revoke execute on function public.teacher_card_upsert(text, text, text, text, text, jsonb, boolean, text) from public, anon;
grant execute on function public.teacher_card_upsert(text, text, text, text, text, jsonb, boolean, text) to authenticated;

-- Ustoz nomi: karta ismi, bo'lmasa email.
create or replace function private.admin_teacher_label(p_user uuid)
returns jsonb
language sql
stable
security definer
set search_path to ''
as $$
  select jsonb_build_object(
    'teacher_id', u.id,
    'teacher_name', coalesce(nullif(c.display_name, ''), u.email),
    'teacher_email', u.email)
  from auth.users u
  left join public.teacher_cards c on c.user_id = u.id
  where u.id = p_user
$$;

-- O'tkazilgan testlar: eng yangisi birinchi. score100 — to'g'ri/jami × 100
-- o'rtachasi (bir kasr xona).
create or replace function public.admin_class_tests(
  p_query text default null,
  p_limit int default 100,
  p_offset int default 0)
returns jsonb
language plpgsql
stable
security definer
set search_path to ''
as $$
declare
  me uuid := private.admin_guard();
  q text := private.like_escape(nullif(btrim(left(coalesce(p_query, ''), 100)), ''));
  v_limit int := least(greatest(coalesce(p_limit, 100), 1), 200);
  v_offset int := greatest(coalesce(p_offset, 0), 0);
begin
  return coalesce((
    select jsonb_agg(x.j order by x.at desc)
    from (
      select j, at from (
        -- Jonli sinf sessiyalari.
        select coalesce(s.started_at, s.created_at) as at,
          jsonb_build_object(
            'kind', 'live',
            'id', s.id,
            'at', coalesce(s.started_at, s.created_at),
            'status', s.status,
            'group_name', null,
            'code', s.code,
            'topic_title', s.topic_title,
            'question_count', (select count(*) from public.class_session_questions sq
                               where sq.session_id = s.id),
            'participants', (select count(*) from public.class_participants p
                             where p.session_id = s.id and p.kicked_at is null),
            'finished', (select count(*) from public.class_participants p
                         where p.session_id = s.id and p.kicked_at is null),
            'avg_score100', (
              select round(avg(pc.c * 100.0 / nullif(qc.n, 0)), 1)
              from (select p.id, count(a.*) filter (where a.is_correct) as c
                    from public.class_participants p
                    left join public.class_answers a on a.participant_id = p.id
                    where p.session_id = s.id and p.kicked_at is null
                    group by p.id) pc,
                   (select count(*) as n from public.class_session_questions sq
                    where sq.session_id = s.id) qc)
          ) || private.admin_teacher_label(s.teacher_id) as j,
          s.topic_title as topic, (select u.email from auth.users u where u.id = s.teacher_id) as email,
          coalesce((select c.display_name from public.teacher_cards c where c.user_id = s.teacher_id), '') as tname,
          '' as gname
        from public.class_sessions s
        where s.status <> 'lobby' or exists (
          select 1 from public.class_participants p where p.session_id = s.id)
        union all
        -- Guruh vazifalari (uyga test).
        select a.created_at as at,
          jsonb_build_object(
            'kind', 'assignment',
            'id', a.id,
            'at', a.created_at,
            'status', a.status,
            'group_name', g.name,
            'code', null,
            'topic_title', a.topic_title,
            'question_count', a.question_count,
            'participants', (select count(*) from public.class_group_members m
                             where m.group_id = g.id),
            'finished', (select count(*) from public.class_assignment_attempts t
                         where t.assignment_id = a.id and t.submitted_at is not null),
            'avg_score100', (
              select round(avg(t.score * 100.0 / nullif(t.total, 0)), 1)
              from public.class_assignment_attempts t
              where t.assignment_id = a.id and t.submitted_at is not null
                and t.total > 0)
          ) || private.admin_teacher_label(g.teacher_id) as j,
          a.topic_title as topic, (select u.email from auth.users u where u.id = g.teacher_id) as email,
          coalesce((select c.display_name from public.teacher_cards c where c.user_id = g.teacher_id), '') as tname,
          g.name as gname
        from public.class_assignments a
        join public.class_groups g on g.id = a.group_id
      ) all_rows
      where q is null
         or all_rows.topic ilike '%' || q || '%' escape '\'
         or all_rows.email ilike '%' || q || '%' escape '\'
         or all_rows.tname ilike '%' || q || '%' escape '\'
         or all_rows.gname ilike '%' || q || '%' escape '\'
      order by at desc
      limit v_limit offset v_offset
    ) x), '[]'::jsonb);
end $$;

-- Bitta test natijalari: talaba laqabi, to'g'ri/jami, yakunlagan vaqti.
create or replace function public.admin_class_test_detail(p_kind text, p_id uuid)
returns jsonb
language plpgsql
security definer
set search_path to ''
as $$
declare
  me uuid := private.admin_guard();
  v_rows jsonb;
  v_total int;
begin
  if p_kind = 'live' then
    select count(*) into v_total from public.class_session_questions sq
      where sq.session_id = p_id;
    select coalesce(jsonb_agg(jsonb_build_object(
        'nickname', r.nickname, 'correct', r.c, 'total', v_total,
        'finished_at', r.last_at) order by r.c desc, r.nickname), '[]'::jsonb)
      into v_rows
      from (select p.nickname, count(a.*) filter (where a.is_correct) as c,
                   max(a.answered_at) as last_at
            from public.class_participants p
            left join public.class_answers a on a.participant_id = p.id
            where p.session_id = p_id and p.kicked_at is null
            group by p.id, p.nickname) r;
  elsif p_kind = 'assignment' then
    select coalesce(jsonb_agg(jsonb_build_object(
        'nickname', m.nickname,
        'correct', t.score, 'total', t.total,
        'finished_at', t.submitted_at)
        order by (t.submitted_at is null), t.score desc nulls last, m.nickname), '[]'::jsonb)
      into v_rows
      from public.class_assignments a
      join public.class_group_members m on m.group_id = a.group_id
      left join public.class_assignment_attempts t
        on t.assignment_id = a.id and t.user_id = m.user_id
      where a.id = p_id;
  else
    return jsonb_build_object('ok', false, 'error', 'invalid_kind');
  end if;
  perform private.admin_log(me, 'CLASS_TEST_VIEW', p_kind, p_id::text, '{}'::jsonb);
  return jsonb_build_object('ok', true, 'rows', v_rows);
end $$;

revoke execute on function public.admin_class_tests(text, int, int) from public, anon;
revoke execute on function public.admin_class_test_detail(text, uuid) from public, anon;
grant execute on function public.admin_class_tests(text, int, int) to authenticated;
grant execute on function public.admin_class_test_detail(text, uuid) to authenticated;
revoke execute on function private.admin_teacher_label(uuid) from public, anon, authenticated;
