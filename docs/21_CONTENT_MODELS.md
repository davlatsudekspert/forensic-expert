# 21 — Kontent modellari: Reagent/Eritma, Ekspress test, Sud biokimyosi, Metod / SOP / Standart

Barcha modellar `fe_content_schema` da; har bir qiymat — **faqat manba bilan** (`SourcedValue`, `SourcedNote`). Bo‘sh maydon UI’da «MA’LUMOT TEKSHIRILMAGAN — EKSPERT TASDIG‘I KERAK» yoki «manbada ko‘rsatilmagan — taxmin qilinmadi». Har bir tur uchun **kontent shabloni** (`ContentTemplates`) bor: UI qaysi bo‘limlar manbali ekanini «Manbali bo‘limlar: N / M» deb ko‘rsatadi, qolganini bitta qatorda sanaydi — hech narsa to‘qilmaydi.

## 1. Reagent va eritmalar (`SolutionRecipe`)

| Talab | Model | Holat |
|---|---|---|
| nom, sinonim | `names`, (kelajak: synonyms jadvali) | ✅ |
| grade / tozalik | `Ingredient` matni manbadagidek; tozalik kalkulyatorda foydalanuvchi kiritadi | ⚠️ alohida maydon rejada |
| maqsad | `purpose`, claim `use_context` | ✅ |
| bog‘liq metod / test | `associatedMethodIds`, graf `used_in` | ✅ |
| kimyoviy moddalar, konsentratsiya, birlik | `ingredients[] (amount, unit, source)` | ✅ |
| formula / kalkulyator bog‘lanishi | `fe_calc_engine` (C1V1=C2V2, massa, molyarlik, foiz) — **ilmiy qo‘llanishdan alohida** | ✅ |
| tayyorlash tartibi | `steps[]` + `orderExplicitInSource` (tartib faqat manba aytsa) | ✅ |
| saqlash, barqarorlik, yaroqlilik | `storage`, `temperature`, `stability` | ✅ (manba bo‘lsa) |
| xavfsizlik, utilizatsiya, QC | `hazards`, `disposalReference`, `qcRequirement` | ✅ |
| manba, metod/SOP manbasi, review, versiya | `sourceIds`, `status`, `version` | ✅ |

**Qat’iy qoida:** retsept, nisbat, konsentratsiya va yaroqlilik muddati to‘qilmaydi (FE018–FE020). Retsept VERIFIED/PUBLISHED bo‘lishi uchun qabul qilingan metod/SOP/ilmiy manba + reviewer workflow shart. Hozir: Dragendorff — manbali tarkib (4 ingredient), qolganlarida retsept yo‘q.

## 2. Ekspress / skrining testlari (`ScreeningTest`)

Texnologiya (`principle`), nishon analit/sinf, namuna, cutoff / sezgirlik / o‘ziga xoslik (**faqat ishonchli manba bo‘lsa**, `SourcedValue`), kesishgan reaktivlik, interferensiya, soxta musbat/manfiy sabablari, cheklovlar, talqin, tasdiqlovchi metod (`confirmatoryMethodIds`, majburiy — FE021), ishlab chiqaruvchiga xos (`manufacturer`, `model`) vs umumiy ilmiy ma’lumot, manba, dalil va review holati.

**SKRINING ≠ TASDIQLANGAN IDENTIFIKATSIYA** — CRITICAL banner; `supportsDefinitiveIdentification` faqat avtoritet manba bilan (FE023).

## 3. Sud biokimyosi (biomarker shabloni)

Bo‘limlar: marker · namuna · namuna olish sharoiti · o‘limdan keyingi cheklovlar · barqarorlik · analitik metod · talqin cheklovlari · tadqiqotlar. **Esdan olingan referens diapazon yoki diagnostik chegara kiritilmaydi**; postmortem PMI formulasi yo‘q. Pilot: 16 mavzu, 17 claim (barchasi NEEDS_REVIEW).

## 4. Metodlar / SOP / Standartlar

`MethodKind` (4 qatlam, aralashtirilmaydi — FE024): ilmiy metod · xalqaro standart · milliy metod · institut SOP. Hujjat turi `DocumentKind`: STANDARD / GUIDELINE / METHOD / SOP / LAW / REGULATION / SCIENTIFIC ARTICLE / OFFICIAL DOCUMENT; `BindingNature` — har bir qo‘llanma qonuniy majburiy emas.

Metod sahifasi shabloni: prinsip · forensik qo‘llanish · namunalar · namuna tayyorlash · asbob-uskunalar · sifat/miqdoriy qo‘llanish · validatsiya talablari · interferensiya · cheklovlar · QC · bog‘liq moddalar · bog‘liq reagentlar · tadqiqotlar. Texnikalar: TLC, GC, GC-FID, headspace GC, GC-MS, **GC-MS/MS**, HPLC, **LC-MS**, LC-MS/MS, **HRMS**, UV-Vis, **spektrofotometriya**, immunoanaliz. **Ma’lumotnoma tasdiqlanmagan laboratoriya SOP’iga aylantirilmaydi**; GC-MS/LC-MS/MS parametrlari (ion, MRM, harorat dasturi) manbasiz kiritilmaydi.

Library → «Standartlar va rasmiy hujjatlar»: ilmiy bo‘lmagan metodlar + rasmiy hujjatlar, har biri turi va majburiyligi bilan.

## 5. Laboratoriya kalkulyatorlari (`fe_calc_engine`)

INPUT → UNITS → METHOD → FORMULA → CALCULATION → RESULT → LIMITATIONS → REFERENCES.

| Vosita | Engine ID | Asos |
|---|---|---|
| Suyultirish C1V1=C2V2 | `lab.dilution.c1v1` | ta’rif |
| Eritma uchun massa | `lab.solution.mass_required` | ta’rif |
| Molyarlik (tortilgan massadan) | `lab.molarity.from_mass` | ta’rif |
| Foizli eritma (w/v, v/v, w/w) | `lab.percent.solute_amount` | ta’rif |
| Konsentratsiya birliklari, massa ↔ molyar | `lab.concentration.convert` | SI prefikslari, ρ = c·M |
| Tavsifiy statistika (o‘rtacha, mediana, SD n−1, CV%) | `stats.descriptive` | ta’rif |
| Chiziqli regressiya (OLS, s_y/x) | `stats.linear_regression` | ta’rif |
| LOD / LOQ | `stats.lod_loq.ich` | **ICH Q2(R1) §6.3, §7.3** — DL = 3.3σ/S, QL = 10σ/S (rasmiy PDF matni bilan tekshirildi; Q2(R2) bilan moslik — reviewer) |

Hech qanday tibbiy/forensik koeffitsient manbasiz kodlanmagan (`reyestr` testi: ta’rifiy bo‘lmagan formula manbasiz bo‘lishi mumkin emas). Widmark, back-calculation, Henssge PMI — **rejalashtirilgan**, manba va reviewersiz yoqilmaydi. Molekulyar massa kalkulyatori — atom massalari jadvali (IUPAC/CIAAW) provenance bilan kiritilmaguncha rejada.
