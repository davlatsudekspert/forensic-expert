# 10 — Global Scientific Core + Country/Jurisdiction Layer

> Holat: **arxitektura tayyor, kontent YO‘Q.** Bu hujjatda va kodda hech qanday davlat qonuni, nazorat ro‘yxati, chegara qiymati yoki milliy metodika keltirilmagan. Faqat tizim tayyorlangan.

## 1. Tamoyil

FORENSIC EXPERT — butun dunyo uchun global platforma. Bilim uch qatlamga ajratiladi va ular **aralashtirilmaydi**:

| Qatlam (`KnowledgeLayer`) | Kod | Nima kiradi | Davlatga bog‘liqmi |
|---|---|---|---|
| Xalqaro ilmiy dalillar | `international_scientific` | Farmakologiya, metabolizm, analitik kimyo, talqin, barqarorlik, interferensiya | **Yo‘q** |
| Xalqaro standartlar | `international_standard` | Xalqaro konvensiyalar, xalqaro standartlar va ko‘rsatmalar | Yo‘q (xalqaro) |
| Yurisdiksion qatlam | `jurisdictional` | Qonun, regulation, nazorat ro‘yxati, milliy metodika, protsedura talabi, huquqiy chegara | **Ha** |

Qoidalar:

1. Ilmiy claim hech qachon davlatga bog‘lanmaydi (`jurisdictionId == null`).
2. Yurisdiksion claim **albatta** yurisdiksiya va rasmiy hujjatga (`instrumentId`) bog‘lanadi.
3. `legal` domenidagi kontent ilmiy qatlamda bo‘lishi mumkin emas.
4. Har bir rasmiy hujjat (instrument) quyidagilarga ega: rasmiy manba, kuchga kirish sanasi, tugash sanasi (ixtiyoriy), versiya/tahrir, oxirgi tekshiruv sanasi, review statusi.
5. Faqat review’dan o‘tgan (`VERIFIED` / `REVIEWED`) **va** tanlangan sanada kuchda bo‘lgan qoidalar ko‘rsatiladi.

## 2. Domen modeli (`packages/fe_content_schema/lib/src/jurisdiction.dart`)

| Tur | Maydonlar |
|---|---|
| `Jurisdiction` | `id` (`INT`, `EU`, `UZ`, `US`, `US-CA`), `level` (international / supranational / country / subdivision), `parentId`, `iso3166`, `names` (ko‘p tilli, **ma’lumot**) |
| `JurisdictionalInstrument` | `id`, `jurisdictionId`, `type` (law, regulation, controlled_substance_schedule, standard, national_method, official_guideline, international_convention), `titles`, `officialSourceId` → `Source`, `officialReference`, `effectiveFrom`, `effectiveTo`, `version`, `lastVerifiedAt`, `status`, `isTestData` |
| `JurisdictionalRule` | `id`, `instrumentId`, `ruleType` (control_status, procedure_requirement, legal_threshold), `subjectType` / `subjectId` (masalan, modda), `value`, `effectiveFrom`, `effectiveTo`, `status`, `isTestData` |
| `Claim` | yangi maydonlar: `layer` (standart `internationalScientific`), `jurisdictionId`, `instrumentId` |

Talab qilingan barcha atributlar qamrab olingan: davlat, hudud/shtat (`subdivision`), qonun, regulation, standard, national method, effective date, version, official source, last verified, status.

### `JurisdictionResolver`

- `chainOf('US-CA')` → `US-CA → US → INT`. Hudud davlat qoidalarini meros qilib oladi. Aylanma bog‘lanishdan himoyalangan.
- `view(jurisdictionId, subject, at)` zanjir bo‘yicha faqat publishable va `at` sanasida kuchda bo‘lgan qoidalarni qaytaradi.
- `compare([...])` bir nechta yurisdiksiyani yonma-yon ko‘rsatadi va kelajakdagi **«Compare jurisdictions»** funksiyasining asosi bo‘ladi. UI’da bu funksiya hozircha «Rejalashtirilgan» holatida, o‘chirilgan.

## 3. Validator qoidalari (content pipeline)

| Kod | Qoida |
|---|---|
| `FE012_JURISDICTIONAL_CLAIM_WITHOUT_JURISDICTION_OR_INSTRUMENT` | Yurisdiksion claimda yurisdiksiya yoki rasmiy hujjat yo‘q |
| `FE013_LAYER_MIXING` | Ilmiy/standart claim davlatga bog‘langan; legal kontent ilmiy qatlamda; hujjat boshqa yurisdiksiyaga tegishli |
| `FE014_INSTRUMENT_WITHOUT_OFFICIAL_SOURCE` | Hujjatning rasmiy manbasi to‘plamda yo‘q yoki versiyasi bo‘sh |
| `FE015_INVALID_EFFECTIVE_PERIOD` | `effectiveTo ≤ effectiveFrom`; qoida davri hujjat davridan tashqarida |
| `FE016_UNKNOWN_JURISDICTION_REFERENCE` | Noma’lum yurisdiksiya, ota yurisdiksiya yoki hujjat; ierarxiyada aylana |

Production to‘plamda TEST ma’lumot va review’siz hujjat/qoida bo‘lishi mumkin emas (FE001, FE008 bu turlarga ham qo‘llanadi).

## 4. Baza (`content.db`, schema_version **2**)

Yangi jadvallar:

- `jurisdictions`
- `jurisdictional_instruments` (`official_source_id NOT NULL REFERENCES sources`, `CHECK (effective_to > effective_from)`)
- `jurisdictional_rules`

`claims` jadvaliga quyidagilar qo‘shildi:

- `knowledge_layer` — `CHECK` bilan cheklangan;
- `jurisdiction_id` va `instrument_id` — FK;
- **qatlamlar aralashmasligini ta’minlovchi `CHECK`**: yurisdiksion claim ⇔ ikkala bog‘lanish bor.

`docs/00` 9-bo‘limidagi rejadagi `legal_status` jadvali endi shu umumiy model bilan almashtiriladi: huquqiy maqom `jurisdictional_rules` (`rule_type = control_status`) orqali beriladi.

`content.db` imzolangan paket sifatida to‘liq almashtiriladi, shuning uchun in-place migratsiya yo‘q. Schema 1 dagi paketni verifier `supportedSchemaVersions` orqali rad etadi. Production paketlar hali chiqarilmagan.

## 5. Ilova

- `AppSettings.jurisdictionId` (standart `INT` — «Xalqaro») lokal saqlanadi (`fe.settings.jurisdiction`).
- **Profil → Yurisdiksiya** tanlash ekrani ikki guruhdan iborat:
  - xalqaro va mintaqaviy;
  - davlatlar.
- Boshlang‘ich ro‘yxat: INT, EU, UZ, KZ, KG, TJ, TM, RU, TR, US, GB, DE. Bu faqat ISO kodlari va nomlardan iborat, qonunlar kiritilmagan. Kontent paketi o‘zining `jurisdictions` jadvali bilan ro‘yxatni ilova kodini o‘zgartirmasdan kengaytiradi.
- Modda kartochkasi:
  - «Xalqaro ilmiy dalillar» bloki (davlatga bog‘liq emas) va undan **alohida** «Yurisdiksiya qatlami: {nom}» bloki ko‘rsatiladi;
  - yurisdiksiya blokida «Huquqiy maqom» va «Milliy metodikalar va protseduralar» bo‘limlari bor;
  - hozircha ular halol bo‘sh holatni ko‘rsatadi: «kontent hali yuklanmagan; har bir yozuvda rasmiy manba, kuchga kirgan sana, tahrir va oxirgi tekshiruv sanasi bo‘ladi».
- Ilmiy qatlam tanlangan yurisdiksiyadan qat’i nazar bir xil.

## 6. Testlar

- `fe_content_schema/test/jurisdiction_test.dart` (20 test):
  - resolver zanjiri va meros;
  - kuchda bo‘lish sanasi;
  - faqat publishable qoidalar;
  - compare;
  - aylanma himoya;
  - FE012–FE016;
  - production taqiqlari.

  Yurisdiksiyalar ISO 3166 «user-assigned» kodlari (`XA`, `XB`) bilan berilgan, real davlatlar ishlatilmagan.
- `fe_database/test/database_test.dart` (4 test):
  - qatlam `CHECK`’lari;
  - FK;
  - kuchga kirish davri.
- Ilova:
  - sozlama saqlanishi;
  - tanlash ekrani;
  - Profil qatori;
  - kartochkada qatlamlar ajratilgani;
  - noma’lum ID’da «Xalqaro»ga qaytish;
  - Compare o‘chirilgani;
  - a11y / 320dp / offline.

## 7. Keyingi qadamlar (kontent bosqichida, PHASE 3+)

1. Har bir yurisdiksiya uchun **legal reviewer** (RG-04) va rasmiy manba (masalan, rasmiy huquqiy baza) tanlanadi.
2. Hujjatlar faqat rasmiy matndan kiritiladi va oxirgi tekshiruv sanasi bilan belgilanadi.
3. Davriy qayta tekshiruv: `lastVerifiedAt` eskirsa, yozuv `OUTDATED` holatiga o‘tadi.
4. «Compare jurisdictions» kamida ikki yurisdiksiya uchun tekshirilgan kontent paydo bo‘lgach yoqiladi.
