# Store mahsulotlari — holat: IAP YO‘Q (2026-10-17)

Egasi qarori (2026-10-17; Apple 2.5.19 va 2.1): ilovada **ilova ichidagi xaridlar, obunalar, tariflar, to‘lov
tugmalari va paywall yo‘q**. Hamma funksiya bepul va ochiq. Shu sababli store konsollarida **hech qanday mahsulot
yaratilmaydi**.

## Identifikatorlar

* iOS bundle ID: `uz.forensicexpert.app`
* Android applicationId: `uz.forensicexpert.forensic_expert`

## App Store Connect

1. **Apps → + New App**: platforma iOS, bundle ID `uz.forensicexpert.app`.
2. **Pricing and Availability**: Free.
3. **In-App Purchases / Subscriptions**: bo‘sh qoldiriladi (hech narsa yaratilmaydi). «Paid Apps Agreement» talab qilinmaydi.
4. **App Privacy**: tracking yo‘q; xarid ma’lumotlari yig‘ilmaydi (`ios/Runner/PrivacyInfo.xcprivacy` shuni aytadi).

## Google Play Console

1. **Pricing**: Free. «Contains in-app purchases» — **No**.
2. **Monetize → Products** (Subscriptions / In-app products): bo‘sh qoldiriladi.
3. Data safety: «Purchase history» yig‘ilmaydi.

## Kelajak

To‘lovli funksiya faqat alohida, to‘liq ishlaydigan yangi versiya sifatida (do‘kon mahsulotlari, sandbox sinovi,
server tekshiruvi, «Restore purchases», narx/muddat/bekor qilish yo‘li ekranda, tekshiruvchiga sandbox akkaunt va
izoh) qaytariladi — qarang `CLAUDE.md` («Pro/pullik funksiyalar»). Hozirgi ilovada bunday kod yo‘q.
