# FORENSIC EXPERT — birinchi bosqich audit hisoboti (2026-10-17)

> Bosqich: **faqat audit, hisobot va takliflar** (`docs/MASTER_PROMPT_AUDIT_2026-10-17.md`, 13-bo‘lim, 12 qism).
> Branch `claude/phase-8-12-final-release`, HEAD (audit boshida) `0b09c79`.
> Bu bosqichda kod, kontent bazasi, migratsiya, deploy, build, to‘liq test va implementatsiya agentlari **ishlatilmadi**. Yagona yozuv: shu hujjat.
> Model: Sonnet (CLAUDE.md qoidasi). Hisobot mavjud hujjatlar va kichik maqsadli tekshiruvlarga tayanadi; kitoblar qayta o‘qilmadi.
> Egasining «MA’QULLAYMAN, BOSHLANG» ruxsati hali **yo‘q** — quyidagi hamma narsa taklif.

---

## 0. Egasining yangi ko‘rsatmalari (2026-10-17) — qaror va cheklovlar sifatida qabul qilindi

| # | Ko‘rsatma | Qanday qabul qilindi |
|---|---|---|
| Q-1 | Drive papkasi `1rir6q-B7wz1KizctHCWaWUDmIySGKC3Y` — fakultetlarning dars jadvallari va prezentatsiya adabiyotlari | Papka ro‘yxati (faqat metadata) olindi, 4-bo‘limda o‘quv rejaga bog‘landi. Hech narsa yuklab olinmadi. |
| Q-2 | Sud toksikologiyasi: **ABY aynan o‘z holicha qoladi** (tegilmaydi). Manba tartibi: **1) ustoz kitobi, 2) Karamarenko (Kramarenko turidagi toksikologiya) darsligi** — aniq bet va nom bilan keltirishga ruxsat | Egasi ruxsati sifatida qayd etildi. **Lekin bu darslik hali berilmagan va o‘qilmagan** → «ADABIYOT KUTILMOQDA» ro‘yxatiga (5-bo‘lim). Bet raqami to‘qilmaydi. Eslatma: repoda faqat «Kramarenko usuli» (pH 2–3 ajratish) haqida eslatma bor (`content/guidelines/src/card_h_toks_isolation.json`, `docs/qa/TOKS_SOURCE_AUDIT.md`) — bu darslikdan olingan emas, kitob sifatida kiritilmagan. |
| Q-3 | Til tartibi: **avval o‘zbekcha** | CLAUDE.md «Til tartibi» (2026-10-12) bilan mos; RU/EN keyingi hafta, so‘ng qozoq/tojik/qirg‘iz. Hamma yangi taklif shu tartibda. |

Cheklov: yangi manba (Karamarenko, Drive adabiyotlari) uchun «manba avval, kontent keyin» — o‘qilmagan kitobdan sahifa/iqtibos yo‘q.

---

## 1. Loyihaning hozirgi haqiqiy holati

### 1.1. CI (GitHub Actions) — halol holat
Branch bo‘yicha **eng oxirgi** run (HEAD `0b09c79`, 2026-10-14; undan keyin yangi run yo‘q):

| Workflow | Natija |
|---|---|
| **CI** (#194) | **FAILURE** |
| Release build (#201) | success |
| (oldingi `31769ec` Release build #200) | cancelled (keyingi push bekor qilgan) |

CI ichida: migration/RLS testlari, Deno, gitleaks, OSV, secrets-inventory — **success**; claim-source audit, gen-l10n drift, format, analyze (packages+app), Dart paket testlari — **success**. Muvaffaqiyatsiz: faqat «Test (app)» bosqichi: **2868 o‘tdi, 2 ta yiqildi, 1 skip**. Qaysi 2 ta test ekani log oxiridan ko‘rinmadi (to‘liq log yuklanmadi — limit tejash). Taxmin (tasdiqlanmagan): `HISOBOT_2026-10-11_12.md` va OWNER_REQUESTS ham «golden yangilangan, CI natijasi ko‘rilmagan» deydi, shuning uchun golden/son testlari ehtimoli yuqori. **Hozircha CI yashil deb aytib bo‘lmaydi.** Birinchi tasdiqlangan ishda: 2 testni aniqlash.
Eslatma: Release build “success” CI yashil degani emas (alohida workflow).

### 1.2. Umumiy holat jadvali
Manbalar: `PROJECT_STATUS.md` (2026-10-08, qisman eskirgan), `HISOBOT_2026-10-11_12.md`, `SHANBA_REJA`, `OWNER_REQUESTS_AND_FILES.md`. Aniq sonlar shu hujjatlardagi qiymatlar; bugun qayta sanalmadi.

| Soha | Holat | Dalil |
|---|---|---|
| Ilova (Home, kutubxona, qidiruv, AI, kalkulyatorlar, yo‘riqnomalar, admin, Savol-javob) | TAYYOR (avtomatik testlar), real qurilmada **sinalmagan** | 2860–2870 test; analyze toza (3 kun oldin) |
| Kontent paketi | 137 modda; ABY 92 da’vo/39 mavzu uz-only bepul; 47 moddada kitob usul yozuvlari (55 moddada mahalliy usul hujjatlashtirilgan, 82 moddada yo‘q) | SUBSTANCE_METHODS_COVERAGE, ABY_COVERAGE |
| Ilmiy taqriz | HUMAN_VERIFIED = 0 (hammasi NEEDS_REVIEW) | PROJECT_STATUS |
| Lokalizatsiya | Interfeys 3 til; yangi kontent faqat uz (qaror); 883 tadqiqot sarlavhasi tarjimasi yo‘q | PROJECT_STATUS |
| Billing | **Server xarid tekshiruvi (RG-18) yo‘q**, do‘konda mahsulotlar yaratilmagan, real xarid sinalmagan | PROJECT_STATUS, SHANBA_REJA |
| AI (`ai-answer`) | Deploy qilingan (v5); **kvota yo‘q** (hamma uchun 30/soat); real E2E qaydi yo‘q | SHANBA_REJA 5-blok |
| Build | Oxirgi tarqatilgan: **188 = 0.3.0+11**; yangi o‘zgarishlar (profil rasmi, uch qatlam «Tahlil») build’ga chiqmagan; **yangi test build yuborilmagan** | OWNER_REQUESTS |
| Real qurilma sinovi | **Hech qachon qilinmagan** (STUDENT/EXPERT/ADMIN, iOS, real OTP, xarid) | HISOBOT 5-bo‘lim |

---

## 2. Oldingi topshiriqlar bilan solishtirish — hamma eski vazifa, 7 belgi bilan

Belgilar: **[OK]** BAJARILGAN VA SINOVDAN O‘TGAN (avtomatik) · **[REAL]** BAJARILGAN, LEKIN REAL SINOV TALAB · **[QISMAN]** · **[YO‘Q]** BAJARILMAGAN · **[XATO]** XATOSI BOR · **[ADAB]** QO‘SHIMCHA ADABIYOT KERAK · **[QAROR]** EGASINING QARORI KERAK.
Eslatma: «[OK]» faqat avtomatik test ma’nosida; real qurilma sinovi hech qaysida yo‘q (CLAUDE.md talabi bo‘yicha u alohida bosqich).

| # | Vazifa | Belgi | Izoh |
|---|---|---|---|
| 1 | Admin paneldan istalgan pochtaga Pro sovg‘a | [REAL] | Kod+3 widget test bor; ikkinchi haqiqiy hisob bilan «u odam Pro ko‘rdi» sinalmagan. Ikkinchi admin/sinov hisobi kerak [QAROR] |
| 2 | iOS/Android test build, App Store Connect matni | [QISMAN] | 168/179/182/188 yuborilgan; yangi o‘zgarishlar build’da yo‘q; Play grafikasi qo‘lda |
| 3 | Profil sahifasi sifati / profil rasmi (faqat telefonda) | [REAL] | Kodda tayyor, push qilingan, build’ga chiqmagan, ekranda ko‘rilmagan |
| 4 | Har modda/mavzu to‘liq (kitob → ABY → jahon adabiyoti) | [QISMAN] | Eng katta kamchilik: metabolit 15/137, biomarker 1/137, namuna 54/137, konsentratsiya 54/137 (SUBSTANCE_COVERAGE_AUDIT, 10-11 holati; keyin qisman yaxshilangan) |
| 5 | ABY tartibi (ekspress→ajratish→rangli→TLC→GC-MS→spektrofotometriya→namuna) hamma moddaga | [QISMAN] | 328 ABY bog‘lama; «Ob’ekt» 56/94 yozuvda aytilgan, 38 tasida ABYda yo‘q (taxmin qilinmadi); reaktiv tayyorlash miqdorlari: 94 dan 9 tasida iz, 76 retsept ABYniki emas → ABY bo‘limining sahifalari kerak [ADAB] |
| 6 | «Tasdiqlangan manba» = ABY + ustoz kitoblari; xorijiy = «tasdiqlash kerak»; uch qatlam | [REAL] | «Tahlil» uch qatlami kodlangan va push qilingan; ekranda real ko‘rilmagan |
| 7 | Tergovchi savollari (5 ta, Ғиёсов) Pro’da | [OK] | Mavjud Pro darvozasi, test bor |
| 8 | Ustoz Pro (ilova ichida slaydlar) | [QAROR] | Faqat reja (`USTOZ_PRO_PLAN.md`), 6 qaror kutilmoqda (PPTX yo‘li, 18+, narx, monitor, birinchi dars, yurist) |
| 9 | Kitobdagi HAMMA modda va usul o‘zbekcha mukammal | [QISMAN] | 47/140 moddada kitob usul yozuvi; kitobda nomlangan ~17 moddada usuli yo‘q; ilovada umuman bo‘lmagan kitob moddalari ko‘p; inventarizatsiya (2 yordamchi) natijasi **tayyor emas/olinmagan** |
| 10 | Maqola/tezislardan GC-MS/LC-MS usullari hamma moddaga; sud-tibbiy holatlar | [YO‘Q] | Keyingi haftaga ko‘chirilgan |
| 11 | Global o‘sish/narx/fishkalar rejasi | [OK] | `GLOBAL_GROWTH_PLAN.md` hujjat sifatida bajarilgan; narx zinasi egasi qarorini kutadi [QAROR] |
| 12 | 6 ta rolik | [QAROR] | Qoldirilgan; egasi 1–2 tasini ko‘rib fikr bildiradi |
| 13 | Rus «Коды практик Узбекистана (закрыто)» kartasi + yurisdiksiya qulfi | [XATO] | Karta faqat admin’da, ABY ochiq bo‘lgach «yopiq/import» matni eskirgan; yurisdiksiyaga bog‘liq emas; qaror: olib tashlash yoki «Ichki katalog (admin)» [QAROR] |
| 14 | Fakultet dars jadvali → LabGuide kabi bo‘lim + test + PPTX | [QISMAN] | Matn repoda (`docs/curriculum/`, 4 fayl), ilovaga kiritilmagan; adabiyot egasidan [ADAB] |
| 15 | Model/limit qoidalari | [OK] | CLAUDE.md’da; shu audit unga amal qildi |
| 16 | Ғиёсов 2018 / Искандаров 2009 | [QISMAN] | ~80-betgacha o‘qilgan; keyingi boblar (zaharlanish, asfiksiya, PMI, o‘lim sababi) olinmagan; Drive’da to‘liq PDF’lar endi bor (4-bo‘lim) [ADAB] |
| 17 | Yuldashev GMT-2024 va Toksikologik kimyo 2025 | [QISMAN] | Ruxsat bor (DECISIONS); ~1M belgi, to‘liq inventarizatsiya tugamagan |
| 18 | Savol-javob (Hamjamiyat) bo‘limi | [REAL] | 7 jadval/12 RPC/2 Edge fn/24 Deno test; ommaviy nashrda o‘chiq (`FE_QA`); real foydalanuvchilar bilan sinalmagan |
| 19 | «Sudda so‘roq: tayyorgarlik» | [REAL] | Mavjud, Pro darvoza; Gemini real javob+iqtibos E2E qaydi yo‘q |
| 20 | Google/AI kvotasi (bepul/Pro) | [YO‘Q] | `ai-answer` hamma uchun bir xil limit; deploy egasi tasdig‘i bilan |
| 21 | Xarid oqimi (RG-18, 4 obuna, restore) | [YO‘Q] | Server tekshiruvi yo‘q, mahsulotlar do‘konda yaratilmagan, narx qarori kerak [QAROR] |
| 22 | Bepul/pullik chegarani kengaytirish (har bo‘limda 3 yozuv) | [QAROR] | GLOBAL_GROWTH_PLAN tavsiyasi; egasi roziligi kerak |
| 23 | Qalqib turuvchi klaviatura, kichik ekran (320dp) tuzatishlari | [OK] | Arxitektura testi + 74 ekran×2 o‘lcham; (telefonda ko‘rilmagan) |
| 24 | Maqola sahifasida bo‘sh «Jurnal» qatori | [OK] | Ildizi tuzatilgan, butun baza skanerlanadi |
| 25 | Fenazepam kartasida nasha plastinkasi | [OK] | Tuzatilgan |
| 26 | Simob/sirka kislotasi/ammiak moddalari | [QISMAN] | Faqat identifikatsiya + ABY havolasi; to‘liq dossier yo‘q |
| 27 | Butan 1→7 yozuv | [OK] | |
| 28 | To‘mtoq jism jarohati (6 yozuv) | [OK] | |
| 29 | Ilmiy taqriz (HUMAN_VERIFIED) | [QAROR] | 0 ta; vakolatli reviewer topish egasi/muassasa qarori |
| 30 | Production E2E closeout (Supabase, OTP, Gemini, referral, imzolangan build) | [REAL] | Hech biri real qurilma/real xarid bilan tasdiqlanmagan; Resend domeni tasdiqlanmagan (OTP spam), Android release keystore, kontent imzo kaliti — egasi |
| 31 | Rasmli ilmiy kontent (TLC plastinka, spektr, xromatogramma) | [QISMAN] | Metod rasmlari bor (`l10n_method_images`), lekin tizimli «haqiqiy surat vs. o‘quv sxemasi» ajratish va manba bog‘lash yo‘q (6-bo‘lim) |
| 32 | App Store 6.9" skrinshotlar / Play matnlari | [QAROR] | Chiqarishga ruxsat/qo‘lda ish |

---

## 3. Takroriy ishlar (qaytadan qilinmaydi)

- Admin Pro sovg‘a paneli, tergovchi savollari, Savol-javob moduli, Henssge, 12 kalkulyator, klaviatura/kichik ekran tuzatishlari.
- ABY 94 yozuv (uz-only, bepul, «Ob’ekt» qatori, 328 bog‘lama) — **ABY tegilmaydi** (Q-2).
- Dizayn tizimi, 3 tilli interfeys, offline paket imzolash (development kalit).
- Global o‘sish/narx hujjati; Ustoz Pro reja hujjati; kitob usul yozuvlari (326 yozuv, 47 modda) — qayta yaratilmaydi, yangi manba bilan boyitiladi.
- Uch qatlamli «Tahlil», profil rasmi kodi — qayta yozilmaydi, faqat real sinov va build.

---

## 4. Qolgan kamchiliklar

### 4.1. Ilmiy kontent
1. Kitob modda inventarizatsiyasi tugamagan: 47/140 moddada usul yozuvi; ~17 ta nomlangan moddada yo‘q; ilovada umuman bo‘lmagan kitob moddalari ko‘p (to‘liq ro‘yxat yo‘q).
2. Modda dossiyesi: metabolit 15/137, biomarker 1/137, namuna va konsentratsiya 54/137, tasdiqlovchi usul bog‘lamasi 0/137 (GC-MS/LC-MS skrining orqali ko‘rinadi — 2-xato eslatmasi).
3. Eng bo‘sh moddalar: butane (yaxshilangan), colchicine, etonitazene, etonitazepyne, nitrous oxide (1 yozuv).
4. Sud-tibbiyot: Ғиёсов/Искандаров qolgan boblari; Drive’dagi ko‘plab yangi darsliklar (4-bo‘lim) hali o‘qilmagan.
5. Sud-gistologiya, sud-biologiya/genetika, antropologiya, odontologiya: fan taksonomiyasi bor (26 fan), kontent yo‘q yoki juda kam; ABYda bo‘lmagan 13 mavzuga ota-yozuv yo‘q.
6. HUMAN_VERIFIED = 0.

### 4.2. Tarjima
- Yangi kontent faqat uz (qaror); RU/EN keyingi hafta. 883 tadqiqot sarlavhasi tarjimasi yo‘q. «Tarjima kutilmoqda» belgisi mexanizmi qaror bilan kelishilgan, haqiqiy to‘liqligi tekshirilmagan.

### 4.3. Rasmlar/testlar/metodikalar
- Testlar: quiz va flashcards production’da bo‘sh/MOCK (PROJECT_STATUS 10-08; keyingi holat tekshirilmagan).
- Metodika: nomi bor, ammo «nima uchun, prinsipi, bosqichlar maqsadi, cheklovlar, QC» tuzilmasi hamma metodda emas; reaktiv tayyorlash ABY sahifalarisiz to‘ldirilmaydi.

### 4.4. Ta’lim
- Dars jadvali ilovada yo‘q; Ustoz Pro faqat reja.

### 4.5. Texnik
- CI qizil (2 test); yangi build yo‘q; AI kvota yo‘q; RG-18 yo‘q; Resend domeni; Android keystore; real qurilma sinovi; rus “yopiq katalog” kartasi va yurisdiksiya qulfi.

---

## 5. Yangi adabiyotlar rejasi

### 5.1. Qabul qilish tartibi (har kitob uchun)
Kataloglash yozuvi (muallif, to‘liq nom, yil, nashriyot, bob, bet, asl til, huquq, qaysi mavzuni to‘ldiradi, mavjud kontent bilan moslik) → mavjud kontent bilan solishtirish (takror yaratmaslik, yangi dalil bilan boyitish; zid bo‘lsa farq izohlanadi) → mavjud `SRC-*` manba tizimi orqali kiritish (qayta import yo‘q). O‘qilmagan kitobdan bet/iqtibos to‘qilmaydi. Ruxsat holati har kitobda yoziladi.

### 5.2. «ADABIYOT KUTILMOQDA» ro‘yxati
| Adabiyot | Holat | Nima kerak |
|---|---|---|
| **Karamarenko (Kramarenko) toksikologiya darsligi** (sud toksikologiyasi; ustoz kitobidan keyingi 2-o‘rin) | **Berilmagan, o‘qilmagan.** Egasi bet+nom bilan keltirishga ruxsat bergan (Q-2) | Fayl/havola + to‘liq bibliografiya (muallif, nom, yil, nashriyot). Shundan keyingina bet bilan kiritiladi |
| Ғиёсов 2018 va Искандаров 2009 — 80-betdan keyingi boblar | Qisman | Google Hujjat sifatida (ulagich >10 MB bermaydi) yoki bob-bob matn; Drive’da PDF bor (98 MB va 6.8 MB) — metadata ko‘rilgan, o‘qilmagan |
| ABY sud-kimyo bo‘limi sahifalari (reaktiv tayyorlash) | Yo‘q | Faqat o‘sha sahifalar; ABY o‘zi tegilmaydi (Q-2) |
| Ustoz Pro uchun dars jadvallari | Bor (docx, Drive) | O‘qib mapping (4-bo‘lim) |
| Boshqa fanlar (gistologiya, biologiya, genetika, morfologiya, patanatomiya, antropologiya, odontologiya, tibbiy-kriminalistika) | Egasi keyin beradi | Sud-gistologik PDF Drive’da bor (4-bo‘lim) |
| Maqola/tezislar GC-MS/LC-MS hamma moddaga | Keyingi hafta | PubMed MCP orqali manba qidirish mumkin; tanlov egasi bilan |

---

## 6. Vizual ilmiy kontent — taklif

Muammo: rasm bor, lekin haqiqiy laboratoriya surati va AI/o‘quv sxemasini ajratuvchi tizim, TLC/Rf/spektr jadvali standarti yo‘q.
Taklif (minimal yangi qism, mavjud `method_images` va claim-source tizimi ustiga):
1. Har tasvirga majburiy maydon: `image_kind` = `real_photo` | `source_figure` | `schematic` (AI/o‘quv sxemasi), `source_id`+`locator`, `license`. UI: sxemada doimiy «O‘quv sxemasi — haqiqiy natija emas» belgisi. AI yaratgan sxema hech qachon real natija deb ko‘rsatilmaydi.
2. **Rf jadvali** (bitta universal Rf yo‘q): har qator = modda × sistema (harakatchan faza) × plastinka/sorbent × vizualizatsiya × Rf × manba+bet. Manbasiz Rf, cho‘qqi, spektr va rang qo‘shilmaydi (hozirgi qoidaga mos).
3. Spektr/xromatogramma: faqat litsenziyali (UNODC/SWGDRUG, o‘zimizning ruxsatli kitoblar, ochiq litsenziyali) manbadan; aks holat «ma’lumot kutilmoqda».
4. Fan bo‘yicha qoliplar: gistologiya — preparat+bo‘yash+artefakt yonma-yon; sud-tibbiyot — jarohat tasnifi/PMI diagrammalari; sud-biologiya — serologiya/DNK bosqich sxemalari; sud-kimyo — rang reaksiyalari+TLC+GC/LC.
5. Huquq: Pigolkin atlasi (271 MB) kabi darslik rasmlarini ilovaga ko‘chirish — muallif/nashriyot ruxsatisiz **tavsiya etilmaydi**; havola+mazmun o‘z so‘zimiz bilan.

---

## 7. Ustoz–talaba rejasi (fakultet o‘quv dasturlari asosida)

Mavjud: `docs/curriculum/` 4 fayl (4-kurs davolash 442 qator, 4-kurs pediatriya 376, 5-kurs tibbiy profilaktika 396, 6-kurs davolash 386). Dars nomlari «№N. Ma’ruza … Amaliy mashg‘ulot …» ko‘rinishida, SSV 180-son buyrug‘i (MP A-1…28) va PQ-270 (08.09.2025) havolalari bilan.

**Drive papkasi (Q-1) mazmuni va o‘quv rejaga xaritalash** — metadata asosida (faylllar o‘qilmagan):

| Guruh | Fayl(lar) | Vazifa |
|---|---|---|
| Sud tibbiyoti jadvallari (.doc, ilovadagi nusxalar) | `4-kurs davolash.doc`, `4-kurs pediatriya.doc`, `5-kurs tibbiy profilaktika.doc`, `6-kurs davolash.doc` | `docs/curriculum/*.txt` ning manbasi; mapping asosi |
| **Yangi** 2026 ИД ish rejalari (docx, 2026-10-16) | `2026 ИД Sud_tibbiyoti узб леч фак`, `… пед фак`, `… стом фак` | Ilovada yo‘q yangi jadvallar: davolash, pediatriya, **stomatologiya** fakulteti — o‘qilib mavzular solishtiriladi (stomatologiya yangi, odontologiya bilan bog‘lanadi) |
| Bioetika dars jadvallari | `биоэтика 2026 ИД узб 2 курс леч/пед фак`, `биоэтика узб КТП` | **Yangi fan (bioetika)** — hozir ilovada yo‘q; alohida fan sifatida egasi qaroriga [QAROR] |
| Bioetika adabiyotlari | Юлдашев 2019; Ғиёсов 2022 (308 b., docx+pdf); Мухамедова 2021 (darslik); `Bioetika muxamedov.docx`; Ғиёсов «Vrach faoliyatining huquqiy asoslari» 2012 | Bioetika fani va huquqiy mavzular uchun |
| Bioetika prezentatsiyalari | `Bioetika_3_mavzu_taqdimot.pptx`, `Biotibbiy_etika_asoslari_ZQ_Xakimov.pptx` | Ustoz prezentatsiya uslubi/mazmuni namunasi |
| Sud-tibbiyot darsliklari | Giyosov 2018; Iskandarov; Жалолов 1996 (uz); Тагаев; Пашинян/Харин (ред.); Харин «Краткий курс»; Пиголкин atlas 2010; Ромодановский «в схемах и рисунках» | Mavzu → manba bog‘lash; rasmli slaydlar uchun (huquq bilan, 6-bo‘lim) |
| Morfologik toksikologiya | Пиголкин «Морфологическая диагностика наркотических интоксикаций»; Пиголкин/Баринов/Богомолов; Дмитриева ва b. (.doc) | Sud-tibbiy toksikologiya + gistologiya ko‘prigi |
| Sud-gistologiya | `Sud-gistologik.pdf` (77 MB) | Gistologiya fani uchun asosiy manba, o‘qilmagan |

(Papkada jami 30 fayl: 5 + 25 ikki sahifada ro‘yxatlandi; 6 ta ish jadvali/ИД docx, 4 ta eski .doc jadval, 2 pptx, qolgani kitoblar.) Karamarenko darsligi papkada **yo‘q**.

**Taklif etilgan struktura** (mavjud `learn` bo‘limi va Pro darvozasi ustiga; yangi tab yo‘q):
- Dars = jadvaldagi mavzu (№) → ma’ruza+amaliy → slaydlar → ustoz eslatmalari → manbalar (kitob/bet) → test (har savol manbali) → dars yakuniy bahosi.
- Birinchi pilot: **bitta fakultet, 1–2 mavzu** (masalan sud tibbiy tanatologiya, PMI — ilovada Henssge/PMI kontenti bor) — keyin kengaytirish.
- Real imkoniyat/cheklovlar (USTOZ_PRO_PLAN bilan mos): PPTX Edge Function’da aylanmaydi (variant a: ustoz o‘zi PDF/PNG yuklaydi, pul ketmaydi); iOS skrinshotni bloklab bo‘lmaydi (faqat yozuv sezish, suv belgisi, jurnal); Android FLAG_SECURE ishlaydi; AirPlay/HDMI ko‘zgu rejimi; Google Cast — alohida plagin va xarajat, v1 uchun tavsiya etilmaydi; brauzer/to‘liq ekran — bepul. Ilova ichida taqdimot ochiladi, oddiy foydalanuvchi PPTX/PDF yuklab olmaydi (avvalgi talab saqlanadi).

---

## 8. Sifat va ishonchlilik

- «TASDIQLANMAGAN» belgisini 4 darajaga ajratish (UI taklifi): «Ilmiy manbasi mavjud» → «Manbadagi joyi tekshirilgan» → «Ilmiy taqrizdan o‘tgan» → «Qo‘shimcha tekshiruv kerak (aniq jihat)». Ichki `NEEDS_REVIEW`/`HUMAN_VERIFIED` o‘zgarmaydi. Katta umumiy belgi o‘rniga yozuv darajasida kichik nishon va “qanday tekshirilgan” bo‘limi.
- Da’vo turiga mos manba: umumiy ilm → darslik; huquq → normativ hujjat (PQ-270, SSV 180 va b.); laboratoriya natijasi → validatsiya hujjati. Aralashtirilmaydi (claim-source audit CI’da bor va o‘tgan).
- Metodika: “o‘quv metodikasi ≠ laboratoriya SOP” ogohlantirishi.
- Xavfsizlik: admin faqat server roli; maxfiy kalitlar yo‘q (gitleaks o‘tgan); AI kvota yo‘qligi — nashrdan oldin yopilishi shart.
- Real tekshiruv holatlari: HUMAN_VERIFIED 0; ekspert-reviewer tizimi qurilgan, odam yo‘q.
- Tasdiqlanmagan/sinalmagan narsa: real qurilma, iOS, OTP, xarid, begona pochtaga Pro, App Store/Play sahifalari (yordamchi to‘ldirgan).

---

## 9. Texnik arxitektura

Qayta ishlatiladi: `learn` bo‘limi, `ProductFeature`+`AccessPolicy`, `admin_set_access`, xususiy storage+RLS naqshi, claim/citation/source tizimi, `LocaleFilteredKnowledgeRepository`, `method_images`, kontent pipeline (`fe_content_pipeline`), tarjima jadvali.
Minimal yangi qismlar (faqat tasdiqdan keyin): (1) `image_kind` maydoni; (2) Rf/xromatografiya jadval turi; (3) “ustoz” roli yoki `teacher_grants` + `teacher_decks/deck_slides` (1 migratsiya); (4) AI kvota (edge function, deploy tasdig‘i bilan); (5) trust-badge 4 daraja (UI).
Yangi arxitektura qurilmaydi; feature-freeze mantiqi (CLAUDE.md) saqlanadi — yangi funksiya egasi ruxsatidan keyin.

---

## 10. Taklif va 5 tomonlama baho

Baho: A sud-ekspert · B universitet ustozi · C talaba · D dasturchi/UX · E ilmiy muharrir. (5 = juda foydali/mos, 3 = o‘rtacha, 1 = zarar/qimmat.) Bu AI bahosi, inson taqrizi o‘rnini bosmaydi.

| # | Taklif | Hajm/xarajat | Xavf | Model | A | B | C | D | E | Ustuvorlik |
|---|---|---|---|---|---|---|---|---|---|---|
| T1 | Birinchi: CI’dagi 2 ta yiqilgan test + yangi test build (kitob moddalarisiz, mavjud holat) | kichik, pul yo‘q | past | Sonnet | 3 | 3 | 4 | 5 | 3 | **1** |
| T2 | Real qurilma STUDENT/EXPERT/ADMIN sinov paketi (egasi telefonda + chek-list) | o‘rta, egasi vaqti | past | Sonnet | 4 | 4 | 5 | 5 | 3 | **1** |
| T3 | Kitob modda inventarizatsiyasini tugatish (ro‘yxat → keyin kiritish) | katta, Sonnet | past | Sonnet | 5 | 4 | 5 | 3 | 5 | **2** |
| T4 | Karamarenko darsligini qabul qilish (kelgach), bet bilan | o‘rta | past | Sonnet | 5 | 4 | 4 | 3 | 5 | **2** (kitobga bog‘liq) |
| T5 | Ishonch nishoni 4 daraja (UI) | kichik–o‘rta | past | Sonnet | 4 | 3 | 4 | 4 | 5 | 2 |
| T6 | Tasvir turi (`image_kind`) + Rf jadvali standarti | o‘rta | o‘rta (huquq) | Sonnet; huquqiy qaror Opus | 5 | 5 | 4 | 3 | 5 | 3 |
| T7 | Dars jadvalini ilovaga kiritish: 1 fakultet, 1–2 mavzu pilot | o‘rta | past | Sonnet | 4 | 5 | 5 | 4 | 4 | 3 |
| T8 | Ustoz Pro v1 (PDF/PNG yuklash yo‘li, ko‘zgu rejimi) | katta | o‘rta | Sonnet (arxitektura Opus) | 3 | 5 | 4 | 3 | 3 | 4 |
| T9 | AI kvota (Free/Pro) | kichik, deploy ruxsat | o‘rta (xarajat nazorati) | Sonnet | 3 | 3 | 3 | 5 | 3 | **2** (nashr oldidan) |
| T10 | RG-18 server xarid tekshiruvi + 4 obuna, sandbox | katta | yuqori (pul) | Opus (xavfsizlik) | 3 | 3 | 3 | 5 | 3 | 2 (daromad uchun shart) |
| T11 | Bioetika — yangi fan | o‘rta | o‘rta (hozir feature-freeze) | Sonnet | 3 | 5 | 4 | 3 | 4 | 4 (qaror) |
| T12 | Rus “yopiq katalog” kartasini “Ichki katalog (admin)” qilish + yurisdiksiya qulfini tekshirish | kichik | past | Sonnet | 3 | 2 | 3 | 5 | 4 | 3 |
| T13 | Stomatologiya jadvali ↔ sud-odontologiya kontenti | o‘rta | past | Sonnet | 4 | 4 | 4 | 3 | 4 | 4 |
| T14 | Pigolkin atlasi rasmlarini ilovaga ko‘chirish | — | **yuqori (mualliflik)** | — | 4 | 5 | 5 | 2 | **1** | **tavsiya etilmaydi**; o‘rniga havola+o‘z so‘zimiz |
| T15 | Cast/AirPlay maxsus integratsiya | katta, plagin | o‘rta | — | 2 | 3 | 2 | 2 | 3 | v1 emas; ko‘zgu+brauzer yetarli |
| T16 | Sud-gistologik PDF asosida gistologiya fanini ochish | katta | past | Sonnet | 5 | 5 | 5 | 3 | 4 | 3 |

Men aytmagan, ammo foydali takliflar (qisqa): (a) bepul “fishka” — Henssge/Widmark natijasi va bitta casebook (GLOBAL_GROWTH_PLAN); (b) manbasiz da’voni ko‘rsatmaydigan “manba filtri” rejimi; (c) o‘qituvchi uchun “dars bo‘yicha test statistikasi” (faqat Ustoz Pro keyin). Hammasi mavjud funksiyalarga bog‘langan, hech biri hali qilinmagan.

---

## 11. Egasi qarori kerak bo‘lgan masalalar (faqat haqiqatan zarurlari)

1. «MA’QULLAYMAN, BOSHLANG» — qaysi tartibda (12-bo‘lim tavsiyasi).
2. **Karamarenko darsligi**: fayl/havola va bibliografiya (Q-2 ruxsati qabul qilingan; bet faqat o‘qilgandan keyin).
3. Narx zinasi va 4 obuna (A/B/C mintaqa), sinov faqat yillikda; lifetime yo‘q (tavsiya).
4. Bepul chegarani kengaytirish (har bo‘limda 3 yozuv — kam) roziligi.
5. Ustoz Pro: 6 qaror (PPTX yo‘li = ustoz o‘zi eksport, 18+, narx, monitor, birinchi dars, yurist) + qaysi fakultet/mavzu pilot.
6. Bioetika yangi fan sifatida qo‘shilsinmi (feature-freeze bilan to‘qnashadi).
7. Rus “yopiq katalog” kartasi: olib tashlash yoki “Ichki katalog (admin)”; yurisdiksiya qulfi qoidasi.
8. Ikkinchi admin/sinov hisobi (Pro sovg‘a E2E uchun).
9. Pigolkin atlasi kabi rasmlar: mualliflik ruxsati yo‘lini tanlash (ruxsat so‘rash yoki faqat havola).
10. Vakolatli ilmiy reviewer (HUMAN_VERIFIED) kim bo‘lishi.
11. 6.9" App Store skrinshotlari va Play matnlarini chiqarishga ruxsat.

---

## 12. Bosqichma-bosqich amalga oshirish rejasi (tasdiqdan keyin)

| Bosqich | Nima | Model | Taxminiy hajm |
|---|---|---|---|
| 0 (hozir) | Shu hisobot; egasi fikri | — | — |
| 1 | CI’dagi 2 testni aniqlab tuzatish; yangi test build (0.3.0+12); real qurilma chek-listi | Sonnet | kichik |
| 2 | Egasi telefonda STUDENT/EXPERT/ADMIN sinaydi; xatolar tuzatiladi | Sonnet | o‘rta (egasi vaqti) |
| 3 | Kitob modda inventarizatsiyasi tugaydi → ro‘yxat egasiga → kiritish (uz) | Sonnet | katta |
| 4 | AI kvota; rus karta/yurisdiksiya qulfi; ishonch nishoni | Sonnet | kichik–o‘rta |
| 5 | Karamarenko va Drive kitoblari kelgach: kataloglash → mavjud bilan solishtirish → bet bilan kiritish | Sonnet (ziddiyat bo‘lsa Opus) | o‘rta |
| 6 | Vizual standart (`image_kind`, Rf jadvali) | Sonnet | o‘rta |
| 7 | Dars pilot: 1 fakultet, 1–2 mavzu: slayd+test+manba | Sonnet | o‘rta |
| 8 | RG-18 + do‘kon mahsulotlari + sandbox (egasi tasdig‘i bilan) | Opus | katta |
| 9 | RU/EN tarjima (keyingi hafta), so‘ng qozoq/tojik/qirg‘iz | Sonnet | katta |

Shanba operatsion rejasi (`SHANBA_REJA_2026-10-17.md`) bilan moslik: uning 1-blok (holat tekshiruvi/CI) = 1-bosqich; 2-blok (xarid yo‘li) = 8-bosqich (tasdiq kerak); 3–5-bloklar = 4-bosqich; “shanbadan keyin” bandi = 7-bosqich.

---

## Sinalmagan va tekshirilmagan narsalar (ochiq)
- Bu auditda ilova ishga tushirilmadi, test suite yurgizilmadi; sonlar hujjatlardan olingan (eng yangi 10-11/10-14 holati).
- CI’ning 2 ta yiqilgan testi nomi aniqlanmadi.
- Drive fayllari faqat metadata orqali ko‘rildi (mazmuni o‘qilmagan); stomatologiya/bioetika jadvallarining ichki mavzulari tekshirilmagan.
- Karamarenko darsligi ko‘rilmagan.
