# Apple App Review Guidelines yangilanishi — audit (2026-10-17)

Faqat audit: kod, kontent, migratsiya va build o'zgartirilmadi; commit qilinmadi.

## Cheklovlar (ochiq aytiladi)

- **App Store Connect'ga kirilmadi.** ASC'da hozir nima kiritilgani (age rating javoblari, privacy labels, Notes for review) **tekshirilmadi**. Faqat repodagi hujjatlar (`docs/APP_STORE_CONNECT_PROMPT.md`) o'qildi.
- **Real iOS qurilmada hech narsa sinalmadi.** Ilova ishga tushirilmadi, faqat kod va hujjatlar o'qildi.
- **Apple matni:** `developer.apple.com/app-store/review/guidelines/` o'qildi, lekin sahifa matni 114 428 belgidan faqat dastlabki 100 000 belgisi o'qildi. 1.2, 1.2.1, 2.3.14, 2.5.19, 3.1.1(a), 4.8, 5.1.1(v) va 5-bo'lim kirishi shu qismda bor edi. 5.2.5 dan keyingi qism **tekshirilmadi**. Quyida faqat o'sha sahifadagi qisqa iqtiboslar keltirilgan. Apple xatidagi quyidagi tafsilotlarni sahifada **tekshirib bo'lmadi**: 1.2 da "safeguards'ni joriy qilmaslik Developer Code of Conduct buzilishi" jumlasi va "ogohlantirishdan keyin tuzatmaslik" bandi; 5-bo'limdagi aniq jumla ("facilitate human trafficking and/or the exploitation of children") esa topildi.
- `docs/07_POLICY_COMPLIANCE.md` Apple matnining "Last Updated: June 8, 2026" nusxasiga tayanadi; yangi versiya bilan solishtirilmadi.

---

## (A) Xulosa jadvali

| Band | Holat | Nima qilish |
|---|---|---|
| 1.2 UGC — filtr | **RISK** | Faqat "ish materiali" (maxfiylik) filtri bor. Haqorat/zo'ravonlik/spam filtri yo'q. |
| 1.2 UGC — report | **OK** (kod), **RISK** (javob muddati) | Report bor. "Timely response" uchun SLA va bildirishnoma hujjatlashtirilmagan. |
| 1.2 UGC — foydalanuvchini bloklash | **KERAK TUZATISH** | Foydalanuvchini bloklash funksiyasi yo'q. |
| 1.2 UGC — aloqa ma'lumoti | **RISK** | Q&A ekranlarida ko'rinadigan aloqa yo'q (faqat privacy.html va Profil'da). |
| 1.2 UGC — EULA/qoidalar | **RISK** | Qoidalar ekrani bor, lekin yozishdan oldin rozilik (accept) talab qilinmaydi. Terms of Use matni QORALAMA. |
| UGC faqat test buildda mi | **OK, lekin shartli** | FE_QA standart o'chiq. Public buildga tushmasligi uchun CI'da to'siq (guard) yo'q. Admin uchun bayroqsiz ham ko'rinadi. |
| 2.5.19 yashirin/dormant | **RISK** | Sabab: bayroqlar bilan yashirilgan kod bor (Q&A, Publications, ABY, yopiq katalog, admin panel). Review notes'da hujjatlashtirish kerak. |
| Review notes | **KERAK TUZATISH** | Namuna matn bor, lekin 2.5.19 bo'yicha yashirin bo'limlar va auth tavsifi noto'g'ri/to'liq emas. |
| 3.1.1 IAP | **OK** | To'lov qatlami ilovadan olib tashlandi (qaror 2026-10-17): IAP, obuna, paywall, restore, Pro yorliqlari yo'q; hamma funksiya bepul va ochiq. Quyidagi 3-bo'limdagi tafsilotlar olib tashlashdan OLDINGI holat uchun yozilgan (tarixiy). |
| 3.1.1(a) entitlement | **OK** (kerak emas) | Tashqi to'lov havolasi yo'q, entitlement kerak emas. |
| 2.3.14 creative assets | **RISK** | ASC prompt va metadata fayllari bir-biriga mos emas. FIXTURE belgili skrinshotlar bor. Skrinshot o'lchami yetishmaydi. |
| 5 — odam savdosi / bolalar | **OK** | Ilova bunday narsaga yordam bermaydi. Sud-tibbiy ta'limiy kontent. |
| 1.1 / 1.4 zararli kontent | **RISK (past)** | Jinsiy jinoyat ekspertizasi mavzusi bor. Kontent ogohlantirishi va age rating asosi hujjatlashtirilishi kerak. |
| Age rating | **RISK** | Javoblar `APP_STORE_CONNECT_PROMPT.md` da bor, lekin UGC va yangi savollar (2025–26 anketasi) hisobga olinmagan. |
| 5.1.1(v) account deletion | **OK** (kod) | Ilovada bor. |
| 4.8 login | **OK** | Faqat o'zining email+parol tizimi. Uchinchi tomon login yo'q. |
| 5.1.1 / 5.1.2 privacy | **RISK (past)** | Privacy manifest va ASC prompt'dagi privacy labels farq qiladi (User ID, Product Interaction, Other User Content). |
| 3.1.2 (obuna metama'lumoti) | **RISK** | Terms of Use hali QORALAMA (RG-05). Obuna ilovalarida kerak. |

---

## (B) Har band bo'yicha dalillar

### 1. Guideline 1.2 — User-Generated Content

Apple matni (qisqa): "such apps must include: A method for filtering objectionable material from being posted to the app; A mechanism to report offensive content and timely responses to concerns; The ability to block abusive users from the service; Published contact information so users can easily reach you."

Ilovada UGC: "Savol-javob (Hamjamiyat)". Har qanday kirgan foydalanuvchi savol berishi mumkin, javob/ovoz faqat tasdiqlangan mutaxassis uchun (`docs/QA_COMMUNITY.md` jadval 1-bo'lim).

| Talab | Holat | Dalil |
|---|---|---|
| (a) Filtr | **RISK** | `private.qa_privacy_flags()` ish/ekspertiza raqami, identifikator, sana, "Familiya I.O." topadi va postni `moderation` holatiga tushiradi (`supabase/migrations/20261011000000_qa_community.sql:190-212`). Bu **maxfiylik** filtri. Haqorat, jinsiy, zo'ravonlik, spam uchun so'zlar ro'yxati yoki AI-filtr topilmadi. Rasm/fayl yuklash sxemada yo'q (`QA_COMMUNITY.md` 1-bo'lim), bu IP/NCII xavfini kamaytiradi. |
| (b) Report | **OK** | Har savol va javobda "Shikoyat" tugmasi: `apps/mobile/lib/features/qa/presentation/qa_question_screen.dart:84-98, 193-197, 219, 347-350`. Server: `qa_report`, 3 xil foydalanuvchi shikoyati postni yashiradi (migratsiya `:495-520`, `QA_COMMUNITY.md`). Kunlik limit 10. |
| Tezkor javob | **RISK** | Admin moderatsiya ekrani bor (`qa_moderation_screen.dart`, `qa_admin_queue`/`qa_moderate`: publish/remove/pin/reinstate/suspend, `private.admin_guard()` + audit log). Lekin shikoyatga javob muddati (masalan 24 soat) hech qayerda hujjatlashtirilmagan, shikoyat qiluvchiga natija haqida xabar yo'q. |
| (c) Bloklash | **KERAK TUZATISH** | `grep` bo'yicha `lib/features/qa`, `lib/domain/qa`, `lib/data/remote/supabase_qa.dart` va QA migratsiyalarida "block user" yo'q. Mavjud: post darajasida yashirish va mutaxassis belgisini `suspend` qilish (`:599-602`). Bu "abusive userni bloklash" emas. Boshqa foydalanuvchi postlarini o'zim uchun yashirish (mute) ham yo'q. |
| (d) Aloqa | **RISK** | Email `davlatsudekspert@gmail.com` privacy.html'da (`docs/legal/privacy.html:50,129,151,231`) va Profil'dagi support (`profile_screen.dart:367`, murojaat yuborish; faqat backend ulangan bo'lsa). Q&A ekranlarida (`qa_rules_screen.dart`, `qa_feed_screen.dart`) aloqa havolasi/email topilmadi. |
| (e) EULA/qoidalar | **RISK** | Qoidalar ekrani bor: `qa_rules_screen.dart`, matn `app_uz.arb:2575-2595` (taqiqlar 6 band, ijro bo'limi). Yozishdan oldin qabul qilish (checkbox) topilmadi: `qa_ask_screen.dart:101-104` faqat "Qoidalarni ochish" tugmasi. Terms of Use: `legal_screens.dart:18-31` QORALAMA, `l.disclaimerBody` bilan to'ldirilgan (RG-05 ochiq). Apple talab qiladigan "zero tolerance for objectionable content / abusive users" iborasi qoidalarda aniq yozilmagan. |

**UGC faqat test buildda mi:**
- `FeFlags.qaCommunity = bool.fromEnvironment('FE_QA')` standart `false` (`apps/mobile/lib/core/flags.dart:41`).
- Ko'rinish sharti: server ulangan + kirgan + (`FE_QA` **yoki admin**) (`apps/mobile/lib/app/qa.dart:20-25`). Hub plitkasi: `library_screen.dart:439`.
- CI: `FE_QA=true` faqat qo'lda ishga tushirilgan workflow input `qa_community` bilan (`.github/workflows/release-build.yml:22, 62, 107, 224, 256`). Input tavsifida "TEST DISTRIBUTION ONLY — never for a public release build" yozilgan.
- `docs/APP_STORE_CONNECT_PROMPT.md:55` ham Q&A "faqat sinov build'ida" deydi.
- Xulosa: public buildda standart holda foydalanuvchi ko'rmaydi. Lekin (1) kod va RPC binar/serverda mavjud, (2) admin bayroqsiz ko'radi, (3) TestFlight workflow'i `qa_community=true` bilan chiqarilsa, App Review'ga yuboriladigan build ham UGC bilan chiqishi mumkin: bunga to'siq yo'q. **TestFlight tashqi (external) tester** guruhi ham App Review (beta review) dan o'tadi, shuning uchun FE_QA=true build tashqi testerlarga berilsa 1.2 talablari amal qiladi.

### 2. Guideline 2.5.19 — yashirin/dormant/hujjatlanmagan funksiyalar

Apple matni (qisqa): "Don't include any hidden, dormant, or undocumented features in your app; your app's functionality should be clear to end users and App Review. Attempting to hide undocumented features in your app binary, such as through code obfuscation or other methods, is grounds for removal..."

Kodda topilgan bayroqlar/yashirin yo'llar:

| Narsa | Dalil | Apple nuqtai nazaridan |
|---|---|---|
| Q&A (`FE_QA`) | `flags.dart:41`, `qa.dart:20-25` | Binar ichida, review hisobi ko'rmaydi. **RISK**: notes'da ko'rsatish kerak. |
| Ekspert maqolalari (`FE_PUBLICATIONS`) | `flags.dart:35`, `routes.dart:77-82` | Xuddi shunday; admin uchun ko'rinadi. **RISK**. |
| ABY kontenti (`kShowAbyContent=false`) | `apps/mobile/lib/core/aby_flag.dart:5`; ma'lumot bundle ichida qolgan (fayl izohi: "ma'lumotlar o'chirilmaydi, bundle o'zgarmaydi") | Kompilyatsiya-vaqti o'chirilgan kontent, lekin ma'lumot binarda. **RISK**. ABY — litsenziyali manba, binarda yashirin kontent bo'lishi 2.5.19 va litsenziya nuqtai nazaridan ham e'tiborga loyiq. |
| "Yopiq katalog" admin kartasi | `guidelines_screens.dart:112-115` (`isAdmin && abyContentEnabled`), `practice_catalog_screen.dart:20-60`, `guidelines.dart:32` | Hozir `abyContentEnabled=false` bo'lgani uchun hech kimga ko'rinmaydi: kod "dormant". Faylni admin qurilmaga import qiladi (JSON), serverga ketmaydi. **RISK (past-o'rta)**: "hujjatlanmagan funksiya" sifatida talqin qilinishi mumkin. |
| Admin panel | `docs/ADMIN_PANEL.md`; faqat server roli (`account_roles`, `private.has_role`) | Rol server tomonida: reviewer admin bo'lmaydi, panelni ko'rmaydi. Bu o'zi aldov emas, lekin Apple "reviewer ko'rmaydigan funksiya"ni notes'da talab qiladi. **RISK**. |
| Obfuskatsiya | Release workflow'da `--obfuscate` ishlatilmagan (`.github/workflows/release-build.yml:95-110, 247-260`) | **OK**. |
| Boshqa bayroqlar | `FE_TEST_FIXTURES`, `FE_CONTENT_CHANNEL`, `FE_REQUIRE_SERVER_PURCHASE_VERIFICATION`, `FE_AI_REMOTE`, `FE_AUTH_MODE`, `FE_REFERRAL_BASE_URL` (`flags.dart`, `bootstrap.dart:183`, `supabase_ai_provider.dart:35`) | Odatda build-time konfiguratsiya, yashirin funksiya emas. `FE_AUTH_MODE` va `FE_TEST_FIXTURES` mock yo'llarini ochadi: public buildda ishlatilmasligini tekshirish kerak. |
| `kFloatingNav` | `lib/` ichida `grep` bilan **topilmadi** | Tekshirilmadi: nomi boshqacha bo'lishi mumkin. |
| Deep link `forensicexpert://app/invite/<CODE>` | `ios/Runner/Info.plist:12`, `referral_models.dart` | Hujjatlangan (REFERRALS.md). **OK**. |

Review notes bor-yo'qligi:
- Bor: `docs/APP_STORE_CONNECT_PROMPT.md` bo'lim 5 (Notes matni). `FINAL_RELEASE_CHECKLIST.md`, `STORE_RELEASE.md` ham App Review'ni eslatadi, lekin notes matni faqat o'sha faylda.
- Muammolar: (1) Q&A, Publications, admin panel, ABY/yopiq katalog haqida **hech narsa yozilmagan**; (2) "Signing in ... uses a one-time code" deyilgan, lekin kodda email+**parol** bilan kirish va emailni tasdiqlash bor (`auth_screens.dart:375, 402`, `ForgotPasswordScreen:666`, hisob o'chirishda "joriy parol" `:354`): tavsif noaniq bo'lishi mumkin, tekshirib to'g'rilang; (3) "demo account kerak emas" mantiqi to'g'ri faqat agar Pro/Q&A/referral ko'rib chiqilmasa. Pro obuna paywall'i login talab qilsa, review uchun demo hisob berish kerak bo'lishi mumkin (3.1.1 sinovi uchun sandbox xarid ham).

### 3. Guideline 3.1.1 / to'lov

> **Yangilanish (2026-10-17, branch `claude/no-paywall`):** to'lov qatlami ilovadan olib tashlandi. `paywall_screen.dart`, `subscription_ui.dart`, `in_app_purchase_client.dart` o'chirildi; `in_app_purchase*` paketlari pubspec'dan olib tashlandi; Profil'dagi Obuna/Restore qatorlari, bepul-demo chegaralari, qulf belgilari, admin 'Pro berish' bo'limi va referral kredit matni olib tashlandi. Domen/port kodi (`billing_ports.dart`, `product_tiers.dart`, `store_entitlement_service.dart`, `http_purchase_verifier.dart`) UI'dan ajratilgan holda qoldi. Quyidagi bandlar tarixiy.

Apple matni (qisqa): "If you want to unlock features or functionality ... (subscriptions ... access to premium content ...), you must use in-app purchase." 3.1.1(a): "Developers may apply for entitlements to provide a link in their app to a permitted destination ... These entitlements are not required ... in their United States storefront apps." Music Streaming Services Entitlement endi StoreKit External Purchase Link Entitlements bandi ichida.

- Mahsulotlar: `fe_student_pro_monthly/yearly`, `fe_professional_pro_monthly/yearly` (`apps/mobile/lib/domain/ports/billing_ports.dart:140-143`, `docs/STORE_PRODUCT_SETUP.md:13-20`). `fe_lifetime_unlock` ishlatilmaydi.
- Restore: `paywall_screen.dart:56-63,121-124`, `profile_screen.dart:244-256`, `in_app_purchase_client.dart:96` (`restorePurchases`). **OK**.
- Narx faqat store metadata'sidan, store yo'q bo'lsa tugmalar o'chiq (`paywall_screen.dart:24-25, 256-270`). **OK**.
- Obunani boshqarish: `https://apps.apple.com/account/subscriptions` (`subscription_ui.dart:51`). Bu Apple'ning o'z havolasi. **OK**.
- Tashqi to'lov: `launchUrl` chaqiruvlari (`guidelines_screens.dart:551`, `source_detail_screen.dart:210`, `legal_screens.dart:63`, `subscription_ui.dart:72`, `court_prep_widgets.dart:467`, `research_screens.dart:470`) manbalar/PubMed/privacy/obuna boshqaruviga olib boradi; to'lov sahifasiga olib boradigan havola topilmadi.
- Referral: mukofotlar "ichki promo-kredit, naqd emas", `rewards_enabled=false` (`docs/REFERRALS.md:28, 43-50`). Referral kreditni qanday sarflash (Pro'ni App Store'dan tashqarida ochish?) hali aniqlanmagan: kredit orqali Pro ochilsa, bu 3.1.1 bilan (o'z mexanizmi bilan kontent ochish) **to'qnashishi mumkin**. Hozir o'chiq, shuning uchun **RISK (kelajak)**.
- Admin Pro berish (`ServerAccess.tier`, `admin_models.dart:25-35, 122`): hisobga qo'lda bepul kirish. Bu to'lov emas, bepul sovg'a: odatda ruxsat etiladi, lekin notes'da hisob ko'rsatilmasa reviewer'ga ko'rinmaydi.
- StoreKit External Purchase Link Entitlement: **kerak emas**, chunki ilovada tashqi to'lov havolasi/CTA yo'q. Kelajakda veb-to'lov qo'shilsa: AQShdan tashqari storefront'lar uchun entitlement kerak.
- `Info.plist`/entitlements'da external purchase kaliti topilmadi (`grep`), mos.
- `FE_REQUIRE_SERVER_PURCHASE_VERIFICATION` standart `false` (`flags.dart:28`): public buildda `true` bo'lishi RG-18 blocker sifatida yozilgan, buni Apple review bilan bog'liq emas, lekin tekshirib qo'ying.

### 4. Guideline 2.3.14 — creative assets

Apple matni (qisqa): "Creative assets must pertain to your app's content and functionality or overarching brand ... be appropriate for all audiences. They should not include ... unverifiable product claims, or specific or discounted pricing information."

- Metadata manbalari: `docs/APP_STORE_CONNECT_PROMPT.md` (ASC uchun), `docs/store/metadata_{uz,ru,en}.md`, `docs/play_store/listing.md`, `docs/play_store/graphics/`, `docs/screenshots/final/`.
- **Nomuvofiqlik 1:** kategoriya. ASC prompt: Primary "Medical", subtitle "Sourced forensic reference" (`APP_STORE_CONNECT_PROMPT.md:28-29`). `metadata_en.md:4-5`: subtitle "Forensic science reference", kategoriya "Education / Reference (Medical not claimed)". Medical kategoriya Apple'da qo'shimcha e'tibor jalb qiladi (1.4.1 tibbiy ilovalar). Bitta variantni tanlang.
- **Nomuvofiqlik 2:** `APP_STORE_CONNECT_PROMPT.md` description'ni `docs/play_store/listing.md` dan olishni aytadi; metadata_en.md esa boshqa matn ("Most scientific content is still awaiting qualified expert review"). Qaysi biri yakuniy ekani noaniq.
- **Narx/va'da:** `metadata_en.md` "Pricing: Free tier; ... prices shown by the store only" ichki hujjatda, public metadata'da narx yo'q. **OK**. Promotional text "Every statement carries its source and the exact page" (`APP_STORE_CONNECT_PROMPT.md:~70`) **tekshirib bo'lmaydigan da'vo** (unverifiable claim) sifatida talqin qilinishi mumkin, chunki `FINAL_RELEASE_REPORT.md:5` "HUMAN VERIFIED = 0" deydi; metadata_en'dagi "Most content awaiting review" halol, lekin promo matn uni aytmaydi. **RISK (o'rta)**.
- "Works fully offline; no tracking, no ads" (`metadata_en.md`) bilan ilovaning Supabase/AI/Q&A onlayn funksiyalari mos kelishi kerak: "fully offline" ni "core reference works offline" ga o'zgartirish ma'qul. Privacy matni bilan ham.
- Free vs pullik: ilova Free, obuna IAP (`APP_STORE_CONNECT_PROMPT.md:~46`). Obuna borligi description'da aytilishi kerak (3.1.2). **RISK (past)**.
- **Skrinshotlar:** `docs/screenshots/final/` ichida `fin_13_pending_FIXTURE_uz.png`, `fin_14_verified_FIXTURE_uz.png`, `fin_22_review_FIXTURE_uz.png` nomlari fixture (namunaviy ma'lumot) ekanini bildiradi. App Store'ga yuklanmasligi kerak: haqiqiy ilova holatini ko'rsatmaydi ("verified" ekrani, aslida HUMAN VERIFIED=0). **RISK**. O'lcham: mavjud 1170×2532, ASC 6.9" (1290×2796 yoki 1320×2868) talab qiladi (`APP_STORE_CONNECT_PROMPT.md` bo'lim 6): tayyor emas.
- Skrinshotlarda Q&A yoki admin ekranlari bo'lmasligi kerak (reviewer ko'ra olmaydi): `docs/screenshots/` ichida tekshirilmadi (batafsil ko'rilmadi).
- Ikonka: `docs/play_store/graphics/play-icon-512.png` Play uchun; iOS 1024×1024 ikonka (`ios/Runner/Assets.xcassets`) mazmuni **tekshirilmadi**.

### 5. Guideline 5 (odam savdosi/bolalar), 1.1, 1.4, age rating

Apple matni (qisqa): "in extreme cases, such as apps that are found to facilitate human trafficking and/or the exploitation of children, appropriate authorities will be notified and the apps will be removed from the App Store..."; 1.1.4: "...hookup apps and other apps that may include pornography or be used to facilitate prostitution, or human trafficking and exploitation."

- Ilova sud-tibbiy/sud-kimyoviy ma'lumotnoma. Odam savdosi yoki bolalarni ekspluatatsiya qilishga yordam beradigan funksiya/UGC mavzusi **topilmadi**. Q&A qoidalari zararli maqsadli so'rovlarni taqiqlaydi (`app_uz.arb:2584-2589`: ish materiali, natijani buzish, zarar maqsadida modda, tashxis/doza, spam).
- Kontentda jinsiy jinoyat ekspertizasi mavzulari bor (masalan `apps/mobile/assets/content/guidelines/guidelines_v1.json` ichida "sexual-assault cases", "jinsiy aloqadan keyin ..." kabi analitik statistika/vaqt oynalari). Bu ilmiy-ta'limiy; grafik tasvir yo'q (`docs/07_POLICY_COMPLIANCE.md:106`: "V1 da grafik tasvirlar yo'q"). `content.db` ichi to'liq o'qilmadi, go'dak o'ldirish (infanticide) mavzusining aniq joylashuvi **tekshirilmadi** (`grep` faqat umumiy fayl nomlarini topdi).
- 1.1 / 1.4: `07_POLICY_COMPLIANCE.md:106` ta'lim/tibbiyot istisnosi Apple matnida "ko'rsatilmagan" deb qayd etilgan. Risk past, lekin AI yordamchi (Gemini) bu mavzularda javob berganda zararli ko'rsatma bermasligini review notes'da aytish tavsiya etiladi (notes'da AI manbadan javob beradi, deyilgan).
- Age rating: `APP_STORE_CONNECT_PROMPT.md:34-40` — Medical/Treatment Information: Frequent/Intense; Drug/Alcohol/Tobacco: Infrequent/Mild; qolgani None; "17+ chiqsa shunday qoldiring". Hujjatlashtirilgan, lekin: (1) bu **eskirgan** anketa tuzilishi bo'lishi mumkin: Apple age rating savollari 2025-yilda yangilangan (yangi toifalar, UGC/chat savollari); joriy ASC anketasi bilan solishtirilmadi; (2) Q&A (UGC) yoqilgan build uchun "User-generated content / unrestricted web access" savollariga javob hujjatlashtirilmagan; (3) jinsiy jinoyat ekspertizasi mavzusi uchun mos savol (Sexual Content or Nudity / Mature themes) javobi yozilmagan. Play uchun: `PLAY_CONSOLE_RELEASE.md:83-86` target audience 18+.

### 6. Boshqa bandlar (qisqa)

- **4.8 Login:** Apple matni: faqat "third-party or social login service" ishlatilsa ekvivalent variant kerak; "Another login service is not required if: Your app exclusively uses your company's own account setup and sign-in systems." Ilovada email+parol va email tasdiqlash (`auth_screens.dart:354-402`), Google/Facebook/Apple paketi `pubspec.yaml` da topilmadi. **OK**, Sign in with Apple kerak emas. Eslatma: `docs/00_ARXITEKTURA_REJASI.md:814` "email yoki Sign in with Apple / Google" deydi: agar kelajakda Google qo'shilsa 4.8 amal qiladi.
- **5.1.1(v) hisob o'chirish:** `DeleteAccountScreen` (`auth_screens.dart:859-886`, `profile_screen.dart:189`), privacy.html:121-123. **OK**. Kichik e'tibor: o'chirish "joriy parol" so'raydi (`:354`), parolini unutgan foydalanuvchi uchun yo'l mavjudligini tekshiring; Apple talabi: o'chirish oson topilsin va obuna Apple orqali davom etishi haqida ogohlantirish (`01_EVIDENCE_AUDIT.md` C-04 shuni qayd qilgan, ogohlantirish matni tekshirilmadi).
- **5.1.1 / 5.1.2 privacy:** `ios/Runner/PrivacyInfo.xcprivacy` faqat Email va Purchase History'ni e'lon qiladi (izoh "draft, owner/legal confirmation required"). ASC prompt'da qo'shimcha: User ID, Product Interaction, Other User Content (`APP_STORE_CONNECT_PROMPT.md:50-56`). Q&A yoqilsa "Other User Content" manifestda ham bo'lishi kerak. Manifest va ASC labels bir xil bo'lsin. Tracking yo'q (`NSPrivacyTracking=false`). **RISK (past)**.
- `Info.plist` faqat `NSPhotoLibraryUsageDescription` (profil rasmi) — mos. `ITSAppUsesNonExemptEncryption=false`.
- Privacy policy URL: `https://davlatsudekspert.github.io/forensic-expert-legal/` (`app_info.dart:17`). Ilova ichida Terms of Use QORALAMA (RG-05).

---

## (C) Egasi qo'lda bajarishi kerak bo'lgan ishlar (App Store Connect)

1. **Age Rating:** joriy ASC anketasini qaytadan to'ldiring (eski javoblarga tayanmang). Q&A bilan va Q&A'siz buildlar uchun alohida o'ylang. Jinsiy jinoyat ekspertizasi uchun ta'limiy-tibbiy kontent javobini rostini belgilang. Natija 17+ bo'lsa qoldiring.
2. **Kategoriya:** Medical yoki Education/Reference ni tanlab, `docs/store/metadata_*.md` va ASC prompt'ni bir xil qiling. (Medical tanlansa, "not a medical device, no diagnosis" bayonoti notes'da kerak.)
3. **Privacy labels:** `PrivacyInfo.xcprivacy` bilan bir xil. Q&A public buildga kirsa: User Content → Other User Content (savol/javob matni).
4. **Skrinshotlar:** 6.9" o'lchamda, FIXTURE belgili emas, haqiqiy ma'lumot.
5. **Support URL / aloqa:** ishlaydigan sahifa; UGC bo'lsa Q&A ichida ham ko'rinadigan aloqa.
6. **Terms of Use (EULA):** yuridik tekshiruvdan o'tgan matn (RG-05), obuna tavsifida Terms va Privacy havolasi.
7. **Reviewer uchun hisob:** Pro/Q&A/admin ko'rsatilsa, demo hisob (ochiq maxfiy kalitlarsiz) yarating, sandbox xarid yo'riqnomasi bering.

### Notes for review — namuna (o'zbekcha)

```
Ilova: sud-ekspertlar, sud-tibbiyot va sud-kimyo mutaxassislari/talabalari uchun
manbali ma'lumotnoma va o'quv vositasi. Tibbiy qurilma emas, tashxis yoki davolash
maslahati bermaydi. Birinchi ishga tushirishda ogohlantirish qabul qilinadi.

Hisobsiz: asosiy bo'limlar (moddalar, usullar, reaktivlar, qo'llanmalar,
kalkulyatorlar, qidiruv, o'quv rejimi) login talab qilmaydi.
Hisob (ixtiyoriy): email va parol, email tasdiqlash kodi bilan. Hisobni o'chirish:
Profil -> Hisobni o'chirish.

Obuna: Student Pro / Professional Pro (oylik, yillik) faqat App Store IAP orqali.
Restore: Profil -> "Xaridlarni tiklash". Ilovada tashqi to'lov havolasi yo'q.

Yashirin/cheklangan bo'limlar (hujjatlangan):
- Savol-javob (Hamjamiyat): [bu buildda O'CHIQ / YOQILGAN]. Yoqilgan bo'lsa: filtr,
  shikoyat, bloklash, qoidalar, aloqa email, moderatsiya (administrator) tavsifi.
- Administrator paneli: faqat server roli bor hisoblarga ko'rinadi, oddiy foydalanuvchi
  va reviewer ko'rmaydi. Review hisobida admin huquqi yo'q.
- "Ekspert maqolalari": [bu buildda O'CHIQ].
- ABY materiali: bu buildda foydalanuvchiga ko'rsatilmaydi.

AI yordamchi faqat ilova manbalaridan javob beradi, manbalarni ko'rsatadi va matnni
"AI yaratgan" deb belgilaydi. Kontrol qilinadigan moddalar faqat laboratoriya
identifikatsiyasi nuqtai nazaridan; olish/tayyorlash/iste'mol bo'yicha ko'rsatma yo'q.
Reklama yo'q, kuzatuv yo'q, joylashuv yo'q.
Aloqa: davlatsudekspert@gmail.com
```

### Notes for review — namuna (English)

```
App: a sourced reference and study tool for forensic science, forensic medicine and
forensic chemistry practitioners and students. Not a medical device; no diagnosis or
treatment advice. A disclaimer is accepted on first launch.

No account needed: all core sections (substances, methods, reagents, guidelines,
calculators, search, study mode) open without signing in.
Account (optional): e-mail + password with e-mail verification code. Account deletion:
Profile -> Delete account.

Subscriptions: Student Pro / Professional Pro (monthly, yearly) via App Store in-app
purchase only. Restore: Profile -> Restore purchases. No external purchase links.

Hidden / restricted areas (documented):
- Community Q&A: [OFF in this build / ENABLED]. If enabled: content filter, report
  button, user blocking, community rules, published contact, admin moderation.
- Admin panel: visible only to accounts holding a server-side admin role; not
  available to regular users or to the review account.
- Expert publications: [OFF in this build].
- ABY material: not shown to users in this build.

The AI assistant answers only from the app's own sources, lists them and labels its
output as AI-generated. Controlled substances appear only as analytical identification
data; the app contains no instructions to obtain, make or use any substance.
No ads, no tracking, no location.
Contact: davlatsudekspert@gmail.com
```

(Eslatma: "Sign in required" va demo hisob qarori: login haqiqatan ixtiyoriy bo'lsa belgilamang; Pro yoki Q&A ko'rsatiladigan bo'lsa demo hisob bering. Auth tavsifini oldin real ilovada tekshiring.)

---

## (D) Men (Claude) kodda qilishim mumkin bo'lgan tuzatishlar (ustuvorlik bilan)

Feature-freeze (`CLAUDE.md`) sababli har biri uchun egasining ruxsati kerak. Hajm taxminiy.

| # | Ish | Hajm | Ustuvorlik |
|---|---|---|---|
| 1 | Q&A: foydalanuvchini bloklash (migratsiya `qa_blocks` + RPC + feed filtri + UI tugmasi + l10n uz/ru/en + testlar) | o'rta (1-2 kun) | **Yuqori**, faqat Q&A public bo'lsa; aks holda keyinga |
| 2 | Q&A: yozishdan oldin qoidalarni qabul qilish (EULA checkbox, serverda `accepted_at`), "zero tolerance" iborasi | kichik-o'rta | Yuqori (Q&A public bo'lsa) |
| 3 | Q&A: ko'rinadigan aloqa (rules ekranida va savol sahifasida email/support havolasi) | kichik | Yuqori (Q&A public bo'lsa) |
| 4 | Q&A: haqorat/spam kontent filtri (so'zlar ro'yxati uz/ru/en yoki server tomonida AI-moderatsiya) va shikoyat holati/SLA | o'rta | O'rta |
| 5 | CI to'sig'i: `FE_QA=true` va `FE_TEST_FIXTURES`/`FE_AUTH_MODE` mock rejimi public (production kanal) buildda bo'lsa workflow'ni to'xtatish | kichik | Yuqori |
| 6 | Notes for review va ASC hujjatini yangilash (`APP_STORE_CONNECT_PROMPT.md`: auth tavsifi, yashirin bo'limlar, kategoriya/metadata bir xilligi) | kichik (faqat hujjat) | Yuqori |
| 7 | Metadata mosligi: `docs/store/metadata_*.md` va `listing.md` ni bitta manbaga keltirish, "fully offline" va "every statement carries source" iboralarini aniqlashtirish | kichik (hujjat) | O'rta |
| 8 | Privacy manifest (`PrivacyInfo.xcprivacy`) ni ASC labels bilan moslash (User ID, Product Interaction; Q&A uchun Other User Content) | kichik | O'rta |
| 9 | Yopiq katalog (`RestrictedCatalogEntry`) va ABY kodi: public buildda butunlay kompilyatsiyadan chiqarish yoki hujjatlashtirish; ABY ma'lumotini binardan olib tashlash bahosi | o'rta (egasi qarori kerak) | O'rta |
| 10 | Terms of Use to'liq matni (yuridik matn egasidan) va paywall'da Terms+Privacy havolalari | kichik (matn egasidan) | Yuqori (obuna uchun) |
| 11 | Referral kredit sarfi 3.1.1 bilan to'qnashmasligini tekshirish (kredit orqali Pro ochilmasin) | kichik-o'rta | Past (hozir o'chiq) |
| 12 | Hisob o'chirishda parol so'rash va obuna ogohlantirishini real ilovada tekshirish; parolsiz yo'l | kichik | Past |

---

## (E) Noaniq / tekshirilmagan narsalar

- App Store Connect'dagi haqiqiy holat (age rating javoblari, privacy labels, notes, kategoriya, skrinshotlar): kirib bo'lmadi.
- Real iOS qurilma, TestFlight build, StoreKit sandbox xaridlari, real OTP email: sinalmadi.
- Apple sahifasining oxirgi ~14 000 belgisi (5.2.5 dan keyin) o'qilmadi. Apple xatidagi "Developer Code of Conduct" va "ogohlantirishdan keyin tuzatmaslik" jumlalari sahifada tasdiqlanmadi.
- Apple age rating anketasining joriy savollari (2025-26 yangilanishi) ko'rilmadi.
- `kFloatingNav` bayrog'i repoda topilmadi.
- Auth oqimi: "email+parol" va "OTP" munosabati kodda to'liq kuzatilmadi (`auth_screens.dart` qisman o'qildi). Notes matnini yozishdan oldin real ilovada tekshiring.
- Go'dak o'ldirish va jinsiy jinoyat mavzularining `content.db` ichidagi aniq joylashuvi va matn ohangi o'qilmadi.
- `docs/screenshots/*` ichida Q&A/admin ekranlari bor-yo'qligi ko'rilmadi; iOS 1024 ikonka mazmuni ko'rilmadi.
- Server tomoni (Supabase) production holati (RLS, grantlar) bu auditda qayta tekshirilmadi; `QA_COMMUNITY.md` ga tayanildi.
- Q&A "tezkor javob" uchun amalda moderatsiya navbati kim tomonidan va qancha vaqtda ko'rilishi (jarayon) hujjatda yo'q.
