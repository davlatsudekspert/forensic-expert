# 14 — Global yurisdiksiya modeli (PHASE 4)

## 1. Tamoyillar

- Ilmiy yadro yurisdiksiyadan mustaqil. Huquqiy ma’lumot alohida qatlam va **hech qachon ilmiy claim emas**.
- **«Topilmadi = ruxsat / nazoratda emas / taqiqlangan»** — hech qachon. Ma’lumot yo‘q bo‘lsa, UI «ma’lumot yo‘q — xulosa chiqarilmaydi» deydi.
- Barcha davlatlar uchun ommaviy qonun yig‘ilmaydi. Har bir yurisdiksiya rasmiy manba va legal reviewer bilan qo‘shiladi (RG-15).

## 2. Model

| Obyekt | Asosiy maydonlar |
|---|---|
| `Jurisdiction` | ID (ISO 3166-1 yoki 3166-2), daraja (international / supranational / country / subdivision), ota yurisdiksiya, nomlar |
| `Authority` | Hujjat chiqargan organ (masalan, «The Scottish Ministers») |
| `JurisdictionalInstrument` | Turi, organ, rasmiy manba, havola, kuchga kirish sanasi, versiya, nashr / o‘zgartirish sanasi, huquqiy holat (in force / amended / superseded / repealed), til, tarjima holati |
| `JurisdictionalRule` | Turi (control status / legal threshold / procedure), predmet, qiymat, modda/bo‘lim, `topicKey`, `appliesTo` (hududiy qamrov), versiya |

## 3. Hal qilish qoidalari (`JurisdictionResolver.view`)

1. Zanjir quriladi: tanlangan hudud → davlat → INT.
2. Qoida faqat shu sanada kuchda bo‘lsa olinadi. Hujjat bekor qilingan yoki almashtirilgan bo‘lsa, olinmaydi.
3. **Hududiy qamrov.** Davlat qoidasida `appliesTo` bor bo‘lsa va tanlangan hudud unda yo‘q bo‘lsa, qoida o‘tkazib yuboriladi. Misol: RTA s.11 «E+W+S» → Shimoliy Irlandiyaga meros o‘tmaydi.
4. **Aniqroq yurisdiksiya ustun.** Bir xil `topicKey` bo‘yicha eng yaqin yurisdiksiya qoidasi qoladi; qolganlari `overridden` ro‘yxatiga tushadi va UI’da shaffof ko‘rsatiladi. Misol: Shotlandiyada SSI 2014/328 GB qoidasi o‘rniga amal qiladi.
5. Production kanalda faqat reviewer tasdiqlagan qoidalar ko‘rsatiladi. Pilot kanalda NEEDS_REVIEW qoidalar ham chiqadi, lekin har doim status belgisi bilan.

## 4. Pilot: Buyuk Britaniya (mast holda haydash chegarasi)

| Hudud | Manba | Nafas | Qon | Siydik |
|---|---|---|---|---|
| Angliya, Uels | RTA 1988 s.11(2), legislation.gov.uk XML (SHA-256), matn holati 2026-06-29, bo‘lim hududi E+W+S | 35 µg/100 mL | 80 mg/100 mL | 107 mg/100 mL |
| Shotlandiya | SSI 2014/328 reg.2 (made 2014-11-20, in force 2014-12-05) | 22 µg/100 mL | 50 mg/100 mL | 67 mg/100 mL |
| Shimoliy Irlandiya | — | ma’lumot yo‘q | ma’lumot yo‘q | ma’lumot yo‘q |

- Barcha qiymatlar rasmiy XML matnidan olingan va pipeline tomonidan asl matn bilan solishtirilgan.
- Matn Open Government Licence v3.0 ostida.
- Status: NEEDS_REVIEW (legal reviewer yo‘q — RG-15).
- **Cheklov:** RTA uchun `effective_from` — legislation.gov.uk dagi shu matn versiyasining boshlanishi (2018-03-01). Bu qonun qabul qilingan sana emas.

## 5. Compare Jurisdictions

- Mavzu (`topicKey`) bo‘yicha yonma-yon solishtirish; yurisdiksiya tanlash yig‘iladigan panelda.
- Har bir katakda quyidagilar ko‘rsatiladi:
  - organ;
  - modda yoki bo‘lim;
  - kuchga kirish sanasi va oxirgi tekshiruv;
  - huquqiy holat;
  - hududiy qamrov;
  - rasmiy matn iqtibosi;
  - «o‘rniga amal qiladi» belgisi.
- Doimiy ogohlantirishlar: «yuridik maslahat emas» va «ma’lumot yo‘qligi xulosa emas».
- Yangi yurisdiksiya qo‘shish faqat kontent ishi: bundle’ga yurisdiksiya, organ, hujjat va qoida yoziladi. Ilova kodi o‘zgarmaydi.
