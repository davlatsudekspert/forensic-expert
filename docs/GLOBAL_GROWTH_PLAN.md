# FORENSIC EXPERT — global o‘sish va narx rejasi

| | |
|---|---|
| Sana | 2026-10-12 |
| Holat | **Tavsiya.** Kod o‘zgartirilmagan. Narx do‘konga kiritilmagan. Ommaviy nashr yo‘q |
| Asos | Repo hujjatlari (`02`, `05`, `STORE_PRODUCT_SETUP`, `AUTH_AND_SUBSCRIPTIONS`, `REFERRALS`, `USTOZ_PRO_PLAN`, `PROJECT_STATUS`, `BACKLOG`) + kod (`billing_ports.dart`, `paywall_screen.dart`, `features/pro`, `ai-answer`) + veb-manbalar (8-bo‘lim) |
| Belgilar | **[M]** — manbada bor (8-bo‘limdagi raqam). **ESTIMATE** — mening taxminim, asosi yozilgan. **TEKSHIRISH** — rasmiy tasdiq topilmadi |

---

## 1. Qisqa xulosa

1. **Avval pul olish yo‘lini yoping.** RG-18 (server xarid tekshiruvi), Apple Small Business Program’ga yozilish (15 %), do‘konda 4 obunani narx bilan yaratish. Busiz har qanday «fishka» foyda bermaydi.
2. **Uch narx guruhi (A/B/C), yillik tarif standart tanlov, faqat yillikda 7 kunlik bepul sinov.** Lifetime yo‘q. Professional Pro: A — $99.99/yil, B — $49.99, C — $24.99. Student Pro: $39.99 / $19.99 / $9.99.
3. **O‘zbekistonda asosiy daromad — muassasa litsenziyasi**, shaxsiy obuna emas. Sabab: Google Play O‘zbekistonda faqat Visa/Mastercard/Amex/Discover qabul qiladi [M18]; Humo/Uzcard ishlamaydi. Apple 3.1.3(c) muassasaga to‘g‘ridan-to‘g‘ri sotishga ruxsat beradi [M12].
4. **Bepul qism ishonch yaratsin:** ABY yozuvlari (egasi qarori bo‘yicha bepul), xavfsizlik va manbalar, Henssge va Widmark natijasi, sudda so‘roq demo, casebook nusxasi — bepul. Pul — chuqurlik, vaqt tejash va natijani ishga olib borish uchun.
5. **Birinchi to‘lovchi bozorlar:** O‘zbekiston (muassasa + xalqaro talabalar), Qozog‘iston, keyin Hindiston va O‘zbekistondagi 16 ming xalqaro tibbiyot talabasi (inglizcha) [M20]. Rossiyada ikkala do‘konda to‘lov ishlamaydi [M9][M10] — u yerda faqat bepul tarqatish.
6. **AI xarajati nazoratda emas:** hozir `ai-answer` hamma uchun bir xil — soatiga 30 so‘rov (`FE_AI_HOURLY_LIMIT`). Ommaviy nashrdan oldin tarif bo‘yicha kvota shart.
7. **«Tasdiqlangan» deb sotmang:** HUMAN VERIFIED = 0. Marketing «har gap manbasi va sahifasi bilan» deyadi. A guruhi (AQSh/YeI) — kamida 100 ta inson tekshirgan yozuvdan keyin.

---

## 2. Kim sotib oladi

Aniq rasmiy statistika ko‘p segmentda topilmadi. Raqamlar shuning uchun **ESTIMATE** — tartib (order of magnitude) sifatida o‘qing.

| Segment | Hajm | To‘lashga tayyorlik | Nima uchun to‘laydi | Qanday sotiladi |
|---|---|---|---|---|
| **Talaba** (tibbiyot, farmatsiya, sud ekspertizasi, huquq) | UZ: bir necha ming sud tibbiyoti fanini o‘qiydi (ESTIMATE). UZ’dagi xalqaro tibbiyot talabalari — 16 476, shundan hindistonlik — 10 000+ [M20]. Hindistonda forensic science BSc/MSc — o‘n minglab (ESTIMATE) | Past: C guruhida $1–3/oy (ESTIMATE). Xalqaro talabalar — xalqaro kartasi bor, sal yuqori | Imtihon, test, tez takrorlash | Student Pro, imtihon mavsumi chegirmasi, universitet litsenziyasi |
| **Ekspert-amaliyotchi** (sud-tibbiy, sud-kimyo, toksikolog, kriminalist) | UZ: bir necha yuz – ~1 000 (ESTIMATE). MDH: o‘n minglab (ESTIMATE). Dunyo: forensic tox/chem — yuz minglab (ESTIMATE) | O‘rta: C — $2–4/oy; A — $8–15/oy (epocrates+ $179.99/yil, AMBOSS klinitsist ~$259/yil bilan solishtiriladi [M1][M2]) | Vaqt: modda → namuna → usul; sudda so‘roq; xulosaga cheklov bloklari | Professional Pro; hamkasb taklifi |
| **Laboratoriya / ekspert markazi** | UZ: respublika markazi + viloyat filiallari, ~15–20 bo‘linma (ESTIMATE). MDH: yuzlab (ESTIMATE) | Yuqori, lekin sekin (byudjet, shartnoma) | Bir xil usul standarti, yangi xodim o‘qitish, ABY bilan moslik | Muassasa litsenziyasi (o‘rindiq bo‘yicha), Apple 3.1.3(c) |
| **Universitet / tibbiyot kolleji** | UZ: tibbiyot oliygohlari ~10+ (ESTIMATE) + yuridik fakultetlar va IIV akademiyasi | Byudjet orqali | Ustoz Pro (dars taqdimoti), test banki, talaba statistikasi | Kafedra litsenziyasi, talaba boshiga narx |
| **Huquqshunos / advokat / tergovchi** | UZ: minglab (ESTIMATE); faqat kichik qismi ekspertiza bilan ishlaydi | O‘rta–yuqori (ish puli mijozdan) | Ekspert xulosasini o‘qish, «tergovchi qo‘yadigan savollar», atamalar lug‘ati | Hozircha Professional Pro; alohida «huquqshunos» rejimi — 3 oydan keyin |

**Xulosa:** pul hajmi bo‘yicha birinchi — muassasa (UZ) va xalqaro ingliz tilli talaba. Ovoz/ishonch bo‘yicha birinchi — O‘zbekiston ekspertlari (ular hamkasbini taklif qiladi).

---

## 3. Nega sotib olishadi — «fishkalar»

Hozir pullik devor ortida nima bor (kod bo‘yicha, `FeatureGate.minimumTier`):

| Tarif | Kodda ochiladi |
|---|---|
| Free | oflayn baza, xavfsizlik + manbalar; har bo‘limda 3 ta yozuv; qidiruvda har guruhda 3 natija; 2 kalkulyator (eritish, konsentratsiya birliklari); 1 kurs; sudda so‘roq demo |
| Student Pro | to‘liq moddalar, reaktivlar, ekspress-testlar, sud tibbiyoti, standartlar, yurisdiksiyalar, o‘quv rejimi, testlar, cheksiz qidiruv |
| Professional Pro | + laboratoriya vositalari, professional kalkulyatorlar (Widmark, Henssge…), analitik usullar (Pro qidiruv, tahlil rejasi), dalillar, sudda so‘roq to‘liq, professional AI |

Muammo: bepul foydalanuvchi har bo‘limda **faqat 3 ta modda** ko‘radi. Bu ishonch va tarqalishni to‘xtatadi. Pastda tavsiya qilingan chegarani berdim.

### 3.1. Reyting (konversiyaga ta’siri bo‘yicha)

Hajm: S — 1–3 kun, M — 1–2 hafta, L — 3+ hafta.

| # | Fishka | Nima | Nega pul to‘laydi | Hozir bormi | Hajm | Xavf | Free / Pro |
|---|---|---|---|---|---|---|---|
| 1 | **Sudda so‘roq: tayyorgarlik** | Savol-javob kartalari, mashq, «tergovchi qo‘yadigan savollar» (Ғиёсов 2018, bo‘limi bilan) | Eng og‘riqli lahza — sud. Bunga tayyorlanish uchun ekspert pul beradi. Raqobatchilarda yo‘q (`02`, G-4) | **Bor.** Demo bepul, kengaytirilgan simulyator va tarix — Pro | S (paywall matni) | Past. «Javobni yodlatish» emas, halollik tamoyillari saqlansin | Demo — Free; to‘liq — **Pro** |
| 2 | **Modda → namuna → usul → tahlil rejasi** | Pro qidiruv (teskari qidiruv), tahlil rejasi, «xulosa uchun eslatma» | Kunlik ishni 10–20 daqiqaga qisqartiradi (ESTIMATE). Bu 4n6 Tools Pro’da ham yo‘q | **Bor** (`features/pro`) | S | Past. Faqat paketdagi manbali ma’lumot | **Pro** |
| 3 | **Casebook → xulosa uchun cheklov bloklari** | Yo‘riqnomaning «Cheklovlar / Ehtiyot choralari» bo‘limini to‘liq iqtibos va sahifasi bilan ishga ko‘chirish | Ekspert xulosasiga to‘g‘ridan-to‘g‘ri yordam. Ulashilgan matn ilovani reklama qiladi | **Bor** (nusxa/ulashish, gating yo‘q) | S: bepulda 1 ta ish, Pro’da cheksiz. M: DOCX/PDF eksport | O‘rta: matn ekspert xulosasi o‘rnini bosmasligi ochiq yozilsin | 1 ish — Free; cheksiz + eksport — **Pro** |
| 4 | **ABY bo‘yicha amaliyot (faqat UZ)** | ABY joyi aniq ko‘rsatilgan yozuvlar, 328 modda bog‘lamasi | O‘zbekiston ekspertini olib keladigan **magnit**. Pul olmaydi, lekin ishonch va tavsiya yaratadi | **Bor** | — | ABY qoidalari (`CLAUDE.md`): bepul, faqat uz, so‘zma-so‘z iqtibos yo‘q | **Free** (egasi qarori) |
| 5 | **AI — manbali javob** | Savolga faqat ilova manbalaridan javob, iqtiboslar bilan | «Tez javob + manba» — eng kuchli taklif. AI ilovalarda birinchi yil LTV median $30.16 vs $21.37 [M13] | IMPLEMENTED-UNVERIFIED (Gemini, real E2E yo‘q). Tarif kvotasi **yo‘q** | M (tarif kvotasi) | Yuqori: xarajat, noto‘g‘ri javob. Manbasiz matn ko‘rsatilmaydi — saqlansin | Free 3/kun; **Pro** ko‘proq |
| 6 | **Imtihon rejimi + natija guvohnomasi** | Manbali testlar, vaqtli imtihon, mavzu bo‘yicha natija; «o‘zlashtirish guvohnomasi» (rasmiy sertifikat **emas**) | Talaba imtihon oldidan to‘laydi. Guvohnoma ulashiladi — tarqalish | PARTIAL/MOCK: production’da quiz va kartochkalar bo‘sh | L (≥300 manbali savol) | O‘rta: manbasiz savol baholanadigan rejimga kirmaydi (`CLAUDE.md`) | 1 test — Free; **Student Pro** |
| 7 | **Henssge / Widmark va 10 kalkulyator** | Formula, taxminlar, noaniqlik, manba | Qidiruvda ko‘p so‘raladi (ASO). 4n6 Lite Henssge’ni bepul beradi (`02`) | **Bor** (12 vosita), hozir 10 tasi Pro | S | Past. Apple 1.4.1: metodologiya va manba ko‘rsatilishi shart [M12] — bor | Natija — **Free**; noaniqlik hisobi, tarix, hisobot — **Pro** |
| 8 | **Iqtibos eksporti** | Manbani GOST / Vancouver / APA ko‘rinishida nusxalash | Dissertatsiya, maqola, xulosa yozuvchilar uchun vaqt | Yo‘q (manba ma’lumoti bor) | S–M | Past | Bitta — Free; to‘plam — **Pro** |
| 9 | **Oflayn ishlash** | Butun baza qurilmada | Laboratoriya va sud zalida internet yo‘q. Lexidrug/Micromedex onlayn talab qiladi (`02`, G-3) | **Bor** | — | Past | **Free** (marketing dalili) |
| 10 | **Yangilanish ogohlantirishlari** | Yangi NPS, o‘zgargan cutoff, yangi ABY tahriri haqida xabar | «Obuna nega davom etadi?» savoliga javob. Apple 3.1.2 doimiy qiymat talab qiladi [M12] | Imzolangan kontent paketi bor; push yo‘q | M | Past | **Pro** |
| 11 | **Ustoz Pro** | Dars taqdimoti, ko‘rish jurnali, suv belgisi | Universitet litsenziyasini sotadigan asosiy dalil | Reja (`USTOZ_PRO_PLAN.md`), kod yo‘q | L | Yuqori: yurist, 18+, UGC moderatsiyasi | **Muassasa** |
| 12 | **Hamjamiyat savol-javob + tasdiqlangan mutaxassis belgisi** | Ekspertlar javob beradi | Ijtimoiy isbot, qaytib kelish | **Bor**, `FE_QA` bilan o‘chiq | S (yoqish) | O‘rta: Apple UGC talabi — shikoyat/bloklash/moderatsiya | O‘qish — Free; savol berish — Free (cheklangan) |
| 13 | **«Mening kitoblarim»** | O‘zi sotib olgan PDF’ni qurilmada indekslash, AI «Kitob, N-bet» deydi | Kuchli professional fishka | Backlog | L | O‘rta: fayl tarqatilmasin | **Pro** |

### 3.2. Bepul qism (tavsiya etilgan chegara)

Qoida: **bepul foydalanuvchi har bir modda haqida «nima bu va qanchalik xavfli» ni to‘liq ko‘radi.** «Qanday tahlil qilaman va qanday talqin qilaman» — Pro.

| Free | Student Pro | Professional Pro |
|---|---|---|
| Barcha moddalarning asosiy kartasi (nomi, sinfi, huquqiy maqomi, ogohlantirish, manbalar) | Barcha moddalarning to‘liq yozuvi | Student Pro’dagi hammasi |
| ABY yozuvlari (uz) | Barcha kurslar, testlar, kartochkalar, imtihon rejimi | Tahlil rejasi, Pro qidiruv, analitik usullar |
| Henssge, Widmark, eritish, birliklar — natija | Cheksiz qidiruv | Kalkulyatorlar: noaniqlik, tarix, hisobot |
| Sudda so‘roq — namunaviy kartalar | AI: 150 so‘rov/oy | Sudda so‘roq — to‘liq simulyator va tarix |
| Casebook — 1 ta ish | | Casebook cheksiz + eksport |
| AI: 3 so‘rov/kun | | AI: 400 so‘rov/oy (keyin arzon model) |
| 1 ta test to‘plami | | Yangilanish ogohlantirishlari |

Xavfsizlik, cheklovlar va provenance — **hech qachon** pullik emas (kodda shunday, saqlanadi).

---

## 4. Narxlar

### 4.1. Bozordagi tayanch narxlar

| Mahsulot | Narx | Model | Manba |
|---|---|---|---|
| 4n6 Tools Pro (eng yaqin raqobatchi) | iOS $99.99, Android $94.99 | bir martalik | `02` (2026-10-04) |
| epocrates+ | $179.99/yil yoki $24.99/oy; talabaga bepul (edu email) | obuna | [M1] |
| AMBOSS | talaba $19.99/oy yoki $12.50/oy yillik (~$150); klinitsist $29.99/oy yoki $21.58/oy yillik | obuna | [M2] |
| UpToDate (AMSA a’zolari) | talaba $109.50/yil, rezident $175.20/yil | obuna | [M3] |
| UpToDate Lexidrug (iOS) | $29.99/oy, 1 oylik sinov | obuna | [M4] |
| Complete Anatomy | talaba $39.99 birinchi yil, keyin $74.99/yil; muassasa — faqat so‘rov bo‘yicha | obuna | [M5] |
| Osmosis | $199.99/yil (App Store, 2026-07-16 holati) | obuna | [M6] |
| TOXBASE | $6.99/yil | obuna | `02` |
| Bloodstain ID Decision Map | $39.99 | bir martalik | `02` |

**Xulosa:** klinik liderlar $150–260/yil. Bizda inson tekshirgan kontent hali 0 — shuning uchun A guruhida **ulardan arzon**, 4n6 Pro’ning bir martalik narxiga teng yillik narx.

### 4.2. Narx zinapoyasi

Guruhlar (har mamlakat uchun narx do‘kon konsolida qo‘lda qo‘yiladi — Apple 900 narx nuqtasi beradi va boshqa mamlakatlarni valyuta kursi bo‘yicha avtomatik tenglashtiradi, xarid qobiliyatini hisobga olmaydi [M7]):

- **A:** AQSh, Kanada, Buyuk Britaniya, YeI (G‘arbiy), Shveytsariya, Norvegiya, Avstraliya, Yaponiya, Koreya, BAA, Saudiya Arabistoni, Qatar, Quvayt, Isroil.
- **B:** Qozog‘iston (YaMD $12 090 [M8]), Turkiya, Braziliya, Meksika, Sharqiy YeI, Gruziya, Armaniston, Ozarbayjon, Malayziya.
- **C:** O‘zbekiston (YaMD $3 020 [M8]), Qirg‘iziston ($2 190), Tojikiston ($1 650), Hindiston, Pokiston, Bangladesh, Misr, Indoneziya, Vetnam, Filippin.
- **Faqat bepul:** Rossiya va Belarus — do‘kon to‘lovlari ishlamaydi [M9][M10].
- **Chiqarilmaydi:** Xitoy (alohida litsenziya talablari — TEKSHIRISH).

| | A | B | C |
|---|---|---|---|
| **Professional Pro — yillik** (standart tanlov) | **$99.99** | **$49.99** | **$24.99** |
| Professional Pro — oylik | $14.99 | $6.99 | $3.99 |
| **Student Pro — yillik** (standart tanlov) | **$39.99** | **$19.99** | **$9.99** |
| Student Pro — oylik | $5.99 | $2.99 | $1.49 |
| Yillikning oylikka nisbati | ~44 % tejash | ~40 % | ~48 % |

Asos:
- A: Pro yillik = 4n6 Pro bir martalik narxi; epocrates+ dan 44 % arzon. Student — Complete Anatomy talaba narxiga teng [M5].
- B ≈ A × 0.5, C ≈ A × 0.25 (ESTIMATE). O‘zbekiston YaMD AQShnikidan ~20+ marta past (ESTIMATE). Lekin xarid qiluvchi — xalqaro kartali, odatda daromadi yuqoriroq odam. Shuning uchun 1/25 emas, 1/4.
- C’da $24.99 ≈ 300–325 ming so‘m/yil (1 USD ≈ 12–13 ming so‘m — ESTIMATE, kurs tekshirilmagan).
- Student Pro’da tasdiqlash so‘ralmaydi (`AUTH_AND_SUBSCRIPTIONS`: minimal ma’lumot). Himoya — **o‘z-o‘zini tanlash**: Student Pro’da professional vositalar yo‘q, mutaxassisga u yetmaydi.

**Lifetime: yo‘q.** Kod ham shunday (`fe_lifetime_unlock` yaratilmaydi). Sabab: lifetime eng sodiq foydalanuvchining kelajakdagi to‘lovini yeydi [M11]. AI va kontent yangilanishi doimiy xarajat. 6 oydan keyin qayta ko‘riladi: faqat Pro, yillik narxning ≥5 baravari [M11].

**Muassasa (do‘kondan tashqari, shartnoma, Apple 3.1.3(c) [M12]):**

| | A | B | C (UZ) |
|---|---|---|---|
| Professional o‘rindiq / yil | $60 (5–49 o‘rindiq), $45 (50+) | $30 / $22 | **$15 / $10** |
| Talaba o‘rindig‘i / yil (kafedra, min 100) | $15 | $8 | **$4** |
| Minimal shartnoma | 5 o‘rindiq | 5 | 10 professional yoki 100 talaba |
| Ustoz Pro (tayyor bo‘lganda) | kafedra uchun qo‘shimcha ESTIMATE: $300/yil | $150 | $75 |

Mantiq: chakana narxdan 40–60 % chegirma (ESTIMATE). Guruh chegirmasi soha amaliyoti: UpToDate 50+ talaba guruhiga alohida narx beradi [M3]; Complete Anatomy muassasa narxini faqat so‘rov bilan beradi [M5]. Texnik asos bor: `admin_set_access` server granti. Yetishmaydi: ommaviy grant va o‘rindiq boshqaruvi (M).

### 4.3. Sinov (trial)

- **7 kunlik bepul sinov — faqat yillik tariflarda** (Pro va Student). Oylikda sinov yo‘q.
- Dalil: 5–9 kunlik sinovlarda trial→to‘lov mediani 37.4 %, ≤4 kunlikda 25.5 %, 17–32 kunlikda 42.5 % [M13]. 3 kunlik sinov bekor qilishlarining 55.4 % — 0-kuni [M13].
- 14 kun — keyingi test (7-bo‘lim). Boshlashda 7 kun: AI xarajati va suiiste’mol kamroq.
- Sinov boshlanishidan oldin: muddat, nima yopilishi, narx — aniq yoziladi (Apple 3.1.2 [M12]).

### 4.4. Paywall qayerda

| Joy | Qachon | Nima ko‘rsatiladi |
|---|---|---|
| 1. Onboarding oxiri | Til → ogohlantirish → rejim (Talaba/Mutaxassis) tanlangandan keyin | Rejimga mos bitta tarif, yillik oldindan tanlangan, «7 kun bepul», katta «Hozircha bepul davom etish» tugmasi |
| 2. Qiymat lahzasi | Sudda so‘roq demosi tugaganda; tahlil rejasi tugmasi; casebook’da 2-ish; AI limiti; yopiq modda bo‘limi; kalkulyatorda «noaniqlik» | Aynan shu funksiya nima beradi — 1 ekran |
| 3. Profil → Pro | Doim | To‘liq taqqoslash jadvali |

Dalil: onboarding paywall + trial eng yuqori nisbiy konversiyani beradi (1.35 % vs ilova ichida 0.89 %, Adapty matritsasi, maxraj ko‘rsatilmagan) [M14]. Qattiq paywall 5 baravar ko‘p konversiya qiladi (10.7 % vs 2.1 %) [M13] — lekin bizda Apple 5.1.1(v) bo‘yicha hisobsiz asosiy funksiya va ishonch kerak. Shuning uchun **yopiladigan** onboarding paywall + qiymat lahzasi.

### 4.5. Chegirma kalendari

Do‘kon vositalari: Apple introductory/promotional offer va offer code; Google Play developer-determined offer (sozlash — egasi).

| Davr | Kimga | Taklif |
|---|---|---|
| Sentyabr (o‘quv yili boshlanadi) | Talaba | Student yillik −30 % birinchi yil |
| Noyabr oxiri (Black Friday) | Hammaga (A, B) | Pro yillik −30 % birinchi yil |
| Dekabr – yanvar (qishki sessiya, UZ) | Talaba | Student yillik −25 % |
| Mart (Navro‘z, UZ) | UZ | Pro yillik −20 % |
| May – iyun (yozgi sessiya, bitiruv) | Talaba, bitiruvchi | Student → Pro o‘tishda birinchi yil −40 % |
| Iyul – avgust (ordinatura/magistratura imtihonlari) | Talaba | Student yillik −25 % |

Sessiya sanalari universitetga qarab farq qiladi (ESTIMATE). Yiliga 4–5 tadan ko‘p aksiya qilmang — narx ishonchi tushadi.

### 4.6. Referral iqtisodi

Hozir (`REFERRALS.md`): 10 % FORENSIC Credits, faqat server tasdiqlagan xariddan, 14 kunlik oyna, kuniga 20 limit, `rewards_enabled = false`.

**Tavsiya:**
- Kreditni **valyuta qilmang.** Apple 3.1.1 ilovaning o‘z mexanizmi bilan funksiya ochishni taqiqlaydi [M12]. Kredit «pul» ga o‘xshasa, xavf bor.
- O‘rniga: taklif qilingan odam **yillik** obuna olsa → taklif qilganga **30 kun Pro** (server granti, sotilmaydi, almashtirilmaydi). Yillikda 12 oygacha.
- Taklif qilingan odamga: oddiy 7 kunlik sinov (alohida taklif yo‘q — sodda).
- Narxi bizga: 30 kun Pro ≈ $8.33 (A), $2.08 (C) yo‘qotilgan daromad (agar u baribir to‘lagan bo‘lsa) + AI ~$0.59. Bitta yillik xarid net daromadi: A $85, C $19 (4.7). **Har holatda foydali.**
- Ikki tomonlama mukofot keng tarqalgan [M15], lekin referral samaradorligi bo‘yicha jiddiy tadqiqot topilmadi [M15]. O‘zimiz o‘lchaymiz (7-bo‘lim).
- `rewards_enabled = true` — faqat RG-18 ishga tushgandan keyin.

### 4.7. Unit-iqtisod

**Farazlar:**
- Do‘kon ulushi 15 %: Apple Small Business Program (yozilish kerak) va Google obunalari [`05`, VERIFIED].
- QQS: UZ va KZ 12 % (Apple soliqsiz narxdan hisoblaydi; Google’da UZ dasturchisi UZ xaridorlari uchun QQS’ni o‘zi to‘laydi) [`05`]. AQSh — 0 % (soddalashtirish).
- AI narxi: `05` dagi Haiku bahosi $0.0106/so‘rov — **yuqori chegara**. Hozir Gemini Flash ishlatiladi; uning narxi ~2 baravar past bo‘lishi mumkin (ESTIMATE, TEKSHIRISH [M16]).
- AI ishlatish: Pro — 70 % × 80 so‘rov = $0.59/oy; Student — 70 % × 40 = $0.30/oy; Free — 30 % × 8 = $0.025/MAU/oy [`05`].
- Doimiy infratuzilma: ~$55/oy (Supabase Pro $25, Apple $8.25, domen ~$1, Resend $0–20) [`05`]. Reviewer mehnati **kiritilmagan**.

| Guruh / tarif | Narx/yil | QQS’siz | −15 % do‘kon | AI/yil | **Hissa/yil** | Hissa/oy |
|---|---|---|---|---|---|---|
| A — Pro yillik | $99.99 | $99.99 | $84.99 | $7.08 | **$77.91** | $6.49 |
| A — Student yillik | $39.99 | $39.99 | $33.99 | $3.60 | **$30.39** | $2.53 |
| B (KZ) — Pro yillik | $49.99 | $44.63 | $37.94 | $7.08 | **$30.86** | $2.57 |
| B (KZ) — Student yillik | $19.99 | $17.85 | $15.17 | $3.60 | **$11.57** | $0.96 |
| C (UZ) — Pro yillik | $24.99 | $22.31 | $18.97 | $7.08 | **$11.89** | $0.99 |
| C (UZ) — Student yillik | $9.99 | $8.92 | $7.58 | $3.60 | **$3.98** | $0.33 |
| C (UZ) — muassasa o‘rindig‘i | $15.00 | $13.39 (QQS shartnomaga bog‘liq) | 0 % (do‘kon yo‘q) | $7.08 | **$6.31** | $0.53 |

**Zararsizlik nuqtasi (oyiga):**

| Ssenariy | Oylik xarajat | Faqat C-Pro | UZ aralash (50/50 C) | Faqat A-Pro |
|---|---|---|---|---|
| 2 000 MAU | $55 + $51 free AI = **$106** | 108 obunachi | 161 | 17 |
| 10 000 MAU | ~$70 + $254 = **$324** | 328 | 491 | 50 |
| 10 000 MAU + reviewer $500/oy (HYPOTHETICAL) | **$824** | 833 | 1 249 | 127 |

**Xulosa:**
- Faqat O‘zbekiston shaxsiy obunasi reviewer mehnatini qoplamaydi. Kerak: muassasa + B guruhi + ingliz tilli talaba, keyin A.
- C guruhida AI hissani yarmidan ko‘pini yeydi. Shuning uchun: Pro limiti 400/oy, keyin arzon model; Free — 3/kun; lokal kartochka birinchi (`05`, 4.3).
- Yillik obunachilarning 72 % i birinchi yilda bekor qiladi, 35 % i — 1-oyda [M13]. Birinchi oy tajribasi hal qiladi.

---

## 5. Global kirish tartibi

### 5.1. Til va mamlakat tartibi

| Bosqich | Til | Mamlakatlar | Nima uchun | Narx |
|---|---|---|---|---|
| 1 | UZ (mukammal) | O‘zbekiston | ABY, ustozlar, egasining tarmog‘i, raqobat yo‘q (`02`, G-1) | C + muassasa |
| 2 | RU | Qozog‘iston, Qirg‘iziston, Tojikiston, Ozarbayjon, Gruziya, Armaniston; Rossiya — faqat bepul | MDHda RU professional tili; KZ — eng yuqori xarid qobiliyati (YaMD $12 090 [M8]) | B / C |
| 2 | EN | O‘zbekistondagi xalqaro tibbiyot talabalari, Hindiston, Pokiston | 16 476 xalqaro tibbiyot talabasi UZ’da [M20]; hind raqobatchilari manbasiz va reklamali (`02`) | C |
| 3 | KK, TG, KY | Qozog‘iston, Tojikiston, Qirg‘iziston | Mahalliy til — ishonch | B / C |
| 4 | EN | AQSh, Buyuk Britaniya, YeI, Fors ko‘rfazi | Eng yuqori narx, eng kuchli raqobat (4n6, klinik liderlar), GDPR | A — **≥100 inson tekshirgan yozuvdan keyin** |

Rossiya: Google 2022-03-10 dan billing’ni to‘xtatgan, 2022-05-05 dan pullik ilovalarni bloklagan [M10]; Apple 2026-04-01 dan yangi xaridlarni to‘xtatgan [M9]. Daromad yo‘q — faqat obro‘ va RU sharhlar uchun.

### 5.2. ASO kalit so‘zlar

Diqqat: App Store metadata tillari ro‘yxatida o‘zbek tili bo‘lmasligi mumkin — TEKSHIRISH (App Store Connect’da). Bo‘lmasa, UZ so‘zlar RU yoki EN lokalizatsiyasining kalit so‘z maydoniga qo‘shiladi.

| Til | Kalit so‘zlar |
|---|---|
| UZ | sud tibbiyoti, sud kimyosi, toksikologiya, ekspertiza, zaharlanish, modda tahlili, YuQX, GX-MS, Henssge, Widmark, etanol, test, ABY, ekspert |
| RU | судебная медицина, судмедэксперт, судебная химия, токсикология, экспертиза, отравление, ТСХ, ГХ-МС, Хенссге, Видмарк, этанол, тесты, справочник |
| EN | forensic toxicology, forensic medicine, forensic chemistry, toxicology reference, postmortem interval, Henssge, Widmark, TLC, GC-MS, forensic exam prep, reagents |
| KK/TG/KY | 3-bosqichda, ona tilida so‘zlashuvchi mutaxassis bilan |

Metadatada **ishlatmang:** «drugs», «narcotics», «наркотики», «giyohvand» — sotish bilan adashtirish xavfi (Apple 1.4.3 [M12]). O‘rniga «drug analysis», «анализ веществ», «modda tahlili». Nom va subtitle’da narx yozilmaydi (Apple 2.3.7 [M12]).

### 5.3. Do‘kon sahifasi

- Birinchi 3 skrinshot: (1) «Har gap — manba va sahifa bilan»; (2) Sudda so‘roq tayyorgarligi; (3) Modda → usul → tahlil rejasi. Keyin: oflayn, kalkulyatorlar, ABY (faqat UZ sahifada).
- «Tasdiqlangan», «expert-verified» so‘zlari **yo‘q** — HUMAN VERIFIED = 0. Apple 2.3.1: bo‘lmagan xizmatni reklama qilish — ilovani olib tashlash sababi [M12].
- Halollik bandi («ekspert xulosasi o‘rnini bosmaydi») saqlanadi (`APP_STORE_CONNECT_PROMPT.md`).

### 5.4. Review va qonunchilik xavflari

| Xavf | Qoida | Holat | Chora |
|---|---|---|---|
| Nazoratdagi moddalar | Apple 1.4.3 — sotishga yordam taqiqlangan [M12] | Review Notes tayyor | Metadata so‘zlari (5.2); sintez/olish yo‘q (saqlanadi) |
| Tibbiy aniqlik | Apple 1.4.1 — metodologiya va manba, shifokorga murojaat eslatmasi [M12] | Kalkulyatorlarda manba bor | «Bu tibbiy qaror vositasi emas» — kalkulyator natijasida ham |
| Ilovaning o‘z ochish mexanizmi | Apple 3.1.1 [M12]; Google Play billing majburiy, boshqa to‘lovga yo‘naltirish taqiqlangan [M17] | Kredit — hali o‘chiq | Kredit → server granti (4.6). Ilova ichida Click/Payme havolasi **yo‘q** |
| Muassasa litsenziyasi | Apple 3.1.3(c) — faqat tashkilotga to‘g‘ridan-to‘g‘ri sotilsa [M12]; Google’da aniq band topilmadi [M17] | `admin_set_access` bor | Shartnoma faqat yuridik shaxs bilan; jismoniy shaxsga do‘kondan tashqari sotmang |
| Obuna qiymati | Apple 3.1.2 — doimiy qiymat, ≥7 kun [M12] | — | Oylik kontent yangilanishi + o‘zgarishlar jurnali |
| UGC (Savol-javob, Ustoz Pro) | Shikoyat, bloklash, moderatsiya talab qilinadi (`USTOZ_PRO_PLAN`) | `FE_QA` o‘chiq | Yoqishdan oldin tekshiruv |
| Hisobni o‘chirish | Apple 5.1.1(v) [M12] | Bor | — |
| GDPR (YeI) | Huquqiy asos, protsessorlar, transfer | Maxfiylik siyosati yuristda (RG-05) | A guruhidan oldin yurist |
| O‘zbekiston shaxsiy ma’lumotlarni lokalizatsiya qilish talabi | TEKSHIRISH (yurist) | Supabase xorijda | Yurist xulosasi ommaviy nashrdan oldin |
| Gemini bepul tarifida ma’lumotdan foydalanish | TEKSHIRISH (Gemini API shartlari) | `gemini-flash-latest` | Ommaviy nashrdan oldin pullik tarif |

### 5.5. To‘lovni mahalliylashtirish

- O‘zbekistonda Play faqat Amex/Discover/Mastercard/Visa qabul qiladi [M18]. Humo/Uzcard ustunlik qiladi, Apple Pay/Google Pay UZ fuqarolariga yo‘q [M19]. **Shaxsiy obuna bozori kichik bo‘ladi.**
- Yechimlar (tartib bilan):
  1. **Muassasa shartnomasi** (bank o‘tkazmasi, so‘mda) — asosiy kanal.
  2. **Admin orqali sovg‘a/grant** — pilot, aksiya, hamkor ustozlar uchun (bor).
  3. **Xalqaro kartali foydalanuvchi** — do‘kon orqali (Visa/Mastercard ko‘p bank beradi).
  4. Click/Payme orqali veb-sotuv — **hozir yo‘q.** Apple 3.1.3(b) faqat ilova ichida ham IAP bo‘lsa ruxsat beradi; ilovada havola berib bo‘lmaydi; Google’da tashqi xaridni ishlatish qoidasi aniq emas [M17]; soliq va yuridik shaxs kerak. Yurist va buxgalterdan keyin qayta ko‘riladi.
- Apple O‘zbekiston do‘konida narx qaysi valyutada ko‘rinishi — TEKSHIRISH. Apple to‘lovini O‘zbekiston bankiga olish — `05` da NOT VERIFIED. **Bu birinchi haftada aniqlanadi.**

---

## 6. Reja

**Feature-freeze hurmat qilinadi:** 1–2-haftada yangi funksiya yo‘q — faqat closeout va do‘kon sozlamasi. Gating o‘zgarishi va paywall matni — konfiguratsiya darajasidagi kichik ish, egasi tasdiqlagandan keyin.

### 6.1. 4 hafta

| Hafta | Ish | Kim |
|---|---|---|
| 1 | Narx jadvalini tasdiqlash. Apple Small Business Program’ga yozilish. Paid Apps Agreement + bank (UZ bank qabul qilinadimi — aniqlash). 4 obunani A/B/C narxlari va 7 kunlik intro offer bilan **yaratish (nashrsiz)**. RG-18 server tekshiruvi. Resend domeni. Gemini real E2E | Egasi + agent |
| 2 | AI tarif kvotasi (Free 3/kun, Student 150/oy, Pro 400/oy). Bepul chegarani 3.2 bo‘yicha o‘zgartirish. Paywall: onboarding oxiri + 5 qiymat lahzasi; yillik standart. Do‘kon konsoli analitikasi + minimal hodisalar (7-bo‘lim) | Agent |
| 3 | Yopiq beta: 30–50 ekspert, 100 talaba (TestFlight / Play closed testing), sandbox xaridlar. 1 universitet va 1 ekspert markazi bilan pilot kelishuvi (niyat xati). STUDENT/EXPERT/ADMIN real sinov | Egasi + agent |
| 4 | Beta natijasi bo‘yicha tuzatish. **Egasi ruxsati bilan** UZ + KZ + Markaziy Osiyoda ommaviy nashr. Referral mukofoti yoqiladi (RG-18 ishlasa) | Egasi |

### 6.2. 3 oy

| Oy | Ish |
|---|---|
| 1 (yuqoridagi 4 hafta) | Pul yo‘li ochiladi, UZ/KZ nashr |
| 2 | RU va EN kontent QA tugaydi; EN sahifa Hindiston va UZ’dagi xalqaro talabalar uchun. Reviewer jarayoni: **≥50 inson tekshirgan yozuv**. Imtihon rejimi: ≥300 manbali savol — **qishki sessiyadan oldin** (dekabr). Casebook DOCX eksporti. Sentyabr/Black Friday aksiyasi |
| 3 | Muassasa litsenziyasi: ommaviy grant, o‘rindiq boshqaruvi, shartnoma namunasi. Ustoz Pro A bosqichi — bitta universitetda pilot. KK/TG/KY interfeysi. ≥100 tekshirilgan yozuv bo‘lsa — A guruhi va GDPR ko‘rib chiqiladi |

### 6.3. Qaror kerak

| # | Qaror | Tavsiya (standart) |
|---|---|---|
| 1 | Narx jadvali | 4.2 dagi A/B/C narxlar |
| 2 | Sinov | 7 kun, faqat yillikda |
| 3 | Lifetime | Yo‘q (6 oydan keyin qayta ko‘rish) |
| 4 | Bepul chegara | 3.2: barcha moddalarning asosiy kartasi, Henssge/Widmark natijasi, 1 casebook ishi — bepul |
| 5 | AI limitlari | Free 3/kun, Student 150/oy, Pro 400/oy, keyin arzon model |
| 6 | Referral mukofoti | 10 % kredit o‘rniga: yillik xarid uchun 30 kun Pro (server granti); RG-18 dan keyin yoqiladi |
| 7 | Muassasa narxi va kim sotadi | UZ: $15/professional o‘rindiq, $4/talaba, min 10/100; egasi sotadi, shartnoma yuridik shaxs orqali (yurist + buxgalter) |
| 8 | Click/Payme veb-sotuv | Hozir yo‘q |
| 9 | Rossiya | Bepul tarqatiladi, daromad kutilmaydi |
| 10 | Analitika | Birinchi tomonda agregat hodisalar, reklama ID’siz; privacy label yangilanadi |
| 11 | Gemini tarifi | Ommaviy nashrdan oldin pullik tarif |
| 12 | A guruhiga chiqish | ≥100 inson tekshirgan yozuv + GDPR yurist xulosasidan keyin |
| 13 | Apple Small Business Program | Darhol yozilish |

---

## 7. Nimani o‘lchaymiz

### 7.1. Asosiy ko‘rsatkichlar

| Ko‘rsatkich | Ta’rif | Boshlang‘ich maqsad (ESTIMATE) |
|---|---|---|
| Install → onboarding tugadi | rejim tanlanganlar / o‘rnatganlar | ≥70 % |
| Paywall ko‘rish ulushi | D0 va D7 da ≥1 paywall ko‘rgan yangi foydalanuvchi | D7 ≥60 % |
| Paywall → sinov | sinov boshlaganlar / paywall ko‘rganlar | 5–10 % |
| Sinov → to‘lov | 8-kun to‘laganlar / sinov boshlaganlar | ≥35 % (median 37.4 % [M13]) |
| Install → to‘lov (D35) | | Freemium median 2.1 % [M13]; maqsad 2–4 % |
| D1 / D7 / D30 retention | rejim bo‘yicha alohida | 35 % / 18 % / 10 % |
| 1-oyda yillik bekor qilish | | <35 % (median 35 % [M13]) |
| AI so‘rov / faol foydalanuvchi va $ / foydalanuvchi | tarif va guruh bo‘yicha | Pro ≤ $0.60/oy |
| Referral | taklif yuborgan foydalanuvchi ulushi; kod ishlatilishi; taklif qilinganlarning xaridi | xaridning ≥10 % i referraldan |
| Qaytarish (refund) ulushi | | <3 % |
| Daromad guruh bo‘yicha | A/B/C/muassasa ulushi, ARPU | — |

Manba: avval App Store Connect va Play Console analitikasi (kod kerak emas). Keyin Supabase’da agregat hodisalar jadvali: `paywall_view`, `trial_start`, `purchase`, `ai_question`, `referral_share` — email/matnsiz.

### 7.2. A/B testlar

Kichik hajmda (haftasiga <1 000 o‘rnatish) bo‘lingan test ishonchli natija bermaydi. Shuning uchun **ketma-ket test**: 2 hafta A, 2 hafta B, bir xil mamlakat aralashmasida.

| Tartib | Test | Gipoteza |
|---|---|---|
| 1 | Onboarding paywall bor / yo‘q (faqat qiymat lahzasi) | Bor — sinov ko‘p, retention bir xil |
| 2 | Sinov 7 / 14 kun | 14 kun konversiyani oshiradi [M13], AI xarajati ozgina oshadi |
| 3 | Paywall sarlavhasi: «Har gap — manba va sahifa bilan» / «Sudga tayyor bo‘ling» | Mutaxassisda ikkinchisi yutadi |
| 4 | C-Pro yillik $24.99 / $19.99 | Narx elastikligi UZ’da |
| 5 | Henssge/Widmark noaniqlik qismi bepul / Pro | Pro konversiyasi yo‘qolmaydi, ASO oshadi |
| 6 | Referral: 30 kun Pro / 14 kun Pro + taklif qilinganga 14 kunlik sinov | Ikki tomonlama yaxshiroq |

---

## 8. Manbalar

Repo hujjatlari: `docs/02_COMPETITOR_ANALYSIS.md` (2026-10-04), `docs/05_COST_MODEL.md` (2026-10-04), `docs/REFERRALS.md`, `docs/AUTH_AND_SUBSCRIPTIONS.md`, `docs/STORE_PRODUCT_SETUP.md`, `docs/USTOZ_PRO_PLAN.md`, `docs/PROJECT_STATUS.md`, `docs/BACKLOG.md`, `docs/APP_STORE_CONNECT_PROMPT.md`. Kod: `apps/mobile/lib/domain/ports/billing_ports.dart` (`FeatureGate`, `AccessPolicy`), `supabase/functions/ai-answer/index.ts` (`FE_AI_HOURLY_LIMIT` = 30).

Veb-manbalar (hammasi 2026-10-12 da ochilgan):

| # | Nima | URL |
|---|---|---|
| M1 | epocrates+ narxi | https://www.epocrates.com/discover/plus ; https://apppricinglab.com/iap/apple/281935788 |
| M2 | AMBOSS narxlari | https://amboss.com/us/pricing ; https://support.amboss.com/hc/en-us/articles/32345265867921-AMBOSS-Pricing |
| M3 | UpToDate talaba/rezident narxi (AMSA), guruh chegirmasi | https://amsa.org/?p=12139 ; https://www.wolterskluwer.com/en/solutions/uptodate/resources/proof-of-trainee-status |
| M4 | UpToDate Lexidrug iOS | https://apps.apple.com/rs/app/id313401238 ; https://dcdm.doody.com/2016/10/a-review-of-lexicomp-online/ |
| M5 | Complete Anatomy talaba va muassasa | https://store.3d4medical.com/complete-anatomy/license/student ; https://www.elsevier.support/complete-anatomy/answer/how-does-pricing-work |
| M6 | Osmosis IAP narxlari | https://apppricinglab.com/iap/apple/646540641 |
| M7 | Apple 900 narx nuqtasi va tenglashtirish | https://www.apple.com/newsroom/2022/12/apple-announces-biggest-upgrade-to-app-store-pricing-adding-700-new-price-points/ ; https://developer.apple.com/wwdc23/10014 |
| M8 | YaMD aholi jon boshiga 2024 (World Bank WDI, uchinchi tomon ko‘zgusi) va 2025 | https://statisticsoftheworld.com/country/uzbekistan/gni-per-capita ; https://daryo.uz/en/2026/09/09/uzbekistan-records-3700-per-capita-gni-as-kazakhstan-reaches-13700-world-bank-says/ |
| M9 | Apple Rossiyada to‘lovlarni to‘xtatgani (2026-04) | https://support.apple.com/en-in/126891 ; https://www.mactrast.com/2026/04/apple-turns-off-app-store-and-services-payments-in-russia/ |
| M10 | Google Play Rossiyada billing’ni to‘xtatgani (2022) | https://support.google.com/googleplay/android-developer/answer/11950272 ; https://9to5google.com/2022/05/05/google-play-russia-paid-apps/ |
| M11 | Lifetime tarif: foyda va kannibalizatsiya, narx 2–12× yillik | https://www.revenuecat.com/blog/growth/lifetime-subscriptions ; https://www.airbridge.io/en/blog/should-you-offer-a-lifetime-subscription |
| M12 | App Store Review Guidelines (1.4.1, 1.4.3, 2.3.1, 2.3.7, 3.1.1, 3.1.2, 3.1.3(b)(c), 5.1.1(v)) | https://developer.apple.com/app-store/review/guidelines/ |
| M13 | RevenueCat State of Subscription Apps 2026 (2026-03-19, yangilangan 2026-04-22) | https://www.revenuecat.com/blog/growth/subscription-app-trends-benchmarks-2026 ; https://www.revenuecat.com/state-of-subscription-apps |
| M14 | Paywall joyi va sinov (Adapty 2026, ikkilamchi) | https://adapty.io/blog/markdown/high-performing-paywall-2026.md ; https://pricepush.app/blog/trial-to-paid-conversion-rate-benchmarks |
| M15 | Referral dasturlari (vendor maqolalari, jiddiy tadqiqot yo‘q) | https://adapty.io/blog/mobile-app-referral-program/ ; https://www.referralcandy.com/blog/subscription-referral-programs-the-complete-strategy-integration-guide |
| M16 | Gemini Flash narxlari (uchinchi tomon, rasmiy sahifa ochilmadi — TEKSHIRISH) | https://www.morphllm.com/gemini-api-pricing |
| M17 | Google Play Payments policy | https://support.google.com/googleplay/android-developer/answer/9858738 |
| M18 | Google Play to‘lov usullari (ro‘yxatda yo‘q mamlakatlar uchun) | https://support.google.com/googleplay/answer/2651410 |
| M19 | O‘zbekistonda Humo/Uzcard, Apple Pay/Google Pay, PayPal holati | https://gazeta.uz/en/2024/10/04/paypal-apple-pay-google-pay ; https://wise.com/gb/hub/payment-methods/uzbekistan |
| M20 | O‘zbekistondagi xalqaro tibbiyot talabalari (16 476; hindistonlik 10 000+) | https://beta.kun.uz/en/news/2024/11/09/uzbekistan-sees-surge-in-international-students-choosing-medical-studies ; https://www.biospectrumasia.com/news/49/26089/india-and-uzbekistan-announce-collaboration-across-education-business-healthcare.html |

**Topilmagan / tekshirilmagan:** O‘zbekistondagi sud ekspertlari va tibbiyot talabalarining rasmiy soni; Apple O‘zbekiston do‘koni valyutasi; Apple to‘lovini UZ bankiga olish; Gemini’ning hozirgi rasmiy narxi; UZ shaxsiy ma’lumot lokalizatsiyasi talabining ilovaga tatbiqi; Drugs.com Pro narxi; tibbiy toifa bo‘yicha alohida konversiya raqamlari.
