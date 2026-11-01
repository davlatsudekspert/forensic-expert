# PROJECT STATUS — FORENSIC EXPERT

Yangilangan: 2026-10-08 · Branch: `claude/phase-8-12-final-release` · Audit asosi: HEAD `cd1fe66` (Phase A, read-only).
Statuslar: WORKING (avtomatik test yoki real sinov dalili bor) · IMPLEMENTED-UNVERIFIED · PARTIAL · MOCK/DEMO · MISSING · BLOCKED.
"Real qurilmada sinalgan" — faqat egasi qayd etgan holatlar; emulyator (BlueStacks) real qurilma emas.

| Komponent | Status | Izoh / dalil |
|---|---|---|
| Home | WORKING (avtomatik) | widget + golden testlar; real qurilma chek-listi to‘ldirilmagan |
| Ilmiy kutubxona | WORKING (kod), kontent ko‘rilmagan | 137 modda, 75 bilim yozuvi, 497 claim, 457 manba — hammasi NEEDS_REVIEW |
| Fanlar taksonomiyasi | PARTIAL (tuzilma to‘liq, kontent kam) | 26 fan, kriminalistika guruhi; yangi fanlarda kontent hali yo‘q (soxta kontent qo‘shilmaydi) |
| Qidiruv (asosiy) | PARTIAL | InMemorySearchIndex; FTS5 jadvali runtime’da ishlatilmaydi; fan filtri yo‘q |
| AI offline qidiruvi (RAG retrieval) | WORKING (2026-10-08 tuzatildi) | IDF + bo‘sag‘a, umumiy so‘zlar filtri, apostrof, UZ/RU→EN kengaytma; regressiya testi `test/unit/retrieval_relevance_test.dart` |
| AI ekrani | WORKING (avtomatik) | 1 savol = 1 server so‘rovi; xato sababi ko‘rsatiladi; manbasiz model matni ko‘rsatilmaydi; oflayn tugma serverga chiqmaydi |
| Gemini (`ai-answer`) | IMPLEMENTED-UNVERIFIED (v5 deploy qilingan 2026-10-08) | egasi ruxsati bilan v5: 45 s muddat, urinish byudjeti, discovery timeout; JWT himoyasi tekshirildi (401); real savol-javob E2E qaydi hali yo‘q |
| Email OTP | IMPLEMENTED-UNVERIFIED (egasi BlueStacks’da kirgan) | Resend domeni tasdiqlanmagan → xatlar spamga; `config.toml` endi `verify_jwt=false` bilan mos |
| Supabase migratsiyalar + RLS | WORKING | CI `db-security` SQL testlari; `advisor_hardening` migratsiya tarixida yo‘q |
| Billing | BLOCKED | server xarid tekshiruvi yo‘q (RG-18); 4 obuna mahsuloti kodda, lifetime yo‘q; do‘konlarda mahsulot yaratilmagan |
| Admin panel + server grant | WORKING (egasi sinagan) | Pro egasiga berilgan |
| Yo‘riqnomalar | WORKING (avtomatik), kontent NEEDS_REVIEW | 7 karta (etanol GX, diatom, bo‘y uzunligi, YuQX, postmortem talqin, namuna preanalitikasi, metodlar solishtiruvi), 76 tekshirilgan manba; Home va global qidiruvda; admin yopiq katalogi qurilmadan import |
| Kalkulyatorlar | WORKING | 12 vosita (Widmark, teskari hisob, etanol birliklari, Henssge 2026-10-06 qo‘shilgan) |
| O‘quv rejimi | PARTIAL / MOCK | quiz va flashcards production’da bo‘sh |
| Research workspace | PARTIAL | faqat lokal sevimlilar/tarix; izoh, to‘plam, sinxron yo‘q |
| Expert Publications | IMPLEMENTED (migratsiya production’da, 2026-10-08, egasi ruxsati bilan) | RPC + RLS, moderatsiya holat mashinasi, audit; lokal SQL 62 PASS; production smoke (rollback bilan): save_draft → submit → can_moderate → FORBIDDEN_OWN; advisors: faqat kutilgan RPC ogohlantirishlari; UI faqat admin yoki `FE_PUBLICATIONS` bayrog‘i bilan |
| Lokalizatsiya | WORKING | 3 til teng kalitlar; `uz_completeness_test` (inglizcha UI so‘zlari yo‘q) |
| Iqtibos tarjimalari (2026-10-09) | PARTIAL | 357 claim + 2 qoida iqtibosi uz/ru avtomatik tarjima (`machine_draft`, «tekshirilmagan» belgisi, asl inglizcha matn birinchi; SHA-256 bilan eskirish nazorati, FE043, DB CHECK); bo‘lim kodlari (ABSTRACT/INTRO/DISCUSS…) lokal nom bilan; 883 tadqiqot sarlavhasi tarjimasi HALI YO‘Q (infratuzilma tayyor: `content/pilot/translations/research_titles_i18n.json`) |
| Dizayn tizimi | WORKING (avtomatik) | Scientific Luxury: graphite/navy/noir + champagne gold, ivory; Source Serif 4 (OFL); kontrast testi 93/93 |
| Offline paket + Ed25519 | WORKING (development kalit) | production imzo kaliti/kanal yo‘q |
| CI | WORKING | format, analyze, test, db-security, gitleaks |
| HUMAN VERIFIED kontent | MISSING (0) | reviews=0 |
| ABY 2025 | INTERNAL_RESTRICTED | faqat admin qurilmasida katalog (repo/CI/server yo‘q); fayllar konteyner qayta ishga tushganda yo‘qolgan — egasi qayta yuklashi kerak |

## Ishga tushirishga to‘sqinliklar (Release blockers)
1. Server xarid tekshiruvi (RG-18) va do‘kon mahsulotlari — egasi.
2. Android release keystore / Play yuklash — egasi.
3. Production kontent imzo kaliti va kanal.
4. Human review: 0 ta tasdiqlangan yozuv.
5. Gemini real E2E qaydi (v5 deploy qilingan; telefonda savol bilan sinov kerak).
6. Resend domen tasdig‘i (OTP xatlari spam).

## Buildlar (0.4.0, `claude/pro-0.4.0`)
- **Build 40** (0.4.0+40): Play internal + TestFlight, keyin Play rollout — bajarilgan.
- **Build 42** (0.4.0+42, commit `0a9b29e`, 2026-11-01): release run 41327144953 yashil (Android + iOS/TestFlight), Play rollout run 41328690448 yashil. APK: aapt2 versionCode 42, SHA256 `49946618…aec1ca6` SHA256SUMS bilan mos; egasiga yuborildi. Tarkibi: Asosiy panel takrorlarsiz (DNK/kalkulyator/AI/sudda so‘roq/o‘qish — stollarda), «Yangi bo‘limlar» qatori, Profil → «Shrift o‘lchami» (1.0/1.15/1.3), DNK kartasi matni chapda, DNK bo‘limi, murda o‘zgarishlari sxemalari, KZ/KG/TJ qo‘shni davlatlar, yangi alifbo tugmasi. Testlar 3755 o‘tdi; QA ustoz 86/86, talaba 46/46, ekspert 37/37 (real qurilma/TV sinovi yo‘q). 8 ta dars (ktp26-u-30/33/38/39/49/50/52, toks-15) DBda qayta yozildi; zaxira `backup.lesson_decks_20261101`, `backup.class_quiz_questions_20261101`. `app_config.min_build` hali 0 — egasi iPhone’da TestFlight 42 ni ko‘rgach 42 ga qo‘yiladi.
- **Build 41** (0.4.0+41, commit `2e3e6c1`, 2026-11-01): release run 41293999454 yashil (Android + iOS). Play rollout dispatch qilindi. APK: aapt2 versionCode 41, SHA256SUMS mos; egasiga yuborildi. Tarkibi: «Asbob-uskunalar» bo‘limi (17 ta karta, illyustratsiyalar), virtual autopsiya, «Sudda so‘roq» kengaytmasi (97 savol, 1152-son qonun, kimyogar vakolat chegarasi, aniqlash muddatlari), «Manba keltirilgan» yozuvlari.
- Release build’da `FE_PRO_STRICT` yo‘q, ya’ni Pro qulflari foydalanuvchiga ko‘rinmaydi. Ekran katalogidagi qulflar faqat test sozlamasidan chiqqan.
