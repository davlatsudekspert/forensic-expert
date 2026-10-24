# Store mahsulotlari — 0.4.0 (Pro obunalar), 2026-10-24

Tekshiruvdagi **0.3.1** da IAP yo‘q va u o‘zgarmaydi (egasi qarori 2026-10-17, Apple 2.5.19 / 2.1). Quyidagilar
faqat **0.4.0** (branch `claude/pro-0.4.0`) uchun; shartnoma — `docs/PRO_IMPL_0.4.0.md`, qarorlar —
`docs/PRO_PLAN_2026-10-24.md`. Mahsulotlarni **egasi** yaratadi; kodda narx yo‘q (faqat do‘kondan o‘qiladi).

## Identifikatorlar
* iOS bundle ID: `uz.forensicexpert.app`
* Android applicationId: `uz.forensicexpert.forensic_expert`

## 1. Oltita obuna (iOS va Android — product id bir xil)

Obuna guruhi (App Store Connect): **«FORENSIC EXPERT Pro»**. Reja faqat o‘z rejimini ochadi (student/teacher/expert).

| Reja | Product ID | Davr | Narx (USD) |
|---|---|---|---|
| student | `fe_student_monthly` | 1 oy | 1.49 |
| student | `fe_student_yearly` | 1 yil | 9.99 |
| teacher | `fe_teacher_monthly` | 1 oy | 2.49 |
| teacher | `fe_teacher_yearly` | 1 yil | 24.99 |
| expert | `fe_expert_monthly` | 1 oy | 3.49 |
| expert | `fe_expert_yearly` | 1 yil | 34.99 |

Boshqa mamlakatlar narxlari do‘kon jadvalidan tanlanadi. Product ID **aynan** shunday bo‘lishi shart: server
`^fe_(student|teacher|expert)_(monthly|yearly)$` ni tekshiradi, boshqasini rad etadi.

### App Store Connect
1. **Agreements → Paid Apps Agreement** (bank, soliq) — faol bo‘lishi shart.
2. **Monetization → Subscriptions → guruh «FORENSIC EXPERT Pro»**: yuqoridagi 6 ta Auto-Renewable Subscription.
   Daraja tartibi (upgrade/downgrade): expert > teacher > student (yillik oyligidan yuqori).
3. Har obunaga uz/ru/en nomi va tavsifi, ko‘rsatiladigan nom, review skrinshoti (Pro sahifasi) va Review Notes.
4. **Intro-offer «1 oy bepul»** (egasi qarori): har obunaga *Subscription Prices → Introductory Offers → Free, 1 month*,
   barcha mamlakatlar, faqat yangi obunachilar. Bir Apple ID — bir marta (Apple o‘zi nazorat qiladi).
5. **Sandbox tester**: *Users and Access → Sandbox → Testers* (haqiqiy bo‘lmagan email). Qurilmada *Settings → Developer →
   Sandbox Apple Account*. Tekshiruvchiga ham sandbox akkaunt va qisqa izoh beriladi (xarid, bekor qilish, restore, tugash).
6. **In-App Purchase API kaliti**: *Users and Access → Integrations → In-App Purchase → Generate* → `.p8` fayl
   (bir marta yuklab olinadi), Key ID va Issuer ID. Quyidagi sekretlarga qo‘yiladi.
7. App Privacy: «Purchases / Purchase History» — ilova funksiyasi uchun, foydalanuvchiga bog‘liq, tracking yo‘q.
8. Apple 3.1.2: Pro sahifasida narx, muddat, avto-uzayish, bekor qilish yo‘li, Shartlar va Maxfiylik havolalari ko‘rinadi.

### Google Play Console
1. **Monetize → Products → Subscriptions**: 6 ta obuna, product ID yuqoridagidek; har birida bitta base plan
   (oylik `P1M`, yillik `P1Y`, auto-renewing).
2. Narx — jadvaldagidek (USD), boshqa mamlakatlar avtomatik konvertatsiya.
3. **Offer «1 oy bepul»**: har base plan uchun *Add offer → New customer acquisition → Free trial, 1 month*.
4. **Setup → License testing**: tester Gmail akkauntlari (License testers) va ichki test treki.
5. **API access**: Google Cloud da service account yarating → Play Console *Users and permissions* da shu akkauntga
   ilova uchun «View financial data» va «Manage orders and subscriptions» ruxsati → JSON kalit yuklab oling.
   Google Cloud da *Google Play Android Developer API* yoqilgan bo‘lishi kerak (kuch kirishi 24 soatgacha cho‘zilishi mumkin).
6. Data safety: «Purchase history» — yig‘iladi (ilova funksiyasi uchun).

## 2. Sekretlar — qaysi nom qayerga

Qiymatlar hech qachon repoga, hujjatga yoki logga yozilmaydi.

### Supabase Edge Function sekretlari (`verify-purchase`)
`supabase secrets set NOM=...` yoki Dashboard → Edge Functions → Secrets:

| Nom | Nima |
|---|---|
| `ASC_IAP_KEY_ID` | App Store Connect IAP kalitining Key ID |
| `ASC_IAP_ISSUER_ID` | Issuer ID (UUID) |
| `ASC_IAP_PRIVATE_KEY` | `.p8` fayl matni (BEGIN/END qatorlari bilan; yangi qator o‘rniga `\n` ham bo‘ladi) |
| `APP_BUNDLE_ID` | `uz.forensicexpert.app` (berilmasa shu qiymat) |
| `PLAY_SERVICE_ACCOUNT_JSON` | service account JSON faylining to‘liq matni |
| `ANDROID_PACKAGE` | `uz.forensicexpert.forensic_expert` (berilmasa shu qiymat) |

`SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY` — Supabase o‘zi beradi. Sekretlar yo‘q bo‘lsa funksiya
`{result:'NOT_CONFIGURED'}` qaytaradi va ilova «Do‘kon tekshiruvi hali ulanmagan» deydi (xavfsiz holat).

### GitHub Actions sekretlari
Server sekretlari CI ga **kerak emas** (CI faqat tarmoqsiz testlar). Faqat deploy ishi uchun mavjudlari ishlatiladi:
`SUPABASE_ACCESS_TOKEN`, `SUPABASE_PROJECT_REF`. Store build imzolash sekretlari avvalgidek
(`ANDROID_KEYSTORE_BASE64` va h.k.). Agar deploy workflow'ida function sekretlarini CI orqali o‘rnatish xohlansa —
GitHub sekretlari `ASC_IAP_KEY_ID`, `ASC_IAP_ISSUER_ID`, `ASC_IAP_PRIVATE_KEY`, `PLAY_SERVICE_ACCOUNT_JSON` nomlari bilan
qo‘yiladi va `supabase secrets set` ga uzatiladi.

## 3. Deploy tartibi (egasi tasdig‘i bilan — migratsiya va edge function deploy tasdiq talab qiladi)
1. Migratsiya `supabase/migrations/20261025000000_plans.sql` (additiv; rollback sarlavhada).
2. `supabase functions deploy verify-purchase` (JWT tekshiruvi yoqilgan holda).
3. Sekretlarni qo‘yish (yuqorida), keyin sandbox'da: xarid → `APPLIED`, bekor qilish, restore, tugash.
4. Admin panelda `admin_set_plan` bilan qo‘lda reja berish/olib tashlash sinaladi.

## 4. Eslatmalar
* Sinov: ilovaning o‘zi 30 kunlik sinov bermaydi — asosiy yo‘l do‘kon intro-offer'i; serverdagi `plan_claim_trial`
  qurilma hash'i (sha256) bo‘yicha qo‘shimcha himoya (bir qurilma — bir marta, bir akkaunt — bir marta).
* Bir do‘kon obunasi bir vaqtda faqat bitta akkauntga bog‘lanadi (`LINKED_ELSEWHERE`).
* Hozirgi (0.3.1) ilovada bunday kod yo‘q; qarang `CLAUDE.md` («Pro/pullik funksiyalar»).
