# 19 — PHASE 5: Global Professional Content + Scientific Visual System + iOS/Android verification

**Branch:** `claude/phase-5-global-professional-content` (main’ga merge qilinmagan, PR ochilmagan, store’ga hech narsa yuborilmagan).
**Kontent paketi:** `2026.10.3`, format `fe-bundle/3`, DB schema v4, kanal `development`.

> Tamoyil: **sifat > son.** Barcha yangi yozuvlar `NEEDS_REVIEW`. Hech bir yozuv VERIFIED / REVIEWED / PUBLISHED emas — reviewer yo‘q.
> Manba topilmagan joyda «MA’LUMOT TEKSHIRILMAGAN — EKSPERT TASDIG‘I KERAK» yoki «manbada ko‘rsatilmagan — taxmin qilinmadi» deb ko‘rsatiladi.

## 1. Kontent soni (haqiqiy, paketdan hisoblangan)

| Bo‘lim | Soni | Izoh |
|---|---|---|
| Moddalar | **137** | Har biri PubChem PUG REST (bitta CID, formula, InChIKey, IUPAC); 16 tahririy guruh |
| Adabiyot dalili bor moddalar | **127** | qolgan 10 tasida faqat identifikatsiya — «ma’lumot yo‘q» |
| INCB nazorat holati (Yellow 65 / Green 36) | **58** modda | PDF qatori aniq moslik bilan; yo‘qligi «nazoratda emas» degani emasligi UI’da yozilgan |
| Modda claim’lari | **403** | identity 137, analitik metod 99, metabolizm izohi 96, **reported concentration 54**, metabolitlar 15, biomarker 1, transformatsiya mahsuloti 1 |
| Analitik metodlar | **18** | 4 qatlam alohida; GC-MS/LC-MS/MS parametrlari **kiritilmagan** (manbasiz) |
| Reagentlar | **4** | faqat Dragendorff’da manbali tarkib (4 ingredient); qolganlarida retsept yo‘q |
| Skrining testlari | **7** | «SKRINING ≠ TASDIQLANGAN IDENTIFIKATSIYA» banneri; tasdiqlovchi metod bog‘langan |
| Sud tibbiyoti mavzulari | **17** (25 tadan) | 19 claim |
| Sud gistologiyasi | **6** | 6 claim; «ilova/AI tashxis qo‘ymaydi» banneri |
| Postmortem biokimyo | **16** | 17 claim; universal chegara yoki PMI formulasi yo‘q |
| Jami claim | **482** | A 10 · B 243 · C 191 · D 38; hammasi NEEDS_REVIEW |
| Manbalar | **439** | 298 jurnal maqolasi, 137 PubChem yozuvi, 4 rasmiy hujjat |

### Reported concentration qoidasi
* 54 claim: har birida **specimen**, **kontekst** va `not_a_threshold: true` (FE032).
* Doimiy banner: «toksik, o‘ldiruvchi yoki huquqiy chegara EMAS».
* Konsentratsiya/doza qiymatli jumla boshqa bo‘limda (metod, metabolizm) **ko‘rsatilmaydi** — 5 ta shunday claim rad etildi (`content/phase5/claims_rejected_assembly.json`); test bilan himoyalangan.

## 2. Research / Evidence Library

| Tur | Soni | Dalil darajasi | Peer-reviewed |
|---|---|---|---|
| Jurnal maqolasi | 388 | B | ha |
| Review | 244 | C | ha |
| Case report | 80 | D | ha |
| Tizimli review | 36 | A | ha |
| Meta-analiz | 23 | A | ha |
| **Konferensiya maqolasi** | **36** | E | **yo‘q** |
| **Konferensiya tezisi (abstract)** | **0** | — | — |
| **Doktorlik dissertatsiyasi** | **59** | E | **yo‘q** |
| **Tezis (magistrlik / boshqa)** | **17** | E | **yo‘q** |
| **Jami** | **883** | | |

* Manba API: PubMed 771, Crossref 68, Europe PMC 44.
* Dedup: DOI → PMID → Handle → sarlavha + 1-muallif; **45 dublikat** birlashtirildi.
* **38 hayvon/veterinariya tadqiqoti** sabab bilan rad etildi (`content/phase5/research_rejected.json`).
* Konferensiya **tezislari** (abstract) uchun PubMed «Congress» so‘rovi natija bermadi — 0 deb halol ko‘rsatildi.
* Faqat metadata va havola; to‘liq matn yoki annotatsiya ko‘chirilmagan.
* 688 ta «yozuv ↔ tadqiqot» bog‘lanishi.

## 3. Ilmiy rasmlar (156)

| Tur | Soni | Litsenziya |
|---|---|---|
| Kimyoviy struktura (RDKit, PubChem SMILES) | 137 | original_depiction_of_factual_data |
| Original sxema (cairosvg) | 11 | original_work — «Schematic — not experimental data» |
| Xromatogramma (PMC, nashr qilingan) | 3 | CC BY |
| Mikrofoto (H&E, IHC, Oil Red O) | 3 | CC BY |
| TLC plastinkasi | 1 | CC BY |
| Rang testi | 1 | CC BY |

* Har bir tashqi rasmda: manba, muallif, litsenziya, attribution, URL, DOI, murojaat sanasi (FE031).
* **Graphic/autopsiya rasmi: 0.** «reprinted/©» va graphic izohli rasmlar rad etilgan.
* Original sxemalar hech qachon real ma’lumot sifatida ko‘rsatilmaydi (`representsRealData=false`).
* Alt matn (EN/RU/UZ), offline (DB BLOB), lazy yuklash va xotira keshi.

## 4. Bilim grafigi (849 bog‘lanish)

research 688 · analysed_by 111 · metabolism_co_mention 32 · confirmed_by 12 · related_topic 6. Har bir bog‘lanishning asosi bor (claim ID, research ID yoki `editorial:…`); uchlari mavjudligi test bilan tekshiriladi (FE030).

## 5. Reviewer navbati

`content/review/REVIEW_QUEUE.md`, `queue.csv`, `queue.json` — **835 element**:
scientific 314 · legal 216 · translation 137 · analytical 126 · medicine_histology 42.
Turlari: claim 482, rasm 156, tarjima 137, huquqiy qoida 60. Muallif o‘z claim’ini tasdiqlay olmaydi (`StatusResolver`).

## 6. Rad etilgan nomzodlar

| Bosqich | Soni | Sabab |
|---|---|---|
| Modda claim nomzodlari (kuratsiya) | 158 | hayvon/bakteriya/o‘simlik, boshqa birikma, threshold/reference-range tili, doza, to‘liq bo‘lmagan retsept |
| Mavzu claim nomzodlari | 38 | xuddi shunday |
| Yig‘ish bosqichi | 6 | 5 konsentratsiya/doza noto‘g‘ri bo‘limda, 1 dublikat jumla |
| Research | 38 + 45 dublikat | hayvon/veterinariya; dublikat birlashtirildi |

## 7. Ilova

* Home: «Sud gistologiyasi» va «Tadqiqotlar va dalillar» modullari.
* Kutubxona: tahririy guruh filtri («ilmiy tasnif da’vosi emas» izohi bilan).
* Modda sahifasi: struktura rasmi, analitik metodlar, reported concentration (banner), bog‘liq materiallar.
* Research kutubxonasi: tur filtri, «peer-reviewed emas» belgisi, metadata, havola nusxasi.
* Rasm ko‘rgich: litsenziya va to‘liq attribution.
* Qidiruv: research sarlavhalari indekslangan, natija research sahifasini ochadi.
* Dizayn auditi natijasida tuzatilganlar: metadata yorliqlari so‘z ichida bo‘linmaydi (FeMetaList, 48 dp), texnika va metod bo‘limi nomlari lokalizatsiya qilindi (`lcMsMs` emas `LC-MS/MS`), gistologiya banneri yuqoriga, takroriy jumla bir marta, research filtri 320 dp’da gorizontal.

## 8. Tekshiruvlar

| Tekshiruv | Natija |
|---|---|
| `flutter analyze` / `dart analyze packages` (`--fatal-infos`) | ✅ No issues |
| `tool/ci_local.sh` (format, generated code, analyze, barcha testlar) | ✅ OK |
| Avtomatik testlar | ✅ **959** (ilova 766 + paketlar 193), 1 skip (PHASE 1 preview) |
| Yangi PHASE 5 testlari | kontent qoidalari (konsentratsiya, research, rasm litsenziyasi, graf), widget (18), a11y (9 ekran × light/dark), golden (24), perf |
| Golden | ✅ 61 kadr (24 ta yangi PHASE 5, shu jumladan 2 ta iOS platformasi) |
| Kontent validator | ✅ development — 0 xato; production — **576 × FE008** bilan rad etiladi (kutilgan) |
| gitleaks (git tarixi) | ✅ 53 commit — leak yo‘q |
| gitleaks (katalog) | ✅ repozitoriy fayllarida leak yo‘q; 15 topilma faqat gitignore qilingan HTTP keshida (maqola matnidagi kimyoviy nomlar — false positive) |
| OSV | ✅ 132 paket — zaiflik yo‘q |
| Android release APK | ✅ `apps/mobile/build/app/outputs/flutter-apk/app-release.apk` — **70.0 MB** (69 955 456 bayt, universal), SHA-256 `df92561f…a7f9`; ⚠️ **Android Debug** sertifikati (RG-20). Store’ga yuborilmagan |
| iOS statik tekshiruv | ✅ 11 PASS · 0 FAIL · 3 OPEN (`docs/verification/phase5_ios_static_check.txt`) |
| **iOS build** | ⛔ **BAJARILMAGAN** — muhitda macOS/Xcode yo‘q. «iOS build passed» deb da’vo qilinmaydi |
| Real qurilma | ⛔ yo‘q (RG-10) |

## 9. Unumdorlik (host VM, JIT; qurilma o‘lchovi EMAS)

`docs/perf/phase5_raw.txt`:

| Amal | Vaqt |
|---|---|
| Paket o‘rnatish (imzo + SHA-256) | 423–482 ms |
| Kutubxona yuklash (137 modda) | 105–114 ms |
| Bilim obyektlari | 53–62 ms |
| Evidence (883 research, 849 link, 156 rasm meta) | 75–78 ms |
| Bitta rasm baytlari | 2.7 ms |
| Qidiruv indeksi | ~20 ms |
| Qidiruv (8 so‘rov) | median 33–40 ms, max ~110 ms |

Qidiruv PHASE 4 ga nisbatan sekinroq (883 uzun sarlavha). Minglab yozuvlar uchun keyingi bosqichda research’ni alohida FTS indeksiga o‘tkazish tavsiya etiladi.

## 10. Skrinshotlar (24 ta, `docs/screenshots/phase5/`)

01 home_en · 02 home_uz_dark · 03 library_groups_en · 04 substance_structure_en · 05 substance_concentration_en · 06 substance_related_uz_dark · 07 research_library_en · 08 research_dissertation_en · 09 research_sr_ru_dark · 10 image_chromatogram_en · 11 image_schematic_uz · 12 histology_hub_en · 13 histology_entry_en · 14 method_lcmsms_en · 15 reagent_dragendorff_en · 16 screening_strips_ru_dark · 17 biochemistry_hub_ru · 18 fm_entry_en · 19 search_research_en · 20 library_320_x13 · 21 substance_320_x13_dark · 22 research_320_x13 · 23 ios_home_en · 24 ios_substance_dark

## 11. Ochiq blokerlar (avtomatik yopilmagan)

RG-18 (server tomonida xarid tekshiruvi — SECURITY), RG-20 (release imzo), RG-10 (real qurilma), RG-19/21/23 (domen reviewerlari, 835 element), RG-11 (tarjima review), RG-06 (trademark), RG-22 (AI backend/eval/kvota), RG-08 (privacy manifest), RG-24 (iOS Xcode build / TestFlight / export compliance).
