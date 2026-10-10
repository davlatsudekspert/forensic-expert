# Da’vo ↔ manba yaxlitligi: tuzatishlar jurnali (2026-10-10)

Vosita: `content/tools/claim_source_audit.py` (deterministik, oflayn; CI: `--check`). Natija:
`docs/qa/CLAIM_SOURCE_AUDIT.md` + `docs/qa/claim_source_audit.json`. Qo‘lda ko‘rik daftari:
`content/tools/claim_source_reviews.json` (hash bilan bog‘langan: matn o‘zgarsa yozuv eskiradi).
Boshlang‘ich nuqta: `198452c` (`docs/qa/claim_source_audit_baseline.json`).
Ishlatilgan metadata: PubMed (E-utilities / PubMed MCP), Crossref, PubChem PUG REST, lex.uz, SWGDRUG v8.2 PDF,
ICH Q2(R2) PDF, egasi bergan GMT/TOKS PDF nusxalari (faqat lokal o‘qish).

## Jami (1797 da’vo birligi)

| Hukm | Oldin | Keyin |
|---|---|---|
| UNSUPPORTED | 1 | 1 (qasddan qoldirilgan fixture, quyiga qarang) |
| SCOPE_MISMATCH | 10 | 0 |
| ABSTRACT_ONLY | 569 | 565 |
| NO_LOCATOR | 76 | 17 |
| PARTIAL | 56 | 67 |
| SUPPORTED | 1085 | 1147 |

Umumiy qoida («hamisha/hech qachon/isbotlaydi») bilan yozilgan, faqat annotatsiyaga tayangan da’vo: 18 → 0 ko‘rilmagan
(15 tasi qo‘lda ko‘rildi — 4 tasi toraytirildi, 11 tasi annotatsiyaga mos deb qoldirildi; qolganlari matn toraytirilgach belgidan chiqdi).

## O‘zgartirilgan da’volar (uz/ru/en uchalasi, raqam/birlik/formula o‘zgarmagan; `translation_qa` 0 xato)

| Da’vo | Nima uchun |
|---|---|
| `diatom_test/cautions#2` | «har seriyada blank nazorat» — annotatsiyalarda yo‘q; ifloslanishsiz namuna olish (Hürlimann) va standartlashtirish (Tyr) ga toraytirildi, blank nazorat «umumiy laboratoriya amaliyoti» deb belgilandi |
| `diatom_test/advantages#1` | «kremniyli qobiq chirishga chidamli, shuning uchun qo‘llanadi» — annotatsiyada yo‘q; Pollanen (2 holat) + Bortolotti ogohlantirishi (passiv kirish) |
| `tlc_screening/cautions#3` | de Zeeuw 1994 faqat har plastinkadagi Rf-tuzatish aralashmasini tasdiqlaydi; nazorat/standart talabi manbadan ajratildi |
| `postmortem_interpretation/cautions#2` | Pounder: konsentratsiya joyga bog‘liq; «hisobotda joy ko‘rsatiladi» qoidasi emas, shu fakt yozildi |
| `postmortem_interpretation/limitations#8` | Kintz: soch — retrospektiv ta’sirlanish tarixi; «faqat bilvosita» annotatsiyada yo‘q |
| `postmortem_interpretation/scope#2`, `cautions#8`, `specimen_preanalytics/basis#6`, `limitations#5` | ASB — AQSh ixtiyoriy tavsiyasi ekani yozildi; «amal qilinadi» → «inobatga olinadi»; ASB 156 «moslashtiriladi» da’vosi scope’dan keng edi |
| `specimen_preanalytics/cautions#1` | Flanagan: ikki periferik joy; «hech qachon bitta idishda aralashtirilmaydi» annotatsiyada yo‘q |
| `method_comparison/cautions#1` | «hech qachon yakuniy emas» → «yakka o‘zi yetarli emas» (Saitman: immunoanaliz; SWGDRUG IIIB.3.1/3.2) |
| `method_comparison/basis#4`, `factors#3`, `cautions#5`, `limitations#6`; `gmt_analysis_scheme/instrumental#4`; `uvvis/methods#7` | ANSI/ASB 113/098/036 — AQSh ixtiyoriy standartlari; ASB 113 spirt/uchuvchi, CO, sianid, metallarga taalluqli emas (scope) |
| `toks_pesticides/cautions#3` | Maurer 2004 «instrumental tasdiqsiz xulosa yo‘q» demaydi; GC-MS asosiy / LC-MS to‘ldiruvchi skrining deb toraytirildi |
| `gmt_cocaine/tlc#3` | Uchiyama «kamida ikki tizim» demaydi; amaliy tavsiya deb belgilandi |
| `gmt_benzodiazepines/basis#3` | «ayniqsa nitro-hosilalar» annotatsiyada yo‘q — olib tashlandi |
| `co_cohb/factors#9`, `cautions#3`, `cautions#4` | Delvau 2024 — **cho‘chqa modeli**; turi aytilmagan edi, endi «hayvon modeli, odamga ko‘chirilmaydi» |
| `court.q.interp_cause_of_death` (qisqa javob) | «bir xil konsentratsiyalar turli sabablarda uchraydi» annotatsiyada yo‘q → taqsimot + nazorat guruhi |
| `court.q.interp_redistribution` (qisqa javob, explain.0) | joylarni solishtirish Pélissier ga, eng maqbul joy (son venasi) Yarema ga qayta bog‘landi |
| `court.q.ident_criteria` explain.0, `ident_colour_test` explain.1, `instr_gcms` short_answer | ASB 113 — AQSh ixtiyoriy standarti; scope istisnolari |
| bundle: `C-FENTANYL-METABOLISM_NOTE-P5`, `C-MITRAGYNINE-METABOLISM_NOTE-P5`, `C-MDMB-4EN-PINACA-ANALYTICAL_METHOD-P5` | manba in vitro / analoglar / farmakologiya; `value.scope_note` qo‘shildi (ekspert ko‘rigi kerak). UI hozircha ko‘rsatmaydi |

Qo‘shilgan joylashuvlar (matn o‘zgarmadi, daftarda): SWGDRUG 43 da’vo (`sec:IIIB.x`, Jadval 1), UNODC 9 (quiz, kartadagi bet),
ICH Q2(R2) 9 (`sec:1.2`, 3.1–3.3), lex.uz 8 (`art:4`, `art:28`, ilovalar 4–7), PubChem 2 (CID; formulalar 2026-10-10 da PUG REST bilan solishtirildi).

## Qasddan o‘zgartirilmagan

- `C-FM-ALGOR-MORTIS-DEFINITION` — manba retraksiya qilingan (PMID 39575351). Bu ilovaning hujjatlashtirilgan fixture’i
  (retracted banner + RAG’dan chiqarish; `phase7_test`, `rag_pipeline_test` aynan shuni tekshiradi). Egasi qarori: manbani
  almashtirish (masalan, `SRC-PMC12346081` INTRO «algor mortis (cooling of the body)») yoki fixture sifatida qoldirish.

## Ekspert uchun qolganlar

1. 565 ta ABSTRACT_ONLY — jurnal manbalar faqat annotatsiya darajasida; to‘liq matn bilan tasdiqlash (ustuvorlik: raqamli va
   «kerak/lozim» bilan yozilgan da’volar).
2. 17 ta NO_LOCATOR: UNODC umumiy jumlalar (4 ta + quiz), PubChem EI cho‘qqilari (11 ta; diazepam uchun PubChem yozuvlarida 256 va 285
   ko‘rindi, kartadagi 283/284 qayta tekshirilsin), lex.uz «tahrir ro‘yxati» (3 ta).
3. Faqat scope o‘qilgan standartlar (ASB 036/037/098/113/156, ISO/IEC 17025, JCGM 100, Eurachem QUAM): ularning matni o‘qilmagan.
4. `iupac_beer_lambert` (sayt Cloudflare orqasida) va `swinehart1962` (faqat Crossref metadata): Buger–Lambert–Ber da’vosi
   darslik darajasidagi qonun, lekin manba matni o‘qilmagan.
5. Bundle’dagi 3 ta `scope_note` va retraksiya fixture’i; `INTRO` bo‘limidan olingan 100+ da’vo — bu maqolaning o‘z natijasi emas,
   fon bayoni.
6. Dalil darajalari — `docs/EVIDENCE_LEVELS_AUDIT.md` (taklif).
7. Darslik (Yuldashev) qoldiqlari: `o-tolidin` kabi xavfli reagentlar TOKS kartasida kitob bo‘yicha keltirilgan; zamonaviy xavfsizlik
   baholashi ekspertdan.
8. Cited-in-text bo‘lmagan ISO 21043, WHO, NIST (faqat PubChem orqali spektr manbasi sifatida), ISFG: kartalar/court matnida
   standart sifatida keltirilmagan — tekshiriladigan da’vo yo‘q.
