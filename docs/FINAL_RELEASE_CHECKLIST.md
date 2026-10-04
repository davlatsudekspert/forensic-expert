# FINAL RELEASE CHECKLIST — FORENSIC EXPERT

Holat: ✅ bajarildi · ⚠️ qisman / cheklov bilan · ⛔ bloklangan (inson / hisob / kalit kerak). Hech bir ⛔ band «bajarildi» deb ko‘rsatilmagan.

## Kod va sifat
- ✅ `flutter analyze --fatal-infos`, `dart analyze --fatal-infos packages` — muammo yo‘q
- ✅ `dart format --set-exit-if-changed` — o‘zgarish yo‘q
- ✅ Ilova testlari: 1002 PASS, 0 FAIL, 1 SKIP (preview skrinshot to‘plami); paketlar: 251 PASS
- ✅ Golden testlar yangilangan va ko‘zdan kechirilgan
- ✅ Yakuniy UI auditi: PHASE 7–11 ekranlari 320 dp, shrift ×2.0, EN/RU/UZ (45 test) — 1 overflow topildi va tuzatildi
- ✅ Hardcoded matn yo‘q (architecture test), ARB parity, rendered-language audit
- ✅ Oflayn rejim (`offline_test.dart`) — tarmoqsiz ishlaydi
- ⚠️ Perf — faqat Linux VM (qurilmada emas, RG-10)
- ⚠️ Impeccable UI/UX auditi — **NOT AVAILABLE** (asbob o‘rnatilmagan; nomi o‘xshash paketlar o‘rnatilmadi)
- ⚠️ Brauzer auditi — qo‘llanmaydi (ilovada web target yo‘q)

## Xavfsizlik
- ✅ gitleaks (to‘liq tarix) — leak yo‘q
- ✅ OSV-scanner (`pubspec.lock`, 132 paket) — zaiflik yo‘q
- ✅ Repozitoriyda keystore, `.p8`, `key.properties`, parol yo‘q
- ✅ Android: `allowBackup=false`, cleartext o‘chiq; iOS PrivacyInfo.xcprivacy
- ✅ Lokal ma’lumotni o‘chirish (Profil)
- ⛔ RG-18 — server tomonida xarid tekshiruvi joylashtirilmagan (faqat mock testlar)

## Ilmiy / huquqiy
- ✅ Production validator: faqat FE008 (review’siz kontent production’ga kira olmaydi) — kutilgan
- ✅ Barcha 497 claim NEEDS_REVIEW, «MA’LUMOT TEKSHIRILMAGAN — EKSPERT TASDIG‘I KERAK»
- ⛔ HUMAN VERIFIED = 0 (RG-19/21/23 — domen reviewerlari)
- ⛔ Legal review (RG-15), tarjima review (RG-11), RG-25 (lab reviewer)

## Android
- ✅ `flutter build appbundle --release`, `flutter build apk --release` (lokal)
- ⛔ Release imzo (RG-20) — upload keystore yo‘q; artefaktlar DEBUG imzoli, store uchun yaroqsiz
- ⛔ Play Console / store mahsulotlari (RG-16) — yuborilmagan

## iOS
- ✅ Loyiha: bundle ID, deployment 15.0, PrivacyInfo, `ITSAppUsesNonExemptEncryption=false`
- ✅ macOS CI (macos-15): `flutter build ios --release --no-codesign` va imzosiz xcarchive — muvaffaqiyatli (run 37239093623)
- ⛔ Imzo / TestFlight — **TESTFLIGHT UPLOAD BLOCKED BY CREDENTIALS** (ASC_KEY_ID, ASC_ISSUER_ID, ASC_PRIVATE_KEY, APPLE_TEAM_ID)
- ⛔ Real qurilma testi (RG-10, RG-24)

## Do‘kon
- ✅ Metadata qoralamalari EN/RU/UZ (`docs/store/`)
- ⛔ Skrinshotlar va listing tasdig‘i, trademark (RG-06), AI backend (RG-22)
- ✅ App Review’ga yuborilmagan, ommaviy release qilinmagan
