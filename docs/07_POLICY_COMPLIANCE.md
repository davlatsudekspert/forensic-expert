# 07 — CAS, Google Play va Apple talablari: aynan amaldagi rasmiy matnlar

| | |
|---|---|
| Sana | 2026-10-04 (barcha sahifalar shu kuni ochilgan) |
| Usul | Rasmiy sahifalar `curl` orqali yuklanib, matn qatorma-qator tekshirildi. Iqtiboslar so‘zma-so‘z (inglizcha) |
| Muhim | Bu yuridik xulosa emas. Yakuniy talqin — yurist (legal checklist L-08, L-10) |

Har bir band uch qismga ajratilgan:

- **TALAB (MUST)** — rasmiy matnda «must / required / don’t allow».
- **TAVSIYA (SHOULD)** — «should / may» yoki misol tariqasida berilgan.
- **BIZNING QARORIMIZ** — xavfni kamaytirish uchun o‘zimiz qabul qilgan qaror (rasmiy talab emas).

---

## 1. CAS Registry Number® — qayta tekshiruv

### 1.1. Rasmiy matnlar

| # | Manba | Sana | So‘zma-so‘z iqtibos | Status |
|---|---|---|---|---|
| CAS-1 | CAS RN Verified Partner Program — https://www.cas.org/training/documentation/chemical-substances/cas-rn-verified-partner-program | Ko‘rsatilmagan | "A CAS Registry Number license is required anytime an organization will “publish” CAS Registry Numbers to the public or use them to support features of a platform that is publicly or commercially available (i.e., as a “search by CAS RN” feature), even if the CAS Registry Number is not displayed as part of the answer." | VERIFIED |
| CAS-2 | CAS REGISTRY FAQ — https://www.cas.org/cas-data/cas-registry | Ko‘rsatilmagan | "A CAS Registry Number license is required anytime an organization will “publish” CAS Registry Numbers to the public or use them to support features of a platform that is publicly or commercially available." / "CAS is the source and final authority for CAS Registry Numbers." | VERIFIED |
| CAS-3 | CAS Common Chemistry — https://commonchemistry.cas.org/ | Ko‘rsatilmagan | "CAS Common Chemistry is provided under the Creative Commons CC BY-NC 4.0 license." | VERIFIED |
| CAS-4 | Common Chemistry Commercial License (API), «Version 07/12/2024» — cas.org/legal sahifasidan havola | 2024-07-12 | §2: "…solely for private, internal purposes related to Licensee’s business." §8b: taqiq — "…distribute, publish, transfer, or otherwise make available to a third party the API or CAS Content;" §8k: AI/machine learning maqsadlari taqiqlangan | VERIFIED |
| CAS-5 | CAS Information Use Policy, «Updated: July 12, 2024» | 2024-07-12 | "Via the Internet. Except as expressly set forth in this Policy, publishing, sharing or redistributing Information via the Internet is prohibited." (CAS mahsulotlari orqali olingan ma’lumot uchun) | VERIFIED |
| CAS-6 | «N tagacha CAS RN bepul» kabi kichik hajm istisnosi | — | Joriy rasmiy hujjatlarda **topilmadi** (2021 va 2024 Information Use Policy, Verified Partner sahifasi). Ba’zi qidiruv natijalarida eski matnga ishora bor, lekin rasmiy manbada tasdiqlanmadi | NOT FOUND |
| CAS-7 | CAS RN uchinchi tomondan (PubChem, NIST, UNODC/INCB, davlat ro‘yxatlari) olinsa | — | CAS’ning bu holatga oid aniq bayonoti **topilmadi**. CAS-1 dagi talab raqamning qayerdan olinganiga bog‘lanmagan | NOT FOUND |
| CAS-8 | «Ichki kuzatuv tizimi uchun litsenziya kerak emas» degan jumla | — | Faqat qidiruv parchalarida uchradi, joriy rasmiy sahifada **yo‘q** | NOT VERIFIED |

### 1.2. Xulosa — hozircha MUTLAQ FAKT SIFATIDA QOTIRILMAYDI

| Savol | Rasmiy matn nima deydi | Aniqlik |
|---|---|---|
| (a) Ilovada CAS RN ko‘rsatish | Litsenziya talab qilinadi (CAS-1, CAS-2) | Aniq |
| (b) CAS RN bo‘yicha qidiruv | Litsenziya talab qilinadi — raqam ko‘rsatilmasa ham (CAS-1) | Aniq |
| (c) Faqat ichki saqlash, foydalanuvchiga hech qanday funksiya bermasdan | Aniq javob yo‘q | **Noaniq** |
| (d) Davlat/BMT ro‘yxatlaridan olingan raqamlar | Aniq javob yo‘q | **Noaniq** |
| (e) ~100 ta modda uchun kichik hajm yoki bepul daraja | Topilmadi | **Noaniq** |

### 1.3. CAS’ga yuboriladigan savollar (help@cas.org, CAS Customer Center)

> We are building a paid mobile reference app covering about 100 substances.
> (1) Do we need a CAS RN Verified Partner license to display these CAS RNs, to offer search by CAS RN, or only to store them internally with no user-facing function?
> (2) Does it change anything if every RN is taken from public government or UN lists (UNODC, INCB, national schedules) or NIST, rather than from CAS products?
> (3) Is there a small-quantity or no-fee tier, and what is the fee?
> (4) What trademark notice and attribution are required?

### 1.4. Arxitekturadagi qaror (PHASE 1 da amalga oshirilgan)

- Sxemada **CAS uchun alohida ustun yo‘q**. CAS — `external_identifiers` jadvalidagi sxemalardan biri (`cas_rn`).
- `IdentifierPolicy` — **konfiguratsiya**, qotirilgan qoida emas. Default: CAS saqlanmaydi, ko‘rsatilmaydi va qidiruvga qo‘shilmaydi. CAS javobidan keyin kod o‘zgarmaydi — faqat siyosat (kontent paketi yoki remote config).
- Qidiruv klassifikatori CAS **shaklini** taniydi, lekin bunday qidiruvni bajarish-bajarmaslikni siyosat hal qiladi.
- Testlar: `IdentifierPolicy conservative default disables CAS entirely`, `policy is configuration — CAS can be enabled without code change`.
- Agar litsenziya olinsa, CAS’ning talabiga ko‘ra atama **«CAS Registry Number®» / «CAS RN®»** bo‘ladi («CAS No.» yoki «CASRN» emas).

---

## 2. Google Play

Sahifalarda «Last updated» sanasi HTML’da ko‘rsatilmagan (JavaScript bilan to‘ldiriladi) — shu sababli kirish sanasi asos qilib olindi.

### 2.1. Health Content and Services — https://support.google.com/googleplay/android-developer/answer/16679511

| Mavzu | So‘zma-so‘z iqtibos | Turi | Bizning qarorimiz |
|---|---|---|---|
| Disclaimer | "Other health and medical apps must include a clear disclaimer in their app description indicating that the app is “not a medical device and does not diagnose, treat, cure, or prevent any medical condition.”" | **TALAB.** Joyi — **store’dagi ilova tavsifi (app description)**. Ilova ichida bo‘lishi talab qilinmagan | Tavsifga aynan shu matn qo‘shiladi (release checklist). Bundan tashqari, **o‘z qarorimiz** bilan ilova ichida ham ilmiy disclaimer bor (onboarding + Profil) |
| Mutaxassisga murojaat | "Apps must also remind users to consult a healthcare professional for medical advice, diagnosis, or treatment." | **TALAB.** Joyi ko‘rsatilmagan | Onboarding’dagi disclaimer ekranida (`disclaimerConsult` matni, EN/RU/UZ) va store tavsifida |
| Privacy policy | "Your app must post a privacy policy link in the designated field within Play Console, and a privacy policy link or text within the app itself." | **TALAB** | Release gate: Privacy Policy (EN/RU/UZ) — Profil → Legal |
| Deklaratsiya | "All developers must complete the Health apps declaration form on the App content page…" | **TALAB** | Release gate |
| Zararli funksiyalar | "We don’t allow apps with health and medical related functionalities that are misleading or potentially harmful." | **TALAB (taqiq)** | Provenance, review, kalkulyatorlarda cheklovlar |
| Noto‘g‘ri sog‘liq da’volari | "We don’t allow apps containing misleading health claims that contradict existing medical consensus, or can cause harm to users." | **TALAB (taqiq)** | Faqat review’dan o‘tgan kontent; AI xulosa bermaydi |
| Tasdiqlanmagan moddalar | "Google Play doesn't allow apps that promote or sell unapproved substances, irrespective of any claims of legality." | **TALAB (taqiq)** | Kontent faqat reference/ta’lim; sotib olish, tayyorlash va dozalash yo‘riqlari **yo‘q** (o‘z qarorimiz) |

### 2.2. Health apps declaration — https://support.google.com/googleplay/android-developer/answer/14738291

| Iqtibos | Turi | Qaror |
|---|---|---|
| "All developers that have an app published on Google Play must complete the Health apps declaration, including apps on closed testing, open testing, or production tracks." | **TALAB** (yopiq test bosqichidan boshlab) | PHASE 13 dan oldin |
| Kategoriya: "Medical Reference and Education — Educational resources for healthcare professionals and patients, including medical encyclopedias, treatment guidelines and symptom checkers." | Kategoriyani tanlash — **dasturchi qarori** (siyosat bu kategoriyani majburlamaydi) | Taklif: «Medical Reference and Education». Diqqat: «Clinical Decision Support» ta’rifida «drug dosage calculators, risk assessment tools» bor — **bizning kalkulyatorlarimiz dozalash emas**, lekin yurist bilan aniqlashtiriladi |

### 2.3. AI-Generated Content — https://support.google.com/googleplay/android-developer/answer/13985936

| Iqtibos | Turi | Qaror |
|---|---|---|
| "Apps that generate content using AI must contain in-app user reporting or flagging features that allow users to report or flag offensive content to developers without needing to exit the app." | **TALAB** | Forensic AI ulanganda (PHASE 8) har bir javobda «Shikoyat qilish» tugmasi |
| "Developers should utilize user reports to inform content filtering and moderation in their apps." | **TAVSIYA** | Shikoyatlar AI eval to‘plamiga qo‘shiladi |
| AI kontentini belgilash yoki oshkor qilish | Bu sahifada **talab topilmadi** | **O‘z qarorimiz:** AI javoblari aniq belgilanadi va manbalar bilan ko‘rsatiladi |

### 2.4. Boshqa talablar

| Mavzu | Iqtibos | Turi |
|---|---|---|
| Data safety (…/answer/10787469) | "All developers that have an app published on Google Play must complete the Data safety form, including apps on closed, open, or production testing tracks." | **TALAB** |
| Account deletion (…/answer/13327111) | "If your app enables account creation, you must: provide users with an in-app path to delete their app accounts and associated data; and provide a web link resource where users can request app account deletion and associated data deletion." | **TALAB** (akkaunt bo‘lsa) |
| Zo‘ravonlik (…/answer/9878810) | "We don't allow apps that depict or facilitate gratuitous violence or other dangerous activities." Misol: "Graphic depictions or descriptions of realistic violence…" | Taqiq — **TALAB**; misol — **MISOL** |
| EDSA istisnosi (zo‘ravonlik uchun) | Violence bo‘limida **yo‘q**. EDSA faqat boshqa bo‘limlarda: nudity, violent extremism, sensitive events (o‘lim, dozadan oshirish va h.k. — EDSA qiymati bo‘lsa «generally allowed») | **O‘z qarorimiz:** V1 da autopsiya va jarohat fotosuratlari yo‘q; faqat sxematik chizmalar |

---

## 3. Apple App Review Guidelines — https://developer.apple.com/app-store/review/guidelines/ («Last Updated: June 8, 2026»)

| Band | So‘zma-so‘z iqtibos | Turi | Bizning qarorimiz |
|---|---|---|---|
| 1.1 / 1.1.2 | "Apps should not include content that is offensive, insensitive, upsetting, intended to disgust…" / "Realistic portrayals of people or animals being killed, maimed, tortured, or abused…" | «should», lekin amalda rad etish sababi; ta’lim/tibbiyot istisnosi **ko‘rsatilmagan** | V1 da grafik tasvirlar yo‘q |
| 1.4.1 | "Medical apps that could provide inaccurate data or information… may be reviewed with greater scrutiny." | Ko‘rib chiqish tartibi («may») | — |
| 1.4.1 | "Apps must clearly disclose data and methodology to support accuracy claims relating to health measurements, and if the level of accuracy or methodology cannot be validated, we will reject your app." | **TALAB** | Har bir kalkulyatorda FORMULA, ASSUMPTIONS, LIMITATIONS, REFERENCES (`CalculatorDescriptor`) |
| 1.4.1 | "Apps should remind users to check with a doctor in addition to using the app and before making medical decisions." | **TAVSIYA** | Bajariladi (disclaimer ekrani) |
| 3.1.1 | "If you want to unlock features or functionality within your app… you must use in-app purchase." | **TALAB** | `EntitlementService` faqat store billing orqali |
| 3.1.1 | "…you should make sure you have a restore mechanism for any restorable in-app purchases." | **TAVSIYA** (amalda kutiladi) | `EntitlementService.restore()` — majburiy interfeys metodi |
| 5.1.1(v) | "If your app doesn’t include significant account-based features, let people use it without a login. If your app supports account creation, you must also offer account deletion within the app." | Login’siz foydalanish — ko‘rsatma; o‘chirish — **TALAB** | Akkaunt ixtiyoriy; `AuthRepository.deleteAccount()` |

---

## 4. Ilovaga hozirdan kiritilgan elementlar (PHASE 1)

| Element | Asos | Qayerda |
|---|---|---|
| Ilmiy disclaimer (egasi tasdiqlagan EN matni + RU/UZ) | O‘z qarorimiz + Apple 1.4.1 | Onboarding → `DisclaimerScreen`, Profil → Legal |
| «Mutaxassisga murojaat qiling» eslatmasi | Google Play Health — TALAB | `disclaimerConsult` |
| «Ilova ekspert xulosasini bermaydi» | O‘z qarorimiz (17-bo‘lim) | `disclaimerNoConclusions` |
| Login’siz ishlash | Apple 5.1.1(v) | Onboarding’da login yo‘q |
| Restore / Manage subscription interfeysi | Apple 3.1.1 (tavsiya) | `EntitlementService` |
| Account deletion interfeysi | Apple 5.1.1(v), Google Play — TALAB | `AuthRepository.deleteAccount()` |
| AI PII ogohlantirishi | O‘z qarorimiz (18-bo‘lim) | AI tab |

**Release vaqtida qo‘shiladiganlar:** Play tavsifidagi aynan «not a medical device…» disclaimeri, Health apps deklaratsiyasi, Data safety, App Privacy, Privacy Policy havolasi (Play Console + ilova ichida) va AI shikoyat tugmasi.
