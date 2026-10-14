# Egasining topshirig‘i (2026-10-14): limit tejash + yakuniy audit va ikki tomonlama kelishuv

> **HOLAT: SAQLANDI, ISH BOSHLANMAGAN.** Egasi: «Saqla, ish boshlama. Shanba boshlaymiz, limit tiklangach avto boshlab yozasan.»
> Shanba (2026-10-17) birinchi bosqich — **faqat audit, hisobot va takliflar**. Egasi «MA’QULLAYMAN, BOSHLANG» demaguncha: kod yozilmaydi, kontent bazasi o‘zgarmaydi, migratsiya/deploy/build/commit (hujjatdan tashqari) qilinmaydi, implementatsiya agentlariga topshirilmaydi.
> Bu matn egasining so‘zlari; quyida o‘zgartirishsiz saqlangan.

---

## A. CLAUDE CODE LIMITINI TEJASH VA MODELLARDAN OQILONA FOYDALANISH

Bu talab oldingi FORENSIC EXPERT master topshirig‘imga MUHIM QO‘SHIMCHA.
Men Claude Code Max 20x tarifidan foydalanaman. Maqsad — limitni behuda sarflamasdan, mavjud imkoniyatlardan maksimal darajada samarali foydalanish.

**ASOSIY QOIDA: HAR BIR VAZIFAGA UNING MURAKKABLIGIGA MOS MODEL VA FIKRLASH DARAJASINI TANLA.**

### 1. Modellarni vazifaga qarab tanla
**HAIKU yoki mavjud eng tejamkor model:** oddiy fayl qidirish va ro‘yxatlash; fayllarni tasniflash; mavjud ma’lumotlarni tartiblash; takroriy yozuvlarni aniqlash; oddiy hujjat formatlash; sodda texnik tekshiruv; kichik, aniq va xavfi past topshiriqlar.

**SONNET — asosiy ish modeli:** Flutter ekranlari va odatiy funksiyalar; test yozish; lokalizatsiya; kontent pipeline; ilmiy adabiyotlarni inventarizatsiya qilish; mavjud kodni tahlil qilish; oddiy va o‘rtacha murakkab xatolarni tuzatish; dasturlash agentlarining kundalik ishlari.

**OPUS — faqat murakkab va muhim ishlar uchun:** katta arxitektura qarorlari; murakkab, ko‘p komponentli xatolar; bir nechta agent ishini ziddiyatsiz birlashtirish; ilmiy manbalar o‘rtasidagi murakkab ziddiyatlar; muhim huquqiy va ilmiy xatarlarni baholash; xavfsizlik arxitekturasining murakkab masalalari; yangi yirik funksiyaning yakuniy texnik yechimi.

Opus’ni oddiy fayl o‘qish, formatlash, tarjima kalitlarini joylashtirish, oddiy test yoki ro‘yxat tuzish uchun ishlatma.

### 2. Modellarni o‘zing boshqar
Agar Claude Code muhiti modelni vazifaga qarab avtomatik tanlash yoki subagentga alohida model berish imkoniyatini qo‘llasa, undan foydalan. Murakkab ish tugasa, keyingi oddiy ishni yana tejamkor modelda bajar. Bir butun sessiyani zaruratsiz Opus’da olib borma. Agar muhitda avtomatik model almashtirish imkoniyati bo‘lmasa, bunga urinib ishlamay qolma: mavjud sozlamalar doirasida eng tejamkor usulni tanla va kerakli modelga qo‘lda o‘tish zaruratini menga ayt. Mavjud bo‘lmagan model yoki imkoniyatni bor deb ko‘rsatma. Oldingi kelishuvga muvofiq **Fable’dan foydalanma**.

### 3. Limitni tejash
- Bitta faylni sababsiz qayta-qayta o‘qima.
- Oldingi audit va hisobotlardan foydalan.
- Bir xil vazifani bir nechta agentga takroran topshirma.
- Avval kichik va aniq qidiruv bajar, keyin kerakli fayl qismini o‘qi.
- Katta kontekstni keraksiz loglar bilan to‘ldirma; uzun loglardan kerakli xatolarni ajrat.
- Mavjud testlarni qayta ishlat.
- Har mayda o‘zgarishdan keyin butun test to‘plamini ishga tushirma; avval tegishli testlarni bajar. Katta integratsiyadan keyin to‘liq regressiya testini albatta bajar.
- Test, build va ma’lumot yig‘ish uchun mavjud skript va avtomatlashtirish vositalaridan foydalan.
- Parallel agentlarni faqat ishlar mustaqil bo‘lganda ishlat. Keraksiz agentlar, takroriy tadqiqotlar va ortiqcha kontekst yaratma.

Tejamkorlik sifatni pasaytirish degani emas. Arzon model vazifani to‘g‘ri bajara olmasa, kuchliroq modelga o‘t. Ilmiy aniqlik, xavfsizlik va test sifatini limitni tejash uchun qurbon qilma.

### 4. Mavjud imkoniyatlardan foydalan
Maxsus subagentlar; alohida worktree; loyiha xotirasi va `CLAUDE.md`; avtomatlashtirilgan testlar; GitHub Actions; mavjud skriptlar; ilmiy manba tekshirish vositalari; kerakli joyda parallel ishlar; kontekstni ixchamlashtirish va sessiyalar orasida ishni davom ettirish. Maxsus agent yoki tashqi vosita vaqt, limit yoki pulni ko‘proq talab qilsa, foydasini bahola. **Yangi pullik API yoki servisni ruxsatimsiz faollashtirma.**

### 5. Limit tugashiga yaqinlashganda
Qolgan limitni taxmin qilib aniq foiz sifatida ko‘rsatma. Limit kamayganda: yangi katta vazifa boshlama; tugallangan ishlar holatini saqla; bajarilgan va qolgan vazifalarni yoz; muhim qarorlarni hujjatlashtir; keyingi sessiya uchun aniq davom ettirish nuqtasini qoldir. Limitni chetlab o‘tish yoki cheklovlarni buzishga urinma.

### 6. Oldingi ishlarni takrorlama
Avval `CLAUDE.md`, loyiha hujjatlari, faol branch va oxirgi commitlarni o‘rgan. DONE bo‘lgan funksiyani qaytadan yozma. Mavjud sifatli kod, kontent, tarjima, dizayn va testlarni saqla.

### 7. Ikki tomonlama kelishuv saqlanadi
Hozirgi bosqichda: (1) loyihani tahlil qil; (2) qilingan ishlarni ko‘rsat; (3) yetishmayotgan ishlarni aniqla; (4) o‘z texnik va ilmiy takliflaringni ber; (5) qaysi vazifaga qaysi model mosligini ham rejalashtir; (6) menga xarajat, murakkablik va ustuvorlik bo‘yicha hisobot ber. «MA’QULLAYMAN, BOSHLANG» demagunimcha yangi implementatsiya, commit, build yoki deploy boshlama. Tasdiqdan keyin kelishilgan ishlarni sifatli, mustaqil va tejamkor olib bor.

**YAKUNIY TALAB: MAKSIMAL SIFAT + MINIMAL ISROF + TO‘G‘RI MODEL TANLOVI + OLDINGI ISHLARNI TAKRORLAMASLIK.**

---

## B. FORENSIC EXPERT — YAKUNIY AUDIT, ILMIY RIVOJLANISH REJASI VA IKKI TOMONLAMA KELISHUV

### Asosiy topshiriq
Sen FORENSIC EXPERT loyihasining bosh arxitektori, dasturchisi, ilmiy ma’lumotlar tizimi mutaxassisi, UI/UX dizayneri va sifat nazoratchisi sifatida ishlaysan. FORENSIC EXPERT — barcha sud-ekspertiza yo‘nalishlari uchun mo‘ljallangan xalqaro ilmiy, amaliy va ta’limiy platforma. **BU YANGI ILOVA YARATISH EMAS. MAVJUD LOYIHANI MUKAMMALLASHTIRISH BO‘YICHA KELISHUV OLDI TOPSHIRIG‘I.** Men senga ko‘p topshiriqlar berganman; sen ham o‘z ish rejalaringni va texnik qarorlaringni ishlab chiqqansan. Endi hammasini bir joyga jamlab, solishtirib, nima bajarilganini, nima yetishmasligini va qanday rivojlantirish kerakligini aniqlaymiz.

**HOZIRCHA YANGI FUNKSIYA YARATMA, KODNI O‘ZGARTIRMA, BUILD, DEPLOY YOKI PRODUCTION MIGRATSIYA QILMA.** Avval to‘liq tahlil va takliflar. Men hisobotni ko‘rib o‘z fikrimni yozaman; sen fikrlarimni hisobga olib yakuniy rejani taklif qilasan; kelishib, men aniq «MA’QULLAYMAN, BOSHLANG» deganimdan keyingina yangi ishlar amalga oshiriladi.

### 1. Avval o‘zingning bajarilgan ishlaringni tekshir
Repository: `davlatsudekspert/forensic-expert`. Eng so‘nggi faol branch, HEAD, commitlar va birlashtirilmagan ishlarni aniqla. O‘qi: `CLAUDE.md`, `docs/SHANBA_REJA_2026-10-17.md`, `docs/35_MASTER_PROMPT_GLOBAL_PLATFORM.md`, `docs/PROJECT_STATUS.md`, `docs/ACTIVE_TASKS.md`, `docs/DECISIONS.md`, `docs/BACKLOG.md`, `docs/TEST_REPORT.md`, `docs/ABY_COVERAGE.md`, `docs/SUBSTANCE_COVERAGE_AUDIT.md`, `docs/L10N_AUDIT_20261009.md`, `docs/USTOZ_PRO_PLAN.md`, `docs/GLOBAL_GROWTH_PLAN.md`, `docs/curriculum/` dagi barcha o‘quv dasturlari; boshqa tegishli hujjatlar, agent hisobotlari va test natijalari. Har bir eski vazifani amaldagi kod bilan solishtir va ajrat:
- BAJARILGAN VA SINOVDAN O‘TGAN
- BAJARILGAN, LEKIN REAL SINOV TALAB
- QISMAN BAJARILGAN
- BAJARILMAGAN
- XATOSI BOR
- QO‘SHIMCHA ADABIYOT KERAK
- EGASINING QARORI KERAK

Mukammal bajarilgan ishni qayta qilishni taklif qilma. Mavjud dastur, fanlar, dizayn, kontent paketlari, foydalanuvchi rollari, ta’lim tizimi va manbalarni saqla.

### 2. Avvalgi master promptni to‘liq tahlil qil
Oldingi katta master topshiriq va barcha sud-ekspertiza fanlariga oid qo‘shimcha talablarni o‘rgan: (1) qaysilari bajarilgan; (2) qaysilari sening rejangda bor; (3) qaysilari takrorlanadi; (4) qaysilari yangi va foydali; (5) qaysilari texnik jihatdan noto‘g‘ri yoki ortiqcha; (6) qaysilari ko‘p xarajat talab qiladi; (7) qaysilari mavjud arxitekturaga zarar yetkazishi mumkin; (8) qaysilarini yaxshiroq yechim bilan almashtirish mumkin. Mening takliflarimga ko‘r-ko‘rona rozi bo‘lma; yaxshiroq variant bilsang, ilmiy va texnik dalillar bilan tushuntir. Kelishuvsiz katta o‘zgarish qilma.

### 3. Men yana qo‘shimcha ilmiy adabiyotlar beraman
Yo‘nalishlar: sud-tibbiy ekspertiza; sud-kimyo va toksikologiya; sud-gistologiya; sud-biologiya; sud-genetika; morfologiya; patologik anatomiya; tibbiy-kriminalistika; sud-antropologiya; sud-odontologiya; boshqa mavjud fanlar. Yangi adabiyotlarni mavjud manbalar tizimi orqali kirit; manbani qayta-qayta import qilma. Har bir yangi kitob bo‘yicha saqlansin: muallif; to‘liq nom; nashr yili; nashriyot; foydalanilgan bob; aniq sahifa; manbaning asl tili; foydalanish huquqi; qaysi mavzularni to‘ldirishi; mavjud kontent bilan mosligi. Yangi adabiyot kelganda avval mavjud ma’lumot bilan solishtir; mavzu mavjud bo‘lsa takroran yaratma — yangi dalil/tushuntirish bilan boyit; manbalar zid bo‘lsa farqni ilmiy asosda tushuntir. O‘qilmagan kitobdan sahifa yoki iqtibos to‘qima. Hali berilmagan adabiyot uchun alohida **«ADABIYOT KUTILMOQDA»** ro‘yxatini tuz. Yangi manbalardan ilmiy va huquqiy jihatdan to‘g‘ri foydalan.

### 4. «TASDIQLANMAGAN» belgisini ilmiy jihatdan to‘g‘ri qo‘lla
Ilovada ko‘p materiallar ilmiy kitoblar, maqolalar va ishonchli manbalardan olingan; hammasiga bir xil katta «TASDIQLANMAGAN» yozuvi qo‘yilib noto‘g‘ri taassurot uyg‘otilmasin. Lekin tekshirilmagan ma’lumotni asossiz tasdiqlangan deb ko‘rsatma. Ajrat:
1. «Ilmiy manbasi mavjud» — manba aniq identifikatsiya qilingan.
2. «Manbadagi joyi tekshirilgan» — da’vo asl manbaning aniq sahifasi/bo‘limi bilan solishtirilgan.
3. «Ilmiy taqrizdan o‘tgan» — vakolatli inson mutaxassis ko‘rib chiqqan.
4. «Qo‘shimcha tekshiruv kerak» — faqat konkret tekshirilmagan jihat mavjud.

Bitta maqola/kitobning ishonchliligi u asosida yozilgan har jumla taqrizdan o‘tganini anglatmasin. Ichki `NEEDS_REVIEW`, `HUMAN_VERIFIED` va boshqa maqomlar saqlansin; foydalanuvchiga ko‘rsatish dizaynini ilmiy ma’noni buzmasdan yaxshilashni taklif qil. Maqsad — foydalanuvchi FORENSIC EXPERT’ni oddiy AI chatbotdan ishonchliroq deb bilsin; buning asosi reklama yoki «100% tasdiqlangan» emas, balki aniq manba, tekshiriladigan dalil va xolis talqin.

### 5. Barcha fanlar uchun mukammal ilmiy kontent
Ilovadagi haqiqiy barcha sud-ekspertiza yo‘nalishlarini aniqla (faqat sud-kimyo bilan cheklanma). Har fan uchun baholash: ilmiy tushunchalar; mavzularning batafsil bayoni; amaliy metodikalar; tekshiruv obyektlari; namunalar; asbob-uskunalar; reaktivlar; natijalarni baholash; ilmiy rasmlar; jadvallar; diagrammalar; testlar; prezentatsiyalar; ilmiy manbalar; fanlar o‘rtasidagi bog‘lanishlar. Barcha fanlarga bitta qolipni majburan qo‘llama (gistologiya — mikroskopik tasvirlar; sud-tibbiyot — anatomiya, jarohatlar, o‘limdan keyingi o‘zgarishlar; sud-biologiya — serologiya, biologik izlar, DNK; sud-kimyo — rangli reaksiyalar, TLC/YuQX, GC, GC-MS, HPLC, LC-MS/MS, UV-VIS).

### 6. Rangli rasmlar, diagrammalar, jadvallar va laboratoriya natijalari
FORENSIC EXPERT — professional RASMLI ILMIY PLATFORMA bo‘lsin. Har mavzuga ilmiy qiymat qo‘shadigan vizual materiallar imkoniyatini tekshir.
- **Sud-kimyo va toksikologiya:** rangli reaksiyalar; musbat/manfiy natijalar; TLC/YuQX plastinkalari; dog‘lar va zonalar; Rf; harakatchan faza; sorbent/plastinka turi; aniqlovchi reaktiv; vizualizatsiya sharoiti; Rf taqqoslash; xromatogrammalar; retention time; GC/GC-MS va UV-VIS spektrlari; LC-MS/MS usullari; analitik jadvallar; sifat nazorati misollari; metod cheklovlari. **Rf:** bitta modda uchun yagona universal Rf ko‘rsatma; Rf bilan birga aniq eksperimental sharoit, sistema, plastinka, vizualizatsiya va manba bo‘lsin; bir nechta Rf — sharoitlari bilan jadvalda; manbasiz Rf, cho‘qqi, mass-spektr yoki reaksiya rangini uydirma.
- **Sud-tibbiyot:** anatomik rasmlar; jarohatlar tasnifi; morfologik va o‘limdan keyingi o‘zgarishlar; taqqoslovchi jadvallar; vaqt/holat diagrammalari; metodlarning imkoniyati va xatolari.
- **Sud-gistologiya:** normal va patologik preparatlar; mikroskopik tasvirlar; bo‘yash usullari; to‘qima tuzilishi; artefaktlar; yonma-yon solishtirma.
- **Sud-biologiya va genetika:** biologik izlar sxemalari; serologik jadvallar; DNK bosqichlari; natijani baholash diagrammalari; kontaminatsiya va sifat nazorati misollari.

MUHIM: haqiqiy laboratoriya surati bilan o‘quv sxemasini aniq ajrat; **AI yaratgan sxemani haqiqiy tajriba natijasi deb ko‘rsatma**. Rasm va jadvallar huquqiy jihatdan ruxsatli bo‘lsin. Vizual kontentni fan, mavzu, metod va manbaga bog‘lashning eng yaxshi mavjud yoki yangi minimal yechimini taklif qil.

### 7. Metodika faqat nomi bilan emas, tushuntirishi bilan
Metod ochilganda: nima uchun ishlatilishi; ilmiy prinsipi; qaysi namunada; asbob va reaktivlar; bosqichlar maqsadi; kutiladigan natija; aniqligi va cheklovlari; skrining yoki tasdiqlovchi ekani; natijalarni baholash; manbadagi aniq qiymatlar; sifat nazorati; adabiyotlar. Ishonchli manbalar bor joyda batafsil o‘quv-amaliy metodikalar rejalashtir. Laboratoriyada alohida validatsiya talab qilinsa, o‘quv metodikasi bilan haqiqiy SOP maqomini chalkashtirma.

### 8. Ustoz–talaba tizimi — oldingi o‘quv rejalarim asosida
`docs/curriculum/` ni tekshir (4-kurs davolash; 4-kurs pediatriya; 5-kurs tibbiy profilaktika; 6-kurs davolash). Darslarni o‘quv rejasiga mos bog‘la; mavjud darslarni qayta yaratma. Keyinchalik boshqa fanlar uchun ham o‘quv rejalari va materiallar beraman. Ustoz rejimi: professional 16:9 prezentatsiya; rasmli slaydlar; diagrammalar va jadvallar; tushuntirishlar; ustoz eslatmalari; katta ekranda namoyish; testlar; talabalar javoblari; dars yakuniy bahosi — `USTOZ_PRO_PLAN.md` bilan solishtir. Google Cast, AirPlay, HDMI va brauzer fullscreen bo‘yicha real imkoniyat, texnik cheklov va xarajatlarni ko‘rsat. Ilova ichida prezentatsiya ochilishi va odatiy foydalanuvchi PPTX/PDF ni to‘g‘ridan-to‘g‘ri yuklab olmasligi avvalgi talab bo‘lib qoladi.

### 9. Uch til — UZ / RU / EN
Oldingi lokalizatsiyani tekshir. UZ — o‘zbek lotin; RU — rus; EN — ilmiy ingliz. Interfeys, mavzular, tushuntirishlar, testlar, javoblar, ogohlantirishlar va darslar tanlangan tilda. Asl kitob/maqolaning bibliografik nomi va asl iqtibosi saqlansin; tarjima ilmiy ma’noni buzmasin; mavjud tarjimalarni qayta yozma, yetishmayotgan/noto‘g‘rilarini aniqla; maxsus huquqiy va til cheklovli manbalarni o‘zboshimchalik bilan tarjima yoki nashr qilma. (Eslatma: 2026-10-12 qarori — yangi kontent avval faqat o‘zbek tilida, RU/EN keyingi hafta; `CLAUDE.md` «Til tartibi».)

### 10. «Sudda so‘roq» va manbali javoblar
Oldin katta ish bajarilgan — qaytadan yaratma. Audit: savol; aniq javob; ilmiy asos; huquqiy asos; darslik/maqolaning aniq joyi; qo‘shimcha savollar; cheklovlar; manbalarni nusxalash; simulyator; Free/Pro taqsimoti. Har javobda da’voga mos manba bo‘lsin: umumiy ilmiy fikrni darslik, qonuniy huquq/majburiyatni normativ hujjat, konkret laboratoriya natijasini haqiqiy ekspertiza ma’lumotlari va validatsiya hujjatlari asoslaydi — **aralashtirma**. Oldingi bepul savol-javoblar bepul qoladi; ilg‘or AI simulyator va professional mashqlar Pro.

### 11. Biznes model va texnik xarajatlarni ham baholа
Free + Pro modelini saqla. Holatini ko‘r: Student Pro; Professional Pro; Ustoz Pro rejasi; institutsional litsenziya; AI kvotalari; Apple/Google billing; Restore Purchases; Supabase infratuzilmasi. Oldin kelishilgan bepul kontentni tasodifan pullik qilma. Yangi ilmiy-ta’limiy imkoniyatlar xarajatini hisobla; eng tejamkor va sifatli yechimlarni taklif qil. Yangi pullik servisni faollashtirma.

### 12. Har bir taklifni 5 tomonlama baholа
A. Sud-ekspert mutaxassisi (ilmiy aniqlik, metodika, talqin, cheklovlar). B. Universitet ustozi (dars sifati, rasmlar, tushuntirish, prezentatsiya, pedagogika). C. Talaba (tushunarlilik, testlar, o‘rganish qulayligi). D. Dasturchi va UX (arxitektura, platformalar, tezlik, ekranlar, xavfsizlik). E. Ilmiy muharrir (manbalar, terminologiya, sahifalar, tarjima, mualliflik huquqi, dalillar). Bu AI baholash inson taqrizi o‘rnini bosmaydi.

### 13. Sendan kutilayotgan birinchi hisobot (o‘zbek lotin; katta, tartibli, tushunarli; kod yozma)
1. Loyihaning hozirgi haqiqiy holati (tayyor / qisman / bajarilmagan).
2. Oldingi topshiriqlar bilan solishtirish (master prompt, o‘z rejalaring, yangi talablar).
3. Takroriy ishlar (qaytadan bajarish shart emaslari).
4. Qolgan kamchiliklar (ilmiy kontent, tarjima, fanlar, rasmlar, testlar, metodikalar, ta’lim, texnik).
5. Yangi adabiyotlar rejasi (qabul qilish, bog‘lash, takroriy ma’lumot yaratmaslik).
6. Vizual ilmiy kontent (rasmlar, diagrammalar, jadvallar, TLC plastinkalari, Rf, spektr, xromatogrammalar uchun aniq yechim).
7. Ustoz–talaba rejasi (fakultet o‘quv dasturlariga asoslangan dars tizimi).
8. Sifat va ishonchlilik (manbalar, da’volar, haqiqiy tekshiruv holatlari, ekspert taqrizi, xavfsizlik).
9. Texnik arxitektura (qayta ishlatiladigan komponentlar, minimal yangi qismlar).
10. O‘z takliflaring (men aytmagan, ammo ilovani xalqaro darajada foydaliroq, ilmiy kuchliroq va daromadliroq qiladigan). Har taklif uchun: qanday muammoni hal qiladi; foydalanuvchiga foydasi; mavjud funksiyalar bilan aloqasi; murakkabligi; taxminiy xarajat; xavfi; ustuvorligi; oldin qilingan/qilinmaganligi.
11. Mening qarorim kerak bo‘lgan masalalar (faqat haqiqatan egasi qarorini talab qiladiganlar; mayda texnik savollar bilan band qilma).
12. Bosqichma-bosqich amalga oshirish rejasi (nima, keyin nima, vaqt va resurs taxmini; shanba operatsion rejasi bilan moslashtir).

### 14. Ikki tomonlama kelishuv — qat’iy qoida
Tartib: (1) SEN loyihani tekshirasan; (2) SEN bajarilgan va yetishmayotganlarni ko‘rsatasan; (3) SEN tavsiyalar berasan; (4) MEN ko‘rib chiqaman; (5) MEN fikr, adabiyot va qarorlarimni yozaman; (6) SEN shular asosida yakuniy reja tuzasan; (7) MEN «MA’QULLAYMAN, BOSHLANG» deb aniq ruxsat beraman; (8) SHUNDAN KEYIN kodlash, integratsiya, sinov va commit. Rozilikdan keyin kelishilgan xavfsiz vazifalarni mustaqil bajarish mumkin; yangi katta yo‘nalish, pullik xizmat, production, ommaviy release yoki maxfiy ma’lumotlarga ta’sir qiluvchi o‘zgarishlar uchun alohida tasdiq kerak.

Hozircha: yangi kod yozma; kontent bazasini o‘zgartirma; migratsiya qilma; deploy qilma; build chiqarma; mavjud ishlarni o‘chirma; boshqa agentlarga implementatsiya topshirig‘i berma. Oldingi agentlardan tugallanmagan natijalar bo‘lsa, holatini aniqlab hisobotda ko‘rsat; ularni qayta ishga tushirma.

**BIRINCHI JAVOBING — FAQAT TO‘LIQ AUDIT, TAKLIFLAR VA KELISHUV UCHUN REJA BO‘LSIN.**

### Yakuniy maqsad
FORENSIC EXPERT dunyo bo‘yicha talabalar, universitet ustozlari va sud-ekspertiza mutaxassislari foydalanadigan, ilmiy manbalarga tayangan, vizual jihatdan boy, qulay va professional platforma bo‘lsin. Har fan uchun mavjud manbalar imkon bergan darajada mukammal ilmiy materiallar, tushuntirishlar, rangli tasvirlar, diagrammalar, jadvallar, metodikalar, testlar va darslar bo‘lsin. Ilmiy ma’lumotlar uydirilmasin. Mavjud bajarilgan ishlar takrorlanmasin. Ilova shoshma-shosharlik bilan emas, puxta o‘ylangan reja asosida rivojlantirilsin.

**HOZIR FAQAT TAHLIL QIL VA TAKLIF BER. MEN MA’QULLAGANIMDAN KEYIN ISHNI BOSHLAYSAN.**
