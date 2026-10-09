# ACTIVE TASKS

Yangilangan: 2026-10-09. Format: [holat] vazifa — egasi/keyingi qadam.

## Hozir bajarilmoqda
- [agent] O‘zbekcha UI to‘liqligi + avtomatik test (worktree, birlashtirish kutilmoqda).
- [agent] Premium dizayn tizimi: graphite/navy/noir, champagne gold, ivory, serif sarlavhalar (worktree).

- [agent] Admin panel + «Taklif va murojaatlar» (worktree): migratsiya
  `20261009000000_support_and_admin.sql` + SQL testlar, Flutter ekranlar, testlar,
  goldenlar. Batafsil: `docs/ADMIN_PANEL.md`.

## Admin panel / murojaatlar — yo‘l xaritasi
1. [egasi] Migratsiyani production’ga qo‘llash (ruxsat) → OTP bilan kirib, Profil →
   «Taklif va murojaatlar» va Boshqaruv paneli → Murojaatlar qutisi E2E.
2. [egasi] `delete-account` Edge Function deploy (skrinshotlarni ham o‘chiradi).
3. [backlog] MFA: ilovada TOTP enroll ekrani → `admin_requires_aal2 = true`.
4. [backlog] Bildirishnoma: egasiga Telegram/email «yangi murojaat»; foydalanuvchiga
   push (FCM) — feature-freeze’dan keyin, narx/variantlar `ADMIN_PANEL.md` §6.
5. [backlog] Yopilgan murojaatlarni 24 oydan keyin tozalash (pg_cron) + maxfiylik
   siyosatiga band.
6. [backlog] Katta jamoa bo‘lsa — alohida web admin (o‘sha RPC’lar ustida).

## Navbatdagi (xavfsiz, mustaqil)
1. Agent natijalarini birlashtirish → to‘liq test → goldenlar → push → CI.
2. YuQX/TLC bo‘yicha alohida mustaqil karta (afzallik/cheklovlar, tekshirilgan manbalar) — BlueStacks muammosi shu mavzuda.
3. Yo‘riqnomalarni global qidiruvga ulash; Home’da «Yo‘riqnomalar» kirishi.
4. Qidiruv: ko‘p so‘zli so‘rovlar va fan filtri (FTS5 indeksidan foydalanish).
5. Fanlar ontologiyasi: tibbiy-kriminalistika, trasologiya, ballistika, hujjatlar, raqamli kriminalistika (bo‘sh, soxta kontentsiz).
6. Expert Publications: model + moderatsiya oqimi (public o‘chiq).
7. O‘quv rejimi: quiz/flashcards uchun manbali kontent.
8. ABY: 203 sarlavha RU/EN qoralama, admin katalogi qayta qurish (ZIP qayta yuklangach).

## Egasining ruxsati/harakati kerak
- ABY nuqsonlari bo‘yicha mualliflarga xat (loyiha tayyor, yuborilmagan).
- Do‘kon mahsulotlari, narxlar ($4.99 / $39.99 sinov), server tekshiruvi.
- Resend domeni, Android keystore, Play Console.
- ABY ZIP fayllarini qayta yuklash (konteyner tozalangan).
