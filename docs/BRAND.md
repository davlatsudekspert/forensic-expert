# FORENSIC EXPERT — «Shield of Evidence» brendi

Egasi bergan referens rasm vizual yo‘nalish sifatida olingan; belgi toza
vektor geometriyada **qayta chizilgan original** kompozitsiya (rastr rasm
ilovaga qo‘yilmagan). Hech qanday tashkilot logotipi ko‘chirilmagan;
Asklepiy tayog‘i, tarozi, barmoq izi — umumiy (jamoat mulki) ramzlar.
Trademark tekshiruvi — RG-06 (egasi).

| Element | Ma’no |
|---|---|
| Qalqon | institutsional ishonch, dalil himoyasi |
| Tayoq + bitta ilon | sud tibbiyoti |
| Tarozi | xolis ekspert xulosasi |
| Barmoq izi | kriminalistik dalil |
| Xromatogramma cho‘qqilari | analitik laboratoriya (shartli shakl) |
| Bo‘lingan halqa | aniqlik |

## Darajalar (optik soddalashtirish)

* **full** (≥ 96 px) — splash, About, til ekrani, marketing.
* **icon** (41–95 px) — launcher, App Store: qalqon + tayoq/ilon + tarozi.
* **small** (≤ 40 px) — favicon, Home sarlavhasi: qalqon + tayoq/ilon.

16/24/32/48/64/96/180 px sinovi: `design/brand/png/size-test-sheet.png`.

## Ranglar

**Emblema** (o‘zgarmagan): navy `#0F1E3D`, kumush `#E8EDF4`, teal
`#0A6F7A` / `#4CC9D6`, oltin `#9C7A33` (oq fonda) / `#C9A75E` (to‘q fonda).

**UI — «Scientific Luxury»** (`lib/core/design/tokens.dart`):

| Token | Qorong‘i | Yorug‘ |
|---|---|---|
| background | `#0B1017` grafit | `#F7F5EF` fil suyagi |
| surface (ikkilamchi fon) | `#121A25` | `#EFECE4` |
| surfaceRaised (karta) | `#192332` | `#FFFFFF` |
| textPrimary | `#F4F4F1` | `#161B22` |
| textSecondary | `#9AA4B2` | `#525A66` |
| accent (shampan oltini / bronza) | `#C8A86B` | `#7D5F27` |

Oltin aksent kam ishlatiladi: tanlangan holat, asosiy ta’kid, premium
detallar. Kontrast `test/unit/contrast_test.dart` da tekshiriladi.

**Shriftlar** (ilovaga o‘rnatilgan, SIL OFL 1.1): Source Serif 4 —
sarlavhalar; Inter — matn; JetBrains Mono — formulalar (yo‘q glif Inter’dan).

## Fayllar

`design/brand/tools/generate_brand.py` — yagona manba:
SVG (`design/brand/svg/`: emblem full/icon/small × light/dark/mono,
app-icon dark/light/mono, splash, horizontal/stacked lockup), PNG,
Android mipmap + adaptive foreground + monochrome (Android 13 themed),
iOS AppIcon (alpha yo‘q), LaunchImage, Flutter painter
(`lib/core/widgets/brand_emblem.g.dart`). Splash foni — navy.
