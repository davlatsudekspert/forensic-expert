# 04 — V1 Scope va V1 moddalar taklif ro‘yxati

| | |
|---|---|
| Sana | 2026-10-04 |
| Holat | **TAKLIF** — egasining tasdig‘ini kutmoqda |
| Asos | `01_EVIDENCE_AUDIT.md`, `02_COMPETITOR_ANALYSIS.md`, `03_SOURCE_MATRIX.md`, `05_COST_MODEL.md` |

---

## 1. V1 maqsadi (bir jumlada)

**EN/RU/UZ tillarida, offline ishlaydigan, har bir fakti manbali sud-toksikologiya va laboratoriya ish stoli: asosiy sud tibbiyoti reference va ta’lim yadrosi bilan.**

Research xulosasi: bozorda RU/UZ tilidagi professional forensic ilova yo‘q (G-1), manbali vositalar kam (G-2). Eng yaqin raqobatchi (4n6 Tools Pro) vositalar soni bo‘yicha kuchli, shuning uchun V1 vositalar sonini quvmaydi — **ishonchlilik, til va toksikologiya chuqurligi** bo‘yicha ustunlik qiladi.

---

## 2. Scope taqsimoti

### 2.1. MUST HAVE (V1 busiz chiqmaydi)

| # | Funksiya | Sabab |
|---|---|---|
| M-01 | Birinchi ochilishda til tanlash (EN/RU/UZ), disclaimer, rejim tanlash | Talab; store muvofiqligi |
| M-02 | Bottom navigation (Home, Tools, Library, AI, Profile), Settings (til, tema, rejim, birliklar) | Asos |
| M-03 | Offline content.db + imzolangan bazaviy kontent paketi | Offline-first, xavfsizlik |
| M-04 | Global Search (offline, EN/RU/UZ, kirill↔lotin, typo-tolerant, kategoriyali) | Mahsulot yadrosi |
| M-05 | Laboratory Tools: C1V1, eritish (seriyali ham), molarlik, massa konsentratsiyasi, % eritma, birlik konvertatsiyasi, molekulyar massa, mean/median/SD/CV, chiziqli regressiya/kalibrlash, LOD/LOQ | Litsenziya xavfi yo‘q; to‘liq test qilinadi; G-5 bo‘shlig‘i |
| M-06 | Ethanol: birlik konvertatsiyasi, Widmark (klassik + Watson/Forrest/Seidl r-faktor variantlari), back-calculation diapazon bilan | G-7 bo‘shlig‘i; manbalar tekshirilgan (A-03, A-04, A-10, A-13, A-14) |
| M-07 | Universal kalkulyator shabloni: INPUT · METHOD · FORMULA · RESULT · LIMITATIONS · REFERENCES | Talab; Apple 1.4.1 (metodologiyani ochish) |
| M-08 | Substance Library — **MUST guruhidagi ~46 yozuv** (3-bo‘lim), identifikatsiya (CAS’siz), sinonimlar, metabolitlar, namunalar, metodlar, talqin izohlari | Yadro |
| M-09 | Reference konsentratsiyalar (asosan Schulz 2020, CC BY 4.0) — kontekst maydonlari majburiy | Yadro; ochiq manba bor |
| M-10 | Specimens moduli (qon turlari, siydik, vitreous va h.k.) | Talqin xatolarining asosiy manbasi |
| M-11 | Analytical Methods reference (TLC, GC, GC-FID, HS-GC, GC-MS, HPLC, LC-MS/MS, UV-VIS, Immunoassay) + «SOP emas» banneri | Yadro |
| M-12 | Provenance: Sources sheet, review status belgilari, «MA’LUMOT TEKSHIRILMAGAN» banneri, conflict ko‘rsatish | Asosiy tamoyil |
| M-13 | Huquqiy status: UZ, BMT (INCB ro‘yxatlari), AQSh, RF — `effective_date` bilan | Mahalliy qiymat |
| M-14 | Forensic Medicine reference (matn): postmortem o‘zgarishlar (algor/rigor/livor), travma turlari, kuyishlar | `fm` reviewer bilan; hisob yo‘q — xavfi past |
| M-15 | Learn yadrosi: glossary (EN/RU/UZ), bookmarks | Arzon, foydali; terminologiya qatlamidan qayta foydalanadi |
| M-16 | Billing: Free / Student Pro / Professional Pro, restore, manage, entitlement abstraksiyasi | Talab |
| M-17 | Privacy: akkauntsiz ishlash, account deletion (agar akkaunt bo‘lsa), Privacy Policy, Terms, Scientific Disclaimer | Store talabi |
| M-18 | Store talablari: Play tavsifidagi «not a medical device» disclaimer, Health apps deklaratsiyasi, Data safety, App Privacy, yosh reytingi, target API 36 | Audit topilmalari (D-01, D-09, C-11) |
| M-19 | Kontent pipeline v1: validator, reviewer qoidalari (`22-bo‘lim`), imzolash, conflict tekshiruvi | Ilmiy to‘g‘rilik kafolati |
| M-20 | Accessibility: 320 dp, 200% shrift, screen reader, kontrast, reduced motion | Talab |

### 2.2. SHOULD HAVE (V1 da bo‘lishi kerak, lekin vaqt yetmasa V1.1 ga suriladi)

| # | Funksiya | Shart |
|---|---|---|
| S-01 | Substance Library — SHOULD guruhidagi qolgan ~49 yozuv | Reviewer resursiga bog‘liq |
| S-02 | Flashcards (SRS) va quiz (manbali izohlar bilan) | `edu` reviewer |
| S-03 | Forensic AI (beta): faqat Pro, RAG, citation validator, PII filtri, ilova ichida shikoyat tugmasi (D-02) | AI eval to‘plami 100% o‘tishi kerak |
| S-04 | Content update over-the-air (delta, rollback) | Bazaviy pack M-03 da bor |
| S-05 | Akkaunt va sinxronlash (bookmarks, progress) | |
| S-06 | Interferensiyalar bo‘limi (immunoassay cross-reactivity) | `lab` reviewer |

### 2.3. V1.1

| # | Funksiya | Nima uchun keyin |
|---|---|---|
| V11-01 | **Henssge kalkulyatori** | Egasining qarori. Tekshirilgan: birlamchi maqola (A-05), kitob (A-08); patent topilmadi (A-07); nomogramma tasviri himoyalangan → o‘zimiz hisoblaymiz va chizamiz. Ochiq: Marshall & Hoare 1962 (A-06), `fm` reviewer × 2, nashr qilingan misollar bilan testlar |
| V11-02 | External Scientific Search (PubMed, PubChem, Crossref) | V1 yadrosi barqaror bo‘lgach; limitlar tekshirilgan (B-04, B-11, B-12) |
| V11-03 | Kurslar va lessonlar, case studies | Kontent hajmi katta |
| V11-04 | Vitreous kaliy va boshqa PMI usullari | Henssge bilan birga |
| V11-05 | AI — Student Pro uchun | Xarajat ma’lumotlari beta’dan keyin |
| V11-06 | Reference eksporti (BibTeX/RIS) | |

### 2.4. FUTURE

| # | Funksiya | Shart |
|---|---|---|
| F-01 | CAS raqamlari | LICENSE REQUIRED (LR-01) |
| F-02 | Baselt / Clarke’s chuqurligi | LICENSE REQUIRED (LR-02, LR-03) |
| F-03 | Mass spektral ma’lumotlar | LR-06, LR-07 |
| F-04 | Forensic anthropology kalkulyatorlari (bo‘y, yosh, jins) | Populyatsiyaga xos cheklovlar (A-09); ehtiyotkor dizayn |
| F-05 | Odontologiya, DVI (INTERPOL DVI Guide 2023 asosida) | |
| F-06 | Exam mode | |
| F-07 | Institution / University litsenziyalari | Billing barqaror bo‘lgach |
| F-08 | Qo‘shimcha tillar (ES, FR, DE, TR, AR, PT, ZH, HI) | Arxitektura tayyor |
| F-09 | ATC tasnifi | LR-04 |
| F-10 | Ekspert hisobotiga o‘xshash PDF eksport | Yuridik ko‘rik talab qilinadi |

### 2.5. V1 da umuman yo‘q

Ijtimoiy tarmoq, foydalanuvchilar o‘rtasida chat, reels, marketplace, reklama, autopsiya fotosuratlari (Apple «Unrated» xavfi — C-11; Google grafik zo‘ravonlik siyosati — D-05).

---

## 3. V1 moddalar taklif ro‘yxati

### 3.1. Tanlov metodologiyasi

Ro‘yxat **xotiradan emas**, quyidagi tekshirilgan manbalar asosida tuzildi:

1. **Analitik qamrov standartlari** (AQSh, xalqaro amaliyotda keng qo‘llanadi): ANSI/ASB 119 (o‘lim tergovi, qon), 120 (haydovchilar, qon), 121 (DFC, siydik), NSC/D’Orazio 2021 tavsiyalari (Tier I/II).
2. **Epidemiologiya:** CDC/NCHS (AQSh, dozadan oshirib yuborish o‘limlari 2017–2023), UNODC World Drug Report 2025/2026 (Markaziy Osiyo bo‘yicha ma’lumot bilan), EUDA European Drug Report.
3. **Pestitsidlar, gazlar, uchuvchan moddalar:** peer-reviewed maqolalar va WHO.
4. **Mintaqaviy (O‘zbekiston/MDH):** WHO Medical Product Alert 1/2023 (O‘zbekiston, DEG/EG bilan ifloslangan siroplar), UNODC Markaziy Osiyo ma’lumotlari, RF «Судебно-медицинская экспертиза» jurnali maqolalari.

**Muhim cheklov:** PubMed’da O‘zbekiston bo‘yicha peer-reviewed postmortem toksikologiya epidemiologiyasi **topilmadi** (O-13). Mintaqaviy ustuvorlik UNODC, WHO va RF maqolalariga asoslangan. **Mahalliy ekspertlar bilan albatta tekshirilishi kerak** — siz va reviewerlar mahalliy amaliyotdagi ko‘p uchraydigan moddalarni qo‘shishingiz yoki olib tashlashingiz mumkin.

**Belgilar:**

- **MUST** — V1 dagi asosiy guruh.
- **SHOULD** — V1 da bo‘lishi maqsad, reviewer resursiga bog‘liq.
- **EJ** — EXPERT JUDGMENT — NEEDS REVIEWER CONFIRMATION: yuqoridagi manbalarda topilmagan, faqat ekspert mulohazasi asosida taklif qilingan.

Metabolitlar (6-MAM, benzoylecgonine, THC-COOH, nordiazepam va h.k.) ota modda bilan bitta yozuvda, `metabolic_relations` orqali. **Ro‘yxatda hech qanday konsentratsiya qiymati yo‘q.**

### 3.2. Manbalar (ro‘yxat uchun)

| ID | Manba | Nima beradi | URL / DOI / PMID | Yil | Kirish | Status |
|---|---|---|---|---|---|---|
| S1 | ANSI/ASB Std 119 | Minimal qamrov, qon, o‘lim tergovi (1- va 2-jadval) | aafs.org/sites/default/files/media/documents/119_Std_e1.pdf | 2021 | Bepul (CITE-ONLY) | VERIFIED |
| S2 | ANSI/ASB Std 120 | Minimal qamrov, qon, haydovchilar | aafs.org/.../120_Std_e1.pdf | 2021 | Bepul (CITE-ONLY) | VERIFIED |
| S3 | ANSI/ASB Std 121 | Minimal qamrov, siydik, DFC | aafs.org/.../121_Std_e1.pdf | 2021 | Bepul (CITE-ONLY) | VERIFIED |
| S4 | D’Orazio AL va hamk., J Anal Toxicol 45(6):529–536 | NSC Tier I/II | doi:10.1093/jat/bkab064; PMID 34086916 | 2021 | Bepul (CC BY-NC) | VERIFIED |
| S5 | D’Orazio AL va hamk., 2025 yangilanishi | Tier o‘zgarishlari (gabapentin Tier I ga) | doi:10.1093/jat/bkaf085; PMID 40972092 | 2025 | Pullik | PARTIALLY (abstrakt) |
| S6 | Garnett MF va hamk., NVSR 75(1) (CDC/NCHS) | AQSh dozadan oshirish o‘limlarida top-15 modda; suitsidlar | stacks.cdc.gov/view/cdc/174640 | 2026 | Bepul | VERIFIED |
| S7 | UNODC World Drug Report 2025 — Key Findings | Nitazenlar, tramadol, Sharqiy Yevropa/Markaziy Osiyoda NPS | unodc.org (WDR 2025) | 2025 | Bepul | VERIFIED |
| S8 | UNODC World Drug Report 2026 — Highlights | Markaziy Osiyo va Zakavkazyeda suiiste’mol qilinadigan dorilar: tramadol, benzodiazepinlar, opioid dorilar, tropikamid, kodein; ksilazin, medetomidin | unodc.org (WDR 2026) | 2026 | Bepul | VERIFIED (asosiy qismlar) |
| S9–S10 | EUDA European Drug Report 2025, 2026 — o‘limlar | Opioidlar, nitazenlar, kokain | euda.europa.eu/publications/european-drug-report/ | 2025/2026 | Bepul | PARTIALLY (sayt 403) |
| S11 | Mew EJ va hamk., J Affect Disord 219:93–104 | Pestitsid suitsidlari ulushi | doi:10.1016/j.jad.2017.05.002; PMID 28535450 | 2017 | Pullik | VERIFIED (abstrakt) |
| S13 | Gunnell D va hamk., Lancet Glob Health 5:e1026 | Xavfli pestitsidlarni taqiqlash ta’siri | doi:10.1016/S2214-109X(17)30299-1; PMID 28807587 | 2017 | Bepul | VERIFIED (abstrakt) |
| S14 | Dawson AH va hamk., PLoS Med 7:e1000357 | Pestitsidlar bo‘yicha o‘lim ko‘rsatkichlari | doi:10.1371/journal.pmed.1000357; PMID 21048990 | 2010 | Bepul | VERIFIED |
| S16 | Lin CY va hamk., BMJ Glob Health 11(2) | Koreyada parakvat taqiqi | doi:10.1136/bmjgh-2025-022329; PMID 41714100 | 2026 | Bepul | VERIFIED (abstrakt) |
| S17 | Long J va hamk., BMJ Open 11:e053240 | CO zaharlanishidan global o‘lim | doi:10.1136/bmjopen-2021-053240; PMID 34789496 | 2021 | Bepul | VERIFIED (abstrakt) |
| S18 | Ruder JB va hamk., J Burn Care Res 36:e23 | H₂S bilan suitsid | doi:10.1097/BCR.0000000000000065; PMID 25522151 | 2015 | Pullik | VERIFIED (abstrakt) |
| S19 | J Forensic Leg Med — yopiq joydagi yong‘in o‘limlarida sianid | Sianid | doi:10.1016/j.jflm.2026.103071; PMID 41494402 | 2026 | Pullik | PARTIALLY (faqat sarlavha) |
| S20 | Tiemensma M va hamk., Med Sci Law | Uchuvchan moddalar: benzin → butan/propan | doi:10.1177/00258024261460353; PMID 42286946 | 2026 | Pullik | VERIFIED (abstrakt) |
| S21 | Wiesen MHJ va hamk., Drug Test Anal 17:470 | Postmortem qonda mishyak, qo‘rg‘oshin, talliy | doi:10.1002/dta.3749; PMID 38886062 | 2025 | Bepul | VERIFIED (abstrakt) |
| S22 | «Thallium – poisoner’s poison», Curr Res Toxicol | Talliy | doi:10.1016/j.crtox.2024.100157; PMID 38420185 | 2024 | Bepul | PARTIALLY |
| S23 | WHO Medical Product Alert N°1/2023 | O‘zbekistondan xabar qilingan DEG/EG bilan ifloslangan siroplar | who.int/news/item/11-01-2023-medical-product-alert-n-1-2023-… | 2023 | Bepul | VERIFIED |
| S24 | Corkery JM va hamk., Hum Psychopharmacol 27:254 | Fenazepam (SSSRda ishlab chiqilgan), o‘limlar | doi:10.1002/hup.2222; PMID 22407587 | 2012 | Pullik | VERIFIED (abstrakt) |
| S25 | Sud Med Ekspert 60(4):18 | α-PVP bilan o‘limli zaharlanish (RF) | doi:10.17116/sudmed201760418-20; PMID 28766523 | 2017 | Pullik (RU) | PARTIALLY (sarlavha) |
| S27 | Mel’nikov IuL va hamk., Sud Med Ekspert 36(3):21 | Spirt surrogatlari bilan o‘limli zaharlanishlar (sobiq SSSR) | PMID 8378974 | 1993 | Pullik (RU) | PARTIALLY |
| S28 | «The Perils of Methanol Exposure», Toxics 12:924 | Metanol | doi:10.3390/toxics12120924; PMID 39771139 | 2024 | Bepul | PARTIALLY |
| S29 | «DARK Classics…: Heroin and Desomorphine», ACS Chem Neurosci | Dezomorfin review | doi:10.1021/acschemneuro.0c00262; PMID 32568519 | 2020 | Pullik | PARTIALLY |
| S30 | Sud Med Ekspert 67(1):147 | Fenazepam bilan ommaviy zaharlanish (RF) | doi:10.17116/sudmed20246701147; PMID 38353015 | 2024 | Pullik (RU) | PARTIALLY |
| S31 | NSC/NMS taqdimoti (D’Orazio) | 2021 Tier II qo‘shimchalari (trazodon, difluoroetan) | nsc.org/getmedia/17dfa36e-…/nms-tox-investigation-drug-impaired-driving-mv-fatalities.pdf | 2024 | Bepul | VERIFIED |
| S32 | Kumar S va hamk., Dialogues Health 7:100247 | Alyuminiy fosfid o‘limi, Hindiston | doi:10.1016/j.dialog.2025.100247; PMID 41140947 | 2025 | Bepul | VERIFIED (abstrakt) |
| S33 | Bagherian F va hamk., Arch Acad Emerg Med 9:e66 | Alyuminiy fosfid o‘limi, Eron | doi:10.22037/aaem.v9i1.1396; PMID 34870232 | 2021 | Bepul | VERIFIED |

### 3.3. Taklif ro‘yxati (95 yozuv)

#### Spirtlar, toksik spirtlar va glikollar (6)

| Modda | Kiritish sababi | Manba | Ustuvorlik |
|---|---|---|---|
| Ethanol | Barcha qamrov ro‘yxatlarida; sud-kimyoning eng ko‘p tekshiriladigan moddasi | S1, S2, S3, S4 | MUST |
| Methanol | ASB 119 volatiles; ommaviy zaharlanishlar; MDHda spirt surrogatlari | S1, S27, S28 | MUST |
| Isopropanol | ASB 119 volatiles | S1 | MUST |
| Acetone | ASB 119 volatiles (ketoatsidoz va izopropanol talqini) | S1 | SHOULD |
| Ethylene glycol | O‘zbekiston bo‘yicha WHO ogohlantirishida nomlangan | S23 (+EJ — umumiy qamrov uchun) | MUST |
| Diethylene glycol | O‘zbekiston bo‘yicha WHO ogohlantirishida nomlangan | S23 | MUST |

#### Opioidlar (18)

| Modda | Sabab | Manba | Ustuvorlik |
|---|---|---|---|
| Fentanyl (+norfentanyl) | AQSh o‘limlarida 1-o‘rin; barcha ro‘yxatlarda | S1–S4, S6, S7, S10 | MUST |
| Fentanyl analoglari (acetylfentanyl, carfentanil) | NSC Tier II sinfi | S4, S8; aniq analoglar — EJ | SHOULD |
| Heroin / 6-MAM | AQSh 7-o‘rin; Yevropa | S1–S4, S6, S9 | MUST |
| Morphine | Barcha ro‘yxatlarda | S1–S4, S6 | MUST |
| Codeine | Barcha ro‘yxatlarda; Markaziy Osiyoda suiiste’mol | S1–S4, S8 | MUST |
| Oxycodone | AQSh 6-o‘rin | S1–S4, S6 | MUST |
| Hydrocodone | Barcha ro‘yxatlarda | S1–S4, S6 | MUST |
| Hydromorphone | ASB 119/121, NSC Tier I | S1, S3, S4 | SHOULD |
| Methadone | AQSh 10-o‘rin; Yevropa | S1, S2, S4, S6, S7, S9 | MUST |
| Buprenorphine (+norbuprenorphine) | ASB/NSC Tier I | S1, S2, S4 | MUST |
| Tramadol (+O-desmethyltramadol) | ASB/NSC; **Markaziy Osiyoda eng ko‘p suiiste’mol qilinadigan dori** | S1–S4, S6, S7, S8 | MUST |
| Tapentadol | NSC Tier II | S4, S8 | SHOULD |
| Protonitazene | 2024 da eng ko‘p aniqlangan nitazen; Yevropadagi o‘limlar | S7, S8, S9 | MUST |
| Metonitazene | Estoniya, Shvetsiya, Norvegiyadagi o‘limlar | S7, S9 | MUST |
| Isotonitazene / N-desethyl isotonitazene / N-pyrrolidino protonitazene (guruh) | UNODC eng ko‘p aniqlangan nitazenlar | S7, S8 | SHOULD |
| Desomorphine | MDHda ahamiyati | S29 (faqat review) + EJ | SHOULD — EJ |
| Mitragynine (kratom) | NSC Tier II | S4, S7 | SHOULD |
| Dextromethorphan | ASB 119/121, NSC Tier II | S1, S3, S4 | SHOULD |

#### Stimulyatorlar, jumladan NPS (7)

| Modda | Sabab | Manba | Ustuvorlik |
|---|---|---|---|
| Cocaine (+benzoylecgonine, cocaethylene) | AQSh 3-o‘rin; Yevropadagi o‘limlarning 27% | S1–S4, S6, S10 | MUST |
| Methamphetamine | AQSh 2-o‘rin | S1–S4, S6, S7 | MUST |
| Amphetamine | Barcha ro‘yxatlarda | S1–S4, S6 | MUST |
| MDMA (+MDA) | Barcha ro‘yxatlarda | S1–S4 | MUST |
| Mephedrone (4-MMC) | Katinon musodaralari Sharqiy Yevropada to‘plangan | S7, S4 (sinf) | SHOULD |
| α-PVP | RF sud-tibbiy o‘lim holatlari; katinonlar NSC Tier II | S25, S4 | SHOULD |
| Methylphenidate | NSC Tier II | S4 | SHOULD |

#### Kannabinoidlar (3)

| Modda | Sabab | Manba | Ustuvorlik |
|---|---|---|---|
| THC (+11-OH-THC, THC-COOH) | Barcha ro‘yxatlarda | S1–S4 | MUST |
| Sintetik kannabinoid retseptor agonistlari (sinf yozuvi) | NSC Tier II; sintetik NPS musodaralarining asosiy qismi | S4, S7 | MUST |
| MDMB-4en-PINACA, ADB-BUTINACA (namunalar) | Aniq birikmalar tanlovi | EJ | SHOULD — EJ |

#### Benzodiazepinlar va Z-dorilar (11)

| Modda | Sabab | Manba | Ustuvorlik |
|---|---|---|---|
| Alprazolam | AQSh 5-o‘rin; barcha ro‘yxatlarda | S1–S4, S6 | MUST |
| Clonazepam (+7-aminoclonazepam) | AQSh 14-o‘rin | S1–S4, S6 | MUST |
| Diazepam (+nordiazepam, oxazepam, temazepam) | Barcha ro‘yxatlarda | S1–S4, S6 | MUST |
| Lorazepam | Barcha ro‘yxatlarda | S1–S4 | MUST |
| Bromazolam | AQSh 2023 da 15-o‘rin; yangi benzodiazepin | S6, S4 (sinf) | MUST |
| Phenazepam | SSSRda ishlab chiqilgan; o‘limlar; RFda ommaviy zaharlanish | S24, S30 | SHOULD (**mintaqa uchun MUST bo‘lishi mumkin — reviewer hal qiladi**) |
| Etizolam | Yangi benzodiazepinlar sinfi | S4 (sinf) + EJ | SHOULD — EJ |
| Midazolam | Manbalarda topilmadi | EJ | SHOULD — EJ |
| Chlordiazepoxide | NSC Tier II | S4 | SHOULD |
| Zolpidem | Barcha ro‘yxatlarda | S1–S4 | MUST |
| Zopiclone | ASB 121, NSC Tier II | S3, S4 | SHOULD |

#### Barbituratlar (2)

| Modda | Sabab | Manba | Ustuvorlik |
|---|---|---|---|
| Phenobarbital | ASB 119/121 | S1, S3, S4 | SHOULD |
| Pentobarbital / butalbital (guruh) | ASB 119 | S1, S3 | SHOULD |

#### Antidepressantlar (10)

| Modda | Sabab | Manba | Ustuvorlik |
|---|---|---|---|
| Amitriptyline (+nortriptyline) | ASB 119/121; TCA sinfi | S1, S3, S4 | MUST |
| Imipramine / clomipramine / doxepin (TCA guruhi) | ASB 119 | S1, S3, S4 | SHOULD |
| Bupropion | AQSh suitsidal dozadan oshirishda 3-o‘rin | S1, S6 | MUST |
| Citalopram / escitalopram | ASB 119 | S1 (escitalopram — EJ) | SHOULD |
| Sertraline | ASB 119 | S1 | SHOULD |
| Fluoxetine | ASB 119 | S1 | SHOULD |
| Paroxetine | ASB 119 | S1 | SHOULD |
| Venlafaxine (+O-desmethylvenlafaxine) | ASB 119 | S1 | SHOULD |
| Mirtazapine | ASB 119, NSC Tier II | S1, S4 | SHOULD |
| Trazodone (+mCPP) | ASB 119/121, NSC Tier II | S1, S3, S4, S31 | SHOULD |

#### Antipsixotiklar (5)

| Modda | Sabab | Manba | Ustuvorlik |
|---|---|---|---|
| Quetiapine | AQSh suitsidal dozadan oshirishda 8-o‘rin | S1, S6 | MUST |
| Olanzapine | ASB 119 | S1 | SHOULD |
| Clozapine | ASB 119 | S1 | SHOULD |
| Risperidone (+9-OH) | ASB 119 | S1 | SHOULD |
| Chlorpromazine / haloperidol | Chlorpromazine — ASB 119; haloperidol — manbasiz | S1; haloperidol — EJ | SHOULD |

#### Antikonvulsantlar / gabapentinoidlar (6)

| Modda | Sabab | Manba | Ustuvorlik |
|---|---|---|---|
| Gabapentin | AQSh 8-o‘rin; NSC Tier I ga ko‘tarilgan | S1, S5, S6, S8 | MUST |
| Pregabalin | ASB 119; NSC Tier II; ko‘p mintaqalarda suiiste’mol | S1, S4, S8 | MUST |
| Carbamazepine (+10-OH) | ASB 119 | S1, S4 | SHOULD |
| Lamotrigine | ASB 119 | S1, S4 | SHOULD |
| Valproic acid | NSC Tier II | S4 | SHOULD |
| Levetiracetam / phenytoin / topiramate (guruh) | ASB 119 | S1, S4 | SHOULD |

#### Antigistaminlar (4)

| Modda | Sabab | Manba | Ustuvorlik |
|---|---|---|---|
| Diphenhydramine | AQSh suitsidal dozadan oshirishda 1-o‘rin | S1, S3, S4, S6 | MUST |
| Doxylamine | ASB 119/121 | S1, S3, S4 | SHOULD |
| Hydroxyzine | ASB 119, NSC Tier II | S1, S4 | SHOULD |
| Chlorpheniramine / promethazine | ASB 119 | S1, S3, S4 | SHOULD |

#### Keng tarqalgan analgetiklar (3)

| Modda | Sabab | Manba | Ustuvorlik |
|---|---|---|---|
| Paracetamol (acetaminophen) | ASB 119; AQSh suitsidlarda 5-o‘rin | S1, S6 | MUST |
| Salicylates | ASB 119 | S1 | MUST |
| Ibuprofen / NSAIDlar | Manbalarda topilmadi | EJ | SHOULD — EJ |

#### Miorelaksantlar (2)

| Modda | Sabab | Manba | Ustuvorlik |
|---|---|---|---|
| Carisoprodol (+meprobamate) | ASB 119/120/121; 2025 da NSC Tier II ga tushirilgan | S1–S3, S5 | SHOULD |
| Cyclobenzaprine | ASB 119/121, NSC Tier II | S1, S3, S4 | SHOULD |

#### Yurak-qon tomir va boshqa dorilar (6) — hammasi EJ

| Modda | Sabab | Manba | Ustuvorlik |
|---|---|---|---|
| Digoxin | Klassik sud-tibbiy zahar | EJ | SHOULD — EJ |
| Insulin | Qotillik/suitsid; maxsus postmortem markerlar | EJ | SHOULD — EJ |
| Propranolol / β-blokatorlar | Dozadan oshirish o‘limlari | EJ | SHOULD — EJ |
| Verapamil / amlodipine (kalsiy kanali blokatorlari) | Dozadan oshirish o‘limlari | EJ | SHOULD — EJ |
| Colchicine | Yuqori o‘limlilik | EJ | SHOULD — EJ |
| Lithium | Terapevtik monitoring va dozadan oshirish | EJ | SHOULD — EJ |

#### Dissotsiativlar, sedativlar, aralashmalar va boshqalar (6)

| Modda | Sabab | Manba | Ustuvorlik |
|---|---|---|---|
| Ketamine (+norketamine) | ASB 119/121; NSC Tier II; global bozor | S1, S3, S4, S7, S8 | MUST |
| GHB | ASB 121; NSC Tier II | S3, S4 | MUST |
| Xylazine | AQSh 2023 da 4-o‘rin | S6, S8 | MUST |
| Medetomidine | Yangi paydo bo‘lgan aralashma | S8 | SHOULD |
| Tropicamide | WDR 2026: Markaziy Osiyo va Zakavkazyeda suiiste’mol qilinadigan dorilar ro‘yxatida | S8 | SHOULD (**mintaqa uchun MUST bo‘lishi mumkin**) |
| PCP | ASB 119; NSC Tier II | S1, S4 | SHOULD |

#### Pestitsidlar (8)

| Modda | Sabab | Manba | Ustuvorlik |
|---|---|---|---|
| Fosfororganik birikmalar (sinf) + chlorpyrifos | Eng ko‘p iste’mol qilinadigan | S11–S14 | MUST |
| Dimethoate | Yuqori o‘lim ko‘rsatkichi | S14 | MUST |
| Paraquat | Eng yuqori o‘lim ko‘rsatkichi; milliy taqiqlar nishoni | S13, S14, S16 | MUST |
| Aluminium phosphide / phosphine | Hindistonda zaharlanish o‘limlarining asosiy sababi; Eronda yuqori o‘limlilik | S32, S33 | MUST |
| Endosulfan | Yuqori o‘lim ko‘rsatkichi | S14 (+ PMID 32075613) | SHOULD |
| Glyphosate | Ko‘p iste’mol qilinadi | S14 | SHOULD |
| Karbamatlar (carbofuran, aldicarb) | Manbalarda topilmadi | EJ | SHOULD — EJ |
| Antikoagulyant rodentitsidlar (brodifacoum) | Manbalarda topilmadi | EJ | SHOULD — EJ |

#### Toksik gazlar (3)

| Modda | Sabab | Manba | Ustuvorlik |
|---|---|---|---|
| Carbon monoxide (COHb) | ASB 119; dunyoda eng ko‘p o‘limli zaharlanishlardan biri | S1, S17 | MUST |
| Cyanide (HCN) | Yong‘in o‘limlari; qotillik/suitsid | S19 + EJ | MUST — EJ (tasdiq kerak) |
| Hydrogen sulfide | Kimyoviy suitsid | S18 | SHOULD |

#### Uchuvchan moddalar (3)

| Modda | Sabab | Manba | Ustuvorlik |
|---|---|---|---|
| Butane / propane (LPG) | Uchuvchan modda suiiste’moli o‘limlari | S20, S4 (inhalantlar) | SHOULD |
| 1,1-Difluoroethane | 2021 da NSC Tier II ga qo‘shilgan | S4, S31 | SHOULD |
| Toluene / benzin erituvchilari | Tarixiy benzin hidlash o‘limlari | S20 (benzin); toluen — EJ | SHOULD — EJ |

#### Metallar va boshqa zaharlar (4)

| Modda | Sabab | Manba | Ustuvorlik |
|---|---|---|---|
| Arsenic | Aniqlanmay qolgan qotilliklar; ICP-MS | S21 | SHOULD |
| Thallium | Jinoiy zaharlanish | S21, S22 | SHOULD |
| Sodium nitrite | Yangi suitsid vositasi | EJ | SHOULD — EJ |
| Acetic acid (sirka essensiyasi) | MDHda ahamiyati bo‘lishi mumkin | EJ | SHOULD — EJ |

### 3.4. Statistika

| Ko‘rsatkich | Soni |
|---|---|
| Jami yozuvlar | 95 |
| MUST | ~46 |
| SHOULD (manbali) | ~31 |
| Faqat EJ (reviewer tasdig‘i shart) | 18 (12 SHOULD-EJ, 1 MUST-EJ — sianid, 5 qisman EJ) |

### 3.5. V1.1 backlog (moddalar)

Clomipramine va desipramine (alohida yozuv sifatida), fenthion, propanil, MCPA, qo‘rg‘oshin, CO₂, etomidate (S8 da nomlangan).

### 3.6. Reviewer uchun savollar

1. **O‘zbekiston amaliyoti:** sud-kimyo laboratoriyalarida eng ko‘p aniqlanadigan moddalar qaysilar? Ro‘yxatda yo‘q, lekin mahalliy amaliyotda muhim moddalar bormi? Masalan: «solt» nomli katinonlar, pregabalin suiiste’moli, sirka essensiyasi, spirt surrogatlari, mahalliy pestitsidlar.
2. Fenazepam va tropikamid mintaqa uchun MUST bo‘lishi kerakmi?
3. Hamma EJ yozuvlarni tasdiqlaysizmi yoki olib tashlaymizmi?
4. Ba’zi MUST yozuvlar AQShga xos ko‘rinishi mumkin (hydrocodone, oxycodone, xylazine). Ular xalqaro foydalanuvchilar uchun qolsinmi?
