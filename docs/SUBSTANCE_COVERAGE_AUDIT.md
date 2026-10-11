# Modda sahifalari — to'liqlik auditi (2026-10-11)

Egasining talabi: **qayerga kirilsa, shu mavzu bo'yicha hamma narsa o'sha
yerda yozilgan bo'lsin** — «u yerdan ol, bu yerda bor» demasdan; har yozuv
ostida manbasi va aniq joyi ko'rsatilsin.

Ekran tuzilishi buni allaqachon ko'taradi (modda sahifasida identifikatsiya,
metabolitlar, metabolizm, biomarker, parchalanish mahsulotlari, aniqlash
usullari, metod yozuvlari, konsentratsiyalar, yurisdiksiya, bog'liq yozuvlar,
manbalar bo'limlari bor). **Muammo tuzilishda emas — kontentda.**

## O'lchangan holat (`content/pilot/bundle.json`, 137 modda)

| Bo'lim | Bor | Yetishmaydi |
| --- | ---: | ---: |
| Identifikatsiya | 137 / 137 | 0 |
| Metabolizm izohi | 95 / 137 | 42 |
| Aniqlash usullari | 99 / 137 | 38 |
| Konsentratsiyalar | 54 / 137 | 83 |
| Metabolitlar | 15 / 137 | 122 |
| Biomarker | 1 / 137 | 136 |
| Parchalanish mahsuloti | 1 / 137 | 136 |
| Namuna (qon / siydik / jigar …) | 0 / 137 | 137 |

Bir moddaga to'g'ri keladigan yozuv: eng kami **1**, o'rtachasi **4**, eng
ko'pi **24**.

Eng bo'sh moddalar: butane, colchicine, etonitazene, etonitazepyne, nitrous
oxide (har birida 1 ta yozuv — faqat identifikatsiya).
Eng to'liqlari: morphine (24), heroin (20), ethanol (19), codeine (18),
THC (16).

Ya'ni foydalanuvchi morphine sahifasini ochsa to'liq ko'radi, butane
sahifasini ochsa deyarli bo'sh ko'radi. Shikoyat aynan shundan.

## Tuzatilgani (shu o'tirishda)

**Bo'sh maydon ildizidan tuzatildi.** Manbada matn maydoni bo'sh satr bo'lib
kelganda (PubMed'da jurnali ko'rsatilmagan 14 ta maqola) bazaga `''` bo'lib
yozilardi — `null` emas, shuning uchun ekranda **sarlavhasi bor, qiymati yo'q
qator** chiqardi («Jurnal / konferensiya» bo'sh). Endi
`fe_content_pipeline` baza yozuvchisida **hamma jadval va hamma ustun** uchun
bir joyda normallashtiriladi: bo'sh satr → `NULL`. Pipeline testi butun
bazani skanerlaydi va bironta matn ustunida bo'sh satr qolsa yiqiladi.
Qayta yig'ilgan `content.db` da bunday qator **0 ta**.

## Qoladigan ish — dossier to'ldirish

Har bir moddada quyidagilar bo'lishi kerak, har biri **manbasi va aniq joyi
bilan** (`claim` + `citation`, `source_id` + `locator`):

1. Identifikatsiya (bor).
2. Metabolizm: asosiy yo'l, ferment (CYP2D6, UGT…), faol metabolitlar.
3. Metabolitlar ro'yxati — qaysi biri aniqlanadi.
4. Namuna turlari: qon, siydik, jigar, soch, shishasimon tana suyuqligi —
   qaysi biridan, qancha muddat ichida aniqlanadi.
5. Aniqlash usullari: skrining (immunoanaliz, rang sinamasi, YuQX) va
   tasdiqlovchi (GC-MS, LC-MS/MS) — cheklovlari bilan.
6. Manbalarda keltirilgan konsentratsiyalar: terapevtik / toksik / o'limga
   olib keluvchi oraliq, namuna turi va kontekst bilan.
7. Talqin cheklovlari: postmortem redistribusiya, barqarorlik, xalaqit
   beruvchi moddalar.

**Qoida:** manbasiz bironta jumla yozilmaydi. Topilmagan joyda bo'lim
«ma'lumot topilmadi» deb ochiq ko'rsatiladi — to'qib yozilmaydi.
