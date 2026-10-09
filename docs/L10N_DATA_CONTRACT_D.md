# L10N ma’lumot shartnomasi — Phase D (ilmiy tarjima ma’lumotlari)

Sana: 2026-10-09. Holat: barcha tarjimalar **`machine_draft`** (inson tekshirmagan).
`reviewed` / `official` statusi hech qayerda qo‘yilmagan. Sxema (v7) **o‘zgartirilmagan**.

## 1. Mavjud shartnomalarga to‘ldirilgan ma’lumot (ilova hozir o‘qiydi)

| Joy | Nima | Manba fayl |
|---|---|---|
| `text_translations` `research_title` (uz, ru) | **882 / 883** tadqiqot sarlavhasi glossi (hammasi `machine_draft`). Tarjima qilinmagan 1 ta sarlavha va sababi: `content/pilot/translations/research_titles_pending.json` (asl sarlavha har uch tilda o‘zgarmagan holda ko‘rsatiladi) | `content/pilot/translations/research_titles_i18n.json` → `tools/apply_text_translations.py` |
| `text_translations` `claim_excerpt` | 10 ta tarjimada mingliklar «1,710» → «1 710» (uz/ru’da vergul — o‘nli kasr); 7 ta qisqartma tiklandi (CSF, CoA, EG, PK, UDP); ВЭЖХ → HPLC | `excerpts_i18n.json` |
| `authorities.names` | 6 ta idora uz/ru/en («Олий Мажлис…» → uz «O‘zbekiston Respublikasi Oliy Majlisi», en «Oliy Majlis (Parliament) of the Republic of Uzbekistan») | `content/tools/apply_l10n_d.py` |
| `jurisdictions.names` | INT uz/ru | 〃 |
| `instruments.titles` | INCB Sariq/Yashil ro‘yxat, UK RTA 1988, SSI 2014/328 — uz/ru (machine_draft); UZ-LAW-813-I uz/ru — lex.uz rasmiy nomi | 〃 |
| `instruments.official_reference` | faqat rasmiy raqam; «consolidated text retrieved …; NEEDS LEGAL REVIEW» → `internal_note` (content.db ga tushmaydi) | 〃 |
| `methods.titles` | GC-MS, GC-FID, LC-MS/MS, HPLC, TLC, GC — kanonik qisqartma + kengaytma | 〃 |
| `term_translations` | T-POSTMORTEM-INTERVAL: uz «o‘limdan keyin o‘tgan vaqt oralig‘i (PMI)», ru «посмертный интервал (PMI)» | 〃 |
| recipe `names`/`texts` | Dragendorff PMC varianti (5 element) uz/ru; tushib qolgan sinonimlar (1-naftol, 2-naftol, 1-naftilamin, «1 л») | 〃 |
| `sources.title` SRC-OWNER-REAGENTS | faqat asl rus nomi «Приготовление реактивов»; inglizcha izoh `notes` ga | 〃 |
| guidelines / court_prep `references[]` | `titles{uz,ru,en}`, `official_titles{uz,uz_cyrl,ru}`, `title_status`, `title_verification[]` (lex.uz URL + sana) — CPC, ZRU-249, 813-I, VM 330 | `content/tools/apply_uz_legal_titles.py` |

`title_status` qiymatlari: `official` (lex.uz’dagi rus matni nomi), `official_transliterated`
(lex.uz o‘zbek kirill rasmiy nomining 1995-yilgi lotin alifbosiga harfma-harf o‘girilishi),
`unofficial_translation` (inglizcha).

**Diqqat (huquqiy):** lex.uz izohiga ko‘ra ZRU-249 «Sud ekspertizasi to‘g‘risida» 13.12.2026 dan
kuchini yo‘qotadi (O‘RQ-1152, 11.06.2026 «Sud-ekspertlik faoliyati to‘g‘risida»). Kontent
o‘zgartirilmadi; `legal_status_note` qo‘shildi — huquqshunos tekshiruvi kerak.

## 2. Sxemada maydoni yo‘q matnlar — yon fayl (C qatlami uchun)

`content/pilot/translations/localized_texts_d.json` (`content/tools/build_localized_d.py`
`localized_texts_d.src.json` dan yig‘adi). Har yozuv audit 10.2 dagi `localized_texts`
jadvali shaklida:

```json
{"target_type": "screening_field", "target_id": "scr-immunoassay-opiates#analyte",
 "source_lang": "en", "source_text": "opiates (class-based)", "source_sha256": "…",
 "text": {"uz": "opiatlar (sinf bo‘yicha)", "ru": "опиаты (по классу)"}, "status": "machine_draft"}
```

| target_type | target_id shakli | Soni |
|---|---|---:|
| `screening_field` | `<screening_id>#analyte|specimen|principle` | 21 |
| `conflict_text` | `<conflict_id>#question|note` | 8 |
| `standard_note` | `<standard_id>` | 7 |
| `context_text` | `<claim_id>#<context_strict kaliti>[i]` (faqat erkin matn; `not_stated` kabi kodlar — ARB yorlig‘i) | 67 |
| `list_item` | `<claim_id>#items[i]` | 34 |
| `source_title` | `SRC-FE-EDITORIAL` (asl tili uz → `text.ru`, `text.en`) | 1 |
| `topic_body` | `<topic_id>`; `derived: true`, `source_claims[]` — faqat kartadagi manbali da’volardan | 45 |
| `method_body` | `<method_id>`; shart-sharoiti `topic_body` bilan bir xil (`derived: true`, `source_claims[]`) | 18 |

Barcha 63 ta mavzu/usul kartasi (45 mavzu + 18 usul) uchun uch tilli tushuntiruvchi bo‘lim
`topic_body` / `method_body` yozuvlarida: matn faqat o‘sha kartaning manbali da’volaridan
chiqarilgan (yangi fakt yo‘q, raqam va birlik o‘zgarmagan — `translation_qa.py` `derived`
tekshiruvi), oxirida kartaning qolgan bo‘limlari hali manbasiz ekani aytiladi. Status —
`machine_draft`: ilmiy reviewer tasdig‘i kerak.

Qoidalar: yozuv faqat `sha256(asl matn) == source_sha256` bo‘lsa ko‘rsatiladi; status faqat
`machine_draft` (validator `terminology_checked`/`claim_checked` ni ham qabul qiladi, lekin
hozir ishlatilmaydi); UI «Avtomatik tarjima — tekshirilmagan» belgisini ko‘rsatadi.
`text_translations` jadvaliga yangi tur qo‘shilmadi: DB CHECK (`target_type`, `lang IN ('uz','ru')`)
va `TextTranslationTarget.fromCode` eski kodni yiqitadi — import C agentining v8 jadvali orqali.

## 3. Avtomatik tekshiruv (darvoza)

* `content/terminology/canonical_terms.json` — kanonik qisqartmalar, uz/ru/en kengaytma, taqiqlangan
  variantlar (GX-MS, SX-MS, YuSSX, YuQX, ГХ-МС, ЖХ-МС, ВЭЖХ, ТСХ …) va uz’dagi inglizcha so‘zlar.
* `content/tools/translation_qa.py` — raqam, birlik (mg/L ≡ мг/л), solishtirish belgilari, formula,
  qisqartma, DOI/PMID, terminologiya. Istisnolar: `content/terminology/qa_exceptions.json` (sabab bilan, 3 ta).
  Ulangan: `tool/update_bundled_pack.sh` (paketdan oldin), guidelines `validate.py` G019, court_prep C019.
* `content/tools/l10n_terms_normalize.py` — idempotent normalizator (`--check` rejimi).
