# REVIEW_GMT — «Giyohvand moddalar tahlili» kartalari: ekspert uchun tekshiruv ro‘yxati

Manba: Yuldashev Z.A., Zulfikariyeva D.A., Usmanaliyeva Z.U., Nurmatova M.I.
«Giyohvand moddalar tahlili. O‘quv qo‘llanma». Toshkent farmatsevtika instituti,
Toshkent, 2024; UDK 615.074.615.322; 173 b. (`gmt_yuldashev2024`).
Foydalanish: muallifning yozma ruxsati bilan (2026-10-09, `docs/DECISIONS.md`);
bu manbadan olingan kartalar, test savollari va terminlar **barcha uchun bepul**.

Holat: barcha 9 karta `NEEDS_REVIEW`; uz — muallif matni, ru/en — `DRAFT`.
«ABY 2025» materialidan foydalanilmagan.

## 1. Yaratilgan kartalar (`content/guidelines/src/`)

| Fayl | ID | Savollar |
|---|---|---|
| `card_gmt_0_scheme.json` | `guideline.chem.gmt_analysis_scheme` — Giyohvand moddalarni tahlil qilish sxemasi | 4 |
| `card_gmt_1_opioids.json` | `guideline.chem.gmt_opioids` — opiatlar va opioidlar | 8 |
| `card_gmt_2_cocaine.json` | `guideline.chem.gmt_cocaine` | 5 |
| `card_gmt_3_cannabis.json` | `guideline.chem.gmt_cannabis` | 4 |
| `card_gmt_4_phenylalkylamines.json` | `guideline.chem.gmt_phenylalkylamines` | 5 |
| `card_gmt_5_barbiturates.json` | `guideline.chem.gmt_barbiturates` | 4 |
| `card_gmt_6_benzodiazepines.json` | `guideline.chem.gmt_benzodiazepines` | 5 |
| `card_gmt_7_precursors.json` | `guideline.chem.gmt_precursors` | 4 |
| `card_gmt_8_uz_legal.json` | `guideline.chem.gmt_uz_control_lists` — huquqiy eslatma | 3 |

Jami test savollari: **42** (o‘zimiz yozgan; darslikdagi test savollari ishlatilmagan).

## 2. Qo‘shimcha (mustaqil) manbalar — darslik raqamlarini tekshirish uchun

| Kalit | Nima uchun | Qanday tekshirildi |
|---|---|---|
| `gmt_unodc_rapid_tests` | UNODC ST/NAR/13/Rev.1 — rangli testlar natijalari | unodc.org rasmiy PDF, 9–11 va 37–51-betlar o‘qildi |
| `gmt_pubchem_2026` | Formulalar, IUPAC nomlari, EI-MS asosiy cho‘qqilari (NIST yozuvlari) | PubChem PUG REST / PUG-View, 2026-10-09 |
| `gmt_bird2023` | Fentanil metabolizmi (norfentanil) | PubMed (PMID 37788600) |
| `gmt_lex_law813` | 813-I-son Qonun (4, 28-moddalar) | lex.uz/docs/86028, 2026-10-09 |
| `gmt_lex_cm330` | VM 330-son qarori (I–IV ro‘yxatlar 4–7-ilovalar; 878-son tahriri) | lex.uz/docs/2815342, 2026-10-09 |

## 3. Tuzatilgan xatolar (kartalarda «tuzatishlar» bo‘limida ko‘rsatilgan)

| Darslik (bet) | Darslikda | Kartada | Asos |
|---|---|---|---|
| 50 | Petidin = «1-metil-4-etinil-4-fenilpiperidin» | Etil 1-metil-4-fenilpiperidin-4-karboksilat, C15H21NO2 | PubChem CID 4058 |
| 52 | Petidin IQ-spektri: 186, 42, 201, 56, 57, 187, 202, 71 sm⁻¹ | Olib tashlandi | Promedol bo‘limidan (41-b.) aynan ko‘chirilgan; raqamlar to‘lqin soni emas |
| 41 | Promedol «IQ»: 186, 42, 201, 56 … sm⁻¹ | Olib tashlandi | m/z ga o‘xshaydi; PubChem da trimeperidin uchun GX-MS yozuvi yo‘q — tasdiqlab bo‘lmadi |
| 22 | Morfin ekstraksiyasi «Rf = 8,6–10,2» | pH 8,6–10,2 deb izohlandi | Rf 0–1 oralig‘ida bo‘ladi; kontekst — ekstraksiya muhiti |
| 61 | TGK: marixuana 13–15%, gashish 2–10% | Raqamlar olib tashlandi; sifat jihatdan | Nisbat teskari ko‘rinadi; UNODC: TGK miqdori o‘stirish va tayyorlashga bog‘liq |
| 134 | Nitrazepam gidrolizi → AXB | ANB | Darslikning o‘zi 135-b. sxema/jadvalda ANB beradi; nitroguruh |
| 114 | Metilfenobarbital UB/IQ/MS qatori | Olib tashlandi | Butalbital qatori bilan aynan bir xil (nusxa xatosi) |
| 101 | Butalbital suyuqlanish harorati 188–192 °C | Olib tashlandi | Barbital qiymati bilan bir xil (nusxa xatosi) |
| 31–32 | Opiatlar Markis jadvali (diamorfin ≠ geroin rangi; buprenorfin ikki marta) | Jadval o‘rniga UNODC umumiy natijasi | Ichki qarama-qarshilik |
| 146–147 | Fenilsirka kislota → «MDA»; N-metilefedrin → «metkatinon»; safrol → faqat «MDEA» | Bu bog‘lanishlar keltirilmadi | Noto‘liq/noaniq; mustaqil tekshirilmadi |
| 151 | Sirka angidridi «tahlilda keng qo‘llaniladi» | Prekursor sifatida — sintezda (morfin → geroin atsetillash, 15-b.) | Kontekst xatosi |
| 11 | JK 270–276-moddalarini «Jinoyat-protsessual kodeksi» deb atash | Keltirilmadi | Jinoyat kodeksi bilan chalkashtirilgan; huquqiy kartada umumiy eslatma |
| 12 | Ro‘yxatlar «878-son qarorga muvofiq» | Ro‘yxatlar 330-son qarorga 4–7-ilovalar; 878-son — o‘zgartiruvchi qaror | lex.uz |
| 45 | Fentanil metabolizmi — amid gidrolizi asosiy yo‘l sifatida | Asosiy siydik metaboliti norfentanil | Bird 2023 (PubMed) |

## 4. Ataylab keltirilmagan raqamlar va ma’lumotlar

Umumiy qoida: (a) faqat bitta laboratoriya sharoitiga xos raqamlar (Rf, ushlanish
vaqtlari, aniqlash chegaralari, unumlar); (b) dozalar, o‘lim dozalari, farmakokinetika;
(c) mustaqil manba bilan solishtirib bo‘lmagan spektral raqamlar — keltirilmadi.

| Darslik (bet) | Ma’lumot | Sabab |
|---|---|---|
| 23, 32, 43, 46–47, 58, 67–68, 76, 86, 112, 135, 156 | Barcha Rf / Rf×100 / Rs qiymatlari | Sharoitga bog‘liq; faqat ajralish **tartibi** keltirildi (opiatlar, kannabinoidlar, efedrin/efedron, benzoilekgonin startda) |
| 23 | Morfin aniqlash chegarasi 10–15 mkg; unum qondan 83%, siydikdan 71% | Laboratoriyaga xos |
| 24, 27–28, 36 | Mikrokristall/rangli reaksiyalar sezgirligi (0,03 mg; 0,1 mkg; 0,05–0,07 mkg; 2–14 mkg) | Tekshirilmagan; ayrimlari (kodein Frede 0,1 mkg) shubhali |
| 24–44 | Morfin, kodein, geroin, dionin, apomorfin, metadon, fentanil IQ to‘lqin sonlari | Mustaqil spektr kutubxonasi bilan solishtirilmadi |
| 27, 34, 36 | Frede reaktivi ranglari (kodein, dionin, geroin) | Mustaqil manba bilan tasdiqlanmadi (UNODC qo‘llanmasida Frede yo‘q) |
| 40 | Promedol Markis — «to‘q qizil» | Tasdiqlanmadi |
| 52 | Petidin UB maksimumlari 204/207/213 nm | Fenilpiperidin efiri uchun shubhali (fentanil/promedol 251/257/263 nm) |
| 20–21, 26, 34, 38, 41, 44–45, 50, 55, 78, 83–84, 105, 133 | Dozalar, o‘lim dozalari, ta’sir kuchi nisbatlari, qondagi «zaharli/o‘lim» konsentratsiyalari | Analitik emas; tekshirilmagan |
| 42, 50 | Metadon va meperidin o‘lim holatlaridagi konsentratsiyalar (Baselt) | Ikkilamchi iqtibos |
| 55 | Kokain yarim chiqish davrlari, bioyaroqlilik, metabolitlar foizlari | Tekshirilmagan; sifat jihatdan |
| 56 | Kokain ishlab chiqarish uchun prekursor miqdorlari | Tahlilga aloqasiz |
| 64–65 | Kannabinoidlar chiqarilish foizlari; reaksiyalar sezgirligi 1 mkg; «Buke» reaktivi | Tekshirilmagan |
| 76 | Efedrin MS ning kichik ionlari (146 va b.) | Faqat asosiy cho‘qqi m/z 58 (darslik) keltirildi |
| 79, 86 | YuQX tizimi xloroform–aseton–etanol–ammiak (20:3:1:20) | G‘ayrioddiy tarkib (ehtimol bosma xatosi) |
| 100–108 | Har bir barbiturat uchun eruvchanlik, pKa, suyuqlanish harorati | Alohida keltirilmadi (faqat pKa oralig‘i 7,4–8,0) |
| 114–115 | Barbituratlarning IQ va kichik MS ionlari | Faqat fenobarbital 204/117 (NIST) va umumiy 141/156 fragmentlari |
| 135 | Benzofenonlar Rf va UB maksimumlari | Sharoitga bog‘liq |
| 138–143 | Xlordiazepoksid, oksazepam, fenazepam IQ/MS | NIST bilan solishtirilmadi (diazepam, nitrazepam — solishtirildi va mos) |
| 10–13, 145, 160–171 | Ro‘yxatlardagi moddalar soni (246/51/85/29; 26), farmon PQ-175/2, ilova matnlari | Vaqt bilan o‘zgaradi; ro‘yxatlar ilovada ko‘chirilmaydi |
| 145 | Yevropa Ittifoqining 2001 yilgi norefedrin qarori | Tekshirilmagan |
| 151, 156 | Sirka angidridi havodagi REM; LSD o‘lim dozasi | Tekshirilmagan |

## 5. Mustaqil tekshirilgan va kartaga kiritilgan raqamlar

- EI-MS (PubChem/NIST): fentanil 245/146/189 (darslik bilan mos); metadon 72; petidin 71, M⁺ 247;
  amfetamin 44/91; MDMA 58/135/77; fenobarbital 204/117; diazepam 256/283/284 (darslik bilan mos);
  nitrazepam 253/280/206 (darslik bilan mos); kokain 82 (HMDB/MoNA EI).
- UB: morfin ~285 nm (kislota), ishqorda uzun to‘lqinga siljish; barbituratlar pH 10 ~240 nm, pH 13 ~255 nm;
  amfetaminlar 251/257/263 nm; MDA/MDMA ~235/286 nm — darslikdan, Clarke tipidagi ma’lumotlarga mos
  (ekspert qayta tekshirsin).
- Rangli testlar: UNODC ST/NAR/13/Rev.1 bilan solishtirildi (Markis, Mekke, nitrat kislota, kobalt
  tiotsianat, Skott, Fast Blue B, Dyukenua–Levin, Saymon, Dille–Koppani, Simmerman, Vitali–Moren).

## 6. Ekspertdan so‘raladigan savollar

1. Metadon uchun Mandelin «yashil → ko‘k» va kobalt tiotsianat «ko‘k» (43-b.) — amaliyotda tasdiqlansinmi?
2. Fentanil uchun limon kislota/sirka angidridi «qizil-binafsha» (46-b.) — laboratoriyada sinalganmi?
3. Kannabinoidlar GX elyutsiya tartibi (KBD < TGK < KBN, SE-30) — saqlansinmi?
4. Benzol o‘rniga (134-b.) qaysi erituvchi tavsiya etiladi?
5. Ru/en tarjimalar terminologiyasi (`DRAFT`).
