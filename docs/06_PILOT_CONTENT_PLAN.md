# 06 — Pilot ilmiy kontent rejasi (content pipeline sinovi)

| | |
|---|---|
| Sana | 2026-10-04 |
| Holat | **ARXITEKTURA VA TANLOV TAKLIFI.** Kontent hali to‘ldirilmagan |
| Qoida | Pilot moddalarning ilmiy qiymatlari reviewer tasdig‘isiz `VERIFIED` yoki `PUBLISHED` bo‘lmaydi. Bu qoida kodda majburlangan: `fe_content_schema` `ContentValidator` va `StatusResolver` |

## 1. Maqsad

95 ta moddani to‘ldirishdan oldin 10–20 ta **reprezentativ** modda bilan butun zanjirni sinash:

```
manba (Source) → claim → citation → review → status (avtomatik hisob)
   → validator → kontent paketi (imzo) → content.db → FTS5 qidiruv → UI (Sources sheet)
```

Pilotning vazifasi — ilmiy kontent yaratish emas, **tizimdagi xatolarni topish**: sxemadagi bo‘shliqlar, ziddiyatlar modeli, tarjima holati, qidiruv sifati, reviewer ish oqimi.

## 2. Pilot moddalar taklifi (18 ta)

Har biri tizimning muayyan qismini sinash uchun tanlangan. V1 ro‘yxatidagi asosi `docs/04_V1_SCOPE.md` da.

| # | Modda | Nimani sinaydi |
|---|---|---|
| P-01 | Ethanol | Kalkulyatorlar bilan bog‘lanish (Widmark), ko‘p namuna turi (qon, siydik, vitreous), postmortem hosil bo‘lish talqini |
| P-02 | Methanol | Toksik spirtlar guruhi; metabolit (formik kislota) yozuvi; MDH’dagi surrogat konteksti |
| P-03 | Ethylene glycol | O‘zbekiston bilan bog‘liq rasmiy manba (WHO alert); guruh/sinf yozuvi |
| P-04 | Morphine | Ota modda ↔ metabolitlar grafi (6-MAM va heroin bilan bog‘liqlik), ko‘p sinonim |
| P-05 | Heroin / 6-MAM | Metabolit asosidagi identifikatsiya; `metabolic_relations` jadvali |
| P-06 | Fentanyl | Yuqori qiymatli kontent; analoglar sinfi; kichik konsentratsiya birliklari (ng/mL ↔ µg/L) |
| P-07 | Tramadol | Mintaqaviy ahamiyat (UNODC WDR 2026); O-desmetiltramadol |
| P-08 | Methamphetamine | Qidiruv sinovi (EN/RU/UZ, `methamphetamine ↔ метамфетамин ↔ metamfetamin`); stimulyator |
| P-09 | Cocaine | Bir nechta metabolit (benzoylecgonine, cocaethylene); in vitro barqarorlik izohlari |
| P-10 | THC | Faol va nofaol metabolitlar; namuna turlariga bog‘liq talqin |
| P-11 | Alprazolam | Benzodiazepinlar guruhi; immunoassay cross-reactivity (interferensiya jadvali) |
| P-12 | Phenazepam | Mintaqaviy (MDH) modda; RU manbalari; tarjima va terminologiya |
| P-13 | Amitriptyline | Postmortem redistribution talqini (namuna joyi ahamiyati) |
| P-14 | Paracetamol | Klinik va sud-tibbiy talqinning farqi; keng tarqalgan dori |
| P-15 | Pregabalin | Suiiste’mol konteksti; huquqiy status yurisdiksiyaga qarab farqlanishi |
| P-16 | Carbon monoxide | Modda emas, **marker** orqali o‘lchanadi (COHb) — sxemaning moslashuvchanligi |
| P-17 | Organophosphates (sinf) / chlorpyrifos | Sinf yozuvi va aniq modda; xolinesteraza faolligi kabi bilvosita marker |
| P-18 | Aluminium phosphide / phosphine | Qattiq modda → gaz; namuna olish va xavfsizlik izohlari |

**Ataylab qamrab olingan holatlar:** metabolit grafi, sinf/guruh yozuvlari, marker orqali o‘lchash (CO), mintaqaviy manbalar (RU/UZ), birlik konvertatsiyasi, interferensiyalar, huquqiy status farqi va (ehtimoliy) manbalararo ziddiyat.

## 3. Pilot yozuvlarining holati

| Bosqich | Holat | Kim |
|---|---|---|
| Identifikatsiya (nom, formula, MW, PubChem CID, InChIKey) | `NEEDS_REVIEW` → `REVIEWED` | Avtomatik olish + `tox` reviewer |
| Sinonimlar (EN), RU/UZ nomlari | `machine_draft` → `translated` → `reviewed` | Tarjimon + `i18n:ru`, `i18n:uz` |
| Metabolitlar, namunalar, metodlar | `NEEDS_REVIEW` | `tox`, `lab` reviewerlar |
| Reference konsentratsiyalar | **Pilotning 2-bosqichigacha kiritilmaydi** | `tox` × 2 |
| Huquqiy status | `NEEDS_REVIEW` | `legal` |

Reviewerlar tayinlanmaguncha barcha pilot yozuvlari faqat `development` kanaliga tushadi va UI’da **«MA’LUMOT TEKSHIRILMAGAN — EKSPERT TASDIG‘I KERAK»** banneri bilan ko‘rsatiladi. Production kanalida `NEEDS_REVIEW` kontent bo‘lishini validator bloklaydi (qoida `FE008`).

## 4. Pipeline arxitekturasi (PHASE 3 da implementatsiya)

```
content/
  sources/*.yaml          # Source yozuvlari (DOI/PMID → Crossref/PubMed tekshiruvi)
  substances/<id>/
    identity.yaml         # identifikatorlar + manba
    claims/*.yaml         # har bir claim alohida fayl (git diff = audit izi)
    i18n/{en,ru,uz}.yaml  # tarjimalar + translation_status
  reviews/*.yaml          # review yozuvlari (CMS tayyor bo‘lguncha — PR orqali)
tools/
  validate.dart           # fe_content_schema ContentValidator
  build_pack.dart         # content.db + FTS5 indeks
  sign_pack.dart          # Ed25519 (maxfiy kalit faqat CI secret / KMS)
```

**Muhim:** CMS (PHASE 10) tayyor bo‘lguncha review yozuvlari git’dagi PR orqali qayd etiladi. Har bir review alohida commit (kim, qachon, nima) — audit izi git tarixida saqlanadi.

## 5. Pilotni muvaffaqiyatli deb hisoblash mezonlari

- [ ] 18 ta yozuvning barchasi validator’dan xatosiz o‘tadi (`development` kanal).
- [ ] Har bir yozuv EN/RU/UZ qidiruvda (kirill/lotin, 1–2 xato bilan) topiladi.
- [ ] Kamida bitta haqiqiy manbalararo ziddiyat `claim_groups` orqali to‘g‘ri ko‘rsatiladi.
- [ ] Production kanalga urinish test ma’lumot yoki tekshirilmagan claim bilan **muvaffaqiyatsiz** tugaydi (salbiy test).
- [ ] Reviewer ish oqimi (approve / request changes / reject) va four-eyes qoidasi amalda sinaladi.
- [ ] Pilot natijasiga ko‘ra sxemaga kiritiladigan o‘zgarishlar ro‘yxati tuziladi.
