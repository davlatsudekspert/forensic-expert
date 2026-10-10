# Play Console — 2-bosqich: testerlarni qo'shish va chiqarish (yordamchi uchun prompt)

Quyidagi matnni to'liq ko'chirib yordamchiga bering.

---

Men Google Play Console'da **FORENSIC EXPERT** ilovasi ustida ishlayapman.
Imzolangan `.aab` faylini **allaqachon yukladim**. Endi ichki sinovni (Internal
testing) oxiriga yetkazishim kerak. Men texnik odam emasman — har qadamni
**o'zbek tilida**, sodda tushuntir, bir vaqtda bitta qadam ber va men
bajarganimni aytganimdan keyin keyingisiga o't. Skrinshot yuborsam, o'sha
ekranda nima bosishim kerakligini ayt.

## Ilova haqida qisqacha

- Nomi: **FORENSIC EXPERT**, paket nomi `uz.forensicexpert.forensic_expert`
- Sud-ekspertlar uchun professional ma'lumotnoma va o'quv ilovasi
  (sud-kimyo, sud-tibbiyot, sud-biologiya). Uch tilli: o'zbek, rus, ingliz.
- Kirish — elektron pochtaga keladigan bir martalik kod orqali; hisobsiz ham
  ishlaydi. Ilova ichida hisobni butunlay o'chirish mumkin.
- Reklama yo'q. 18+ professional foydalanuvchilar uchun.
- Backend — Supabase (Frankfurt). AI javoblari server orqali, manbalar bilan.

## Nima qilishim kerak

### 1. Testerlar ro'yxati

Internal testing uchun email ro'yxati yaratishim kerak. **Menda ro'yxat bor —
men senga yuboraman.** Sen menga ayt:

- ro'yxatni qayerga kiritaman (Play Console'da aniq qaysi menyu);
- email'larni qanday formatda yozish kerak (vergul bilanmi, har biri yangi
  qatordami, CSV faylmi);
- **har bir tester Google hisobi bo'lishi shartmi** — agar email Google hisobi
  bo'lmasa nima bo'ladi;
- testerlarga opt-in havolasi qanday boradi va ular qanday o'rnatadi.

Agar ro'yxatda xato email bo'lsa yoki kimdir havolani ocha olmasa, buni qanday
tekshirishni ham ayt.

### 2. Majburiy bo'limlar

Ular to'ldirilmaguncha chiqarishni boshlab bo'lmaydi. Har biri uchun menga
aniq nima yozishimni ayt:

- **App access** — ilovaning bir qismi hisob talab qiladi, shuning uchun Google
  tekshiruvchisiga ishlaydigan test akkaunt berishim kerak. Kod elektron
  pochtaga kelishini ham tushuntirib yozish kerak. Buni qanday rasmiylashtiraman?
- **Data safety** — yig'iladi: email (autentifikatsiya), professional profil,
  yuklangan malaka hujjatlari (maxfiy, faqat vakolatli tekshiruvchi ko'radi).
  Yig'ilmaydi: joylashuv, kontaktlar, reklama identifikatorlari. Transitda TLS.
  Foydalanuvchi hisobni ilova ichidan o'chira oladi.
- **Content rating** — savolnoma. Ilovada giyohvand moddalar **faqat aniqlash
  va ekspertiza kontekstida** tilga olinadi; tayyorlash yoki iste'mol
  yo'riqnomasi yo'q. Buni qayerda va qanday izohlashim kerak?
- **Target audience** — 18+, bolalar uchun emas.
- **Privacy policy URL** — majburiy. Menda matn bor, lekin ochiq URL yo'q.
  Buni qayerga joylashtirsam bo'ladi (eng oson yo'lini ayt).
- **Ads** — reklama yo'q.

### 3. Release'ni boshlash

Hammasi to'ldirilgach, Internal testing release'ni qanday boshlashni va
tekshiruv qancha vaqt olishini ayt. Rad etilsa nima qilishimni ham oldindan
tushuntir.

## Muhim

- **Production'ga chiqarmayman** — hozircha faqat Internal testing.
- Rad etish xavfi asosan giyohvand moddalar mavzusi va hisob talab qilinishi
  bilan bog'liq. Shuning uchun tavsif va Content rating izohlarida maqsad
  aniq yozilishi kerak.
- Menda yo'q ma'lumot kerak bo'lsa (hujjat, URL, karta), to'g'ridan-to'g'ri
  so'ra — o'zing taxmin qilib to'ldirma.

## Birinchi javobing

Avval qisqa ro'yxat ber: nechta qadam qoldi va qaysi biri eng uzoq davom etadi.
Keyin 1-qadamdan boshla.
