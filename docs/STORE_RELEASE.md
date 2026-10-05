# Store release: Google Play (internal testing) va TestFlight

> Holat (commit `5f8d856`, versiya **0.2.0 (2)**): store imzosi va store API sirlari repozitoriyda **sozlanmagan**. Shuning uchun hech narsa store’ga yuklanmagan. Debug imzoli APK va imzosiz iOS arxivi store’ga **yuborilmaydi**.

## Identifikatorlar

| | Android | iOS |
|---|---|---|
| ID | `uz.forensicexpert.forensic_expert` | `uz.forensicexpert.forensicExpert` |
| Versiya | 0.2.0 | 0.2.0 |
| Build | versionCode **2** (`pubspec.yaml`) | CI’da `GITHUB_RUN_NUMBER` (har doim o‘sadi) |

**Diqqat (RG-09):** bu ID’lar vaqtinchalik deb belgilangan. Play’da package name birinchi yuklashdan keyin **o‘zgarmaydi**. Agar Play Console / App Store Connect’da FORENSIC EXPERT allaqachon boshqa ID bilan ro‘yxatdan o‘tgan bo‘lsa, birinchi yuklashdan oldin shu ID’ni loyihaga qo‘yish kerak — aks holda ikkinchi ilova paydo bo‘ladi.

## Kerakli GitHub Secrets (egasi qo‘shadi; hech qachon commit qilinmaydi)

**Android release imzosi:** `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD` (Play App Signing’dagi *upload key*).

**Google Play API:** `PLAY_SERVICE_ACCOUNT_JSON` — Play Console → Users and permissions’da **faqat FORENSIC EXPERT ilovasiga** release huquqi berilgan service account (NFCSTORE / BugunBor’ga huquq bermang).

**App Store Connect:** `ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_PRIVATE_KEY` (.p8 matni, App Manager roli), `APPLE_TEAM_ID`. App Store Connect’da `uz.forensicexpert.forensicExpert` uchun ilova yozuvi bo‘lishi shart.

## Ishga tushirish

GitHub → Actions → **Release build** → *Run workflow*:
* `play_internal = true` → release imzoli `forensic-expert-release.aab`. Workflow avval imzo, package ID va versiyani tekshiradi (debug imzo yoki boshqa package bo‘lsa to‘xtaydi), keyin **Internal testing** track’iga **draft** sifatida yuklaydi. Production’ga hech qachon yuklamaydi; draft’ni Play Console’da egasi o‘zi chiqaradi.
* `testflight = true` → avtomatik imzolangan `forensic-expert-testflight.ipa`. Workflow quyidagilarni tekshiradi, keyin TestFlight’ga yuklaydi (App Review’ga yuborilmaydi):
  * bundle ID;
  * Apple Distribution sertifikati;
  * App Store provisioning profile (`get-task-allow = false`);
  * `altool --validate-app`.

**Muhim (Google cheklovi):** butunlay yangi Play ilovasiga *birinchi* AAB’ni API orqali yuklab bo‘lmaydi. Birinchi release Play Console’da qo‘lda yuklanadi; keyingilarini workflow avtomatik yuklaydi.

## Egasi javob berishi kerak bo‘lgan savollar (taxmin qilinmaydi)

1. **Play Data safety formasi.** Hozirgi build qurilmadan hech narsa yubormaydi: akkaunt, tasdiqlash va taqriz serverlari ulanmagan; analitika va reklama yo‘q. Ular ulanganda email, xarid tarixi, profil va malaka hujjatlari yig‘iladi. Qaysi holat bo‘yicha deklaratsiya qilinadi?
2. **App Store App Privacy** javoblari va `PrivacyInfo.xcprivacy` (qoralama: email, xarid tarixi) — tasdiqlash yoki o‘zgartirish.
3. **Eksport muvofiqligi.** Kod tahlili:
   * HTTPS (TLS);
   * kontent paketining Ed25519 imzosini tekshirish;
   * SHA-256 yaxlitlik tekshiruvi;
   * maxfiylik uchun shifrlash yo‘q.

   Shu asosda `ITSAppUsesNonExemptEncryption = false` qo‘yilgan. App Store Connect’dagi savolga ham shunday javob berishni egasi tasdiqlaydi.
4. **Play Console majburiy bo‘limlari:**
   * Content rating so‘rovnomasi;
   * Target audience (bolalar emas);
   * Privacy policy URL (ochiq sahifa kerak);
   * App access (hisob talab qilinmaydi);
   * Ads (yo‘q);
   * kategoriya.
5. Yakuniy package/bundle ID (RG-09) va mavjud store yozuvlari.

## Do‘kon matni

`docs/store/metadata_{en,ru,uz}.md`. Ilova quyidagicha tavsiflanadi:
* professional sud-ekspert ma’lumotnomasi;
* ilmiy ta’lim;
* ilmiy hisob-kitob vositasi.

Tibbiy da’vo yo‘q. Ogohlantirish: «Forensic Expert is intended for professional reference, education and scientific calculation. It does not replace validated laboratory procedures, institutional protocols, applicable law or qualified professional judgment.» «Needs review» materiallar tasdiqlangan deb ko‘rsatilmaydi. **HUMAN VERIFIED = 0.**
