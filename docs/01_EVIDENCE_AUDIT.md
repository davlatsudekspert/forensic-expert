# 01 — Verification & Evidence Audit (PHASE 0.5)

| | |
|---|---|
| Audit sanasi | 2026-10-04 (barcha manbalar shu sanada ochilgan — ACCESSED DATE) |
| Qamrov | `docs/00_ARXITEKTURA_REJASI.md` dagi barcha **[TEKSHIRISH KERAK]** bandlari + qo‘shimcha topilgan muhim faktlar |
| Usul | Faqat birlamchi va rasmiy manbalar: PubMed/NCBI, Crossref API, noshir sahifalari, rasmiy tashkilotlar (WHO, UNODC, EUDA, NIST, INTERPOL, AAFS ASB), Apple Developer, Google Play Console Help, pub.dev, sqlite.org, lex.uz, pravo.gov.ru, government.ru, eCFR, INCB, EUR-Lex. Blog va AI matnlari manba sifatida ishlatilmagan |
| Cheklovlar | Ba’zi sahifalar avtomatik yuklab olishni bloklagan (Wiley, EUDA legal notice — HTTP 403, NCBI Bookshelf — CAPTCHA). Bunday hollarda rasmiy domendagi qidiruv parchasi yoki boshqa rasmiy sahifa ishlatilgan va NOTES ustunida aytilgan. Sahifalar AI-yordamchi orqali o‘qilgan — eng muhim raqamlar implementatsiyadan oldin qo‘lda qayta tekshiriladi |

**STATUS:**

- **VERIFIED** — da’vo rasmiy/birlamchi manbada to‘g‘ridan-to‘g‘ri tasdiqlandi.
- **PARTIALLY VERIFIED** — da’voning bir qismi tasdiqlandi, manba bilvosita yoki da’vo tuzatildi.
- **NOT VERIFIED** — tasdiq topilmadi yoki da’vo noto‘g‘ri chiqdi.

---

## 1. Umumiy natija

| Guruh | Jami | VERIFIED | PARTIALLY | NOT VERIFIED / noto‘g‘ri |
|---|---|---|---|---|
| A. Ilmiy manbalar va bibliografiya | 16 | 12 | 4 | 0 |
| B. Manbalar litsenziyasi va API shartlari | 14 | 11 | 3 | 0 |
| C. Apple App Store | 13 | 13 | 0 | 0 |
| D. Google Play | 10 | 8 | 2 | 0 |
| E. Texnologiya / paketlar | 8 | 6 | 0 | 2 (EOL — reja tuzatildi) |
| F. Huquq (UZ, RU, AQSh, BMT, EI) | 11 | 8 | 3 | 0 |
| G. Narx va to‘lovlar | `05_COST_MODEL.md` da | — | — | — |
| **Jami** | **72** | **58** | **12** | **2** |

### 1.1. Rejani o‘zgartiradigan eng muhim topilmalar

| # | Topilma | Ta’siri |
|---|---|---|
| 1 | **CAS Registry Numbers** ommaga ko‘rsatish yoki CAS bo‘yicha qidiruv uchun **CAS litsenziyasi talab qilinadi** | V1 da CAS ko‘rsatilmaydi; LICENSE REQUIRED (LR-01) |
| 2 | **ANSI/ASB standartlari** bepul, lekin tijoriy maqsadda ko‘chirish va o‘zgartirish taqiqlangan | Faqat havola + o‘z so‘zimiz bilan qisqa mazmun |
| 3 | ASB raqamlari rejada noto‘g‘ri edi: **119** — o‘lim tergovi (qon), **120** — haydovchilar (qon), **121** — DFC (siydik) | Tuzatildi |
| 4 | **WHO ATC/DDD** — tijoriy nusxalash va o‘zgartirish taqiqlangan | V1 da ATC yo‘q |
| 5 | **DrugBank** to‘liq ma’lumotlari CC BY-NC; faqat DrugBank **Open Data** CC0 | Faqat Open Data |
| 6 | **Schulz 2020** (Crit Care) — **CC BY 4.0**; Schulz 2012 — CC BY 2.0 | V1 reference konsentratsiyalari uchun asosiy ochiq manba |
| 7 | **D’Orazio 2021** — CC BY-NC 4.0 (rejada CC BY deb taxmin qilingan edi) | Faqat havola |
| 8 | **O‘zbekiston lokalizatsiya talabi 2026-03-26 da toraytirildi** (ZRU-1125): majburiy lokal saqlash faqat biometrik, genetik va telekom foydalanuvchilari ma’lumotlari uchun; qolganlari — adekvatlik / standart shartnoma bandlari asosida chetda mumkin | Supabase (xorij) arxitekturasi yuridik jihatdan mumkin bo‘lishi ehtimoli oshdi — yurist tasdig‘i kerak |
| 9 | Yangi **«Sud-ekspertlik faoliyati to‘g‘risida»gi qonun ZRU-1152** (2026-06-11), **2026-12-13 dan** kuchga kiradi; ZRU-249 o‘z kuchini yo‘qotadi | Kontentdagi huquqiy havolalar yangilanadi |
| 10 | O‘zbekiston qonunining rasmiy nomi: **«Giyohvandlik vositalari va psixotrop moddalar toʻgʻrisida»** (813-I, 19.08.1999) | Tuzatildi |
| 11 | `sqlite3_flutter_libs` va `sqlcipher_flutter_libs` — **end of life** (2026-02); o‘rniga `sqlite3` 3.x (build hooks, FTS5 bilan) | Texnik stek tuzatildi |
| 12 | **Isar** — 2023-04 dan barqaror reliz yo‘q | Rad etildi (drift tanlangan — o‘zgarishsiz) |
| 13 | **Google Play:** sog‘liq ilovalari uchun tavsifda «not a medical device…» disclaimer majburiy; AI kontenti uchun ilova ichida shikoyat tugmasi majburiy | Talablar ro‘yxatiga qo‘shildi |
| 14 | **Apple yosh reytingi** (2025-07): 4+/9+/13+/16+/18+; uzoq davom etuvchi grafik realistik zo‘ravonlik → «Unrated» (nashr qilib bo‘lmaydi) | Autopsiya/jarohat tasvirlari bo‘yicha qat’iy siyosat |
| 15 | **Google Play target API 36** — 2026-08-31 dan majburiy | PHASE 1 konfiguratsiyasi |
| 16 | **NLM WISER** 2023-02-28 da to‘xtatilgan | Raqobatchilar ro‘yxatidan chiqarildi |
| 17 | **Google Play** O‘zbekistondagi dasturchidan O‘zbekiston QQS’ni **o‘zi** undirib to‘lashni talab qiladi | Soliq/buxgalteriya majburiyati |

---

## 2. A — Ilmiy manbalar va bibliografiya

| # | CLAIM | SOURCE | URL / DOI / PMID | PUBLICATION / UPDATE DATE | ACCESSED | STATUS | NOTES |
|---|---|---|---|---|---|---|---|
| A-01 | Schulz va hamk., Crit Care 2012, ~1 000 dori bo‘yicha terapevtik/toksik qon konsentratsiyalari review | PubMed; Crossref | doi:10.1186/cc11441; PMID 22835221; PMC3580721 | 2012-07-26 | 2026-10-04 | VERIFIED | Sarlavha: «Therapeutic and toxic blood concentrations of nearly 1,000 drugs and other xenobiotics». Mualliflar: Schulz M, Iwersen-Bergmann S, Andresen H, Schmoldt A. Crit Care 16(4):R136. Litsenziya **CC BY 2.0** |
| A-02 | Schulz va hamk., Crit Care 2020 «Revisited», >1100 dori | PubMed; Crossref | doi:10.1186/s13054-020-02915-5; PMID 32375836; PMC7201985 | 2020-05-06 | 2026-10-04 | VERIFIED | «Revisited: Therapeutic and toxic blood concentrations of more than 1100 drugs and other xenobiotics». Schulz M, Schmoldt A, Andresen-Streichert H, Iwersen-Bergmann S. Crit Care 24(1):195. **CC BY 4.0** |
| A-03 | Widmark 1932 asl asari va 1981 inglizcha tarjimasi | WorldCat (OCLC 7813129) | worldcat.org/title/7813129 | 1932 / 1981 | 2026-10-04 | PARTIALLY VERIFIED | Asl: «Die theoretischen Grundlagen und die praktische Verwendbarkeit der gerichtlich-medizinischen Alkoholbestimmung», Urban & Schwarzenberg, 1932. Tarjima: «Principles and applications of medicolegal alcohol determination», Biomedical Publications, 1981. Faqat katalog yozuvi orqali |
| A-04 | Watson PE, Watson ID, Batt RD 1980 — TBW | PubMed | doi:10.1093/ajcn/33.1.27; PMID 6986753 | 1980-01 | 2026-10-04 | VERIFIED | Am J Clin Nutr 33(1):27-39 |
| A-05 | Henssge 1988 — rektal harorat nomogrammasi | PubMed | doi:10.1016/0379-0738(88)90168-5; PMID 3192144 | 1988-09 | 2026-10-04 | VERIFIED | Forensic Sci Int 38(3-4):209-236. Marshall–Hoare ikki-eksponentli modeliga asoslangan |
| A-06 | Marshall & Hoare 1962 sovish modeli | Henssge 1988 abstrakti orqali | DOI/PMID topilmadi | 1962 | 2026-10-04 | PARTIALLY VERIFIED | J Forensic Sci 7 (1962) 56-81 deb keltirilgan; aniq sarlavha birlamchi yozuvdan tasdiqlanmadi |
| A-07 | Henssge usuliga patent/litsenziya cheklovi | Patent va veb qidiruv | — | — | 2026-10-04 | PARTIALLY VERIFIED | Patent yoki litsenziya cheklovi **topilmadi** (bu yo‘qligini isbotlamaydi). Nomogramma **tasviri** noshir mualliflik huquqida — ilova o‘zi hisoblashi/chizishi kerak |
| A-08 | Henssge & Madea kitobi | Routledge/CRC | ISBN 9781032135533; doi:10.1201/9781003244974 | 2023 (4-nashr) | 2026-10-04 | VERIFIED | Madea B (ed.), «Estimation of the Time Since Death», 4th ed., CRC Press 2023 |
| A-09 | Trotter & Gleser 1952, 1958 | PubMed | PMID 13007782 (doi:10.1002/ajpa.1330100407); PMID 13571400 (doi:10.1002/ajpa.1330160106) | 1952-12; 1958-03 | 2026-10-04 | PARTIALLY VERIFIED | Am J Phys Anthropol 10(4):463-514; 16(1):79-123. Populyatsiyalar (Terry kolleksiyasi, AQSh harbiylari) keyingi maqolalar orqali tasdiqlangan (masalan, PMID 7595318) |
| A-10 | Jones AW 2010 — etanol eliminatsiya tezligi review | PubMed | doi:10.1016/j.forsciint.2010.02.021; PMID 20304569 | 2010-03-20 | 2026-10-04 | VERIFIED | Forensic Sci Int 200(1-3):1-20. (Qiymatlar audit ichida keltirilmaydi — kontent pipeline orqali review bilan kiritiladi) |
| A-11 | D’Orazio va hamk. 2021 — DUID tavsiyalari | PubMed; Crossref | doi:10.1093/jat/bkab064; PMID 34086916; PMC8272528 | 2021-06-04 | 2026-10-04 | VERIFIED | J Anal Toxicol 45(6):529-536. **CC BY-NC 4.0** |
| A-12 | D’Orazio va hamk. 2025 yangilanishi | PubMed | doi:10.1093/jat/bkaf085; PMID 40972092 | 2025/2026 | 2026-10-04 | PARTIALLY VERIFIED | Faqat abstrakt (pullik) |
| A-13 | Seidl, Jensen, Alt 2000 | PubMed | doi:10.1007/s004140000154; PMID 11197633 | 2000 | 2026-10-04 | VERIFIED | Int J Legal Med 114(1-2):71-77 |
| A-14 | Forrest 1986 — Widmark faktori | PubMed | doi:10.1016/s0015-7368(86)72491-2; PMID 3760810 | 1986 | 2026-10-04 | VERIFIED | J Forensic Sci Soc 26(4):249-252 |
| A-15 | Baselt — eng so‘nggi nashr | Pharmaceutical Press | pharmaceuticalpress.com/?p=172711 | 12-nashr, 2020 | 2026-10-04 | VERIFIED | Biomedical Publications. Endi MedicinesComplete’da onlayn obuna (yiliga 4 yangilanish), narx so‘rov bo‘yicha. 13-nashr topilmadi |
| A-16 | Clarke’s Analysis of Drugs and Poisons | Pharmaceutical Press | pharmaceuticalpress.com/content/clarkes-analysis-of-drugs-and-poisons/ | Bosma 4-nashr 2011; onlayn yangilanish 2025-06 | 2026-10-04 | VERIFIED | ISBN 978-0-85369-711-4. Onlayn — faqat obuna/institutsional |
| A-17 | Pigolkin «Судебная медицина» | Universitet kutubxona ro‘yxatlari (ЭБС «Консультант студента» yozuvi) | ISBN 978-5-9704-6313-0 | 4-nashr, 2022 | 2026-10-04 | PARTIALLY VERIFIED | ГЭОТАР-Медиа, 592 b. Noshir saytida tekshirilmagan |
| A-18 | ASB Standard 036 — metod validatsiyasi | AAFS Standards Board PDF | aafs.org/sites/default/files/media/documents/036_Std_e1.pdf | 1-nashr 2019 | 2026-10-04 | VERIFIED | Bepul, lekin tijoriy maqsadda ko‘paytirish va o‘zgartirish taqiqlangan. 2-nashr tayyorlanmoqda |
| A-19 | ASB 119 / 120 / 121 — analitik qamrov standartlari | AAFS ASB PDF’lari | aafs.org/.../119_Std_e1.pdf; 120_Std_e1.pdf; 121_Std_e1.pdf | Hammasi 1-nashr 2021 | 2026-10-04 | PARTIALLY VERIFIED (raqamlash tuzatildi) | **119** — o‘lim tergovi, qon; **120** — transport vositasini boshqarish, qon; **121** — DFC, siydik. 036 kabi tijoriy cheklov |
| A-20 | INTERPOL DVI Guide | interpol.int | interpol.int/content/download/589/file/DVI_DVI%20Guide%202023.pdf | 2023-11 | 2026-10-04 | VERIFIED | Bepul PDF + 13 ilova; EN/FR/ES/AR |
| A-21 | NLM WISER to‘xtatilgan | NLM Technical Bulletin | nlm.nih.gov/pubs/techbull/jf23/jf23_wiser_discontinued.html | 2023-01-24 | 2026-10-04 | VERIFIED | 2023-02-28 da barcha platformalarda to‘xtatilgan |
| A-22 | TOXBASE faqat ro‘yxatdan o‘tgan UK sog‘liqni saqlash mutaxassislari uchun; ilova bor | toxbase.org | toxbase.org/toxbase-app-for-ios-and-android/ | — | 2026-10-04 | VERIFIED | NHS/UKHSA/MOD/ac.uk email bilan ro‘yxatdan o‘tish |

## 3. B — Manbalar litsenziyasi va API shartlari

| # | CLAIM | SOURCE | URL / DOI | DATE | ACCESSED | STATUS | NOTES |
|---|---|---|---|---|---|---|---|
| B-01 | EMCDDA → EUDA | EUR-Lex | Regulation (EU) 2023/1322, OJ L 166, 30.6.2023 | Qabul 2023-06-27; EUDA 2024-07-02 dan | 2026-10-04 | VERIFIED | Reg. 1920/2006 bekor qilingan |
| B-02 | EUDA kontentini qayta ishlatish | euda.europa.eu (qidiruv parchalari; legal notice sahifasi 403) | euda.europa.eu | — | 2026-10-04 | PARTIALLY VERIFIED | Siyosat «CC BY 4.0 bilan to‘liq mos», atributsiya bilan ruxsatsiz; uchinchi tomon fotosuratlari bundan mustasno |
| B-03 | SWGDRUG monografiyalari va MS kutubxonasi bepul | swgdrug.org | swgdrug.org/ms.htm; swgdrug.org/approved.htm | Kutubxona v3.14 (2025-01-22); Recommendations v8.2 (2024-06-27) | 2026-10-04 | PARTIALLY VERIFIED | Bepul yuklab olish; «© 2005-2026 SWGDRUG. All rights reserved», aniq reuse litsenziyasi yo‘q → qayta tarqatish uchun ruxsat kerak |
| B-04 | PubChem foydalanish shartlari va so‘rov limiti | PubChem docs; NCBI policies | pubchem.ncbi.nlm.nih.gov/docs/programmatic-access; ncbi.nlm.nih.gov/home/about/policies/ | 2026 | 2026-10-04 | VERIFIED | ≤ **5 so‘rov/s**, API kalit yo‘q; ortiqcha so‘rov → HTTP 503. NCBI kontenti public domain, lekin har bir PubChem deposit manbasining o‘z litsenziyasi bor |
| B-05 | CAS Registry Numbers shartlari | cas.org (CAS RN Verified Partner Program); Common Chemistry license PDF | cas.org/training/documentation/chemical-substances/cas-rn-verified-partner-program; web.cas.org/marketing/pdf/common-chemistry-commercial-license.pdf | joriy | 2026-10-04 | VERIFIED | Ommaga ko‘rsatish yoki «CAS RN bo‘yicha qidiruv» uchun litsenziya talab qilinadi (raqam ko‘rsatilmasa ham). Common Chemistry — CC BY-NC 4.0 |
| B-06 | ChEBI litsenziyasi | EMBL-EBI | ebi.ac.uk/chebi/aboutChebiForward.do | joriy | 2026-10-04 | VERIFIED | CC BY 4.0 |
| B-07 | DrugBank litsenziyasi | go.drugbank.com | go.drugbank.com/releases/latest | Reliz 5.1.22, 2026-06-27 | 2026-10-04 | VERIFIED | To‘liq ma’lumotlar CC BY-NC 4.0; tijoriy — pullik. Akademik yuklab olish hozir to‘xtatilgan. **Open Data — CC0** |
| B-08 | TIAFT reference qon darajalari ro‘yxati / UV spektrlar | tiaft.org | tiaft.org/features/free-resources-on-the-web/ | Havolalar 2026-02 da tekshirilgan | 2026-10-04 | PARTIALLY VERIFIED | TIAFT endi Schulz 2012/2020 maqolalariga havola beradi; alohida TIAFT ro‘yxati va joriy UV kutubxonasi topilmadi |
| B-09 | NIST WebBook shartlari va API | webbook.nist.gov | doi:10.18434/T4D303 | Ma’lumotlar 2025 | 2026-10-04 | VERIFIED | Standard Reference Data Act asosida himoyalangan; **rasmiy API yo‘q** |
| B-10 | NIST mass spektral kutubxonasi pullik | nist.gov SRD 1A | nist.gov/srd/nist-standard-reference-database-1a | 2026-06-10 | 2026-10-04 | VERIFIED | Faqat distribyutorlar orqali; eng so‘nggi — **NIST26** |
| B-11 | NCBI E-utilities limitlari; PMC OA | NCBI | ncbi.nlm.nih.gov/books/NBK25497/; pmc.ncbi.nlm.nih.gov/tools/textmining/ | — | 2026-10-04 | VERIFIED | Kalitsiz 3 so‘rov/s, kalit bilan 10/s; `tool` va `email` parametrlari. PMC OA — commercial / non-commercial guruhlarga bo‘lingan |
| B-12 | Crossref REST API | crossref.org | crossref.org/documentation/retrieve-metadata/rest-api/access-and-authentication/ | Limitlar 2025-12-01 da yangilangan | 2026-10-04 | VERIFIED | Bepul; polite pool (`mailto`) 10 so‘rov/s; metadata — CC0; abstraktlar himoyalangan bo‘lishi mumkin |
| B-13 | WHO ATC/DDD qayta ishlatish | WHO Collaborating Centre (Oslo) | atcddd.fhi.no/copyright_disclaimer/ | joriy | 2026-10-04 | VERIFIED | Tijoriy nusxalash/tarqatish va o‘zgartirish **taqiqlangan** |
| B-14 | UNODC ST/NAR qo‘llanmalari va NPS EWA | unodc.org | unodc.org/documents/scientific/stnar34.pdf; unodc.org/lss/page/about | EWA 2013-06-26 dan | 2026-10-04 | VERIFIED | Bepul; EWA batafsil ma’lumoti ro‘yxatdan o‘tgan mutaxassislar uchun. Aniq reuse litsenziyasi — ochiq savol |
| B-15 | NIOSH Pocket Guide; DailyMed API | cdc.gov; dailymed.nlm.nih.gov | cdc.gov/niosh/npg/default.html; dailymed.nlm.nih.gov/dailymed/app-support-web-services.cfm | NPG 2020-02-18 | 2026-10-04 | VERIFIED | Ikkalasi bepul; AQSh davlat ishi |

## 4. C — Apple App Store

| # | CLAIM | SOURCE | URL | DATE | ACCESSED | STATUS | NOTES |
|---|---|---|---|---|---|---|---|
| C-01 | 1.4.1: tibbiy ilovalar qattiqroq ko‘rikdan o‘tadi, metodologiya ochiq bo‘lishi kerak | App Review Guidelines | developer.apple.com/app-store/review/guidelines/ | «living document» | 2026-10-04 | VERIFIED | «Apps must clearly disclose data and methodology to support accuracy claims…», «should remind users to check with a doctor…» |
| C-02 | 4.8: uchinchi tomon login bo‘lsa, ekvivalent maxfiylikka yo‘naltirilgan login varianti kerak | o‘sha | o‘sha | — | 2026-10-04 | VERIFIED | Talab Sign in with Apple deb nomlanmaydi — xususiyatlar orqali ta’riflangan (ism+email cheklovi, emailni yashirish, reklama kuzatuvisiz) |
| C-03 | 5.1.1(v): akkaunt majburiy bo‘lmasligi; akkaunt bo‘lsa ilova ichida o‘chirish | o‘sha | o‘sha | — | 2026-10-04 | VERIFIED | «If your app doesn’t include significant account-based features, let people use it without a login» — offline-first, akkauntsiz yondashuvimiz bilan mos |
| C-04 | Account deletion talablari | Apple Support | developer.apple.com/support/offering-account-deletion-in-your-app/ | 2022-06-30 dan | 2026-10-04 | VERIFIED | To‘liq o‘chirish (deaktivatsiya emas); Sign in with Apple tokenlarini bekor qilish; obuna Apple orqali davom etishi haqida ogohlantirish |
| C-05 | 4.2 Minimum Functionality | App Review Guidelines | o‘sha | — | 2026-10-04 | VERIFIED | |
| C-06 | 3.1.1 IAP majburiy; restore mexanizmi | o‘sha | o‘sha | — | 2026-10-04 | VERIFIED | Restore — «should» (tavsiya), amalda kutiladi |
| C-07 | 3.1.2 auto-renewable obunalar | o‘sha | o‘sha | — | 2026-10-04 | VERIFIED | Doimiy qiymat; davr ≥ 7 kun; barcha qurilmalarda |
| C-08 | Eksport nazorati: faqat OS/HTTPS shifrlash — istisno | Apple documentation | developer.apple.com/documentation/security/complying-with-encryption-export-regulations | — | 2026-10-04 | VERIFIED | **SQLCipher/SQLite3MultipleCiphers OS shifrlashi emas** — ular ishlatilsa, deklaratsiya qayta ko‘riladi |
| C-09 | Komissiya: 30% / 15% (Small Business, obunaning 2-yili) | Apple | developer.apple.com/app-store/small-business-program/; /subscriptions/ | — | 2026-10-04 | VERIFIED | |
| C-10 | App Store O‘zbekistonda mavjud | Apple Support | support.apple.com/en-us/118205 | 2026-09-30 | 2026-10-04 | VERIFIED | |
| C-11 | Yosh reytingi yangilangan: 4+/9+/13+/16+/18+ | Apple Developer News; reference | developer.apple.com/news/?id=ks775ehf; …/age-ratings-values-and-definitions | 2025-07-24 | 2026-10-04 | VERIFIED | «Medical or Treatment Information»: kam — 13+, tez-tez — 16+. Uzoq grafik realistik zo‘ravonlik → **Unrated (nashr qilinmaydi)** |
| C-12 | App Privacy details va SDK privacy manifestlari | Apple | developer.apple.com/app-store/app-privacy-details/; developer.apple.com/support/third-party-SDK-requirements/ | — | 2026-10-04 | VERIFIED | Flutter ro‘yxatdagi SDK’lar orasida |
| C-13 | App Store Server API va Server Notifications V2 | Apple documentation | developer.apple.com/documentation/appstoreserverapi; …/appstoreservernotifications | — | 2026-10-04 | VERIFIED | V1 notification’lar eskirgan |

## 5. D — Google Play

| # | CLAIM | SOURCE | URL | DATE | ACCESSED | STATUS | NOTES |
|---|---|---|---|---|---|---|---|
| D-01 | Health apps siyosati va deklaratsiya formasi | Play Console Help | support.google.com/googleplay/android-developer/answer/16679511; …/answer/14738291 | — | 2026-10-04 | VERIFIED | Kategoriya: **«Medical Reference and Education»**. Tibbiy qurilma bo‘lmagan ilova tavsifida **«not a medical device and does not diagnose, treat, cure, or prevent any medical condition»** disclaimer va mutaxassisga murojaat eslatmasi majburiy |
| D-02 | AI kontenti uchun ilova ichida shikoyat | Play Console Help | …/answer/13985936 | — | 2026-10-04 | VERIFIED | Ilovadan chiqmasdan shikoyat qilish majburiy |
| D-03 | Data safety bo‘limi | Play Console Help | …/answer/10787469 | — | 2026-10-04 | VERIFIED | Ma’lumot yig‘masa ham majburiy; SDK’lar ham deklaratsiya qilinadi |
| D-04 | Akkauntni o‘chirish: ilova ichida + veb havola | Play Console Help | …/answer/13327111 | — | 2026-10-04 | VERIFIED | |
| D-05 | Giyohvand moddalar siyosati va reference kontent | Illegal Activities (…/9878877); Inappropriate Content (…/9878810) | — | — | 2026-10-04 | PARTIALLY VERIFIED | Taqiq: sotish/xaridga ko‘maklashish, yetishtirish/ishlab chiqarish yo‘riqnomalari, targ‘ibot. Giyohvand moddalar bo‘limida **aniq EDSA (ta’lim/ilmiy) istisno yo‘q**. Sof reference kontent taqiqlanmagan ko‘rinadi — bu bizning talqinimiz, Google matni emas |
| D-06 | Xizmat haqi: obunalar 15%, birinchi $1M 15% | Play Console Help | …/answer/112622; …/answer/16954621 | Joriy reja sanalari bilan | 2026-10-04 | PARTIALLY VERIFIED (o‘zgarmoqda) | Yangi tuzilma: obunalar 10% + billing fee. EEA/UK/AQSh — 2026-06-30; AU/JP — 2026-09-30; KR — 2026-12-31; **qolgan dunyo (O‘zbekiston, Rossiya) — 2027-09-30**. Ungacha eski 15% |
| D-07 | Ro‘yxatdan o‘tish $25 | Play Console Help | …/answer/6112435 | — | 2026-10-04 | VERIFIED | ID va qurilma tasdiqlash ham |
| D-08 | Yangi shaxsiy akkauntlar: 12 tester × 14 kun yopiq test | Play Console Help | …/answer/14151465 | — | 2026-10-04 | VERIFIED | 2023-11-13 dan keyin ochilgan shaxsiy akkauntlar uchun — **release jadvaliga ta’sir qiladi** (tashkilot akkaunti afzal) |
| D-09 | Target API darajasi | Play Console Help | …/answer/11926878 | — | 2026-10-04 | VERIFIED | **2026-08-31 dan API 36 (Android 16)**; 2026-11-01 gacha uzaytirish mumkin |
| D-10 | Play Developer API (subscriptionsv2) va RTDN | Google | developers.google.com/android-publisher/api-ref/rest/v3/purchases.subscriptionsv2/get; developer.android.com/google/play/billing/rtdn-reference | — | 2026-10-04 | VERIFIED | |

## 6. E — Texnologiya / paketlar

| # | CLAIM | SOURCE | URL | DATE | ACCESSED | STATUS | NOTES |
|---|---|---|---|---|---|---|---|
| E-01 | Isar loyihasining kelajagi noaniq | pub.dev; GitHub | pub.dev/packages/isar; pub.dev/packages/isar_community | isar 3.1.0+1 — 2023-04-25 | 2026-10-04 | VERIFIED | 2023 dan beri barqaror reliz yo‘q; v4 «not ready for production». **Rad etildi** |
| E-02 | drift faol va FTS5 bilan ishlaydi | pub.dev | pub.dev/packages/drift | 2.35.1 — 2026-09-30 | 2026-10-04 | VERIFIED | Flutter Favorite |
| E-03 | `sqlite3_flutter_libs` FTS5 ni o‘z ichiga oladi | pub.dev | pub.dev/packages/sqlite3_flutter_libs | 0.6.0+eol — 2026-02-15 | 2026-10-04 | **NOT VERIFIED — paket EOL** | O‘rniga `sqlite3` 3.x (3.7.0, 2026-09-30) — build hooks orqali SQLite’ni `SQLITE_ENABLE_FTS5` bilan birga keltiradi |
| E-04 | FTS5 trigram tokenizer SQLite ≥ 3.34 talab qiladi | sqlite.org | sqlite.org/changes.html; sqlite.org/fts5.html | 3.34.0 — 2020-12-01 | 2026-10-04 | VERIFIED | |
| E-05 | `sqlcipher_flutter_libs` | pub.dev | pub.dev/packages/sqlcipher_flutter_libs | 0.7.0+eol — 2026-02-15 | 2026-10-04 | **NOT VERIFIED — paket EOL** | O‘rniga `sqlite3` 3.x hooks bilan `sqlcipher` yoki `sqlite3mc` manbasi; alohida litsenziya va OpenSSL masalalari |
| E-06 | `flutter_math_fork` holati | pub.dev | pub.dev/packages/flutter_math_fork | 0.7.4 — 2025-05-21 | 2026-10-04 | VERIFIED | Ishlaydi, lekin kam qo‘llab-quvvatlanadi (~16 oy reliz yo‘q). Alternativa: formulalarni build vaqtida SVG’ga render qilish |
| E-07 | `purchases_flutter`, `flutter_secure_storage` faol | pub.dev | pub.dev/packages/purchases_flutter; pub.dev/packages/flutter_secure_storage | 10.14.0 — 2026-10-01; 11.2.0 — 2026-09-16 | 2026-10-04 | VERIFIED | |
| E-08 | Impeller — iOS va Android’da standart renderer | docs.flutter.dev | docs.flutter.dev/perf/impeller | 2026-08-21 (Flutter 3.47) | 2026-10-04 | VERIFIED | iOS — yagona renderer; Android — API 29+ da standart, eski qurilmalarda OpenGL fallback |

## 7. F — Huquq

| # | CLAIM | SOURCE | URL | DATE | ACCESSED | STATUS | NOTES |
|---|---|---|---|---|---|---|---|
| F-01 | O‘zbekiston: narkotik vositalar to‘g‘risidagi qonun | lex.uz | lex.uz/docs/-86044 (uz); lex.uz/ru/docs/86028 (ru) | 813-I, 19.08.1999; oxirgi tahrir 08.05.2025 | 2026-10-04 | VERIFIED (nomi tuzatildi) | Rasmiy nomi: **«Giyohvandlik vositalari va psixotrop moddalar toʻgʻrisida»**. 4-modda — I–IV ro‘yxatlar Vazirlar Mahkamasi belgilagan tartibda tasdiqlanadi |
| F-02 | O‘zbekiston nazorat ro‘yxatlari | lex.uz | VM qarori №330, 12.11.2015: lex.uz/docs/2815340 (uz), lex.uz/ru/docs/2815342 (ru) | Tahrirlar 10.04.2025 gacha + **12.01.2027** sanali tahrir | 2026-10-04 | VERIFIED | I–IV ro‘yxatlar — 4–7-ilovalar. 12.01.2027 sanali tahrir — kechiktirilgan kuchga kirish ehtimoli; ro‘yxatlarni yuklashdan oldin tekshiriladi |
| F-03 | «Shaxsga doir ma’lumotlar to‘g‘risida» ZRU-547, 02.07.2019 | lex.uz | lex.uz/docs/-4396419 (uz); lex.uz/ru/docs/4396428 (ru) | Kuchga kirgan 01.10.2019; tahrirlar 27.03.2026, 25.07.2026, 12.09.2026 | 2026-10-04 | VERIFIED | |
| F-04 | 27-1-modda: barcha shaxsiy ma’lumotlar O‘zbekistonda saqlanishi kerak | lex.uz | o‘sha | 27-1-modda 2026-03-26 dagi ZRU-1125 bilan qayta yozilgan | 2026-10-04 | **PARTIALLY VERIFIED — jiddiy o‘zgargan** | Joriy matn (norasmiy rus tarjimasi asosida, uzbekcha matn ustun): majburiy lokal saqlash — **biometrik, genetik va telekom foydalanuvchilari ma’lumotlari**. Qolganlari — adekvat davlat, standart shartnoma bandlari, BCR yoki tasdiqlangan xalqaro standartlar asosida chetda mumkin. Yurist tasdig‘i kerak |
| F-05 | Sud-ekspertiza faoliyati to‘g‘risidagi qonun | lex.uz | Amaldagi: ZRU-249, 01.06.2010 (lex.uz/ru/docs/1633100). Yangi: **ZRU-1152, 11.06.2026** (lex.uz/ru/docs/8265779) | ZRU-1152 **13.12.2026** dan kuchga kiradi | 2026-10-04 | VERIFIED (tuzatildi) | ZRU-249 o‘sha sanada o‘z kuchini yo‘qotadi |
| F-06 | RF hukumati qarori №681 (30.06.1998) | government.ru | government.ru/docs/all/27467/ | Oxirgi ko‘rsatilgan o‘zgarish: №880, 11.06.2025 | 2026-10-04 | PARTIALLY VERIFIED | Konsolidatsiyalangan matn pravo.gov.ru da olinmadi |
| F-07 | RF 152-FZ, 18-modda 5-qism — lokalizatsiya | pravo.gov.ru | pravo.gov.ru/proxy/ips/?doc_itself=&nd=102108261 | 28.02.2025 dagi 23-FZ tahririda | 2026-10-04 | VERIFIED | RF fuqarolari ma’lumotlarini xorijdagi bazalarda birlamchi qayta ishlash taqiqlangan (istisnolar bilan) |
| F-08 | AQSh DEA jadvallari — 21 CFR 1308 | eCFR | ecfr.gov/current/title-21/chapter-II/part-1308 | 2026-10-01 holatiga | 2026-10-04 | VERIFIED | §§1308.11–1308.15 |
| F-09 | INCB Yellow/Green/Red ro‘yxatlari | incb.org | Yellow: …/Yellowlist/yellow-list.html; Green: …/psychotropics/green-list.html; Red: …/precursors/Red_Forms/red-list.html | Yellow 65-nashr (2026-07); Green 36-nashr (2025-12); Red 23-nashr (2025-07) | 2026-10-04 | VERIFIED | Jadvalga kiritish qarorlari — BMT CND |
| F-10 | GDPR 3(2)-modda | EUR-Lex | eur-lex.europa.eu/eli/reg/2016/679/oj | 2016/679 | 2026-10-04 | VERIFIED | EIdagi shaxslarga xizmat taklif qilgan EIdan tashqaridagi kontrollerlarga ham qo‘llanadi |
| F-11 | Anthropic API O‘zbekistonda mavjud | anthropic.com | anthropic.com/supported-countries | — | 2026-10-04 | VERIFIED | |

---

## 8. Ochiq qolgan bandlar (keyingi bosqichda yopiladi)

| # | Band | Nima uchun ochiq | Keyingi qadam |
|---|---|---|---|
| O-01 | Apple to‘lovlarini O‘zbekiston bankiga olish | Rasmiy tasdiq topilmadi | App Store Connect’da bank tanlash orqali amalda tekshirish |
| O-02 | Rossiyada Apple/Google IAP ishlashi | Tekshirilmadi | Alohida tekshiruv; RU foydalanuvchilari uchun billing strategiyasi |
| O-03 | UNODC hujjatlarining aniq reuse litsenziyasi | Topilmadi | UNODC’ga so‘rov yoki faqat CITE-ONLY |
| O-04 | SWGDRUG qayta tarqatish ruxsati | Litsenziya yo‘q | Ruxsat so‘rovi (agar kerak bo‘lsa) |
| O-05 | CAS litsenziya narxi | Narx so‘rov bo‘yicha | CAS’ga so‘rov |
| O-06 | Baselt/Clarke’s (MedicinesComplete) API/ma’lumot litsenziyasi | Narx so‘rov bo‘yicha | Pharmaceutical Press’ga so‘rov |
| O-07 | O‘zbekiston: adekvat davlatlar ro‘yxati va tasdiqlangan standartlar (27-1-modda) | Qidirilmadi | Yurist |
| O-08 | Uzbekcha rasmiy matn (27-1-modda) | Rus tarjimasi ishlatilgan | Yurist uzbekcha matnni tasdiqlaydi |
| O-09 | Marshall & Hoare 1962 aniq bibliografiyasi | DOI/PMID yo‘q | Henssge (V1.1) bosqichida kutubxona orqali |
| O-10 | EUDA European Drug Report 2025/2026 to‘liq matni | Sayt 403 qaytargan | Qo‘lda yuklab olish |
| O-11 | Trademark («Forensic Expert» nomi va logo) | Store tekshiruvi `02_COMPETITOR_ANALYSIS.md` da; rasmiy reestrlar qidirilmadi | WIPO/USPTO/EUIPO/UZ reestrlari + IP yurist |
| O-12 | IUPAC CIAAW atom massalari, ICD-11 litsenziyalari | Tekshirilmadi | PHASE 4 dan oldin |
| O-13 | O‘zbekiston bo‘yicha peer-reviewed sud-toksikologiya epidemiologiyasi | PubMed’da topilmadi | Mahalliy jurnallar, eLibrary.ru, mahalliy ekspertlar |

---

## 9. Arxitektura rejasiga kiritilgan tuzatishlar

`docs/00_ARXITEKTURA_REJASI.md` dagi har bir **[TEKSHIRISH KERAK]** belgisi audit natijasi bilan almashtirildi (format: `[AUDIT: STATUS — ID]`). Asosiy o‘zgarishlar:

1. CAS — V1 dan chiqarildi (LICENSE REQUIRED).
2. ASB raqamlari tuzatildi.
3. ATC — V1 dan chiqarildi.
4. `sqlite3_flutter_libs`/`sqlcipher_flutter_libs` → `sqlite3` 3.x build hooks.
5. Google Play tavsif disclaimeri, AI shikoyat tugmasi, target API 36 qo‘shildi.
6. Apple yosh reytingi va grafik tasvir siyosati qo‘shildi.
7. O‘zbekiston qonunlari nomlari va yangi ZRU-1152 qo‘shildi.
8. Lokalizatsiya bo‘yicha xulosa yangilandi (yurist tasdig‘i bilan).
