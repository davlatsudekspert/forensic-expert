# content/guidelines — «Yo‘riqnomalar» bo‘limi kontenti (fe-guidelines/1)

Ilovaning «Yo‘riqnomalar» (Guidelines) bo‘limi uchun mustaqil yozilgan ilmiy
yo‘riqnoma kartochkalari. UI va DB sxemasi bu yerda o‘zgartirilmaydi — UI
integratsiyasi `guidelines_v1.json` faylini o‘qiydi.

## Fayllar

| Fayl | Vazifasi |
|---|---|
| `src/card_*.json` | Har bir kartochkaning muallif matni (bitta fayl — bitta kartochka) |
| `references.json` | Tekshirilgan bibliografiya (yagona manba) |
| `build.py` | `guidelines_v1.json` ni yig‘adi (faqat iqtibos keltirilgan manbalar kiritiladi) |
| `guidelines_v1.json` | **Iste’mol uchun tayyor fayl** (generatsiya qilinadi, qo‘lda tahrirlanmaydi) |
| `validate.py` | Tekshiruv (G001–G017) |
| `REVIEW_GMT.md` | «Giyohvand moddalar tahlili» kartalari: tuzatilgan va olib tashlangan raqamlar (ekspert uchun) |

```bash
python3 content/guidelines/build.py && python3 content/guidelines/validate.py
python3 content/guidelines/sync_app_asset.py   # ilova asset’i (ichki maydonlarsiz)
```

## Sxema: `fe-guidelines/1`

```jsonc
{
  "schema": "fe-guidelines/1",
  "language_order": ["uz", "ru", "en"],
  "section_order": ["basis","scope","methods","reactions","tlc","instrumental","interpretation","advantages","limitations","factors","cautions","alternatives"],
  "cards": [{
    "id": "guideline.chem.ethanol_gc",          // barqaror ID (bookmark/URL)
    "discipline_codes": ["forensic_chemistry"], // taxonomy.dart ForensicDiscipline.code
    "status": "NEEDS_REVIEW",                   // inson tekshiruvisiz boshqa qiymat yo‘q
    "updated": "2026-10-08",
    "translation_status": {"uz":"AUTHORED","ru":"DRAFT","en":"DRAFT"},
    "related_tool_ids": ["tool.tox.widmark"],   // tools_catalog.dart dagi ID lar
    "title":   {"uz":"…","ru":"…","en":"…"},
    "summary": {"uz":"…","ru":"…","en":"…"},    // ro‘yxat/kartochka preview uchun
    "sections": [{
      "key": "basis",
      "title": {"uz":"…","ru":"…","en":"…"},
      "body":  {"uz":"…","ru":"…","en":"…"},    // oddiy matn; \n\n — paragraf, "• " — ro‘yxat
      "citations": ["tiscione2011"]             // bo‘limda ishlatilgan manba kalitlari
    }],
    "reference_keys": ["…"],                    // kartochkadagi barcha kalitlar (build.py)
    "keywords": {"uz":[…],"ru":[…],"en":[…]},   // qidiruv uchun sinonimlar
    "omitted_unverified": ["…"]                 // ataylab kiritilmagan, tekshirilmagan faktlar (EN, ichki)
  }],
  "references": [{
    "key": "tiscione2011", "type": "journal_article",
    "authors": ["Tiscione NB", "…"], "title": "…", "journal": "…",
    "year": 2011, "volume": "35", "issue": "7", "pages": "501-511",
    "doi": "10.1093/anatox/35.7.501", "pmid": "21871160",   // yo‘q bo‘lsa null
    "note": "…", "used_for": "…",
    "verified_via": "PubMed MCP get_article_metadata", "verified_on": "2026-10-08"
  }]
}
```

### O‘quv-uslubiy majmualar (`type: teaching_material`)
- Prof. Yuldashev Z.A. majmualari (`toks_*`, `dvssm_*`) muallif ruxsati bilan;
  `rights` va `publisher` majburiy (G014). Bunday manbaga tayangan karta va
  undan olingan savollar **barcha uchun bepul** (`"access": "free"`, G015) —
  kartada manba qatori ko‘rsatiladi, savollar o‘quv rejimida alohida bepul
  to‘plamda.
- Ixtiyoriy `quiz` maydoni (G016): `{"id","e":{uz,ru,en},"q":{uz,ru,en},"a":{…},"d":{"uz":[3 ta],…},"pages"}`.
  `e` — izoh (nega javob to‘g‘ri, variantlar nega noto‘g‘ri), **faqat kartadagi manbali
  matndan** (yangi fakt yo‘q); majburiy. Quiz matnlarida `content/terminology/canonical_terms.json`
  dagi taqiqlangan shakllar (GX-MS, SX-MS, YuSSX …) bo‘lmasligi kerak (G016). O‘quv rejimida
  baholanadigan imtihonga faqat izohi, 3 ta distraktori va sahifa/bo‘limi bor savollar kiradi.
- Iqtibos sahifasi kalitdan keyin: `[toks_majmua2025] (23-b.)` / `(с. 23)` / `(p. 23)`.
- Tuzatilgan va chiqarilgan raqamlar: `REVIEW_TOKS.md`.

### UI uchun eslatmalar
- Matn ichidagi iqtiboslar `[key]` yoki `[key1, key2]` ko‘rinishida; UI ularni
  havolaga yoki raqamli izohga aylantirishi mumkin. Har bir inline kalit shu
  bo‘limning `citations` ro‘yxatida bor (G005).
- `status: NEEDS_REVIEW` va `translation_status: DRAFT` foydalanuvchiga ko‘rinadigan
  belgi bilan ko‘rsatilishi tavsiya etiladi («Ekspert tekshiruvi kutilmoqda»,
  «Tarjima — qoralama»).
- `omitted_unverified` — ichki ishchi maydon, foydalanuvchiga ko‘rsatilmaydi.

## Ilmiy halollik qoidalari
- Matn mustaqil yozilgan; hech qaysi manbadan ko‘chirilmagan. Cheklangan ichki
  «ABY» qo‘llanmasi ishlatilmagan va unga havola yo‘q (G012).
- Har bir manba bibliografik reyestrda tekshirilgan (PubMed MCP, NCBI E-utilities,
  Crossref) — `verified_via` va `verified_on` majburiy (G006). DOI/PMID
  o‘ylab topilmaydi: yo‘q bo‘lsa `null`.
- Raqamli qiymatlar (chegara, xato, foiz, konsentratsiya, SEE) faqat tekshirilgan
  manbadan va aniq iqtibos bilan keltiriladi; aks holda sifat jihatdan bayon qilinadi.
- Skrining va tasdiqlovchi tahlil, ilmiy tavsiya va huquqiy talab farqlanadi;
  yurisdiksiyaga xos huquqiy da’volar yo‘q.
- Barcha kartochkalar `NEEDS_REVIEW`: inson (ekspert) tekshiruvi qayd etilmaguncha
  status o‘zgarmaydi (G002). O‘zbek matni — muallif matni, rus va ingliz —
  mashina yordamidagi qoralama tarjima (`DRAFT`).
- O‘zbek lotin yozuvi: o‘ / g‘ uchun U+2018, tutuq belgisi uchun ’ (U+2019) (G010).

## Qo‘shimcha qoidalar (2026-10-09)
- «Giyohvand moddalar tahlili» (`gmt_yuldashev2024`, `teaching_material`) sahifa bilan keltiriladi:
  `[gmt_yuldashev2024] (23-b.)`, `(с. 23)`, `(p. 23)` (G017). Kartalar `access: "free"` (G015).
- `quiz` elementida ixtiyoriy `"cite": ["kalit", …]` — savol aniq tayangan manbalar (masalan,
  PubChem yoki UNODC); `pages` faqat o‘quv-uslubiy materialga tegishli (G016). GMT savollari
  o‘quv rejimida alohida «Giyohvand moddalar tahlili (Yuldashev Z.A.)» to‘plamida.
