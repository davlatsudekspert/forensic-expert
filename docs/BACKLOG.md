# FORENSIC EXPERT — keyingi ishlar (egasi bilan kelishilgan)

TestFlight closeout’dan KEYIN, limit tiklanganda boshlanadi.

## 1. Kitoblar
- **Umumiy «Kitoblar» bo‘limi** — faqat erkin/ruxsatli materiallar:
  UNODC tavsiya etilgan tahlil usullari, WHO qo‘llanmalari, ASB/AAFS
  sud-toksikologiya standartlari, SWGDRUG, ochiq kirishdagi sharhlar.
  Oflayn qidiruv va AI’da bet/bo‘lim iqtibosi bilan.
- **«Mening kitoblarim» (Pro)** — foydalanuvchi o‘zi sotib olgan PDF’larni
  (masalan, Clarke’s) faqat o‘z qurilmasiga yuklaydi; qurilmada indekslanadi,
  qidiruv va AI «Kitob, N-bet» deb ko‘rsatadi; fayl tarqatilmaydi.
- Mualliflik huquqi bilan himoyalangan kitoblar (Clarke’s, Goldfrank,
  Casarett & Doull, Baselt…) ilovaga JOYLANMAYDI.

## 2. Qidiruv sinonimlari
- «alkogol / spirt / алкоголь» → etanol va headspace GC; o‘zbek/rus
  sinonimlarini kontent paketiga qo‘shish (paket qayta imzolanadi).

## 3. Iqtibos tarjimasi
- Har iqtibos ostida «Tarjima (avtomatik, tekshirilmagan)»; asl matn asosiy.

## 4. Kichik UX
- ~~AI ekranida hisobdan chiqilganda «ulanmagan» emas, «hisobga kiring» deyish.~~ Bajarildi (`f43a00a`).

## Tillarni kengaytirish (egasi, 2026-10-10)

Hozircha uchta til — UZ / RU / EN — va ular mukammal qilinadi. Keyinchalik
qo'shiladi: **qozoq, tojik, qirg'iz**.

Har bir yangi til uchun kerak bo'ladigan ish (baholash uchun):
1. ARB kalitlari (~1400 kalit) — interfeys.
2. Ilmiy kontent: qo'llanma kartalari, modda yozuvlari, sudda so'roq, testlar.
   Bu eng og'ir qism — avtomatik tarjima yetarli emas, soha mutaxassisi
   tekshirishi kerak (raqam, birlik, formula, cutoff o'zgarmaydi).
3. `SupportedLanguages.locales` ga qo'shish, til tanlash ekrani, `lang_audit.py`
   va `translation_qa.py` ni yangi tilga kengaytirish.
4. Tarjima holati belgisi: tekshirilmagan tarjima shunday ko'rsatiladi.

Tavsiya: bitta tilni to'liq tugatib, sinovdan o'tkazib, keyin keyingisiga
o'tish. Uchtasini bir vaqtda boshlash sifatni tushiradi.

- **3D anatomiya ko‘rinishi (egasi taklifi, 2026-10-17):** ochiq «Human Atlas» (BodyParts3D asosida, GitHub) kabi 3D atlas. Hozir boshlanmaydi. Avval: (1) litsenziya (BodyParts3D CC BY-SA — nomlash va share-alike talabi tekshiriladi), (2) hajm (2 234 qism — faqat kerakli to‘plam), (3) Flutter 3D ko‘rish usuli va past qurilmada tezlik, (4) oflayn. Foydasi: sud-tibbiy jarohat joyi va a’zolar uchun ustoz/talaba rejimi. Qaror egasida.

- **Serverdagi Pro qoldiqlari (2026-10-17):** `admin_set_access`, `account_access`/tier ustuni, `admin_users(p_tier)`, `admin_stats().tiers` va xarid-tekshiruv edge funksiyalari ilova tomonidan chaqirilmaydi. Egasi tasdig‘idan keyin alohida migratsiya bilan olib tashlanadi (production DB o‘zgarishi — tasdiq kerak).
