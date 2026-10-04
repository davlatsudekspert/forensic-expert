# 15 — Reagentlar, metodlar, skrining, sud tibbiyoti va biokimyo (PHASE 4)

## 1. Qat’iy qoidalar (validator)

| Kod | Qoida |
|---|---|
| FE018 | Tayyorlash ma’lumoti bor retsept — manbasiz bo‘lishi mumkin emas |
| FE019 | Qo‘shish tartibi faqat manba tartibni aniq aytgan bo‘lsa raqamlanadi |
| FE021 | Skrining testi tasdiqlovchi metodsiz bo‘lishi mumkin emas |
| FE022 | Cut-off, sezgirlik, spetsifiklik, harorat va boshqa raqamlar — faqat `SourcedValue` (manba + joy) bilan |
| FE023 | «Yakuniy identifikatsiya» faqat avtoritet manba bilan |
| FE024 | 4 metod turi aralashtirilmaydi; tashkilot va yurisdiksiya qoidalari |
| FE025 | Matn: o‘zimiz yozgan qisqa mazmun yoki ochiq litsenziyali iqtibos. Pullik standart yoki SOP matni ko‘chirilmaydi |
| FE026 | Yangi muammo — manba va sanasiz bo‘lishi mumkin emas |

**Hech qachon taxmin qilinmaydi:** retsept, nisbat, konsentratsiya, yaroqlilik muddati, saqlash sharti.

## 2. Pilot yozuvlar (barchasi NEEDS_REVIEW, real manba bilan)

Barcha iqtiboslar PMC BioC asl matni bilan aniq solishtirilgan; litsenziyasi CC BY.

| Yozuv | Turi | Manba (asl jumla) |
|---|---|---|
| Livor mortis | FM mavzusi, ta’rif | PMC12450430 (narrativ review, C) |
| Algor mortis | FM mavzusi, ta’rif | PMC11580817 (B) |
| PMI | FM mavzusi, cheklov (noaniqlik) | PMC10861637 (C) |
| Vitreous kaliy va PMI | Biokimyo: marker + harorat cheklovi | PMC5431803 (B), PMC13224331 (C) |
| Marquis reagenti | Reagent: qo‘llanish konteksti va rang testlari «presumptive» | PMC11961553 (B), PMC5537996 (C) |
| Immunoanaliz skriningi | Skrining: «presumptive», cross-reactivity → soxta ijobiy | PMC11402778 (B), PMC2688477 (B) |
| GC-MS | Ilmiy metod: sud toksikologiyasidagi o‘rni | PMC11929145 (C) |
| Nitazenlar | Yangi muammo (sintetik opioidlar), sana 2025-05-13 (epub) | PMC12147671 (B) |

**Rad etilganlar (sababi bilan, `content/pilot/curation_p4.json`):**
- Rigor mortis — topilgan manba faqat stomatologiya kontekstida;
- LC-MS/MS — veterinariya manbasi;
- postmortem biokimyo cheklovlari — mos jumla topilmadi.

## 3. UI xulosalari

- **Reagent.** Ochiq manbada tasdiqlangan retsept topilmagan, shuning uchun «Tayyorlash» bo‘limida «MA’LUMOT TEKSHIRILMAGAN» holati va izoh ko‘rsatiladi. To‘liq retsept ko‘rinishi faqat TEST fixture’da tekshirilgan (TEST DATA belgisi bilan).
- **Skrining.** Doimiy «SKRINING NATIJASI ≠ TASDIQLANGAN IDENTIFIKATSIYA» banneri. Manbasiz cut-off o‘rniga «Manbalarda ko‘rsatilmagan — taxmin qilinmaydi» deb yoziladi.
- **Metodlar.** 4 tur alohida bo‘limlarda; bo‘sh turlar halol ko‘rsatiladi.
- **Sud tibbiyoti.** 25 mavzu; «25 mavzudan 3 tasida manbali ma’lumot bor».
- **Eritma kalkulyatori.** Ta’rifiy hisob, NEEDS_REVIEW. Molyar massa va tozalik foydalanuvchidan olinadi; «bu retsept emas» cheklovi bor.

## 4. Kengayish yo‘li (PHASE 5+, egasining tasdig‘i bilan)

- Har bir yangi yozuv: manba → validator → review (four-eyes) → REVIEWED/VERIFIED.
- Ustuvorlik — reviewer tasdiqlagan 50 ta to‘liq yozuv, keyin yuzlab va minglab yozuvlar.
