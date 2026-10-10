# Google Play Console — FORENSIC EXPERT chiqarish tartibi

Holat: **Internal testing** (ichki sinov) uchun tayyorlanmoqda. Production (ochiq)
chiqish alohida qaror bilan — hozircha tavsiya etilmaydi, chunki ilmiy kontentning
katta qismi hali `NEEDS_REVIEW` holatida.

- Paket nomi (applicationId): `uz.forensicexpert.forensic_expert`
- Versiya: `pubspec.yaml` dagi `version:` maydoni (masalan `0.3.0+101`) —
  `+` dan keyingi raqam Play uchun `versionCode`, u **har yuklashda oshishi shart**.

---

## 1. Imzo kaliti (upload key)

Play'ga yuklanadigan `.aab` **upload key** bilan imzolanadi. Google keyin ilovani
o'zining **app signing key**'i bilan qayta imzolaydi (Play App Signing) — shuning
uchun upload kaliti yo'qolsa, Google orqali tiklash mumkin.

Kalit yaratilgan:

- Fayl: `fe-upload.jks` (JKS, RSA 4096, 10000 kun)
- Alias: `fe-upload`
- SHA-256 barmoq izi: `74:19:A1:68:ED:28:3A:D2:2F:D4:BF:41:75:C3:DD:16:21:04:C8:E1:3F:FD:67:3A:DE:FD:8F:96:6E:17:11:C8`

**MUHIM:** kalit fayli va paroli repoga kirmaydi (`.gitignore`da: `*.jks`,
`key.properties`). Ularni parol menejeriga yoki xavfsiz joyga saqlang. Kalit
yo'qolsa, yangi kalit bilan yuklash uchun Google'ga murojaat qilish kerak bo'ladi.

### GitHub Actions uchun (ixtiyoriy, avtomatik build)

Repo → Settings → Secrets and variables → Actions:

| Secret | Qiymati |
|---|---|
| `FE_KEYSTORE_BASE64` | `base64 -w0 fe-upload.jks` natijasi |
| `FE_KEYSTORE_PASSWORD` | keystore paroli |
| `FE_KEY_PASSWORD` | kalit paroli (bu yerda bir xil) |
| `FE_KEY_ALIAS` | `fe-upload` |

---

## 2. Lokal build (bizda bajarilgan usul)

```bash
export PATH=/opt/flutter/bin:$PATH
export ANDROID_HOME=/opt/android-sdk ANDROID_SDK_ROOT=/opt/android-sdk

# apps/mobile/android/key.properties — kalit yo'li va parollar (repoga kirmaydi)
cat > apps/mobile/android/key.properties <<EOF
storePassword=<parol>
keyPassword=<parol>
keyAlias=fe-upload
storeFile=<fe-upload.jks ga to'liq yo'l>
EOF

cd apps/mobile
flutter build appbundle --release --dart-define=FE_AI_REMOTE=true
# natija: build/app/outputs/bundle/release/app-release.aab
```

`--dart-define=FE_AI_REMOTE=true` — AI javoblarini yoqadi (haqiqiy Gemini kaliti
serverda, `ai-answer` edge funksiyasida turadi; ilovada kalit yo'q).

Imzoni tekshirish:

```bash
unzip -p app-release.aab META-INF/MANIFEST.MF | head
# yoki: bundletool validate --bundle=app-release.aab
```

---

## 3. Play Console'da birinchi marta sozlash

1. **Hisob.** https://play.google.com/console — Google Play Developer hisobi
   (bir martalik $25). Tashkilot nomidan ochilsa, D-U-N-S raqami va tashkilot
   hujjatlari so'raladi; shaxs nomidan ochilsa, shaxsni tasdiqlash (ID) kerak.
2. **Create app:** nomi «FORENSIC EXPERT», standart til, App turi — *App*,
   Free/Paid — hozircha *Free* (Pro obunasi ilova ichidagi xarid orqali).
3. **App access:** ilovaning bir qismi hisob bilan ochilishi aytiladi. Google
   tekshiruvchisi uchun **test akkaunt** (email + OTP olish tartibi) yoziladi.
   Bu majburiy — aks holda rad etiladi.
4. **Content rating:** savolnomani to'ldiring. Ilova — professional ma'lumotnoma;
   giyohvand moddalar **ilmiy/ekspertiza konteksti**da tilga olinadi, iste'molga
   da'vat yo'q. Shu izohni «Miscellaneous» bo'limida yozing.
5. **Target audience:** 18+ (professional foydalanuvchilar). Bolalar uchun emas.
6. **Data safety:** quyidagini aniq ko'rsating:
   - yig'iladi: email (autentifikatsiya), professional profil ma'lumotlari,
     yuklangan malaka hujjatlari (maxfiy, faqat tekshiruvchi ko'radi);
   - yig'ilmaydi: joylashuv, kontaktlar, reklama identifikatorlari;
   - shifrlash: transitda TLS; foydalanuvchi akkauntni o'chirishni ilova ichidan
     so'ray oladi (`delete-account` funksiyasi) — bu Play talabi.
7. **Privacy policy URL:** `https://davlatsudekspert.github.io/forensic-expert-legal/`
   (manba: `docs/legal/privacy.html`, `forensic-expert-legal` ochiq repo + GitHub Pages).
   2026-10-10 da tekshirildi: HTTP 200, hisobsiz ochiladi, uz/ru/en.
8. **Ads:** reklama yo'q — «No ads» belgilang.

---

## 4. Internal testing chiqishi

1. **Testing → Internal testing → Create new release.**
2. **App signing:** birinchi chiqishda «Use Google Play app signing» ni
   tanlang (tavsiya). `.aab` ni yuklang — Google upload kalitingizni qabul
   qiladi va o'zining signing kalitini yaratadi.
3. `app-release.aab` ni yuklang.
4. **Release name:** `0.3.0 (101)` kabi; **Release notes** uch tilda (uz/ru/en)
   yozilsin — ilovaning o'zi uch tilli.
5. **Testers:** email ro'yxati yarating (o'zingiz, ustoz, markaz xodimlari).
   Ularga opt-in havolasi yuboriladi.
6. **Review release → Start rollout to Internal testing.**

Internal testing odatda bir necha daqiqadan bir necha soatgacha tekshiriladi.
Testerlar havola orqali Play Store'dan o'rnatadi.

---

## 5. Store listing (do'kon sahifasi)

Uch tilda (uz, ru, en) to'ldiring:

- **Qisqa tavsif** (80 belgigacha) va **to'liq tavsif** (4000 belgigacha).
  Tavsifda **aniq yozing:** ilova ma'lumotnoma va o'quv vositasi; ekspert
  xulosasi o'rnini bosmaydi; moddalar haqidagi ma'lumot sud-ekspertiza
  amaliyoti uchun.
- **Ikonka:** 512×512 PNG.
- **Feature graphic:** 1024×500 PNG.
- **Skrinshotlar:** telefon uchun kamida 2 ta (bizda `docs/qa/` ostida
  real-app QA skrinshotlari bor — ularni ishlatish mumkin).

---

## 6. Rad etish xavflari va ularni oldini olish

| Xavf | Nima qilish |
|---|---|
| Giyohvand moddalar mavzusi | Tavsifda va ilovada professional/ilmiy maqsad aniq yozilgan; retsept va tayyorlash yo'riqnomasi berilmaydi |
| Tibbiy maslahat deb talqin qilinishi | «Bu ekspert xulosasi emas» ogohlantirishlari allaqachon ilovada; tavsifga ham qo'shing |
| Hisob talab qilinishi | App access bo'limida ishlaydigan test akkaunt bering |
| Akkauntni o'chirish | Play talabi — ilovada bor (`delete-account`), Data safety'da ko'rsating |
| Maxfiylik siyosati | Ochiq URL majburiy |

---

## 7. Keyingi chiqishlar

Har safar: `pubspec.yaml` dagi `+N` ni oshiring → `flutter build appbundle` →
Play Console'da yangi release → `.aab` yuklang. Internal testing'dan
Closed/Production'ga «Promote release» orqali o'tkaziladi.

---

## Holat: Internal testing jonli (2026-10-10)

- Versiya **0.3.0**, 10-oktabr 22:30 da ichki testerlar uchun ochildi.
- Testerlar uchun havola:
  `https://play.google.com/apps/internaltest/4699917367893320231`
  Tester havolani telefonida, ro'yxatdagi Google hisobi bilan ochadi →
  «Accept invite» → «Download it on Google Play».
- `.aab` CI orqali avtomatik yuklanadi: workflow `release-build.yml` ni
  `workflow_dispatch` bilan, `play_internal: true` kalitchasi yoqilgan holda
  ishga tushirish kifoya. Qo'lda yuklab olish kerak emas.
- Qolgan ish: **Store listing** — ilova nomi va tavsiflari uch tilda
  (`docs/play_store/listing.md`), ikonka 512×512, feature graphic 1024×500,
  kamida 2 ta telefon skrinshoti. To'ldirilmaguncha ilova do'konda paket
  nomi bilan ko'rinadi.
