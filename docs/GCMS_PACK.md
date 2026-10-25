# GC-MS apparat sxemasi (LabGuide paketi, 2026-10-25)

Egasi bergan `labguide_gc_pack.zip` ilovaga joylandi.

* **Qayerda:** Vositalar → «GC-MS apparat sxemasi» (faqat **Mutaxassis** rejimi) → `/tools/gc-ms`.
  Rasm bosilsa — to‘liq ekran (zoom/pan), «sxematik tasvir — aniq model emas» izohi bu yerda ham doim ko‘rinadi.
  Rasm ostida izoh va eslatma har doim ko‘rinadi; «Qismlar va ishlash tamoyili» paneli yig‘iladigan (1–10 qism, tamoyil, natija).
* **Matnlar** (nom, vazifa, tamoyil, natija, izoh) JSON’dan uch tilda **o‘zgartirilmasdan** (`assets/content/instruments/gc_ms/`).
  Interfeys yorliqlari — `tool/l10n_gcms.py`.
* **Manbali jumla:** faqat «sud-tibbiy toksikologiya va dori vositalarini aniqlashda qo‘llanadi» (karta `a3-tox-gc-ms`, manba
  `a3-statpearls-ms` — StatPearls «Mass Spectrometer» (Garg, Zubair), NCBI Bookshelf NBK589702, so‘nggi yangilanish 2024-11-22).
  **Boshqa sud-ekspert mazmuni qo‘shilmagan** (cut-off, validatsiya, hosilalash, ish tartiblari yo‘q — `NEEDS_SOURCE`).
* **Holat:** qismlarning ko‘pi darslik darajasida — `NEEDS_EXPERT` (ekspert tekshiruvi kutilmoqda; ekranda chip bilan ko‘rinadi, o‘zimiz olib tashlamaymiz).
* **Rasm:** original sinf sxemasi (LabGuide generatori, 2026-10-25), ishlab chiqaruvchi fotosurati emas, aniq model emas.

## Yaxlitlik (SHA-256; testda tekshiriladi — `test/unit/gcms_content_test.dart`)
| Fayl | SHA-256 |
|---|---|
| `mass_spec_gc_1200.png` | `d03a2586aac8dad6527e1522400e39f01370a6e2ba799750dd4bac996882880f` |
| `mass_spec_gc_480.png` | `461c2aec24053f3c3cc24b954696124c2e802006d6af737e231c29ef63d39102` |
| `mass_spec_gc.svg` (ilovaga qo‘shilmagan, `tools/instruments/gc_ms/`) | `812d71c6127d074c3da6fc2e9d674238ed7fc3cfc45bcd93d3c9ed059bbfed72` |

Paketning asl fayllari (README, viewer, hujjatlar, generator) — `tools/instruments/gc_ms/` (faqat ma’lumot uchun).
