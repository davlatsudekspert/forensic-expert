# FORENSIC EXPERT — Global professional platform (egasining master topshirig‘i, 2026-10-08)

Holat: QABUL QILINDI, limit tiklangach (shanba) boshlanadi. Hali hech bir faza bajarilmagan.

## ⚠️ TUZATISH (2026-10-08) — oldingi ABY 2025 ko‘rsatmalaridan ustun
- "ABY 2025" (sud-tibbiy ekspertiza amaliyotlari yo‘riqnomasi) hali rasman tasdiqlanmagan/e’lon qilinmagan bo‘lishi mumkin: rasmiy, amaldagi yoki ommaviy metodika sifatida qabul qilinmaydi, "qo‘llanma" deb qayta nomlanmaydi.
- Fayl GitHub, Supabase, AI/RAG, kutubxona yoki boshqa tashqi xizmatga yuklanmaydi; matn, jadval, rasm, metodlari ko‘chirilmaydi, tarjima/e’lon qilinmaydi.
- Egasi, tasdiq maqomi va ruxsat aniqlanmaguncha ilmiy kontent importidan CHIQARILGAN.
- Rejaga: sud-tibbiyot, sud-kimyo, gistologiya, biologiya, kriminalistika bo‘yicha MUSTAQIL o‘quv materiallari — qonuniy darsliklar, ochiq adabiyot va rasmiy xalqaro manbalar asosida.
- Mamlakat huquqiy manbasi sifatida faqat tasdiqlangan va amaldagi normativ hujjatlar ko‘rsatiladi.
- Egasi hali hech qanday PDF/DJVU faylni Claude Code’ga bermagan — hech biri o‘qilgan/tekshirilgan/import qilingan deb hisoblanmaydi.
- Tasdiqlanmagan va cheklangan materiallar import qilinmaydi; production bazaga o‘zgartirish faqat alohida rozilik bilan.

## Qoidalar
- Mavjud repo davom ettiriladi; NFCSTORE/BugunBor/boshqa Supabase loyihalarga tegilmaydi.
- Muloqot — o‘zbek lotin; ilova kontenti EN/RU/UZ.
- Taxmin yo‘q: kod/serverda yo‘q narsa "tayyor" deyilmaydi. Statuslar: WORKING, IMPLEMENTED-UNVERIFIED, PARTIAL, MOCK/DEMO, MISSING, BLOCKED.
- Alohida feature branch; kichik bosqichlar, har biri commit + test + qisqa hisobot.
- Sirlar kodga/logga chiqmaydi. Pullik xizmat, billing, production deploy, App Store Review, Play production, ommaviy nashr, mavjud kontentni almashtirish — faqat egasining tasdig‘i bilan.
- Haqiqiy qurilmada sinalmaganini "real device tested" deb yozmaslik.

## Fazalar (birini tugatmay keyingisi "completed" emas)
- **A — Current-state audit (READ-ONLY):** branch/SHA, Android/iOS versiyalar, Flutter/deps, barcha ekranlar, SQLite/FTS5 + Ed25519 paketlar, Supabase migratsiyalar/RLS/Auth/Edge Functions, Email OTP, Gemini/RAG/citation/AI usage, referral/billing, CI/TestFlight/APK, EN/RU/UZ, HUMAN VERIFIED soni, testlar.
- **B — Gemini + qidiruv (1-ustuvorlik):** BlueStacks’da YuQX savoliga ~20 s dan keyin AI o‘rniga "OFLAYN BAZADAGI MOS MA’LUMOTLAR" va aloqasiz fanlar (entomologiya, antropologiya, odontologiya) chiqqan. Tekshirish: FE_AI_REMOTE build’da yoqilganmi, SupabaseAiProvider chaqiriladimi, ai-answer faolmi, GEMINI_API_KEY mavjudligi (qiymatsiz), model mavjudligi, 400/404/429/503 qaysi bosqichda, Free tier limitlari, xato yashirilyaptimi, RAG relevansi, CitationResolver. Sinonim/fan/til/yurisdiksiya/semantik moslik bilan qidiruv. NFCSTORE bilan umumiy Google API loyihasi quota xavfi — tavsiya, ruxsatsiz yaratmaslik.
- **C — Global Scientific Library:** barcha fanlar (tanatologiya, morfologiya/patologiya, gistologiya, biologiya/serologiya, genetika/DNK, kimyo/toksikologiya, tibbiy-kriminalistika, antropologiya, odontologiya, entomologiya, izshunoslik, ballistika, hujjatlar, raqamli va b.); har fan: overview, library, methods, instruments, reference materials, articles, learning, jurisdiction docs, tools, evidence status. Bibliografiya (ISBN/DOI/PMID), versiyalar, sahifali citation, copyright/license status, bookmark, import + OCR pipeline (DJVU/skan PDF, qo‘lda tekshiruv). Egasi yuklagan 18 hujjat ChatGPT’da (ABY 2025 — yuqoridagi tuzatishga ko‘ra chiqarilgan) — repoda yo‘q bo‘lsa `MISSING SOURCE FILES` reyestri. Mualliflik huquqi: katalog bepul, cheklangan kitob — faqat bibliografiya + qonuniy havola + mustaqil manbali kartalar.
- **D — Global science / National jurisdiction:** UZ, US, GB, DE, FR, RU, KZ, KG, TJ; hujjat metadata (raqam, sanalar, holat, versiya, til, URL, huquq, review). NIST/OSAC, ENFSI BPM, ISO/IEC 17025, ISO 21043, SWGDRUG, ANSI/ASB, ASTM, UNODC, WHO, ISFG — versiya/maqom tekshiruvi, matnni tarqatmaslik, tekshirilmagani NEEDS_REVIEW.
- **E — Expert Publications:** submission, muallif profili, metadata, huquq/rozilik, plagiat/PII tekshiruvi, moderatsiya, taqriz, versiyalash; statuslar DRAFT→SUBMITTED→SCREENING→IN_REVIEW→APPROVED/REJECTED→PUBLISHED, RETRACTED, SUPERSEDED. Avto HUMAN VERIFIED yo‘q; ommaviy nashr keyinroq.
- **F — FREE + PRO:** sinov narxlari PRO $4.99/oy, $39.99/yil (yakuniy emas; store mahsulotlari faqat tasdiq bilan). StoreKit/Play Billing, server verifikatsiya, restore, renewal/grace/refund/revoke, AI kvota, abuse protection; Lifetime $59.90 faollashtirilmaydi — eski billing audit + migratsiya rejasi. Manba va xavfsizlik ogohlantirishlari Free’da ham ko‘rinadi.
- **G — Premium UI/UX:** graphite/deep navy/noir + gold, ivory light, kuchli tipografika, ilmiy qidiruv markazda, Professional/Student mode, a11y, 320dp, safe area, uzun ruscha atamalar, dark/light. Avval audit, yaxshi komponentlar saqlanadi.
- **H — QA & release preparation:** Android/iOS, security, l10n, regression, performance.

## Birinchi javobda talab qilinadi
1) repo/branch holati; 2) ishlayotgan/ishlamayotgan jadvali; 3) Gemini muammosi dalillari va sabablari; 4) buzmasdan rivojlantirish taklifi; 5) library/publications/Free-Pro arxitektura diagrammasi va roadmap; 6) mustaqil qila oladiganlar vs egasi ruxsati kerak bo‘lganlar; 7) infratuzilma va AI xarajat modeli; 8) ustuvor 10 vazifa; 9) Phase A’dan keyin xavfsiz ishlarni alohida branchda boshlash; 10) muhim o‘zgarishlardan oldin tasdiq.
