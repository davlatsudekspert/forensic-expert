# Dalil darajalari (A–E) auditi

Sana: 2026-10-10. Ko‘lam: `content/pilot/bundle.json` (523 manba, 497 da’vo), `content/guidelines/`,
`content/court_prep/`. Usul: kod va ma’lumotlarni o‘qish + PubMed publikatsiya turini (E-utilities
`esummary`, 312 ta PMID) qoida bilan solishtirish. Takrorlanadigan qismi:
`python3 content/tools/claim_source_audit.py` (`docs/qa/CLAIM_SOURCE_AUDIT.md`, «Evidence levels» bo‘limi).

Bu hujjat **taklif** beradi: hech bir daraja jimgina o‘zgartirilmadi. «trust» agenti UI’da
asoslanmagan darajalarni yashirishi mumkin — quyidagi «asoslanmagan» ro‘yxat shu uchun.

## 1. Asosiy xulosa

- A/B/C/D/E — **nashr turi** bo‘yicha belgi, **dalil sifati** emas. Mezon faqat kodda
  (`content/tools/p5/assemble_p5.py::level`, `content/tools/p5/harvest_research.py::evidence`,
  `content/pilot/evidence_levels.json`); manba yozuvida mezon/asos (`evidence_basis`) maydoni **yo‘q**.
  Foydalanuvchi harfni ko‘radi, qaysi qoida bilan berilganini ko‘ra olmaydi.
- Karta qatlami (`guidelines`, `court_prep`) A/B/C ishlatmaydi — daraja faqat bundle (kutubxona /
  provenance) qatlamida.
- Da’vo darajasi manba darajasidan **nusxa** (497/497 mos) — da’vo darajasida alohida baho yo‘q.

## 2. Daraja qayerdan keladi

| Kelib chiqishi | Qoida | Mezon ma’lumotda yozilganmi | Soni |
|---|---|---|---|
| PubMed publikatsiya turi (`assemble_p5.level`) | A: systematic review / meta-analysis; C: review; D: case report; B: qolgan hamma maqola | yo‘q (faqat kodda) | ~290 maqola |
| Qo‘lda (`pilot/evidence_levels.json`) | «dastlabki baho, reviewer tasdiqlaydi» (A: rasmiy qo‘llanma/tizimli sharh, C: narrativ/ma’lumotlar bazasi…) | faqat fayl izohida | 18 PMC |
| `assemble_p7.py` / `assemble_p8.py` | **B qattiq kodlangan** (nashr turi tekshirilmaydi) | yo‘q | p7/p8 maqolalari |
| Qonun/ro‘yxat (`legislation`, tier1) | A (INCB, GB, AQSh, GFR, O‘zbekiston) | **yo‘q** — qonunga ilmiy daraja berish mezoni yo‘q | 8 |
| Ma’lumotlar bazasi (PubChem, `database`, tier2) | C | faqat 3-faza hujjatida | 201 |
| Hisobot/muharrir (`SRC-OWNER-REAGENTS` C, `SRC-FE-EDITORIAL` E) | kodda | yo‘q | 2 |

## 3. PubMed turi bilan solishtirish (312 maqola)

300 ta daraja qoidaga mos. **12 ta chetga chiqish** (asos hujjatlashtirilmagan):

| Manba | Berilgan | Qoida bo‘yicha | Sabab |
|---|---|---|---|
| SRC-PMC11049589 «PCR in Forensic Science: A Critical Review» | B | C | p7/p8 qattiq B |
| SRC-PMC12652486 «Analysis of Human Degraded DNA…» (review) | B | C | p7/p8 qattiq B |
| SRC-PMC6197100 «Thanatomicrobiome…» (review) | B | C | p7/p8 qattiq B |
| SRC-PMC11839505 «A review of methods of age estimation…» | B | C | p7/p8 qattiq B |
| SRC-PMC11790690 «Postmortem redistribution of drugs: a literature review» | B | C | p7/p8 qattiq B |
| SRC-PMC12346081 «Current Understanding… PMI» (review) | B | C | p7/p8 qattiq B |
| SRC-PMC12586478 «…role of hair as a biospecimen» (review) | B | C | p7/p8 qattiq B |
| SRC-PMC11580817 (retraksiya qilingan, review) | B | C | qo‘lda (`assemble_p4.LEVELS`: B); manba retraksiya qilingan |
| SRC-PMC3756590 (editorial) | C | B (qoida) | qo‘lda; editorial uchun A–E mezoni yo‘q |
| SRC-PMC11567147 (tadqiqot) | C | B | qo‘lda, asosi yozilmagan |
| SRC-PMC5478479 (CPIC qo‘llanma) | A | B | qo‘lda («rasmiy qo‘llanma = A»; PubMed turi «practice guideline») |
| SRC-PMC12550317 «Meta-analysis of mortality…AlP» | A | C | sarlavhada meta-analysis, PubMed turi «review» |

Qo‘shimcha (sarlavha bo‘yicha belgilangan nomuvofiqliklar, to‘liq ro‘yxat
`docs/qa/CLAIM_SOURCE_AUDIT.md`):

- **SRC-PMC13553925** «Diagnostic challenges in infant death… a forensic case report and review of the
  literature» — daraja **A**: PubMed uni «systematic review» deb tiplagan, sarlavha esa case report +
  narrativ sharh. A asoslanmagan (D yoki C kutiladi). Shu manbadan da’vo: `C-BIO-COCAINE-STABILITY-LIMITATION-P5`
  (matnda «Huertas et al. demonstrated…» — ikkilamchi keltirish).
- «A Systematic Review» sarlavhali, lekin C berilgan: PMC11694602, PMC12030428, PMC12793923,
  PMC13224331, PMC9822528 (PubMed turi faqat «review»; sarlavhaga ko‘ra A bo‘lishi mumkin).
- «Case report» sarlavhali, lekin B/C: PMC10053335, PMC13331822, PMC13342391, PMC7994691, PMC8400298, PMC9863810.
- Qonunlar (8) — A: mezon yo‘q.

## 4. Taklif (hech narsa jimgina o‘zgartirilmadi)

1. **Asos maydoni.** Har bir manbaga `evidence_basis` (`pubmed_pubtype` | `official_guideline` | `manual_review` | `none`)
   va `evidence_basis_detail` (masalan, PubMed turlari ro‘yxati) qo‘shish. Asos yo‘q → UI harfni ko‘rsatmaydi
   («daraja belgilanmagan»). Bu «trust» agenti uchun aniq qoida: harf faqat `evidence_basis != none` bo‘lsa ko‘rinadi.
2. **Qonun/ro‘yxatlar A–E olmaydi.** Ularning o‘rniga «Rasmiy hujjat (tier1, yurisdiksiya: …)» belgisi; ilmiy dalil
   darajasi bilan aralashtirmaslik.
3. **Matn.** UI/hujjatda «dalil darajasi» o‘rniga «manba turi» («tizimli sharh», «birlamchi tadqiqot», «narrativ sharh»,
   «klinik holat bayoni»); A–E sifat kafolati emasligi yozilsin.
4. **p7/p8.** B ni qattiq kodlash o‘rniga PubMed turi bo‘yicha `level()` ishlatish (7 ta B→C). Natija ekspert
   tasdig‘idan o‘tadi (FE027 regressiya qo‘riqchisi versiya oshirishni talab qiladi).
5. **PMC13553925** — PubMed turi xato (case report + review). D (yoki C) deb belgilash; shu manbadagi
   «Huertas et al.» da’vosini birlamchi manbaga almashtirish.
6. **Qo‘lda baholar** (`evidence_levels.json`: 18 ta) — har biriga bir qatorli asos yozish; editorial/komment uchun
   alohida «E» qoidasi.
7. **PubChem (database, C).** Daraja o‘rniga «ma’lumotlar bazasi» belgisi.
8. **CI.** `claim_source_audit.py --check` endi bundle darajalarining nomuvofiqligini JSON’da ko‘rsatadi; kelajakda
   `ungrounded_or_inconsistent_sources` ro‘yxati bo‘sh bo‘lishi talab qilinishi mumkin.

## 5. Tekshirilmaganlar

- PubMed turi faqat 312 ta PMID uchun olindi; `research` ro‘yxatidagi 882 yozuv (`kind` → daraja) alohida
  tekshirilmadi: `kind`→daraja xaritasi (`harvest_research.evidence`) bir xil qoida, lekin `journal_article` → B
  tadqiqot dizaynini (kohort, in vitro, hayvon) farqlamaydi.
- Sarlavha bo‘yicha belgilar taxminiy (matn qidiruvi); yakuniy qaror ekspertniki.
