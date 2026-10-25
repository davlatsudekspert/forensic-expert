# «Bilim va malakani baholash» bo‘limi (2026-10-25)

Nomi: UZ «Bilim va malakani baholash» · RU «Проверка знаний и компетенций» · EN «Knowledge & Skills Assessment».
Kimga: **Mutaxassis** va **Ustoz** rejimlari (Bosh sahifadagi plitka). Talabaga ko‘rinmaydi; to‘g‘ridan-to‘g‘ri havola Bosh sahifaga qaytaradi.
Ogohlantirish/«kafolat» jumlalari yo‘q (egasi talabi). Hozircha hamma funksiya bepul.

## Ma’lumot
`apps/mobile/assets/content/assessment/assessment_v1.json` (qurilmada, oflayn).

* **Og‘zaki savollar — 1270 ta** (rasmiy ro‘yxat, tmbm.ssv.uz / gov.uz): sud-tibbiy ekspertiza 436, patologik anatomiya 501, sud-kimyogar ekspertiza 333;
  uchta toifa guruhi: uchinchi va ikkinchi / birinchi / oliy. Faqat savollar — **javoblar rasmiy ro‘yxatda yo‘q va to‘qilmagan**.
* **Test savollari — 1273 ta** (tmbm.ssv.uz «Test sinovi savollari»): sud-tibbiy 424, patologik anatomiya 448, sud-kimyo 401.
  PDF’dagi buzilgan/noaniq qatorlar (rasm ustidagi yozuvlar, takroriy variantlar) kiritilmagan.
* Savollar rasmiy ro‘yxatdagi kabi **faqat o‘zbekcha** (tarjima qilinmaydi).

## Javob kalitlari (faqat tasdiqlanganlari baholanadi)
Jami **791 ta** test kalitli; qolgan 482 tasi «Javob kaliti hali qo‘shilmagan» deb ko‘rinadi va mashqqa kirmaydi.

| Mutaxassislik | Kalitli | Manba |
|---|---|---|
| Sud-tibbiy ekspertiza | 237 / 424 | 173 — G‘iyosov «Sud tibbiyoti» (1–4-qism, bet+iqtibos); 64 — jahon adabiyoti/lex.uz |
| Patologik anatomiya | 164 / 448 | jahon adabiyoti (Strukov–Serov, MSD, PMC, PathologyOutlines …) |
| Sud-kimyogar ekspertiza | 390 / 401 | 361 — ustoz yuborgan kalitli test banki (matn bo‘yicha moslashtirilgan); 21 — kitoblar; 8 — jahon adabiyoti |

Jarayon (tekshiruv izi — `tools/assessment/data/audit/`):
1. Kitoblardan (agentlar) yoki veb-manbadan (Opus agentlar) kalit + iqtibos + bet/URL.
2. Iqtibos kitob/sahifa matnida borligi dasturiy tekshirildi (`verify_quotes.py`).
3. **Mustaqil auditor** (boshqa agent) har bir kalitni qayta tekshirdi: faqat `DIRECT` (manba faktni o‘zi aytadi, boshqa variant mos kelmaydi), kuchli manba (darslik, PMC, WHO/MSD, lex.uz) va iqtibos topilgan kalitlar qabul qilindi (`assemble_web_keys.py`).
4. Chiqarilganlar: taxminiy (`INFERRED`), inkor/«barcha javoblar» orqali topilgan, namunaga o‘xshatilgan tashxis-tuzish savollari, zaif manbalar (Vikipediya nusxalari, studfile, kollej konspektlari), qonun moddasi tahriri noaniq bo‘lganlar (masalan JPK 177 va 176¹).
5. Jahon adabiyoti kalitlarida manba nomi va havolasi «Javob manbasi» qatorida ko‘rsatiladi.

Qayta qurish: `tools/assessment/build_assessment.py` (og‘zaki), `merge_tests.py <data> <json>` (testlar + kalitlar), `assemble_web_keys.py`.

## Adabiyot — javob asosi (egasi qarori, 2026-10-25)
Har bir kalitli savolda «Javob manbasi» (kitob + PDF-bet, yoki nom + havola) va «Asos» (aniq iqtibos) ko‘rsatiladi;
bo‘lim bosh sahifasida «Foydalanilgan adabiyotlar» ro‘yxati (har manba bo‘yicha savollar soni). Ilovada «tasdiqlanmagan» so‘zi ishlatilmaydi:
adabiyot asos bo‘ladi; kaliti yo‘q savol «Javob kaliti hali qo‘shilmagan» deb turadi.

## Og‘zaki savollarga javoblar (adabiyot asosida, 2026-10-25)
Ilovada: savol ekranida «Javob (adabiyot asosida)» — qisqa bandlar; har bandni bosganda manba oynasi (adabiyot, PDF-bet yoki havola, **asl iqtibos**).
Javobi yo‘q savolda «Javob tez kunda qo‘shiladi». «Foydalanilgan adabiyotlar» ekraniga og‘zaki javob manbalari ham qo‘shildi.
Ma’lumot: `assets/content/assessment/oral_{sud_tib,pat_anat,sud_kimyo}.json` (`answers{qid:{c,g?,p[{t,s,p?,q,u?}]}}`, `sources[]`), model: `OralAnswers` (`assessment_models.dart`), test: `test/unit/assessment_oral_data_test.dart`.

Hozirgi holat (yig‘ilgan, takror savollar bilan): sud_tib 427/436, sud_kimyo 313/333, pat_anat 177/501 savolga javob (~8 100 band, ~4 MB). Sud-tibbiyot va sud-kimyo partiyalari tugagan; qolgani — patologik anatomiya (pat_anat 16–42).
Egasi qarori (2026-10-25): patologik anatomiyada tayyor qismi chiqariladi, qolgani «tez kunda» (ish ko‘p, limit tejash).

Jarayon (hamma bosqich Opus/Sonnet agent + dasturiy tekshiruv, `tools/assessment/assemble_oral.py`):
1. **Qoralama** (agent): savolga 6–12 band; har band — o‘z so‘zi bilan o‘zbekcha da’vo + **so‘zma-so‘z iqtibos (≤300 belgi)** + kitob/bet yoki saqlangan veb-manba. Kitoblar: G‘iyosov «Sud tibbiyoti» 1–4, toksikologik kimyo majmuasi, Yuldashev «Giyohvand moddalar tahlili». Patanatomiya: Strukov–Serov darsligi (medchitalka.ru), MSD, WHO, PMC va h.k.; Vikipediya/studfile/mashina tarjimasi yo‘q.
2. **Dasturiy tekshiruv** (`oral_build_ver.py`): iqtibos sahifada (±1)/saqlangan manba faylida topiladimi; topilmasa band tushadi.
3. **Mustaqil audit** (boshqa agent): har band `OK / OVERSTATED / WRONG`; manba sifati (`strong/weak`); savol mavzuga mosligi (`topic_ok`).
4. **Yig‘ish qoidalari:** `topic_ok=false` → savol «tez kunda»; OVERSTATED → faqat auditor `fix` matni (iqtibosdan; bo‘sh bo‘lsa tushadi); WRONG → tushadi (tarjima-xatosi bo‘lgan 6 band tuzatish bilan qabul qilingan); `weak` manba tushadi; kitob/darslik xatosini takrorlagan, eskirgan (nashr paytidagi tashkiliy holat, bekor qilingan buyruq, JK modda raqami tahriri noaniq), OCR bilan buzilgan, boshqa usuldan ko‘chirilgan bandlar qo‘lda tushirilgan (`oral_exclude.json`, ~79 band); 3 tadan kam band qolsa — javob tushadi. Terminologiya tuzatishlari (`qoplovchi (parietal)`, `vorsinkasimon (villyoz)`, «нередко» → «ancha tez-tez» …) skriptda.
5. `gaps` (adabiyotda yoritilmagan jihatlar) faqat qisman javobda ko‘rsatiladi; kitob xatolariga oid izohlar ko‘rsatilmaydi.

Cheklov: javoblar — manbadagi bayon (kitob/darslik davri); amaldagi O‘zbekiston normativ hujjatlari uchun (JPK/JK moddalari, buyruqlar) rasmiy matn bilan solishtirish kerak. Mustaqil inson-mutaxassis taqrizi o‘tmagan.
RU/EN: javob matni o‘zbekcha (CLAUDE.md: avval faqat o‘zbekcha); RU/EN foydalanuvchiga «Javob o‘zbek tilida; tarjimasi keyin qo‘shiladi» belgisi chiqadi.

## Ochiq ishlar
* 482 ta kalitsiz test: ko‘pi klinik holatga tashxis qo‘llash (patanatomiya 286–401) — mahalliy qo‘llanma (masalan, Зайратьянц «Формулировка патологоанатомического диагноза» yoki O‘zbekiston kafedrasi) kerak.
* Og‘zaki javoblar: qolgan partiyalar (pat_anat 16–42; ~320 savol) yozilmagan — ilovada «Javob tez kunda qo‘shiladi». Egasi ruxsat berganda **Sonnet** bilan davom etiladi (pipeline pastda).
* Eski reja: patologik anatomiya uchun mahalliy kitob yo‘q.
