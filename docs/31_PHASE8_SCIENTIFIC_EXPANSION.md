# 31 — PHASE 8: professional ilmiy kengaytma

> **HUMAN VERIFIED = 0.** Yangi barcha claim’lar NEEDS_REVIEW. Ommaviy fakt generatsiyasi qilinmadi.

## 1. Model kengaytmalari (manbasiz qiymat kiritib bo‘lmaydi)

| Obyekt | Yangi maydonlar | Qoida |
|---|---|---|
| Reagent / eritma (`SolutionRecipe`) | konsentratsiya, erituvchi, pH, yaroqlilik muddati, PPE, ingredient tozaligi/sinfi, kalkulyator havolalari | har biri `SourcedValue`/`SourcedNote`; manba ID’si ma’lum bo‘lishi shart (FE018, FE022) |
| Ekspress test (`ScreeningTest`) | natija turi (sifat/yarim miqdoriy), interferensiyalar, kontekstli aniqlash oynasi | manbali; tasdiqlovchi metod majburiy (FE021); skrining ≠ tasdiqlash CRITICAL |
| Metod (`MethodRecord`) | `MethodEvidenceType`: xalqaro standart · qo‘llanma · nashr etilgan validatsiyalangan metod · milliy metodika · mahalliy SOP havolasi · ta’limiy umumlashma | FE042: «standart» rasmiy/standart manbasiz, «validatsiyalangan» manbasiz — rad |
| Mavzu (`KnowledgeTopic`) | aniq fan (`discipline`) | fan sahifasida «Manbali mavzular» |

To‘liq shablon: reagent va ekspress test sahifalari barcha maydonlarni ko‘rsatadi; manbasizi «manbali emas». Mavjud 4 reagentda manbali retsept **yo‘q** — retsept to‘qilmadi (`reagent.noRecipe`). 18 metodning barchasi «ta’limiy umumlashma» (adabiyotdan; laboratoriya uchun validatsiya da’vosi yo‘q).

## 2. Yangi manbali mavzular (PMC OA asl matn, `tools/p8/find_p8_sentences.py`)

| Fan | Mavzu | Claim |
|---|---|---|
| Sud genetikasi | DNK profillash (STR) | tamoyil; cheklov (degradatsiya) |
| Sud entomologiyasi | entomologiya va PMI | tamoyil (mPMI); harorat–rivojlanish bog‘liqligi |
| Sud mikrobiologiyasi | tanatomikrobiom | tamoyil |
| Sud radiologiyasi | o‘limdan keyingi KT | qo‘llanilishi |
| Sud toksikologiyasi | o‘limdan keyingi qayta taqsimlanish | tamoyil (lipofil, Vd > 3 L/kg) |

Rad etilganlar (sabab bilan, `content/phase8/curation_p8.json`): PMCT «metodlar» gapi; ISO/IEC 17025 — bitta laboratoriyaga xos gap. Sifat menejmenti (QA) fanida manbali umumiy claim hali yo‘q.

Bog‘lanishlar: rad-pmct ↔ o‘limdan keyingi o‘zgarishlar; entomologiya/mikrobiologiya ↔ PMI; mikrobiologiya ↔ chirish; PMR ↔ namuna olish joyi (taksonomik, `editorial:` deb belgilangan).

## 3. Raqamlar (paket 2026.10.6)

Claim 497 (+7) · mavzu 44 (+5) · review paketi 159 · navbat 888 · VERIFIED 0 · REVIEWED 0.

## 4. Testlar

Sxema: 4 (FE042, reagent/skrining JSON, mavzu fani). Ilova: 6 (yangi fanlar manbali va NEEDS_REVIEW, metodlarda validatsiya da’vosi yo‘q, reagent retsepti to‘qilmagan, genetika sahifasi, dalil turi belgisi).
