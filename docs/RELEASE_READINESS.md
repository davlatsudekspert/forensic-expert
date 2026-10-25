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
- Android: applicationId `uz.forensicexpert.app`; iOS bundle `uz.forensicexpert.app`; versiya `0.4.0+21` (pubspec).
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
