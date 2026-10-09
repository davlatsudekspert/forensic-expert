# FORENSIC EXPERT — premium logotip (2026-10-09)

> **Holat: egasi tasdig‘ini kutmoqda.** Yangi logotip worktree branch’da
> to‘liq ulangan (ilova ichi, launcher ikonlari, splash), lekin egasi
> ko‘rib tasdiqlamaguncha asosiy branch’ga birlashtirilmaydi.
> Ko‘rib chiqish to‘plami: `docs/brand/logo_preview_20261009/`
> (asosiysi — `contact_sheet.png` / `.jpg`).

## Manba

`design/brand/source/logo_original.webp` — egasi bergan rastr logotip
(1254×1254, RGB, oq fon): navy qalqon, oltin hoshiya; ichida oltin
Asklepiy tayog‘i (tayoq + bitta ilon), xira ko‘k DNK spirali va oltin
tarozi yoylari; pastda «FORENSIC» (navy serif), «EXPERT» (oltin, yon
chiziqlar bilan) va «EVIDENCE • SCIENCE • PRECISION».

**Vektor yo‘q (ochiq aytiladi):** manbada metall gradient va soyalar bor —
SVG trace ularni tekislab, sifatni pasaytirardi. Shuning uchun barcha
assetlar yuqori aniqlikdagi rastrdan **faqat kichraytirib** olinadi
(qalqon ≈ 580×675 px; App Store 1024 ikonda qalqon ≈ 676 px — 1:1).
Kelajakda dizayner haqiqiy vektor manba bersa, generator shu manbaga
o‘tkaziladi.

Generator: `python3 design/brand/tools/generate_brand.py` (Pillow + numpy).
Ko‘rib chiqish to‘plami: `python3 design/brand/tools/preview_brand.py`.
Ilova skrinshotlari: `integration_test/qa_brand_test.dart`
(`tool/qa_real_app.sh brand`, `QA_OUT=docs/brand/logo_preview_20261009/app`).

## Variantlar

| Variant | Tarkib | Qayerda |
|---|---|---|
| **full** (yorug‘ / qorong‘i) | qalqon + tayoq/ilon + DNK + tarozi | ≥ 57 dp: til ekrani, kirish, About, splash, launcher ikon (≥ 49 px) |
| **small** (yorug‘ / qorong‘i) | qalqon + tayoq/ilon (DNK va tarozisiz) | ≤ 56 dp: Home sarlavhasi (44), Admin AppBar (28), paywall (48); ≤ 48 px iOS ikonlari |
| **mono** (oq siluet) | hoshiya + tayoq/ilon | Android 13+ themed ikon |
| **lockup stacked** | emblema + FORENSIC + EXPERT + tagline | splash (native), marketing |
| **lockup compact** | taglinesiz | kichikroq marketing joylari |
| **wordmark** | faqat matn | hujjatlar, store grafikasi |

**Qorong‘i variant:** oltin hoshiya va ramzlar o‘zgarmaydi, qalqon ichidagi
navy `#021A31` → `#102C52` ga ko‘tariladi — grafit fonda (`#0B1017`)
qalqon yo‘qolmaydi. Wordmark: navy → fil suyagi `#F4F4F1`.

**Ilova ichida** (`lib/core/widgets/brand_mark.dart`):

* `BrandMark(size)` — kvadrat, shaffof PNG (`assets/brand/`, @1x/@2x/@3x;
  full: 128 dp bazasi, small: 40 dp bazasi), `BoxFit.contain` — hech
  qachon cho‘zilmaydi/kesilmaydi; mavzuga qarab yorug‘/qorong‘i asset;
  `tierFor(size)`: ≤ 56 dp → small.
* `BrandLockup` — emblema + **jonli matn** wordmark (Source Serif 4
  SemiBold; har o‘lchamda tiniq): «FORENSIC» navy/fil suyagi, «EXPERT»
  oltin yon chiziqlar bilan, tagline ARB’dan (uz: «DALIL · FAN · ANIQLIK»).
  Wordmark shrift masshtabi bilan kattalashmaydi (logotip), tagline ≤ 1.3×.
  Ekran o‘quvchisi: bitta yorliq «FORENSIC EXPERT. <tagline>».

| Joy | Variant |
|---|---|
| Native splash (Android/iOS) | lockup stacked (tagline bilan), 200 dp kenglik |
| Android 12+ tizim splash’i | adaptive ikon, fon — fil suyagi / grafit |
| Til ekrani (birinchi ishga tushirish) | `BrandLockup(112)` tagline bilan |
| Kirish (email kod, parol) | `BrandLockup(72, showTagline: false)` |
| Home sarlavhasi | `BrandMark(44)` → small + mavjud «FORENSIC EXPERT» matni |
| Admin panel AppBar | `BrandMark(28)` → small |
| Paywall | `BrandMark(48)` → small |
| About / huquqiy | `BrandMark(128)` → full |

## Ilova belgisi

Faqat markaziy emblema (qalqon), mayda matnsiz.

* **Fon:** navy radial gradient `#173155` (markaz) → `#061224` (chekka) —
  qalqon ichidan ochroq, shuning uchun qalqon siluet bo‘lib o‘qiladi.
* **Android:** adaptive `ic_launcher_foreground` (qalqon 52 dp / 108 dp —
  66 dp xavfsiz doira ichida), `ic_launcher_background` (gradient PNG),
  `ic_launcher_monochrome` (themed), legacy `ic_launcher` (yumaloq
  kvadrat) — mdpi…xxxhdpi.
* **iOS:** AppIcon barcha o‘lchamlar, RGB (alpha yo‘q), 1024 ham;
  ≤ 48 px — small variant, belgi 74 % (o‘qilishi uchun) + yengil unsharp.
* **Muqobil (taklif, ulanmagan):** fil suyagi fonli ikon —
  `design/brand/png/app-icon-alt-ivory-1024.png`.

## Ranglar (logotipdan o‘lchangan)

| Token (`FeBrand`) | Hex | Ishlatilishi |
|---|---|---|
| navy | `#021A31` | qalqon ichi, «FORENSIC» |
| navyLifted | `#102C52` | qorong‘i fonda qalqon ichi |
| navyIconCenter / navyIconEdge | `#173155` / `#061224` | ikon foni |
| goldMetal | `#D0B076` | metall hoshiya (o‘rta ton), qorong‘ida «EXPERT» |
| goldOnLight | `#AB864B` | yorug‘ fonda «EXPERT» (yirik matn, ≥ 3:1) |
| dnaBlue | `#3F6381` | DNK spirali (faqat emblemada) |
| ivory | `#F4F4F1` | qorong‘ida wordmark |

UI palitrasi (`FePalette`, «Scientific Luxury») o‘zgarmagan: yorug‘ fon
fil suyagi `#F7F5EF`, qorong‘i — grafit `#0B1017`, aksent oltin
`#7D5F27` / `#C8A86B`. Brend navy faqat emblema, wordmark, ikon va splash
fonida. Splash foni: yorug‘ — `#F7F5EF`, qorong‘i — `#0B1017`.

## Bo‘sh joy va minimal o‘lchamlar

* **Clear-space:** emblema atrofida kamida qalqon kengligining 25 %;
  lockup atrofida — «FORENSIC» harf balandligi (cap-height).
* **Minimal:** full — 57 dp / 64 px; small — 16 px; lockup (tagline bilan)
  — 160 dp kenglik; taglinesiz — 120 dp.
* Taqiqlanadi: cho‘zish, kesish, rangni almashtirish (yorug‘/qorong‘i
  variantlardan boshqa), soya/effekt qo‘shish, emblemani gradient
  yoki rasm ustiga past kontrastda qo‘yish.

## Sinovlar

* `test/unit/brand_assets_test.dart` — iOS RGB/kvadrat/1024, LaunchImage
  light+dark, Android adaptive/monochrome/splash (light+night), ilova
  assetlari @1x/@2x/@3x kvadrat RGBA, eski vektor qoldiqlari yo‘q, darajalar,
  BrandLockup 320 dp da overflow’siz.
* Golden: brendga tegishli ekranlar yangilangan (til, kirish, home,
  admin, paywall, About).
* Real ilova (Linux, Xvfb, MOCK): `qa_brand_test.dart` 8/8 PASS.
* Sinalmagan: haqiqiy Android/iOS qurilmada launcher va splash (Xcode /
  Android build bu muhitda qilinmadi) — preview’dagi ikon/splash rasmlari
  haqiqiy resurs fayllaridan simulyatsiya.
