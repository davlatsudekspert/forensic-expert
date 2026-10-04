# 26 — PHASE 7: tasdiqlanadigan ilmiy kontent pipeline’i

> Holat: **pipeline va pilot tayyor, HUMAN VERIFIED = 0.** Hech bir yozuv VERIFIED/REVIEWED emas — malakali reviewer qatnashmagan. Bu kutilgan holat.

## 1. Zanjir

```
SOURCE → ARCHIVE/METADATA → CLAIM → STRUCTURED VALUE → LINKAGE → REVIEW
       → TRANSLATION → VALIDATION → PACKAGE → SEARCH → UI → UPDATE/ROLLBACK
```

| Bosqich | Qayerda | Nima kafolatlanadi |
|---|---|---|
| Source | `content/tools/p5/*`, `content/tools/p7/fetch_legal.py`, `find_p7_sentences.py` | Faqat rasmiy API/sayt: PMC BioC, PubMed eutils, legislation.gov.uk, eCFR, gesetze-im-internet.de, lex.uz, ICH, UNODC, NIST OSAC registri |
| Archive/metadata | `phase7/legal.json`, `sources[*]` | SHA-256 (yuklangan fayl uchun), versiya, tekshirilgan sana, til, litsenziya |
| Lifecycle | `phase7/retraction_check.json` | 1056 PMID `Retracted Publication[pt]` bo‘yicha tekshirildi → 1 ta retraksiya |
| Claim | `assemble_p7.py` | Asl jumla (faqat ochiq litsenziyada), bo‘lim, manba; qabul/rad qarorlari sabab bilan (`phase7/curation_p7.json`) |
| Structured | `context_strict`, `metabolite_relations` | Iqtibosda yo‘q maydon `not_stated`; rol faqat matnda aytilganda |
| Linkage | `links` (`has_metabolite`, `measured_in`, `screened_by`, `standard_for`, `legal_status`) | Har bir qirra asosi: claim / qoida / standart / munosabat ID (FE037) |
| Review | `review/packets/`, `review_actions` | Paketlar tayyor; harakatlar = 0 |
| Translation | `term_translations`, ARB | DOI/PMID/formula/qisqartma tarjima qilinmaydi (FE040); RU/UZ — machine_draft |
| Validation | `ContentValidator` FE001–FE041 | Development: 0 xato; production: FE008 (review yo‘q) |
| Package | `tool/update_bundled_pack.sh` | Imzolangan `content.db` (schema v6, paket `2026.10.5`) |
| Search | `AppSearchService` | Namunalar (EN/RU/UZ + variantlar), standart belgilanishlari |
| UI | provenance oynasi, banner’lar, ekranlar | Provenance bitta bosishda |
| Update/rollback | `fe_content_package` | FE027: ko‘rib chiqilgan ma’lumot jimgina almashtirilmaydi |

## 2. Manba ierarxiyasi (Tier A/B/C)

| Tier | Manba sinfi | Misol |
|---|---|---|
| **A** | rasmiy birlamchi matn; xalqaro standart / rasmiy qo‘llanma | INCB ro‘yxatlari, UK MDA 1971, 21 CFR 1308, BtMG, lex.uz qonuni; ICH Q2(R2), UNODC ST/NAR/41 |
| **B** | peer-reviewed nashr | PMC OA maqolalar |
| **C** | qo‘llanma, ma’lumotlar bazasi, ikkilamchi | PubChem |
| — | blog, forum, AI matni | dalil emas (FE017) |

`SourceHierarchy.of(SourceClass)` — deterministik; bazada `source_provenance.hierarchy` (A 8 · B 306 · C 137).

**Qayta foydalanish holati** (`reuse_status`): OPEN_REUSE · CITE_ONLY · NON_COMMERCIAL · **LICENSE_REQUIRED** · LOOKUP_ONLY · UNKNOWN. Iqtibos matni faqat OPEN_REUSE da. Himoyalangan asarlar (Clarke’s, Baselt, ASB/ASTM/ISO standartlari, litsenziyali bazalar) — faqat metadata, LICENSE REQUIRED.

## 3. Claim darajasidagi provenance

Har bir claim: manba(lar), joy (bo‘lim/locator), asl jumla, dalil darajasi, versiya, review holati, **hisoblangan hayot sikli**, ziddiyatlar. Ilovada: claim kartochkasidagi **«Bu ma’lumot qayerdan?»** → provenance oynasi (tier, litsenziya, retraksiya tekshiruvi sanasi, arxiv SHA-256, PMID/DOI, kerakli reviewer roli, review harakatlari soni, «MA’LUMOT TEKSHIRILMAGAN — EKSPERT TASDIG‘I KERAK»).

## 4. Hayot sikli

`ClaimLifecycleResolver` (qo‘lda belgilanmaydi): **REJECTED > RETRACTED > SUPERSEDED > OUTDATED > CURRENT > NEEDS_REVIEW**.

* Bitta manba retraksiya/withdrawn → RETRACTED (sabab va manba ID’lari `claim_lifecycle.caused_by_json`).
* Barcha manbalar almashtirilgan → SUPERSEDED.
* CURRENT faqat REVIEWED/VERIFIED dan — hozir **0**.
* `ClaimLifecycleResolver.dependentClaims(sourceId, citations)` — manba holati o‘zgarsa, bog‘liq claim’lar ro‘yxati.
* FE034: retraksiya/almashtirilgan manbali claim publishable deb e’lon qilinsa — build to‘xtaydi.

**Real holat:** PMID 39575351 (SRC-PMC11580817, Cureus 2024; retraksiya xabari: Cureus 2025;17(1):r156, PMID 39791019) → `C-FM-ALGOR-MORTIS-DEFINITION` RETRACTED. Claim o‘chirilmadi (shaffoflik), CRITICAL banner bilan ko‘rsatiladi. Algor mortis uchun boshqa (retraksiyasiz) manbadan **cheklov** claim’i qo‘shildi; yangi ta’rif manbasi topilmaguncha ta’rif yo‘q.

## 5. Qat’iy konsentratsiya konteksti (FE033)

Majburiy kalitlar: namuna (ID), sampling (post/ante-mortem), sub’ekt (vafot etgan/tirik), populyatsiya, holatlar soni, holat turi, birga aniqlangan moddalar, analitik metod, vaqt, statistika, ma’lumot kelib chiqishi (birlamchi / boshqa tadqiqotdan iqtibos), cheklovlar.

* 14 ta pilot claim **qo‘lda** iqtibos matnidan to‘ldirildi; aytilmagan — `not_stated` (UI: «manbada ko‘rsatilmagan»).
* Qolgan 40 ta — `auto_minimal` (faqat namuna; `reporting: not_assessed`).
* Topilgan xato tuzatildi va qayd etildi: metadon claim’ining P5 yorlig‘i «clinical intoxication» edi, iqtibos esa o‘lim holatlari haqida (`context_label_correction`).
* 7 ta claim **boshqa tadqiqotdan iqtibos** (secondary_citation) deb belgilandi — ular birlamchi ma’lumot sifatida ko‘rsatilmaydi.
* Hech qanday qiymat chegara emas: «fatal/lethal» toifasi taqiqlangan (FE007), CRITICAL banner.

## 6. Ziddiyatlar («EVIDENCE CONFLICT»)

Turlar: `direct_contradiction`, `context_dependent`, `value_overlap`, `inconsistent_characterisation`. Ilova hech qachon «g‘olib» tanlamaydi; holat faqat reviewer harakati bilan o‘zgaradi (FE035).

| ID | Tur | Mazmun (faqat iqtiboslar) |
|---|---|---|
| CF-VITREOUS-K-PMI | context_dependent | K⁺ PMI bilan chiziqli o‘sadi ↔ harorat ta’siri nomuvofiq, chalkashtiruvchi omil |
| CF-METHADONE-PM-VS-LIVING | value_overlap | o‘limdagi o‘rtacha 503 ng/mL ↔ tirik MMT bemorlari 400–1000 ng/mL |
| CF-FENTANYL-INCIDENTAL | value_overlap | tabiiy o‘limda tasodifiy fentanil 2.7–33 ng/mL — fentanil o‘limlari bilan qisman ustma-ust |
| CF-TRAMADOL-M2-ACTIVITY | inconsistent_characterisation | bir manba faqat M1 ni «faol» deydi, ikkinchisi M1 va M2 ni |

To‘g‘ridan-to‘g‘ri qarama-qarshilik pilotda **topilmadi** — sun’iy yaratilmadi.

## 7. Metabolitlar, namunalar, skrining

* 24 metabolit munosabati (17 pilot moddadan 12 tasi). Rol: «faol» 5, «nofaol» 1 (THC-COOH — «psychoinactive»), qolgani rolsiz «metabolit». FE036 rolni iqtibos matnida tekshiradi. Ataylab yo‘q: izotonitazen (iqtibos aniq emas), MDMA (faqat umumiy konjugatlar), pregabalin (ahamiyatsiz metabolizm), 6-MAM «marker» (iqtibosda «marker» so‘zi yo‘q).
* 12 namuna (qon, zardob/plazma, siydik, vitreous, og‘iz suyuqligi, soch, oshqozon tarkibi, jigar, o‘t, buyrak, bosh miya, LCS); 6 tasiga yangi PMC OA claim, 64 `measured_in` qirrasi.
* Skrining: 7 `screened_by` qirrasi (asos — claim matnida ikkalasi tilga olingan); skrining ≠ tasdiqlash (CRITICAL banner, FE021).
* Metodlar: barcha 18 metod — «nashr etilgan ilmiy metod, laboratoriya uchun validatsiya qilingan SOP emas» banneri.
* Reagentlar: yangi retsept **qo‘shilmadi** (manbali ochiq retsept topilmadi; to‘qilmaydi).

## 8. Standartlar katalogi (faqat metadata)

ICH Q2(R2) (amaldagi) · ICH Q2(R1) (almashtirilgan → Q2(R2)) · UNODC ST/NAR/41 · ANSI/ASB 056-25 · ANSI/ASB 017-25 · ANSI/ASTM E2329-25 (LICENSE REQUIRED) · OSAC 2025-S-0010 (**proposed**, SDO’da ishlab chiqilmoqda). Manba: nashriyot PDF yoki NIST OSAC registri sahifasi, 2026-10-04. ISO 17025 va ASB 036 **kiritilmadi** — rasmiy sahifa tekshirib bo‘lmadi (403 / JS-challenge).

## 9. Yurisdiksiya pilot (NEEDS LEGAL REVIEW)

| Davlat | Rasmiy manba | Natija |
|---|---|---|
| GB | legislation.gov.uk — MDA 1971 Sch. 2 (OGL v3.0) | 12 modda (A/B/C sinf) |
| US | eCFR 21 CFR 1308.11–.15 (2026-10-01 holati) | 14 modda (I–V) |
| DE | gesetze-im-internet.de — BtMG Anlagen I–III | 12 modda |
| UZ | lex.uz/docs/86028 — Qonun № 813-I (1999-08-19) | qonun yozuvi; ro‘yxatlar alohida Vazirlar Mahkamasi hujjatida — **xaritalanmagan** |

Faqat ro‘yxat yozuvi aniq mos kelsa qoida yaratiladi; **«topilmadi» ≠ «nazorat qilinmaydi»** (generik bandlar baholanmaydi). DE/US hujjatlarida kuchga kirish sanasi yozilmagan — `effective_from` = olingan konsolidatsiyalangan matn sanasi, bu ochiq aytilgan. Qonun loyihalari (masalan UZ ПЗ-246) kuchga kirmagan — kiritilmadi.

## 10. Bilim grafigi zanjirlari

Modda → metabolit → namuna → skrining → tasdiqlovchi metod → reagent → tadqiqot → standart → huquqiy holat (`KnowledgeChainScreen`). Har bir qadamda asos ID’si; bosilsa — provenance oynasi. FM mavzu → namuna → biokimyo → tadqiqot: `related_topic` (editorial taksonomiya, alohida belgilangan) + `measured_in`/claim’lar orqali.

## 11. Tarjima

`term_translations`: 13 termin (machine_draft RU/UZ) + 7 tarjima qilinmaydigan (LC-MS/MS, GC-MS, 6-MAM, THC-COOH, DOI, PMID, C17H19NO3). Iqtiboslar, qonun matnlari, standart sarlavhalari asl tilda (`locale: en`).

## 12. Raqamlar (paket 2026.10.5)

Moddalar 137 · claim 490 (+8) · manba 451 · rasmiy hujjat 8 · qoida 98 (+38) · namuna 12 · metabolit munosabati 24 · ziddiyat 4 · standart 7 · termin 20 · graf qirrasi 1031 · review paketi 146 · review navbati 881 · **review harakati 0 · reviewer 0 · VERIFIED 0 · REVIEWED 0 · RETRACTED 1**.
