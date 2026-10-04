# 27 — Reviewer workflow (PHASE 7)

> **HUMAN VERIFIED = 0.** Reviewer ro‘yxati bo‘sh, review harakatlari yo‘q. Pipeline, rollar va paketlar tayyor — haqiqiy malakali mutaxassislar ulanishini kutadi (RG-19/21/23, RG-11, RG-15).

## 1. Rollar va ruxsatlar (`ReviewerRole`, `ReviewPermissions`)

| Rol | APPROVE / REJECT | FLAG_CONFLICT / FLAG_OUTDATED / REQUEST_CHANGE |
|---|---|---|
| Forensic Toxicology | `tox` | `tox` |
| Forensic Medicine | `fm` | `fm` |
| Laboratory / Analytical | `lab` | `lab` |
| Forensic Biochemistry | `fm`, `lab` | `fm`, `lab` |
| Legal / Jurisdiction | `legal` | `legal` |
| Translation | `i18n` (faqat tarjima) | `i18n` |
| Scientific Editor / Admin | **hech narsa** | barcha domenlar |

Tarjimon ilmiy yoki huquqiy claim’ni, huquqshunos ilmiy claim’ni, muharrir esa hech narsani tasdiqlay olmaydi.

## 2. Harakat (`ReviewAction`)

`APPROVE · REJECT · REQUEST_CHANGE · FLAG_CONFLICT · FLAG_OUTDATED` — har biri: reviewer ID, rol, domen, obyekt ID, **obyekt versiyasi**, kontent paketi versiyasi, vaqt (UTC), izoh.

`ReviewWorkflow.check` rad etadi:
* ro‘yxatda yo‘q yoki faol bo‘lmagan reviewer (soxta identitet yo‘q);
* rol domenga mos emas;
* eski versiyaga harakat (claim o‘zgargan — review qayta kerak);
* muallifning o‘z claim’ini tasdiqlashi;
* izohsiz REJECT / REQUEST_CHANGE / FLAG.

DB: `review_actions` (CHECK: APPROVE dan boshqasida izoh majburiy; `reviewer_id` → `reviewers` FK). Validator FE039.

## 3. Holat mashinasi

`awaitingReview → partiallyApproved (1 approve) → approved (2 mustaqil approve)`; `changesRequested`, `conflictFlagged`, `outdatedFlagged`; `rejected` ustun.

Status (VERIFIED/REVIEWED) **faqat** `StatusResolver` orqali: approve harakatlari `Review` ga aylanadi; VERIFIED = 2 turli malakali reviewer, kamida bittasi `canVerify`, DOI/PMID API orqali tekshirilgan. Ilova va pipeline o‘zi status yoza olmaydi (FE002/FE020).

## 4. Review paketlari

`content/tools/p7/review_packets.py` → `content/review/packets/<rol>/<id>.json` + `index.json` + `README.md`.

Har paket: claim (asl jumla, joy, taklif qilingan qiymat), manbalar (tier, litsenziya, hayot sikli va asosi, DOI/PMID/URL, locator), nima uchun muhim, ziddiyatlar, cheklovlar, qat’iy kontekst, tarjima holati, joriy status, kerakli rol va review soni, ruxsat etilgan harakatlar, reviewer cheklisti. Retraksiya qilingan manbali paket birinchi bandda buni ko‘rsatadi.

| Rol | Paket | Talab |
|---|---|---|
| forensic_toxicology | 71 | 2 |
| laboratory_analytical | 20 | 2 |
| forensic_medicine | 9 | 2 |
| forensic_biochemistry | 6 | 2 |
| legal_jurisdiction | 40 | 1 |
| **Jami** | **146** (6 tasida EVIDENCE CONFLICT, 1 tasida RETRACTED manba) | |

Umumiy navbat (`content/review/queue.json`, P5 vositasi): 881 element (835 → 881: yangi claim, qoida va tarjimalar).

## 5. Ilovada

Library → **Review status**: inson tomonidan tasdiqlangan 0, ko‘rib chiqilgan 0, kutayotgan, retraksiya qilingan manbali da’volar 1, ochiq ziddiyatlar 4, harakatlar 0, reviewerlar 0 — barchasi `content.db` dan hisoblanadi (hardcode emas). Rollar va ruxsatlar ro‘yxati.

## 6. Keyingi qadam (inson talab qiladi)

1. Har rol uchun haqiqiy, malakasi tekshirilgan reviewerlarni ro‘yxatga olish (ism, malaka, domen, `canVerify`).
2. Harakatlarni CMS yoki imzolangan PR orqali yozish → `review_actions`.
3. Paket qayta yig‘iladi; status resolver natijasi ilovada ko‘rinadi.
