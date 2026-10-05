# Store mahsulotlarini sozlash (egasi uchun)

> Narxlar **belgilanmagan** — ularni egasi store konsolida tanlaydi; ilova narx, valyuta va davrni faqat store’dan oladi. Hech narsa yuborilmagan.

## Identifikatorlar (loyiha konvensiyasi)

* iOS bundle ID: `uz.forensicexpert.forensicExpert`
* Android applicationId: `uz.forensicexpert.forensic_expert`
* Mahsulot ID konvensiyasi: `fe_` prefiksi + snake_case (avvalgi `fe_lifetime_unlock` bilan bir xil uslub). Kodda: `ProductIds` (`apps/mobile/lib/domain/ports/billing_ports.dart`) — **store’dagi ID’lar aynan shunday bo‘lishi shart**.

| Product ID | Tarif | Davr |
|---|---|---|
| `fe_student_pro_monthly` | Student Pro | 1 oy |
| `fe_student_pro_yearly` | Student Pro | 1 yil |
| `fe_professional_pro_monthly` | Professional Pro | 1 oy |
| `fe_professional_pro_yearly` | Professional Pro | 1 yil |

Institution — store mahsuloti yo‘q (shartnoma asosida, server huquqi `institution`).

`fe_lifetime_unlock` (avvalgi model) endi ishlatilmaydi va store’da yaratilmagan; uni yaratmang.

## App Store Connect

1. **Apps → + New App**: platforma iOS, bundle ID `uz.forensicexpert.forensicExpert` (avval Certificates, Identifiers & Profiles’da App ID yaratiladi; In-App Purchase capability App ID’da standart yoqilgan).
2. **Agreements, Tax, and Banking**: Paid Apps Agreement faol bo‘lishi shart (busiz mahsulotlar store’da chiqmaydi).
3. **Subscriptions → Subscription Groups → +**: bitta guruh, masalan «FORENSIC EXPERT». Bitta guruhda bo‘lishi upgrade/downgrade’ni to‘g‘ri ishlatadi.
4. Guruhda 4 ta auto-renewable subscription — yuqoridagi ID’lar bilan. Darajalar (Subscription Levels): Professional Pro (yillik, oylik) — yuqori daraja; Student Pro (yillik, oylik) — pastroq.
5. Har biriga: Duration (1 Month / 1 Year), narx (egasi tanlaydi; mamlakatlar bo‘yicha), EN/RU/UZ display name va description (tavsifda ilova ichidagi imkoniyatlar ro‘yxati bilan mos), Review screenshot (paywall).
6. **Billing Grace Period** yoqish tavsiya etiladi (ilova grace’ni qo‘llab-quvvatlaydi).
7. **App Store Server Notifications V2**: Production va Sandbox URL — xarid tekshiruvi backend’i (RG-18).
8. **Users and Access → Integrations → In-App Purchase / App Store Connect API**: server uchun In-App Purchase kaliti (Issuer ID, Key ID, `.p8`) — faqat server sirlarida.
9. Sandbox tester akkauntlari (Users and Access → Sandbox).
10. TestFlight uchun alohida App Store Connect API kaliti (Developer roli) — `ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_PRIVATE_KEY` + `APPLE_TEAM_ID` GitHub Secrets’ga (`docs/34_…`).

## Google Play Console

1. **Create app**: package name `uz.forensicexpert.forensic_expert`. Birinchi AAB’ni (release imzo bilan, RG-20) Internal testing’ga yuklash kerak — busiz mahsulot yaratib bo‘lmaydi.
2. **Payments profile** (merchant) faol bo‘lishi shart.
3. **Monetize → Products → Subscriptions → Create subscription** — 4 ta subscription, product ID yuqoridagidek. Har birida **bitta auto-renewing base plan** (masalan `monthly` / `yearly`), Billing period P1M / P1Y, narx — egasi tanlaydi, mamlakatlar bo‘yicha. Ilova shu base plan’ning `billingPeriod` ini ko‘rsatadi.
4. Grace period (masalan 7 kun) va Account hold yoqish tavsiya etiladi — ilova `gracePeriod` va `billingRetry` holatlarini qo‘llaydi.
5. EN/RU/UZ nom va tavsif.
6. **Monetization setup → Real-time developer notifications**: Pub/Sub topic (`google-play-developer-notifications@system.gserviceaccount.com` ga publish huquqi) → push subscription backend’ga (OIDC autentifikatsiyasi).
7. **Setup → API access**: service account (`androidpublisher`), Financial data / Manage orders ruxsatlari — faqat server sirlarida.
8. License testing akkauntlari.

## Ilova tomoni (allaqachon tayyor)

* `ProductIds.all`, tarif xaritasi `ProductIds.tierOf`, paywall’da Institution ko‘rinmaydi.
* Narx kodda yo‘q (test: `narx UI va domen kodida yozilmagan`).
* Server konfiguratsiyasi `VerificationConfig.productTiers` ilovadagi xarita bilan bir xil bo‘lishi kerak:
  `{fe_student_pro_monthly: student_pro, fe_student_pro_yearly: student_pro, fe_professional_pro_monthly: professional_pro, fe_professional_pro_yearly: professional_pro}`.
