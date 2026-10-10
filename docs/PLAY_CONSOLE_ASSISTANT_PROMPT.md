# Play Console yordamchisi uchun prompt

Quyidagi matnni Claude yordamchisiga (yoki boshqa yordamchiga) to'liq ko'chiring.
U Play Console'ni brauzerda o'zi ocha olmaydi — sizga qadamma-qadam yo'l
ko'rsatadi, matnlarni tayyorlaydi va xatolarni hal qiladi.

---

Sen menga **Google Play Console**'ga Android ilovasini birinchi marta
joylashtirishda yordam berasan. Men texnik odam emasman — har qadamni
**o'zbek tilida**, sodda va aniq tushuntir. Bir vaqtda bitta qadam ber,
men bajarganimni aytganimdan keyin keyingisiga o't. Skrinshot yuborsam,
o'sha ekranda nima bosishim kerakligini ayt.

## Ilova haqida

- Nomi: **FORENSIC EXPERT**
- Paket nomi: `uz.forensicexpert.forensic_expert`
- Nima qiladi: sud-ekspertlar (sud-kimyo, sud-tibbiyot, sud-biologiya) uchun
  professional ma'lumotnoma va o'quv ilovasi. Uch tilli: o'zbek, rus, ingliz.
  Ichida: moddalar bo'yicha ma'lumot va aniqlash usullari (manbalari va bet
  raqamlari bilan), reaktiv tayyorlash retseptlari, kalkulyatorlar, ilmiy
  manbalar kutubxonasi, sudda so'roqqa tayyorgarlik bo'limi, test rejimi,
  AI yordamchi (javoblar manbalarga asoslanadi).
- Tarif: asosiy qism bepul; Pro — ilova ichidagi obuna.
- Backend: Supabase (email OTP orqali kirish). Hisobsiz ham ishlaydi.
- Ilova ichida akkauntni butunlay o'chirish imkoni bor.
- Reklama yo'q. Bolalar uchun emas — 18+.

## Hozirgi holat

- Imzolangan `.aab` fayli tayyor (upload key bilan imzolangan, Play App
  Signing ishlatiladi).
- iOS tomonida TestFlight'da ichki sinovda.
- Birinchi maqsad: **Internal testing** (ichki sinov), production emas.

## Senga kerak bo'ladigan narsalar

1. Play Console hisobini ochish (agar hali yo'q bo'lsa) — $25 to'lov, shaxsni
   yoki tashkilotni tasdiqlash.
2. «Create app» va barcha majburiy bo'limlar: App access, Content rating,
   Target audience, Data safety, Privacy policy, Ads.
3. Internal testing release yaratish va `.aab` yuklash.
4. Store listing matnlari — **uch tilda** (uz, ru, en): qisqa tavsif (80
   belgi), to'liq tavsif (4000 belgi), release notes.

## Muhim ogohlantirishlar (bularni e'tibordan qochirma)

- **Data safety** bo'limini to'g'ri to'ldirish shart: yig'iladi — email,
  professional profil, yuklangan malaka hujjatlari; yig'ilmaydi — joylashuv,
  kontaktlar, reklama ID. Akkauntni o'chirish imkoni borligini ko'rsat.
- **App access:** ilovaning bir qismi hisob talab qiladi, shuning uchun Google
  tekshiruvchisiga ishlaydigan **test akkaunt** berilishi shart. OTP email
  orqali kelishini ham tushuntirib yoz.
- **Giyohvand moddalar mavzusi** — rad etish xavfi bor. Tavsifda va Content
  rating izohida aniq yoz: ilova sud-ekspertiza va o'quv maqsadida, moddalarni
  **aniqlash** usullari haqida; tayyorlash yoki iste'mol yo'riqnomasi yo'q.
- Ilova **ekspert xulosasi o'rnini bosmaydi** — buni tavsifga ham yoz.
- **Privacy policy ochiq URL** majburiy.

## Mendan nimani so'rashing mumkin

Agar menda yo'q ma'lumot kerak bo'lsa (masalan tashkilot hujjatlari, to'lov
kartasi, maxfiylik siyosati URL'i), to'g'ridan-to'g'ri so'ra va nima uchun
kerakligini tushuntir. Taxmin qilib o'zing to'ldirma.

## Birinchi javobing

Avval menga butun jarayonning qisqa xaritasini ber (nechta qadam, qancha vaqt
ketadi, qayerda kutish bo'ladi), keyin birinchi qadamni boshla.
