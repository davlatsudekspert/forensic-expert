# 33 — PHASE 10: global huquq va yurisdiksiya

> 249 davlat katalogi saqlangan, **lekin huquqiy kontent faqat 5 yurisdiksiyada** (INT, GB, US, DE, UZ). Qolganlari — «tasdiqlangan kontent yo‘q». Boshqa davlat qonuni hech qachon o‘rniga qo‘yilmaydi. Barcha qoidalar NEEDS LEGAL REVIEW.

## Tuzilma

Davlat → yurisdiksiya → hudud/shtat → **huquqiy domen** → rasmiy hujjat → modda/bo‘lim.

14 domen (`LegalDomain`): sud eksperti maqomi · dalillar bilan ishlash · saqlash zanjiri · namuna olish · o‘limni tekshirish · autopsiya · toksikologiya · alkogol va transport · nazorat ostidagi moddalar · hisobot · laboratoriya standartlari · saqlash muddatlari · sudda ko‘rsatma · sifat/akkreditatsiya. Yurisdiksiya sahifasida har domen: «N ta yozuv» yoki «Tasdiqlangan kontent yo‘q». Hozir yozuvlar faqat 2 domenda (nazorat ostidagi moddalar; alkogol va transport).

## Yozuv to‘liqligi (`LegalRecordCompleteness`)

Majburiy maydonlar: rasmiy nomi, asl nomi, organ, raqam, modda/bo‘lim, rasmiy havola, nashr sanasi, kuchga kirish sanasi, versiya/o‘zgartirish, holat, oxirgi tekshiruv, til, tarjima holati, review holati. Yetishmayotganlari kartochkada WARNING banner bilan ochiq ko‘rsatiladi (to‘ldirilmaydi). Masalan: US/DE — kuchga kirish sanasi yozilmagan (konsolidatsiya sanasi ishlatilgan, bu ochiq aytiladi); US — nashr sanasi yo‘q. Ilovada asl tildagi nom alohida qatorda.

## Compare Jurisdictions

Mavzular: alkogol chegarasi (GB hududlari) + **nazorat holati** har modda uchun (GB/US/DE milliy ro‘yxatlar). INCB (INT) qoidalari ataylab mavzu kalitisiz — milliy ro‘yxat xalqaro konvensiyani «bekor qilgan» deb ko‘rsatilmaydi. Ma’lumot yo‘q katak: «ma’lumot yo‘q, xulosa chiqarilmaydi».

## Yangilash quvuri

`content/tools/p10/legal_change_check.py`: rasmiy manba → **keshsiz** qayta yuklash → ikki barmoq izi (xom fayl SHA-256 va normallashtirilgan ro‘yxat yozuvlari) → o‘zgarish bo‘lsa `NEEDS_LEGAL_REVIEW` taklifi → legal review → versiyalangan yangilash. Avtomatik nashr yo‘q (`LegalChangeProposal.autoPublish == false`; FE027 jimgina almashtirishni rad etadi).

**Haqiqiy ishga tushirish (2026-10-04):** GB MDA Sch. 2 (451 yozuv), US 21 CFR 1308 (485), DE BtMG Anlagen (1534), UZ Qonun 813-I — **o‘zgarish aniqlanmadi** (xom fayllar kiritilgan paytdagi bilan bir xil). Natija: `content/phase10/legal_change_report.json`, bazaviy barmoq izlari: `legal_baseline.json`.

O‘zbekiston — global pilotlardan biri (mahsulot markazi emas).

## Testlar

Sxema 3 (to‘liqlik, avtomatik nashr yo‘q, domen); ilova 5 (249 katalog vs 5 kontentli yurisdiksiya, hujjat metadata, INCB kalitsiz, DE domenlar/yetishmayotgan maydonlar, Compare nazorat holati).

## Ochiq

RG-15: har yurisdiksiya uchun legal reviewer; UZ nazorat ro‘yxatlari (Vazirlar Mahkamasi qarori) — rasmiy matn topilib, modda bo‘yicha xaritalanishi kerak; qolgan 12 domen uchun rasmiy manbalar.
