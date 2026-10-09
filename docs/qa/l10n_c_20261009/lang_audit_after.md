# Til auditi — aralash-til detektori natijasi

Paket: `{'pack_version': '2026.10.9', 'schema_version': '7', 'bundle_format': 'fe-bundle/4'}` · birliklar: **8005** · findings sha256 `d9394b66a8c89dff`

## Jami (til × daraja)

| til | error | warn | info |
|---|---:|---:|---:|
| uz | 123 | 40 | 8 |
| ru | 122 | 30 | 0 |
| en | 3 | 0 | 8 |

## Qoida bo‘yicha

| qoida:til | soni |
|---|---:|
| MISSING_TRANSLATION:uz | 153 |
| MISSING_TRANSLATION:ru | 152 |
| CYRILLIC_QUOTED_IN_EN:en | 8 |
| CYRILLIC_QUOTED_IN_UZ:uz | 8 |
| ENGLISH_IN_UZ:uz | 6 |
| ENGLISH_SHAPED_IN_UZ:uz | 4 |
| CYRILLIC_IN_EN:en | 1 |
| MISSING_TRANSLATION:en | 1 |
| UZBEK_IN_EN:en | 1 |

## Bo‘lim bo‘yicha (error/warn)

| bo‘lim | uz err | uz warn | ru err | ru warn | en err | en warn |
|---|---:|---:|---:|---:|---:|---:|
| 01_home Bosh sahifa | 0 | 0 | 0 | 0 | 0 | 0 |
| 02_disciplines Fanlar | 0 | 0 | 0 | 0 | 0 | 0 |
| 03_library Kutubxona (moddalar) | 70 | 30 | 70 | 30 | 0 | 0 |
| 04_research Ilmiy maqolalar | 0 | 0 | 0 | 0 | 0 | 0 |
| 05_guidelines Yo‘riqnomalar (ilmiy kartalar) | 0 | 10 | 0 | 0 | 0 | 0 |
| 06_reagents Reaktivlar / retseptlar | 5 | 0 | 5 | 0 | 0 | 0 |
| 07_narcotics Giyohvand moddalar va nazorat ro‘yxatlari | 10 | 0 | 10 | 0 | 1 | 0 |
| 08_toxicology Toksikologiya (skrining, metodlar, ilmiy da’volar) | 21 | 0 | 21 | 0 | 0 | 0 |
| 09_forensic_medicine Sud tibbiyoti | 0 | 0 | 0 | 0 | 0 | 0 |
| 10_histology Gistologiya | 0 | 0 | 0 | 0 | 0 | 0 |
| 11_biology Biologiya / biokimyo | 0 | 0 | 0 | 0 | 0 | 0 |
| 12_genetics Genetika | 0 | 0 | 0 | 0 | 0 | 0 |
| 13_med_criminalistics Tibbiy kriminalistika | 0 | 0 | 0 | 0 | 0 | 0 |
| 14_glossary Glossariy / terminlar | 0 | 0 | 0 | 0 | 0 | 0 |
| 15_study O‘quv rejimi va testlar | 0 | 0 | 0 | 0 | 0 | 0 |
| 16_court Sudda so‘roq: tayyorgarlik | 0 | 0 | 0 | 0 | 0 | 0 |
| 17_ai AI yordamchi | 0 | 0 | 0 | 0 | 0 | 0 |
| 18_tools Professional asboblar / kalkulyatorlar | 0 | 0 | 0 | 0 | 0 | 0 |
| 19_free_pro Free / Pro, obuna | 0 | 0 | 0 | 0 | 0 | 0 |
| 20_auth_profile Kirish va profil | 0 | 0 | 0 | 0 | 0 | 0 |
| 21_admin Admin panel | 0 | 0 | 0 | 0 | 0 | 0 |
| 22_support Taklif va murojaatlar | 0 | 0 | 0 | 0 | 0 | 0 |
| 23_errors Xatolar / ogohlantirishlar | 8 | 0 | 8 | 0 | 0 | 0 |
| 24_empty_loading Bo‘sh / yuklanish holatlari | 0 | 0 | 0 | 0 | 0 | 0 |
| 25_notifications Bildirishnomalar | 0 | 0 | 0 | 0 | 0 | 0 |
| 26_privacy_terms Maxfiylik / shartlar | 0 | 0 | 0 | 0 | 0 | 0 |
| 27_offline Oflayn kontent / paket holati | 0 | 0 | 0 | 0 | 0 | 0 |
| 28_sources_citation Manbalar va iqtibos nusxalash | 9 | 0 | 8 | 0 | 2 | 0 |

## Manba bo‘yicha (error/warn)

| manba | uz err | uz warn | ru err | ru warn | en err | en warn |
|---|---:|---:|---:|---:|---:|---:|
| content.db:authorities | 6 | 0 | 6 | 0 | 1 | 0 |
| content.db:claims | 70 | 30 | 70 | 30 | 0 | 0 |
| content.db:evidence_conflicts | 8 | 0 | 8 | 0 | 0 | 0 |
| content.db:jurisdictional_instruments | 3 | 0 | 3 | 0 | 0 | 0 |
| content.db:jurisdictions | 1 | 0 | 1 | 0 | 0 | 0 |
| content.db:knowledge_entities | 26 | 0 | 26 | 0 | 0 | 0 |
| content.db:sources | 2 | 0 | 1 | 0 | 2 | 0 |
| content.db:standards | 7 | 0 | 7 | 0 | 0 | 0 |
| guidelines:assets/content/guidelines/guidelines_v1.json | 0 | 10 | 0 | 0 | 0 | 0 |

## Tarjima qatlami (manba:maydon:toifa → til → holat)

| manba:maydon:toifa | uz | ru | en |
|---|---|---|---|
| `arb:app_<lang>.arb:value:A` | present=2207 | present=2207 | present=2207 |
| `arb:app_<lang>.arb:value:E` | present=1 | present=1 | present=1 |
| `content.db:authorities:names_json:B` | missing=6 | missing=6 | no_status=6 |
| `content.db:claims:context_strict.case_type:B` | missing=14 | missing=14 | authored=14 |
| `content.db:claims:context_strict.co_intoxicants:B` | missing=2 | missing=2 | authored=2 |
| `content.db:claims:context_strict.limitations[]:B` | missing=22 | missing=22 | authored=22 |
| `content.db:claims:context_strict.population:B` | missing=14 | missing=14 | authored=14 |
| `content.db:claims:context_strict.statistic:B` | missing=14 | missing=14 | authored=14 |
| `content.db:claims:identity:G` | invariant=137 | invariant=137 | invariant=137 |
| `content.db:claims:value_json.excerpt:D` | machine_draft=357 | machine_draft=357 | original=357 |
| `content.db:claims:value_json.items[]:B` | missing=34 | missing=34 | original=34 |
| `content.db:evidence_conflicts:note:B` | missing=4 | missing=4 | authored=4 |
| `content.db:evidence_conflicts:question:B` | missing=4 | missing=4 | authored=4 |
| `content.db:images:alt_json:B` | no_status=156 | no_status=156 | no_status=156 |
| `content.db:images:caption_original:D` | missing=8 | missing=8 | original=8 |
| `content.db:images:title_json:B` | no_status=156 | no_status=156 | no_status=156 |
| `content.db:jurisdictional_instruments:official_reference:B` | missing=3 | missing=3 | authored=3 |
| `content.db:jurisdictional_instruments:titles_json:F` | machine_draft=4, missing=4 | machine_draft=3, missing=4, official/original=1 | machine_draft=2, official/original=6 |
| `content.db:jurisdictional_rules:value_json.convention:F` | missing=58 | missing=58 | official=58 |
| `content.db:jurisdictional_rules:value_json.excerpt:F` | machine_draft=2 | machine_draft=2 | official=2 |
| `content.db:jurisdictions:names_json:B` | missing=1, no_status=8 | missing=1, no_status=8 | no_status=9 |
| `content.db:knowledge_entities:names_json:B` | no_status=147 | no_status=147 | no_status=147 |
| `content.db:knowledge_entities:payload.analyte:B` | missing=7 | missing=7 | authored=7 |
| `content.db:knowledge_entities:payload.cross_reactivity[].text:D` | machine_draft (via claim)=1 | machine_draft (via claim)=1 | original=1 |
| `content.db:knowledge_entities:payload.false_positive[].text:D` | machine_draft (via claim)=1 | machine_draft (via claim)=1 | original=1 |
| `content.db:knowledge_entities:payload.hazards[]:B` | machine_draft=263 | machine_draft=263 | machine_draft=263 |
| `content.db:knowledge_entities:payload.ingredients[].name:B` | machine_draft=304, missing=4 | machine_draft=304, missing=4 | machine_draft=308 |
| `content.db:knowledge_entities:payload.ingredients[].quantity_note:B` | machine_draft=66 | machine_draft=66 | machine_draft=66 |
| `content.db:knowledge_entities:payload.limitations[].text:D` | machine_draft (via claim)=7 | machine_draft (via claim)=7 | original=7 |
| `content.db:knowledge_entities:payload.notes[]:B` | machine_draft=28 | machine_draft=28 | machine_draft=28 |
| `content.db:knowledge_entities:payload.original_text:D` | n/a (strukturali tarjima bor)=74 | original=74 | n/a (strukturali tarjima bor)=74 |
| `content.db:knowledge_entities:payload.principle:B` | missing=7 | missing=7 | authored=7 |
| `content.db:knowledge_entities:payload.specimen:B` | missing=7 | missing=7 | authored=7 |
| `content.db:knowledge_entities:payload.stability:B` | machine_draft=13 | machine_draft=13 | machine_draft=13 |
| `content.db:knowledge_entities:payload.steps[]:B` | machine_draft=182, missing=1 | machine_draft=182, missing=1 | machine_draft=183 |
| `content.db:knowledge_entities:payload.storage:B` | machine_draft=14 | machine_draft=14 | machine_draft=14 |
| `content.db:knowledge_entities:payload.variants[]:B` | machine_draft=10 | machine_draft=10 | machine_draft=10 |
| `content.db:metabolite_relations:metabolite_name:G` | invariant=24 | invariant=24 | invariant=24 |
| `content.db:research_records:title:E` | missing_gloss=883 | missing_gloss=883 | original=883 |
| `content.db:sources:title:B` | missing=2 | authored=1, missing=1 | authored=1, missing=1 |
| `content.db:sources:title:E` | missing_gloss=521 | missing_gloss=520, original=1 | missing_gloss=1, original=520 |
| `content.db:specimens:names_json:B` | no_status=12 | no_status=12 | no_status=12 |
| `content.db:standards:note:B` | missing=7 | missing=7 | authored=7 |
| `content.db:standards:title:E` | missing_gloss=7 | missing_gloss=7 | original=7 |
| `content.db:substance_i18n:name:B` | machine_draft=137 | machine_draft=137 | machine_draft=137 |
| `content.db:term_translations:localized_json:B` | machine_draft=103 | machine_draft=103 | machine_draft=103 |
| `content.db:term_translations:localized_json:G` | machine_draft=3 | machine_draft=3 | machine_draft=3 |
| `court_prep:court_prep_v1.json:context:C` | no_status=8 | no_status=8 | no_status=8 |
| `court_prep:court_prep_v1.json:followups[].a:C` | authored=105 | draft=105 | draft=105 |
| `court_prep:court_prep_v1.json:followups[].q:C` | authored=105 | draft=105 | draft=105 |
| `court_prep:court_prep_v1.json:limitations[]:C` | authored=53 | draft=53 | draft=53 |
| `court_prep:court_prep_v1.json:options[].feedback:C` | no_status=24 | no_status=24 | no_status=24 |
| `court_prep:court_prep_v1.json:options[].text:C` | no_status=24 | no_status=24 | no_status=24 |
| `court_prep:court_prep_v1.json:prepare.*[]:C` | authored=207 | draft=207 | draft=207 |
| `court_prep:court_prep_v1.json:prompt:C` | no_status=8 | no_status=8 | no_status=8 |
| `court_prep:court_prep_v1.json:question:C` | authored=52 | draft=52 | draft=52 |
| `court_prep:court_prep_v1.json:references.title:E` | missing_gloss=54, original=2 | missing_gloss=56 | missing_gloss=2, original=54 |
| `court_prep:court_prep_v1.json:references.title:F` | missing_official_title=2 | missing_official_title=1, original=1 | missing_official_title=1, original=1 |
| `court_prep:court_prep_v1.json:short_answer:C` | authored=52 | draft=52 | draft=52 |
| `court_prep:court_prep_v1.json:summary:B` | no_status=17 | no_status=17 | no_status=17 |
| `court_prep:court_prep_v1.json:tests:C` | authored=52 | draft=52 | draft=52 |
| `court_prep:court_prep_v1.json:text:C` | no_status=5 | no_status=5 | no_status=5 |
| `court_prep:court_prep_v1.json:title:B` | no_status=17 | no_status=17 | no_status=17 |
| `dart:country_directory.g.dart:country name:B` | present=249 | present=249 | present=249 |
| `dart:credential_file_picker.dart:hard-coded UI literal:A` | hardcoded=1 | hardcoded=1 | hardcoded=1 |
| `dart:jurisdiction_catalog.dart:LocalizedText map:B` | present=2 | present=2 | present=2 |
| `dart:jurisdiction_catalog.dart:country name:B` | present=9 | present=9 | present=9 |
| `dart:learn_models.dart:LocalizedText map:B` | present=2 | present=2 | present=2 |
| `guidelines:guidelines_v1.json:keywords:B` | authored=23 | draft=23 | draft=23 |
| `guidelines:guidelines_v1.json:quiz.a:C` | authored=76 | draft=76 | draft=76 |
| `guidelines:guidelines_v1.json:quiz.d[]:C` | authored=228 | draft=228 | draft=228 |
| `guidelines:guidelines_v1.json:quiz.q:C` | authored=76 | draft=76 | draft=76 |
| `guidelines:guidelines_v1.json:references.title:E` | missing_gloss=102, original=3 | missing_gloss=105 | missing_gloss=3, original=102 |
| `guidelines:guidelines_v1.json:references.title:F` | missing_official_title=2 | missing_official_title=2 | original=2 |
| `guidelines:guidelines_v1.json:sections.*.body:B` | authored=174 | draft=174 | draft=174 |
| `guidelines:guidelines_v1.json:sections.*.title:B` | authored=174 | draft=174 | draft=174 |
| `guidelines:guidelines_v1.json:summary:B` | authored=23 | draft=23 | draft=23 |
| `guidelines:guidelines_v1.json:title:B` | authored=23 | draft=23 | draft=23 |

## Faqat inglizcha chizadigan joylar (render sites)

| fayl:qator | tur | kod |
|---|---|---|

## O‘quv testi auditi (qisqa)

```json
{
 "items_total": 274,
 "by_kind": {
  "topicExcerpt": 38,
  "substanceFormula": 137,
  "guidelineSummary": 23,
  "guidelineQuestion": 76
 },
 "auto_distractors_from_other_entries": 198,
 "cross_deck_distractors_items": 21,
 "authored_distractors": 76,
 "english_quote_stem": 38,
 "english_quote_stem_with_uz_translation_unused": 38,
 "without_page": 216,
 "without_any_locator": 41,
 "with_page": 58,
 "with_explanation": 0,
 "mode_proposal": {
  "practice_only": 198,
  "graded_after_explanation": 76
 },
 "decks": {
  "discipline.analyticalScience": 10,
  "discipline.forensicAnthropology": 2,
  "discipline.forensicBiochemistry": 9,
  "discipline.forensicHistology": 2,
  "discipline.forensicMedicine": 8,
  "discipline.forensicOdontology": 1,
  "discipline.forensicPathology": 1,
  "discipline.forensicToxicology": 1,
  "discipline.forensic_entomology": 1,
  "discipline.forensic_genetics": 1,
  "discipline.forensic_microbiology": 1,
  "discipline.humanIdentification": 1,
  "group.adulterants": 2,
  "group.alcohols_volatiles": 10,
  "group.anticonvulsants": 6,
  "group.antidepressants": 11,
  "group.antipsychotics": 6,
  "group.barbiturates": 4,
  "group.benzodiazepines": 14,
  "group.cannabinoids": 7,
  "group.hallucinogens_dissociatives": 6,
  "group.metals_inorganic": 2,
  "group.opioids": 27,
  "group.pesticides": 11,
  "group.pharmaceuticals": 10,
  "group.sedatives_hypnotics": 2,
  "group.stimulants": 14,
  "group.toxic_gases": 5,
  "guideline.anthro": 1,
  "guideline.chem": 19,
  "guideline.path": 1,
  "guideline.tox": 2,
  "teaching.gmt": 42,
  "teaching.toks": 34
 },
 "decks_with_1_item": [
  "discipline.forensicOdontology",
  "discipline.forensicPathology",
  "discipline.forensicToxicology",
  "discipline.forensic_entomology",
  "discipline.forensic_genetics",
  "discipline.forensic_microbiology",
  "discipline.humanIdentification",
  "guideline.anthro",
  "guideline.path"
 ],
 "decks_with_lt_4_items": [
  "discipline.forensicAnthropology",
  "discipline.forensicHistology",
  "discipline.forensicOdontology",
  "discipline.forensicPathology",
  "discipline.forensicToxicology",
  "discipline.forensic_entomology",
  "discipline.forensic_genetics",
  "discipline.forensic_microbiology",
  "discipline.humanIdentification",
  "group.adulterants",
  "group.metals_inorganic",
  "group.sedatives_hypnotics",
  "guideline.anthro",
  "guideline.path",
  "guideline.tox"
 ]
}
```

## Terminologiya (uz): kanonik shakl va uchraydigan variantlar

| termin | kanonik (egasi) | variantlar (soni) |
|---|---|---|
| PMI | O‘limdan keyin o‘tgan vaqt oralig‘i (PMI) | `PMI`=12; `o‘limdan keyin o‘tgan vaqt oralig‘i`=5; `o‘limdan keyin o‘tgan vaqt`=3; `o‘lim vaqti`=2; `O‘lim vaqti`=1 |
| PMR | O‘limdan keyingi qayta taqsimlanish (PMR) | `PMR`=13; `o‘limdan keyingi qayta taqsimlanish`=11; `o‘limdan keyingi qayta taqsimlanishni`=2 |
| LC-MS/MS | Suyuqlik xromatografiyasi — tandem mass-spektrometriya (LC-MS/MS) | `LC-MS/MS`=41; `SX-MS`=39; `YuSSX`=30; `suyuqlik xromatografiyasi-tandem mass-spektrometriya`=14; `LC-MS`=11; `suyuqlik xromatografiyasi-mass-spektrometriya`=4; `LC-MS-MS`=3; `UPLC-MS/MS`=2; `suyuqlik xromatografiyasi - tandem mass-spektrometriya`=1 |
| GC-MS | Gaz xromatografiyasi — mass-spektrometriya (GC-MS) | `GX-MS`=56; `GC-MS`=44; `gaz xromatografiyasi-mass-spektrometriya`=13; `gaz xromatografiyasi/mass-spektrometriya`=2; `gaz xromatografiyasi - mass-spektrometriya`=1; `xromato-mass-spektrometriya`=1 |
| COHb | Karboksigemoglobin (COHb) | `COHb`=33; `karboksigemoglobin`=6; `karboksigemoglobinga`=1 |
| Vd | Taqsimlanish hajmi (Vd) | `taqsimlanish hajmi`=4 |
| Rf | Rf (ushlanish omili) | `Rf`=39 |

## Qamrov (bo‘lim → toifa:til → holat)

| bo‘lim | toifa:til | holatlar |
|---|---|---|
| 01_home | A:en | present=149 |
| 01_home | A:ru | present=149 |
| 01_home | A:uz | present=149 |
| 02_disciplines | A:en | present=126 |
| 02_disciplines | A:ru | present=126 |
| 02_disciplines | A:uz | present=126 |
| 02_disciplines | B:en | present=2 |
| 02_disciplines | B:ru | present=2 |
| 02_disciplines | B:uz | present=2 |
| 03_library | A:en | present=190 |
| 03_library | A:ru | present=190 |
| 03_library | A:uz | present=190 |
| 03_library | B:en | authored=66, machine_draft=71, no_status=312, original=34 |
| 03_library | B:ru | machine_draft=71, missing=100, no_status=312 |
| 03_library | B:uz | machine_draft=71, missing=100, no_status=312 |
| 03_library | D:en | original=271 |
| 03_library | D:ru | machine_draft=263, missing=8 |
| 03_library | D:uz | machine_draft=263, missing=8 |
| 03_library | G:en | invariant=161 |
| 03_library | G:ru | invariant=161 |
| 03_library | G:uz | invariant=161 |
| 04_research | A:en | present=136 |
| 04_research | A:ru | present=136 |
| 04_research | A:uz | present=136 |
| 04_research | E:en | original=883 |
| 04_research | E:ru | missing_gloss=883 |
| 04_research | E:uz | missing_gloss=883 |
| 05_guidelines | A:en | present=90 |
| 05_guidelines | A:ru | present=90 |
| 05_guidelines | A:uz | present=90 |
| 05_guidelines | B:en | draft=266 |
| 05_guidelines | B:ru | draft=266 |
| 05_guidelines | B:uz | authored=266 |
| 06_reagents | A:en | present=34 |
| 06_reagents | A:ru | present=34 |
| 06_reagents | A:uz | present=34 |
| 06_reagents | B:en | machine_draft=885, no_status=76 |
| 06_reagents | B:ru | machine_draft=880, missing=5, no_status=76 |
| 06_reagents | B:uz | machine_draft=880, missing=5, no_status=76 |
| 06_reagents | D:en | n/a (strukturali tarjima bor)=74, original=5 |
| 06_reagents | D:ru | machine_draft=5, original=74 |
| 06_reagents | D:uz | machine_draft=5, n/a (strukturali tarjima bor)=74 |
| 07_narcotics | A:en | present=111 |
| 07_narcotics | A:ru | present=111 |
| 07_narcotics | A:uz | present=111 |
| 07_narcotics | B:en | authored=3, draft=151, machine_draft=66, no_status=16 |
| 07_narcotics | B:ru | draft=151, machine_draft=66, missing=10, no_status=9 |
| 07_narcotics | B:uz | authored=151, machine_draft=66, missing=10, no_status=9 |
| 07_narcotics | D:en | original=1 |
| 07_narcotics | D:ru | machine_draft=1 |
| 07_narcotics | D:uz | machine_draft=1 |
| 07_narcotics | F:en | machine_draft=2, official=60, official/original=6 |
| 07_narcotics | F:ru | machine_draft=5, missing=62, official/original=1 |
| 07_narcotics | F:uz | machine_draft=6, missing=62 |
| 08_toxicology | A:en | present=70 |
| 08_toxicology | A:ru | present=70 |
| 08_toxicology | A:uz | present=70 |
| 08_toxicology | B:en | authored=21, no_status=39 |
| 08_toxicology | B:ru | missing=21, no_status=39 |
| 08_toxicology | B:uz | missing=21, no_status=39 |
| 08_toxicology | D:en | original=47 |
| 08_toxicology | D:ru | machine_draft=38, machine_draft (via claim)=9 |
| 08_toxicology | D:uz | machine_draft=38, machine_draft (via claim)=9 |
| 09_forensic_medicine | A:en | present=26 |
| 09_forensic_medicine | A:ru | present=26 |
| 09_forensic_medicine | A:uz | present=26 |
| 09_forensic_medicine | B:en | no_status=21 |
| 09_forensic_medicine | B:ru | no_status=21 |
| 09_forensic_medicine | B:uz | no_status=21 |
| 09_forensic_medicine | D:en | original=33 |
| 09_forensic_medicine | D:ru | machine_draft=33 |
| 09_forensic_medicine | D:uz | machine_draft=33 |
| 10_histology | B:en | no_status=6 |
| 10_histology | B:ru | no_status=6 |
| 10_histology | B:uz | no_status=6 |
| 11_biology | B:en | no_status=16 |
| 11_biology | B:ru | no_status=16 |
| 11_biology | B:uz | no_status=16 |
| 11_biology | D:en | original=17 |
| 11_biology | D:ru | machine_draft=17 |
| 11_biology | D:uz | machine_draft=17 |
| 14_glossary | A:en | present=16 |
| 14_glossary | A:ru | present=16 |
| 14_glossary | A:uz | present=16 |
| 14_glossary | B:en | machine_draft=103 |
| 14_glossary | B:ru | machine_draft=103 |
| 14_glossary | B:uz | machine_draft=103 |
| 14_glossary | G:en | machine_draft=3 |
| 14_glossary | G:ru | machine_draft=3 |
| 14_glossary | G:uz | machine_draft=3 |
| 15_study | A:en | present=94 |
| 15_study | A:ru | present=94 |
| 15_study | A:uz | present=94 |
| 15_study | B:en | present=2 |
| 15_study | B:ru | present=2 |
| 15_study | B:uz | present=2 |
| 15_study | C:en | draft=380 |
| 15_study | C:ru | draft=380 |
| 15_study | C:uz | authored=380 |
| 16_court | A:en | present=106 |
| 16_court | A:ru | present=106 |
| 16_court | A:uz | present=106 |
| 16_court | B:en | no_status=34 |
| 16_court | B:ru | no_status=34 |
| 16_court | B:uz | no_status=34 |
| 16_court | C:en | draft=626, no_status=69 |
| 16_court | C:ru | draft=626, no_status=69 |
| 16_court | C:uz | authored=626, no_status=69 |
| 16_court | F:en | missing_official_title=1, original=1 |
| 16_court | F:ru | missing_official_title=1, original=1 |
| 16_court | F:uz | missing_official_title=2 |
| 17_ai | A:en | present=79 |
| 17_ai | A:ru | present=79 |
| 17_ai | A:uz | present=79 |
| 18_tools | A:en | present=251 |
| 18_tools | A:ru | present=251 |
| 18_tools | A:uz | present=251 |
| 18_tools | E:en | present=1 |
| 18_tools | E:ru | present=1 |
| 18_tools | E:uz | present=1 |
| 19_free_pro | A:en | present=102 |
| 19_free_pro | A:ru | present=102 |
| 19_free_pro | A:uz | present=102 |
| 20_auth_profile | A:en | present=260 |
| 20_auth_profile | A:ru | present=260 |
| 20_auth_profile | A:uz | present=260 |
| 20_auth_profile | B:en | present=258 |
| 20_auth_profile | B:ru | present=258 |
| 20_auth_profile | B:uz | present=258 |
| 21_admin | A:en | present=132 |
| 21_admin | A:ru | present=132 |
| 21_admin | A:uz | present=132 |
| 22_support | A:en | present=55 |
| 22_support | A:ru | present=55 |
| 22_support | A:uz | present=55 |
| 23_errors | A:en | hardcoded=1, present=36 |
| 23_errors | A:ru | hardcoded=1, present=36 |
| 23_errors | A:uz | hardcoded=1, present=36 |
| 23_errors | B:en | authored=8 |
| 23_errors | B:ru | missing=8 |
| 23_errors | B:uz | missing=8 |
| 24_empty_loading | A:en | present=5 |
| 24_empty_loading | A:ru | present=5 |
| 24_empty_loading | A:uz | present=5 |
| 26_privacy_terms | A:en | present=28 |
| 26_privacy_terms | A:ru | present=28 |
| 26_privacy_terms | A:uz | present=28 |
| 27_offline | A:en | present=2 |
| 27_offline | A:ru | present=2 |
| 27_offline | A:uz | present=2 |
| 28_sources_citation | A:en | present=109 |
| 28_sources_citation | A:ru | present=109 |
| 28_sources_citation | A:uz | present=109 |
| 28_sources_citation | B:en | authored=8, missing=1 |
| 28_sources_citation | B:ru | authored=1, missing=8 |
| 28_sources_citation | B:uz | missing=9 |
| 28_sources_citation | E:en | missing_gloss=6, original=683 |
| 28_sources_citation | E:ru | missing_gloss=688, original=1 |
| 28_sources_citation | E:uz | missing_gloss=684, original=5 |
| 28_sources_citation | F:en | original=2 |
| 28_sources_citation | F:ru | missing_official_title=2 |
| 28_sources_citation | F:uz | missing_official_title=2 |

## Topilmalar (birinchi 400; to‘liq ro‘yxat — JSON)

| # | daraja | qoida | til | manba | jadval/fayl | ID | maydon | toifa | parcha | izoh |
|---:|---|---|---|---|---|---|---|---|---|---|
| 1 | error | MISSING_TRANSLATION | ru | content.db | `authorities` | `AUTH-DE-BTMG-ANL` | names_json | B | Bundesministerium der Justiz (Veröffentlichung) | ilova boshqa tilga qaytadi (fallback) |
| 2 | error | MISSING_TRANSLATION | uz | content.db | `authorities` | `AUTH-DE-BTMG-ANL` | names_json | B | Bundesministerium der Justiz (Veröffentlichung) | ilova boshqa tilga qaytadi (fallback) |
| 3 | error | MISSING_TRANSLATION | ru | content.db | `authorities` | `AUTH-GB-MDA-1971-SCH2` | names_json | B | Parliament of the United Kingdom | ilova boshqa tilga qaytadi (fallback) |
| 4 | error | MISSING_TRANSLATION | uz | content.db | `authorities` | `AUTH-GB-MDA-1971-SCH2` | names_json | B | Parliament of the United Kingdom | ilova boshqa tilga qaytadi (fallback) |
| 5 | error | MISSING_TRANSLATION | ru | content.db | `authorities` | `AUTH-GB-PARLIAMENT` | names_json | B | Parliament of the United Kingdom | ilova boshqa tilga qaytadi (fallback) |
| 6 | error | MISSING_TRANSLATION | uz | content.db | `authorities` | `AUTH-GB-PARLIAMENT` | names_json | B | Parliament of the United Kingdom | ilova boshqa tilga qaytadi (fallback) |
| 7 | error | MISSING_TRANSLATION | ru | content.db | `authorities` | `AUTH-GB-SCT-MINISTERS` | names_json | B | The Scottish Ministers | ilova boshqa tilga qaytadi (fallback) |
| 8 | error | MISSING_TRANSLATION | uz | content.db | `authorities` | `AUTH-GB-SCT-MINISTERS` | names_json | B | The Scottish Ministers | ilova boshqa tilga qaytadi (fallback) |
| 9 | error | MISSING_TRANSLATION | ru | content.db | `authorities` | `AUTH-US-21CFR1308` | names_json | B | Drug Enforcement Administration (DEA), U.S. Department of Justice | ilova boshqa tilga qaytadi (fallback) |
| 10 | error | MISSING_TRANSLATION | uz | content.db | `authorities` | `AUTH-US-21CFR1308` | names_json | B | Drug Enforcement Administration (DEA), U.S. Department of Justice | ilova boshqa tilga qaytadi (fallback) |
| 11 | error | CYRILLIC_IN_EN | en | content.db | `authorities` | `AUTH-UZ-LAW-813-I` | names_json | B | Олий Мажлис Республики Узбекистан | ОлийМажлисРе |
| 12 | error | MISSING_TRANSLATION | ru | content.db | `authorities` | `AUTH-UZ-LAW-813-I` | names_json | B | Олий Мажлис Республики Узбекистан | ilova boshqa tilga qaytadi (fallback) |
| 13 | error | MISSING_TRANSLATION | uz | content.db | `authorities` | `AUTH-UZ-LAW-813-I` | names_json | B | Олий Мажлис Республики Узбекистан | ilova boshqa tilga qaytadi (fallback) |
| 14 | error | MISSING_TRANSLATION | ru | content.db | `claims` | `C-6-MAM-REPORTED_CONCENTRATION-P5` | context_strict.case_type | B | heroin-related fatalities | ilova boshqa tilga qaytadi (fallback) |
| 15 | error | MISSING_TRANSLATION | uz | content.db | `claims` | `C-6-MAM-REPORTED_CONCENTRATION-P5` | context_strict.case_type | B | heroin-related fatalities | ilova boshqa tilga qaytadi (fallback) |
| 16 | error | MISSING_TRANSLATION | ru | content.db | `claims` | `C-6-MAM-REPORTED_CONCENTRATION-P5` | context_strict.limitations[0] | B | Second matrix is given as 'BNaF'; the abbreviation is not expanded in the excerpt. | ilova boshqa tilga qaytadi (fallback) |
| 17 | error | MISSING_TRANSLATION | uz | content.db | `claims` | `C-6-MAM-REPORTED_CONCENTRATION-P5` | context_strict.limitations[0] | B | Second matrix is given as 'BNaF'; the abbreviation is not expanded in the excerpt. | ilova boshqa tilga qaytadi (fallback) |
| 18 | error | MISSING_TRANSLATION | ru | content.db | `claims` | `C-6-MAM-REPORTED_CONCENTRATION-P5` | context_strict.limitations[1] | B | Values refer to one age group only. | ilova boshqa tilga qaytadi (fallback) |
| 19 | error | MISSING_TRANSLATION | uz | content.db | `claims` | `C-6-MAM-REPORTED_CONCENTRATION-P5` | context_strict.limitations[1] | B | Values refer to one age group only. | ilova boshqa tilga qaytadi (fallback) |
| 20 | error | MISSING_TRANSLATION | ru | content.db | `claims` | `C-6-MAM-REPORTED_CONCENTRATION-P5` | context_strict.population | B | heroin-related fatalities, Jeddah 2008–2018; 61–70-year age group | ilova boshqa tilga qaytadi (fallback) |
| 21 | error | MISSING_TRANSLATION | uz | content.db | `claims` | `C-6-MAM-REPORTED_CONCENTRATION-P5` | context_strict.population | B | heroin-related fatalities, Jeddah 2008–2018; 61–70-year age group | ilova boshqa tilga qaytadi (fallback) |
| 22 | error | MISSING_TRANSLATION | ru | content.db | `claims` | `C-6-MAM-REPORTED_CONCENTRATION-P5` | context_strict.statistic | B | median 21 ng/mL (BNaF); median 52 ng/mL (vitreous humor) | ilova boshqa tilga qaytadi (fallback) |
| 23 | error | MISSING_TRANSLATION | uz | content.db | `claims` | `C-6-MAM-REPORTED_CONCENTRATION-P5` | context_strict.statistic | B | median 21 ng/mL (BNaF); median 52 ng/mL (vitreous humor) | ilova boshqa tilga qaytadi (fallback) |
| 24 | error | MISSING_TRANSLATION | ru | content.db | `claims` | `C-ALPRAZOLAM-REPORTED_CONCENTRATION-P5` | context_strict.case_type | B | alprazolam toxicity | ilova boshqa tilga qaytadi (fallback) |
| 25 | error | MISSING_TRANSLATION | uz | content.db | `claims` | `C-ALPRAZOLAM-REPORTED_CONCENTRATION-P5` | context_strict.case_type | B | alprazolam toxicity | ilova boshqa tilga qaytadi (fallback) |
| 26 | error | MISSING_TRANSLATION | ru | content.db | `claims` | `C-ALPRAZOLAM-REPORTED_CONCENTRATION-P5` | context_strict.limitations[0] | B | Cited from other authors. | ilova boshqa tilga qaytadi (fallback) |
| 27 | error | MISSING_TRANSLATION | uz | content.db | `claims` | `C-ALPRAZOLAM-REPORTED_CONCENTRATION-P5` | context_strict.limitations[0] | B | Cited from other authors. | ilova boshqa tilga qaytadi (fallback) |
| 28 | error | MISSING_TRANSLATION | ru | content.db | `claims` | `C-ALPRAZOLAM-REPORTED_CONCENTRATION-P5` | context_strict.limitations[1] | B | Outcome of the two cases is not stated in the excerpt. | ilova boshqa tilga qaytadi (fallback) |
| 29 | error | MISSING_TRANSLATION | uz | content.db | `claims` | `C-ALPRAZOLAM-REPORTED_CONCENTRATION-P5` | context_strict.limitations[1] | B | Outcome of the two cases is not stated in the excerpt. | ilova boshqa tilga qaytadi (fallback) |
| 30 | error | MISSING_TRANSLATION | ru | content.db | `claims` | `C-ALPRAZOLAM-REPORTED_CONCENTRATION-P5` | context_strict.population | B | two alprazolam toxicity cases | ilova boshqa tilga qaytadi (fallback) |
| 31 | error | MISSING_TRANSLATION | uz | content.db | `claims` | `C-ALPRAZOLAM-REPORTED_CONCENTRATION-P5` | context_strict.population | B | two alprazolam toxicity cases | ilova boshqa tilga qaytadi (fallback) |
| 32 | error | MISSING_TRANSLATION | ru | content.db | `claims` | `C-ALPRAZOLAM-REPORTED_CONCENTRATION-P5` | context_strict.statistic | B | 32.8 and 13.0 ng/mL | ilova boshqa tilga qaytadi (fallback) |
| 33 | error | MISSING_TRANSLATION | uz | content.db | `claims` | `C-ALPRAZOLAM-REPORTED_CONCENTRATION-P5` | context_strict.statistic | B | 32.8 and 13.0 ng/mL | ilova boshqa tilga qaytadi (fallback) |
| 34 | error | MISSING_TRANSLATION | ru | content.db | `claims` | `C-ALUMINIUM-PHOSPHIDE-TRANSFORMATION_PRODUCT` | value_json.items[] | B | phosphine gas | ilova boshqa tilga qaytadi (fallback) |
| 35 | error | MISSING_TRANSLATION | uz | content.db | `claims` | `C-ALUMINIUM-PHOSPHIDE-TRANSFORMATION_PRODUCT` | value_json.items[] | B | phosphine gas | ilova boshqa tilga qaytadi (fallback) |
| 36 | error | MISSING_TRANSLATION | ru | content.db | `claims` | `C-AMPHETAMINE-REPORTED_CONCENTRATION-P5` | context_strict.case_type | B | fatal oral amphetamine ingestion (case reports) | ilova boshqa tilga qaytadi (fallback) |
| 37 | error | MISSING_TRANSLATION | uz | content.db | `claims` | `C-AMPHETAMINE-REPORTED_CONCENTRATION-P5` | context_strict.case_type | B | fatal oral amphetamine ingestion (case reports) | ilova boshqa tilga qaytadi (fallback) |
| 38 | error | MISSING_TRANSLATION | ru | content.db | `claims` | `C-AMPHETAMINE-REPORTED_CONCENTRATION-P5` | context_strict.limitations[0] | B | Highest values only; different units (μg/mL vs μg/g). | ilova boshqa tilga qaytadi (fallback) |
| 39 | error | MISSING_TRANSLATION | uz | content.db | `claims` | `C-AMPHETAMINE-REPORTED_CONCENTRATION-P5` | context_strict.limitations[0] | B | Highest values only; different units (μg/mL vs μg/g). | ilova boshqa tilga qaytadi (fallback) |
| 40 | error | MISSING_TRANSLATION | ru | content.db | `claims` | `C-AMPHETAMINE-REPORTED_CONCENTRATION-P5` | context_strict.limitations[1] | B | Two cases — not generalisable. | ilova boshqa tilga qaytadi (fallback) |
| 41 | error | MISSING_TRANSLATION | uz | content.db | `claims` | `C-AMPHETAMINE-REPORTED_CONCENTRATION-P5` | context_strict.limitations[1] | B | Two cases — not generalisable. | ilova boshqa tilga qaytadi (fallback) |
| 42 | error | MISSING_TRANSLATION | ru | content.db | `claims` | `C-AMPHETAMINE-REPORTED_CONCENTRATION-P5` | context_strict.population | B | two fatal cases after oral ingestion | ilova boshqa tilga qaytadi (fallback) |
| 43 | error | MISSING_TRANSLATION | uz | content.db | `claims` | `C-AMPHETAMINE-REPORTED_CONCENTRATION-P5` | context_strict.population | B | two fatal cases after oral ingestion | ilova boshqa tilga qaytadi (fallback) |
| 44 | error | MISSING_TRANSLATION | ru | content.db | `claims` | `C-AMPHETAMINE-REPORTED_CONCENTRATION-P5` | context_strict.statistic | B | highest values: urine 2600 μg/mL (case 1); stomach content 14,000 μg/g (case 2) | ilova boshqa tilga qaytadi (fallback) |
| 45 | error | MISSING_TRANSLATION | uz | content.db | `claims` | `C-AMPHETAMINE-REPORTED_CONCENTRATION-P5` | context_strict.statistic | B | highest values: urine 2600 μg/mL (case 1); stomach content 14,000 μg/g (case 2) | ilova boshqa tilga qaytadi (fallback) |
| 46 | error | MISSING_TRANSLATION | ru | content.db | `claims` | `C-BENZOYLECGONINE-REPORTED_CONCENTRATION-P5` | context_strict.case_type | B | drivers tested for alcohol/drugs | ilova boshqa tilga qaytadi (fallback) |
| 47 | error | MISSING_TRANSLATION | uz | content.db | `claims` | `C-BENZOYLECGONINE-REPORTED_CONCENTRATION-P5` | context_strict.case_type | B | drivers tested for alcohol/drugs | ilova boshqa tilga qaytadi (fallback) |
| 48 | error | MISSING_TRANSLATION | ru | content.db | `claims` | `C-BENZOYLECGONINE-REPORTED_CONCENTRATION-P5` | context_strict.limitations[0] | B | Median across all positive drivers; not limited to cocaine-only cases. | ilova boshqa tilga qaytadi (fallback) |
| 49 | error | MISSING_TRANSLATION | uz | content.db | `claims` | `C-BENZOYLECGONINE-REPORTED_CONCENTRATION-P5` | context_strict.limitations[0] | B | Median across all positive drivers; not limited to cocaine-only cases. | ilova boshqa tilga qaytadi (fallback) |
| 50 | error | MISSING_TRANSLATION | ru | content.db | `claims` | `C-BENZOYLECGONINE-REPORTED_CONCENTRATION-P5` | context_strict.population | B | motor vehicle drivers in Brittany, France, with at least one positive test | ilova boshqa tilga qaytadi (fallback) |
| 51 | error | MISSING_TRANSLATION | uz | content.db | `claims` | `C-BENZOYLECGONINE-REPORTED_CONCENTRATION-P5` | context_strict.population | B | motor vehicle drivers in Brittany, France, with at least one positive test | ilova boshqa tilga qaytadi (fallback) |
| 52 | error | MISSING_TRANSLATION | ru | content.db | `claims` | `C-BENZOYLECGONINE-REPORTED_CONCENTRATION-P5` | context_strict.statistic | B | median 173.3 ng/mL | ilova boshqa tilga qaytadi (fallback) |
| 53 | error | MISSING_TRANSLATION | uz | content.db | `claims` | `C-BENZOYLECGONINE-REPORTED_CONCENTRATION-P5` | context_strict.statistic | B | median 173.3 ng/mL | ilova boshqa tilga qaytadi (fallback) |
| 54 | error | MISSING_TRANSLATION | ru | content.db | `claims` | `C-COCAINE-REPORTED_CONCENTRATION-P5` | context_strict.case_type | B | stratified: cardiac-related deaths / acute intoxication / chronic or binge use | ilova boshqa tilga qaytadi (fallback) |
| 55 | error | MISSING_TRANSLATION | uz | content.db | `claims` | `C-COCAINE-REPORTED_CONCENTRATION-P5` | context_strict.case_type | B | stratified: cardiac-related deaths / acute intoxication / chronic or binge use | ilova boshqa tilga qaytadi (fallback) |
| 56 | error | MISSING_TRANSLATION | ru | content.db | `claims` | `C-COCAINE-REPORTED_CONCENTRATION-P5` | context_strict.limitations[0] | B | Approximate means quoted in the introduction of another paper. | ilova boshqa tilga qaytadi (fallback) |
| 57 | error | MISSING_TRANSLATION | uz | content.db | `claims` | `C-COCAINE-REPORTED_CONCENTRATION-P5` | context_strict.limitations[0] | B | Approximate means quoted in the introduction of another paper. | ilova boshqa tilga qaytadi (fallback) |
| 58 | error | MISSING_TRANSLATION | ru | content.db | `claims` | `C-COCAINE-REPORTED_CONCENTRATION-P5` | context_strict.population | B | deaths reported to the National Programme on Substance Abuse Deaths (2000–2019) | ilova boshqa tilga qaytadi (fallback) |
| 59 | error | MISSING_TRANSLATION | uz | content.db | `claims` | `C-COCAINE-REPORTED_CONCENTRATION-P5` | context_strict.population | B | deaths reported to the National Programme on Substance Abuse Deaths (2000–2019) | ilova boshqa tilga qaytadi (fallback) |
| 60 | error | MISSING_TRANSLATION | ru | content.db | `claims` | `C-COCAINE-REPORTED_CONCENTRATION-P5` | context_strict.statistic | B | mean ≈900 / ≈19,100 / ≈6,200 ng/mL | ilova boshqa tilga qaytadi (fallback) |
| 61 | error | MISSING_TRANSLATION | uz | content.db | `claims` | `C-COCAINE-REPORTED_CONCENTRATION-P5` | context_strict.statistic | B | mean ≈900 / ≈19,100 / ≈6,200 ng/mL | ilova boshqa tilga qaytadi (fallback) |
| 62 | error | MISSING_TRANSLATION | ru | content.db | `claims` | `C-FENTANYL-REPORTED_CONCENTRATION-P5` | context_strict.case_type | B | natural deaths; fentanyl considered incidental | ilova boshqa tilga qaytadi (fallback) |
| 63 | error | MISSING_TRANSLATION | uz | content.db | `claims` | `C-FENTANYL-REPORTED_CONCENTRATION-P5` | context_strict.case_type | B | natural deaths; fentanyl considered incidental | ilova boshqa tilga qaytadi (fallback) |
| 64 | error | MISSING_TRANSLATION | ru | content.db | `claims` | `C-FENTANYL-REPORTED_CONCENTRATION-P5` | context_strict.limitations[0] | B | Literature values summarised in a case report / literature review. | ilova boshqa tilga qaytadi (fallback) |
| 65 | error | MISSING_TRANSLATION | uz | content.db | `claims` | `C-FENTANYL-REPORTED_CONCENTRATION-P5` | context_strict.limitations[0] | B | Literature values summarised in a case report / literature review. | ilova boshqa tilga qaytadi (fallback) |
| 66 | error | MISSING_TRANSLATION | ru | content.db | `claims` | `C-FENTANYL-REPORTED_CONCENTRATION-P5` | context_strict.limitations[1] | B | Partially overlaps values in fentanyl-attributed deaths (see EVIDENCE CONFLICT). | ilova boshqa tilga qaytadi (fallback) |
| 67 | error | MISSING_TRANSLATION | uz | content.db | `claims` | `C-FENTANYL-REPORTED_CONCENTRATION-P5` | context_strict.limitations[1] | B | Partially overlaps values in fentanyl-attributed deaths (see EVIDENCE CONFLICT). | ilova boshqa tilga qaytadi (fallback) |
| 68 | error | MISSING_TRANSLATION | ru | content.db | `claims` | `C-FENTANYL-REPORTED_CONCENTRATION-P5` | context_strict.population | B | deaths from natural causes with an incidental fentanyl finding | ilova boshqa tilga qaytadi (fallback) |
| 69 | error | MISSING_TRANSLATION | uz | content.db | `claims` | `C-FENTANYL-REPORTED_CONCENTRATION-P5` | context_strict.population | B | deaths from natural causes with an incidental fentanyl finding | ilova boshqa tilga qaytadi (fallback) |
| 70 | error | MISSING_TRANSLATION | ru | content.db | `claims` | `C-FENTANYL-REPORTED_CONCENTRATION-P5` | context_strict.statistic | B | range 2.7–33 ng/mL; mean 12 ng/mL | ilova boshqa tilga qaytadi (fallback) |
| 71 | error | MISSING_TRANSLATION | uz | content.db | `claims` | `C-FENTANYL-REPORTED_CONCENTRATION-P5` | context_strict.statistic | B | range 2.7–33 ng/mL; mean 12 ng/mL | ilova boshqa tilga qaytadi (fallback) |
| 72 | error | MISSING_TRANSLATION | ru | content.db | `claims` | `C-MDMA-REPORTED_CONCENTRATION-P5` | context_strict.case_type | B | coronial cases | ilova boshqa tilga qaytadi (fallback) |
| 73 | error | MISSING_TRANSLATION | uz | content.db | `claims` | `C-MDMA-REPORTED_CONCENTRATION-P5` | context_strict.case_type | B | coronial cases | ilova boshqa tilga qaytadi (fallback) |
| 74 | error | MISSING_TRANSLATION | ru | content.db | `claims` | `C-MDMA-REPORTED_CONCENTRATION-P5` | context_strict.limitations[0] | B | Coronial cases include deaths not caused by MDMA; cause of death is not in the excerpt. | ilova boshqa tilga qaytadi (fallback) |
| 75 | error | MISSING_TRANSLATION | uz | content.db | `claims` | `C-MDMA-REPORTED_CONCENTRATION-P5` | context_strict.limitations[0] | B | Coronial cases include deaths not caused by MDMA; cause of death is not in the excerpt. | ilova boshqa tilga qaytadi (fallback) |
| 76 | error | MISSING_TRANSLATION | ru | content.db | `claims` | `C-MDMA-REPORTED_CONCENTRATION-P5` | context_strict.population | B | MDMA-positive coronial cases, New Zealand | ilova boshqa tilga qaytadi (fallback) |
| 77 | error | MISSING_TRANSLATION | uz | content.db | `claims` | `C-MDMA-REPORTED_CONCENTRATION-P5` | context_strict.population | B | MDMA-positive coronial cases, New Zealand | ilova boshqa tilga qaytadi (fallback) |
| 78 | error | MISSING_TRANSLATION | ru | content.db | `claims` | `C-MDMA-REPORTED_CONCENTRATION-P5` | context_strict.statistic | B | mean 0.88 mg/L; range 0.01–9.30 mg/L (peripheral blood) | ilova boshqa tilga qaytadi (fallback) |
| 79 | error | MISSING_TRANSLATION | uz | content.db | `claims` | `C-MDMA-REPORTED_CONCENTRATION-P5` | context_strict.statistic | B | mean 0.88 mg/L; range 0.01–9.30 mg/L (peripheral blood) | ilova boshqa tilga qaytadi (fallback) |
| 80 | error | MISSING_TRANSLATION | ru | content.db | `claims` | `C-METHADONE-REPORTED_CONCENTRATION-P5` | context_strict.case_type | B | methadone-related deaths | ilova boshqa tilga qaytadi (fallback) |
| 81 | error | MISSING_TRANSLATION | uz | content.db | `claims` | `C-METHADONE-REPORTED_CONCENTRATION-P5` | context_strict.case_type | B | methadone-related deaths | ilova boshqa tilga qaytadi (fallback) |
| 82 | error | MISSING_TRANSLATION | ru | content.db | `claims` | `C-METHADONE-REPORTED_CONCENTRATION-P5` | context_strict.limitations[0] | B | The 400–1000 ng/mL range quoted alongside refers to living patients in methadone maintenance treatment, not t… | ilova boshqa tilga qaytadi (fallback) |
| 83 | error | MISSING_TRANSLATION | uz | content.db | `claims` | `C-METHADONE-REPORTED_CONCENTRATION-P5` | context_strict.limitations[0] | B | The 400–1000 ng/mL range quoted alongside refers to living patients in methadone maintenance treatment, not t… | ilova boshqa tilga qaytadi (fallback) |
| 84 | error | MISSING_TRANSLATION | ru | content.db | `claims` | `C-METHADONE-REPORTED_CONCENTRATION-P5` | context_strict.limitations[1] | B | Post-mortem values overlap living-patient values (see EVIDENCE CONFLICT). | ilova boshqa tilga qaytadi (fallback) |
| 85 | error | MISSING_TRANSLATION | uz | content.db | `claims` | `C-METHADONE-REPORTED_CONCENTRATION-P5` | context_strict.limitations[1] | B | Post-mortem values overlap living-patient values (see EVIDENCE CONFLICT). | ilova boshqa tilga qaytadi (fallback) |
| 86 | error | MISSING_TRANSLATION | ru | content.db | `claims` | `C-METHADONE-REPORTED_CONCENTRATION-P5` | context_strict.population | B | adult methadone-related deaths (compared with children) | ilova boshqa tilga qaytadi (fallback) |
| 87 | error | MISSING_TRANSLATION | uz | content.db | `claims` | `C-METHADONE-REPORTED_CONCENTRATION-P5` | context_strict.population | B | adult methadone-related deaths (compared with children) | ilova boshqa tilga qaytadi (fallback) |
| 88 | error | MISSING_TRANSLATION | ru | content.db | `claims` | `C-METHADONE-REPORTED_CONCENTRATION-P5` | context_strict.statistic | B | mean 503 ng/mL (adults) | ilova boshqa tilga qaytadi (fallback) |
| 89 | error | MISSING_TRANSLATION | uz | content.db | `claims` | `C-METHADONE-REPORTED_CONCENTRATION-P5` | context_strict.statistic | B | mean 503 ng/mL (adults) | ilova boshqa tilga qaytadi (fallback) |
| 90 | error | MISSING_TRANSLATION | ru | content.db | `claims` | `C-METHAMPHETAMINE-REPORTED_CONCENTRATION-P5` | context_strict.case_type | B | methamphetamine-positive post-mortem cases | ilova boshqa tilga qaytadi (fallback) |
| 91 | error | MISSING_TRANSLATION | uz | content.db | `claims` | `C-METHAMPHETAMINE-REPORTED_CONCENTRATION-P5` | context_strict.case_type | B | methamphetamine-positive post-mortem cases | ilova boshqa tilga qaytadi (fallback) |
| 92 | error | MISSING_TRANSLATION | ru | content.db | `claims` | `C-METHAMPHETAMINE-REPORTED_CONCENTRATION-P5` | context_strict.co_intoxicants | B | compared: methamphetamine only vs multiple substances | ilova boshqa tilga qaytadi (fallback) |
| 93 | error | MISSING_TRANSLATION | uz | content.db | `claims` | `C-METHAMPHETAMINE-REPORTED_CONCENTRATION-P5` | context_strict.co_intoxicants | B | compared: methamphetamine only vs multiple substances | ilova boshqa tilga qaytadi (fallback) |
| 94 | error | MISSING_TRANSLATION | ru | content.db | `claims` | `C-METHAMPHETAMINE-REPORTED_CONCENTRATION-P5` | context_strict.limitations[0] | B | SD exceeds the mean — strongly skewed distribution. | ilova boshqa tilga qaytadi (fallback) |
| 95 | error | MISSING_TRANSLATION | uz | content.db | `claims` | `C-METHAMPHETAMINE-REPORTED_CONCENTRATION-P5` | context_strict.limitations[0] | B | SD exceeds the mean — strongly skewed distribution. | ilova boshqa tilga qaytadi (fallback) |
| 96 | error | MISSING_TRANSLATION | ru | content.db | `claims` | `C-METHAMPHETAMINE-REPORTED_CONCENTRATION-P5` | context_strict.population | B | nation-wide 7-year post-mortem study (see source) | ilova boshqa tilga qaytadi (fallback) |
| 97 | error | MISSING_TRANSLATION | uz | content.db | `claims` | `C-METHAMPHETAMINE-REPORTED_CONCENTRATION-P5` | context_strict.population | B | nation-wide 7-year post-mortem study (see source) | ilova boshqa tilga qaytadi (fallback) |
| 98 | error | MISSING_TRANSLATION | ru | content.db | `claims` | `C-METHAMPHETAMINE-REPORTED_CONCENTRATION-P5` | context_strict.statistic | B | mean 2.68 (SD 13.7) vs 1.62 (SD 7.59) µg/mL; P = 0.255 (not significant) | ilova boshqa tilga qaytadi (fallback) |
| 99 | error | MISSING_TRANSLATION | uz | content.db | `claims` | `C-METHAMPHETAMINE-REPORTED_CONCENTRATION-P5` | context_strict.statistic | B | mean 2.68 (SD 13.7) vs 1.62 (SD 7.59) µg/mL; P = 0.255 (not significant) | ilova boshqa tilga qaytadi (fallback) |
| 100 | error | MISSING_TRANSLATION | ru | content.db | `claims` | `C-METHANOL-METABOLITES` | value_json.items[] | B | formic acid | ilova boshqa tilga qaytadi (fallback) |
| 101 | error | MISSING_TRANSLATION | uz | content.db | `claims` | `C-METHANOL-METABOLITES` | value_json.items[] | B | formic acid | ilova boshqa tilga qaytadi (fallback) |
| 102 | error | MISSING_TRANSLATION | ru | content.db | `claims` | `C-MORPHINE-REPORTED_CONCENTRATION-P5` | context_strict.case_type | B | deaths with morphine findings | ilova boshqa tilga qaytadi (fallback) |
| 103 | error | MISSING_TRANSLATION | uz | content.db | `claims` | `C-MORPHINE-REPORTED_CONCENTRATION-P5` | context_strict.case_type | B | deaths with morphine findings | ilova boshqa tilga qaytadi (fallback) |
| 104 | error | MISSING_TRANSLATION | ru | content.db | `claims` | `C-MORPHINE-REPORTED_CONCENTRATION-P5` | context_strict.co_intoxicants | B | stratified: none / alcohol / benzodiazepines / alcohol + benzodiazepines | ilova boshqa tilga qaytadi (fallback) |
| 105 | error | MISSING_TRANSLATION | uz | content.db | `claims` | `C-MORPHINE-REPORTED_CONCENTRATION-P5` | context_strict.co_intoxicants | B | stratified: none / alcohol / benzodiazepines / alcohol + benzodiazepines | ilova boshqa tilga qaytadi (fallback) |
| 106 | error | MISSING_TRANSLATION | ru | content.db | `claims` | `C-MORPHINE-REPORTED_CONCENTRATION-P5` | context_strict.limitations[0] | B | Analyte reported as free morphine. | ilova boshqa tilga qaytadi (fallback) |
| 107 | error | MISSING_TRANSLATION | uz | content.db | `claims` | `C-MORPHINE-REPORTED_CONCENTRATION-P5` | context_strict.limitations[0] | B | Analyte reported as free morphine. | ilova boshqa tilga qaytadi (fallback) |
| 108 | error | MISSING_TRANSLATION | ru | content.db | `claims` | `C-MORPHINE-REPORTED_CONCENTRATION-P5` | context_strict.limitations[1] | B | Group medians only; ranges and group sizes are not in the excerpt. | ilova boshqa tilga qaytadi (fallback) |
| 109 | error | MISSING_TRANSLATION | uz | content.db | `claims` | `C-MORPHINE-REPORTED_CONCENTRATION-P5` | context_strict.limitations[1] | B | Group medians only; ranges and group sizes are not in the excerpt. | ilova boshqa tilga qaytadi (fallback) |
| 110 | error | MISSING_TRANSLATION | ru | content.db | `claims` | `C-MORPHINE-REPORTED_CONCENTRATION-P5` | context_strict.population | B | morphine deaths (study cohort; see source) | ilova boshqa tilga qaytadi (fallback) |
| 111 | error | MISSING_TRANSLATION | uz | content.db | `claims` | `C-MORPHINE-REPORTED_CONCENTRATION-P5` | context_strict.population | B | morphine deaths (study cohort; see source) | ilova boshqa tilga qaytadi (fallback) |
| 112 | error | MISSING_TRANSLATION | ru | content.db | `claims` | `C-MORPHINE-REPORTED_CONCENTRATION-P5` | context_strict.statistic | B | median per group: 0.30 / 0.40 / 0.53 / 0.80 μg/mL | ilova boshqa tilga qaytadi (fallback) |
| 113 | error | MISSING_TRANSLATION | uz | content.db | `claims` | `C-MORPHINE-REPORTED_CONCENTRATION-P5` | context_strict.statistic | B | median per group: 0.30 / 0.40 / 0.53 / 0.80 μg/mL | ilova boshqa tilga qaytadi (fallback) |
| 114 | error | MISSING_TRANSLATION | ru | content.db | `claims` | `C-PREGABALIN-METABOLISM_NOTE` | value_json.items[] | B | negligible metabolism | ilova boshqa tilga qaytadi (fallback) |
| 115 | error | MISSING_TRANSLATION | ru | content.db | `claims` | `C-PREGABALIN-METABOLISM_NOTE` | value_json.items[] | B | almost exclusive renal elimination | ilova boshqa tilga qaytadi (fallback) |
| 116 | error | MISSING_TRANSLATION | uz | content.db | `claims` | `C-PREGABALIN-METABOLISM_NOTE` | value_json.items[] | B | negligible metabolism | ilova boshqa tilga qaytadi (fallback) |
| 117 | error | MISSING_TRANSLATION | uz | content.db | `claims` | `C-PREGABALIN-METABOLISM_NOTE` | value_json.items[] | B | almost exclusive renal elimination | ilova boshqa tilga qaytadi (fallback) |
| 118 | error | MISSING_TRANSLATION | ru | content.db | `claims` | `C-PREGABALIN-REPORTED_CONCENTRATION-P5` | context_strict.case_type | B | drug-related deaths | ilova boshqa tilga qaytadi (fallback) |
| 119 | error | MISSING_TRANSLATION | uz | content.db | `claims` | `C-PREGABALIN-REPORTED_CONCENTRATION-P5` | context_strict.case_type | B | drug-related deaths | ilova boshqa tilga qaytadi (fallback) |
| 120 | error | MISSING_TRANSLATION | ru | content.db | `claims` | `C-PREGABALIN-REPORTED_CONCENTRATION-P5` | context_strict.limitations[0] | B | National data quoted for comparison, not measured in the citing study. | ilova boshqa tilga qaytadi (fallback) |
| 121 | error | MISSING_TRANSLATION | uz | content.db | `claims` | `C-PREGABALIN-REPORTED_CONCENTRATION-P5` | context_strict.limitations[0] | B | National data quoted for comparison, not measured in the citing study. | ilova boshqa tilga qaytadi (fallback) |
| 122 | error | MISSING_TRANSLATION | ru | content.db | `claims` | `C-PREGABALIN-REPORTED_CONCENTRATION-P5` | context_strict.population | B | drug-related deaths, Australia, 2000–2020 | ilova boshqa tilga qaytadi (fallback) |
| 123 | error | MISSING_TRANSLATION | uz | content.db | `claims` | `C-PREGABALIN-REPORTED_CONCENTRATION-P5` | context_strict.population | B | drug-related deaths, Australia, 2000–2020 | ilova boshqa tilga qaytadi (fallback) |
| 124 | error | MISSING_TRANSLATION | ru | content.db | `claims` | `C-PREGABALIN-REPORTED_CONCENTRATION-P5` | context_strict.statistic | B | mean 16.3 mg/L | ilova boshqa tilga qaytadi (fallback) |
| 125 | error | MISSING_TRANSLATION | uz | content.db | `claims` | `C-PREGABALIN-REPORTED_CONCENTRATION-P5` | context_strict.statistic | B | mean 16.3 mg/L | ilova boshqa tilga qaytadi (fallback) |
| 126 | error | MISSING_TRANSLATION | ru | content.db | `claims` | `C-THC-COOH-REPORTED_CONCENTRATION-P5` | context_strict.case_type | B | cannabis-related case reports | ilova boshqa tilga qaytadi (fallback) |
| 127 | error | MISSING_TRANSLATION | uz | content.db | `claims` | `C-THC-COOH-REPORTED_CONCENTRATION-P5` | context_strict.case_type | B | cannabis-related case reports | ilova boshqa tilga qaytadi (fallback) |
| 128 | error | MISSING_TRANSLATION | ru | content.db | `claims` | `C-THC-COOH-REPORTED_CONCENTRATION-P5` | context_strict.limitations[0] | B | Kidney tissue values are written in ng/mL in the source — reviewer to check units. | ilova boshqa tilga qaytadi (fallback) |
| 129 | error | MISSING_TRANSLATION | uz | content.db | `claims` | `C-THC-COOH-REPORTED_CONCENTRATION-P5` | context_strict.limitations[0] | B | Kidney tissue values are written in ng/mL in the source — reviewer to check units. | ilova boshqa tilga qaytadi (fallback) |
| 130 | error | MISSING_TRANSLATION | ru | content.db | `claims` | `C-THC-COOH-REPORTED_CONCENTRATION-P5` | context_strict.population | B | case study reports (see source) | ilova boshqa tilga qaytadi (fallback) |
| 131 | error | MISSING_TRANSLATION | uz | content.db | `claims` | `C-THC-COOH-REPORTED_CONCENTRATION-P5` | context_strict.population | B | case study reports (see source) | ilova boshqa tilga qaytadi (fallback) |
| 132 | error | MISSING_TRANSLATION | ru | content.db | `claims` | `C-THC-COOH-REPORTED_CONCENTRATION-P5` | context_strict.statistic | B | range 8.0–3894 ng/g (liver); 3–1774 ng/mL (kidney, as written) | ilova boshqa tilga qaytadi (fallback) |
| 133 | error | MISSING_TRANSLATION | uz | content.db | `claims` | `C-THC-COOH-REPORTED_CONCENTRATION-P5` | context_strict.statistic | B | range 8.0–3894 ng/g (liver); 3–1774 ng/mL (kidney, as written) | ilova boshqa tilga qaytadi (fallback) |
| 134 | error | MISSING_TRANSLATION | ru | content.db | `claims` | `C-THC-REPORTED_CONCENTRATION-P5` | context_strict.case_type | B | paediatric cannabis intoxication | ilova boshqa tilga qaytadi (fallback) |
| 135 | error | MISSING_TRANSLATION | uz | content.db | `claims` | `C-THC-REPORTED_CONCENTRATION-P5` | context_strict.case_type | B | paediatric cannabis intoxication | ilova boshqa tilga qaytadi (fallback) |
| 136 | error | MISSING_TRANSLATION | ru | content.db | `claims` | `C-THC-REPORTED_CONCENTRATION-P5` | context_strict.limitations[0] | B | Cited from another study. | ilova boshqa tilga qaytadi (fallback) |
| 137 | error | MISSING_TRANSLATION | uz | content.db | `claims` | `C-THC-REPORTED_CONCENTRATION-P5` | context_strict.limitations[0] | B | Cited from another study. | ilova boshqa tilga qaytadi (fallback) |
| 138 | error | MISSING_TRANSLATION | ru | content.db | `claims` | `C-THC-REPORTED_CONCENTRATION-P5` | context_strict.limitations[1] | B | Time since exposure not stated in the excerpt. | ilova boshqa tilga qaytadi (fallback) |
| 139 | error | MISSING_TRANSLATION | uz | content.db | `claims` | `C-THC-REPORTED_CONCENTRATION-P5` | context_strict.limitations[1] | B | Time since exposure not stated in the excerpt. | ilova boshqa tilga qaytadi (fallback) |
| 140 | error | MISSING_TRANSLATION | ru | content.db | `claims` | `C-THC-REPORTED_CONCENTRATION-P5` | context_strict.population | B | paediatric cannabis intoxication cases, France | ilova boshqa tilga qaytadi (fallback) |
| 141 | error | MISSING_TRANSLATION | uz | content.db | `claims` | `C-THC-REPORTED_CONCENTRATION-P5` | context_strict.population | B | paediatric cannabis intoxication cases, France | ilova boshqa tilga qaytadi (fallback) |
| 142 | error | MISSING_TRANSLATION | ru | content.db | `claims` | `C-THC-REPORTED_CONCENTRATION-P5` | context_strict.statistic | B | mean THC 29 ng/mL; 11-OH-THC 21 ng/mL; THC-COOH 255 ng/mL (plasma) | ilova boshqa tilga qaytadi (fallback) |
| 143 | error | MISSING_TRANSLATION | uz | content.db | `claims` | `C-THC-REPORTED_CONCENTRATION-P5` | context_strict.statistic | B | mean THC 29 ng/mL; 11-OH-THC 21 ng/mL; THC-COOH 255 ng/mL (plasma) | ilova boshqa tilga qaytadi (fallback) |
| 144 | error | MISSING_TRANSLATION | ru | content.db | `claims` | `C-TRAMADOL-REPORTED_CONCENTRATION-P5` | context_strict.case_type | B | tramadol poisoning with hypoglycaemia and cardiac arrest (fatal outcome) | ilova boshqa tilga qaytadi (fallback) |
| 145 | error | MISSING_TRANSLATION | uz | content.db | `claims` | `C-TRAMADOL-REPORTED_CONCENTRATION-P5` | context_strict.case_type | B | tramadol poisoning with hypoglycaemia and cardiac arrest (fatal outcome) | ilova boshqa tilga qaytadi (fallback) |
| 146 | error | MISSING_TRANSLATION | ru | content.db | `claims` | `C-TRAMADOL-REPORTED_CONCENTRATION-P5` | context_strict.limitations[0] | B | Value is cited from an earlier report, not measured by the citing authors. | ilova boshqa tilga qaytadi (fallback) |
| 147 | error | MISSING_TRANSLATION | uz | content.db | `claims` | `C-TRAMADOL-REPORTED_CONCENTRATION-P5` | context_strict.limitations[0] | B | Value is cited from an earlier report, not measured by the citing authors. | ilova boshqa tilga qaytadi (fallback) |
| 148 | error | MISSING_TRANSLATION | ru | content.db | `claims` | `C-TRAMADOL-REPORTED_CONCENTRATION-P5` | context_strict.limitations[1] | B | Whether the plasma sample was taken before or after death is not stated in the excerpt. | ilova boshqa tilga qaytadi (fallback) |
| 149 | error | MISSING_TRANSLATION | uz | content.db | `claims` | `C-TRAMADOL-REPORTED_CONCENTRATION-P5` | context_strict.limitations[1] | B | Whether the plasma sample was taken before or after death is not stated in the excerpt. | ilova boshqa tilga qaytadi (fallback) |
| 150 | error | MISSING_TRANSLATION | ru | content.db | `claims` | `C-TRAMADOL-REPORTED_CONCENTRATION-P5` | context_strict.population | B | single previously reported case | ilova boshqa tilga qaytadi (fallback) |
| 151 | error | MISSING_TRANSLATION | uz | content.db | `claims` | `C-TRAMADOL-REPORTED_CONCENTRATION-P5` | context_strict.population | B | single previously reported case | ilova boshqa tilga qaytadi (fallback) |
| 152 | error | MISSING_TRANSLATION | ru | content.db | `claims` | `C-TRAMADOL-REPORTED_CONCENTRATION-P5` | context_strict.statistic | B | single value 5.2 mg/L (plasma) | ilova boshqa tilga qaytadi (fallback) |
| 153 | error | MISSING_TRANSLATION | uz | content.db | `claims` | `C-TRAMADOL-REPORTED_CONCENTRATION-P5` | context_strict.statistic | B | single value 5.2 mg/L (plasma) | ilova boshqa tilga qaytadi (fallback) |
| 154 | error | MISSING_TRANSLATION | ru | content.db | `evidence_conflicts` | `CF-FENTANYL-INCIDENTAL` | note | B | The source reports partial overlap with blood values in natural-cause deaths where fentanyl was considered in… | ilova boshqa tilga qaytadi (fallback) |
| 155 | error | MISSING_TRANSLATION | uz | content.db | `evidence_conflicts` | `CF-FENTANYL-INCIDENTAL` | note | B | The source reports partial overlap with blood values in natural-cause deaths where fentanyl was considered in… | ilova boshqa tilga qaytadi (fallback) |
| 156 | error | MISSING_TRANSLATION | ru | content.db | `evidence_conflicts` | `CF-FENTANYL-INCIDENTAL` | question | B | Can a fentanyl blood concentration alone separate fentanyl-attributed deaths from incidental findings? | ilova boshqa tilga qaytadi (fallback) |
| 157 | error | MISSING_TRANSLATION | uz | content.db | `evidence_conflicts` | `CF-FENTANYL-INCIDENTAL` | question | B | Can a fentanyl blood concentration alone separate fentanyl-attributed deaths from incidental findings? | ilova boshqa tilga qaytadi (fallback) |
| 158 | error | MISSING_TRANSLATION | ru | content.db | `evidence_conflicts` | `CF-METHADONE-PM-VS-LIVING` | note | B | The source states that the mean adult post-mortem concentration (503 ng/mL) overlaps the range reported in li… | ilova boshqa tilga qaytadi (fallback) |
| 159 | error | MISSING_TRANSLATION | uz | content.db | `evidence_conflicts` | `CF-METHADONE-PM-VS-LIVING` | note | B | The source states that the mean adult post-mortem concentration (503 ng/mL) overlaps the range reported in li… | ilova boshqa tilga qaytadi (fallback) |
| 160 | error | MISSING_TRANSLATION | ru | content.db | `evidence_conflicts` | `CF-METHADONE-PM-VS-LIVING` | question | B | Does a post-mortem methadone blood concentration distinguish toxicity from therapeutic use? | ilova boshqa tilga qaytadi (fallback) |
| 161 | error | MISSING_TRANSLATION | uz | content.db | `evidence_conflicts` | `CF-METHADONE-PM-VS-LIVING` | question | B | Does a post-mortem methadone blood concentration distinguish toxicity from therapeutic use? | ilova boshqa tilga qaytadi (fallback) |
| 162 | error | MISSING_TRANSLATION | ru | content.db | `evidence_conflicts` | `CF-TRAMADOL-M2-ACTIVITY` | note | B | One source names only O-desmethyltramadol as the active metabolite and M2 simply as 'the metabolite M2'; anot… | ilova boshqa tilga qaytadi (fallback) |
| 163 | error | MISSING_TRANSLATION | uz | content.db | `evidence_conflicts` | `CF-TRAMADOL-M2-ACTIVITY` | note | B | One source names only O-desmethyltramadol as the active metabolite and M2 simply as 'the metabolite M2'; anot… | ilova boshqa tilga qaytadi (fallback) |
| 164 | error | MISSING_TRANSLATION | ru | content.db | `evidence_conflicts` | `CF-TRAMADOL-M2-ACTIVITY` | question | B | Is N-desmethyltramadol (M2) described as an active metabolite? | ilova boshqa tilga qaytadi (fallback) |
| 165 | error | MISSING_TRANSLATION | uz | content.db | `evidence_conflicts` | `CF-TRAMADOL-M2-ACTIVITY` | question | B | Is N-desmethyltramadol (M2) described as an active metabolite? | ilova boshqa tilga qaytadi (fallback) |
| 166 | error | MISSING_TRANSLATION | ru | content.db | `evidence_conflicts` | `CF-VITREOUS-K-PMI` | note | B | One source reports a linear rise of vitreous potassium with advancing PMI; another reports an inconsistent in… | ilova boshqa tilga qaytadi (fallback) |
| 167 | error | MISSING_TRANSLATION | uz | content.db | `evidence_conflicts` | `CF-VITREOUS-K-PMI` | note | B | One source reports a linear rise of vitreous potassium with advancing PMI; another reports an inconsistent in… | ilova boshqa tilga qaytadi (fallback) |
| 168 | error | MISSING_TRANSLATION | ru | content.db | `evidence_conflicts` | `CF-VITREOUS-K-PMI` | question | B | Can vitreous potassium be used to estimate the post-mortem interval? | ilova boshqa tilga qaytadi (fallback) |
| 169 | error | MISSING_TRANSLATION | uz | content.db | `evidence_conflicts` | `CF-VITREOUS-K-PMI` | question | B | Can vitreous potassium be used to estimate the post-mortem interval? | ilova boshqa tilga qaytadi (fallback) |
| 170 | error | MISSING_TRANSLATION | ru | content.db | `jurisdictional_instruments` | `DE-BTMG-ANL` | official_reference (editorial) | B | BtMG 1981, Anlagen I–III — consolidated text retrieved 2026-10-04; date of entry into force not recorded (NEE… | ilova boshqa tilga qaytadi (fallback) |
| 171 | error | MISSING_TRANSLATION | uz | content.db | `jurisdictional_instruments` | `DE-BTMG-ANL` | official_reference (editorial) | B | BtMG 1981, Anlagen I–III — consolidated text retrieved 2026-10-04; date of entry into force not recorded (NEE… | ilova boshqa tilga qaytadi (fallback) |
| 172 | error | MISSING_TRANSLATION | ru | content.db | `jurisdictional_instruments` | `US-21CFR1308` | official_reference (editorial) | B | 21 CFR 1308.11–1308.15 — consolidated text retrieved 2026-10-04; date of entry into force not recorded (NEEDS… | ilova boshqa tilga qaytadi (fallback) |
| 173 | error | MISSING_TRANSLATION | uz | content.db | `jurisdictional_instruments` | `US-21CFR1308` | official_reference (editorial) | B | 21 CFR 1308.11–1308.15 — consolidated text retrieved 2026-10-04; date of entry into force not recorded (NEEDS… | ilova boshqa tilga qaytadi (fallback) |
| 174 | error | MISSING_TRANSLATION | ru | content.db | `jurisdictional_instruments` | `UZ-LAW-813-I` | official_reference (editorial) | B | № 813-I — consolidated text retrieved 2026-10-04; date of entry into force not recorded (NEEDS LEGAL REVIEW) | ilova boshqa tilga qaytadi (fallback) |
| 175 | error | MISSING_TRANSLATION | uz | content.db | `jurisdictional_instruments` | `UZ-LAW-813-I` | official_reference (editorial) | B | № 813-I — consolidated text retrieved 2026-10-04; date of entry into force not recorded (NEEDS LEGAL REVIEW) | ilova boshqa tilga qaytadi (fallback) |
| 176 | error | MISSING_TRANSLATION | ru | content.db | `jurisdictions` | `INT` | names_json | B | International | ilova boshqa tilga qaytadi (fallback) |
| 177 | error | MISSING_TRANSLATION | uz | content.db | `jurisdictions` | `INT` | names_json | B | International | ilova boshqa tilga qaytadi (fallback) |
| 178 | error | MISSING_TRANSLATION | ru | content.db | `knowledge_entities` | `reagent-dragendorff` | payload.ingredients[5].name | B | distilled water | ilova boshqa tilga qaytadi (fallback) |
| 179 | error | MISSING_TRANSLATION | uz | content.db | `knowledge_entities` | `reagent-dragendorff` | payload.ingredients[5].name | B | distilled water | ilova boshqa tilga qaytadi (fallback) |
| 180 | error | MISSING_TRANSLATION | ru | content.db | `knowledge_entities` | `reagent-dragendorff` | payload.ingredients[6].name | B | acetic acid | ilova boshqa tilga qaytadi (fallback) |
| 181 | error | MISSING_TRANSLATION | uz | content.db | `knowledge_entities` | `reagent-dragendorff` | payload.ingredients[6].name | B | acetic acid | ilova boshqa tilga qaytadi (fallback) |
| 182 | error | MISSING_TRANSLATION | ru | content.db | `knowledge_entities` | `reagent-dragendorff` | payload.ingredients[7].name | B | potassium iodide solution, 40 g% (w/v) | ilova boshqa tilga qaytadi (fallback) |
| 183 | error | MISSING_TRANSLATION | uz | content.db | `knowledge_entities` | `reagent-dragendorff` | payload.ingredients[7].name | B | potassium iodide solution, 40 g% (w/v) | ilova boshqa tilga qaytadi (fallback) |
| 184 | error | MISSING_TRANSLATION | ru | content.db | `knowledge_entities` | `reagent-dragendorff` | payload.ingredients[8].name | B | basic bismuth nitrate, 1.7 g% w/v in 20% v/v acetic acid | ilova boshqa tilga qaytadi (fallback) |
| 185 | error | MISSING_TRANSLATION | uz | content.db | `knowledge_entities` | `reagent-dragendorff` | payload.ingredients[8].name | B | basic bismuth nitrate, 1.7 g% w/v in 20% v/v acetic acid | ilova boshqa tilga qaytadi (fallback) |
| 186 | error | MISSING_TRANSLATION | ru | content.db | `knowledge_entities` | `reagent-dragendorff` | payload.steps[3] | B | Dragendorff’s reagent was prepared by mixing 70 mL distilled water and 20 mL acetic acid with 5 mL of 40 g% p… | ilova boshqa tilga qaytadi (fallback) |
| 187 | error | MISSING_TRANSLATION | uz | content.db | `knowledge_entities` | `reagent-dragendorff` | payload.steps[3] | B | Dragendorff’s reagent was prepared by mixing 70 mL distilled water and 20 mL acetic acid with 5 mL of 40 g% p… | ilova boshqa tilga qaytadi (fallback) |
| 188 | error | MISSING_TRANSLATION | ru | content.db | `knowledge_entities` | `scr-colour-tests` | payload.analyte | B | various (presumptive) | ilova boshqa tilga qaytadi (fallback) |
| 189 | error | MISSING_TRANSLATION | uz | content.db | `knowledge_entities` | `scr-colour-tests` | payload.analyte | B | various (presumptive) | ilova boshqa tilga qaytadi (fallback) |
| 190 | error | MISSING_TRANSLATION | ru | content.db | `knowledge_entities` | `scr-colour-tests` | payload.principle | B | colour (spot) reaction | ilova boshqa tilga qaytadi (fallback) |
| 191 | error | MISSING_TRANSLATION | uz | content.db | `knowledge_entities` | `scr-colour-tests` | payload.principle | B | colour (spot) reaction | ilova boshqa tilga qaytadi (fallback) |
| 192 | error | MISSING_TRANSLATION | ru | content.db | `knowledge_entities` | `scr-colour-tests` | payload.specimen | B | seized material (see source) | ilova boshqa tilga qaytadi (fallback) |
| 193 | error | MISSING_TRANSLATION | uz | content.db | `knowledge_entities` | `scr-colour-tests` | payload.specimen | B | seized material (see source) | ilova boshqa tilga qaytadi (fallback) |
| 194 | error | MISSING_TRANSLATION | ru | content.db | `knowledge_entities` | `scr-fentanyl-test-strips` | payload.analyte | B | fentanyl and some analogues (see source) | ilova boshqa tilga qaytadi (fallback) |
| 195 | error | MISSING_TRANSLATION | uz | content.db | `knowledge_entities` | `scr-fentanyl-test-strips` | payload.analyte | B | fentanyl and some analogues (see source) | ilova boshqa tilga qaytadi (fallback) |
| 196 | error | MISSING_TRANSLATION | ru | content.db | `knowledge_entities` | `scr-fentanyl-test-strips` | payload.principle | B | test strip (see source) | ilova boshqa tilga qaytadi (fallback) |
| 197 | error | MISSING_TRANSLATION | uz | content.db | `knowledge_entities` | `scr-fentanyl-test-strips` | payload.principle | B | test strip (see source) | ilova boshqa tilga qaytadi (fallback) |
| 198 | error | MISSING_TRANSLATION | ru | content.db | `knowledge_entities` | `scr-fentanyl-test-strips` | payload.specimen | B | not specified in source | ilova boshqa tilga qaytadi (fallback) |
| 199 | error | MISSING_TRANSLATION | uz | content.db | `knowledge_entities` | `scr-fentanyl-test-strips` | payload.specimen | B | not specified in source | ilova boshqa tilga qaytadi (fallback) |
| 200 | error | MISSING_TRANSLATION | ru | content.db | `knowledge_entities` | `scr-immunoassay-amphetamines` | payload.analyte | B | amphetamines (class-based) | ilova boshqa tilga qaytadi (fallback) |
| 201 | error | MISSING_TRANSLATION | uz | content.db | `knowledge_entities` | `scr-immunoassay-amphetamines` | payload.analyte | B | amphetamines (class-based) | ilova boshqa tilga qaytadi (fallback) |
| 202 | error | MISSING_TRANSLATION | ru | content.db | `knowledge_entities` | `scr-immunoassay-amphetamines` | payload.principle | B | immunoassay | ilova boshqa tilga qaytadi (fallback) |
| 203 | error | MISSING_TRANSLATION | uz | content.db | `knowledge_entities` | `scr-immunoassay-amphetamines` | payload.principle | B | immunoassay | ilova boshqa tilga qaytadi (fallback) |
| 204 | error | MISSING_TRANSLATION | ru | content.db | `knowledge_entities` | `scr-immunoassay-amphetamines` | payload.specimen | B | not specified in source | ilova boshqa tilga qaytadi (fallback) |
| 205 | error | MISSING_TRANSLATION | uz | content.db | `knowledge_entities` | `scr-immunoassay-amphetamines` | payload.specimen | B | not specified in source | ilova boshqa tilga qaytadi (fallback) |
| 206 | error | MISSING_TRANSLATION | ru | content.db | `knowledge_entities` | `scr-immunoassay-cannabinoids` | payload.analyte | B | THC metabolites (class-based) | ilova boshqa tilga qaytadi (fallback) |
| 207 | error | MISSING_TRANSLATION | uz | content.db | `knowledge_entities` | `scr-immunoassay-cannabinoids` | payload.analyte | B | THC metabolites (class-based) | ilova boshqa tilga qaytadi (fallback) |
| 208 | error | MISSING_TRANSLATION | ru | content.db | `knowledge_entities` | `scr-immunoassay-cannabinoids` | payload.principle | B | immunoassay | ilova boshqa tilga qaytadi (fallback) |
| 209 | error | MISSING_TRANSLATION | uz | content.db | `knowledge_entities` | `scr-immunoassay-cannabinoids` | payload.principle | B | immunoassay | ilova boshqa tilga qaytadi (fallback) |
| 210 | error | MISSING_TRANSLATION | ru | content.db | `knowledge_entities` | `scr-immunoassay-cannabinoids` | payload.specimen | B | not specified in source | ilova boshqa tilga qaytadi (fallback) |
| 211 | error | MISSING_TRANSLATION | uz | content.db | `knowledge_entities` | `scr-immunoassay-cannabinoids` | payload.specimen | B | not specified in source | ilova boshqa tilga qaytadi (fallback) |
| 212 | error | MISSING_TRANSLATION | ru | content.db | `knowledge_entities` | `scr-immunoassay-drugs` | payload.analyte | B | drugs of abuse (class-based; see source) | ilova boshqa tilga qaytadi (fallback) |
| 213 | error | MISSING_TRANSLATION | uz | content.db | `knowledge_entities` | `scr-immunoassay-drugs` | payload.analyte | B | drugs of abuse (class-based; see source) | ilova boshqa tilga qaytadi (fallback) |
| 214 | error | MISSING_TRANSLATION | ru | content.db | `knowledge_entities` | `scr-immunoassay-drugs` | payload.principle | B | immunoassay | ilova boshqa tilga qaytadi (fallback) |
| 215 | error | MISSING_TRANSLATION | uz | content.db | `knowledge_entities` | `scr-immunoassay-drugs` | payload.principle | B | immunoassay | ilova boshqa tilga qaytadi (fallback) |
| 216 | error | MISSING_TRANSLATION | ru | content.db | `knowledge_entities` | `scr-immunoassay-drugs` | payload.specimen | B | not specified in source | ilova boshqa tilga qaytadi (fallback) |
| 217 | error | MISSING_TRANSLATION | uz | content.db | `knowledge_entities` | `scr-immunoassay-drugs` | payload.specimen | B | not specified in source | ilova boshqa tilga qaytadi (fallback) |
| 218 | error | MISSING_TRANSLATION | ru | content.db | `knowledge_entities` | `scr-immunoassay-fentanyl` | payload.analyte | B | fentanyl (class-based) | ilova boshqa tilga qaytadi (fallback) |
| 219 | error | MISSING_TRANSLATION | uz | content.db | `knowledge_entities` | `scr-immunoassay-fentanyl` | payload.analyte | B | fentanyl (class-based) | ilova boshqa tilga qaytadi (fallback) |
| 220 | error | MISSING_TRANSLATION | ru | content.db | `knowledge_entities` | `scr-immunoassay-fentanyl` | payload.principle | B | immunoassay | ilova boshqa tilga qaytadi (fallback) |
| 221 | error | MISSING_TRANSLATION | uz | content.db | `knowledge_entities` | `scr-immunoassay-fentanyl` | payload.principle | B | immunoassay | ilova boshqa tilga qaytadi (fallback) |
| 222 | error | MISSING_TRANSLATION | ru | content.db | `knowledge_entities` | `scr-immunoassay-fentanyl` | payload.specimen | B | not specified in source | ilova boshqa tilga qaytadi (fallback) |
| 223 | error | MISSING_TRANSLATION | uz | content.db | `knowledge_entities` | `scr-immunoassay-fentanyl` | payload.specimen | B | not specified in source | ilova boshqa tilga qaytadi (fallback) |
| 224 | error | MISSING_TRANSLATION | ru | content.db | `knowledge_entities` | `scr-immunoassay-opiates` | payload.analyte | B | opiates (class-based) | ilova boshqa tilga qaytadi (fallback) |
| 225 | error | MISSING_TRANSLATION | uz | content.db | `knowledge_entities` | `scr-immunoassay-opiates` | payload.analyte | B | opiates (class-based) | ilova boshqa tilga qaytadi (fallback) |
| 226 | error | MISSING_TRANSLATION | ru | content.db | `knowledge_entities` | `scr-immunoassay-opiates` | payload.principle | B | immunoassay | ilova boshqa tilga qaytadi (fallback) |
| 227 | error | MISSING_TRANSLATION | uz | content.db | `knowledge_entities` | `scr-immunoassay-opiates` | payload.principle | B | immunoassay | ilova boshqa tilga qaytadi (fallback) |
| 228 | error | MISSING_TRANSLATION | ru | content.db | `knowledge_entities` | `scr-immunoassay-opiates` | payload.specimen | B | not specified in source | ilova boshqa tilga qaytadi (fallback) |
| 229 | error | MISSING_TRANSLATION | uz | content.db | `knowledge_entities` | `scr-immunoassay-opiates` | payload.specimen | B | not specified in source | ilova boshqa tilga qaytadi (fallback) |
| 230 | error | UZBEK_IN_EN | en | content.db | `sources` | `SRC-FE-EDITORIAL` | title (app-authored) | B | FORENSIC EXPERT — tahririy izohlar (umumiy xavfsizlik tavsiyalari, manba noaniqliklari); ilmiy manba emas | emas manba |
| 231 | error | MISSING_TRANSLATION | ru | content.db | `sources` | `SRC-FE-EDITORIAL` | title (app-authored) | B | FORENSIC EXPERT — tahririy izohlar (umumiy xavfsizlik tavsiyalari, manba noaniqliklari); ilmiy manba emas | ilova boshqa tilga qaytadi (fallback) |
| 232 | error | MISSING_TRANSLATION | uz | content.db | `sources` | `SRC-FE-EDITORIAL` | title (app-authored) | B | FORENSIC EXPERT — tahririy izohlar (umumiy xavfsizlik tavsiyalari, manba noaniqliklari); ilmiy manba emas | ilova boshqa tilga qaytadi (fallback) |
| 233 | error | MISSING_TRANSLATION | en | content.db | `sources` | `SRC-OWNER-REAGENTS` | title (app-authored) | B | «Приготовление реактивов» — reagent preparation compilation (toxicological chemistry), 74 entries | ilova boshqa tilga qaytadi (fallback) |
| 234 | error | MISSING_TRANSLATION | uz | content.db | `sources` | `SRC-OWNER-REAGENTS` | title (app-authored) | B | «Приготовление реактивов» — reagent preparation compilation (toxicological chemistry), 74 entries | ilova boshqa tilga qaytadi (fallback) |
| 235 | error | MISSING_TRANSLATION | ru | content.db | `standards` | `STD-ASB-017-25` | note | B | Listed on the OSAC Registry (SDO published standard). Text not reproduced. | ilova boshqa tilga qaytadi (fallback) |
| 236 | error | MISSING_TRANSLATION | uz | content.db | `standards` | `STD-ASB-017-25` | note | B | Listed on the OSAC Registry (SDO published standard). Text not reproduced. | ilova boshqa tilga qaytadi (fallback) |
| 237 | error | MISSING_TRANSLATION | ru | content.db | `standards` | `STD-ASB-056-25` | note | B | Listed on the OSAC Registry (SDO published standard). Text not reproduced. | ilova boshqa tilga qaytadi (fallback) |
| 238 | error | MISSING_TRANSLATION | uz | content.db | `standards` | `STD-ASB-056-25` | note | B | Listed on the OSAC Registry (SDO published standard). Text not reproduced. | ilova boshqa tilga qaytadi (fallback) |
| 239 | error | MISSING_TRANSLATION | ru | content.db | `standards` | `STD-ASTM-E2329-25` | note | B | Listed on the OSAC Registry (SDO published standard). Text not reproduced. | ilova boshqa tilga qaytadi (fallback) |
| 240 | error | MISSING_TRANSLATION | uz | content.db | `standards` | `STD-ASTM-E2329-25` | note | B | Listed on the OSAC Registry (SDO published standard). Text not reproduced. | ilova boshqa tilga qaytadi (fallback) |
| 241 | error | MISSING_TRANSLATION | ru | content.db | `standards` | `STD-ICH-Q2R1` | note | B | Superseded by Q2(R2) (complete revision; history table in Q2(R2)). | ilova boshqa tilga qaytadi (fallback) |
| 242 | error | MISSING_TRANSLATION | uz | content.db | `standards` | `STD-ICH-Q2R1` | note | B | Superseded by Q2(R2) (complete revision; history table in Q2(R2)). | ilova boshqa tilga qaytadi (fallback) |
| 243 | error | MISSING_TRANSLATION | ru | content.db | `standards` | `STD-ICH-Q2R2` | note | B | Pharmaceutical scope; applicability to forensic methods is a laboratory decision. | ilova boshqa tilga qaytadi (fallback) |
| 244 | error | MISSING_TRANSLATION | uz | content.db | `standards` | `STD-ICH-Q2R2` | note | B | Pharmaceutical scope; applicability to forensic methods is a laboratory decision. | ilova boshqa tilga qaytadi (fallback) |
| 245 | error | MISSING_TRANSLATION | ru | content.db | `standards` | `STD-OSAC-2025-S-0010` | note | B | OSAC Proposed Standard, in SDO development — not a published SDO standard. | ilova boshqa tilga qaytadi (fallback) |
| 246 | error | MISSING_TRANSLATION | uz | content.db | `standards` | `STD-OSAC-2025-S-0010` | note | B | OSAC Proposed Standard, in SDO development — not a published SDO standard. | ilova boshqa tilga qaytadi (fallback) |
| 247 | error | MISSING_TRANSLATION | ru | content.db | `standards` | `STD-UNODC-ST-NAR-41` | note | B | Status 'current' means no successor was found on the publisher page; not a statement of endorsement. | ilova boshqa tilga qaytadi (fallback) |
| 248 | error | MISSING_TRANSLATION | uz | content.db | `standards` | `STD-UNODC-ST-NAR-41` | note | B | Status 'current' means no successor was found on the publisher page; not a statement of endorsement. | ilova boshqa tilga qaytadi (fallback) |
| 249 | warn | MISSING_TRANSLATION | ru | content.db | `claims` | `C-ALPRAZOLAM-METABOLITES` | value_json.items[] | B | 4-hydroxyalprazolam | ilova boshqa tilga qaytadi (fallback) |
| 250 | warn | MISSING_TRANSLATION | ru | content.db | `claims` | `C-ALPRAZOLAM-METABOLITES` | value_json.items[] | B | α-hydroxyalprazolam | ilova boshqa tilga qaytadi (fallback) |
| 251 | warn | MISSING_TRANSLATION | uz | content.db | `claims` | `C-ALPRAZOLAM-METABOLITES` | value_json.items[] | B | 4-hydroxyalprazolam | ilova boshqa tilga qaytadi (fallback) |
| 252 | warn | MISSING_TRANSLATION | uz | content.db | `claims` | `C-ALPRAZOLAM-METABOLITES` | value_json.items[] | B | α-hydroxyalprazolam | ilova boshqa tilga qaytadi (fallback) |
| 253 | warn | MISSING_TRANSLATION | ru | content.db | `claims` | `C-AMITRIPTYLINE-METABOLITES` | value_json.items[] | B | nortriptyline | ilova boshqa tilga qaytadi (fallback) |
| 254 | warn | MISSING_TRANSLATION | uz | content.db | `claims` | `C-AMITRIPTYLINE-METABOLITES` | value_json.items[] | B | nortriptyline | ilova boshqa tilga qaytadi (fallback) |
| 255 | warn | MISSING_TRANSLATION | ru | content.db | `claims` | `C-CARBON-MONOXIDE-BIOMARKER` | value_json.items[] | B | Carboxyhaemoglobin (COHb) | ilova boshqa tilga qaytadi (fallback) |
| 256 | warn | MISSING_TRANSLATION | uz | content.db | `claims` | `C-CARBON-MONOXIDE-BIOMARKER` | value_json.items[] | B | Carboxyhaemoglobin (COHb) | ilova boshqa tilga qaytadi (fallback) |
| 257 | warn | MISSING_TRANSLATION | ru | content.db | `claims` | `C-CHLORPYRIFOS-METABOLITES` | value_json.items[] | B | chlorpyrifos-oxon | ilova boshqa tilga qaytadi (fallback) |
| 258 | warn | MISSING_TRANSLATION | uz | content.db | `claims` | `C-CHLORPYRIFOS-METABOLITES` | value_json.items[] | B | chlorpyrifos-oxon | ilova boshqa tilga qaytadi (fallback) |
| 259 | warn | MISSING_TRANSLATION | ru | content.db | `claims` | `C-COCAINE-METABOLITES` | value_json.items[] | B | EME | ilova boshqa tilga qaytadi (fallback) |
| 260 | warn | MISSING_TRANSLATION | ru | content.db | `claims` | `C-COCAINE-METABOLITES` | value_json.items[] | B | BE | ilova boshqa tilga qaytadi (fallback) |
| 261 | warn | MISSING_TRANSLATION | ru | content.db | `claims` | `C-COCAINE-METABOLITES` | value_json.items[] | B | ecgonine (EC) | ilova boshqa tilga qaytadi (fallback) |
| 262 | warn | MISSING_TRANSLATION | uz | content.db | `claims` | `C-COCAINE-METABOLITES` | value_json.items[] | B | EME | ilova boshqa tilga qaytadi (fallback) |
| 263 | warn | MISSING_TRANSLATION | uz | content.db | `claims` | `C-COCAINE-METABOLITES` | value_json.items[] | B | BE | ilova boshqa tilga qaytadi (fallback) |
| 264 | warn | MISSING_TRANSLATION | uz | content.db | `claims` | `C-COCAINE-METABOLITES` | value_json.items[] | B | ecgonine (EC) | ilova boshqa tilga qaytadi (fallback) |
| 265 | warn | MISSING_TRANSLATION | ru | content.db | `claims` | `C-ETHANOL-METABOLITES` | value_json.items[] | B | acetaldehyde | ilova boshqa tilga qaytadi (fallback) |
| 266 | warn | MISSING_TRANSLATION | ru | content.db | `claims` | `C-ETHANOL-METABOLITES` | value_json.items[] | B | acetate | ilova boshqa tilga qaytadi (fallback) |
| 267 | warn | MISSING_TRANSLATION | ru | content.db | `claims` | `C-ETHANOL-METABOLITES` | value_json.items[] | B | acetyl-CoA | ilova boshqa tilga qaytadi (fallback) |
| 268 | warn | MISSING_TRANSLATION | uz | content.db | `claims` | `C-ETHANOL-METABOLITES` | value_json.items[] | B | acetaldehyde | ilova boshqa tilga qaytadi (fallback) |
| 269 | warn | MISSING_TRANSLATION | uz | content.db | `claims` | `C-ETHANOL-METABOLITES` | value_json.items[] | B | acetate | ilova boshqa tilga qaytadi (fallback) |
| 270 | warn | MISSING_TRANSLATION | uz | content.db | `claims` | `C-ETHANOL-METABOLITES` | value_json.items[] | B | acetyl-CoA | ilova boshqa tilga qaytadi (fallback) |
| 271 | warn | MISSING_TRANSLATION | ru | content.db | `claims` | `C-ETHYLENE-GLYCOL-METABOLITES` | value_json.items[] | B | glycolaldehyde | ilova boshqa tilga qaytadi (fallback) |
| 272 | warn | MISSING_TRANSLATION | ru | content.db | `claims` | `C-ETHYLENE-GLYCOL-METABOLITES` | value_json.items[] | B | glycolate | ilova boshqa tilga qaytadi (fallback) |
| 273 | warn | MISSING_TRANSLATION | uz | content.db | `claims` | `C-ETHYLENE-GLYCOL-METABOLITES` | value_json.items[] | B | glycolaldehyde | ilova boshqa tilga qaytadi (fallback) |
| 274 | warn | MISSING_TRANSLATION | uz | content.db | `claims` | `C-ETHYLENE-GLYCOL-METABOLITES` | value_json.items[] | B | glycolate | ilova boshqa tilga qaytadi (fallback) |
| 275 | warn | MISSING_TRANSLATION | ru | content.db | `claims` | `C-FENTANYL-METABOLITES` | value_json.items[] | B | norfentanyl | ilova boshqa tilga qaytadi (fallback) |
| 276 | warn | MISSING_TRANSLATION | uz | content.db | `claims` | `C-FENTANYL-METABOLITES` | value_json.items[] | B | norfentanyl | ilova boshqa tilga qaytadi (fallback) |
| 277 | warn | MISSING_TRANSLATION | ru | content.db | `claims` | `C-HEROIN-METABOLITES` | value_json.items[] | B | 6-monoacetylmorphine (6-MAM) | ilova boshqa tilga qaytadi (fallback) |
| 278 | warn | MISSING_TRANSLATION | ru | content.db | `claims` | `C-HEROIN-METABOLITES` | value_json.items[] | B | morphine | ilova boshqa tilga qaytadi (fallback) |
| 279 | warn | MISSING_TRANSLATION | uz | content.db | `claims` | `C-HEROIN-METABOLITES` | value_json.items[] | B | 6-monoacetylmorphine (6-MAM) | ilova boshqa tilga qaytadi (fallback) |
| 280 | warn | MISSING_TRANSLATION | uz | content.db | `claims` | `C-HEROIN-METABOLITES` | value_json.items[] | B | morphine | ilova boshqa tilga qaytadi (fallback) |
| 281 | warn | MISSING_TRANSLATION | ru | content.db | `claims` | `C-METHAMPHETAMINE-METABOLITES` | value_json.items[] | B | 4-hydroxymetamphetamine | ilova boshqa tilga qaytadi (fallback) |
| 282 | warn | MISSING_TRANSLATION | ru | content.db | `claims` | `C-METHAMPHETAMINE-METABOLITES` | value_json.items[] | B | amphetamine (AM) | ilova boshqa tilga qaytadi (fallback) |
| 283 | warn | MISSING_TRANSLATION | uz | content.db | `claims` | `C-METHAMPHETAMINE-METABOLITES` | value_json.items[] | B | 4-hydroxymetamphetamine | ilova boshqa tilga qaytadi (fallback) |
| 284 | warn | MISSING_TRANSLATION | uz | content.db | `claims` | `C-METHAMPHETAMINE-METABOLITES` | value_json.items[] | B | amphetamine (AM) | ilova boshqa tilga qaytadi (fallback) |
| 285 | warn | MISSING_TRANSLATION | ru | content.db | `claims` | `C-METHANOL-METABOLITES` | value_json.items[] | B | formaldehyde | ilova boshqa tilga qaytadi (fallback) |
| 286 | warn | MISSING_TRANSLATION | uz | content.db | `claims` | `C-METHANOL-METABOLITES` | value_json.items[] | B | formaldehyde | ilova boshqa tilga qaytadi (fallback) |
| 287 | warn | MISSING_TRANSLATION | ru | content.db | `claims` | `C-MORPHINE-METABOLITES` | value_json.items[] | B | morphine-3-glucuronide (M3G) | ilova boshqa tilga qaytadi (fallback) |
| 288 | warn | MISSING_TRANSLATION | ru | content.db | `claims` | `C-MORPHINE-METABOLITES` | value_json.items[] | B | morphine-6-glucuronide (M6G) | ilova boshqa tilga qaytadi (fallback) |
| 289 | warn | MISSING_TRANSLATION | uz | content.db | `claims` | `C-MORPHINE-METABOLITES` | value_json.items[] | B | morphine-3-glucuronide (M3G) | ilova boshqa tilga qaytadi (fallback) |
| 290 | warn | MISSING_TRANSLATION | uz | content.db | `claims` | `C-MORPHINE-METABOLITES` | value_json.items[] | B | morphine-6-glucuronide (M6G) | ilova boshqa tilga qaytadi (fallback) |
| 291 | warn | MISSING_TRANSLATION | ru | content.db | `claims` | `C-PARACETAMOL-METABOLITES` | value_json.items[] | B | sulfate | ilova boshqa tilga qaytadi (fallback) |
| 292 | warn | MISSING_TRANSLATION | ru | content.db | `claims` | `C-PARACETAMOL-METABOLITES` | value_json.items[] | B | glucuronide | ilova boshqa tilga qaytadi (fallback) |
| 293 | warn | MISSING_TRANSLATION | ru | content.db | `claims` | `C-PARACETAMOL-METABOLITES` | value_json.items[] | B | NAPQI | ilova boshqa tilga qaytadi (fallback) |
| 294 | warn | MISSING_TRANSLATION | uz | content.db | `claims` | `C-PARACETAMOL-METABOLITES` | value_json.items[] | B | sulfate | ilova boshqa tilga qaytadi (fallback) |
| 295 | warn | MISSING_TRANSLATION | uz | content.db | `claims` | `C-PARACETAMOL-METABOLITES` | value_json.items[] | B | glucuronide | ilova boshqa tilga qaytadi (fallback) |
| 296 | warn | MISSING_TRANSLATION | uz | content.db | `claims` | `C-PARACETAMOL-METABOLITES` | value_json.items[] | B | NAPQI | ilova boshqa tilga qaytadi (fallback) |
| 297 | warn | MISSING_TRANSLATION | ru | content.db | `claims` | `C-PHENAZEPAM-METABOLITES` | value_json.items[] | B | 3-hydroxyphenazepam | ilova boshqa tilga qaytadi (fallback) |
| 298 | warn | MISSING_TRANSLATION | uz | content.db | `claims` | `C-PHENAZEPAM-METABOLITES` | value_json.items[] | B | 3-hydroxyphenazepam | ilova boshqa tilga qaytadi (fallback) |
| 299 | warn | MISSING_TRANSLATION | ru | content.db | `claims` | `C-THC-METABOLITES` | value_json.items[] | B | THC-COOH | ilova boshqa tilga qaytadi (fallback) |
| 300 | warn | MISSING_TRANSLATION | ru | content.db | `claims` | `C-THC-METABOLITES` | value_json.items[] | B | 11-OH-THC | ilova boshqa tilga qaytadi (fallback) |
| 301 | warn | MISSING_TRANSLATION | uz | content.db | `claims` | `C-THC-METABOLITES` | value_json.items[] | B | THC-COOH | ilova boshqa tilga qaytadi (fallback) |
| 302 | warn | MISSING_TRANSLATION | uz | content.db | `claims` | `C-THC-METABOLITES` | value_json.items[] | B | 11-OH-THC | ilova boshqa tilga qaytadi (fallback) |
| 303 | warn | MISSING_TRANSLATION | ru | content.db | `claims` | `C-TRAMADOL-METABOLITES` | value_json.items[] | B | O-desmethyltramadol | ilova boshqa tilga qaytadi (fallback) |
| 304 | warn | MISSING_TRANSLATION | ru | content.db | `claims` | `C-TRAMADOL-METABOLITES` | value_json.items[] | B | M2 | ilova boshqa tilga qaytadi (fallback) |
| 305 | warn | MISSING_TRANSLATION | ru | content.db | `claims` | `C-TRAMADOL-METABOLITES` | value_json.items[] | B | M5 | ilova boshqa tilga qaytadi (fallback) |
| 306 | warn | MISSING_TRANSLATION | uz | content.db | `claims` | `C-TRAMADOL-METABOLITES` | value_json.items[] | B | O-desmethyltramadol | ilova boshqa tilga qaytadi (fallback) |
| 307 | warn | MISSING_TRANSLATION | uz | content.db | `claims` | `C-TRAMADOL-METABOLITES` | value_json.items[] | B | M2 | ilova boshqa tilga qaytadi (fallback) |
| 308 | warn | MISSING_TRANSLATION | uz | content.db | `claims` | `C-TRAMADOL-METABOLITES` | value_json.items[] | B | M5 | ilova boshqa tilga qaytadi (fallback) |
| 309 | warn | ENGLISH_SHAPED_IN_UZ | uz | guidelines | `assets/content/guidelines/guidelines_v1.json` | `guideline.chem.co_cohb_determination` | sections.advantages.body | B | Uch yondashuvni qisqa taqqoslash: • CO-oksimetriya (ko‘p to‘lqinli): tez, kichik hajm, bir o‘lchovda bir nech… | methemoglobin |
| 310 | warn | ENGLISH_SHAPED_IN_UZ | uz | guidelines | `assets/content/guidelines/guidelines_v1.json` | `guideline.chem.co_cohb_determination` | sections.methods.body | B | • CO-oksimetriya (ko‘p to‘lqinli spektrofotometriya). Avtomatlashtirilgan asboblar umumiy gemoglobin, oksigem… | methemoglobin methemoglobinni |
| 311 | warn | ENGLISH_SHAPED_IN_UZ | uz | guidelines | `assets/content/guidelines/guidelines_v1.json` | `guideline.chem.ethanol_gc` | sections.cautions.body | B | • O‘lchangan natija namuna olingan paytdagi namunadagi konsentratsiyadir; u hodisa paytidagi konsentratsiyaga… | ethanol tool |
| 312 | warn | ENGLISH_SHAPED_IN_UZ | uz | guidelines | `assets/content/guidelines/guidelines_v1.json` | `guideline.chem.toks_mineralization` | sections.methods.body | B | 1. Ho‘l mineralizatsiya (laboratoriya mashg‘uloti tavsifi). Maydalangan ob’ekt (majmuada 100 g) Keldal kolbas… | kation |
| 313 | warn | ENGLISH_IN_UZ | uz | guidelines | `assets/content/guidelines/guidelines_v1.json` | `guideline.tox.postmortem_interpretation` | keywords | B | o‘limdan keyingi qayta taqsimlanish, postmortem redistribution, PMR, postmortem toksikologiya, son venasi qon… | postmortem |
| 314 | warn | ENGLISH_IN_UZ | uz | guidelines | `assets/content/guidelines/guidelines_v1.json` | `guideline.tox.postmortem_interpretation` | sections.advantages.body | B | • Bir nechta joydan olingan namunalar PMR ni aniqlash va natijani noto‘g‘ri talqin qilmaslik imkonini beradi … | antemortem postmortem |
| 315 | warn | ENGLISH_IN_UZ | uz | guidelines | `assets/content/guidelines/guidelines_v1.json` | `guideline.tox.postmortem_interpretation` | sections.factors.body | B | • Namuna olingan joy. Markaziy tomirlar (yurak, o‘pka tomirlari) qoni odatda periferik qondan yuqori qiymat b… | postmortem |
| 316 | warn | ENGLISH_IN_UZ | uz | guidelines | `assets/content/guidelines/guidelines_v1.json` | `guideline.tox.postmortem_interpretation` | sections.methods.body | B | Postmortem natijani talqin qilish bitta raqamni jadval bilan solishtirish emas, balki bosqichma-bosqich dalil… | antemortem postmortem |
| 317 | warn | ENGLISH_IN_UZ | uz | guidelines | `assets/content/guidelines/guidelines_v1.json` | `guideline.tox.specimen_preanalytics` | keywords | B | preanalitika, preanalitik bosqich, namuna olish, namunalarni tanlash, belgilash, markirovka, konservatsiya, k… | antemortem of |
| 318 | warn | ENGLISH_IN_UZ | uz | guidelines | `assets/content/guidelines/guidelines_v1.json` | `guideline.tox.specimen_preanalytics` | sections.scope.body | B | Kartochka quyidagi holatlarda olinadigan biologik namunalarga taalluqli: • postmortem toksikologiya (o‘lim sa… | antemortem postmortem |
| 319 | info | CYRILLIC_QUOTED_IN_EN | en | content.db | `knowledge_entities` | `reagent-dragendorff-munier` | payload.notes[0] | B | The original text reads «Муиье» (OCR error), read as «Мунье» (Munier). | МуиьеМунье |
| 320 | info | CYRILLIC_QUOTED_IN_UZ | uz | content.db | `knowledge_entities` | `reagent-dragendorff-munier` | payload.notes[0] | B | Asl matnda «Муиье» (OCR xatosi) — «Мунье» (Munier) deb o‘qildi. | МуиьеМунье |
| 321 | info | CYRILLIC_QUOTED_IN_EN | en | content.db | `knowledge_entities` | `reagent-folin-ciocalteu` | payload.notes[0] | B | For solution B the original reads «прибавляют иоду» (add iodine); read as «воду» (water), an OCR error — plea… | прибавляютио |
| 322 | info | CYRILLIC_QUOTED_IN_UZ | uz | content.db | `knowledge_entities` | `reagent-folin-ciocalteu` | payload.notes[0] | B | Asl matnda B eritma uchun «прибавляют иоду до растворения» yozilgan — bu «воду» (suv) so‘zining OCR xatosi de… | прибавляютио |
| 323 | info | CYRILLIC_QUOTED_IN_EN | en | content.db | `knowledge_entities` | `reagent-iron-iii-chloride-potassium-iodide` | payload.notes[0] | B | The original gives the final volume as «до Ю мл», read as «10 mL» (OCR error) — please verify. | доЮмл |
| 324 | info | CYRILLIC_QUOTED_IN_UZ | uz | content.db | `knowledge_entities` | `reagent-iron-iii-chloride-potassium-iodide` | payload.notes[0] | B | Asl matnda yakuniy hajm «до Ю мл» — «10 ml» deb o‘qildi (OCR xatosi); tekshiring. | доЮмл |
| 325 | info | CYRILLIC_QUOTED_IN_EN | en | content.db | `knowledge_entities` | `reagent-mandelin` | payload.notes[0] | B | The original reads «Маиделина» (OCR error), read as «Манделина» (Mandelin). | МаиделинаМан |
| 326 | info | CYRILLIC_QUOTED_IN_UZ | uz | content.db | `knowledge_entities` | `reagent-mandelin` | payload.notes[0] | B | Asl matnda nom «Маиделина» (OCR xatosi) — «Манделина» deb o‘qildi. | МаиделинаМан |
| 327 | info | CYRILLIC_QUOTED_IN_EN | en | content.db | `knowledge_entities` | `reagent-organophosphorus-indicator-mixture` | payload.notes[1] | B | The original reads «0,1 и.», read as «0.1 N» (OCR error). | и |
| 328 | info | CYRILLIC_QUOTED_IN_UZ | uz | content.db | `knowledge_entities` | `reagent-organophosphorus-indicator-mixture` | payload.notes[1] | B | Asl matnda «0,1 и.» — «0,1 n.» (normal) deb o‘qildi (OCR xatosi). | и |
| 329 | info | CYRILLIC_QUOTED_IN_EN | en | content.db | `knowledge_entities` | `reagent-sonnenschein` | payload.notes[0] | B | The source gives no amounts or concentrations. The original reads «Зоннеишейиа» (OCR error), read as «Зонненш… | ЗоннеишейиаЗ |
| 330 | info | CYRILLIC_QUOTED_IN_UZ | uz | content.db | `knowledge_entities` | `reagent-sonnenschein` | payload.notes[0] | B | Miqdor va konsentratsiyalar manbada berilmagan. Asl matnda nom «Зоннеишейиа» (OCR xatosi) — «Зонненштейна» de… | ЗоннеишейиаЗ |
| 331 | info | CYRILLIC_QUOTED_IN_EN | en | content.db | `knowledge_entities` | `reagent-trinder` | payload.notes[0] | B | The original reads «Триидлера» (OCR error), read as «Триндера» (Trinder). | ТриидлераТри |
| 332 | info | CYRILLIC_QUOTED_IN_UZ | uz | content.db | `knowledge_entities` | `reagent-trinder` | payload.notes[0] | B | Asl matnda nom «Триидлера» (OCR xatosi) — «Триндера» (Trinder) deb o‘qildi. | ТриидлераТри |
| 333 | info | CYRILLIC_QUOTED_IN_EN | en | content.db | `knowledge_entities` | `reagent-wagner` | payload.notes[0] | B | The original text reads «Вагиера» (OCR error), read as «Вагнера» (Wagner). | ВагиераВагне |
| 334 | info | CYRILLIC_QUOTED_IN_UZ | uz | content.db | `knowledge_entities` | `reagent-wagner` | payload.notes[0] | B | Asl matnda nom «Вагиера» (OCR xatosi) — «Вагнера» deb o‘qildi. | ВагиераВагне |
