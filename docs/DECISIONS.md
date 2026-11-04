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

**Bajarildi (2026-10-10).** Yozuvlar paketga kiritildi: 32 da’vo, 19 bepul
mavzu, manba yozuvi `SRC-ABY-2025`, minnatdorchilik sahifasida tashkilot,
9 tuzuvchi va 3 taqrizchi. Qamrov va qolgan ish: `docs/ABY_COVERAGE.md`.
Texnik tafsilotlar:

- Builder `content/tools/build_aby_content.py` (ma’lumot `aby_data.py`),
  `build_ethanol_gc_content.py` dan keyin ishga tushiriladi.
- Ilovada til filtri bitta joyda: `LocaleFilteredKnowledgeRepository`
  (`knowledgeRepositoryProvider`) — ro‘yxat, qidiruv, kurslar va havola bilan
  kirish ham filtrlanadi, shuning uchun ru/en da bo‘sh sahifa ochilmaydi.
- `translation_qa.py` va `apps/mobile/tool/lang_audit.py` `locale_only`
  yozuvlarni biladi: ular faqat o‘z tilida tekshiriladi, boshqa tilda
  «tarjimasi yo‘q» xatosi chiqmaydi.
- Qatlam (`layer`) taksonomiyasida «milliy uslubiy hujjat» qiymati yo‘q,
  `jurisdictional` esa huquqiy hujjatga bog‘lanishni talab qiladi; shuning
  uchun yozuvlar ilmiy qatlamda qoldi, milliy mansubligi manba va
  ko‘rsatkich orqali beriladi. Taksonomiyani kengaytirish — backlog.


## 2026-10-10 — Bepul/Pro chegarasi: bilim bepul, vositalar Pro

Egasining qarori: **ABY va boshqa muallif manbalari bepul**, Pro paywall ortiga
qo'yilmaydi. Sabab: ABY markaz o'z ishi uchun sotib olgan hujjat; boshqaning
mehnatini sotish mumkin emas. Yuldashev GMT-2024 / TOKS-2025 ham shunday.

Chegara printsipi:

- **Bepul — bilim:** butun kutubxona (moddalar, usullar, reaktivlar, qo'llanma
  kartalari, manbalar), ABY yozuvlari va minnatdorchilik bo'limi, sudda so'roq
  savollari, test rejimi, oddiy kalkulyatorlar, cheklangan AI.
- **Pro — vaqtni tejaydigan vositalar:** fasetli/teskari aniq qidiruv (Rf, rang,
  massa, alomat bo'yicha), «Modda bo'yicha tahlil rejasi», murakkab hisob
  (LOD/LOQ, regressiya, validatsiya, statistika), xulosa uchun iqtibosli
  eksport, test natijalari tahlili, kengaytirilgan AI.

Sababi ochiq aytiladi: biz bilimni sotmaymiz, mehnatni tejaymiz.

### Aniqlashtirilgan tijorat modeli (egasi, 2026-10-10 kechqurun)

- **Birinchi oy — Pro bepul.** Ro'yxatdan o'tgan foydalanuvchiga 30 kun to'liq Pro.
- **Bepul:** kutubxonani o'qish — moddalar, usullar matni, reaktivlar, qo'llanma
  kartalari, manbalar ro'yxati, oddiy qidiruv va oddiy kalkulyatorlar.
  **ABY va muallif kitoblaridan olingan matn ham bepul** — boshqaning mehnati
  sotilmaydi.
- **Pro:** sudda so'roq moduli; toifaga tayyorlanish va test rejimi, natijalar
  tahlili; aniq/teskari qidiruv (Rf, rang, massa, alomat); «Modda bo'yicha
  tahlil rejasi»; xulosa uchun iqtibosli eksport; murakkab hisob (LOD/LOQ,
  validatsiya, regressiya).

Chegara qoidasi: **manbadan olingan matn — bepul; o'sha matn ustiga biz
qurgan vosita — Pro.** Foydalanuvchi metodikani o'qiydi bepul; «shu modda
uchun tahlil rejasini tuzib ber» desa — Pro.

Mamlakat bo'yicha turli tarif hozircha joriy etilmaydi: avval bitta oddiy
model bilan chiqiladi, haqiqiy foydalanish ko'ringandan keyin qayta qaraladi.

## 2026-10-11 — Egasi «ruxsat senga» dedi: kutib turgan bandlar hal qilindi

1. **Admin «Tasdiqlash arizalari» RPC production'ga qo‘llandi.**
   `public.admin_pending_verifications(int,int)` — faqat qo‘shadi, hech narsa
   o‘zgartirmaydi/o‘chirmaydi. Tekshirildi: SECURITY DEFINER, `anon` ga ruxsat
   yo‘q, `authenticated` ga bor (ichkarida `private.admin_guard()` tekshiradi).
   Orqaga qaytarish (bir qator):
   `drop function if exists public.admin_pending_verifications(int, int);`
   Supabase advisor: yangi ERROR yo‘q; funksiya boshqa `admin_*` RPC'lar bilan
   bir xil WARN ro‘yxatida (bu kutilgan — himoya funksiya ichida).
2. **Ekspert ish daftari — bepul.** Qurilmada saqlanadigan ish vositasi,
   boshqa muallifning mehnati emas; Pro paywall ortiga qo‘yilmaydi.
3. **Umumiy qurilma:** daftar chiqishda **avtomatik tozalanmaydi** — bu yolg‘iz
   ishlaydigan ekspertning yozuvlarini bexosdan yo‘qotadi. Hozirgi himoya:
   yozuvlar faqat qurilmada, serverga/AI'ga ketmaydi, «Butun daftarni tozalash»
   tugmasi bor va maxfiylik matnida aytilgan. PIN/biometrika — backlog
   (feature-freeze davrida qo‘shilmaydi).
4. **`C-FM-ALGOR-MORTIS-DEFINITION` qoldirildi** — chaqirib olingan manbaga
   bog‘langan ataylab qoldirilgan namuna: retraksiya ogohlantirishi va RAG
   filtri ishlayotganini ko‘rsatadi (phase7_test, rag_pipeline_test).
5. **Ikkinchi admin akkaunt — hali ochiq.** DB o‘zini-o‘zi tasdiqlashni
   taqiqlaydi (to‘g‘ri qoida). Egasining maqomini tasdiqlash uchun ishonchli
   hamkasbning elektron pochtasi kerak; keyin server tomonida rol beriladi
   (audit yozuvi bilan). Egasidan: shu shaxsning emaili.

6. **Savol-javob: ilova baza jadvallariga tegmaydi.** Barcha 7 jadvalda RLS
   yoniq va **policy yo'q**, `anon`/`authenticated` uchun DML grant yo'q.
   Sabab: ekspert hamjamiyatida bitta noto'g'ri policy boshqa odamning
   savolini yoki shikoyat kimdan kelganini oshkor qiladi. Hamma ish
   `SECURITY DEFINER` RPC'lar orqali, ularning ichida qoida yoziladi.
7. **Server funksiyalari `public.qa_service_*` orqali.** PostgREST faqat
   `public` sxemasini ochadi, shuning uchun `private.*`ga berilgan grant
   HTTP orqali yetib bo'lmaydi. Referral server funksiyalaridagi naqsh
   takrorlandi: yupqa `public` wrapper, faqat `service_role`ga grant.
   Orqaga qaytarish: `supabase/rollback/20261011010000_qa_service_api_down.sql`.
8. **Tekshiruv hujjati saqlanmaydi — bu arxitektura qarori, sozlama emas.**
   Sxemada fayl/yo'l/rasm ustuni umuman yo'q, server funksiyalari hujjatni
   parametr sifatida qabul qilmaydi, Edge Function esa uni faqat xotirada
   ushlaydi. Shuning uchun keyinchalik «hujjatni saqlab qo'yaylik» degan
   o'zgartirish migratsiya talab qiladi — tasodifan yuz bermaydi.
9. **Tarjima dvigateli: Cloudflare Workers AI (m2m100), zaxirasi Gemini.**
   Egasining qarori (2026-10-10). Kalit faqat Edge Function muhitida.
   Cloudflare m2m100 til parametrini ikki xil yozgan (to'liq ism va ISO
   kod) — ikkisi ham ketma-ket sinaladi, shuning uchun API o'zgarsa ham
   tarjima to'xtamaydi.
10. **Egasining belgisi `manual = true` bilan.** Keyingi avtomatik tekshiruv
    bu belgini o'chirmaydi (`manual = manual or excluded.manual`), ya'ni
    qo'lda tekshirilgan maqom AI qarori bilan yo'qolmaydi. Email hech
    qayerda saqlanmaydi — faqat seed chaqirig'ida argument.

## 2026-10-17 — Pro/pullik funksiyalar to‘xtatildi (Apple 2.5.19, 2.1)
Egasi qarori: ilovaga yangi to‘lov/paywall/yashirin bayroq qo‘shilmaydi; hamma funksiya bepul. Server tomonida faqat `plan` (free/pro, `pro_until`) tayyorgarligi mumkin. Pro tayyor bo‘lganda to‘liq ishlaydigan yangi versiya sifatida yuboriladi (do‘kon mahsulotlari, sandbox, server tekshiruvi, restore, ekranda shartlar, intro-offer). Tafsilot: CLAUDE.md.
Mavjud kod (paywall_screen.dart, billing_ports.dart, 4 ta store mahsuloti ID, entitlement/gating) repoda BOR — uni olib tashlash/o‘chirish qarori egasidan kutilmoqda.

## 2026-10-17 — ABY 2025 ilovadan to‘liq olib tashlandi (Apple 2.5.19)
Egasi qarori (aynan): «ABY ni ilovadan to‘liq o‘chir, git tarixidan tiklash mumkin». Sabab: `kShowAbyContent=false` bilan yashirilgan kod va ma’lumot Apple 2.5.19 bo‘yicha «yashirin funksiya» xavfini tug‘diradi.
Olib tashlandi: bundle’dan 94 claim (`C-ABY-*`, `C-ABYX-*`), ularning iqtiboslari, `SRC-ABY-2025` va ekspert-izoh manbalari, 39 ta `aby-*` mavzu, 356 ta `editorial:aby-order` havola; `content.db` qayta yig‘ildi va imzolandi (development kalit yangilandi); builder va dossier skriptlari; `aby_flag.dart`; analiz tabidagi ABY qatlami (qolgan qatlamlar: kitob qo‘llanmalari + ilmiy adabiyot); «ob’ekt» qatori; admin «yopiq katalog» (`practice_catalog*`, import, marshrut); ARB kalitlari (`aby*`, `restrictedCatalog*`, `confirmedSourceBanner`); testlar va goldenlar. «Manbalar va mualliflar»dan ABY bandi olib tashlandi.
Qoldi: modda sifatida simob, sirka kislotasi, ammiak (PubChem identifikatsiyasi; ABY havolasiz), ustoz kitoblari va xalqaro adabiyot — o‘zgarmagan.
Tiklash: faqat git tarixidan (holat `05bffed`, tafsilot `docs/ABY_COVERAGE.md` tepasida). Qayta qo‘shish yangi egasi qarorini talab qiladi.

## 2026-10-18 — Darslar fakultet bo‘yicha; MR16 olib tashlandi; toksikologiya 81 dars
Egasi javoblari: «toksikologya qolmasin» — 76–81 [Qo‘shimcha] amaliy mashg‘ulotlar kursda qoladi (jami 81 dars).
«Olib tashlasa xam boladi kitob yoq bolsa» — MR16 «Mutaxassislarning asosiy savollari» (manbasi yo‘q) rejadan chiqarildi (`slides-out` `out/aliases.json` → `not_topics`).
«Xa shunaqa qil fakultet bogicha» — «Darslar» guruhlari kurssiz: Davolash ishi, Pediatriya, Stomatologiya, Tibbiy profilaktika fakulteti va Bioetika. Joriy KTP 2026 birinchi (ma’ruza → amaliy → mustaqil → qo‘shimcha), eski rejadagi qolgan mavzular oxirida; bir xil prezentatsiyani ochadigan takror mavzu `lesson_topics.hidden` bilan yashirilgan (o‘chirilmagan). Migratsiya `20261018030000_lesson_topics_hidden` prod’ga qo‘llandi; mavzular yangilandi (249 ko‘rinadi, 11 yashirin).

## 2026-10-18 — Toksikologiya kitoblaridagi ziddiyatlar: bitta qiymat
Egasi: «538. Krilova. Bittasini yoz bo‘ldi». COHb — 538 nm; kasrli usul — A.N. Krilova; boshqa ziddiyatlarda slaydda bitta qiymat (kitobdagi asosiy yoki to‘g‘ri variant), ikkinchisi faqat teacher_notes’da. Ro‘yxat: `docs/toks/kitob_ziddiyatlari.md`.

## 2026-10-18 — App Store: barcha davlatlar
Egasi: «Apple’da to‘ldirayotganda hamma davlatlarga deb yozaylik. Esingda saqla». App Store Connect → Pricing and Availability → **All countries or regions** (bepul). Istisno ehtimoli: Xitoy materigi — generativ AI xizmatlari uchun mahalliy litsenziya talab qilinadi; Apple shu hududni rad etsa, faqat o‘sha hudud olib tashlanadi. Play Console’da ham barcha davlatlar.

## 2026-10-24 — Prezentatsiyalar v2 va dars testi (egasi qarori)
- Har prezentatsiya 38–42 slayd, diagrammali slaydlar ≥40 %, 8 xil diagramma turi (`docs/lessons/DECK_SPEC_V2.md`); har deck 20 ta manbali savol. 81 toksikologiya decki boyitildi, manba bo‘yicha tekshirildi va prod’ga seed qilindi (slides-out `b714ada`); 127 sud tibbiyoti/bioetika decki boyitildi, tekshiruv davom etmoqda.
- Dars oxiridagi test — **«Guruh testi»** (kirgan talabalar, o‘z ismi bilan, o‘rinlar, qiyin savollar muhokamasi), «Sinfda test» (jonli, taxallusli) dars tugmasidan olib tashlanadi, Ustoz panelida qoladi.
- Test savollari o‘zbekcha (`source_lang: uz`), ru/en — «tarjima kutilmoqda» (til tartibi 2026-10-12 ga muvofiq).
- Prod’ga qo‘llandi: `class_hardest_detail` funksiyasi (additiv).

## 2026-10-24 — «Ustoz» rejimi va fan sahifasida darslar (egasi topshirig‘i)
- Foydalanish rejimi uchta: Mutaxassis, Talaba, **Ustoz** (`UserMode.teacher`). Rejim faqat ilova tuzilishini o‘zgartiradi; darslar, jonli test va guruh testlari **serverdagi `teacher` roli** bilan ochiladi (rolni admin beradi).
- Ustoz fanni («Sud tibbiyoti», «Sud toksikologiyasi») ochganda shu fan prezentatsiyalari kurs bo‘yicha ko‘rinadi, har dars qatorida «Guruh testi» tugmasi (10/15/20 savol, QR, jonli natija, qiyin savollar). Kurs → fan bog‘lami ilovada: «Toksikologik kimyo», «Apparatlar bilan ishlash» → toksikologiya; qolgan kurslar → sud tibbiyoti.
- «Apparatlar bilan ishlash» alohida kurs (3 dars), rasmlar faqat ruxsatli (CC Commons, o‘z sxemalar) — `lesson-images` bucket (ommaviy o‘qish; yozish — ustoz/admin, 2 MB, PNG/JPG).

## 2026-10-24 — «Apparatlar bilan ishlash» mutaxassisga ochiq; Pro rejasi
- `lesson_topics.audience` ('teacher' | 'all'): «Apparatlar bilan ishlash» kursi `all` — har qanday kirgan foydalanuvchi (mutaxassis) ko‘radi; boshqa ma’ruzalar — faqat ustoz roli. Prod’ga qo‘llandi (`lesson_list`/`lesson_get` yangilandi).
- Mutaxassis uchun Bosh sahifada «Apparatlar bilan ishlash» plitkasi; dars oxirida test — o‘zi yechadi (guruh testi faqat ustozda).
- Egasi topshirig‘i: tekshiruvdan o‘tgach Pro versiya tayyorlanadi; Talaba/Mutaxassis/Ustoz rejimlari free/pro bo‘linadi; «Apparatlar bilan ishlash» mutaxassis uchun Pro bo‘ladi (hozircha bepul — tekshiruvdagi buildga tegilmaydi). Taklif va narxlar: `docs/PRO_PLAN_2026-10-24.md` (tasdiq kutilmoqda).

## 2026-10-24 — Pro narxlari (egasi qarori, yakuniy)
Talaba $1.49/oy, $9.99/yil; Ustoz $2.49/oy, $24.99/yil; Mutaxassis $3.49/oy, $34.99/yil (uchta alohida obuna). Admin panel: istalgan emailga Pro berish (server `admin_set_plan`, audit). Tafsilot: `docs/PRO_PLAN_2026-10-24.md`. Pro — 0.4.0 versiyasida, tekshiruvdagi 0.3.1 ga tegilmaydi.
- (2026-10-24, kech) Pro himoya qoidalari: reja faqat o‘z rejimini ochadi (Student Pro ≠ Ustoz paneli), rejim almashtirish huquq bermaydi; 30 kunlik sinov — do‘kon intro-offer + serverda qurilma-hash (bir telefon — bir sinov, boshqa Gmail bilan takrorlanmaydi); Pro faqat server tasdig‘i bilan. `docs/PRO_PLAN_2026-10-24.md` §5.

## 2026-10-24 — «Sinf» so‘zi yo‘q, hammasi «Guruh testi» (egasi qarori)
Ilovada «Sinfda test» degan joy qolmaydi: jonli test — «Guruh testi (jonli)», muddatli mavzu testi — «Guruh testi». Kod kalitlari (`class*`) va marshrutlar o‘zgarmaydi, faqat matn (uz/ru/en, `tool/l10n_group_wording.py`). CSV fayl nomi `guruh_test_…`. Maqsad: kim bo‘lib kirsa ham bitta tushuncha — guruh.

## 2026-10-24 — Tarjima navbati (egasi qarori)
Pro 0.4.0 test buildidan keyin darslar va test savollari RU/EN ga tarjima qilinadi (avtomatik raqam/birlik/formula nazorati, «tekshirilmagan» belgisi), so‘ng qozoq, tojik, qirg‘iz. Ro‘yxat: `docs/ACTIVE_TASKS.md` «Navbatdagi ishlar».

## 2026-11-02 — 6-kurs davolash: to‘liq 7 mavzulik reja (egasi so‘rovi)
Egasi yuborgan 6-kurs davolash rejasi (7 mavzu, 18+18=36 soat) bo‘yicha: «Darslar»da 6-kurs uchun yashirilgan 3 takror mavzu ochildi (`6-kurs-davolash-02/04/10` → slaydlar `4-kurs-davolash-14/16/19` bilan umumiy; «bir xil bo‘lsa 6-kursga ham qo‘y»). Zaxira: `public.lesson_topics_backup_20261102`. Guruh testi: `6-kurs-davolash-10` («Tibbiy yordam ko‘rsatish nuqsonlari») — `4-kurs-davolash-19` ning 60 savoli (uz/ru/en) nusxalandi, ilova bankiga qo‘shildi (build 46). `tools/class_quiz/import_quiz_bank.py` bu mavzuni bilmaydi — qayta generatsiyada qo‘lda qo‘shish kerak. Ma’ruzalar (02/04) uchun test savollari yo‘q.

## 2026-11-02 — Ustoz profili boshi, toifa, reja belgisi; admin «O‘tkazilgan testlar» (build 47)
- Egasi namunasi (NFC profil): ustozda Profil boshida katta dumaloq rasm, ism, ish joyi, **toifa** (Oliy/Birinchi/Ikkinchi/Toifasiz — `teacher_cards.category`), qisqa ma’lumot, tarmoqlar, «Profilni tahrirlash». Alohida «Ustoz kartam» qatori olib tashlandi (bosh qismning o‘zi).
- **Pro belgisi:** egasi «pro so‘zi ham tursin» dedi — ustozda faol reja bo‘lsa (masalan admin bergan «Ustoz Pro») profil boshida reja nomi belgisi ko‘rsatiladi. Bu 2026-10-17/24 dagi «Pro belgisi qo‘yilmaydi» qarorini shu belgi uchun o‘zgartiradi; to‘lov tugmasi/paywall qo‘shilmagan.
- Admin: `admin_class_tests` / `admin_class_test_detail` (faqat identity_admin, detal ko‘rish audit jurnaliga `CLASS_TEST_VIEW`). Migratsiya `20261102070000_teacher_category_admin_tests.sql` prod’ga qo‘llandi; `teacher_card_upsert` ga `p_category` (NULL — eski qiymat saqlanadi).
- Keyingi so‘rov (rejasi alohida): ustozlar bir-birini ko‘rishi va «klass» bosishi; hisobga kirgan talabalar ham ko‘rishi.

## 2026-11-02 — Katalog va «Talaba paneli» (build 49)
- **Ustozlar va mutaxassislar katalogi:** bitta yulduzcha (like), eng ko‘p yulduzcha olganlar tepada. Faqat hisobga kirganlar ko‘radi va bosadi (o‘ziga bosib bo‘lmaydi, kim bosgani ko‘rsatilmaydi). Katalogda chiqish — alohida rozilik (standart o‘chiq). Mutaxassis faqat tasdiqlangan bo‘lsa. Migratsiya `20261102080000_catalog_stars.sql` (prod).
- **Talaba hamma mavzuni o‘qiydi (egasi so‘rovi):** 2026-10-24 dagi «Darslar talabaga yo‘q» qarori bekor. Hisobga kirgan har kim 345 ta darsni (slayd matni + manbalar) o‘qiydi, «Tinglash» va mavzu bo‘yicha o‘zi test yechadi. «Ustoz eslatmalari» (`teacher_notes`) va guruh testi berish faqat ustoz rolida. Serverda `lesson_get` ustoz bo‘lmaganga eslatmalarni olib tashlaydi. Migratsiya `20261102090000_lessons_open_read.sql` (prod, additiv; qaytarish — `20261024040000` funksiyalari).
- «O‘qish stolim» → **«Talaba paneli»**, talabaning Bosh sahifasida birinchi. «Barcha mavzular» bo‘limida fakultet tanlovi, tartib raqami va «Ma’ruza/Amaliy mashg‘ulot» belgisi bor. Uzun KTP sarlavhalari nom + bandlarga bo‘lib ko‘rsatiladi (matn o‘zgartirilmaydi). Fan sahifasida yozuvi yo‘q rejadagi mavzular yig‘ilgan.
- **Tinglash talaffuzi:** TTS `style` dars tiliga qarab beriladi. O‘zbekcha uchun: «Native Tashkent Uzbek speaker. Pure Uzbek pronunciation…, no English or Russian accent». Haqiqiy ovoz sifatini egasi qurilmada tinglab tasdiqlaydi.
- Pro (tinglash, test va boshqalar) — keyingi versiyada, hozir hammasi bepul (egasi, 2026-11-02).
- Kontent kamchiligi (egasiga ma’lum qilindi): Davolash 6-mavzu sarlavhasiga begona pedagogika matni («Kasbiy aks ettirishning psixologik va akmeologik asoslari…») qo‘shilib qolgan. Server ma’lumoti tuzatilmadi, egasi tasdig‘i kerak.

## 2026-11-02 — Ovozli «Tushuntirish» barcha mavzular uchun (build 50)
- **Uzluksiz tinglash:** «Ovoz tugagach» rejimi — slayd tushuntirishi o‘qib bo‘lingach keyingi slaydga o‘zi o‘tadi; TTS bo‘lmasa 30 soniya.
- **Tushuntirish matni (egasi: «pptx ni o‘qimasin, aniq tushuntirsin»):** har slayd uchun ravon o‘zbekcha ma’ruza matni, faqat shu slayd faktlari (raqam/yil slaydda bor-yo‘qligi avtomatik tekshirildi, «keyingi slayd» yo‘q). Pilot (Davolash 1-mavzu) egasi ma’qulladi; qolgan 203 ta deck shu uslubda agentlar tomonidan qo‘lda yozildi. AI yordamida tayyorlangan, ilmiy reviewer tasdig‘idan o‘tmagan.
- **Saqlash joyi:** 26 deck — serverda (`lesson_decks.deck->slides[i].narration`, zaxira `lesson_decks_backup_narration_20261102`). Qolganlari — ilova ichida `assets/content/narration/<deck>.json`; ilova faqat server matni bo‘sh va slayd sarlavhasi aynan mos bo‘lsa qo‘yadi (server slaydi o‘zgarsa eski matn o‘qilmaydi). Sabab: serverga har deck uchun alohida ruxsat kerak edi, ayrim toksikologiya/asfiksiya matnlari yuklashda xavfsizlik filtri tomonidan to‘xtatildi.
- RU tushuntirish — keyingi bosqich («Avtomatik tarjima — tekshirilmagan» belgisi bilan).
- Taklif (egasi bilan muhokamada): **og‘zaki imtihon** — har talabaga takrorlanmas 5 savollik bilet, ustoz telefondan 0–20 ball/savol, 100 ballik natija ekranda. Savollar ro‘yxati ustozdan; build 50 dan keyin.

## 2026-11-02 — Og‘zaki imtihon (bilet) va build 53
- **Og‘zaki imtihon (egasi so‘rovi, 2026-11-02):** «Bilim va malakani baholash» → mutaxassislik → toifa → «Og‘zaki imtihon (bilet)». Rasmiy og‘zaki savollar bankidan **5 savollik bilet**, har savolga **0–20 ball**, jami **100**; ball qo‘yuvchi (ustoz yoki mutaxassis) telefonni ushlab turadi, har savol tagida «Javob kaliti (ustoz uchun)» (adabiyotga asoslangan javob, bet bilan). Chiqarilgan savollar darhol «ishlatilgan» deb belgilanadi — keyingi talabaga **takrorlanmaydi**; hammasi ishlatilsa aylanish qaytadan boshlanadi. Natija (ixtiyoriy ism, ballar, sana) va ishlatilgan savollar **faqat shu qurilmada** (`fe.assessment.oralexam.v1`), serverga yuborilmaydi; tarixni tozalash va aylanishni boshidan boshlash tugmalari bor. Natija bo‘yicha «o‘tdi/yiqildi» hukmi chiqarilmaydi (faqat ball).
- **TTS (Gemini) 429 tuzatishi:** bitta modelning kunlik bepul limiti tugasa, server keyingi modelga o‘tadi; faqat muvaffaqiyatli yaratish foydalanuvchi limitidan yechiladi (`tts` funksiyasi, v4).
- **Ovozni oldindan yaratish (`tts-prefill`):** `tts_prefill_queue` jadvali (RLS yoqilgan, ruxsatsiz), pg_cron har 10 daqiqada `tts-prefill` funksiyasini chaqiradi (Vault sirri `tts_prefill_token`); tayyor ovoz `tts-cache` ga yoziladi va hamma foydalanuvchiga limitsiz chiqadi. Bepul limit ≈ 15–20 slayd/kun; pullik (Batch) limitda ≈ $32 ga hammasi bir kunda. O‘chirish: `select cron.unschedule('tts-prefill')`.
- **Saqlash:** hozir ovoz Supabase `tts-cache` da (WAV). Rejа: MP3 siqish + Cloudflare R2 (10 GB bepul, trafik bepul) — ertaga egasi R2 ni ochgach; Cloudflare Workers AI TTS o‘zbek/rus tilini qo‘llamaydi.
- Yulduzcha tugmasi: bosilmagan holat ham oltin kontur (ustozlar va mutaxassislar ro‘yxati bir xil ko‘rinadi).

## 2026-11-03 — SPE (qattiq fazali ekstraksiya) usuli va yulduzcha (build 54)
- **SPE usuli (egasi so‘rovi: markaz e’loni, «faqat usulni yozamiz»):** «Asbob-uskunalar» da yangi kartochka `spe` («Qattiq fazali ekstraksiya (SPE) qurilmasi», Laboratoriya): nima ekani, nima uchun, 6 qadam (kondisionlash → muvozanatlash → yuklash → yuvish → elyuatsiya → tahlilga tayyorlash), ehtiyot choralari, sorbent turlari, zamonaviy mikroekstraksiya usullari (SPME, MEPS, SBSE, DLLME). Rasm — **original sxema** (kod bilan chizilgan, AI emas; `assets/images/instruments/spe.webp`), izohi «Sxema (original chizma)». Raqamlar qadamlarga mos, oltin nuqta — modda, kulrang — halaqit.
- Manbalar: Restek «Resprep SPE Products» umumiy protsedurasi (2025), Taylor T. LCGC 2015, PubMed sharhlari (Walker & Mills 2002; Platoff & Gere 1991; Scheurer & Moore 1992; He & Concheiro-Guisan 2019; Samanidou 2011; Klu 2021). Restek va LCGC — ishlab chiqaruvchi/savdo nashri (ilmiy sharh emas); qadamlar tartibi uchun ishlatildi, raqamli ko‘rsatkichlar ular matnidan.
- **«Usullar» bo‘limida ham:** `method-spe` usul sahifasida (Barcha usullar va SOP) qadamlar sxemasi, qadamlar va manbalar chiqadi (`SpeMethodCard`), qurilma kartochkasiga havola bor. Imzolangan `content.db` o‘zgartirilmadi (kartochka ilova ichidagi `equipment_v1.json` dan).
- Boshqa zamonaviy usullar (SPME, MEPS, SLE, DBS, onlayn SPE, soch tahlili) — alohida usul kartochkasi sifatida keyin; manba tekshiruvidan so‘ng.
- **Yulduzcha:** bosilmagan holat ham oltin «tabletka» (ustoz bilan bir xil o‘lcham va rang; farq — faqat yulduz to‘liq/bo‘sh).

- **Tuzatish (egasi, 2026-11-03):** SPE kartochkasidan markaz e’loni (O‘zbekiston bloki va manba) olib tashlandi — «faqat usulni yozamiz». Keyingi buildda.

## 2026-11-03 — O‘z kartochkasidagi yulduzcha (build 55)
- **Muammo (egasi):** «Mutaxassis — menda 1 ta yulduzcha bor, sen yo‘q deding». Bazada (`catalog_stars`) egasining mutaxassis kartochkasiga 1 ta yulduz bor edi; server `stars=1` qaytaradi. Xato ilovada: o‘z kartochkasida yulduz belgisi «men bosganmanmi» (`starred`) bo‘yicha chizilardi — o‘ziga bosib bo‘lmagani uchun u doim `false`, natijada olingan yulduz bo‘sh kontur bo‘lib ko‘rinardi.
- **Tuzatish:** o‘z kartochkasida yulduz `stars > 0` bo‘lsa to‘liq oltin, tabletka ustozlar ro‘yxatidagi bilan bir xil; bosilmaydi (`cat.starMine.<id>`). Widget test + skrinshot (`star_shots_test`).
- Build 55 tarkibi: SPE kartochkasi markaz e’lonisiz + shu tuzatish.
- **Build 55 chiqarildi (2026-11-03):** `0e808699` (branch `claude/pro-0.4.0`), release-build run #411 — Android AAB imzolangan, Play internal (draft) + iOS TestFlight (review’ga yuborilmagan); keyin internal testerlarga rollout. Tekshiruv: to‘liq suite 3821 o‘tdi; real ilova — talaba 46/46, mutaxassis 37/37, SPE 6/6. Sinalmagan: real telefon.
- **Tasodifiy symlink:** `a38fbb69` ga `apps/mobile/build -> /dev/shm/fe_build` symlink tushib qolgan edi (CI runner’da osilib qoladi); `0e808699` da olib tashlandi, `apps/mobile/.gitignore` da `/build/` → `/build`.

## 2026-11-03 — Ustoz stolim: mavzu bo‘yicha og‘zaki bilet (build 56)
- **Egasi so‘rovi:** «Ustoz stolimga qo‘sh, mavzu bo‘yicha bilet qil … tartibli joyla». Asl kelishuv (2026-11-02): ustoz mavzu(lar)ni tanlaydi, har talabaga 5 savollik takrorlanmas bilet, ustoz telefondan 0–20 ball/savol, jami 100.
- **Joyi:** Ustoz rejimi → Asosiy → «Ustoz stolim» → 3-kartochka «Og‘zaki imtihon (bilet)» (Guruh testidan keyin). To‘r tartibi: Ma’ruza prezentatsiyalari | Guruh testi / Og‘zaki imtihon | Guruhlar / Natijalar (yolg‘iz oxirgi karta to‘liq kenglikda). Faqat Ustoz rejimida; Talaba/Mutaxassisda marshrut Asosiyga qaytaradi.
- **Savollar manbasi:** tanlangan darslarning slayd sarlavhalari (xizmat slaydlari — Kirish, Xulosa, Tezkor savol, Nazorat savollari, keys, reja — chiqarilgan; «(davomi)» oldingisiga qo‘shiladi); javob kaliti — slayd bandlari va manbasi. Matn to‘qilmaydi. 220 ta real darsda: har darsdan 14–58 (o‘rtacha 33) savol.
- **Bilet:** mavzular bo‘yicha aralash, ishlatilgan savol keyingi talabaga chiqmaydi, tugasa aylanish qaytadan. Natijalar faqat qurilmada (`fe.teacher.oralexam.v1`). Mutaxassisdagi «Bilim va malakani baholash» bileti o‘zgarmadi (umumiy savol kartochkasi).
- **Muallif initsiallari (egasi tasdiqladi):** «Yuldashev Z.A.» to‘g‘ri. «Z.O.» tuzatildi: server `lesson_decks` (3 deck), `class_quiz_questions` (126), `class_session_questions` (5) — zaxira `private.*_backup_zo_20261103`; `slides-out` seed fayllari (6); GC-MS o‘qish sahifasi.
- **Tekshiruv:** unit 7 + widget 9 (320 dp, 2×, uz/ru/en), arxitektura testlari, golden yangilandi (ustoz stoli), to‘liq suite (golden yangilanishidan oldin 3833 o‘tdi), real ilova: teacheroral 26/26, student 46/46, expert 37/37, class 86/86, oral 9/9, oralstudent 3/3.
- **Chiqarildi:** `15f0b454` (branch `claude/pro-0.4.0`), release-build run #413 → Play internal (versionCode 56, rollout run #414) + TestFlight (review’ga yuborilmagan). Sinalmagan: real telefon.
- **Play eslatma:** yangi testerlar faqat «Closed testing – Alpha 1» ro‘yxatlariga qo‘shilgan; buildlar faqat ichki trekka chiqadi — ichki test «Тестировщики» da ro‘yxat belgilanishi kerak (egasi qiladi).

## 2026-11-03 — Guruh og‘zaki imtihoni (QR bilan) — egasi qarori, build 57 rejasi
- **Taklif (egasi):** ustoz talabalar sonini belgilaydi → doskada QR → talabalar skanerlab ismini yozadi → har biriga har xil bilet (1…N) → javobga tayyorlar navbat bo‘lib keladi → ustoz ro‘yxatdan tanlab javobni eshitadi va baholaydi (test kabi).
- **Qarorlar (egasi, 2026-11-03):** (1) talaba biletini **qo‘shilishi bilan** ko‘radi, ustoz ixtiyoriy tayyorlanish vaqtini qo‘yadi; javob kaliti talabaga ko‘rinmaydi. (2) Ball qo‘yilgach talaba **o‘z balini darhol** ko‘radi; doskada va boshqalarda ballar ko‘rinmaydi. (3) Serverga yangi jadval/funksiyalar — **ruxsat berildi** (zaxira + migratsiya, keyin ustoz+talaba sinovi, build 57). Roliklar tugagach boshlanadi.
- Qayta ishlatiladi: «Guruh testi» QR/6 xonali kod, ism bilan qo‘shilish, proyektor rejimi, jonli ro‘yxat; savollar — 56-builddagi mavzu bileti mantig‘i (dars slaydlari).
- Keyingi kichik tuzatish: mavzu tanlash ekranida kurs tugmalari chapdan zich joylashsin (hozir o‘rtada, bittadan qator).

## 2026-11-03 — Dars ovozi (tts-prefill) holati va egasi qarori
- Holat (06:10 UTC): navbatda 8622 slayd, tayyor — 15 (oxirgisi 2026-11-02 19:00 UTC); Gemini bepul kunlik limiti tugagan (`quota:true`). 6 slayd `upstream_400` bilan qaytgan (4-kurs-davolash-06: 2, 3, 6, 7, 15; 4-kurs-davolash-01: 0) — ehtimol Gemini xavfsizlik filtri (tekshirilmagan).
- **Egasi qarori:** hozircha **bepul limitda** davom etiladi (~15–20 slayd/kun); pullik reja (~$32, bir kunda tugaydi) — mablag‘ tushganda egasi aytadi.
- Aniqlik: ilovada qurilma (device) ovozi bilan zaxira o‘qish YO‘Q — tayyor ovozi yo‘q slaydda limit tugagan bo‘lsa «Tinglash» xato xabarini ko‘rsatadi; «Tushuntirish» matni ekranda o‘qiladi. Variantlar (egasi qarori kerak): telefon ovozi bilan zaxira (o‘zbekcha ovoz deyarli yo‘q) yoki boshqa neyron ovoz (litsenziya shartlari aniqlanmagan).
- Build 57 ga: tinglash paytida ekran o‘chmaydi (ref-counted keep-awake).
- Guruh og‘zaki imtihoni: talaba bilet ekranidan chiqsa (ilova fonga o‘tsa) hisoblanadi — `oral_report_leave`, ustoz navbat/baholash ekranida «Ilovadan chiqdi: N marta» ko‘radi (egasi: «AI’dan foydalanmasin»).

## 2026-11-03 — Guruh og‘zaki imtihoni chiqarildi (build 57)
- **Server:** `20261103010000_oral_sessions.sql` production’ga qo‘llandi (07:40 UTC) — yangi `oral_sessions`, `oral_tickets`, `oral_participants` (RLS yoqilgan, jadval huquqi yo‘q) va 11 ta RPC; faqat `authenticated` (anon’da hech biri yo‘q, tekshirildi). Mavjud ma’lumotga tegilmadi. Lokal DB testlari: `run_local.sh` 3121 PASS, CI run #478 yashil.
- **Ilova:** Ustoz stolim → Og‘zaki imtihon → mavzu tanlash → «Guruhga (QR)»: talabalar soni (1..200), tayyorlanish vaqti (yo‘q/5…30 daq) → doska (QR + 6 xonali kod, biletlar to‘ri, ballarsiz) → navbat (tayyorlar oldin) → baholash (0–20, kalit faqat ustoz telefonida) → natijalar. Talaba: QR/kod, ism, tasodifiy bo‘sh bilet darhol, ortga sanoq, «Javobga tayyorman», faqat o‘z bali. Bilet ekranidan chiqish ustozga «Ilovadan chiqdi: N» bo‘lib ko‘rinadi. Tinglashda ekran o‘chmaydi. Mavzu tanlashda kurs tugmalari chapdan zich.
- **Tekshiruv:** unit + widget (320 dp, 2×, uz/ru/en), arxitektura; `flutter analyze` toza; real ilova: oralgroup 35/35, teacheroral 26/26, class 86/86, student 46/46, expert 37/37. Sinalmagan: ikki real telefon bilan production serverda.
- **Chiqarish:** `b54398dc` (branch `claude/pro-0.4.0`, 0.4.0+57), release-build run #415 → Play internal (draft) + TestFlight (review’ga yuborilmagan).

## 2026-11-04 — Dars kuni (60 talaba), tuzatishlar va qarorlar (builds 58–60)
- **Kirish majburiy (build 58, Play):** ro‘yxatdan o‘tmasdan foydalanib bo‘lmaydi (`FE_REQUIRE_LOGIN`, standart yoqiq; faqat real backend). Apple uchun alohida **iOS-only review build 59/419** (`store_review`: kirish majburiy emas, 5.1.1(v)); Play’da 58 qoladi, keyingi Play build ≥ 60.
- **Majburiy yangilash o‘chiq** (`app_config.min_build=42`): dars paytida «yangilang» yo‘q; faqat egasi aytganda yoqiladi.
- **AI imtihonda yopiladi (server):** `ai_exam_lock` + `ai-answer` v10 (423 `exam_locked`). Mijoz tomoni (orqaga/chiqish cheklovi, AI tugmasini yashirish) — 59/60.
- **Dars natijasi:** 33 talaba, 5 guruh (461–465), o‘rtacha 68–72%, server xatosi 0 (5054 so‘rov). Natija rasmlari (1-2-3 o‘rin, 100 ball, PF-191 bahosi) egasiga yuborildi.
- **Server tuzatishlari (build’siz):** `email-otp` limiti: IP 10→200 / 10 daq, email 3→8 / 10 daq, qayta yuborish oralig‘i 60→15 s; `admin_users` sahifasi kamida 150; `class_hidden_topics` mexanizmi (bo‘sh; kerak bo‘lsa mavzuni yashiradi); `class_groups.archived_at`, `group_set_archived`, `group_delete` (ilova tugmalari build 60 da).
- **Savol manbalari tekshiruvi:** 4-kurs davolash 01–13 mavzulari 90–100% sud tibbiyoti darsligidan; 14–19 (va 6-kurs 03, 05–08) — tibbiyot huquqi (o‘quv reja bo‘yicha, huquq kitobidan). «Sud-tibbiy toksikologiya» (10) da 8/30 savol «Токсикологическая химия» (Almaty) kitobidan — litsenziyasi ko‘rsatilmagan. Hech narsa yashirilmadi (egasi: reja mavzulari qolsin).
- **Professor G‘iyosov Z.A. ruxsat berdi** (og‘zaki, 2026-11-04): kitoblaridan foydalanish va minnatdorchilikda ism qoldirilsin. Yozma tasdiq (Telegram skrinshoti) saqlash tavsiya etildi.
- **Professor fikri (tuzilma):** «Toksikologiya» alohida emas; sud-tibbiy ekspertiza ichida sud kimyosi / sud biologiyasi / sud gistologiyasi (morfologiya) / tibbiy kriminalistika bo‘lsin; ilova nomi o‘zbekcha ham yozilsin («Sud ekspertizasi»). **Kutilmoqda:** egasi professor bilan tuzilmani tasdiqlaydi, keyin bosh sahifa va dars kurslari nomlari moslanadi.
- **Apple:** 20-okt rad (4.3/4.2.6); javob + Notes yuborilgan, build 419 biriktirilgan, «Waiting for Review»; TestFlight tashqi guruh «Talabalar» (15 ta) Beta Review kutmoqda.
- **GitHub Actions bloklangan (2026-11-04):** to‘lov ($63,09) rad etilgan + Actions budget $0 → build’lar 3 soniyada yiqiladi. Zaxira: **Codemagic** (`codemagic.yaml`: `ios-testflight`, `android-release`; bepul 500 macOS-M2 daqiqa/oy; guruhlar `fe_ios`, `fe_android`). Android sinov kaliti (`fe-test`, SHA-1 08:3F:A0:12:…:CF:69) Google Cloud/Supabase’ga qo‘shilgan; haqiqiy upload kalit `fe-upload.jks` topilmagan (Play’ga yuklash uchun kerak).
- **Google/Apple kirish:** Supabase’da yoqilgan; build 60 da `FE_SOCIAL_SIGNIN` bilan; real telefonda sinalmagan.
- **Play tester chegarasi (ichki 100):** 100/100 to‘ldi; ortiqchasi yopiq test (Alpha 1, «Talabalar 2») orqali.
- **Ochiq ishlar:** Codemagic build natijalari; Alpha 1 → 58; admin ro‘yxatida bo‘sh testlarni yashirish (egasi roziligi kerak); maxfiylik sahifasini GitHub Pages’dan o‘z domeniga ko‘chirish; kod zaxirasi; R2 (MP3 siqish → R2); ru/en kontent tarjimasi (limit tiklangach).
