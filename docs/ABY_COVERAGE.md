# ABY 2025 — ilovadagi qamrov

Hujjat: **Sud-tibbiyot ekspertiza (tekshiruv)lari amaliyotlarini bajarish
yo‘riqnomasi (ABY)**. Respublika sud-tibbiy ekspertiza ilmiy-amaliy markazi,
Toshkent, 2025, 439 bet. Manba yozuvi: `SRC-ABY-2025`.

Yangilangan: 2026-10-10.

## Qoidalar (egasining qarori, `docs/DECISIONS.md`, 2026-10-10)

1. **Ochiq manba.** Yo‘riqnoma nomi bilan keltiriladi, aniq joyi bilan:
   «ABY, G bo‘limi, № ABY.G.16.2025 amaliyoti, 2.3-band». Ko‘rsatkich bet
   bo‘yicha emas — hujjatning o‘z raqamlash tartibi bo‘yicha.
2. **So‘zma-so‘z iqtibos yo‘q.** `value.excerpt` ishlatilmaydi; mazmun o‘z
   so‘zlarimiz bilan `value.statement` da. Auditda bu `paraphrase_not_quoted`
   belgisi bilan ko‘rinadi.
3. **Faqat o‘zbek tilida.** Har bir yozuvda `value.locale_only = "uz"`, mavzuda
   `locale_only = "uz"`. Rus va ingliz tilida yozuv ham, mavzu ham, qidiruvdagi
   nomi ham umuman chiqmaydi (`LocaleFilteredKnowledgeRepository`).
   Tarjima qilinmaydi, «tarjimasi yo‘q» degan joy ham qolmaydi.
4. **Bepul.** `tier_access = free` — Pro paywall ortiga qo‘yilmaydi.
5. **Fayl chiqmaydi.** Yo‘riqnoma faylining o‘zi repoda, ilova assetlarida,
   Supabase’da yoki boshqa AI xizmatida yo‘q — faqat undan olingan bilim va
   unga havola. Hujjat ochiq internetda yo‘q, shuning uchun manbada URL yo‘q.
6. Barcha yozuvlar `NEEDS_REVIEW`: ilmiy taqriz hali o‘tmagan.

Minnatdorchilik: Profil → Ilova haqida → **«Manbalar va mualliflar»** (faqat
o‘zbek tilida): tashkilot, 9 tuzuvchi, 3 taqrizchi va foydalanish izohi.

## Kiritilgan yozuvlar (92 ta da’vo, 39 ta mavzu) + 2 ta ekspert eslatmasi

### 1-to‘plam (2026-10-10): 32 da’vo, 19 mavzu

| Bo‘lim | Amaliyot | Ilovadagi joyi |
|---|---|---|
| G.5 | opiatlar (ajratish, TLC, rang reaksiyalari, cheklovlar) | `aby-tox-opiates` (3) |
| G.6 | barbituratlar | `aby-tox-barbiturates` |
| G.7 | 1,4-benzodiazepinlar (benzofenonlar orqali) | `aby-tox-benzodiazepines` |
| G.12 | kannabinoidlar | `aby-tox-cannabinoids` |
| G.14–15 | COHb va karboksimioglobin | `carbon-monoxide` moddasi (2) |
| G.16 | etanol/metanol — alkil nitritlar orqali GC-FID | `ethanol` (3), `methanol` (1) |
| G.18 | vodorod sulfid | `aby-tox-hydrogen-sulfide` |
| G.20 | difengidramin | `aby-tox-diphenhydramine` |
| G.24 | siydikda ekspress-test | `aby-tox-urine-express` (2) |
| D.1, D.2, D.14 | qon dog‘ini aniqlash | `aby-bio-blood-presence` (3) |
| D.5 | tur mansubligi (Chistovich–Ulengut) | `aby-bio-species` |
| D.9 | ABO (absorbsiya-elyusiya) | `aby-bio-abo` |
| D.25 | sperma — p30 (PSA) | `aby-bio-semen` |
| D.29–30 | so‘lak — amilaza, ekspress-test | `aby-bio-saliva` (2) |
| D.42–43 | soch morfologiyasi va taqqoslash | `aby-bio-hair` (2) |
| D.48 | najas dog‘i | `aby-bio-feces` |
| D.49 | ashyoviy dalillarni qabul qilish | `aby-evidence-intake` |
| D.50 | saqlash muddatlari | `aby-evidence-storage` |
| E.2 | formalinda fiksatsiya | `aby-his-fixation` |
| E.24 | gematoksilin–eozin (Mayer) | `aby-his-staining` |
| E.31 | diatom-plankton | `aby-his-diatoms` |

### 2-to‘plam (2026-10-11): 60 da’vo, 20 mavzu

| Bo‘lim | Amaliyotlar | Mazmuni |
|---|---|---|
| G.1–G.2 | sulfonilmochevina hosilalari | ajratish, TLC, STDIS |
| G.3, G.4, G.21, G.22 | uchuvchi zaharlar, Stass–Otto, dializ | ajratish usullari |
| G.9 | fosfororganik birikmalar | xolinesteraza sinamasi, TLC |
| G.10, G.11, G.13, G.19 | simob, metallar, sirka kislotasi, ammiak | destruksiya/mineralizatsiya va aniqlash |
| G.17 | fenotiazinlar | rang reaksiyalari, TLC |
| G.23, G.25 | amitriptilin, karbamazepin | ajratish, TLC, farmakokinetika |
| A.10, A.16–A.23, A.27, A.29–A.30 | supravital reaksiyalar, strangulyatsiya, chaqaloq sinamalari, emboliya, sinishlar, voqea joyi | murdani tekshirish |
| B.1–B.3 | tirik shaxs ekspertizasi tartibi, jarohatni tavsiflash, jinsiy yetuklik | |
| C.1, C.4 | takroriy/komission ekspertiza, tibbiy yordam nuqsonlari | |
| F.1–F.8 | dalillarni qabul/saqlash, tayyorlash, kiyim, o‘q-otar iz | |
| F.9–F.16 | suyaklar bo‘yicha jins | to‘sh, o‘mrov, kurak, tos, bosh suyagi |
| F.17–F.23, F.47 | yosh | tishlar, epifiz, bosh suyagi, simfiz, choklar, rentgen |
| F.24–F.26 | bo‘y | Manuvrie, Pirson, Rolle |
| F.27–F.28 | aynanlik | AGI (grafik identifikatsiya) |

### Ekspert eslatmalari (yo‘riqnomadan emas, xalqaro adabiyotdan)

| ID | Mavzu | Mazmuni |
|---|---|---|
| `C-ABYX-BENZIDINE-01` | qon dog‘ini aniqlash | benzidin — odam uchun kanserogen; xavfsizroq alternativalar |
| `C-ABYX-FLOAT-01` | chaqaloq o‘pka sinamasi | manfiy natija nafas olmaganlikni isbotlamaydi (208 ta o‘pka, 98 %) |

To‘liq ekspert tahlili va taqrizga qoldirilgan fikrlar: `docs/qa/ABY_EXPERT_REVIEW.md`.

Manba: `content/tools/aby_data.py`, `aby_data_b2.py`, `aby_expert_notes.py`;
builder `content/tools/build_aby_content.py`
(`build_substance_methods.py` va `build_ethanol_gc_content.py` dan **keyin**
ishga tushiriladi; `--check` bilan idempotentligi tekshiriladi).

## Hali kiritilmagan

Yo‘riqnomada jami 207 amaliyot: A (murdani tekshirish) 33, B (tirik shaxslar)
10, C (takroriy/komissiyali/kompleks) 4, D (sud-biologiya) 50,
E (sud-gistologiya) 37, F (tibbiy kriminalistika) 50, G (sud-kimyo) 23.
O‘qilib yozuvga aylantirilgani — 60 dan ortiq amaliyot (yuqoridagi jadvallar).
Eslatma: matndagi haqiqiy raqamlash A.1–A.32 va G.1–G.25.

Kiritilmagani:
- A, B, C va F bo‘limlari butunlay;
- G ning qolgan amaliyotlari: sulfonilmochevina hosilalari (G.1–2), metallar va
  simob (G.9–11, G.13, G.19), fenotiazinlar, fosfororganik birikmalar (G.17),
  sirka kislotasi, ammiak — bu moddalarning ko‘pi bazada hali yo‘q;
- D va E ning qolgan amaliyotlari (DNK, suyak, gistokimyo va boshqalar).

Ustuvorlik: avval bazada moddasi/mavzusi bor amaliyotlar, so‘ng yangi moddalar.
Har bir yangi yozuv yuqoridagi 6 qoidaga bo‘ysunadi.

## Eslatmalar (halol belgilangan)

- `C-ABY-ETHANOL-02`: qon uchun 0,95 va siydik uchun 1,05 koeffitsientlarining
  kelib chiqishi yo‘riqnomada tushuntirilmagan — «manba tekshirilmoqda».
- `C-ABY-TOX-OPI-02`: kodein FeCl₃ bilan reaksiya bermasligi aytilgan, ammo
  «uchala reaksiya musbat bo‘lishi» talabi bilan zid — matnda shunday
  ko‘rsatilgan.
- `C-ABY-TOX-BZD-01`: Rf jadvali hujjat matnida chalkash — qiymatlar
  keltirilmadi.
- `C-ABY-ETHANOL-01` va `C-ABY-CO-01` auditda `PARTIAL`: usul faqat shu milliy
  yo‘riqnomaga tayanadi, xalqaro manba bilan tasdiqlanmagan
  (`content/tools/claim_source_reviews.json` da sababi yozilgan).
