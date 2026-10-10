# Uch tilli lokalizatsiya — yakuniy real-ilova sinovi (2026-10-10)

Linux desktop (haqiqiy Flutter dvigateli, Xvfb), `FE_AUTH_MODE=mock`, HTTP bloklangan,
har yugurish toza `XDG_DATA_HOME` bilan. Commit: `3d3096c` + QA tuzatishlari.

| Yugurish | Natija |
|---|---|
| `l10n_uz` — o‘zbekcha ekranlar | 31/31 PASS |
| `l10n_ru` — ruscha ekranlar | 31/31 PASS |
| `l10n_en` — inglizcha ekranlar | 31/31 PASS |
| `study_uz` — o‘quv testi (talaba va mutaxassis, uz/ru/en, 390/320 dp) | 63/63 PASS |
| `student` — talaba roli | 48/49 → skript tuzatildi (`s18` iqtibos blokigacha aylantirish) |
| `expert` — mutaxassis roli | 37/37 PASS |
| `admin` — admin roli | 23/23 PASS |

**Jami: 256 qadam, 255 PASS.** Yagona FAIL ilova xatosi emas edi: tarjima belgisi endi
iqtibos blokidan yuqorida ham chiqadi, shuning uchun sinov skripti iqtibosga yetmay
to‘xtagan. Skript tuzatildi (`integration_test/qa_student_test.dart`).

## Nima tasdiqlandi (egasining talablari bo‘yicha)
- **Maqola ro‘yxati:** avval tanlangan tildagi sarlavha, ostida «Asl nomi» / «Оригинальное
  название», keyin «Avtomatik tarjima — tekshirilmagan» va bibliografiya (muallif, jurnal, yil).
- **Ilmiy kartalar:** «Qisqacha tushuntirish» foydalanuvchi tilida, ostida «Asl manbadagi
  iqtibosni ko‘rish». Matn faqat kartadagi manbali da’volardan olinganligi ochiq yozilgan.
- **Metabolit, skrining, ziddiyat, standart va kontekst matnlari** uch tilda.
- **O‘quv testi:** «1-savol / 10 ta» sanog‘i, mashq va imtihon rejimlari, har javobga izoh va
  manba, noto‘g‘ri variantlar faqat shu mavzudan.
- **Atamalar:** GC-MS, LC-MS/MS, PMI, PMR — hamma joyda bir xil, birinchi uchraganda izohlanadi.

## Sinalmagan
Haqiqiy iOS/Android qurilma, haqiqiy OTP email, haqiqiy xarid, production Supabase.

## Ochiq masalalar
- Barcha tarjimalar `machine_draft` — ekspert ko‘rigi kutilmoqda.
- Baholanadigan imtihon hozircha faqat o‘zbek tilida (76 savol); ru/en uchun izohlar
  tekshirilgach ochiladi.
- ZRU-249 2026-12-13 dan kuchini yo‘qotadi (o‘rniga O‘RQ-1152) — huquqiy qayta ko‘rik kerak.
