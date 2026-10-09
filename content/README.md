# content/ — ilmiy kontent manbalari

Bu katalogdagi har bir qiymat **real so‘rov yoki tekshiruv** natijasida olingan.

- `tools/fetch_identity.py` — PubChem PUG REST: identifikatorlar va sinonimlar.
- `tools/verify_incb.py` — INCB Yellow List / Green List PDF: aniq qator va SHA-256.
- `tools/verify_excerpts.py` — PMC BioC: iqtibos asl matnda bor-yo‘qligi, DOI va litsenziya.
- `tools/assemble_pilot.py` — `pilot/bundle.json` (fe-bundle/1).
- `tools/apply_text_translations.py` — `pilot/translations/*.json` dagi avtomatik
  (machine_draft, tekshirilmagan) iqtibos/sarlavha tarjimalarini bundle’ga qo‘shadi;
  asl matn xeshi (`source_sha256`) mos kelmasa, tarjima tashlab yuboriladi.
- `tools/reagents/fetch_ghs.py` — PubChem PUG REST/View: reaktiv ingrediyentlarining
  GHS xavf bayonotlari → `pilot/reagents/pubchem_ghs.generated.json`.
- `tools/reagents/assemble_reagents.py` — ilova egasi to‘plami «Приготовление
  реактивов» (74 band, `SRC-OWNER-REAGENTS`, egasi ruxsati bilan 2026-10-09)
  dan tuzilgan retseptlar (`pilot/reagents/recipes_*.yaml`) + GHS xavflari →
  `bundle.json` (`assemble_pilot.py` ham chaqiradi; yakka ishga tushirsa bo‘ladi).
  Raqamlar asl matnga solishtiriladi; uz/en — machine_draft; status NEEDS_REVIEW.
- `pilot/candidates/` — qidiruv nomzodlari. Ular ishonchli emas: faqat tekshiruvdan o‘tgani ishlatiladi.

Qayta yig‘ish (repo ildizidan):

```bash
(cd content && python3 tools/fetch_identity.py && python3 tools/verify_incb.py \
  && python3 tools/verify_excerpts.py && python3 tools/assemble_pilot.py)
# faqat reaktivlar (mavjud bundle ustiga):
(cd content && python3 tools/reagents/fetch_ghs.py && python3 tools/reagents/assemble_reagents.py)
bash tool/update_bundled_pack.sh
```

Qoidalar:
- Review yozuvisiz hech narsa `VERIFIED` / `REVIEWED` bo‘lmaydi (validator FE002).
- Production kanal faqat review’dan o‘tgan kontentni qabul qiladi (FE008).
- Ilmiy fakt va huquqiy ma’lumot alohida qatlamlarda (FE012–FE016).
