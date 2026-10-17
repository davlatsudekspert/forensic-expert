"""«Tahlil» 3 bo‘lim — kitob (ustoz) va ochiq adabiyot yozuvlari ma’lumotlari.

Qoidalar (CLAUDE.md «Til tartibi», 2026-10-12; feature-freeze):
  * Hamma yangi yozuv avval FAQAT o‘zbek tilida (`source_lang: "uz"`); RU/EN tarjima keyin.
  * Kitob (Yuldashev, Umarova, «Toksikologik kimyo», 2025 — muallif yozma ruxsati, docs/DECISIONS.md):
    so‘zma-so‘z ko‘chirilmaydi, mazmun o‘z so‘zimiz bilan, aniq bet bilan. Raqamlar kitobdagidek.
  * Ochiq adabiyot (PMC, CC BY): jumla ASL MATNDAN aynan (value.excerpt), litsenziya BioC dan tekshirilgan;
    o‘zbekcha tarjima — `machine_draft`, tekshirilmagan.
  * Manbada bo‘lmagan raqam / LOD / m/z / RT YOZILMAGAN.

BOOK: (suffix, modda, maydon, oila, sinf, matn_uz, bet_uz, bet_en, reaktivlar, havola)
  maydon — claim.field; oila — method_family; sinf — evidence_class;
  havola — (relation, to) graf bog‘lanishi yoki None.
"""

TAIL_PRESUMPTIVE = " Faqat taxminiy natija: u o‘zi bilan modda aynanligini isbotlay olmaydi."
TAIL_SCREEN = (" Dastlabki (yo‘naltiruvchi) sinama: sezgir bo‘lsa-da xos emas, natija qo‘shimcha tahlil "
               "bilan tasdiqlanishi shart.")
TAIL_QUANT = (" Bu yozuv kitobning o‘quv tavsifi; validatsiyadan o‘tgan laboratoriya usuli o‘rnini bosmaydi.")

SRC_TOKS = "SRC-YULDASHEV-TOKS-2025"
SRC_TOKS_UZ = "Yuldashev Z.A., Umarova G.Q., «Toksikologik kimyo» o‘quv-uslubiy majmua (2025)"

BARB = (
    "Peshobda barbituratlar bilan zaharlanishni taxminiy tekshirish uchun peshobga kobalt atsetati eritmasi "
    "ammiak yoki litiy ishqori sharoitida qo‘shilib, ekstraksiya qilinib aniqlanadi (manba bu o‘rinda rangni "
    "ko‘rsatmaydi). Bu — barbituratlar guruhi uchun sinama: guruh ichidagi alohida moddani ajratmaydi."
)

BOOK = [
    # ------------------------------------------------------------------ simob
    ("MERCURY-COLOUR_TEST-01", "mercury", "colour_test", "colour_test", "presumptive",
     "Ditizon bilan sinama (destruktatda): destruktat avval xloroform bilan chayqatib yuviladi (xloroform ulushi "
     "rangsiz bo‘lguncha), so‘ng tozalangan destruktatga 10% askorbin kislota, xloroform va ditizonning 0,01% "
     "xloroformli eritmasi qo‘shib chayqatiladi. Xloroform qatlamining sariq-zarg‘aldoq rangga kirishi simob "
     "borligidan dalolat beradi. Kumush kationi ham ditizon bilan sariq-tilla rang beradi; ikkalasini ajratish "
     "uchun xloroform qatlami 0,5 n xlorid kislota bilan chayqatiladi: kumush ditizonatida rang ko‘k-yashilga "
     "o‘tadi, simob ditizonatida o‘zgarmaydi." + TAIL_PRESUMPTIVE,
     "79-bet (simob), 202-bet (kumushdan farqlash)", "pp. 79, 202", ["ditizon", "askorbin kislota", "xloroform"],
     ("screened_by", "scr-colour-tests")),
    ("MERCURY-CHEMICAL_TEST-01", "mercury", "chemical_test", "chemical", "presumptive",
     "Mis(I) yodid osilmasi bilan sinama: destruktatning aniq hajmiga 10 ml CuI osilmasi qo‘shilsa, qizil-zarg‘aldoq "
     "cho‘kma — Cu2[HgI4] hosil bo‘ladi. Reaksiyaga oksidlovchilar xalaqit beradi: ular CuI dan erkin yod "
     "ajratadi." + TAIL_PRESUMPTIVE,
     "79-bet", "p. 79", ["mis(I) yodid"], ("screened_by", "scr-colour-tests")),
    ("MERCURY-SAMPLE_PREPARATION-01", "mercury", "sample_preparation", "sample_preparation", "supporting",
     "Simob quruq va ho‘l mineralizatsiyada deyarli butunlay yo‘qoladi, shuning uchun manba ob’ektni destruksiya "
     "qilishni tavsiya etadi (Vasileva usuli): ob’ekt nitrat va sulfat kislota bilan qisman parchalanadi, "
     "tezlashtirish uchun oz miqdor etanol qo‘shiladi, ortiqcha nitrat kislota mochevina bilan yo‘qotiladi. "
     "Jigar va buyrakdan har biri alohida ~20 g olinadi; kolbaga etanol 1 ml, konsentrlangan HNO3 10 ml, so‘ng "
     "tomchilab konsentrlangan H2SO4 10 ml qo‘shiladi (suv hajmi kitobning ikki joyida har xil: 5 ml va 10 ml), "
     "azot oksidlari kolbadan chiqib ketmasligi kerak; 10–20 daqiqa qaynoq suv hammomida qizdiriladi. Siydikdan "
     "(~200 ml, o‘rtacha kunlik) ikki usul keltirilgan: HNO3 + etanol + H2SO4 bilan 40 daqiqa suv hammomida, so‘ng "
     "to‘yingan tiomochevina; yoki H2SO4 va KMnO4 bilan, so‘ng rang yo‘qolguncha oksalat kislota. Qon jigar va "
     "buyrakdagidek ishlanadi, faqat suv qo‘shilmaydi." + TAIL_QUANT,
     "78-bet, 213-bet", "pp. 78, 213", ["nitrat kislota", "sulfat kislota", "mochevina"], None),
    ("MERCURY-ANALYTICAL_METHOD-01", "mercury", "analytical_method", "photometric", "supporting",
     "Miqdoriy aniqlash (destruktatda) kitobda ikki yo‘l bilan keltirilgan: ditizonat holida fotokolorimetrik "
     "usulda va Cu2[HgI4] holida kolorimetrik usulda. Laboratoriya mashg‘ulotida bular Cu2[HgI4] holida "
     "nefelometrik va ditizon ishtirokida fotometrik usul deb yoziladi; nefelometriyada destruktatga natriy "
     "sulfit eritmasi va CuI osilmasi qo‘shiladi, hosil bo‘lgan cho‘kma yodning kaliy yodiddagi eritmasida "
     "eritiladi va eritmadan simob miqdori aniqlanadi. Kitobning o‘qilgan bandlarida aniqlash chegarasi "
     "(LOD/LOQ), chiziqlilik oralig‘i yoki validatsiya ko‘rsatkichlari keltirilmagan." + TAIL_QUANT,
     "79-bet, 213-bet", "pp. 79, 213", ["ditizon", "mis(I) yodid"], None),
    # -------------------------------------------------------------- sirka kislota
    ("ACETIC-ACID-ODOUR_TEST-01", "acetic-acid", "odour_test", "odour_test", "presumptive",
     "Dastlabki belgi: ob’ektdan suv bug‘i bilan haydalgan distillyatdan sirka kislotasining o‘ziga xos hidi "
     "kelsa (bu ob’ektda kislota ko‘p bo‘lganda seziladi), bu sirka kislotasiga tekshirish uchun yo‘naltiruvchi "
     "belgi. Sirka kislota organizmda biokimyoviy jarayonlar natijasida oz miqdorda o‘zi ham hosil bo‘ladi, "
     "shuning uchun hid aynanlikni isbotlamaydi va keyingi sifat reaksiyalari bilan tasdiqlanadi." + TAIL_SCREEN,
     "31-bet", "p. 31", [], None),
    ("ACETIC-ACID-COLOUR_TEST-01", "acetic-acid", "colour_test", "colour_test", "presumptive",
     "Temir(III) xlorid bilan: distillyat neytrallanib bug‘latilgach, qoldiqning bir qismiga FeCl3 reaktivi "
     "qo‘shilsa qizil mahsulot hosil bo‘ladi, qizdirilganda u qo‘ng‘ir rangga o‘tadi. Manba keltirgan sezgirlik — "
     "0,5 mg sirka kislota." + TAIL_PRESUMPTIVE,
     "32-bet", "p. 32", ["temir(III) xlorid"], ("screened_by", "scr-colour-tests")),
    ("ACETIC-ACID-COLOUR_TEST-02", "acetic-acid", "colour_test", "colour_test", "presumptive",
     "Lantan nitrat va yod bilan: qoldiqning bir qismiga lantan nitrat, yodning spirtli eritmasi va ammiak "
     "qo‘shilsa, to‘q ko‘k rang yoki shu rangdagi cho‘kma hosil bo‘ladi." + TAIL_PRESUMPTIVE,
     "32-bet", "p. 32", ["lantan nitrat", "yod", "ammiak"], ("screened_by", "scr-colour-tests")),
    ("ACETIC-ACID-CHEMICAL_TEST-01", "acetic-acid", "chemical_test", "chemical", "presumptive",
     "Efir hosil qilish reaksiyalari: qoldiq etanol va konsentrlangan sulfat kislota bilan qizdirilsa sirka-etil "
     "efirining xarakterli hidi paydo bo‘ladi (manba keltirgan sezgirlik — 5 mg sirka kislota); amil spirti va "
     "konsentrlangan sulfat kislota bilan qizdirilsa nok essensiyasi hidi (sirka-amil efiri) seziladi. Yana bir "
     "yo‘l: qoldiqqa kalsiy tuzlari qo‘shib qizdirilsa aseton hosil bo‘ladi, undan indigo bo‘yog‘i olish mumkin."
     + TAIL_PRESUMPTIVE,
     "32-bet", "p. 32", ["etanol", "konsentrlangan sulfat kislota", "amil spirti"], ("screened_by", "scr-colour-tests")),
    ("ACETIC-ACID-SAMPLE_PREPARATION-01", "acetic-acid", "sample_preparation", "sample_preparation", "supporting",
     "Sirka kislota uchuvchan, shuning uchun suv bug‘i bilan haydab ajratiladi. Erkin (bog‘lanmagan) kislotani "
     "aniqlash uchun ob’ekt to‘g‘ridan-to‘g‘ri haydaladi; organizmda hosil qilgan tuzlarini aniqlash uchun "
     "ob’ekt muhiti 10% sulfat kislota bilan pH 2,5–3,0 gacha nordonlashtirilib haydaladi (kuchsiz kislotali "
     "muhitda sirka kislota ionlarga dissotsiyalanib, suv bug‘i bilan deyarli haydalmaydi). Kislota uchib "
     "ketmasligi uchun distillyat 0,1 n ishqor eritmasi saqlagan idishga to‘liq ajralguncha haydaladi; distillyat "
     "aniq hajmga keltirilib teng ikkiga bo‘linadi: biri miqdoriy tahlilga qoladi, ikkinchisi suv hammomida "
     "quritilib atsetat ioniga sifat tahlili uchun ishlatiladi." + TAIL_QUANT,
     "27-bet, 31–32-betlar", "pp. 27, 31–32", ["sulfat kislota", "natriy ishqori"], None),
    ("ACETIC-ACID-ANALYTICAL_METHOD-01", "acetic-acid", "analytical_method", "titration", "supporting",
     "Miqdoriy aniqlash: sirka kislotaning o‘zi neytrallash (titrlash) usuli bilan aniqlanadi. Kislotaning "
     "havodagi miqdori yodometrik usulda aniqlanadi: KI va KIO3 sirka kislota bilan ekvivalent miqdorda yod "
     "ajratadi, ajralgan yod kraxmal ishtirokida natriy tiosulfatning aniq konsentratsiyali eritmasi bilan "
     "titrlanadi. Kitobning bu bandida aniqlash chegarasi (LOD/LOQ) va validatsiya ko‘rsatkichlari keltirilmagan."
     + TAIL_QUANT,
     "32-bet", "p. 32", ["KI", "KIO3", "natriy tiosulfat"], None),
    # -------------------------------------------------------------------- ammiak
    ("AMMONIA-EXPRESS_TEST-01", "ammonia", "express_test", "express_test", "presumptive",
     "Dastlabki sinama: ob’ektning suvli ajratmasi (yoki dializat) ammoniy ionini saqlab, fenolftalein bo‘yicha "
     "aniq ishqoriy muhit ko‘rsatsa, bu ammiak bilan zaharlanishga shubha qilish uchun asos. Ikki indikator qog‘ozi "
     "— namlangan qizil lakmus va mis sulfat shimdirilgan filtr qog‘ozi — kolba tiqini tagiga osib qo‘yiladi "
     "(qizdirish rang o‘zgarishini tezlashtiradi): ikkalasining ko‘karishi ammiakni bildiradi. Murda chirishi ham "
     "doim ammiak va vodorod sulfid hosil qiladi, shuning uchun avval vodorod sulfidga tekshiriladi "
     "(qo‘rg‘oshin atsetat shimdirilgan qog‘oz qorayadi); vodorod sulfid topilsa, ammiakka tekshirilmaydi. Agar "
     "lakmus o‘zgarmay, mis va qo‘rg‘oshin qog‘ozlari qorayib qolsa, bu chirishdan hosil bo‘lgan sulfidni "
     "bildiradi. Biomaterialda ammiakning topilishi har doim shu preparat bilan zaharlanganini isbotlamaydi."
     + TAIL_SCREEN,
     "147-bet, 262–263-betlar", "pp. 147, 262–263", ["qizil lakmus qog‘ozi", "mis sulfat", "fenolftalein"], None),
    ("AMMONIA-CHEMICAL_TEST-01", "ammonia", "chemical_test", "chemical", "presumptive",
     "Nessler reaktivi bilan: ammiak saqlagan dializat yoki biologik materialdan ajratilgan ishqoriy suvli "
     "eritmaga Nessler reaktivi qo‘shilsa, diyoddimerkurammoniy yodid cho‘kmasi hosil bo‘ladi (manba bu o‘rinda "
     "cho‘kma rangini ko‘rsatmaydi). Natriy yoki kaliy ishqori bo‘lsa ham ammiakni aniqlash mumkin, chunki NH4Cl "
     "va NaOH reaksiyasida ammiak ajraladi." + TAIL_PRESUMPTIVE,
     "147-bet, 263-bet", "pp. 147, 263", ["Nessler reaktivi"], ("screened_by", "scr-colour-tests")),
    # ------------------------------------------- dastlabki (taxminiy) sinamalar, 20 va 170-bet
    ("CHLORPROMAZINE-EXPRESS_TEST-01", "chlorpromazine", "express_test", "express_test", "presumptive",
     "Peshobda aminazinni (xlorpromazin) dastlabki aniqlash: 1 ml peshobga 1 ml reaktiv (80 ml 10% H2SO4 va 20 ml "
     "5% FeCl3 aralashmasi) qo‘shilsa, eritma qizil-pushti rangga bo‘yaladi; yoki 1 ml FPN reaktivi (5 ml 5% FeCl3, "
     "45 ml 20% HClO4 va 50 ml 50% HNO3 aralashmasi) qo‘shilsa, qizil rang hosil bo‘ladi. Manba boshqa joyda "
     "fenotiazin hosilalari uchun peshobga temir xloridning sulfat kislotali eritmasi qo‘shilsa och-qizil rang "
     "hosil bo‘lishini ham aytadi." + TAIL_SCREEN,
     "20-bet, 170-bet", "pp. 20, 170", ["temir(III) xlorid", "sulfat kislota", "FPN reaktivi"], None),
    ("PHENOBARBITAL-EXPRESS_TEST-01", "phenobarbital", "express_test", "express_test", "presumptive",
     BARB + TAIL_SCREEN, "20-bet", "p. 20", ["kobalt atsetati"], None),
    ("PENTOBARBITAL-EXPRESS_TEST-01", "pentobarbital", "express_test", "express_test", "presumptive",
     BARB + TAIL_SCREEN, "20-bet", "p. 20", ["kobalt atsetati"], None),
    ("SECOBARBITAL-EXPRESS_TEST-01", "secobarbital", "express_test", "express_test", "presumptive",
     BARB + TAIL_SCREEN, "20-bet", "p. 20", ["kobalt atsetati"], None),
    ("BUTALBITAL-EXPRESS_TEST-01", "butalbital", "express_test", "express_test", "presumptive",
     BARB + TAIL_SCREEN, "20-bet", "p. 20", ["kobalt atsetati"], None),
    ("HYDROGEN-CYANIDE-EXPRESS_TEST-01", "hydrogen-cyanide", "express_test", "express_test", "presumptive",
     "Ob’ektda sianid kislotasini dastlabki aniqlash: ob’ektning kichik bo‘lagi chinni tavoqchaga solinib, "
     "oksalat kislota qo‘shiladi; ustiga ostki tomonida ishqor tomchisi bor buyum oynasi yopilib, bir muddat "
     "qoldiriladi. So‘ng oyna olinib, tomchiga FeCl3 va FeCl2 aralashmasidan bir tomchi tomiziladi va xlorid "
     "kislota qo‘shiladi: sianid kislotasi bo‘lsa, ko‘k rang hosil bo‘ladi." + TAIL_SCREEN,
     "170-bet", "p. 170", ["oksalat kislota", "temir(III) xlorid", "temir(II) xlorid"], None),
    ("ARSENIC-TRIOXIDE-EXPRESS_TEST-01", "arsenic-trioxide", "express_test", "express_test", "presumptive",
     "Ob’ektdagi chinnisimon oq bo‘lakchalar (oq mishyak, arsenit angidridi) uchun dastlabki sinama: bo‘lakcha "
     "pinset bilan ajratilib ingichka shisha probirkaga solinadi, ustiga kichik ko‘mir bo‘lagi qo‘shib kuchsiz "
     "alangada qizdiriladi (probirkaning yuqori qismi oldindan namlangan qog‘oz yoki doka bilan o‘ralgan). "
     "Namlangan qism ochilganda devorda qoramtir-kul rangli dog‘ bo‘lsa, oq mishyak borligidan dalolat beradi; "
     "dog‘ sovitilgan joyda qizdirilsa, oq dog‘ hosil bo‘ladi." + TAIL_SCREEN,
     "170-bet", "p. 170", ["ko‘mir"], None),
    # ------------------------------------------------------------ sertralin (TDSIS, 141 va 257–258-b.)
    ("SERTRALINE-ANALYTICAL_METHOD-01", "sertraline", "analytical_method", "instrumental", "instrumental",
     "Termodesorbsion sirt-ionlashuv spektroskopiyasi (TDSIS) bilan sertralinni tahlil qilish: O‘zbekiston Fanlar "
     "akademiyasi Elektronika instituti xodimlari taklif etgan PII-N-S «Iskovich-1» sirt-ionlashuv indikatoridan "
     "foydalaniladi. Namuna eritmasidan 1,0 mkl indikatorning bug‘latgich lentasidagi chuqurchaga solinadi. Sharoit: "
     "emitter — iridiy kirishmali oksidlangan molibden, kuchlanishi 405 V, harorati 390–420 °C; bug‘latish xona "
     "haroratidan 505 °C gacha; havo oqimi 50 l/soat; tahlil davomiyligi 3 daqiqa. Sertralinning 50, 100 va 200 mkg/ml "
     "ishchi standart eritmalarining termodesorbsion spektri olinadi: sertralinga xos chiziqli cho‘qqilar ~131±15 °C va "
     "~190±15 °C da paydo bo‘ladi. Aynanlik effektiv desorbsiya haroratlari bo‘yicha, olingan spektrni kompyuter "
     "ma‘lumotlar bankidagi etalon spektr bilan solishtirib aniqlanadi. Kitobning bu bandida aniqlash chegarasi "
     "(LOD/LOQ) va validatsiya ko‘rsatkichlari keltirilmagan." + TAIL_QUANT,
     "141-bet, 257–258-betlar", "pp. 141, 257–258", [], None),
]
