# 20 — Global platforma arxitekturasi, fanlar taksonomiyasi, yurisdiksiya modeli, manba va dalil ierarxiyasi

PHASE 6. FORENSIC EXPERT — butun dunyo uchun professional forensic science platformasi: forensic ekspertlar, sud-tibbiyot ekspertlari va patologlar, toksikologlar, kimyogarlar, laboratoriya mutaxassislari, biokimyogarlar, genetiklar, antropologlar, odontologlar, biologlar, talaba/rezidentlar, tadqiqotchilar va muassasalar. **Iste’molchi tibbiy diagnostika ilovasi emas.**

## 1. Global arxitektura

```
GLOBAL SCIENTIFIC CORE  ─┐   (davlatga bog‘liq emas: modda, metabolizm, analitik kimyo, dalillar)
INTERNATIONAL STANDARDS  ├─► PROFESSIONAL TOOLS · SCIENTIFIC LIBRARY · EDUCATION · FORENSIC AI
COUNTRY / JURISDICTION  ─┘   (qonun, nazorat ro‘yxati, milliy metod, protsedura — faqat tanlangan yurisdiksiya)
```

Uch qatlam **hech qachon aralashtirilmaydi**:

| Qatlam | Kodda | Qoida |
|---|---|---|
| A. Global Scientific Core | `KnowledgeLayer.internationalScientific` | Yurisdiksiyaga bog‘lanmaydi (validator FE012–FE016) |
| B. International standards & methods | `KnowledgeLayer.internationalStandard`, `MethodKind.internationalStandard` | Qonun emas, qabul qilinmaguncha (`BindingNature.voluntaryUnlessAdopted`) |
| C. Country / jurisdiction law & procedures | `KnowledgeLayer.jurisdictional`, `JurisdictionalInstrument`, `JurisdictionalRule` | Faqat o‘z yurisdiksiyasi zanjirida (`US-CA → US → INT`) |

Paketlar: `fe_content_schema` (qoidalar va modellar), `fe_content_pipeline` (validator → content.db → imzo), `fe_content_package` (imzo, o‘rnatish, yangilash, rollback), `fe_database` (drift, schema **v5**), `fe_search_core` (offline FTS + fuzzy), `fe_calc_engine` (UI’dan mustaqil hisob). Ilova (`apps/mobile`) faqat `domain` portlari orqali ishlaydi.

## 2. Fanlar taksonomiyasi (`ForensicDiscipline`, 20 ta)

| Guruh | Fanlar |
|---|---|
| Tibbiyot va patologiya | Sud tibbiyoti · Sud patologiyasi · Klinik sud tibbiyoti · Sud radiologiyasi / vizualizatsiya · Sud psixiatriyasi va psixologiyasi (**faqat professional ma’lumotnoma**) |
| Toksikologiya va kimyo | Sud toksikologiyasi · Sud kimyosi · Sud biokimyosi · Analitik fan |
| Biologiya va identifikatsiya | Sud biologiyasi · Genetika / DNK · Gistologiya · Antropologiya · Odontologiya · Mikrobiologiya · Entomologiya · DVI / shaxsni aniqlash |
| Laboratoriya va sifat | Laboratoriya sifati va validatsiya · Ashyoviy dalillar va saqlash zanjiri |
| Ta’lim | Ta’lim va tadqiqot |

* Kodlar barqaror (`forensic_toxicology` …) — bookmark, qidiruv, URL.
* `disciplineOfArea()` va `disciplineOfFmTopic()` — mavjud bilim sohalari va sud tibbiyoti taksonomiyasining (25 mavzu) aniq xaritasi.
* Ilova: **Fanlar** ekrani (guruhlar, har fan uchun paketdagi haqiqiy manbali yozuvlar soni), fan sahifasi (modullar, rejalashtirilgan mavzular tuzilmasi). Kontenti yo‘q fan — «hali manba yo‘q» (bilim yo‘q degani emas).

## 3. Yurisdiksiya modeli

`Jurisdiction` (INT / EU / ISO 3166-1 davlat / ISO 3166-2 hudud, ierarxiya `parentId`) + `Authority` + `JurisdictionalInstrument` + `JurisdictionalRule`.

Har bir davlatga xos yozuv qo‘llab-quvvatlaydigan maydonlar:

| Talab | Maydon |
|---|---|
| country / jurisdiction / state-region | `jurisdictionId` (+ `parentId` zanjiri), `JurisdictionLevel.subdivision` |
| authority | `authorityId` → `Authority` |
| document type | `InstrumentType` → `DocumentKind` (LAW / REGULATION / STANDARD / GUIDELINE / METHOD / SOP …) |
| official title | `titles` |
| document number | `officialReference` |
| article / section | `JurisdictionalRule.articleSection` |
| issue date / effective date | `publicationDate`, `effectiveFrom`, `effectiveTo` |
| amendment / version | `lastAmendedAt`, `version` (+ qoida `version`) |
| validity / status | `legalStatus` (inForce / amended / superseded / repealed), `isInForceAt()` |
| official source URL / source authority | `officialSourceId` → `Source.officialUrl`, `organization` |
| last verified | `lastVerifiedAt` |
| reviewed_by / review status | `Review` yozuvlari (four-eyes) → `status` |
| language / translation status | `language`, `translationStatus` |

**Qoidalar:**
* Kontent yo‘q yurisdiksiya: «Content not yet verified for this jurisdiction» (`jurisdiction.notVerified`). **Boshqa davlat qonuni hech qachon fallback sifatida ko‘rsatilmaydi** (test: `phase6_test` — Germaniya sahifasida UK hujjatlari yo‘q).
* Global ilmiy kontent yurisdiksiyasiz ishlaydi; birinchi ishga tushirishda davlat majburiy emas.
* Tanlovchi: 249 ta ISO 3166-1 davlati (nomlar Unicode CLDR’dan, `tool/gen_country_directory.py`), qidiruv, **bayroq ishlatilmaydi** (ISO kod + nom), EI a’zolari `EU` ostida.
* **Compare jurisdictions** (PHASE 4 dan) — hub’dan kirish; mavzu kaliti (`topicKey`) bo‘yicha eng aniq yurisdiksiya qoidasi.
* Hozir yuzlab davlat qonuni **to‘ldirilmagan**: pilot — INT (INCB Yellow/Green List) va GB (RTA 1988) — barchasi NEEDS_REVIEW.

## 4. Manba ierarxiyasi

1. Rasmiy hujjat (qonun, regulation, INCB/UNODC/WHO ro‘yxatlari) — rasmiy URL, SHA-256 (PDF), kirish sanasi.
2. Xalqaro standart / qo‘llanma (NIST/OSAC, ASB, ICH, ISO) — faqat litsenziya ruxsat bergan metadata va havola.
3. Tizimli review / meta-analiz.
4. Peer-reviewed birlamchi tadqiqot (validatsiya tadqiqoti shu jumladan).
5. Review maqola, darslik.
6. Case series / case report.
7. Dissertatsiya, tezis, konferensiya maqolasi/tezisi — **peer-reviewed maqola bilan bir xil ko‘rsatilmaydi** (dalil darajasi E, «peer-reviewed emas» belgisi).

Pullik / mualliflik huquqi bilan himoyalangan qo‘llanma va bazalar ko‘chirilmaydi. DOI, PMID, iqtibos, manba, konsentratsiya, metabolit, huquqiy talab, metod va reagent retsepti **hech qachon to‘qilmaydi**.

## 5. Dalil ierarxiyasi va forensik dolzarblik

* `EvidenceLevel` A–E; `ResearchKind.maxEvidence` turidan yuqori daraja berilmaydi (FE028). PHASE 6 yangi turlari: guideline (A), validation study (B), case series (D).
* **Forensik dolzarblik** (`ForensicRelevance`: unassessed / direct / supporting / background) — dalil sifatidan **alohida tushuncha**; reviewer baholamaguncha `unassessed` (DB v5 `research_records.forensic_relevance`).
* Hujjat turi va majburiyligi (`DocumentKind` + `BindingNature`) UI’da aniq: faqat LAW va REGULATION qonuniy majburiy, va faqat o‘z yurisdiksiyasida.

## 6. Ogohlantirish ierarxiyasi

`FeBannerTone`: **CRITICAL** (skrining ≠ tasdiq; xabar qilingan konsentratsiya ≠ chegara) › **WARNING** (tekshirilmagan ma’lumot, cheklovlar) › **INFO** › **REVIEW** (review holati). Rang yagona belgi emas: ikonka shakli, chegara qalinligi va ekran o‘quvchisi uchun daraja nomi.
