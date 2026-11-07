-- Sinf testi / guruh testi savollarini UI tilida (ru/en) ko'rsatish.
-- QO'LLANMAGAN — egasi tasdig'idan keyin qo'llanadi (faqat additiv: 2 ta
-- yangi o'qish funksiyasi, jadval/ma'lumot o'zgarmaydi).
--
-- Nega kerak: sessiya (class_session_questions) va guruh testi
-- (class_assignment_questions) savollari NUSXALANADI va variantlari serverda
-- aralashtiriladi; nusxada bank savoli id'si (sessiyada) yoki aralashtirish
-- tartibi saqlanmaydi. Mijoz class_quiz_questions'ni o'qiy olmaydi (RLS),
-- shuning uchun class_quiz_question_translations dagi variantlarni
-- aralashgan tartibga o'zi moslay olmaydi. Mashq savollari
-- (class_practice_questions) asl tartibda keladi — ular uchun mijoz
-- tarjima jadvalini to'g'ridan-to'g'ri o'qiydi, bu funksiya shart emas.
--
-- Xavfsizlik: funksiya faqat chaqiruvchi ALLAQACHON ko'rib turgan matnni
-- tarjima qiladi — aynan o'zbekcha savol matni va variantlar to'plamini
-- yuborish shart; izoh faqat aynan o'zbekcha izoh yuborilganda qaytadi
-- (jonli savol paytida izoh oshkor bo'lmaydi). correct_index qaytmaydi va
-- o'zgarmaydi: variantlar yuborilgan (aralashgan) tartibda qaytadi.

create or replace function public.class_quiz_localize(p_lang text, p_items jsonb)
returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  it jsonb;
  q public.class_quiz_questions;
  tr public.class_quiz_question_translations;
  v_id uuid;
  v_opts jsonb;
  v_pos int;
  v_ok boolean;
  v_out jsonb := '[]'::jsonb;
  e jsonb;
  k int;
begin
  if me is null then
    raise exception 'not_signed_in' using errcode = '28000';
  end if;
  if p_lang is null or p_lang not in ('ru', 'en')
     or p_items is null or jsonb_typeof(p_items) <> 'array'
     or jsonb_array_length(p_items) > 60 then
    return jsonb_build_object('ok', false, 'error', 'invalid');
  end if;
  for it in select value from jsonb_array_elements(p_items) loop
    q := null;
    tr := null;
    v_id := null;
    if jsonb_typeof(it) = 'object' and jsonb_typeof(it -> 'options') = 'array'
       and jsonb_typeof(it -> 'question') = 'string' then
      if (it ->> 'id') ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$' then
        v_id := (it ->> 'id')::uuid;
        select * into q from public.class_quiz_questions x
          where x.id = v_id and x.question = it ->> 'question';
      end if;
      if q.id is null then
        -- Sessiya nusxasida bank id'si yo'q: matn + variantlar to'plami bo'yicha.
        -- Asl mavzu (`~ru`/`~en` nusxadan oldin) afzal.
        select * into q from public.class_quiz_questions x
          where x.question = it ->> 'question'
            and x.options @> (it -> 'options') and (it -> 'options') @> x.options
          order by (x.topic_id like '%~%'), x.id
          limit 1;
      end if;
    end if;
    if q.id is not null then
      select * into tr from public.class_quiz_question_translations t
        where t.question_id = q.id and t.lang = p_lang;
    end if;
    v_ok := tr.question_id is not null
      and jsonb_array_length(tr.options) = jsonb_array_length(q.options)
      and jsonb_array_length(it -> 'options') = jsonb_array_length(q.options);
    v_opts := '[]'::jsonb;
    if v_ok then
      for e in select value from jsonb_array_elements(it -> 'options') loop
        v_pos := null;
        for k in 0 .. jsonb_array_length(q.options) - 1 loop
          if q.options -> k = e then
            v_pos := k;
            exit;
          end if;
        end loop;
        if v_pos is null then
          v_ok := false;
          exit;
        end if;
        v_opts := v_opts || jsonb_build_array(tr.options -> v_pos);
      end loop;
    end if;
    v_out := v_out || jsonb_build_array(case when v_ok then jsonb_build_object(
      'question', tr.question,
      'options', v_opts,
      'explanation', case
        when coalesce(it ->> 'explanation', '') <> ''
             and it ->> 'explanation' = q.explanation
        then nullif(tr.explanation, '') end)
    else null end);
  end loop;
  return jsonb_build_object('ok', true, 'items', v_out);
end $$;

revoke execute on function public.class_quiz_localize(text, jsonb) from public, anon;
grant execute on function public.class_quiz_localize(text, jsonb) to authenticated;

-- Mavzu nomlari: ma'ruza tarjimasidagi `topic` bo'lagi (lesson_deck_translations).
-- {deck_id: tarjima nomi}; tarjimasi yo'q mavzu kirmaydi (mijoz o'zbekcha nomni
-- qoldiradi).
create or replace function public.class_topic_titles(p_lang text)
returns jsonb
language plpgsql stable security definer set search_path = '' as $$
begin
  if auth.uid() is null then
    raise exception 'not_signed_in' using errcode = '28000';
  end if;
  if p_lang is null or p_lang not in ('ru', 'en') then
    return '{}'::jsonb;
  end if;
  return coalesce((
    select jsonb_object_agg(d.deck_id, tr.strings ->> (s.i - 1))
      from public.lesson_decks d
      join public.lesson_deck_translations tr
        on tr.deck_id = d.deck_id and tr.lang = p_lang
      cross join lateral (select min(x.i) as i from public.deck_strings(d.deck) x
                           where x.kind = 'topic') s
     where d.deck is not null and s.i is not null
       and nullif(btrim(coalesce(tr.strings ->> (s.i - 1), '')), '') is not null),
    '{}'::jsonb);
end $$;

revoke execute on function public.class_topic_titles(text) from public, anon;
grant execute on function public.class_topic_titles(text) to authenticated;
