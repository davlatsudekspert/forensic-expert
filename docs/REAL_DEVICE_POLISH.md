# Real-device UX / kontent sayqali

> Yangi faza emas: arxitektura, xavfsizlik, provenance, review, oflayn, qidiruv va yurisdiksiya o‘zgarmagan. Yangi ilmiy kontent qo‘shilmagan. HUMAN VERIFIED = 0.

## 1. Ichki / dev so‘zlar
* Foydalanuvchi UI matnlari (ARB): 21 kalit qayta yozildi — «PHASE», «pilot», «placeholder/заглушка», «prototip», «TEST DATA», «Ishlab chiqilmoqda/В разработке», «later development phase», «not yet curated» va h.k.
* Kontent paketi (2026.10.7): 40 ta konsentratsiya da’vosidagi «Context not yet curated (PHASE 7 pilot covers 17 substances).» cheklovi olib tashlandi (UI o‘rniga lokalizatsiyalangan «tekshirilgan kontekstual ma’lumot hozircha mavjud emas» ko‘rsatadi); 14 manba izohidan «PHASE 7/8» va skript nomlari olib tashlandi. Manbalarning `accessed_date` qiymatlari o‘zgartirilmadi (haqiqiy kirish sanasi saqlandi).
* Regressiya: `test/widget/polish_test.dart` — ARB (EN/RU/UZ) va paket maydonlari skaneri hamda 3 til × 10 ekranda ko‘rinadigan matn skaneri.

## 2. Bo‘sh holatlar
`AvailabilityStateView` — 5 xil halol holat: ma’lumot yo‘q · tekshirilgan ma’lumot yo‘q · filtr bo‘sh · ulanmagan · xizmat vaqtincha ishlamayapti; kerak joyda amallar (Filtrlarni tozalash, Barcha yozuvlar, Qidirish). «Ishlab chiqilmoqda» ekrani olib tashlandi (Manbalar, modul ma’lumotnomasi, testlar, kartochkalar, filtr natijasi).

## 3. Konsentratsiya
Har bir konsentratsiya kartasi: modda, qiymat (manba iqtibosida — raqam ajratilmaydi, to‘qilmaydi), namuna, tirik/o‘limdan keyin, manba turi (holat tavsifi/annotatsiya/kirish/natijalar/muhokama), holat/tadqiqot konteksti, analitik metod, birga aniqlangan moddalar, cheklovlar, dalil darajasi, tekshiruv holati, manba + kartaning ichida CRITICAL ogohlantirish (universal toksik/o‘limga olib keluvchi/terapevtik/huquqiy chegara emas). Kuratsiya qilinmagan maydon — «Ma’lumot mavjud emas»; manbada aytilmagani — «manbada ko‘rsatilmagan».

## 4. Tekshiruv holati
Ro‘yxatlarda ixcham belgi (✓ / ○ / ! / × + xira matn); to‘liq belgi faqat tafsilot sahifalarida. `rejected` endi «Rad etilgan» deb to‘g‘ri ko‘rsatiladi (avval «Tekshiruv kerak» chiqardi).

## 5. Kalkulyatorlar
Alohida: hisoblash moduli («avtomatik dasturiy testlar bilan tekshirilgan — bu ilmiy ekspertiza emas»), formula manbasi (ilmiy tekshiruv holati), talqin (kontekstga bog‘liq). Plitkada «Modul sinovdan o‘tgan» + formula holati ixcham.

## 6. Forensic AI
Production provayder ulanmaganda: ekran yuqorisida «Namoyish · ulanmagan» kartasi (4 band), «Yuborish» o‘chiq va sababi yozilgan, javob namunasi «NAMOYISH — AI javobi ham, ilmiy tavsiya ham emas» deb belgilangan va faqat ulanmagan holatda ko‘rsatiladi. «Manbalarni oflayn topish» ishlaydi. Provayder ulanganda oddiy holat avtomatik.

## 7–11. Dizayn
Home: header (belgi 32 + so‘z belgisi + lokalizatsiyalangan izoh), yengil tekshiruv eslatmasi (ramkasiz), modul kartalari teng balandlikdagi to‘r, ikonka bir xil fonli belgida, matn to‘liq kenglikda (RU uzun so‘zlar bo‘linmaydi). Kutubxona: nom → guruh → ixcham holat/kirish. Profil: akkaunt serveri ulanmaganda ishlamaydigan kirish/ro‘yxat tugmalari yashirildi. Paywall o‘zgarmadi (narx faqat store’dan, Institution yashirin).

## 12. Lokalizatsiya
UZ: 27 kalitda «reviewer/review» → «taqrizchi/taqriz», «Claim» → «Da’vo», «Ustoz (Tutor)» → «Ustoz», «Sharh (review)» → «Sharh maqola», «Kontent paketi» → «Ilmiy ma’lumotlar paketi», «Bepul demo» → «Bepul». RU: «Пакет контента» → «Пакет научных данных». Yakuniy tarjima taqrizi — RG-11 (inson).

## 14. O‘lchamlar
`test/a11y/polish_responsive_test.dart`: 320/360/390/430 dp × 1.0/1.3/2.0 × EN/RU(dark)/UZ × 8 ekran = 288 holat. Topildi va tuzatildi: ixcham kirish belgisida matn sig‘masligi (RU, 320–430 dp).
