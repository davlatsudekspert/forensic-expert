# 05 — Xarajatlar modeli (Cost Model)

| | |
|---|---|
| Sana | 2026-10-04 |
| Narxlar manbasi | Rasmiy vendor sahifalari, 2026-10-04 da ochilgan (pastdagi jadvalda URL bilan) |
| Muhim | Ko‘p narx sahifalarida «amal qilish sanasi» ko‘rsatilmagan. Byudjet tasdiqlanishidan oldin narxlar qayta tekshirilishi kerak |

## 0. Belgilar

- **VERIFIED** — raqam rasmiy sahifada ko‘rsatilgan.
- **ESTIMATE** — rasmiy narx yo‘q, mening taxminim (asosi yozilgan).
- **HYPOTHETICAL** — faqat modellash uchun olingan faraz (masalan, obuna narxi). Ilovada narxlar **faqat store’dan olinadi**, bu yerdagi raqam hech qayerda kodga yozilmaydi.

---

## 1. Rasmiy narxlar (asosiy kirish ma’lumotlari)

| Xizmat | Narx / shart | URL | Status |
|---|---|---|---|
| Supabase Free | $0; 50 000 MAU, 500 MB DB, 5 GB egress, 1 GB storage, 500K Edge Function chaqiruv. **1 hafta faolsizlikdan keyin loyiha pauza qilinadi** | https://supabase.com/pricing | VERIFIED |
| Supabase Pro | $25/oy dan; 100K MAU (keyin $0.00325/MAU), 8 GB disk (keyin $0.125/GB), 250 GB egress (keyin $0.09/GB), 250 GB cached egress (keyin $0.03/GB), 100 GB storage, 2M Edge chaqiruv (keyin $2/1M); $10 compute krediti (Micro) | https://supabase.com/pricing | VERIFIED |
| Supabase compute | Micro $10, Small $15, Medium $60, Large $110 /oy | https://supabase.com/pricing | VERIFIED |
| Supabase pgvector | Extension sifatida yoqiladi | https://supabase.com/docs/guides/database/extensions/pgvector | PARTIALLY (reja cheklovi aytilmagan) |
| RevenueCat | Oylik kuzatiladigan daromad (MTR) $2 500 gacha bepul, keyin MTR’ning 1% | https://www.revenuecat.com/pricing/ | VERIFIED |
| Claude Haiku 4.5 | $1 input / $5 output (1M token uchun); cache hit $0.10; Batch −50% | https://platform.claude.com/docs/en/about-claude/pricing | VERIFIED |
| Claude Sonnet 5.5 | $2 input / $10 output; cache hit $0.20 | o‘sha | VERIFIED |
| Claude tokenizer | 4.7 va keyingi modellarda bir xil matn ~30% ko‘proq token beradi | o‘sha | VERIFIED |
| Anthropic API ma’lumotlari bilan o‘qitish | «Anthropic may not train models on Customer Content from Services» (Commercial Terms, 2025-06-17 dan) | https://www.anthropic.com/legal/commercial-terms | VERIFIED |
| Anthropic API O‘zbekistonda | Supported countries ro‘yxatida bor | https://www.anthropic.com/supported-countries | VERIFIED |
| Voyage voyage-4 (multilingual embedding) | $0.06/1M token, 200M token bepul | https://docs.voyageai.com/docs/pricing | VERIFIED |
| Voyage voyage-4-lite | $0.02/1M token, 200M bepul | o‘sha | VERIFIED |
| Apple Developer Program | $99/yil | https://developer.apple.com/programs/whats-included/ | VERIFIED |
| App Store komissiyasi | 30% standart; Small Business Program va obunaning 2-yilidan 15% | https://developer.apple.com/app-store/small-business-program/ | VERIFIED |
| Google Play ro‘yxatdan o‘tish | $25, bir marta | https://support.google.com/googleplay/android-developer/answer/6112435 | VERIFIED |
| Google Play xizmat haqi | Obunalar 15%; boshqa xaridlar yiliga birinchi $1M uchun 15% (O‘zbekiston ham shu guruhda). AQSh/UK/EEA/Avstraliya/Yaponiyada 2026 dan yangi tuzilma | https://support.google.com/googleplay/android-developer/answer/112622 | VERIFIED (yangi bozorlar — PARTIALLY) |
| Cloudflare R2 | $0.015/GB-oy; **egress bepul**; oyiga 10 GB storage bepul | https://developers.cloudflare.com/r2/pricing/ | VERIFIED |
| Sentry | Developer bepul (1 foydalanuvchi, 5K xato/oy); Team $26/oy (yillik to‘lov bilan) | https://sentry.io/pricing/ | VERIFIED / PARTIALLY |
| Firebase Crashlytics | Bepul | https://firebase.google.com/pricing | VERIFIED |
| Resend (email) | Bepul 3 000 email/oy; Pro $20/oy | https://resend.com/pricing | VERIFIED |
| .com domen | ~$10–11/yil (Cloudflare Registrar ustama qo‘shmaydi) | https://www.cloudflare.com/products/registrar/ | ESTIMATE (aniq narx rasmiy sahifada yo‘q) |

### 1.1. Soliq va to‘lovlar bo‘yicha muhim topilmalar

| Topilma | Manba | Status | Ta’siri |
|---|---|---|---|
| Google Play: **O‘zbekistonda joylashgan dasturchi** O‘zbekistondagi xaridorlarga sotuvlardan O‘zbekiston QQS’ni **o‘zi** hisoblab, undirib, to‘lashi shart | https://support.google.com/googleplay/android-developer/answer/138000 | VERIFIED | Buxgalteriya xarajati va majburiyat; yurist/buxgalter bilan hal qilinadi (legal checklist L-16) |
| Google Play O‘zbekistonda dasturchi va merchant ro‘yxatdan o‘tishini qo‘llab-quvvatlaydi (to‘lov USD’da) | https://support.google.com/googleplay/android-developer/answer/150324 | VERIFIED | Ijobiy |
| Google Play’da O‘zbekiston foydalanuvchilari pullik ilova/xarid qila oladi | https://support.google.com/googleplay/answer/143779 | VERIFIED | Ijobiy |
| App Store’da O‘zbekiston storefront’i bor | https://developer.apple.com/help/app-store-connect/reference/app-store-pricing-and-availability-start-times-by-region/ | VERIFIED | Ijobiy |
| Apple O‘zbekiston QQS’ni o‘zi undiradimi | Apple 2020-04-14 xabari: O‘zbekistondagi narxlar yangi QQS sababli o‘zgardi, daromad soliqsiz narxdan hisoblanadi | PARTIALLY | Bilvosita «ha». Aniq ro‘yxat — App Store Connect’dagi Paid Applications Agreement, Exhibit B |
| Apple to‘lovlarini O‘zbekiston bankiga olish | Rasmiy tasdiq topilmadi | NOT VERIFIED | **Risk.** App Store Connect’da bank tanlash orqali amalda tekshirish kerak; zaxira varianti — boshqa yurisdiksiyadagi yuridik shaxs (yurist bilan) |

---

## 2. Modellash farazlari

| Faraz | Qiymat | Turi | Izoh |
|---|---|---|---|
| Faol foydalanuvchilar (MAU) | 0 / 1 000 / 10 000 / 100 000 | Ssenariy | |
| Tarif taqsimoti | Free 95%, Student Pro 2.5%, Professional Pro 2.5% | ESTIMATE | Professional nisha ilovalari uchun ehtiyotkor faraz; real konversiya beta’da o‘lchanadi |
| Akkaunt ochgan foydalanuvchilar | MAU’ning ~40% | ESTIMATE | Akkaunt majburiy emas → Supabase Auth MAU kamroq |
| Student Pro narxi (faqat modellash uchun) | $4.99/oy | HYPOTHETICAL | |
| Professional Pro narxi (faqat modellash uchun) | $14.99/oy | HYPOTHETICAL | |
| AI so‘rovi tuzilmasi | Tizim ko‘rsatmasi 2 000 token (keshlangan), kontekst 4 000, savol 500, javob 700 | ESTIMATE | RAG uchun odatiy |
| Validator o‘tishi (Haiku) | 2 500 input, 150 output | ESTIMATE | Citation va xavfsizlik tekshiruvi |
| Bitta AI so‘rov narxi — Haiku 4.5 | **≈ $0.0106** (validator bilan) | Hisob | Skript: pastda |
| Bitta AI so‘rov narxi — Sonnet 5.5 | **≈ $0.0237** (+30% tokenizer, validator bilan) | Hisob | |
| AI’dan foydalanuvchilar ulushi / oylik so‘rovlar | Free 30% × 8; Student 70% × 40; Pro 70% × 80 | ESTIMATE | |

---

## 3. Oylik xarajat ssenariylari (USD, taxminiy)

| Modda | 0 MAU (ishga tushirishdan oldin) | 1 000 MAU | 10 000 MAU | 100 000 MAU |
|---|---|---|---|---|
| Supabase | $0 (Free, development) | $25 (Pro) | $40 (Pro + Small compute) | $85–135 (Pro + Medium compute; Auth MAU ~40K — 100K ichida) |
| Kontent CDN (R2) | $0 | $0 | ~$0–1 | ~$1–5 (egress bepul; asosiy pack ilova bilan birga keladi) |
| AI — LLM (Haiku/Sonnet) | $0 | ~$65 | ~$650 | ~$6 500 |
| AI — embedding | ~$0 (korpus bir marta: bir necha mln token, 200M bepul ichida) | ~$0 | ~$1 | ~$5 |
| RevenueCat | $0 | $0 (MTR ≈ $500) | ~$50 (MTR ≈ $5 000) | ~$500 (MTR ≈ $50 000) |
| Store komissiyasi (15%) — xarajat emas, daromaddan ushlanadi | — | ~$75 | ~$750 | ~$7 500 |
| Monitoring (Sentry/Crashlytics) | $0 | $0 | $0–26 | $26–80 |
| Email | $0 | $0 | $0 | $0–20 |
| Apple ($99/yil) + domen (~$11/yil) | ~$9 | ~$9 | ~$9 | ~$9 |
| **Jami infratuzilma (komissiyasiz)** | **~$9** | **~$100** | **~$750–780** | **~$7 100–7 300** |
| Taxminiy yalpi daromad (HYPOTHETICAL narxlar bilan) | $0 | ~$500 | ~$5 000 | ~$50 000 |
| **AI ulushi yalpi daromadda** | — | ~13% | ~13% | ~13% |

**Xulosa:** infratuzilma arzon; **AI eng katta o‘zgaruvchan xarajat**. Free foydalanuvchilarning AI xarajati (100K MAU’da ~$2 400/oy) eng xavfli qism — shuning uchun 4-bo‘limdagi limitlar majburiy.

Bir martalik xarajatlar: Google Play $25.

---

## 4. AI cost control arxitekturasi

### 4.1. Tamoyillar

1. **AI bo‘lmasa ham ilova to‘liq ishlaydi.** Qidiruv, kutubxona, kalkulyatorlar, ta’lim — AI’ga bog‘liq emas. AI o‘chirilsa (kill-switch) faqat AI tab «vaqtincha mavjud emas» deydi.
2. **Har bir so‘rov narxi oldindan cheklangan:** `max_tokens`, kontekst hajmi limiti, tarix uzunligi limiti.
3. **Limitlar serverda**, kodda emas: `ai_quota_config` jadvali (tarif, model, kunlik/oylik limit, max kontekst). O‘zgartirish app update talab qilmaydi.

### 4.2. Tarif bo‘yicha taklif (boshlang‘ich qiymatlar, beta’dan keyin sozlanadi)

| | FREE | STUDENT PRO | PROFESSIONAL PRO |
|---|---|---|---|
| Model | Haiku 4.5 | Haiku 4.5 | Sonnet 5.5 (murakkab savollar) + Haiku (oddiy savollar, router orqali) |
| Limit | 3 so‘rov/kun, 30/oy | 300/oy | 1 000/oy (fair use) |
| Javob uzunligi (max_tokens) | 500 | 900 | 1 500 |
| Suhbat tarixi | 2 xabar | 6 xabar | 10 xabar |
| Bitta foydalanuvchining maksimal oylik xarajati | ~$0.32 | ~$3.2 | ~$15–24 |
| Maksimal xarajat / HYPOTHETICAL narx | — | ~64% (faqat limitni to‘liq ishlatganda) | ~100–160% (faqat limitni to‘liq ishlatganda) |

Ko‘pchilik foydalanuvchi limitga yetmaydi, lekin oxirgi qator shuni ko‘rsatadi: **Professional Pro uchun 1 000 so‘rov/oy juda yuqori**. Ikki yechim bor: (a) Professional Pro limiti 400–500/oy, keyin Haiku’ga avtomatik o‘tish; (b) haqiqiy narxlar aniqlangach, limitni narxga bog‘lab qayta hisoblash. Tavsiya — (a).

### 4.3. Texnik mexanizmlar

| Mexanizm | Tavsif | Kutiladigan tejash |
|---|---|---|
| **Prompt caching** | Tizim ko‘rsatmasi va qoidalar keshlanadi (cache hit — input narxining 10%) | Input xarajatining 20–30% |
| **Javob keshi** | Bir xil normallashtirilgan savol + bir xil content versiyasi → saqlangan javob (PII’siz savollar uchun, faqat umumiy bilim savollari) | Ko‘p takrorlanadigan savollarda katta |
| **Lokal birinchi javob** | Savol aniq modda/kalkulyatorga ishora qilsa, avval lokal kartochka ko‘rsatiladi va «AI’dan so‘rash» ixtiyoriy | AI so‘rovlari soni kamayadi |
| **Model router** | Oddiy (ta’rif, terminologiya) → Haiku; murakkab (talqin, differensial) → Sonnet | Pro xarajatining 30–50% |
| **Retrieval cheklovi** | Top-k chunk va har bir chunk hajmi cheklangan | Input token barqaror |
| **Global byudjet himoyasi** | Kunlik umumiy xarajat chegarasi; 80% da ogohlantirish, 100% da Free AI vaqtincha o‘chadi, pullik foydalanuvchilar ishlashda davom etadi | Kutilmagan hisobdan himoya |
| **Suiiste’moldan himoya** | Akkauntsiz foydalanuvchiga AI yo‘q (Free uchun ham akkaunt kerak); qurilma attestatsiyasi (App Attest / Play Integrity); IP/akkaunt rate limit | Bot trafikidan himoya |
| **Kuzatish** | Har bir so‘rov: tarif, model, token, narx (PII’siz) → kunlik dashboard | |

---

## 5. Ilmiy kontent va litsenziya xarajatlari

| Modda | Baho | Status |
|---|---|---|
| Reviewerlar mehnati (tox, fm, lab, tarjima) | **Loyihaning eng katta real xarajati bo‘lishi ehtimoli bor.** Stavkalar mahalliy bozorga bog‘liq — egasi bilan aniqlanadi | ESTIMATE kerak |
| Ochiq manbalar (PubChem, PubMed, NIST WebBook, UNODC, EUDA, SWGDRUG, ASB) | $0 (litsenziya shartlari — `03_SOURCE_MATRIX.md`) | VERIFIED (har biri alohida) |
| «LICENSE REQUIRED» manbalar (Baselt, Clarke’s va h.k.) | Noshirdan taklif olinmaguncha noma’lum | NOT VERIFIED |
| Yuridik review (release’dan oldin) | Mahalliy yurist taklifi kerak | ESTIMATE kerak |
| Trademark ro‘yxatdan o‘tkazish | Davlat bojlari + yurist; yurisdiksiyalar soniga bog‘liq | ESTIMATE kerak |

---

## 6. Hisob skripti

AI ssenariylari quyidagi formula bilan hisoblangan (Python, skretch):

```
so‘rov_narxi = (kesh_token × cache_narx + (kontekst + savol) × input_narx) × tokenizer_koeff
             + javob_token × output_narx × tokenizer_koeff
             + validator_narxi
oylik_AI = MAU × tarif_ulushi × AI_foydalanuvchi_ulushi × oylik_so‘rovlar × so‘rov_narxi
```

Natijalar: Haiku ≈ $0.0106/so‘rov, Sonnet 5.5 ≈ $0.0237/so‘rov; 1K / 10K / 100K MAU uchun ≈ $65 / $646 / $6 458 oyiga.
