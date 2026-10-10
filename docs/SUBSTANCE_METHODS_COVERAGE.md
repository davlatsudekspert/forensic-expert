# Modda darajasidagi «Tekshirish usullari» — qamrov hisoboti

> Avtomatik yaratiladi: `python3 content/tools/build_substance_methods.py` (qo‘lda tahrirlamang). Holat: barcha matnlar `machine_draft`, yozuvlar `NEEDS_REVIEW` (ilmiy reviewer tasdig‘i yo‘q).

## 1. Umumiy natija

- Paketdagi moddalar: **137**.
- Kamida 1 ta **mahalliy (GC-MS/LC-MS/MS talab qilmaydigan)** usuli manba va aniq joyi bilan hujjatlashtirilgan moddalar: **55**.
- Kamida 3 xil usul oilasi hujjatlashtirilgan: **27** ta modda (amitriptyline, amphetamine, butalbital, chlorpromazine, cocaine, codeine, diazepam, diphenhydramine, ephedrine, fentanyl, haloperidol, heroin, ibuprofen, ketamine, lsd, mda, mdea, mdma, methadone, methamphetamine, morphine, oxazepam, pentobarbital, phenazepam, phenobarbital, salicylic-acid, secobarbital).
- Yangi yozuvlar (claim): **326** (shundan 57 tasi — modda bo‘yicha umumiy «identifikatsiya usullari» xulosasi).
- Usul oilalari bo‘yicha yozuvlar: 3 caveat, 15 chemical, 114 colour_test, 3 immunoassay, 20 instrumental, 16 microcrystal, 3 odour_test, 5 photometric, 5 physical, 1 spectroscopy, 53 tlc, 29 uv_spectrum.
- Hujjatlashtirilmagan moddalar: **82** (4-bo‘lim).

## 2. Manbalar (faqat ruxsat etilganlari)

| Kalit | Manba | Qanday keltiriladi |
|---|---|---|
| GMT-2024 | Yuldashev Z.A. va boshq., «Giyohvand moddalar tahlili», 2024 (muallif yozma ruxsati, `docs/DECISIONS.md`) | PDF sahifasi (bosma = PDF − 1), jadval raqami |
| TOKS-2025 | Yuldashev Z.A., Umarova G.Q., «Toksikologik kimyo» o‘quv-uslubiy majmua, 2025 (shu ruxsat) | PDF sahifasi (= bosma) |
| UNODC-13 | UNODC ST/NAR/13/Rev.1 «Rapid Testing Methods of Drugs of Abuse» (rasmiy PDF, bosma 37–52-betlar o‘qilgan) | bosma bet (PDF = bosma + 10) |
| SWGDRUG | SWGDRUG Recommendations v8.2, Part IIIB (Table 1 bosma 17-b.; IIIB.2–IIIB.5) | bo‘lim raqami + bosma bet |

Egasining reaktivlar to‘plami (`SRC-OWNER-REAGENTS`) — retseptlar bilan bog‘lash uchun: yozuvlardagi `recipe_ids` mavjud 76 retseptga ishora qiladi (Marki, Mecke, Mandelin, Fröhde, Erdmann, Dragendorff, Wagner, kobalt rodanid, Duquenois, Nessler, Trinder va b.); retsepti yo‘q reaktivlar (Simon, Zimmermann, Vitali–Morin, Fast Blue B, Pauli, Dille–Koppanyi, Ehrlich, van Urk …) nomi bilan keltirilgan, retsept to‘qilmagan.

Har bir yozuvda: matn (uz/ru/en), manba, aniq joyi (`value.locator_i18n` — uch tilda, manba nomi bilan), `evidence_class` (presumptive / supporting / screening / instrumental / physical), `swgdrug_category` (SWGDRUG ning o‘z toifasi, hujjatda bor bo‘lsa), `recipe_ids`. Aniq joyi keltirib bo‘lmagan usul **qo‘shilmagan**.

## 3. Modda bo‘yicha qamrov (usul oilalari soni)

| Modda | Guruh | rang | hid | kimyo | TLC | kristall | UB | foto | spektr. | t.suyuq. | immuno | instr. | Manbalar | Adabiyotdagi instr. havolalar |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 6-mam | opioids |  |  |  |  |  |  |  |  |  | 1 | 1 | GMT-2024 | 1 |
| acetone | alcohols_volatiles |  |  | 1 |  |  |  |  |  |  |  | 1 | TOKS-2025 | 2 |
| amitriptyline | antidepressants | 1 |  |  | 1 | 1 | 1 |  |  |  |  | 1 | TOKS-2025 | 2 |
| amphetamine | stimulants | 4 |  |  | 1 |  | 1 |  |  |  |  |  | GMT-2024, UNODC-13 | 1 |
| arsenic-trioxide | metals_inorganic |  |  | 1 |  |  |  |  |  |  |  |  | TOKS-2025 | 1 |
| benzoylecgonine | stimulants |  |  |  | 1 |  |  |  |  |  |  |  | GMT-2024 |  |
| butalbital | barbiturates | 4 |  |  | 1 | 1 | 1 |  |  |  |  | 1 | GMT-2024, UNODC-13 |  |
| carbon-monoxide | toxic_gases |  |  |  |  |  |  |  | 1 |  |  |  | TOKS-2025 | 1 |
| cbd | cannabinoids | 3 |  |  | 2 |  |  |  |  |  |  |  | GMT-2024, SWGDRUG | 1 |
| chloroform | alcohols_volatiles |  |  | 1 |  |  |  |  |  |  |  |  | TOKS-2025 | 3 |
| chlorpromazine | antipsychotics | 5 |  |  | 1 | 1 | 1 | 1 |  |  |  |  | GMT-2024 | 1 |
| chlorpyrifos | pesticides |  |  | 1 | 1 |  |  |  |  |  |  |  | TOKS-2025 |  |
| cocaine | stimulants | 3 | 1 |  | 1 | 1 | 1 |  |  |  |  | 1 | GMT-2024, UNODC-13 |  |
| codeine | opioids | 6 |  |  | 4 | 1 | 1 |  |  | 1 |  | 1 | GMT-2024, UNODC-13 |  |
| diazepam | benzodiazepines | 4 |  |  | 2 | 1 | 1 | 1 |  |  |  |  | GMT-2024, UNODC-13 | 1 |
| diazinon | pesticides |  |  | 1 | 1 |  |  |  |  |  |  |  | TOKS-2025 | 2 |
| diphenhydramine | pharmaceuticals | 4 |  |  | 1 |  | 1 |  |  |  |  |  | TOKS-2025 | 1 |
| doxepin | antidepressants |  |  |  |  |  |  |  |  |  |  | 1 | TOKS-2025 |  |
| ephedrine | stimulants | 3 |  |  | 2 | 1 | 1 |  |  |  |  |  | GMT-2024 | 1 |
| ethanol | alcohols_volatiles |  |  | 1 |  |  |  |  |  |  |  | 1 | TOKS-2025 | 3 |
| fentanyl | opioids | 2 |  |  | 1 |  | 1 |  |  |  |  | 1 | GMT-2024 | 1 |
| fluoxetine | antidepressants |  |  |  | 1 |  |  |  |  |  |  |  | TOKS-2025 | 1 |
| haloperidol | antipsychotics | 3 |  |  | 1 |  | 1 |  |  |  |  |  | GMT-2024 | 1 |
| heroin | opioids | 6 | 1 |  | 3 | 1 | 1 |  |  | 1 | 1 | 1 | GMT-2024, UNODC-13 | 2 |
| hydrogen-cyanide | toxic_gases |  |  | 1 |  |  |  |  |  |  |  |  | TOKS-2025 | 1 |
| hydrogen-sulfide | toxic_gases |  |  | 1 |  |  |  |  |  |  |  |  | TOKS-2025 | 1 |
| ibuprofen | pharmaceuticals | 1 |  |  | 1 |  | 1 |  |  | 1 |  |  | TOKS-2025 |  |
| imipramine | antidepressants |  |  |  |  |  |  |  |  |  |  | 1 | TOKS-2025 | 1 |
| ketamine | hallucinogens_dissociatives | 2 |  |  | 1 | 1 | 1 |  |  |  |  | 1 | GMT-2024 | 1 |
| lidocaine | pharmaceuticals |  |  |  |  | 1 |  |  |  |  |  |  | TOKS-2025 | 1 |
| lorazepam | benzodiazepines | 1 |  |  |  |  |  |  |  |  |  |  | UNODC-13 | 1 |
| lsd | hallucinogens_dissociatives | 3 |  |  | 1 |  | 1 |  |  |  |  |  | GMT-2024, UNODC-13 | 1 |
| malathion | pesticides |  |  | 2 | 2 |  |  |  |  |  |  |  | TOKS-2025 | 1 |
| mda | stimulants | 5 |  |  | 1 |  | 1 |  |  |  |  |  | GMT-2024, UNODC-13 |  |
| mdea | stimulants | 5 |  |  | 1 |  | 1 |  |  |  |  |  | GMT-2024, UNODC-13 |  |
| mdma | stimulants | 5 |  |  | 1 |  | 1 |  |  |  |  |  | GMT-2024, UNODC-13 | 1 |
| methadone | opioids | 5 |  |  | 1 |  | 1 |  |  |  |  |  | GMT-2024 | 1 |
| methamphetamine | stimulants | 5 |  |  | 1 |  | 1 |  |  |  |  |  | GMT-2024, UNODC-13 | 1 |
| methanol | alcohols_volatiles |  |  | 1 |  |  |  |  |  |  |  | 1 | TOKS-2025 | 2 |
| midazolam | benzodiazepines | 1 |  |  |  |  |  |  |  |  |  |  | UNODC-13 | 1 |
| mirtazapine | antidepressants |  |  |  | 1 |  | 1 |  |  |  |  |  | TOKS-2025 |  |
| morphine | opioids | 7 |  |  | 4 | 2 | 1 | 1 |  |  | 1 | 2 | GMT-2024, UNODC-13 | 1 |
| nortriptyline | antidepressants |  |  |  | 1 | 1 |  |  |  |  |  | 1 | TOKS-2025 | 1 |
| oxazepam | benzodiazepines | 1 |  |  | 2 |  | 1 | 1 |  |  |  |  | GMT-2024, UNODC-13 |  |
| parathion | pesticides |  |  | 1 | 1 |  |  |  |  |  |  |  | TOKS-2025 |  |
| pcp | hallucinogens_dissociatives | 4 |  |  | 1 |  |  |  |  |  |  |  | GMT-2024 | 2 |
| pentobarbital | barbiturates | 4 |  |  | 1 | 1 | 1 |  |  |  |  | 1 | GMT-2024, UNODC-13 |  |
| phenazepam | benzodiazepines | 1 |  |  | 2 |  | 1 | 1 |  | 1 |  |  | GMT-2024 |  |
| phenobarbital | barbiturates | 4 |  |  | 1 | 1 | 1 |  |  | 1 |  | 1 | GMT-2024, UNODC-13 | 1 |
| phosphine | toxic_gases |  |  | 1 |  |  |  |  |  |  |  |  | TOKS-2025 |  |
| psilocybin | hallucinogens_dissociatives |  |  |  |  |  | 1 |  |  |  |  |  | GMT-2024 | 1 |
| salicylic-acid | pharmaceuticals | 3 | 1 |  |  |  | 1 |  |  |  |  |  | TOKS-2025 |  |
| secobarbital | barbiturates | 4 |  |  | 1 | 1 | 1 |  |  |  |  | 1 | GMT-2024, UNODC-13 |  |
| strychnine | pesticides |  |  | 1 |  |  |  |  |  |  |  |  | TOKS-2025 | 2 |
| thallium-sulfate | metals_inorganic |  |  | 1 |  |  |  |  |  |  |  |  | TOKS-2025 | 1 |
| thc | cannabinoids | 5 |  |  | 2 |  |  |  |  |  |  | 1 | GMT-2024, SWGDRUG, UNODC-13 | 1 |
| venlafaxine | antidepressants |  |  |  | 1 |  |  |  |  |  |  |  | TOKS-2025 | 1 |

`instr.` — shu qatlamdagi (manbali) instrumental yozuvlar; oxirgi ustun — paketda oldindan mavjud `analysed_by` (adabiyot) havolalari soni.

## 4. Mahalliy usul hujjatlashtirilmagan moddalar (halol ro‘yxat)

Bu moddalar uchun ruxsat etilgan manbalarda (yuqoridagi 4 ta) aniq joyi bilan mahalliy usul topilmadi yoki o‘qilgan qismda yo‘q. Bu «usul mavjud emas» degani emas — faqat «hujjatlashtirilmagan».

- **adulterants** (2): levamisole, xylazine
- **alcohols_volatiles** (6): butane, diethylene-glycol, difluoroethane, ethylene-glycol, isopropanol, toluene
- **anticonvulsants** (6): carbamazepine, gabapentin, lamotrigine, phenytoin, pregabalin, valproic-acid
- **antidepressants** (6): bupropion, citalopram, doxepin, imipramine, sertraline, trazodone
- **antipsychotics** (4): clozapine, olanzapine, quetiapine, risperidone
- **benzodiazepines** (9): 7-aminoclonazepam, alprazolam, bromazolam, clonazepam, etizolam, flualprazolam, flunitrazepam, nordiazepam, temazepam
- **cannabinoids** (5): 11-oh-thc, adb-butinaca, jwh-018, mdmb-4en-pinaca, thc-cooh
- **hallucinogens_dissociatives** (2): 2c-b, ghb
- **opioids** (21): acetylfentanyl, alfentanil, buprenorphine, carfentanil, dextromethorphan, etonitazene, etonitazepyne, furanylfentanyl, hydrocodone, hydromorphone, isotonitazene, loperamide, metonitazene, mitragynine, norfentanyl, oxycodone, oxymorphone, protonitazene, sufentanil, tapentadol, tramadol
- **pesticides** (6): aldicarb, aluminium-phosphide, brodifacoum, carbofuran, glyphosate, paraquat
- **pharmaceuticals** (6): colchicine, digoxin, metformin, paracetamol, propranolol, verapamil
- **sedatives_hypnotics** (2): zolpidem, zopiclone
- **stimulants** (6): alpha-pvp, cathinone, cocaethylene, mdpv, mephedrone, methylphenidate
- **toxic_gases** (1): nitrous-oxide

Eslatma: GMT-2024 to‘liq o‘qilgan, TOKS-2025 esa kerakli bo‘limlar (alkaloidlar, uchuvchi zaharlar, metallar, FOB, antidepressantlar, NSAID). Qolgan moddalar (masalan, etilenglikol, izopropanol, paraquat, glifosat, karbamazepin, fenitoin, digoksin, metformin, propranolol, tramadol, paratsetamol) bu kitoblarda mahalliy usul bilan uchramadi.

## 5. Ilmiy halollik — qanday cheklovlar kiritilgan

- Har bir presumptive usul matnida uch tilda «taxminiy natija, o‘zi bilan aynanlikni isbotlamaydi» jumlasi bor; TLC uchun «xuddi shu plastinkadagi standart + ortogonal usul», kristall uchun «solishtirma nazorat», UB uchun «faqat yordamchi».
- Rf faqat manba aniq tizim bilan keltirganda kiritilgan. Tizimi aytilmagan Rf (strixnin 0,33; LSD 0,57) kiritilmadi; fentanilning jadvalida kesilgan ikki ustun qiymati kiritilmadi.
- Manbalarning ichki qarama-qarshiliklari yashirilmagan: morfinning Rf bir tizimda ikki jadvalda har xil (0,32–0,39 va 0,20); geroin UB (ishqorda 299 va 294 nm); morfin UB (296 va 298 nm); Duquenois ranglari kitobda (pushti → ko‘k → to‘q pushti) va UNODC da (binafsha) farq qiladi; talliy ditizonati ranglari ma’ruza va laboratoriya matnida farq qiladi.
- Kitob «reaksiya manfiy bo‘lsa tekshirishni to‘xtatish / nasha emas» kabi xulosalarni (ko‘rsatilgan joylarda) **takrorlanmadi**: SWGDRUG IIIB.3.3.4 ga ko‘ra manfiy natija aynanlikka hissa qo‘shmaydi; «manfiy ahamiyatli» reaksiyalar manba so‘zi bilan shunday belgilangan.
- SWGDRUG toifalari (A/B/C) hujjatning o‘z ta’rifi bo‘yicha; minimal talab IIIB.3.1–3.2 iborasi bilan; «sud xulosasi uchun yetarli» deb **aytilmaydi** — bu yurisdiksiya va laboratoriya protokoliga bog‘liq (IIIB.2.2). SWGDRUG faqat musodara qilingan giyohvand moddalar guruhlariga qo‘llanilgan.
- «ABY 2025» materiali ishlatilmagan va bu qatlamda unga havola yo‘q.

## 6. Hali qilinmagan / keyingi qadamlar

- Boshqa UNODC ST/NAR qo‘llanmalari (kannabis, amfetaminlar, kokain, opiatlar uchun TLC/rang sinamalari) hali o‘qilmagan; rasmiy PDF manzillari tekshirilib qo‘shilishi mumkin.
- Peer-reviewed adabiyot (PubMed/Crossref) bu o‘tishda yangi usul yozuvlari uchun ishlatilmadi; immunoanaliz kross-reaktivligi mavjud `scr-immunoassay-*` yozuvlarida (adabiyotdan) turibdi.
- UI (Dart) integratsiyasi: yangi `claims.field` qiymatlari — `colour_test`, `odour_test`, `chemical_test`, `tlc_system`, `microcrystal_test`, `uv_spectrum`, `photometric_assay`, `immunoassay_screen`, `confirmatory_method`, `melting_point`, `spectroscopy`, `identification_methods_overview`. Joyi uch tilda `value.locator_i18n`, manba nomi `value.source_i18n`; `value.evidence_class` bo‘yicha «TAXMINIY» belgisi ko‘rsatilishi kerak. Mavjud UI bu maydonlarni hozircha bo‘lim sifatida ko‘rsatmaydi.
- Ilmiy reviewer tasdig‘i va uz/ru tarjimalarining inson tekshiruvi.
