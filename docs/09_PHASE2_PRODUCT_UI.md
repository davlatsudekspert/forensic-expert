# 09 — PHASE 2: Product UI

Branch: `claude/phase-2-product-ui` (PHASE 1 ustiga). main’ga merge qilinmagan, PR ochilmagan.

> Ilovadagi barcha kutubxona, o‘quv va test yozuvlari **TEST DATA** (namunaviy ma’lumot). Ilmiy qiymat, konsentratsiya, formula (C₁V₁ dan tashqari), metabolit va manbalar kiritilmagan. Real AI ulanmagan.

## 1. Ekranlar

| Ekran | Marshrut | Asosiy mazmuni |
|---|---|---|
| Til tanlash | `/onboarding/language` | FORENSIC EXPERT, «Evidence · Science · Precision», English · Русский · O‘zbekcha |
| Disclaimer | `/onboarding/disclaimer` | Ilmiy ogohlantirish va tasdiq |
| Rejim | `/onboarding/mode` | Professional · Student/Resident · Research/Education (keyin Profil’da o‘zgartiriladi) |
| Home | `/home` | Global Search, 6 modul, Quick access (so‘nggi vositalar, saralanganlar, so‘nggi qidiruvlar). Bo‘sh holatlar halol, soxta statistika yo‘q |
| Global Search | `/home/search?q=` | Guruhlar SUBSTANCES / METHODS / TOOLS / LEARNING / REFERENCES; EN/RU/UZ va xatoli yozuvga chidamli; lokal tarix va uni tozalash; natija yo‘q holati. «Online scientific databases» bloki alohida va «Rejalashtirilgan» deb belgilangan |
| Modul hub | `/home/module/:id` | Bo‘lim vositalari va «ishlab chiqilmoqda» ma’lumotnoma bloki |
| Tools | `/tools` | Toifalar: Forensic Medicine, Toxicology, Laboratory, Conversions. Har bir kartochkada nom, qisqa vazifa, mavjudlik, review holati (ikonka + matn) va saralash tugmasi |
| Kalkulyator | `/tools/tool/tool.lab.dilution` | C₁V₁ = C₂V₂: birliklar, natija, formula, taxminlar, cheklovlar, engine versiyasi. Statusi **NEEDS_REVIEW** (VERIFIED emas) |
| Library | `/library` | Bo‘limlar: Substances, Analytical Methods, Specimens, References, Glossary. Filtr va status chiplari |
| Modda kartochkasi | `/library/entry/:id` | Names, Class, Metabolites, Specimens, Methods, Concentrations (ogohlantirish bilan), Interpretation, Stability, Interferences, References, Evidence status, Last reviewed. **Xalqaro ilmiy dalillar** va **Yurisdiksiya qatlami** alohida bloklarda |
| Forensic AI | `/ai` | PII ogohlantirishi (doim ko‘rinadi) va jonli PII aniqlash; savol maydoni; «Ulanmagan» holati; javob maketi: iqtiboslar [1][2][3], Sources, Evidence status (ichki/tekshirilgan, tashqi/tekshirilmagan), Limitations |
| Learn (Student) | `/home/learn`, `/quiz`, `/flashcards` | Kurslar, darslar, test, kartochkalar, holatlar tahlili, progress (TEST fixture) |
| Profil | `/profile` | Language, Usage mode, **Jurisdiction**, Appearance (System/Light/Dark), Contrast (System/Standard/High), Lifetime Access (Free version / Lifetime), Scientific database version, Privacy Policy, Terms, Scientific Disclaimer, Open-source Licenses, About. Delete Account faqat `signedIn` bo‘lganda ko‘rinadi |
| Yurisdiksiya | `/profile/jurisdiction` | Xalqaro va mintaqaviy / Davlatlar; «Compare jurisdictions — rejalashtirilgan» (o‘chirilgan) |
| Lifetime Access | `/profile/purchase` | FORENSIC EXPERT · Lifetime Access · «{narx} · One-time purchase», 6 ta asosiy qiymat, «Unlock FORENSIC EXPERT», «One-time purchase · No recurring subscription», Restore Purchase, bepul versiya tavsifi, AI cheklov izohi. Store ulanmagan: reference narx ($59.99, izoh bilan) va tugma o‘chiq. Soxta chegirma, taymer yoki sharh yo‘q (6-bo‘lim) |
| Privacy / Terms / About | `/profile/privacy` va boshqalar | **DRAFT** — yuridik review talab qilinadi (RG-05) |

## 2. Professional va Student rejimlari

- **Bitta ilova, umumiy navigatsiya.** Rejim Home’dagi modullar tartibini va urg‘uni o‘zgartiradi:
  - Professional rejimda birinchi navbatda Toxicology, Library, Laboratory va Forensic Medicine turadi.
  - Student rejimida birinchi navbatda Learn turadi va «Continue learning» kartasi chiqadi.
- Student rejimidagi Learn bo‘limida kurslar, testlar, kartochkalar va holatlar tahlili bor.
- Professional rejimda «Continue learning» kartasi yo‘q.

## 3. Mavzular va accessibility

- Light / Dark / System mavzulari.
- High contrast (AAA ≥ 7:1, token testlari bilan). Uchta rejim: `System` OS sozlamasiga ergashadi (iOS «Increase Contrast», Android yuqori kontrastli matn), `Standard`, `High`.
- Holat hech qachon faqat rang bilan berilmaydi: har doim ikonka va matn birga ko‘rsatiladi (StatusChip, ReviewStatusBadge, TEST DATA belgisi).
- Avtomatik a11y tekshiruvlari: tap target (Android 48dp / iOS 44pt), tugmalarda label, matn kontrasti. Har bir ekran light, dark, HC light va HC dark mavzularida tekshiriladi.
- 320dp kenglikdagi ekranda matn masshtabi ×1.0, ×1.3 va ×2.0 bilan, 3 tilda: overflow yo‘q. PHASE 2 da topilgan 4 ta overflow tuzatildi:
  - kalkulyator metod qatori;
  - FeSectionHeader amal tugmasi;
  - obuna jadvali;
  - TestDataBadge.

## 4. Golden (vizual regressiya)

`apps/mobile/test/golden/`:
- `flutter_test_config.dart` haqiqiy shriftlarni yuklaydi va 0.5 % tolerantli komparator ishlatadi.
- Suite 26 ta reprezentativ kadrdan iborat (Lifetime ekrani light / dark / 320dp).
- Har bir ekran kamida bir marta qamralgan. EN / RU / UZ, Light / Dark / HC hamda 320 dp × (1.3, 2.0) bir necha marta takrorlanadi.
- To‘plam CI’da `flutter test` ichida ishlaydi.
- Ko‘rish uchun nusxa: `docs/screenshots/phase2/` (`_contact_sheet.png`).

## 5. Maxfiylik

- Saralanganlar, so‘nggi vositalar va **qidiruv tarixi faqat qurilmada** (SharedPreferences) saqlanadi. Ular serverga ham, telemetriyaga ham yuborilmaydi.
- `core/telemetry`:
  - hodisalar faqat enum;
  - parametrlar faqat `int` / `bool` / enum (sealed tur);
  - erkin matnni (qidiruv so‘rovi, AI savoli, ish raqami, ism) tur darajasida uzatib bo‘lmaydi;
  - default sink — `Noop`.

  Test pubspec’da analytics yoki crash SDK yo‘qligini tekshiradi.
- AI ekranida PII (ism-sharif, ish raqami, pasport, telefon, email) jonli aniqlanadi. PII topilsa ham hech narsa yuborilmaydi, chunki AI ulanmagan.

## 6. Monetizatsiya — FORENSIC EXPERT Lifetime (egasi qarori, PHASE 2 davomida)

Oldingi `Free / Student Pro / Professional Pro` obuna modeli **asosiy model sifatida olib tashlandi**. Student va Professional faqat foydalanish rejimi bo‘lib qoldi, pullik tier emas.

| Masala | Qaror / amalga oshirish |
|---|---|
| Mahsulot | **FORENSIC EXPERT Lifetime** — bir martalik xarid, obuna emas |
| Store turi | App Store: Non-Consumable IAP. Google Play: one-time product. Yagona ID — `fe_lifetime_unlock` (`ProductIds`) |
| Narx | UI kodida yo‘q (test buni tekshiradi). Store ulanganda storefront’ning lokal narxi (`Offer.localizedPrice`) ko‘rsatiladi. `$59.99` faqat `BillingConfig.referenceLifetimePrice` sifatida turadi va store yo‘q holatda «Reference price…» izohi bilan ko‘rsatiladi |
| Domen | `AccessLevel { free, lifetime, institution }`, `Entitlements.hasFullAccess`, `ProductFeature` (Forensic Medicine, Toxicology, Lab tools, Library, reagents/solutions, methods, express-test, biochemistry, calculators, Learn, offline DB, international standards, jurisdiction layers, verified references), `AccessPolicy` (bepul demo hajmi) |
| Bepul versiya | Har bir asosiy bo‘limdan haqiqiy demo bor: qidiruv, har bo‘limda 3 tadan yozuv, C₁V₁ vositasi, 1 ta kurs. Disclaimer, cheklovlar va manba/provenance tizimi **doim to‘liq** ochiq (`safetyAndProvenance`) |
| Forensic AI | Lifetime’ga «cheksiz» kirmaydi. Alohida `AiEntitlement` / `AiEntitlementService` bor: `AiPlan.none / includedQuota / aiPackage`. Limit majburiy, «cheksiz» holat modellashtirilmagan. PHASE 2 da AI billing yo‘q |
| Store holati | `StoreUnavailableEntitlementService`: taklif yo‘q, xarid `unavailable`. Real StoreKit / Play Billing adapteri keyingi bosqichda shu interfeysga ulanadi |

Eslatma: `docs/05_COST_MODEL.md` obuna modeli asosida yozilgan. Lifetime modeli uchun daromad va AI xarajati hisobini qayta ko‘rib chiqish kerak (RG-16).

## 7. Global Scientific Core + Jurisdiction Layer

Batafsil: `docs/10_GLOBAL_JURISDICTION_LAYER.md`.

## 8. Ishlash o‘lchovlari (faqat real o‘lchovlar)

> **Bu mobil qurilma o‘lchovi EMAS.** Muhitda Android emulator (KVM yo‘q), iOS simulator va real qurilma yo‘q. O‘lchovlar Linux desktop profile build’da olindi: Xvfb, GPU yo‘q, software rasterizatsiya, 4 vCPU VM. Xom ma’lumot: `docs/perf/phase2_raw.txt`. Real qurilma o‘lchovi **RG-10** bo‘lib qoladi.

| Ko‘rsatkich | Natija (median) | Usul |
|---|---|---|
| Cold start → birinchi kadr (dvigatel), til ekrani | 139.5 ms; rasterlangan 214.9 ms (n=5) | `flutter run --profile --trace-startup` |
| Cold start → birinchi kadr (dvigatel), Home | 164.0 ms; rasterlangan 247.5 ms (n=5) | o‘sha usul, sozlamalar oldindan yozilgan |
| `main()` → birinchi kadr (Dart) | 171.8–185.5 ms (n=3) | `StartupMetrics`, integration test |
| Startup’da tarmoq / AI / backend | **yo‘q** — Home ularni kutmaydi | kod + offline testi |
| Tab navigatsiyasi → maqsad ekranning birinchi kadri | birinchi kirishda 28–75 ms; keyingi kirishlarda 23–31 ms | integration test (n=15/ekran) |
| Ichki sahifa (kalkulyator, kartochka, qidiruv) | 34–39 ms | o‘sha usul |
| Mavzu almashtirish → keyingi kadr | 30.6 ms (max 35.8; n=18) | o‘sha usul |
| Til almashtirish → keyingi kadr | 66.4 ms (max 84.9; n=18) | o‘sha usul |
| Lokal qidiruv (ilova ichida, fixture indeks) | 1.37 ms (max 6.8; n=24) | `AppSearchService.latency` |
| content.db ochish (mavjud fayl) | 0.69–0.73 ms | `fe_database/tool/bench.dart`, host |
| FTS5 qidiruv, 15 000 sintetik termin | median 0.71 ms, p95 2.83 ms | o‘sha |
| Release APK (universal, 3 ABI) | 62.3 MB | `flutter build apk --release` (Lifetime ekrani qo‘shilishidan oldingi build) |

Izohlar:

- Navigatsiya raqamlariga integration-test harness va kadr kutish (vsync) vaqti ham kiradi, ya’ni bu yuqori chegara.
- Til almashtirish ~66 ms. Software renderda u bir necha kadrga cho‘ziladi va butun daraxtni qayta qurish bilan bog‘liq. Real qurilmada tekshiriladi (R-P2-03).
- Sozlamalarni o‘qish integration testda mock SharedPreferences bilan o‘lchangan (~30 µs), shuning uchun bu disk o‘qishi emas.

## 9. Tarjimalar

- EN / RU / UZ ARB to‘liq (parity testi).
- Hardcoded UI matni yo‘q (arxitektura testi).
- Har bir ekran 3 tilda render qilinadi.
- **RU va UZ matnlari professional review’dan O‘TMAGAN** (RG-11). Ular «reviewed» deb belgilanmagan.
- Reviewer alohida tekshirishi kerak bo‘lgan terminlar:
  - postmortem redistribution — «посмертное перераспределение» / «o‘limdan keyingi qayta taqsimlanish»;
  - chain of custody — «цепочка хранения доказательств» / «ashyoviy dalillarni saqlash zanjiri»;
  - femoral blood — «бедренная кровь» / «son venasi qoni»;
  - vitreous humour;
  - headspace GC-FID;
  - «Jurisdiction layer»;
  - legal status.
- O‘zgartirilgan matn: UZ qidiruv placeholder’i egasining talabi bilan «Moddalar, usullar, vositalar va manbalarni qidiring…» qilindi. Bu regressiya emas, spetsifikatsiya o‘zgarishi; PHASE 1 testi shunga yangilangan.

## 10. Bundle / Application ID — egasi uchun variantlar

Hozirgi ID **vaqtinchalik**:
- Android: `uz.forensicexpert.forensic_expert`;
- iOS: `uz.forensicexpert.forensicExpert`.

Store’da ro‘yxatdan o‘tgandan keyin ID’ni **o‘zgartirib bo‘lmaydi**.

| Variant | Misol | Afzallik | Kamchilik |
|---|---|---|---|
| A | `com.forensicexpert.app` | Global, neytral | `forensicexpert.com` domeni egalik qilinishi kerak (tekshirilmagan) |
| B | `app.forensicexpert.mobile` | Zamonaviy `.app` TLD | Domen egaligi kerak (tekshirilmagan) |
| C | `uz.forensicexpert.app` | Hozirgi holatga yaqin | «Faqat O‘zbekiston» taassurotini beradi va global pozitsiyaga zid |
| D | `<yuridik-shaxs-domeni>.forensicexpert` | Yuridik shaxsga bog‘langan | Yuridik shaxs hali aniqlanmagan (RG-01, RG-09) |

Tavsiya: avval domen va yuridik shaxsni hal qilish, keyin A yoki D variantini tanlash. Nom va logo trademark tekshiruvidan o‘tmagan (RG-06).

## 11. Logo

`design/logo/refined/REFINED_VARIANTS.md` faylida A3 asosida 3 ta variant bor: R1 Tailing Peak, R2 Integrated Peak, R3 Resolved Doublet.
- Har biri 1024 / 180 / 64 / 32 px, monoxrom siluet, Android adaptive (safe zone) va iOS mask preview’lari bilan.
- A3 safe zone’dan 21 % chiqardi. R1, R2 va R3 da bu ko‘rsatkich 0 %.
- Yakuniy tanlov egasiga qoldiriladi. Logo qulflanmagan.

## 12. Ochiq xavflar

| # | Xavf | Choralar |
|---|---|---|
| R-P2-01 | Real qurilmada perf va a11y (TalkBack / VoiceOver) o‘lchanmagan | RG-10 |
| R-P2-02 | Fixture’lar default yoqilgan (`FE_TEST_FIXTURES=true`) | RG-12: production build `--dart-define=FE_TEST_FIXTURES=false`; production’da kontent paketi TEST ma’lumotni rad etadi |
| R-P2-03 | Til almashtirish ~66 ms (desktop software render) | Real qurilmada o‘lchash; kerak bo‘lsa lokalizatsiyani qisman qayta qurish |
| R-P2-04 | RU/UZ terminologiya review qilinmagan | RG-11 |
| R-P2-05 | Privacy / Terms — DRAFT | RG-05 |
| R-P2-06 | Golden’lar Linux rasterizatsiyasiga bog‘liq | Tolerant komparator; CI ham Linux’da ishlaydi |
| R-P2-07 | Bepul demo hajmi (`AccessPolicy`: 3 yozuv / 1 kurs / 1 vosita) — taklif, tasdiqlanmagan; UI’da qulflash hali qo‘llanmagan (kontent TEST) | Egasi; kontent paydo bo‘lganda gating UI |
| R-P2-09 | `docs/05` xarajat modeli obuna asosida | RG-16 |
| R-P2-08 | Yurisdiksiya ro‘yxatidagi davlat nomlari (RU/UZ) review qilinmagan | RG-11 |
