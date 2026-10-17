# «Tahlil» bo‘limi tuzilmasi — audit va to‘ldirish (2026-10-17)

Egasi topshirig‘i: moddalarning «Tahlil» tabi uch qismga ajratilsin — **1) Test (ekspress / skrining)**,
**2) Sifat reaksiyalari (rangli reaktivlar)**, **3) Miqdoriy aniqlash (GC-MS, LC-MS/MS, spektrofotometr va b.)**.
Qoidalar: feature-freeze (mavjud tabni tartibga solish), Pro/to‘lov yo‘q, ABY ga tegilmadi va tayanilmadi,
yangi yozuvlar faqat o‘zbek tilida (`source_lang: "uz"`; RU/EN keyin), manbasiz raqam (LOD, m/z, RT) yozilmaydi.

## 1. Audit natijasi — boshlang‘ich holat

**Ilovada (`substance_analysis_section.dart`).** «Tahlil» tabi uch qatlamga bo‘lingan edi, lekin egasi aytgan tartibda emas:
ABY bloki → «kitob qo‘llanmasi» bloki (ekspress → rangli → mikrokristall → TLC → UB …) → «adabiyotdagi dalillar» bloki;
undan keyin namunalar, skrining → tasdiqlash, metodlar, metabolitlar. «Test / Sifat / Miqdoriy» bo‘linishi yo‘q edi,
bo‘sh bo‘lim uchun «manba kerak» holati ham yo‘q edi (modda butunlay bo‘sh bo‘lsagina umumiy bo‘sh holat chiqardi).

**`content/` da.**
- Yuldashev kitoblari (GMT-2024, TOKS-2025) asosidagi yozuvlar: `C-SM-*` (326 ta, `build_substance_methods.py`) — rangli
  reaksiyalar, TLC, mikrokristall, UB, tasdiqlovchi usullar; har biri aniq bet bilan, so‘zma-so‘z emas. Qamrov hisoboti:
  `docs/SUBSTANCE_METHODS_COVERAGE.md`.
- UNODC ST/NAR/13 (rang sinamalari, bosma 37–52-b.) va SWGDRUG v8.2 (Part IIIB) — yuqoridagi yozuvlar ichida.
- Ochiq adabiyot (PMC, CC BY): `analytical_method` — ~111 modda uchun bittadan abstrakt jumla (`C-*-ANALYTICAL_METHOD-P5`),
  `reported_concentration`, sud-tibbiy holatlar; metodlar (`method-gcms`, `method-lcmsms`, `method-uvvis` …) va reagentlar.
- **Kravchenko kitobi repoda ham, ish papkasida ham yo‘q** — hech bir yozuv unga tayanmaydi. (Uni qo‘shish uchun egasi
  faylni va kerakli boblarni berishi kerak, 5-bo‘limga qarang.)
- Hisoblash usuli: `python3 content/tools/analysis_structure_audit.py` (ABY yozuvlari hisobga olinmaydi).

Boshlang‘ich son (bu ish boshlanishidan oldin, 140 modda): **1. Test — 10**, **2. Sifat — 52**, **3. Miqdoriy — 111**;
uch bo‘limi ham bor moddalar — **8**, hech bo‘lmaganda bittasi ham yo‘q — **25**.

## 2. Nima qilindi

**Ilova (minimal o‘zgarish, yangi funksiya emas).**
- Tab endi aniq 3 bo‘lim: «1. Test (ekspress / skrining)», «2. Sifat reaksiyalari (rangli reaktivlar)»,
  «3. Miqdoriy aniqlash (GC-MS, LC-MS/MS, spektrofotometriya)». Har bir bo‘limda qisqa izoh; ichida avval tasdiqlangan
  manba (ustoz kitobi), keyin adabiyot yozuvlari (har biri o‘z holati va dalil darajasi bilan, aniq joyi bilan).
- Bo‘limda manbali yozuv bo‘lmasa — halol bo‘sh holat: «manba kerak. Hech narsa taxmin qilinmaydi.»
- Graf qatorlari ham shu tartibda: rangli / mikrokristall sinamalar va TLC → «Sifat»; qolgan skrining testlari → «Test»;
  GC-MS / LC-MS/MS / UB metodlari → «Miqdoriy». Namunalar va metabolitlar 3 bo‘limdan keyin (o‘zgarishsiz).
- Faqat o‘zbekcha asl tilda bo‘lgan yozuv rus/ingliz interfeysida asl o‘zbekcha matn bilan va «Tarjima kutilmoqda» belgisi
  bilan ko‘rinadi (tarjima to‘qilmaydi) — CLAUDE.md «Til tartibi».
- Fayllar: `substance_analysis_section.dart`, `content_entry_sections.dart` (belgi), `library_models.dart` (getter),
  ARB (uz/ru/en: 8 ta yangi matn), `test/widget/analysis_three_sections_test.dart`.

**Kontent (`C-AS-*`, 54 ta yangi yozuv; `content/tools/build_analysis_fill.py`, ma’lumotlar `analysis_fill_data.py` va
`analysis_fill_lit.json`).**
- *Yuldashev, Umarova «Toksikologik kimyo» (2025) — 20 yozuv, faqat o‘zbekcha, o‘z so‘zimiz bilan, bet ko‘rsatilgan:*
  simob (ditizon va CuI sinamalari, destruksiya, fotokolorimetriya/nefelometriya — 77–79, 202, 213-b.), sirka kislota
  (hid, FeCl3, La-nitrat+yod, efir reaksiyalari, ajratish, titrlash/yodometriya — 27, 31–32-b.), ammiak (indikator
  qog‘ozlar, Nessler — 147, 262–263-b.), aminazin (peshob sinamasi, 20 va 170-b.), barbituratlar guruhi (peshobda kobalt
  atsetati sinamasi, 20-b.), sianid kislotasi va mishyak(III) oksidi (dastlabki sinamalar, 170-b.), sertralin
  (termodesorbsion sirt-ionlashuv spektroskopiyasi, TDSIS — mahalliy «Iskovich-1» apparati: sharoit va xos cho‘qqilar, 141, 257–258-b.).
- *Ochiq adabiyot (PMC, CC BY/CC0) — 34 yozuv:* jumla asl matndan aynan (`value.excerpt`), litsenziya va jumla
  `build_analysis_fill.py --verify` bilan tekshirilgan (PMC BioC yoki Europe PMC); o‘zbekcha tarjima — `machine_draft`
  (tekshirilmagan). Manbada bo‘lgan raqamlar (masalan, furanilfentanil/atsetilfentanil LOD/LOQ: 0,30/1,0 va 0,15/0,50 ng/mL)
  o‘zgarishsiz. Qamrab olingan: bromazolam, flualprazolam, etizolam (UB solishtirma yutilish), gidrokodon, etonitazepyne,
  bupropion, risperidon (TLC), JWH-018, furanilfentanil, atsetilfentanil, kolxitsin, simob (shakllanish tahlili), GHB;
  «Test» uchun: tramadol (2), paratsetamol, zopiklon, levamizol, oksikodon, buprenorfin, nitazenlar (5).
- Raqamli ko‘rsatkichlar (LOD/LOQ, test-chiziq kross-reaktivligi) `value.analytical_performance: true` belgisi bilan: bu — usul
  ko‘rsatkichi, namunadagi konsentratsiya emas (`phase5_test` dagi «konsentratsiya faqat banner ostida» qoidasi shu belgi bilan
  chetlab o‘tiladi; namunadagi konsentratsiyali jumlalar adabiyotdan kiritilmadi).
- Qat’iy qoida: manbada bo‘lmagan hech narsa (m/z, RT, LOD/LOQ, rang) yozilmagan; kitob bandida rang aytilmagan joyda
  yozuvda ham «rangi ko‘rsatilmagan» deyilgan (masalan, Nessler cho‘kmasi, kobalt atsetati sinamasi).
- Hamma yangi yozuv `NEEDS_REVIEW`; ilmiy reviewer tasdig‘i yo‘q.

## 3. Natija (avtomatik jadval)

Quyidagi blok `analysis_structure_audit.py` bilan yangilanadi (qo‘lda tahrirlamang).

<!-- AUTO:BEGIN -->
Moddalar: **140**. Hisoblash: `python3 content/tools/analysis_structure_audit.py` (ABY hisobga olinmagan).

| Bo‘lim | Kamida 1 ta manbali yozuvi bor moddalar |
|---|---|
| 1. Test | 30 / 140 |
| 2. Sifat | 56 / 140 |
| 3. Miqdoriy | 124 / 140 |

| Nechta bo‘lim to‘ldirilgan | Moddalar |
|---|---|
| 3/3 | 16 |
| 2/3 | 45 |
| 1/3 | 72 |
| 0/3 | 7 |

Belgilar: `Y-GMT` / `Y-TOKS` = Yuldashev kitoblari (GMT-2024, TOKS-2025); `UNODC` = ST/NAR/13; `SWGDRUG` = v8.2; `LIT` = ochiq maqola (PMC/PubMed); `graf-skrining` / `graf-sinama` / `graf-usul` = manbali graf bog‘lanishi (skrining testi / rangli-mikrokristall-TLC sinamasi / tahlil usuli).

**Guruh bo‘yicha bo‘sh bo‘limlar (manbali yozuvi yo‘q moddalar soni / guruhdagi jami)**

| Guruh | Jami | 1. Test bo‘sh | 2. Sifat bo‘sh | 3. Miqdoriy bo‘sh |
|---|---|---|---|---|
| adulterants | 2 | 1 | 2 | 1 (levamisole) |
| alcohols_volatiles | 11 | 10 | 6 | 1 (difluoroethane) |
| anticonvulsants | 6 | 6 | 6 | 0 |
| antidepressants | 11 | 11 | 6 | 0 |
| antipsychotics | 6 | 5 | 3 | 0 |
| barbiturates | 4 | 0 | 0 | 0 |
| benzodiazepines | 14 | 14 | 9 | 0 |
| cannabinoids | 7 | 6 | 5 | 0 |
| hallucinogens_dissociatives | 6 | 6 | 3 | 0 |
| metals_inorganic | 3 | 2 | 0 | 0 |
| opioids | 27 | 15 | 22 | 4 (alfentanil, etonitazene, loperamide, metonitazene) |
| pesticides | 11 | 11 | 6 | 3 (aluminium-phosphide, chlorpyrifos, parathion) |
| pharmaceuticals | 10 | 8 | 6 | 1 (verapamil) |
| sedatives_hypnotics | 2 | 1 | 2 | 1 (zopiclone) |
| stimulants | 14 | 10 | 6 | 2 (alpha-pvp, benzoylecgonine) |
| toxic_gases | 6 | 4 | 2 | 3 (ammonia, nitrous-oxide, phosphine) |

| Modda | Guruh | 1. Test | 2. Sifat | 3. Miqdoriy | Jami |
|---|---|---|---|---|---|
| levamisole | adulterants | LIT×1 | — | — | 1/3 |
| xylazine | adulterants | — | — | LIT×1, graf-usul×1 | 1/3 |
| acetic-acid | alcohols_volatiles | Y-TOKS×1 | Y-TOKS×3, graf-sinama×3 | Y-TOKS×2 | 3/3 |
| acetone | alcohols_volatiles | — | Y-TOKS×1, graf-sinama×1 | LIT×1, Y-TOKS×1, graf-usul×2 | 2/3 |
| butane | alcohols_volatiles | — | — | LIT×1, graf-usul×1 | 1/3 |
| chloroform | alcohols_volatiles | — | Y-TOKS×1, graf-sinama×1 | LIT×1, graf-usul×3 | 2/3 |
| diethylene-glycol | alcohols_volatiles | — | — | LIT×1, graf-usul×1 | 1/3 |
| difluoroethane | alcohols_volatiles | — | — | — | 0/3 |
| ethanol | alcohols_volatiles | — | Y-TOKS×1, graf-sinama×1 | LIT×4, Y-TOKS×1, graf-usul×3 | 2/3 |
| ethylene-glycol | alcohols_volatiles | — | — | LIT×1, graf-usul×1 | 1/3 |
| isopropanol | alcohols_volatiles | — | — | LIT×1, graf-usul×2 | 1/3 |
| methanol | alcohols_volatiles | — | Y-TOKS×1, graf-sinama×1 | LIT×1, Y-TOKS×1, graf-usul×2 | 2/3 |
| toluene | alcohols_volatiles | — | — | LIT×1, graf-usul×1 | 1/3 |
| carbamazepine | anticonvulsants | — | — | LIT×1, graf-usul×2 | 1/3 |
| gabapentin | anticonvulsants | — | — | LIT×1, graf-usul×1 | 1/3 |
| lamotrigine | anticonvulsants | — | — | LIT×1, graf-usul×1 | 1/3 |
| phenytoin | anticonvulsants | — | — | LIT×1, graf-usul×2 | 1/3 |
| pregabalin | anticonvulsants | — | — | LIT×1, graf-usul×1 | 1/3 |
| valproic-acid | anticonvulsants | — | — | LIT×1, graf-usul×1 | 1/3 |
| amitriptyline | antidepressants | — | Y-TOKS×3, graf-sinama×3 | LIT×1, Y-TOKS×2, graf-usul×3 | 2/3 |
| bupropion | antidepressants | — | — | LIT×1 | 1/3 |
| citalopram | antidepressants | — | — | LIT×1, graf-usul×1 | 1/3 |
| doxepin | antidepressants | — | — | Y-TOKS×1, graf-usul×1 | 1/3 |
| fluoxetine | antidepressants | — | Y-TOKS×1, graf-sinama×1 | LIT×1, graf-usul×1 | 2/3 |
| imipramine | antidepressants | — | — | LIT×1, Y-TOKS×1, graf-usul×2 | 1/3 |
| mirtazapine | antidepressants | — | Y-TOKS×1, graf-sinama×1 | Y-TOKS×1, graf-usul×1 | 2/3 |
| nortriptyline | antidepressants | — | Y-TOKS×2, graf-sinama×2 | LIT×1, Y-TOKS×1, graf-usul×2 | 2/3 |
| sertraline | antidepressants | — | — | LIT×1, Y-TOKS×1, graf-usul×1 | 1/3 |
| trazodone | antidepressants | — | — | LIT×1, graf-usul×1 | 1/3 |
| venlafaxine | antidepressants | — | Y-TOKS×1, graf-sinama×1 | LIT×1, graf-usul×1 | 2/3 |
| chlorpromazine | antipsychotics | Y-TOKS×1 | Y-GMT×7, graf-sinama×3 | LIT×1, Y-GMT×2, graf-usul×2 | 3/3 |
| clozapine | antipsychotics | — | — | LIT×1 | 1/3 |
| haloperidol | antipsychotics | — | Y-GMT×4, graf-sinama×2 | LIT×1, Y-GMT×1, graf-usul×2 | 2/3 |
| olanzapine | antipsychotics | — | — | LIT×1, graf-usul×1 | 1/3 |
| quetiapine | antipsychotics | — | — | LIT×1, graf-usul×1 | 1/3 |
| risperidone | antipsychotics | — | LIT×2 | LIT×1 | 2/3 |
| butalbital | barbiturates | Y-TOKS×1 | UNODC×1, Y-GMT×5, graf-sinama×3 | Y-GMT×2, graf-usul×3 | 3/3 |
| pentobarbital | barbiturates | Y-TOKS×1 | UNODC×1, Y-GMT×5, graf-sinama×3 | LIT×1, Y-GMT×2, graf-usul×3 | 3/3 |
| phenobarbital | barbiturates | Y-TOKS×1 | UNODC×1, Y-GMT×6, graf-sinama×3 | LIT×1, Y-GMT×2, graf-usul×4 | 3/3 |
| secobarbital | barbiturates | Y-TOKS×1 | UNODC×1, Y-GMT×5, graf-sinama×3 | Y-GMT×2, graf-usul×3 | 3/3 |
| 7-aminoclonazepam | benzodiazepines | — | — | LIT×1, graf-usul×1 | 1/3 |
| alprazolam | benzodiazepines | — | — | LIT×1, graf-usul×1 | 1/3 |
| bromazolam | benzodiazepines | — | — | LIT×2 | 1/3 |
| clonazepam | benzodiazepines | — | — | LIT×1, graf-usul×1 | 1/3 |
| diazepam | benzodiazepines | — | UNODC×3, Y-GMT×4, graf-sinama×3 | LIT×1, Y-GMT×2, graf-usul×2 | 2/3 |
| etizolam | benzodiazepines | — | — | LIT×2 | 1/3 |
| flualprazolam | benzodiazepines | — | — | LIT×2 | 1/3 |
| flunitrazepam | benzodiazepines | — | — | LIT×1, graf-usul×1 | 1/3 |
| lorazepam | benzodiazepines | — | UNODC×1, graf-sinama×1 | LIT×1, graf-usul×1 | 2/3 |
| midazolam | benzodiazepines | — | UNODC×1, graf-sinama×1 | LIT×1, graf-usul×1 | 2/3 |
| nordiazepam | benzodiazepines | — | — | LIT×1, graf-usul×1 | 1/3 |
| oxazepam | benzodiazepines | — | UNODC×1, Y-GMT×2, graf-sinama×2 | LIT×1, Y-GMT×2, graf-usul×1 | 2/3 |
| phenazepam | benzodiazepines | — | Y-GMT×4, graf-sinama×2 | Y-GMT×2, graf-usul×1 | 2/3 |
| temazepam | benzodiazepines | — | — | LIT×1, graf-usul×2 | 1/3 |
| 11-oh-thc | cannabinoids | — | — | LIT×1, graf-usul×1 | 1/3 |
| adb-butinaca | cannabinoids | — | — | LIT×1, graf-usul×1 | 1/3 |
| cbd | cannabinoids | — | SWGDRUG×1, Y-GMT×5, graf-sinama×2 | LIT×1, graf-usul×1 | 2/3 |
| jwh-018 | cannabinoids | — | — | LIT×1 | 1/3 |
| mdmb-4en-pinaca | cannabinoids | — | — | LIT×1 | 1/3 |
| thc | cannabinoids | graf-skrining×1 | SWGDRUG×1, UNODC×2, Y-GMT×6, graf-sinama×2 | LIT×1, Y-GMT×1, graf-usul×2 | 3/3 |
| thc-cooh | cannabinoids | — | — | LIT×1, graf-usul×1 | 1/3 |
| 2c-b | hallucinogens_dissociatives | — | — | LIT×1, graf-usul×1 | 1/3 |
| ghb | hallucinogens_dissociatives | — | — | LIT×2 | 1/3 |
| ketamine | hallucinogens_dissociatives | — | Y-GMT×4, graf-sinama×3 | LIT×1, Y-GMT×2, graf-usul×4 | 2/3 |
| lsd | hallucinogens_dissociatives | — | UNODC×1, Y-GMT×3, graf-sinama×2 | LIT×1, Y-GMT×1, graf-usul×2 | 2/3 |
| pcp | hallucinogens_dissociatives | — | Y-GMT×5, graf-sinama×2 | LIT×1, graf-usul×2 | 2/3 |
| psilocybin | hallucinogens_dissociatives | — | — | LIT×1, Y-GMT×1, graf-usul×2 | 1/3 |
| arsenic-trioxide | metals_inorganic | Y-TOKS×1 | Y-TOKS×1, graf-sinama×1 | LIT×1, graf-usul×1 | 3/3 |
| mercury | metals_inorganic | — | Y-TOKS×2, graf-sinama×2 | LIT×1, Y-TOKS×2 | 2/3 |
| thallium-sulfate | metals_inorganic | — | Y-TOKS×1, graf-sinama×1 | LIT×1, graf-usul×1 | 2/3 |
| 6-mam | opioids | Y-GMT×1, graf-skrining×1 | — | LIT×1, Y-GMT×1, graf-usul×2 | 2/3 |
| acetylfentanyl | opioids | — | — | LIT×3 | 1/3 |
| alfentanil | opioids | — | — | — | 0/3 |
| buprenorphine | opioids | LIT×1 | — | LIT×1, graf-usul×1 | 2/3 |
| carfentanil | opioids | — | — | LIT×1, graf-usul×1 | 1/3 |
| codeine | opioids | — | UNODC×3, Y-GMT×9, graf-sinama×3 | Y-GMT×2, graf-usul×2 | 2/3 |
| dextromethorphan | opioids | — | — | LIT×1, graf-usul×1 | 1/3 |
| etonitazene | opioids | LIT×1 | — | — | 1/3 |
| etonitazepyne | opioids | LIT×1 | — | LIT×1 | 2/3 |
| fentanyl | opioids | graf-skrining×2 | Y-GMT×3, graf-sinama×2 | LIT×1, Y-GMT×2, graf-usul×4 | 3/3 |
| furanylfentanyl | opioids | — | — | LIT×3 | 1/3 |
| heroin | opioids | Y-GMT×2, graf-skrining×1 | UNODC×3, Y-GMT×8, graf-sinama×3 | LIT×1, Y-GMT×2, graf-usul×4 | 3/3 |
| hydrocodone | opioids | — | — | LIT×1 | 1/3 |
| hydromorphone | opioids | — | — | LIT×1, graf-usul×1 | 1/3 |
| isotonitazene | opioids | LIT×1 | — | LIT×1, graf-usul×1 | 2/3 |
| loperamide | opioids | — | — | — | 0/3 |
| methadone | opioids | — | Y-GMT×6, graf-sinama×2 | LIT×1, Y-GMT×1, graf-usul×2 | 2/3 |
| metonitazene | opioids | LIT×1 | — | — | 1/3 |
| mitragynine | opioids | — | — | LIT×1, graf-usul×1 | 1/3 |
| morphine | opioids | Y-GMT×1, graf-skrining×1 | UNODC×4, Y-GMT×9, graf-sinama×3 | LIT×1, Y-GMT×4, graf-usul×3 | 3/3 |
| norfentanyl | opioids | — | — | LIT×1, graf-usul×1 | 1/3 |
| oxycodone | opioids | LIT×1 | — | LIT×1, graf-usul×1 | 2/3 |
| oxymorphone | opioids | — | — | LIT×1, graf-usul×1 | 1/3 |
| protonitazene | opioids | LIT×1 | — | LIT×1, graf-usul×1 | 2/3 |
| sufentanil | opioids | — | — | LIT×1, graf-usul×1 | 1/3 |
| tapentadol | opioids | — | — | LIT×1, graf-usul×1 | 1/3 |
| tramadol | opioids | LIT×2 | — | LIT×1, graf-usul×1 | 2/3 |
| aldicarb | pesticides | — | — | LIT×1, graf-usul×1 | 1/3 |
| aluminium-phosphide | pesticides | — | — | — | 0/3 |
| brodifacoum | pesticides | — | — | LIT×1, graf-usul×1 | 1/3 |
| carbofuran | pesticides | — | — | LIT×1, graf-usul×1 | 1/3 |
| chlorpyrifos | pesticides | — | Y-TOKS×2, graf-sinama×2 | — | 1/3 |
| diazinon | pesticides | — | Y-TOKS×2, graf-sinama×2 | LIT×1, graf-usul×2 | 2/3 |
| glyphosate | pesticides | — | — | LIT×1, graf-usul×1 | 1/3 |
| malathion | pesticides | — | Y-TOKS×4, graf-sinama×2 | LIT×1, graf-usul×1 | 2/3 |
| paraquat | pesticides | — | — | LIT×1, graf-usul×1 | 1/3 |
| parathion | pesticides | — | Y-TOKS×2, graf-sinama×2 | — | 1/3 |
| strychnine | pesticides | — | Y-TOKS×1, graf-sinama×1 | LIT×1, graf-usul×2 | 2/3 |
| colchicine | pharmaceuticals | — | — | LIT×1 | 1/3 |
| digoxin | pharmaceuticals | — | — | LIT×1, graf-usul×1 | 1/3 |
| diphenhydramine | pharmaceuticals | — | Y-TOKS×5, graf-sinama×2 | LIT×1, Y-TOKS×1, graf-usul×2 | 2/3 |
| ibuprofen | pharmaceuticals | — | Y-TOKS×3, graf-sinama×2 | Y-TOKS×1, graf-usul×1 | 2/3 |
| lidocaine | pharmaceuticals | — | Y-TOKS×1, graf-sinama×1 | LIT×1, graf-usul×1 | 2/3 |
| metformin | pharmaceuticals | — | — | LIT×1, graf-usul×1 | 1/3 |
| paracetamol | pharmaceuticals | LIT×1 | — | LIT×1, graf-usul×1 | 2/3 |
| propranolol | pharmaceuticals | — | — | LIT×1, graf-usul×1 | 1/3 |
| salicylic-acid | pharmaceuticals | Y-TOKS×1 | Y-TOKS×3, graf-sinama×1 | Y-TOKS×1, graf-usul×1 | 3/3 |
| verapamil | pharmaceuticals | — | — | — | 0/3 |
| zolpidem | sedatives_hypnotics | — | — | LIT×1, graf-usul×3 | 1/3 |
| zopiclone | sedatives_hypnotics | LIT×1 | — | — | 1/3 |
| alpha-pvp | stimulants | — | — | — | 0/3 |
| amphetamine | stimulants | graf-skrining×1 | UNODC×3, Y-GMT×2, graf-sinama×2 | LIT×1, Y-GMT×1, graf-usul×2 | 3/3 |
| benzoylecgonine | stimulants | graf-skrining×1 | Y-GMT×1, graf-sinama×1 | — | 2/3 |
| cathinone | stimulants | — | — | LIT×1, graf-usul×2 | 1/3 |
| cocaethylene | stimulants | — | — | LIT×1, graf-usul×1 | 1/3 |
| cocaine | stimulants | UNODC×1, graf-skrining×1 | UNODC×3, Y-GMT×2, graf-sinama×3 | Y-GMT×2, graf-usul×2 | 3/3 |
| ephedrine | stimulants | — | Y-GMT×6, graf-sinama×3 | LIT×1, Y-GMT×1, graf-usul×2 | 2/3 |
| mda | stimulants | — | UNODC×3, Y-GMT×3, graf-sinama×2 | Y-GMT×1, graf-usul×1 | 2/3 |
| mdea | stimulants | — | UNODC×3, Y-GMT×3, graf-sinama×2 | Y-GMT×1, graf-usul×1 | 2/3 |
| mdma | stimulants | — | UNODC×3, Y-GMT×3, graf-sinama×2 | LIT×1, Y-GMT×1, graf-usul×2 | 2/3 |
| mdpv | stimulants | — | — | LIT×1 | 1/3 |
| mephedrone | stimulants | — | — | LIT×1, graf-usul×1 | 1/3 |
| methamphetamine | stimulants | graf-skrining×1 | UNODC×3, Y-GMT×3, graf-sinama×2 | LIT×1, Y-GMT×1, graf-usul×2 | 3/3 |
| methylphenidate | stimulants | — | — | LIT×1, graf-usul×1 | 1/3 |
| ammonia | toxic_gases | Y-TOKS×1 | Y-TOKS×1, graf-sinama×1 | — | 2/3 |
| carbon-monoxide | toxic_gases | — | — | LIT×1, Y-TOKS×1, graf-usul×1 | 1/3 |
| hydrogen-cyanide | toxic_gases | Y-TOKS×1 | Y-TOKS×1, graf-sinama×1 | LIT×1, graf-usul×1 | 3/3 |
| hydrogen-sulfide | toxic_gases | — | Y-TOKS×1, graf-sinama×1 | LIT×1, graf-usul×1 | 2/3 |
| nitrous-oxide | toxic_gases | — | — | — | 0/3 |
| phosphine | toxic_gases | — | Y-TOKS×1, graf-sinama×1 | — | 1/3 |
<!-- AUTO:END -->


## 4. Bu ishdan keyingi holat

| Ko‘rsatkich | Oldin | Keyin |
|---|---|---|
| «1. Test» da manbali yozuvi bor moddalar | 10 / 140 | 30 / 140 |
| «2. Sifat» | 52 / 140 | 56 / 140 |
| «3. Miqdoriy» | 111 / 140 | 124 / 140 |
| Uch bo‘limi ham to‘ldirilgan moddalar | 8 | 16 |
| Hech bir bo‘limda ma’lumoti yo‘q moddalar | 25 | 7 |

**Uch bo‘limga to‘ldirilgan 8 ta yangi modda:** sirka kislota, aminazin (xlorpromazin), fenobarbital, pentobarbital,
sekobarbital, butalbital, sianid kislotasi, mishyak(III) oksidi. (Yana 20 dan ortiq moddada bir yoki ikki bo‘lim to‘ldirildi; ro‘yxat uchun auditni ishga tushiring.)

**Eslatma — «3/3» nimani anglatadi.** Bu «kamida bitta manbali yozuv bor» degani, «bo‘lim chuqur yoritilgan» degani emas:
ko‘p moddada «3. Miqdoriy» faqat bitta abstrakt jumla (masalan, «LC-MS/MS usuli qo‘llangan») va moddaga umumiy graf
bog‘lanishi (`analysed_by`, ba’zilari jumlada moddalar birga tilga olinganiga asoslangan). Parametrlar (namuna tayyorlash,
LOD/LOQ, iyon/RT) faqat yuqorida sanalgan ~15 modda uchun, manbada bor bo‘lgani qadar keltirilgan.

## 5. Manba yetishmasligi sababli bo‘sh qolganlar — egasi nimani berishi kerak

1. **Kravchenko kitobi** (nomi, nashr yili, fayl) — hozir repoda yo‘q. «1. Test» (110 modda bo‘sh) va «2. Sifat» (84 modda bo‘sh)
   uchun asosiy kutilgan manba. Kerakli boblar: ekspress-diagnostika / test-chiziqlar; rangli (cho‘ktiruvchi va rang beruvchi)
   reaktivlar jadvali: opioidlar, benzodiazepinlar, stimulyatorlar, kannabinoidlar, antidepressantlar va antikonvulsantlar
   (karbamazepin, fenitoin, valproat, lamotrigin, gabapentin), sintetik opioidlar (fentanil analoglari, nitazenlar).
2. **Yuldashev, Umarova «Toksikologik kimyo» (2025)** — shu majmuada quyidagi moddalar umuman yo‘q (matn bo‘yicha qidirildi):
   paratsetamol, karbamazepin, fenitoin, digoksin, metformin, kolxitsin, verapamil, izopropanol, glifosat, levamizol;
   paraquat faqat sinflashda tilga olingan (150-b.). Ularning boblari boshqa kitobda bo‘lsa, fayl va bo‘lim kerak.
   Majmuada bor, lekin ilovada modda yozuvi yo‘q: diuretiklar (furosemid, gidroxlortiazid, atsetazolamid — 137, 253–255-b.),
   NSAID (diklofenak, indometatsin, ketoprofen, piroksikam — 139-b.), sulfanilmochevina hosilalari. Ularni qo‘shish
   «yangi modda» bo‘lgani uchun feature-freeze doirasida egasi qarorini kutadi.
3. **«3. Miqdoriy» uchun instrumental parametrlar (GC-MS / LC-MS/MS: m/z, RT, LOD/LOQ, namuna tayyorlash)** — 16 ta modda
   hali bo‘sh (difluoroetan, alfentanil, loperamid, aluminiy fosfid/fosfin, verapamil, α-PVP, zopiklon, azot oksidi,
   ammiak, xlorpirifos, paration, benzoilekgonin, etonitazen, metonitazen, levamizol …), qolganlarida esa 1–2 jumla.
   Ochiq manbalar (uydirmasdan, keyingi bosqichda o‘qib kiritish mumkin; egasi ruxsati talab qilinmaydi): UNODC
   «Recommended methods for the identification and analysis of …» (fentanil va analoglari, amfetamin guruhi, kokain, opiatlar,
   kannabis, sintetik kannabinoidlar), SWGDRUG monografiyalari (spektrlar) va Part IIIA/IIIB, ENFSI/ISO 17025 yo‘riqnomalari,
   CC BY tadqiqotlar (PMC). Laboratoriyaning o‘z SOP/validatsiya hujjati bo‘lsa — u eng ishonchli manba.
4. **Ilmiy reviewer** — barcha yangi yozuvlar `NEEDS_REVIEW`; tasdiqsiz «tasdiqlangan» deb ko‘rsatilmaydi.

## 6. Sinov holati (halol)

- Bajarilgan: `flutter analyze` (xatosiz); `translation_qa.py` (0 xato); `claim_source_audit.py --check`; `build_pack`
  (validator, 0 ogohlantirish); vidjet testlari haqiqiy pilot paketda (390 va 320 dp), o‘zbek va rus tilida.
- **Bajarilmagan:** haqiqiy telefonda (iOS/Android) STUDENT va EXPERT rollarida qo‘lda sinov; internet o‘chganda xatti-harakat;
  haqiqiy backend. Bu ish davomida ilova qurilmada ishga tushirilmadi — «sinadim» deb yozilmaydi.
- Ma’lum cheklov: ABY olib tashlanayotgan `claude/remove-aby` bilan `substance_analysis_section.dart` da birlashtirish
  konflikti bo‘lishi mumkin (ABY bloki o‘z holicha qoldirilgan, atrofi qayta tuzilgan).
