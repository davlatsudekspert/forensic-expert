# TEST REPORT

Oxirgi yangilanish: 2026-10-08 (lokal, Linux konteyner; real qurilma emas).

| Sana | Commit | Nima | Natija |
|---|---|---|---|
| 2026-10-08 | c7e4a2c | `test/widget/guidelines_test.dart` + architecture | 11/11 PASS |
| 2026-10-08 | f50246a | retrieval_relevance + rag_pipeline + ai_architecture | 38/38 PASS |
| 2026-10-08 | f50246a | guidelines_content + guidelines widget | 9/9 PASS |
| 2026-10-08 | 6b898a7 | rag_pipeline + phase9_ai widget | 28 PASS; phase9 4/4 PASS |
| 2026-10-08 | 6b898a7 | flutter analyze | No issues |
| 2026-10-08 | 860e9d3 | to‘liq suite (dizayn + l10n + maqolalar + 7 karta birlashtirilgandan keyin) | **2251 PASS, 1 skip, 0 FAIL** |
| 2026-10-08 | a80e5fe | to‘liq suite (lokal) | 2185 PASS, 1 skip, 4 FAIL → 2 golden (kutilgan, yangilandi), qidiruv guruh tartibi (test yangilandi), 1 a11y (alohida PASS, yuklama sababli) |
| 2026-10-06 | bf342be | to‘liq suite (oldingi bosqich) | 2152 PASS (goldenlar yangilangach) |

To‘liq suite va goldenlar agentlar birlashtirilgandan keyin qayta ishga tushiriladi (shu jadvalga yoziladi).
Edge function (`ai-answer`) uchun Deno type-check bu muhitda yo‘q — deploydan oldin tekshirilishi kerak.

**CI holati (2026-10-08):** GitHub Actions barcha ishga tushirishlarda `startup_failure` (hisob darajasida — ehtimol Actions daqiqalari/billing). Workflow YAML’lari to‘g‘ri. Egasi GitHub Billing’ni tekshirishi kerak.


## Premium dizayn (2026-10-17, branch `claude/design-premium`)

Asos: `claude/ux-polish`. Lokal Linux konteyner; real iOS/Android qurilma emas.

| Nima | Natija |
|---|---|
| `flutter analyze --fatal-infos`, `dart format --set-exit-if-changed` | No issues / 0 changed |
| Ta’sirlangan testlar (widget, a11y, l10n, unit, architecture) | 2664 PASS; yangi: `teacher_panel_test` (4), `nav_inset_test` (3: talaba/mutaxassis 390, talaba 320 — har ekranda kontent menyu ostida qolmaydi), `method_short_name_test` (2) |
| Goldenlar | 210 tasi ongli yangilandi (global tema: AppBar 20 sp serif, radius 14→20, mayin soya, palitra, banner chiziqsiz, holat chipi, usul chiplari, nomlar). Turlar: final 31, phase6 27, registration 26, phase7 26, phase5 24, polish 12, referral 9, phase4 7, release 6, trilingual 4, pilot 4, lux 4, home 4, qolgan 26 (admin/support, search, tools, ai, onboarding, language, entry, chain, typography, learn, library, jurisdiction, quiz, profile) |
| Real-app harness (Linux, Xvfb, MOCK, tarmoq o‘chiq) | STUDENT 46/46, EXPERT 37/37, ADMIN 23/23, UX-AUDIT 57/57 (+5 ustoz paneli qadami, qorong‘i/320 ustoz paneli va modda), nopaywall talaba/mutaxassis 15/15 va admin 22/22 × uz/ru/en — hammasi PASS |
| Ekranlar katalogi (`--tags catalog`) | 409 render (162 holat; uz yorug‘ + qorong‘i, muhimlari ru/en/320), Flutter xatosi/overflow 0 |
| To‘liq `flutter test` (bir marta, oxirida) | **2887 PASS, 2 skip, 0 FAIL** |
| Sinalmagan | real iOS/Android qurilma (shrift, safe area, Reduce Motion OS sozlamasi), haqiqiy Supabase’da ustoz roli va sinf (faqat demo/soxta server), haqiqiy CSV ulashish oynasi |

## Integratsiya 0.3.0 (2026-10-17, branch `claude/integration-0.3.0`)

Birlashtirilgan: no-paywall → analysis-structure → admin-ext → apple-revoke (social-sign-in bilan) → class-quiz (asos: `claude/phase-8-12-final-release`, ABY’siz). Lokal Linux konteyner; real qurilma emas.

| Nima | Natija |
|---|---|
| `flutter analyze --fatal-infos` (app) / `dart analyze --fatal-infos packages` | No issues / No issues |
| To‘liq `flutter test` (bir marta, goldenlar yangilangandan keyin) | **2913 PASS, 1 skip, 3 FAIL** → 3 tasi tuzatildi va alohida qayta sinaldi (13/13 PASS): arb_parity (class-quiz «DEMO», `{code} · {status}`, `{seconds} s`), phase11 (class-quiz QR uchun CAMERA ruxsati, `required=false`) |
| Goldenlar | konflikt/no-paywall tufayli yiqilgan 58 tasi `--update-goldens` bilan yangilandi (Pro belgisi/obuna qatori yo‘q, ABY’siz Tahlil, admin-ext profil qatorlari); tolerans ichida qayta yozilgan 11 tasi qaytarildi |
| Paketlar (`dart test`, 7 paket) | hammasi PASS (fe_content_pipeline: C-AS-* iqtiboslari faqat uz — egasi til tartibi bo‘yicha test moslandi) |
| SQL `supabase/tests/run_local.sh` (vaqtinchalik PostgreSQL 16) | hammasi PASS, RLS matritsa PASS (class_quiz_test fixture id’lari 79000000-* ga o‘zgartirildi; class_quiz migratsiyasi 20261017010000 ga ko‘chirildi — admin_extension bilan versiya to‘qnashuvi) |
| `translation_qa.py` / `claim_source_audit.py --check` / `analysis_structure_audit.py --check` | 0 xato / OK / OK |
| Kontent build (development, vaqtinchalik katalog) | warnings=0; ilovadagi `content.db` bundle.json bilan bir xil (faqat `built_at` farq) — qayta yig‘ish kerak bo‘lmadi |
| Real-app harness (Linux, Xvfb, MOCK) | STUDENT 40/6, EXPERT 37/0, ADMIN 23/0, nopaywall 15/0. STUDENT’dagi 6 FAIL (s12–s16, s18) asosiy shoxda ham aynan shunday (43/6) — integratsiyadan emas (kirgandan keyingi snackbar AI tugmasini to‘sadi, keyingi qadamlar zanjirli yiqiladi). Pro/paywall qadamlari «hamma ochiq» tekshiruviga almashtirildi |
| Sinalmagan | real iOS/Android qurilma, haqiqiy Google/Apple kirish va Apple token revoke (Deno yo‘q — `apple_revoke_test.ts` ishga tushirilmadi), teacher roli real-app harnessda (faqat widget/unit/SQL testlari), haqiqiy Supabase’ga migratsiya/deploy (qilinmadi) |

## Sinfda test (2026-10-17, branch `claude/class-quiz`)

| Nima | Natija |
|---|---|
| SQL: `bash supabase/tests/run_local.sh` (PostgreSQL 16; `class_quiz_test.sql` + RLS matritsa yangi 7 jadval bilan) | **472 PASS, 0 FAIL** (shundan ~120 ta sinf testi) |
| `test/unit/class_quiz_test.dart` (kod, laqab filtri, ball, aralashtirish, CSV, JSON, bank formati) | 28/28 PASS |
| `test/unit/class_quiz_fake_test.dart` (Fake adapter = server qoidalari, to‘liq oqim) | 26/26 PASS |
| `test/unit/class_quiz_supabase_test.dart` (RPC adapteri, xato xaritasi) | 5/5 PASS |
| `test/widget/class_quiz_test.dart` (ustoz UI oqimi, talaba UI oqimi, rol, 320 dp qorong‘i, 16:9 landshaft, deep link) | 10/10 PASS |
| `flutter analyze` | No issues |
| Arxitektura/l10n/a11y/to‘liq suite | **ISHGA TUSHMADI** — sandbox diski to‘lgan (`No space left on device`). Qo‘lda statik tekshiruv: hardcoded matn yo‘q, TextField/onTapOutside/keyboardDismiss mos, ARB 3 tilda 2776 kalit. CI/lokal qayta ishga tushirilishi shart. |


## UX polish + Pro tozalash (2026-10-17, branch `claude/ux-polish`)

| Nima | Natija |
|---|---|
| `flutter analyze --fatal-infos` | No issues |
| To‘liq `flutter test` (bir marta, oxirida) | 2873 PASS, 1 skip, 2 FAIL → tuzatildi va qayta sinaldi (support_admin_test: snackbar bannerni yopib turadi — test snackbar’ni tozalaydi; supabase_support_test: `p_tier` olib tashlandi): 15/15 PASS. Goldenlar o‘zgarmadi (tolerans ichida) |
| Real-app harness (Linux, Xvfb, MOCK) | STUDENT 46/46 (avval 40/6), EXPERT 37/37, ADMIN 23/23, UX-AUDIT 48/48 |
| `nopaywall` (Pro/tarif/qulf so‘zi yoki ikonkasi = 0) | STUDENT, MUTAXASSIS, ADMIN × uz/ru/en: 15/15, 15/15, 22/22 PASS (9 yurish) |
| Sinalmadi | real iOS/Android qurilma, haqiqiy OTP/Google/Apple, haqiqiy Supabase; eski `qa_court/qa_pro_tools/qa_reading/qa_reagents` harnesslari (Pro tarmoqlari eskirgan — ishga tushirilmadi) |
