-- FORENSIC EXPERT — «Sinfda test»: «Qiyin savollar» muhokama varaqasi uchun tafsilot.
-- Additiv: faqat bitta YANGI funksiya; jadval va mavjud funksiyalar o'zgarmaydi.
--
-- `class_teacher_dashboard.hardest` faqat {index, text, answered, correct_pct}
-- qaytaradi. Muhokama uchun variantlar, to'g'ri javob, tushuntirish va manba
-- (muallif, sarlavha, bet) kerak. Ular `class_session_questions` da (sessiya
-- yaratilganda bankdan nusxalangan). Shu yerdan, FAQAT:
--   * kirgan va `teacher` / `identity_admin` roli bor foydalanuvchiga
--     (private.class_owned: rol yo'q yoki sessiya boshqaniki → 42501);
--   * o'zi ochgan sessiyasi uchun;
--   * sessiya TUGAGACH (`finished`) — jonli testda to'g'ri javob chiqmaydi.
-- Talaba laqabi/ID yo'q: faqat savol bo'yicha jami (answered, correct_pct,
-- variantlar bo'yicha sanoq). Tanlov qoidasi dashboard `hardest` bilan bir xil
-- (eng past to'g'ri %, keyin idx), shuning uchun indekslar mos keladi.

create or replace function public.class_hardest_detail(p_session uuid, p_limit int default 5)
returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare
  s public.class_sessions;
  v_limit int := least(greatest(coalesce(p_limit, 5), 1), 10);
begin
  s := private.class_owned(p_session, false);
  if s.status <> 'finished' then
    return jsonb_build_object('ok', false, 'error', 'not_finished');
  end if;
  return jsonb_build_object('ok', true, 'items', coalesce((select jsonb_agg(
      jsonb_build_object(
        'index', h.idx, 'text', h.question, 'options', h.options,
        'correct_index', h.correct_index, 'explanation', h.explanation,
        'source', h.source, 'answered', h.n, 'correct_pct', h.pct,
        'option_counts', h.counts)
      order by h.pct, h.idx)
    from (select sq.idx, sq.question, sq.options, sq.correct_index, sq.explanation,
                 sq.source, count(a.id)::int as n,
                 round(100.0 * count(*) filter (where a.is_correct)
                       / nullif(count(a.id), 0))::int as pct,
                 jsonb_build_array(
                   count(*) filter (where a.option_id = 'o0')::int,
                   count(*) filter (where a.option_id = 'o1')::int,
                   count(*) filter (where a.option_id = 'o2')::int,
                   count(*) filter (where a.option_id = 'o3')::int) as counts
          from public.class_session_questions sq
          join public.class_answers a on a.session_id = sq.session_id
                                     and a.question_index = sq.idx
          where sq.session_id = s.id
          group by sq.idx, sq.question, sq.options, sq.correct_index,
                   sq.explanation, sq.source
          order by pct, sq.idx limit v_limit) h), '[]'::jsonb));
end $$;

revoke execute on function public.class_hardest_detail(uuid, int) from public, anon;
grant execute on function public.class_hardest_detail(uuid, int) to authenticated;
