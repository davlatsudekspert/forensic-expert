# FORENSIC EXPERT — Progress jurnali

| Sana | Phase | Holat | Izoh |
|---|---|---|---|
| 2026-10-04 | PHASE 0 | ✅ Tugadi | Arxitektura va mahsulot rejasi: `docs/00_ARXITEKTURA_REJASI.md` |
| 2026-10-04 | PHASE 0.5 | ✅ Tugadi | Evidence audit (72 band), raqobatchilar, source matrix, V1 scope, cost model (`docs/01`–`05`) |
| 2026-10-04 | PHASE 1 | ✅ Tugadi va tasdiqlandi | Foundation: 5 ta paket + Flutter ilova, CI, l10n, dizayn tizimi, onboarding, abstraksiyalar, logo prototiplari. 322 test. Hisobot: `docs/08_PHASE1_FOUNDATION.md` |
| 2026-10-04 | PHASE 2 | ✅ Tugadi — **egasi tasdig‘i kutilmoqda** | Product UI: barcha asosiy ekranlar, Global Search, AI prototipi (iqtiboslar UX), Student/Pro rejimlari, Profil, **FORENSIC EXPERT Lifetime** (bir martalik xarid) ekrani, HC mavzu, golden suite, Global Scientific Core + Jurisdiction Layer, logo R1–R3. 607 test (+1 skip). Hisobot: `docs/09_PHASE2_PRODUCT_UI.md`, `docs/10_GLOBAL_JURISDICTION_LAYER.md`. **PHASE 3 boshlanmagan** |

## Branch’lar (main’ga merge qilinmagan)

| Branch | Mazmuni |
|---|---|
| `claude/phase-0-architecture-plan` | PHASE 0 |
| `claude/phase-0-5-evidence-audit` | PHASE 0.5 (PHASE 0 ustiga) |
| `claude/phase-1-foundation` | PHASE 1 (PHASE 0.5 ustiga) |
| `claude/phase-2-product-ui` | PHASE 2 (PHASE 1 ustiga) |

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
| RG-12 | Production build’da TEST fixture’lar o‘chirilgan (`--dart-define=FE_TEST_FIXTURES=false`) va ilovada TEST DATA ko‘rinmaydi | ⛔ OCHIQ | `docs/09` R-P2-02 |
| RG-13 | Privacy Policy, Terms of Use, About — DRAFT matnlar yuridik review’dan o‘tishi | ⛔ OCHIQ | `docs/09` R-P2-05 |
| RG-14 | Logo tanlovi (A3 / R1 / R2 / R3) — faqat egasi qarori, keyin trademark (RG-06) | ⛔ OCHIQ | `design/logo/refined/REFINED_VARIANTS.md` |
| RG-16 | Lifetime modeli: App Store Non-Consumable va Google Play one-time product (`fe_lifetime_unlock`) store’larda yaratish, narxni storefront’larda belgilash, `docs/05` xarajat/daromad modelini qayta hisoblash, AI kvota siyosatini aniqlash | ⛔ OCHIQ | `docs/09` 6-bo‘lim |
| RG-15 | Har bir yurisdiksiya kontenti uchun legal reviewer va rasmiy manba; «Compare jurisdictions» faqat tekshirilgan kontent bilan | ⛔ OCHIQ | `docs/10` 7-bo‘lim |

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

