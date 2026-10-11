# FORENSIC EXPERT — Play Console grafik assetlari

Bu papkadagi hamma narsa **ilovaning o‘z brendi va o‘z ekranlaridan** olingan.
Hech qanday rasm «o‘ylab topilmagan» va boshqa ilovadan ko‘chirilmagan.

## Yuklanadigan fayllar

| Play maydoni | Fayl | O‘lcham |
| --- | --- | --- |
| App icon (majburiy) | `play-icon-512.png` | 512×512 PNG |
| Feature graphic (majburiy) | `play-feature-1024x500.png` | 1024×500 PNG |
| Phone screenshots (kamida 2 ta, 8 ta tayyor) | `screenshots/01…08-*.png` | 1170×2532 PNG |

## Manbalar

* **Ikonka va feature grafika** — `design/brand/png/app-icon-1024.png`
  («Shield of Evidence» emblemasi) dan o‘lchami o‘zgartirilgan. Bu ilovaning
  haqiqiy launcher ikonkasi bilan **bir xil** tasvir: Android
  `mipmap-*/ic_launcher.png` va iOS `Icon-App-1024x1024@1x.png` shu manbadan.
  Feature grafikada emblema kesilmagan; chap va o‘ng tomon manbaning o‘z fon
  ustunlari bilan cho‘zilgan, ya’ni yangi grafik element qo‘shilmagan.
* **Skrinshotlar** — `docs/screenshots/final/` dagi haqiqiy ilova
  ekranlaridan. Tanlanganlari: Asosiy (talaba va mutaxassis rejimi),
  Toksikologiya, Sud tibbiyoti, Modda kartasi, Usul kartasi, Manba sahifasi,
  Qidiruv. Hammasi o‘zbek tilida.

## Ataylab QO‘SHILMAGANLAR

`fin_13_pending_FIXTURE_uz.png`, `fin_14_verified_FIXTURE_uz.png` va
`fin_22_review_FIXTURE_uz.png` — bu ekranlarda **namunaviy (FIXTURE)**
ma’lumot bor. Do‘kon sahifasida ular haqiqiy ma’lumotdek ko‘rinardi,
shuning uchun olinmadi.

## Nimani bilib qo‘yish kerak

Skrinshotlar kontent paketi **2026.10.7** bilan olingan. O‘shandan keyin
qo‘llanma yozuvlarining ikkinchi to‘plami qo‘shildi va «Savol-javob
(Hamjamiyat)» bo‘limi paydo bo‘ldi (hozircha faqat test tarqatishda).
Ekranlarning tuzilishi o‘zgarmagan, lekin raqamlar (yozuvlar soni) biroz
eski. Yangisi kerak bo‘lsa — `tool/qa_real_app.sh` bilan qayta olinadi.

Do‘kon matnlari (nom, qisqa va to‘liq tavsif, uch tilda):
`docs/play_store/listing.md`.
