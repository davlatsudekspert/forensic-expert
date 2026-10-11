"""ABY 2025 — SECOND batch of records (Uzbek ONLY; owner's rules of 2026-10-10 apply unchanged).

Same structure as aby_data.py (TOPICS / CLAIMS tuples).  Everything below is our own wording of what
the guide says; nothing is quoted, no `excerpt`.  Every record is `locale_only = "uz"`.

This file is meant to sit in content/tools/ next to aby_data.py.  It imports the shared pieces from it
Section names and `loc()` come from aby_data, which now carries every section letter (A–G).

Where one claim rests on two practices, `locm()` joins the two places with «; ».
Where the guide itself is unclear (garbled table, undefined symbol, internal contradiction) the claim
says so and gives «manba tekshirilmoqda» instead of a value.
"""
from __future__ import annotations

from aby_data import PRESUMPTIVE, SECTION_UZ, SRC_ID, SOURCE_I18N_UZ, loc  # noqa: F401


def locm(letter: str, *parts: tuple[int, str]) -> str:
    """Two (or more) practices of the same section in one locator."""
    head = f"ABY, {SECTION_UZ[letter]}, "
    return head + "; ".join(
        f"№ ABY.{letter}.{n}.2025 amaliyoti" + (f", {d}" if d else "") for n, d in parts
    )


# --------------------------------------------------------------------------------- topics
# (topic_id, area, uz name)
TOPICS_B2 = [
    ("aby-tox-sulfonylureas", "toxicology", "Sulfonilmochevina hosilalari: biologik suyuqlik va ichki a’zolarda sud-kimyoviy aniqlash"),
    ("aby-tox-organophosphates", "toxicology", "Fosfororganik birikmalar: ichki a’zolarda sud-kimyoviy aniqlash"),
    ("aby-tox-mercury", "toxicology", "Simob: ichki a’zolarda sud-kimyoviy aniqlash"),
    ("aby-tox-metals", "toxicology", "Metalli zaharlar: mineralizatsiya va kasrli usul"),
    ("aby-tox-acetic-acid", "toxicology", "Sirka kislotasi: haydash va sud-kimyoviy aniqlash"),
    ("aby-tox-phenothiazines", "toxicology", "Fenotiazinlar: ajratib olish va TLC bilan sifat tahlili"),
    ("aby-tox-ammonia", "toxicology", "Ammiak: dializ va sifat tahlili"),
    ("aby-tox-isolation-methods", "toxicology", "Ajratib olish usullari: uchuvchi zaharlar, Stass–Otto, dializ"),
    ("aby-fm-supravital", "forensicMedicine", "Murdada supravital reaksiyalar (o‘lim vaqtini aniqlashda yordamchi usul)"),
    ("aby-fm-strangulation", "forensicMedicine", "Strangulyatsion egat va bo‘yin a’zolarini tekshirish"),
    ("aby-fm-newborn", "forensicMedicine", "Yangi tug‘ilgan chaqaloq (homila) murdasi: tirik tug‘ilganlik sinamalari"),
    ("aby-fm-autopsy-technique", "forensicMedicine", "Murdani tekshirish texnikasi: emboliya sinamasi, sinishlarni tavsiflash, voqea joyi"),
    ("aby-fm-living-persons", "forensicMedicine", "Tirik shaxslar ekspertizasi: tartib, jarohatni tavsiflash, jinsiy yetuklik"),
    ("aby-fm-repeat-commission", "forensicMedicine", "Takroriy, komission va kompleks ekspertizalar; tibbiy yordam nuqsonlari"),
    ("aby-fm-bone-sex", "forensicMedicine", "Suyaklar bo‘yicha jins mansubligini aniqlash"),
    ("aby-fm-bone-age", "forensicMedicine", "Suyak va tishlar bo‘yicha yoshni aniqlash"),
    ("aby-fm-bone-stature", "forensicMedicine", "Naysimon suyaklar bo‘yicha bo‘y uzunligini aniqlash"),
    ("aby-fm-photo-identification", "forensicMedicine", "Bosh suyagi va fotosurat bo‘yicha aynanlikni aniqlash (AGI)"),
    ("aby-fm-clothing-gunshot", "forensicMedicine", "Kiyimdagi jarohatlar va o‘q-otar jarohat izlarini kontakt-diffuzion tekshirish"),
    ("aby-fm-medcrim-lab", "forensicMedicine", "Tibbiy-kriminalistik bo‘lim: dalillarni qabul qilish, saqlash va tekshiruvga tayyorlash"),
]

# --------------------------------------------------------------------------------- claims
# (claim_id, entity_type, entity_id, field, evidence_class, locator, uz text)
CLAIMS_B2 = [
    # ================================================================== G: toxicology
    # ------------------------------------------------------------------ sulfonylureas (G.1, G.2)
    ("C-ABY-SMH-01", "topic", "aby-tox-sulfonylureas", "sample_preparation", "presumptive",
     locm("G", (1, "«Jarayonni olib borish tartibi»"), (2, "2.1-band")),
     "Sulfonilmochevina hosilalari (SMH) kislotali xususiyatga ega, shu sabab ABY ularni barbituratlar kabi nordonlashtirilgan "
     "suv yordamida ajratadi. Biologik suyuqlikdan: 10 ml qon (yoki 20 ml siydik) 2 n xlorid kislota bilan pH 2 gacha "
     "nordonlashtirilib, ajratkich voronkada 3 marta 10 ml xloroform bilan ekstraksiya qilinadi, xloroform qatlami suvsiz natriy "
     "sulfat orqali o‘tkaziladi. Ichki a’zolardan: 100 g maydalangan material 200 ml distillangan suv bilan aralashtirilib, "
     "oksalat kislotaning to‘yingan eritmasi bilan pH 2,0–2,5 ga keltiriladi, 2 soat vaqti-vaqti bilan chayqatiladi, ikki qavat "
     "dokadan o‘tkazilib 10 daqiqa 3000 ayl/daq da sentrifugalanadi; ustki suyuqlik 15 ml dan 2–3 marta xloroform bilan "
     "ekstraksiya qilinib, qatlamlar birlashtirilib xloroform bilan 50 ml gacha yetkaziladi. ABY o‘rtacha ajratib olish "
     "ulushini keltiradi: glibenklamid 36,4 %, glimepirid 34,8 %, glipizid 27,3 %, glikvidon 31,7 %, gliklazid 30,5 %. Qabul "
     "mezoni: reaktivlar va shu preparatni saqlamagan nazorat bioob’ekt mos natija bermasligi kerak." + PRESUMPTIVE),
    ("C-ABY-SMH-02", "topic", "aby-tox-sulfonylureas", "tlc_system", "presumptive",
     loc("G", 1, "«Jarayonni olib borish tartibi», 1- va 2-jadvallar"),
     "SMH ning TLC aniqlashi (ABY): 2 ml xloroformli ekstrakt 0,5 ml gacha bug‘latilib, plastinka start nuqtasiga bir tomchi "
     "tomiziladi, 2 sm o‘ngga preparatning 0,01 % li metanoldagi standarti qo‘yiladi; plastinka xloroform–aseton (9:1) bug‘i "
     "bilan to‘yingan kamerada front 10 sm ga ko‘tarilguncha xromatografiya qilinadi. Rf (Silufol / Sorbfil): glibenklamid "
     "0,56–0,59 / 0,58–0,61; glimepirid 0,33–0,37 / 0,36–0,39; gliklazid 0,62–0,66 / 0,66–0,70; glikvidon 0,70–0,74 / "
     "0,72–0,76; glipizid 0,11–0,15 / 0,14–0,17. Dog‘lar ketma-ket difenilkarbazon (xloroformda) va simob sulfat bilan "
     "ochilganda barcha beshta preparat havo rang fonda to‘q moviy dog‘ beradi; yod bug‘i va Bushard reaktivida qo‘ng‘ir, "
     "Mune bo‘yicha Dragendorfda jigarrang, Libermanda zarg‘aldoq dog‘ hosil bo‘ladi. Simob nitrat (qora), fosfornomolibdat "
     "kislota (to‘q ko‘k) va kobalt nitrat (binafsha) faqat ayrim preparatlarda rang beradi, ammo ABY jadvalida ustunlar "
     "rim raqamlari (I–V) bilan belgilangan va qaysi ustun qaysi preparat ekani yozilmagan: manba tekshirilmoqda. "
     "Xulosa uchun standart bilan bir plastinkada solishtirish kerak." + PRESUMPTIVE),
    ("C-ABY-SMH-03", "topic", "aby-tox-sulfonylureas", "analytical_method", "instrumental",
     loc("G", 1, "«Jarayonni olib borish tartibi», 3- va 4-jadvallar"),
     "SMH ni sirt termodesorbsion ionlanish spektroskopiyasi (STDIS, PII-N-S «Iskovich» asbobi) bilan aniqlash: emitter harorati "
     "390–420 °C, emitter kuchlanishi 400 V, bug‘latgich xona haroratidan 310 °C gacha; 1 ml xloroformli ekstrakt quritilib, "
     "qoldiq 0,5 ml metanolda eritiladi, mikroshpris bilan 1–2 µl (aniq hajm miqdoriy hisob uchun muhim) olinadi, hosil bo‘lgan "
     "spektr asbob bazasidagi etalon bilan solishtiriladi. Tmax (°C) va aniqlash chegarasi: glibenklamid 214±6 (1 µg); gliklazid "
     "244±6 va 276±6 (0,01 µg); glikvidon 240±6 (1 µg); glipizid 235±5 (1 µg); glimepirid 210±4, 255±5, 368±5 (0,05 µg). UB "
     "spektrofotometriya (200–350 nm, solishtiruvchi — metanol) maksimumlari (nm), etanol / metanol / 0,1 n NaOH / 0,1 n HCl: "
     "glibenklamid 275, 300 / 275, 300 / 275, 300 / —; gliklazid 228, 263 / 228, 263 / 229, 263 / 227; glikvidon 311 / 311 / "
     "276 / noma’lum; glipizid 275 / 274 / — / 231, 276; glimepirid 227, 274 / 227, 274 / noma’lum / noma’lum. Miqdoriy "
     "hisob solishtirma ko‘rsatkich E1%1sm = D/(S·l) orqali yuritiladi, ammo ABYdagi yakuniy formulada V2 hajmi tushuntirilmagan: "
     "formula keltirilmadi, manba tekshirilmoqda."),
    # ------------------------------------------------------------------ organophosphates (G.9)
    ("C-ABY-OP-01", "topic", "aby-tox-organophosphates", "analytical_method", "presumptive",
     loc("G", 9, "2.1 va 2.2.1-bandlar"),
     "Fosfororganik birikmalarni (FOB) ajratish va xolinesteraza sinamasi (ABY): 20 g mayda murda materiali, qon yoki siydik "
     "(20 ml) alohida kolbalarga solinib, har biriga 20 ml benzol qo‘shiladi, elektr chayqatgichda 20 daqiqa chayqatilib xona "
     "haroratida 2 soat qoldiriladi va benzolli ajratma filtrlanadi. Xolinesteraza sinamasi: 1 ml filtrat 1 ml normal ot "
     "zardobi bilan 20 daqiqa chayqatiladi, pastki qismdan 0,05 ml olinib Ulengut probirkasiga solinadi, unga pH 8,4 li "
     "bromtimol ko‘ki buferi va asetilxolinxlorid aralashmasidan 2 ml qo‘shiladi, probirkalar 40 °C li suv komparatoriga qo‘yiladi. "
     "Nazorat — ferment faolligini so‘ndiruvchi modda bo‘lmagan a’zolardan olingan benzolli ajratma. 10 daqiqadan so‘ng "
     "bufer-indikator rangining o‘zgarishi FOB yo‘qligini bildiradi; ferment faolligining 10 % dan ortiq susayishi namunada "
     "fosfororganik antixolinesteraza bo‘lishi ehtimolini ko‘rsatadi. ABYga ko‘ra chuqur chirimagan (xona haroratida 6 kun "
     "saqlangan) a’zo, qon va siydikdan olingan ekstrakt usulga xalaqit bermaydi." + PRESUMPTIVE),
    ("C-ABY-OP-02", "topic", "aby-tox-organophosphates", "tlc_system", "presumptive",
     loc("G", 9, "2.2.2 va 3.3-bandlar"),
     "FOB ning TLC aniqlashi (ABY): 5 ml benzolli ajratma 0,5 ml gacha bug‘latilib silikagel plastinkaga tomiziladi, 2 sm o‘ngga "
     "standart (FOB ning 0,01 % li spirtli eritmasi) qo‘yiladi; plastinka suv bilan to‘yingan benzol bug‘i kamerasida front "
     "10 sm ga ko‘tarilguncha xromatografiya qilinadi. Ochish alohida nuqtalarda: kaliy yodiddagi vismut yodid — zarg‘aldoq dog‘ "
     "(oktametil); natriy ishqorining spirtli eritmasi — sarg‘ish dog‘ (metilnitrofos); bromfenol ko‘ki va 5 % sirka kislota — havo "
     "rang dog‘ (antio); rezorsinning natriy ishqoridagi eritmasi — pushti dog‘ (xlorofos). Preparat nomlari ABYdagi atamalar "
     "bilan berilgan. Rf qiymatlari bu amaliyotda keltirilmagan. Faollashtirmasdan va ekstrakt aralashmalarisiz aniqlash chegarasi: "
     "xlorofos 2 µg; metilmerkaptofos va oktametil 5 µg; butifos va fozalon 10 µg; sayfos va ftalofos 12 µg; metafos, "
     "metilnitrofos, karbofos 25 µg. Reaktivlar va nazorat namuna FOBga musbat natija bermasligi kerak." + PRESUMPTIVE),
    # ------------------------------------------------------------------ mercury (G.10)
    ("C-ABY-HG-01", "topic", "aby-tox-mercury", "sample_preparation", "framing",
     loc("G", 10, "«Jarayonni olib borish tartibi», destruksiya bo‘limlari"),
     "Simobni aniqlash uchun ob’ekt destruksiya qilinadi (ABY). Ichki a’zolar: har bir a’zodan alohida 20 g, 200 ml konussimon "
     "kolbaga 5 ml suv, 1 ml etanol va 10 ml kons. nitrat kislota solinadi, azot oksidlari chiqib ketmasligi uchun 20 ml kons. sulfat "
     "kislota tomchilab qo‘shiladi, 5–10 daqiqa xona haroratida qoldirilib, so‘ng 10–20 daqiqa qaynoq suv hammomida qizdiriladi; "
     "reaksiya avjida 30–50 ml issiq suv qo‘shiladi; issiq destruktat ikki hajm issiq suv bilan aralashtirilib, sovutilmay namlangan "
     "filtr orqali 20 ml to‘yingan mochevina eritmasi (denitratsiya) solingan kolbaga filtrlanadi. Siydik: 500 ml Kyeldal kolbasiga "
     "200 ml filtrlanmagan siydik va 25 ml kons. sulfat kislota solinib, oz-ozdan 7 g kaliy permanganat qo‘shiladi, 40 daqiqa "
     "qoldirilib, permanganat rangi yo‘qolguncha shavel kislotaning to‘yingan eritmasi qo‘shiladi. Qon (50–100 ml) a’zolardagi "
     "kabi, faqat suv qo‘shilmasdan destruksiya qilinadi."),
    ("C-ABY-HG-02", "topic", "aby-tox-mercury", "analytical_method", "presumptive",
     loc("G", 10, "«Destruktatdan simobni aniqlash» va «Tahlil. Izohlash»"),
     "Destruktatda simobni aniqlash (ABY): (1) ditizon bilan — destruktat avval xloroform bilan tozalanadi, so‘ng 10 ml 10 % "
     "gidroksilamin sulfat (yoki 10 % askorbin kislota), 5 ml xloroform va 0,3 ml 0,01 n yashil ditizon eritmasi qo‘shilib "
     "chayqatiladi; xloroform qatlamining sariq yoki zarg‘aldoq-sariq tusga kirishi simob borligini bildiradi. (2) mis (I) yodid "
     "tortmasi bilan — destruktat yarmiga 5 ml 2,5 n natriy sulfit, 250 ml suv va 10 ml mis (I) yodid tortmasi qo‘shiladi; "
     "qizil yoki zarg‘aldoq-qizil rang simobni ko‘rsatadi. ABYga ko‘ra mis (I) yodid bilan cho‘ktirishda simob 100 g a’zoda "
     "(yoki 100 ml qon/siydikda) 1·10⁻² mg dan 10 mg va undan ko‘p miqdorgacha aniqlanadi. Standart: 0,135 g simob xlorid 1 l "
     "0,25 % yodli eritmada eritiladi (0,1 mg/ml), 10 marta suyultirib 0,01 mg/ml tayyorlanadi, saqlash muddati 30 kun. Qabul "
     "mezoni: nazorat namunasi va reaktivlar simob bo‘yicha manfiy natija berishi shart." + PRESUMPTIVE),
    # ------------------------------------------------------------------ metals (G.11)
    ("C-ABY-MET-01", "topic", "aby-tox-metals", "sample_preparation", "framing",
     loc("G", 11, "«Jarayonni o‘tkazish tavsifi», mineralizatsiya va denitratsiya"),
     "Metalli zaharlar uchun kasrli usulda ob’ekt avval mineralizatsiya qilinadi (ABY): jigar, oshqozon (ichidagi massa bilan), "
     "buyrak va boshqalardan har biridan alohida 100 g olinadi, aralashtirilmaydi. 100 g maydalangan material Kyeldal kolbasiga "
     "solinib, sulfat kislota, nitrat kislota va suvning 1:1:1 aralashmasidan 75 ml qo‘shiladi (siydik, sut, sho‘rva kabilar uchun "
     "25 ml nitrat va 25 ml sulfat kislota). Kolba asbest to‘ridan 1–2 sm balandlikda mahkamlanib 30–40 daqiqa sekin qizdiriladi, "
     "nitrat kislota tomchilatib turiladi; nitrat kislota qo‘shilganda rang o‘zgarmay qolguncha davom ettirilib, so‘ng SO₂ ning "
     "quyuq oq bug‘i chiqquncha yana 30 daqiqa qizdiriladi. Azot oksidlarini tekshirish uchun difenilaminning sulfat kislotadagi "
     "eritmasi ishlatiladi (zangori/ko‘k rang — azot oksidlari bor), ular formalin bilan qaynatib yo‘qotiladi (denitratsiya). "
     "Mineralizat 180 ml gacha suyultirilib, cho‘kma bo‘lsa 18–24 soat qoldiriladi, filtrlanadi va 200 ml gacha yetkaziladi; "
     "cho‘kma qaynoq ammoniy asetat bilan ishlanganda qo‘rg‘oshin eritmaga o‘tadi, bariy cho‘kmada qoladi."),
    ("C-ABY-MET-02", "topic", "aby-tox-metals", "analytical_method", "presumptive",
     loc("G", 11, "«Jarayonni o‘tkazish tavsifi», metallar bo‘yicha reaksiyalar"),
     "Mineralizatda ayrim metallarni aniqlash reaksiyalari va ABYda ko‘rsatilgan sezgirliklar. Qo‘rg‘oshin: pH 7,5–8,0 da ditizon "
     "bilan xloroform qatlami olvon-qizil; sulfid (qora), sulfat (oq) va xromat (sariq) cho‘kmalari; mikrokristallar — seziy–"
     "qo‘rg‘oshin yodid (aniqlash chegarasi 0,01 µg) va mis–qo‘rg‘oshin–kaliy geksanitrit (0,03 µg). Marganes: kaliy peryodat yoki "
     "ammoniy persulfat bilan oksidlash, pushti–siyohrang (0,1 µg/ml). Xrom: kumush nitrat va persulfat bilan oksidlab, "
     "difenilkarbazid bilan pushti–qizg‘ish-binafsha (0,1 µg/ml). Kumush: ditizon bilan xloroform tillarang-sariq (0,04 µg/ml). "
     "Mis: qo‘rg‘oshin dietilditiokarbamat bilan sariq–jigarrang; rux tetrarodanomerkurat (0,1 µg/ml), kadmiy ferrotsianid "
     "(0,1 µg/ml), piridin-rodan kompleksi (1 µg). Surma va talliy: malaxit yashili–toluol, ko‘k rang (0,01 µg/ml). Mishyak: "
     "Zanger–Blek apparatida simob bromid qog‘ozida qo‘ng‘ir-jigarrang dog‘ (0,1 µg/ml). Vismut: yodid-oksin kompleksining "
     "zarg‘aldoq-qizil cho‘kmasi (100 g a’zoda kamida 2 mg bo‘lganda 30–60 daqiqada). Rux: ditizon, pH 4,5–5,0, yashil rang "
     "pushtiga o‘tadi (100 g namunada 5 mg). Kadmiy: dietilditiokarbamatdan so‘ng natriy sulfid bilan sariq cho‘kma "
     "(100 g namunada 4 mg). Bariy: kons. sulfat kislotada rangsiz kristallar. Bu — dastlabki reaksiyalar, ABY xulosa uchun "
     "bir nechta reaksiyaning mos kelishini talab qiladi." + PRESUMPTIVE),
    ("C-ABY-MET-03", "topic", "aby-tox-metals", "limitation", "framing",
     loc("G", 11, "«Tahlil. Izohlash. Hujjatlashtirish» (3.1-band va keyingilar)"),
     "ABY metallarni baholashda organizmning tabiiy tarkibini hisobga olishni talab qiladi. Keltirilgan ma’lumotlar (100 g a’zoga, mg): "
     "A.I. Voynar bo‘yicha qo‘rg‘oshin — jigarda 0,13, buyrakda 0,027, miyada 0,013, o‘pkada 0,028, uzun suyaklarda 1,88, "
     "qovurg‘ada 0,47; kumush — jigarda 0,005, miyada 0,03, o‘pkada 0,004; xrom — jigarda 0,001, buyrakda 0,028, sochda 0,2, "
     "tirnoqda 0,12. Kasrli usulda mis meyorda aniqlanadi: ABY ishlab chiqilgan usulda jigarda 0,56–1,12, buyrakda 0,26–0,40, "
     "miyada 0,31–0,94 mg topilganini yozadi (adabiyotda jigarda 0,7–0,8 mg); yangi tug‘ilgan davrga yaqin homilada jigarda mis "
     "ko‘proq, 5–15 yoshda minimal. Mishyak tabiiy miqdorda: jigarda 0,01–0,07, buyrakda 0,01–0,08 mg; rux: jigarda 2,73–6,71, "
     "buyrakda 1,76–6,16 mg. Qo‘rg‘oshin, bariy, kumush, xrom, vismut, surma va talliy kasrli usulda odatda aniqlanmaydi; vismut "
     "preparatlari bilan davolanganda organizmda 1 yil 8 oygacha saqlanishi mumkin. ABY mis, rux va mishyakni organizmning tabiiy "
     "tarkibi sifatida kasrli usulda aniqlanishi mumkinligini alohida ta’kidlaydi. ABY matnidagi mis "
     "bo‘yicha adabiyot ma’lumotida birlik xato yozilgan («0,46 g»), shu sabab u qiymat keltirilmadi: manba tekshirilmoqda."),
    # ------------------------------------------------------------------ acetic acid (G.13)
    ("C-ABY-ACA-01", "topic", "aby-tox-acetic-acid", "analytical_method", "presumptive",
     loc("G", 13, "2-bo‘lim va 3.1-band"),
     "Sirka kislotasi suv bug‘i bilan haydab ajratiladi (ABY): 100 g ob’ekt distillangan suv bilan quyuq bo‘tqa qilinib yumaloq "
     "tubli kolbaga (hajmning 1/3 gacha) solinadi, 10 % sulfat kislota bilan pH 2–3 gacha nordonlashtiriladi (muhit allaqachon "
     "nordon bo‘lsa ob’ekt o‘shandayligicha haydaladi). Distillyat ma’lum hajmdagi 0,1 n natriy ishqori solingan qabul qiluvchiga "
     "yig‘iladi (sovutkich allonji ishqorga tegib turishi kerak), haydash distillyat kislotaga manfiy reaksiya bergunga qadar "
     "davom ettiriladi. Distillyatning bir qismi quruq qoldiqqacha bug‘latiladi va tekshiriladi: yangi 5 % temir (III) xlorid — "
     "qizil rang (asetat aniqlash chegarasi 1,25 mg/ml distillyat); orto-nitrobenzaldegid usuli — qoldiq kalsiy oksidi va "
     "karbonat aralashmasi bilan isitilib, ortonitrobenzaldegidning 5 % li natriy ishqoridagi eritmasiga ho‘llangan qog‘oz "
     "sariqqa bo‘yaladi; etil spirti va kons. sulfat kislota bilan qizdirilganda sirka etil efirining hidi. Ikkinchi qism 0,1 n "
     "xlorid kislota bilan fenolftalein ishtirokida titrlanadi; hisoblash formulasi ABY matnida ko‘rinmaydi: manba "
     "tekshirilmoqda. ABY haydalishi mumkin bo‘lgan sirka kislotaning eng kam miqdorini 0,5 g deb ko‘rsatadi; chirimagan "
     "biologik namunada 0,3–0,4 % miqdori birinchi distillyatlarda haydalishi haqidagi band ABYda boshqa yozuvda berilgan "
     "va mazmuni noaniq: manba tekshirilmoqda." + PRESUMPTIVE),
    # ------------------------------------------------------------------ phenothiazines (G.17)
    ("C-ABY-PHT-01", "topic", "aby-tox-phenothiazines", "sample_preparation", "presumptive",
     loc("G", 17, "2.1 va 2.2-bandlar"),
     "Fenotiazinlarni siydikda dastlabki aniqlash (ABY): 1 ml siydikka 10 % sulfat kislota (60 ml) va 5 % temir (III) xlorid "
     "(20 ml) aralashmasidan 1 ml qo‘shilganda to‘q-qizil rang; ikkinchi usulda 5 % temir (III) xlorid (5 ml) va 20 % nitrat "
     "kislota (45 ml) aralashmasidan 1 ml qo‘shilganda och-qizil pushti rang hosil bo‘ladi. Ajratib olish: 2 ml qon yoki 10 ml siydik "
     "50 % natriy ishqori bilan pH 13 gacha keltirilib qaynoq suv hammomida 10 daqiqa qizdiriladi, sovitilib, 3 % izoamil spirti "
     "saqlagan n-geptan (yoki dietil efiri, xloroform) bilan 2 marta 20 ml dan ekstraksiya qilinadi. Ichki a’zolardan: 100 g material "
     "oksalat kislota bilan nordonlashtirilgan 96 % etanol bilan (100 ml, 3 marta, har gal 2 soat) ishlanadi, bug‘latilib, "
     "oqsillar etanol bilan cho‘ktiriladi, qoldiq pH 13 da dietil efiri bilan ekstraksiya qilinib, fenotiazinlar 0,5 n sulfat "
     "kislota bilan (10, 10, 10, 5 ml) reekstraksiya qilinadi. Standart: aminazin, diprazin, triftazin, levomepromazin, etaperazin "
     "va boshqalarning 0,01 % li metanolli (yoki xloroformli) eritmasi." + PRESUMPTIVE),
    ("C-ABY-PHT-02", "topic", "aby-tox-phenothiazines", "colour_test", "presumptive",
     loc("G", 17, "2.3-band, 1- va 2-jadvallar, 3.2-band"),
     "Fenotiazinlarning quruq qoldiqdagi rang reaksiyalari (ABY, nomlar ABYdagidek): kons. H₂SO₄ — aminazin, diprazin, "
     "levomepromazin va etaperazinda to‘q-qizil, triftazinda qizil; kons. HNO₃ — aminazin va levomepromazinda to‘q-qizil "
     "binafsha, diprazinda och-qizil→sariq, triftazinda qizil, etaperazinda qizil; Marki reaktivi — levomepromazinda ko‘k-qizil, "
     "boshqalarida to‘q-qizil; Mandelin reaktivi — ko‘k-yashil→qizil (levomepromazinda qizil-binafsha). Vitali–Moren reaksiyasi "
     "diprazinga xos: qoldiq kons. HNO₃ bilan bug‘latiladi, hosil bo‘lgan sariq qoldiqqa bir tomondan aseton, ikkinchi tomondan "
     "10 % spirtli ishqor tomiziladi — tez o‘chuvchi binafsha rang. TLC (ikkita plastinka): A sistema benzol–dioksan–25 % ammiak "
     "60:35:5; B sistema etilasetat–aseton–(25 % ammiak va etanolning 1:1 aralashmasi) 50:45:4; front 10 sm; dog‘lar H₂SO₄–etanol "
     "(1:9) yoki Marki reaktivi bilan ochiladi. ABYdagi Rf jadvalida ba’zi qiymatlar 1 dan katta (masalan, 1,56; 2,9), bu oddiy "
     "Rf bo‘la olmaydi va nimaga nisbatan berilgani yozilmagan: qiymatlar keltirilmadi, manba tekshirilmoqda. Tirik "
     "shaxslarning qon va siydik tekshiruvida aminazin Stass–Otto usulining Salomatin modifikatsiyasida 50 %, A.A. Vasileva "
     "usulida 25 % gacha aniqlanadi deb yozilgan (nimaning ulushi ekani ABYda tushuntirilmagan)." + PRESUMPTIVE),
    # ------------------------------------------------------------------ ammonia (G.19) + putrefaction (G.22)
    ("C-ABY-NH3-01", "topic", "aby-tox-ammonia", "principle", "presumptive",
     loc("G", 19, "2.1 va 3.1–3.3-bandlar"),
     "Ammiak biologik ob’ektdan suv bilan dializ yo‘li bilan ajratiladi (ABY): 100 g mayda ichki a’zo, 2–3 l li kristallizatorning "
     "1/3 qismigacha tozalangan suv solinadi; ichiga tagi kesilgan, tagi pergament qog‘ozi bilan o‘rab ipda mahkamlangan uzun shisha "
     "stakan tushiriladi, unga ob’ekt va suv aralashmasi solinadi (ikki suyuqlik sathi bir xil bo‘lishi kerak); har 4–6 soatda "
     "kristallizatordagi suv yangilanib, dializatlar birlashtiriladi. Aniqlash: 50 ml dializat Erlenmeyer kolbasida; kolba "
     "og‘ziga qizil lakmus, mis sulfat va qo‘rg‘oshin asetat shimdirilgan ho‘l qog‘ozlar osilib 1–2 soatdan keyin ko‘riladi — "
     "lakmus va mis sulfatli qog‘oz ko‘karib, qo‘rg‘oshin asetatli qog‘oz o‘zgarmasa ammiak bor. Nessler reaktivi bilan: "
     "1–2 tomchi dializat, 3–5 tomchi suv va 3–4 tomchi reaktivdan sariq-qo‘ng‘ir yoki zarg‘aldoq-jigarrang cho‘kma. Suv bilan "
     "namlangan lakmus va fenolftalein qog‘ozi bilan 30 daqiqadan so‘ng: lakmus ko‘karadi, fenolftalein qizaradi. Reaktivlar va "
     "nazorat namuna ammiakka musbat bermasligi kerak." + PRESUMPTIVE),
    ("C-ABY-NH3-02", "topic", "aby-tox-ammonia", "limitation", "framing",
     locm("G", (19, "4-bo‘lim «Tahlil. Izohlash»"), (22, "5.4–5.5-bandlar")),
     "Chirish jarayonida ob’ektda ammiak va vodorod sulfid hosil bo‘ladi, shuning uchun ammiak topilishi o‘z-o‘zidan zaharlanishni "
     "isbotlamaydi. ABY bo‘yicha ammiakni tekshirishdan oldin ob’ekt vodorod sulfidga tekshiriladi: vodorod sulfid topilsa, "
     "ob’ekt chiriyotgani hisoblanadi va ammiakka tekshiruv o‘tkazilmaydi; ammiakni tekshirish uchun a’zo chirimagan va vodorod "
     "sulfid saqlamagan bo‘lishi kerak. Ob’ekt zich yopiladigan idishda, 1 kundan oshmay sud-kimyo tekshiruviga yetkazilishi "
     "zarur. Ob’ektning hidi qo‘shimcha yo‘nalish berishi mumkin, lekin odatda chirish hidi izlanayotgan birikma hidini yashiradi."),
    # ------------------------------------------------------------------ isolation methods (G.3, G.21, G.4, G.22)
    ("C-ABY-VOL-01", "topic", "aby-tox-isolation-methods", "limitation", "framing",
     loc("G", 3, "«Tahlil. Izohlash. Hujjatlashtirish»"),
     "Uchuvchi zaharlar guruhini tekshirishda ABY quyidagilarga e’tibor berishni talab qiladi: ob’ekt hidi (izoamil spirti — "
     "spirt tozalash moyining hidi; nitrobenzol va sinil kislota — achchiq bodom hidi) va distillyatning tashqi ko‘rinishi "
     "(izoamil spirti suvdan yengil, yuzasida moy pardasi; fenol — o‘ziga xos hid va sutsimon loyqa; xloroform va uglerod to‘rt "
     "xlorid suvdan og‘ir, rangsiz tomchi yoki qatlam hosil qiladi). Berlin lazuri reaksiyasi o‘ta sezgir va spesifik bo‘lib, "
     "ABYga ko‘ra sinil kislotani isbotlashda yagona reaksiya xulosa uchun yetarli, hosil bo‘lgan cho‘kmani ashyoviy dalil sifatida "
     "taqdim etish mumkin. Organik bog‘langan xlorga umumiy reaksiya sezgir bo‘lsa-da spesifik emas, shuning uchun u faqat "
     "manfiy sud-kimyoviy ahamiyatga ega; u yoki bu uchuvchi zahar haqidagi xulosa reaksiyalar majmuasiga tayanadi."),
    ("C-ABY-VOL-02", "topic", "aby-tox-isolation-methods", "sample_preparation", "framing",
     locm("G", (21, "2-bo‘lim va 4.1-band"), (4, "«Jarayonni olib borish tartibi» va «Tahlil»")),
     "Chirigan biologik ob’ektlardan organik zaharlarni oksalat kislota bilan nordonlashtirilgan 96 % etanol yordamida "
     "ajratish (Stass–Otto usuli, ABY): 100 g maydalangan ob’ekt etanol bilan qoplanib, 10 % spirtli oksalat kislota bilan "
     "pH 2,5–3,0 ga keltiriladi, har kuni muhit tekshirilib, uch kun davomida spirt almashtiriladi; spirtli ajratma ~40 °C da "
     "quyuq sharbatgacha bug‘latiladi, oqsil 96 % spirt bilan tomchilab cho‘ktiriladi; suvli eritma xloroform bilan 3 marta "
     "ishlanib «birinchi kislotali ajralma» olinadi, so‘ng pH 8–10 gacha (25 % ammiak) ishqoriy qilinib 3 marta 10 ml xloroform "
     "bilan «ikkinchi ishqoriy ajralma» olinadi; ajralmalar qo‘shimcha tozalanadi. ABY oksalat o‘rniga kuchli mineral kislota "
     "ishlatmaslikni talab qiladi: ko‘p yot modda o‘tadi va murakkab efir tuzilishli ayrim zaharlar qisman parchalanadi. Usul 8–10 kun "
     "va taxminan 500 ml spirt talab qilsa-da, ABY uni chirigan materialdan ajratish uchun samarali deb hisoblaydi. "
     "Barbituratlar ulushi: yangi jigarda (100 g da 40 mg qo‘shilganda, G.4) barbital 6,16–8,78 %, fenobarbital 16,5–21,5 %, "
     "barbamil 24,0–25,6 %, benzonal 2,1–2,4 %, etaminal-natriy 22,5–26,6 %, butobarbital 28,3–30,9 % ajratib olinadi; "
     "chirigan ob’ektlarda (1 oy / 6 oy) barbital 1,8–2,2 / 3,0–3,2 %, fenobarbital 15,8–16,0 / 14,7–15,8 %, "
     "etaminal-natriy 20,6–22,7 / 19,8–20,7 %, barbamil 21,0–25,6 / 20,6–23,0 % (G.21 jadvalida ushbu foizlar nima ulushi "
     "ekani aniq yozilmagan)."),
    ("C-ABY-DIA-01", "topic", "aby-tox-isolation-methods", "principle", "framing",
     loc("G", 22, "4.1-band va 5.1–5.3-bandlar"),
     "Dializ usuli mineral kislotalar (sulfat, nitrat, xlorid), ishqorlar (natriy, kaliy, ammiak) va ayrim tuzlar (kaliy xlorat, "
     "nitrit va nitratlar) ni suvda yaxshi erishiga asoslanib ajratadi (ABY). Tekshiriladigan ob’ektlar: qusuq massasi va chayindi "
     "suvlar, ovqat qoldig‘i, me’da va ichaklar, jigar (o‘t pufagi bilan), traxeya hamda qizilo‘ngach. Tartib: 2–3 l "
     "kristallizatorning yarmidan ortig‘iga tozalangan suv; ichiga tagi pergament bilan o‘ralgan dializator-stakan; unga 100 g "
     "ob’ekt suv bilan aralashtirilib (2–4 soatga qo‘yilgan) solinadi; ikki sath bir xil; har 4–6 soatda suv boshqa stakanga "
     "olinadi, jarayon 2–3 marta takrorlanib, dializatlar (250–1000 ml) birlashtiriladi. Mineral kislotalar tekshirilganda avval "
     "sulfat, so‘ng nitrat va xlorid kislotaga tekshiriladi. ABY kons. nitrat kislota (68 %) uchun LD = 8–10 ml deb "
     "ko‘rsatadi."),
    ("C-ABY-DIA-02", "topic", "aby-tox-isolation-methods", "chemical_test", "presumptive",
     loc("G", 22, "4.2–4.10-bandlar"),
     "Dializatda aniqlash reaksiyalari (ABY). Sulfat kislota: bariy xlorid — nitrat va xlorid kislotada hamda ishqorda erimaydigan "
     "oq cho‘kma; qo‘rg‘oshin asetat — nitrat kislotada erimaydigan, ammoniy asetatda qizdirilganda eriydigan oq cho‘kma; natriy "
     "rodizonat bilan bariyli dog‘ rangining yo‘qolishi. Nitrat kislota: difenilamin (kons. H₂SO₄ da) va brutsin — qizil rang, "
     "ammo nitritlar va boshqa oksidlovchilar ham shunday beradi, shuning uchun avval nitritlar aniqlanadi (sulfanil kislota yoki "
     "Griss reaktivi, azobo‘yoq hosil bo‘ladi; yodkraxmal qog‘ozi); jun nitrat kislotadan turg‘un sariq tusga kiradi, paxta — "
     "yo‘q. Xlorid kislota: kumush nitrat — oq cho‘kma; Bertole tuzi bilan erkin xlor. Natriy: rux uranil asetat bilan sariq cho‘kma; "
     "kaliy: natriy kobaltonitrat bilan sariq yulduzsimon kristallar, natriy gidrotartrat bilan oq cho‘kma. Ammiak: lakmus/mis "
     "sulfat/qo‘rg‘oshin asetat qog‘ozlari va Nessler reaktivi. Vodorod sulfid: lakmus o‘zgarmasa-yu, mis va qo‘rg‘oshinli "
     "qog‘ozlar qorayishi dializatda chirish natijasida sulfid borligini bildiradi. Indikator qog‘ozlar: Kongo (qizil→ko‘k, "
     "pH 3,0–5,2), tropeolin 00 (sariq→qizil), dimetilaminoazobenzol (qizil→sariq, pH 2,0–4,0), metilbinafsha (sariq→yashil, "
     "pH 1,5–3,2). Reaktivlar va nazorat musbat bermasligi kerak." + PRESUMPTIVE),
    # ------------------------------------------------------------------ carbamazepine (G.25), amitriptyline (G.23)
    ("C-ABY-CBZ-01", "substance", "carbamazepine", "tlc_system", "presumptive",
     loc("G", 25, "«Jarayonni olib borish», 1–4-bandlar va 1-jadval"),
     "Karbamazepin va metabolitlarini ajratish va TLC (ABY): qon 20 (10) ml — pH 9–10 gacha 30 % NaOH yoki pH 2–2,5 gacha 50 % "
     "oksalat kislota bilan, 2–3 marta 20 ml xloroformda 2–3 daqiqadan chayqatiladi; siydik 20 ml — pH 2–2,5 gacha 6 n HCl, 60 °C da "
     "30 daqiqa (gidroliz), sovitilib pH 8–9 gacha 50 % NaOH, 3 marta 20 ml xloroform. Qoldiq 1 ml xloroformda eritilib 1 µl "
     "«Sorbfil» plastinkaga, 2 sm yoniga standart (standart bo‘lmasa karbamazepin tabletkasidan taqqoslash eritmasi) tomiziladi; "
     "sistema dioksan–xloroform–aseton–25 % ammiak 47,5:45:5:2,5. Plastinka 254 (365) nm UB nurida, so‘ng Marki, yana UB va "
     "Dragendorf bilan ko‘riladi. Qon uchun (pH 2–2,5 va 8–9): UB da Rf 0,5 havo rang; Marki — Rf 0,5 va 0,3 da sariq; "
     "Markidan keyingi UB — Rf 0,7 havo rang, 0,5 va 0,3 yorqin sarg‘imtir-yashil; Dragendorf — Rf 0,5 va 0,3 zarg‘aldoq. "
     "Gidrolizlangan siydik qatorida ABY jadvali katakchalari chalkash, shu sabab qiymatlar keltirilmadi: manba tekshirilmoqda. "
     "ABYga ko‘ra o‘zgarmagan karbamazepin UB da havo rang va yashil, metabolit yashil va sarg‘imtir flyuoressensiya hamda Rf 0,2 "
     "da qo‘shimcha flyuoressensiya beradi; birinchi sutkada ko‘rinadigan havo rang flyuoressensiya 24 soatdan so‘ng yo‘qoladi, "
     "3-sutkada faqat yashil qoladi, metabolizmning oxirgi bosqichlarida Marki va Dragendorf dog‘lari bo‘lmasligi, ammo "
     "flyuoressensiya kuzatilishi mumkin. ABYdagi standart tayyorlash bandida karbamazepin o‘rniga «10 mg amitriptilin» deb yozilgan: "
     "manba tekshirilmoqda." + PRESUMPTIVE),
    ("C-ABY-CBZ-02", "substance", "carbamazepine", "metabolism_note", "framing",
     loc("G", 25, "«Tahlil. Izohlash. Hujjatlashtirish»"),
     "ABY farmakokinetikasi bo‘yicha karbamazepin ichga qabul qilinganda deyarli to‘liq so‘riladi, plazma oqsillari bilan 75 % "
     "bog‘lanadi; bir martalik dozadan so‘ng o‘zgarmagan moddaning cho‘qqi konsentratsiyasiga 4–10 soatda erishiladi, yarim "
     "chiqarilish davri 12–30 soat; jigar fermentlarining induktori sifatida o‘z metabolizmini tezlashtiradi; dozaning taxminan 70 % "
     "siydik bilan (nofaol metabolitlar ko‘rinishida), 30 % najas bilan chiqariladi. ABY sud-kimyoviy natijani toksikolog aniqlagan "
     "klinik ko‘rinish bilan birga sharhlash, biologik namunalarni o‘z vaqtida olish va tekshiruvda instrumental usullardan "
     "foydalanib metabolizmni hisobga olishni talab qiladi."),
    ("C-ABY-AMI-01", "substance", "amitriptyline", "tlc_system", "presumptive",
     loc("G", 23, "2-bo‘lim (ajratish va TLC), 1- va 1a-jadvallar"),
     "Amitriptilinni ajratish va TLC (ABY): 5 ml qon (amaliyotda 10 ml olish ehtimolni oshirishi qayd etilgan) yoki 50 ml siydik "
     "pH 9–10 gacha 30 % NaOH bilan ishqoriy qilinib, efir (xloroform) bilan 2–3 marta 20 ml dan ekstraksiya qilinadi. Ichki "
     "a’zolardan: 100 g material 200 ml suv va oksalat kislota bilan pH 2–3 gacha, 2 soat; so‘ng pH 10 gacha 25 % ammiak va "
     "xloroform (2–3 marta 15–20 ml), 10 daqiqa 3000 ayl/daq sentrifuga. TLC: A sistema benzol–aseton 80:20 (Rf 0,12), B sistema "
     "benzol–dioksan–25 % ammiak 60:35:5 (Rf 0,38), ketma-ket A va B (Rf 0,52); har bir nuqtaga kons. H₂SO₄ tomizilib 365 nm UB "
     "da qizg‘ish-jigarrang flyuoressensiya, Dragendorfda zarg‘aldoq rang. Boshqa sistemalar uchun ABYda Rf: aseton 0,15; metanol 0,27; "
     "xloroform–metanol 9:1 0,32; siklogeksan–toluol–dietilamin 15:3:2 0,5; metanol–ammiak 100:1,5 0,51 (qaysi plastinkada "
     "ekani yozilmagan). Standart eritma konsentratsiyasi ABYda ikki xil ko‘rsatilgan (0,01 % va 0,5 mg/ml): manba "
     "tekshirilmoqda." + PRESUMPTIVE),
    ("C-ABY-AMI-02", "substance", "amitriptyline", "reported_concentration", "framing",
     loc("G", 23, "3.1–3.2-bandlar"),
     "ABY amitriptilin haqida: narkotik, psixotrop va uyqu chaqiruvchi moddalar ta’sirini kuchaytiradi va uzaytiradi; "
     "organizmga tez so‘riladi, plazma oqsillari bilan 33–62 % bog‘lanadi, asosan jigarda metabolizmga uchraydi; qondagi "
     "terapevtik konsentratsiya 120–240 ng/ml; 7 kun ichida organizmdan to‘liq chiqadi; yarim chiqarilish davri 10–28 soat; "
     "toksik doza 1,5–2,5 mg/kg. O‘limga olib keluvchi doza ABYda «35/70 mg/kg» va «kattalar uchun 1,5 g dan ortiq» deb "
     "bir-biriga mos kelmaydigan ko‘rinishda yozilgan: qiymat keltirilmadi, manba tekshirilmoqda.",
     # Konsentratsiya yozuvi uchun majburiy kontekst (sxema qoidasi FE032/FE033):
     # qaysi namunada, qanday sharoitda va bu chegara EMASligi ochiq yoziladi.
     {
         "specimen": ["blood"],
         "context": "ABY: tirik odamda davolash maqsadida kutiladigan qon konsentratsiyasi; "
                    "o‘lim yoki mastlik chegarasi emas",
         "not_a_threshold": True,
         "context_strict": {
             "specimen": ["blood"],
             "sampling": "antemortem",
             "subject_state": "living",
             "population": "not_stated",
             "study_size": "not_stated",
             "case_type": "not_stated",
             "co_intoxicants": "not_stated",
             "analytical_method": "not_stated",
             "timing": "not_stated",
             "statistic": "not_stated",
             "reporting": "not_assessed",
             # Bo‘sh: bu ro‘yxat paketda inglizcha metama’lumot sifatida
             # ko‘rsatiladi, yozuvning o‘zi esa faqat o‘zbekcha. Cheklov
             # yozuvning matnida aytilgan («manba tekshirilmoqda»).
             "limitations": [],
             "curation": "auto_minimal",
         },
     }),
    # ================================================================== A: corpse examination
    ("C-ABY-SUP-01", "topic", "aby-fm-supravital", "application", "framing",
     loc("A", 17, "«Ko‘z rangdor pardasi mushaklarining kimyoviy moddalarga reaksiyasi»"),
     "Supravital reaksiyalar o‘lim vaqtini aniqlashda postmortal davrning dastlabki 20 soatiga qadar qo‘shimcha usul sifatida "
     "qo‘llanadi (ABY). Qorachiq reaksiyasi: qorachiq diametri o‘lchanadi; ingichka in’eksion igna shoxparda chetidan oldingi "
     "kameraga kiritilib, qorachiq o‘rtasiga yetgach 1 % pilokarpin gidroxloridning 0,1 ml i yuboriladi va sekundomerda "
     "qorachiq qisqarish davomiyligi o‘lchanadi; xuddi shunday atropin bilan kengayish baholanadi. Dastlabki 9–10 soatda "
     "qorachiq ikkala preparatga javob beradi, 9–10 soatdan keyin faqat bittasiga. K.I. Xijnyakov jadvali bo‘yicha "
     "maksimal qisqarish vaqti 3–5 s — o‘lim 5 soatgacha; 6–15 s — 10–14 soat; 20–30 s — 24 soatgacha; 60–120 s — 24 "
     "soatdan ko‘p. Atropinda qorachiq kengayishi 5–7 daqiqada kuzatiladi va 1,5 soatgacha turadi."),
    ("C-ABY-SUP-02", "topic", "aby-fm-supravital", "application", "framing",
     loc("A", 17, "mushaklarning mexanik va elektr ta’siriga reaksiyalari, ter bezlari reaksiyasi"),
     "Mushaklarning mexanik ta’siriga reaksiyasi (ABY): nevrologik bolg‘acha yoki shunga o‘xshash predmet bilan ko‘rsatilgan "
     "sohalarga urilganda dastlabki 2–3 soatda mushak qisqarishi (masalan, trapetsiyasimon mushak qisqarib kurakni umurtqa "
     "pog‘onasiga tortadi; son quyi uchligida tizza qopqog‘i tortiladi) kuzatiladi. Idiomuskulyar shish (Prokop sinamasi), "
     "V.V. Bilkun bo‘yicha yelkaning ikki boshli mushagida: tez paydo bo‘ladigan zich valik 1,5–2,0 sm — o‘lim 1–3 soat; "
     "1,0–1,5 sm — 3–6 soat; taxminan 0,5 sm yoki faqat paypaslab sezilsa — 6–9 soat; faqat chuqurlashish — 10 soatdan "
     "ko‘p. Qorachiqning elektr tokiga reaksiyasi (Bilkun): o‘lim 1–6 soatda qisqarish 1–2 s da boshlanib maksimal qisqarish "
     "7 s da; 7–12 soatda 4 s va 15 s; 13–18 soatda 9 s va 25 s; maksimal deformatsiya vaqti 18, 34, 44, 56 s (7–12, 13–18, "
     "19–24, 25–30 soat). Elektr manbaining ko‘rsatkichi ABYda «vatt» deb yozilgan (kuchlanish bo‘lishi kerak): qiymat "
     "keltirilmadi, manba tekshirilmoqda. Yuz mimik mushaklari reaksiyasi elektrodlar o‘rniga qarab o‘lim vaqtini 2–12 soat "
     "oralig‘ida bosqichlarga ajratadi. Ter bezlari reaksiyasi: soha spirtli yod bilan tozalanib, amifin aralash kastor moyi "
     "surtiladi, 1 ml 1 % adrenalin yoki pilokarpin teri ostiga yuboriladi; o‘lim 30 soatdan oshmagan bo‘lsa, 1–1,5 soatdan "
     "so‘ng ter ajraladi."),
    ("C-ABY-STR-01", "topic", "aby-fm-strangulation", "application", "framing",
     loc("A", 20, "tartib bandlari"),
     "Strangulyatsion egatni tavsiflash tartibi (ABY): egatning umumiy ko‘rinishi masshtabli suratga olinadi; bo‘yinda joylashuvi "
     "anatomik qismlarga nisbatan ko‘rsatiladi; yon tomonlarda egat yuqori qirrasidan so‘rg‘ichsimon o‘simta, quloq suprasi pastki "
     "uchi va jag‘ burchagigacha masofa o‘lchanadi; egat yo‘nalishi, soni, uchlari tutashgan-tutashmaganligi (tutashmasa uchlari "
     "orasidagi masofa) qayd etiladi; eni turli joylarda santimetrda, chuqurligi, rangi, konsistensiyasi, yuza relefi va "
     "hamma sohalarda bir xilligi yoziladi; egatning yuqori va quyi chegarasidagi shilinish, qizarish, qon quyilishlar, shuningdek "
     "uning yuzasi va atrofidagi ifloslanish, yot unsurlar tasvirlanadi. Hayotiylik sinamasi (Bokarius) va sud-gistologik "
     "tekshiruv uchun egat sohasidan teri bo‘lakchasi belgilangan tartibda olinadi."),
    ("C-ABY-STR-02", "topic", "aby-fm-strangulation", "application", "framing",
     locm("A", (21, "tartib bandlari"), (16, "tartib bandlari (E.S. Mishin, 1986)")),
     "Strangulyatsion asfiksiyada bo‘yin a’zolarini tekshirish (ABY). Egat yaqqol bo‘lsa, terida kesma o‘rta chiziq bo‘ylab iyak "
     "ostidan boshlanadi; egat juda sust bo‘lsa, bo‘yin quyi uchligida yoqasimon kesma o‘tkaziladi. Teri ajratilgach teri ostidagi "
     "yumshoq to‘qimalar qavatma-qavat kesilib, qon quyilish va ezilishlar qayd etiladi; limfa tugunlari, tashqi uyqu arteriyasi va "
     "venalar ko‘riladi; til osti suyagi va hiqildoq tog‘aylari paypaslanib butunligi aniqlanadi; umumiy/tashqi va ichki uyqu "
     "arteriyasi bo‘ylama kesilib intimasi ko‘riladi (yorilishlar — ABYda «Amyuss–Martin belgisi»); bo‘yin umurtqalari va "
     "bog‘lamlari tekshiriladi. Til osti kompleksi tibbiy-kriminalistik tekshiruvga, egat va yumshoq to‘qima bo‘lakchalari "
     "sud-gistologik tekshiruvga olinadi. Mishin usulida bo‘yin a’zolarini tekshirishdan oldin bosh miya ochilib, venoz "
     "tomirlar kesilib bo‘yin qon tomirlari qonsizlantiriladi, egat to‘liq tasvirlanadi, qalqonsimon bez, so‘lak bezlari, hiqildoq, "
     "traxeya, til osti suyagi va tomir-nerv tutamlari joyida tekshiriladi."),
    ("C-ABY-STR-03", "topic", "aby-fm-strangulation", "application", "framing",
     loc("A", 22, "tartib bandlari (N.S. Bokarius sinamasi)"),
     "Egat zararlanishining hayotiyligini aniqlash — Bokarius sinamasi (ABY): strangulyatsion egatdan uning zararlanmagan yuqori va "
     "pastki sohalarini ham qamrab oluvchi teri va teri osti to‘qimasi bo‘lakchasi kesib olinadi; teri osti yog‘i va yumshoq "
     "to‘qimadan to‘liq tozalanib, ikki yupqa tiniq predmet oynasi orasiga joylashtiriladi, oynalar barmoqlar bilan bosilgan "
     "holda nurga (lampa yoki quyosh) qaratib sinchiklab ko‘riladi. Kapillyarlarning kengayishi, ekstravazatlar mavjudligi va "
     "qon tomirlarning qonsizlanishi egat tirik paytda hosil bo‘lganini ko‘rsatadi. ABYda sinamaning ishonchlilik darajasi "
     "yozilmagan."),
    ("C-ABY-NB-01", "topic", "aby-fm-newborn", "application", "framing",
     loc("A", 29, "tartib bandlari (Galen–Shreyer sinamasi)"),
     "O‘pka suzish sinamasi (ABY): havo tutgan (nafas olgan) chaqaloq o‘pkasining solishtirma og‘irligi birdan past, shuning uchun "
     "suvda qalqib chiqadi; nafas olmagan o‘pka cho‘kadi. Tartib: ko‘krak qafasi ochilishidan oldin traxeya va qizilo‘ngachga "
     "ligatura qo‘yiladi, diafragma ustida qizilo‘ngachga ham; bo‘yin va ko‘krak a’zolari yaxlit suvli idishga botiriladi; so‘ng "
     "halqum–traxeya–o‘pka kompleksi alohida; keyin bronxlarga ligatura qo‘yilib o‘pkalar, har bir o‘pka, bo‘lagi va "
     "bo‘lakchalari navbat bilan alohida botiriladi, cho‘kish manfiy, qalqish ijobiy deb yoziladi. ABY ogohlantiradi: qalqish "
     "chirish gazlari tufayli bo‘lishi mumkin — bo‘lakcha barmoq bilan bosilib takroran botiriladi, chirish gazida natija "
     "manfiyga o‘tadi. Ijobiy natija sun’iy nafas berish, ikkilamchi atelektaz yoki murda muzlashi bilan ham bog‘liq bo‘lishi "
     "mumkin; buni sud-gistologik tekshiruv aniqlashtiradi."),
    ("C-ABY-NB-02", "topic", "aby-fm-newborn", "application", "framing",
     locm("A", (30, "tartib bandlari (Breslau sinamasi)"), (27, "tartib bandlari (Dillon sinamasi)")),
     "Oshqozon-ichak suzish sinamasi (Breslau, ABY): qorin a’zolarini ajratishdan oldin oshqozonning kirish va chiqish joyiga, "
     "ichakning to‘rt joyiga va to‘g‘ri ichak quyi uchligiga ligatura qo‘yiladi, ajratilgan oshqozon va ichaklar suvga botiriladi, "
     "natija o‘pka sinamasidek baholanadi. ABYga ko‘ra faqat oshqozonda havo bo‘lishi chaqaloq tirik tug‘ilib minutlar "
     "yashaganini, oshqozon va ingichka ichakda — taxminan 4–6 soat, oshqozon va ichakning barcha qismida — kamida 12 soat "
     "yashaganini ko‘rsatadi (chirish gazlari inkor etilganida). O‘pka–oshqozon rentgenologik sinamasi (Dillon, 1937 yil) "
     "tana bo‘shliqlari ochilmasdan ko‘krak qafasi va qorin bo‘shlig‘i rentgenografiyasi bilan o‘tkaziladi; ABYga ko‘ra usul "
     "o‘pka va oshqozonda juda oz (0,2 sm³) havoni aniqlashga imkon beradi, natijani rentgenolog baholaydi."),
    ("C-ABY-AUT-01", "topic", "aby-fm-autopsy-technique", "application", "framing",
     loc("A", 10, "tartib bandlari (Sunsov sinamasi)"),
     "Havo (gaz) emboliyasi sinamasi — Sunsov sinamasi (ABY): ichki tekshiruv ko‘krak-qorin bo‘shlig‘idan boshlanadi, teri kesmasi "
     "bo‘yindan emas, balki to‘sh suyagi dastasi sohasidan ochiladi; to‘sh suyagi ikkinchi qovurg‘a birikish joyidan, "
     "qovurg‘alarning tog‘ay qismi bilan birga ajratiladi, bunda yurak xaltasi, plevra va o‘pka shikastlanmasligi kerak; yurak xaltasi old yuzasida bo‘ylama "
     "kesilib, kesma uchlari tortib turiladi (yordamchi xodim); xalta bo‘shlig‘iga yurak to‘liq suv ostida qoladigan darajada suv "
     "to‘ldiriladi; suv ostida yurakning o‘ng bo‘shliqlariga, zarur bo‘lsa chap tomonga ham seksion pichoq uchi suqiladi. Sinama "
     "suvda pufakchalar paydo bo‘lish-bo‘lmasligiga qarab baholanadi."),
    ("C-ABY-AUT-02", "topic", "aby-fm-autopsy-technique", "application", "framing",
     loc("A", 19, "tartib bandlari"),
     "Murdada suyaklar sinishini tavsiflash (ABY): sinish sohasi yumshoq to‘qimadan to‘liq tozalanadi; joylashuvi anatomik "
     "tuzilishga ko‘ra aniq ko‘rsatiladi; turi (darz ketish, chiziqli, darchasimon, parchalangan va h.k.); yo‘nalishi (bo‘ylama, "
     "ko‘ndalang va h.k.); sinish yuzasi holati; chetlari konturi va suyak anatomik o‘qiga nisbati hamda xususiyatlari (mayda "
     "tishli, tekis, notekis); kompakt qavat zararlanishi va yoriq yo‘nalishlari, shakli, uzunligi; suyak parchalari joylashuvi, "
     "o‘lchami, shakli, soni va o‘zaro munosabati."),
    ("C-ABY-AUT-03", "topic", "aby-fm-autopsy-technique", "application", "framing",
     loc("A", 23, "tartib bandlari"),
     "Murdani topilgan joyida sirtdan ko‘zdan kechirish (ABY): hodisa joyi va murdani ko‘zdan kechirishni JPK talablariga binoan "
     "tergov organlari o‘tkazadi, jalb qilingan vrach-mutaxassis (sud-tibbiy ekspert) murdani sirtdan to‘liq ko‘rib chiqadi. "
     "Tartib: murda holatining ikkita qo‘zg‘almas ob’ektga nisbati va oralig‘i; atrofdagi ashyoviy dalillar; umumiy holat "
     "(yotgan, osilgan, o‘tirgan, bukchaygan); tana qismlarining holati; kiyimlarning holati, mosligi, tugmalari, dog‘lari, "
     "yirtiqlari va cho‘ntaklaridagi narsalar — bunda kiyimlar tanadan yechilmaydi; umumbiologik xususiyatlar (jinsi, yoshi, "
     "tana uzunligi, gavda tuzilishi); o‘limdan keyingi o‘zgarishlar va ularning dinamikasi; tashqi jarohatlar; shaxsi noma’lum "
     "murda topilganda ahamiyatli alohida belgilar. Hammasi ko‘zdan kechirish bayonida to‘liq aks ettiriladi."),
    # ================================================================== B: living persons
    ("C-ABY-LIV-01", "topic", "aby-fm-living-persons", "application", "framing",
     loc("B", 1, "tartib bandlari"),
     "Tirik shaxs ekspertizasi tartibi (ABY): qaror yoki ajrim bilan tanishib, maqsad va vazifalarga ko‘ra reja tuziladi; "
     "ekspertizadan o‘tayotgan shaxs hujjat asosida tasdiqlanadi (hujjat bo‘lmasa ekspertiza tayinlagan organ orqali); tibbiy "
     "yordam ko‘rsatilgan bo‘lsa tibbiy hujjatning asl nusxasi o‘rganiladi; voqea tafsiloti so‘raladi (voyaga yetmaganlarda ota-ona "
     "yoki qonuniy vakil, yoki pedagog ishtirokida); umumiy holat va jarohat sohalari tekshiriladi, o‘zgarishlar belgilangan "
     "tartibda tasvirlanadi; zarur bo‘lsa qon, surtma kabi qo‘shimcha material olinadi, ko‘rsatma bo‘lsa laborator, instrumental "
     "tekshiruvlarga va mutaxassislar ko‘rigiga yuboriladi."),
    ("C-ABY-LIV-02", "topic", "aby-fm-living-persons", "application", "framing",
     loc("B", 2, "tartib bandlari"),
     "Jarohat va uning izlarini tasvirlash (ABY): joylashuvi umumqabul qilingan ikki anatomik nuqta yoki chiziqqa nisbatan "
     "masofa bilan ko‘rsatiladi; turi (shilinma, qontalash, chandiq va h.k.); ajralmalar va xususiyatlari; shakli geometrik "
     "figuralarga mos; o‘lchamlari santimetr yoki millimetrda — uzunligi, eni, chuqurligi, do‘mpayishi; yuzasining relefi, "
     "chetlari va burchaklari, konturi, zichligi, rangi; bitishga xos belgilar va ularning dinamikasi; atrofdagi dog‘lar, "
     "ifloslanishlar, yot unsurlar. Jarohat va izi suratga olinadi, sxematik tasviri chiziladi."),
    ("C-ABY-LIV-03", "topic", "aby-fm-living-persons", "application", "framing",
     loc("B", 3, "tartib bandlari"),
     "Jinsiy yetuklikni aniqlash (ABY): zaruriyat 14–18 yosh oralig‘ida paydo bo‘ladi, chunki 14 yoshga yetmaganlar "
     "fiziologik jihatdan yetuk emas deb hisoblanadi, 18 yoshda esa nikoh yoshiga yetiladi. Tartib: ambulator va statsionar "
     "tibbiy hujjatlar, anamnez (qizlarda hayz sikli, o‘g‘illarda ereksiya, eyakulyatsiya); umumiy jismoniy rivojlanish va "
     "antropometriya (tik turganda bo‘y, o‘tirganda tana uzunligi, ko‘krak qafasi diametri tinch holatda, nafas olganda va "
     "chiqarganda, yelka va boldir aylanasi, qizlarda chanoq o‘lchamlari va tashqi konyugata); ikkilamchi jinsiy belgilar "
     "(qizlarda sut bezlari, so‘rg‘ich atrofi pigmentatsiyasi), tashqi jinsiy a’zolar va qov junlanishi; ichki jinsiy a’zolar "
     "UTT va urolog/bolalar ginekologi maslahati bilan baholanadi. ABY yetuk qizlarda bachadon tanasi umumiy uzunligining "
     "2/3 qismini, bo‘yni 1/3 ni tashkil etishi va bachadon bo‘yni silindrsimon bo‘lishi lozimligini yozadi."),
    # ================================================================== C: repeat / commission / complex
    ("C-ABY-COM-01", "topic", "aby-fm-repeat-commission", "application", "framing",
     loc("C", 1, "tartib bandlari"),
     "Takroriy, komission va kompleks ekspertizalar tartibi (ABY): qaror va unga ilova ob’ektlar qayd etiladi, to‘liqligi va "
     "yaroqliligi tekshiriladi; to‘liq yoki yaroqli bo‘lmasa, ekspertiza tayinlagan organga xabar berilib ijro to‘xtatiladi; "
     "ob’ektlar to‘liq bo‘lgach ekspertlar tarkibi shakllantiriladi, ish tafsiloti bayoni tuziladi, tegishli tekshiruvlar "
     "o‘tkaziladi, materiallar va natijalar ekspertlar komissiyasiga taqdim etiladi, muhokama o‘tkaziladi, xulosa loyihasi "
     "muhokama qilinib xulosa rasmiylashtiriladi. Takroriy ekspertiza ob’ektlari: ish materiallari, dastlabki va qo‘shimcha "
     "xulosalar, tibbiy hujjatlar, tirik shaxs, eksgumatsiya qilingan murda, olingan namunalar; kompleks ekspertizada "
     "gumon qilingan vosita, predmet, qurol ham qo‘shiladi."),
    ("C-ABY-COM-02", "topic", "aby-fm-repeat-commission", "application", "framing",
     loc("C", 4, "tartib bandlari"),
     "Tibbiy yordam ko‘rsatishdagi nuqsonlarni aniqlash (ABY): nuqsonning bosqichi; turi (profilaktik, tashkiliy, diagnostik, "
     "davolash, aralash va h.k.); nuqsonga olib kelgan shart-sharoit, jumladan tibbiyot xodimining harakati yoki "
     "harakatsizligi; ob’ektiv va sub’ektiv sabablar; mas’ul xodimning mutaxassisligi va lavozimi; amaldagi standart, klinik "
     "protokol yoki buyruq talablari bajarilmaganligi va sabablari; salbiy oqibatlar; nuqson bilan oqibat o‘rtasidagi "
     "bog‘liqlik (bevosita yoki bilvosita)."),
    # ================================================================== F: medical criminalistics
    ("C-ABY-CLO-01", "topic", "aby-fm-clothing-gunshot", "application", "framing",
     loc("F", 7, "4-bo‘lim «Amal»"),
     "Kiyimdagi jarohatlarni tavsiflash (ABY): quruq qon tufayli jarohat sohasi mato deformatsiyalangan bo‘lsa, shu soha suv "
     "bo‘yalmay qolguncha almashtirib turib suvga solinadi va quritiladi. Kiyim yuqoridan pastga, fasoni, mato rangi va turi, "
     "o‘lchamlari, uzunliklari, tugmalari o‘rni va soni, emblemasi bo‘yicha tavsiflanadi. Jarohatlar kiyim detallarining ikki nuqtasiga "
     "nisbatan to‘g‘ri burchakli koordinatalar sistemasida belgilanadi. Jarohat oxirlari va chetlaridagi shikastlangan iplar va "
     "tolalar xarakteri (ko‘ndalang chet, bo‘ylama chet, jarohat oxiridagi iplar) tavsiflanadi; kelgusi identifikatsion "
     "tekshiruvlar uchun mato strukturasi elementlarining metrik ma’lumotlari qayd etiladi; ip va tolalar jarohatlari shartli "
     "belgilar bilan «grafik modellashtirish» (I.B. Dmitriev usuli) modelida ko‘rsatiladi. Asbob: chizg‘ich, shtangensirkul, lupa, "
     "yon va o‘tuvchi yorug‘likli stereomikroskop."),
    ("C-ABY-CLO-02", "topic", "aby-fm-clothing-gunshot", "analytical_method", "presumptive",
     loc("F", 8, "2- va 4-bo‘limlar"),
     "O‘q-otar jarohat va elektrotamg‘alarni kontakt-diffuzion usulda tekshirish (ABY): fiksatsiyalangan, yuvilgan, quritilgan "
     "oddiy glyansli fotoqog‘oz erituvchi reaktivga shimdiriladi: ammiakning 12 % eritmasi (mis, nikel, kobalt), sirka "
     "kislotaning 25 % eritmasi (qo‘rg‘oshin, temir), 10 % eritmasi (alyuminiy), 1 % nitrat kislota (qo‘rg‘oshin); namoyon qiluvchi "
     "reaktivlar: rubean vodorod kislotaning to‘yingan eritmasi (mis, nikel, kobalt), natriy yoki kaliy rodizonatning 0,2 % li "
     "suvli eritmasi (qo‘rg‘oshin), α-nitrozo-β-naftol natriy ishqori bilan (temir, rux, qo‘rg‘oshin, mis), morinning metanoldagi "
     "to‘yingan eritmasi (alyuminiy). Qog‘oz ob’ekt ustiga qo‘yilib, ko‘p qavatli paket 1 kg/sm² gacha bosim ostida 5–10 daqiqa "
     "ushlanadi; ortiqcha bosim metall izlarini tarqatib, masalan, surtilish gardishini yaqin masofadan otish belgisi qilib "
     "ko‘rsatib yuborishi mumkin. Kontaktdan keyin qog‘ozga namoyon qiluvchi reaktiv tomiziladi; tamg‘a 10–30 sekundda bo‘yaladi, "
     "distillangan suv bilan yuviladi. Nazorat: shu qutidagi fotoqog‘ozning iz tushirilmagan bo‘lagi, namoyon qiluvchi "
     "reaktivning o‘zi va ma’lum metall (mis, qo‘rg‘oshin) izi bilan." + PRESUMPTIVE),
    ("C-ABY-MCL-01", "topic", "aby-fm-medcrim-lab", "application", "framing",
     loc("F", 1, "5-bo‘lim «Amal»"),
     "Tibbiy-kriminalistika bo‘limiga ashyoviy dalillarni qabul qilish (ABY): ekspertiza sud-tergov idorasining qarori "
     "yoki ajrimi bilan, tekshiruv esa markazning boshqa bo‘linmasidagi ekspert yo‘llanmasi bilan boshlanadi. Dalillar bo‘lim mudiri "
     "yoki uning ko‘rsatmasi bilan ekspert tomonidan o‘ramning holati, imzo, muhr, shtamplari qayd etilib, maxsus jurnalga yoziladi; "
     "dalillar faqat o‘ralgan va muhrlangan holda qabul qilinadi; o‘rash materiali — qog‘oz, karton quti, yog‘och yashik, "
     "polietilen paket taqiqlanadi. Chirigan murdadan olingan bo‘yin a’zolari kompleksi 10–12 % neytral formalinda zich "
     "yopilgan, muhrlangan idishda keltiriladi; idish yorlig‘ida murda F.I.Sh., tug‘ilgan yili, ekspert xulosasi raqami, "
     "tekshiruv sanasi va ekspert F.I.Sh. bo‘lishi kerak. Ilova hujjatlar: ekspertiza tayinlash qarori, ko‘zdan kechirish "
     "bayonnomasi, dalillarni olish bayonnomasi, takroriy ekspertizada dastlabki xulosa va ish daftari. O‘ram yoki hujjatlarda "
     "nuqson bo‘lsa, uch xodim imzosi bilan ikki nusxada dalolatnoma tuziladi; rad etish asoslari: o‘ram yo‘qligi yoki "
     "butunligi buzilganligi, yo‘llanma hujjatlar yo‘qligi, dalil yaroqsizligi (ho‘l, chiriy boshlagan, jarohat butunligi buzilgan)."),
    ("C-ABY-MCL-02", "topic", "aby-fm-medcrim-lab", "application", "framing",
     loc("F", 2, "5-bo‘lim «Amal», 6-band"),
     "Tibbiy-kriminalistika bo‘limida saqlash (ABY): hujjatlar alohida papkada seyf yoki qulflanadigan metall shkafda, ish vaqti "
     "tugagach bo‘lim muhri bilan muhrlanadi (har bir ekspertga alohida shkaf); sovuq va o‘q-otar qurollar, o‘q-dorilar "
     "signalizatsiyali xonada muhrlanadigan seyfda. Tekshiruvdan keyin dalillar buyurtmachiga tilxat bilan qaytariladi; RIAMSTE va "
     "filiali yo‘llanmasi bilan tekshirilgan ob’ektlar bo‘lim arxivida 3 yil saqlanadi (ochilmagan jinoyatlarda idoraning yozma "
     "talabiga ko‘ra uzaytirilishi mumkin). Saqlash muddatlari: ekspert xulosasi, sud-tibbiy tekshiruv dalolatnomasi, "
     "laboratoriya va mutaxassis maslahatiga yo‘llanma dalolatnomasi — 25 yil; ashyoviy dalillarni ro‘yxatga olish jurnali — "
     "10 yil; fotosuratlar — 10 yil. Muddati o‘tgan arxiv ob’ektlari Markaz direktori ruxsati bilan komissiya dalolatnomasi "
     "asosida yo‘q qilinadi (ko‘miladi)."),
    ("C-ABY-PRP-01", "topic", "aby-fm-medcrim-lab", "sample_preparation", "framing",
     loc("F", 4, "4-bo‘lim «Amal»"),
     "Suyak qoldiqlarini tekshiruvga tayyorlash (ABY), maqsadga qarab: (a) yumshoq to‘qimalar o‘ta chiriganda suyaklar oqar suvda "
     "yuviladi, qoldiq mexanik olib tashlanadi, xona haroratida quritiladi; (b) jarohatlarni tekshirish uchun yumshoq to‘qima "
     "chirimagan yoki oz chirigan bo‘lsa, suyaklar kir yuvish kukunining iliq suvdagi konsentrlangan eritmasida 24 soat saqlanib, "
     "mexanik tozalanadi, yuvilib quritiladi; (v) shaxs identifikatsiyasi (jins, yosh, bo‘y, irq) uchun suyaklar 10 l idishda "
     "qaynoq suv bilan yumshoq to‘qima yumshab ajralgunga qadar ishlanadi, so‘ng tozalanib quritiladi; (g) kerak bo‘lsa "
     "(qovurg‘alar) yog‘sizlantirish uchun 96 % etanol bilan efir yoki aseton–etanol (1:1) aralashmasida 1–1,5 soat "
     "saqlanadi."),
    ("C-ABY-PRP-02", "topic", "aby-fm-medcrim-lab", "sample_preparation", "framing",
     loc("F", 5, "3- va 4-bo‘limlar"),
     "Teri laxtagini tekshiruvga tayyorlash (ABY, Ratnevskiy eritmalari): 1-raqamli eritma — 10 ml kons. sirka kislota, 20 ml "
     "etanol va distillangan suv bilan 100 ml gacha. Teri osti yog‘i mexanik olib tashlanadi, laxtak quritilib 3–5 sutka "
     "1-raqamli eritmada ushlanadi, oqar suvda yuviladi va quritiladi. Chirigan (qorayib ketgan) laxtakda 2-raqamli eritma "
     "qo‘llanadi: 100 ml 1-raqamli eritmaga 10 ml pergidrol qo‘shiladi, laxtak oqarguncha 7–12 kun saqlanadi, yuvilib yana "
     "1-raqamli eritmaga o‘tkaziladi (pergidrol teri to‘qimasining parchalanishiga olib kelishini ABY qayd etadi)."),
    ("C-ABY-PRP-03", "topic", "aby-fm-medcrim-lab", "sample_preparation", "framing",
     loc("F", 6, "4-bo‘lim «Amal»"),
     "Bo‘yin organokompleksini tekshiruvga tayyorlash (ABY): rentgenologik tekshiruvdan keyin yumshoq to‘qimalarni olish "
     "osonlashishi uchun kompleks 10–12 % formalinda 24 soat saqlanadi, so‘ng yumshoq to‘qimalar mexanik tozalanadi; til osti "
     "suyagi, qalqonsimon va uzuksimon tog‘aylar iliq suvda yuvilib, sinish yuzalaridagi qon iviqlari yumshoq cho‘tka bilan "
     "tozalanadi, quritilib tekshiriladi. Yumshoq to‘qima yo‘q bo‘lsa (qayta tekshiruv), til osti suyagi va hiqildoq tog‘aylari "
     "tog‘ay to‘qimasi to‘liq tiklangunga qadar suvda ushlab turiladi."),
    ("C-ABY-SEX-01", "topic", "aby-fm-bone-sex", "application", "framing",
     loc("F", 9, "3-bo‘lim «Amal»"),
     "To‘sh suyagi bo‘yicha jinsni aniqlash (ABY, Dyurvald, 1960): o‘rta chiziq bo‘ylab xanjarsimon o‘siqsiz umumiy uzunlik, 2- va "
     "3-qovurg‘a o‘yig‘i orasidagi kenglik, 3- va 4-qovurg‘a o‘yig‘i orasidagi kenglik, dastaning eng kichik qalinligi va birinchi "
     "segmentda 2- va 3-qovurg‘a o‘yig‘i orasidagi tana qalinligi o‘lchanib, besh o‘lcham yig‘indisi olinadi. Yig‘indi 226–262 "
     "mm bo‘lsa erkak skeletiga, 192–223 mm bo‘lsa ayol skeletiga mansub. 224–225 mm oralig‘i ABYda ko‘rsatilmagan: manba "
     "tekshirilmoqda."),
    ("C-ABY-SEX-02", "topic", "aby-fm-bone-sex", "application", "framing",
     loc("F", 10, "3-bo‘lim «Amal»"),
     "O‘mrov suyagi bo‘yicha jinsni aniqlash (ABY, Z.L. Laptev, 1975): diafiz kengligi, egrilik kattaligi, yelka tomoni oxiri kengligi va "
     "umumiy uzunlik qo‘shilib jins ko‘rsatkichi (JK) olinadi; o‘ng va chap suyak alohida baholanadi. O‘ng suyakda JK 206 mm "
     "va undan kam — ayol; 207–216 mm — ikkala jinsda uchraydi. Chap suyakda JK 212 mm dan oshmasa — ayol, 218 mm va undan "
     "ko‘p — erkak, 212–217 mm — ikkala jinsda (chegaraviy 212 qiymati ABYda ikki joyda keltirilgan). O‘ng suyak uchun erkaklik "
     "chegarasi «261 mm va undan ko‘p» deb yozilgan, biroq shu amaliyotda o‘ng suyak JK oralig‘i 178–261 mm deb berilgan va "
     "217–260 mm oralig‘i izohlanmagan: manba tekshirilmoqda."),
    ("C-ABY-SEX-03", "topic", "aby-fm-bone-sex", "application", "framing",
     locm("F", (11, "3-bo‘lim «Amal», jadval"), (12, "3-bo‘lim")),
     "Kurak suyagi bo‘yicha jinsni aniqlash (ABY, L.A. Koshelev, 1971): 11 ta o‘lcham (balandlik, kenglik, lateral va yuqori chekka "
     "uzunligi, qirra usti va osti chuqurchalari kengligi, qirra, yelka o‘sig‘i, tumshuqsimon o‘siq, bo‘g‘im chuqurchasi o‘lchamlari) "
     "jadvaldagi erkak/ayol uchun «ishonchli», «ehtimoliy» va «noaniq» intervallar bilan solishtiriladi (masalan, balandlik 168 mm dan "
     "ko‘p — erkak uchun ishonchli; 139 dan kam — ayol uchun ishonchli). Baholash: 11 tadan hatto 1 ta ishonchli ko‘rsatkich "
     "bo‘lsa jins haqida aniq xulosa; ishonchli yo‘q, ammo 4 yoki undan ko‘p ehtimoliy belgi bo‘lsa — ehtimol shaklidagi xulosa; "
     "4 tadan kam ehtimoliy va qolgani noaniq bo‘lsa — jinsni aniqlash imkoni yo‘q. Son suyagi (Pirson va Bell) uchun ABY o‘siqlar "
     "kengligi (erkak 80,1; ayol 70,1), boshcha vertikal diametri (47,1; 41,1) va bo‘yincha vertikal diametri (33,8; 29,4) o‘rtacha "
     "qiymatlarini keltiradi, lekin birligi va «natijalarni baholash» bandi matnda bo‘sh: baholash mezoni ABYda yozilmagan, "
     "manba tekshirilmoqda."),
    ("C-ABY-SEX-04", "topic", "aby-fm-bone-sex", "application", "framing",
     loc("F", 14, "3-bo‘lim «Amal»"),
     "Tos suyaklari bo‘yicha jinsni aniqlash (ABY, K. Garmus, 1991): tos tuzilishidagi 20 ta sifat belgisi (kichik tosga kirish "
     "konturi, qov burchagi, qov do‘ngligi, chanoq teshigi shakli, o‘tirg‘ich o‘sig‘i, quloq suprasi oldi egati, dumg‘aza "
     "belgilari va h.k.) jadvalda erkak/ayol uchun baholanadi, belgilar nisbatidan jins dimorfizmining diagnostik koeffitsienti "
     "DK = 100·lg(E/A) hisoblanadi. Erkak jins — DK +29,96 va undan ortiq; ayol jins — DK −5,05 va undan kam; oraliq — jins "
     "aniqlanmagan. E va A qiymatlarini belgilar bo‘yicha qanday yig‘ish ABYda ko‘rsatilmagan: manba tekshirilmoqda."),
    ("C-ABY-SEX-05", "topic", "aby-fm-bone-sex", "application", "framing",
     loc("F", 16, "3-bo‘lim «Amal», 3.2–3.3-bandlar (V.N. Zvyagin)"),
     "Bosh suyaklari bo‘yicha jinsni aniqlash (ABY, V.N. Zvyagin, 1984): bosh suyagining 40 ta asosiy sifat belgisi (peshona, "
     "tepa, ensa, asosiy, chakka suyaklari, yuz va pastki jag‘ belgilari) erkak/ayol uchun «+» va «−» bilan baholanadi; katta "
     "yoshdagilar uchun DK = 100·lg(M/J) hisoblanadi. Jins DK bo‘yicha: ayol — −20,681 va kam; aniqlanmagan — −20,682 dan "
     "+26,552 gacha; erkak — +26,553 va ko‘p. Formuladagi M va J belgilari ABYda izohlanmagan: manba tekshirilmoqda."),
    ("C-ABY-AGE-01", "topic", "aby-fm-bone-age", "application", "framing",
     locm("F", (17, "3-bo‘lim (M.M. Gerasimov, 1955)"), (22, "3-bo‘lim")),
     "Tishlar bo‘yicha yosh (ABY). Yuqori jag‘ tishlarining yeyilishi (Gerasimov) 0–6 balli shkalada baholanadi (0 — yeyilish yo‘q, "
     "1 — faqat emal, 2 — do‘ngliklar, 3 — dentin, 4 — tish kanali, 5 — toj qismigacha, 6 — toj to‘liq yeyilgan); jadvalda "
     "yoshga ko‘ra: 10–13 yoshda yeyilish boshlanmagan; 18–20 yoshda kesuvchilar 2–3, qoziq 2, kichik oziq 2, birinchi katta oziq 2, "
     "ikkinchi katta oziq 1; 60–70 yoshda mos ravishda 5–6, 5, 5–6, 5–6, 6. ABY jadvalida 40–45 yosh qatori yo‘q. Tish ildizi "
     "tiniqligi bo‘yicha (D. Krause va boshq., 1979): Y = 24,0 + 6,2·X ± 12,0 yil, bunda Y — yosh, X — ildiz tiniqligi (mm); "
     "hisob har bir tish uchun bajarilib, o‘rtacha arifmetik olinadi."),
    ("C-ABY-AGE-02", "topic", "aby-fm-bone-age", "application", "framing",
     locm("F", (18, "3-bo‘lim (Hansen jadvali)"), (19, "3-bo‘lim (Hansen jadvali)")),
     "Yelka va son suyagi proksimal uchi bo‘yicha yosh (ABY, Hansen, 1953–1954): suyak proksimal qismi frontal yo‘nalishda "
     "arralanib, epifizar chiziq, kompakt va g‘ovak qavatlar, to‘sin tizimi baholanadi; suyak ko‘migi bo‘shlig‘i yuqori chegarasigacha "
     "masofa shtangensirkulda (mm) o‘lchanib, jadval bilan solishtiriladi. Yelka suyagida (epifiz yuqori nuqtasidan ko‘mik "
     "bo‘shlig‘igacha) erkaklarda 10–19 yoshda 60–85 mm (o‘rtacha 71,0), 70 yosh va undan katta 17–35 mm (o‘rtacha 23,0); "
     "ayollarda 10–19 yoshda 60 mm (o‘rtacha 60,0), 70 dan katta 14–30 mm (21,7). Son suyagida (ko‘mik bo‘shlig‘idan katta "
     "ko‘st yuqori chekkasigacha) erkaklarda 10–19 yoshda 70–85 mm (75,0), 70 dan katta 55–65 mm (59,6); ayollarda 60–70 mm "
     "(65,0) va 50–60 mm (54,5). Masofa yosh ortishi bilan kamayadi; oraliq yosh guruhlari ABY jadvalida."),
    ("C-ABY-AGE-03", "topic", "aby-fm-bone-age", "application", "framing",
     loc("F", 20, "3-bo‘lim (V.N. Zvyagin, 1983)"),
     "Bolalar bosh suyagi qalinligi bo‘yicha yosh (ABY): choklar bo‘ylab markerda 6 ta doimiy nuqta belgilanadi — A (peshona "
     "suyagi o‘ng toj chokining o‘rta qismi), B (chakka suyagi o‘ng toj chokining o‘rta qismi), V (o‘ng tepa suyagi o‘qsimon chok, "
     "bregma va cho‘qqi o‘rtasi), G (o‘qsimon chok, obelion va orqa qism o‘rtasi), D (tepa suyagi o‘ng ensa choki o‘rta qismi), "
     "Ye (ensa suyagi o‘ng ensa choki o‘rta qismi); shu nuqtalarda bormashina bilan teshik ochib suyak qalinligi o‘lchanadi va "
     "F6 = −16,619 + 1,5·A + 1,4·B + 1,3·V + 1,0·G + 0,7·D + 0,5·Ye formulasi bo‘yicha yosh hisoblanadi (ABYda xato oralig‘i "
     "«±3» deb yozilgan; qalinlik birligi ko‘rsatilmagan: manba tekshirilmoqda)."),
    ("C-ABY-AGE-04", "topic", "aby-fm-bone-age", "application", "framing",
     loc("F", 21, "3-bo‘lim (A.K. Garmus, 1988)"),
     "Qov birikmasi bo‘yicha yosh (ABY): simfizdagi yosh o‘zgarishlari 5 guruh bo‘yicha ballanadi — A (bo‘g‘im yuzasi, 1–7 ball: "
     "chuqur gorizontal chiziqlardan eroziya va ekzostozlargacha), B (old qirra, 1–7), C (orqa qirra, 1–5), D (yuqori oxir, "
     "1–5), E (pastki oxir, 1–5); o‘ng va chap qov suyagi jadvalga yoziladi. Ballar regressiya formulalariga qo‘yiladi (o‘ng, "
     "chap va umumiy). ABYda formulalardagi belgilar bir-biriga mos emas (umumiy formulada RA, RB, LB, LD, LE aralash) va natijalarni "
     "qo‘shish tartibi tushunarsiz: koeffitsientlar keltirilmadi, manba tekshirilmoqda."),
    ("C-ABY-AGE-05", "topic", "aby-fm-bone-age", "application", "framing",
     loc("F", 23, "3-bo‘lim (V.N. Zvyagin, 1975)"),
     "Bosh suyagi choklarining bitishi bo‘yicha yosh (ABY): avval bosh suyagi jinsi va shakli (dolixokran, mezokran, braxikran; "
     "ko‘ndalang o‘lcham·100 / bo‘ylama o‘lcham) aniqlanadi; gumbaz choklari 16 qismga bo‘linadi (toj — 6, o‘qsimon — 4, ensa — 6); "
     "har qismda obliteratsiya darajasi 5 balli shkala bilan baholanadi (1 — chok butun uzunlikda ochiq … 5 — to‘liq "
     "bitishgan); tashqi va ichki tomondan baholanadi. Ballarning o‘rtachasi erkaklar va ayollar uchun alohida ko‘p regressiyali "
     "formulalarga (har jins uchun 4 ta) qo‘yiladi; ABYda formulalarning xato oralig‘i erkaklar uchun ±8,36 dan ±9,75 gacha, "
     "ayollar uchun ±8,61 dan ±8,73 yilgacha. Formuladagi ayrim belgilar ABYda chalkash yozilgan: koeffitsientlar keltirilmadi, "
     "manba tekshirilmoqda."),
    ("C-ABY-AGE-06", "topic", "aby-fm-bone-age", "application", "framing",
     loc("F", 47, "«Natijalarni baholash», to‘sh suyagi va yelka kamari bo‘limlari"),
     "To‘sh suyagi va yelka kamarining yoshga xos rentgenologik o‘zgarishlari (ABY). To‘sh suyagi: suyaklanish homila "
     "ichi rivojlanishining 5–6 oyidan boshlanadi; yangi tug‘ilganda 4 tadan 13 tagacha suyaklanish markazi (1–2 tasi dastada); "
     "markazlar sinostozi 1 oydan boshlanib 6 yoshda tugaydi; 10 yoshda barcha markazlar birlashgan; segmentlar sinostozi 14–18 "
     "yoshda, tana markazlarining sinostozi 18–20 yoshda (xanjarsimon o‘siq shu davrda suyaklanadi); tana segmentlari "
     "birlashuvi rentgenogrammada erkaklarda 29 yoshgacha, ayollarda 35 yoshgacha aniqlanadi; dasta va xanjarsimon o‘siq "
     "tana bilan 25–30 yoshdan keyin sinostozlanadi, tananing xanjarsimon o‘siq bilan to‘liq sinostozi 50 yoshda. Yelka "
     "kamari: pasport yoshi bilan mahalliy suyak yoshining mosligi ABYga ko‘ra faqat ikki yoshda ishonchli — 1 yoshda yelka "
     "suyagi boshchasining suyaklanish yadrosi, 4 yoshda o‘mrov suyagi to‘sh oxirining suyaklanish markazlari bo‘yicha; "
     "yelka suyagi boshchasining epifiz bilan to‘liq sinostozi 18 yoshda."),
    ("C-ABY-STA-01", "topic", "aby-fm-bone-stature", "application", "framing",
     loc("F", 24, "3-bo‘lim (Manuvrie, 1892)"),
     "Naysimon suyaklar bo‘yicha bo‘y (Manuvrie, ABY): suyak uzunligi (mm) santimetrli lenta va Brok taxtachasida o‘lchanib, "
     "erkaklar va ayollar uchun alohida jadvaldan (son, katta va kichik boldir, yelka, bilak, tirsak suyaklari) murda bo‘yi (sm) "
     "topiladi. ABY izohi: tirik shaxsning bo‘yini aniqlash uchun jadvalda topilgan tana uzunligidan 2 sm ayriladi. "
     "Jadvaldagi bitta qatorda xato bor ko‘rinadi (erkaklar, bo‘y 178,5 sm qatorida tirsak suyagi 278 mm — oldingi qatordan "
     "kichik): manba tekshirilmoqda."),
    ("C-ABY-STA-02", "topic", "aby-fm-bone-stature", "application", "framing",
     loc("F", 25, "3-bo‘lim (Pirson, 1889)"),
     "Pirson formulalari bo‘yicha bo‘y (ABY), yangi suyaklar uchun, S — bo‘y, F — son, H — yelka, T — katta boldir, R — bilak "
     "suyagi uzunligi. Erkaklar: S = 81,231 + 1,880·F; S = 70,714 + 2,894·H; S = 78,807 + 2,376·T; S = 86,465 + 3,271·R. Ayollar: "
     "S = 73,163 + 1,945·F; S = 72,046 + 2,754·H; S = 75,369 + 2,352·T; S = 82,189 + 3,343·R. ABY ko‘p suyakli formulalarni "
     "ham keltiradi (masalan, erkaklar: S = 71,164 + 1,159·(F + T)). Tuzatishlar: son suyagi tabiiy holatda o‘lchansa, bo‘yga "
     "erkaklarda 0,32 sm, ayollarda 0,33 sm qo‘shiladi; katta boldir suyagi do‘nglararo tepacha bilan o‘lchansa, uzunlikdan "
     "erkaklarda 0,95 sm, ayollarda 0,87 sm ayriladi; suyaklar tegishli tirik odamning bo‘yi uchun formula natijasidan "
     "erkaklarda 1,26 sm, ayollarda 2 sm ayriladi. Quruq suyaklar uchun ABY alohida koeffitsientlar beradi, ammo uning "
     "ro‘yxatida bir necha satrda belgi xatolari bor (masalan, yelka formulasida «F»): bu satrlar keltirilmadi, manba "
     "tekshirilmoqda."),
    ("C-ABY-STA-03", "topic", "aby-fm-bone-stature", "application", "framing",
     loc("F", 26, "3-bo‘lim va izoh (Rolle, 1888)"),
     "Rolle usuli bo‘yicha bo‘y (ABY): suyak uzunligi (mm) jadvaldagi erkaklar yoki ayollar qatoriga mos bo‘y (sm) bilan "
     "solishtiriladi (erkaklar jadvali 152–180 sm, ayollar 140–172 sm). Jadval yangi suyaklarga tegishli bo‘lgani uchun quruq "
     "suyak ekspertizasida har bir suyak uzunligiga 2 mm qo‘shiladi. Suyak o‘lchami jadvalda yo‘q bo‘lsa, Rolle L·H/B nisbatidan "
     "foydalanishni tavsiya etadi (L — o‘lchangan suyak uzunligi, B — jadvaldagi suyak uzunligi, H — unga mos jadvaldagi bo‘y)."),
    ("C-ABY-ID-01", "topic", "aby-fm-photo-identification", "application", "framing",
     locm("F", (27, "3-bo‘lim (AGI-1)"), (28, "3-bo‘lim (AGI-4)")),
     "Grafik identifikatsion algoritm (AGI, Elbur R.E., 1965) bo‘yicha noma’lum murda bosh suyagi (pastki jag‘i bilan) va "
     "bedarak yo‘qolgan shaxsning hayotlikdagi surati solishtiriladi (ABY). Avval suratning rakursi aniqlanib, suyak shunga mos "
     "joylashtiriladi; yuz va bosh suyagida 11 tadan mos doimiy nuqta belgilanadi (ko‘z burchaklari, qanshar usti, burun "
     "to‘sig‘i asosi, og‘iz burchaklari va hosil qilingan yordamchi nuqtalar). Vertikal o‘q chiziqlari parallel qilib "
     "varaqqa yopishtirilgan rasmlardan bir xil nuqtalar orqali to‘g‘ri chiziqlar o‘tkaziladi. Nuqtalar kesishmasi masofasi "
     "chizma ko‘lamining 10 % idan kam bo‘lsa — aynanlik natijasi ijobiy; 11–20 % — noma’lum; 21 % dan ko‘p — salbiy "
     "(ABYdagi chegaralar shunday yozilgan; 10–11 va 20–21 % oraliqlari alohida ko‘rsatilmagan). AGI-4 yuqori (1, 11, 2, 5, 3, 4) "
     "va pastki (8, 6, 10, 7, 9) nuqtalar uchun alohida baholaydi va koordinata sistemasida siniq chiziqli yoyilma "
     "tuzadi; ABYda AGI-4 uchun manba sifatida AGI-1 ko‘rsatilgan."),
]
