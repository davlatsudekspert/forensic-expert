# FORENSIC EXPERT — Progress jurnali

| Sana | Phase | Holat | Izoh |
|---|---|---|---|
| 2026-10-04 | PHASE 0 | ✅ Tugadi | Arxitektura va mahsulot rejasi: `docs/00_ARXITEKTURA_REJASI.md` |
| 2026-10-04 | PHASE 0.5 | ✅ Tugadi | Evidence audit (72 band), raqobatchilar, source matrix, V1 scope, cost model (`docs/01`–`05`) |
| 2026-10-04 | PHASE 1 | ✅ Tugadi va tasdiqlandi | Foundation: 5 ta paket + Flutter ilova, CI, l10n, dizayn tizimi, onboarding, abstraksiyalar, logo prototiplari. 322 test. Hisobot: `docs/08_PHASE1_FOUNDATION.md` |
| 2026-10-04 | PHASE 2 | ✅ Tugadi va tasdiqlandi | Product UI: barcha asosiy ekranlar, Global Search, AI prototipi (iqtiboslar UX), Student/Pro rejimlari, Profil, **FORENSIC EXPERT Lifetime** (bir martalik xarid) ekrani, HC mavzu, golden suite, Global Scientific Core + Jurisdiction Layer, logo R1–R3. 607 test (+1 skip). Hisobot: `docs/09_PHASE2_PRODUCT_UI.md`, `docs/10_GLOBAL_JURISDICTION_LAYER.md`. |
| 2026-10-04 | PHASE 3 | ✅ Tugadi — **egasi tasdig‘i kutilmoqda** | Pilot kontent: 18 modda + 2 bog‘liq yozuv, 38 claim, 40 manba (barchasi NEEDS_REVIEW). Kontent pipeline, imzolangan paket, provenance UI, Lifetime (store tasdig‘i, Restore, server tekshiruvi porti), bepul demo, R2 brend. Hisobot: `docs/11_PHASE3_PILOT_CONTENT.md`, `docs/12_PURCHASE_VERIFICATION.md`. |
| 2026-10-04 | PHASE 4 | ✅ Tugadi — **egasi tasdig‘i kutilmoqda** | Global Forensic Knowledge System: sud tibbiyoti (25 mavzu), biokimyo, reagentlar, skrining, metodlar (4 tur), yangi muammolar, UK yurisdiksiyasi + Compare, Student Mode, Forensic AI arxitekturasi (LLM ulanmagan), DB v3, fe-bundle/2, FE017–FE027, premium dizayn. Pilot: 8 bilim obyekti, 11 claim, 13 manba (barchasi NEEDS_REVIEW). Hisobot: `docs/13`–`docs/17`. |
| 2026-10-04 | PHASE 5 | ✅ Tugadi — **egasi tasdig‘i kutilmoqda** | Global professional kontent: 137 modda (127 tasida adabiyot dalili, 58 tasida INCB), 482 claim (54 reported concentration — threshold emas), 18 metod, 4 reagent, 7 skrining, FM 17 / gistologiya 6 / biokimyo 16 mavzu, Research Library 883 yozuv (dissertatsiya 59, tezis 17, konferensiya maqolasi 36, tezis-abstract 0), 156 litsenziyali rasm, 849 graf bog‘lanishi, reviewer navbati 835. Barchasi NEEDS_REVIEW. 959 test. iOS build bajarilmagan (Xcode yo‘q). Hisobot: `docs/18`, `docs/19`. |
| 2026-10-04 | PHASE 6 | ✅ Tugadi — **egasi tasdig‘i kutilmoqda** | Global platform: 20 forensic fan taksonomiyasi, 3 qatlamli yurisdiksiya arxitekturasi (249 ISO davlat, fallback yo‘q, hujjat metadata), Home/Library hub qayta tuzildi, research filtrlari, DB v5 (forensik dolzarblik alohida), 6 yangi kalkulyator (LOD/LOQ — ICH Q2(R1)), AI yurisdiksiya qoidasi, CRITICAL/WARNING/INFO/REVIEW, RU/UZ ekran-matn auditi. Yangi ilmiy fakt qo‘shilmadi; hammasi NEEDS_REVIEW. 1080 test (+1 skip). Hisobot: `docs/20`–`docs/25`. |
| 2026-10-04 | PHASE 7 | ✅ Tugadi — **egasi tasdig‘i kutilmoqda** | Tasdiqlanadigan kontent pipeline’i: DB v6 (manba hayot sikli/ierarxiya/litsenziya, hisoblangan claim hayot sikli, dalil ziddiyatlari, reviewer rollari/harakatlari, metabolitlar, namunalar, standartlar, terminlar), FE033–FE041, retraksiya tekshiruvi (1 manba → 1 claim RETRACTED), 14 qat’iy konsentratsiya konteksti, 24 metabolit munosabati, 12 namuna, 4 ziddiyat, 7 standart, GB/US/DE/UZ huquqiy pilot (38 qoida), 146 review paketi, provenance UI, RG-18 server arxitekturasi (mock), RG-20 imzo konfiguratsiyasi, RG-25 tahlili. **HUMAN VERIFIED = 0.** Hisobot: `docs/26`–`docs/30`. **PHASE 8 boshlanmagan** |

## Branch’lar (main’ga merge qilinmagan)

| Branch | Mazmuni |
|---|---|
| `claude/phase-0-architecture-plan` | PHASE 0 |
| `claude/phase-0-5-evidence-audit` | PHASE 0.5 (PHASE 0 ustiga) |
| `claude/phase-1-foundation` | PHASE 1 (PHASE 0.5 ustiga) |
| `claude/phase-2-product-ui` | PHASE 2 (PHASE 1 ustiga) |
| `claude/phase-3-pilot-content` | PHASE 3 (PHASE 2 ustiga) |
| `claude/phase-4-global-forensic-system` | PHASE 4 (PHASE 3 ustiga) |
| `claude/phase-5-global-professional-content` | PHASE 5 (PHASE 4 ustiga) |
| `claude/global-forensic-platform` | PHASE 6 (PHASE 5 ustiga) |
| `claude/phase-7-verified-content-pipeline` | PHASE 7 (PHASE 6 ustiga) |

## RELEASE GATES (public release’dan oldin majburiy; development’ni to‘xtatmaydi)

| # | Gate | Holat | Manba |
|---|---|---|---|
| RG-01 | **Apple to‘lovlarini O‘zbekiston bankiga olish** — App Store Connect’da bank tanlash orqali amalda tasdiqlash; bo‘lmasa yuridik shaxs strategiyasi | ⛔ OCHIQ | `docs/01_EVIDENCE_AUDIT.md` O-01 |
| RG-02 | Google Play: O‘zbekiston QQS’ni dasturchi o‘zi undirishi (buxgalteriya) | ⛔ OCHIQ | `docs/05_COST_MODEL.md` 1.1 |
| RG-03 | CAS RN bo‘yicha CAS javobi / litsenziya qarori | ⛔ OCHIQ | `docs/07_POLICY_COMPLIANCE.md` 1.3 |
| RG-04 | Yo‘nalish bo‘yicha reviewerlar tayinlangan (tox, fm, lab, legal, i18n) | ⛔ OCHIQ | `docs/00` 22-bo‘lim |
| RG-05 | Professional yuridik review (legal checklist L-01…L-17) | ⛔ OCHIQ | `docs/00` 28-bo‘lim |
| RG-06 | Trademark (nom + logo) tekshiruvi va logo tasdig‘i | ⛔ OCHIQ | `design/logo/LOGO_PROTOTYPES.md` |
| RG-07 | Google Play: tavsifda «not a medical device…» disclaimer, Health apps deklaratsiyasi, Data safety | ⛔ OCHIQ | `docs/07` 2-bo‘lim |
| RG-08 | Apple: App Privacy, yosh reytingi anketasi, privacy manifest | ⛔ OCHIQ | `docs/01` C-11, C-12 |
| RG-09 | Application/Bundle ID va yuridik shaxs — yakuniy | ⛔ OCHIQ | `docs/08` R-05 |
| RG-10 | Real qurilmada perf, TalkBack/VoiceOver tekshiruvi | ⛔ OCHIQ | `docs/08` R-04 |
| RG-11 | RU/UZ UI tarjimalari va disclaimer matnlari review (PHASE 2 kalitlari va yurisdiksiya nomlari ham) | ⛔ OCHIQ | `docs/08` 8-bo‘lim, `docs/09` 9-bo‘lim |
| RG-12 | Production build’da TEST fixture’lar o‘chirilgan va ilovada TEST DATA ko‘rinmaydi | ✅ PHASE 3: fixture’lar standart o‘chiq (faqat testlarda) | `docs/11` 4-bo‘lim |
| RG-13 | Privacy Policy, Terms of Use, About — DRAFT matnlar yuridik review’dan o‘tishi | ⛔ OCHIQ | `docs/09` R-P2-05 |
| RG-14 | Logo tanlovi — egasi R2 ni tanladi; trademark (RG-06) tugamaguncha yuridik tasdiqlanmagan | ⏳ R2 tanlangan, RG-06 kutilmoqda | `design/logo/refined/REFINED_VARIANTS.md` |
| RG-16 | Lifetime modeli: App Store Non-Consumable va Google Play one-time product (`fe_lifetime_unlock`) store’larda yaratish, narxni storefront’larda belgilash, `docs/05` xarajat/daromad modelini qayta hisoblash, AI kvota siyosatini aniqlash | ⛔ OCHIQ | `docs/09` 6-bo‘lim |
| RG-17 | Public release yig‘masi `FE_CONTENT_CHANNEL=production` va review’dan o‘tgan, production kalit bilan imzolangan kontent paketi (hozirgi pilot — development, NEEDS_REVIEW) | ⛔ OCHIQ | `docs/11` 1, 4-bo‘lim |
| RG-18 | **Lifetime xaridini server tomonida tekshirish** (App Store Server API, Google Play Developer API, refund/revocation) va `FE_REQUIRE_SERVER_PURCHASE_VERIFICATION=true`. PHASE 7: server arxitekturasi `packages/fe_purchase_verification` (replay, idempotentlik, refund/revoke, fail closed) — **faqat mock bilan test qilingan**; haqiqiy kalitlar, backend va store bildirishnomalari yo‘q | ⛔ OCHIQ — **SECURITY / RELEASE BLOCKER** | `docs/12`, `docs/29` |
| RG-19 | Pilot claim’lar uchun tox/fm/lab reviewerlar (four-eyes) va RU/UZ nomlar review’i; PubChem stereoizomer CID’lari (tramadol, metamfetamin) va AlP CID tekshiruvi | ⛔ OCHIQ | `docs/11` 2-bo‘lim |
| RG-20 | Release imzolash: hozirgi release APK **debug sertifikat** bilan imzolangan. PHASE 7: Gradle `key.properties`/CI sirlaridan imzo, `-PrequireReleaseSigning=true` kalitsiz build’ni to‘xtatadi (tekshirildi); upload keystore, Play App Signing, Apple sertifikatlari — yaratilmagan | ⛔ OCHIQ | `docs/11` 8-bo‘lim, `docs/29` |
| RG-15 | Har bir yurisdiksiya kontenti uchun legal reviewer va rasmiy manba; «Compare jurisdictions» production’da faqat tekshirilgan kontent bilan (PHASE 4: UK pilot — NEEDS_REVIEW, faqat development kanalda) | ⛔ OCHIQ | `docs/10` 7-bo‘lim, `docs/14` |
| RG-21 | PHASE 4 bilim obyektlari (FM, biokimyo, reagent, skrining, metod, yangi muammolar) uchun domen reviewerlari; imtihon savollari faqat reviewer tasdiqlagan ta’lim kontentidan | ⛔ OCHIQ | `docs/15`, `docs/16` |
| RG-23 | PHASE 5–7 kontenti: 881 elementli reviewer navbati (PHASE 7: +146 review paketi, 4 ochiq ziddiyat, 1 RETRACTED claim) (scientific / analytical / medicine_histology / legal / translation), research dalil darajalari va 8 ta CC BY tashqi rasm attribution’ining legal tekshiruvi | ⛔ OCHIQ | `docs/19`, `content/review/REVIEW_QUEUE.md` |
| RG-24 | iOS: macOS/Xcode’da real build, TestFlight, real iPhone/iPad; privacy manifest (`PrivacyInfo.xcprivacy`) va export compliance (`ITSAppUsesNonExemptEncryption`) qarori. PHASE 5 da faqat statik tekshiruv (11 PASS / 3 OPEN) | ⛔ OCHIQ | `docs/19` 8-bo‘lim, `docs/verification/phase5_ios_static_check.txt` |
| RG-25 | LOD/LOQ kalkulyatori: PHASE 7 da ICH Q2(R2) §3.2.3.3 bilan solishtirildi — koeffitsientlar o‘zgarmagan, havola R2 ga ko‘chirildi (dvigatel 1.1.0). σ tanlash va forensik qo‘llanilishini laboratoriya reviewer’i tasdiqlashi | ⛔ OCHIQ | `docs/21` 5-bo‘lim, `docs/28` |
| RG-22 | Forensic AI: server provayderi, ikkinchi xavfsizlik qatlami, eval, kvota va narx siyosati (ilovada kalit yo‘q) | ⛔ OCHIQ | `docs/16` |

## PHASE 1 — majburiy tekshiruvlar

| Tekshiruv | Natija |
|---|---|
| flutter analyze / dart analyze (`--fatal-infos`) | ✅ No issues |
| Avtomatik testlar | ✅ 322 / 322 |
| Kichik ekran (320 dp) va katta shrift | ✅ 119 test; preview’da topilgan nav-label muammosi tuzatildi |
| Lokalizatsiya | ✅ ARB to‘liqligi, 3 tilda render, hardcoded matn yo‘q |
| Offline | ✅ Tarmoq taqiqlangan holda barcha ekranlar ishlaydi |
| Performance | ⚠️ O‘lchov infratuzilmasi tayyor; qurilmada hali o‘lchanmagan |
| Security | ✅ gitleaks — leak yo‘q; OSV — zaiflik yo‘q; repozitoriyda sir yo‘q |
| Critical / High bug | Yo‘q |

## PHASE 2 — majburiy tekshiruvlar

| Tekshiruv | Natija |
|---|---|
| flutter analyze / dart analyze packages (`--fatal-infos`) | ✅ No issues |
| Avtomatik testlar | ✅ 607 (ilova 491 + paketlar 116), 1 skip (PHASE 1 preview skrinshotlari) |
| PHASE 1 regressiyasi | ✅ 322 ta PHASE 1 testining barchasi o‘tadi. 1 ta kutilgan qiymat egasi talabi bilan o‘zgardi (UZ qidiruv placeholder’i) |
| a11y (tap target, label, kontrast) | ✅ 21 ekran × light / dark / HC light / HC dark |
| 320 dp × matn ×1 / ×1.3 / ×2 × EN / RU / UZ | ✅ overflow yo‘q |
| Golden / vizual regressiya | ✅ 26 kadr, CI’da |
| Offline | ✅ tarmoq taqiqlangan holda barcha ekranlar |
| Performance | ⚠️ Faqat Linux desktop (profile, software render) va host VM’da o‘lchandi. Mobil qurilmada o‘lchanmagan (RG-10) |
| CI | ✅ GitHub Actions run #4 — barcha joblar yashil (`docs/09` 13-bo‘lim) |

## PHASE 3 — majburiy tekshiruvlar

| Tekshiruv | Natija |
|---|---|
| flutter analyze / dart analyze packages (`--fatal-infos`) | ✅ No issues |
| Avtomatik testlar | ✅ 663 (ilova 532 + paketlar 131), 1 skip (PHASE 1 preview) |
| Golden / vizual regressiya | ✅ 30 kadr (4 tasi haqiqiy pilot kontent bilan) |
| Kontent validator | ✅ development — 0 xato; production — 48 × FE008 bilan rad etiladi (kutilgan) |
| Security: gitleaks / OSV | ✅ leak yo‘q / 132 paketda zaiflik yo‘q |
| Release APK | ✅ build (64.2 MB, universal); ⚠️ debug sertifikat bilan imzolangan (RG-20) |
| Real qurilma / emulator | ⛔ Muhitda yo‘q (KVM yo‘q) — RG-10 |
| Lifetime server tekshiruvi | ⛔ Yo‘q — RG-18 SECURITY / RELEASE BLOCKER |


## PHASE 4 — majburiy tekshiruvlar

| Tekshiruv | Natija |
|---|---|
| flutter analyze / dart analyze packages (`--fatal-infos`) | ✅ No issues |
| Avtomatik testlar | ✅ 880 (ilova 705 + paketlar 175), 1 skip (PHASE 1 preview) |
| Golden / vizual regressiya | ✅ 37 kadr (7 ta yangi PHASE 4 ekrani, haqiqiy pilot paket bilan) |
| a11y | ✅ 32 ekran (11 ta yangi) × light / dark / HC |
| Kontent validator | ✅ development — 0 xato; production — 67 × FE008 bilan rad etiladi (kutilgan); FE027 regressiya himoyasi faol |
| Security: gitleaks / OSV | ✅ leak yo‘q / 132 paketda zaiflik yo‘q |
| Release APK | ✅ build (65.8 MB, universal); ⚠️ debug sertifikat bilan imzolangan (RG-20). Store’ga yuborilmagan |
| Perf | ⚠️ Faqat host VM’da (`docs/13` 8-bo‘lim); qurilmada emas (RG-10) |
| Lifetime server tekshiruvi | ⛔ Yo‘q — RG-18 SECURITY / RELEASE BLOCKER (o‘zgarmagan) |


## PHASE 5 — majburiy tekshiruvlar

| Tekshiruv | Natija |
|---|---|
| flutter analyze / dart analyze packages (`--fatal-infos`) | ✅ No issues |
| `tool/ci_local.sh` | ✅ OK |
| Avtomatik testlar | ✅ 959 (ilova 766 + paketlar 193), 1 skip (PHASE 1 preview) |
| Golden / vizual regressiya | ✅ 61 kadr (24 ta yangi PHASE 5, 2 tasi iOS platformasi) |
| a11y | ✅ +9 PHASE 5 ekrani × light / dark (haqiqiy pilot paket) |
| Kontent validator | ✅ development — 0 xato; production — 576 × FE008 bilan rad etiladi (kutilgan) |
| Security: gitleaks / OSV | ✅ git tarixida leak yo‘q; katalogdagi 15 topilma faqat gitignore qilingan HTTP keshida (false positive) / 132 paketda zaiflik yo‘q |
| Release APK | ✅ build (70.0 MB, universal); ⚠️ debug sertifikat bilan imzolangan (RG-20). Store’ga yuborilmagan |
| iOS | ⚠️ Faqat statik tekshiruv (11 PASS / 0 FAIL / 3 OPEN). **Real iOS build bajarilmagan** (RG-24) |
| Perf | ⚠️ Faqat host VM’da (`docs/19` 9-bo‘lim); qurilmada emas (RG-10) |
| Lifetime server tekshiruvi | ⛔ Yo‘q — RG-18 SECURITY / RELEASE BLOCKER (o‘zgarmagan) |

## PHASE 6 — majburiy tekshiruvlar

| Tekshiruv | Natija |
|---|---|
| flutter analyze / dart analyze packages (`--fatal-infos`) | ✅ No issues |
| Avtomatik testlar | ✅ 1080 PASS (ilova 866 + paketlar 214), 0 FAIL, 1 SKIP (PHASE 1 preview) |
| Lokalizatsiya | ✅ RU/UZ ekran-matn auditi (22 ekran × 2 til), ARB parity |
| Golden | ✅ 88 kadr (27 ta yangi PHASE 6, EN/RU/UZ, light/dark, 320dp ×1.3) |
| Kontent validator | ✅ development — 0 xato; production — 576 × FE008 (kutilgan) |
| Security: gitleaks / OSV | ✅ leak yo‘q / zaiflik yo‘q |
| Release APK | ✅ 70.7 MB; ⚠️ debug sertifikat (RG-20). Store’ga yuborilmagan |
| iOS | ⚠️ Faqat statik (11 PASS / 3 OPEN). Real build yo‘q (RG-24) |
| Perf | ⚠️ Host VM (`docs/perf/phase6_raw.txt`); qurilmada emas (RG-10) |
| Lifetime server tekshiruvi | ⛔ Yo‘q — RG-18 SECURITY / RELEASE BLOCKER (o‘zgarmagan) |

