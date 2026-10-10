# DECISIONS (qarorlar jurnali)

| Sana | Qaror | Kim | Asos |
|---|---|---|---|
| 2026-10-06 | Feature-freeze `cf049d8`; keyin egasi master topshiriq bilan yangi bosqichni ochdi | Egasi | CLAUDE.md |
| 2026-10-08 | Biznes modeli FREE + PRO (oylik/yillik); sinov narxlari $4.99 / $39.99; lifetime faollashtirilmaydi | Egasi | master topshiriq |
| 2026-10-08 | ABY 2025: yopiq/admin integratsiya, Variant B — katalog faqat admin qurilmasida (repo, CI, Supabase, AI yo‘q) | Egasi | ABY qarori |
| 2026-10-08 | Umumiy bo‘lim nomi «Yo‘riqnomalar»; mustaqil kartalar ABY’dan alohida, provenance ichki | Egasi | |
| 2026-10-08 | Manbasiz AI matni foydalanuvchiga ko‘rsatilmaydi; o‘rniga «manbalar savolni qamramaydi» | Muhandis | ilmiy ishonchlilik; test `rag_pipeline_test` |
| 2026-10-08 | Har savolga bitta server so‘rovi (AiRouter + RAG ikki chaqiruvi bekor qilindi) | Muhandis | kvota isrofi (audit) |
| 2026-10-08 | Offline retrieval: IDF + bo‘sag‘a + umumiy so‘zlar filtri | Muhandis | BlueStacks YuQX hodisasi |
| 2026-10-08 | Iqtibos kalitlari (muallif+yil) gitleaks allowlist’ida | Muhandis | soxta signal |
| 2026-10-08 | Kartalar holati faylda nima yozilsa ham ekspert ko‘rigisiz NEEDS_REVIEW | Muhandis | kod `GuidelineCard._status` |
| 2026-10-08 | `ai-answer` v5 production’ga deploy | Egasi ruxsat berdi | vaqt byudjeti tuzatishlari |

## 2026-10-09 — Yuldashev Z.A. materiallaridan foydalanish ruxsati
- Muallif (Yuldashev Z.A., TFI) Telegram orqali 2026-10-09 14:19 da yozma ruxsat berdi:
  «Қанча манба керак бўлса фойдаланаверинглар» (egasi skrinshotini sessiyada ko‘rsatdi).
- Qamrov: «Toksikologik kimyo» va «ДВССМ» o‘quv-uslubiy majmualari (2025-26), «Giyohvand moddalar tahlili» o‘quv qo‘llanmasi (2024).
- Qoidalar: matn so‘zma-so‘z ko‘chirilmaydi — faktlar o‘z tuzilmamizda; har kartada manba «Yuldashev Z.A. va boshq., asar, yil»;
  topilgan xatolar (etanol letal dozasi, morfin pH, petidin formulasi, TGK foizlari, muvozanatsiz tenglamalar) tuzatiladi;
  holat NEEDS_REVIEW; muallifga ilmiy taqrizchi bo‘lish taklif qilingan.
- **Egasi qarori (2026-10-09): Yuldashev Z.A. materiallaridan olingan BARCHA kontent — barcha uchun
  BEPUL**, hech qachon Pro ortida emas: yo‘riqnoma kartalari, test savollari, glossariy terminlari va
  paketga qo‘shiladigan har qanday yozuv (`tier_access`/`EntryAccess` = free). Kartada
  `access: "free"`, manba `type: teaching_material` (joy, nashriyot, huquq) va uz/ru/en atribusiya qatori
  («Manba: Yuldashev Z.A. va boshq., … — muallif ruxsati bilan, barcha uchun bepul») ko‘rsatiladi.
  Tekshiruv: `content/guidelines/validate.py` G014–G017 va `test/unit/guidelines_content_test.dart`,
  `test/unit/gmt_study_glossary_test.dart`. Birinchi qo‘llanish: «Giyohvand moddalar tahlili» (2024) —
  9 karta, 42 savol, 48 termin; xatolar ro‘yxati `content/guidelines/REVIEW_GMT.md`.
- Egasining reaktivlar to‘plami (o‘zi jamlagan) — egasi ruxsati bilan (2026-10-09).

## 2026-10-09 — Free/Pro qarori (egasi)
- **Reaktivlar:** egasi to‘plamidagi 74 retseptning hammasi FREE (`tier_access=free`, `assemble_reagents.py`). Holat NEEDS_REVIEW;
  amaliy laboratoriya tavsiyasi sifatida tasdiqlanmagan. PubChem’da GHS tasnifi topilmagan ingrediyentli 33 retseptda
  «Xavflilik ma’lumotlari to‘liq tekshirilmagan … xavfsiz degani emas» ogohlantirishi. Keyinchalik Pro bo‘lishi mumkin:
  chuqur solishtirish, professional kalkulyatorlar, shaxsiy laboratoriya vositalari.
- **«Sudda so‘roq»:** barcha asosiy savol-javoblar, ilmiy/huquqiy asoslar, manba/sahifa/modda havolalari, cheklovlar va
  namunaviy qo‘shimcha savollar FREE. Pro: ilg‘or simulyator, sudya/advokat/prokuror ketma-ket mashqlari, AI tahlil,
  shaxsiy baholash, murakkab ssenariylar, statistika/tarix. Simulyator tekshirilmagan javobni to‘g‘ri deb baholamaydi.
- O‘zgarish faqat ilova kodi va kontent paketida; production entitlement/billing konfiguratsiyasi o‘zgartirilmadi.
- «MUALLIF/EGASI RUXSATI BILAN» belgisi faqat kontent huquqi (mualliflik) ruxsati uchun — xavfli moddalar muomalasi
  bo‘yicha qonuniy ruxsat ma’nosida emas. Faqat `license_agreement_id` qayd etilgan manbalarda chiqadi.

## 2026-10-09 — Hodisa: agent umumiy papkani o‘chirgan
- Reaktivlar agenti worktree’dan tashqaridagi `~/.local/share/uz.forensicexpert.forensic_expert/content` (desktop QA ilovasining
  o‘rnatilgan kontent paketi) ni o‘chirgan; boshqa bir agent `/tmp/flutter_tools` ni o‘chirib, parallel test yugurishini to‘xtatgan.
  Manba, kalit yoki foydalanuvchi ma’lumoti yo‘qolmagan; paket keyingi ishga tushishda assets’dan qayta o‘rnatiladi.
- Qoida: har agent faqat o‘z worktree’sida, `TMPDIR=<worktree>/.tmp`; tashqarida hech narsa o‘chirilmaydi; umumiy tozalash —
  faqat birlashtirishdan keyin, koordinator tomonidan.
- Ildiz sabab tuzatildi: `BundledPackInstaller` bir xil `pack_version` dagi, lekin mazmuni (SHA-256) boshqa paketni almashtirmas edi
  → eskirgan kontent qolardi. Endi teng versiya + boshqa xesh bo‘lsa qayta o‘rnatiladi (imzo va xesh tekshiruvi saqlanadi;
  eski versiyaga qaytish baribir rad etiladi). Test: `content_pack_test.dart`. Paket faqat o‘qiladigan kontent — foydalanuvchi
  ma’lumoti (sozlamalar, eslatmalar, murojaatlar) boshqa joyda saqlanadi.

## 2026-10-09 — «Sudda so‘roq: tayyorgarlik» (bepul/Pro va halollik)
- Egasi qarori: savol-javob kartalari (A–I: qisqa javob, ilmiy/huquqiy asos, aniq joyli manbalar, qo‘shimcha savollar, cheklovlar, eksport), mashq rejimi, halollik tamoyillari va asosiy simulyator ssenariylari — hamma uchun bepul.
- Mutaxassis Pro (mavjud `FeatureGate`, `ProductFeature.courtTestimonyPrep`; billing konfiguratsiyasi o‘zgartirilmadi): barcha ssenariylar, ketma-ket rol mashqi, AI tahlili (ulanmagan — halol «tez orada», AI chaqirilmaydi), shaxsiy statistika va tarix (faqat qurilmada, `fe.court.history.v1`).
- Bo‘lim natijani yashirish/yumshatish/buzishni o‘rgatmaydi; joyi asl matndan tasdiqlanmagan manba «Manba tekshirilmagan» deb ko‘rsatiladi va simulyatorda to‘liq ball olmaydi; holat doim NEEDS_REVIEW.
- Huquqiy savollar yurisdiksiyaga qarab: O‘zbekiston — JPK (lex.uz/docs/111460, 111463) va «Sud ekspertizasi to‘g‘risida»gi qonun (lex.uz/docs/1633100), 2026-10-09 holatiga; boshqa — umumiy xalqaro tamoyillar. FPK tekshirilmagan — «qonun matni lex.uz da tekshirilishi kerak».

## 2026-10-10 — Da'vo–manba auditi: DOI'siz rasmiy hujjatlar va iqtibossiz da'volar

`content/tools/claim_source_audit.py` ikki holatda noto'g'ri «UNSUPPORTED» bergan edi:

1. **DOI/ISBN'siz manbalar.** Vosita faqat `identifier_verified` ni tan olardi, shuning uchun
   UNODC ST/NAR/13/Rev.1, SWGDRUG v8.2 va muallif ruxsati bilan olingan Yuldashev GMT-2024 /
   TOKS-2025 «tekshirilmagan manba» deb belgilanardi (327 ta da'vo). Endi kitob, qo'llanma,
   standart, hisobot va qonun hujjati uchun **rasmiy URL yoki hujjatlashtirilgan litsenziya
   shartnomasi** ham identifikatsiya hisoblanadi; jurnal maqolalari uchun qoida o'zgarmadi.
2. **Iqtibos berilmaydigan manbalar.** Yopiq litsenziyali manbadan so'zma-so'z iqtibos
   olinmaydi, shuning uchun bunday da'volar matni `value.statement` da saqlanadi. Vosita
   faqat `value.excerpt` ni o'qiganidan matn bo'sh ko'rinardi. Endi `value.statement`
   o'qiladi va `paraphrase_not_quoted` bayrog'i qo'yiladi — ya'ni bu **bizning manbaga
   asoslangan bayonimiz, so'zma-so'z iqtibos emas**.

Natija: UNSUPPORTED 327 → 1 (ataylab qoldirilgan retraksiya fixture'i), SUPPORTED 1503.

Bundan tashqari bitta **haqiqiy iqtibos xatosi** tuzatildi: `guideline.bio.semen` «Ilmiy asos»
bo'limida mikroskopiya va PSA/p30 bir jumlada immunoanaliz manbalariga bog'langan edi;
mikroskopiya endi o'z manbasiga (`peonim2013`) bog'landi. Blood-presumptive kartasidagi
4 ta signal evristika xatosi bo'lgani `content/tools/claim_source_reviews.json` da
asoslantirib yozildi.

## 2026-10-10 — Google Play to'lov profili

To'lov profili (Payments profile) **Google Play dasturchi akkaunti darajasida**
bo'ladi, har bir ilova uchun alohida emas. Egasining akkauntida profil Mystery
Room ilovasi uchun NBU hisobi bilan yaratilmoqda — **FORENSIC EXPERT Pro
obunasi ham shu profildan foydalanadi**, yangisini yaratish kerak emas.

Shundan kelib chiqadigan narsalar:

- Ikkala ilovaning tushumi bitta hisobga tushadi — buxgalteriya va soliq
  hisobotida ajratib yuritish kerak bo'ladi (Play Console'da har ilova
  bo'yicha hisobot alohida ko'rinadi).
- Obuna sotish uchun to'lov profili **to'liq tasdiqlangan** bo'lishi shart
  (shaxs/tashkilot tekshiruvi + soliq ma'lumotlari). Tasdiqlanmaguncha
  `Monetize → Subscriptions` da mahsulot yaratilsa ham sotilmaydi.
- AQSh soliq formasi (tax info) to'ldirilmasa, tushumdan ushlab qolish
  (withholding) qo'llanadi.
- To'lov chegarasi bor: summa minimal chegaraga yetmaguncha pul o'tkazilmaydi.

## 2026-10-10 — ABY: manba sifatida ochiq keltiriladi

Egasining qarori o‘zgardi. Ilgari ABY faqat ichki mavzu ro‘yxati bo‘lib, nomi
yozilmas edi. Endi:

- ABY **manba sifatida yoziladi**, aniq joyi bilan: «ABY, 2-bob, 3-bo‘lim».
- So‘zma-so‘z iqtibos **olinmaydi**: mazmun o‘z so‘zimiz bilan `value.statement`
  {en,uz,ru} da, manba nomi `value.source_i18n`, joyi `value.locator_i18n`.
  Bu Yuldashev GMT-2024 / TOKS-2025 bilan bir xil yondashuv.
- ABY faylining o‘zi repoga, ilova assetlariga yoki Supabase’ga ko‘chirilmaydi.
- Bundle’dagi source yozuvi `license_agreement_id` bilan: markaz hujjatni
  foydalanish uchun sotib olgan.
- Xalqaro manba topilsa, u ham yonma-yon keltiriladi; topilmagani endi
  ABY’dan yozishga to‘siq emas.

- **Faqat o‘zbek tilida ko‘rinadi.** Rus va ingliz tilida ABY’ga asoslangan
  yozuvlar umuman chiqmaydi va tarjima qilinmaydi (`value.locale_only: "uz"`).
  Bu uch tilli qoidadan ataylab qilingan istisno: hujjat milliy amaliyotga oid
  va egasi uni boshqa tillarda tarqatishni istamaydi.

Sabab: egasi aytdi — ABY ning o‘zi kitoblardan jamlangan, va O‘zbekistonda
amalda qo‘llanadigan usullar aynan shu hujjatda yozilgan; usulni manbasiz
qoldirgandan ko‘ra, uni o‘z manbasi bilan ko‘rsatish to‘g‘riroq.

