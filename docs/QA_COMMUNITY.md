# «Savol-javob (Hamjamiyat)» — server qismi

Holat: **QA-1 (DB) va QA-2 (Edge Function) bajarildi.** Flutter qatlami
(QA-3) va l10n/testlar (QA-4) keyingi bosqichda. Bo'lim ilovada server
ulanmaguncha **ko'rinmaydi** — ulanmagan funksiya ishlayotgandek
ko'rsatilmaydi.

Egasining shartlari qanday bajarilgani quyida.

## 1. Ma'lumotlar bazasi (migratsiya `20261011000000_qa_community.sql`)

7 jadval: `qa_profiles`, `qa_rate`, `qa_questions`, `qa_answers`,
`qa_votes`, `qa_reports`, `qa_translations`. Hammasida **RLS yoniq va
hech qanday policy yo'q**, `anon`/`authenticated` uchun DML grant yo'q —
ya'ni jadvallarga to'g'ridan-to'g'ri murojaat qilib bo'lmaydi. Hamma ish
`SECURITY DEFINER ... set search_path = ''` funksiyalari orqali.

Ilova chaqiradigan RPC'lar (faqat `authenticated`):
`qa_status`, `qa_feed`, `qa_question`, `qa_my`, `qa_translation`,
`qa_ask`, `qa_answer`, `qa_vote`, `qa_accept`, `qa_report`,
`qa_admin_queue`, `qa_moderate` (oxirgi ikkitasi ichida
`private.admin_guard()` bor).

Qoidalar serverda:

| Qoida | Qanday bajarilgan |
| --- | --- |
| Faqat tasdiqlangan mutaxassis javob yozadi va ovoz beradi | `private.qa_is_expert()`, `qa_answer`/`qa_vote` ichida |
| Savol egasi eng yaxshi javobni belgilaydi | `qa_accept` — faqat muallif |
| Admin pin/olib tashlash | `qa_moderate`, `private.admin_guard()` + audit log |
| 3 xil foydalanuvchi shikoyati | `qa_report` — post yashiriladi yoki belgi to'xtatiladi, `QA_AUTO_HIDDEN` audit yozuvi |
| Maxfiylik filtri | `private.qa_privacy_flags()` — ish/ekspertiza raqami, ism, sana+joy birikmasi topilsa post `moderation` holatiga tushadi |
| Kunlik limitlar | savol 5, javob 20, ovoz 100, shikoyat 10, hujjat tekshiruvi 3, tarjima 200 |
| Postda rasm yo'q | sxemada rasm/fayl/yo'l ustuni umuman yo'q (SQL test buni tekshiradi) |

## 2. Edge Function'lar (migratsiya `20261011010000_qa_service_api.sql`)

PostgREST faqat `public` sxemasini ochadi, shuning uchun server funksiyalari
uchun `public.qa_service_*` yupqa wrapper'lar qo'shildi — **faqat
`service_role`ga** berilgan (`anon` va `authenticated` uchun yo'q).
Productionda tekshirildi: oltitasining ham `anon=false, authenticated=false,
service_role=true`.

### `qa-verify-expert` (hujjat bo'yicha avtomatik tekshiruv)

* So'rov: `{ role, country, mime, data (base64), lang }` — imzolangan
  foydalanuvchi.
* Javob: `{ status, reason, attempts_today }`.
* **Fayl saqlanmaydi.** Hujjat faqat so'rov davomida xotirada bo'ladi:
  bazaga, storage'ga va logga tushmaydi. Saqlanadi: foydalanuvchi ID, rol,
  mamlakat, status, qisqa mashina sababi (`document_ok`,
  `not_a_credential`, `unreadable`, `role_mismatch`, `low_confidence`,
  `expired`), sana. Diplom raqami va to'liq ism yozilmaydi — model
  prompt'ida ham «hujjatdagi matnni ko'chirma» deb qat'iy aytilgan, va
  javobdan faqat beshta maydon o'qiladi.
* Foydalanuvchi o'zini tasdiqlay olmaydi: verdikt `service_role` kaliti
  bilan yoziladi, foydalanuvchi ID esa uning JWT'sidan olinadi.
* Kuniga 3 urinish; urinish **model chaqirilishidan oldin** hisoblanadi.
* Model javob bermasa, foydalanuvchiga tushunarsiz rad javob yozilmaydi
  (`502`, status o'zgarmaydi).
* Talqin ehtiyotkor: shubha bo'lsa rad etiladi. Laborator hujjati
  `lab_technician` roliga yetadi, lekin shifokor/kimyogar da'vosi hujjatga
  mos kelishi kerak.

### `qa-translate` (serverdagi mashina tarjimasi)

* So'rov: `{ target_type, target_id, lang }`.
* Kalit ilovaga joylanmaydi: birlamchi dvigatel **Cloudflare Workers AI**
  (`CF_ACCOUNT_ID` + `CF_API_TOKEN`, model `@cf/meta/m2m100-1.2b`),
  zaxirasi Gemini. Ikkisi ham Edge Function secret'i.
* Har (post, til) uchun bir marta tarjima qilinadi va `qa_translations`da
  keshlanadi; ilova «Mashina tarjimasi» belgisi va «Asl matn» bilan
  ko'rsatadi (`engine` ustuni qaysi dvigatel yozganini saqlaydi).
* Faqat `published` post va faqat sarlavha/matn tarjimaga yuboriladi —
  muallif ID, email va boshqa shaxsiy ma'lumot chiqmaydi.
* Raqam, birlik, formula, modda nomi, cutoff, usul qisqartmalari prompt
  darajasida o'zgarmas deb belgilangan.
* Post allaqachon shu tilda bo'lsa tarjima qilinmaydi.

### Egasining belgisi

`private.qa_seed_manual_expert(email, rol, mamlakat)` — idempotent,
`service_role` uchun ochilgan wrapper orqali. Email faqat `auth.users`da
qidirish uchun argument; hech qayerda saqlanmaydi. Productionda bir marta
ishga tushirildi: `role=forensic_physician`, `country=UZ`,
`status=verified`, `reason=manual_check`, `manual=true`. Keyingi avtomatik
tekshiruv `manual` belgisini o'chirmaydi (SQL test bor). Rolni
`forensic_chemist`ga o'zgartirish kerak bo'lsa — bir qatorlik ish.

**AI egasining nomidan post yoki javob yozmaydi.** Hech bir server
funksiyasi muallif ID'sini tashqaridan qabul qilmaydi: muallif har doim
`auth.uid()`, ya'ni haqiqiy imzolangan foydalanuvchi.

## 3. Nima sinaldi (raqamlar bilan)

* Lokal SQL to'plami (`supabase/tests/run_local.sh`, bir martalik
  PostgreSQL 16): **1200 tasdiq, 0 xato** — ichida yangi
  `qa_service_api_test.sql` (grantlar, 3 urinish limiti, verdikt yozilishi,
  manual seed idempotentligi, tarjima keshi, kunlik hisoblagich).
* Deno unit testlari (AI mock, tarmoq yo'q, baza yo'q): **24 test, 0 xato**
  (`supabase/functions/qa-verify-expert/verify_test.ts` — 12,
  `supabase/functions/qa-translate/translate_test.ts` — 12). Ichida
  «verdikt hujjat matnini olib o'tmaydi» testi ham bor.
* `deno check` — 5 ta Edge Function toza.
* Production: migratsiya qo'llandi, grantlar so'rov bilan tasdiqlandi,
  xavfsizlik advisor'ida **yangi ERROR yo'q** (`qa_service_*` funksiyalari
  `anon`/`authenticated` ro'yxatlarida ko'rinmaydi).
* Ikki funksiya deploy qilindi va imzosiz so'rov bilan sinaldi: ikkisi ham
  `401 UNAUTHORIZED_NO_AUTH_HEADER`.

Sinalmagani (ochiq aytiladi): real hujjat bilan vision tekshiruvi va
Cloudflare tarjimasi hali **haqiqiy so'rov bilan sinalmadi** — Cloudflare
secret'lari kiritilgandan keyin va ilova qatlami tayyor bo'lganda
sinaladi. Haqiqiy foydalanuvchilarga hech qanday sinov xabari yuborilmadi.

## 4. Mendan kerak bo'ladigan narsa

1. **Cloudflare**: `CF_ACCOUNT_ID` va `CF_API_TOKEN` (Workers AI o'qish
   huquqi). Ularsiz tarjima Gemini zaxirasi bilan ishlaydi.
2. Egasining Q&A rolini tasdiqlash: `forensic_physician` (hozir) yoki
   `forensic_chemist`.
