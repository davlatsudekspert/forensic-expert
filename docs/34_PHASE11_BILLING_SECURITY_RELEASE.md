# 34 — PHASE 11: tariflar, xavfsizlik, release tayyorgarligi

> Hech qanday store’ga yuborish, App Review yoki ommaviy release YO‘Q. Imzo kalitlari va App Store Connect sirlari repozitoriyda yo‘q va yaratilmagan.

## Tariflar

| Daraja | Holat | Store mahsuloti |
|---|---|---|
| Free | faol | — |
| Student Pro | rejalashtirilgan | yaratilmagan (RG-16) |
| Professional Pro | faol | `ProductIds.lifetime` (bir martalik) |
| Institution | rejalashtirilgan (shartnoma) | yaratilmagan |

Narx kodda yo‘q — faqat store’dan (`ProductDetails.price`). Rejalashtirilgan daraja xarid qilinmaydi.

## RG-18 — huquq holatlari (server paketi `fe_purchase_verification`)

`EntitlementStateResolver.resolve(transaction, now)` (deterministik):

| Holat | Shart | Kirish |
|---|---|---|
| `active` | Lifetime yoki muddati tugamagan, avtoyangilanuvchi obuna | ha |
| `cancelledActiveUntilExpiry` | bekor qilingan, to‘langan muddat davom etmoqda | ha |
| `gracePeriod` | muddat tugagan, store imtiyozli davri ichida | ha |
| `expired` | muddat va imtiyoz tugagan | yo‘q (`VerificationOutcome.expired`) |
| `revoked` | refund / revoke | yo‘q |

* **Restore:** `PurchaseVerificationService.restore(accountId, platform, {productId: credential})` — har bir xarid store’dan qayta tekshiriladi; boshqa akkauntga bog‘langan xarid berilmaydi (replay).
* **Sandbox:** production konfiguratsiyada rad etiladi (`sandboxNotAllowed`); faqat `allowSandbox: true` staging serverda.
* `EntitlementRecord.activeAt(now)` — muddatli huquq vaqt bo‘yicha tekshiriladi.
* Testlar: paketda jami 12 (yangi obuna holatlari guruhi bilan; barchasi MOCK verifier). **Haqiqiy Apple/Google API bilan tekshirilmagan; backend joylashtirilmagan → RG-18 OCHIQ.**

## Xavfsizlik auditi (2026-10-04)

| Soha | Natija |
|---|---|
| Sirlar | gitleaks (staged + tarix) — topilmadi; repozitoriyda keystore/`.p8`/`key.properties` yo‘q |
| Jurnallar | `debugPrint` faqat `kDebugMode` ostida (content_store, startup metrics); shaxsiy ma’lumot jurnalga yozilmaydi |
| Saqlash | SharedPreferences — faqat sozlamalar va lokal ro‘yxatlar (saqlanganlar, tarix); token/parol yo‘q |
| Tarmoq | `lib/` da `http://` yo‘q; Android `usesCleartextTraffic="false"` |
| Zaxira | Android `allowBackup="false"`, `fullBackupContent="false"` |
| Imzolangan paket | kontent paketi SHA-256 manifest + imzo tekshiruvi (avvalgi fazalar); buzilgan paket rad etiladi |
| Bog‘liqliklar | OSV-scanner `pubspec.lock` — natija release hisobotida |
| AI maxfiyligi | provayder sukut bo‘yicha `none/mock`; so‘rov matni saqlanmaydi; maxfiy ma’lumot detektori (PHASE 9) |
| Debug artefaktlari | release build’da diagnostika ekrani faqat debug/profile |

## Huquqiy va foydalanuvchi ma’lumotlari

* Profil: maxfiylik, shartlar, disklaymer, ochiq kodli litsenziyalar (`showLicensePage`).
* **Yangi:** «Barcha lokal ma’lumotlarni o‘chirish» (`profile.deleteLocalData`) — tasdiqlash dialogi, so‘ng saqlanganlar/tarix/sozlamalar tozalanadi. Server akkaunti hozircha yo‘q (backend RG-18 bilan birga); akkaunt o‘chirish talabi — backend bilan OCHIQ.

## Android

* `applicationId uz.forensicexpert.forensic_expert`, versiya `0.1.0+1`, minSdk 24, target/compile 36.
* Lokal (Linux VM, `flutter clean` dan keyin, 2026-10-04):

| Artefakt | Hajm | SHA-256 |
|---|---|---|
| `build/app/outputs/bundle/release/app-release.aab` | 69 587 401 B (69.6 MB) | `6fcf8185c083df336a6698c0a03fb22ae34b08384ec5c6d4bab2b08d4f2a35f4` |
| `build/app/outputs/flutter-apk/app-release.apk` | 71 606 888 B (71.6 MB) | `26560736dfb88ee72f1a0b48cbeefb6dd30e8e72980f9380d3a86c5bdec99b1d` |

  `apksigner verify --print-certs`: `CN=Android Debug` → **DEBUG imzo (RG-20 ochiq)**, store uchun yaroqsiz. Artefaktlar lokal VM’da; commit qilinmaydi.
* CI: `.github/workflows/release-build.yml` (`android` job). Sirlar `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD` bo‘lsa — release imzo; aks holda artefakt nomi `android-DEBUG-SIGNED-not-for-store-<sha>`.
* Tarqatish: faqat GitHub Actions artefakti (repozitoriyga kirish huquqi bor foydalanuvchilar uchun). Ommaviy URL yaratilmagan.

## iOS

* Bundle `uz.forensicexpert.forensicExpert`, deployment 15.0.
* `PrivacyInfo.xcprivacy` (tracking yo‘q, ma’lumot yig‘ilmaydi, UserDefaults CA92.1) Runner target’ga qo‘shilgan; `ITSAppUsesNonExemptEncryption=false`.
* CI (`ios` job, macos-15): `pod install` → `flutter build ios --release --no-codesign` → `flutter build ipa --release --no-codesign` → **imzosiz** xcarchive artefakti.
* Imzo + TestFlight: faqat qo‘lda (`workflow_dispatch`, `testflight=true`) va barcha sirlar bo‘lsa: `ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_PRIVATE_KEY`, `APPLE_TEAM_ID` (`tool/ios_testflight.sh`; kalit vaqtinchalik katalogda, chop etilmaydi). App Review’ga yuborilmaydi.
* CI natijasi (run 37239093623, commit a937da4): kompilyatsiya ✅, imzosiz xcarchive ✅ (artefakt ID 11316539373).
* Sirlar mavjud emas → **TESTFLIGHT UPLOAD BLOCKED BY CREDENTIALS**.

## Store metadata

`docs/store/metadata_en.md`, `metadata_ru.md`, `metadata_uz.md` — qoralama; yuborilmagan.

## Ochiq

RG-18 (backend), RG-20 (Android upload key), RG-24 (Apple sertifikat/TestFlight), RG-16 (store mahsulotlari), RG-22 (store listing/skrinshotlar tasdig‘i), akkaunt o‘chirish (backend).
