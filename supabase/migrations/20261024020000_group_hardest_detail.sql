-- FORENSIC EXPERT — «Guruh testi»: «Qiyin savollar» muhokamasi uchun tafsilot.
-- Additiv: faqat bitta YANGI funksiya; jadval va mavjud funksiyalar o'zgarmaydi.
-- (Sinfdagi jonli test uchun o'xshash funksiya: 20261024010000_class_hardest_detail.sql.)
--
-- Dars oxiridagi guruh testi yopilgach ustoz eng ko'p xato qilingan savollarni
-- variantlari, to'g'ri javobi, tushuntirishi va manbasi bilan muhokama qiladi.
-- FAQAT:
--   * kirgan va guruhning o'z ustozi (private.group_assignment_owned: rol yo'q
--     yoki boshqa ustozning topshirig'i → 42501; anon uchun execute yo'q);
--   * topshiriq YOPILGAN yoki muddati o'tgan bo'lsa — aks holda {ok:false,
--     error:'not_finished'} (ochiq testda to'g'ri javob chiqmaydi).
-- Talaba ismi/ID yo'q: faqat savol bo'yicha jami (answered, correct_pct,
-- variantlar bo'yicha sanoq).
--
-- Variant rejimi: har talabaga savollar TURLICHA tanlanadi (SHA-256 draw), lekin
-- variantlar tartibi topshiriq nusxasida (class_assignment_questions) hamma uchun
-- bir xil, javob `answers[qid]` shu nusxadagi indeks. Shuning uchun savol har doim
-- nusxadagi asl ko'rinishida qaytadi, sanoq esa shu indekslarga mos (A, B, C, D).
-- Faqat kamida bitta javob berilgan savollar kiradi; tartib: eng past to'g'ri %,
-- keyin ko'proq javob berilgani, keyin qid. `index` — shu tartibdagi o'rin (0..).
-- ROLLBACK: supabase/rollback/20261024020000_group_hardest_detail_down.sql

create or replace function public.group_assignment_hardest_detail(
  p_assignment uuid, p_limit int default 5)
returns jsonb
language plpgsql security definer set search_path = '' as $$
declare
  a public.class_assignments;
  v_limit int := least(greatest(coalesce(p_limit, 5), 1), 10);
begin
  a := private.group_assignment_owned(p_assignment);
  if not (a.status = 'closed'
          or (a.due_at is not null and now() >= a.due_at)) then
    return jsonb_build_object('ok', false, 'error', 'not_finished');
  end if;
  -- Vaqti tugagan, yuborilmagan urinishlar oxirgi saqlangan javoblar bilan yopiladi.
  perform private.group_finalize_expired(a.id);
  return jsonb_build_object('ok', true, 'items', coalesce((select jsonb_agg(
      jsonb_build_object(
        'index', h.pos - 1, 'qid', h.qid, 'text', h.question, 'options', h.options,
        'correct_index', h.correct_index, 'explanation', h.explanation,
        'source', h.source, 'answered', h.n, 'correct_pct', h.pct,
        'option_counts', h.counts)
      order by h.pos)
    from (select row_number() over (order by s.pct, s.n desc, s.qid collate "C") as pos, s.*
          from (select q.qid, q.question, q.options, q.correct_index, q.explanation,
                       q.source, count(*)::int as n,
                       round(100.0 * count(*) filter (
                         where (t.answers ->> q.qid) = q.correct_index::text) / count(*))::int as pct,
                       jsonb_build_array(
                         count(*) filter (where (t.answers ->> q.qid) = '0')::int,
                         count(*) filter (where (t.answers ->> q.qid) = '1')::int,
                         count(*) filter (where (t.answers ->> q.qid) = '2')::int,
                         count(*) filter (where (t.answers ->> q.qid) = '3')::int) as counts
                from public.class_assignment_questions q
                join public.class_assignment_attempts t
                  on t.assignment_id = q.assignment_id
                 and (t.answers ->> q.qid) is not null
                where q.assignment_id = a.id
                group by q.qid, q.question, q.options, q.correct_index,
                         q.explanation, q.source) s
          order by s.pct, s.n desc, s.qid collate "C"
          limit v_limit) h), '[]'::jsonb));
end $$;

revoke execute on function public.group_assignment_hardest_detail(uuid, int) from public, anon;
grant execute on function public.group_assignment_hardest_detail(uuid, int) to authenticated;
