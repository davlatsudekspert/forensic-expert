"""Records drawn from the Uzbek practice guide ABY (2025) — Uzbek ONLY (owner's rule, 2026-10-10).

Rules (owner):
  * The guide is cited openly as a source, with the exact place («ABY, G bo‘limi, № ABY.G.16.2025»).
  * NOTHING is copied from the guide: every statement below is our own wording of its content.
    There is no `value.excerpt`; the text lives in `value.statement` with ONLY the `uz` key.
  * The guide's file is not in the repository, in assets or in Supabase — only knowledge taken from
    it and a reference to it.
  * Every record carries `value.locale_only = "uz"`: the app shows it only when the interface
    language is Uzbek. Russian and English never show it (no placeholder, no translation).
  * Free content (tier_access = free) — not behind the paywall.

The guide is a forensic-medicine guide. Its sections (letter in the number ABY.<letter>.<n>.2025):
  A corpse examination · B living persons · C repeat / commission / complex examinations ·
  D forensic biology · E forensic histology · F medical criminalistics · G forensic chemistry.
Only what the guide actually covers is attributed to it. Items below were read in the guide's text;
the rest of its 175+ practices is listed in docs/ABY_COVERAGE.md as «not yet written».
"""
from __future__ import annotations

SRC_ID = "SRC-ABY-2025"

SECTION_UZ = {
    "D": "D bo‘limi (sud-biologik ekspertizalar va tekshiruvlar)",
    "E": "E bo‘limi (sud-gistologik ekspertizalar va tekshiruvlar)",
    "G": "G bo‘limi (sud-kimyo ekspertizalari va tekshiruvlari)",
}

SOURCE = {
    "source_id": SRC_ID,
    "source_type": "guideline",
    "title": "Sud-tibbiyot ekspertiza (tekshiruv)lari amaliyotlarini bajarish yo‘riqnomasi (ABY)",
    "authors": [
        "Sh.I. Ro‘ziev", "S.I. Indiaminov", "O.I. Xvan", "A.S. Umarov", "J.X. Xoshimova",
        "X.I. Primuxamedova", "A.M. Hamdamov", "K.I. Ikromov", "A.Z. Otamurodov",
    ],
    "organization": "O‘zbekiston Respublikasi Sog‘liqni saqlash vazirligi, Respublika sud-tibbiy ekspertiza ilmiy-amaliy markazi",
    "publication_year": 2025,
    "edition": "Toshkent, 2025. 439 bet.",
    "accessed_date": "2026-10-10",
    "tier": "tier3",
    "evidence_level": "C",
    "license_mode": "licenseRequired",
    "license_agreement_id": "OWNER-ABY-USE-RIGHT-2026-10-10",
    "identifier_verified": False,
    "language": "uz",
    "notes": (
        "Taqrizchilar: Q.A. Maxsumxonov (t.f.d., dotsent), I.I. Baxriev (t.f.n., dotsent), N. Burankulova (PhD). "
        "Hujjatdan foydalanish huquqini markaz o‘z ishi uchun sotib olgan (egasining bayonoti, 2026-10-10). "
        "Matn ko‘chirilmagan: faqat mazmuni o‘z so‘zlarimiz bilan berilgan; hujjat fayli repoga, assetlarga yoki Supabase’ga kiritilmagan. "
        "Ko‘rsatkichlar bet bo‘yicha emas, hujjatning o‘z raqamlash tartibi bo‘yicha: bo‘lim harfi (A–G) va amaliyot raqami "
        "(masalan, № ABY.G.16.2025), amaliyot ichida esa bandlar (masalan, 2.3-band). "
        "Faqat o‘zbek tilida ko‘rsatiladi (ruscha/inglizcha tarjima yo‘q). Ilmiy review kutilmoqda."
    ),
}

SOURCE_I18N_UZ = (
    "ABY — Sud-tibbiyot ekspertiza (tekshiruv)lari amaliyotlarini bajarish yo‘riqnomasi, "
    "Respublika sud-tibbiy ekspertiza ilmiy-amaliy markazi, Toshkent, 2025"
)

PRESUMPTIVE = " Taxminiy natija: tasdiqlash uchun boshqa usul kerak."


def loc(letter: str, num: int, detail: str = "") -> str:
    base = f"ABY, {SECTION_UZ[letter]}, № ABY.{letter}.{num}.2025 amaliyoti"
    return base + (f", {detail}" if detail else "")


# --------------------------------------------------------------------------------- topics
# (topic_id, area, uz name)
TOPICS = [
    ("aby-tox-opiates", "toxicology", "Opiatlar (morfin, kodein): biologik suyuqliklarda sud-kimyoviy aniqlash"),
    ("aby-tox-barbiturates", "toxicology", "Barbituratlar: biologik suyuqliklarda sud-kimyoviy aniqlash"),
    ("aby-tox-benzodiazepines", "toxicology", "1,4-benzodiazepinlar: biologik suyuqliklarda sud-kimyoviy aniqlash"),
    ("aby-tox-cannabinoids", "toxicology", "Kannabinoidlar: biologik suyuqliklarda TLC bilan aniqlash"),
    ("aby-tox-diphenhydramine", "toxicology", "Difengidramin (dimedrol): ajratib olish va TLC bilan aniqlash"),
    ("aby-tox-hydrogen-sulfide", "toxicology", "Vodorod sulfid: biologik ob’ektda sifat tahlili"),
    ("aby-tox-urine-express", "toxicology", "Siydikda ekspress-test bilan dastlabki tekshiruv"),
    ("aby-bio-blood-presence", "laboratory", "Qon dog‘ini aniqlash (sud-biologiya)"),
    ("aby-bio-species", "laboratory", "Dog‘ning tur mansubligi: pretsipitatsiya reaksiyasi"),
    ("aby-bio-abo", "laboratory", "ABO guruhini kichik qon dog‘larida aniqlash"),
    ("aby-bio-semen", "laboratory", "Sperma dog‘i: p30 (PSA) ekspress-testi"),
    ("aby-bio-saliva", "laboratory", "So‘lak dog‘i: amilaza bo‘yicha aniqlash"),
    ("aby-bio-hair", "laboratory", "Sochni morfologik va taqqosiy tekshirish"),
    ("aby-bio-feces", "laboratory", "Najas dog‘ini tekshirish"),
    ("aby-evidence-intake", "laboratory", "Ashyoviy dalillarni qabul qilish va berish"),
    ("aby-evidence-storage", "laboratory", "Ashyoviy dalillar va hujjatlarni saqlash muddatlari"),
    ("aby-his-fixation", "histology", "Ichki a’zolarni formalinda fiksatsiyalash"),
    ("aby-his-staining", "histology", "Gematoksilin–eozin bilan bo‘yash (Mayer)"),
    ("aby-his-diatoms", "histology", "Diatom-plankton tekshiruvi (cho‘kishni aniqlash)"),
]

# --------------------------------------------------------------------------------- claims
# (claim_id, entity_type, entity_id, field, evidence_class, locator, uz text)
CLAIMS = [
    # ------------------------------------------------------------------ ethanol / methanol / CO (free substances)
    ("C-ABY-ETHANOL-01", "substance", "ethanol", "analytical_method", "instrumental",
     loc("G", 16, "2.2–2.4-bandlar"),
     "Biologik suyuqliklarda etil spirtini aniqlashning mahalliy usuli: oddiy gaz xromatografi (alanga-ionlashtiruvchi detektor, "
     "namuna bug‘ holida qo‘lda shpris bilan kiritiladi), mass-spektrometr talab qilinmaydi. Spirtlar to‘g‘ridan-to‘g‘ri emas, "
     "alkil nitritlar ko‘rinishida aniqlanadi: penitsillin flakonida uch xlorli sirka kislotasining (UXSK) 50 % li eritmasidan 0,5 ml "
     "bo‘ladi; unga tekshiriluvchi suyuqlik (miqdoriy tahlilda — ichki standart bilan aralashtirilgan suyuqlikdan 1 ml) qo‘shiladi, flakon "
     "zich yopilib, 0,3 ml natriy nitritning 30 % li eritmasi shpris bilan yuboriladi, 1–2 daqiqa aralashtiriladi va undan 1,5 ml "
     "bug‘ fazasi xromatograf dozatoriga yuboriladi. Ichki standart — propil spirti (0,4 % li eritma; 2 ml tekshiriluvchi suyuqlik "
     "bilan 2 ml shu eritma aralashtirilib, undan 1 ml olinadi). Avval sifat tahlilida metilnitritga xos cho‘qqi belgilanadi; "
     "etilnitrit cho‘qqisi topilsa, uning chiqish vaqti standart bilan solishtirilib, miqdoriy tahlilga o‘tiladi. Chiqish vaqtlarini "
     "aniqlash uchun metil, etil, propil, butil va amil spirtlari aralashmasidan foydalaniladi. Bu usul uchun xalqaro adabiyotdan "
     "(PubMed qidiruvi) mos manba topilmadi; xalqaro tavsiya etilgan to‘g‘ridan-to‘g‘ri headspace GC-FID usuli yuqoridagi yozuvlarda."),
    ("C-ABY-ETHANOL-02", "substance", "ethanol", "qc_requirement", "instrumental",
     loc("G", 16, "2.3 va 2.4-bandlar"),
     "Kalibrlash va hisoblash (ABY bo‘yicha): 1 ‰, 3 ‰ va 6 ‰ li etanol standartlari (2 % li asosiy eritmadan suyultirib tayyorlanadi; "
     "saqlash muddati 1 hafta) har biridan 2 ml olinib, 2 ml 0,4 % li propanol bilan aralashtiriladi, so‘ng nitrit hosil qilish "
     "bosqichiga o‘tkaziladi. Grafikda ordinata — etilnitrit va propilnitrit cho‘qqi balandliklari nisbatining 100 ga ko‘paytmasi, "
     "abssissa — konsentratsiya; nuqtalar orqali to‘g‘ri chiziq o‘tkaziladi. Tekshiriluvchi namunadagi miqdor grafikdan topilib, "
     "qon uchun 0,95, siydik uchun 1,05 koeffitsientga ko‘paytiriladi va promillda (‰) beriladi. Qabul mezoni: reaktivlar va nazorat "
     "namuna spirtlarga musbat natija bermasligi kerak. Koeffitsientlarning kelib chiqishi ABYda tushuntirilmagan: manba tekshirilmoqda."),
    ("C-ABY-ETHANOL-03", "substance", "ethanol", "limitation", "framing",
     loc("G", 16, "3-bo‘lim «Tahlil. Izohlash»"),
     "ABY etil spirti bilan zaharlanish va mastlik tashxisida miqdoriy natijani promillda (‰) ifodalash muhimligini ta’kidlaydi. "
     "Murda qonida etanol baholanganda chirish jarayonida ham etil spirti hosil bo‘lishini hisobga olish kerak: ABYga ko‘ra chigan "
     "qonda sezilmas miqdordan 2,4 ‰ gacha etanol paydo bo‘lishi mumkin. Shu sababli chigan murda qonidagi natija o‘lim oldidan "
     "ichilganini o‘z-o‘zidan isbotlamaydi. Xalqaro adabiyotdagi shu mavzudagi yozuv yuqorida (o‘limdan keyingi qon uchun cheklov)."),
    ("C-ABY-METHANOL-01", "substance", "methanol", "analytical_method", "instrumental",
     loc("G", 16, "2.2 va 2.4.1-bandlar"),
     "ABYdagi etil spirti uchun gaz xromatografik usulda (alkil nitritlar orqali) sifat tahlili bosqichida avval metilnitritga xos "
     "cho‘qqi belgilanadi, ya’ni shu usul bilan metil spirtini ham aniqlash mumkin. Spirtlarning chiqish vaqti metil, etil, propil, "
     "butil va amil spirtlari aralashmasidan aniqlanadi. Metanol uchun alohida miqdoriy hisoblash ABYning bu amaliyotida berilmagan."
     + PRESUMPTIVE),
    ("C-ABY-CO-01", "substance", "carbon-monoxide", "analytical_method", "presumptive",
     loc("G", 14, "2.1-band"),
     "Qonda karboksigemoglobin (COHb) borligini sifat jihatdan aniqlash uchun ABY oltita rang sinamasini keltiradi; har biri "
     "karboksigemoglobin saqlamaydigan yangi qon bilan yonma-yon qo‘yiladi: Goppe-Zeyler sinamasi (30 % NaOH qo‘shilganda COHb li "
     "qon yorqin qizil qoladi, nazorat qon bir necha daqiqada qo‘ng‘ir tusga kiradi); formalin bilan (Liberman); kaliy "
     "geksatsianoferrat(III) bilan (Byurker); geksatsianoferrat(III) va kaliy dixromat bilan (Sidorov — COHb li qon karmin-qizil, "
     "nazorat jigarrang-yashil); geksatsianoferrat(III) va sirka kislota bilan (Vetsel); mis sulfat bilan (Zalesskiy). Chirigan qon "
     "ishqor ta’sirida gemoxromogen hosil qilib yorqin qizil rangga kirishi mumkin — bu holda Goppe-Zeyler sinamasi chalg‘itadi."
     + PRESUMPTIVE),
    ("C-ABY-CO-02", "substance", "carbon-monoxide", "analytical_method", "instrumental",
     loc("G", 14, "2.2-band va 3-bo‘lim"),
     "COHb miqdoriy aniqlash (ABY bo‘yicha): laxtasiz qon 0,1 % ammiak yoki fosfat bufer (pH 7,38) bilan suyultiriladi (A eritma); "
     "unga natriy gidrosulfit qo‘shib qaytariladi (B eritma); taqqoslash uchun xuddi shu qon uglerod (II) oksidi bilan to‘yintiriladi "
     "(V eritma). Optik zichlik 1 sm kyuvetada 535 va 560 nm da o‘lchanadi, K1 va K2 koeffitsientlari orqali COHb ning foizi "
     "hisoblanadi. COHb li qon bilan ishlash havo ta’siri juda kam bo‘lgan, yorug‘lik manbalaridan uzoq joyda olib borilishi, "
     "fotometrlash uchun eritma tiniq bo‘lishi kerak. ABYga ko‘ra o‘limga olib keluvchi COHb konsentratsiyasi o‘rtacha 60 %, lekin "
     "40–80 % va undan ortiq ham bo‘lishi mumkin; bu raqam hukm chegarasi emas. Mushakdagi karboksimioglobinni aniqlash alohida "
     "amaliyotda (№ ABY.G.15.2025) mushak ekstraktidan xuddi shunday spektrofotometrik usul bilan bajariladi; unda COHb ga nisbatan "
     "karboksimioglobin ulushi 0,52 deb keltiriladi."),
    # ------------------------------------------------------------------ toxicology topics
    ("C-ABY-TOX-OPI-01", "topic", "aby-tox-opiates", "principle", "presumptive",
     loc("G", 5, "«Jarayonni olib borish tartibi»"),
     "ABY bo‘yicha qondan opiatlar xloroform bilan ajratiladi: 20 ml qon natriy bikarbonatning to‘yingan eritmasi bilan pH 8,7 ga "
     "keltirilib, 3 marta 10 ml xloroformda ekstraksiya qilinadi, ekstrakt suvsiz natriy sulfatdan o‘tkazilib 5 ml gacha bug‘latiladi. "
     "Siydikda opiatlarning asosiy qismi konyugat (glyukuronid) holida bo‘lgani uchun avval kislotali gidroliz qilinadi: 20 ml siydik "
     "4 ml konsentrlangan xlorid kislota bilan yopiq flakonda 60 °C da 30 daqiqa isitiladi, sovitilgach pH 8,5–9,0 ga keltirilib "
     "organik erituvchi (xloroform yoki xloroform bilan n-butanol/izoamil spirti/izopropanol aralashmasi) bilan uch marta "
     "ekstraksiya qilinadi. ABYga ko‘ra gidroliz va ekstraksiya birgalikda kodeinning taxminan 90 %, morfinning 93 % ini ajratib oladi."),
    ("C-ABY-TOX-OPI-02", "topic", "aby-tox-opiates", "principle", "presumptive",
     loc("G", 5, "TLC va rang reaksiyalari bo‘limlari, 3.5-band"),
     "TLC: ekstrakt silikagel plastinkaga tomizilib, yonida morfin va kodeinning 0,01 % li spirtli standarti (guvoh) qo‘yiladi; front "
     "10 sm gacha ko‘tariladi. ABY tavsiya etgan tizimlar: etilatsetat–metanol–ammiak (17:2:1); metanol–ammiak (100:1,5); "
     "metanol–n-butanol (6:4); toluol–aseton–etanol–ammiak (45:45:7:3); dioksan–xloroform–aseton–25 % ammiak (47,5:45:5:2,5). "
     "Birinchi plastinka 10 % FeCl3, so‘ng Dragendorf reaktivi (Mune varianti) bilan, ikkinchisi Marki reaktivi bilan ochiladi. "
     "Marki reaktivida morfin binafsha, kodein ko‘k dog‘ beradi; kodein FeCl3 bilan reaksiya bermaydi — shu bilan morfindan farqlanadi. "
     "ABY aniqlashni uchala reaksiya (FeCl3, Dragendorf, Marki) musbat bo‘lgandagina to‘g‘ri bajarilgan hisoblaydi, ammo kodein FeCl3 "
     "bilan reaksiya bermasligi o‘sha matnning o‘zida aytilgani uchun bu mezon kodein uchun o‘zaro zid: manba tekshirilmoqda. Xulosada "
     "dog‘ rangi hamda Rf batafsil yozilishi talab qilinadi. Jadvaldagi Rf (morfin 0,14; kodein 0,28) qaysi tizimga tegishli ekani "
     "ko‘rsatilmagan: manba tekshirilmoqda; plastinka turiga qarab Rf o‘zgaradi, shuning uchun standart bilan bir plastinkada solishtiring."
     + PRESUMPTIVE),
    ("C-ABY-TOX-OPI-03", "topic", "aby-tox-opiates", "limitation", "framing",
     loc("G", 5, "3.3 va 3.4-bandlar"),
     "ABY ta’kidlashicha, namunada aralashmalar ko‘p bo‘lsa yoki boshqa matritsa bo‘lsa, ajratish va tahlil natijalari buzilishi "
     "mumkin; bunday holda ekstraktni oldindan tozalash (matritsaning qutbli qismlarini ushlab qoluvchi adsorbsion qatlamli "
     "plastinkalar) qo‘llanadi. Plastinkaga tomizilgan zona kattaligi natijaga sezilarli ta’sir qiladi: zonalar faqat bir xil "
     "o‘lchamda tomizilgan taqdirdagina harakatchanligi bo‘yicha solishtirilishi mumkin."),
    ("C-ABY-TOX-BAR-01", "topic", "aby-tox-barbiturates", "principle", "presumptive",
     loc("G", 6, "2.1 va 2.2-bandlar"),
     "ABY bo‘yicha 10 ml qon yoki siydik 2 n xlorid kislota bilan pH 2 ga keltirilib, uch marta 10 ml xloroformda ekstraksiya "
     "qilinadi; xloroform qatlami suvsiz natriy sulfatdan o‘tkaziladi. Aniqlash ikki yo‘l bilan olib boriladi. Mikrokristalloskopiya: "
     "predmet oynasida quritilgan qoldiqqa kons. sulfat kislota (kislotali shaklni ajratish), xlorsinkyod, temir yodid kompleksi yoki "
     "mis-piridin kompleksi qo‘shilib, hosil bo‘lgan kristall shakllari standart barbituratlarniki bilan solishtiriladi. TLC: silikagel "
     "plastinka, \"A\" tizimi — xloroform : n-butanol : 25 % ammiak = 70 : 40 : 5; dog‘lar 0,02 % difenilkarbazonning xloroformdagi "
     "eritmasi, so‘ng simob sulfat eritmasi bilan ochiladi, havo-binafsha yoki qizg‘ish binafsha dog‘ barbiturat borligini bildiradi. "
     "ABYdagi Rf: barbital 0,70–0,75; fenobarbital 0,49–0,55; etaminal-natriy 0,94–0,96; barbamil 0,85–0,92; butobarbital 0,78–0,85. "
     "Standart bilan bir plastinkada solishtirish talab qilinadi; reaktivlar va nazorat namuna barbituratlarga musbat natija "
     "bermasligi kerak." + PRESUMPTIVE),
    ("C-ABY-TOX-BZD-01", "topic", "aby-tox-benzodiazepines", "principle", "presumptive",
     loc("G", 7, "«Jarayonni olib borish tartibi», 3.3-band"),
     "1,4-benzodiazepinlar ABY bo‘yicha gidroliz mahsulotlari — benzofenonlar — orqali aniqlanadi: 10 ml siydik yoki qon 10 ml "
     "konsentrlangan xlorid kislota bilan qaytar sovutgich ostida qaynoq suv hammomida 1 soat qizdiriladi, neytrallanib pH 8–10 ga "
     "keltiriladi va uch marta 20 ml xloroformda ekstraksiya qilinadi. Hosil bo‘ladigan benzofenonlar: xlordiazepoksid va oksazepam — "
     "2-amino-5-xlorbenzofenon; diazepam — 2-metilamino-5-xlorbenzofenon; nitrazepam — 2-amino-5-nitrobenzofenon va 2,5-diaminobenzofenon; "
     "fenazepam — brom saqlovchi benzofenon (ABYda nomi noaniq yozilgan: manba tekshirilmoqda). TLC silikagelda benzol bug‘i bilan to‘yingan kamerada olib "
     "boriladi; sariq dog‘lar benzofenon borligini bildiradi (dog‘dagi miqdor 5 µg/ml dan kam bo‘lsa sariq rang chiqmaydi), "
     "254 nm da flyuoressensiya kuzatiladi, so‘ng plastinka ketma-ket 2 n HCl, 0,1 % natriy nitrit va 5 daqiqadan keyin 2 % "
     "β-naftolning ishqoriy eritmasi (Bratton–Marshall reaksiyasi) bilan purkaladi. ABYdagi Rf jadvali matnda noaniq (qaysi modda "
     "qaysi Rf ga mosligi buzilgan): qiymatlar keltirilmadi, manba tekshirilmoqda." + PRESUMPTIVE),
    ("C-ABY-TOX-CAN-01", "topic", "aby-tox-cannabinoids", "principle", "presumptive",
     loc("G", 12, "2.1–2.5-bandlar"),
     "ABY bo‘yicha kannabinoidlar so‘lakdan (to‘yingan NaCl bilan aralashtirib, etilasetat bilan 2 marta 10 ml ekstraksiya), qon "
     "plazmasidan (5 ml, petroley efiri va pentanol aralashmasi bilan 4 marta), siydikdan (2 ml siydikka 1 ml metanol va 150 µl 50 % "
     "NaOH qo‘shib 60 °C da 10 daqiqa isitish, pH 2–3 gacha HCl, ekstraksiya) va qo‘l/lab surtmasidan ajratib olinadi. TLC: "
     "quruq qoldiq xloroformda eritilib faollashtirilgan plastinkaga tomiziladi, yonida tetragidrokannabinol (THC) standarti "
     "(1 mg/ml metanolda); tizimlar sifatida petroley efiri–dietil efiri (4:1), toluol yoki benzol, xloroform–izopropil spirti (9:1), "
     "n-geksan–etilasetat (7:1) keltirilgan. Plastinka Mustahkam «B» zangorisi (Fast Blue B) ning 10 % natriy karbonatdagi eritmasi bilan "
     "purkalanadi; Rf ≈ 0,8 dagi qizil-binafsha dog‘ THC borligini ko‘rsatadi. Kannabinol uchun Rf ≈ 0,76 keltirilgan. Biologik "
     "ob’ektlarda THC ning o‘zi yoki uning metabolitlari (asosan THC-karbon kislota) bo‘lishi mumkinligi va Rf plastinka turiga qarab "
     "qisman o‘zgarishi hisobga olinishi kerak." + PRESUMPTIVE),
    ("C-ABY-TOX-DPH-01", "topic", "aby-tox-diphenhydramine", "principle", "presumptive",
     loc("G", 20, "2–3.2-bandlar"),
     "Difengidraminni qon yoki siydikdan ajratish (ABY): 20 ml namuna 25 % ammiak bilan pH 10 ga keltirilib, 20 ml dan 2–3 marta "
     "xloroformda ekstraksiya qilinadi. Ichki a’zolardan: 100 g mayda kesilgan to‘qima 200 ml suv va oksalat kislotaning to‘yingan "
     "eritmasi bilan pH 2–3 ga keltirilib 2 soat qoldiriladi, suyuqlik ajratiladi, ammiak bilan pH 10 ga keltirilib xloroform bilan "
     "ekstraksiya qilinadi. Rang reaksiyalari (quruq qoldiqda): kons. H2SO4 — sariq, tezda qizil-g‘isht rangga o‘tadi va suv "
     "qo‘shilganda yo‘qoladi; Marki reaktivi — limon-sariq; Liberman — zarg‘aldoq; Mandelin — sariq; sulfat va nitrat kislota "
     "aralashmasi — qizil. TLC (silikagel): xloroform–aseton–25 % ammiak (12:24:1) da Rf 0,58–0,60; etanol–aseton–25 % ammiak (20:2:1) "
     "da Rf 0,66; dog‘lar Dragendorf (Mune varianti) bilan zarg‘aldoq, kons. H2SO4 bilan sariq. ABY farmakokinetikadan metabolitlar "
     "sifatida benzgidrol va dimetilaminoetanolni, yarim chiqarilish davri 4–10 soat ekanini keltiradi." + PRESUMPTIVE),
    ("C-ABY-TOX-H2S-01", "topic", "aby-tox-hydrogen-sulfide", "principle", "presumptive",
     loc("G", 18, "2-bo‘lim va 4-bo‘lim «Tahlil. Izohlash»"),
     "Vodorod sulfid ABY bo‘yicha biologik ob’ektdan ajratilmasdan, uning uchuvchanligidan foydalanib aniqlanadi: ashyoviy dalil "
     "(ichki a’zolar) zich yopiladigan idishda keltiriladi, idish qopqog‘i ehtiyotkorlik bilan ochilib, ichiga qizil lakmus qog‘ozi "
     "va qo‘rg‘oshin asetat shimdirilgan qog‘oz qo‘yiladi. Qo‘rg‘oshin asetat qog‘ozi qorayib, lakmus o‘zgarmasa — sulfid bor; ikkala "
     "qog‘oz ham o‘zgarsa (lakmus ko‘karadi, qo‘rg‘oshin qorayadi) — ammiak va vodorod sulfid ob’ektning chirishidan hosil bo‘lgan. "
     "Boshqa sinamada kuchsiz ishqoriy natriy nitroprussid shimdirilgan qog‘ozning binafsha rangga bo‘yalishi vodorod sulfid "
     "borligini bildiradi. Ikki muhim cheklov: ob’ekt chirigan bo‘lsa vodorod sulfid bilan zaharlanish bo‘lganini aniqlab bo‘lmaydi; "
     "zaharlanishga gumon bo‘lsa kimyoviy aniqlash 24 soat ichida zudlik bilan o‘tkazilishi kerak." + PRESUMPTIVE),
    ("C-ABY-TOX-URX-01", "topic", "aby-tox-urine-express", "principle", "presumptive",
     loc("G", 24, "2-bo‘lim va «Hujjatlashtirish»"),
     "ABY bo‘yicha siydikda dastlabki (skrining) sud-kimyoviy tekshiruv xromatografik-immunokimyoviy ekspress-test kassetalari bilan "
     "o‘tkaziladi. Siydik toza va quruq idishga olinadi; xira bo‘lsa sentrifugalanib filtrlanadi; zarur bo‘lsa 48 soatgacha 2–8 °C da, "
     "uzoqroq bo‘lsa −20 °C da saqlanadi. Namuna va test xona haroratiga (15–30 °C) keltiriladi; kassetaning namuna oynasiga 3 tomchi "
     "(taxminan 120 µl) siydik tomiziladi va 5 daqiqadan keyin natija o‘qiladi (10 daqiqadan keyingi holat hisobga olinmaydi). Test "
     "turiga qarab natija o‘qilishi farq qiladi, shuning uchun har gal o‘ram ichidagi ko‘rsatma o‘qiladi; nazorat chizig‘i chiqmasa natija "
     "yaroqsiz. Laboratoriyada testlarni qo‘llashni boshlashdan oldin bir necha marta sinab ko‘rish kerak." + PRESUMPTIVE),
    ("C-ABY-TOX-URX-02", "topic", "aby-tox-urine-express", "limitation", "framing",
     loc("G", 24, "«Hujjatlashtirish»"),
     "ABY ta’kidlashicha, ekspress-test faqat dastlabki, sifat natijasini beradi; miqdoriy aniqlash va tasdiqlash uchun qo‘shimcha "
     "kimyoviy usullar kerak, buning uchun gaz xromatografiya/mass-spektrometriya maqsadga muvofiq. Musbat natija modda yoki uning "
     "metabolitlari borligini bildiradi, ammo zaharlanish miqdori va organizmga kirish yo‘li haqida ma’lumot bermaydi. Manfiy natija "
     "moddaning yo‘qligini har doim tasdiqlamaydi: miqdori testning sezgirligidan past bo‘lishi mumkin. Siydikdagi begona moddalar yoki "
     "texnik xato noto‘g‘ri natijaga olib kelishi mumkin. Test o‘rami muhri tekshiruvgacha buzilmasligi, saqlash muddati o‘tgan "
     "test ishlatilmasligi, testlarni muzlatmaslik (2–4 °C yoki xona harorati) kerak."),
    # ------------------------------------------------------------------ forensic biology
    ("C-ABY-BIO-BLD-01", "topic", "aby-bio-blood-presence", "principle", "presumptive",
     loc("D", 1, "5–7-bandlar") ,
     "Qon borligini qog‘ozda xromatografiya bilan aniqlash (ABY): dog‘dan, predmet tashuvchidan va ma’lum qon namunasidan olingan "
     "bo‘lakchalar xromatografik qog‘ozning kesiklariga o‘rnatiladi; erituvchi — butanol va 25 % ammiakning teng aralashmasi "
     "(yuqori qavati). Erituvchi qog‘oz chetiga yetgach quritilib, avval benzidinning xloroformdagi 0,1 % eritmasi, so‘ng 3 % vodorod "
     "peroksid bilan ochiladi. Qon pigmenti sohasi darhol ko‘k rangga kirsa va oqar suv ostida yuvilgach turg‘un qizg‘ish-jigarrang "
     "bo‘lib qolsa, dog‘ qon deb hisoblanadi. Reaksiya to‘g‘ri bajarilgan hisoblanadi, agar ma’lum qon namunasi shu tarzda bo‘yalsa "
     "(Rf 0,11–0,15) va predmet tashuvchi bo‘yalmasa." + PRESUMPTIVE),
    ("C-ABY-BIO-BLD-02", "topic", "aby-bio-blood-presence", "principle", "presumptive",
     loc("D", 2, "5-band"),
     "Silufol plastinkada mikroxromatografiya (ABY): universal erituvchi — butanol : sirka kislota : suv = 4 : 1 : 2; ochuvchi — "
     "96 % spirtda benzidin (muzli sirka kislota bilan) eritmasi, so‘ng 3 % vodorod peroksid. Dog‘, predmet tashuvchi va ma’lum qon "
     "namunasi plastinkaning boshlanish chizig‘iga o‘rnatilib, Petri idishida xromatografiya qilinadi, 100 °C li termostatda 15 daqiqa "
     "isitilib, ketma-ket ochuvchi va peroksid eritmalarida ishlanadi. Qon bo‘lsa boshlanish chizig‘idan marra chizig‘igacha ko‘k "
     "bo‘yalish hosil bo‘ladi; ma’lum qon namunasi intensiv ko‘k bo‘yalmasa reaksiya noto‘g‘ri bajarilgan." + PRESUMPTIVE),
    ("C-ABY-BIO-BLD-03", "topic", "aby-bio-blood-presence", "principle", "presumptive",
     loc("D", 14, "2, 5 va 6-bandlar"),
     "Immunoxromatografik test (ABAcard Hematrace) odam qonini aniqlash va tur mansubligini taxmin qilish uchun ishlatiladi. ABY "
     "ta’kidlashicha, u odam qoni uchun spesifik bo‘lishi bilan birga, sassiqkuzan va primatlar (yuqori sinf sut emizuvchilar) qoni "
     "bilan ham musbat natija bergan. Bo‘lakcha ekstraksion buferga botiriladi: yangi dog‘lar 1–5 daqiqa, xona haroratida 5 yilgacha "
     "saqlangan eski dog‘lar kamida 30 daqiqa. 4–5 tomchi (150 µl) tortilma testning namuna oynasiga solinadi va 10 daqiqa "
     "kuzatiladi; musbat natija odatda 2 daqiqa ichida ko‘rinadi. Test zonasida yorqin chiziq — musbat, kuchsiz chiziq — kuchsiz musbat, "
     "noaniq chiziq — shubhali, chiziq yo‘q — manfiy; nazorat zonasidagi chiziq bo‘lmasa natija yaroqsiz va test takrorlanadi."
     + PRESUMPTIVE),
    ("C-ABY-BIO-SPC-01", "topic", "aby-bio-species", "principle", "presumptive",
     loc("D", 5, "5 va 6-bandlar"),
     "Chistovich–Ulengut usulida tur mansubligi suyuq muhitda halqali pretsipitatsiya bilan aniqlanadi (ABY): dog‘, uning predmet "
     "tashuvchisi va ma’lum antigenlardan fiziologik eritmada +4–6 °C da tortilma tayyorlanadi (ekstraksiya dog‘ ning yoshi va "
     "to‘yinganligiga qarab 20–72 soat). Tortilmada oqsil borligi nitrat kislota bilan Geller sinamasida tekshiriladi (loyqa halqa); "
     "sinama manfiy bo‘lsa ham pretsipitatsiya reaksiyasi o‘tkazilishi kerak, chunki zardob nitrat kislota sinamasidan ancha suyultirilgan "
     "oqsilni ham sezadi (nitrat kislota sinamasi taxminan 1:1000 gacha, zardob esa 1:10 000 gacha suyultirilgan oqsilni sezadi). Tortilmaning tagiga odam, shoxli mol va qush oqsiliga qarshi pretsipitatsiyalovchi "
     "zardoblardan kam miqdorda (zardob : tortilma taxminan 1 : 10) qatlamlanadi va 1 soat kuzatiladi. Halqa faqat bitta zardob bilan "
     "hosil bo‘lib, boshqalari bilan hosil bo‘lmasa, tur mansubligi aniqlangan hisoblanadi; hech qaysi zardob bilan bo‘lmasa "
     "laboratoriyadagi barcha zardoblar qo‘llanadi. Reaksiya to‘g‘ri bajarilgan hisoblanadi, agar ma’lum antigenlar o‘z zardobi bilan "
     "halqa bersa, predmet tashuvchi va fiziologik eritma bermasa."),
    ("C-ABY-BIO-ABO-01", "topic", "aby-bio-abo", "principle", "presumptive",
     loc("D", 9, "5 va 6-bandlar"),
     "Kichik qon dog‘larida ABO guruhini absorbsiya-elyusiya usulida aniqlash (ABY): dog‘, predmet tashuvchi va ma’lum guruhli qon "
     "namunalaridan 0,2 × 0,2 sm li bo‘lakchalar spirtda fiksatsiyalanadi (etil spirti 1 soat; metil yoki butil spirti 20 daqiqa); "
     "titri 1:128 bo‘lgan a-A va a-B izozardoblari bilan +4–6 °C da 20–24 soat absorbsiya qilinadi; sovuq fiziologik eritmada 2 daqiqadan "
     "ketma-ket yuviladi; fiziologik eritmada 56 °C da 30 daqiqa elyusiya qilinadi; elyuatga mos 1 % standart eritrotsitlar qo‘shilib, "
     "mikroskopda agglyutinatsiya qaraladi. β qatorida agglyutinatsiya — B antigeni, α qatorida — A antigeni. Predmet tashuvchi "
     "tortilmasida agglyutinatsiya bo‘lsa, uning ta’sirini bartaraf etish choralari ko‘riladi; tortilmalarda agglyutinatsiya bo‘lmasa "
     "ketma-ket absorbsiya (bir necha 2 soatlik bosqich, so‘ng 20–24 soat) o‘tkaziladi. Bu choralardan keyin ham manfiy bo‘lsa, "
     "qonning guruhiy mansubligi haqida gapirib bo‘lmaydi. Reaksiya to‘g‘ri bajarilgan hisoblanadi, agar ma’lum guruhli namunalar "
     "mos eritrotsitlar bilan agglyutinatsiya bersa va predmet tashuvchi bermasa."),
    ("C-ABY-BIO-SEM-01", "topic", "aby-bio-semen", "principle", "presumptive",
     loc("D", 25, "2, 5 va 6-bandlar"),
     "ABAcard p30 testi sperma borligini prostata-spesifik antigen (PSA, p30 oqsili) bo‘yicha immunoxromatografik usulda aniqlaydi. "
     "ABY ta’kidlashicha, spermatozoidlari kam yoki yo‘q bo‘lgan erkaklarda (alohida kasalliklar, vazektomiya) ham p30 oqsili ishlab "
     "chiqariladi, shuning uchun sperma borligini tasdiqlashda test sud-tibbiy ahamiyatga ega. Dog‘ bo‘lakchasi 750 µl distillangan suvda "
     "15 daqiqadan 2 soatgacha ekstraksiya qilinadi; 8 tomchi (200 µl) tortilma testning namuna oynasiga solinadi va 10 daqiqa "
     "kuzatiladi, musbat natija odatda 2 daqiqa ichida ko‘rinadi. Test zonasida yorqin chiziq — musbat, kuchsiz — kuchsiz musbat, noaniq "
     "— shubhali, chiziq yo‘q — manfiy; nazorat zonasida chiziq bo‘lmasa natija yaroqsiz va yangi test bilan takrorlanadi." + PRESUMPTIVE),
    ("C-ABY-BIO-SAL-01", "topic", "aby-bio-saliva", "principle", "presumptive",
     loc("D", 29, "5 va 6-bandlar"),
     "So‘lakni amilaza fermenti bo‘yicha aniqlash (ABY): dog‘, predmet tashuvchi va ma’lum so‘lak namunasidan 100 mg dan oshmaydigan "
     "bo‘lakchalar toluol ostida xona haroratida 4 soat qoldiriladi, so‘ng har biriga 5 ml kartoshka kraxmalining NaCl dagi eritmasi "
     "qo‘shilib, +37 °C da 20–24 soat saqlanadi. Suyuqlikning yarmiga 1:3 suyultirilgan Lyugol eritmasi tomiziladi. Loyqa eritma tiniq "
     "bo‘lib, Lyugol bilan bo‘yalmasa (amilaza kraxmalni parchalagan) — so‘lak aniqlangan hisoblanadi; so‘lak bo‘lmasa yoki juda kam "
     "bo‘lsa eritma loyqaligicha qoladi va Lyugol bilan ko‘karadi. Suyuqlikdagi binafsha rang so‘lak bor yoki yo‘qligi haqida xulosa "
     "uchun asos bo‘lmaydi. Reaksiya to‘g‘ri bajarilgan hisoblanadi, agar predmet tashuvchi manfiy, ma’lum so‘lak namunasi musbat bersa."
     + PRESUMPTIVE),
    ("C-ABY-BIO-SAL-02", "topic", "aby-bio-saliva", "principle", "presumptive",
     loc("D", 30, "2, 5 va 6-bandlar"),
     "Odam so‘lagini alfa-amilaza bo‘yicha aniqlovchi immunoxromatografik ekspress-test (ABY): maydonda va laboratoriyada ishlatish "
     "uchun, qo‘shimcha jihoz talab qilinmaydi, natija taxminan 10 daqiqada olinadi. Dog‘ bo‘lakchasi 750 µl distillangan suvda "
     "10 daqiqadan 2 soatgacha ekstraksiya qilinadi; 3 tomchi (120 µl) tortilma testga solinadi va 15 daqiqa kuzatiladi. Ikkinchi "
     "katta oynacha zonasining och-jigarrang yoki qora tusga kirishi — musbat, och-sariq tus — manfiy; rang o‘zgarmasa test yaroqsiz "
     "va amal takrorlanadi." + PRESUMPTIVE),
    ("C-ABY-BIO-HAR-01", "topic", "aby-bio-hair", "principle", "framing",
     loc("D", 42, "5 va 6-bandlar"),
     "Sochga o‘xshash ob’ektlarni morfologik tekshirish (ABY): har bir ob’ekt o‘lchanib alohida o‘raladi; ksilol ostida mikroskopda "
     "ko‘riladi; to‘q rangli ob’ektning tuzilishi ko‘rinmasa, silikat elim yoki rangsiz lakda bosma olinadi yoki nitrat kislota bilan "
     "rangsizlantiriladi. Kutikula, pigmentli po‘stloq va o‘zak qavatlari bo‘lsa ob’ekt soch hisoblanadi. Odam va hayvon sochi "
     "farqlari ABYda jadval ko‘rinishida berilgan: odam sochida o‘zak odatda ingichka (soch qalinligining 1/3 qismidan oshmaydi), "
     "po‘stloq modda ko‘p qismni egallaydi, pigment bir tekis yoki kutikulaga yaqin, kutikula chekkasi nisbatan tekis; hayvon sochida "
     "o‘zak keng (9/10 gacha), pigment markazda va yirik donali, kutikula tishchalari yaxshi ko‘rinadi. Natijalar rangi, shakli, uzunligi, "
     "qalinligi, o‘zak, po‘stloq va kutikula belgilari bilan ish jurnalidagi jadvalga yoziladi."),
    ("C-ABY-BIO-HAR-02", "topic", "aby-bio-hair", "application", "framing",
     loc("D", 43, "5 va 6-bandlar"),
     "Sochlarni taqqoslash (ABY): ish bo‘yicha o‘tuvchi shaxs boshining 5 ta sohasidan 5 tadan soch alohida o‘ralib, barcha sochlar "
     "makro- va mikroskopik belgilari bo‘yicha jadvalga yoziladi; voqea joyidagi sochlar tola, hayvon sochi, pigmentsiz va pigmentli "
     "odam sochi, regional soch guruhlariga ajratiladi; pigmentli odam sochlari o‘zaro va shaxslar namunalari bilan taqqoslanadi. "
     "Barcha asosiy morfologik belgilar (rangi, shakli, uzunligi, qalinligi, po‘stloq moddasi, pigment rangi, donadorligi, jamlanishi) "
     "bo‘yicha o‘xshash bo‘lsa — voqea joyi sochi shaxs sochiga o‘xshash, farq qilsa — farq qiladi deb hisoblanadi. Regional soch "
     "topilsa, shaxslarning ham regional sochlari bilan taqqoslanadi."),
    ("C-ABY-BIO-FEC-01", "topic", "aby-bio-feces", "principle", "framing",
     loc("D", 48, "5 va 6-bandlar"),
     "Najasga o‘xshash dog‘ ABY bo‘yicha mikroskopik tekshiriladi: dog‘dan bo‘lakcha predmet oynasiga o‘tkazilib, bir tomchi "
     "distillangan suv bilan qoplama oyna ostida ko‘riladi. Preparatda hazm bo‘lmagan ovqat qoldiqlari, mushak tolalari, o‘simlik "
     "kletchatkasi, yog‘, o‘t pigmentlari, ichak epiteliysi hujayralari, shuningdek gijja tuxumlari yoki sodda hayvonlar sistalari "
     "topilsa, najas borligi aniqlangan hisoblanadi. Natijalar nomutanosib bo‘lgani uchun najasning tur va guruhiy mansubligini "
     "aniqlash maqsadga muvofiq emas deb ko‘rsatilgan."),
    ("C-ABY-EVD-IN-01", "topic", "aby-evidence-intake", "application", "framing",
     loc("D", 49, "5-band"),
     "Ashyoviy dalillar ABYda ko‘rsatilgan tartibda qabul qilinadi (tartib sud-biologik ekspertiza qoidalari va Sog‘liqni saqlash "
     "vazirligi buyruqlariga tayanadi, hujjat shularni keltiradi): dalillar bo‘lim mudiri yoki u tayinlagan shaxs tomonidan, faqat "
     "o‘ralgan va muhrlangan holatda qabul qilinadi; o‘rash materiali — qog‘oz, karton, yog‘och yashik, polietilen paket taqiqlangan. "
     "Tekshiriladigan hujjatlar: ekspertiza tayinlash qarori yoki ajrimi, ko‘zdan kechirish bayonnomasi, dalillarni olish bayonnomasi, "
     "qayta ekspertizada dastlabki ekspertiza materiallari, namunalar (soch, qon, so‘lak) olish bayonnomasi. Qabulni rad etish "
     "asoslari: o‘ram yo‘qligi yoki butunligi buzilgani, yo‘llanma hujjatlar yo‘qligi, dalil tekshiruvga yaroqsizligi (nam, chiriy boshlagan). "
     "Qabul qilingan dalillar ro‘yxatga olish jurnaliga yoziladi; o‘ramlar va soch paketlari bo‘limning ikki xodimi ishtirokida "
     "ochiladi; dalillar soni qarordagi bilan solishtiriladi, nomuvofiqlik bo‘lsa uch xodim imzosi bilan dalolatnoma tuziladi; "
     "tekshiruvdan keyin dalillar buyurtmachiga imzo evaziga qaytariladi."),
    ("C-ABY-EVD-ST-01", "topic", "aby-evidence-storage", "application", "framing",
     loc("D", 50, "5-band"),
     "Saqlash tartibi (ABY): hujjatlar alohida papkada seyf yoki qulflanadigan shkafda, ish vaqti tugagach bo‘lim muhri bilan "
     "muhrlanadi; yangi tushgan va ekspertiza tugagan dalillar alohida shkaf yoki xonada (istisno — alohida tokchalarda) saqlanadi; "
     "tez buziladigan ob’ektlar muhrlanadigan sovutgichda. Muddatlar: laboratoriyada qoladigan ashyoviy dalillar (murda qoni, "
     "dokali tiqimlar va boshqalar) — 3 yil (ochilmagan jinoyatlarda ekspertiza tayinlagan idoraning rasmiy murojaatiga ko‘ra "
     "uzaytirilishi mumkin); ekspert xulosasi va sud-tibbiy tekshiruv dalolatnomasi — 25 yil; ashyoviy dalillar va yo‘llanma "
     "hujjatlarni, surtma va dokali tiqimlarni, murda qonini ro‘yxatga olish jurnallari — 10 yil. Saqlanish muddati o‘tmagan namunalar "
     "faqat sud-tergov idoralarining yozma talabiga binoan beriladi."),
    # ------------------------------------------------------------------ forensic histology
    ("C-ABY-HIS-FIX-01", "topic", "aby-his-fixation", "principle", "framing",
     loc("E", 2, "4–6-bandlar"),
     "Ichki a’zolarni formalinda fiksatsiyalash (ABY): 10 %, 15 % va 20 % li eritmalar 40 % li formalinning vodoprovod (oqar) suviga "
     "1 : 9, 1 : 6 va 1 : 4 nisbatida aralashtirilib tayyorlanadi; distillangan suv to‘qimalarning bo‘kishiga olib kelgani uchun "
     "ishlatilmaydi. Fiksatsiya yetarli va muddati 24–48 soat bo‘lsa a’zo bo‘lakchalarini sud-gistologik tekshiruvga olish mumkin; "
     "yetarli bo‘lmasa yoki suyuqlik xira yoki qon bilan bo‘yalgan bo‘lsa, bo‘lakchalar yangi 10 % li formalinga o‘tkaziladi (o‘pka "
     "bo‘lakchasi to‘liq fiksatsiyalanishi uchun ustiga paxta yoki doka qo‘yiladi). Fiksator hajmi bo‘lakchalar hajmidan kamida 10 "
     "marta ko‘p, fiksatsiya xona haroratida 24–48 soat. 48 soatdan ortiq saqlash bo‘kishga va to‘q jigarrang kristall cho‘kma "
     "(formalin pigmenti) paydo bo‘lishiga olib keladi. Kesma yuzasida to‘qima rangi bir tekis va konsistensiyasi bir xil bo‘lsa "
     "fiksatsiya tugagan hisoblanadi."),
    ("C-ABY-HIS-STN-01", "topic", "aby-his-staining", "principle", "framing",
     loc("E", 24, "5-band"),
     "Gematoksilin–eozin bilan Mayer bo‘yicha bo‘yash (ABY): parafinsizlantirilgan kesma gematoksilinda 3–15 daqiqa, vodoprovod "
     "suvida kamida 2 daqiqa, 0,1 % li suvli eozinda 2–3 daqiqa, 0,1 % li spirtli eozinda 2–5 daqiqa, so‘ng 96 % spirtning birinchi "
     "idishida 1–5 daqiqa, ikkinchisida 2–5 daqiqa, karbol-ksilolda 2–5 daqiqa, ksilolda 2 daqiqa ushlanadi; kesma doka bilan "
     "ehtiyotkorlik bilan artilib, polistirol yoki boshqa muhit tomiziladi, qoplama oyna yopiladi va xona haroratida 24 soat "
     "quritiladi. Sifat mezoni: mikroskopda hujayra yadrolari, sitoplazma, tomir devori, stroma va parenxima, shikastlangan sohalar "
     "yaxshi ko‘rinishi kerak."),
    ("C-ABY-HIS-DIA-01", "topic", "aby-his-diatoms", "principle", "framing",
     loc("E", 31, "5 va 6-bandlar"),
     "Diatom-plankton tekshiruvi (ABY) cho‘kishda o‘limni aniqlash uchun: 100 g a’zo (o‘pka va jigardan chekka qismlar, buyrak "
     "kapsulasiz) distillangan suv bilan yuvilib, kolbada sulfat va nitrat kislota hamda suvning 1 : 1 : 1 aralashmasi (25 : 25 : 25 ml) "
     "bilan xona haroratida 18–20 soat qisman parchalanadi, so‘ng nitrat kislotaning 1 : 1 eritmasini tomchilatib tiniq sariq suyuqlik "
     "hosil bo‘lguncha davom ettiriladi; sovitilib 24 soat cho‘ktiriladi, 3000 ayl/daq da sentrifugalanadi, cho‘kmadan preparat "
     "tayyorlanadi va qorong‘i maydonda yoki fazo-kontrast bilan 100× da ko‘rilib, 400× da sanaladi. Tahlil: suyak ko‘migida 5–10 "
     "diatom qobig‘i topilishi (o‘pkada, nazorat a’zoda, bir ko‘rish maydonida 20 tadan ortiq bo‘lganda) cho‘kishdan o‘lim belgisi deb "
     "hisoblanadi. Murda materialida diatom topilmasa, cho‘kishdan o‘limni istisno qilib bo‘lmaydi; suv va murda namunalarida turlar "
     "farq qilsa, boshqa suv havzasi yoki turli vaqtda tushish ehtimoli, silikozda kasbiy kelib chiqish ehtimoli hisobga olinadi. "
     "Barcha idishlar distillangan suv bilan yuvilishi kerak (vodoprovod suvi diatom bilan ifloslantirishi mumkin)."),
]
