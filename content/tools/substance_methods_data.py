"""Substance-level method entries (facts, each with a source and an exact locator).

Rules for this file (owner decision 2026-10-10):
* only sources we may legitimately use: UNODC ST/NAR/13/Rev.1, SWGDRUG v8.2, the
  teacher's books (written permission, docs/DECISIONS.md), the owner's reagent
  compilation; nothing from any restricted/closed material;
* every entry has a concrete locator — otherwise it is not added;
* no value is invented: Rf only where the source prints it together with the
  exact system; colours/maxima exactly as printed (internal contradictions of a
  source are stated, not silently resolved);
* presumptive methods are never presented as confirmatory.
The text of each entry is rendered in uz/ru/en from sm_vocab.py (numbers, units and
formulas identical by construction).
"""
from sm_core import N, colour, generic, loc, micro, tlc, tlc_free, uv

E = []  # all entries
add = E.append

UNODC_REM = N(
    "The source adds that similar or other colours may occur with other controlled and non-controlled drugs or precursors.",
    "Manba qo‘shimcha qiladi: boshqa nazorat ostidagi va nazoratsiz moddalar yoki prekursorlar ham o‘xshash yoki boshqa rang berishi mumkin.",
    "Источник добавляет: другие контролируемые и неконтролируемые вещества или прекурсоры могут давать сходную или иную окраску.",
)
TOGETHER = N(
    "The source gives this result for morphine, codeine and heroin together; the test does not tell them apart.",
    "Manba bu natijani morfin, kodein va geroin uchun birgalikda keltiradi; sinama ularni bir-biridan ajratmaydi.",
    "Источник приводит этот результат для морфина, кодеина и героина вместе; реакция их не различает.",
)
SECOND_ONLY = N(
    "The source says this reagent is a differentiating test that is not used alone but as a secondary test after the Marquis test.",
    "Manba bu reaktivni farqlovchi sinama deb ataydi: u yolg‘iz ishlatilmaydi, Marki sinamasidan keyin ikkilamchi sinama sifatida qo‘llaniladi.",
    "Источник называет этот реактив дифференцирующей пробой: его не используют отдельно, а только как вторичную пробу после реакции Марки.",
)

OPI = ["morphine", "codeine", "heroin"]

# =============================================================== OPIOIDS
add(colour(OPI, "marquis", ["violet", "reddish-purple"], "UNODC", loc("UNODC", printed=38), rng=True,
           note=N(TOGETHER[0] + " " + UNODC_REM[0], TOGETHER[1] + " " + UNODC_REM[1], TOGETHER[2] + " " + UNODC_REM[2])))
add(colour(OPI, "mecke", ["blue", "green"], "UNODC", loc("UNODC", printed=39), rng=True,
           note=N(TOGETHER[0] + " " + UNODC_REM[0], TOGETHER[1] + " " + UNODC_REM[1], TOGETHER[2] + " " + UNODC_REM[2])))
add(colour("heroin", "nitric", ["yellow", "light-green"], "UNODC", loc("UNODC", printed=39, to=40), timing="slow",
           note=N(SECOND_ONLY[0] + " " + UNODC_REM[0], SECOND_ONLY[1] + " " + UNODC_REM[1], SECOND_ONLY[2] + " " + UNODC_REM[2])))
add(colour("morphine", "nitric", ["orange", "red", "yellow"], "UNODC", loc("UNODC", printed=39, to=40),
           timing="rapid_then_slow",
           note=N("Colour sequence: orange, rapidly red, then slowly yellow. " + SECOND_ONLY[0] + " " + UNODC_REM[0],
                  "Rang ketma-ketligi: zarg‘aldoq, tez qizil, so‘ng sekin sariq. " + SECOND_ONLY[1] + " " + UNODC_REM[1],
                  "Последовательность цветов: оранжевый, быстро красный, затем медленно жёлтый. " + SECOND_ONLY[2] + " " + UNODC_REM[2])))
add(colour("codeine", "nitric", ["orange", "yellow"], "UNODC", loc("UNODC", printed=39, to=40), timing="slow",
           note=N(SECOND_ONLY[0] + " " + UNODC_REM[0], SECOND_ONLY[1] + " " + UNODC_REM[1], SECOND_ONLY[2] + " " + UNODC_REM[2])))
add(colour("morphine", "fe2so43", ["red"], "UNODC", loc("UNODC", printed=40), note=UNODC_REM))
add(colour("morphine", ["marquis", "frohde", "mandelin", "erdmann"], ["violet"], "GMT", loc("GMT", pdf=24),
           note=N("The source states this for morphine or other opium alkaloids; the colour reagents are not specific to morphine.",
                  "Manba buni morfin yoki boshqa opiy alkaloidlari uchun keltiradi; rang hosil qiluvchi reaktivlar morfinga xos emas.",
                  "Источник приводит это для морфина или других алкалоидов опия; цветные реактивы не специфичны для морфина.")))
add(colour("morphine", "fecl3", ["blue"], "GMT", loc("GMT", pdf=24),
           note=N("The source notes that this reaction is less sensitive than the colour reagents but separates morphine from codeine, heroin and dionine, because it needs the free phenolic hydroxyl.",
                  "Manba bu reaksiya rang hosil qiluvchi reaktivlarga qaraganda kam sezgirligini, lekin erkin fenol gidroksili talab qilgani uchun morfinni kodein, geroin va dioninidan ajratishini ta’kidlaydi.",
                  "Источник отмечает, что реакция менее чувствительна, чем цветные реактивы, но отличает морфин от кодеина, героина и дионина, так как требует свободного фенольного гидроксила.")))
add(colour("codeine", ["fecl3", "k3fe"], ["colourless"], "GMT", loc("GMT", pdf=28),
           note=N("The source explains that codeine has no free phenolic group (it is methylated), so these reactions help to separate it from morphine.",
                  "Manba tushuntiradi: kodeinda erkin fenol guruhi yo‘q (u metillangan), shuning uchun bu reaksiyalar uni morfindan farqlashga yordam beradi.",
                  "Источник поясняет: у кодеина нет свободной фенольной группы (она метилирована), поэтому эти реакции помогают отличить его от морфина.")))
add(colour("heroin", "fecl3", ["colourless"], "GMT", loc("GMT", pdf=37),
           note=N("The source contrasts this with morphine, which gives a colour.",
                  "Manba buni rang beradigan morfin bilan taqqoslaydi.",
                  "Источник противопоставляет это морфину, который даёт окраску.")))
add(colour("morphine", "k3fe", ["blue"], "GMT", loc("GMT", pdf=25),
           note=N("Result: a blue solution or precipitate (alkaline chloroform extract residue dissolved in water).",
                  "Natija: ko‘k eritma yoki cho‘kma (ishqoriy xloroformli ajralma qoldig‘i suvda eritilgan).",
                  "Результат: синий раствор или осадок (остаток щелочного хлороформного извлечения растворён в воде).")))
add(colour("codeine", "marquis", ["light-violet"], "GMT", loc("GMT", pdf=27), sensitivity="0.05 mg",
           note=N("Result for codeine itself; the reagent is not specific to codeine.",
                  "Natija kodeinning o‘zi uchun; reaktiv kodeinga xos emas.",
                  "Результат для самого кодеина; реактив не специфичен для кодеина.")))
add(colour("codeine", "frohde", ["dirty-blue", "greenish-blue"], "GMT", loc("GMT", pdf=28), sensitivity="0.1 µg",
           note=N("The source calls this reaction very characteristic for codeine.",
                  "Manba bu reaksiyani kodein uchun juda xarakterli deb ataydi.",
                  "Источник называет эту реакцию очень характерной для кодеина.")))
add(colour("heroin", "marquis", ["violet"], "GMT", loc("GMT", pdf=37), timing="immediate",
           note=N("Result after a few drops of the reagent on the powder.",
                  "Natija: kukunga reaktivdan bir necha tomchi tomizilgandan keyin.",
                  "Результат после нескольких капель реактива на порошок.")))
add(colour("heroin", "frohde", ["violet"], "GMT", loc("GMT", pdf=37),
           note=N("The source says this separates heroin from codeine.",
                  "Manba buning geroinni kodeindan farqlashini aytadi.",
                  "Источник указывает, что это отличает героин от кодеина.")))
add(micro("morphine",
          N("Wagner reagent (iodine in potassium iodide): rectangular plate-like crystals under the microscope; sensitivity stated by the source: 0.03 mg. The source notes that atropine, brucine, caffeine and scopolamine do not form crystals of this shape.",
            "Vagner reaktivi (yodning kaliy yodiddagi eritmasi): mikroskop ostida to‘g‘ri to‘rtburchak plastinkasimon kristallar; manba keltirgan sezgirlik: 0,03 mg. Manba atropin, brutsin, kofein va skopolamin bunday shakldagi kristallar hosil qilmasligini ta’kidlaydi.",
            "Реактив Вагнера (иод в иодиде калия): под микроскопом прямоугольные пластинчатые кристаллы; чувствительность по источнику: 0,03 мг. Источник отмечает, что атропин, бруцин, кофеин и скополамин кристаллов такой формы не образуют."),
          "GMT", loc("GMT", pdf=25), recipes=["recipe-wagner"], reagents=["Wagner reagent"]))
add(micro("morphine",
          N("Cadmium iodide (15%): first a white precipitate, then clusters of needle crystals; detection limit stated by the source: 2.5 µg. Reinecke salt solution: clusters of pink needle crystals; detection limit stated by the source: 2 µg.",
            "Kadmiy yodidning 15% eritmasi: avval oq cho‘kma, so‘ng ninasimon kristallar to‘plami; manba keltirgan aniqlash chegarasi: 2,5 µg. Reyneke tuzi eritmasi: pushti rangli ninasimon kristallar to‘plami; manba keltirgan aniqlash chegarasi: 2 µg.",
            "Иодид кадмия (15%): сначала белый осадок, затем скопления игольчатых кристаллов; предел обнаружения по источнику: 2,5 µg. Раствор соли Рейнеке: скопления розовых игольчатых кристаллов; предел обнаружения по источнику: 2 µg."),
          "GMT", loc("GMT", pdf=29), reagents=["cadmium iodide", "Reinecke salt"]))
add(micro("codeine",
          N("Saturated picrolone acid solution: first a yellow amorphous precipitate, then yellow spheroids and white-yellow plates; detection limit stated by the source: 1 µg. Mercury(II) chloride (5%) with gentle rubbing: clusters of needle and plate crystals; detection limit stated by the source: 13 µg.",
            "Pikrolon kislotaning to‘yingan eritmasi: avval sariq amorf cho‘kma, so‘ng sariq sferoidlar va oq-sariq plastinkalar; manba keltirgan aniqlash chegarasi: 1 µg. Simob(II) xloridning 5% eritmasi (sekin ishqalanganda): ninasimon va plastinkasimon kristallar to‘plami; manba keltirgan aniqlash chegarasi: 13 µg.",
            "Насыщенный раствор пикролоновой кислоты: сначала жёлтый аморфный осадок, затем жёлтые сферолиты и бело-жёлтые пластинки; предел обнаружения по источнику: 1 µg. Хлорид ртути(II) (5%) при осторожном растирании: скопления игольчатых и пластинчатых кристаллов; предел обнаружения по источнику: 13 µg."),
          "GMT", loc("GMT", pdf=29), reagents=["picrolone acid", "mercury(II) chloride"]))
add(micro("heroin",
          N("Hexachloroplatinic acid H2PtCl6: microcrystals as yellow needles; sensitivity stated by the source: 0.05–0.07 µg.",
            "Geksaxloroplatinat kislota H2PtCl6: sariq ignalardan iborat mikrokristallar; manba keltirgan sezgirlik: 0,05–0,07 µg.",
            "Гексахлороплатиновая кислота H2PtCl6: микрокристаллы в виде жёлтых игл; чувствительность по источнику: 0,05–0,07 µg."),
          "GMT", loc("GMT", pdf=37), reagents=["hexachloroplatinic acid"]))
add(generic("heroin", "odour_test",
            N("Acetic acid formed on hydrolysis: heating with ethanol and concentrated sulfuric acid gives the characteristic odour of ethyl acetate.",
              "Gidroliz natijasida hosil bo‘lgan sirka kislota: etanol va konsentrlangan sulfat kislota bilan qizdirilganda etilatsetatning xarakterli hidi chiqadi.",
              "Уксусная кислота, образующаяся при гидролизе: при нагревании с этанолом и концентрированной серной кислотой появляется характерный запах этилацетата."),
            "GMT", loc("GMT", pdf=37), "odour", "presumptive"))
# TLC — opiates (system as printed with Rf)
add(tlc(["morphine", "codeine", "heroin"], [("EtOAc", 17), ("MeOH", 2), ("NH3", 1)], "silica", "marquis_or_frohde",
        "GMT", loc("GMT", pdf=24, tbl=2),
        rf=[(N("morphine", "morfin", "морфин"), "0.32–0.39"), (N("codeine", "kodein", "кодеин"), "0.39–0.52"),
            (N("heroin", "geroin", "героин"), "0.52–0.66")],
        note=N("The source gives the order of Rf as morphine < codeine < heroin and notes a detection limit of 10–15 µg for morphine; spot colours with Marquis reagent: morphine red-pink, codeine pink, heroin red-pink.",
               "Manba Rf tartibini morfin < kodein < geroin deb beradi va morfin uchun aniqlash chegarasi 10–15 µg ekanini ko‘rsatadi; Marki reaktivi bilan dog‘ ranglari: morfin qizil-pushti, kodein pushti, geroin qizil-pushti.",
        "Источник приводит порядок Rf: морфин < кодеин < героин и предел обнаружения морфина 10–15 µg; цвет пятен с реактивом Марки: морфин красно-розовый, кодеин розовый, героин красно-розовый.")))
add(tlc_free(["morphine", "codeine", "heroin"],
             N("TLC, same system as above, plate-dependent values from a second table of the same book — ethyl acetate–methanol–25% ammonia solution (17:2:1): Rf on Silufol — morphine 0.20, codeine 0.40, heroin 0.52; on Sorbfil — morphine 0.27, codeine 0.49, heroin 0.65. Visualisation is not stated in this table.",
               "TLC, yuqoridagi bilan bir xil tizim, xuddi shu kitobning ikkinchi jadvalidagi plastinkaga bog‘liq qiymatlar — etilatsetat–metanol–ammiakning 25% eritmasi (17:2:1): Silufolda Rf — morfin 0,20, kodein 0,40, geroin 0,52; Sorbfilda — morfin 0,27, kodein 0,49, geroin 0,65. Bu jadvalda ochuvchi reagent ko‘rsatilmagan.",
               "TLC, та же система, зависящие от пластинки значения из второй таблицы той же книги — этилацетат—метанол—25% раствор аммиака (17:2:1): Rf на Силуфоле — морфин 0,20, кодеин 0,40, героин 0,52; на Сорбфиле — морфин 0,27, кодеин 0,49, героин 0,65. Проявление в этой таблице не указано."),
             "GMT", loc("GMT", pdf=33, tbl=3),
             data={"system": "EtOAc-MeOH-NH3 17:2:1", "plates": ["Silufol", "Sorbfil"]},
             note=N("The same system gives different Rf in the two tables of the book (for example morphine 0.32–0.39 and 0.20), so Rf is only meaningful against standards run on the same plate.",
                    "Kitobning ikki jadvalida bir xil tizim turlicha Rf beradi (masalan, morfin 0,32–0,39 va 0,20), shuning uchun Rf faqat xuddi shu plastinkada yurgizilgan standartlarga nisbatan ma’noga ega.",
                    "В двух таблицах книги одна и та же система даёт разные Rf (например, морфин 0,32–0,39 и 0,20), поэтому Rf имеет смысл только относительно стандартов на той же пластинке.")))
add(tlc_free(["morphine", "codeine", "heroin"],
             N("TLC, two further systems from the same table, Rf on Silufol / Sorbfil: diethyl ether–ethanol–25% ammonia solution (6:3:1) — morphine 0.30 / 0.30, codeine 0.60 / 0.45, heroin 0.80 / 0.60; methanol–25% ammonia solution (100:1.5) — morphine 0.37 / 0.29, codeine 0.37 / 0.29, heroin 0.40 / 0.43. Visualisation is not stated in this table.",
               "TLC, xuddi shu jadvaldagi yana ikki tizim, Silufol / Sorbfildagi Rf: dietil efiri–etanol–ammiakning 25% eritmasi (6:3:1) — morfin 0,30 / 0,30, kodein 0,60 / 0,45, geroin 0,80 / 0,60; metanol–ammiakning 25% eritmasi (100:1,5) — morfin 0,37 / 0,29, kodein 0,37 / 0,29, geroin 0,40 / 0,43. Bu jadvalda ochuvchi reagent ko‘rsatilmagan.",
               "TLC, ещё две системы из той же таблицы, Rf на Силуфоле / Сорбфиле: диэтиловый эфир—этанол—25% раствор аммиака (6:3:1) — морфин 0,30 / 0,30, кодеин 0,60 / 0,45, героин 0,80 / 0,60; метанол—25% раствор аммиака (100:1,5) — морфин 0,37 / 0,29, кодеин 0,37 / 0,29, героин 0,40 / 0,43. Проявление в этой таблице не указано."),
             "GMT", loc("GMT", pdf=33, tbl=3),
             data={"systems": ["Et2O-EtOH-NH3 6:3:1", "MeOH-NH3 100:1.5"]},
             note=N("In the methanol–ammonia system morphine and codeine have the same printed Rf on both plates, so that system does not separate them.",
                    "Metanol–ammiak tizimida morfin va kodein har ikki plastinkada bir xil Rf ga ega, shuning uchun bu tizim ularni ajratmaydi.",
                    "В системе метанол—аммиак у морфина и кодеина одинаковые Rf на обеих пластинках, поэтому эта система их не разделяет.")))
add(tlc("morphine", [("Et2O", 40), ("Me2CO", 20), ("NH3", 2)], "silica", "dragendorff_munier", "GMT", loc("GMT", pdf=25),
        rf=[(None, "0.18")],
        note=N("Spot colour: reddish-brown.", "Dog‘ rangi: qizg‘ish-qo‘ng‘ir.", "Цвет пятна: красновато-коричневый.")))
add(tlc("codeine", [("CHCl3", 50), ("Me2CO", 30), ("Et2NH", 2)], "silica", "dragendorff_munier", "GMT", loc("GMT", pdf=28),
        rf=[(None, "0.40")],
        note=N("Spot colour: brownish-red.", "Dog‘ rangi: qo‘ng‘ir-qizg‘ish.", "Цвет пятна: коричневато-красный.")))
# UV — opiates
add(uv("morphine", N("0.1 M sulfuric acid", "0,1 M sulfat kislota", "0,1 М серной кислоте"), ["284"], "GMT", loc("GMT", pdf=25),
       note=N("The same passage gives 287 nm (ethanol), 250 and 296 nm (0.1 M sodium hydroxide) and 285 nm (hydrochloride and sulfate in water); the table on PDF p. 34 gives 285 nm (0.1 M HCl) and 298 nm (0.1 M NaOH).",
              "Xuddi shu bandda 287 nm (etanol), 250 va 296 nm (0,1 M natriy ishqori) va 285 nm (xlorid va sulfat tuzlari, suvda) keltirilgan; PDF 34-betdagi jadvalda 285 nm (0,1 M HCl) va 298 nm (0,1 M NaOH).",
              "В том же месте приведены 287 нм (этанол), 250 и 296 нм (0,1 М гидроксид натрия) и 285 нм (гидрохлорид и сульфат в воде); в таблице на PDF с. 34 — 285 нм (0,1 М HCl) и 298 нм (0,1 М NaOH).")))
add(uv("codeine", N("ethanol (base)", "etanol (asos)", "этаноле (основание)"), ["286"], "GMT", loc("GMT", pdf=28),
       note=N("The table on PDF p. 34 gives 285 nm for codeine in 0.1 M HCl.",
              "PDF 34-betdagi jadvalda kodein uchun 0,1 M HCl da 285 nm keltirilgan.",
              "В таблице на PDF с. 34 для кодеина в 0,1 М HCl указано 285 нм.")))
add(uv("heroin", N("0.1 M hydrochloric acid (first value) and 0.1 M alkali (second value)", "0,1 M xlorid kislota (birinchi qiymat) va 0,1 M ishqor (ikkinchi qiymat)", "0,1 М соляной кислоте (первое значение) и 0,1 М щёлочи (второе значение)"), ["279", "299"], "GMT",
       loc("GMT", pdf=37),
       note=N("The table on PDF p. 34 gives 279 nm (0.1 M HCl) and 294 nm (0.1 M NaOH) for heroin, so the alkaline value differs inside the book.",
              "PDF 34-betdagi jadvalda geroin uchun 279 nm (0,1 M HCl) va 294 nm (0,1 M NaOH) keltirilgan, ya’ni ishqoriy qiymat kitob ichida farq qiladi.",
              "В таблице на PDF с. 34 для героина указаны 279 нм (0,1 М HCl) и 294 нм (0,1 М NaOH), то есть значение в щёлочи внутри книги различается.")))
add(generic("morphine", "photometric",
            N("Photocolorimetric determination as a silicomolybdate complex (blue colour on adding ammonia) against a calibration curve; working range stated by the source: 0.2–4 mg.",
              "Kremniy-molibdat kompleksi bilan fotokolorimetrik aniqlash (ammiak qo‘shilganda ko‘k rang) kalibrlash chizmasi bo‘yicha; manba keltirgan ishchi oraliq: 0,2–4 mg.",
              "Фотоколориметрическое определение в виде кремнемолибденового комплекса (синий цвет после добавления аммиака) по градуировочному графику; рабочий диапазон по источнику: 0,2–4 мг."),
            "GMT", loc("GMT", pdf=26), "supporting", "supporting", note=None))
add(generic("heroin", "physical",
            N("Melting point of heroin base: 173 °C.", "Geroin asosining suyuqlanish harorati: 173 °C.", "Температура плавления основания героина: 173 °C."),
            "GMT", loc("GMT", pdf=36), "physical", "physical", cat="C"))
add(generic("codeine", "physical",
            N("Melting point of codeine: 153–155 °C.", "Kodeinning suyuqlanish harorati: 153–155 °C.", "Температура плавления кодеина: 153–155 °C."),
            "GMT", loc("GMT", pdf=26), "physical", "physical", cat="C"))
# immunoassay / instrumental (opiates)
add(generic(["heroin", "morphine", "6-mam"], "immunoassay",
            N("The source states that heroin and its metabolites 6-monoacetylmorphine and morphine can also be determined by enzyme immunoassay methods.",
              "Manba geroin va uning metabolitlari 6-monoasetilmorfin va morfinni immunoferment tahlil usullarida ham aniqlash mumkinligini bildiradi.",
              "Источник указывает, что героин и его метаболиты 6-моноацетилморфин и морфин можно определять также иммуноферментными методами."),
            "GMT", loc("GMT", pdf=38), "immuno", "screening", cat="C", data={"screening_id": "scr-immunoassay-opiates"}))
add(generic(["heroin", "morphine", "6-mam"], "instrumental",
            N("The source names GC-MS (gas chromatography–mass spectrometry) and HPLC-MS (liquid chromatography–mass spectrometry) for heroin and its metabolites 6-monoacetylmorphine and morphine; in the same passage gas–liquid chromatography is named for heroin.",
              "Manba geroin va uning metabolitlari 6-monoasetilmorfin va morfin uchun GC-MS (gaz xromatografiyasi — mass-spektrometriya) va HPLC-MS (suyuqlik xromatografiyasi — mass-spektrometriya) ni keltiradi; xuddi shu bandda geroin uchun gaz-suyuqlik xromatografiyasi ham ko‘rsatilgan.",
              "Источник называет для героина и его метаболитов 6-моноацетилморфина и морфина GC-MS (газовая хроматография — масс-спектрометрия) и HPLC-MS (жидкостная хроматография — масс-спектрометрия); в том же месте для героина названа газожидкостная хроматография."),
            "GMT", loc("GMT", pdf=37, to=38), "instrumental", "instrumental", cat="A", data={"methods": ["method-gcms"]}))
add(generic(["morphine", "codeine"], "instrumental",
            N("The source names GC-MS and HPLC-MS (liquid chromatography–mass spectrometry) for quantifying the substance isolated from the specimen.",
              "Manba ajratib olingan moddani miqdoriy aniqlash uchun GC-MS va HPLC-MS (suyuqlik xromatografiyasi — mass-spektrometriya) ni keltiradi.",
              "Источник называет GC-MS и HPLC-MS (жидкостная хроматография — масс-спектрометрия) для количественного определения вещества, выделенного из объекта."),
            "GMT", loc("GMT", pdf=26, to=29), "instrumental", "instrumental", cat="A", data={"methods": ["method-gcms"]}))

# ---- methadone
add(colour("methadone", "h2so4_hno3", ["orange"], "GMT", loc("GMT", pdf=43, to=44),
           note=N("Preliminary test on the powder (a drop of the 1:1 acid mixture).",
                  "Kukun ustida dastlabki sinama (kislotalar aralashmasi 1:1 dan bir tomchi).",
                  "Предварительная проба на порошке (капля смеси кислот 1:1).")))
add(colour("methadone", "cobalt_thiocyanate", ["blue"], "GMT", loc("GMT", pdf=44),
           note=N("Preliminary test on the powder with a 2% aqueous solution. A blue colour with cobalt thiocyanate is not specific: cocaine, methaqualone and phencyclidine can give a similar colour (UNODC remark, printed pp. 42 and 52).",
                  "Kukun ustida dastlabki sinama (2% suvli eritma). Kobalt tiotsianat bilan ko‘k rang xos emas: kokain, metakvalon va fensiklidin ham o‘xshash rang berishi mumkin (UNODC izohi, bosma 42- va 52-betlar).",
                  "Предварительная проба на порошке (2% водный раствор). Синий цвет с тиоцианатом кобальта не специфичен: кокаин, метаквалон и фенциклидин могут давать сходную окраску (замечание UNODC, печатные сс. 42 и 52).")))
add(colour("methadone", "liebermann", ["orange"], "GMT", loc("GMT", pdf=44)))
add(colour("methadone", "mandelin", ["green", "pale-blue"], "GMT", loc("GMT", pdf=44)))
add(colour("methadone", "marquis", ["pink-red", "red"], "GMT", loc("GMT", pdf=44),
           note=N("The source adds that the red colour then fluoresces.",
                  "Manba qizil rang keyin fluoressensiyalanishini qo‘shimcha qiladi.",
                  "Источник добавляет, что красная окраска затем флуоресцирует.")))
add(tlc("methadone", [[("C6H12", 10), ("PhMe", 10), ("Et2NH", 1)], [("hexane", 2), ("Me2CO", 2), ("NH3", 0.2)], [("PhH", 9), ("EtOH", 1), ("Et2NH", 1)]],
        "sorbfil", "mandelin", "GMT", loc("GMT", pdf=44),
        rf=[(N("in benzene–ethanol–diethylamine (9:1:1)", "benzol–etanol–dietilamin (9:1:1) da", "в системе бензол—этанол—диэтиламин (9:1:1)"), "0.80")],
        note=N("Plates: Sorbfil or Silufol. Spot colour with Mandelin reagent: green turning blue. The three systems are the ones listed by the source; benzene is a hazardous solvent.",
               "Plastinkalar: Sorbfil yoki Silufol. Mandelin reaktivi bilan dog‘ rangi: yashildan ko‘kka o‘tadi. Uchta tizim manbada keltirilgan; benzol xavfli erituvchi.",
               "Пластинки: Сорбфил или Силуфол. Цвет пятна с реактивом Манделина: от зелёного к синему. Три системы приведены в источнике; бензол — опасный растворитель.")))
add(uv("methadone", N("0.1 M hydrochloric acid / sulfuric acid solution", "0,1 M xlorid kislota / sulfat kislota eritmasi", "растворе 0,1 М соляной / серной кислоты"), ["253", "259", "264", "292"], "GMT", loc("GMT", pdf=44),
       note=N("The source lists the same maxima for normethadone (253, 259, 265, 292 nm), so UV does not separate methadone from its close analogues.",
              "Manba normetadon uchun deyarli bir xil maksimumlarni keltiradi (253, 259, 265, 292 nm), shuning uchun UB metadonni yaqin analoglaridan ajratmaydi.",
              "Источник приводит почти такие же максимумы для норметадона (253, 259, 265, 292 нм), поэтому УФ не отличает метадон от его близких аналогов.")))
# ---- fentanyl
add(colour("fentanyl", "marquis", ["orange"], "GMT", loc("GMT", pdf=47),
           note=N("Chloroform solution evaporated on a slide, then 1–2 drops of reagent.",
                  "Xloroformli eritma buyum oynasida uchirilgandan so‘ng qoldiqqa reaktivdan 1–2 tomchi.",
                  "Хлороформный раствор выпаривают на стекле, затем добавляют 1–2 капли реактива.")))
add(colour("fentanyl", "citric_ac2o", ["red-violet"], "GMT", loc("GMT", pdf=47),
           note=N("Result after gentle heating on a water bath.", "Natija: suv hammomida sekin qizdirilgandan keyin.",
                  "Результат после осторожного нагревания на водяной бане.")))
add(tlc("fentanyl", [("EtOAc", 85), ("MeOH", 10), ("NH3", 5)], "silica_g", "iodoplatinate", "GMT", loc("GMT", pdf=47, to=48),
        rf=[(None, "0.78")],
        note=N("The source lists ten systems on silica gel G; this is the system it labels TE. In the same table the Rf in other listed systems are: chloroform–methanol (90:10) 0.74; acetone 0.58; methanol 0.70; methanol–n-butanol (60:40) 0.77; chloroform–ethanol (90:10) 0.59; chloroform–cyclohexane–glacial acetic acid (40:40:20) 0.08; chloroform–methanol–propionic acid (72:18:10) 0.84 (the values for the first two systems are cut off in the source and are not given).",
               "Manba silikagel G da o‘nta tizimni keltiradi; bu u TE deb belgilagan tizim. Xuddi shu jadvalda boshqa tizimlar uchun Rf: xloroform–metanol (90:10) 0,74; aseton 0,58; metanol 0,70; metanol–n-butanol (60:40) 0,77; xloroform–etanol (90:10) 0,59; xloroform–siklogeksan–muzlovchi sirka kislota (40:40:20) 0,08; xloroform–metanol–propion kislota (72:18:10) 0,84 (dastlabki ikki tizim qiymatlari manbada kesilgan va keltirilmaydi).",
               "Источник приводит десять систем на силикагеле G; это система, обозначенная в нём как TE. В той же таблице Rf в других системах: хлороформ—метанол (90:10) 0,74; ацетон 0,58; метанол 0,70; метанол—н-бутанол (60:40) 0,77; хлороформ—этанол (90:10) 0,59; хлороформ—циклогексан—ледяная уксусная кислота (40:40:20) 0,08; хлороформ—метанол—пропионовая кислота (72:18:10) 0,84 (значения для первых двух систем в источнике обрезаны и не приводятся).")))
add(uv("fentanyl", N("0.1 M hydrochloric acid", "0,1 M xlorid kislota", "0,1 М соляной кислоте"), ["251", "257", "263"], "GMT", loc("GMT", pdf=48),
       note=N("The same three maxima are printed for amphetamine, methamphetamine and ephedrine (PDF p. 87), so they reflect the phenyl chromophore and do not identify fentanyl.",
              "Xuddi shu uchta maksimum amfetamin, metamfetamin va efedrin uchun ham keltirilgan (PDF 87-bet), ya’ni ular fenil xromoforni aks ettiradi va fentanilni aniqlamaydi.",
              "Те же три максимума приведены для амфетамина, метамфетамина и эфедрина (PDF с. 87), то есть они отражают фенильный хромофор и не идентифицируют фентанил.")))
add(generic("fentanyl", "instrumental",
            N("The source describes HPLC (silica column, methanol with ammonium perchlorate, UV-diode detection) and gas chromatography (3% SE-30 column, retention index RI 2720) and states that fentanyl is quantified by GLC and HPLC; mass-spectral peaks are listed as well.",
              "Manba HPLC (silikagel kolonka, ammoniy perxloratli metanol, UB-diod detektor) va gaz xromatografiyasi (3% SE-30 kolonka, ushlanish indeksi RI 2720) ni tavsiflaydi va fentanil GLC va HPLC bilan miqdoriy aniqlanishini bildiradi; mass-spektr cho‘qqilari ham keltirilgan.",
              "Источник описывает HPLC (колонка с силикагелем, метанол с перхлоратом аммония, УФ-диодный детектор) и газовую хроматографию (колонка 3% SE-30, индекс удерживания RI 2720) и указывает, что фентанил количественно определяют методами GLC и HPLC; приведены также пики масс-спектра."),
            "GMT", loc("GMT", pdf=48), "instrumental", "instrumental", cat="B", data={"methods": ["method-hplc", "method-gcms"]}))
