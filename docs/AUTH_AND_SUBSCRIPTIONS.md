# Akkaunt va obunalar (Release completion)

> Holat: **mijoz (ilova) to‘liq tayyor; production backend ulanmagan.** Release yig‘mada akkaunt ekranlari «akkaunt xizmati hali ulanmagan» deb halol ko‘rsatiladi. MOCK backend faqat testlarda va `--dart-define=FE_AUTH_MODE=mock` bilan qurilgan debug/profile yig‘mada ishlaydi; u haqiqiy xat yubormaydi va ekranda «TEST» banneri bilan belgilanadi.

## 1. Tamoyillar

* **Oflayn birinchi.** Ilmiy ma’lumotnoma, qidiruv, kalkulyatorlar va ogohlantirishlar akkauntsiz ishlaydi. Majburiy kirish devori yo‘q (Apple 5.1.1(v)).
* **Akkaunt ≠ huquq.** Akkaunt — identifikatsiya (email). Huquq (tarif) — store xaridi, server tekshiruvi orqali. Store xaridi akkauntsiz ham ishlaydi; akkaunt faqat bulutdagi huquq/sinxronlash/AI uchun kerak.
* **Minimal ma’lumot.** Faqat email + parol + Shartlar/Maxfiylikni qabul qilish. Kasb, muassasa, ish yoki shaxsiy ma’lumot so‘ralmaydi. Professional maqomni tasdiqlash so‘ralmaydi.
* **Sirlar.** Parol mijozda saqlanmaydi va jurnalga yozilmaydi; refresh token — Keychain (`first_unlock_this_device`) / Android Keystore (`flutter_secure_storage`); access token — faqat xotirada. Kodlar va tokenlar jurnalga yozilmaydi (test: `auth kodida parol/token jurnalga yozilmaydi`).

## 2. Oqimlar

| Oqim | Ilova | Enumeratsiyaga qarshi |
|---|---|---|
| Ro‘yxatdan o‘tish | email (normallashtiriladi: trim + kichik harf), parol (qoidalar ro‘yxati jonli ko‘rsatiladi), tasdiqlash, Shartlar/Maxfiylik belgisi | band email ham `202` oladi; server egasiga «akkauntingiz bor» xatini yuboradi |
| Email tasdiqlash | 6 xonali kod, 24 soat; qayta yuborish (60 s oraliq); xatolar: noto‘g‘ri, muddati o‘tgan, allaqachon tasdiqlangan, oflayn, server | qayta yuborish har doim bir xil javob |
| Kirish | email + parol; tasdiqlanmagan akkaunt → kod ekrani | noto‘g‘ri email va noto‘g‘ri parol — bir xil xato |
| Parolni unutdim | email → kod (30 daqiqa, bir martalik) → yangi parol → barcha sessiyalar bekor | har doim «agar akkaunt bo‘lsa, kod yuborildi» |
| Chiqish | server refresh tokenni bekor qiladi; lokal token o‘chiriladi | — |
| Sessiyani tiklash | birinchi kadrdan keyin refresh; rad etilsa token o‘chadi; tarmoq yo‘q bo‘lsa saqlanadi | — |
| Akkauntni o‘chirish | oqibatlar ro‘yxati, store obunasi bekor bo‘lmasligi haqida ogohlantirish, «tushunaman» belgisi, joriy parol, yakuniy dialog | — |
| Qurilmadagi ma’lumotni o‘chirish | **alohida** amal (saralanganlar, tarix, sozlamalar) | — |

Parol siyosati (`PasswordPolicy`): kamida 10, ko‘pi bilan 128 belgi; kamida bitta harf (har qanday alifbo) va bitta raqam; email yoki uning local qismi bilan bir xil emas.

## 3. Arxitektura

```
UI (features/account, features/profile)
  → AuthRepository (domain port)  ←  OfflineAuthRepository   (standart: ulanmagan)
                                   ←  HttpAuthRepository      (FE_AUTH_BASE_URL=https://…)
                                   ←  MockAuthRepository      (testlar; FE_AUTH_MODE=mock, release’da emas)
  → SessionStore                  ←  SecureSessionStore (Keychain/Keystore) | InMemorySessionStore (test)
  → authStateProvider (Notifier — ko‘rinmas ekran pauzasida ham holat yo‘qolmaydi)
```

### Backend REST kontrakti (`HttpAuthRepository`)

| Metod va yo‘l | Tana | Javob |
|---|---|---|
| `POST v1/auth/register` | `email, password, accepted_terms_version` | `202 {}` (har doim) |
| `POST v1/auth/verify-email` | `email, code` | `200 {access_token, refresh_token, user:{id,email,email_verified}}` |
| `POST v1/auth/verify-email/resend` | `email` | `202 {}` (har doim) |
| `POST v1/auth/login` | `email, password` | `200` sessiya / `401 invalid_credentials` / `403 email_not_verified` |
| `POST v1/auth/password/forgot` | `email` | `202 {}` (har doim) |
| `POST v1/auth/password/reset` | `email, code, new_password` | `204`; barcha sessiyalar bekor |
| `POST v1/auth/session/refresh` | `refresh_token` | `200` sessiya / `401` |
| `POST v1/auth/logout` | `refresh_token` | `204` |
| `DELETE v1/account` | `password` (+ Bearer) | `204` — akkaunt, sessiyalar, sinxron ma’lumot, huquq yozuvlari o‘chiriladi |

Xato tanasi: `{"error": "invalid_email" | "weak_password" | "terms_not_accepted" | "invalid_credentials" | "email_not_verified" | "code_invalid" | "code_expired" | "already_verified" | "requires_recent_login"}`; `429` — juda ko‘p urinish; `5xx` — server. Server matni foydalanuvchiga ko‘rsatilmaydi.

Server talablari: parol — Argon2id (yoki bcrypt ≥ 12); kodlar — kriptografik tasodifiy, xeshlangan holda saqlanadi, bir martalik; IP/email bo‘yicha rate limit; tokenlar jurnalga yozilmaydi; email yetkazish — transactional provayder (SPF/DKIM/DMARC).

## 4. Tariflar va huquqlar

| Tarif | Kimga | Imkoniyat (`FeatureGate`) |
|---|---|---|
| Free | hamma, akkauntsiz | oflayn baza, xavfsizlik va manbalar (doim to‘liq), qidiruv va ma’lumotnoma demo, oddiy kalkulyatorlar |
| Student Pro | talaba / rezident | to‘liq ma’lumotnoma, barcha kurslar, testlar, kartochkalar, imtihon, cheklanmagan qidiruv |
| Professional Pro | mutaxassis | Student Pro + professional kalkulyatorlar va laboratoriya vositalari, analitik metodlar, tadqiqot/dalillar vositalari, professional AI (AI xizmati ulanganda) |
| Institution | shartnoma | arxitekturada bor; paywall’da **ko‘rsatilmaydi** |

Xavfsizlik ogohlantirishlari, cheklovlar va provenance hech qachon to‘lov ortida emas (`ProductFeature.safetyAndProvenance` → Free).

**Yagona huquq modeli** — `Entitlements {tier, status, source, verification, productId, expiresAt}`; `effectiveTier` faqat tasdiqlangan (store yoki server) va kirish beradigan holatda pullik tarifni qaytaradi. Lokal `isPro` bayrog‘i yo‘q (test bilan tekshiriladi).

| Holat | Kirish |
|---|---|
| `active` | ha |
| `gracePeriod` | ha (to‘lov muammosi, store imtiyozli davri) |
| `cancelledActiveUntilExpiry` | ha (muddat oxirigacha) |
| `billingRetry` | yo‘q (Apple billing retry / Google account hold) |
| `expired`, `revoked`, `unknown` | yo‘q |

## 5. Store integratsiyasi (ilova)

* `InAppPurchaseStoreClient` (`in_app_purchase` 3.x: StoreKit 2 / Play Billing 7): mahsulotlarni yuklash, narx/valyuta/davr store metadata’sidan (App Store `subscriptionPeriod`, Google Play base plan `billingPeriod`), xarid, restore, store egaligini jim qayta so‘rash, `completePurchase` (Google acknowledge).
* `StoreEntitlementService`: pending / bekor / xato / muddati o‘tgan iOS tranzaksiyasi / server holatlari; bir nechta obuna — eng yuqori tarif.
* Server tekshiruvi: `HttpPurchaseVerifier` (`FE_PURCHASE_VERIFY_URL=https://…`, akkaunt tokeni `Authorization` sarlavhasida); javob: `status`, `entitlement_status`, `expires_at`. Server sozlanmagan va `FE_REQUIRE_SERVER_PURCHASE_VERIFICATION` false bo‘lsa — store tasdig‘i bilan (`storeConfirmed`, diagnostikada «release blocker» deb ko‘rsatiladi). Public release: `true` + ishlaydigan backend.
* Restore Purchases: paywall va Profil’da. «Obunani boshqarish»: iOS `apps.apple.com/account/subscriptions`, Android `play.google.com/store/account/subscriptions?package=…&sku=…`.
* Paywall’da Apple/Google talab qiladigan avtomatik yangilanish matni, Shartlar va Maxfiylik havolalari.

## 6. Server tomonida tekshirish (RG-18) — `packages/fe_purchase_verification`

APPLE / GOOGLE → `PurchaseVerificationService` → normallashtirilgan `AccountEntitlement` → akkaunt → mijoz javobi (`toClientJson`).

* Fail-closed qoidalari: ruxsat etilgan mahsulot, ilova identifikatori, production’da sandbox rad, refund/revoke, **replay** (bitta tranzaksiya — bitta akkaunt, atomik), **idempotentlik**, store javob bermasa huquq yo‘q.
* Obuna hayot sikli: `EntitlementStateResolver` (+ billing retry); Apple App Store Server Notifications V2 (`SUBSCRIBED`, `DID_RENEW`, `DID_CHANGE_RENEWAL_STATUS`, `DID_FAIL_TO_RENEW` [GRACE_PERIOD], `GRACE_PERIOD_EXPIRED`, `EXPIRED`, `REFUND`, `REVOKE`); Google RTDN (`RECOVERED`, `RENEWED`, `CANCELED`, `PURCHASED`, `ON_HOLD`, `IN_GRACE_PERIOD`, `RESTARTED`, `REVOKED`, `EXPIRED`) va Voided Purchases.
* `revoked` — yakuniy; boshqa o‘tishlar store hodisalaridan.
* Audit: har holat o‘zgarishi `EntitlementAuditEntry` (vaqt, platforma, `sha256(platform:originalTransactionId)` ning 16 belgisi, eski→yangi holat, sabab) — credential/token/JWS yozilmaydi.
* Mock’lar production’da taqiqlangan (`assertNoMocksInProduction`).
* **Testlar mock verifier bilan — haqiqiy Apple/Google API bilan tekshirilmagan. RG-18 OCHIQ.**

## 7. Egasi tomonidan qilinishi kerak (tashqi konfiguratsiya)

1. **Akkaunt backend’i**: yuqoridagi REST kontraktini joylashtirish (HTTPS), parol xeshlash, rate limit, akkauntni o‘chirish (sinxron ma’lumot va huquq yozuvlari bilan), transactional email provayderi (domen, SPF/DKIM/DMARC). So‘ng yig‘ma: `--dart-define=FE_AUTH_BASE_URL=https://…`.
2. **Xarid tekshiruvi backend’i**: `fe_purchase_verification` ni HTTP xizmat sifatida joylashtirish; Apple App Store Server API kaliti (Issuer ID, Key ID, `.p8`), App Store Server Notifications V2 URL; Google Play service account (`androidpublisher`), RTDN Pub/Sub (OIDC push), Voided Purchases; tranzaksion DB (`(platform, original_transaction_id)` noyob indeksi, audit jadvali). So‘ng: `--dart-define=FE_PURCHASE_VERIFY_URL=https://…` va `FE_REQUIRE_SERVER_PURCHASE_VERIFICATION=true`.
3. Store mahsulotlari — `STORE_PRODUCT_SETUP.md`.
4. Maxfiylik siyosati va Shartlar matnini yuridik tasdiqlash (RG-05) va `acceptedTermsVersion` ni yangilash.
