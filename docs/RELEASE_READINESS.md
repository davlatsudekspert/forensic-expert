# RELEASE READINESS (yangilandi: 2026-10-25, versiya 0.4.0+21, branch `claude/pro-0.4.0`)

Mahalliy tekshiruv: `apps/mobile/tool/release_check.py` (22 ta tekshiruv; `--net` bilan
jamoat sahifalarini ham tekshiradi). Bu skript faqat KOD/KONFIG ni tekshiradi —
do‘kon konsollari, imzo kalitlari va real qurilmani tekshira olmaydi.

## Holat

| Kanal | Holat | Izoh |
|---|---|---|
| Android Closed Testing | TAYYOR EMAS (egasi qadamlari kerak) | kod/konfig izchil; release keystore va Play service account mahalliy tekshirilmadi (CI sirlari) |
| iOS TestFlight | TAYYOR EMAS (egasi qadamlari kerak) | kod/konfig izchil; build faqat `release-build.yml` (pullik macOS runner) orqali, ASC sirlari mahalliy tekshirilmadi |
| App Store / Play public release | YO‘Q | egasi ruxsatisiz yuborilmaydi |

## Kod/konfig bo‘yicha tasdiqlanganlar
- Android: applicationId `uz.forensicexpert.forensic_expert`; iOS bundle `uz.forensicexpert.app` (ikkalasi ham o‘zgarmagan); versiya `0.4.0+21` (pubspec).
- iOS deployment target 15.0; Privacy manifest (`PrivacyInfo.xcprivacy`) bor; Sign in with Apple entitlement bor.
- Android ruxsatlar: INTERNET, CAMERA (kamera majburiy emas); cleartext o‘chiq; allowBackup o‘chiq.
- Release imzo: `-PrequireReleaseSigning=true` kalitsiz muvaffaqiyatsiz bo‘ladi (debug imzo bilan store’ga chiqmaydi).

## Ochiq (egasi/do‘kon tomonida) — build’dan oldin majburiy
1. Do‘kon mahsulotlari: `fe_{student,teacher,expert}_{monthly,yearly}` Play Console va App Store Connect’da yaratilgan va narxlangan bo‘lishi; sandbox sinovi (xarid, bekor qilish, restore, tugash).
2. Server tomonida xarid tekshiruvi (`verify-purchase`): do‘kon muhit o‘zgaruvchilari qo‘yilmaguncha `NOT_CONFIGURED` qaytaradi.
3. Maxfiylik siyosati va Foydalanish shartlari: `docs/legal/privacy.html` (13–14-bo‘limlar qo‘shildi) jamoat sahifasiga (alohida GitHub Pages repo) qayta joylanishi; Terms uchun alohida URL yoki Apple standart EULA.
4. Android release keystore (`FE_KEYSTORE_*` yoki `key.properties`), Play service account, App Store Connect API kalitlari — GitHub sirlarida mavjudligi.
5. Play Console “Data safety” va App Store “App Privacy” anketalari `PrivacyInfo.xcprivacy` bilan mos to‘ldirilishi (email, xarid tarixi, qurilma identifikatori).
6. Real qurilma sinovi (`docs/REAL_DEVICE_TEST_CHECKLIST.md`): OTP, xarid, oflayn, kichik ekran, katta shrift — mahalliy muhitda bajarilmagan.
7. Normativ-huquqiy ma’lumotlar (JK moddalari, chegaralar) rasmiy matn bilan to‘liq tekshirilmagan; ilovada «Darslikka ko‘ra» belgisi va rasmiy matn bilan tekshirish eslatmasi bor.

## Yangilanish (2026-10-25, kechqurun): GitHub Actions tarixi bo‘yicha dalillar
- `Release build` #347 (workflow_dispatch, branch `claude/pro-0.4.0`, `7961ef6`, 0.4.0+21): Android AAB yig‘ildi,
  «Verify package, version and signature» o‘tdi, «Upload to Google Play — internal testing (draft)» muvaffaqiyatli;
  iOS «Signed IPA + TestFlight upload» (~5 daq) muvaffaqiyatli. Demak ilova Play Console va App Store Connect’da mavjud,
  release imzo kaliti va Apple sertifikat/ASC sirlari ishlaydi (qiymatlari ko‘rilmadi).
- Bu build `7961ef6` dan: «Bilim va malakani baholash» bo‘limi va og‘zaki javoblar (917) unda YO‘Q — ular faqat
  lokal commitlarda (push qilinmagan). Ularni tarqatish uchun yangi build raqami (+22) va yangi CI build kerak.
- Jamoat maxfiylik sahifasi (`.../forensic-expert-legal/`) mavjud (200), lekin eski: 2026-10-10 versiyasi, Savol-javob (7a),
  obuna/xarid (13) va Foydalanish shartlari (14) bo‘limlari yo‘q. `terms.html` / `privacy.html` yo‘llari 404.

## Lokal Android release build (2026-10-25)
- Android SDK/NDK shu konteynerda o‘rnatildi (`/opt/android-sdk`), `flutter build appbundle --release` muvaffaqiyatli:
  `app-release.aab` 99.5 MB (0.4.0, build 21 — build raqami keyin 22 ga ko‘tarildi), paket `uz.forensicexpert.forensic_expert`,
  ichida `assessment_v1.json` va 3 ta `oral_*.json` bor.
- U **DEBUG kalit bilan imzolangan** (CN=Android Debug) — Play’ga yuklab BO‘LMAYDI. Haqiqiy upload kaliti faqat GitHub
  sirlarida; lokalga olinmadi. Bu build faqat "kod Android’da yig‘iladi" degan dalil.
- Build raqami `0.4.0+22` (pubspec + `AppInfo.build`): +21 allaqachon Play internal (draft) va TestFlight’ga yuklangan,
  do‘konlar bir xil raqamni qabul qilmaydi.
