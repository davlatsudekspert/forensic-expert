# 02 — Raqobatchilar tahlili (jonli Store tekshiruvi)

| | |
|---|---|
| Sana | 2026-10-04 |
| Usul | **App Store:** Apple’ning rasmiy iTunes Search/Lookup API (apps.apple.com bilan bir xil ma’lumot) — US, RU va UZ storefront’lari; EN, RU va UZ so‘rovlari. 3 ta sahifa apps.apple.com’da to‘g‘ridan-to‘g‘ri tekshirildi. **Google Play:** 35+ qidiruv sahifasi (EN/RU/UZ) va ~45 ta ilova sahifasi ochildi |
| Reyting | App Store — US storefront; Google Play — US sahifasi. «—» — Store reyting ko‘rsatmagan (sharh juda kam) |
| Maqsad | Ko‘chirish emas — **bozordagi bo‘shliqni** aniqlash |

---

## 1. Asosiy xulosa (qisqa)

1. **Eng yaqin raqobatchi — 4n6 Tools Pro** (Slovakiya). Ko‘p jihatdan bizning g‘oyaga yaqin: 27 ta sud-tibbiy vosita (Henssge, vitreous K⁺, Widmark back-calculation noaniqlik bilan, 67 dori bo‘yicha diapazonlar, CO-Hb, kuyishlar, DVI, antropologiya). Har bir metodda manba ko‘rsatiladi, ilova to‘liq offline ishlaydi. Lekin narxi juda yuqori (iOS $99.99 / Android $94.99, bir martalik), faqat **EN/SK** tillarida, ta’lim va AI yo‘q, yuklab olishlar soni juda kam (Android 5+). Ilova yangi — 2026-09/10 da yangilangan.
2. **Rus va o‘zbek tilidagi sud-tibbiy yoki sud-toksikologik professional ilova yo‘q.** RU va UZ storefront’larda bunday ilova topilmadi. O‘zbekcha so‘rovlar App Store’da 0 natija berdi.
3. **Manbasini ko‘rsatadigan ilovalar juda kam.** Faqat 4n6 Tools Pro (forensic) va MDCalc (klinik).
4. **Toksikologiya + sud tibbiyoti + laboratoriya + ta’lim kombinatsiyasi sifatli bajarilmagan.**
5. **Forensic sohada manbali AI yo‘q.** AI faqat klinik ilovalarda (Micromedex Assistant, Medscape AI search) va havaskor suyak tanish ilovalarida bor.
6. **Kategoriyaning katta qismi eskirgan:** iTOD (2016), ACEP Antidote (2015), Autopsy iOS (2021), CDC qo‘llanmasi (2020).
7. **«Forensic Expert» nomi bilan aniq mos ilova yo‘q.** Yaqin nomlar bor (pastda, 5-bo‘lim).

---

## 2. Raqobatchilar jadvali

### 2.1. Sud tibbiyoti / patologiya va o‘lim vaqti vositalari

| Ilova | Dasturchi (joylashuvi) | Platforma | Narx modeli | Tillar | Asosiy funksiyalar | Offline | Ilmiy manbalar | Reyting | Oxirgi yangilanish | Kuchli tomoni | Zaif tomoni |
|---|---|---|---|---|---|---|---|---|---|---|---|
| **4n6 Tools Pro** | Ján Šikuta (Bratislava, Slovakiya) | iOS, Android | Bir martalik: iOS $99.99 (sahifada «ishga tushirish narxi»), Android $94.99; IAP/reklama/obuna yo‘q | EN, SK | 27 vosita: Henssge (tuzatish omili yordamchisi bilan), postmortem o‘zgarishlar xronologiyasi, vitreous K⁺ (4 usul) + gipoksantin, entomologiya (ADD), etanol/Widmark back-calculation noaniqlik bilan, 67 dori diapazonlari, CO-Hb, kuyishlar (Lund-Browder, Baux), DVI (INTERPOL), odontologiya, bo‘y/jins/yosh, foto o‘lchash, eksport | **Ha** (to‘liq qurilmada, ma’lumot yig‘maydi) | **Ha** («Source citations with every method») | — ; Android 5+ yuklab olish | iOS v5.2 — 2026-09-30; Android — 2026-10-03 | Ekspert darajasi, manbali, maxfiylikka yo‘naltirilgan | Juda qimmat; RU/UZ yo‘q; ta’lim va AI yo‘q; foydalanuvchilar deyarli yo‘q |
| 4n6 Tools Lite | Ján Šikuta | iOS, Android | Bepul (Pro’ga yo‘naltiradi) | EN, SK | 6–7 bepul vosita (Henssge, vitreous K⁺, BMI, birlik konvertori va h.k.) | Ko‘rsatilmagan | Bilvosita | — ; Android 10+ | iOS 2026-09-07; Android 2026-10-03 | Bepul voronka | Cheklangan |
| iTOD | Holmen Innovative Solutions AS | iOS | Bepul | EN | O‘lim vaqti: 5 usul (harorat — Henssge, kaliy, gipoksantin) | Ko‘rsatilmagan | Ha (Henßge va hamk.; Oslo universiteti) | — | 2016-06-30 | Birinchi ko‘p markerli ilova | 10 yildan beri yangilanmagan |
| Post Mortem | Erebo Stirpe | iOS | $8.99 | 11 til, **RU** bilan | Interaktiv Henssge (ta’lim) | Ko‘rsatilmagan | Metod nomi, havolalarsiz | — | 2026-04-01 | Ko‘p tilli | Faqat Henssge |
| SDFI – Forensic Guidelines | SDFI-TeleMedicine LLC (AQSh) | iOS | Bepul | EN | Klinik sud tibbiyoti foto protokollari | Ko‘rsatilmagan | Ko‘rsatilmagan | — | 2025-09-11 | Klinik forensic nishasi | Tor |
| Cause of Death Reference Guide | CDC/NCHS (AQSh) | iOS | Bepul | EN | O‘lim guvohnomasini to‘ldirish | Ko‘rsatilmagan | Davlat manbasi | 4.2 (5) | 2020-04-20 | Rasmiy | AQShga xos, eskirgan |
| Autopsy | Autopsy Center of Chicago (AQSh) | iOS, Android | $9.99 + tashqi obuna | EN | 40 autopsiya video holati, quiz | Ko‘rsatilmagan | O‘z amaliyoti | iOS 4.09 (56); Android 4.6 (120), 1K+ | iOS 2021-01-26; Android 2026-09-07 | Real video | AQShga yo‘naltirilgan |
| Bloodstain ID Decision Map | Bevel, Gardner & Associates (AQSh) | iOS | $39.99 | EN | Qon dog‘lari naqshlarini tasniflash | Ko‘rsatilmagan | BPA jarayoni | 5 (1) | 2026-03-30 | Professional nisha | Bitta mavzu |
| Trace Evidence Collection App | RTI International (AQSh) | iOS | Bepul | — | OSAC qo‘llanmasiga hamroh | Ko‘rsatilmagan | OSAC | 5 (2) | 2023-08-16 | Standartlarga asoslangan | Kriminalistika, tibbiyot emas |

### 2.2. Toksikologiya va zaharlar bo‘yicha ma’lumotnomalar

| Ilova | Dasturchi (joylashuvi) | Platforma | Narx modeli | Tillar | Asosiy funksiyalar | Offline | Manbalar | Reyting | Oxirgi yangilanish | Kuchli tomoni | Zaif tomoni |
|---|---|---|---|---|---|---|---|---|---|---|---|
| **TOXBASE** | NHS Lothian / UK NPIS (Edinburg) | iOS, Android | NHS/MOD/ac.uk/UKHSA email uchun bepul; iOS IAP $6.99/yil | EN | Zahar monografiyalari, triaj, davolash | **Ha** (qidiruv) | Peer-reviewed | iOS 1.0 (1); Android 50K+ | iOS 2025-12-15; Android 2026-02-03 | UK oltin standarti | Faqat UK domenlari; klinik, forensic emas |
| 5 Minute Toxicology Consult | Skyscape Medpresso (AQSh) | iOS, Android | Bepul namuna + IAP | EN | Kitob kontenti | Ko‘rsatilmagan | Kitob | iOS 4.0 (9); Android 1K+ | 2025-12-30 / 2026-09-01 | Ishonchli darslik | Pullik devor |
| Poisoning & Drug Overdose (8th ed.) | Skyscape Medpresso (AQSh) | iOS | Bepul namuna + IAP | EN | Shoshilinch toksikologiya | Ko‘rsatilmagan | Darslik | 4.67 (9) | 2025-11-11 | Nufuzli | Faqat klinik |
| UpToDate Lexidrug | Wolters Kluwer (AQSh) | iOS, Android | Bepul + obuna (narx ko‘rsatilmagan) | 13 til, **RU yo‘q** | Dori monografiyalari, o‘zaro ta’sir, kalkulyatorlar | Onlayn kontent | Tahririy review | iOS 4.74 (5 627); Android 4.3, 1M+ | 2026-07-22 / 2026-05-20 | Bozor lideri | Qimmat; postmortem konteksti yo‘q |
| Micromedex | Merative (AQSh) | iOS, Android | Institutsional aktivatsiya | EN | Dori ma’lumotnomasi, AI «Micromedex Assistant» | Aktivatsiya uchun onlayn | Akkreditatsiyalangan review | iOS 3.43 (35); Android 3.8, 50K+ | 2025-10-08 / 2025-05-02 | Institutsional standart, AI bor | Institutsional litsenziya |
| epocrates | Epocrates, Inc. (AQSh) | iOS, Android | Bepul + IAP | EN | Monografiyalar, tabletka identifikatsiyasi | Ko‘rsatilmagan | Ko‘rsatilmagan | iOS 4.43 (7 213); Android 2.7, 1M+ | 2026-09-24 / 2026-09-23 | Katta auditoriya | AQSh klinik fokusi |
| Medscape | WebMD (AQSh) | iOS, Android | Bepul, reklama | EN | 9 200+ dori, 450+ kalkulyator, AI qidiruv | Ko‘rsatilmagan | Ko‘rsatilmagan | iOS 3.63; Android 3.5, 5M+ | 2026-09-30 / 2026-09-22 | Bepul, keng | Reklama; forensic yo‘q |
| webPOISONCONTROL | National Capital Poison Center (AQSh) | iOS | Bepul | EN | Iste’molchi triaji | Ko‘rsatilmagan | Ekspertlar | 4.56 (36) | 2026-01-23 | Ishonchli | Iste’molchi uchun |
| ACEP Toxicology Antidote | ACEP (AQSh) | iOS | Bepul | EN | Antidot dozalari | Ko‘rsatilmagan | ACEP | 5 (3) | 2015-04-07 | Nufuzli | Tashlab qo‘yilgan |
| Toxicologia Hoy | Dadic F.T. (Argentina) | Android | Bepul | ES | 400+ toksikant, aniqlash usullari bilan | Ko‘rsatilmagan | Ko‘rsatilmagan | — ; 50K+ | 2024-04-02 | Laboratoriya jihati bor | Faqat ispancha |
| Toxicology (lug‘at) | SyuaLikesApple (Koreya) | Android | Bepul, reklama | KO, EN, DE, **RU**, ES, FR, ZH | Lug‘at | **Ha** | Yo‘q | — ; 5K+ | 2023-11-10 | Offline, ko‘p tilli | Kontent yupqa |
| CAMEO Chemicals | NOAA (AQSh) | iOS | Bepul | EN | Xavfli kimyoviy moddalar varaqalari | **Ha** | Davlat bazalari | 4.23 (26) | 2024-05-31 | Offline, rasmiy | Hazmat, forensic emas |

### 2.3. Ta’lim (sud tibbiyoti, patologiya, toksikologiya)

| Ilova | Dasturchi (joylashuvi) | Platforma | Narx modeli | Tillar | Asosiy funksiyalar | Offline | Manbalar | Reyting | Oxirgi yangilanish | Kuchli tomoni | Zaif tomoni |
|---|---|---|---|---|---|---|---|---|---|---|---|
| **Forensic Science** (Afrozulla Khan) | Afrozulla Khan Ziaulla (Hindiston) | Android | Bepul, reklama + IAP | EN | 15 fan bo‘yicha video kurslar, quiz, **50+ kalkulyator** (Henssge, Widmark, bo‘y, DNK LR), Hindiston qonunchiligi | Ko‘rsatilmagan | Ko‘rsatilmagan | — ; 10K+ | 2026-07-25 | Android’dagi eng yaqin «hammasi bir joyda» | Hindistonga xos; reklama; manbasiz; kriminalistikaga yo‘naltirilgan |
| Forensic Science (Softecks) | Rajil Thankaraju (Hindiston) | Android | Bepul, reklama + IAP | EN | 10 modul | Ko‘rsatilmagan | Ko‘rsatilmagan | 4.6 (67); 10K+ | 2026-07-08 | Keng dastur | Konspekt uslubi |
| Forensic Medicine Exam Review / Prep | Tourkia CHIHI / Brightson Learners (Tunis) | iOS, Android | iOS $3.99; Android $2.99 | EN | Flashcards, savollar | Ko‘rsatilmagan | Yo‘q | — ; Android 10+ | 2024-02-09 / 2023-07-11 | Arzon | Shablon kontent, eskirgan |
| Forensic Med MCQ Question Bank | Nerve Education (Hindiston) | Android | Bepul, reklama + IAP | EN | 200+ MCQ | Ko‘rsatilmagan | Yo‘q | — ; 100+ | 2025-06-03 | Imtihonga yo‘naltirilgan | Kichik |
| E-Book on Forensic Medicine | rajIT Solutions (Bangladesh) | Android | Bepul | EN | Sud tibbiyoti va toksikologiya e-kitobi | Ko‘rsatilmagan | Yo‘q | — ; 500+ | 2025-11-02 | Ikkala sohani qamraydi | Statik |
| Toxicology Prep Mastery | Learn-Train Inc. | iOS | $19.99 | EN | Board tayyorgarligi (forensic toksikologiya bo‘limi bilan) | Ko‘rsatilmagan | Yo‘q | — | 2025-09-29 | Forensic tox bor | Qimmat, yangi |
| ToxRunner | Adam Blumenberg | iOS | Bepul | — | Bir necha yuz savol | Yo‘q | Yo‘q | 3.0 (4) | 2020-10-13 | Bepul | Eskirgan |
| Case Files: Pathology | Expanded Apps (AQSh) | iOS | Bepul yuklab olish | EN | 50+ klinik holat | Ko‘rsatilmagan | Case Files® kitobi | — | 2026-05-05 | Tanilgan brend | Forensic emas |

### 2.4. Laboratoriya kalkulyatorlari

| Ilova | Dasturchi (joylashuvi) | Platforma | Narx modeli | Tillar | Asosiy funksiyalar | Offline | Manbalar | Reyting | Oxirgi yangilanish | Kuchli tomoni | Zaif tomoni |
|---|---|---|---|---|---|---|---|---|---|---|---|
| **Lab.Hacks** | Lab.hacks GmbH (Germaniya) | iOS, Android | Bepul; Android’da reklama + IAP | EN | Eritish/molarlik, bufer kutubxonasi, 50+ protokol | **Ha** (iOS) | Yo‘q | iOS 4.93 (136); Android 4.8 (2.15K), 100K+ | 2026-10-01 / 2026-09-23 | Kategoriya lideri | Molekulyar biologiya; forensic yo‘q |
| Lab Mate | Marcus Griffiths | iOS/macOS | $6.99 | 11 til, **RU** bilan | Molarlik, eritish, kimyoviy qidiruv | Ko‘rsatilmagan | Yo‘q | 5.0 (6) | 2025-12-16 | Sifatli, RU bor | Tor |
| LabCalc / Lab Calculator | Biplav Parajuli / Zenski Apps (Nepal) | iOS, Android | Bepul; Android reklama | EN | 65+ vosita | Ko‘rsatilmagan | Yo‘q | — ; 100+ | 2026-06 | Keng | Kam foydalanuvchi |
| ChemBioCalc | Ü. C. Erim (Turkiya) | Android | Bepul + Pro obuna; reklama | EN | Mol/pH/eritish, PCR | Ko‘rsatilmagan | Yo‘q | — ; 1K+ | 2026-10-02 | Boy funksiya | Kam foydalanuvchi |
| LabCompanion | AT productions (Daniya) | iOS | Bepul + bir martalik Premium | EN | 10 kalkulyator, jadvallar | **Ha** | Yo‘q | — | 2026-06-25 | Obunasiz | Yangi |
| **MDCalc** | MDCalc Ltd. (AQSh) | iOS | Bepul (ro‘yxatdan o‘tish) | EN | 900+ klinik kalkulyator | **Ha** | **Ha** («every tool includes research validation») | 4.92 (51 990) | 2026-09-30 | Manbali kalkulyatorlar uchun benchmark | Faqat klinik |

### 2.5. Qondagi alkogol

Professional forensic Widmark ilovasi topilmadi (4n6 Tools Pro va Afrozulla Khan ilovasi ichidagi vositalardan tashqari). Qolganlari iste’molchi ilovalari:

| Ilova | Dasturchi | Platforma | Narx | Tillar | Izoh | Yangilanish |
|---|---|---|---|---|---|---|
| Alcocurve | J. Laskemoen (Norvegiya) | iOS, Android | Bepul + Pro obuna | 11 til, RU bilan | Widmark va Watson formulalari nomlangan | 2026-09-07 |
| Alcohol Calculator – sobriety | MilMed (Chexiya) | Android | Bepul | EN | Forrest tuzatishi | 2026-02-05 |
| AlcoTrack | FLX Apps (Germaniya) | Android | Bepul, reklama + IAP | EN | Ichimlik jurnali; 4.4 (3.1K), 500K+ | 2026-09-08 |

### 2.6. Osteologiya / antropologiya

| Ilova | Dasturchi | Platforma | Narx | Izoh | Yangilanish |
|---|---|---|---|---|---|
| 3D Osteology | XR Anatomy LTD | iOS | $8.99 | Anatomiya, forensic antropologiya emas; 3.62 (8) | 2025-01-23 |
| Osteo+ | LMT Digital Creations (Fransiya) | iOS, Android | Bepul + IAP | AI foto identifikatsiya, AI tutor; manba ko‘rsatilmagan; RU bor | 2026-09 |
| Bone, Skull & Tooth ID | S. Nesterenko | iOS | Bepul + obuna | AI foto (asosan hayvon suyaklari); 4.51 (57) | 2026-05-26 |
| Anthropology: Notes & MCQ | Bloom Code Studio (Pokiston) | Android | Bepul, reklama | Umumiy antropologiya; 4.7 (89), 5K+ | 2026-05-19 |

**Kamroq tegishli (tekshirilgan):** Human Skeleton: Gross Anatomy; Anatomic Pathology Flashcards; EM Toxicology Trainer; NIOSH Pocket Guide; Tox Info Suisse; Poisoning – First Aid (EN/DE/RU); VOKA 3D Anatomy & Pathology (Belarus, 500K+); ADN Criminalística (Argentina); QPM Forensics AR.

---

## 3. Bozordagi bo‘shliq (gap analysis)

| # | Bo‘shliq | Dalil | Bizning javob |
|---|---|---|---|
| G-1 | **RU va UZ tilidagi professional sud-tibbiy va sud-toksikologik ilova yo‘q** | RU/UZ storefront’lari va Play’dagi rus/o‘zbek so‘rovlari bunday ilova bermadi. RU lokalizatsiyasi faqat umumiy yoki tor ilovalarda bor (Post Mortem, Lab Mate, Alcocurve, Osteo+) | EN/RU/UZ canonical terminologiya, MDH amaliyotiga mos kontent (RU darsliklari, UZ qonunchiligi). **Bu asosiy pozitsiyalash** |
| G-2 | **Manba ko‘rsatish kam** | Faqat 4n6 Tools Pro va MDCalc (klinik). Ta’lim ilovalari manbasiz | Har bir fakt, natija va quiz izohida «Manbalar» tugmasi; review statusi |
| G-3 | **Offline notekis** | Lexidrug va Micromedex onlayn/aktivatsiya talab qiladi; ta’lim ilovalari bu haqda hech narsa demaydi | Offline-first kafolati (CI testi bilan) |
| G-4 | **Toksikologiya + sud tibbiyoti + laboratoriya + ta’lim birga emas** | 4n6 Pro — ta’limsiz va juda qimmat; Afrozulla Khan — kriminalistika, manbasiz, reklamali; klinik ma’lumotnomalar — postmortem talqinsiz | Yagona platforma, ikki rejim (Professional / Student) |
| G-5 | **Forensic laboratoriya ish oqimi yo‘q** | Lab kalkulyatorlari molekulyar biologiyaga yo‘naltirilgan (GC-MS uchun namuna eritish, LOD/LOQ, kalibrlash yo‘q) | Sud-kimyo laboratoriyasiga moslashgan Lab Tools |
| G-6 | **Manbali forensic AI yo‘q** | AI faqat klinik ilovalarda yoki havaskor foto-identifikatsiyada | RAG, faqat ichki tekshirilgan baza, citation validatori, xulosa bermaydi |
| G-7 | **Professional Widmark vositasi yo‘q** | Widmark ilovalari — iste’molchi ichimlik trekerlari | Ethanol moduli: formula, taxminlar, noaniqlik, cheklovlar, manbalar |
| G-8 | **Kategoriya eskirgan** | iTOD 2016, ACEP 2015, Autopsy iOS 2021 | Muntazam yangilanadigan, imzolangan kontent paketlari |
| G-9 | **Narx to‘sig‘i** | 4n6 Pro ~$95–100; Lexidrug/Micromedex — institutsional | Free darajasi + Student va Professional obunalari |

### 3.1. 4n6 Tools Pro’ga nisbatan pozitsiya

4n6 Tools Pro kalkulyator va vositalar chuqurligi bo‘yicha kuchli raqobatchi. Uning bilan **vosita soni bo‘yicha emas**, quyidagilar bo‘yicha farqlanamiz:

| | 4n6 Tools Pro | FORENSIC EXPERT (reja) |
|---|---|---|
| Tillar | EN, SK | EN, RU, UZ (+ kengaytiriladigan) |
| Narx | ~$95–100 bir martalik | Free + obunalar |
| Ta’lim | Yo‘q | Student Mode |
| Substance Library | 67 dori diapazonlari | ~95 yozuv (V1 taklifi), metabolitlar, namunalar, metodlar, huquqiy status bilan |
| Review jarayoni | Ko‘rsatilmagan | Domen bo‘yicha reviewer, status va oxirgi review sanasi ko‘rinadi |
| Manbalar ziddiyati | Ko‘rsatilmagan | Ziddiyatlar ko‘rsatiladi (`23-bo‘lim`) |
| AI | Yo‘q | RAG + citations |
| Kontent yangilanishi | App update orqali | Imzolangan kontent paketi |

**Xavf:** 4n6 Tools Pro tez rivojlanmoqda (bir oyda bir necha reliz). V1 da ularning vositalar sonini quvish emas, **ishonchlilik, til va ta’lim** bo‘yicha ustunlikka e’tibor beramiz.

---

## 4. Monetizatsiya bo‘yicha bozor signallari

- Professional niche ilovalar **bir martalik yuqori narx** bilan sotiladi: 4n6 Pro $95–100, Bloodstain ID $39.99, Anatomic Pathology Flashcards $39.99.
- Klinik liderlar **obuna yoki institutsional litsenziya** bilan ishlaydi: Lexidrug, Micromedex, TOXBASE.
- Ta’lim ilovalari arzon ($3–20) yoki reklamali. **Biz reklamasiz modelni saqlaymiz** — professional ishonch uchun.
- **Xulosa:** Free + obuna modeli to‘g‘ri, lekin Professional Pro narxi klinik referencelar bilan solishtiriladi. Institution litsenziyasi (FUTURE) muhim daromad kanali bo‘lishi mumkin.

---

## 5. «Forensic Expert» nomi bo‘yicha to‘qnashuvlar (faqat Store’lar)

| Topilma | Platforma | Xavf darajasi | Izoh |
|---|---|---|---|
| «Forensic Expert» aniq nomli ilova | Google Play (US), App Store US/RU/UZ | **Topilmadi** | |
| Forensic Examiner (BUGRA TUNCER) | iOS, o‘yin, $0.99, 2026-08-22 | O‘rta | Ma’nosi eng yaqin nom, lekin o‘yin |
| Forensic Master (Ruby Game Studio) | iOS (4.35, 43 274 baho), Play’da ham bor | O‘rta | «Forensic ___» naqshidagi kuchli brend (o‘yin) |
| Forensic medicine (T.R.I., s.r.o.) | Ikkala store, konferensiya ilovasi | Past | |
| «Медэксперт» (OOO «МЕДЭКСПЕРТ», Ulan-Ude) | Android, 10K+ | Past–o‘rta (RU nomi uchun) | Agar RU nomi «Медэксперт» bo‘lsa — to‘qnashuv. «Судмедэксперт» nomli ilova topilmadi |
| «Forensic Science» | 2 ta Android ilovasi | Past | Umumiy ibora |

**Muhim:** bu faqat Store listinglari bo‘yicha tekshiruv. Rasmiy trademark reestrlari (WIPO, USPTO, EUIPO, Rospatent, O‘zbekiston Intellektual mulk agentligi) **tekshirilmagan** — ochiq band O-11. «Forensic Expert» tavsifiy ibora bo‘lgani uchun so‘z belgisi sifatida himoyalash qiyin bo‘lishi mumkin. Brendni himoyalashda logo va o‘ziga xos dizayn katta rol o‘ynaydi.

---

## 6. Tekshirib bo‘lmagan ma’lumotlar

- Obuna/IAP narxlari ko‘p ilovalarda Store sahifasida ko‘rinmaydi (Lexidrug, epocrates, Micromedex, Skyscape, Osteo+ va boshqalar). Istisno — TOXBASE ($6.99/yil).
- Google Play ilovalar tillarini ro‘yxat sifatida ko‘rsatmaydi — tillar tavsif matnidan olingan.
- iOS’da dasturchi davlati ko‘rsatilmaydi — Play’dagi manzil yoki domen orqali aniqlangan.
- iOS reytinglari faqat US storefront bo‘yicha.
- PathPresenter, Sigma, Thermo, Promega, GraphPad ilovalari qidiruvda chiqmadi (alohida tekshirilmagan).
- WISER Store’larda topilmadi. NLM rasmiy xabariga ko‘ra 2023-02-28 da to‘xtatilgan (`01_EVIDENCE_AUDIT.md`, A-21).
- Ko‘pchilik ta’lim ilovalarining offline imkoniyati ko‘rsatilmagan.
