# A3 asosidagi takomillashtirilgan variantlar: R1 / R2 / R3

> **PROTOTIP. Yakuniy logo EMAS va QULFLANMAGAN.** Variantni tanlash faqat egasining qarori. Logo qulflanishidan oldin trademark qidiruvi (WIPO, USPTO, EUIPO, Rospatent, O‘zbekiston IMA) va IP yurist xulosasi majburiy. **Bu ishda trademark qidiruvi QILINMAGAN.**

Egasi A3 «Nested Peaks» variantini ko‘rib chiqib, quyidagi qat’iy shartlar bilan uchta takomillashtirilgan variant so‘radi:

- belgi barmoq izi klishesi, tog‘ yoki «A» harfi bo‘lib o‘qilmasligi kerak;
- politsiya nishoni, tibbiy xoch, bosh suyagi, tarozi, qon tomchisi va lupa ishlatilmaydi;
- 32 px da tanib olinishi kerak;
- FORENSIC EXPERT uchun o‘ziga xos ilmiy, dalilga oid ramz bo‘lishi kerak.

Asosiy yondashuv: A3 dagi **simmetrik** Gauss «qo‘ng‘iroqlari» o‘rniga real xromatografiyadagi **asimmetrik** cho‘qqi ishlatildi. Uning shakli Exponentially Modified Gaussian (EMG) funksiyasi bilan hisoblanadi: old tomoni tik, orqasida uzun «tailing» dumi bor. Cho‘qqi ostidagi maydon **to‘ldirildi** (integratsiya). Shu ikki usul «A» va tog‘ siluetini buzadi: bu belgilarda ikki tomon simmetrik bo‘ladi, ichi esa bo‘sh qoladi.

## Fayllar

| Yo‘l | Mazmuni |
|---|---|
| `tools/generate_refined.py` | SVG generator (100×100 grid). EMG cho‘qqilar, mask orqali maydon va kontur orasidagi bo‘shliq |
| `tools/render_refined.mjs` | Playwright/Chromium orqali 1024 / 180 / 64 / 32 px va silhouette rasterlash; Android adaptive va iOS mask preview’lari; kontakt varag‘i |
| `tools/measure_refined.py` | Raqamli tekshiruv: safe zone, 32 px legibility, ko‘zgu asimmetriyasi |
| `svg/R*-{icon,icon-small,light,dark,mono,mono-small}.svg` | Har variant uchun 6 ta SVG |
| `previews/*-icon-{1024,180,64,32}.png`, `*-silhouette-*.png` | Rasterlar (A3 ham solishtirish uchun shu yerda qayta render qilingan) |
| `previews/*-masks.png` | Android (108dp qatlam, circle / squircle / rounded square) va iOS mask preview’lari |
| `previews/contact-sheet.png` | **Asosiy solishtirish varag‘i** (A3 + R1 + R2 + R3) |
| `metrics/refined_metrics.json`, `metrics/refined_metrics.md` | O‘lchov natijalari |

Qayta yaratish (repo ildizidan):

```bash
pip install pillow numpy
python3 design/logo/refined/tools/generate_refined.py
NODE_PATH=$(npm root -g) node design/logo/refined/tools/render_refined.mjs
python3 design/logo/refined/tools/measure_refined.py
```

### Masshtab tizimi

Glif dizayn koordinatalarida markazi (50,50), radiusi 46 bo‘lgan doira ichida chiziladi. Har bir chiqish turida u markaz atrofida masshtablanadi:

| Fayl | Glif doirasi radiusi (100-grid) | Izoh |
|---|---|---|
| `icon` | 28 | 100-grid = Android 108dp qatlam. Safe doira radiusi 30.56, demak ~2.5 birlik zaxira bor |
| `icon-small` | 38 | ≤64 px va favicon uchun. Glif kattaroq, chiziqlar qalinroq. **Adaptive foreground sifatida ishlatilmaydi** |
| `light` / `dark` / `mono` | 44 | |
| `mono-small` | 46 | |

## Variantlar

### R1 «Tailing Peak» (asimmetrik cho‘qqi va dalil qavslari)

- **G‘oya:** real xromatografik cho‘qqining old tomoni tik, dumi uzun. Integrallangan maydon (moddaning miqdori) teal rangda to‘ldirilgan. To‘rt burchakdagi qavslar dalil ramkasini, kadrga olishni va o‘lchov aniqligini bildiradi.
- **Klishelardan qochish:** apex chap tomonga siljigan (bbox asimmetriyasi 0.50). Belgining silueti tog‘ ham, «A» ham emas, «suzgich/yelkan» shakliga yaqin. Barmoq izi, lupa va xoch ishlatilmagan.
- **Small versiya:** qavslar tashqariroqqa surilgan, bazaviy chiziq qisqartirilgan. Maydon konturga yopishgan, shuning uchun 32 px da yaxlit siluet hosil bo‘ladi.

### R2 «Integrated Peak» (integrallash oynasi va retention belgisi)

- **G‘oya:** tailing cho‘qqining konturi. Maydon faqat cho‘qqi boshidan tushirish chizig‘igacha (drop line) to‘ldirilgan, ya’ni dasturdagi integrallash oynasi kabi. Teal tushirish chizig‘i bazaviy chiziqdan pastga chiqadi va retention/integration belgisi vazifasini bajaradi. Bazaviy chiziq chapga uzaygan, chap uchida kichik «injection» belgisi bor. Kompozitsiya markazdan o‘ngga siljigan.
- **Klishelardan qochish:** cho‘qqi simmetrik emas, chap tomonda uzun bo‘sh bazaviy chiziq bor, teal belgi faqat bir tomonda turadi.
- **Eslatma:** birinchi iteratsiyada retention tiki apex ostida edi va «⊥»/«A» shaklini kuchaytirardi. Shuning uchun u integrallash chegarasiga, ya’ni drop line’ga ko‘chirildi.

### R3 «Resolved Doublet» (ajratilgan ikki cho‘qqi)

- **G‘oya:** balandligi har xil ikki cho‘qqi qisman ustma-ust tushgan, lekin bir-biridan ajralgan. Bu ikki moddaning analitik ajratilishini bildiradi, ya’ni dalilni ajratish metaforasi. Baland cho‘qqi oq kontur bilan, pastki cho‘qqi teal rangda to‘ldirilgan holda chizilgan. Ochiq aylana ramkaning uzilishi o‘ng-yuqorida joylashgan.
- **Klishelardan qochish:** ikki cho‘qqi va ochiq halqa (asimmetriya 0.52) bitta «A» yoki tog‘ bo‘lib o‘qilmaydi.
- **Eslatma:** birinchi iteratsiyada baland cho‘qqi tor edi, aylana bilan birga «Ⓐ» (anarxiya belgisi) assotsiatsiyasini berardi. Shuning uchun cho‘qqi kengaytirildi va tailing qo‘shildi.

## O‘lchov natijalari

`tools/measure_refined.py` natijasi (`metrics/refined_metrics.json`):

| Variant | Safe zonadan tashqari glif (icon, %) | Glif maks. radiusi / safe r | 32px siluet ink % | 32px siluet komponentlar | 32px yopiq counter | 32px icon komponentlar | Asimmetriya 1024 (1−IoU) | Asimmetriya small-64 |
|---|---|---|---|---|---|---|---|---|
| A3 (asos) | **21.1** | 50.7 / 30.6 | 20.6 | 1 | 4 | 1 | **0.001** | 0.005 |
| R1 Tailing Peak | 0.0 | 27.1 / 30.6 | 20.4 | 3 | 0 | 3 | 0.501 | 0.297 |
| R2 Integrated Peak | 0.0 | 29.3 / 30.6 | 23.5 | 1 | 0 | 1 | 0.378 | 0.191 |
| R3 Resolved Doublet | 0.0 | 28.0 / 30.6 | 34.1 | 1 | 4 | 1 | 0.521 | 0.519 |

Usul:

- **(i) Safe zone:** `icon-1024.png` da navy fondan farq qiluvchi piksellar olinadi (RGB masofasi > 48) va ularning markaziy 66/108 doiradan tashqaridagi ulushi hisoblanadi.
- **(ii) 32 px:** `silhouette-32` (mono-small, alpha ≥ 128) va `icon-32` (icon-small) bo‘yicha hisoblanadi. 8-bog‘lanishli komponentlar sanaladi. Counter — chegaraga tegmaydigan yopiq fon sohasi.
- **(iii) Asimmetriya:** siluet glifning bbox markazi bo‘yicha gorizontal aks ettiriladi va 1 − IoU hisoblanadi. 0 qiymati to‘liq simmetrik degani, bunda «A» yoki tog‘ xavfi yuqori bo‘ladi.

Talqin:

- A3 amalda to‘liq simmetrik (0.001). Uning glifining 21% Android safe zonasidan tashqarida qoladi, ya’ni circle mask’da bazaviy chiziq kesiladi. Barcha R variantlarda bu ko‘rsatkich 0%.
- **R1:** 32 px da 3 ta komponent bor: cho‘qqi, yuqori qavslar va pastki qavslar qisman qo‘shiladi. Komponentlar ataylab bir nechta (qavslar alohida bo‘lishi kerak). Lekin pastki qavslar antialiasing tufayli bazaviy chiziq bilan bir pikselga tegadi. Ko‘z bilan qaraganda ajralib turadi, metrik bo‘yicha esa chegaraviy holat.
- **R2:** 32 px dagi eng sodda siluet (1 komponent, 0 counter). Kichik o‘lchamda asimmetriyasi pasayadi (0.19).
- **R3:** 32 px dagi eng zich glif (ink 34%, 4 counter). Detallar ko‘p, shuning uchun 32 px da «shovqinli».

## Vizual baho (kontakt varag‘i, 32 px ×8 ham ko‘rib chiqildi)

| Mezon | R1 | R2 | R3 |
|---|---|---|---|
| 1024 / 180 px | Toza, o‘ziga xos. Glif iOS kvadratida biroz kichik ko‘rinadi | Toza, ilmiy ko‘rinishli, gorizontal | Eng boy kompozitsiya |
| 32 px | Tanib bo‘ladi (qavslar ichida uchburchaksimon «yelkan»), lekin cho‘qqining o‘zi ~8 px | Eng aniq: cho‘qqi va chiziq | Ramka tanib olinadi, ichidagi juft cho‘qqilar 32 px da qo‘shilib ketadi |
| «A» / tog‘ xavfi | Past | O‘rta: 32 px siluetda yaxlit «tepalik» bo‘lib ko‘rinishi mumkin | Past–o‘rta: chap cho‘qqi alohida qaralsa «A» ga o‘xshashi mumkin |
| Boshqa assotsiatsiyalar | Akula suzgichi yoki yelkan. Burchak qavslari «scan / QR / kamera fokus» UI ikonkalarida keng tarqalgan | «Sehrgar shlyapasi», umumiy «graph» ikonka | Qayiq yoki to‘lqinli kosa |
| Android masks | Barcha mask’larda xavfsiz | Xavfsiz | Xavfsiz, aylana mask bilan eng mos |

## Halol risklar

1. **Trademark qidiruvi qilinmagan.** «Peak / chromatogram / graph» shakllari laboratoriya, analitika va moliya brendlarida juda keng tarqalgan. Vena tasnifidagi grafik/diagramma kategoriyalari bo‘yicha qidiruv va IP yurist xulosasi zarur.
2. **R1 qavslari** boshqa ilovalardagi «scan» ikonkalariga o‘xshaydi (QR-skaner, Face ID, kamera). Bu o‘ziga xoslikni pasaytiradi.
3. **R2** kichik o‘lchamda (silhouette 32) yana tog‘ yoki tepalikka yaqinlashadi, chunki maydon va kontur bitta yaxlit qora shaklga birlashadi.
4. **R3** 32 px da eng zich va detallari eng ko‘p belgi. Favicon (16 px) darajasida deyarli o‘qilmaydi.
5. Barcha variantlar «xromatografiya» ma’nosiga tayanadi. Mutaxassis bo‘lmagan foydalanuvchi uchun bu shunchaki «grafik» bo‘lib ko‘rinishi mumkin. Barmoq izi (dactyloscopy) ma’nosi ataylab olib tashlangan.
6. O‘lchovlar avtomatik va soddalashtirilgan. Ular foydalanuvchi testining o‘rnini bosmaydi. 5 kishi bilan «2 soniyada topish» testi hali o‘tkazilmagan.

## Tavsiya (qaror egasiniki, logo qulflanmagan)

- **Asosiy nomzod: R1 «Tailing Peak».** Konsept eng kuchli: asimmetrik dalil cho‘qqisi va aniqlik ramkasi. U «A» va tog‘dan eng uzoq turadi (asimmetriya 0.50). Safe zone muammosi yo‘q. Keyingi iteratsiyada «scan» ikonkasiga o‘xshashlikni kamaytirish kerak: masalan, faqat ikki diagonal qavs (chap-yuqori va o‘ng-past) yoki qavs uchlarini kesik qilish.
- **Muqobil: R2 «Integrated Peak».** 32 px da eng sodda va aniq belgi. Lekin siluetda tepalik xavfi bor va boshqa analitika brendlariga o‘xshab qolishi mumkin.
- **R3** marketing yoki katta o‘lchamdagi belgi sifatida qiziqarli, lekin app icon uchun 32 px da zaif.

Yakuniy tanlov **faqat egasining qarori**. Hech bir variant qulflanmagan. Tanlovdan keyin quyidagilar kerak: trademark qidiruvi, 32 px foydalanuvchi testi, wordmark lockup sinovi, alohida Android adaptive foreground qatlami va iOS light/dark/tinted to‘plamlari.
