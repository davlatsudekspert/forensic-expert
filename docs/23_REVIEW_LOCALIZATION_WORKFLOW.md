# 23 — Kontent review va lokalizatsiya workflow’i

## 1. Kontent pipeline (isbotlangan zanjir)

```
SOURCE → INGESTION → CLAIM → PROVENANCE → REVIEW → TRANSLATION → SEARCH → DISPLAY → UPDATE → ROLLBACK
```

| Bosqich | Qayerda | Isbot |
|---|---|---|
| Source | `content/tools/p5/*` (PubChem, INCB PDF, PMC BioC, PubMed, Crossref, Europe PMC), kesh SHA-256 bilan | `content/phase5/*` |
| Ingestion / curation | `curate.py` + qo‘lda rad etish sabablari | `rejected_*.json`, `research_rejected.json`, `claims_rejected_assembly.json` |
| Claim + provenance | `assemble_pilot.py` → `bundle.json` (manba, locator, asl jumla, litsenziya) | validator FE001–FE032 |
| Review | `content/review/queue.json` — 835 element, rollar; muallif o‘z claim’ini tasdiqlay olmaydi (`StatusResolver`) | `status_resolver` testlari |
| Translation | nomlar `machine_draft`; UI ARB EN/RU/UZ | `arb_parity_test`, `rendered_language_audit_test` |
| Search | `fe_search_core` (FTS trigram + fuzzy, EN/RU/UZ, transliteratsiya) | `phase6_test` (Methamphetamine/Метамфетамин/Metamfetamin) |
| Display | provenance kartochkasi, review holati, dalil darajasi | widget testlari |
| Update | imzolangan paket (`fe_content_package`), CalVer, downgrade/replay himoyasi; FE027 — review qilingan ma’lumot jimgina almashtirilmaydi | `content_package_test`: «o‘rnatish, yangilash va rollback» |
| Rollback | oldingi faol paketga qaytish; sog‘lomlik tekshiruvidan o‘tmagan paket faol bo‘lmaydi | o‘sha test guruhi |

Production kanali review’dan o‘tmagan kontentni rad etadi (hozir 576 × FE008 — kutilgan).

## 2. Review rollari

scientific · analytical · medicine_histology · legal · translation (`REVIEW_QUEUE.md`). Talab: ilmiy/analitik/tibbiy — 2 ta mustaqil review (four-eyes), legal va translation — 1 ta. Review versiyaga bog‘lanadi; yozuv o‘zgarsa review qayta talab qilinadi.

## 3. Lokalizatsiya

* UI: `lib/core/l10n/arb/app_{en,ru,uz}.arb`; PHASE skriptlari (`tool/l10n_phase*.py`) — kalitlar tarixini saqlaydi. Yangi til qo‘shish: yangi ARB + `SupportedLanguages`; kontent nomlari `names` xaritasida istalgan tilni qabul qiladi.
* **Avtomatik audit (PHASE 6):** `rendered_language_audit_test` RU va UZ tilida 22 ta ekranni chizadi va ekrandagi har bir UI matnini inglizcha ARB qiymatlari bilan solishtiradi — tasodifiy «Home / Tools / Library» qolsa, test yiqiladi.
* **Ataylab bir xil qoldirilgan (hujjatlashtirilgan):** brend (FORENSIC EXPERT, «Lifetime»), xalqaro qisqartmalar (DOI, PMID, GC-MS, LC-MS/MS, HPLC, SOP, R², n), ICH hujjat nomi, raqamli oraliqlar.
* **Kontent tili** (UI emas): ilmiy maqola sarlavhalari, asl iqtiboslar, rasmiy hujjat sarlavhalari manba tilida qoladi — tarjima qilinsa, ma’nosi buzilishi va mualliflik huquqi masalasi bor. Rasm sarlavhalari va alt matnlar RU/UZ ga o‘girildi (machine_draft).
* Sanalar har doim yil bilan, lokal formatda (`feDate`).
* Barcha RU/UZ matnlar — **mashina qoralamasi**; professional terminologik review — release gate **RG-11**.
