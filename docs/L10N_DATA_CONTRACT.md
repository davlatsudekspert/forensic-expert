# L10N ma’lumot shartnomasi — ilova qaysi tarjimalarni o‘qiydi (Phase C, 2026-10-09)

Maqsad: kontent tarjimasini to‘ldiruvchi (agent «L10n D», keyinroq CMS/ekspert) **ilova kodiga
tegmasdan** ma’lumot qo‘shsa, u ekranda avtomatik ko‘rinsin. Ilova tomonidagi yagona API:

```dart
// apps/mobile/lib/domain/evidence/content_translations.dart
ref.watch(contentTranslationsProvider)
   .resolve(kind, id, source: <asl matn>, lang: <UI tili>, originalLang: <asl til>)
   → LocalizedContent { text, textLang, original, originalLang, status, missingTranslation }
```

UI qatlami (`features/evidence/presentation/localized_content.dart`): `LocalizedContentText`
(tarjima → holat belgisi → «Asl matn» yig‘ilgan), `LocalizedInlineText` (qisqa qiymat),
`TranslatedTitle` (sarlavha → «Asl nomi» → holat), `InstrumentTitle` (huquqiy hujjat nomi),
`LocalizedReferenceTitle` (sud/yo‘riqnoma adabiyoti nomi).

## 1. Umumiy qoidalar

| Qoida | Tafsilot |
|---|---|
| Asl matn | Hech qachon almashtirilmaydi; «Asl matn» / «Оригинал» / «Original text» orqali ochiladi |
| Xesh | `source_sha256` = asl matnning UTF-8 SHA-256 (hex, 64 belgi). Ilova **ekrandagi aniq asl matnni** xeshlaydi; mos kelmasa tarjima eskirgan → ko‘rsatilmaydi |
| Tillar | `uz`, `ru`, `en` (en — asl matn rus/nemis tilida bo‘lsa). Boshqa til — e’tiborsiz |
| Statuslar | `machine_draft`, `terminology_checked`, `claim_checked`, `reviewed`, `official`. Faqat `reviewed`/`official` «tekshirilmagan» belgisini olib tashlaydi. Ilova kodi bu statuslarni **hech qachon o‘rnatmaydi** |
| Noma’lum | Noma’lum `target_type`, status yoki til — **xato emas**, qator e’tiborsiz qoldiriladi |
| Tarjima yo‘q | UI tilida ochiq yoziladi: «Bu matnning o‘zbekcha tarjimasi hali tayyorlanmagan — asl tili: ingliz» |
| Saqlanadigan qiymatlar | Raqam, birlik, formula, modda nomi, cut-off, foiz — tarjimada o‘zgarmasin (`claim_checked` shuni bildiradi) |

## 2. Manbalar (jadval / fayl)

### 2.1 `text_translations` (sxema v7, mavjud — **hozir to‘ldirish mumkin**)

`target_type, target_id, lang, source_sha256, translated_text, status`. Paket `bundle.json`
→ `text_translations[]` (`target_type`, `target_id`, `lang`, `source_sha256`, `text`, `status`).

Joriy cheklov (baza CHECK, `packages/fe_database/.../content.drift`, validator FE043):
`target_type ∈ {claim_excerpt, rule_excerpt, research_title}`, `lang ∈ {uz, ru}`,
`status = machine_draft`. Shu doirada D agenti **sxemani o‘zgartirmasdan** to‘ldira oladi.

### 2.2 Yon fayl `fe-localized-texts/1` (Phase D — **ilova hozir o‘qiydi**)

`content/pilot/translations/localized_texts_d.json` (shartnoma: `docs/L10N_DATA_CONTRACT_D.md`)
→ `tool/update_bundled_pack.sh` uni `apps/mobile/assets/content/translations/localized_texts.json`
ga ko‘chiradi → `localizedTextsAssetProvider` o‘qiydi va paket tarjimalari bilan birlashtiradi
(`ContentTranslations.merge`). Yozuv: `{target_type, target_id, source_sha256, text: {uz, ru, en},
status}`. Fayl imzolanmagan, shuning uchun **faqat** `machine_draft` / `terminology_checked` /
`claim_checked` qabul qilinadi; `reviewed`/`official` faqat imzolangan paketdan. Har yozuv baribir
imzolangan `content.db` dagi asl matn xeshi mos bo‘lsagina ko‘rsatiladi. Sxema (v7) o‘zgarmadi.

### 2.3 `localized_texts` jadvali (ixtiyoriy, taklif qilingan v8 — ilova allaqachon o‘qiydi)

Agar paketda shu nomli jadval bo‘lsa (ustunlar: `target_type, target_id, lang,
source_sha256, text` yoki `translated_text`, `status`; qo‘shimcha ustunlar e’tiborsiz), ilova
uni `text_translations` bilan birlashtiradi (bir kalitda — yuqoriroq status ustun).
Bu yerda CHECK cheklovlari yo‘q: barcha 3-bo‘limdagi turlar, `en` va 5 status. Jadvalni yozish
uchun pipeline (`db_writer.dart`, `bundle_codec.dart`, validator) kengaytmasi kerak —
**hali qilinmagan** (ruxsat: sxema o‘zgarishi).

### 2.4 Muallif yozgan tilga bog‘liq xaritalar (mavjud)

| Manba | Maydon | Ilova qoidasi |
|---|---|---|
| `jurisdictional_instruments.titles_json` | `{uz, ru, en, <rasmiy til>}` + `language` + `translation_status` | `titles[lang]` → `titles[language]` (rasmiy asl) → `en` → ID. `lang == language` → «Rasmiy nomi (… tilida)»; boshqasi → «Nomning norasmiy tarjimasi — tekshirilmagan» (+ «Asl nomi: …»); `translation_status = reviewed` → «Tarjima mutaxassis tomonidan tekshirilgan» |
| `authorities.names_json` | `{uz, ru, en}` | `lang` → `en` → birinchi; yo‘q bo‘lsa «(asl tili: …)» (kirill yozuvi → rus) |
| `court_prep_v1.json` / `guidelines_v1.json` `references[]` | **yangi ixtiyoriy**: `titles: {uz, ru, en}`, `title_status: {uz: official \| unofficial_translation \| machine_draft \| reviewed}` | UI tilidagi nom asl iqtibos **ustida**; `official` → «Rasmiy nomi (o‘zbek tilida)», `reviewed` → tekshirilgan, boshqasi → norasmiy tarjima. Asl `title`/`citation` o‘zgarmaydi. Misol: `court_uz_cpc` → `titles.uz = "O‘zbekiston Respublikasining Jinoyat-protsessual kodeksi"`, `title_status.uz = "official"` (lex.uz’dan qo‘lda tasdiqlansin) |
| reaktiv `ingredients[].quantity_note`, `variants[].labels`, izoh `texts` | `{uz, ru, en}` | `lang` → asl → `en`; yo‘q bo‘lsa — ochiq belgi |

## 3. `target_type` (kind) ro‘yxati va ID shakllari

| kind | ID | Asl matn (xeshlanadigan) | Ekran | Manba jadvali/maydoni | Yozish mumkinmi (v7) |
|---|---|---|---|---|---|
| `claim_excerpt` | `claims.claim_id` | `value_json.excerpt` | mavzu/modda kartasi, provenance varag‘i, **o‘quv testi** (`StudyItem.answerQuoteId`), **AI bo‘lagi** (`chunkId` = claim ID) | claims | ✅ (357×2 bor) |
| `rule_excerpt` | `jurisdictional_rules.rule_id` | `value_json.excerpt` | huquqiy qoida kartasi | rules | ✅ |
| `research_title` | `research_records.research_id` | `title` | tadqiqotlar ro‘yxati va sahifasi (`TranslatedTitle`) | research_records | ✅ (**0 / 883** — D to‘ldiradi) |
| `source_title` | `sources.source_id` | `title` | manba kartasi, provenance, o‘quv testi manbalari, konsentratsiya jadvali | sources | yon fayl (D: 1, `SRC-FE-EDITORIAL` asl tili uz) |
| `standard_title` | `standards.standard_id` | `title` | standartlar katalogi | standards | yon fayl / 2.3 |
| `standard_note` | `standards.standard_id` | `note` | standartlar katalogi | standards | yon fayl (D: 7) |
| `conflict_text` | `<conflict_id>#question` / `<conflict_id>#note` | `question` / `note` | ziddiyatlar ro‘yxati/sahifasi, provenance | evidence_conflicts | yon fayl (D: 8) |
| `context_text` | `<claimId>#<maydon>` (`case_type`, `population`, `study_size`, `analytical_method`, `co_intoxicants`, `timing`) yoki `<claimId>#limitations[<i>]` | `value_json.context_strict.<maydon>` (satr) / `limitations[i]` | konsentratsiya konteksti jadvali | claims | yon fayl (D: 67) |
| `list_item` | `<claimId>#items[<i>]` | `value_json.items[i]` | da’vo kartasidagi metabolit/marker chiplari | claims | yon fayl (D: 34) |
| `metabolite_name` | `metabolite_relations.relation_id` | `metabolite_name` | modda → metabolitlar, bilim zanjiri, tahlil bo‘limi, «Qisqacha» | metabolite_relations | yo‘q bo‘lsa — **aynan shu asl matnli** `list_item` tarjimasi ishlatiladi (xesh mos) |
| `topic_body` | `<topic_id>` | kartadagi da’vo iqtibosi (`derived`, `source_claims[]`) | mavzu kartasi tepasidagi «Qisqacha tushuntirish» (faqat UI tilida tarjima bo‘lsa) | knowledge_entities | yon fayl (D: 1) |
| `screening_field` | `<entityId>#analyte` \| `#specimen` \| `#principle` | `payload.analyte/specimen/principle` | skrining kartasi | knowledge_entities | yon fayl (D: 21) |
| `entity_note` | `<entityId>#<maydon>` yoki `<entityId>#<maydon>[<i>]` (`limitations`, `cross_reactivity`, `false_positive`, `false_negative`, `hazards`, `result_type`, `detection_window`, `interferences`) | izoh `text` (tilga moslanmagan) | skrining/reaktiv xavfsizlik izohlari | knowledge_entities | yon fayl / 2.3 |
| `rule_convention` | `jurisdictional_rules.rule_id` | `value_json.convention` | huquqiy qoida (nazorat jadvali) | rules | yon fayl / 2.3 |
| `image_caption` | `images.image_id` | `caption_original` | rasm ko‘ruvchisi | images | yon fayl / 2.3 |
| `ai_chunk` | (zaxira) | — | hozircha AI bo‘lagi `claim_excerpt` ni ishlatadi | — | — |

Eslatma: `"not specified in source"` (pipeline belgisi) tarjima qilinmaydi — ilova uni UI
tilidagi «Manbada ko‘rsatilmagan» bilan almashtiradi.

## 4. Tekshiruv

* Ilova birlik testlari: `apps/mobile/test/unit/content_translations_test.dart` (fallback,
  eskirgan xesh, noma’lum tur/status, faqat reviewed/official belgini olib tashlaydi).
* Widget testlari: `test/widget/trilingual_render_test.dart`, `test/widget/quote_translation_test.dart`,
  `test/widget/trilingual_pilot_test.dart` (haqiqiy paket + D yon fayli).
* Vizual: `test/golden/trilingual_golden_test.dart` (uz/ru/en, 390/320 dp, qorong‘i).

## `value.locale_only` (2026-10-10)
Ixtiyoriy claim maydoni: `value.locale_only = "uz"` — yozuv faqat shu til interfeysida
ko‘rinadi; `value.statement` da faqat shu til kaliti bo‘ladi (tarjima yozilmaydi). Boshqa tilda
yozuv ro‘yxatdan butunlay chiqariladi (bo‘sh joy, «tarjima yo‘q» yoki inglizcha matn chiqmaydi).
Kod: `ClaimView.visibleIn/statementFor` va `visibleClaims` (`library_models.dart`); testlar:
`test/widget/method_images_records_test.dart`. Hozircha kontent paketida bunday yozuv YO‘Q
(ABY mazmuni egasining tasdig‘ini kutmoqda, `docs/ACTIVE_TASKS.md`). `translation_qa.py` bunday
yozuvlarni tekshirishga tayyor emas: kontent qo‘shilganda `statement.en` yo‘qligini istisno
qilish va faqat `uz` matnini terminologiya uchun tekshirish kerak.
