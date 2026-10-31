# Anti-cheat (server): erkin soniya + «ilovadan chiqdi» hodisasi — 2026-10-31

Migratsiya: `supabase/migrations/20261031010000_anti_cheat_seconds_leave.sql`
Qaytarish: `supabase/rollback/20261031010000_anti_cheat_seconds_leave_down.sql`
SQL test: `supabase/tests/anti_cheat_seconds_leave_test.sql` (`run_local.sh` ga qo'shilgan)
Asos: build 30 (`1d6f122`), jonli sinf `pace` migratsiyasi (`20261031000000`) production'da qo'llangan.

**Holat: production'ga QO'LLANMAGAN** (migratsiya ham, deploy ham). Qo'llash — egasi ruxsati bilan.

## 1. Erkin soniya (jonli sinf)

`public.class_create_session(p_topic, p_question_count, p_student_limit, p_seconds)`
endi `p_seconds` ni **5..300** (butun son) qabul qiladi (avval faqat 15/30/45/60).
Imzo o'zgarmagan; chegaradan tashqarisi (4, 301, 0, manfiy, null) —
`{ok:false, error:'invalid_settings'}`. Boshqa tekshiruvlar (5..20 savol,
5..200 talaba, mavzu, 10 ta ochiq sessiya, savollar yetarliligi) o'zgarmagan.
`class_create_session_pace` shu funksiyani chaqiradi — o'zgartirilmagan.

Vaqt mantig'i (`class_phase`, `class_remaining_ms`, `class_revealed`,
`class_submit_answer`, `class_next_mine`, `class_close_question`, `class_session_state`)
soniyani `settings->>'seconds'` dan o'qiydi, qiymatlar ro'yxati (whitelist) yo'q —
SQL testda 5, 20, 90, 300 bilan tasdiqlangan (host va self rejim).

## 2. «Ilovadan chiqdi» hodisasi

Mijoz test paytida ilova fonga o'tganda RPC chaqiradi; server sanaydi, faqat ustoz ko'radi.
Hech qanday avtomatik jazo/ball o'zgarishi yo'q.

### Jonli sinf
- Ustunlar: `class_participants.leave_count int not null default 0`, `last_left_at timestamptz`.
- `public.class_report_leave(p_session uuid) returns jsonb`
  - ishtirokchi emas / kicked / anon-bo'lmagan begona → `42501`; anon → execute yo'q;
  - sessiya `running` bo'lmasa (lobby/finished) → `{ok:true, counted:false}`;
  - self rejimda talaba birinchi savolni ochmagan yoki test tugatgan bo'lsa → `counted:false`;
  - 1 soniyada bir ishtirokchi uchun ko'pi bilan bir marta (`last_left_at <= clock_timestamp() - 1s`,
    bitta atomik UPDATE; parallel chaqiruv ham ikki marta sanalmaydi);
  - javob: `{ok:true, counted:true|false}`.
- Ustoz: `class_teacher_dashboard(p_session).participants[]` ga `leave_count` (int) va
  `last_left_at` (ISO vaqt yoki null) qo'shildi — host va self ikkalasida. Boshqa kalitlar o'zgarmagan.
- Talaba RPC'lari (`class_session_state`, `class_my_results`, `class_next_mine`, `class_export_results`)
  bu maydonlarni qaytarmaydi; jadvalga to'g'ridan-to'g'ri huquq yo'q (testda tasdiqlangan).

### Guruh testi
- Ustunlar: `class_assignment_attempts.leave_count`, `last_left_at` (xuddi shunday).
- `public.group_report_leave(p_assignment uuid) returns jsonb` — a'zo bo'lmasa `42501`;
  urinish yo'q (hali ochilmagan) yoki yuborilgan bo'lsa → `{ok:true, counted:false}`;
  1 s limit; javob `{ok:true, counted:bool}`.
- Ustoz: **`group_assignment_board(p_assignment).rows[]`** ga `leave_count` (urinish boshlanmagan
  bo'lsa 0) va `last_left_at` (null) qo'shildi. Ustoz uchun talabalar ro'yxatini qaytaradigan
  yagona RPC shu (boshqa RPC lar — `group_assignment_hardest_detail`, `group_detail` — ro'yxat qaytarmaydi
  yoki talaba bo'yicha emas; ularga tegilmagan).

### Xavfsizlik
Hammasi `SECURITY DEFINER`, `search_path = ''`; `grant execute ... to authenticated`, anon yo'q;
`private.*` yordamchilar mijozga yopiq (yangi private funksiya qo'shilmagan); jadval huquqi yo'q (RLS + revoke all).

## Qo'llash tartibi (egasi ruxsati bilan)
1. Migratsiyani qo'llash (`apply_migration` yoki `supabase db push`): jadvallarga ustun qo'shadi
   (`add column ... default 0`, blokirovkasiz tez), 2 ta yangi RPC, 3 ta `create or replace`.
2. Eski mijozlar (build 30 va oldingilari) buzilmaydi: yangi RPC'larni chaqirmaydi, qo'shimcha
   JSON kalitlarini e'tiborsiz qoldiradi, host rejimi natijalari o'zgarmagan.
3. Yangi mijoz (boshqa agent) `class_report_leave` / `group_report_leave` ni ilova fonga o'tganda chaqiradi
   va ustoz ekranida `leave_count` / `last_left_at` ni ko'rsatadi.
4. Soniya tanlash: mijoz endi 5..300 yuborishi mumkin; eski mijoz 15/30/45/60 yuboradi — ishlaydi.

## Qaytarish
`supabase/rollback/20261031010000_anti_cheat_seconds_leave_down.sql` — funksiyalarni build 30 dagi
tanalarga qaytaradi, yangi 2 RPC va 4 ustunni o'chiradi (hisoblagichlar yo'qoladi). Erkin soniya bilan
yaratilgan sessiyalar (masalan 20 yoki 90) o'z sozlamasini saqlab ishlayveradi (vaqt mantig'ida
whitelist yo'q); faqat YANGI sessiyalar yana 15/30/45/60 ga cheklanadi.

## Sinov natijalari (lokal PostgreSQL 16, `supabase/tests/run_local.sh`)
- To'liq to'plam: exit 0, **2335 PASS** (avval 2255; yangi test faylida 79 tekshiruv + «ALL … PASSED» qatori).
- Rollbackdan keyin mavjud to'plam: exit 0, **2255 PASS** (yangi test o'tkazib yuborilgan).
- Rollback → qayta qo'llash → yangi test: o'tdi.
- `class_quiz_test.sql` dagi bitta tekshiruv eski qoidani («20 s rad etiladi») kodlagan edi — yangi qoidaga
  mos 3 va 301 s ga o'zgartirildi (ikkala holatda ham rad etiladi, shuning uchun rollbackdan keyin ham o'tadi).

## Sinalmaganlar
- Haqiqiy Supabase/PostgREST: RPC'larning HTTP orqali chaqirilishi, JWT `sub` bilan haqiqiy autentifikatsiya,
  PostgREST schema cache'ning yangilanishi (migratsiyadan keyin `notify pgrst, 'reload schema'` kerak bo'lishi mumkin).
- Real mijoz (Flutter): ilova fonga o'tganda RPC chaqirilishi, offline holatda navbat/qayta yuborish.
- Katta yuk: yuzlab talaba bir vaqtda; 1 s limit atomik UPDATE ga tayanadi, lekin yuk bilan o'lchanmagan.
- Self rejimda «savol ochilmagan» holatida chiqish sanalmaydi (qaror: talaba hali savol ko'rmagan);
  guruh testida urinish muddati o'tib, hali yakunlanmagan bo'lsa ham sanaladi.
- Mijoz soatiga ishonilmaydi: «chiqish» faqat mijozning o'zi xabar berganda yoziladi (ilovani majburan
  yopish yoki tarmoqni uzish sanalmaydi) — bu anti-cheat ning ma'lum chegarasi.
