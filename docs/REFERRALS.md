# FORENSIC EXPERT — hamkasb taklifi (referral) va FORENSIC Credits

Holat: **production’ga DEPLOY QILINDI** (2026-10-06, loyiha
`igvzlmpgwybjdgkyowrl`). Real E2E (2 ta akkaunt) — `docs/PRODUCTION_CLOSEOUT.md`.

## 1. Oqim

```
A: Profil → «Hamkasbingizni taklif qiling» → kod (serverda yaratiladi)
   → tizim share sheet’i (kontaktlarga ruxsat so‘ralmaydi)
B: havola/kod → ilova (deep link `forensicexpert://app/invite/<CODE>`
   yoki Profil → Taklif kodi) → kod LOKAL saqlanadi
B: email OTP orqali akkaunt ochadi (email tasdiqlanadi)
   → ilova `claim_referral(code)` ni BIR MARTA chaqiradi
Server: tekshiruvlar → referrals (VALID yoki PENDING_VERIFICATION)
```

Ommaviy veb-havola (`https://<domen>/invite/<CODE>`) faqat
`FE_REFERRAL_BASE_URL` (HTTPS) berilganda ko‘rsatiladi. Domen egaligi
tasdiqlanmagan — shuning uchun kodga domen yozilmagan; hozir kod ulashiladi.
Domen ulangach: `assetlinks.json` / `apple-app-site-association` va
AndroidManifest’ga `autoVerify` intent-filter qo‘shiladi.

## 2. Ma’lumotlar bazasi (`supabase/migrations/20261006030000_referrals.sql`)

| Jadval | Maqsad | Mijoz kirishi |
|---|---|---|
| `referral_config` | foiz (standart 10 %), valyuta, `rewards_enabled` (false), oyna, limitlar | yo‘q (RLS, siyosatsiz) |
| `referral_codes` | 1 akkaunt = 1 kod, UNIQUE | yo‘q |
| `referrals` | referrer → referred, `UNIQUE(referred_id)`, `CHECK(referrer<>referred)`, o‘zgarmas (trigger) | yo‘q |
| `referral_rewards` | `reward_type, reward_percent, purchase_amount_minor, reward_amount_minor, currency, status, source_transaction UNIQUE, referrer_id, referred_user_id, created_at` | yo‘q |
| `private.account_email_history` | tuzli email hash (o‘chirib qayta ochish suiiste’molini to‘sish) | yo‘q (ochiq sxemada emas) |
| `private.referral_audit` | har urinish va mukofot | yo‘q |

RPC: `referral_dashboard()` (faqat o‘z agregatlari, kod birinchi so‘rovda
yaratiladi), `claim_referral(code)` — `authenticated`.
`award_referral_reward(buyer, tx, amount_minor, currency)` va
`set_referral_reward_status(tx, status)` — **faqat `service_role`**
(serverdagi xarid tekshiruvi; mijoz chaqira olmaydi).

## 3. 10 % FORENSIC Credits arxitekturasi

* Ro‘yxatdan o‘tish uchun mukofot **yo‘q**.
* Taklif qilingan foydalanuvchining **server tomonidan tasdiqlangan** mos
  xaridi → `floor(amount × reward_percent / 100)` kredit, `PENDING`.
  Qaytarish muddatidan keyin `APPROVED`; refund/chargeback → `REVERSED`.
* Foiz `referral_config` da — ilovani yangilamasdan o‘zgartiriladi
  (0–50 % chegarasi bilan).
* Kreditlar ichki promo-bonus, **naqd pul emas**; pullik xizmatlar ishga
  tushmaguncha `rewards_enabled = false` va UI buni ochiq aytadi.

## 4. Tahdid modeli

| Tahdid | Himoya |
|---|---|
| O‘z-o‘zini taklif | `owner = me` → `SELF_REFERRAL`; `CHECK(referrer<>referred)` |
| Ikkinchi referrer / takror | `UNIQUE(referred_id)`, `ON CONFLICT DO NOTHING` |
| Eski akkauntni bog‘lash | faqat `attribution_window_days` (14) ichida ochilgan akkaunt |
| O‘chirib qayta ochish | tuzli email hash tarixi → `NOT_ELIGIBLE` |
| A↔B aylana | teskari juftlik bor bo‘lsa rad |
| Kod taxmin qilish | soatiga 10 urinish (audit asosida) |
| Ko‘p akkaunt fermasi | referrer uchun kunlik limit (20), email tasdig‘i talab |
| Mijoz mukofot yozishi | RLS siyosatsiz + privilegiyalar olib tashlangan; award faqat `service_role` |
| Soxta xarid | award faqat server xarid tekshiruvidan keyin (service role) |
| Xarid qayta yuborilishi / ikki marta mukofot | `UNIQUE(source_transaction)` → `DUPLICATE` |
| Nol/manfiy/noto‘g‘ri summa | `INVALID`, `CHECK(purchase_amount_minor > 0)` |
| Attribution’ni o‘zgartirish | trigger: referrer/referred/kod o‘zgarmas |
| Maxfiylik | panel faqat sonlar; email/ism/profil/hujjat hech qachon qaytarilmaydi; kontakt ruxsati yo‘q |

Akkaunt o‘chirilsa: referrer’ning kodi va kreditlari o‘chadi (cascade);
taklif qilingan foydalanuvchining attribution qatori o‘chadi, berilgan
kreditda uning ID’si `NULL` bo‘ladi; faqat tuzli email hash qoladi
(suiiste’molga qarshi, maxfiylik siyosatida ko‘rsatiladi).

## 5. Testlar

* `supabase/tests/referral_test.sql` (PostgreSQL 16, `bash supabase/tests/run_local.sh`):
  noyob kod, VALID/PENDING, self, takror, bitta referrer, aylana, eski va
  qayta ochilgan akkaunt, urinish limiti, kunlik limit, RLS, mijoz mukofot
  yozishi/chaqirishi/konfiguratsiyani o‘zgartirishi, o‘zgarmaslik, anon,
  10 % hisob, idempotentlik, nol/manfiy/valyuta, tasdiqlanmagan referral,
  sozlanadigan foiz (15 %), APPROVED/REVERSED o‘tishlari, audit, akkaunt
  o‘chirish.
* `apps/mobile/test/unit/referral_test.dart`, `test/widget/referral_test.dart`.

## 6. Deploy (connector tiklangach)

1. `apply_migration` → `20261006030000_referrals.sql` (mavjud loyiha
   `igvzlmpgwybjdgkyowrl`; yangi loyiha yaratilmaydi).
2. `get_advisors` (security) — yangi ogohlantirish yo‘qligini tekshirish.
3. Smoke: kirgan akkaunt bilan `rpc/referral_dashboard` → kod qaytadi.
4. Ixtiyoriy: ommaviy domen tayyor bo‘lsa `FE_REFERRAL_BASE_URL` bilan build.
5. Pullik xizmatlar ishga tushganda: server xarid tekshiruvi
   `award_referral_reward` ni chaqiradi, so‘ng
   `update referral_config set rewards_enabled = true`.
