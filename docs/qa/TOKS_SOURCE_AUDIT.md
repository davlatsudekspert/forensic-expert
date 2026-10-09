# «Toksikologik kimyo» kartalari va savollari — manba auditi

Sana: 2026-10-09. Ko‘lam: `content/guidelines/src/card_{h,i,j,k,l}_toks_*.json`
(5 karta) va ulardagi 34 ta o‘z-o‘zini tekshirish savoli (`quiz`). Kartalar
`NEEDS_REVIEW` holatida qoladi; hech qayerda `HUMAN_VERIFIED` qo‘yilmagan.
Bu audit AI tomonidan bajarilgan manba–matn solishtiruvi, ekspert ko‘rigi emas.

## Usul

- Manba: `toks_majmua2025` (Yuldashev Z.A., Umarova G.Q., 2025; 355 b.) va
  `dvssm_majmua2025` (350 b.) — egasi bergan PDF nusxa (repoga kiritilmagan).
- Sahifa xaritasi: `pdftotext` matnida forma-feed (`\f`) bo‘yicha bo‘lingan
  sahifa indeksi har bir sahifa oxiridagi bosma raqam bilan solishtirildi —
  toks: 351 ta raqamli sahifada 0 nomuvofiqlik, dvssm: 349 tasida 0;
  `pdftotext -f 152 -l 152 toks.pdf` ham shuni tasdiqladi. Demak **bosma sahifa
  raqami = PDF sahifa indeksi**, kartalar ham shu raqamdan foydalanadi.
- Har bir `[toks_majmua2025] (N-b.)` / `[dvssm_majmua2025] (N-b.)` iqtibosli
  da’vo birligi (uz matn; ru/en — uning tarjimasi) tegishli sahifada o‘qilib
  hukm chiqarildi: **SUPPORTED** (sahifa da’voni qo‘llaydi), **PARTIAL**
  (qisman: da’vo kitobdan kengroq yoki qo‘shimcha sahifa kerak),
  **NOT_SUPPORTED**, **WRONG_PAGE** (matn boshqa sahifada).
- Boshqa adabiyot (11 ta maqola) PubMed annotatsiyasi darajasida tekshirildi.
- Kitobdagi ilmiy xatolar (balanslanmagan tenglamalar va h.k.) avvalgi
  agent qarori bo‘yicha tuzatilgan holda qoldi, lekin iqtibos endi kitob
  tuzatilgan shaklni bergandek ko‘rsatmaydi: «majmuadagi tenglama
  balanslanmagan; to‘g‘ri shakli: …» kabi aniq yozildi.
- Kitobda yo‘q, umumiy xavfsizlik tavsiyalari iqtibosdan ajratilib,
  «(umumiy laboratoriya xavfsizligi talabi)» deb belgilandi.

## Jami

| Ko‘rsatkich | Soni |
|---|---|
| Tekshirilgan da’vo birliklari (kitob iqtibosi bilan) | 177 |
| SUPPORTED | 144 |
| PARTIAL → matn toraytirildi / sahifa qo‘shildi | 29 |
| WRONG_PAGE → sahifa tuzatildi | 4 |
| NOT_SUPPORTED → olib tashlandi | 0 |
| Jami tuzatilgan da’volar | 33 |
| Adabiyot iqtiboslari (da’vo × manba) | 19: 16 SUPPORTED, 3 PARTIAL (toraytirildi), 0 olib tashlandi |
| Savollar | 34: 27 SUPPORTED, 3 WRONG_PAGE, 4 PARTIAL — 7 tasi tuzatildi, 0 olib tashlandi |

Ikki da’voga `dvssm_majmua2025` (88-b.) qo‘shildi (I va J kartalar, «factors»
bo‘limi). Ro‘yxatdagi `omitted_unverified` izohidagi «pp. 26 and 172» ham
«173» ga tuzatildi.

Kitobdagi tuzatilgan va atributsiyasi aniqlashtirilgan tenglamalar (5 ta):
AsH3 + AgNO3 (77-b.), Berlin zangorisi FeCl3 koeffitsienti (29-b.),
KBrO3 + KBr (35-b.), fosfomolibdat (153-b., suv yo‘q), geksaxloran + NaOH
(158-b., «H2O»). HCN + AgNO3 argentometriya tenglamasi (29-b.) kitobda
to‘g‘ri — o‘zgarishsiz.

## Da’volar jadvali

ID — `karta.bo‘lim.tartib` (uz matndagi iqtibosli birliklar tartibi, audit
oldingi holat bo‘yicha). H — ajratib olish, I — mineralizatsiya, J — metallar,
K — uchuvchi zaharlar, L — pestitsidlar.

| ID | Da’vo (qisqa, uz) | Sahifa | Hukm | Harakat |
|---|---|---|---|---|
| H.basis.1 | Zaharli modda biologik ob’ektda odatda juda kam miqdorda va oqsil, yog‘, pigment kabi yot modda… | 11, 18 → 11, 18–19 | PARTIAL | Oqsil/yog‘/pigment 19-b.da — sahifa qo‘shildi |
| H.basis.2 | Majmuada zaharlar ajratib olish usuliga ko‘ra guruhlanadi | 20 | SUPPORTED | — |
| H.basis.3 | Ayrim moddalar bir necha usulda ajralishi mumkin; amaliyotda eng ko‘p modda ajraladigan usul ta… | 20 | SUPPORTED | — |
| H.scope.1 | Suv bug‘i bilan haydash — uchuvchan, suvda kam eriydigan yoki o‘z qaynash haroratida parchalana… | 22–23 | SUPPORTED | — |
| H.scope.2 | Ikkinchi (ishqoriy) haydash — ob’ekt ishqorlantirilgach, anilin, nikotin, anabazin, koniin, efe… | 26 | SUPPORTED | — |
| H.scope.3 | Nordonlashtirilgan suv yoki spirt bilan ajratish — kristall dori moddalari, barbituratlar va al… | 93–94 | SUPPORTED | — |
| H.scope.4 | Suyuq alkaloidlar (nikotin, anabazin, paxikarpin, koniin, arekolin) umumiy usullardan tashqari … | 96 | SUPPORTED | — |
| H.scope.5 | Organik erituvchi bilan bo‘ktirish — fosfororganik va boshqa pestitsidlar uchun (alohida kartag… | 152 | SUPPORTED | — |
| H.methods.1 | Qurilma: bug‘ hosil qiluvchi kolba (himoya naychasi bilan), suv hammomidagi ob’ekt kolbasi, sov… | 23–24 | SUPPORTED | — |
| H.methods.2 | Maydalangan ob’ekt suv bilan bo‘tqa holiga keltiriladi va oksalat yoki vino kislotasi bilan pH … | 25, 172 → 25, 173 | WRONG_PAGE | pH 2,0–2,5 va tiqin 25 va 173-b.da (172 — jadval) |
| H.methods.3 | U to‘liq faqat sianidga tekshiriladi . | 26, 28 | SUPPORTED | — |
| H.methods.4 | Ikkinchi distillyat (taxminan 25 ml) bo‘sh idishga yig‘iladi va spirtlar, aldegid va ketonlar, … | 26 → 26, 28 | PARTIAL | Fenollar 28-b.da — sahifa qo‘shildi |
| H.methods.5 | Kerak bo‘lsa ob’ekt ishqorlantirilib, distillyat suyultirilgan xlorid kislotasiga yig‘iladi — a… | 26 | SUPPORTED | — |
| H.methods.6 | Miqdoriy tahlil uchun ob’ektning yangi qismidan alohida distillyat olinadi; haydash shu moddaga… | 26 | SUPPORTED | — |
| H.methods.7 | Stas usuli (1851) — ob’ekt oksalat yoki vino kislotasi bilan nordonlashtirilgan etil spirtida b… | 94 | SUPPORTED | — |
| H.methods.8 | Nordonlashtirilgan suv usullari (Uslar–Erdman, Dragendorf, Shvaykova–Vasilyeva, Kramarenko) — K… | 94–96 | SUPPORTED | — |
| H.methods.9 | Natijada ikki ajratma olinadi: kislotali muhitdagi (barbituratlar, neytral moddalar, organik ki… | 96 | SUPPORTED | — |
| H.advantages.1 | Suv bug‘i bilan haydashda modda nisbatan past haroratda ajraladi va tuzilishi kamroq o‘zgaradi;… | 22–23, 26 | SUPPORTED | — |
| H.advantages.2 | Distillyatlarni ketma-ket yig‘ish (ishqorga — sianid uchun, bo‘sh idishga — qolgan uchuvchi mod… | 26, 28 | SUPPORTED | — |
| H.advantages.3 | Stas–Otto usulida tozalash spirt ishtirokida bo‘lgani uchun ekstraksiyada emulsiya kam hosil bo… | 94 | SUPPORTED | — |
| H.advantages.4 | Shvaykova–Vasilyeva usuli tez va qimmat reaktiv talab qilmaydi; Kramarenko usuli sezgir, nisbat… | 95–96 | SUPPORTED | — |
| H.limitations.1 | Etilenglikol, sirka kislotasi, tetraetilqo‘rg‘oshin kabi moddalar oddiy sharoitda suv bug‘i bil… | 26 | SUPPORTED | — |
| H.limitations.2 | Ayrim moddalar suv bilan azeotrop aralashma hosil qiladi; bunday aralashma tarkibi haydashda o‘… | 23 | PARTIAL | uz matni toraytirildi: komponentlarni bir-biridan ajratib bo‘lmaydi (kitob shuni aytadi) |
| H.limitations.3 | Stas–Otto usuli uzoq vaqt va ko‘p spirt talab qiladi, sezgirligi past va natijalari o‘zgaruvcha… | 94–95 | SUPPORTED | — |
| H.limitations.4 | Nordonlashtirilgan suv usullarida chirigan ob’ektlardan barqaror emulsiya hosil bo‘ladi va modd… | 95 | PARTIAL | Kitob buni faqat Shvaykova–Vasilyeva usuli haqida aytadi — umumlashtirish olib tashlandi |
| H.limitations.5 | Qayta ekstraksiya bilan tozalashda kuchsiz asoslar (purin hosilalari, narkotin, promedol, antip… | 88–89, 92–93 | SUPPORTED | — |
| H.factors.1 | pH: kislota xossali moddalar kislotali muhitda, asos xossalilar ishqoriy muhitda haydaladi va o… | 26, 86–87 | SUPPORTED | — |
| H.factors.2 | Istisno — sirka kislotasi: uning dissotsiatsiyasini bostirish uchun kuchli mineral kislota kera… | 26–27 | SUPPORTED | — |
| H.factors.3 | Ekstraksiya: taqsimlanish koeffitsienti, erituvchi tabiati, ekstraksiyalar soni, tuzlovchi elek… | 86–88 | SUPPORTED | — |
| H.factors.4 | Alkaloidlar oqsillar bilan bog‘lanadi; bog‘ni uzish uchun Kramarenko usulida pH 2–3 tanlangan . | 95 | PARTIAL | Kitob: pH 2,5–3; Kramarenko protsedurasi pH 2–2,5 — «pH 2–3» tuzatildi |
| H.factors.5 | Chirish: chirish mahsulotlari distillyatga o‘tib tahlilga xalaqit beradi va hidlarni o‘zgartira… | 21, 27 | SUPPORTED | — |
| H.factors.6 | Ob’ektni olish va saqlash: har bir a’zo alohida toza, quruq shisha idishga solinadi (metall yok… | dvssm 87–88; 10 | SUPPORTED | — |
| H.cautions.1 | Bug‘ hosil qiluvchi kolbaning himoya naychasi bosimni tenglaydi; suv ko‘tarilsa alanga pasaytir… | 24 | SUPPORTED | — |
| H.cautions.2 | Haydash tugaganda avval bug‘ naychasi ob’ekt kolbasidan ajratiladi, keyin qizdirish to‘xtatilad… | 24–25 | SUPPORTED | — |
| H.cautions.3 | Sovutgich uchi qabul qiluvchi suyuqlikka botib turishi shart, aks holda oson uchuvchi moddalar … | 25 → 25–26 | PARTIAL | «Suyuqlikka botib turishi» 26-b.da |
| H.cautions.4 | Sianid saqlashi mumkin bo‘lgan ob’ektni nordonlashtirish va keyingi ishlar so‘ruvchi shkafda ba… | 56 | PARTIAL | 56-b. sianid reaktivlari haqida; ob’ektni nordonlashtirishdagi talab «umumiy xavfsizlik talabi» deb ajratildi |
| H.cautions.5 | Dastlabki (taxminiy) tekshiruv musbat bo‘lsa ham xulosa chiqarilmaydi: taxmin qilingan moddaga … | 12 | SUPPORTED | — |
| H.alternatives.1 | Vakuumda haydash — yuqori haroratda parchalanadigan moddalar uchun (masalan, tetraetilqo‘rg‘osh… | 19, 22 | SUPPORTED | — |
| H.alternatives.2 | Mikrodiffuziya — ayrim uchuvchan moddalarni aniqlash uchun . | 22 | SUPPORTED | — |
| H.alternatives.3 | Ajratmalarni tozalash: sovunlash (gidrolizga chidamli xlororganik birikmalar uchun), sulfirlash… | 19, 89–90 | SUPPORTED | — |
| H.alternatives.4 | Majmuada ajratilgan moddalar kimyoviy, mikrokristalloskopik, YuQX, spektral va gaz-xromatografi… | 11 | SUPPORTED | — |
| I.basis.1 | Simob, qo‘rg‘oshin, mis, rux, kadmiy kabi metallar oqsil va aminokislotalarning –SH, –NH2, –COO… | 50–51 | SUPPORTED | — |
| I.basis.2 | To‘liq tekshiruvda majmua 13 element birikmalarini ko‘rsatadi: bariy, marganets, xrom, rux, tal… | 18, 51 | SUPPORTED | — |
| I.basis.3 | Mineralizatsiya usullari ikki guruhga bo‘linadi | 51 | SUPPORTED | — |
| I.basis.4 | Sulfat va nitrat kislotalar bilan mineralizatsiyada organik modda kislotalarning parchalanishid… | 51–52 | SUPPORTED | — |
| I.scope.1 | Tekshiriladigan ob’ektlar: oshqozon, ingichka va yo‘g‘on ichak, jigar, o‘t pufagi, buyrak, siyd… | 58 | SUPPORTED | — |
| I.scope.2 | Ho‘l mineralizat bariy va qo‘rg‘oshin (cho‘kmada), shuningdek marganets, xrom, mis, kumush, rux… | 58–77 | SUPPORTED | — |
| I.scope.3 | Simob uchun ob’ekt mineralizatsiya qilinmaydi, balki chala oksidlanadi — destruksiya (Vasilyeva… | 78 | SUPPORTED | — |
| I.scope.4 | Ko‘p metallar (masalan, marganets, kadmiy) organizmda tabiiy mikroelement sifatida uchraydi, sh… | 58, 65, 73 | SUPPORTED | — |
| I.methods.1 | Maydalangan ob’ekt (majmuada 100 g) Keldal kolbasiga solinadi, teng hajmdagi konsentrlangan sul… | 193 | SUPPORTED | — |
| I.methods.2 | Birinchi bosqich — to‘qima elementlarining suyuqlikda erishi; ikkinchi bosqichda mineralizat qo… | 193–194 | SUPPORTED | — |
| I.methods.3 | Tugash belgisi: oksidlovchisiz qizdirilganda suyuqlik qoraymaydi va oltingugurt(VI) oksidining … | 194 | SUPPORTED | — |
| I.methods.4 | Oksidlovchilarni tekshirish: bir tomchi mineralizat suv bilan aralashtirilib, difenilaminning k… | 54, 194 | SUPPORTED | — |
| I.methods.5 | Denitratsiya: qaynab turgan mineralizatga formaldegid tomchilab qo‘shiladi (azot oksidlari ajra… | 54, 194 | SUPPORTED | — |
| I.methods.6 | Boshqa kimyoviy denitratorlar — natriy sulfit, mochevina (CO(NH2)2 + 2HNO2 → CO2 + 2N2 + 3H2O),… | 54 | SUPPORTED | — |
| I.methods.7 | Mineralizat suv bilan suyultiriladi (majmuada 180 ml gacha) va qisqa qaynatiladi; cho‘kma (bari… | 54, 58, 194 → 54, 59, 194 | WRONG_PAGE | Ba/Pb sulfat cho‘kmasi 59-b.da |
| I.methods.8 | Krilova): har bir kation mineralizatning alohida qismida o‘ziga xos sezgir reaksiya bilan aniql… | 54, 57–58 | SUPPORTED | — |
| I.methods.9 | Niqoblovchilarga misollar: Fe(III) uchun ftoridlar va fosfatlar (rangsiz komplekslar); kumush, … | 55–57 | SUPPORTED | — |
| I.advantages.1 | Sulfat va nitrat kislotalar bilan mineralizatsiyada organik moddalar to‘liq parchalanadi, jaray… | 52 | SUPPORTED | — |
| I.advantages.2 | Kimyoviy denitratsiya (formaldegid va boshqalar) oksidlovchilarni uchuvchan gazlarga aylantirib… | 54 | SUPPORTED | — |
| I.advantages.3 | Kasrli usul har bir kationni boshqa kationlarni ketma-ket ajratmasdan, alohida qismda aniqlash … | 57 | SUPPORTED | — |
| I.limitations.1 | Sulfat–nitrat usulida simob deyarli to‘liq yo‘qoladi; quruq va ho‘l mineralizatsiyada ham simob… | 52, 78 | SUPPORTED | — |
| I.limitations.2 | Xlor bilan mineralizatsiya (eski usul) organik moddani chala parchalaydi, uzoq davom etadi, mis… | 52 → 51 | WRONG_PAGE | Xlor usuli kamchiliklari 51-b.da |
| I.limitations.3 | Sulfat kislota va ammoniy nitrat usulida mineralizat ko‘p ammoniy sulfat saqlaydi va parchalani… | 52–53 | SUPPORTED | — |
| I.limitations.4 | Mineralizatda qolgan oksidlovchilar (ayniqsa nitrozilsulfat kislota) mishyak, qo‘rg‘oshin va bo… | 53 | SUPPORTED | — |
| I.limitations.5 | Quruq kuydirish faqat uchmaydigan kationlar uchun yaroqli . | 51 | SUPPORTED | — |
| I.factors.1 | Oksidlovchi yetishmasa mineralizat qorayadi; nitrat kislotani o‘z vaqtida qo‘shish to‘liq parch… | 193–194 | SUPPORTED | — |
| I.factors.2 | Nitrozilsulfat kislota konsentrlangan sulfat kislotada barqaror, suvda gidrolizlanadi; shuning … | 53 | SUPPORTED | — |
| I.factors.3 | Ortiqcha formaldegid qizdirish yoki oz miqdor vodorod peroksid bilan yo‘qotiladi . | 194 | SUPPORTED | — |
| I.factors.4 | Niqoblovchi va pH ni to‘g‘ri tanlash kasrli reaksiyaning o‘ziga xosligini belgilaydi; masalan, … | 55 | SUPPORTED | — |
| I.factors.5 | Ob’ekt turi va miqdori: surunkali zaharlanishda soch, tirnoq va suyaklar ham tekshiriladi . | 58 + dvssm 88 | PARTIAL | «Surunkali» 58-b.da yo‘q — toraytirildi; surunkali Pb/Tl/As uchun dvssm 88-b. qo‘shildi |
| I.cautions.1 | Konsentrlangan kislotalar bilan mineralizatsiya va denitratsiya faqat so‘ruvchi shkafda bajaril… | 193–194 | SUPPORTED | — |
| I.cautions.2 | Perxlorat kislotali aralashma (H2SO4 + HNO3 + HClO4) to‘liq mineralizatsiya beradi, ammo o‘ta x… | 53 → 52–53 | PARTIAL | Kaan usuli 52–53-b.; «ruxsat talab qiladi» kitobda yo‘q — umumiy talab deb ajratildi |
| I.cautions.3 | Sianidlarni niqoblovchi sifatida nordon eritmaga qo‘shib bo‘lmaydi — zaharli vodorod sianid ajr… | 56 | SUPPORTED | — |
| I.cautions.4 | Ko‘p metallar tabiiy mikroelement: topilgan kation miqdori aniqlanmasdan zaharlanish haqida xul… | 17, 58 | SUPPORTED | — |
| I.alternatives.1 | Simob uchun destruksiya: 20 g jigar yoki buyrakka suv, oz miqdor etil spirti (katalizator) va k… | 78, 211–212 → 78, 213 | WRONG_PAGE | Destruksiya tartibi 78 va 213-b.da |
| I.alternatives.2 | Kation miqdori majmuada fotoelektrokolorimetrik (ditizon, dietilditiokarbamat va boshqa rangli … | 60–74 | SUPPORTED | — |
| J.basis.1 | Metall birikmalari organizmda oqsillar, fermentlarning sulfgidril guruhlari bilan birikadi; tah… | 50–51, 57, 78 | SUPPORTED | — |
| J.basis.2 | Sud-kimyoviy ahamiyatiga ko‘ra reaksiyalar ikki xil | 61, 76 | SUPPORTED | — |
| J.basis.3 | Asosiy kimyo: mishyak birikmalari ajralayotgan vodorod ta’sirida uchuvchan arsinga qaytariladi;… | 75 | SUPPORTED | — |
| J.scope.1 | Majmuada to‘liq tekshiruvga kiruvchi metall zaharlar va ularning manbalari | 58–80 | SUPPORTED | — |
| J.scope.2 | Marganets va xromning yuqori valentli, surmaning uch valentli birikmalari kuchliroq ta’sir qila… | 58, 68 | SUPPORTED | — |
| J.methods.1 | Mishyak | 75–77, 211–213 | SUPPORTED | — |
| J.methods.2 | Simob (destruktatda) | 79, 213 | SUPPORTED | — |
| J.methods.3 | Qo‘rg‘oshin va bariy (mineralizat cho‘kmasi) | 59–61 | SUPPORTED | — |
| J.methods.4 | Boshqa kationlar (qisqacha) : kumush — ditizonat sariq, suyultirilgan HCl bilan chayqatilganda … | 62–74 | SUPPORTED | — |
| J.advantages.1 | Kasrli reaksiyalar oddiy asbob-uskuna bilan bajariladi va har bir kation alohida qismda tekshir… | 57 | SUPPORTED | — |
| J.advantages.2 | Marsh usuli dog‘ning bir necha mustaqil xossasini (ko‘rinish, alanga, hid, qizdirilgandagi kris… | 76–77 | SUPPORTED | — |
| J.advantages.3 | Ditizon, dietilditiokarbamat va boshqa rangli komplekslar fotoelektrokolorimetrik miqdoriy aniq… | 61, 65, 77, 79 | SUPPORTED | — |
| J.limitations.1 | Ditizon ko‘p metallar bilan rangli komplekslar beradi (masalan, kumush va simob ditizonatlari i… | 62–63, 67–68 | SUPPORTED | — |
| J.limitations.2 | Mis tetrarodanmerkuriat reaksiyasini temir, kobalt va nikel ham beradi; malaxit yashili reaksiy… | 64, 68 | SUPPORTED | — |
| J.limitations.3 | Mis(I) yodid bilan simob reaksiyasiga oksidlovchilar xalaqit beradi (erkin yod ajraladi) . | 79 | SUPPORTED | — |
| J.limitations.4 | Marganets, kadmiy kabi elementlar normada ham organlarda bo‘ladi — sifat reaksiyasi yolg‘iz o‘z… | 65, 73 | SUPPORTED | — |
| J.limitations.5 | Tetraetilqo‘rg‘oshin qizdirilganda parchalanadi; uni yod bilan ishlab noorganik qo‘rg‘oshinga o… | 61–62 | SUPPORTED | — |
| J.factors.1 | Reaktivlar tozaligi: Marsh usulida reaktivlar «bo‘sh» tajribada mishyakdan holi ekanligi isbotl… | 76, 212 | SUPPORTED | — |
| J.factors.2 | Mineralizatda oksidlovchilar qolmasligi kerak — ular mishyak va qo‘rg‘oshin tahliliga xalaqit b… | 53 | SUPPORTED | — |
| J.factors.3 | pH va niqoblovchilar: talliy ditizon reaksiyasi kuchli ishqoriy muhitda sianid, sitrat, tiomoch… | 67–68 | SUPPORTED | — |
| J.factors.4 | Ob’ekt tanlash: simob uchun jigar va buyrak (alohida), siydik va qon ham tekshiriladi; surunkal… | 58, 78 + dvssm 88 | PARTIAL | «Surunkalida soch/tirnoq» 58/78-b.da yo‘q — toraytirildi; dvssm 88-b. (simob tuzlari) qo‘shildi |
| J.factors.5 | Zanger–Blek qurilmasida vodorod sulfid qo‘rg‘oshin atsetatli paxta bilan ushlanmasa, qog‘ozdagi… | 75–76 → 75–76, 212 | PARTIAL | «Dog‘ ishonchsiz» kitobda yo‘q — H2S PbS holida ushlanishi bilan almashtirildi |
| J.cautions.1 | Qurilmadan havo to‘liq siqib chiqarilganini to‘nkarilgan probirkadagi gazni yoqib tekshirish ke… | 76, 212 | SUPPORTED | — |
| J.cautions.2 | Talliy, mis va boshqa metallarni niqoblash uchun kaliy sianid ishlatiladi — u faqat ishqoriy mu… | 56, 67–68 | SUPPORTED | — |
| J.cautions.3 | Bitta rangli reaksiya asosida xulosa chiqarilmaydi; topilgan metall miqdori va uning normada uc… | 17, 58 | SUPPORTED | — |
| J.alternatives.1 | Mishyak miqdori: arsinni ammiakli kumush nitrat eritmasidan o‘tkazib ortiqcha kumushni rodanid … | 77 | PARTIAL | Kitobdagi AsH3+AgNO3 tenglamasi balanslanmagan — «majmuada balanslanmagan; to‘g‘ri shakli» deb yozildi |
| J.alternatives.2 | Simob miqdori: ditizonat holida fotometrik yoki Cu2[HgI4] holida nefelometrik/kolorimetrik . | 79, 213 | SUPPORTED | — |
| J.alternatives.3 | Qo‘rg‘oshin: ditizonat holida fotometriya, kompleksonometriya yoki bixromat-yodometriya; bariy:… | 60–61 | SUPPORTED | — |
| J.alternatives.4 | Etilmerkurxlorid kabi organik simob birikmalari xloroform bilan ajratilib, mis simida simob qop… | 79–80 | SUPPORTED | — |
| K.basis.1 | «Uchuvchi» zaharlar tuzilishi xilma-xil, ammo ularni suv bug‘i bilan haydalishi birlashtiradi; … | 18, 22 | SUPPORTED | — |
| K.basis.2 | Distillyatlar tahlili rejasi | 28 | SUPPORTED | — |
| K.basis.3 | Reaksiyalar sud-kimyoviy ahamiyatiga ko‘ra «manfiy» (guruhga xos, faqat istisno qiladi) va «mus… | 28, 30, 36 | SUPPORTED | — |
| K.scope.1 | Sianidlar: achchiq bodom hidi taxminiy yo‘llanma beradi; HCN va uning tuzlari murdada uzoq saql… | 21, 28 | SUPPORTED | — |
| K.scope.2 | Formaldegid (formalin taxminan 37 % li suvli eritma): suv bilan gidrat hosil qilgani uchun qiyi… | 30 | SUPPORTED | — |
| K.scope.3 | Metanol, etanol, amil spirtlari va etilenglikol: etilenglikol suv bug‘i bilan yomon haydaladi v… | 39–46 | SUPPORTED | — |
| K.scope.4 | Alkilgalogenidlar: xloroform, xloralgidrat, to‘rtxlorli uglerod, 1,2-dixloretan . | 36–39 | SUPPORTED | — |
| K.scope.5 | Fenol, sirka kislotasi va atseton . | 31–36 | SUPPORTED | — |
| K.scope.6 | Atseton qandli diabetda va izopropil spirtining metaboliti sifatida ham organizmda bo‘lishi mum… | 31, 33 | SUPPORTED | — |
| K.methods.1 | Sianid (birinchi distillyat) | 29, 173 → 29, 173–174 | PARTIAL | 48 soat 174-b.da; kitobda FeCl3 koeffitsienti yo‘q — bu aniq ko‘rsatildi |
| K.methods.2 | Formaldegid | 30, 176 | SUPPORTED | — |
| K.methods.3 | Spirtlar | 40–43, 185–187 | SUPPORTED | — |
| K.methods.4 | Alkilgalogenidlar | 36–39, 181–183 | SUPPORTED | — |
| K.methods.5 | Fenol | 35, 177 | SUPPORTED | — |
| K.methods.6 | Sirka kislotasi va atseton | 31–34 | SUPPORTED | — |
| K.advantages.1 | Distillyat reaksiyalari oddiy reaktivlar bilan bajariladi va bir nechta reaksiya natijalarini j… | 182 | SUPPORTED | — |
| K.advantages.2 | Gaz-suyuqlik xromatografiyasi universal, sezgir, aniq, kam namuna talab qiladi va murakkab aral… | 48–49 | PARTIAL | «Yetakchi usul» kitobda yo‘q — «yetarlicha sezgir va aniq» deb toraytirildi |
| K.advantages.3 | Spirtlarni alkilnitritlarga o‘tkazib bug‘-gaz fazasini tahlil qilish uchuvchanlikni oshiradi; m… | 49 | SUPPORTED | — |
| K.limitations.1 | Yodoform, rezorsin, organik xlor va nitroprussid reaksiyalari guruhga xos: etanol va atseton, x… | 30, 33, 36–37, 42 | SUPPORTED | — |
| K.limitations.2 | Metilsalitsilat hidi etanoldan ham hosil bo‘ladi — distillyatda etanol bo‘lsa, metanol uchun ok… | 41, 185 | SUPPORTED | — |
| K.limitations.3 | Atseton diabet va izopropanol metabolizmida, sirka kislotasi esa organizmda oz miqdorda hosil b… | 31, 33 | SUPPORTED | — |
| K.limitations.4 | Sianid murdada tez kamayadi; salbiy natija iste’mol qilinmaganini isbotlamaydi , [mcallister200… | 28 → 17, 28 | PARTIAL | «Isbotlamaydi» kuchli xulosa — «istisno qilishga yetarli bo‘lmasligi mumkin» deb yumshatildi |
| K.factors.1 | Berlin zangorisi reaksiyasida ortiqcha xlorid kislota reaksiyani sekinlashtiradi; temir gidroks… | 29 | SUPPORTED | — |
| K.factors.2 | Sianid miqdorini aniqlash usuli ob’ekt holatiga bog‘liq: chirimagan ob’ektda argentometriya, ch… | 29 | SUPPORTED | — |
| K.factors.3 | Uchuvchan moddalar uchun ob’ekt tez tahlil qilinadi, distillyatlar tiqinli idishda saqlanadi . | 41, 173 | PARTIAL | «Tez tahlil» kitobda faqat etanol uchun — toraytirildi |
| K.factors.4 | Etanolga tekshiriladigan ob’ektni etil spirti bilan konservatsiya qilish taqiqlanadi; boshqa ho… | 10 | SUPPORTED | — |
| K.factors.5 | Fenol va amil spirti uchun distillyat avval efir bilan ekstraksiya qilinadi — reaksiya sezgirli… | 35, 43 | SUPPORTED | — |
| K.cautions.1 | Sianid tuzlari va distillyatlarini kislota bilan ishlash faqat so‘ruvchi shkafda: zaharli HCN a… | 56 | SUPPORTED | — |
| K.cautions.2 | Izonitril reaksiyasi so‘ruvchi shkafda bajariladi; badbo‘y izonitril oz miqdor sulfat kislota b… | 182 | SUPPORTED | — |
| K.cautions.3 | Xloroform quyosh nurida oksidlanib juda zaharli fosgen hosil qiladi — qorong‘i idishda saqlanad… | 36 | PARTIAL | «Qorong‘i idish» kitobda yo‘q — umumiy laboratoriya talabi deb ajratildi |
| K.cautions.4 | Fenol teriga tushsa kuydiradi va teri orqali tez so‘riladi — qo‘lqop bilan ishlanadi . | 34 | PARTIAL | «Qo‘lqop» kitobda yo‘q — umumiy xavfsizlik talabi deb ajratildi |
| K.cautions.5 | Dixloretanni ampulada qizdirish (bosim ostida) va atsetilenid hosil qilish faqat o‘qituvchi yok… | 39, 183 | SUPPORTED | — |
| K.alternatives.1 | Gaz-suyuqlik xromatografiyasi: sifat — ushlanish parametrlari, standart moddalar bilan solishti… | 48–49 | SUPPORTED | — |
| K.alternatives.2 | Atseton alanga-ionizatsion detektorli GX da aniqlanadi ; spirtlar ham qon, siydik va distillyat… | 34; 49 | SUPPORTED | — |
| K.alternatives.3 | Etilenglikol: mis(II) gidroksid bilan ko‘k kompleks, periodat bilan formaldegidgacha oksidlash … | 46–47 | SUPPORTED | — |
| K.alternatives.4 | Sianid miqdori: argentometrik titrlash (balanslangan: HCN + AgNO3 → AgCN↓ + HNO3) . | 29 | SUPPORTED | — |
| K.alternatives.5 | Fenol miqdori: bromatometriya (balanslangan: KBrO3 + 5KBr + 3H2SO4 → 3Br2 + 3K2SO4 + 3H2O; C6H5… | 35 | PARTIAL | Kitobdagi KBrO3 tenglamasi noto‘g‘ri — «majmuada noto‘g‘ri; balanslangan shakli» deb yozildi |
| L.basis.1 | Pestitsidlar kimyoviy tabiatiga ko‘ra noorganik (mis, mishyak birikmalari), organik va metallor… | 149–150 | SUPPORTED | — |
| L.basis.2 | Fosfororganik birikmalar xolinesteraza fermentini bo‘g‘adi; atsetilxolin gidrolizlanmay to‘plan… | 150–151, 153 | SUPPORTED | — |
| L.basis.3 | Xlororganik birikmalar barqaror, tabiatda uzoq saqlanadi va yog‘ to‘qimasida to‘planadi; ayriml… | 151 | SUPPORTED | — |
| L.scope.1 | Majmuada to‘liq tekshiruvga bir qator FOB (karbofos, metafos, metiletiltiofos, metilnitrofos, t… | 18, 154 | SUPPORTED | — |
| L.scope.2 | Xlororganik birikmalardan geksaxloran (geksaxlorsiklogeksan, uning γ-izomeri — lindan) batafsil… | 156–159 | SUPPORTED | — |
| L.scope.3 | Sintetik piretroidlar (danitol/fenpropatrin, sipermetrin, detsis/deltametrin va boshqalar) — su… | 159–163 | PARTIAL | Ishqoriy gidroliz kitobda sipermetrin uchun — «ayrimlari (masalan, sipermetrin)» deb toraytirildi |
| L.scope.4 | FOB bilan zaharlanishda o‘ziga xos patologoanatomik belgi yo‘q, shuning uchun sud-kimyoviy tahl… | 151 | SUPPORTED | — |
| L.scope.5 | Ob’ektlar: jigar, buyrak, siydik, oshqozon, ichak va xolinesteraza faolligi uchun qon . | dvssm 88 | SUPPORTED | — |
| L.methods.1 | Qo‘shimcha tozalash — sorbentli kolonka yoki YuQX; muqobil — suvsiz natriy sulfat ishtirokida g… | 152 | SUPPORTED | — |
| L.methods.2 | Biologik suyuqliklar (piretroidlar uchun ko‘rsatilgan sxema): qon yoki siydik pH 8–9 ga, to‘qim… | 155–156, 161 | SUPPORTED | — |
| L.methods.3 | Umumiy FOB skriningi | 153–154 | PARTIAL | Kitobdagi fosfomolibdat tenglamasida suv yo‘q — bu aniq ko‘rsatildi |
| L.methods.4 | YuQX bilan tur aniqlash: ajralma plastinkaga 4 nuqta qilib tomiziladi, suv bilan to‘yintirilgan… | 154–155 | SUPPORTED | — |
| L.methods.5 | Xususiy reaksiyalar (misollar) : xlorofos — o-tolidin bilan sariq, ishqor va atseton bilan och … | 156, 265–267 | SUPPORTED | — |
| L.methods.6 | Geksaxloran : suv bug‘i bilan haydash yoki efir bilan bo‘ktirish (faollangan ko‘mir kolonkasida… | 157–159 | PARTIAL | Kitobda «H2O» (3H2O emas) — bu aniq ko‘rsatildi |
| L.advantages.1 | Fosfor-molibden ko‘ki va xolinesteraza testlari juda sezgir: manfiy natija FOB guruhini tez ist… | 153–154 | SUPPORTED | — |
| L.advantages.2 | To‘rt purkagichli YuQX bir plastinkada FOB ning kimyoviy turini (tio/ditiofosfat, nitrofenolli,… | 154–155 | SUPPORTED | — |
| L.advantages.3 | Geksaxloranda ishqor va natriy bilan ajralgan xlor miqdorlarini solishtirish birikma tuzilishin… | 158 | SUPPORTED | — |
| L.advantages.4 | Piretroidlar uchun YuQX, GX va YuSSX sharoitlari ishlab chiqilgan . | 161–163 | SUPPORTED | — |
| L.limitations.1 | Umumiy FOB testlari o‘ziga xos emas: fosfor saqlovchi har qanday modda molibden ko‘kini beradi,… | 153–154 | SUPPORTED | — |
| L.limitations.2 | Ajralmaga yog‘ va yog‘simon moddalar o‘tadi, ayniqsa oshqozon-ichak, jigar va buyrakdan — tozal… | 152 | SUPPORTED | — |
| L.limitations.3 | Majmuaga ko‘ra xlororganik birikmalarning tahlil usullari kam o‘rganilgan; piretroidlar uchun h… | 151–152 | SUPPORTED | — |
| L.limitations.4 | Rf qiymatlari sharoitga bog‘liq; faqat Rf yoki rang asosida identifikatsiya qilinmaydi [dezeeuw… | 155 → 154–155 | PARTIAL | «Rf sharoitga bog‘liq» na kitobda, na de Zeeuw annotatsiyasida — kitob va maqola aytganiga toraytirildi |
| L.limitations.5 | Piretroidlar kuchli ishqoriy sharoitda gidrolizlanadi — ajratishda pH ni nazorat qilish kerak . | 159–160 → 152, 160 | PARTIAL | Faqat sipermetrin haqida — toraytirildi |
| L.factors.1 | pH, organik erituvchi tabiati va bo‘ktirishlar soni ajralish darajasini belgilaydi . | 86–88, 268 | SUPPORTED | — |
| L.factors.2 | Moddaning barqarorligi: fozalon kislotali muhitda chidamli, ishqoriy muhitda tez gidrolizlanadi… | 156, 159–160 → 156, 160 | PARTIAL | Piretroidlar → sipermetrin |
| L.factors.3 | Metabolizm: sevin metaboliti α-naftol bilan birga aniqlanadi; xlororganik birikmalar oksidlanis… | 151, 155, 157 | SUPPORTED | — |
| L.factors.4 | Biologik suyuqliklardan piretroidlarning ajralish darajasi siydik va qonda to‘qimaga nisbatan y… | 162 | SUPPORTED | — |
| L.factors.5 | Xolinesteraza testida ferment manbai sifati va reaksiya vaqti natijaga ta’sir qiladi . | 153–154 | PARTIAL | «Sifati ta’sir qiladi» kitobda yo‘q — standart sharoit (zardob, belgilangan vaqt) deb toraytirildi |
| L.cautions.1 | FOB teri orqali ham so‘riladi; standart eritmalar va ashyoviy dalillar (pestitsid idishlari) bi… | 150 | PARTIAL | «Qo‘lqop va shkaf» kitobda yo‘q — umumiy talab deb ajratildi |
| L.cautions.2 | Majmuadagi ayrim laboratoriya sxemalarida benzol ishlatiladi; benzol kanserogen — iloji bo‘lsa … | 155, 265 | SUPPORTED | — |
| L.cautions.3 | Umumiy testlar (molibden ko‘ki, xolinesteraza) va rangli YuQX natijalari dastlabki hisoblanadi;… | 154 → 153–155 | PARTIAL | Kitob: dastlabki, keyingi tahlilni yo‘naltiradi; instrumental tasdiq — faqat [maurer2004] ga |
| L.alternatives.1 | Majmuada geksaxloran izomerlari va metabolitlari GX, GX-MS va YuSSX usullarida aniqlanishi, miq… | 159 | SUPPORTED | — |
| L.alternatives.2 | Piretroidlar uchun GX (harorat dasturi bilan) va UB detektorli gradiyent YuSSX qo‘llanadi; tasd… | 162–163 → 48, 162–163 | PARTIAL | Standart bilan solishtirish 48-b.da |
| L.alternatives.3 | UB-spektrofotometriyada piretroidlar 260–280 nm sohada yutilish maksimumiga ega — bu yordamchi,… | 163 | SUPPORTED | — |

## Adabiyot iqtiboslari (PubMed annotatsiyasi darajasida)

| Da’vo | Manba | Hukm | Harakat |
|---|---|---|---|
| H.factors: chirishda moddalar parchalanishi/hosil bo‘lishi | skopp2004 ([10.1016/j.forsciint.2004.02.012](https://doi.org/10.1016/j.forsciint.2004.02.012)) | SUPPORTED | — |
| H.factors: umumiy namuna olish tavsiyalari | flanagan2005 ([10.2165/00139709-200524010-00005](https://doi.org/10.2165/00139709-200524010-00005)) | SUPPORTED | — |
| H.factors: umumiy namuna olish tavsiyalari | dinis2010 ([10.3109/15376516.2010.497976](https://doi.org/10.3109/15376516.2010.497976)) | SUPPORTED | — |
| H.alternatives: skrining/tasdiq asosan GX-MS va SX-MS | maurer2004 ([10.1515/CCLM.2004.250](https://doi.org/10.1515/CCLM.2004.250)) | SUPPORTED | — |
| H.alternatives: skrining/tasdiq asosan GX-MS va SX-MS | maurer2010 ([10.1007/978-3-7643-8338-1_9](https://doi.org/10.1007/978-3-7643-8338-1_9)) | SUPPORTED | — |
| I.alternatives: usul validatsiyasi | peters2007 ([10.1016/j.forsciint.2006.05.021](https://doi.org/10.1016/j.forsciint.2006.05.021)) | SUPPORTED | — |
| J.alternatives: rangli reaksiyalar — dastlabki testlar | philp2018 ([10.1002/dta.2300](https://doi.org/10.1002/dta.2300)) | PARTIAL | Maqola giyohvand moddalar spot-testlari haqida — «(giyohvand moddalar misolida)» qo‘shildi |
| J.alternatives: validatsiya | peters2007 | SUPPORTED | — |
| K.scope: sianid murdada/namunada beqaror | mcallister2008 ([10.1093/jat/32.8.612](https://doi.org/10.1093/jat/32.8.612)) | SUPPORTED | — |
| K.limitations: o‘limdan keyingi (mikrobiologik) etanol | kugelberg2007 ([10.1016/j.forsciint.2006.05.004](https://doi.org/10.1016/j.forsciint.2006.05.004)) | SUPPORTED | — |
| K.limitations: o‘limdan keyingi etanol | skopp2004 | SUPPORTED | — |
| K.limitations: salbiy sianid natijasi | mcallister2008 | PARTIAL | «Isbotlamaydi» → «istisno qilishga yetarli bo‘lmasligi mumkin» |
| K.cautions: etanol talqini kontekstda, validatsiyalangan GX | kugelberg2007 | SUPPORTED | — |
| K.cautions: validatsiya | peters2007 | SUPPORTED | — |
| L.limitations: identifikatsiya | dezeeuw1997 ([10.1016/s0378-4347(96)00332-5](https://doi.org/10.1016/s0378-4347(96)00332-5)) | PARTIAL | Annotatsiyada Rf haqida gap yo‘q — «tizimli yondashuv va validatsiyalangan usullar» ga toraytirildi |
| L.cautions: instrumental tasdiq | maurer2004 | SUPPORTED | — |
| L.alternatives: tasdiq GX-MS/SX-MS | maurer2004 | SUPPORTED | — |
| L.alternatives: SX-MS | remane2016 ([10.1016/j.clinbiochem.2016.07.010](https://doi.org/10.1016/j.clinbiochem.2016.07.010)) | SUPPORTED | — |
| L.alternatives: validatsiya | peters2007 | SUPPORTED | — |

Manba: PubMed (annotatsiyalar), DOI havolalari yuqorida.

## Savollar jadvali (34)

| ID | Savol (qisqa) | Javob | Sahifa | Hukm | Harakat |
|---|---|---|---|---|---|
| toks_iso_1 | Uchuvchi zaharlarni suv bug‘i bilan haydashdan oldin ob’ekt odatda nim… | Oksalat yoki vino kislotasi (pH 2,0–2,5) | 25, 172 → 25, 173 | WRONG_PAGE | Sahifa tuzatildi |
| toks_iso_2 | Birinchi distillyat nima uchun ishqor eritmasiga yig‘iladi? | HCN uchmaydigan sianid tuziga o‘tib, yo‘qolmasligi uchun | 26 | SUPPORTED | — |
| toks_iso_3 | Ob’ektni kuchli mineral kislota bilan nordonlashtirish qaysi xatoga ol… | Fenol kon’yugatlari gidrolizlanib «soxta» fenol topilishi | 26–27 | SUPPORTED | — |
| toks_iso_4 | Stas usulini 1856 yilda kim o‘zgartirib, spirtli ajratmani tozalashni … | F. Otto | 94 | SUPPORTED | — |
| toks_iso_5 | Kramarenko usulida alkaloidlar nordon suvli ajratmadan qaysi pH da xlo… | pH 8,5–9 | 95–96 | SUPPORTED | — |
| toks_iso_6 | Qayta ekstraksiya bilan tozalashda qaysi moddalar yo‘qotilishi mumkin? | Kuchsiz asoslar (purin hosilalari, narkotin, antipirin) | 92–93 | SUPPORTED | — |
| toks_min_1 | Nima uchun simob uchun ho‘l mineralizatsiya emas, balki destruksiya qo… | Mineralizatsiyada simob deyarli to‘liq yo‘qoladi | 52, 78 | SUPPORTED | — |
| toks_min_2 | Mineralizatda oksidlovchilar borligi qaysi reaktiv bilan tekshiriladi? | Difenilaminning konsentrlangan sulfat kislotadagi eritmasi (… | 54, 194 | SUPPORTED | — |
| toks_min_3 | Ho‘l mineralizatsiya tugaganini qaysi belgi ko‘rsatadi? | Oksidlovchisiz qizdirilganda qorayish yo‘q va SO3 ning oq bu… | 194 | SUPPORTED | — |
| toks_min_4 | Kasrli usulda Fe(III) ionlari odatda nima bilan niqoblanadi? | Ftoridlar yoki fosfatlar | 55–56 | SUPPORTED | — |
| toks_min_5 | Formaldegid bilan denitratsiyaning balanslangan tenglamasi qaysi? | 4HNO3 + 3CH2O → 4NO + 3CO2 + 5H2O | 54 | SUPPORTED | — |
| toks_min_6 | Nima uchun marganets yoki kadmiy topilganda miqdoriy tahlil majburiy? | Ular organizmda tabiiy mikroelement sifatida uchraydi | 58, 65, 73 | SUPPORTED | — |
| toks_met_1 | Zanger–Blek reaksiyasida mishyak qaysi shaklda ajralib, qog‘ozni bo‘ya… | Arsin (AsH3) gazi holida | 75 | SUPPORTED | — |
| toks_met_2 | Marsh usulida mineralizatni qo‘shishdan oldin nima qilinadi? | Reaktivlar «bo‘sh» tajribada mishyakka tekshiriladi va havo … | 76, 212 | SUPPORTED | — |
| toks_met_3 | Marsh trubkasidagi mishyak dog‘ini surma dog‘idan qaysi sinov ajratadi… | Gipoxlorit eritmasi: mishyak dog‘i eriydi, surmaniki erimayd… | 77 | SUPPORTED | — |
| toks_met_4 | Mineralizat cho‘kmasida qo‘rg‘oshin sulfatni bariy sulfatdan qanday aj… | Sirka kislotali issiq ammoniy atsetat bilan yuvib (PbSO4 eri… | 59, 61 | SUPPORTED | — |
| toks_met_5 | Destruktatda simob mis(I) yodid bilan qanday natija beradi? | Cu2[HgI4] ning qizil-to‘q sariq cho‘kmasi | 79 | SUPPORTED | — |
| toks_met_6 | Kumush va simob ditizonatlari (ikkalasi sariq) qanday farqlanadi? | Suyultirilgan HCl bilan chayqatiladi: kumush ditizonati parc… | 62–63 | SUPPORTED | — |
| toks_met_7 | Marganets kationi mineralizatda qanday aniqlanadi? | Persulfat yoki periodat bilan permanganatgacha oksidlab (pus… | 65 | SUPPORTED | — |
| toks_vol_1 | Birinchi distillyatda sianid qaysi reaksiya bilan aniqlanadi? | Berlin zangorisi hosil bo‘lishi (temir(II) sulfat, so‘ng HCl… | 29, 173 | SUPPORTED | — |
| toks_vol_2 | Qaysi formaldegid reaksiyasi majmuada musbat (o‘ziga xosroq) ahamiyatl… | Kodein va konsentrlangan sulfat kislota bilan ko‘k-binafsha … | 30 → 30, 176 | PARTIAL | 30-b.da «ko‘k-pushti», 176-b.da «ko‘k-binafsha» — 176 qo‘shildi |
| toks_vol_3 | Qaysi modda izonitril reaksiyasini BERMAYDI? | 1,2-dixloretan | 36, 39, 186 → 36, 39 | PARTIAL | 186-b. aloqasiz — olib tashlandi |
| toks_vol_4 | Distillyatda xloroform va xloralgidrat qanday farqlanadi? | Efirli ajralma bug‘latiladi: qoldiqda reaksiya musbat bo‘lsa… | 182–183 | SUPPORTED | — |
| toks_vol_5 | Nima uchun distillyatda etanol bo‘lsa, metanol uchun salitsil kislotal… | Etanol ham o‘xshash murakkab efir hidini beradi; formaldegid… | 40–41 | SUPPORTED | — |
| toks_vol_6 | Fenol bromli suv bilan qanday natija beradi? | Oq tribromfenol cho‘kmasi | 35 | SUPPORTED | — |
| toks_vol_7 | Sianid uchun manfiy natija nima uchun iste’mol bo‘lmaganini isbotlamay… | Sianid murdada va saqlangan namunada tez o‘zgaradi va kamaya… | 28 → 17, 28 | PARTIAL | Parchalanish/o‘zgarish sabablari 17-b.da |
| toks_vol_8 | Majmuada spirtlarni qon va siydikdan GX bilan aniqlashda ichki standar… | Propil spirti (propilnitrit holida) | 49 | SUPPORTED | — |
| toks_pest_1 | Fosfororganik birikmalarning zaharli ta’siri asosan nimaga bog‘liq? | Xolinesteraza bo‘g‘ilib, atsetilxolin to‘planishiga | 150–151 | SUPPORTED | — |
| toks_pest_2 | Fosfor-molibden ko‘ki reaksiyasi nima uchun faqat manfiy ahamiyatli? | Uni fosfor saqlovchi barcha moddalar beradi | 153 | SUPPORTED | — |
| toks_pest_3 | To‘rt purkagichli YuQX da ishqoriy rezorsin bilan qizil dog‘ qaysi bir… | Xlorofos | 155 → 154 | WRONG_PAGE | Xlorofos/rezorsin 154-b.da |
| toks_pest_4 | YuQX da natriy ishqori bilan sariq dog‘ beruvchi FOB larning umumiy tu… | p-Nitrofenol qoldig‘i | 155 → 154 | WRONG_PAGE | p-Nitrofenol/ishqor 154-b.da |
| toks_pest_5 | Xolinesteraza testi bo‘yicha FOB aniqlashga qaysi moddalar xalaqit ber… | Sevin, prozerin, galantamin, alkogol, oqsil parchalanish mah… | 154 | SUPPORTED | — |
| toks_pest_6 | Geksaxloranda spirtli ishqor va metall natriy bilan ajralgan xlor (AgC… | 1:2 (3 va 6 ta xlor) | 158 | SUPPORTED | — |
| toks_pest_7 | Pestitsid skriningining rangli natijasi qanday tasdiqlanadi? | Boshqa tamoyilga asoslangan instrumental usul (GX-MS, SX-MS … | 159, 162–163 → 48, 159, 162–163 | PARTIAL | «SX-MS» kitobda yo‘q — javob «GX, YuSSX yoki GX-MS, standart bilan solishtirib» deb toraytirildi (uch tilda) |

## Tekshirilmagan / cheklovlar

- Kitobning o‘zi xato qilgan joylar REVIEW_TOKS.md da qayd etilgan; bu audit
  ularni qayta ko‘rib chiqmadi, faqat iqtibos atributsiyasini to‘g‘riladi.
- ru/en matnlar uz matnning mashina yordamidagi tarjimasi (`DRAFT`) — mazmun
  uz bilan bir xil tuzatildi, tarjima sifati alohida ko‘rilmadi.
- Maqolalar faqat annotatsiya darajasida tekshirildi (to‘liq matn emas).
- Kartalar `NEEDS_REVIEW`: ilmiy tasdiq faqat vakolatli ekspert-reviewer
  tomonidan beriladi.

## Avtomatik nazorat

`apps/mobile/test/unit/guidelines_content_test.dart`:
- «manba auditi: har bir iqtibos sahifasi kitob chegarasida» — har bir
  `[toks_majmua2025]`/`[dvssm_majmua2025]` iqtibosi uch tilda sahifa bilan
  (1–355 / 1–350), har bir savolda sahifa (1–355);
- «manba auditi: hech bir karta HUMAN_VERIFIED emas» — paket va manba
  fayllarida `HUMAN_VERIFIED` yo‘q, barcha kartalar `NEEDS_REVIEW`.
