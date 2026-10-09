# Admin panel va «Taklif va murojaatlar»

Yangilangan: 2026-10-09. Migratsiya: `supabase/migrations/20261009000000_support_and_admin.sql`
(PRODUCTION’GA HALI QO‘LLANMAGAN — egasining ruxsati kerak). SQL testlar:
`supabase/tests/support_admin_test.sql` (CI: «Supabase migration security tests»).

## 1. Nima qurildi

**Foydalanuvchi (Profil → «Taklif va murojaatlar»)**
- O‘z murojaatlari ro‘yxati: turkum, holat chipi (Yangi / Ko‘rib chiqilmoqda /
  Javob berilgan / Yopilgan), o‘qilmagan javoblar belgisi.
- Yangi murojaat: turkum (Taklif, Ilovadagi nosozlik, Ilmiy xato, Yangi imkoniyat,
  Texnik yordam, Umumiy savol), mavzu (≤ 200), xabar (≤ 4000), ixtiyoriy skrinshot
  (JPEG/PNG, ≤ 5 MB; 1 MB dan katta rasm 1600 px gacha kichraytiriladi),
  maxfiylik izohi va **majburiy rozilik** belgisi (serverda ham tekshiriladi).
- Murojaat — chat ko‘rinishida (foydalanuvchi o‘ngda, jamoa chapda), javob maydoni.
  Admin kimligi foydalanuvchiga ko‘rsatilmaydi («FORENSIC EXPERT jamoasi»).
- Modda / bilim / yo‘riqnoma sahifalarida app bar «⋮» → «Xato haqida xabar berish»:
  forma `SCIENTIFIC_ERROR` va `related_entity` (masalan `substance:morphine`,
  `guideline:<id>`) bilan oldindan to‘ldiriladi.
- Ilova ichidagi bildirishnoma: Profil tabida son belgisi, Profil’da karta, boshqa
  tablarda pastki banner («Ko‘rish» / yashirish). Push/email hozir YO‘Q (§6).

**Admin (faqat server `my_access.is_admin` = identity_admin)**
- Boshqaruv paneli: bo‘limlar (Murojaatlar qutisi, Foydalanuvchilar, Amallar
  jurnali, Maqolalar moderatsiyasi), `admin_stats()` kartalari, 14 kunlik ustunli
  diagramma (ro‘yxatdan o‘tish + AI savollari), turkumlar bo‘yicha ustunlar, eski
  `admin_dashboard()` bloklari (platforma, davlat, Pro berish).
- Inbox: holat (javob kutmoqda / hammasi / har bir holat), turkum, qidiruv (mavzu
  yoki email), «Yana yuklash»; murojaatni ochish, «Javob yozish», holatni o‘zgartirish.
- Foydalanuvchilar: qidiruv (email/ism), rol va tarif saralash, sahifalash.
- Amallar jurnali: har bir admin amali (xabar matnisiz).
- Admin bo‘lmagan foydalanuvchi admin marshrutini ochsa — «Kirish taqiqlangan»
  sahifasi (`AdminGate`). Bu faqat UI qulayligi: **xavfsizlik chegarasi server**.

## 2. Arxitektura tanlovi: ilova ichidagi Flutter admin vs alohida web panel

| Mezon | Ilova ichida (tanlandi) | Alohida web panel (Next.js/Retool va h.k.) |
|---|---|---|
| Xavfsizlik chegarasi | Bir xil: Supabase RPC + `identity_admin` + RLS | Bir xil RPC’lar; lekin yangi domen, CORS, sessiya, CSP — yangi hujum yuzasi |
| Kirish | Mavjud email-OTP sessiyasi | Alohida login oqimi kerak (yoki Supabase Auth web) |
| Xarajat | 0 (mavjud ilova, mavjud backend) | Hosting + domen + alohida deploy/CI; Retool kabi SaaS — oylik to‘lov |
| Ishlab chiqish | Mavjud dizayn tizimi, l10n, testlar qayta ishlatiladi | Yangi stack, yangi testlar |
| Qulaylik | Telefon/planshetda tez javob berish | Katta ekran, jadval, eksport qulayroq |
| Feature-freeze | Kichik, ajratilgan qo‘shimcha | Katta yangi loyiha |

**Qaror:** hozir ilova ichida. Egasi bitta, murojaatlar soni kichik, javob
telefondan tez beriladi. Barcha ma’lumot va huquq serverda bo‘lgani uchun keyinchalik
web panel qo‘shish faqat yangi mijoz yozishni talab qiladi — RPC’lar o‘zgarmaydi.
Web panel zarur bo‘ladi: jamoa > 2 admin, CSV eksport, ko‘p ustunli jadvallar.

## 3. Xavfsizlik modeli

- `support_threads`, `support_messages`, `private.admin_audit`,
  `private.admin_settings`: RLS yoqilgan, **siyosat yo‘q, jadval huquqi yo‘q**
  (anon/authenticated). Hamma narsa `SECURITY DEFINER` + `search_path = ''` RPC
  orqali; har bir funksiya uchun aniq `revoke … from public, anon, authenticated` +
  `grant … to authenticated`.
- Admin huquqi **faqat** `private.has_role(auth.uid(), 'identity_admin')`
  (`account_roles`, egasi SQL konsolda beradi). Email bo‘yicha moslashtirish hech
  qayerda yo‘q. Ilovadagi `isAdmin` faqat UI’ni ko‘rsatish uchun.
- Yagona tekshiruv: `private.admin_guard()` (hamma admin RPC’lar, shu jumladan qayta
  yozilgan `admin_dashboard()` va `admin_set_access()`).
- Foydalanuvchi faqat o‘z murojaatlarini ko‘radi; boshqasining murojaatiga yozish
  `NOT_FOUND` qaytaradi; `publication_moderator` support admin emas.
- Cheklovlar: mavzu ≤ 200, xabar ≤ 4000; ≤ 10 yangi murojaat / 24 soat;
  ≤ 60 xabar / soat (foydalanuvchi bo‘yicha). Rozilik bo‘lmasa — `CONSENT_REQUIRED`.
- Skrinshot: shaxsiy bucket `support-attachments` (public = false, 5 MB, jpeg/png/webp).
  Storage siyosati: yozish faqat `<o‘z uid>/…`, o‘qish — o‘z papkasi yoki
  identity_admin. RPC faqat `<o‘z uid>/<uuid>.(jpg|png|webp)` ko‘rinishidagi va
  bucket’da **mavjud** obyektni qabul qiladi. Admin rasmni 5 daqiqalik imzolangan
  havola orqali ko‘radi.
- `admin_stats()` faqat agregat sonlar qaytaradi (SQL test: matn/email yo‘q).
  Talaba/ekspert soni: **serverda saqlanmaydi** (rejim — qurilma sozlamasi), shuning
  uchun `null`; o‘rniga «mutaxassis profillari» va «tasdiqlangan mutaxassislar».
  Faol foydalanuvchi ta’rifi: oynada `user_devices.last_seen`, `ai_usage` yoki
  `auth.users.last_sign_in_at` bo‘lgan distinct foydalanuvchilar (7 va 30 kun).
  Pro: faqat server `access_grants` (do‘kon xaridlari qurilmada tekshiriladi).
- `admin_users()` qaytaradi: id, email, ism (professional profil bo‘lsa), sana,
  mutaxassislik, tillar, oxirgi qurilma tili, platformalar, tasdiq holati, tarif,
  rollar, oxirgi faollik, akkaunt holati (ACTIVE / UNCONFIRMED / BANNED). Parol
  xeshi, token, `raw_*_meta_data` hech qachon.

### Audit
`private.admin_audit` ga yoziladi: `SUPPORT_REPLY`, `SUPPORT_STATUS`,
`SUPPORT_THREAD_VIEW` (admin boshqa foydalanuvchi murojaatini ochdi), `USERS_VIEW`,
`ACCESS_SET` (Pro berish/olish), `ROLE_GRANTED` / `ROLE_REVOKED` / `ROLE_CHANGED`
(`account_roles` trigger’i — SQL konsol o‘zgarishlari ham). Tafsilotda faqat id,
holat, uzunlik, tarif/rol — xabar matni yo‘q. `admin_audit_log(limit)` — faqat admin.
Inbox ro‘yxati va statistika (agregat, o‘qish) jurnalga yozilmaydi — shovqin bo‘lmasin.

## 4. MFA (TOTP, aal2) yoqish — egasi uchun

Sukut bo‘yicha o‘chiq (`private.admin_settings.admin_requires_aal2 = false`), aks
holda TOTP’siz egasi panelga kira olmay qoladi.

1. Supabase Dashboard → Authentication → Multi-Factor → TOTP yoqilganini tekshiring.
2. Ilovada (yoki Supabase JS/REST orqali) egasi akkauntiga TOTP faktorini qo‘shing
   (`/auth/v1/factors` enroll → verify). *Eslatma:* ilovada hozircha MFA enroll
   ekrani yo‘q — bu BACKLOG’da; shu sababli hozir yoqmang.
3. Kirishda `challenge` + `verify` qilingandan keyin JWT’da `aal = aal2` bo‘ladi.
4. SQL konsol: `update private.admin_settings set admin_requires_aal2 = true;`
5. Shundan so‘ng `aal1` sessiya bilan har bir admin RPC `mfa required` xatosini
   beradi (SQL testda tekshirilgan). Qaytarish: `… = false`.

## 5. Ma’lumotni saqlash va akkauntni o‘chirish

- Akkaunt o‘chirilganda (`auth.users` delete) muallifning murojaatlari va xabarlari
  `ON DELETE CASCADE` bilan o‘chadi (SQL testda tekshirilgan).
- Admin javoblari boshqa foydalanuvchilar murojaatlarida qoladi, `sender_id = null`.
- Audit yozuvlari qoladi, `actor_id = null` (kim qilgani noma’lum bo‘ladi).
- Skrinshot fayllari storage’da: `delete-account` Edge Function `support-attachments/<uid>/`
  papkasini ham o‘chirishi kerak — kod yangilandi
  (`supabase/functions/delete-account/index.ts`), lekin **deploy egasi ruxsati bilan**.
- Tavsiya (hali avtomatlashtirilmagan): `CLOSED` murojaatlarni 24 oydan keyin
  o‘chirish (pg_cron yoki qo‘lda SQL). Maxfiylik siyosatida 1 qator qo‘shish kerak.
- Ma’lum cheklov (avvaldan bor): `account_roles.granted_by` FK’da `ON DELETE` yo‘q —
  rol bergan adminni o‘chirishdan oldin u bergan rollarni qayta tayinlash kerak.

## 6. Bildirishnoma variantlari va narxi

| Variant | Narx | Izoh |
|---|---|---|
| Ilova ichida (hozir) | 0 | Belgi + banner; ilova ochilganda/murojaat ko‘rilganda yangilanadi |
| Email (Resend, mavjud SMTP) | Bepul: 3 000 xat/oy, 100/kun; keyin ~$20/oy | Edge Function trigger yoki `pg_net`; domen tasdiqlanishi kerak (BACKLOG) |
| Push — FCM (Android + iOS APNs orqali) | FCM bepul | `firebase_messaging` qo‘shish (yangi bog‘liqlik), APNs kalit, qurilma token jadvali, Edge Function yuboruvchi — feature-freeze’dan keyin |
| OneSignal kabi SaaS | Bepul tarif bor, keyin pullik | Uchinchi tomonga foydalanuvchi identifikatori beriladi — maxfiylik siyosatini yangilash kerak |
| Admin uchun Telegram bot | 0 | Faqat egasiga «yangi murojaat» xabari; token Edge Function secret’da |

## 7. Nima soxta (mock) va nima haqiqiy

- **Haqiqiy:** SQL migratsiya va RPC’lar (lokal PostgreSQL 16 da test qilingan),
  `SupabaseSupportService` (REST/Storage; soxta transport bilan unit test).
- **Soxta:** `InMemorySupportService` (faqat testlar/namoyish), widget va golden
  testlardagi statistika va foydalanuvchilar (FIXTURE).
- **Qo‘llanmagan:** production DB’ga migratsiya, `delete-account` deploy, MFA.

## 8. Egasining ruxsati kerak

1. `20261009000000_support_and_admin.sql` ni production’ga qo‘llash (yangi jadvallar,
   bucket, `admin_dashboard`/`admin_set_access` qayta yoziladi).
2. `delete-account` Edge Function deploy (skrinshotlarni o‘chirish).
3. MFA (aal2) yoqish — TOTP enroll’dan keyin.
4. Maxfiylik siyosatiga «murojaatlar va skrinshotlar» bandini qo‘shish.
5. Har qanday push/email provayderi (pullik bo‘lishi mumkin).
