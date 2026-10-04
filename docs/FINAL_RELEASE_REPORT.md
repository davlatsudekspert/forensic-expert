# FINAL RELEASE REPORT — FORENSIC EXPERT (PHASE 8–12)

Sana: 2026-10-04 · Branch: `claude/phase-8-12-final-release` · Batafsil artefaktlar: `FINAL_ARTIFACT_MANIFEST.md` · Ro‘yxat: `FINAL_RELEASE_CHECKLIST.md`.

> Bu **ichki release-candidate tayyorgarligi**. Store’ga yuborilmagan, App Review yo‘q, ommaviy release yo‘q. Kontent ekspert tomonidan tekshirilmagan (HUMAN VERIFIED = 0).

## Fazalar
| Faza | Holat | Asosiy natija | Hujjat |
|---|---|---|---|
| PHASE 8 — ilmiy kengaytma | DONE | retsept/ekspress test/metod dalil turi maydonlari (FE042), fan xaritasi, 5 yangi manbali mavzu (7 claim) | `31_…` |
| PHASE 9 — AI / RAG | DONE (mock provayder) | provenance retrieval, manba ustuvorligi, retracted chiqarib tashlash, DOI/PMID butunligi, rad etish holatlari, yurisdiksiya talabi | `32_…` |
| PHASE 10 — huquq | DONE | 249 davlat katalogi, kontent faqat 5 yurisdiksiyada; 14 domen; yozuv to‘liqligi; o‘zgarishni aniqlash (avtomatik nashr yo‘q) | `33_…` |
| PHASE 11 — tarif/xavfsizlik/release | PARTIAL | RG-18 holatlari + restore (mock); xavfsizlik auditi; Android AAB/APK (DEBUG imzo); iOS CI imzosiz arxiv; TestFlight credentials yo‘q | `34_…` |
| PHASE 12 — yakuniy audit | DONE (cheklovlar bilan) | UI auditi 320dp ×2.0 EN/RU/UZ (1 overflow tuzatildi), to‘liq test matritsasi, skanerlar, CI yashil | shu hujjat |

## Audit natijalari
* **Birinchi ishga tushirish:** til → disklaymer → rejim (`first_launch_test.dart`), onboarding ekranlari 320dp ×1.0/1.3/2.0/3.0 da overflow’siz.
* **Lokalizatsiya:** hardcoded matn yo‘q (architecture test), ARB parity, RU/UZ rendered-language audit — aralash til yo‘q.
* **Yakuniy UI auditi (yangi):** 15 ta PHASE 7–11 ekrani × 3 til, haqiqiy pilot paket, pastgacha aylantirib — 45 test. Topildi: yurisdiksiya «huquqiy domenlar» ro‘yxatida `trailing` matn overflow (RU/UZ/EN, ×2.0) → `subtitle` ga ko‘chirildi.
* **Impeccable:** NOT AVAILABLE (asbob mavjud emas; o‘xshash nomli paketlar o‘rnatilmadi).
* **Brauzer auditi:** qo‘llanmaydi — ilovada web target yo‘q.
* **Oflayn:** `offline_test.dart` — barcha asosiy ekranlar tarmoqsiz; kontent imzolangan lokal paketdan.
* **Perf:** faqat Linux VM (`docs/perf/phase7_raw.txt`: cold start → Home ≈ 0.9 s, provenance yuklash ≈ 44 ms, qidiruv mediani ≈ 43 ms). Real qurilma o‘lchovi yo‘q (RG-10).
* **Ilmiy audit:** 497 claim NEEDS_REVIEW; production kanal faqat FE008 bilan rad etiladi (633) — review’siz kontent production’ga kira olmaydi. VERIFIED 0, HUMAN VERIFIED 0, RETRACTED manba 1 (chiqarib tashlanadi), ziddiyat 4.
* **Xavfsizlik:** gitleaks (to‘liq tarix) toza; OSV (132 paket) zaiflik yo‘q; sirlar repozitoriyda yo‘q.

## Test matritsasi
Ilova 1002 PASS / 0 FAIL / 1 SKIP; paketlar 251 PASS → **1253 PASS, 0 FAIL, 1 SKIP**. `flutter analyze` / `dart analyze --fatal-infos` / `dart format` — toza.

## CI
* `a937da4`: CI ✅ success (run 37239093611); Release build ✅ success (run 37239093623).
* PHASE 9 commit (`3d7aed8`) CI qizil edi (paket testida 2 ta `prefer_const` info) — keyingi commitda tuzatilgan; PHASE 11 commit (`a93e2a1`) CI qizil edi (3 profil golden) — `a937da4` da tuzatilgan.

## Ochiq release blockerlar
RG-18 (server xarid tekshiruvi — SECURITY), RG-20 (Android upload key), RG-24 (Apple imzo / TestFlight), RG-10 (real qurilma), RG-19/21/23 (domen reviewerlari; 888 element), RG-11 (RU/UZ tarjima review), RG-15 (legal review), RG-25 (lab reviewer), RG-22 (AI backend), RG-16 (store mahsulotlari), RG-08 (privacy — iOS manifest qo‘shildi, store privacy javoblari tasdiqlanmagan), RG-06 (trademark).
