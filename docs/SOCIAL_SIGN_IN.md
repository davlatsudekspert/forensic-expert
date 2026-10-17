# Google va Apple bilan kirish

> Holat (2026-10-17): **kod tayyor, standart holatda O‘CHIQ.** Egasi quyidagi
> qo‘lda ishlarni bajarib, `FE_SOCIAL_SIGN_IN=true` bilan yig‘masa tugmalar
> ko‘rinmaydi. Feature-freeze istisnosi (egasi ruxsati). Native oqim
> **hech qayerda sinalmagan** — 6-bo‘limga qarang.

Sabab: Apple App Review 4.8 — uchinchi tomon (Google) bilan kirish bo‘lsa,
Sign in with Apple ham bo‘lishi **shart**. Shuning uchun ikkalasi bitta bayroq
ortida birga yoqiladi. Email OTP/parol kirishi o‘zgarmagan.

## 1. Nima qilindi (kod)

| Qism | Fayl |
|---|---|
| Bayroq | `lib/core/social_sign_in_flag.dart` — `kSocialSignIn` (`--dart-define=FE_SOCIAL_SIGN_IN=true`, standart `false`), test seam: `socialSignInEnabled` |
| Domen | `lib/domain/auth/social_sign_in.dart` — `SocialProvider`, `SocialCredential`, `SocialNonce` (xom nonce + SHA-256 hex), `visibleSocialProviders` (platforma qoidasi) |
| Native token | `lib/data/auth/native_social_credential_source.dart` (`google_sign_in ^7.2.0`, `sign_in_with_apple ^8.2.0`) |
| Supabase | `SupabaseAuthRepository.signInWithIdToken` — `POST {url}/auth/v1/token?grant_type=id_token` `{provider, id_token, nonce}`; so‘ng `PUT /auth/v1/user` bilan `user_metadata` ga `full_name` (Apple faqat birinchi kirishda beradi) va `accepted_terms_version` |
| UI | `social_sign_in_buttons.dart` — Kirish, Ro‘yxatdan o‘tish va Email-kod ekranlarida «yoki» ajratgichi + tugmalar |
| Akkaunt o‘chirish | Google/Apple akkauntida parol so‘ralmaydi (`AuthAccount.isSocial`); server funksiyasi (`delete-account`) o‘zgarmagan, auth foydalanuvchini (identity’lar bilan) o‘chiradi |
| Matnlar | `tool/l10n_social_auth.py` (idempotent, en/ru/uz) → `flutter gen-l10n` |
| iOS | `ios/Runner/Runner.entitlements` (`com.apple.developer.applesignin = Default`), `Info.plist` Google URL scheme `$(GOOGLE_REVERSED_CLIENT_ID)`, `ios/Flutter/Social.xcconfig` (placeholder + gitignored `SocialLocal.xcconfig`), `project.pbxproj` da `CODE_SIGN_ENTITLEMENTS` |

Tugmalar qoidasi: bayroq o‘chiq → hech narsa. iOS → Apple (qora/oq standart
tugma, qorong‘i rejimda oq) **yuqorida**, Google pastda. Android → faqat Google
(Apple Androidda faqat web oqimi bilan ishlaydi; yashirilgan). Web/desktop → yo‘q.
Foydalanuvchi oynani yopsa xato ko‘rsatilmaydi.

`l10n` tartibi: `l10n_social_auth.py` ni `l10n_avatar.py` dan keyin, `l10n_ux_audit.py` dan oldin
ishga tushiring (CLAUDE.md dagi ro‘yxatga qo‘shilmagan — egasi/keyingi sessiya qo‘shsin).

### Dart-define’lar (kodda qiymat yo‘q)

| Nom | Nima |
|---|---|
| `FE_SOCIAL_SIGN_IN=true` | tugmalarni yoqadi |
| `GOOGLE_IOS_CLIENT_ID` | Google iOS OAuth client ID |
| `GOOGLE_SERVER_CLIENT_ID` | Google **Web** OAuth client ID (Android’da ham shart; ID token `aud` shu) |

`GOOGLE_SERVER_CLIENT_ID` bo‘lmasa Google tugmasi «akkaunt xizmati ulanmagan» xatosini beradi.

## 2. EGASI QO‘LDA QILADIGAN ISHLAR (qadamma-qadam)

Hech qanday kalit/secret repoga yozilmaydi. `.p8`, client secret — faqat
Supabase Dashboard’da va parol menejerida.

### (a) Apple Developer

1. developer.apple.com → Certificates, Identifiers & Profiles → **Identifiers** → App ID
   `uz.forensicexpert.app` (xcodeproj’dagi bundle ID) → **Sign In with Apple** capability’ni yoqing
   (Enable as a primary App ID).
2. Shu App ID uchun **provisioning profile**’ni qayta yarating/yangilang. Avtomatik
   imzolashda (App Store Connect API kaliti bilan, `tool/ios_testflight.sh`) profil
   capability’dan keyin o‘zi yangilanadi; qo‘lda profil bo‘lsa — yangisini yuklang.
   **Shu qadamsiz imzolangan build entitlement xatosi bilan yiqiladi.**
3. **Native iOS uchun Services ID va .p8 kalit SHART EMAS** (faqat bundle ID).
   Ular faqat kelajakda Android/web Apple oqimi kerak bo‘lsa:
   * Identifiers → **Services IDs** → yangi (masalan `uz.forensicexpert.app.signin`), Sign In with Apple’ni
     yoqing, Return URL: `https://<project-ref>.supabase.co/auth/v1/callback`.
   * Keys → yangi kalit, **Sign in with Apple** → `.p8` yuklab oling (faqat bir marta beriladi), **Key ID** ni yozib oling.
   * **Team ID** — Membership sahifasida.
   * `.p8` ni repoga/chatga qo‘ymang; parol menejerida va Supabase Dashboard’da saqlang.
     Supabase uchun client secret — `.p8` dan yasalgan JWT (6 oyda eskiradi, eslatma qo‘ying).

### (b) Google Cloud Console

1. APIs & Services → **OAuth consent screen**: User type External, ilova nomi, qo‘llab-quvvatlash emaili,
   maxfiylik siyosati va shartlar havolalari, scope’lar faqat `openid`, `email`, `profile`
   (sezgir scope yo‘q → Google tekshiruvi talab qilinmaydi). Publishing status: **In production**
   (Testing’da faqat test foydalanuvchilar kira oladi).
2. Credentials → Create OAuth client ID:
   * **Web application** → bu `GOOGLE_SERVER_CLIENT_ID` va Supabase’dagi asosiy Client ID. Client secret’ni
     faqat Supabase’ga yozing.
   * **iOS** → Bundle ID `uz.forensicexpert.app` → `GOOGLE_IOS_CLIENT_ID`. Yuklab olinadigan plist’dagi
     `REVERSED_CLIENT_ID` (`com.googleusercontent.apps.…`) ni `apps/mobile/ios/Flutter/SocialLocal.xcconfig`
     ga yozing: `GOOGLE_REVERSED_CLIENT_ID = com.googleusercontent.apps.XXXX` (fayl gitignored; CI’da
     shu faylni build oldidan yarating).
   * **Android** → package `uz.forensicexpert.forensic_expert` + **SHA-1** barmoq izi. Debug, upload
     keystore va (Play App Signing bo‘lsa) **Play Console → App integrity** dagi *app signing key* SHA-1
     — uchalasi uchun alohida Android client yarating. SHA-1 noto‘g‘ri bo‘lsa Android’da
     «xatolik» chiqadi (kodda emas, Console sozlamasida).

### (c) Supabase Dashboard → Authentication

1. **Providers → Google**: Enable. *Client IDs* maydoniga vergul bilan: Web client ID, iOS client ID,
   Android client ID(lar) (birinchisi — Web). *Client Secret* — Web client secret.
   **Skip nonce checks = ON.** Sabab: iOS Google SDK ID token’ga o‘zi nonce qo‘shadi va uni ilovaga bermaydi,
   shuning uchun Supabase tekshira olmaydi. (Xavf: replay himoyasi kuchsizroq; yengillashtiruvchi: token
   qisqa umrli, faqat TLS orqali, Google imzosi va `aud` baribir tekshiriladi.)
2. **Providers → Apple**: Enable. *Client IDs* — `uz.forensicexpert.app` (native uchun; Services ID qo‘shilsa vergul bilan).
   *Secret Key* — faqat web/Services ID oqimi uchun kerak; native-only uchun bo‘sh qolishi mumkin.
   **Skip nonce checks = OFF** (ilova Apple’ga SHA-256 nonce beradi, Supabase’ga xom nonce yuboradi).
3. **URL Configuration**: web oqimi ishlatilmaydi, lekin Redirect URL ro‘yxatida
   `https://<project-ref>.supabase.co/auth/v1/callback` Apple/Google konsollariga kerak bo‘lsa shu manzil.
4. **Sign In / Providers → Allow manual linking**: o‘chiq qoldiring. *Automatic linking* haqida 4-bo‘limga qarang.
5. Edge function deploy **qilinmagan** (men deploy qilmadim). Hozirgi `delete-account` o‘zgarishsiz ishlaydi.

### (d) App Store Connect — Review Notes’ga yozish (ingliz tilida)

> The app offers Sign in with Google and Sign in with Apple (guideline 4.8) in addition to email one-time-code
> sign-in. Account creation is optional; the scientific reference works without an account (5.1.1(v)).
> Account deletion: Profile → Account → Delete account (works for email, Google and Apple accounts; no password
> required for Google/Apple accounts). Reviewer test account: <egasi to‘ldiradi — email + OTP qanday olinishi>.
> Google/Apple sign-in requests only name and email. With "Hide My Email" a private relay address is stored.

Shuningdek: App Privacy («nutrition label») da *Name* va *Email* (account functionality, linked to user, not
for tracking) — mavjud bo‘lmasa qo‘shing; maxfiylik siyosatida Google/Apple’dan ism va email olinishini yozing.
Ilovaning `docs/AUTH_AND_SUBSCRIPTIONS.md` dagi «faqat email» tamoyili Apple ismi (bu topshiriq bo‘yicha saqlanadi)
bilan kengaydi — siyosat matnini shunga moslang.

### (e) Test tartibi (hammasi egasi/TestFlight; hozircha SINALMAGAN)

1. Yuqoridagi (a)–(c) tayyor; `SocialLocal.xcconfig` to‘ldirilgan; build:
   `flutter build ipa --dart-define-from-file=config/backend.json --dart-define=FE_SOCIAL_SIGN_IN=true --dart-define=GOOGLE_IOS_CLIENT_ID=… --dart-define=GOOGLE_SERVER_CLIENT_ID=…`
2. **Real iOS qurilma, TestFlight**: (1) Apple — birinchi kirish (ism + email beriladimi; Supabase Auth → Users’da
   foydalanuvchi, `user_metadata.full_name`), (2) chiqish va qayta kirish (ism endi kelmaydi — metadata saqlanib qolishi kerak),
   (3) «Hide My Email» bilan kirish, (4) Google real akkaunt bilan, (5) oynani yopish (jim qaytishi), (6) samolyot rejimi (oflayn xabar),
   (7) akkauntni o‘chirish (parolsiz) va Supabase’da foydalanuvchi yo‘qolgani, (8) o‘sha Apple/Google bilan qayta ro‘yxatdan o‘tish.
3. **Real Android qurilma**: faqat Google tugmasi ko‘rinishi, kirish, SHA-1 to‘g‘ri bo‘lmasa xato.
4. Bayroq o‘chiq yig‘mada tugmalar yo‘qligini tekshiring (standart).

## 3. Hisobni o‘chirish va Apple tokenini bekor qilish

* Ilovada o‘chirish (5.1.1(v)) social akkaunt uchun parolsiz ishlaydi (test: `social_sign_in_test.dart`).
* **BAJARILMAGAN (ochiq xavf):** Apple talabiga ko‘ra Apple bilan ochilgan akkaunt o‘chirilganda
  Apple tokeni bekor qilinishi (`POST https://appleid.apple.com/auth/revoke`) kerak. Buning uchun
  server (a) kirishda Apple `authorizationCode` ni `https://appleid.apple.com/auth/token` da refresh tokenga
  almashtirishi va xavfsiz saqlashi, (b) o‘chirishda `client_secret` (Team ID, Key ID, `.p8` dan JWT) bilan
  revoke qilishi kerak. Supabase native `id_token` oqimida Apple refresh tokenini saqlamaydi, shuning uchun
  ilova `authorizationCode` ni serverga yuborishi va `delete-account` Edge Function kengaytirilishi kerak.
  Bu men deploy qilmaydigan server ishi; App Review’gacha bajarilishi tavsiya etiladi (aks holda 5.1.1(v) bo‘yicha rad etilishi mumkin).
  `.p8` Edge Function secret’ida (`APPLE_TEAM_ID`, `APPLE_KEY_ID`, `APPLE_PRIVATE_KEY`) saqlanadi — egasi qo‘shadi.
* Google uchun alohida revoke majburiy emas (ixtiyoriy: `https://oauth2.googleapis.com/revoke`).

## 4. Xavfsizlik: email bo‘yicha hisoblarni birlashtirish

Supabase standartda **bir xil tasdiqlangan emailli identity’larni avtomatik bog‘laydi**.
* Google email’i tasdiqlangan (`email_verified`) — mavjud email-OTP akkaunti bilan bir xil email bo‘lsa, bitta foydalanuvchiga
  qo‘shiladi. Bu qulay, lekin faqat ikkala tomonda email **tasdiqlangan** bo‘lsa xavfsiz. Bizning email-OTP oqimi akkauntni
  faqat kod tasdiqlangandan keyin yaratadi (tasdiqlanmagan akkaunt yo‘q) — pre-hijacking xavfi past.
* **Apple «Hide My Email» (private relay)**: email `xxx@privaterelay.appleid.com` — haqiqiy emailga mos kelmaydi, shuning uchun
  mavjud akkaunt bilan **bog‘lanmaydi**: foydalanuvchida ikkita alohida akkaunt bo‘lib qoladi (ma’lumot/obuna bo‘linadi). Ilova
  buni hal qilmaydi; qo‘llab-quvvatlash ma’lumoti: foydalanuvchiga qaysi usul bilan kirganini eslatish kerak.
  Relay emailga xat yuborish uchun Apple’da jo‘natuvchi domenini (Private Email Relay Service) ro‘yxatdan o‘tkazish kerak
  (aks holda bizning OTP/xatlar yetib bormaydi) — Certificates, Identifiers & Profiles → More → Configure.
* Provayder tasdiqlanmagan email qaytarsa (Apple kamdan-kam), Supabase bog‘lamaydi; ilova `email` bo‘lmasa kirishni rad etadi (`server` xato).
* Tavsiya: *Allow manual linking* o‘chiq; admin huquqi faqat `account_roles` orqali (email moslik huquq bermaydi — CLAUDE.md), shuning
  uchun bog‘lash orqali admin huquqini olish mumkin emas.

## 5. Ma’lum cheklovlar

* Google «G» belgisi soddalashtirilgan vektor (`_GoogleGPainter`); store’ga topshirishdan oldin Google brend yo‘riqnomasidagi
  rasmiy «G» aktivi bilan almashtirish tavsiya etiladi (fayl repoga qo‘shilmagan — litsenziya/brend tekshiruvi egasida).
* Mock/HTTP/Offline backend’lar social kirishni soxtalashtirmaydi (`backendNotConfigured`).
* Apple/Google ID token imzosini mijoz tekshirmaydi — Supabase serverda tekshiradi.
* CI (`release-build.yml`) hali `FE_SOCIAL_SIGN_IN`/`GOOGLE_*` define’larini uzatmaydi (secret/variable’lar egasi qo‘shgach workflow’ni
  yangilash kerak; hozircha bayroq o‘chiq → CI o‘zgarishsiz).

## 6. Nima sinalgan / sinalmagan

Sinalgan (avtomatik): nonce SHA-256 (ma’lum vektor), platforma/bayroq qoidalari, Supabase adapteri (mock HTTP: muvaffaqiyat,
xato, 429/5xx/oflayn, yomon token, provayder yoqilmagan), foydalanuvchi bekor qilishi, tugmalar widget testlari (bayroq o‘chiq/yoqiq,
iOS/Android), social akkauntni o‘chirish UI, plist sintaksisi, `tool/ios_static_check.py`.

**SINALMAGAN:** real Google/Apple native oyna, real token → Supabase almashuvi, Apple birinchi-kirish ismi, Xcode’da entitlement/imzo,
`flutter build ios/apk` (bu muhitda macOS/Android SDK yo‘q), TestFlight, real qurilmada ko‘rinish. Linux desktop’da native kirish ishlamaydi.
