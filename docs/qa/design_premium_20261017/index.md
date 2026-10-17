# Premium dizayn — OLDIN / KEYIN (2026-10-17, shox `claude/design-premium`)

OLDIN — `docs/qa/ux_audit_20261017/` (shu kunning UX auditi, real ilova, Linux/Xvfb).
KEYIN — real-app harness (`tool/qa_real_app.sh ux_audit`, haqiqiy Flutter dvigateli, MOCK akkaunt,
tarmoq o‘chiq) va ekranlar katalogi (`docs/qa/screen_catalog_20261017/`, widget-render, haqiqiy
shriftlar va soyalar). Real iOS/Android qurilmada **sinalmagan**.

| # | Ekran | OLDIN | KEYIN | Nima o‘zgardi |
|---|---|---|---|---|
| 01 | Asosiy 390 | ✓ | ✓ | «O‘qish» (karta = ekran nomi), «Moddalar» (Kutubxona emas), «Kutubxona — hamma bo‘limlar»; «Ustoz paneli» kartasi; yumshoq soyalar, radius 20, kengroq ichki bo‘shliq |
| 02 | Asosiy pastki | ✓ | ✓ | oxirgi kontent menyu ustida tugaydi (avtomatik test: `nav_inset_test`) |
| 03 | Asosiy qorong‘i | ✓ | ✓ | mayinroq grafit qatlamlar, xira soya |
| 04 | Asosiy 320 | ✓ | ✓ | toshish yo‘q |
| 05 | Mutaxassis Asosiy | ✓ | ✓ | bir xil tizim |
| 06 | O‘qish | ✓ | ✓ | sarlavha «O‘qish» (avval «Ta’lim»); tepada «Sinfda test» |
| 07–09 | Sinfda test 390 / qorong‘i / 320 | ✓ | ✓ | bitta mayin demo belgisi (sariq chiziqsiz), izoh — oddiy matn; «Test o‘tkazish» nomi |
| 10 | Modda (Etanol) | ✓ | ✓ | sariq baland banner → bo‘lim yonida bir qatorli holat chipi «Ekspert hali tasdiqlamagan» (to‘liq matn semantikada); usullar — GC-MS, LC-MS/MS, GC-FID chiplari |
| 11 | Modda: bog‘liq / huquqiy | ✓ | ✓ | usul chiplari kesilmaydi (qisqa nom, to‘liq — maslahat/semantika); bo‘sh huquqiy matn takrorlanmaydi |
| 12 | AI 320 | ✓ | ✓ | segment «Qisqa / Batafsil» — bir qatorda |
| 13–14 | Profil 390 / 320 | ✓ | ✓ | «Rejim: talaba yoki mutaxassis»; AppBar 20 sp |
| 15 | Taklif (server ulanmagan) | ✓ | ✓ | «Qanday ishlaydi» — 3 qadam (bo‘sh sahifa emas) |
| 16 | Maqolalar (bo‘sh) | ✓ | ✓ | sarlavhali bo‘sh holat, keyingi qadam izohi |
| 17 | Fan sahifasi | ✓ | ✓ | modullar kartalarda; «Keyingi qadam»: fan bo‘yicha qidiruv, Forensic AI |
| 18–20 | Ustoz paneli 390 / qorong‘i / 320 | — | ✓ | YANGI: 3 katta amal |
| 21 | Ustoz: kod va QR | — | ✓ | panel → «Test o‘tkazish» → mavzu → kod/QR (demo server) |
| 22–23 | Modda qorong‘i / 320 | — | ✓ | holat chipi va usul chiplari tor ekranda |

## Ustoz paneli oqimi (bosishlar)

* Asosiy → «Ustoz paneli» (**1**) → «Test o‘tkazish» (**2**) → mavzu tanlash → «Yaratish» → katta kod + QR.
* Asosiy → «Ustoz paneli» (1) → «Natijalar va CSV» (**2**) → ro‘yxat; tugagan sinfda CSV tugmasi shu yerda (3).
* Asosiy → «Ustoz paneli» (1) → «Sinfga qo‘shilish (talaba)» (**2**) → kod maydoni.
* Ustoz roli serverda bo‘lsa karta tezkor amallardan keyin (yuqorida), aks holda bo‘limlardan keyin; rolsiz
  foydalanuvchida ustoz amallari yopiq va sababi yoziladi (yashirin bayroq yo‘q). Yangi backend/migratsiya yo‘q.

## Katalog ko‘rib chiqishda topilgan va tuzatilganlar

1. Pastki menyu ochiq bottom sheet’larni berkitardi (sheet shell navigatorida edi) → 13 ta `showModalBottomSheet`
   `useRootNavigator: true` (sheet menyu ustida, barrier bilan).
2. Dropdown tanlangan qiymati serif shriftda (19 joy) → sans `bodyLarge`.
3. Bo‘sh holatlar matni ekran chetiga tegardi (Maqolalarim, Amallar jurnali, Moderatsiya) → `FeEmptyState` gorizontal
   bo‘shliq; ixtiyoriy amal tugmasi (Natijalar bo‘sh → «Test o‘tkazish»).
4. Teskari hisoblashda xom kod «zero_measured» ko‘rinardi → uch tilda tushunarli ogohlantirish.
5. Tab ildizidagi AppBar sarlavhasi chetga yopishgan edi (titleSpacing) → standart 16 dp.
6. Sinf proyektor ekranida variantlar va reyting serif edi → sans (sarlavhalar serif).
7. «Test o‘tkazish» (panel) → «Yangi sinf testi» (ekran) nomi mos emas edi → hammasi «Test o‘tkazish».
8. Kirish kartalari ikonkalari turli uslubda (kulrang/oltin/ramkasiz) → yagona oltin tonal kvadrat (44 dp).
9. Fan sahifasi: modullar ro‘yxat qatori, keyingi qadamlar karta edi → hammasi karta.

## Qolgan (o‘zgartirilmadi, ro‘yxat)

* Uzun AppBar sarlavhalari (kalkulyator, usul nomlari) 20 sp da «…» bilan qisqaradi — to‘liq nom sahifa ichida bor.
* AI oflayn manbalarida xom manba id’si («SRC-PMC…») havola sifatida ko‘rinadi — kontent/havola formati, keyingi bosqich.
* «Shikoyatlar» (admin) — fixture’da shikoyat xizmati yo‘q, «Bajarilmadi. Aloqani tekshiring.» (real server bilan sinalmagan).
* Sinf yakuniy reytingida bir xil ball bo‘lsa hammasi 1-o‘rin (mantiq to‘g‘ri, ko‘rinish odatiy).
* Kalkulyatorlarda «har maydon 0» holati ba’zan xato emas, 0 natija beradi (masalan, birlik konvertori) — hisob to‘g‘ri.
