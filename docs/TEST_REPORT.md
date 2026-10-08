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
