# «Toksikologik kimyo» majmuasi asosidagi kartalar — tekshiruv qaydnomasi

Manba: `toks_majmua2025` — Yuldashev Z.A., Umarova G.Q. «Toksikologik kimyo
modulidan o‘quv-uslubiy majmua» (60910700 – Farmatsiya), Toshkent farmatsevtika
instituti, 2025 (2025-26 o‘quv yili, ~355 b.). Qo‘shimcha: `dvssm_majmua2025`
(60911000 yo‘nalishi majmuasi; faqat 14-ma’ruza, 87–88-b. — ob’ekt olish).
Muallifning yozma ruxsati bilan (docs/DECISIONS.md, 2026-10-09); egasi qarori —
bu manbalardan olingan barcha kontent **barcha uchun bepul**.

Sahifa raqamlari — majmuaning bosma sahifalari (PDF sahifa indeksiga teng).
Matn mustaqil, tuzilgan holda yozilgan; uzun iqtiboslar ko‘chirilmagan.
«ABY 2025» materiali ishlatilmagan.

## Yaratilgan kartalar (hammasi `NEEDS_REVIEW`, `access: free`)

| Karta | Fayl | Savollar |
|---|---|---|
| `guideline.chem.toks_isolation` — ajratib olish (suv bug‘i, Stas–Otto, nordonlashtirilgan suv) | `src/card_h_toks_isolation.json` | 6 |
| `guideline.chem.toks_mineralization` — mineralizatsiya, denitratsiya, kasrli usul, destruksiya | `src/card_i_toks_mineralization.json` | 6 |
| `guideline.chem.toks_metal_poisons` — As, Hg, Pb, Ba va boshqalar | `src/card_j_toks_metals.json` | 7 |
| `guideline.chem.toks_volatile_poisons` — sianid, formaldegid, spirtlar, alkilgalogenidlar, fenol | `src/card_k_toks_volatile.json` | 8 |
| `guideline.chem.toks_pesticides` — FOB, xlororganik, piretroidlar | `src/card_l_toks_pesticides.json` | 7 |

Jami 34 ta o‘z-o‘zini tekshirish savoli (kitob testlari ko‘chirilmagan) va 38 ta
termin (`content/tools/toks_terms.py` → `content/pilot/bundle.json`,
`T-TOKS-*`, `machine_draft`).

Ko‘rib chiqilmagan (boshqa agentlar): CO/karboksigemoglobin, UB-spektrofotometriya,
giyohvand moddalar, reaktiv retseptlari. Antidot/davolash mazmuni ataylab yo‘q.

## Tuzatilgan yoki chiqarib tashlangan raqamlar va da’volar

### Xato — chiqarib tashlandi (hech qayerda takrorlanmaydi)
| Joy | Majmuada | Qaror va sabab |
|---|---|---|
| 41-b. | Qonda etanol: 0,01–0,04 ‰ «kayf», 0,05–0,1 ‰ «mast», 0,2 ‰ «o‘ldiradi» | Taxminan bir tartibga xato va «chegara qoida» — **butunlay chiqarildi**. Kartada: o‘ldiruvchi/mastlik chegaralari qoida sifatida berilmaydi; talqin — sud-tibbiy kontekstda, validatsiyalangan GX, o‘limdan keyingi o‘zgarishlar hisobga olinadi. |
| 28-b. | Oltinni sianidlash tenglamalari (H2O2 mahsulot sifatida; balanslanmagan) | Chiqarildi. |
| 29-b. | HCN + AgNO3 → AgCN + 2HNO3; AgCN → Ag + CO2 + NH3 | Birinchisi balanslab berildi (HCN + AgNO3 → AgCN↓ + HNO3); og‘irlik usuli tenglamasi chiqarildi. |
| 29-b. | Berlin zangorisi: 3Na4[Fe(CN)6] + FeCl3 → … | FeCl3 koeffitsienti 4 bilan tuzatildi. |
| 35-b. | KBrO3 + 5KBr + 3H2SO4 → Br2 + … | Tuzatildi: → 3Br2 + 3K2SO4 + 3H2O. |
| 51-b. | Talliy «Tl+2» | Tl(I)/Tl(III) (majmuaning 67-b. ham shunday) — kartada talliy valentligi ko‘rsatilmagan. |
| 59-b. | Ba2+ + K2Cr2O7 + H2O → BaCrO4 … (balanslanmagan) | Chiqarildi (kartada faqat «sariq cho‘kma»). |
| 60-b. | «PbSO4 (surik)» | Surik — Pb3O4; chiqarildi. |
| 62-b. | Pb(C2H5)4 + I2 → PbI2 + 2C4H10 | Kimyosi noto‘g‘ri; chiqarildi (TEQ yod bilan ishlanib noorganik qo‘rg‘oshinga o‘tkaziladi — sifat jihatdan). |
| 62-b. | «100 g ob’ektda 0,3 g TEQ — zaharlanish» | Chegara qoida, tekshirilmagan — chiqarildi. |
| 63–64, 75-b. | «Cu(OH)2 (malaxit)», Parij/Shveynfurt yashili formulalari | Noto‘g‘ri; chiqarildi. |
| 65-b. | Mn periodat oksidlanishida mahsulot «KIO4» | Kartada tenglama berilmagan (to‘g‘risi KIO3); persulfat tenglamasi ham berilmagan. |
| 69, 70-b. | Sb tiosulfat (Na hisobi), Zn3P2 + 3H2SO4 → 2ZnSO4, PH3 + HBrO → H3PO4 + HBr | Balanslanmagan — chiqarildi. |
| 75-b. | HgCl2 + 2KI → HgI2 + 2HCl | Xato (2KCl) — chiqarildi. |
| 77-b. | AsH3 + AgNO3 + H2O → Ag + H3AsO3 + HNO3 | Balanslab berildi: AsH3 + 6AgNO3 + 3H2O → 6Ag + H3AsO3 + 6HNO3. |
| 77-b. | «Qizil simob oksidi (I)», «HgCl — fungitsid» | Xato; chiqarildi. |
| 149-b. | «Fungitsidlar — viruslarga» | Xato (zamburug‘larga); takrorlanmadi. |
| 156-b. | Fozalon «O,O-dimetil» | Fozalon O,O-dietil efiri; nom berilmadi. |
| 265-b. | Karbofos «(1,3-dikarbetoksietil)» | To‘g‘risi 1,2-; nom berilmadi. |
| 158-b. | C6H6Cl6 + 3NaOH → C6H3Cl3 + 3NaCl + H2O | 3H2O bilan tuzatildi. Benzolni trinitrobenzolgacha nitrolash + alkoksid reaksiyasi — kimyosi shubhali, chiqarildi. |
| 40-b. | Metanol qaynash harorati «63 °C» | Adabiyotda ~64,7 °C; raqam berilmadi. |
| 44-b. | Etilenglikol zichligi 1,127 | ~1,113; berilmadi. |
| dvssm 83-b. | Ko‘z shishasimon tanasida glyukoza yo‘q → «suitsid», ko‘p → «qotillik»; agoniyada glyukoza 20–30 marta | Asossiz/xavfli talqin — sud biokimyosi bo‘limi umuman ishlatilmadi. |

### Siyosat bo‘yicha chiqarib tashlandi (o‘ldiruvchi/zaharli doza, chegaralar)
Formalin 60–90 ml, xloroform 5–10 g, dixloretan 15–20 ml, sirka kislota 2–15 g,
metanol 7–8 g / «LD50 30–100 g» / 40–45 % o‘lim, amil spirti 10–15 g,
etilenglikol 50–300 ml, etanol 100–300 g, metall birikmalari LD50 (52-b.),
BaCO3 0,8–0,9 g, Cd 0,03 g, «As va Hg bilan zaharlanish 50 % o‘lim», pestitsid
zaharlilik sinflari va LD50/LC50, havo/suv/tuproq me’yorlari va oziq-ovqat MRL
qiymatlari, kasbiy havo chegaralari (Mn, Cd). Ilova o‘ldiruvchi chegaralarni
qoida sifatida bermaydi.

### Noaniq yoki tekshirilmagan — chiqarildi yoki sifat jihatdan berildi
- Azeotrop tarkibi foizlari (23-b.: xloroform 2,5 %, CCl4 4,1 %, DXE 19,5 %,
  etanol 4,5 %, propanol 28,3 %, fenol 91 %) — aslida azeotropdagi **suv** ulushi,
  ammo matnda noaniq ifodalangan; kartada faqat «azeotrop hosil qiladi».
- «Tabiiy gazda 4–30 % CO» kabi da’volar ushbu kartalarda ishlatilmagan (CO —
  boshqa agent).
- Birinchi distillyat hajmi sahifalar orasida farqlanadi (3 ml / «5 ml gacha») —
  «bir necha ml».
- Aniqlash chegaralari (mkg), Rf qiymatlari, xolinesteraza rang o‘zgarish vaqti
  (13 daqiqa) va «faollik 10 % kamaysa — FOB», ekstraksiya darajasi foizlari,
  GX/YuSSX kolonka va gradiyent parametrlari, solishtirma yutilish qiymatlari —
  sharoitga bog‘liq yoki tekshirilmagan; berilmadi.
- Tarixiy sanalar va nomlar (Nelyubin 1824, «frantsuz» Frezenius va Babo 1844,
  Meyler 1:4, Kaan 1932) — tekshirilmagan, berilmadi. Stas (1851), Otto (1856),
  Uslar–Erdman (1861) qoldirildi (umumiy ma’lum).
- Me’yoriy hujjatlar, buyruq raqamlari va sanalari (13–14-b.; dvssm 85–86-b.) —
  yurisdiksiyaga xos, rasmiy matn bilan solishtirilmagan — kartalarga kiritilmadi.
- Organlardagi «normal» Mn/Cd miqdorlari (ikkilamchi mualliflarga havola) —
  sifat jihatdan («tabiiy mikroelement») berildi.

## Tekshirilgan va saqlangan (balanslangan) tenglamalar
- 4HNO3 + 3CH2O → 4NO + 3CO2 + 5H2O; CO(NH2)2 + 2HNO2 → CO2 + 2N2 + 3H2O
- 5CH3OH + 2KMnO4 + 3H2SO4 → 5HCHO + K2SO4 + 2MnSO4 + 8H2O
- 3C2H5OH + K2Cr2O7 + 4H2SO4 → 3CH3CHO + K2SO4 + Cr2(SO4)3 + 7H2O
- Fe(CN)2 + 4NaCN → Na4[Fe(CN)6]; 3Na4[Fe(CN)6] + 4FeCl3 → Fe4[Fe(CN)6]3 + 12NaCl
- H3PO4 + 12(NH4)2MoO4 + 21HNO3 → (NH4)3PO4·12MoO3 + 21NH4NO3 + 12H2O
- Pb(NO3)2 + K2CrO4 → PbCrO4 + 2KNO3

## Ekspert ko‘rigi uchun ochiq savollar
1. To‘rtxlorli uglerod izonitril reaksiyasini beradimi? Majmuada (36-b.) «beradi»
   deyilgan, ba’zi manbalar boshqacha — kartada CCl4 bu reaksiya ro‘yxatiga
   kiritilmagan.
2. Laboratoriya sxemalarida benzol (sevin, karbofos) — xavfsizroq erituvchi bilan
   almashtirish tavsiyasi kartada umumiy xavfsizlik talabi sifatida berilgan.
3. Rus va ingliz matnlari — mashina yordamidagi qoralama (`DRAFT`).
