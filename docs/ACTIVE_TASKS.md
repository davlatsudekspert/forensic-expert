# ACTIVE TASKS

Yangilangan: 2026-10-11. Format: [holat] vazifa — egasi/keyingi qadam.

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
