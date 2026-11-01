# Deck tuzatish xulosasi (2026-11-01)

Barcha fayllar `tools/content_pending/deckfix/` ichida. DB ga yozilmagan, commit qilinmagan. Har fayl: `deck_id`, `title`, `slide_count`, `new_deck` (to‘liq), `changes`, `quiz_replacements`, `not_found`. Eslatma: `new` — yangi yozilgan slaydlar (shu jumladan qayta yozilgan kirish/xulosa).

| Deck | Slaydlar | Saqlangan | Qayta yozilgan | Yangi | Olib tashlangan | Quiz almashtirish |
|---|---|---|---|---|---|---|
| ktp26-u-30 | 20 | 8 | 0 | 12 | 34 | 18 |
| ktp26-u-33 | 18 | 10 | 0 | 8 | 29 | 14 |
| ktp26-u-38 | 19 | 2 | 0 | 17 | 38 | 19 |
| ktp26-u-39 | 23 | 11 | 0 | 12 | 28 | 15 |
| ktp26-u-49 | 25 | 17 | 0 | 8 | 21 | 7 |
| ktp26-u-50 | 29 | 17 | 0 | 12 | 23 | 11 |
| ktp26-u-52 | 33 | 25 | 1 | 7 | 12 | 8 |
| toks-15-toks-sud-biokimyo | 34 | 28 | 0 | 6 | 10 | 6 |

## Manbasiz / topilmagan

**ktp26-u-30**
- Benzodiazepinlar va boshqa dori vositalari (Baizoldanov 10-bob) bo‘yicha alohida slayd qo‘shilmadi: vaqt cheklovi, kerak bo‘lsa keyingi iteratsiyada.
- Pigolkin (narkotiklarning morfologik diagnostikasi) va Simpson 20–21-boblari qo‘shimcha manba sifatida ishlatilmadi.

**ktp26-u-33**
- Tagaev va Romodanovskiy kitoblarida gistologiya materiallari bor, lekin Tagaev bet belgilari taxminiy (±1), aniq bet ko‘rsatib bo‘lmadi — ishlatilmadi.
- Immunogistokimyoviy va morfometrik usullar tafsilotlari manbalarda qisqa ko‘rsatilgan, alohida slayd qilinmadi.

**ktp26-u-38**
- Tagaev bo‘yicha shok sahifalari ishlatilmadi: manbada bet belgilari taxminiy (±1), aniq bet ko‘rsatib bo‘lmadi.
- Anafilaktik, septik va kardiogen shokning alohida morfologik tavsifi manbalarda faqat nom sifatida tilga olingan; slayd qilinmadi.

**ktp26-u-39**
- Sunsov sinamasi va yog‘ emboliyasi diagnostikasi (ikki qo‘shimcha fakt) olib tashlandi: mavzu «qon yo‘qotish»ga aloqasi zaif; kerak bo‘lsa alohida mavzuga o‘tkazilsin.
- Qon yo‘qotishning gistologik (immunogistokimyoviy) belgilari bo‘yicha qo‘shimcha manba topilmadi.

**ktp26-u-49**
- Tagaev, Pigolkin, Romodanovskiy kitoblarida GTO‘S (SIDS) bo‘limi topilmadi; mavzu faqat G‘iyosov va Simpson bilan yoritildi.
- PubMed review qo‘shilmadi (vaqt cheklovi); uchlik xavf modeli (triple-risk) manbasiz slaydga kiritilmadi.

**ktp26-u-50**
- Pigolkin 14-bobida (bet 299–305) ichki bet belgilari yo‘q, shu sababli aniq sahifa o‘rniga «299-305» oralig‘i ko‘rsatildi.
- Immunogistokimyoviy markerlar (troponin, komplement, MB-CK) bo‘yicha manba lokal fayllarda topilmadi; slayd qilinmadi.

**ktp26-u-52**
- Soxta tolalar (LVFT) slaydlari 100% ishtirokchi kohortasiga tayanadi; kohorta tafsilotlari olib tashlandi, lekin umumiy tushuncha slaydlari saqlandi.
- Pigolkin 14-bobida (bet 299–305) ichki bet belgilari yo‘q, shu sababli «299-305» oralig‘i ko‘rsatildi.

**toks-15-toks-sud-biokimyo**
- Immunoxromatografik testlar bo‘yicha lokal darslik/qo‘llanma matni topilmadi; slaydlar PubMed abstraktlariga (PMID 32040576, 22471608, 23074492) tayanadi — to‘liq matn o‘qilmadi.
- Immunoxromatografik testlarning har bir modda bo‘yicha rasmiy cutoff qiymatlari (SAMHSA/ETX) manbada topilmadi; faqat abstraktdagi fentanil qiymatlari keltirildi.

## Eslatmalar
- Pigolkin 14-bobida (299–305) ichki bet belgilari yo‘q: «299-305» oralig‘i ko‘rsatilgan.
- toks-15 immunoxromatografik slaydlari faqat PubMed abstraktlariga tayanadi (PMID 32040576, 22471608, 23074492); to‘liq matn o‘qilmagan.
- Quiz almashtirishlarda `replaces_id` — mavjud savol id si; savol `position` saqlangan.
- Tuzatilmagan joylar: u-39, u-38 dagi qolgan eski quiz savollari (mos keluvchilari saqlandi).
