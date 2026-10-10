# ACTIVE TASKS

Yangilangan: 2026-10-10. Format: [holat] vazifa — egasi/keyingi qadam.

## Hozir bajarilmoqda (agentlar, worktree'da, birlashtirilmagan)
- [agent] **Ilmiy ishonchlilik statuslari** — A «Manbasi aniqlangan» / B «Ilmiy asosi
  tekshirilgan» / C «Ekspert taqrizidan o'tgan» / D «Qo'shimcha tekshiruv talab etiladi»,
  ixcham chip + tafsilot oynasi, ichki metama'lumotni STUDENT/EXPERT'dan yashirish,
  dalil darajasi faqat hujjatlashtirilgan mezon bilan.
- [agent] **Pro vositalari** — fasetli/teskari qidiruv va «Modda bo'yicha tahlil rejasi»
  ekrani, `tool/l10n_pro_tools.py`, `qa_pro_tools_test.dart`.

## Egasidan ruxsat kutilmoqda
0. [egasi] **ABY 2025 mazmunini ilovaga kiritish.** `docs/DECISIONS.md` dagi 2026-10-08 qarori
   (Variant B: katalog faqat admin qurilmasida, repo/CI/Supabase/AI'ga chiqmaydi) hali kuchda;
   koordinator xabari bilan kelgan «ABY ochiq manba sifatida yoziladi, bepul, faqat o‘zbekcha»
   o‘zgarishi egasining o‘zidan tasdiqlanmadi, shuning uchun ABY'dan olingan yozuvlar repoga
   KIRITILMADI (kod yo‘lga tayyor: `locale_only`, `ClaimCard` matn rejimi, `visibleClaims`).
   Egasi tasdiqlasa: `DECISIONS.md` ga yangi qaror yozilsin, so‘ng agent saqlangan ABY yozuvlari
   (32 claim, 19 bepul mavzu, manba yozuvi) va minnatdorchilik ekranini qo‘shadi.
1. [egasi] `supabase/migrations/20261010000000_admin_verification_inbox.sql` —
   production'ga qo'llash. Faqat yangi RPC `admin_pending_verifications` qo'shadi;
   mavjud jadval va o'zini-o'zi tasdiqlash taqiqi tegilmagan. **Qo'llanmaguncha
   admin panelidagi «Tasdiqlash arizalari» ro'yxati bo'sh keladi.**
2. [egasi] Egasining o'z professional maqomi: DB cheklovi o'zini-o'zi tasdiqlashni
   taqiqlaydi (`approver_id <> applicant_id`). Yechim — ikkinchi admin akkaunt.
3. [egasi] Ekspert ish daftari bepulmi yoki Pro? Hozir hamma uchun bepul.
4. [egasi] Umumiy qurilmada daftarni chiqishda tozalash / PIN bilan himoyalash kerakmi?
5. [egasi] `C-FM-ALGOR-MORTIS-DEFINITION` — chaqirib olingan manbaga bog'langan
   ataylab qoldirilgan test namunasi. Qoldirilsinmi yoki `SRC-PMC12346081` ga ko'chirilsinmi?
   (Tavsiya: qoldirilsin — retraksiya ogohlantirishi ishlayotganini ko'rsatadi.)

## Play Console (Internal testing)
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
