# 08 — PHASE 1: Foundation hisoboti

| | |
|---|---|
| Sana | 2026-10-04 |
| Branch | `claude/phase-1-foundation` |
| Flutter / Dart | 3.47.6 (stable) / 3.13.5 |
| Holat | PHASE 1 tugadi — **egasining tasdig‘ini kutmoqda**. PHASE 2 boshlanmagan |

## 1. Nima yaratildi

| Talab (PHASE 1 scope) | Bajarildi | Qayerda |
|---|---|---|
| Flutter project foundation | ✅ | `apps/mobile` (Android + iOS) |
| Clean / modular arxitektura | ✅ | 5 ta sof Dart paket + ilova (`presentation / domain / data`) |
| Dependency / version policy | ✅ | 6-bo‘lim; bitta workspace lockfile, `--enforce-lockfile` |
| CI | ✅ | `.github/workflows/ci.yml`, `tool/ci_local.sh` |
| Lint / static analysis | ✅ | `analysis_options.yaml` (strict-casts/inference/raw-types), `--fatal-infos` |
| Localization framework | ✅ | gen-l10n, `lib/core/l10n/arb/app_{en,ru,uz}.arb` |
| Theme / design tokens | ✅ | `lib/core/design/tokens.dart`, `theme.dart` (Light/Dark/System) |
| Responsive layout foundation | ✅ | `lib/core/layout/responsive.dart` (320 dp → planshet) |
| Accessibility foundation | ✅ | Tap target 48 dp, semantics, kontrast tokenlari, reduced motion |
| Navigation skeleton | ✅ | go_router + `StatefulShellRoute.indexedStack` (5 tab) |
| Offline database skeleton | ✅ | `packages/fe_database` (drift: content.db + user.db) |
| Scientific content schema skeleton | ✅ | `content_schema.drift`, `packages/fe_content_schema` |
| Source / provenance schema | ✅ | `Source`, `Claim`, `Citation`, `ClaimGroup` |
| Review status model | ✅ | `StatusResolver` (status review’lardan hisoblanadi), `ContentValidator` |
| Signed content-package skeleton | ✅ | `packages/fe_content_package` (Ed25519, SHA-256, CalVer, atomik o‘rnatish, rollback) |
| Search architecture skeleton | ✅ | `packages/fe_search_core` + FTS5 trigram (`FtsSearchIndex`) |
| Calculation-engine skeleton | ✅ | `packages/fe_calc_engine` (kontrakt, birliklar, namunaviy C1V1) |
| Backend abstraction | ✅ | `lib/domain/ports/backend_ports.dart` + offline adapterlar |
| Billing abstraction | ✅ | `lib/domain/ports/billing_ports.dart` (narxlar kodda yo‘q) |
| AI abstraction (real AI ulanmagan) | ✅ | `lib/domain/ports/ai_ports.dart`, `UnavailableAiAssistant`, `RegexPiiScanner` |
| Logo prototypes | ✅ | `design/logo/` — 3 variant, 1024/180/64/32 px testlari |
| First-launch language screen | ✅ | Birinchi ekran — til tanlash, login yo‘q |
| Basic onboarding shell | ✅ | Til → Ilmiy disclaimer → Rejim → Home |

**Ataylab qilinmagan (scope nazorati):** ilmiy kontent kiritilmadi, real AI, Supabase va RevenueCat SDK’lari ulanmadi, kalkulyator UI’si yo‘q, Henssge yo‘q (V1.1).

## 2. Fayl va papka tuzilmasi

```
forensic-expert/
├─ pubspec.yaml / pubspec.lock     # Dart pub workspace (bitta lockfile)
├─ analysis_options.yaml           # umumiy qat’iy lint
├─ .env.example                    # faqat placeholder
├─ .github/workflows/ci.yml        # CI + gitleaks + OSV + dependency review
├─ .github/dependabot.yml
├─ tool/ci_local.sh                # CI bilan bir xil lokal tekshiruv
├─ packages/
│  ├─ fe_content_schema/           # provenance, review, validator (sof Dart)
│  ├─ fe_search_core/              # EN/RU/UZ normalizatsiya, typo, reyting
│  ├─ fe_calc_engine/              # kalkulyator kontrakti, birliklar, C1V1
│  ├─ fe_content_package/          # imzolangan paket: verify/install/rollback
│  └─ fe_database/                 # drift: content.db (+FTS5), user.db
├─ apps/mobile/
│  ├─ lib/
│  │  ├─ main.dart → app/bootstrap.dart
│  │  ├─ app/        # app, router (onboarding redirect), providers (DI), routes
│  │  ├─ core/       # design, layout, l10n, perf, settings, widgets
│  │  ├─ domain/ports/   # backend, billing, AI kontraktlari
│  │  ├─ data/       # offline adapterlar, lazy content store
│  │  └─ features/   # onboarding, shell, home, tools, library, ai, profile
│  ├─ test/          # unit, widget, a11y, l10n, architecture, screenshots
│  ├─ integration_test/startup_perf_test.dart
│  └─ assets/fonts/  # Inter, JetBrains Mono (SIL OFL 1.1)
├─ design/logo/      # prototiplar, generator, previews, LOGO_PROTOTYPES.md
└─ docs/             # 00–08, screenshots/phase1/
```

## 3. Dependency’lar va tanlov sabablari

Litsenziyalar pub cache’dagi LICENSE fayllaridan tekshirildi.

| Paket | Versiya | Litsenziya | Nima uchun |
|---|---|---|---|
| flutter_riverpod | ^3.4.3 | MIT | Testlanadigan DI va state; `select` orqali keraksiz rebuild yo‘q; override bilan offline/fake adapterlar |
| go_router | ^18.0.2 | BSD-3 | Rasmiy (Flutter jamoasi); `StatefulShellRoute` tab stack’larini saqlaydi; redirect bilan onboarding guard |
| shared_preferences | ^2.5.5 | BSD-3 | Faqat oddiy sozlamalar (til, tema, rejim). Sezgir ma’lumot saqlanmaydi |
| drift | ^2.35.1 | MIT | SQL, migratsiya, FTS5, background isolate, sof Dart’da test qilinadi |
| drift_flutter | ^0.3.1 | MIT | Qurilmada bazani ochish (path_provider + sqlite3) |
| sqlite3 | ^3.7.0 | MIT | Build hooks orqali SQLite (FTS5 bilan). Eski `sqlite3_flutter_libs` EOL — ishlatilmaydi (audit E-03) |
| path_provider | ^2.1.6 | BSD-3 | App support katalogi (kontent paketi joyi) |
| cryptography | ^2.9.0 | Apache-2.0 | Ed25519 imzo tekshiruvi (sof Dart) |
| crypto | ^3.0.7 | BSD-3 | SHA-256 yaxlitlik |
| meta | ^1.19.0 | BSD-3 | `@immutable` |
| intl | (Flutter pin) | BSD-3 | gen-l10n |
| **dev:** build_runner, drift_dev, flutter_lints, lints, test, integration_test, flutter_driver | — | BSD/MIT | Kod generatsiya, lint, testlar, qurilmada perf o‘lchovi |

**Rad etilgan:** Isar (2023 dan barqaror reliz yo‘q — audit E-01), `sqlcipher_flutter_libs` (EOL — E-05), `flutter_math_fork` (kam qo‘llab-quvvatlanadi — E-06; formulalar keyinchalik build vaqtida SVG’ga render qilinadi), `package_info_plus` (`AppInfo` + pubspec moslik testi yetarli).

## 4. Dependency / version policy

1. **Bitta workspace lockfile** (`pubspec.lock`) — barcha paketlar bir xil versiyalarda. CI: `flutter pub get --enforce-lockfile`.
2. Yangi dependency faqat quyidagi shartlarda qo‘shiladi: faol qo‘llab-quvvatlash (oxirgi 12 oyda reliz), ruxsat etilgan litsenziya (MIT, BSD, Apache-2.0, Zlib, OFL — fontlar), aniq sabab shu hujjatda yozilgan.
3. **Taqiqlangan litsenziyalar:** GPL-2.0, GPL-3.0, AGPL-3.0 (CI `dependency-review` bloklaydi).
4. Vendor SDK’lar (Supabase, RevenueCat, HTTP klientlar) **faqat** `lib/data/remote/` ichida — `test/architecture` bloklaydi.
5. Yangilanish: Dependabot (haftalik), har bir yangilanish CI’dan o‘tadi. Major yangilanishlar alohida PR.
6. Xavfsizlik: OSV-scanner (har push), gitleaks (to‘liq git tarixi).
7. Flutter SDK versiyasi CI’da qotirilgan (`FLUTTER_VERSION`), faqat ongli ravishda oshiriladi.

## 5. Test natijalari (2026-10-04, shu muhitda ishga tushirilgan)

| To‘plam | Testlar | Natija |
|---|---|---|
| `fe_content_schema` | 23 | ✅ hammasi o‘tdi |
| `fe_search_core` | 20 | ✅ |
| `fe_calc_engine` | 12 | ✅ |
| `fe_content_package` | 15 | ✅ |
| `fe_database` | 22 | ✅ (FTS5 natijalari in-memory etalon bilan 16 ta so‘rovda aynan mos) |
| App — unit | 43 | ✅ (router redirect, WCAG kontrast 30 juftlik, PII, sozlamalar, versiya) |
| App — widget | 15 | ✅ (birinchi ishga tushirish, onboarding, navigatsiya, offline) |
| App — accessibility | 28 | ✅ (13 ekran × light/dark + semantika) |
| App — 320 dp / katta shrift | 119 | ✅ (13 ekran × 3 til × ×1.0/1.3/2.0 + ×3.0 + planshet) |
| App — l10n | 20 | ✅ (ARB to‘liqligi, 3 tilda render, tab yozuvlari sig‘ishi) |
| App — arxitektura | 5 | ✅ (qatlam chegaralari, vendor importlar, hardcoded matn, sirlar) |
| **Jami** | **322** | ✅ **0 ta xato** |
| Preview skrinshotlari | 10 | Yaratildi (CI’da o‘tkazib yuboriladi — tag `screenshots`) |

- `flutter analyze --fatal-infos` (ilova) — **No issues found**.
- `dart analyze --fatal-infos packages` — **No issues found**.
- `dart format --set-exit-if-changed` — o‘zgarish yo‘q.
- Generatsiya qilingan kod (drift, gen-l10n) qayta generatsiyada farq bermaydi.
- `tool/ci_local.sh` — **OK**.
- gitleaks (git tarixi va fayllar) — **no leaks found**.
- osv-scanner (`pubspec.lock`, 123 paket) — **No issues found**.

## 6. Accessibility holati

| Talab | Holat | Isbot |
|---|---|---|
| 320 dp kichik ekran | ✅ Overflow yo‘q | `small_screen_large_text_test.dart` |
| Katta shrift (Dynamic Type) ×1.3, ×2.0, ×3.0 | ✅ Kontent skroll bo‘ladi; Home grid ustunlari kamayadi | o‘sha + skrinshot 03, 08 |
| Tap target (Android 48 dp, iOS 44 pt) | ✅ | `androidTapTargetGuideline`, `iOSTapTargetGuideline` |
| Tugmalarda label | ✅ | `labeledTapTargetGuideline` |
| Matn kontrasti | ✅ Light va Dark | `textContrastGuideline` + WCAG token testi (≥ 4.5:1) |
| Screen reader | ✅ Header’lar, tanlangan holat, til nomlari o‘z tilida talaffuz uchun belgilangan (`LocaleStringAttribute`) | `accessibility_test.dart` |
| Reduced motion | ✅ Token darajasida (`FeMotion.of`) | — |
| High contrast | ⚠️ Alohida token to‘plami hali yo‘q | PHASE 2 |
| Real qurilmada TalkBack/VoiceOver | ⚠️ Qo‘lda tekshirilmagan (bu muhitda qurilma yo‘q) | PHASE 2 |

**Preview’da topilgan va tuzatilgan muammo:** 320 dp va ×2 shriftda pastki navigatsiya yozuvlari so‘z o‘rtasidan bo‘linib, qirqilardi. Avtomatik overflow testlari buni ushlamadi, chunki Flutter bunday holatda xato bermaydi. Tuzatish:
- tab yozuvlari masshtabi cheklandi (tor ekranda 1.0, qolganida 1.15);
- RU/UZ yozuvlari qisqartirildi («Расчёты», «Справка», «Asosiy»);
- yozuvlar sig‘ishini haqiqiy Inter metrikasi bilan o‘lchaydigan test qo‘shildi (`nav_label_fit_test.dart`).

## 7. Performance

| Talab | Amalga oshirilgan |
|---|---|
| Startup’da tarmoq yo‘q | ✅ Kafolat testi: har qanday `HttpClient` yaratilishi xato — onboarding va barcha ekranlar o‘tdi |
| Kontent bazasi startup’ni bloklamaydi | ✅ Lazy (`contentStatusProvider`), birinchi kadrdan keyin |
| O‘lchov | ✅ `StartupMetrics`: `settings.load`, `settings_loaded`, `first_frame`, `content_db.open` — Timeline’ga yoziladi; navigatsiya — `NavigationTimingObserver` |
| Qurilmada o‘lchov | ✅ `integration_test/startup_perf_test.dart` + `test_driver/perf_driver.dart` (frame build/raster, jank xulosasi) |
| Natijalar | ⚠️ **Hali o‘lchanmagan** — bu muhitda Android/iOS qurilma yoki emulator yo‘q |
| Tab almashish | ✅ `indexedStack` — ekranlar qayta qurilmaydi |
| Rebuild nazorati | ✅ Riverpod `select` (locale/theme alohida) |

## 8. Lokalizatsiya

- Ilova UI’sida hardcoded foydalanuvchi matni **yo‘q** (statik test).
- 3 til × 68 kalit: kalitlar, placeholder’lar va bo‘sh qiymatlar avtomatik tekshiriladi. EN bilan bir xil qolgan tarjima ham ushlanadi (brend nomlaridan tashqari).
- O‘zbek matnida apostrof bir xil (‘ va ’), ASCII `'` yo‘q.
- Material lokalizatsiyasi `uz` uchun ham ishlaydi (3 tilda render testi).
- **Ochiq:** RU/UZ UI matnlari men tomonimdan tayyorlangan — `i18n:ru` / `i18n:uz` reviewer ko‘rib chiqishi kerak. Ayniqsa disclaimer matnlari yuridik ko‘rikdan ham o‘tishi kerak.

## 9. Ochiq risklar

| # | Risk | Daraja | Reja |
|---|---|---|---|
| R-01 | Apple to‘lovlarini O‘zbekiston bankiga olish tasdiqlanmagan | Release-gate | PROGRESS.md da qayd etilgan |
| R-02 | CAS bo‘yicha noaniqliklar (ichki saqlash, davlat ro‘yxatlari, kichik hajm) | O‘rta | CAS’ga so‘rov (`07_POLICY_COMPLIANCE.md`, 1.3); sxema CAS’siz ishlaydi |
| R-03 | Reviewerlar tayinlanmagan → production’da ilmiy kontent bo‘lmaydi | Yuqori (biznes) | Pilot (`06`) development kanalida |
| R-04 | Real qurilmada perf va screen reader tekshirilmagan | O‘rta | PHASE 2 ning birinchi qadami |
| R-05 | Bundle ID `uz.forensicexpert.forensic_expert` — vaqtinchalik; domen va yuridik shaxsga bog‘liq | O‘rta | Store ro‘yxatdan o‘tishdan oldin hal qilinadi (keyin o‘zgartirib bo‘lmaydi) |
| R-06 | Logo A3 «tog‘ / A harfi» assotsiatsiyasi; trademark tekshirilmagan | O‘rta | `design/logo/LOGO_PROTOTYPES.md` |
| R-07 | Google Play shaxsiy akkaunt uchun 12 tester × 14 kun talabi | O‘rta | Tashkilot akkaunti tavsiya etiladi |
| R-08 | RU/UZ UI tarjimalari review qilinmagan | O‘rta | i18n reviewer |
| R-09 | `drift_flutter` 0.x versiyada | Past | Kuzatiladi; zarurat bo‘lsa `sqlite3` to‘g‘ridan-to‘g‘ri |
| R-10 | CI GitHub’da hali ishga tushmagan — workflow faqat lokal ekvivalent bilan sinalgan | Past | Birinchi push’da tekshiriladi |
| R-11 | PHASE 0/0.5/1 branch’lari main’ga merge qilinmagan; main bo‘sh | Ma’lumot | Egasining qarori |
