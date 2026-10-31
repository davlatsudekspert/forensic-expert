# Jonli sinf testi: «Har kim o‘z tezligida» rejimi (2026-10-31)

Egasi talabi: «Jonli sinfda ham har kim o‘z tezligida bo‘lsin. Hammaga bir xil
bo‘lmasin.» Holat: **kod va migratsiya yozilgan va lokal sinalgan; production'ga
HECH NARSA qo‘llanmagan** (migratsiya, deploy, push yo‘q). Branch:
`claude/live-self-pace`.

## 1. Dizayn

Sessiya endi ikki rejimdan birida yaratiladi (`class_sessions.pace`):

| | `host` (STANDART, avvalgidek) | `self` (yangi) |
|---|---|---|
| Savol / vaqt | hammaga umumiy, soat sessiyada | har talabaning o‘zi |
| Keyingisiga | ustoz «Keyingi savol» | talaba o‘zi «Keyingi savol» |
| Taymer boshlanishi | ustoz savolni ochgan paytdan | talaba savolni ochgan paytdan (server soati) |
| Savollar tartibi | hammada bir xil | har talabada alohida (deterministik) |
| Ustoz ekrani | proyektor: joriy savol, «Keyingi/Yopish» | progress doskasi + jonli reyting + «Testni tugatish» |

`host` rejimda hech bir funksiya natijasi o‘zgarmaydi (mavjud `class_quiz_test.sql`
va barcha Dart testlari o‘zgarishsiz o‘tadi).

### Server (`supabase/migrations/20261031000000_class_quiz_self_pace.sql`)

- `class_sessions.pace text not null default 'host' check (pace in ('host','self'))`.
- `class_participants`: `current_index` (o‘z tartibidagi o‘rni), `question_started_at`
  (o‘z savolini ochgan server vaqti), `finished_at` (hammasini tugatgan).
- Yangi RPC:
  - `class_create_session_pace(topic, count, limit, seconds, pace default 'host')` —
    ichida eski `class_create_session` ni chaqiradi (barcha tekshiruvlar bir joyda),
    keyin pace'ni qo‘yadi. Eski 4 argumentli RPC host sessiya yaratadi.
  - `class_next_mine(session)` — talaba birinchi savolni ochadi (taymer shu paytdan),
    yoki yopilgan savoldan keyingisiga o‘tadi, oxirgisidan keyin tugatadi.
    Savol yopilmagan bo‘lsa (javob yo‘q va vaqt bor) — `not_closed`.
- Mavjud RPC lar (`create or replace`, imzo o‘zgarmagan, host yo‘li avvalgidek):
  `class_session_state`, `class_submit_answer`, `class_my_results`,
  `class_teacher_dashboard`, `class_export_results`, `class_next`,
  `class_close_question` (self'da `bad_state`), shuningdek yordamchilar
  `class_phase / class_remaining_ms / class_revealed / class_session_json /
  class_scores`. Private yangilari: `class_self_order`, `class_self_state`.
- `class_session_json` ga `pace` kaliti qo‘shildi (additiv; eski mijoz e’tiborsiz qoldiradi).

### Xavfsizlik qoidalari (serverda)

- Talaba faqat O‘Z holatini oladi (`class_self_state`): o‘z savoli, o‘z taymeri, o‘z
  balli. Boshqa talabaning javobi/progressi/o‘rni yo‘q; o‘rin (`rank`) va reyting faqat
  sessiya tugagach. Ustoz (egasi, `class_owned`) hammaning progressini ko‘radi;
  boshqa ustoz/talaba/begona — 42501.
- Savol matni faqat talaba uni ochgach, bittadan beriladi (oldindan emas).
- To‘g‘ri javob: o‘z javobi tasdiqlangach (u o‘zgarmaydi) yoki o‘z vaqti tugab +1.5 s
  o‘tgach. Ochiq savolda `correct_*`, `explanation`, `reveal` YO‘Q (testda tekshiriladi).
- Takroriy javob taqiqlangan (`unique(participant_id, question_index)` + `already_answered`),
  vaqt serverda (`seconds` + 1 s imtiyoz, so‘ng `time_over`), faqat o‘z hozirgi savoliga
  javob (`not_current`), qator qulflanadi (Keyingi bilan poyga yo‘q).
- Avto-o‘tish yo‘q; ikki marta «Keyingi» bosish savolni o‘tkazib yubormaydi.
- Savollar tartibi: `md5(participant_id || ':' || idx)` bo‘yicha (har talabaga alohida,
  yondagi telefonga qarab ko‘chirishni qiyinlashtiradi). Javoblar ASL savol idx'i bilan
  saqlanadi, shuning uchun «eng qiyin savollar» va eksport o‘zgarishsiz ishlaydi.
- Jadval huquqi yo‘q, hamma narsa SECURITY DEFINER (`search_path = ''`) RPC orqali;
  private yordamchilar mijozga yopiq.

Ma’lum chegara: o‘z javobini tasdiqlagan talaba to‘g‘ri javobni ko‘radi va uni hali
shu savolga yetmagan do‘stiga aytishi mumkin. Har talabaga alohida savol tartibi bu
xavfni kamaytiradi, lekin yo‘q qilmaydi (o‘z tezligidagi har qanday test uchun xos).

### Ilova

- Domen: `ClassPace {host, self}`, `ClassQuizSettings.pace` (standart `host`),
  `ClassSessionInfo.pace`, `ClassStudentState.selfStage/position/answeredCount`,
  `ClassParticipant.progress`, `ClassDashboard.selfOpened/selfDone`, `ClassFailure.notClosed`.
- Port: `ClassQuizService.nextMine`. Adapterlar: Supabase (host → eski RPC, self →
  `class_create_session_pace`; migratsiya qo‘llanmagan serverda host ishlayveradi),
  Fake/demo (SQL nusxasi, demo botlar self rejimda ham o‘z sur’atida yechadi).
- Ustoz «Yangi test»: «Test rejimi» bo‘limi — sozlamalar tagida, «Testni boshlash» tugmasi ustida (ikkita aniq karta, har birining tagida
  bir qatorli izoh); standart — «Ustoz boshqaradi». Self'da lobby'da «Rejim: …» qatori.
- Talaba self ekrani: «Tayyormisiz? → Boshlash», savol (o‘z taymeri), variant tanlash
  (serverga ketmaydi) + alohida «Tasdiqlash», natija/izoh, «Keyingi savol / Yakunlash»
  (avto-o‘tmaydi), tugagach o‘z natijasi va xatolari (reyting ustoz tugatgach).
- Ustoz doskasi: har talaba uchun «Savol n/N», progress chizig‘i, to‘g‘ri/javob soni,
  «Tugatdi / Hali boshlamagan», jonli reyting, «boshladi/tugatdi» yig‘indisi, hamma
  tugatsa banner, «Testni tugatish» (tasdiq bilan).
- Qisqa izohlar (egasi qo‘shimcha talabi): variantlar tagida «Javobni tanlang va
  «Tasdiqlash»ni bosing. Keyingi savolga o‘zingiz o‘tasiz.» (guruh testi va self rejimi);
  guruh testi natijasida «Balingiz tayyor.» (to‘g‘ri javoblar haqidagi mavjud
  `groupRevealText` izohi o‘zgarmagan, takrorlanmaydi).
- L10n: `tool/l10n_class_self_pace.py` (idempotent, uz/ru/en) + `flutter gen-l10n`.
  CLAUDE.md tartibida `l10n_group_wording.py` dan keyin, `l10n_ux_audit.py` dan oldin.

## 2. Migratsiyani qo‘llash tartibi (production — FAQAT egasi ruxsati bilan)

1. Zaxira/xavfsizlik: migratsiya additiv (ustun qo‘shish + `create or replace`), ma’lumot
   o‘chirmaydi. Mavjud ochiq sessiyalar `pace='host'` bo‘lib qoladi.
2. Avval **migratsiyani**, keyin ilovaning yangi versiyasini chiqaring (eski ilova yangi
   serverda ishlayveradi; yangi ilova eski serverda host rejimda ishlaydi, self tanlansa
   «xizmat ulanmagan» ko‘rsatadi).
3. Tavsiya: faol dars/imtihon vaqtida emas, bo‘sh vaqtda qo‘llang (funksiyalar almashadi,
   bir necha millisekundlik oyna).
4. Qo‘llangach: `supabase/tests/class_quiz_self_pace_test.sql` ni kopiya/branch bazada
   ishga tushiring; keyin 1 ta ustoz + 2 ta talaba bilan haqiqiy self sessiya o‘tkazing.
5. Edge function deploy talab qilinmaydi.

## 3. Orqaga qaytarish

`supabase/rollback/20261031000000_class_quiz_self_pace_down.sql` — eski funksiya
tanalarini tiklaydi (avvalgi migratsiyalardan), yangi funksiyalarni o‘chiradi, ketayotgan
self sessiyalarni `finished` qiladi va `pace` / progress ustunlarini olib tashlaydi.
Javoblar saqlanadi. Lokal tekshirilgan: rollbackdan keyin `class_quiz_test.sql` va
`class_hardest_detail_test.sql` o‘tadi. Ilova tomoni: faqat yangi ilova versiyasini
qaytarish (eski serverga ham mos).

## 4. Sinov holati

Lokal PostgreSQL 16 da (`supabase/tests/run_local.sh`): to‘liq SQL to‘plami o‘tdi,
shu jumladan yangi `class_quiz_self_pace_test.sql` (91 tekshiruv) va rollback sinovi.
Dart: yangi unit (15) va widget (9) testlar; mavjud class_quiz*/class_groups* testlari o‘tadi.

**Sinalmagan:**
- Haqiqiy Supabase (production/staging) bazasi, PostgREST orqali (lokal test SQL darajasida,
  `request.jwt.claim.sub` bilan); HTTP 403/404 xaritasi faqat unit testda (soxta transport).
- Real qurilma (iOS/Android) va real internet; ko‘p (20–200) talaba bilan yuklama:
  `class_scores` har so‘rovda hisoblanadi (host rejimdagi kabi), self'da talaba so‘rovi
  yengil (`class_self_state` faqat o‘z qatorlari), lekin ustoz paneli har 2 s hammani
  hisoblaydi.
- STUDENT/EXPERT/ADMIN rollarida real ilova bilan qo‘lda sinov (CLAUDE.md «Majburiy real
  sinov») — bu ishda bajarilmagan, faqat widget testlar (390/320 dp).
- Ekranga ulanib bir vaqtda ishlash (poyga holatlari) ko‘p qurilmada.
- Proyektor/landshaft ko‘rinishi self doskasi uchun alohida optimallashtirilmagan.
