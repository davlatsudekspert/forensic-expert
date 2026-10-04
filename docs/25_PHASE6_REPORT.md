# 25 — PHASE 6: Global platform expansion + product polish — hisobot

**Branch:** `claude/global-forensic-platform` (PHASE 5 ustiga; main’ga merge qilinmagan, PR ochilmagan, history qayta yozilmagan). Kontent paketi `2026.10.4`, DB schema **v5**, kanal `development`.

Batafsil: `docs/20` (arxitektura, fanlar, yurisdiksiya, manba/dalil ierarxiyasi), `docs/21` (reagent, ekspress test, biokimyo, metod/SOP/standart, kalkulyatorlar), `docs/22` (AI/RAG xavfsizligi), `docs/23` (review va lokalizatsiya workflow), `docs/24` (global kontent yo‘l xaritasi).

## 1. Nima o‘zgardi

| Soha | O‘zgarish |
|---|---|
| Taksonomiya | 20 forensic fan (`ForensicDiscipline`), 5 guruh; `DocumentKind` + `BindingNature`; kontent shablonlari (modda, metod, reagent, ekspress test, biomarker, FM mavzu); `ForensicRelevance`; yangi research turlari (guideline, validation study, case series), texnikalar (GC-MS/MS, LC-MS, HRMS, spektrofotometriya), emerging toifalari; `EmergingIssue.lastCheckedAt` |
| Yurisdiksiya | Hub, 249 ISO davlat tanlovchisi (CLDR nomlar, ISO kod, bayroqsiz, lazy), hujjat sahifasi barcha metadata bilan, «tekshirilmagan» holat, fallback yo‘q, Compare kirish nuqtasi |
| Home | Brend + qidiruv, yurisdiksiya konteksti, 12 asosiy bo‘lim (ixcham), «Barcha fanlar», faqat to‘lgan tezkor bloklar, yaqinda ko‘rilganlar (lokal), oflayn baza kartochkasi pastda |
| Library | Hub: ilmiy yozuvlar (moddalar, metodlar, reagentlar, ekspress testlar, namunalar, glossariy) + hujjatlar va dalillar (standartlar, research, manbalar, yurisdiksiyalar), haqiqiy sonlar; Standartlar ekrani |
| Modda sahifasi | «Shu sahifada» indeksi; manbasiz bo‘limlar bitta kartochkada; claim kartochkasida bitta meta-qator |
| Research | Fan, peer-reviewed, open access, davr filtrlari; hujjat turi, open access, forensik dolzarblik (alohida) |
| Qidiruv | Natijada kategoriya · manba turi/dalil · review holati; metabolitlar ota moddaga; EN/RU/UZ transliteratsiya |
| Kalkulyatorlar | +6: konsentratsiya birliklari / massa↔molyar, molyarlik, foizli eritma, statistika, kalibrlash (OLS), LOD/LOQ (ICH Q2(R1)) |
| AI | Huquqiy savolda yurisdiksiya talab qilinadi; rasmiy ekspert xulosasi bloklanadi; javob tuzilmasi: dalil holati, yurisdiksiya, bog‘liq yozuvlar |
| Ogohlantirishlar | CRITICAL / WARNING / INFO / REVIEW; skrining va konsentratsiya bannerlari CRITICAL |
| Lokalizatsiya | ~250 yangi kalit; rasm sarlavha/alt RU/UZ; sana yil bilan; avtomatik ekran-matn auditi |
| Billing / maxfiylik | `ProductTier` (Free / Student Pro / Professional Pro / Institution, narx kodda yo‘q, faqat store’dagi mahsulot xarid qilinadi); `TelemetryPolicy` |
| Navigatsiya | 5 ta pastki tab saqlandi (Home, Tools, Library, AI, Profile) |
| Brend | R2 o‘zgarmadi; trademark (RG-06) ochiq |

## 2. Kontent: REAL vs FIXTURE, VERIFIED vs NEEDS_REVIEW

* **Real (manbali) kontent:** 137 modda, 482 claim, 439 manba, 18 metod, 4 reagent, 7 ekspress test, FM 17 / gistologiya 6 / biokimyo 16 mavzu, 883 research, 156 rasm, 60 huquqiy qoida (INT INCB + GB pilot). **Hammasi NEEDS_REVIEW. VERIFIED: 0** (reviewer yo‘q).
* **Fixture (TEST DATA):** faqat testlarda (`FixtureLibraryRepository` va h.k.), ilovaning standart yig‘masida o‘chiq; fixture ekranlarida «TEST DATA» belgisi. PHASE 6 screenshotlari haqiqiy pilot paket bilan.
* PHASE 6 da yangi ilmiy fakt **qo‘shilmadi** (talab: minglab faktni sun’iy to‘ldirmaslik). Kontent o‘zgarishi: rasm sarlavha/alt tarjimalari, emerging `last_checked`.

## 3. Tekshiruvlar

| Tekshiruv | Natija |
|---|---|
| `flutter analyze --fatal-infos` / `dart analyze --fatal-infos packages` | ✅ No issues |
| Ilova testlari | ✅ **866 PASS · 0 FAIL · 1 SKIP** (PHASE 1 preview skrinshotlari, tag bilan) |
| Paket testlari | ✅ **214 PASS · 0 FAIL** (calc 32, package 15, pipeline 23, schema 97, database 26, search 21) |
| Jami | ✅ **1080 PASS · 0 FAIL · 1 SKIP** |
| Yangi PHASE 6 testlari | widget 28, lokalizatsiya auditi 44, kalkulyator 14, taksonomiya 7, perf 1 |
| Golden | ✅ 88 kadr (27 ta yangi PHASE 6) |
| Kontent validator | ✅ development — 0 xato; production — 576 × FE008 (kutilgan) |
| gitleaks (git) / OSV | ✅ leak yo‘q / 132 paketda zaiflik yo‘q |
| iOS statik | 11 PASS · 0 FAIL · 3 OPEN — **real iOS build bajarilmagan** (Xcode yo‘q) |
| Android APK | ✅ `apps/mobile/build/app/outputs/flutter-apk/app-release.apk` — 70.7 MB (70 653 236 bayt), SHA-256 `af2e527b…c3fd`; ⚠️ **Android Debug** sertifikati (RG-20); store’ga yuborilmagan |
| TalkBack / VoiceOver | ⛔ real qurilmada tekshirilmagan (RG-10); semantics testlari bor |

### Hujjatlashtirilgan test o‘zgarishlari
* `content_pack_test` → 137 modda (PHASE 5 dan).
* Profil yurisdiksiya testi: `JurisdictionPickerScreen` → `JurisdictionSelectScreen`; o‘chirilgan «Compare» yozuvi hub’ga ko‘chdi; lazy ro‘yxat sababli avval qidiriladi.
* Library ro‘yxati testlari `/library/section/substances` ga ko‘chdi (Library endi hub).
* `user_data_test`: yangi `fe.user.recently_viewed` kaliti.

## 4. Unumdorlik (host VM, JIT; qurilma emas)

`docs/perf/phase6_raw.txt`: Home birinchi kadr ~0.86 s (oflayn; AI/backend/billing kutilmaydi), navigatsiya 0.15–0.51 s, davlat tanlovchisi 1.03 s → **0.18 s** (lazy), til almashtirish ~0.87 s, mavzu ~0.52 s. Qidiruv median 33–40 ms (PHASE 5). Real qurilma o‘lchovi — RG-10.

## 5. Screenshotlar (`docs/screenshots/phase6/`, 27 ta)

01 til tanlash · 02 Home EN · 03 Home UZ dark · 04 Home RU · 05 Tools EN · 06 Tools RU dark · 07 Library hub UZ · 08 qidiruv EN (Methamphetamine) · 09 qidiruv RU dark (Метамфетамин) · 10 modda EN · 11 modda UZ dark · 12 analitik metod (GC-MS) · 13 reagent RU · 14 ekspress test UZ dark · 15 research EN · 16 maqola RU · 17 yurisdiksiya tanlovchisi UZ · 18 yurisdiksiya GB EN · 19 yurisdiksiya DE RU dark (tekshirilmagan) · 20 yurisdiksiya hub · 21 AI · 22 Learn UZ · 23 Profil RU dark · 24 fanlar · 25 LOD/LOQ · 26 Home RU 320dp ×1.3 · 27 yurisdiksiya UZ 320dp ×1.3.

## 6. Ochiq release blokerlar

RG-18 (server tomonida xarid tekshiruvi — **SECURITY**), RG-20 (release imzo), RG-10 (real qurilma, TalkBack/VoiceOver), RG-19/21/23 (domen reviewerlari, 835 element), RG-11 (RU/UZ tarjima review), RG-06 (trademark), RG-22 (AI backend/eval/kvota), RG-08 (privacy manifest), RG-24 (iOS Xcode/TestFlight), RG-15 (yurisdiksiya legal reviewerlari), RG-16 (store mahsulotlari: Student Pro / Institution yaratilmagan), **RG-25** (yangi: ICH Q2(R2) bilan LOD/LOQ koeffitsientlari mosligini lab reviewer tasdiqlashi).
