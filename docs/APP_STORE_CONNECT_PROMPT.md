# App Store Connect — yordamchiga beriladigan topshiriq (2026-10-11)

Quyidagi matnni **to‘liq nusxalab** yordamchiga bering. Hamma maydon tayyor —
u faqat kiritadi. Skrinshotlar va «Submit for Review» haqida alohida band bor.

---

## YORDAMCHIGA TOPSHIRIQ (nusxalang)

Variant 1 ni tanlayman: matnli qismlarni sen kirit. Lekin quyidagi matnlarni
o‘zing yozma — men tayyorini beryapman, aynan shuni qo‘y.

### 0. Avval bitta muhim narsa

**«Submit for Review» tugmasini BOSMA.** Hozir faqat App Store Connect
sahifasini to‘ldiramiz va saqlaymiz (Save). Ommaviy nashrga yuborishga
ruxsat alohida beriladi. Hozirgi maqsad — TestFlight orqali ichki sinov.

**Build:** 148-build eskirgan. Hozir yangi build yig‘ilmoqda — **0.3.0**,
build raqami **166** (148 emas).
TestFlight’da ikkita build ko‘rinsa, **eng kattasini** oling: unda bugungi
to‘rtta tuzatish bor (klaviatura, kichik ekranlar, Savol-javob qoidalari,
admin paneldan Pro berish).

### 1. App Information

- **Name:** `FORENSIC EXPERT`
- **Subtitle:** `Sourced forensic reference`
- **Primary category:** Medical
- **Secondary category:** Reference
- **Content Rights:** ilovada uchinchi shaxsning kontenti ko‘rsatiladi
  (ilmiy maqola va qo‘llanmalarning bibliografik ma’lumotlari, iqtiboslar).
  «Contains, shows, or accesses third-party content» — **Yes**.
- **Age Rating** anketasini **rostini belgilang**, taxmin qilmang:
  - *Medical/Treatment Information* → **Frequent/Intense**
    (bu professional sud-tibbiyot/sud-kimyo ma’lumotnomasi);
  - *Drug, Alcohol, or Tobacco Use or References* → **Infrequent/Mild**
    (moddalar faqat laboratoriya identifikatsiyasi nuqtai nazaridan);
  - qolganlari — **None**.
  Natija 17+ chiqsa, shunday qoldiring.

### 2. Pricing and Availability

- **Price:** Free (ilova ichida obuna bor, lekin ilovaning o‘zi bepul).
- **Availability:** barcha mamlakatlar (yoki egasi aytgan ro‘yxat).

### 3. App Privacy

- **Privacy Policy URL:**
  `https://davlatsudekspert.github.io/forensic-expert-legal/`
- Yig‘iladigan ma’lumot (Play Console’dagi bilan bir xil bo‘lsin):
  - **Contact Info → Email Address** — Akkaunt (App Functionality), bog‘langan;
  - **Identifiers → User ID** — App Functionality, bog‘langan;
  - **Usage Data → Product Interaction** — App Functionality, bog‘langan;
  - **User Content → Other User Content** — faqat Savol-javob yoqilgan
    sinov build’ida (savol/javob matni ommaviy ko‘rinadi);
  - **YIG‘ILMAYDI:** joylashuv, kontaktlar, reklama identifikatori,
    sog‘liq ma’lumoti, moliyaviy ma’lumot, fotosuratlar va fayllar.
  - **Tracking:** Yo‘q. **Ads:** Yo‘q.
- Tekshiruv hujjati (mutaxassislik diplomi) **saqlanmaydi** — u faqat
  tekshiruv vaqtida server xotirasida bo‘ladi, shuning uchun «Photos» va
  «Files and Docs» belgilanmaydi.

### 4. Version Information (English)

**Promotional Text (170 belgi):**
```
Every statement carries its source and the exact page. Substances, methods, reagents, calculators and court-preparation cards — in Uzbek, Russian and English.
```

**Keywords (100 belgi ichida, probelsiz):**
```
forensic,toxicology,chemistry,expert,reference,TLC,GC-MS,reagents,autopsy,PMI,calculator
```

**Description:** `docs/play_store/listing.md` faylidagi **ENGLISH → Full
description** bo‘limini aynan oling (o‘zgartirmang — unda «ilova ekspert
xulosasi o‘rnini bosmaydi» degan halollik bandi bor, u turishi shart).

**Support URL:** `https://davlatsudekspert.github.io/forensic-expert-legal/`
**Marketing URL:** bo‘sh qoldiring.
**Copyright:** `2026 Abduraxmonov Y.T.`

**What's New in This Version:**
```
First TestFlight build of 0.3.0. Keyboard now dismisses on every screen, all
screens checked at small size and large text, community Q&A rules added, and
Pro access can be granted from the admin panel.
```

### 5. App Review Information — ENG MUHIM QISMI

- **Sign-in required: NO.** Ilovaning asosiy qismi — moddalar kutubxonasi,
  usullar, reaktivlar, qo‘llanmalar, kalkulyatorlar, qidiruv, test rejimi —
  **hisobsiz, login talab qilmasdan** ochiladi. Birinchi ishga tushirishda
  faqat til tanlash → ogohlantirishni qabul qilish → rejim tanlash bo‘ladi.
  Shuning uchun **demo login/parol bermaymiz va kerak emas**.
  «Sign-in required» katagini **belgilamang**.
  (Agar maydonni bo‘sh qoldirishga ruxsat bermasa — bu katak belgilanmagan
  bo‘lsa maydonning o‘zi chiqmaydi; chiqsa, demak katak belgilangan.)
- **Notes** maydoniga aynan shuni yozing:

```
No account is required. All main sections — substance library, detection
methods, reagents, guideline cards, calculators, search and study mode —
open without signing in. First launch asks only for a language, acceptance
of the disclaimer, and a usage mode.

Signing in is optional and uses a one-time code sent by e-mail. It is only
needed for the profile, the referral screen, support messages and the
community Q&A section. Because the code is sent to the user's own mailbox,
we cannot supply a demo account; nothing in the review path requires one.

What the app is: a professional reference and study tool for forensic
chemistry, forensic medicine and forensic toxicology practitioners. It is
not a medical device and gives no diagnosis or treatment advice. A
disclaimer on first launch states that the app does not replace an expert
opinion. Every statement shows its source and the exact page, and its
verification status.

Controlled substances appear only as analytical identification data for
laboratory work — spectra, colour tests, chromatographic behaviour,
metabolites and reported concentrations. The app contains no instructions
for obtaining, producing or using any substance, and the community section
explicitly forbids such requests.

The AI assistant answers only from the app's own sources, lists them, and
labels its text as AI-generated.

No ads, no tracking, no location, no contacts. Account deletion is
available inside the app (Profile → Account).
```

- **Contact Information:** egasining ismi, telefoni va
  `davlatsudekspert@gmail.com`.
- **Attachment:** kerak emas.

### 6. Skrinshotlar

Men bera oladigan skrinshotlar hozir **1170×2532** (6.1" iPhone) o‘lchamida.
App Store Connect iPhone uchun **6.9"** o‘lchamini (1290×2796 yoki
1320×2868) talab qiladi. Shuning uchun:

- 1170×2532 fayllarni **cho‘zib yuklamang** — sifat buziladi va Apple
  rad etishi mumkin.
- To‘g‘ri o‘lchamdagi skrinshotlar tayyorlanmoqda; tayyor bo‘lgach beriladi.
- Shu paytgacha App Store sahifasining qolgan hamma qismini to‘ldirib,
  **Save** bosing. Skrinshotsiz ham saqlanadi — faqat yuborib bo‘lmaydi,
  va biz hozir yubormayapmiz ham.

### 7. Yakunida

Nima kiritganingizni va qaysi maydon qabul qilinmaganini (xato matni bilan)
yozib bering. **«Submit for Review» bosilmaganiga ishonch hosil qiling.**
