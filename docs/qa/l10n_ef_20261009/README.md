# Phase E/F — o‘quv testi qayta qurilishi va terminologiya (2026-10-09)

Real ilova (Linux desktop, Xvfb, `bootstrap()`, haqiqiy imzolangan pilot paket, MOCK akkaunt,
tarmoq o‘chiq, Pro yo‘q): `QA_OUT=docs/qa/l10n_ef_20261009 ./tool/qa_real_app.sh study`
(`integration_test/qa_study_test.dart`). **63/63 PASS** — TALABA va MUTAXASSIS × uz/ru/en,
390 dp va 320 dp. Natija: `results_study.json`, skrinshotlar `sNN_*.png`.

Sinalmagan: real iOS/Android qurilma, Pro foydalanuvchi (moddalar to‘plamlari faqat vidjet
testlarida), ADMIN roli (o‘quv rejimida admin farqi yo‘q).

## O‘quv testi statistikasi (Pro ochiq katalog, `test/unit/study_quiz_rebuild_test.dart`)

| Ko‘rsatkich | Oldin (audit) | Hozir |
|---|---:|---:|
| Elementlar | 274 | 274 |
| Boshqa fan/to‘plamdan distraktor | 21 | **0** (soha cheklovi, test bilan qotirilgan) |
| 4 variantli test | 274 | 259 |
| «To‘g‘ri / Noto‘g‘ri» (mos distraktor < 3) | 0 | 10 |
| Faqat kartochka (mos distraktor yo‘q) | 0 | 5 |
| Izohli savollar | 0 | 274 (76 muallif izohi uz/ru/en + 198 manbali claim/formula/mazmun izohi) |
| Baholanadigan imtihon (uz) | 0 | **76** (gmt 42 + toks 34) |
| Imtihon (ru/en) | 0 | 0 — savollar tarjimasi `DRAFT` (UI sababini ko‘rsatadi) |
| Faqat mashq | 274 | 198 |
| To‘plamlar / 1 elementli | 33 / 9 | 22 / 0 (kichiklari 3 ta aralash to‘plamga birlashtirilgan) |

## Skrinshotlar ko‘rigi (qo‘lda)

- `s01`, `s53`: to‘plam kartasi — «Mashq» / «Imtihon» tugmalari, «Faqat mashq» belgisi, imtihon
  yo‘qligi sababi; 320 dp da sig‘adi.
- `s03`, `s15`, `s25`: javobdan so‘ng «To‘g‘ri/Noto‘g‘ri», «Izoh», «Manbani ochish»; ru/en da
  savol «Только тренировка / Practice only» (tarjima qoralama).
- `s06`: aralash to‘plam — iqtibos UI tilida birinchi («avtomatik tarjima, tekshirilmagan»),
  «Asl manbadagi iqtibosni ko‘rish», «To‘g‘ri / Noto‘g‘ri» savoli.
- `s07`–`s08`: imtihon natijasi «Natija: 6 / 20», foiz, barcha javoblar izoh bilan.
- `s09`, `s20`, `s30`: kartadagi qisqartma → qisqa izoh varag‘i (machine_draft belgisi).
  D bosqichi base’ga birlashtirilgandan keyin (5810e30) uchala tilda ham kartada TLC, GC-MS,
  LC-MS/MS, Rf, HPLC havolalari bor.
- `s12`: sanoq «1-savol / 10 ta».
- `s19`: ru — imtihon o‘rniga «Экзамен доступен на узбекском…».
