# Shanba (2026-10-17) ish rejasi — ilovani «Pro» holatga keltirish va xaridlarni ko‘paytirish

> Asos: `docs/GLOBAL_GROWTH_PLAN.md` (bozor va narx), `docs/BACKLOG.md`, shu haftadagi egasi talablari.
> Qoida: ommaviy nashr, pullik xizmat va kalit o‘zgarishi — faqat egasi tasdig‘i bilan.
> Til: avval o‘zbekcha mukammal; RU/EN keyingi hafta; keyin qozoq, tojik, qirg‘iz.

## 0. Shanbagacha tayyor bo‘lishi kerak (men)

| # | Ish | Holat |
|---|---|---|
| 1 | Ikkala kitobdagi (GMT-2024, Toksikologik kimyo) hamma modda va usul — ro‘yxat, so‘ng kiritish | yordamchilar ro‘yxat tuzyapti |
| 2 | «Tahlil» uch qatlam: ABY → kitob → adabiyot | tayyor, push qilingan |
| 3 | Profil rasmi (faqat telefonda) | tayyor, push qilingan |
| 4 | Goldenlar yangilash, to‘liq suite, CI yashil | kitob moddalaridan keyin |
| 5 | Yangi test build (0.3.0+12) | yuqoridagilardan keyin |

## 1. Shanba kuni tartib (soat tartibida)

### 1-blok: hozirgi holatni tekshirish (45 daqiqa)
- Egasining shanbagacha topgan mayda kamchiliklari ro‘yxati → tuzatish (kattalari keyingi haftaga).
- CI yashil, test build TestFlight/Play’da, versiya mosligi.

### 2-blok: «sotib olish yo‘li» ishlashini ta’minlash (eng muhim)
Maqsad: odam paywall’ni ko‘rsa, to‘laydi va Pro ochiladi.
1. RG-18 server tomonida xarid tekshiruvi: holatini ko‘rish (qaysi qismi mock, qaysi biri real). Real xarid sinalmagan — buni ochiq ayting.
2. Do‘konda 4 ta obuna mahsuloti (`fe_student_pro_*`, `fe_professional_pro_*`): egasi bilan narx tanlash (**Qaror 1**, tavsiya: yillik oldindan tanlangan, 7 kunlik sinov faqat yillikda, lifetime yo‘q).
3. Sandbox / license-tester bilan bitta to‘liq sinov: sotib olish → Pro ochilishi → tiklash (restore) → bekor qilish.
4. Apple Small Business Program (15 %) arizasi — egasi qiladi.

### 3-blok: bepul va pullik chegarani to‘g‘rilash (konversiya)
GLOBAL_GROWTH_PLAN tavsiyasi:
- Bepul: hamma moddaning asosiy kartasi, ABY (allaqachon bepul), Henssge/Widmark natijasi, 1 ta casebook ishi. Hozir har bo‘limda atigi 3 ta yozuv ochiq — bu odamni ishontirmaydi.
- Pro: sudda so‘roq tayyorgarligi, tahlil rejasi, casebook eksporti, AI (kvota bilan).
- Paywall joyi: odam qiymatni ko‘rgan lahzada (masalan, «tahlil rejasi» yoki «eksport» bosilganda), kirishda emas.

### 4-blok: ishonch va viral omillar
- «Tasdiqlangan manba» (ABY, ustoz kitoblari) ko‘rinishi to‘g‘ri ishlayaptimi — real ekranlarda ko‘zdan kechirish.
- Taklif (referral) kartasi: ko‘rinishi va matnini tekshirish.
- Profil rasmi + ism: jamoa (Savol-javob) uchun ishonch belgisi.

### 5-blok: AI himoyasi (nashrdan oldin shart)
- `ai-answer` hozir hamma uchun bir xil (soatiga 30 so‘rov). Bepul/Pro kvotasini ajratish — rejasi (edge function deploy egasi tasdig‘i bilan).

## 2. Egasidan kerak bo‘ladigan qarorlar (shanba)
1. Narx zinasi (A/B/C mintaqa) — tavsiya `GLOBAL_GROWTH_PLAN.md` 4-bo‘lim.
2. Bepul chegarani kengaytirishga rozilik (3-blok).
3. Ustoz Pro: 6 qaror + ustozdan dars jadvali.
4. Ikkinchi admin hisob (Pro sovg‘a sinovi uchun).
5. Play do‘kon rasmlari va uz/en matnlari (qo‘lda).
6. 6.9" App Store skrinshotlari (1290×2796) chiqarishga ruxsat.

## 3. Sinalmagan narsalar (shanbada ham ochiq aytiladi)
- Real iOS qurilmada STUDENT / EXPERT / ADMIN qo‘lda sinov.
- Real OTP e-mail, haqiqiy xarid, begona pochtaga Pro berish.
- App Store / Play sahifalari yordamchi tomonidan to‘ldirilgan — men tekshirmaganman.

## 4. Keyingi hafta (shanbadan keyin)
- RU/EN tarjima (yangi kitob yozuvlari), keyin qozoq/tojik/qirg‘iz.
- Maqola va tezislardan GC-MS/LC-MS usullarini hamma moddaga to‘liq qo‘shish.
- Ghiyosov/Iskandarov kitoblarining qolgan boblari (Google Hujjat havolalari kerak).
- Institutsional litsenziya (muassasa) oqimi.
