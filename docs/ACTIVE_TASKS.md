# ACTIVE TASKS

Yangilangan: 2026-10-19. Format: [holat] vazifa — egasi/keyingi qadam.

## Shanba (limit tiklanganda) — «Har darsdan keyin 10 savollik test» (egasi, 2026-10-19)
Talab (egasi so‘zi bilan): Ustoz paneli → Darslar → har mavzu tagida shu mavzu
bo‘yicha **10 ta test**. Boshlanganda **QR** chiqadi (ustoz telefoni → monitor);
talabalar skanerlab qo‘shiladi — akkauntda ism bo‘lsa yozmaydi, bo‘lmasa yozadi.
Monitorda **ism bo‘yicha onlayn natija, o‘rinlari bilan**. **Har dars uchun alohida.**
Oxirida **xato yechilgan savollarni ustoz talabalar bilan muhokama qiladi.**

Mavjud (qayta qilinmaydi): dars oxiridan shu mavzu bo‘yicha test boshlash
(`showTopicTestChoice`), 6 xonali kod + QR, taxallus bilan qo‘shilish, jonli
reyting, katta ekran rejimi, qayta ulanish — «Sinfda test» (class quiz).

Qilinadigan ishlar:
1. **Savol banki — har dars uchun 10 ta** (eng katta ish, Sonnet agentlar):
   81 ta «Toksikologik kimyo» darsi (bank yo‘q) + qolgan ~84 mavzu (25/109 tayyor).
   Manba = o‘sha darsning kitobi va beti; 1 aniq javob, mantiqan bog‘liq
   chalg‘ituvchilar, tushuntirish; Opus ilmiy tekshiruvi; serverga seed.
2. **Ism avtomatik:** kirgan talabada profil ismi taxallus o‘rniga avtomatik
   (o‘zgartirish mumkin); kirmagan — hozirgidek yozadi. Filtr/nick tekshiruvi saqlanadi.
3. **Monitor:** natijalar ism bo‘yicha, o‘rin (1, 2, 3…), to‘g‘ri soni va vaqt;
   10 savol uchun default sozlama.
4. **«Xatolar tahlili» ekrani (yangi):** test tugagach ustozda/monitorda har savol
   bo‘yicha necha % xato qilgani, eng ko‘p xato qilingan savollar ro‘yxati;
   savolni ochib to‘g‘ri javob + tushuntirish + manba/bet → muhokama.
   Talaba ismlari bu ekranda ko‘rsatilmaydi (faqat foizlar) — maxfiylik.
5. Har dars uchun alohida sessiya/tarix: «Bu darsning oldingi testlari» ro‘yxati.
6. Sinov: STUDENT + TEACHER, 390/320 dp, proyektor 1920×1080, internet uzilishi;
   iloji bo‘lsa egasi bilan 2 telefonda real QR sinovi.

### Shanba rejasi — 2-qism: «Talaba/mutaxassis ilovadan chiqmasin» (egasi, 2026-10-19)
Tamoyil: odamni foyda ushlab turadi, hiyla emas (dark pattern, majburiy
bildirishnoma, yashirin to‘lov — YO‘Q; Apple 2.5.19/5.6). 10 savollik test
ishidan keyin, navbat bilan (ustuvorlik: 1 → 2 → 3):
1. **Kunning savoli / kunning holati** — har kuni 1 qisqa savol yoki keys, manba+bet bilan.
2. **Shaxsiy progress** — o‘tilgan mavzular, xato savollar, «xatolarimni takrorlash».
3. **Imtihon/attestatsiyaga tayyorlov** — fakultet/kurs bo‘yicha to‘plamlar, vaqtli sinov imtihoni.
4. **Mutaxassis ish quroli** — tezkor qidiruv, kalkulyator, cutoff/konsentratsiyalar, xulosa yordamchisi.
5. **Bildirishnomalar faqat rozilik bilan** — «Ustoz yangi test berdi», «Bugungi savol tayyor».
6. **Hamjamiyat** — savol-javob, ekspert tasdiqlagan javoblar.

## Egasidan ruxsat kutilmoqda
0. [egasi] **Giyasov Z.I. «Sud tibbiyoti» (Toshkent, 2018) — nusxasi kerak.**
   Muallif aniqlandi: **Giyasov Zaynitdin Isamutdinovich**, t.f.d., professor,
   Toshkent davlat tibbiyot universiteti, «Sud tibbiyoti va tibbiyot huquqi» 1-kafedrasi
   (2003–2012 yillarda kafedra mudiri). Ayrim iqtiboslarda inisiallari «Z.A.» deb
   yozilgan — bu kafedra sahifasidagi «Z.I.» bilan mos emas; kitob qo‘lga tushgach
   titul varag‘idan aniqlanadi.
   Topildi (2026-10-11, egasi ko‘rsatdi): **NIU Kutubxona** —
   `https://lib.niuuz.online/book/17769`, sarlavha «Sud tibbiyoti, Darslik. —
   G‘iyosov Z.A». Brauzerda o‘qish mumkin, lekin **faylni yuklab olish mehmon
   (guest) uchun yopiq (403)**; kirish kutubxona akkaunti bilan. Men kirish
   cheklovini aylanib o‘tmadim.
   Shuning uchun undan birorta yozuv yozilmadi (o‘qilmagan kitobdan yozish mumkin emas).
   Kerak: egasining kutubxona akkaunti bilan yuklangan PDF (yoki bosma nusxa). Kelgach — ABY bilan bir xil tartibda
   (o‘z so‘zimiz bilan, bet raqami bilan, muallifga hurmat sahifasida nomi bilan).
1. [egasi] **Ikkinchi admin akkaunt** — egasining o‘z professional maqomini
   tasdiqlash uchun. DB o‘zini-o‘zi tasdiqlashni taqiqlaydi. Kerak: ishonchli
   hamkasbning elektron pochtasi; rol server tomonida, audit bilan beriladi.
2. [egasi] **Giyasov «Sud tibbiyoti» (2018) PDF** — NIU kutubxonada bor
   (`lib.niuuz.online/book/17769`), yuklab olish mehmon uchun yopiq.
3. [egasi] **Play Console do‘kon sahifasi** — ilova nomi, tavsiflar (uz/ru/en),
   512×512 ikonka, 1024×500 banner, ≥2 skrinshot; usiz ilova paket nomi bilan
   ko‘rinadi. Matnlar tayyor: `docs/play_store/listing.md`.

## Bajarildi (2026-10-10)
- [bajarildi] Ilmiy ishonchlilik statuslari va Pro vositalari (fasetli/teskari
  qidiruv, «Modda bo‘yicha tahlil rejasi») — agent ishlari birlashtirildi.
- [bajarildi] **ABY 2025 mazmuni ilovada**: 32 da’vo, 19 bepul mavzu, manba
  `SRC-ABY-2025`, minnatdorchilik sahifasi (tashkilot, 9 tuzuvchi, 3 taqrizchi).
  Faqat o‘zbek tilida, so‘zma-so‘z iqtibossiz, bepul; hujjat fayli repoda yo‘q.
  Qamrov va qolgan bo‘limlar: `docs/ABY_COVERAGE.md`.

## Play Console (Internal testing)
- [bajarildi] 2026-10-10 22:5x — ABY mazmuni bilan yangi build: Play internal (draft,
  versionCode **5** (4 da ilova ichida «build 3» ko‘rinardi — tuzatildi)) va TestFlight (run 38091538066). versionCode 3
  Play'da band edi, shuning uchun 4 ga ko‘tarildi.
- [bajarildi] Imzolangan `.aab` — CI artefakti, `fe-upload` kaliti bilan imzolangan,
  SHA-256 `7419a168…1711c8`. Build: Actions run 38060031190.
- [bajarildi] Do'kon matnlari uch tilda — `docs/play_store/listing.md`.
- [bajarildi] Maxfiylik siyosati sahifasi — `docs/legal/privacy.html` (uz/ru/en).
- [egasi] Ochiq URL: `forensic-expert-legal` repo + GitHub Pages
  (prompt: `docs/PLAY_CONSOLE_PRIVACY_PROMPT.md`).
- [egasi] Testerlar ro'yxati, App access (test akkaunt), Data safety, Content rating.
- [backlog] `PLAY_SERVICE_ACCOUNT_JSON` secret → CI o'zi internal/draft yuklaydi.

## Admin panel / murojaatlar — yo'l xaritasi
1. [egasi] `delete-account` Edge Function deploy (skrinshotlarni ham o'chiradi).
2. [backlog] Hujjatni ilovadan ko'rish: qisqa muddatli imzolangan URL beradigan
   edge function (deploy → alohida tasdiq). Hozir faqat metama'lumot ko'rsatiladi.
3. [backlog] Tasdiqlovchi tengdosh (verified peer) uchun arizalar ro'yxati —
   soha → `reviewer_scope` xaritasi bilan birga belgilanishi kerak.
4. [backlog] MFA: ilovada TOTP enroll ekrani → `admin_requires_aal2 = true`.
5. [backlog] Bildirishnoma: egasiga Telegram/email «yangi murojaat»; push (FCM).
6. [backlog] Yopilgan murojaatlarni 24 oydan keyin tozalash (pg_cron).

## Ilmiy kontent — qolgan ish
- 565 ta da'vo faqat annotatsiya darajasida tekshirilgan (`ABSTRACT_ONLY`),
  17 tasida aniq joy yo'q (`NO_LOCATOR`) — inson eksperti ko'rishi kerak.
  Hisobot: `docs/qa/CLAIM_SOURCE_AUDIT.md`.
- 82 modda uchun mahalliy aniqlash usuli topilmadi —
  `docs/SUBSTANCE_METHODS_COVERAGE.md` 4-bo'lim.
- Biologiya kartalaridagi ~25 ta eski sovet usuli uchun manba topilmadi
  («manba tekshirilmoqda» deb belgilangan, to'qilmagan).
- Barcha yangi kartalar `NEEDS_REVIEW`; ilmiy taqriz hali o'tmagan.

## Savol-javob (Hamjamiyat) — bosqichlar
1. [bajarildi] QA-1 DB: 7 jadval (RLS yoniq, policy yo'q), 12 RPC, 8 private
   yordamchi, maxfiylik filtri, limitlar, shikoyat chegarasi. Productionda
   qo'llangan. SQL: `20261011000000_qa_community.sql`.
2. [bajarildi] QA-2 Edge Function: `qa-verify-expert` (hujjat faqat xotirada)
   va `qa-translate` (Cloudflare Workers AI + Gemini zaxirasi, kesh).
   `public.qa_service_*` wrapper'lari faqat `service_role`ga berilgan.
   Egasining qo'lda tekshirilgan belgisi seed qilindi. Batafsil:
   `docs/QA_COMMUNITY.md`.
3. [bajarildi] QA-3 Flutter: domen, port, Supabase adapter, providerlar,
   olti ekran, kutubxona hub'ida plitka, hujjat tanlagich (xotirada).
   Server ulanmagan bo'lsa bo'lim yashirin (`qaVisibleProvider`).
4. [bajarildi] QA-4 l10n uz/ru/en (`l10n_qa_community.py`), 16 widget test
   (uch tilda «fayl saqlanmaydi», 320 dp + 1.3x matn), maxfiylik siyosati
   7a bo'limi, Play Data safety yo'riqnomasi.
4a. [keyingi] Test tarqatish: `FE_QA=true` bilan Play internal / TestFlight
   build (ommaviy nashr YO'Q).
5. [egasi] Cloudflare `CF_ACCOUNT_ID` va `CF_API_TOKEN` (Workers AI).
6. [egasi] Q&A roli tasdiqlash: hozir `forensic_physician`.

### Manba holati — sud tibbiyoti/bioetika decklarini boyitish uchun (2026-10-24, agent hisoboti)
Drive’dan (`scratchpad/drive_src/pdf2/INVENTORY.md`): to‘liq — Pigolkin (2002), Pigolkin «Морф. диагностика», G‘iyosov «Huquqiy asoslar» (OCR shovqinli);
qisman — Muhamedova (DOCX, bet yo‘q), Kharin (19-bobgacha), Simpson (1–103 bet), Iskandarov (~147K belgi);
skaner (OCR kerak, katta fayl) — Romodanovskiy, G‘iyosov «Sud tibbiyoti» 2018, G‘iyosov «Bioetika» 2022;
topilmadi — Baizoldanov. **Egasidan:** Baizoldanov fayli; katta PDF’larni ≤5 MB bo‘laklab Drive’ga yoki to‘g‘ridan berish (G‘iyosov 2018 — eng muhimi, 68 deck shunga tayanadi).

## Holat 2026-10-24 (bajarildi)
- **Prezentatsiyalar v2:** 208/208 deck serverda 38–42 slayd, 8 xil diagramma; har deck 20 ta savol (prod: 208 uz mavzu, 4340 savol). slides-out: `b714ada` (toks), `ea1ed1e` (sud tibbiyoti/bioetika). Tekshiruv hisobotlari slides-out `verify/`.
- **Ilova 0.3.1 (19):** yangi diagramma turlari, dars → guruh testi (ism avtomatik, o‘rinlar, qiyin savollar muhokamasi), 10/15/20 chiplar, rasmli slayd (`image`, PNG/JPG, host whitelist). Release build #323 (TestFlight + Play internal) muvaffaqiyatli.
- **Prod funksiyalar:** `class_hardest_detail`, `group_assignment_hardest_detail` qo‘llandi. `lesson-images` bucket migratsiyasi HALI qo‘llanmagan (apparatlar kontenti tayyor bo‘lgach).
- **Apparatlar bilan ishlash (2026-10-24, kech):** 3 deck (`instr-01-kristallyuks-etanol`, `instr-02-uv1900-cohb`, `instr-03-gcms-asoslar`; 27–28 slayd, 10 mcq, ruxsatli rasmlar: CC Commons + o‘z sxemalar) prod’da — lesson_topics kursi «Apparatlar bilan ishlash» (3), class quiz 30 savol. `lesson-images` bucket prod’ga qo‘llandi (`private.has_role`), 14 rasm yuklandi. slides-out `42b9432`. Ilova asseti `class_quiz_bank.json` meta 211 mavzu / 11 guruh.
- **«Ustoz» rejimi + fan sahifasida darslar (egasi topshirig‘i, 2026-10-24):** onboarding/sozlamalarda 3-rejim «Ustoz» (`UserMode.teacher`); «Sud tibbiyoti» va «Sud toksikologiyasi» sahifasida «Darslar: prezentatsiya va guruh testi» bo‘limi (server ustoz roli bo‘lsa — darslar kurs bo‘yicha, har qatorda «Guruh testi» tugmasi; «Ustoz» rejimi, rol yo‘q — Ustoz paneliga havola). Fan sahifasidagi «Mavzular N» — ma’lumotnoma (content.db) mavzulari, darslar emas.
- **Qo‘llanma videolar (uz):** `howto_v2_1_ustoz_taqdimot.mp4`, `howto_v2_2_ustoz_guruh_testi.mp4`, `howto_v2_3_talaba_guruh_testi.mp4` (test muhiti, fake backend) — egasiga yuborildi.
- **Mutaxassisga «Apparatlar» (2026-10-24):** server `audience='all'` (3 dars), Bosh sahifa plitkasi, fan sahifasida ko‘rinadi, test — o‘zi yechadi. Apparatlar decklarini 38–42 slayd/20 mcq ga kengaytirish — agent ishlamoqda.
- **Pro versiya (0.4.0, tekshiruvdan keyin):** reja va narx takliflari `docs/PRO_PLAN_2026-10-24.md` — egasi tasdig‘i kerak; tekshiruvdagi 0.3.1 ga Pro qo‘shilmaydi.
- **Audit 2026-10-24 (kech, bajarildi):** apparatlar decklari 42/42/41 slayd, 20 mcq; barcha 11 rasm o‘z bucketdan (Wikimedia hotlink olib tashlandi, 429 xatosi bor edi); «Adabiyotlar» slaydidan ichki fayl nomi olib tashlandi; fan sahifasida kurs darslari 5 tadan + «Yana N ta dars»; «Sinf» → «Guruh testi» hamma matnlarda; ilova asseti faqat tekshirilgan savollar (540), server 4400. Real ilova (Linux, demo ustoz): dars/diagramma/rasm slaydlari, fan sahifasi, Bosh sahifa plitkasi, Darslar ro‘yxati — skrinshotlar `scratchpad/qa_audit_out*`. Haqiqiy iOS/Android qurilmada sinalmagan.
- **Yuborildi (2026-10-24):** Shimadzu (info@shimadzu.eu) va Meta-Xrom (m_chrom@mari-el.ru) ga rasm/skrinshot ruxsat xatlari + o‘zaro foyda davomi; javob kutilmoqda, 14 kundan keyin eslatma — `docs/letters/IMAGE_PERMISSION_SHIMADZU_META-XROM.md` (EN/RU loyihalar). Ruxsatgacha faqat CC va o‘z rasmlar.
- **Egasi qarori kutiladi:** Apparatlar decklarini 38–42 slayd/20 mcq ga kengaytirish; Kristallyuks modeli (Xromatek Kristall vs Meta-Xrom Kristallyuks) va o‘z laboratoriya fotolari.
- **Keyingi:** «Apparatlar bilan ishlash» (Kristallyuks/etanol, UV-1900/COHb, GX-MS) — kontent + ruxsatli rasmlar (agent); egasidan o‘z laboratoriya fotolari so‘raldi. Ilmiy muharrir ko‘rishi kerak bo‘lgan shubhalar — `verify/*.md` (165 uncertain band).
