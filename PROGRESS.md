# FORENSIC EXPERT — Progress jurnali

| Sana | Phase | Holat | Izoh |
|---|---|---|---|
| 2026-10-04 | PHASE 0 | ✅ Tugadi | Arxitektura va mahsulot rejasi: `docs/00_ARXITEKTURA_REJASI.md` |
| 2026-10-04 | PHASE 0.5 | ✅ Tugadi | Evidence audit (72 band), raqobatchilar, source matrix, V1 scope, cost model (`docs/01`–`05`) |
| 2026-10-04 | PHASE 1 | ✅ Tugadi — **tasdiq kutilmoqda** | Foundation: 5 ta paket + Flutter ilova, CI, l10n, dizayn tizimi, onboarding, abstraksiyalar, logo prototiplari. 322 test o‘tdi, analyze toza. Hisobot: `docs/08_PHASE1_FOUNDATION.md`. **PHASE 2 boshlanmagan** |

## Branch’lar (main’ga merge qilinmagan)

| Branch | Mazmuni |
|---|---|
| `claude/phase-0-architecture-plan` | PHASE 0 |
| `claude/phase-0-5-evidence-audit` | PHASE 0.5 (PHASE 0 ustiga) |
| `claude/phase-1-foundation` | PHASE 1 (PHASE 0.5 ustiga) |

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
| RG-11 | RU/UZ UI tarjimalari va disclaimer matnlari review | ⛔ OCHIQ | `docs/08` 8-bo‘lim |

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
