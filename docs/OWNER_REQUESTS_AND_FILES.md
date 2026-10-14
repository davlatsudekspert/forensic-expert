# Egasi yozgan hamma narsa va yuborgan fayllar — audit uchun yagona ro‘yxat (2026-10-14)

> Shanba auditi shularning HAMMASINI hisobga oladi: har bandni amaldagi holat bilan solishtirib, BAJARILGAN / QISMAN / BAJARILMAGAN deb ajratadi. Manbalar: `docs/HISOBOT_2026-10-11_12.md`, `docs/SHANBA_REJA_2026-10-17.md`, `docs/MASTER_PROMPT_AUDIT_2026-10-17.md`, `CLAUDE.md`, git tarixi.

## 1. Egasi yuborgan fayllar (kitoblar va hujjatlar)
| Fayl | Nima | Ilovada holati |
|---|---|---|
| ABY 2025 (`ABY_2025.05.19.doc`, 26 MB) | milliy amaliyot yo‘riqnomasi | 94 yozuv uz-only, bepul; faylning o‘zi repoda yo‘q (qoida) |
| Yuldashev, «Giyohvand moddalar tahlili» 2024 (Drive PDF) | darslik | 47 modda uchun usul yozuvlari; 17+ modda kitobda bor, ilovada usuli yo‘q; kitobdagi barcha moddalar inventarizatsiyasi tugamagan |
| Yuldashev, Umarova, «Toksikologik kimyo» majmua 2025 (Drive PDF) | o‘quv-uslubiy majmua | qisman; ~1M belgi, to‘liq inventarizatsiya tugamagan |
| Ғиёсов, «Суд тиббиёти» 2018 (Google Hujjat) | darslik | taxminan 80 betgacha o‘qilgan; keyingi boblar olinmagan |
| Искандаров 2009 (Drive) | darslik | taxminan 80 betgacha; keyingi boblar olinmagan |
| `КЛД_ихтисослаштириш…doc`, `7289cd98-…doc` | boshqa hujjatlar | holati audit paytida tekshiriladi |
| 4 ta dars jadvali (`docs/curriculum/`) | sud tibbiyoti fakulteti | matn saqlangan; ilovaga kiritilmagan |
| Skrinshotlar (TestFlight, profil, THC-COOH, rus «yopiq katalog», ABY to‘xtam namunasi) | xatolar va misollar | tegishli xatolar tuzatilgan yoki rejaga yozilgan |

## 2. Egasining talablari (suhbat bo‘yicha, vaqt tartibida)
1. Admin paneldan istalgan pochtaga Pro sovg‘a (bajarildi; ikkinchi hisob bilan real sinov yo‘q).
2. iOS/Android test build, App Store Connect/Play topshiriq matni (build 188 = 0.3.0+11; yangi o‘zgarishlar build’ga chiqmagan).
3. Profil sahifasi sifati; profil rasmi — faqat telefonda (kodda tayyor, build’ga chiqmagan).
4. **Har modda/mavzu sahifasi to‘liq**: avval ustoz kitoblari (Giyasov, Iskandarov, Yuldashev), keyin ABY, keyin jahon adabiyoti; har da’voda aniq manba va joy. Moddada: metabolit, qon/siydik/ichki a’zo bo‘yicha aniqlash.
5. ABY tartibi hamma moddaga: ekspress → ajratish → rangli → TLC → GC-MS/LC-MS/MS → spektrofotometriya → namunalar; ABY ob’ekti (qon/siydik/organ) aniq; reaktivlarni tayyorlash (miqdorlari bilan) — manba sahifalari kerak.
6. «Tasdiqlangan manba» = ABY va ustoz kitoblari; xorijiy maqola/tezis = «tasdiqlash kerak»; uch qatlam: ABY → kitob → qo‘shimcha adabiyot (GC-MS/LC-MS, sud-tibbiy holatlar).
7. Tergovchi savollari/o‘lim sababi savollari Pro’ga (5 ta Ғиёсов asosida, bajarildi).
8. Ustoz Pro (ilova ichida slaydlar) — faqat reja; dars jadvali olinishi bilan boshlanadi.
9. Kitobdagi HAMMA modda (ilovada yo‘qlari ham) va usullar o‘zbekcha mukammal; RU/EN keyingi hafta; keyin qozoq/tojik/qirg‘iz.
10. Maqola/tezislardan GC-MS/LC-MS usullari hamma moddaga; sud-tibbiy holatlar.
11. Jahon bozori: «fishkalar», narx, reja (`docs/GLOBAL_GROWTH_PLAN.md`, bajarildi); shanba rejasi.
12. 6 ta rolik (haqiqiy ilovadan); oddiy, sodda tushuniladigan qayta yozish — keyinga qoldirildi, avval 1–2 tasini ko‘rib fikr bildiradi.
13. Rus tilida «Коды практик Узбекистана (закрыто)» kartasi va yurisdiksiya qulfi — tekshirish (`docs/SHANBA_REJA_2026-10-17.md` 5-bo‘lim).
14. Sud tibbiyoti dars jadvali → LabGuide kabi bo‘lim + test + PPTX (shanbadan keyin).
15. Model/limit qoidalari: Fable yo‘q, Sonnet asosiy, Opus faqat murakkab; limitni tejash; «MA’QULLAYMAN, BOSHLANG»dan oldin implementatsiya yo‘q.
16. Mayda kamchiliklarni egasi o‘zi topib yozadi; kattalari shanbaga.

## 3. Ma’lum ochiq holat (2026-10-14)
- Kitoblar inventarizatsiyasi (2 yordamchi) natijasi tayyor emas.
- Yangi test build yuborilmagan; CI’ning oxirgi natijasi ko‘rilmagan (golden yangilangan).
- Real telefonda STUDENT/EXPERT/ADMIN sinovi, real xarid va real OTP sinalmagan.
