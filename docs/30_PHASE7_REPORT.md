# 30 — PHASE 7: Verified scientific content & professional knowledge pipeline — hisobot

**Branch:** `claude/phase-7-verified-content-pipeline` (PHASE 6 `8f19367` ustiga). main’ga merge qilinmagan, PR ochilmagan, history qayta yozilmagan. Kontent paketi `2026.10.5`, DB schema **v6**, bundle `fe-bundle/4`, kanal `development`.

> ## HUMAN VERIFIED = 0
> PHASE 7 da hech qanday malakali inson reviewer qatnashmadi. Reviewer ro‘yxati bo‘sh, review harakatlari 0, VERIFIED 0, REVIEWED 0. Bu kutilgan holat, xato emas.

Batafsil: `docs/26` (pipeline), `docs/27` (review workflow), `docs/28` (RG-25), `docs/29` (RG-18, RG-20).

## 1. Pipeline
Source → archive/metadata → claim → structured → linkage → review → translation → validation → package → search → UI → update/rollback; har bosqichning kodi va isboti `docs/26` 1-bo‘limda.

## 2. Pilot tanlovi (17 modda + 5 metabolit yozuvi)
Etanol, metanol, izopropanol (spirtlar — eng ko‘p uchraydigan tekshiruv); morfin, geroin, fentanil, metadon, tramadol (opioidlar, jumladan sintetik va O‘zbekiston amaliyotida dolzarb tramadol); kokain, amfetamin, metamfetamin, MDMA (stimulyatorlar); diazepam, alprazolam (benzodiazepinlar); pregabalin (noqonuniy foydalanish ortgan); THC (kannabinoid); izotonitazen (NPS/nitazen). Metabolitlar: 6-MAM, benzoilekgonin, THC-COOH, 11-OH-THC, nordiazepam. Mezon: forensik amaliyotdagi chastota, turli sinflar, PHASE 5 da mavjud ochiq manbali dalil.

## 3. Manba ierarxiyasi
A (rasmiy/standart) 8 · B (peer-reviewed) 306 · C (ma’lumotlar bazasi/ikkilamchi) 137. Qayta foydalanish holati har manbada; himoyalangan asarlar — LICENSE REQUIRED.

## 4. Manba metadata
Tier, til, qayta foydalanish, SHA-256 (yuklangan fayllar), versiya, hayot sikli va uning asosi, tekshirilgan sana, forensik dolzarblik (reviewer belgilaguncha `unassessed`).

## 5. Claim provenance
Har claim: manba, joy, asl jumla (faqat ochiq litsenziyada), dalil darajasi, versiya, review holati, hisoblangan hayot sikli, ziddiyatlar. Ilovada bitta bosishda.

## 6. Konsentratsiya konteksti
14 pilot claim qo‘lda (iqtibosdan; aytilmagani `not_stated`), 40 tasi `auto_minimal`. 7 tasi «boshqa tadqiqotdan iqtibos» deb belgilandi. Metadon yorlig‘idagi xato tuzatildi va qayd etildi. Hech qanday qiymat chegara sifatida ko‘rsatilmaydi.

## 7. Metabolitlar
24 munosabat (12 ota modda): faol 5, nofaol 1, rolsiz 18. Rol faqat iqtibosda aytilganda (FE036 tekshiradi).

## 8. Namunalar
12 namuna turi (qon, zardob/plazma, siydik, vitreous, og‘iz suyuqligi, soch, oshqozon tarkibi, jigar, o‘t, buyrak, bosh miya, LCS); 6 ta yangi PMC OA claim; 64 `measured_in` bog‘lanish. Jigar va oshqozon uchun mos manba topilmadi — rad sabablari `phase7/curation_p7.json`.

## 9. Ekspress testlar
7 `screened_by` + 2 yangi `confirmed_by` (umumiy immunoassay → GC-MS, LC-MS/MS) bog‘lanish; skrining ≠ tasdiqlash (CRITICAL).

## 10. Reagentlar
Yangi retsept qo‘shilmadi — ochiq manbali retsept topilmadi; to‘qilmadi.

## 11. Metodlar
18 metodning barchasi «nashr etilgan ilmiy metod — laboratoriya uchun validatsiya qilingan SOP emas» banneri bilan; standart/milliy/SOP turlari alohida (`MethodKind`).

## 12. Sud tibbiyoti
Rigor mortis (yangi manbali ta’rif), algor mortis (ta’rif manbasi RETRACTED; yangi cheklov claim’i), livor mortis, o‘limdan keyingi o‘zgarishlar, PMI, to‘mtoq jarohat terminologiyasi, chirish.

## 13. Biokimyo
Vitreous kaliy (+ ziddiyat), vitreous glyukoza, etanol neoformatsiyasi, kokain barqarorligi, namuna olish joyi — mavjud manbali claim’lar review paketlarida.

## 14. Standartlar katalogi
7 yozuv: ICH Q2(R2), ICH Q2(R1) → superseded, UNODC ST/NAR/41, ANSI/ASB 056-25, ANSI/ASB 017-25, ANSI/ASTM E2329-25, OSAC 2025-S-0010 (proposed). Faqat metadata.

## 15. Yurisdiksiya pilot
GB 12 · US 14 · DE 12 qoida (rasmiy matnda aniq yozuv mosligi); UZ — qonun yozuvi, ro‘yxatlar xaritalanmagan. Hammasi NEEDS LEGAL REVIEW; «topilmadi» ≠ «nazorat qilinmaydi».

## 16. Review paketlari
146 paket (tox 71, lab 20, fm 9, biokimyo 6, legal 40); 6 tasida ziddiyat, 1 tasida retraksiya. Navbat 881.

## 17. Reviewer harakatlari va rollari
5 harakat, 7 rol, ruxsat matritsasi, versiyaga bog‘lanish, izoh majburiyati, soxta reviewer’ga to‘siq — kod, DB CHECK va validator (FE039). Harakatlar soni: **0**.

## 18. Ziddiyat va hayot sikli
4 ochiq ziddiyat (vitreous K⁺/PMI, metadon, fentanil, tramadol M2). Hayot sikli: NEEDS_REVIEW 489, RETRACTED 1, CURRENT 0.

## 19. Tarjima, qidiruv, graf, UI
20 termin (7 tasi tarjima qilinmaydi); qidiruv namuna (EN/RU/UZ) va standart belgilanishi bo‘yicha; bilim zanjiri ekrani; provenance oynasi, ziddiyat/retraksiya banner’lari, namuna, ziddiyat, zanjir, review holati ekranlari; 139 yangi lokalizatsiya kaliti (RU/UZ — machine_draft, RG-11).

## 20. RG-25 / RG-18 / RG-20
* RG-25: koeffitsientlar Q2(R2) da o‘zgarmagan, havola yangilandi — **ochiq** (lab reviewer).
* RG-18: server arxitekturasi + 10 test, **faqat mock** — **ochiq, SECURITY**.
* RG-20: Gradle imzo konfiguratsiyasi va himoya tekshirildi; keystore yo‘q — **ochiq**.

## 21. Tekshiruvlar

| Tekshiruv | Natija |
|---|---|
| `flutter analyze` / `dart analyze` (`--fatal-infos`) | ✅ No issues |
| Testlar | ✅ **1157 PASS · 0 FAIL · 1 SKIP** (ilova 915; paketlar 242: schema 115, calc 32, package 15, pipeline 23, database 26, search 21, purchase_verification 10) |
| Yangi PHASE 7 testlari | schema 18, purchase 10, ilova widget/kontent 24, perf 3, golden 24 |
| Kontent validator | ✅ development — 0 xato |
| Golden | ✅ 112 kadr (24 yangi; eskilari provenance UI uchun qayta yaratildi) |
| Screenshotlar | `docs/screenshots/phase7/` — 24 ta (EN/RU/UZ, light/dark, 320 dp ×1.3) |
| Perf (host VM, qurilma emas) | cold start 0.97 s; provenance yuklash 55 ms; qidiruv median 54 ms; modda 0.76 s; provenance oynasi 0.27 s — `docs/perf/phase7_raw.txt` |
| gitleaks / OSV | ✅ leak yo‘q / 132 paketda zaiflik yo‘q |
| Release APK | ✅ qurildi (71.2 MB); ⚠️ debug imzo (RG-20); store’ga yuborilmagan |
| iOS | ⛔ Xcode yo‘q — real build bajarilmagan (RG-24) |
| Real qurilma | ⛔ tekshirilmagan (RG-10) |

## Hujjatlashtirilgan test o‘zgarishlari
FM qamrovi 17 → 18/25; DE endi pilot hujjatiga ega — «kontentsiz davlat» testi FR ga o‘tdi; INT qoidalari alohida filtrlanadi (GB/US/DE qo‘shildi); LOD/LOQ havolasi Q2(R2); graf testiga yangi tugunlar; `metKindMarker` paritet ro‘yxatida; eski oltin rasmlar provenance tugmasi tufayli yangilandi.

## Ochiq release blokerlar
RG-18 (SECURITY), RG-20, RG-10, RG-24, RG-19/21/23, RG-11, RG-06, RG-22, RG-08, RG-15, RG-16, RG-25 — hech biri yopilmadi.
