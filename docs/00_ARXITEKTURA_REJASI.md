# FORENSIC EXPERT — Mahsulot va arxitektura rejasi (PHASE 0)

**Evidence · Science · Precision**

| | |
|---|---|
| Hujjat versiyasi | 0.1 (qoralama, egasining tasdig‘ini kutmoqda) |
| Sana | 2026-10-04 |
| Holat | KOD YOZILMAGAN. Tasdiqdan keyin PHASE 1 boshlanadi |

---

## Hujjatdagi belgilar haqida

Bu hujjatda ikki xil belgidan foydalanaman. Ular loyihaning «hech narsani o‘ylab topma» qoidasini rejalash bosqichining o‘zida qo‘llash uchun kerak:

- **[TEKSHIRISH KERAK]** — men xotiramdan bilgan, lekin hali birlamchi manba orqali tekshirmagan fakt: nashr yili, standart raqami, litsenziya sharti yoki API imkoniyati. PHASE 0 yakunida har biri rasmiy manbadan tekshiriladi yoki o‘chiriladi.
- **MA’LUMOT TEKSHIRILMAGAN — EKSPERT TASDIG‘I KERAK** — ilovaning o‘zida ishlatiladigan rasmiy status (pastda, 6-bo‘limda).

Bu hujjatda birorta ham konsentratsiya, koeffitsient yoki toksik/fatal diapazon qiymati **ataylab keltirilmagan**. Raqamli ilmiy qiymatlar faqat content pipeline orqali, manbasi bilan va review’dan keyin kiritiladi.

---

## 1. FORENSIC EXPERT konsepsiyasining professional tahlili

### 1.1. Muammo

Sud-tibbiy ekspert va sud-kimyogar kundalik ishida quyidagi ma’lumotlarni bir necha joydan yig‘adi:

1. **Toksikologik reference ma’lumotlar** (Baselt, Clarke’s, TIAFT jadvallari, ilmiy maqolalar) — ko‘pi pullik, qog‘ozda, ingliz tilida va mobil qurilmaga moslanmagan.
2. **Kalkulyatorlar** (Widmark, Henssge, eritish, LOD/LOQ) — Excel fayllarda, alohida mayda ilovalarda yoki qo‘lda hisoblanadi. Bu yerda formula, cheklov va manba ko‘pincha ko‘rsatilmaydi.
3. **Analitik metodlar** (GC-MS, LC-MS/MS) — SOP, UNODC qo‘llanmalari va darsliklarda tarqoq.
4. **Ta’lim** — rus va o‘zbek tilidagi sifatli, manbali, interaktiv material juda kam.
5. **AI-chatlar** — tez javob beradi, lekin manba to‘qiydi va xulosa chiqarishga moyil. Sud ekspertizasida bu jiddiy xavf.

### 1.2. Taklif qilinayotgan qiymat

FORENSIC EXPERT — bu **manbasi tekshiriladigan, offline ishlaydigan, ko‘p tilli professional ish stoli**:

- har bir fakt manbaga bog‘langan (provenance), statusi va oxirgi review sanasi ko‘rinadi;
- har bir kalkulyator INPUT → METHOD → FORMULA → RESULT → LIMITATIONS → REFERENCES tartibida ishlaydi;
- asosiy kutubxona va kalkulyatorlar internet bo‘lmasa ham ishlaydi;
- AI faqat ichki tekshirilgan bazadan javob beradi, manbasini ko‘rsatadi va yakuniy ekspert xulosasini bermaydi;
- EN / RU / UZ tillarida bitta canonical terminologiya qatlami bor.

### 1.3. Asosiy xavflar va ularga javob

| Xavf | Nima uchun jiddiy | Arxitekturadagi javob |
|---|---|---|
| Noto‘g‘ri ilmiy ma’lumot | Sud jarayonida noto‘g‘ri talqinga olib kelishi mumkin | Provenance modeli, 4 bosqichli review, `NEEDS_REVIEW` ma’lumot ekspert kontentida «tasdiqlangan» deb ko‘rsatilmaydi |
| Konsentratsiyani o‘lim sababi deb talqin qilish | Konsentratsiya o‘zi sabab-oqibatni isbotlamaydi | Majburiy «Interpretation notes» va kontekst maydonlari, «Fatal» o‘rniga «Reported postmortem concentrations» atamasi |
| Mualliflik huquqi | Baselt/Clarke’s kabi kitoblarni ko‘chirish noqonuniy | Faqat bibliografik havola va mustaqil strukturaviy ma’lumot; litsenziyali kontent faqat shartnoma bo‘yicha |
| AI gallyutsinatsiyasi | To‘qilgan DOI yoki qiymat | Citation faqat retrieval natijasidagi ID’lardan; javobdan keyin avtomatik tekshiruv |
| Store’dan rad etilish | Tibbiy/dori mavzusi | «Professional reference, education and scientific calculation software» positioning, disclaimerlar |
| Kontent hajmi | Yuzlab moddalarni sifatli to‘ldirish uzoq vaqt oladi | V1 hajmini cheklash, kontentni koddan alohida ishlab chiqish |

### 1.4. Asosiy xulosa

Loyihaning eng qiyin qismi kod emas — **ilmiy kontent va uning review jarayoni**. Shuning uchun kontent pipeline (CMS, review, signed content pack) PHASE 10 kutmasdan, soddalashtirilgan ko‘rinishda PHASE 3 dan boshlab ishlashi kerak. Aks holda tayyor ilovada tekshirilgan kontent bo‘lmaydi.

**Ilmiy muharrir/reviewer (kamida bitta sud-tibbiy ekspert va bitta sud-kimyogar) jamoada bo‘lishi — texnik shart.** Men kontentni tayyorlab, manbasini topa olaman, lekin `REVIEWED`/`VERIFIED` statusini faqat malakali inson bera oladi.

---

## 2. Jahondagi asosiy raqobatchilar va bizning farqimiz

> Eslatma: quyidagi ro‘yxat bilimlarimga asoslangan. Har bir mahsulotning hozirgi holati, narxi va mobil ilovasi bor-yo‘qligi PHASE 0 davomida App Store / Google Play va rasmiy saytlar orqali **[TEKSHIRISH KERAK]**.

### 2.1. Raqobatchilar toifalari

| Toifa | Misollar | Kuchli tomoni | Bizga nisbatan bo‘shliq |
|---|---|---|---|
| Klinik dori ma’lumotnomalari | Lexicomp, Micromedex (POISINDEX ichida), Epocrates, Medscape | Katta, tekshirilgan baza, kuchli brend | Klinik farmakologiyaga yo‘naltirilgan; postmortem toksikologiya, sud-kimyo metodlari, Henssge kabi vositalar yo‘q; rus/o‘zbek tili yo‘q; qimmat |
| Zaharlanish ma’lumotnomalari | TOXBASE (UK NPIS, faqat ro‘yxatdan o‘tgan klinik foydalanuvchilarga) | Klinik toksikologiya bo‘yicha kuchli | Sud-tibbiy talqin va laboratoriya yo‘q; geografik cheklangan |
| Sud toksikologiyasi reference kitoblari | Baselt «Disposition of Toxic Drugs and Chemicals in Man», Clarke’s Analysis of Drugs and Poisons (onlayn versiyasi bor) | Soha «oltin standarti» | Mobil ish oqimi yo‘q, kalkulyator yo‘q, ko‘p tilli emas, qimmat. **Biz ular bilan raqobatlashmaymiz — ularga havola qilamiz** |
| Bepul davlat ma’lumot bazalari | PubChem, NIST Chemistry WebBook, SWGDRUG monografiyalari, UNODC qo‘llanmalari, EUDA profillari | Ishonchli, bepul | Tarqoq, mobilga moslanmagan, talqin qatlami yo‘q |
| Bir maqsadli mayda ilovalar | O‘lim vaqtini hisoblash (Henssge), BAC/Widmark kalkulyatorlari, anatomiya/osteologiya ilovalari | Bitta vazifani bajaradi | Ko‘pchiligida manba, cheklov va noaniqlik ko‘rsatilmaydi; sifati turlicha |
| Umumiy AI-chatlar | Umumiy LLM ilovalari | Tez, qulay | Manba to‘qishi mumkin, yakuniy xulosa chiqaradi, maxfiylik nazorati yo‘q |
| Ta’lim platformalari | Universitet LMS, Quizlet tipidagi flashcard ilovalari | Ta’lim mexanikasi | Sud-tibbiy kontent yo‘q yoki manbasiz |

### 2.2. Bizning farqimiz (positioning)

1. **Sud ekspertizasiga ixtisoslashgan** — klinik emas, postmortem va laboratoriya konteksti.
2. **Provenance hamma joyda** — har bir raqam ostida «Manbalar» tugmasi.
3. **Offline-first** — laboratoriya va morgda internet bo‘lmasligi mumkin.
4. **EN / RU / UZ** — MDH va Markaziy Osiyo bozorida bunday professional mahsulot deyarli yo‘q (bu ham **[TEKSHIRISH KERAK]**, lekin bilishimcha shunday).
5. **Shaffof kalkulyatorlar** — formula, taxminlar, noaniqlik va cheklov ko‘rsatiladi.
6. **Xavfsiz AI** — RAG, faqat ichki manbalardan, yakuniy xulosasiz.
7. **Ta’lim va professional rejim bitta platformada** — talaba kelajakda professional obunachiga aylanadi.

---

## 3. V1’ga qaysi forensic yo‘nalishlar kirishi kerak

Tanlov mezonlari: (a) kundalik foydasi, (b) ilmiy asos va manbalarning ochiqligi, (c) litsenziya xavfi, (d) xato narxi.

### 3.1. V1 — kiradi

| Modul | Tarkibi | Sabab |
|---|---|---|
| **Laboratory Tools** | C1V1=C2V2, dilution, molarity, mass concentration, % eritma, birlik konvertatsiyasi, molekulyar massa, mean/median/SD/CV, chiziqli regressiya va kalibrlash, LOD/LOQ (kalibrlash egri chizig‘i usuli) | Matematik jihatdan aniq, litsenziya xavfi yo‘q, unit test bilan to‘liq tekshiriladi. Eng tez qiymat beradi |
| **Ethanol** | Birlik konvertatsiyasi (g/L, ‰, mg/dL, g/100 mL va h.k.), Widmark (klassik), Watson TBW asosidagi variant, eliminatsiya/back-calculation (diapazon bilan), qon/siydik/so‘lak konteksti | Eng ko‘p so‘raladigan sud-kimyo hisobi. Formulalar ommaviy nashr qilingan |
| **Substance Library (cheklangan)** | 50–100 ta eng ko‘p uchraydigan modda: etanol, opioidlar, benzodiazepinlar, amfetaminlar, kokain, kannabinoidlar, uglerod monoksidi, siyanid, metanol, etilenglikol, organofosfatlar, keng tarqalgan antidepressantlar va h.k. | To‘liq ro‘yxat ilmiy muharrir bilan birga tanlanadi. Sifat miqdordan muhim |
| **Analytical Methods** | TLC, GC, GC-FID, Headspace GC, GC-MS, HPLC, LC-MS/MS, UV-VIS, Immunoassay | Reference xarakterida (SOP emas), manbalari ochiq (UNODC, SWGDRUG, darsliklar) |
| **Specimens** | Qon (yurak/periferik), siydik, vitreous humor, jigar, oshqozon tarkibi, soch va h.k.: yig‘ish, saqlash, talqin cheklovlari | Talqin xatolarining eng katta manbasi — postmortem redistribution va namuna tanlash |
| **Forensic Medicine — PMI** | Postmortem o‘zgarishlar (algor/rigor/livor mortis) reference; Henssge nomogrammasi asosidagi hisob — **faqat** formula va koeffitsientlar birlamchi maqoladan tekshirilib, ekspert tasdiqlagandan keyin | Kundalik ish, lekin xato narxi yuqori — shuning uchun qat’iy review sharti |
| **Forensic Medicine — reference** | Shikastlanishlar (to‘mtoq/o‘tkir/o‘q), kuyishlar — matnli reference, terminologiya | Ta’lim va ish uchun foydali, hisob yo‘q — xavfi past |
| **Learn (asosiy)** | Glossary, flashcards, quiz (manbali izoh bilan), bookmarks, progress | Student Mode’ning minimal yadrosi |
| **Global Search** | Offline, multilingual | Mahsulot yadrosi |
| **Forensic AI (beta)** | RAG, faqat ichki baza bo‘yicha, cheklangan so‘rovlar | Farqlovchi funksiya, lekin xavfsiz chegaralar bilan |

### 3.2. V1.x / V2 — keyinga qoldiriladi

| Modul | Sabab |
|---|---|
| Forensic anthropology kalkulyatorlari (bo‘y, yosh, jins) | Formulalar populyatsiyaga bog‘liq (masalan, Trotter–Gleser formulalari aniq populyatsiyalar uchun ishlab chiqilgan). Mahalliy populyatsiyaga qo‘llash ilmiy jihatdan muammoli; ehtiyotkor dizayn talab qiladi |
| Forensic odontology, DVI | Ixtisoslashgan, foydalanuvchilar soni kam. V2 da INTERPOL DVI Guide asosida reference sifatida |
| Case studies (to‘liq), Exam mode | Kontent hajmi katta, review talab qiladi |
| Online scientific search (PubMed/Crossref) | V1 oxirida yoki V1.1 da — asosiy offline yadro barqaror bo‘lgandan keyin |
| Institution/University litsenziyalari | Billing va admin yadrosi barqaror bo‘lgandan keyin |
| Ma’lumot eksporti (PDF hisobot) | Huquqiy jihatdan ehtiyotkorlik talab qiladi (hisobot ekspert xulosasiga o‘xshab qolmasligi kerak) |

### 3.3. V1’da umuman yo‘q (35-bo‘lim talabiga muvofiq)

Ijtimoiy tarmoq, foydalanuvchilar o‘rtasida chat, reels, marketplace, reklama lentasi, aloqasi yo‘q funksiyalar.

---

## 4. Ishonchli ilmiy manbalarning aniq ro‘yxati

Har bir manba uchun **qanday foydalanish huquqiy jihatdan mumkinligi** ko‘rsatilgan. Litsenziya shartlari PHASE 0 da har bir manbaning rasmiy «Terms of Use» sahifasidan **[TEKSHIRISH KERAK]**.

### 4.1. 1-daraja — asosiy / yuqori ishonch

| Manba | Nima uchun | Foydalanish usuli |
|---|---|---|
| **PubChem** (NCBI/NIH) | Kimyoviy identifikatorlar, formula, molekulyar massa, sinonimlar, CAS (ehtiyotkorlik bilan) | PUG-REST API; ma’lumotlar ochiq. Atributsiya talab qilinadi |
| **PubMed / NCBI E-utilities** | Peer-reviewed maqolalarni topish, PMID | E-utilities API (API key bilan); faqat metadata/abstract, to‘liq matn emas |
| **PubMed Central (Open Access subset)** | Ochiq litsenziyali to‘liq matnlar | Faqat litsenziyasi ruxsat bergan maqolalar (CC BY va h.k.) |
| **NIST Chemistry WebBook** | Fizik-kimyoviy ma’lumotlar, ba’zi spektrlar | Onlayn reference; **NIST mass spektral kutubxonasi pullik** — ilovaga kiritilmaydi |
| **NIST Forensic Science / OSAC Registry** | Sud fanlari standartlari ro‘yxati | Bibliografik havola; standartlar matni ko‘chirilmaydi |
| **AAFS Standards Board (ASB)** standartlari | Masalan, sud toksikologiyasida metod validatsiyasi standarti (ANSI/ASB Standard 036 **[TEKSHIRISH KERAK]**) | Havola va qisqa mustaqil tavsif |
| **UNODC** | Laboratoriya qo‘llanmalari (giyohvand moddalarni aniqlash bo‘yicha tavsiya etilgan metodlar), Early Warning Advisory on NPS, xalqaro nazorat ro‘yxatlari | Ommaviy hujjatlar; havola va mustaqil xulosa |
| **WHO** | Xalqaro nazorat bo‘yicha tavsiyalar (ECDD), ICD-11 | Havola |
| **EUDA** (sobiq EMCDDA, 2024-yildan EU Drugs Agency **[TEKSHIRISH KERAK]**) | Modda profillari, NPS ma’lumotlari | Havola, litsenziyasi ruxsat bergan qismlar |
| **SWGDRUG** | Modda monografiyalari, analiz bo‘yicha tavsiyalar, bepul mass spektral kutubxona | Bepul; foydalanish shartlari **[TEKSHIRISH KERAK]** |
| **CDC / NIOSH** | Kimyoviy xavf ma’lumotlari (masalan, NIOSH Pocket Guide) | AQSh davlat ma’lumoti; havola |
| **FDA** | Dori yorliqlari (DailyMed orqali — NLM) | Ochiq ma’lumot |
| **ChEBI** (EMBL-EBI) | Kimyoviy ontologiya, sinflar | CC BY 4.0 **[TEKSHIRISH KERAK]** |
| **Peer-reviewed jurnallar** | Journal of Analytical Toxicology, Forensic Science International, Journal of Forensic Sciences, International Journal of Legal Medicine, Drug Testing and Analysis, Forensic Toxicology, Clinical Toxicology | Faqat bibliografik havola (DOI/PMID) + mustaqil ravishda chiqarilgan faktlar. Ochiq litsenziyali maqolalardan ko‘proq foydalanish mumkin |

### 4.2. 2-daraja — professional ilmiy adabiyot

| Manba | Foydalanish |
|---|---|
| Baselt R.C., *Disposition of Toxic Drugs and Chemicals in Man* (Biomedical Publications; eng so‘nggi nashr **[TEKSHIRISH KERAK]**) | **Faqat bibliografik havola.** Jadvallari ko‘chirilmaydi. Litsenziya olinsa — alohida shartnoma |
| *Clarke’s Analysis of Drugs and Poisons* (Pharmaceutical Press) | Faqat havola; onlayn versiyasi uchun institutsional litsenziya varianti alohida ko‘riladi |
| Schulz M. va hamk., terapevtik va toksik qon konsentratsiyalari bo‘yicha review (Critical Care jurnalida, 2012 va yangilangan versiyasi 2020 **[TEKSHIRISH KERAK]**) | Ochiq kirishli bo‘lsa, litsenziyasi (CC BY?) **[TEKSHIRISH KERAK]** — ruxsat bersa, atributsiya bilan strukturaviy ma’lumot sifatida |
| TIAFT ma’lumotlari (reference qiymatlar, UV spektrlar) | Foydalanish shartlari **[TEKSHIRISH KERAK]** |
| Saukko P., Knight B., *Knight’s Forensic Pathology* | Havola |
| Henssge C., Madea B. va hamk. — o‘lim vaqtini aniqlash bo‘yicha birlamchi maqolalar va monografiya | Henssge kalkulyatori uchun **birlamchi maqolalardan** formula va koeffitsientlar tekshiriladi |
| Widmark E.M.P. (1932) va keyingi modifikatsiyalar (Watson P.E. va hamk., 1980 — umumiy tana suvi **[TEKSHIRISH KERAK]**; Seidl, Forrest va boshqa modifikatsiyalar) | Ethanol kalkulyatorlari uchun birlamchi manbalar |
| Jones A.W. — etanol farmakokinetikasi bo‘yicha review maqolalar | Eliminatsiya tezligi diapazonlari va cheklovlar uchun |
| Moffat, Osselton, Widdop (Clarke’s muharrirlari), Levine B. *Principles of Forensic Toxicology*, Karch S. *Drug Abuse Handbook* | Havola, ta’lim kontenti uchun mustaqil tavsif |
| Rus tilidagi sud-tibbiyot darsliklari (masalan, Pigolkin Yu.I. tahriri ostidagi «Судебная медицина» **[TEKSHIRISH KERAK]**) | RU terminologiyasi uchun |

### 4.3. 3-daraja — milliy manbalar

| Davlat | Manba | Nima uchun |
|---|---|---|
| O‘zbekiston | **lex.uz** — Qonunchilik ma’lumotlari milliy bazasi | Narkotik vositalar, psixotrop moddalar va prekursorlar ro‘yxatlari, «Narkotik vositalar va psixotrop moddalar to‘g‘risida»gi qonun, sud-ekspertiza faoliyati to‘g‘risidagi qonunchilik. Aniq hujjat raqamlari va oxirgi tahrirlari **[TEKSHIRISH KERAK]** |
| O‘zbekiston | Sog‘liqni saqlash vazirligi, Respublika sud-tibbiy ekspertizasi ilmiy-amaliy markazi rasmiy hujjatlari | Milliy metodik ko‘rsatmalar (ochiq bo‘lsa) |
| Rossiya | Rossiya hukumati qarorlari (narkotik vositalar ro‘yxati), Sog‘liqni saqlash vazirligining sud-tibbiy ekspertiza tartibi | RU foydalanuvchilari uchun huquqiy kontekst |
| AQSh | DEA Controlled Substances Act Schedules (21 CFR 1308) | Huquqiy status |
| Yevropa Ittifoqi | EUDA, EU qonunchiligi (EUR-Lex) | Huquqiy status |
| Xalqaro | BMT 1961, 1971 va 1988 konvensiyalari jadvallari (UNODC/INCB) | Xalqaro nazorat statusi |

**Muhim qoida:** huquqiy status `jurisdiction` + `effective_date` + `source_id` bilan saqlanadi va universal deb ko‘rsatilmaydi. Foydalanuvchi o‘z yurisdiksiyasini tanlaydi.

### 4.4. Foydalanilmaydigan manbalar

- Bloglar, forumlar, Wikipedia (faqat birlamchi manbani topish uchun yo‘naltiruvchi sifatida mumkin, havola sifatida emas).
- Litsenziyasiz ko‘chirilgan PDF darsliklar.
- DrugBank — tijoriy foydalanish uchun litsenziya talab qiladi **[TEKSHIRISH KERAK]**; litsenziyasiz ishlatilmaydi.
- AI tomonidan yaratilgan, manbasi tekshirilmagan matn.

---

## 5. Har bir ma’lumot turi qaysi manbadan olinadi

| Ma’lumot turi | Birlamchi manba | Ikkilamchi / tekshiruv | Minimal status (ekspert kontentida ko‘rsatish uchun) |
|---|---|---|---|
| Kimyoviy nom, IUPAC, formula, molekulyar massa, InChIKey | PubChem | ChEBI, NIST WebBook | `VERIFIED` (avtomatik tekshirish + inson ko‘rigi) |
| CAS raqami | PubChem (CAS ro‘yxatga olish raqamlari CAS kompaniyasining ma’lumoti — foydalanish shartlari **[TEKSHIRISH KERAK]**) | NIST WebBook | `REVIEWED` |
| Sinonimlar (EN) | PubChem (filtrlangan — PubChemda juda ko‘p shovqinli sinonim bor) | UNODC, SWGDRUG | `REVIEWED` |
| RU / UZ nomlari | Rasmiy ro‘yxatlar (lex.uz, RU hukumat ro‘yxatlari), darsliklar | Ilmiy tarjimon + reviewer | `REVIEWED` |
| Dori/kimyoviy sinf | WHO ATC (dorilar uchun), ChEBI | Darsliklar | `REVIEWED` |
| Ta’sir mexanizmi | Peer-reviewed review maqolalar, FDA label | Darslik | `REVIEWED` |
| Metabolitlar | Peer-reviewed maqolalar (PMID/DOI) | Baselt/Clarke’s (havola sifatida) | `VERIFIED` |
| Terapevtik/toksik reference konsentratsiyalar | Peer-reviewed reference jadvallari (litsenziyasi ruxsat bersa), birlamchi maqolalar | Ikkinchi mustaqil manba | `VERIFIED` + majburiy kontekst (namuna turi, tirik/postmortem, birlik, n) |
| Postmortemda qayd etilgan konsentratsiyalar | Birlamchi case series / maqolalar | Review | `VERIFIED` + «bu chegara emas» ogohlantirishi |
| Namuna turlari, saqlash, barqarorlik | Peer-reviewed maqolalar, standartlar (ASB/OSAC), UNODC | Darsliklar | `REVIEWED` |
| Analitik metodlar | UNODC qo‘llanmalari, SWGDRUG tavsiyalari, ASB standartlari, darsliklar | Review maqolalar | `REVIEWED` |
| Interferensiyalar, cross-reactivity | Immunoassay ishlab chiqaruvchisi hujjatlari, maqolalar | — | `REVIEWED` |
| Kalkulyator formulalari | **Faqat birlamchi nashr** (asl maqola) | Mustaqil ikkinchi manba yoki hisoblangan test misollari | `VERIFIED` + unit test |
| Huquqiy status | Har bir davlatning rasmiy huquqiy manbasi | — | `VERIFIED` + `effective_date` |
| Terminologiya (glossary) | Darsliklar, ICD-11, standartlar | Uch tilli reviewer | `REVIEWED` |
| Quiz savollari va izohlari | Ichki bazadagi `REVIEWED`+ yozuvlar | O‘qituvchi | `REVIEWED` |

---

## 6. Scientific evidence / provenance modeli

### 6.1. Asosiy tamoyil

**Fakt (claim) va manba (source) — alohida obyektlar.** Har bir muhim fakt bir yoki bir nechta manbaga `citation` orqali bog‘lanadi. Manbasiz fakt ekspert kontentida ko‘rsatilmaydi.

```
Source ──< Citation >── Claim (fakt / qiymat / formula / matn bloki)
                          │
                          ├── review_status
                          ├── evidence_level
                          └── version tarixi (audit)
```

### 6.2. `sources` jadvali

```sql
CREATE TABLE sources (
  source_id          TEXT PRIMARY KEY,        -- ULID
  source_type        TEXT NOT NULL,           -- journal_article | book | book_chapter | guideline | standard | database | legislation | report | website
  title              TEXT NOT NULL,
  authors            TEXT,                    -- JSON massiv: [{family, given}]
  organization       TEXT,
  journal            TEXT,
  publication_year   INTEGER,
  edition            TEXT,
  volume             TEXT,
  issue              TEXT,
  pages              TEXT,
  doi                TEXT,                    -- Crossref orqali tekshiriladi
  pmid               TEXT,                    -- PubMed orqali tekshiriladi
  isbn               TEXT,
  official_url       TEXT,
  accessed_date      TEXT,                    -- ISO 8601
  license            TEXT,                    -- CC-BY-4.0 | public-domain | citation-only | licensed | unknown
  tier               INTEGER NOT NULL,        -- 1 | 2 | 3
  evidence_level     TEXT NOT NULL,           -- pastda
  identifier_verified INTEGER NOT NULL DEFAULT 0, -- DOI/PMID API orqali tekshirildimi
  review_status      TEXT NOT NULL,
  reviewed_by        TEXT,
  last_reviewed_at   TEXT,
  version            INTEGER NOT NULL DEFAULT 1
);
```

`identifier_verified` — DOI va PMID avtomatik ravishda Crossref va PubMed API orqali tekshiriladi (sarlavha va yil mos kelishi). Bu to‘qilgan DOI’ning bazaga tushishiga qarshi texnik himoya.

### 6.3. `claims` va `citations`

```sql
CREATE TABLE claims (
  claim_id        TEXT PRIMARY KEY,
  entity_type     TEXT NOT NULL,     -- substance | method | topic | calculator | specimen | ...
  entity_id       TEXT NOT NULL,
  field           TEXT NOT NULL,     -- masalan: 'metabolites', 'reported_postmortem_concentration'
  value_json      TEXT NOT NULL,     -- strukturaviy qiymat (raqam, birlik, kontekst)
  review_status   TEXT NOT NULL,
  evidence_level  TEXT NOT NULL,
  version         INTEGER NOT NULL,
  updated_at      TEXT NOT NULL
);

CREATE TABLE citations (
  claim_id     TEXT NOT NULL REFERENCES claims(claim_id),
  source_id    TEXT NOT NULL REFERENCES sources(source_id),
  locator      TEXT,                 -- sahifa, jadval, bo‘lim
  quote_hash   TEXT,                 -- ixtiyoriy: manbadagi joyni tekshirish uchun
  PRIMARY KEY (claim_id, source_id)
);
```

### 6.4. Review status

| Status | Ma’nosi | Ilovada ko‘rinishi |
|---|---|---|
| `VERIFIED` | Kamida ikki mustaqil tekshiruv (muharrir + reviewer), birlamchi manbaga mos | Odatiy ko‘rinish, yashil «Verified» belgisi |
| `REVIEWED` | Bitta malakali reviewer ko‘rib chiqqan | Odatiy ko‘rinish, «Reviewed» belgisi |
| `NEEDS_REVIEW` | Kiritilgan, lekin tekshirilmagan | Ilovaning production bazasiga **tushmaydi**. Agar istisno sifatida ko‘rsatish kerak bo‘lsa — sariq banner: **«MA’LUMOT TEKSHIRILMAGAN — EKSPERT TASDIG‘I KERAK»** |
| `OUTDATED` | Yangi ma’lumot bilan almashtirilgan yoki manba eskirgan | Kulrang banner, yangi versiyaga havola |
| `REJECTED` | Xato yoki ishonchsiz | Ilovada ko‘rsatilmaydi, faqat audit log’da |

CMS’dagi ish jarayoni statuslari (`DRAFT → NEEDS_REVIEW → REVIEWED → PUBLISHED`) yuqoridagi ilmiy statusdan alohida: biri «kontent qayerda turibdi», ikkinchisi «ilmiy ishonchlilik darajasi».

### 6.5. Evidence level (soddalashtirilgan, sudga moslashtirilgan)

| Daraja | Tavsif |
|---|---|
| `A` | Xalqaro standart, rasmiy qo‘llanma yoki tizimli review / ko‘p markazli ma’lumot |
| `B` | Peer-reviewed birlamchi tadqiqot (case series, kohort, validatsiya tadqiqoti) |
| `C` | Tan olingan darslik / monografiya / ekspert konsensusi |
| `D` | Alohida case report |
| `E` | Ekspert fikri (ichki), manba bilan tasdiqlanmagan — **ekspert kontentida faqat shunday deb belgilab** |

### 6.6. Konsentratsiya ma’lumotlari uchun majburiy kontekst

Har bir konsentratsiya `claim`ida quyidagilar majburiy — aks holda validator uni rad etadi:

- `matrix` (masalan: femoral blood, heart blood, serum/plasma, vitreous, urine);
- `population` (tirik/klinik, postmortem, haydovchilar va h.k.);
- `value_type` (single case, range, median, mean±SD, percentile);
- `unit` va konvertatsiya uchun `molecular_weight`;
- `n` (agar ma’lum bo‘lsa);
- `co_intoxicants` / kontekst izohi;
- `interpretation_note_id` (majburiy umumiy ogohlantirish: «Konsentratsiyaning o‘zi o‘lim sababini isbotlamaydi; tolerantlik, postmortem redistribution, namuna joyi, birgalikdagi moddalar va autopsiya topilmalari hisobga olinishi kerak»).

### 6.7. «Manbalar» tugmasi

Har bir kartochka, hisob natijasi va AI javobida «Manbalar» (Sources) tugmasi bottom sheet ochadi: manbalar ro‘yxati, daraja, evidence level, review statusi, oxirgi review sanasi, DOI/PMID havolalari (onlayn bo‘lsa ochiladi).

---

## 7. To‘liq ekranlar xaritasi

### 7.1. Birinchi ishga tushirish

```
S01 Splash (native, 1 kadr — Flutter dvigateli yuklanishi uchun)
 └─ S02 Language Selector  [FORENSIC EXPERT · Evidence · Science · Precision · Choose your language]
     └─ S03 Scientific Disclaimer (qabul qilish, bir marta)
         └─ S04 Mode Selection  [How will you use Forensic Expert?  Professional / Student-Resident / Research-Education]
             └─ S05 Jurisdiction (ixtiyoriy: huquqiy status uchun davlat; keyin o‘zgartirish mumkin)
                 └─ S06 Home
```

Login majburiy emas. Offline asosiy funksiyalar akkauntsiz ishlaydi. Akkaunt faqat obuna sinxronlash, bookmark sinxronlash va AI uchun kerak — bu store talablari va maxfiylik uchun ham afzal.

### 7.2. Asosiy navigatsiya (Bottom Navigation)

| Tab | Ekranlar |
|---|---|
| **Home** | S06 Home (mode’ga mos dashboard) · Global Search bar tepada |
| **Tools** | Barcha kalkulyatorlar katalogi |
| **Library** | Moddalar, metodlar, namunalar, mavzular, manbalar |
| **AI** | Forensic AI |
| **Profile** | Sozlamalar, obuna, til, mode, akkaunt |

### 7.3. Batafsil ekranlar ro‘yxati

**Home va qidiruv**
- S06 Home — Professional: Recent tools, Favorites, Calculators, Substance search, Analytical reference, Forensic AI. Student: Continue learning, Daily flashcards, Quiz, Courses. Research: Library, References, Search.
- S07 Home modul kartalari: Forensic Medicine, Forensic Toxicology, Laboratory, Substance Library, Learn, Forensic AI
- S08 Global Search (to‘liq ekran) — kategoriyalangan natijalar
- S09 Search — kategoriya bo‘yicha barcha natijalar
- S10 External Scientific Search (onlayn, alohida tab: «Ilmiy manbalardan qidirish»)
- S11 External natija tafsiloti (PubMed/PubChem/Crossref metadata, «EXTERNAL — NOT VERIFIED» belgisi)

**Forensic Toxicology**
- S20 Toxicology hub: Ethanol · Drugs · Poisons · Metabolites · Specimens · Analytical Methods · Reference Concentrations
- S21 Ethanol hub
- S22 Ethanol unit converter
- S23 Widmark kalkulyatori
- S24 Back-calculation kalkulyatori
- S25 Specimen list → S26 Specimen detail
- S27 Reference concentrations explorer (filtr: matrix, population)

**Substance Library**
- S30 Library (sinflar, A–Z, filtrlar)
- S31 Substance detail (tablar: Overview · Analysis · Concentrations · Interpretation · Legal · References)
- S32 Metabolite detail
- S33 Legal status (yurisdiksiya bo‘yicha)
- S34 Compare substances (V1.x)

**Analytical Methods**
- S40 Methods list → S41 Method detail (Principle, Applications, Specimen, Sample prep overview, Strengths, Limitations, Interferences, Confirmation requirements, References, «Bu SOP emas» banner)

**Laboratory Tools**
- S50 Lab tools katalogi
- S51–S62 Kalkulyatorlar: C1V1=C2V2, Dilution series, Molarity, Mass concentration, Percent solution, Unit conversion, Molecular weight, Calibration curve + linear regression, Descriptive stats (mean/median/SD/CV), LOD/LOQ
- S63 Universal kalkulyator shabloni (barcha kalkulyatorlar bitta shablon: INPUT · METHOD · FORMULA · RESULT · LIMITATIONS · REFERENCES)

**Forensic Medicine**
- S70 Forensic Medicine hub
- S71 Postmortem interval hub → S72 Postmortem changes reference (algor/rigor/livor) → S73 Henssge kalkulyatori (review’dan o‘tgandan keyin)
- S74 Injury reference (blunt/sharp/firearm) → S75 Topic detail
- S76 Burns reference
- S77 Anthropology, S78 Odontology, S79 DVI (V2)

**Learn (Student Mode)**
- S80 Learn hub · S81 Course → S82 Lesson · S83 Glossary → S84 Term detail · S85 Flashcards (spaced repetition) · S86 Quiz → S87 Quiz result (izoh + manba) · S88 Case studies → S89 Case · S90 Exam mode · S91 Bookmarks · S92 Progress

**Forensic AI**
- S100 AI chat (PII warning banneri, yuqorida doimiy)
- S101 Sources bottom sheet
- S102 AI tarixi (lokal, shifrlangan)
- S103 PII aniqlangani haqida ogohlantirish dialogi

**Profile / Settings**
- S110 Profile · S111 Language · S112 Mode · S113 Theme (Light/Dark/System) · S114 Jurisdiction · S115 Units (SI / an’anaviy) · S116 Subscription (planlar, Manage Subscription, Restore Purchases) · S117 Scientific database versiyasi («Scientific database last updated …», yangilash) · S118 Privacy Policy · S119 Terms · S120 Scientific Disclaimer · S121 Delete Account · S122 About / Licenses / Atributsiyalar · S123 Secure notes (shifrlangan lokal qaydlar) · S124 Accessibility sozlamalari

**Umumiy komponentlar**
- Paywall bottom sheet · Sources bottom sheet · Offline banner · Review status badge · «MA’LUMOT TEKSHIRILMAGAN» banner · Content update dialog

---

## 8. Global Search qanday ishlaydi

### 8.1. Talablar

Tez (<50 ms lokal so‘rov, 1500+ yozuvli bazada), typo-tolerant, ko‘p tilli, sinonim va transliteratsiyani biladi, offline.

### 8.2. Texnologiya tanlovi

| Variant | Baho |
|---|---|
| **SQLite FTS5 (drift orqali)** | ✅ Tanlov. Barcha platformada yetuk, `trigram` tokenizer bilan qisman/typo moslik, BM25 reytingi, bitta fayl — content pack bilan birga yetkaziladi |
| Isar / ObjectBox full-text | Yetarli emas: ko‘p tilli typo-tolerantlik zaif, Isar loyihasining kelajagi noaniq **[TEKSHIRISH KERAK]** |
| Meilisearch/Typesense (server) | Offline-first talabga zid |
| O‘zimizning in-memory indeks | Murakkab, xotira sarfi katta |

### 8.3. Qidiruv pipeline

```
Foydalanuvchi matni
  │
  ├─ 1. Normalizatsiya: lowercase, Unicode NFKC, diakritikani olib tashlash,
  │     o‘zbek apostroflari (o‘ o' oʻ o` → o'), ё→е, defis/bo‘shliq birxillashtirish
  │
  ├─ 2. Transliteratsiya: kirill ↔ lotin (rus va o‘zbek kirill/lotin jadvallari),
  │     masalan «метамфетамин» → «metamfetamin»
  │
  ├─ 3. Parallel so‘rovlar (bitta SQL tranzaksiyada):
  │     a) Aniq moslik — search_terms.normalized = ?
  │     b) Prefiks moslik — FTS5 unicode61 indeksi
  │     c) Typo moslik — FTS5 trigram indeksi
  │     d) CAS / formula maxsus parser (masalan, «C10H15N» yoki «537-46-2» shakli aniqlanadi)
  │
  ├─ 4. Canonical ID ga birlashtirish (har bir term → entity_id)
  │
  ├─ 5. Reyting: aniq > prefiks > trigram; sinonim < canonical nom;
  │     foydalanuvchi tili ustuvor; status (VERIFIED > REVIEWED); mashhurlik
  │
  └─ 6. Kategoriyalash: SUBSTANCE · METABOLITES · METHODS · CALCULATORS ·
        LEARNING · GLOSSARY · CASES · REFERENCES
```

### 8.4. `search_terms` jadvali

```sql
CREATE TABLE search_terms (
  term_id      INTEGER PRIMARY KEY,
  entity_type  TEXT NOT NULL,
  entity_id    TEXT NOT NULL,
  lang         TEXT,              -- en | ru | uz | null (CAS, formula)
  term         TEXT NOT NULL,     -- ko‘rsatiladigan shakl
  normalized   TEXT NOT NULL,     -- normalizatsiya + transliteratsiya natijasi
  term_kind    TEXT NOT NULL,     -- canonical | localized | synonym | abbreviation | misspelling | cas | formula
  weight       REAL NOT NULL DEFAULT 1.0
);
CREATE VIRTUAL TABLE search_fts_word USING fts5(normalized, content='search_terms', content_rowid='term_id', tokenize='unicode61 remove_diacritics 2');
CREATE VIRTUAL TABLE search_fts_tri  USING fts5(normalized, content='search_terms', content_rowid='term_id', tokenize='trigram');
```

Indekslar **build vaqtida** (content pipeline’da) quriladi va tayyor holda yetkaziladi — qurilmada indekslash vaqti sarflanmaydi.

### 8.5. Ishlash tezligi bo‘yicha qarorlar

- Qidiruv alohida isolate’da (drift’ning background isolate rejimi) — UI thread bloklanmaydi.
- 150 ms debounce, oldingi so‘rov bekor qilinadi.
- Natijalar soni har kategoriyada 5 ta bilan cheklangan, «Barchasi» tugmasi orqali to‘liq ro‘yxat.

### 8.6. Onlayn ilmiy qidiruv

Alohida tab: **EXTERNAL SCIENTIFIC SEARCH**. O‘z serverimizdagi proxy orqali (API kalitlari ilovada saqlanmaydi, rate limit va kesh boshqariladi):

- PubMed (E-utilities) — maqolalar;
- PubChem (PUG-REST) — birikmalar;
- Crossref REST API — DOI metadata;
- NIST WebBook — rasmiy API mavjudligi **[TEKSHIRISH KERAK]**; bo‘lmasa faqat tashqi havola.

Natijalar kulrang «EXTERNAL — NOT VERIFIED» belgisi bilan chiqadi va **hech qachon avtomatik ravishda ichki bazaga tushmaydi**. Professional foydalanuvchi «Taklif qilish» tugmasi orqali CMS’dagi review navbatiga yuborishi mumkin.

---

## 9. Substance Library database sxemasi

```sql
-- Asosiy entity
CREATE TABLE substances (
  substance_id      TEXT PRIMARY KEY,     -- ULID
  canonical_name    TEXT NOT NULL UNIQUE, -- 'methamphetamine'
  pubchem_cid       INTEGER,
  cas_rn            TEXT,
  inchikey          TEXT,
  molecular_formula TEXT,
  molecular_weight  REAL,                 -- g/mol, PubChem’dan
  smiles            TEXT,
  entity_kind       TEXT NOT NULL,        -- drug | poison | metabolite | endogenous | precursor | element | gas
  tier_access       TEXT NOT NULL,        -- free | pro
  review_status     TEXT NOT NULL,
  last_reviewed_at  TEXT,
  content_version   TEXT NOT NULL         -- '2026.10'
);

-- Ko‘p tilli nomlar va matnlar
CREATE TABLE substance_i18n (
  substance_id   TEXT NOT NULL REFERENCES substances,
  lang           TEXT NOT NULL,           -- en | ru | uz | (kelajakda es, fr, de, tr, ar, pt, zh, hi)
  name           TEXT NOT NULL,
  description_md TEXT,
  mechanism_md   TEXT,
  analytical_notes_md TEXT,
  interpretation_md   TEXT,
  stability_md   TEXT,
  translation_status TEXT NOT NULL,       -- machine_draft | translated | reviewed
  PRIMARY KEY (substance_id, lang)
);

-- Sinonimlar (search_terms ga ham eksport qilinadi)
CREATE TABLE substance_synonyms (
  substance_id TEXT NOT NULL REFERENCES substances,
  lang         TEXT,
  synonym      TEXT NOT NULL,
  kind         TEXT NOT NULL,             -- trade_name | street_name | abbreviation | iupac | other
  source_id    TEXT REFERENCES sources
);

-- Sinflar (ierarxik)
CREATE TABLE classes (class_id TEXT PRIMARY KEY, parent_id TEXT, scheme TEXT); -- scheme: atc | chebi | forensic_custom
CREATE TABLE class_i18n (class_id TEXT, lang TEXT, name TEXT, PRIMARY KEY (class_id, lang));
CREATE TABLE substance_classes (substance_id TEXT, class_id TEXT, PRIMARY KEY (substance_id, class_id));

-- Metabolizm grafi
CREATE TABLE metabolic_relations (
  parent_id      TEXT NOT NULL REFERENCES substances,
  metabolite_id  TEXT NOT NULL REFERENCES substances,
  pathway        TEXT,                    -- masalan: N-demethylation
  enzymes        TEXT,                    -- JSON
  is_active      INTEGER,                 -- farmakologik faol (null = noma’lum)
  forensic_marker INTEGER,                -- iste’mol belgisi sifatida ahamiyatli
  claim_id       TEXT REFERENCES claims
);

-- Namuna turlari
CREATE TABLE specimens (specimen_id TEXT PRIMARY KEY, code TEXT UNIQUE);  -- femoral_blood, heart_blood, vitreous, urine, hair, liver ...
CREATE TABLE specimen_i18n (specimen_id TEXT, lang TEXT, name TEXT, collection_md TEXT, storage_md TEXT, limitations_md TEXT, PRIMARY KEY (specimen_id, lang));

-- Moddaga xos namuna eslatmalari (masalan, postmortem redistribution moyilligi)
CREATE TABLE substance_specimen_notes (
  substance_id TEXT, specimen_id TEXT, lang TEXT, note_md TEXT, claim_id TEXT,
  PRIMARY KEY (substance_id, specimen_id, lang)
);

-- Konsentratsiyalar — eng sezgir jadval
CREATE TABLE concentration_records (
  record_id        TEXT PRIMARY KEY,
  substance_id     TEXT NOT NULL REFERENCES substances,
  category         TEXT NOT NULL,         -- therapeutic_reference | toxic_reference | reported_postmortem | reported_impairment
  specimen_id      TEXT NOT NULL REFERENCES specimens,
  population       TEXT NOT NULL,         -- clinical | postmortem | dui_drivers | ...
  value_type       TEXT NOT NULL,         -- range | single | median_range | mean_sd | percentile
  value_low        REAL,
  value_high       REAL,
  value_central    REAL,
  unit             TEXT NOT NULL,         -- kanonik: mg/L (ko‘rsatishda konvertatsiya)
  n_cases          INTEGER,
  context_md       TEXT,                  -- birgalikdagi moddalar, holatlar
  claim_id         TEXT NOT NULL REFERENCES claims,  -- => citations => sources (MAJBURIY)
  review_status    TEXT NOT NULL
);
-- E’tibor: 'fatal_threshold' degan kategoriya ATAYLAB yo‘q.

-- Analitik metodlarga bog‘lanish
CREATE TABLE substance_methods (
  substance_id TEXT, method_id TEXT, specimen_id TEXT,
  role TEXT,                               -- screening | confirmation | quantitation
  notes_md TEXT, claim_id TEXT,
  PRIMARY KEY (substance_id, method_id, specimen_id)
);

-- Interferensiyalar (masalan, immunoassay cross-reactivity)
CREATE TABLE interferences (
  interference_id TEXT PRIMARY KEY, substance_id TEXT, method_id TEXT,
  interfering_substance_id TEXT, description_md TEXT, claim_id TEXT
);

-- Huquqiy status — yurisdiksiyaga bog‘liq
CREATE TABLE legal_status (
  substance_id   TEXT NOT NULL,
  jurisdiction   TEXT NOT NULL,           -- ISO 3166 (UZ, RU, US, ...) yoki 'UN', 'EU'
  status_code    TEXT NOT NULL,           -- masalan: 'UN-1961-I', 'US-CSA-II', 'UZ-list-...' (aniq kodlar rasmiy hujjatdan)
  status_text    TEXT,
  effective_date TEXT NOT NULL,
  source_id      TEXT NOT NULL REFERENCES sources,
  review_status  TEXT NOT NULL,
  PRIMARY KEY (substance_id, jurisdiction, status_code)
);
```

**Asosiy qarorlar va sabablar:**

- Konsentratsiyalar **har doim** `mg/L` da saqlanadi va UI’da tanlangan birlikka konvertatsiya qilinadi — birlik chalkashligidan kelib chiqadigan xatoning oldini olish uchun. µmol/L ga konvertatsiya `molecular_weight` orqali.
- `concentration_records.claim_id NOT NULL` — manbasiz konsentratsiya bazaga yozilishi texnik jihatdan mumkin emas.
- Moddalar kartochkasida konsentratsiyalar jadval ko‘rinishida, har bir qatorda matrix/population/n/manba bilan. Universal «toksik chegara» bitta katta raqam ko‘rinishida hech qachon ko‘rsatilmaydi.

---

## 10. Forensic Medicine database sxemasi

Forensic medicine kontenti ikki turga bo‘linadi: **mavzular (reference matnlar)** va **hisoblash metodlari**.

```sql
-- Mavzular daraxti (postmortem changes, injuries, burns, anthropology, odontology, DVI ...)
CREATE TABLE fm_topics (
  topic_id       TEXT PRIMARY KEY,
  parent_id      TEXT REFERENCES fm_topics,
  code           TEXT UNIQUE,              -- 'pm.livor_mortis', 'injury.sharp.stab'
  domain         TEXT NOT NULL,            -- pmi | postmortem_changes | trauma | burns | anthropology | odontology | dvi
  tier_access    TEXT NOT NULL,
  review_status  TEXT NOT NULL,
  content_version TEXT NOT NULL
);
CREATE TABLE fm_topic_i18n (
  topic_id TEXT, lang TEXT, title TEXT, body_md TEXT, limitations_md TEXT,
  translation_status TEXT, PRIMARY KEY (topic_id, lang)
);
-- Matn bloklari darajasida manbalar
CREATE TABLE fm_topic_claims (topic_id TEXT, claim_id TEXT, PRIMARY KEY (topic_id, claim_id));

-- Rasmlar/diagrammalar (faqat o‘zimiz chizgan yoki ochiq litsenziyali)
CREATE TABLE media_assets (
  asset_id TEXT PRIMARY KEY, kind TEXT, path TEXT, license TEXT, source_id TEXT,
  alt_text_key TEXT, sensitive INTEGER NOT NULL DEFAULT 0   -- sezgir tasvirlar blur bilan, bosib ochiladi
);

-- Hisoblash metodlari (Henssge, kelajakda: stature, age estimation)
CREATE TABLE calc_methods (
  method_id        TEXT PRIMARY KEY,       -- 'henssge_rectal_1988' kabi
  domain           TEXT NOT NULL,
  engine_key       TEXT NOT NULL,          -- Dart calculation engine’dagi implementatsiya ID
  engine_version   TEXT NOT NULL,
  formula_latex    TEXT NOT NULL,
  applicability_md TEXT,                   -- qachon qo‘llash mumkin / mumkin emas
  population       TEXT,                   -- antropologiya formulalari uchun majburiy
  claim_id         TEXT NOT NULL REFERENCES claims,
  review_status    TEXT NOT NULL
);
CREATE TABLE calc_method_params (
  method_id TEXT, param_key TEXT, value REAL, unit TEXT, claim_id TEXT NOT NULL,
  PRIMARY KEY (method_id, param_key)
);
CREATE TABLE calc_method_i18n (method_id TEXT, lang TEXT, name TEXT, assumptions_md TEXT, limitations_md TEXT, PRIMARY KEY (method_id, lang));

-- Kalkulyatorning mustaqil tekshirilgan test misollari (manba maqoladagi ishlangan misol yoki mustaqil hisob)
CREATE TABLE calc_reference_cases (
  case_id TEXT PRIMARY KEY, method_id TEXT, inputs_json TEXT, expected_json TEXT,
  tolerance REAL, source_id TEXT, note TEXT
);
```

**Muhim qaror:** koeffitsientlar (`calc_method_params`) kontent bazasida saqlanadi va har biri `claim_id` orqali manbaga bog‘langan, formula logikasi esa Dart kodida. Bu ikkalasini alohida tekshirish imkonini beradi. `calc_reference_cases` CI’da avtomatik test sifatida ishlatiladi: content pack yangilanganda ham kalkulyator natijalari qayta tekshiriladi.

**Henssge bo‘yicha alohida eslatma:** nomogramma va unga asoslangan formulalar ilmiy adabiyotda keng nashr qilingan. Lekin aniq koeffitsientlar, tuzatish omillari jadvali va 95% ishonch oralig‘i birlamchi maqolalardan aniq olinishi, ekspert tomonidan tekshirilishi va nashr qilingan ishlangan misollar bilan solishtirilishi shart. Shu bajarilmaguncha kalkulyator `NEEDS_REVIEW` holatda va production’da yashirin bo‘ladi. Litsenziya jihatidan: formulaning o‘zi mualliflik huquqi obyekti emas (bu umumiy tamoyil), lekin nomogramma tasvirini ko‘chirmaymiz — o‘zimiz hisoblaymiz va chizamiz. Agar yuridik maslahatchi boshqacha xulosa bersa, reja qayta ko‘riladi.

---

## 11. Student Mode arxitekturasi

### 11.1. Kontent modeli

```
Track (Forensic Toxicology)
 └─ Course (Ethanol in Forensic Practice)
     └─ Module
         └─ Lesson (matn bloklari + ichki havolalar: substance/method/calculator)
              ├─ Glossary terminlari
              ├─ Flashcard to‘plami
              └─ Quiz
Case Study (alohida, bir nechta lesson’ga bog‘lanadi)
```

```sql
CREATE TABLE courses (course_id TEXT PRIMARY KEY, track TEXT, level TEXT, tier_access TEXT, review_status TEXT);
CREATE TABLE lessons (lesson_id TEXT PRIMARY KEY, course_id TEXT, order_idx INTEGER, est_minutes INTEGER, review_status TEXT);
CREATE TABLE lesson_i18n (lesson_id TEXT, lang TEXT, title TEXT, body_md TEXT, PRIMARY KEY (lesson_id, lang));
CREATE TABLE lesson_claims (lesson_id TEXT, claim_id TEXT);              -- manbalar

CREATE TABLE glossary_terms (term_id TEXT PRIMARY KEY, canonical TEXT, review_status TEXT);
CREATE TABLE glossary_i18n (term_id TEXT, lang TEXT, term TEXT, definition_md TEXT, translation_status TEXT, PRIMARY KEY (term_id, lang));

CREATE TABLE quiz_questions (
  question_id TEXT PRIMARY KEY, lesson_id TEXT, type TEXT,            -- single | multiple | true_false | numeric
  difficulty INTEGER, claim_id TEXT NOT NULL, review_status TEXT
);
CREATE TABLE quiz_question_i18n (question_id TEXT, lang TEXT, stem_md TEXT, options_json TEXT, explanation_md TEXT, PRIMARY KEY (question_id, lang));

CREATE TABLE flashcards (card_id TEXT PRIMARY KEY, deck_id TEXT, claim_id TEXT, review_status TEXT);
CREATE TABLE flashcard_i18n (card_id TEXT, lang TEXT, front_md TEXT, back_md TEXT, PRIMARY KEY (card_id, lang));
```

**Foydalanuvchi ma’lumotlari** (alohida `user.db` — content bazasidan ajratilgan, chunki content pack yangilanganda o‘chib ketmasligi kerak):

```sql
CREATE TABLE progress (item_type TEXT, item_id TEXT, status TEXT, score REAL, updated_at TEXT, PRIMARY KEY (item_type, item_id));
CREATE TABLE srs_state (card_id TEXT PRIMARY KEY, ease REAL, interval_days REAL, due_at TEXT, reps INTEGER, lapses INTEGER);
CREATE TABLE bookmarks (entity_type TEXT, entity_id TEXT, created_at TEXT, PRIMARY KEY (entity_type, entity_id));
CREATE TABLE quiz_attempts (attempt_id TEXT PRIMARY KEY, quiz_scope TEXT, started_at TEXT, finished_at TEXT, score REAL, answers_json TEXT);
```

### 11.2. Mexanika

- **Flashcards:** SM-2 tipidagi spaced repetition (ochiq, oddiy algoritm; o‘zimiz yozamiz, unit test bilan). FSRS kabi zamonaviyroq algoritm keyingi variant sifatida.
- **Quiz:** har bir savoldan keyin izoh + «Manbalar». Har bir savol `claim_id` ga bog‘langan — ya’ni javob ham manbali.
- **Exam mode:** taymer, izohlar oxirida, tasodifiy savollar (V1.x).
- **Progress:** lokal; akkaunt bo‘lsa — sinxronlash.

### 11.3. Professional ish oqimiga xalal bermaslik

Mode `user_settings.mode` da saqlanadi va Home dashboard, Library tartibi va AI’ning tushuntirish uslubini o‘zgartiradi. Professional rejimda Learn faqat Home’dagi bitta kartochka ko‘rinishida. Mode Profile → Mode orqali istalgan vaqtda o‘zgartiriladi.

---

## 12. AI/RAG qanday ishlashi

### 12.1. Umumiy sxema

```
[Ilova]                                   [Bizning backend]                           [LLM API]
 Savol
  │
  ├─ 1. On-device PII filtri ──(topilsa: ogohlantirish, foydalanuvchi tahrirlaydi)
  │
  ├─ 2. Lokal retrieval (ixtiyoriy oldindan: FTS5 orqali entity ID’lar)
  │
  └─ 3. HTTPS ─────────────────────────► 4. Auth + obuna/limit tekshiruvi
                                          5. Server PII filtri (ikkinchi qatlam)
                                          6. Hybrid retrieval:
                                             - BM25 (Postgres FTS)
                                             - Vektor qidiruv (pgvector, ko‘p tilli embedding)
                                             - Faqat PUBLISHED + VERIFIED/REVIEWED chunk’lar
                                          7. Rerank, top-k chunk (har biri chunk_id + source_ids)
                                          8. Prompt: tizim qoidalari + chunk’lar ──────► 9. Generatsiya
                                          10. Post-validator: ◄──────────────────────────┘
                                             - har bir [cite:chunk_id] retrieval to‘plamida bormi?
                                             - raqamlar chunk matnida bormi?
                                             - taqiqlangan xulosa naqshlari yo‘qmi?
                                          11. Javob + strukturaviy «Sources» ro‘yxati
  ◄────────────────────────────────────────┘
 Javob + Sources bottom sheet
```

### 12.2. Javob ustuvorligi

1. Ichki `VERIFIED` bilimlar bazasi.
2. Ichki `REVIEWED` manbalar.
3. Ruxsat berilgan tashqi manbalar (PubMed abstract’lari, PubChem) — javobda **«EXTERNAL — NOT VERIFIED»** deb alohida belgilanadi.
4. Ishonchli kontekst topilmasa — «Ichki tekshirilgan bazada bu savolga ishonchli javob topilmadi» deb javob beradi va taxmin qilmaydi.

### 12.3. Citation to‘qishga qarshi himoya

- Model DOI yoki sarlavha yozmaydi — faqat `[cite:chunk_id]` markerlari. «Sources» ro‘yxatini **server bazadan** quradi, modelning matnidan emas. Shu sababli to‘qilgan manba texnik jihatdan ko‘rsatila olmaydi.
- Retrieval to‘plamida yo‘q `chunk_id` → javob qayta generatsiya qilinadi yoki shu jumla olib tashlanadi.
- Javobdagi raqamli qiymat (konsentratsiya, koeffitsient) keltirilgan chunk matnida topilmasa → validator ogohlantiradi va javobni bloklaydi.

### 12.4. Xavfsizlik chegarasi (17-bo‘lim)

Tizim ko‘rsatmasi va post-validator quyidagilarni taqiqlaydi: aniq o‘lim sababini aytish, «bu zaharlanish», «ekspert xulosasi shunday», «shaxs mast bo‘lgan», jinoyat sodir etilganligi haqidagi xulosalar. Buning o‘rniga javob tuzilmasi:

1. Mavjud ilmiy ma’lumot (manbali)
2. Differensial mulohazalar
3. Talqin cheklovlari
4. Manbalar
5. Doimiy izoh: «Yakuniy professional xulosa malakali mutaxassisga tegishli»

Bu qoidalar uchun alohida **AI evaluation to‘plami** (200+ test savoli, EN/RU/UZ) tuziladi va har bir prompt/model o‘zgarishida avtomatik ishga tushiriladi.

### 12.5. Model va infratuzilma

- LLM: Anthropic Claude API (server tarafdan; ilovada API kalit yo‘q). Ko‘p tilli (EN/RU/UZ) sifat PHASE 8 boshida eval to‘plami bilan o‘lchanadi. Model tanlovi narx/sifat bo‘yicha o‘sha paytda yakunlanadi.
- Embedding: ko‘p tilli embedding modeli; tanlov o‘zbek tilidagi retrieval sifatini eval qilib aniqlanadi **[TEKSHIRISH KERAK — o‘zbek tili uchun sifat]**.
- Backend: Supabase (Postgres + pgvector + Edge Functions + Auth) — tez boshlash uchun. Muqobil: o‘z serverimiz (Cloud Run + Postgres). Qaror PHASE 1 da.
- Logging: savol matni default holatda **saqlanmaydi**; faqat anonim metrikalar (token soni, kechikish, validator natijasi). Foydalanuvchi ixtiyoriy ravishda «javobni yaxshilash uchun yuborish» ni tanlashi mumkin.

---

## 13. Offline / online chegarasi

| Funksiya | Offline | Online kerak | Izoh |
|---|---|---|---|
| Til tanlash, onboarding | ✅ | — | |
| Global Search (ichki baza) | ✅ | — | |
| Substance Library, Methods, Specimens, Forensic Medicine | ✅ | — | Free yoki Pro, obuna holati lokal keshlangan |
| Barcha kalkulyatorlar | ✅ | — | Hisob serverga bormaydi |
| Learn: lessons, glossary, flashcards, quiz, progress | ✅ | Sinxronlash uchun | |
| Secure notes | ✅ | — | Faqat lokal, shifrlangan |
| Content pack yangilanishi | — | ✅ | Fonda, Wi-Fi’da yoki foydalanuvchi ruxsati bilan |
| External Scientific Search | — | ✅ | |
| Forensic AI | — | ✅ | Offline bo‘lsa aniq xabar |
| Obuna xaridi / restore | — | ✅ | Obuna holati keshlangan, grace period bilan |
| Akkaunt, sinxronlash | — | ✅ | |

**Qoida:** navigatsiya vaqtida hech qanday tarmoq so‘rovi bloklamaydi. Har bir ekran avval lokal ma’lumotni ko‘rsatadi.

---

## 14. Privacy va security modeli

### 14.1. Ma’lumotlar minimalizmi

- Akkauntsiz ishlash mumkin. Akkaunt: email yoki Sign in with Apple / Google. (Agar uchinchi tomon login bo‘lsa, Apple Sign in with Apple’ni ham taklif qilishni talab qiladi — Guideline 4.8 **[TEKSHIRISH KERAK]**.)
- Ism, lavozim, tashkilot so‘ralmaydi (ixtiyoriy).
- Analitika: privacy-friendly, PII’siz, opt-in (masalan, o‘z serverimizda yoki PII yubormaydigan konfiguratsiyada). Reklama SDK’lari **yo‘q**.

### 14.2. AI va PII

- **On-device PII detektori** (regex + qoidalar): ism-familiya shakllari (kirill/lotin), pasport (O‘zbekiston formati va boshqalar), telefon raqamlari, manzil belgilari, email, sana + ism birikmasi, ish/case raqamlari («№», «Ish raqami», «дело №» kabi naqshlar).
- Topilsa: matn ichida ajratib ko‘rsatiladi, «Olib tashlash» / «Baribir yuborish» tanlovi. Default — yubormaslik.
- AI oynasi tepasida doimiy banner: «Shaxsiy ma’lumot, ism, ish raqami yoki pasport ma’lumotlarini kiritmang».
- Server tarafda ikkinchi qatlam filtri; LLM provayderi bilan ma’lumotni o‘qitishda ishlatmaslik sharti (API shartlariga muvofiq **[TEKSHIRISH KERAK]**).

### 14.3. Lokal ma’lumotlarni himoyalash

| Ma’lumot | Himoya |
|---|---|
| Content DB | Shifrlanmagan (ochiq ilmiy ma’lumot), lekin **imzolangan** (Ed25519) — o‘zgartirilganini aniqlash uchun |
| User DB (progress, bookmarks) | Platforma himoyasi (iOS Data Protection, Android app sandbox) |
| Secure notes, AI tarixi | SQLCipher yoki maydon darajasida AES-256-GCM; kalit iOS Keychain / Android Keystore’da (`flutter_secure_storage`). Ixtiyoriy biometrik qulf |
| Tokenlar | Keychain / Keystore |

### 14.4. Tarmoq va backend

- Faqat HTTPS (TLS 1.2+), ATS (iOS) yoqilgan, Android `cleartextTrafficPermitted=false`.
- API kalitlari ilovada yo‘q — barcha uchinchi tomon API’lar backend proxy orqali.
- Rate limiting, obuna tekshiruvi serverda (App Store Server API / Google Play Developer API).
- Content pack: `manifest.json` + SHA-256 xeshlar + Ed25519 imzo. Ochiq kalit ilovaga o‘rnatilgan; kalit almashtirish (rotation) rejasi bor.
- Kodni obfuskatsiya (`--obfuscate --split-debug-info`) — sir saqlash uchun emas, faqat qo‘shimcha to‘siq sifatida.

### 14.5. Huquqiy hujjatlar

Privacy Policy, Terms of Use, Scientific Disclaimer, Data Safety (Google Play), App Privacy «nutrition label» (App Store), Delete Account (ilova ichida + veb sahifa). O‘zbekistonning shaxsga doir ma’lumotlar to‘g‘risidagi qonuni va lokalizatsiya talablari, GDPR — yuridik ko‘rik **[TEKSHIRISH KERAK]**.

---

## 15. Free / Student Pro / Professional Pro taqsimoti

| Funksiya | FREE | STUDENT PRO | PROFESSIONAL PRO |
|---|---|---|---|
| Global Search (ichki) | ✅ | ✅ | ✅ |
| Substance Library | Cheklangan (~20–30 asosiy modda, to‘liq kartochka) | Ta’lim uchun kengaytirilgan | ✅ To‘liq |
| Reference concentrations | Asosiy moddalar uchun | Ta’lim darajasida | ✅ To‘liq, filtrlar bilan |
| Analytical Methods | Asosiy tavsif | ✅ | ✅ + interferensiyalar, tasdiqlash talablari |
| Laboratory calculators | Asosiylari (C1V1, birliklar, molarity, mean/SD) | ✅ Barcha asosiylar | ✅ + kalibrlash, regressiya, LOD/LOQ, partiyaviy hisoblar |
| Ethanol calculators | Birlik konvertatsiyasi | + Widmark (ta’lim) | ✅ Barcha, noaniqlik diapazoni bilan |
| Forensic Medicine | Reference matnlar (qisman) | ✅ Reference | ✅ + Henssge va murakkab vositalar |
| Learn | Glossary + bitta bepul kurs + cheklangan quiz | ✅ To‘liq: kurslar, flashcards, quiz, cases, exam mode, progress | Ixtiyoriy (asosiy kurslar) |
| Bookmarks | 20 tagacha | ✅ | ✅ |
| Forensic AI | Kuniga bir necha savol (aniq limit serverda) | Ta’lim rejimida, oylik limit | ✅ Kengaytirilgan limit |
| External Scientific Search | — | Cheklangan | ✅ |
| Reference management, eksport | — | — | ✅ (manbalar ro‘yxatini BibTeX/RIS ko‘rinishida eksport) |
| Secure notes | — | — | ✅ |
| Offline content | Free qismi | Ta’lim qismi | ✅ To‘liq |

**Tamoyil:** xavfsizlik ma’lumotlari (disclaimerlar, cheklovlar, «Manbalar» tugmasi) hech qachon paywall ortida emas. Pullik qiymat — chuqurlik va qulaylik, ishonchlilik emas.

Limitlar va qaysi kontent qaysi darajaga tegishli — **kontent bazasidagi `tier_access` maydoni** va server konfiguratsiyasi orqali boshqariladi, kodga yozilmaydi.

---

## 16. Original logo uchun 3 ta professional konsepsiya

Barcha konsepsiyalarda taqiqlangan: tibbiy xoch, bosh suyagi, politsiya nishoni, adolat tarozisi, qon tomchisi.

### Konsepsiya A — «RIDGE SPECTRUM» (tavsiya etiladi)

**G‘oya:** barmoq izining 3–4 ta konsentrik yoyi pastki qismida chromatogramma/mass-spektr cho‘qqilariga aylanadi. Bitta shakl ikki ma’noni beradi: *dalil (iz)* → *ilmiy o‘lchov (spektr)*.

```
      ╭───────╮
    ╭─┤ ╭───╮ ├─╮
    │ │ │   │ │ │
  ──┴─┴─┴─╮ ╰─┴─┴──     <- yoylar pastda chiziqqa tushadi
          ╰┬╮_┬_         <- va spektral cho‘qqilar bo‘lib davom etadi
```
(Taxminiy eskiz; yakuniy shakl vektor grid’da quriladi.)

- **Symbol:** 3 yoy + 3 ta har xil balandlikdagi cho‘qqi; bitta chiziq qalinligi (monoline), dumaloq uchlar yo‘q — aniqlik hissi uchun to‘g‘ri kesilgan uchlar.
- **32 px:** ichki yoy soni 2 ga kamaytirilgan maxsus kichik versiya (optical sizing).
- **Afzalligi:** sohaga xos, lekin klishe emas; dalil va laboratoriyani birlashtiradi.
- **Xavf:** barmoq izi elementi ba’zi kriminalistika brendlarida ishlatiladi — trademark qidiruvi kerak **[TEKSHIRISH KERAK]**.

### Konsepsiya B — «EVIDENCE BRACKET»

**G‘oya:** dalil belgilashda va o‘lchov ramkalarida ishlatiladigan to‘rtta burchak qavs (⌜ ⌝ ⌞ ⌟) ichida bitta muntazam olti burchak (benzol halqasi / molekula abstraksiyasi). Ma’nosi: *molekula aniqlik ramkasi ichida*.

- **Symbol:** 4 burchak + olti burchak, olti burchakning bitta qirrasi accent rangda.
- **32 px:** juda yaxshi taniladi (oddiy geometriya).
- **Afzalligi:** eng minimal, eng yaxshi kichik o‘lchamda; «precision» g‘oyasi kuchli.
- **Xavf:** olti burchak kimyo brendlarida ko‘p uchraydi — burchak qavslar orqali farqlanadi.

### Konsepsiya C — «FE PEAK MONOGRAM»

**G‘oya:** «F» va «E» harflari uchta gorizontal chiziqdan iborat; chiziqlar uzunligi spektral cho‘qqilar nisbatini eslatadi, vertikal chiziq — o‘lchov o‘qi (axis). Ostida nozik tik belgilar (tick marks).

- **Symbol:** monogramma; wordmark bilan uyg‘un.
- **Afzalligi:** brend nomi bilan to‘g‘ridan-to‘g‘ri bog‘liq, xalqaro, tilga bog‘liq emas (lotin harflari).
- **Xavf:** harfli monogrammalar kamroq o‘ziga xos; «FE» temir kimyoviy belgisi (Fe) bilan assotsiatsiya — bu kimyoviy kontekstda ham ijobiy, ham chalkash bo‘lishi mumkin.

### Barcha konsepsiyalar uchun yetkaziladigan to‘plam

Primary logo (symbol + wordmark gorizontal), Symbol, Wordmark («FORENSIC EXPERT», geometrik grotesk, keng harf oralig‘i, faqat bosh harflar), App icon (iOS 1024 px, Android adaptive icon: foreground + background qatlamlari, monochrome themed icon — Android 13+), Dark / Light / Monochrome versiyalar, minimal o‘lcham va xavfsiz maydon qoidalari.

**Tavsiyam:** A asosiy belgi sifatida, B dan «precision bracket» elementini UI ikonografiyasida (masalan, verified badge) ishlatish.

---

## 17. UI / design system

### 17.1. Rang tokenlari (taklif — kontrast tekshiruvidan keyin yakunlanadi)

| Token | Light | Dark | Izoh |
|---|---|---|---|
| `color.bg` | #FFFFFF | #0B1220 | Dark — chuqur navy, sof qora emas |
| `color.surface` | #F5F7FA | #121A2B | Cool gray / navy-graphite |
| `color.surfaceRaised` | #FFFFFF | #1A2335 | |
| `color.textPrimary` | #0B1220 | #E8ECF2 | |
| `color.textSecondary` | #4A5568 | #A0AEC0 | |
| `color.border` | #E2E8F0 | #2A3448 | |
| `color.brand` | #0F1E3D (Deep Navy) | #DCE3EE | |
| `color.accent` | #0E8C9A (Spectral Teal) | #3CC3D1 | **Yagona** ilmiy accent |
| `status.verified` | yashil (WCAG AA) | | Status rangi har doim ikonka + matn bilan birga (faqat rangga tayanmaslik — accessibility) |
| `status.reviewed` | ko‘k | | |
| `status.needsReview` | amber | | «MA’LUMOT TEKSHIRILMAGAN» |
| `status.outdated` | kulrang | | |
| `status.danger` | qizil (faqat xato va xavf uchun) | | |

Barcha juftliklar WCAG 2.2 AA (oddiy matn ≥ 4.5:1) bo‘yicha avtomatik test qilinadi. High contrast rejim uchun alohida token to‘plami.

### 17.2. Tipografiya

- UI: **Inter** (lotin + kirill to‘liq qo‘llab-quvvatlanadi, OFL litsenziya) — o‘zbek lotin belgilari (o‘, g‘) tekshiriladi.
- Raqamlar va formulalar: **JetBrains Mono** yoki **IBM Plex Mono** (tabular figures — natijalar ustunlarda tekis turishi uchun).
- Formulalar: `flutter_math_fork` (LaTeX render) **[TEKSHIRISH KERAK — paket holati]**.
- Shriftlar ilova ichiga o‘rnatiladi (offline, Google Fonts’dan runtime’da yuklanmaydi).
- Tip shkalasi: 12 / 14 / 16 / 18 / 22 / 28 / 34; Dynamic Type bilan 200% gacha masshtablash.

### 17.3. Komponentlar

Search bar · Category result list · Entity card · Status badge · Sources sheet · Calculator form (input + birlik tanlash) · Result panel (natija + noaniqlik + «Formula» kengaytmasi) · Limitations callout · Formula block · Data table (konsentratsiyalar uchun gorizontal scroll emas — kichik ekranda kartochka ko‘rinishiga o‘tadi) · Paywall sheet · Empty/Offline/Error holatlari · Skeleton loaderlar (faqat tarmoq uchun; lokal ma’lumot darhol).

### 17.4. Harakat va tezlik

- Animatsiyalar 150–250 ms, reduced motion yoqilganda o‘chiriladi.
- Spacing grid: 4 pt. Minimal touch target: 48×48 dp.
- 320 dp kenglikda overflow bo‘lmasligi uchun barcha ekranlar golden test bilan 320/360/411/768 kengliklarda va 1.0/1.3/2.0 matn masshtabida tekshiriladi.

---

## 18. Android / iOS billing arxitekturasi

### 18.1. Tanlov

| Variant | Afzallik | Kamchilik |
|---|---|---|
| **RevenueCat** (`purchases_flutter`) | Ikki platforma bitta API, server tarafda receipt validatsiyasi, webhook’lar, entitlement modeli, tez ishga tushirish | Uchinchi tomon, daromaddan foiz (ma’lum hajmdan keyin) **[TEKSHIRISH KERAK — joriy narxlar]** |
| `in_app_purchase` (rasmiy Flutter plagini) + o‘z backend | To‘liq nazorat, uchinchi tomon yo‘q | App Store Server API va Google Play Developer API bilan validatsiya, notification’lar, grace period — hammasini o‘zimiz yozamiz |

**Tavsiya:** V1 uchun RevenueCat (xato xavfi kam, tezroq). Arxitekturada `BillingRepository` interfeysi orqali ajratilgan — keyin o‘z backendga o‘tish mumkin.

### 18.2. Model

```
Products (store’larda yaratiladi, narxlar FAQAT store’dan olinadi):
  student_pro_monthly, student_pro_annual
  professional_pro_monthly, professional_pro_annual
  (trial va promo — store’ning introductory offer / promo code / offer code mexanizmlari orqali)

Entitlements:
  student_pro       -> Learn to‘liq, student kalkulyatorlari
  professional_pro  -> student_pro’ning barchasi + professional funksiyalar
  institution       -> (kelajak) server tomonidan beriladi, store’siz
```

- **Narxlar kodga yozilmaydi** — `Offerings` store’dan olinadi, lokalizatsiyalangan narx ko‘rsatiladi.
- `EntitlementService` — ilovaning yagona «haqiqat manbai». Feature gate’lar `entitlement` va kontentdagi `tier_access` orqali.
- Offline: oxirgi tasdiqlangan entitlement holati xavfsiz keshlanadi; muddati o‘tgan bo‘lsa, ma’lum grace period.
- **Restore Purchases** tugmasi Profile → Subscription va paywall’da.
- **Manage Subscription** — platformaning obuna boshqarish sahifasiga deep link.
- Institution (kelajak): universitet/tashkilot uchun server-side litsenziya (domen email yoki taklif kodi orqali). Apple qoidalariga muvofiqligi alohida tekshiriladi **[TEKSHIRISH KERAK]**.

### 18.3. Testlar

StoreKit Configuration fayl (Xcode lokal test), Sandbox va TestFlight; Google Play License Testing va internal testing track; `BillingRepository` uchun fake implementatsiya bilan unit/widget testlar.

---

## 19. App Store / Google Play risklari

| Risk | Platforma | Ehtimoli | Choralar |
|---|---|---|---|
| Tibbiy ilova sifatida qat’iy ko‘rik (ma’lumot aniqligi, metodologiya oshkoraligi) | Apple (Guideline 1.4.1 **[TEKSHIRISH KERAK]**) | O‘rta | Har bir hisobda metodologiya va manba ochiq; disclaimer; «diagnoz qo‘ymaydi» positioning |
| Health apps deklaratsiyasi | Google Play (Health apps policy, Health app declaration **[TEKSHIRISH KERAK]**) | Yuqori (majburiy forma) | Kategoriya: Medical / Education; to‘g‘ri deklaratsiya |
| Giyohvand moddalar mavzusi | Ikkalasi | O‘rta | Kontent reference/ta’lim xarakterida; sotib olish, tayyorlash, iste’mol qilish usullari, dozalash maslahati **yo‘q**. Sintez yo‘llari kiritilmaydi |
| AI generatsiya kontenti | Google Play AI-generated content siyosati; Apple 1.x | O‘rta | Ilova ichida AI javobi haqida shikoyat qilish tugmasi; xavfsizlik filtrlari |
| Sezgir tasvirlar (jarohatlar, autopsiya) | Ikkalasi | O‘rta | V1’da fotosuratlar yo‘q yoki minimal; sxematik chizmalar; blur + ogohlantirish; yosh reytingi mos ravishda (masalan, 17+/Mature) |
| Account deletion | Apple 5.1.1(v), Google Play | Yuqori (majburiy) | Ilova ichida Delete Account + veb sahifa |
| IAP qoidalari | Apple 3.1.x, Google Play Payments | Yuqori | Raqamli kontent faqat store billing orqali; tashqi to‘lovga havola yo‘q |
| Minimal funksionallik | Apple 4.2 | Past | Offline kutubxona + kalkulyatorlar yetarli |
| Privacy label / Data safety | Ikkalasi | Yuqori (majburiy) | Haqiqiy SDK’lar bo‘yicha aniq to‘ldirish; reklama SDK yo‘q |
| Uchinchi tomon kontent litsenziyasi | Ikkalasi (IP shikoyat) | O‘rta | Har bir manbaning litsenziyasi `sources.license` da; About → Atributsiyalar |
| Eksport nazorati (shifrlash) | Apple (ITSAppUsesNonExemptEncryption) | Past | Standart HTTPS/OS shifrlash — odatda istisno; tekshiriladi **[TEKSHIRISH KERAK]** |
| Ba’zi davlatlarda tibbiy dasturiy ta’minot (SaMD) sifatida talqin | Regulyator | Past–o‘rta | Positioning: reference/education/calculation; diagnostika va davolash qarori yo‘q. Yuridik ko‘rik tavsiya etiladi |

Store positioning: **«Professional forensic reference, education and scientific calculation software.»** Consumer diagnosis app sifatida ko‘rsatilmaydi.

---

## 20. Development roadmap

### 20.1. Texnik stek (taklif)

| Qatlam | Tanlov | Sabab |
|---|---|---|
| Framework | **Flutter** (stable), Dart | Bitta codebase, yuqori sifatli render, 120 Hz, kuchli testlash (unit/widget/golden/integration) |
| Arxitektura | Feature-first + Clean (presentation / domain / data) | Kalkulyator va domen mantiqini UI’dan ajratish talabi |
| State | **Riverpod** | Testlanadigan, compile-safe, keraksiz rebuild’larni nazorat qilish oson |
| Navigatsiya | **go_router** (StatefulShellRoute — har bir tab o‘z stack’ini saqlaydi) | Bottom nav’da tab almashganda holat saqlanadi → «instant» his |
| DB | **drift** (SQLite, FTS5) + content.db (read-only) + user.db (read-write) | SQL kuchi, migratsiya, background isolate, test qulayligi |
| Shifrlash | `flutter_secure_storage` + SQLCipher yoki maydon shifrlash | 14-bo‘lim |
| i18n | `flutter_localizations` + **gen-l10n (ARB)**; kontent tarjimalari bazada | Hardcode yo‘q; RTL (arab) uchun tayyor |
| Hisob dvigateli | Sof Dart paketi `packages/calc_engine` (Flutter’ga bog‘liq emas) | UI’dan to‘liq ajratilgan, alohida test qilinadi, kelajakda backend/veb’da qayta ishlatiladi |
| Qidiruv | `packages/search_core` (normalizatsiya, transliteratsiya, reyting) | Alohida test |
| Billing | RevenueCat (`BillingRepository` ortida) | 18-bo‘lim |
| Backend | Supabase (Auth, Postgres, pgvector, Edge Functions, Storage — content pack’lar uchun CDN) | Tez start; qaror PHASE 1 da |
| CMS | Veb admin panel (Next.js yoki Flutter Web) + Postgres; content pipeline (build → validate → sign → publish) | 27-bo‘lim |
| CI | GitHub Actions: analyze, test, golden, content validator, build | |
| Crash reporting | Sentry yoki Firebase Crashlytics (PII’siz konfiguratsiya) | |

### 20.2. Repository tuzilmasi (taklif)

```
forensic-expert/
  apps/mobile/                 # Flutter ilova
    lib/
      app/                     # router, theme, DI
      core/                    # i18n, design_system, utils
      features/
        onboarding/ search/ toxicology/ substances/ methods/
        lab_tools/ forensic_medicine/ learn/ ai/ billing/ profile/
          presentation/ domain/ data/
  packages/
    calc_engine/               # sof Dart, 100% test qamrovi maqsadi
    search_core/
    content_schema/            # drift jadvallari, umumiy modellar
  content/                     # kontent manbalari (YAML/JSON), pipeline skriptlari
    sources/ substances/ methods/ ...
    tools/validate/ build/ sign/
  backend/                     # Edge Functions, SQL migratsiyalar, RAG
  cms/                         # admin panel
  docs/
  PROGRESS.md
```

### 20.3. Bosqichlar

| Phase | Mazmuni | Chiqish mezoni (Definition of Done) |
|---|---|---|
| **0** | Tadqiqot, manba strategiyasi, raqobatchilar tahlili (**ushbu hujjat**), [TEKSHIRISH KERAK] belgilarini yopish, V1 moddalar ro‘yxatini ekspert bilan kelishish | Egasining tasdig‘i; ilmiy muharrir tayinlangan |
| **1** | Monorepo, Flutter skeleti, CI, design system tokenlari, tipografiya, logo (tanlangan konsepsiya vektorda), i18n infratuzilmasi, backend tanlovi | `flutter analyze` toza, CI yashil, golden testlar, tokenlar kontrast testidan o‘tgan |
| **2** | Language selector (birinchi ekran), disclaimer, mode tanlash, bottom navigation, Settings (til/tema/mode) | 320 dp va 200% shrift testlari; EN/RU/UZ to‘liq; cold start maqsadi o‘lchangan |
| **3** | content.db sxemasi, content pipeline v0 (validator + build + imzo), test kontenti, Global Search (FTS5, transliteratsiya, typo) | Search testlari (EN/RU/UZ, kirill/lotin, xatolar), <50 ms; imzo tekshiruvi testlari |
| **4** | `calc_engine`: barcha laboratoriya kalkulyatorlari + ethanol (birliklar, Widmark variantlari, back-calculation) + universal kalkulyator UI | Har bir formula uchun mustaqil reference test misollari; ilmiy reviewer imzosi |
| **5** | Toxicology hub, Substance Library (V1 ro‘yxati), Specimens, Methods, Reference concentrations, Legal status | Kontent `REVIEWED`+; Sources sheet ishlaydi; hech bir konsentratsiya manbasiz emas (validator) |
| **6** | Forensic Medicine: postmortem reference, injuries, burns, Henssge (review’dan keyin) | Henssge nashr qilingan misollar bilan mos; ekspert tasdig‘i |
| **7** | Learn: kurslar, lesson, glossary, flashcards (SRS), quiz, bookmarks, progress | SRS algoritmi testlari; quiz izohlari manbali |
| **8** | Backend RAG, Forensic AI UI, PII filtri, citation validator, AI eval to‘plami | Eval: 0 ta to‘qilgan citation, taqiqlangan xulosalar testi 100% o‘tgan, PII testlari |
| **9** | Billing: RevenueCat, paywall, entitlement’lar, restore, manage | Sandbox/TestFlight/License testing ssenariylari |
| **10** | CMS (rollar, workflow, audit log), signed content updates (delta), «Scientific database last updated» | Rollar bo‘yicha ruxsat testlari, audit log, imzo/rollback testlari |
| **11** | Security / privacy / performance / accessibility audit | Critical/High topilmalar 0 |
| **12** | To‘liq regression, offline ssenariylar, localization audit | Barcha test to‘plamlari yashil |
| **13** | Android AAB release candidate (Play internal testing) | Data safety, health deklaratsiyasi, pre-launch report |
| **14** | iOS TestFlight release candidate | Privacy label, review notes (reviewer uchun izoh), App Review’ga tayyor |

### 20.4. Har bir phase’dan keyin majburiy tekshiruvlar

`flutter analyze` · avtomatik testlar · kichik ekran (320 dp) · lokalizatsiya (EN/RU/UZ, uzun matnlar) · offline (samolyot rejimi) · performance (cold start, frame time — DevTools/profil rejimi) · security (sirlar, tarmoq, loglar). Critical yoki High bug qolsa — keyingi phase’ga o‘tilmaydi. Natijalar `PROGRESS.md` ga yoziladi.

### 20.5. Performance byudjetlari (maqsadlar, real qurilmada o‘lchanadi)

- Cold start → birinchi interaktiv kadr: o‘rta Android qurilmada ≤ 1.5 s maqsad.
- Tab almashish: ≤ 1 kadr kechikish (holat saqlanadi, qayta qurilmaydi).
- Lokal qidiruv: ≤ 50 ms (p95).
- Kalkulyator natijasi: kiritish bilan bir vaqtda (sinxron, < 1 ms).
- Jank: 60/120 Hz’da 99% kadrlar byudjet ichida.
- Usullar: shader warm-up (Impeller), lazy feature yuklash, `const` widgetlar, `select` bilan Riverpod rebuild cheklash, rasmlar uchun to‘g‘ri o‘lchamli keshlash, og‘ir ishlar isolate’da.

### 20.6. Content versioning

- App versiyasi: SemVer (`1.0.0`). Scientific Database versiyasi: CalVer (`2026.10`, `2026.10.1` — tuzatishlar).
- Ilova o‘rnatilganda bazaviy content pack bilan keladi (offline darhol ishlaydi).
- Yangilanish: `manifest.json` (versiya, minimal app versiyasi, xeshlar, Ed25519 imzo) → yuklab olish → imzo va xesh tekshiruvi → vaqtinchalik faylga yozish → atomik almashtirish → oldingi versiyani rollback uchun saqlash.
- Kritik ilmiy tuzatish (masalan, xato koeffitsient) app update kutmasdan content pack orqali yetkaziladi; `critical` flag bilan foydalanuvchiga xabar beriladi.
- Kontent sxemasi o‘zgarsa — `min_app_version` orqali eski ilovalar mos pack oladi.

---

## 21. Mendan tasdiq kutayotgan qarorlar

PHASE 1 ga o‘tishdan oldin quyidagi savollarga javobingiz kerak:

1. **Ilmiy muharrir/reviewer:** jamoada kim `REVIEWED`/`VERIFIED` statusini beradi? (Siz va/yoki boshqa ekspertlar.) Bu shartsiz V1 kontentini production’ga chiqarib bo‘lmaydi.
2. **V1 moddalar ro‘yxati:** 50–100 ta moddani birgalikda tanlaymizmi yoki siz amaliyotingizdan ro‘yxat berasizmi?
3. **Logo:** A (Ridge Spectrum), B (Evidence Bracket) yoki C (FE Peak Monogram)?
4. **Backend:** Supabase (tez start) yoki o‘z serverimiz?
5. **Billing:** RevenueCat (tavsiya) yoki to‘g‘ridan-to‘g‘ri store API?
6. **Henssge:** V1’ga kiritish (qat’iy review sharti bilan) yoki V1.1 ga qoldirish?
7. **Litsenziyali manbalar:** Baselt/Clarke’s/TIAFT kabi manbalar uchun noshirlar bilan litsenziya muzokarasi rejalashtiriladimi yoki V1 faqat ochiq manbalar + havolalar bilanmi?
8. **Yuridik ko‘rik:** Privacy Policy/Terms va O‘zbekiston shaxsga doir ma’lumotlar qonunchiligi bo‘yicha yurist jalb qilinadimi?
9. **Hujjatdagi [TEKSHIRISH KERAK] belgilari:** PHASE 0 davomida ularni rasmiy manbalar (PubMed, rasmiy saytlar, lex.uz) orqali tekshirib, hujjatni yangilashimga ruxsat berasizmi?

---

*Ushbu hujjat — reja. Kod yozish egasining aniq tasdig‘idan keyin boshlanadi.*
