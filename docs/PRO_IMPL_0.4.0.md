# Pro 0.4.0 — texnik shartnoma (2026-10-24). Branch `claude/pro-0.4.0`, tekshiruvdagi 0.3.1 ga tegilmaydi.

Egasi qarorlari: `docs/PRO_PLAN_2026-10-24.md` (§1 free/pro jadvali, §2 narxlar, §5 himoya, §6 undash).
Bu hujjat — server va ilova o‘rtasidagi **aniq shartnoma**. Ikkala tomon shunga yozadi.

## 1. Rejalar va mahsulotlar
`plan`: `student` | `teacher` | `expert` (bepul = yozuv yo‘q yoki muddati tugagan).
Rejim → reja: Talaba→student, Ustoz→teacher, Mutaxassis→expert. **Reja faqat o‘z rejimini ochadi**; rejimni
almashtirish huquq bermaydi (gate `plan == kerakli reja` ni tekshiradi, `userMode` ni emas).

| plan | iOS/Android product id (bir xil) | oylik | yillik |
|---|---|---|---|
| student | `fe_student_monthly` / `fe_student_yearly` | $1.49 | $9.99 |
| teacher | `fe_teacher_monthly` / `fe_teacher_yearly` | $2.49 | $24.99 |
| expert | `fe_expert_monthly` / `fe_expert_yearly` | $3.49 | $34.99 |
Narx kodga yozilmaydi — faqat do‘kondan (`ProductDetails.price`); do‘kon ulanmagan bo‘lsa «narx do‘konda ko‘rsatiladi».

## 2. Server (Supabase) — migratsiya `supabase/migrations/20261025000000_plans.sql` (additiv)
Jadvallar (RLS yoqilgan, to‘g‘ridan-to‘g‘ri kirish yo‘q, faqat RPC):
```
public.plans(user_id uuid pk → auth.users, plan text check in ('student','teacher','expert'),
  source text check in ('store','admin','trial'), platform text check in ('ios','android','other') null,
  product_id text null, original_transaction_id text null, started_at timestamptz default now(),
  expires_at timestamptz null, auto_renew bool default false, note text ≤200, updated_at timestamptz)
public.trial_devices(device_hash text pk (sha256 hex, 64), user_id uuid, plan text, claimed_at timestamptz)
private.plan_events(id, user_id, actor_id, action text, plan text, source text, expires_at, meta jsonb, at timestamptz)
```
Qoidalar: `expires_at is null or > now()` → faol. Do‘kon yozuvi (`source='store'`) admin/trial yozuvidan ustun;
admin bergan muddat do‘kon tugagach ham saqlanadi (bitta qator: eng kech tugaydigan/eng kuchli manba yoziladi).

RPC (hammasi `security definer`, `set search_path = ''`, anon’ga yo‘q):
- `my_plan(p_device_hash text default null) returns jsonb` →
  `{plan: 'student'|'teacher'|'expert'|null, source, expires_at, auto_renew, product_id,
    trial_available: bool  -- device_hash berilgan va bu qurilma ham, bu akkaunt ham sinov olmagan bo‘lsa
   }`
- `plan_claim_trial(p_device_hash text, p_plan text) returns jsonb` → `{result: 'GRANTED'|'ALREADY_USED_DEVICE'|'ALREADY_USED_ACCOUNT'|'HAS_PLAN'|'INVALID', expires_at}`;
  30 kun; bir qurilma — bir marta (abadiy), bir akkaunt — bir marta; audit.
- `plan_apply_store(p_platform, p_product_id, p_original_transaction_id, p_expires_at timestamptz, p_auto_renew bool) returns jsonb` —
  **faqat service role** (edge function chaqiradi), authenticated’ga grant YO‘Q. Qaytadi `{result:'APPLIED', plan}`.
- `admin_set_plan(p_email text, p_plan text, p_until timestamptz) returns jsonb` — faqat `identity_admin`
  (`private.admin_guard()` mavjud bo‘lsa shu), `p_plan null` → olib tashlash (`REVOKED`); `{result:'GRANTED'|'REVOKED'|'NOT_FOUND'|'INVALID'}`; audit `plan_events` + `private.admin_log`.
- `admin_list_plans(p_query text default null, p_limit int default 50) returns jsonb` — admin: `[ {email, plan, source, expires_at, updated_at} ]`.
- `admin_stats_ext` ga qo‘shimcha emas; alohida `admin_plan_stats() returns jsonb` → `{active: {student,teacher,expert}, trials_active, store_active, admin_active}`.
Testlar: `supabase/tests/plans_test.sql` (run_local.sh ga qo‘shiladi, «ALL PLAN TESTS PASSED»): talaba my_plan null; trial bir marta (device/account); admin set/revoke; store ustunligi; muddati tugagan → null; anon → xato; `rls_role_matrix_test.sql` jadval matritsasiga `public.plans`, `public.trial_devices` qo‘shiladi (hech kimga to‘g‘ridan-to‘g‘ri kirish yo‘q).

Edge function `supabase/functions/verify-purchase/index.ts` (Deno, mavjud funksiyalar uslubida, JWT tekshiradi):
kirish `{platform:'ios'|'android', product_id, purchase_token|signed_transaction}` →
iOS: App Store Server API (JWS transaction info tekshiruvi; env `ASC_IAP_KEY_ID`, `ASC_IAP_ISSUER_ID`, `ASC_IAP_PRIVATE_KEY`, `APP_BUNDLE_ID`; sandbox/production ikkalasi),
Android: Google Play Developer API `purchases.subscriptionsv2` (env `PLAY_SERVICE_ACCOUNT_JSON`, `ANDROID_PACKAGE`).
Tasdiqlansa `plan_apply_store` (service role) → `{result:'APPLIED', plan, expires_at}`; env yo‘q → `{result:'NOT_CONFIGURED'}` (ilova buni «Do‘kon tekshiruvi hali ulanmagan» deb ko‘rsatadi); yaroqsiz → `{result:'INVALID'}`. Tarmoqsiz deno test (mock).

## 3. Ilova (Flutter)
Paket: `in_app_purchase` (so‘nggi stabil). Yangi qatlam:
- `lib/domain/plan/plan_models.dart`: `enum Plan {student, teacher, expert}`, `enum PlanSource {store, admin, trial}`,
  `class Entitlements {Plan? plan; PlanSource? source; DateTime? expiresAt; bool autoRenew; bool trialAvailable; bool get isActive}`,
  `enum ProFeature { fullQuizBank, examMode, allFlashcards, errorAnalytics, offlineDownload,   // student
                     allLessons, unlimitedGroupTests, resultsCsv, hardestDiscussion, liveTestLarge,   // teacher
                     instrumentsCourseFull, proCalculators, caseNotebook, courtPrep, aiExtended }`,  // expert
  `Plan requiredPlan(ProFeature)`, `bool Entitlements.allows(ProFeature)` (faqat o‘z rejasi).
- `lib/domain/ports/plan_ports.dart`: `PlanService { myPlan(deviceHash), claimTrial(deviceHash, plan), verifyPurchase(...) }`,
  `StoreService { products(ids), buy(product), restore(), purchaseStream }`.
- `lib/data/remote/supabase_plan.dart` (RPC), `lib/data/plan/fake_plan_service.dart` (testlar/demo),
  `lib/data/store/iap_store_service.dart` (in_app_purchase) + `fake_store_service.dart`.
- `lib/app/plan.dart`: `planServiceProvider`, `storeServiceProvider`, `entitlementsProvider` (FutureProvider, kirgan foydalanuvchi uchun; mehmon → bo‘sh), `deviceHashProvider` (iOS identifierForVendor / Android id → sha256; `device_info_plus`), `proGate(ref, ProFeature) → bool`.
- Ekranlar: `lib/features/pro/presentation/pro_screen.dart` (`Routes.pro = '/profile/pro'`, `Routes.proFor(plan)`): rejimga mos reja, oylik/yillik narx (do‘kondan), «30 kun bepul sinab ko‘rish» (server trial, faqat `trialAvailable`), «Sotib olish», «Xaridlarni tiklash», avto-uzayish/bekor qilish yo‘li (App Store/Play sozlamalari havolasi), Shartlar va Maxfiylik havolalari, «Xavfsizlik ma’lumotlari doim bepul» izohi; do‘kon ulanmagan/NOT_CONFIGURED holatlari halol.
  `ProLockCard` (fe_components uslubida: qulf + foyda jumlasi + «Pro bilan ochish») — qulfli joylarda.
  Profil: «Reja» qatori (Free / Student Pro / … , muddati) → Pro sahifasi. Admin panel: «Pro berish» (email, reja, muddat; ro‘yxat; olib tashlash) → `admin_set_plan`, `admin_list_plans`, `admin_plan_stats`.
- Gate joylari (§1 jadval `docs/PRO_PLAN_2026-10-24.md`): Talaba — mavzu testi 5 savoldan keyin qulf (fullQuizBank), imtihon rejimi (examMode), kartochkalar 1 fandan ortig‘i (allFlashcards), xatolar statistikasi (errorAnalytics); Mutaxassis — Apparatlar kursi: 1-dars ochiq, qolgani qulf (instrumentsCourseFull), professional kalkulyatorlar (proCalculators), ish daftari (caseNotebook), sudda so‘roq (courtPrep), AI kunlik limit (aiExtended); Ustoz — 3 dars ochiq, qolgani qulf (allLessons), guruh testi: 1 guruh / 10 savol bepul (unlimitedGroupTests), CSV (resultsCsv), qiyin savollar muhokamasi (hardestDiscussion).
  **Doim bepul:** xavfsizlik ogohlantirishlari, manbalar, provenance, talabaning ustoz bergan testni yechishi, QR bilan qo‘shilish, ma’lumotnoma o‘qish.
  Pro bo‘lmasa funksiya **ko‘rinadi** (yashirilmaydi), qulf bilan.
- Undash (§6): birinchi kirishda rejimga mos bitta yumshoq taklif (bir marta, `SharedPreferences`), keyin faqat qulfli joylar va natija nuqtalari (test tugadi → «Xatolar tahlili — Pro», dars oxiri → «Barcha darslar — Pro», apparat 1-dars oxiri → «Qolgan darslar — Pro»). Spam-popup yo‘q.
- l10n: yangi skript `tool/l10n_pro_plans.py` (uz/ru/en, CLAUDE.md tartibiga `l10n_group_wording.py` dan keyin), matnlar adabiy o‘zbek; Apple 3.1.2 talab qiladigan jumlalar (narx, muddat, avto-uzayish, bekor qilish, Shartlar/Maxfiylik) Pro sahifasida.
- Testlar: unit (Entitlements.allows — reja faqat o‘z rejimini ochadi, muddati tugagan → yo‘q), widget (Pro sahifa holatlari: free/trial/active/store-not-configured; qulf kartalari; admin Pro berish), `test/widget/all_free_test.dart` ni yangi holatga moslash (endi Pro bor — test nomi/mantiqi o‘zgaradi), goldenlar.
- iOS: `ios/Runner/Runner.entitlements` in-app purchase, `PrivacyInfo.xcprivacy` purchase history; Android: `BILLING` ruxsati `in_app_purchase` orqali avtomatik.
- Versiya: `0.4.0+20` (pubspec + `app_info.dart`).

## 4. Egasi qiladigan ishlar (men qila olmayman)
App Store Connect: Paid Apps Agreement, 6 obuna (guruh «FORENSIC EXPERT Pro», yuqoridagi id/narx), 3 oylik intro-offer, In-App Purchase API kaliti (`ASC_IAP_*` sekretlari); Sandbox tester akkaunt. Play Console: 6 obuna, narx, intro-offer, License testers, service account JSON. Sekretlar GitHub/Supabase’ga qo‘yiladi (men emas).
