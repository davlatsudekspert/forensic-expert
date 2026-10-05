# REAL DEVICE TEST CHECKLIST — Android (FORENSIC EXPERT 0.1.0+1)

**Test qilinadigan APK:** artefakt `android-DEBUG-SIGNED-not-for-store-e83f655…` (ID 11320122430), commit `e83f655`, fayl `forensic-expert-DEBUG-SIGNED-not-for-store.apk`, SHA-256 `e5f604f64fffc30dd3980bf7b750e75ff82917be24a07bf2aa78d4e1b792c28f`.

> ⚠️ **DEBUG imzoli** (`CN=Android Debug`) — faqat real qurilmada sinash uchun. Play Store’ga yoki ommaga tarqatilmaydi. Har CI build o‘z debug kaliti bilan imzolanadi: boshqa build’ni o‘rnatishdan oldin eskisini **o‘chiring** (aks holda «App not installed / signature mismatch»).
>
> Store ulanmagan (mahsulotlar yaratilmagan) va akkaunt serveri ulanmagan — bu build’da xarid va akkaunt yaratish **ishlamasligi kutilgan**; ekranda buni halol aytishi tekshiriladi.

Belgilash: ✅ ishladi · ❌ xato (skrinshot + qadamlar) · ➖ qo‘llanmaydi. Har xato uchun: telefon modeli, Android versiyasi, til, rejim (light/dark), qadamlar.

## Qurilma ma’lumoti
- [ ] Model: ____  Android: ____  RAM: ____  Ekran: ____
- [ ] Tizim tili: ____  Shrift o‘lchami: standart / katta

## 1. Install
- [ ] APK SHA-256 yuqoridagiga mos (`sha256sum` yoki fayl menejeri)
- [ ] «Noma’lum manbalardan o‘rnatish» ruxsati so‘raldi va o‘rnatildi
- [ ] Ilova nomi «FORENSIC EXPERT», ikonka to‘g‘ri
- [ ] Ilova ma’lumotida so‘raladigan ruxsatlar: faqat Internet / tarmoq holati / to‘lov (billing). Kamera, joylashuv, kontaktlar YO‘Q

## 2. First launch
- [ ] Splash → til tanlash ekrani (crash yo‘q)
- [ ] Til → ilmiy disklaymer → rejim tanlash → Home
- [ ] Disklaymer «MA’LUMOT TEKSHIRILMAGAN — EKSPERT TASDIG‘I KERAK» mazmunini aytadi
- [ ] Birinchi ochilish vaqti (taxminan): ____ s

## 3. EN / RU / UZ
- [ ] Profil → Til: har uch tilga o‘tish darhol ishlaydi
- [ ] Har tilda aralash til yo‘q (masalan, RU ekranda inglizcha tugma)
- [ ] O‘zbekcha matnlarda ‘ va ’ belgilari to‘g‘ri ko‘rinadi
- [ ] Matn kesilmaydi / ustma-ust tushmaydi (ayniqsa RU — uzun so‘zlar)

## 4. Light / Dark
- [ ] Profil → Ko‘rinish: System / Light / Dark
- [ ] Kontrast: Standard / High
- [ ] Dark rejimda barcha ekranlar o‘qiladi (oq fonda oq matn yo‘q)

## 5. Home
- [ ] Bo‘limlar kartochkalari ochiladi
- [ ] Oflayn baza kartochkasi ko‘rinadi

## 6. Global search
- [ ] «morphine», «морфин», «morfin» — natija chiqadi
- [ ] Natija guruhlari (moddalar, metodlar, …), bepul rejimda cheklov soni ko‘rsatiladi
- [ ] Qidiruv tarixi saqlanadi

## 7. Substance page
- [ ] Morfin / kokain / etanol: identifikatsiya, ogohlantirishlar, manbalar
- [ ] Provenance (manba) oynasi bitta bosishda ochiladi
- [ ] NEEDS_REVIEW / tekshirilmagan belgisi ko‘rinadi
- [ ] Retraksiya qilingan manba belgilangan (algor mortis ta’rifi)

## 8. Forensic medicine
- [ ] Mavzular ro‘yxati; manbasiz mavzular «ma’lumot yo‘q» deb ko‘rsatiladi
- [ ] Rigor / algor / livor mortis sahifalari ochiladi

## 9. Methods
- [ ] Metodlar ro‘yxati, dalil turi belgisi (xalqaro standart / ta’limiy xulosa …)
- [ ] «Nashr etilgan metod — validatsiya qilingan SOP emas» banneri

## 10. Reagents
- [ ] Marquis va boshqalar: retsept taxmin qilinmagan, manbalar ochiq
- [ ] Xavf / PPE maydonlari ko‘rinadi (mavjud bo‘lsa)

## 11. Rapid tests
- [ ] Ekspress testlar ro‘yxati
- [ ] «Skrining ≠ tasdiqlash» CRITICAL ogohlantirishi

## 12. Calculators
- [ ] C₁V₁ (bepul): hisob to‘g‘ri, birliklar
- [ ] Bepul rejimda professional kalkulyator yopiq va «Tariflarni ko‘rish» tugmasi
- [ ] Noto‘g‘ri kiritish — xato xabari, crash yo‘q
- [ ] Klaviatura maydonni yopib qo‘ymaydi

## 13. Research
- [ ] Tadqiqot kutubxonasi ochiladi, filtrlar ishlaydi
- [ ] Yozuv sahifasi (DOI/PMID ko‘rinadi)

## 14. Jurisdiction
- [ ] Profil → Yurisdiksiya: 249 davlat, qidiruv
- [ ] UZ / GB / US / DE sahifalari; boshqa davlat — «Tasdiqlangan kontent yo‘q»
- [ ] Huquqiy domenlar ro‘yxati (kichik ekranda kesilmaydi)
- [ ] Compare (solishtirish) ekrani

## 15. Student mode
- [ ] Profil → Rejim → Talaba: Learn kirish nuqtasi
- [ ] Birinchi kurs ochiq, keyingisi «Student Pro» bilan yopiq
- [ ] Test / kartochkalar ochiladi

## 16. AI screen
- [ ] AI ekrani: provayder ulanmaganligi ochiq aytiladi (soxta javob yo‘q)
- [ ] Huquqiy savolda yurisdiksiya so‘raladi
- [ ] Lokal manbalar bo‘limi va cheklovlar ko‘rsatiladi

## 17. Account
- [ ] Profil → Akkaunt: «akkaunt ixtiyoriy» va «akkaunt xizmati hali ulanmagan» banneri
- [ ] Kirish / Akkaunt yaratish ekranlari ochiladi; yuborish tugmasi o‘chiq (kutilgan)
- [ ] Parol maydoni: ko‘rsatish/yashirish tugmasi
- [ ] «Qurilmadagi ma’lumotlarni o‘chirish» — tasdiq dialogi, saralanganlar tozalanadi, ilmiy baza saqlanadi
- [ ] AI disklaymeri sahifasi ochiladi

## 18. Paywall
- [ ] Profil → Tarif → «Tariflar»: Free / Student Pro / Professional Pro (Institution YO‘Q)
- [ ] Store ulanmaganligi banneri; narx ko‘rsatilmaydi; obuna tugmalari o‘chiq (kutilgan)
- [ ] «Xaridlarni tiklash» — «Tiklanadigan faol obuna yo‘q» xabari, crash yo‘q
- [ ] Avtomatik yangilanish matni, Shartlar va Maxfiylik havolalari

## 19. Offline mode
- [ ] Samolyot rejimi → ilovani to‘liq yopib qayta ochish
- [ ] Qidiruv, modda sahifasi, kalkulyator, yurisdiksiya oflayn ishlaydi
- [ ] Hech qanday cheksiz yuklanish / bo‘sh ekran yo‘q

## 20. App restart
- [ ] Til, mavzu, rejim, yurisdiksiya saqlanadi
- [ ] Saralanganlar va qidiruv tarixi saqlanadi
- [ ] Orqa fonga o‘tib (5+ daqiqa) qaytish — holat saqlanadi
- [ ] Ekranni burish (agar qo‘llansa) — crash yo‘q

## 21. Performance
- [ ] Sovuq ishga tushish → Home: ____ s
- [ ] Modda sahifasini ochish: ____ s
- [ ] Qidiruv natijasi: ____ s
- [ ] Uzun ro‘yxatlarda aylantirish silliq (qotish yo‘q)
- [ ] Qurilma qizimaydi / batareya g‘ayrioddiy sarflanmaydi
- [ ] Ilova hajmi (Sozlamalar → Ilovalar): ____ MB

## 22. Crash / ANR
- [ ] Sinov davomida crash yo‘q
- [ ] «Ilova javob bermayapti» (ANR) oynasi chiqmadi
- [ ] Xato bo‘lsa: vaqt, ekran, qadamlar; imkon bo‘lsa `adb logcat` chiqishi

## Natija
- [ ] Umumiy: ✅ / ❌   Kritik xatolar soni: ____
- [ ] Izohlar: ____
