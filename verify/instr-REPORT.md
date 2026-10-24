# «Apparatlar bilan ishlash» — kontent va rasmlar hisoboti (2026-10-24)

Papka: `SCRATCH/instruments/` — `out/*.json` (decklar), `images/` (rasmlar + `IMAGES.json`), `build/` (generator skriptlari), `man/` (yuklab olingan Shimadzu qo‘llanmasi, ish nusxasi).
Repo fayllari o‘zgartirilmadi, commit yo‘q. Validator: `tools/lessons/validate_deck.py` — 3 deck, **0 xato** (faqat kutilgan ogohlantirish: slayd soni 27–28 < 38, mcq 10 < 20).

## 1. Decklar

| Deck | Slayd | Diagramma slaydlari | MCQ | Asosiy manba |
|---|---|---|---|---|
| `instr-01-kristallyuks-etanol` | 27 | 24 (steps, flow, facts, table, compare, reaction) | 10 | toks 41, 188–193, 217–218; katalog yozuvlari |
| `instr-02-uv1900-cohb` | 28 | 24 (steps, flow, facts, table, compare, tree, reaction) | 10 | toks 81–85, 108, 217–220; Shimadzu UV-1900i Operation Guide |
| `instr-03-gcms-asoslar` | 28 | 26 (steps, flow, facts, table, compare, tree) | 10 | Shimadzu GC/MS ochiq sahifalari, SCION TN, gmt (m/z), toks 188–191, 269–270 |

Har bulletda `source{author,title,page[,url]}` bor; sahifa = PDF sahifasi (toks, gmt). Slayd `image` maydoni DECK_SPEC_V2 §2a ga mos (`url`, `caption`, `credit`, `kind`) + qo‘shimcha `file` (mahalliy fayl nomi).

### Manbalar
- **Ustoz kitoblari (asosiy):** toks (Yuldashev, Umarova 2025) 41, 82–85, 108, 188–193, 217–220, 269–270; gmt (2024) 4, 10, 26, 29, 48, 77, 78, 92, 93, 97, 100. COHb uchun egasi qarori (538 nm, izobestik 550 nm, K = 0,372) qo‘llandi; kitobdagi «0,2‰ o‘limga olib keladi» xatosi kiritilmadi.
- **Ishlab chiqaruvchi/ochiq hujjatlar:**
  - Shimadzu UV-1900i Instruction Manual (Operation Guide), 207-90563, 2019 — https://www.deq.isep.ipp.pt/deq/labinv/equipamentos/1350_Espectrofot__metro-UVVIS.pdf (to‘liq yuklab olindi; sahifalar: v, vii, viii, 7, 8, 18–23, 55, 62–69, 72–78). Menyu: Mode Menu → Photometric / Photometric 8l / Spectrum…; Auto Zero va Base Corr. farqi; Scan Range, Scan Speed, Data Interval.
  - Shimadzu Europa UV-1900 sahifasi (190–1100 nm).
  - Shimadzu GC/MS texnik yordam sahifalari (Features of EI, Ion Source, Overview, Library Search, Retention Time/Index, FAQ principles/advantages).
  - SCION Instruments Technical Note «Full Scan and SIM in a Single MSWS Method», 2026 (scan/SIM, kvantifikator/kvalifikator).
  - Katalog yozuvlari (qurilma ma’lumoti): astanahub.com E-lab «Kristallyuks-4000M»; christmas-plus.ru «Xromatek Kristall 5000».

## 2. Muhim cheklovlar va halollik qaydlari (egasi ko‘rishi kerak)
1. **Kristallyuks / Xromatek ishlab chiqaruvchi qo‘llanmasi ochiq topilmadi.** Qurilma tugmalari, menyu va ishga tushirish tartibi **yozilmadi** (to‘qilmadi). instr-01 faqat kitob usuli (toks 188–193: katarometrli GSX, alkilnitrit usuli) + katalog xarakteristikalari (uncertain). «Qurilma qo‘llanmasi holati» slaydi buni ochiq aytadi.
2. **Nom noaniqligi:** «Kristallyuks» (Kristallyuks-4000M) odatda **Meta-Xrom** (Yoshkar-Ola) mahsuloti; «Xromatek Kristall 5000» esa **Xromatek**. Egasi qaysi qurilmani nazarda tutayotganini yorliq fotosi bilan tasdiqlashi kerak. (Ishlab chiqaruvchi nomi ochiq katalogda ko‘rsatilmagan; bu — mening bilimim, tekshirish talab etiladi.)
3. **UV-1900 vs UV-1900i:** qo‘llanma UV-1900i uchun; UV-1900 menyulari farq qilishi mumkin. COHb → rejim moslashtirishi (Spectrum / Photometric 8l; WL1=538, WL2=550) kitobda yo‘q — slaydlarda `uncertain` + «ustoz tasdig‘i».
4. **COHb formulasi** (P = 100 − (D_COHb − D_HbCOHb)·100/(D_HbI·K)) kitob 84-betidagi tasvirdan o‘qildi (matn qatlamida yo‘q) — `uncertain`. Kitobda D1 ba’zi joylarda 534 nm; egasi qarori bo‘yicha 538.
5. **GX-MS kitoblarda deyarli yo‘q** (toks/gmt faqat qo‘llanish va m/z ro‘yxatlarini beradi). Nazariya (EI, kvadrupol, scan/SIM, kutubxona) Shimadzu/SCION ochiq sahifalaridan; qurilma sozlamalari (tuning, harorat) yozilmadi.
6. Sozlanmagan/tasdiqsiz: Xromatek «4 detektor, 3 bug‘latgich» (sotuvchi katalogi, matnni o‘zim ochib o‘qimadim — qidiruv natijasi), piretroid GSX da «3 °C/daq» (kitobda «30C», daraja belgisi tushib qolgan), morfin sezgirligi «10-11».
7. Qurilmada hech narsa **sinalmadi** (real UV-1900/GX/GX-MS yo‘q) — decklar faqat hujjat va kitob asosida.
8. Decklar 20–30 slayd (talabga ko‘ra), MCQ 10 ta. Kitob 38–42 / 20 talabiga yetkazish uchun keyin kengaytiriladi.

## 3. Rasmlar (faqat ruxsatli; to‘liq tafsilot — `images/IMAGES.json`)

Wikimedia Commons API orqali qidirildi; faqat CC0 / CC BY / CC BY-SA / Public domain olindi. Ishlab chiqaruvchi saytlaridan rasm olinmadi. Yuklab olingan o‘lcham 960 px (≤ 240 KB).

| Fayl (`images/`) | Nima | Litsenziya | Muallif | Slayd |
|---|---|---|---|---|
| gc_shimadzu_gc2010.jpg | Shimadzu GC-2010 Plus + AOC-20i | **CC0** | Dqwyy | instr-01 #4 |
| gc_aniskov.jpg | GX termostati ichida ikki FID (ПИД-1/2) | CC BY-SA 4.0 | Aniskov | instr-01 #10 |
| gc_autosampler.jpg | Namuna flakonlari (avtonamunaolgich) | CC BY 2.0 | Hey Paul (Sacramento) | instr-01 #18 |
| uv_du640.jpg | Beckman DU 640 spektrofotometr | **Public domain** | TimVickers | instr-02 #11 |
| uv_cuvettes.jpg | Kvars va plastik kyuvetalar | CC BY-SA 4.0 | Retama | instr-02 #15 |
| uv_insert_cuvette.jpg | Kyuvetani o‘rnatish (qo‘l ko‘rinadi) | CC BY-SA 4.0 | Viv Rolfe | instr-02 #18 |
| gc_shimadzu_aoc30.jpg | Shimadzu GX + AOC-30 (ko‘rgazma; chetda odamlar) | CC BY-SA 4.0 | Gpkp | instr-03 #4 |
| gcms_screen.jpg | GX-MS xromatogrammasi ekranda (1987) | CC BY 3.0 | Tracey Nicholls, CSIRO | instr-03 #16 |
| gc_neochrom.jpg, gc_lab.jpg | zaxira, ishlatilmadi | CC BY 4.0 / CC BY 2.0 | NeoLyo89 / Hey Paul | — |
| gc_block_uz.svg/.png | GX blok-sxemasi (o‘z chizma, uz) | original | Forensic Expert | instr-01 #5 |
| uvvis_block_uz.svg/.png | UV-Vis blok-sxemasi (o‘z chizma, uz) | original | Forensic Expert | instr-02 #8 |
| gcms_block_uz.svg/.png | GX-MS blok-sxemasi (o‘z chizma, uz) | original | Forensic Expert | instr-03 #3 |

Eslatma: ilova faqat PNG/JPG qabul qiladi (spec §2a) — SVG lar PNG qilib tayyorlandi. Commons rasmlari uchun `url` = `upload.wikimedia.org` (960 px thumb); o‘z sxemalar uchun `url` — joy egasi `https://PROJECT.supabase.co/.../lesson-images/<fayl>.png`: Storage ga yuklangach hostni almashtirish kerak. Commons rasmlari CC BY/BY-SA: credit (muallif, litsenziya) slaydda ko‘rinadi.

### Topilmagan rasmlar
- Commons da **Shimadzu UV-1900/UV-1900i**, **Xromatek Kristall 5000**, **Kristallyuks** qurilmalarining rasmi topilmadi (qidiruv: UV-1900, Shimadzu UV, Crystal 5000, Хроматэк, Кристаллюкс, Кристалл газовый хроматограф). O‘rniga umumiy analoglar (Beckman DU 640, Shimadzu GC-2010, rus FID) va o‘z sxemalar ishlatildi; sarlavhalarda «misol» deb belgilangan.
- Real GX-MS (Shimadzu GCMS-QP) fotosi yo‘q; faqat Shimadzu GX + AOC-30 ko‘rgazma kadri.
- COHb spektr rasmi (Hb/COHb spektri) ruxsatli manbada topilmadi; ilovada diagramma (`facts`) bilan berildi.

## 4. Egasidan so‘raladigan o‘z fotolari
1. **Xromatek / Kristallyuks GX — old ko‘rinish** (to‘liq asbob, 1,5 m masofadan, ish stolida), **yorliq** (model, seriya raqami, ishlab chiqaruvchi) alohida yaqin kadr.
2. **Boshqaruv paneli yoki PC dasturi ekrani** (menyu, termostat/detektor harorati, gaz oqimi oynasi) — ekran suratlari.
3. **Dozator (inyektor) va rezina tiqin**, mikroshpritsni kiritish payti (yon tomondan, qo‘l bilan).
4. **Kolonka termostati ichi** (eshik ochiq, kolonka va detektor ulanishi) — yuqoridan.
5. **Gaz ta’minoti:** ballon/generator, reduktor, oqim o‘lchagich (manometr ko‘rsatkichi ko‘rinsin).
6. **Penitsillin flakoni + fiksator**, 30 % NaNO₂ va 50 % trixlorsirka kislota idishlari (yorliq ko‘rinsin) — namuna tayyorlash bosqichi.
7. **Real xromatogramma** (qog‘oz yoki ekran): spirt cho‘qqilari, ushlanish vaqti belgilari bilan.
8. **Shimadzu UV-1900 — old ko‘rinish** (qopqoq yopiq/ochiq), **sensorli ekran: Mode Menu**, Photometric 8l va Spectrum parametr ekranlari, **kyuveta bo‘limi (ochiq) va kyuveta o‘rnatilgan holat**, yorliq (UV-1900 yoki 1900i).
9. **A, B, V eritmali kyuvetalar** yonma-yon (ranglari ko‘rinsin), **spektr grafigi** ekranda (557 nm / 541–571 nm cho‘qqilari).
10. **GX-MS (qaysi model — aniqlang): old ko‘rinish, yorliq, ion manbai/kolonka qismi (xizmat qopqog‘i ochiq), PC dasturi: TIC, bitta cho‘qqi spektri, kutubxona qidiruvi natijasi.**
11. Rasmlarda **odamlar yuzi, bemor/ekspertiza ma’lumotlari va maxfiy yozuvlar** ko‘rinmasin.

## 5. Keyingi qadamlar (tavsiya)
- Egasi: qurilma modelini (Meta-Xrom Kristallyuks yoki Xromatek Kristall) va pasportni yuborsin → instr-01 ga tugma/menyu bosqichlari qo‘shiladi.
- Ustoz: COHb formulasi, 538/550 moslashtirishi va rejim tanlovi tasdig‘i (uncertain bandlar).
- Decklarni 38–42 slayd va 20 MCQ ga yetkazish — alohida buyruq bilan.


## 2026-10-24 (kech) — 38–42 slayd / 20 mcq ga kengaytirish (agent hisobotidan)
Deck 1: 42 slayd (38 diagrammali), deck 2: 42 (37), deck 3: 41 (38); har birida 20 mcq. Validator --strict: 0 xato.
Ilmiy muharrir ko'rishi kerak (uncertain): K taqsimlanish koeffitsiyenti ta'rifi (toks 47–48 vs 188); detektor nomi (48 vs 189); Lambert–Beer (faqat dvssm 245; toks 163); COHb rang reaksiyalari (toks 85 vs 218); CO saqlanish muddati (122 kun vs 25–40 soat); Photometric 8λ tenglamasi va Quantitation rejimi COHb uchun kitobda yo'q; xavfsizlik/sifat nazorati manbasi yo'q (ochiq aytilgan); kokaetilen keysi (gmt 61 — faqat topshiriq); Kristallyuks/Xromatek va Shimadzu GX-MS qo'llanmalari topilmadi (to'qilmadi).
