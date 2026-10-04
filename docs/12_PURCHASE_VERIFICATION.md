# 12 — Lifetime xaridini tekshirish (arxitektura)

## Holat

| Qism | Holat |
|---|---|
| Store xaridi (Non-Consumable / one-time) | ✅ `in_app_purchase` adapteri |
| Lokal holatdan premium ochish | ❌ Mumkin emas (test bilan qoplangan) |
| Har sessiyada store’dan egalikni qayta so‘rash | ✅ Android `queryPurchases`, iOS StoreKit 2 `Transaction.all` |
| Restore Purchases | ✅ |
| Klient → backend kontrakti | ✅ `HttpPurchaseVerifier` (kontrakt testlari) |
| **Backend tekshiruvi** | ⛔ **YO‘Q — RELEASE BLOCKER RG-18** |
| Qaytarilgan / bekor qilingan xaridni aniqlash | ⛔ Backend bilan birga (RG-18) |

## Huquq berish qoidasi

| Store hodisasi | Verifier natijasi | `FE_REQUIRE_SERVER_PURCHASE_VERIFICATION` | Natija |
|---|---|---|---|
| purchased / restored | `verified` | har qanday | Lifetime (`serverVerified`), tranzaksiya yakunlanadi |
| purchased / restored | `rejected` | har qanday | Huquq **yo‘q**, tranzaksiya yakunlanmaydi |
| purchased / restored | `serverNotConfigured` | `false` (dev/QA) | Lifetime (`storeConfirmed`) — **production uchun yetarli emas** |
| purchased / restored | `serverNotConfigured` | `true` (release) | Huquq **yo‘q** |
| purchased / restored | `networkError` (backend bor, tarmoq yo‘q) | har qanday | Vaqtincha `storeConfirmed`, keyingi sessiyada qayta tekshiriladi |
| dalil (token/JWS) yo‘q | — | — | Huquq yo‘q |

Public release uchun: `FE_REQUIRE_SERVER_PURCHASE_VERIFICATION=true` va `FE_PURCHASE_VERIFY_URL=https://…`.

## Kontrakt

`POST {FE_PURCHASE_VERIFY_URL}` (faqat HTTPS):

```json
{"platform": "google_play | app_store", "product_id": "fe_lifetime_unlock",
 "purchase_id": "...", "verification_data": "...", "bundle_id": "..."}
```

Javob: `200 {"status": "verified" | "rejected"}`.
- 4xx → rad etilgan.
- 5xx yoki tarmoq xatosi → `networkError`.

## Backend vazifalari (PHASE 4+, RG-18)

1. **Google Play:**
   - Google Play Developer API `purchases.products.get` orqali tekshiriladi: `purchaseState = 0`, `productId`, `packageName`, refund/void holati.
   - Tasdiqlangach `acknowledge` qilinadi.
   - Bekor qilingan xaridlar Real-time Developer Notifications orqali kuzatiladi.
2. **App Store:**
   - App Store Server API orqali tranzaksiya JWS imzosi va `bundleId` / `productId` tekshiriladi.
   - `revocationDate` hisobga olinadi.
   - App Store Server Notifications V2 (REFUND) kuzatiladi.
3. Maxfiy kalitlar (Play service account, App Store `.p8`) faqat serverda saqlanadi, repozitoriyga tushmaydi.
4. Replay himoyasi: bitta `purchase_id` faqat bitta akkauntga bog‘lanadi. Javob server kaliti bilan imzolanadi (keyingi bosqich).
5. Server dalillarni anonim saqlaydi. Ilmiy qidiruv va foydalanuvchi ma’lumotlari yuborilmaydi.

## Ma’lum cheklovlar (halol)

- iOS’da `Transaction.all` wrapper’i `revocationDate` ni bermaydi. Qaytarilgan xaridni aniqlash faqat backend orqali bo‘ladi.
- Ruxsatsiz o‘zgartirilgan (root/jailbreak, patched) ilova klient tekshiruvini chetlab o‘tishi mumkin. Bunga qarshi himoya — server tekshiruvi va kontentni server bilan bog‘lash (RG-18). Hozirgi holat production-secure **emas**.
