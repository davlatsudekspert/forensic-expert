# «Ustoz Pro» — taqdimot bo'limi: reja va baho (2026-10-11)

> Holat: **taklif**. Kod yozilmagan. Egasi «ha» degandan keyin boshlanadi.

## 1. Repo nimaga tayyor, nimaga tayyor emas

**Tayyor (qayta ishlatiladi):**
- `learn` bo'limi (Learn / Exam / Quiz / Flashcards / StudyHub) — taqdimotning
  tabiiy uyi; yangi tab ochish shart emas.
- Pro darvozasi: `ProductFeature` + `AccessPolicy`, bepul demo tushunchasi
  (`court_prep` aynan shunday ishlaydi) va `admin_set_access` orqali qo'lda
  grant — muassasa litsenziyasi uchun ayni mos.
- **Xususiy Storage bucket + storage RLS allaqachon ishlayapti**
  (`credentials` — mutaxassislik hujjatlari). PPTX/slayd uchun shu naqsh
  takrorlanadi: fayl bytes'i hech qachon ilovaga qaytarilmaydi.
- Server naqshi: RLS yoqilgan, siyosatsiz jadval + `SECURITY DEFINER` RPC +
  `private.admin_guard()` + audit log. Yangi jadvallar shu tartibda.
- Mutaxassis tasdig'i (`VERIFIED_PROFESSIONAL`) — «ustoz» roli uchun asos bor.

**Yo'q (yangi quriladi):**
- «Ustoz» roli. Hozir `account_role` faqat `identity_admin` va
  `scope_grantor`. Yangi rol yoki `teacher_grants` jadvali kerak.
- Hech qanday ekran himoyasi (`FLAG_SECURE` kodda umuman yo'q).
- Fayl konvertatsiyasi (PPTX → rasm) infratuzilmasi. Edge Functions —
  Deno; LibreOffice u yerda ishlamaydi.
- Tashqi ekran (monitor) bilan ishlash qatlami.

## 2. Bosqichlar

**A. Poydevor (eng katta qiymat, eng kam xavf).**
Slayd domeni (dars → slaydlar → eslatmalar → manbalar), `teacher_decks` va
`deck_slides` jadvallari, «ustoz» roli, Pro darvozasi, ko'ruvchi jurnali
(kim, qachon, qaysi slaydni ko'rdi). Ilova tayyorlagan slaydlar — mavjud
kontent paketidan, manbalari bilan, tekshirilmagani «qoralama» deb
belgilanadi (mavjud status tizimi aynan shuni qiladi).
Taxminiy hajm: **o'rta** (1 migratsiya + 1 domen + 2–3 ekran + testlar).

**B. Himoya.**
Yuklab olish/ulashish tugmasi yo'q; har slaydda ko'ruvchi taxallusi bilan
suv belgisi; Android `FLAG_SECURE`; iOS'da ekran yozuvi sezilsa slaydni
yashirish. Ko'rish jurnali — asosiy javobgarlik vositasi.
Taxminiy hajm: **kichik–o'rta** (ikkita platforma kanali + UI).

**C. Taqdimot rejimi (monitor).**
Pastdan yuqoriga: avval **ko'zgu rejimi** (monitor telefondagi bilan bir xil,
toza 16:9 slayd, boshqaruv ustma-ust), keyin agar kerak bo'lsa haqiqiy
ikki ekran.
Taxminiy hajm: ko'zgu — **kichik**; haqiqiy ikki ekran — **katta**.

**D. Ustoz PPTX'i (eng qimmat qism, 3-bo'limga qarang).**

**E. Uch til, testlar, QA, test tarqatish.** Har bosqichda, oxirida emas.

## 3. Texnik haqiqat — uchta ochiq gap

**(1) PPTX'ni serverda rasmga aylantirish — Edge Function'da ishlamaydi.**
Deno muhitida LibreOffice/PowerPoint yo'q. Variantlar:
- **(a) Ustoz o'zi eksport qiladi** — PowerPoint'dan PDF yoki PNG qilib
  yuklaydi, server faqat qabul qiladi va kesadi. **Yangi infratuzilma
  kerak emas, pul ketmaydi.** Tavsiyam: v1 uchun shu.
- (b) Alohida konteyner xizmati (LibreOffice headless). To'g'ri yechim,
  lekin oylik to'lov, monitoring va xavfsizlik yuki qo'shadi.
- (c) PPTX'ni umuman qabul qilmaslik — faqat ilova slaydlari.

**(2) iOS'da skrinshotni bloklash mumkin emas.**
Android'da `FLAG_SECURE` ishlaydi. iOS'da unga teng narsa yo'q: faqat ekran
**yozuvi**ni sezish (`isCaptured`) va skrinshot **olingandan keyin** xabar
olish mumkin. Ya'ni iPhone'da skrinshot oldini olib bo'lmaydi — faqat
jurnalga yozish va suv belgisi qoladi. Buni foydalanuvchiga ham ochiq
aytish kerak.

**(3) Monitorda boshqa, telefonda boshqa narsa ko'rsatish — oson emas.**
AirPlay/HDMI odatda ekranni **ko'zgu** qiladi. Haqiqiy ikki ekran uchun
har ikki platformada mahalliy kod kerak (iOS'da ikkinchi `UIWindow`,
Android'da `Presentation` API) — Flutter buni tayyor bermaydi.
Va `FLAG_SECURE` Android'da **HDMI/Cast chiqishini ham bloklaydi** — shuning
uchun himoya faqat talaba rejimida yoqiladi, ustoz rejimida o'chiriladi.

**100% himoya yo'q.** Boshqa telefon bilan ekranni suratga olishni hech
qanday dastur to'xtata olmaydi. Suv belgisi va ko'rish jurnali — qaytarish
emas, **kimdan tarqaganini aniqlash** vositasi. Buni shartnomada ham,
ilovada ham ochiq yozish kerak.

## 4. Sud ekspertizasiga xos talablar

**Tasvirlar.** Har rasm uchun: «o'quv maqsadida» bayrog'i, anonimlashtirish
tasdig'i, xira ko'rinish + «og'ir tasvir» ogohlantirishi, bosganda ochiladi,
18+. Xira ko'rinish **mijozda emas, serverda** tayyorlangan alohida rasm
bo'lsin — aks holda to'liq rasm baribir qurilmaga tushadi.

**Yuklashda avtomatik tekshiruv (ogohlantirish, taqiq emas).** Matnda ish
raqami, ekspertiza raqami, F.I.Sh. qolipi, sana+joy birikmasi topilsa —
ustozga ogohlantirish chiqadi va **«men anonimlashtirdim»** degan yozma
tasdiq so'raladi; tasdiq jurnalga yoziladi. Yuz aniqlash avtomatik
qilinmaydi (xato ko'p) — bu ustozning mas'uliyati, lekin eslatma ko'rsatiladi.

**Toksikologiya chegarasi.** Moddalar, dozalar, usullar faqat o'quv/ekspert
konteksti. Qabul qilinmaydi: zahar tayyorlash tartibi, aniqlanmaslik
yo'llari, dozani yashirish. Bu qoida «Savol-javob» bo'limida yozilgani bilan
bir xil — shu matn qayta ishlatiladi.

**Mualliflik huquqi.** Yuklashda ustoz tasdiqlaydi: men muallifman yoki
ruxsatim bor. Tasdiq sanasi va matni jurnalda qoladi.

**Yurist tekshiruvi kerak bo'lgan joylar (men hal qila olmayman):**
1. Ekspert siri va dastlabki tergov ma'lumotlarining oshkor etilmasligi —
   o'quv maqsadida ham tasvir ko'rsatish mumkinmi, qanday shartda.
2. Shaxsiy ma'lumotlar qonuni: marhum va uning qarindoshlari ma'lumoti;
   anonimlashtirish qaysi darajada yetarli hisoblanadi; rozilik kerakmi.
3. Jasad tasvirlarini o'quv materialida ishlatish bo'yicha vazirlik
   tartibi — markaz ichki qoidasi bormi.
4. Muassasa litsenziyasi shartnomasi: kim javobgar, tarqalsa oqibat nima.
5. Ustoz yuklagan materialning egaligi va ilovadan o'chirilishi tartibi.

**Do'kon qoidalari.** Foydalanuvchi yuklagan kontent bor ekan,
App Store/Play **moderatsiya, shikoyat tugmasi va bloklash** talab qiladi;
tibbiy/og'ir tasvirlar yosh reytingini ko'taradi. Buni ariza bermasdan
oldin hal qilish kerak.

## 5. Narx va tarif (taklif, qaroringiz kerak)

Mavjud tizimda `studentPro` va `professionalPro` bor, mahsulotlar bitta
obuna guruhida. Eng kam o'zgarish: **ustoz uchun alohida mahsulot** emas,
`professionalPro` ichida «Ustoz» imkoniyati. Muassasa litsenziyasi esa
do'kon obunasi emas — `admin_set_access` orqali server granti.
**Diqqat:** ilova ichida ishlatiladigan raqamli kontentni do'kondan tashqari
sotish Apple qoidalariga ziddir; muassasa litsenziyasini qanday rasmiylash-
tirish — yurist va buxgalteriya bilan hal qilinadigan masala.

## 6. Nimalarga tegilmaydi

Mavjud baza va servislar pauza qilinmaydi, pullik tarif yoqilmaydi,
LabGuide/NFCSTORE/BugunBor repolariga tegilmaydi, ommaviy nashr yo'q —
faqat test tarqatish. Ulanmagan funksiya «ishlayapti» deb ko'rsatilmaydi.

## 7. Mendan kerak bo'lgan qarorlar

1. **PPTX:** (a) ustoz PDF/PNG qilib yuklaydi — infratuzilmasiz, **tavsiyam**;
   (b) alohida konvertatsiya xizmati (oylik to'lov); (c) PPTX yo'q.
2. **18+ siyosati:** og'ir tasvirlar umuman bo'ladimi? Bo'lsa — faqat
   tasdiqlangan mutaxassislargami yoki talabalarga ham?
3. **Narx:** ustoz imkoniyati `professionalPro` ichidami yoki alohida
   qimmatroq tarifmi; muassasa litsenziyasi narxi va kim sotadi.
4. **Monitor:** v1 uchun ko'zgu rejimi yetarlimi (telefon va monitorda bir
   xil), yoki haqiqiy ikki ekran shartmi (ancha katta ish).
5. **Birinchi dars:** qaysi mavzudan boshlaymiz — sinab ko'rish uchun bitta
   to'liq taqdimot.
6. **Yurist:** 4-bo'limdagi beshta savolni kim va qachon tekshiradi.
