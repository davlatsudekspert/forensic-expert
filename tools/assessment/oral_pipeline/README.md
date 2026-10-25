# Og‘zaki javoblar pipeline (2026-10-25)

Bu papka — ilovadagi `oral_*.json` javoblarini yaratgan ish jarayonining to‘liq izi. **Keyingi hafta davom ettirish** uchun yetarli.

## Tarkib
* `ORAL_BRIEF.md` (kitoblar rejimi), `ORAL_WEB_BRIEF.md` (patanatomiya veb-manba rejimi), `ORAL_VERIFY_BRIEF.md` (mustaqil auditor) — agent ko‘rsatmalari.
* `oral_in_<spec>_NN.json` — 12 savollik kirish partiyalari. **Qolgan:** `oral_in_pat_anat_16.json` … `oral_in_pat_anat_42.json` (324 savol) + bir nechta alohida savol (sud_tib 9, sud_kimyo 20: `docs/ORAL_REMAINING.md`).
* `oral_out_*.json` — agent qoralamalari; `oral_ver_out_*.json` — mustaqil audit hukmlari (`OK/OVERSTATED/WRONG`, `fix`, `source_quality`, `topic_ok`).
* `oral_exclude.json` (qo‘lda chiqarilgan bandlar), `accept_wrong_fix.json` (WRONG, lekin tuzatish bilan qabul), `oral_unique_meta.json` (takror savollar: `same_as`), `REDO.md` (qarorlar va terminologiya).
* `oral_src.tar.xz` — veb-manbalarning saqlangan matnlari (iqtibos tekshiruvi uchun, `oral_src/`).
* Skriptlar: `oral_build_ver.py` (qoralama → audit kirishi, iqtibosni sahifada tekshiradi), `chk_oral10.py`, `search_books.py`, `showpt.py`; yig‘ish: `../assemble_oral.py`.

## Kitob matnlari (repoga QO‘SHILMAGAN)
`book_<id>.txt` fayllari egasining PDF kitoblaridan sahifa-sahifa ajratilgan (`=====[id] PDF-SAHIFA N=====` belgisi bilan; N — PDF sahifa raqami). Mualliflik huquqi sababli repoda yo‘q: kerak bo‘lsa PDF’lardan PyMuPDF bilan qayta ajratiladi. Kitob idlari: `giyosov_1_asoslar_travmatologiya`, `giyosov_2_oqotar_asfiksiya_toksikologiya1`, `giyosov_3_toksikologiya2_fizik_tanatologiya`, `giyosov_4_murda_ekspertizasi_ashyoviy_dalillar`, `toks_kimyo_majmua_A`, `giyohvand_moddalar_tahlili`.

## Davom ettirish tartibi (limit tejash: **Sonnet**, bir vaqtda ≤4 agent)
1. Ishchi papka yarating (`W`), shu papkadagi fayllarni va (kerak bo‘lsa) kitob matnlarini + `oral_src/` ni joylang.
2. Partiya uchun agent: «Read W/ORAL_WEB_BRIEF.md … Input W/oral_in_pat_anat_NN.json, Output W/oral_out_pat_anat_NN.json» + `REDO.md` dagi qoidalar (tarjima atamalari, «нередко» → «ancha tez-tez», qualifier saqlash, kuchli manbalar, rasm izohiga tayanmaslik, darslik «в настоящее время» → «Darslikka ko‘ra»).
3. `python3 oral_build_ver.py oral_out_X.json oral_ver_in_X.json` → auditor agent (`ORAL_VERIFY_BRIEF.md`) → `oral_ver_out_X.json`.
4. Auditor hisobotidan shubhali bandlarni `oral_exclude.json` ga qo‘shing.
5. `python3 tools/assessment/assemble_oral.py <W>` → `apps/mobile/assets/content/assessment/oral_*.json` yangilanadi.
6. `flutter test test/unit/assessment_oral_data_test.dart test/widget/assessment_test.dart`, `flutter analyze`, hujjatlarni yangilang, lokal commit. Push — faqat egasi aytganda.

## Qoidalar (qisqa)
Har band: o‘z so‘zi bilan o‘zbekcha da’vo + so‘zma-so‘z iqtibos (≤300 belgi) + kitob/bet yoki havola. Manbadagi cheklovlar («ba’zan», «mumkin», shartlar) saqlanadi. Kitob xatosi, OCR bilan buzilgan matn, eskirgan/bekor qilingan norma, taxminga tayangan talqin, boshqa usuldan ko‘chirilgan protsedura — bandga kiritilmaydi. Mustaqil inson-mutaxassis taqrizi o‘tmagan.
