# «Ustoz–talaba testi» (guruhlar va asinxron mavzu testlari)

Yangilangan: 2026-10-18. Branch: `claude/teacher-student-test`. Holat: kod + migratsiya + testlar tayyor;
**production DB'ga QO'LLANMAGAN** (lead/egasi qo'llaydi). Pro/to'lov kodi yo'q — funksiya ochiq va bepul.

LabGuide'dagi (Cloudflare Worker) mantiq o'qib chiqildi va Supabase/RPC arxitekturamizga qayta yozildi
(ko'chirilmadi). «Sinfda test (jonli)» dan alohida: bu — guruh va muddatli mavzu testi, talaba o'z vaqtida yechadi.

## 1. Oqim

1. Ustoz (server roli `teacher`/`identity_admin`) **O'qish → Guruhlar va mavzu testlari** (yoki Ustoz paneli)
   → «Guruh yaratish» → guruh sahifasida **«Mavzu testi berish»**: mavzu (savollar banki `class_quiz_questions`),
   har talabaga savollar soni (1–50), vaqt chegarasi (1–180 daqiqa yoki chegarasiz), muddat (ixtiyoriy),
   «Har talabaga boshqa savollar», to'g'ri javoblar qachon ochilishi (muddat tugagach/ustoz yopgach yoki faqat yopgach).
2. Ustozning jonli panelida **bitta QR** (hammaga bir xil): `forensicexpert://app/g/<KOD>?a=<test>`; «Katta ekran»
   (proyektor, 16:9 va tik telefon, ekran o'chmaydi).
3. Talaba QR'ni ilova skaneri yoki telefon kamerasi bilan o'qiydi → **kirish shart** → birinchi marta taxallus → test.
4. Ball — serverda (`private.group_finalize`). Javoblar har savoldan keyin saqlanadi.
5. Panel/katta ekran har ~3 s: «Qo'shildi → Yechmoqda → Tugatdi + ball».
6. Talaba o'z ballini darhol ko'radi; to'g'ri javob, izoh, manba — faqat ochilgach.

## 2. Server (`supabase/migrations/20261018050000_class_groups.sql`)

Jadvallar: `class_groups`, `class_group_members`, `class_assignments`, `class_assignment_questions` (hovuz nusxasi,
variantlar aralashtirilgan), `class_assignment_attempts`. Hammasida RLS, jadval huquqi yo'q; faqat SECURITY DEFINER RPC.
Rollback: `supabase/rollback/20261018050000_class_groups_down.sql`.

| RPC | Kim | Vazifa |
|---|---|---|
| `group_create(name)` | ustoz | guruh, 8 belgili kod (0/O/1/I/L yo'q), ≤30 guruh, 20/soat |
| `group_list()` | kirgan | o'z guruhlari (ustoz, kod bilan) va a'zo guruhlari |
| `group_detail(group)` | egasi / a'zo | ustoz: a'zolar (faqat taxallus), testlar statistikasi; talaba: o'z holati |
| `group_remove_member`, `group_leave` | egasi / a'zo | chiqarish (urinishlari ham o'chadi) / chiqish |
| `group_assignment_create(...)` | egasi | sozlamalar tekshiruvi; variant hovuz < 2×N bo'lsa `variant_pool_small` (+`available`,`needed`); 60/soat |
| `group_assignment_close` | egasi | yopish → javoblar ochiladi; boshlaganlarga 30 s |
| `group_assignment_board` | egasi | jonli qatorlar (taxallus, holat, ball); email/user_id yo'q |
| `group_assignment_preview` | egasi | «Talaba ko'rinishida sinash» uchun hovuz (faqat o'qish) |
| `group_join(code, nickname?, assignment?)` | kirgan | anonim — 42501; ustoz o'z kodi → `role:teacher`; a'zo → darhol; yangi → `nickname_required`; ≤200; 30/soat + IP bo'yicha xato kodlar |
| `group_assignment_open/save/submit/result` | a'zo | server boshlanish vaqti, variant, saqlash, ball, natija |

* **Taxallus:** `private.nick_fold` (’ ‘ ʻ ʼ ` ´ ′ → ', bo'shliqlar) → `private.class_nick_check` (2–20, filtr);
  guruhda yagona (katta-kichik harfsiz). «Sinfda test» laqabi ham endi shu normalizatsiyadan o'tadi.
* **Variant:** `seed = hex(SHA-256("<assignmentId>:<userId>"))`, `kalit = hex(SHA-256(seed + ":" + savolId))`,
  kalit (teng — id, bayt tartibi) bo'yicha birinchi N ta; variantsiz test — `userId = '*'`. Postgres o'rnatilgan `sha256()`.
  Dart: `lib/domain/class_groups/variant_draw.dart`. Umumiy vektorlar: `apps/mobile/test/fixtures/class_group_variant_vectors.json`
  (`python3 tool/class_group_vectors.py [--check]`).
* **Vaqt:** oyna oxiri = `least(due_at, started_at + limit, closed_at)` + 30 s imtiyoz. Undan keyin yangi javob qabul qilinmaydi,
  oxirgi saqlanganlar bilan yakunlanadi (`finish_reason = expired`).
* **Ochilish:** `status = closed` yoki (`after_due` va `now() >= due_at`).

## 3. Ilova

* Domen/port: `lib/domain/class_groups/*`, `lib/domain/ports/class_groups_ports.dart`; adapterlar:
  `lib/data/remote/supabase_class_groups.dart`, `lib/data/class_groups/fake_class_groups_service.dart` (demo, SQL qoidalari nusxasi).
* Ekranlar: `lib/features/class_groups/presentation/*`; marshrutlar `Routes.groups…` (`/home/learn/groups/...`), havola `/g/<KOD>?a=`.
* **Taklif yo'qolmaydi:** `SharedPrefsPendingGroupInviteStore`; onboarding tugab Asosiy chizilgach qo'shilish sahifasi
  bir marta ochiladi; kirishdan keyin ham davom etadi.
* **Ustoz o'z kodini ochsa:** «Siz bu guruhning ustozisiz» + «Talaba ko'rinishida sinash» (lokal; serverga hech narsa yuborilmaydi).
* **Vaqt ko'rinishi:** vaqt chegarasi bor — teskari sanoq; faqat muddat — «Muddat: 20-okt, 18:00», sanoq faqat oxirgi soatda; server soatiga tuzatiladi.
* **iOS scroll:** `lib/core/widgets/in_bounds_scroll.dart` — yo'nalish faqat chegaralar ichidagi harakatdan; suzuvchi menyu
  (`AppShell`) shunga o'tkazildi; guruh sahifasi sarlavhasi layoutni o'zgartirmaydi.
* **Navigatsiya:** root sahifadan shell sahifaga — `go` (duplicate page key yo'q).
* Matnlar: `tool/l10n_class_groups.py` (uz/ru/en) — CLAUDE.md tartibida «(yangi skriptlar)» joyida, `l10n_ux_audit.py` dan oldin.

## 4. Testlar

* SQL: `supabase/tests/class_groups_test.sql` (112 tekshiruv), `class_groups_e2e.sql` (1 ustoz + 3 talaba), RLS matritsasi —
  `bash supabase/tests/run_local.sh`.
* Dart adapter ↔ lokal Postgres (haqiqiy RPC): `bash supabase/tests/class_groups_dart_e2e.sh`.
* Flutter: `test/unit/class_groups_test.dart`, `test/widget/class_groups_iphone_test.dart` (390×844, notch, iOS fizikasi),
  `test/guards/class_groups_guard_test.dart` (qorovul), kadrlar — `test/screenshots/class_groups_shots_test.dart`.

## 5. Egasi/lead qo'lda

1. Migratsiyani ko'rib chiqib production'ga qo'llash (bu agent qo'llamadi).
2. Ustoz roli (`account_roles`) — `docs/CLASS_QUIZ.md` §3; savollar banki — §5 (bank bo'sh bo'lsa mavzu chiqmaydi).
3. Privacy matniga (egasi tasdig'i bilan): guruh taxallusi, test javoblari va ball hisobga bog'liq saqlanadi; ustoz faqat taxallus va ballni ko'radi.
4. Real qurilma sinovi: iPhone kamera bilan QR, ikki telefon, proyektor — bu muhitda SINALMAGAN.

## 6. Egasining qo'shimcha talablari (2026-10-18, 2-xabar)

* **Yagona savollar indeksi.** `ClassQuizBank.index` — id → savol; bankdagi HAMMA savol (mashq ro'yxatidan
  chiqarilganlari ham, masalan betsiz/slayd matnidan tuzilganlari). Ustoz sinovi, «O'zim yechib ko'rish», demo server
  va «Umumiy test» oldindan ko'rishi savolni shu yerdan id bo'yicha topadi. Server topshiriqda savol matnini nusxalaydi
  (`class_assignment_questions`), shuning uchun talaba testi, katta ekran va natijalar id bo'yicha o'z nusxasidan oladi.
  Qorovul: `test/guards/question_index_guard_test.dart` — HAQIQIY bank (18 mavzu × 30 × 3 til); tuzatishsiz
  (eski `#NNN` id lar yoki betsizlarni indeksdan tushirish) yiqilishi tekshirildi.
* **Ustoz «Mavzu testi»** (Darslar): tanlov — 1) «Guruhga topshirish», 2) «O'zim yechib ko'rish» (qurilmada, 10 savol,
  hech narsa yuborilmaydi), 3) «Sinfda jonli test». Talaba guruh sahifasida testni bossa — darhol ochiladi.
* **Vaqt alohida, muddat alohida.** «Vaqt chegarasi»: 10/15/20/30/45/60 daqiqa, «Vaqtsiz», «Boshqa…» (1–180),
  standart 10; talaba boshlagan paytdan, tugasa javoblar o'zi yuboriladi, server tekshiradi. «Test qancha vaqt ochiq
  turadi»: 1/3/7 kun yoki sana, standart 1 kun. Har birining ostida bir qatorli izoh.
* **Savollar soni:** tez tanlovlar (≤50) + «Barcha N ta» + «Boshqa…» (hovuzgacha, server ≤200).
* **«Umumiy test berish»** (guruh sahifasida): manbalar — bank kurs/fan guruhlari (Darslar bilan bir xil), har manbada
  «Hammasini tanlash» va qidiruv; 10/20/30/50/Barcha/Boshqa; mavzulardan navbatma-navbat (id takrorlanmaydi),
  variant (2N hovuz), javoblar ochilishi, oldindan ko'rish (taqsimot + namuna), avtomatik nom (tahrirlanadi).
  Server: `group_assignment_create_mixed` (`private.group_assignment_make`); taqsimot
  `private.group_round_robin_counts` == Dart `roundRobinCounts` (umumiy vektorlar `round_robin`).
* **Jonli panel:** «Testni yopish» AppBar'da doim ko'rinadi (kichik ekranda ham); ro'yxatdagisi tepada.
* Sinov: `test/widget/class_groups_v2_test.dart` (390×844 va 360×640 @1.3x, haqiqiy bank): mavzu tanlash → 50 savol →
  20 daqiqa → variant → yuborish → talaba yechadi → natija ustozda; `supabase/tests/class_groups_dart_e2e.sh` — umumiy
  test ham.
