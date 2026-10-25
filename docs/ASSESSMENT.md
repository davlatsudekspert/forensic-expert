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
Jami **791 ta** test kalitli; qolgan 482 tasi «Javob kaliti tasdiqlanmagan» deb ko‘rinadi va mashqqa kirmaydi.

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

## Ochiq ishlar
* 482 ta kalitsiz test: ko‘pi klinik holatga tashxis qo‘llash (patanatomiya 286–401) — mahalliy qo‘llanma (masalan, Зайратьянц «Формулировка патологоанатомического диагноза» yoki O‘zbekiston kafedrasi) kerak.
* Og‘zaki savollarga javob matnlari yozilmagan (Forensic AI tugmasi bor). Alohida bosqich: kitob/bet bilan, tasdiqlangan.
* Eski reja: patologik anatomiya uchun mahalliy kitob yo‘q.
