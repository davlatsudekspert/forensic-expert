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
