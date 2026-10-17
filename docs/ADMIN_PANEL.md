# Admin panel va «Taklif va murojaatlar»

Yangilangan: 2026-10-09; kengaytma 2026-10-17 (§9). Migratsiya: `supabase/migrations/20261009000000_support_and_admin.sql`
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
- **Pro sovg‘a qilish (2026-10-11):** «Pro berish» bo‘limiga istalgan elektron
  pochta yoziladi va uch amal bor — «Mutaxassis Pro berish» (`professionalPro`),
  «Talaba Pro berish» (`studentPro`), «Olib tashlash» (tarif `null`). Hammasi
  `admin_set_access(p_email, p_tier)` orqali, server tomonida `admin_guard()` va
  `ACCESS_SET` audit yozuvi bilan. Manzil shakli ilovada ham tekshiriladi
  (xato terilganda so‘rov yuborilmaydi), olib tashlash tasdiq oynasi so‘raydi,
  muvaffaqiyatdan keyin maydon tozalanadi. Hisob **allaqachon mavjud** bo‘lishi
  kerak: bu paneldan taklif/ro‘yxatdan o‘tkazish yuborilmaydi, topilmasa
  `NOT_FOUND`. Do‘kondan qilingan xaridga ta’sir qilmaydi — faqat server grantiga.
- Inbox: holat (javob kutmoqda / hammasi / har bir holat), turkum, qidiruv (mavzu
  yoki email), «Yana yuklash»; murojaatni ochish, «Javob yozish», holatni o‘zgartirish.
- Foydalanuvchilar: qidiruv (email/ism), rol va tarif saralash, sahifalash.
- Amallar jurnali: har bir admin amali (xabar matnisiz).
- **Tasdiqlash arizalari (2026-10-10):** kutayotgan (`APPLICATION_PENDING`) arizalar
  ro‘yxati (`admin_pending_verifications`, faqat identity_admin + MFA qoidasi),
  tafsilot (profil + hujjat metama’lumoti: tur, MIME, hajm, SHA-256 — fayl mazmuni
  EMAS), tekshirilgan hujjatlarni belgilash, sabab (>= 5 belgi) va qaror
  (`decide_identity`: Tasdiqlash / Qo‘shimcha ma’lumot so‘rash / Rad etish).
  O‘z arizasi ro‘yxatda «Sizning o‘z arizangiz» deb belgilanadi va uni tasdiqlab
  bo‘lmaydi (server ham rad etadi) — boshqa vakolatli admin hal qiladi.
  Hujjat faylining o‘zini ilovadan ochish hozir YO‘Q (imzolangan URL serverda
  yozilmagan); admin faylni xavfsiz omborda tekshiradi. `verifier_grants` bo‘yicha
  tasdiqlovchi tengdoshlar uchun bu ro‘yxat yoqilmagan (soha xaritasi yo‘q).
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
6. `20261010000000_admin_verification_inbox.sql` ni production’ga qo‘llash
   (faqat yangi RPC `admin_pending_verifications`; mavjud jadval/funksiyalar o‘zgarmaydi).

## 9. Kengaytma (2026-10-17, branch `claude/admin-ext`)

Migratsiya: `supabase/migrations/20261017000000_admin_extension.sql` — **PRODUCTION’GA
QO‘LLANMAGAN**; egasi ishlari: `docs/ADMIN_EXTENSION_DEPLOY.md`. Yangi kod: Flutter
`lib/features/moderation/`, `lib/app/moderation.dart`, `lib/domain/moderation/`,
`lib/data/remote/supabase_moderation.dart`; Edge Function `supabase/functions/admin-bootstrap`.
To‘lov, paywall yoki yashirin bayroq QO‘SHILMAGAN.

### 9.1 Admin aniqlash (o‘zgarmadi, mustahkamlandi)
- Huquq manbai avvalgidek **server roli**: `account_roles` + `private.has_role(uid, 'identity_admin')`
  (loyihadagi admin roli nomi `identity_admin`; «admin» deganda shu tushuniladi).
- `private.admin_guard()` endi **tasdiqlangan email** va **bloklanmagan hisob**ni ham talab qiladi.
  Har bir admin RPC har so‘rovda uni qayta chaqiradi; ilovadagi tugma/ko‘rinish xavfsizlik emas.
- `ADMIN_EMAILS` (vergul bilan sir) **faqat bootstrap** uchun: `admin-bootstrap` Edge Function
  (service-role kalit bilan chaqiriladi) ro‘yxatdagi **email tasdiqlangan** hisoblarga birinchi
  marta `identity_admin` beradi (`private.admin_bootstrap`, audit `ADMIN_BOOTSTRAP`). Email o‘zi
  huquq bermaydi va oddiy so‘rovda tekshirilmaydi. Ro‘yxatdagi tasdiqlanmagan/noma’lum manzil
  o‘tkazib yuboriladi; bir martada ≤ 10 manzil.
- Ilovadan admin **berish** sukut bo‘yicha o‘chiq (`private.admin_settings.allow_admin_grant_in_app
  = false`): ikkinchi admin kerak bo‘lsa egasi SQL konsolda yoqadi yoki bootstrap ro‘yxatiga
  qo‘shadi. Ilmiy reviewer roli (`scope_grantor`) paneldan berilmaydi: admin ≠ reviewer.

### 9.2 Shikoyat/murojaat (`user_reports`)
- Turlar: shikoyat, nomaqbul kontent, xato, reklama, boshqa. `submit_report(...)` **anon ham**
  chaqiradi. Tezlik: soatiga **5 ta** — kirgan foydalanuvchi uchun `user id`, kirmagan uchun IP
  xeshi (`cf-connecting-ip` → `x-real-ip` → `x-forwarded-for`) **yoki** qurilma kaliti xeshi
  (qaysi biri 5 ga yetsa to‘xtaydi); kirmaganlar uchun umumiy shift 100/soat. IP va kalit
  **tuzlangan SHA-256** ko‘rinishida saqlanadi, xomi hech qayerda.
- Admin: `admin_reports` (holat/tur/qidiruv), `admin_report_note`, `admin_resolve_report`
  (hal qilindi / qayta ochish), hammasi audit’da (matnsiz). Foydalanuvchi `my_reports` orqali
  faqat **o‘zining** shikoyatlarining turi va holatini ko‘radi (matn va admin izohi emas).
- Savol-javob postlari: mavjud `qa_report` (3 ta alohida shikoyat → post yashiriladi) o‘zgarmadi;
  admin ro‘yxatida unga havola bor (`Routes.qaModeration`). Umumiy shikoyatda `target_type`
  (`qa_question` / `qa_answer`) ixtiyoriy.

### 9.3 Foydalanuvchilar
- Qidiruv (`admin_users`, `admin_support_inbox`, `admin_reports`, `qa_feed`): LIKE belgilari
  `%`, `_`, `\` **ekranlanadi** (`private.like_escape` + `ESCAPE '\'`).
- Rol: `admin_set_role(user, 'publication_moderator' | 'identity_admin', grant, reason ≥ 5)`.
  O‘zining admin rolini o‘zgartirib bo‘lmaydi; oxirgi admin olinmaydi; admin berish faqat
  tasdiqlangan email + yuqoridagi sozlama bilan. Audit: `ADMIN_ROLE_SET` (+ trigger
  `ROLE_GRANTED/REVOKED`).
- To‘xtatish: `admin_set_suspension(user, true|false, reason ≥ 5)`: `auth.users.banned_until`
  (Auth kirish va **token yangilashni** rad etadi) + foydalanuvchining `auth.sessions` va
  `auth.refresh_tokens` qatorlari o‘chiriladi + `account_suspensions` yozuvi. **Admin va o‘zini
  to‘xtatib bo‘lmaydi.** Cheklov (halol): allaqachon berilgan access token muddati tugaguncha
  (`jwt_expiry = 3600` s) **eski** RPC’larda ishlashi mumkin; yangi/qayta yozilgan RPC’lar
  (`submit_report`, `accept_terms`, `qa_feed`, `qa_question`, `qa_block_author`) `private.assert_active`
  bilan darhol rad etadi. Production’da `auth.sessions` o‘chirish huquqi **tekshirilmagan** —
  deploy hujjatida tekshiruv qadami bor; zaxira: Dashboard → Authentication → Users → Ban.

### 9.4 Statistika (`admin_stats_ext` + mavjud `admin_stats`)
Jami/yangi (7, 30 kun)/rollar/14 kunlik ustunli grafik (mavjud), shikoyatlar (ochiq/hal qilingan),
Savol-javob (savol, javob, moderatsiyada), bloklashlar, to‘xtatilganlar. Serverga ko‘rinmaydi va
panelda **halol izoh** bilan yoziladi: casebook (qurilmada, hisoblanmaydi), «hozir tizimda»
(kuzatuv yo‘q — `user_devices.last_seen` faqat ilova ochilishidagi belgi, 15 daqiqalik faollik
hisoblanmaydi), yuklab olishlar (App Store Connect / Google Play Console tugmalari, tashqi
brauzer), sotuvlar «0 — to‘lov tizimi yo‘q».

### 9.5 Apple 1.2
- **Bloklash:** `qa_block_author('question'|'answer', id)` muallif kimligini **bilmasdan** blok
  qo‘yadi (`user_blocks`, RLS yopiq); `qa_feed`/`qa_question` bloklanganlarning post va
  javoblarini yashiradi; `my_blocks` faqat ichki belgi + sana qaytaradi; blokdan chiqarish bor.
  UI: savol/javobda «Muallifni bloklash», Qoidalar → «Bloklangan mualliflar».
- **Foydalanish qoidalari (EULA):** `CommunityTermsScreen` — mavjud hamjamiyat qoidalari matni +
  «Foydalanish shartlari (qoralama)» havolasi; ekranda «qoralama, yurist tekshirishi kerak»
  belgisi. Qabul `accept_terms` bilan serverga yoziladi va **server trigger’i** (`qa_terms_required`)
  qabulsiz yangi savol/javobni rad etadi (eski yoki o‘zgartirilgan mijoz ham o‘ta olmaydi).
  Juridik matn to‘qilmagan: mavjud `disclaimerBody` qoralamasi ishlatilgan.
- **Ko‘rinadigan aloqa:** `davlatsudekspert@gmail.com` (`docs/legal/privacy.html` da bor) —
  Savol-javob lentasi, qoidalar, qabul ekrani, bloklanganlar va shikoyat formasida (`mailto`).

### 9.6 Nima soxta/haqiqiy (kengaytma)
- Haqiqiy: SQL migratsiya va RPC’lar lokal PostgreSQL 16 da `admin_extension_test.sql` (135 tekshiruv)
  bilan sinalgan; Flutter servis qatlami soxta transport bilan.
- Soxta/demo: `InMemoryModerationService` (faqat test); widget testlar server o‘rniga shu.
- **Sinalmagan:** production Supabase (migratsiya qo‘llanmagan), `auth.sessions` o‘chirishning
  production’dagi huquqi, haqiqiy iOS/Android qurilmada admin oqimi, `admin-bootstrap` deploy,
  IP sarlavhasining haqiqiy proksi orqali kelishi (`request.headers`), do‘kon konsol havolalari
  haqiqiy qurilmada.
