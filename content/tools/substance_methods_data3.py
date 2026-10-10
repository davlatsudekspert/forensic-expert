"""Entries part 3: barbiturates, benzodiazepines, antipsychotics, antidepressants, salicylic acid."""
from sm_core import N, colour, generic, loc, micro, tlc, tlc_free, uv
from substance_methods_data import E, UNODC_REM, add

# =============================================================== BARBITURATES
BARB = ["phenobarbital", "pentobarbital", "secobarbital", "butalbital"]
add(colour(BARB, "dille", ["reddish-purple"], "UNODC", loc("UNODC", printed=49, to=50),
           note=N("The source gives this result for barbiturates as a class and notes that only very few other controlled or non-controlled drugs give a similar reaction; it does not separate one barbiturate from another.",
                  "Manba bu natijani barbituratlar sinfi uchun keltiradi va faqat juda kam boshqa nazorat ostidagi yoki nazoratsiz moddalar o‘xshash reaksiya berishini ta’kidlaydi; u bir barbituratni boshqasidan ajratmaydi.",
                  "Источник приводит этот результат для барбитуратов как класса и отмечает, что лишь очень немногие другие контролируемые или неконтролируемые вещества дают сходную реакцию; один барбитурат от другого проба не отличает.")))
add(colour(BARB, "co_ammonia", ["red"], "GMT", loc("GMT", pdf=110),
           note=N("Cobalt nitrate on filter paper, barbiturate-containing alcoholic solution, then ammonia vapour. The source states that purine alkaloids and substances with a biuret chain interfere. It is a class reaction of all barbiturates.",
                  "Filtr qog‘oziga kobalt nitrat shimdiriladi, barbiturat saqlovchi spirtli eritma tomiziladi, so‘ng ammiak bug‘iga tutiladi. Manba purin alkaloidlari va byuret zanjiri saqlovchi moddalar halaqit berishini bildiradi. Bu barcha barbituratlarning sinf reaksiyasi.",
                  "Фильтровальную бумагу пропитывают нитратом кобальта, наносят спиртовой раствор с барбитуратом, затем выдерживают в парах аммиака. Источник указывает, что мешают пуриновые алкалоиды и вещества с биуретовой цепью. Это групповая реакция всех барбитуратов.")))
add(colour(BARB, "co_ipa", ["red-pink"], "GMT", loc("GMT", pdf=110, to=111),
           note=N("Chloroform solution shaken with alcoholic cobalt acetate and isopropylamine; a red internal complex forms. Class reaction of barbiturates.",
                  "Xloroformli eritma kobalt atsetat va izopropilaminning spirtli eritmalari bilan chayqatiladi; qizil ichki kompleks hosil bo‘ladi. Barbituratlarning sinf reaksiyasi.",
                  "Хлороформный раствор встряхивают со спиртовыми растворами ацетата кобальта и изопропиламина; образуется красный внутрикомплексный продукт. Групповая реакция барбитуратов.")))
add(colour(BARB, "isonitroso", ["blue"], "GMT", loc("GMT", pdf=109),
           note=N("Applied when the residue is large or the exhibit is a pure powder (oxidation, then barbituric acid, nitrite — red isonitrosobarbituric acid, then iron salts — blue complex). Class reaction.",
                  "Qoldiq ko‘p bo‘lganda yoki ashyoviy dalil toza kukun bo‘lganda qo‘llanadi (oksidlash, so‘ng barbitur kislota, nitrit — qizil izonitrozobarbitur kislota, so‘ng temir tuzlari — ko‘k kompleks). Sinf reaksiyasi.",
                  "Применяется при большом остатке или когда вещественное доказательство — чистый порошок (окисление, затем барбитуровая кислота, нитрит — красная изонитрозобарбитуровая кислота, затем соли железа — синий комплекс). Групповая реакция.")))
add(micro(BARB,
          N("Dissolving the residue in concentrated sulfuric acid and diluting with water gives a white turbidity whose crystals have a characteristic shape for most barbiturates; copper salts with pyridine give an amorphous or crystalline precipitate. The source describes these as reactions specific to individual barbiturates but gives no crystal descriptions for single substances.",
            "Qoldiqni konsentrlangan sulfat kislotada eritib, suv bilan suyultirilganda oq loyqa hosil bo‘ladi, uning kristallari aksariyat barbituratlar uchun xarakterli shaklga ega; mis tuzlari va piridin amorf yoki kristall cho‘kma beradi. Manba bularni alohida barbituratlarga xos reaksiyalar deb tavsiflaydi, lekin ayrim moddalar uchun kristall tavsiflarini bermaydi.",
            "При растворении остатка в концентрированной серной кислоте и разбавлении водой возникает белая муть, кристаллы которой у большинства барбитуратов имеют характерную форму; соли меди с пиридином дают аморфный или кристаллический осадок. Источник описывает это как реакции, специфичные для отдельных барбитуратов, но описаний кристаллов для отдельных веществ не даёт."),
          "GMT", loc("GMT", pdf=113), reagents=["concentrated sulfuric acid", "copper salts with pyridine"]))
add(tlc(BARB, [("CHCl3", 70), ("BuOH", 40), ("NH3", 5)], "silica", "diphenylcarbazone", "GMT", loc("GMT", pdf=113),
        note=N("Barbiturates give blue-violet spots at substance-specific Rf values (the source prints no Rf values for single barbiturates); the toxicological chemistry teaching complex gives the same system (PDF p. 93).",
               "Barbituratlar moddaga xos Rf qiymatlarida ko‘k-binafsha dog‘lar beradi (manba alohida barbituratlar uchun Rf qiymatlarini keltirmaydi); toksikologik kimyo o‘quv-uslubiy majmuasi xuddi shu tizimni beradi (PDF 93-bet).",
               "Барбитураты дают сине-фиолетовые пятна при Rf, характерных для вещества (источник не приводит Rf для отдельных барбитуратов); учебно-методический комплекс по токсикологической химии приводит ту же систему (PDF с. 93).")))
add(uv("phenobarbital", N("borate buffer pH 9.2 (first value) and 1 M sodium hydroxide, pH 13 (second value)", "borat bufer pH 9,2 (birinchi qiymat) va 1 M natriy ishqori, pH 13 (ikkinchi qiymat)", "боратном буфере pH 9,2 (первое значение) и 1 М гидроксиде натрия, pH 13 (второе значение)"), ["239", "254"], "GMT", loc("GMT", pdf=115, tbl=None),
       note=N("The text on PDF p. 114 gives 238–240 nm at pH 10 and 258–260 nm at pH 13 for barbiturates in general; the pH shift of the spectrum is itself a characteristic of the barbiturate ring.",
              "PDF 114-betdagi matn barbituratlar uchun umuman pH 10 da 238–240 nm va pH 13 da 258–260 nm ni keltiradi; spektrning pH ga qarab siljishi barbiturat halqasining o‘ziga xos belgisi.",
              "Текст на PDF с. 114 для барбитуратов в целом приводит 238–240 нм при pH 10 и 258–260 нм при pH 13; сдвиг спектра с изменением pH сам по себе характерен для барбитуратного кольца.")))
add(uv("pentobarbital", N("borate buffer pH 9.2 (first value) and 1 M sodium hydroxide, pH 13 (second value)", "borat bufer pH 9,2 (birinchi qiymat) va 1 M natriy ishqori, pH 13 (ikkinchi qiymat)", "боратном буфере pH 9,2 (первое значение) и 1 М гидроксиде натрия, pH 13 (второе значение)"), ["239", "255"], "GMT", loc("GMT", pdf=115)))
add(uv("secobarbital", N("borate buffer pH 9.2 (first value) and 1 M sodium hydroxide, pH 13 (second value)", "borat bufer pH 9,2 (birinchi qiymat) va 1 M natriy ishqori, pH 13 (ikkinchi qiymat)", "боратном буфере pH 9,2 (первое значение) и 1 М гидроксиде натрия, pH 13 (второе значение)"), ["239", "254"], "GMT", loc("GMT", pdf=116)))
add(uv("butalbital", N("borate buffer pH 9.2 (first value) and 1 M sodium hydroxide, pH 13 (second value)", "borat bufer pH 9,2 (birinchi qiymat) va 1 M natriy ishqori, pH 13 (ikkinchi qiymat)", "боратном буфере pH 9,2 (первое значение) и 1 М гидроксиде натрия, pH 13 (второе значение)"), ["240", "255"], "GMT", loc("GMT", pdf=115)))
add(generic("phenobarbital", "physical",
            N("Melting point of phenobarbital: 174–177 °C.", "Fenobarbitalning suyuqlanish harorati: 174–177 °C.", "Температура плавления фенобарбитала: 174–177 °C."),
            "GMT", loc("GMT", pdf=108, tbl=15), "physical", "physical", cat="C"))
add(generic(BARB, "instrumental",
            N("The source describes gas chromatography (3% SE-30 column, isothermal 190–200 °C; identification by retention indices and the Kováts index) and HPLC (octadecylsilica column, 0.1 M phosphate buffer pH 3.5–methanol 60:40, UV detection at 216 nm); infrared and mass-spectral data are tabulated for the four barbiturates.",
              "Manba gaz xromatografiyasini (3% SE-30 kolonka, izotermik 190–200 °C; ushlanish indekslari va Kovach indeksi bo‘yicha aniqlash) va HPLC ni (oktadesilsilikagel kolonka, 0,1 M fosfat bufer pH 3,5–metanol 60:40, 216 nm da UB-detektor) tavsiflaydi; to‘rt barbiturat uchun IQ va mass-spektr ma’lumotlari jadvalda keltirilgan.",
              "Источник описывает газовую хроматографию (колонка 3% SE-30, изотермический режим 190–200 °C; идентификация по индексам удерживания и индексу Ковача) и HPLC (колонка с октадецилсиликагелем, 0,1 М фосфатный буфер pH 3,5—метанол 60:40, УФ-детектирование при 216 нм); для четырёх барбитуратов в таблице приведены ИК- и масс-спектральные данные."),
            "GMT", loc("GMT", pdf=114, to=116), "instrumental", "instrumental", cat="B", data={"methods": ["method-gcms", "method-hplc"]}))

# =============================================================== BENZODIAZEPINES
add(colour("diazepam", "zimmermann", ["reddish-purple", "pink"], "UNODC", loc("UNODC", printed=50), rng=True,
           note=N("The source states that some benzodiazepines (lorazepam, oxazepam, oxazolam, clorazepate, chlordiazepoxide, midazolam) give no colour with this test, so a negative Zimmermann result does not exclude a benzodiazepine.",
                  "Manba ayrim benzodiazepinlar (lorazepam, oksazepam, oksazolam, klorazepat, xlordiazepoksid, midazolam) bu sinama bilan rang bermasligini bildiradi, shuning uchun Simmerman sinamasining manfiy natijasi benzodiazepinni istisno qilmaydi.",
                  "Источник указывает, что некоторые бензодиазепины (лоразепам, оксазепам, оксазолам, клоразепат, хлордиазепоксид, мидазолам) не дают окраски в этой пробе, поэтому отрицательная реакция Циммермана не исключает бензодиазепин.")))
add(colour(["lorazepam", "oxazepam", "midazolam"], "zimmermann", ["colourless"], "UNODC", loc("UNODC", printed=50),
           note=N("Listed by the source among benzodiazepine derivatives that give no colour with the Zimmermann test (negative result of the test).",
                  "Manba Simmerman sinamasi bilan rang bermaydigan benzodiazepin hosilalari qatorida keltiradi (sinamaning manfiy natijasi).",
                  "Названы в источнике среди производных бензодиазепина, не дающих окраски в пробе Циммермана (отрицательный результат пробы).")))
add(colour("diazepam", "hcl_test", ["yellow"], "UNODC", loc("UNODC", printed=51),
           note=N("The source notes that many non-controlled drugs may give similar colours; the colour is given for diazepam or other benzodiazepine derivatives.",
                  "Manba ko‘p nazoratsiz moddalar o‘xshash rang berishi mumkinligini ta’kidlaydi; rang diazepam yoki boshqa benzodiazepin hosilalari uchun keltirilgan.",
                  "Источник отмечает, что многие неконтролируемые вещества могут давать сходные цвета; цвет приведён для диазепама или других производных бензодиазепина.")))
add(colour("diazepam", "vitali", ["yellow-orange"], "UNODC", loc("UNODC", printed=51), note=UNODC_REM))
add(colour("diazepam", "ninhydrin", ["yellow-brown"], "GMT", loc("GMT", pdf=140),
           note=N("Product colour as described in the diazepam passage.", "Diazepam bandida tavsiflangan mahsulot rangi.", "Цвет продукта по описанию в разделе о диазепаме.")))
add(micro("diazepam",
          N("Mercury iodide in potassium iodide: an amorphous precipitate, after 10–15 minutes in a humid chamber hexagonal plates and elongated prisms. Copper thiocyanate complex: small spheroid crystals that merge after 20–30 minutes in a humid chamber.",
            "Simob yodidning kaliy yodiddagi eritmasi: amorf cho‘kma, nam kamerada 10–15 daqiqadan keyin olti burchakli plastinkalar va cho‘zinchoq prizmalar. Mis tiotsianat kompleksi: mayda sferoid kristallar, nam kamerada 20–30 daqiqadan keyin birlashadi.",
            "Иодид ртути в иодиде калия: аморфный осадок, через 10–15 минут во влажной камере шестиугольные пластинки и удлинённые призмы. Комплекс тиоцианата меди: мелкие сферолитные кристаллы, сливающиеся через 20–30 минут во влажной камере."),
          "GMT", loc("GMT", pdf=140), reagents=["mercury iodide in potassium iodide", "copper thiocyanate complex"]))
add(tlc("diazepam", [[("EtOAc", 26), ("NH3", 1.6), ("MeOH", 3.3)], [("CHCl3", 9), ("Me2CO", 1)]], "ksk", "dragendorff", "GMT", loc("GMT", pdf=140)))
add(tlc_free(["diazepam", "oxazepam", "phenazepam"],
             N("TLC after acid hydrolysis to the benzophenone: the products are run on silica gel (KSK or Silufol) in benzene and the spots are diazotised (sodium nitrite, HCl, sulfanilic acid, alkaline β-naphthol); Rf of the hydrolysis products as printed: diazepam → MXB 0.57; oxazepam → AXB 0.35–0.37; phenazepam → BXB 0.43–0.45. The Rf and the colour (MXB stays yellow, AXB turns red) belong to the benzophenone, not to the intact drug.",
               "Kislotali gidroliz (benzofenonga) dan keyin TLC: mahsulotlar silikagelda (KSK yoki Silufol) benzolda yurgiziladi va dog‘lar diazotirlanadi (natriy nitrit, HCl, sulfanil kislota, ishqoriy β-naftol); gidroliz mahsulotlarining keltirilgan Rf qiymatlari: diazepam → MXB 0,57; oksazepam → AXB 0,35–0,37; fenazepam → BXB 0,43–0,45. Rf va rang (MXB sariqligicha qoladi, AXB qizarib ketadi) benzofenonga tegishli, o‘zgarmagan preparatga emas.",
               "TLC после кислотного гидролиза до бензофенона: продукты хроматографируют на силикагеле (KSK или Силуфол) в бензоле, пятна диазотируют (нитрит натрия, HCl, сульфаниловая кислота, щелочной β-нафтол); приведённые Rf продуктов гидролиза: диазепам → MXB 0,57; оксазепам → AXB 0,35–0,37; феназепам → BXB 0,43–0,45. Rf и цвет (MXB остаётся жёлтым, AXB становится красным) относятся к бензофенону, а не к неизменённому препарату."),
             "GMT", loc("GMT", pdf=135, to=136, tbl=17), data={"hydrolysis": True}))
add(uv("diazepam", N("acid solution (residue dissolved in acid)", "kislotali eritma (qoldiq kislotada eritilgan)", "кислом растворе (остаток растворён в кислоте)"), ["242", "284", "366"], "GMT", loc("GMT", pdf=140)))
add(generic(["diazepam", "oxazepam", "phenazepam"], "photometric",
            N("Class determination after acid hydrolysis: diazotisation and coupling (Bratton–Marshall reaction) gives a cherry-red product measured by photocolorimetry against a calibration graph; a spectrophotometric alternative uses the 200–300 nm absorption of the alcoholic solution. These steps quantify the amount and do not identify the benzodiazepine.",
              "Kislotali gidrolizdan keyin sinf bo‘yicha aniqlash: diazotirlash va birikish (Bratton–Marshall reaksiyasi) olcha-qizil mahsulot beradi, u kalibrlash grafigi bo‘yicha fotokolorimetriya bilan o‘lchanadi; spektrofotometrik muqobil usul spirtli eritmaning 200–300 nm dagi yutilishidan foydalanadi. Bu bosqichlar miqdorni aniqlaydi va benzodiazepinni aniqlamaydi.",
              "Групповое определение после кислотного гидролиза: диазотирование и азосочетание (реакция Браттона—Маршалла) даёт вишнёво-красный продукт, измеряемый фотоколориметрически по градуировочному графику; спектрофотометрический вариант использует поглощение спиртового раствора в области 200–300 нм. Эти этапы определяют количество и не идентифицируют бензодиазепин."),
            "GMT", loc("GMT", pdf=137, to=138), "supporting", "supporting", note=None))
add(tlc("oxazepam", [("CHCl3", 9), ("PrOH", 0.4), ("Me2CO", 1)], "silica", "thiosulfate", "GMT", loc("GMT", pdf=142),
        note=N("Spot colour: yellow or orange.", "Dog‘ rangi: sariq yoki zarg‘aldoq.", "Цвет пятна: жёлтый или оранжевый.")))
add(uv("oxazepam", N("acid (first pair), alkali (second pair) and ethanol (230 and 315)", "kislotali eritma (birinchi juftlik), ishqoriy eritma (ikkinchi juftlik) va etanol (230 va 315)", "кислоте (первая пара), щёлочи (вторая пара) и этаноле (230 и 315)"), ["234", "280", "233", "344", "230", "315"], "GMT", loc("GMT", pdf=142)))
add(tlc("phenazepam", [[("CHCl3", 9), ("Me2CO", 1)], [("PhH", 9), ("EtOH", 1), ("Et2NH", 1)]], "silica", "dragendorff_munier", "GMT", loc("GMT", pdf=143),
        note=N("Spot colour with the reagent: orange; under UV light an ink-coloured spot.",
               "Reaktiv bilan dog‘ rangi: zarg‘aldoq; UB nurida siyoh rangli dog‘.",
               "Цвет пятна с реактивом: оранжевый; в УФ-свете — чернильное пятно.")))
add(colour("phenazepam", "belstein", ["green"], "GMT", loc("GMT", pdf=143),
           note=N("Organically bound chlorine and bromine colour the flame green (copper wire, volatile copper halide); this indicates a halogenated compound, not phenazepam.",
                  "Organik birikkan xlor va brom alangani yashil rangga bo‘yaydi (mis sim, uchuvchan mis galogenidi); bu galogen saqlovchi birikmani ko‘rsatadi, fenazepamni emas.",
                  "Органически связанные хлор и бром окрашивают пламя в зелёный цвет (медная проволока, летучий галогенид меди); это указывает на галогенсодержащее соединение, а не на феназепам."),
           tag="supporting"))
add(uv("phenazepam", N("chloroform (first value) and ethanol (second value)", "xloroform (birinchi qiymat) va etanol (ikkinchi qiymat)", "хлороформе (первое значение) и этаноле (второе значение)"), ["320", "230"], "GMT", loc("GMT", pdf=144)))
add(generic("phenazepam", "physical",
            N("Melting point of phenazepam: 225–230 °C.", "Fenazepamning suyuqlanish harorati: 225–230 °C.", "Температура плавления феназепама: 225–230 °C."),
            "GMT", loc("GMT", pdf=143), "physical", "physical", cat="C"))

# =============================================================== ANTIPSYCHOTICS / PHENOTHIAZINES
add(colour("chlorpromazine", "sulfuric", ["crimson"], "GMT", loc("GMT", pdf=123)))
add(colour("chlorpromazine", "nitric", ["red-pink"], "GMT", loc("GMT", pdf=123)))
add(colour("chlorpromazine", "hcl_conc", ["pink", "red"], "GMT", loc("GMT", pdf=123), timing="on_standing"))
add(colour("chlorpromazine", "marquis", ["green", "red-pink"], "GMT", loc("GMT", pdf=123), timing="on_standing"))
add(colour("chlorpromazine", "mandelin", ["green", "red"], "GMT", loc("GMT", pdf=123), timing="on_standing"))
add(micro("chlorpromazine",
          N("Dragendorff reagent: first an amorphous precipitate, then four-sided brown crystals.",
            "Dragendorf reaktivi: avval amorf cho‘kma, so‘ng to‘rt burchakli qo‘ng‘ir kristallar.",
            "Реактив Драгендорфа: сначала аморфный осадок, затем четырёхугольные коричневые кристаллы."),
          "GMT", loc("GMT", pdf=123), recipes=["recipe-dragendorff"], reagents=["Dragendorff reagent"]))
add(tlc("chlorpromazine", [("PhH", 70), ("diox", 20), ("NH3", 5)], "silica", "h2so4_etoh", "GMT", loc("GMT", pdf=123),
        rf=[(None, "0.93")],
        note=N("Spot colour: pink-violet. The source's table for several phenothiazines gives Rf relative to chlorpromazine (Rf st = 1) in two other systems (PDF p. 121–122, Table 16).",
               "Dog‘ rangi: pushti-binafsha. Manbaning bir necha fenotiazin uchun jadvalida aminazinga nisbatan Rf (Rf st = 1) boshqa ikki tizimda keltirilgan (PDF 121–122-betlar, 16-jadval).",
               "Цвет пятна: розово-фиолетовый. В таблице источника для нескольких фенотиазинов приведены Rf относительно хлорпромазина (Rf st = 1) в двух других системах (PDF сс. 121–122, табл. 16).")))
add(uv("chlorpromazine", N("0.1 M sulfuric acid", "0,1 M sulfat kislota", "0,1 М серной кислоте"), ["255", "307"], "GMT", loc("GMT", pdf=123, to=124),
       note=N("The main metabolite, the sulfoxide, absorbs at 239, 274, 300 and 341 nm in the same solution.",
              "Asosiy metabolit sulfoksid shu eritmada 239, 274, 300 va 341 nm da yutadi.",
              "Основной метаболит — сульфоксид — поглощает в том же растворе при 239, 274, 300 и 341 нм.")))
add(generic("chlorpromazine", "photometric",
            N("Photocolorimetric determination of the red colour formed with concentrated sulfuric acid, or spectrophotometry in the UV range; quantification, not identification.",
              "Konsentrlangan sulfat kislota bilan hosil bo‘lgan qizil rangni fotokolorimetrik aniqlash yoki UB sohasida spektrofotometriya; miqdoriy aniqlash, aynanlikni aniqlash emas.",
              "Фотоколориметрическое определение красной окраски с концентрированной серной кислотой или спектрофотометрия в УФ-области; количественное определение, а не идентификация."),
            "GMT", loc("GMT", pdf=124), "supporting", "supporting"))
add(colour("haloperidol", "marquis", ["yellow"], "GMT", loc("GMT", pdf=130)))
add(colour("haloperidol", "frohde", ["orange"], "GMT", loc("GMT", pdf=130)))
add(colour("haloperidol", "mandelin", ["dark-orange"], "GMT", loc("GMT", pdf=131)))
add(tlc("haloperidol", [[("PhMe", 50), ("Me2CO", 10), ("NH3", 5)], [("PhMe", 30), ("hexane", 5), ("Me2CO", 5), ("Et2NH", 5)], [("EtOH", 100), ("NH3", 1.5)], [("iPrOH", 50), ("EtOH", 20), ("NH3", 5)]], "silica", "uv_dragendorff", "GMT", loc("GMT", pdf=131),
        note=N("The source lists these mobile phases for haloperidol and droperidol (a further toluene–hexane–diethylamine system is also given) and prints no Rf values.",
               "Manba bu harakatlanuvchi fazalarni galoperidol va droperidol uchun keltiradi (toluol–geksan–dietilamin tizimi ham berilgan) va Rf qiymatlarini keltirmaydi.",
               "Источник перечисляет эти подвижные фазы для галоперидола и дроперидола (дана также система толуол—гексан—диэтиламин) и не приводит значений Rf.")))
add(uv("haloperidol", N("95% ethanol", "95% etanol", "95% этаноле"), ["246"], "GMT", loc("GMT", pdf=131)))

# =============================================================== ANTIDEPRESSANTS
add(colour(["amitriptyline"], "mandelin", ["brown", "green"], "TOKS", loc("TOKS", pdf=135), timing="on_standing"))
add(micro("amitriptyline",
          N("Reinecke salt (0.1% HCl residue plus one drop of 0.1% reagent): needle crystals; sensitivity stated by the source: 0.02 µg. Nortriptyline gives branched crystals (sensitivity 0.01 µg).",
            "Reyneke tuzi (qoldiq 0,1% HCl da, 0,1% reaktivdan bir tomchi): ninasimon kristallar; manba keltirgan sezgirlik: 0,02 µg. Nortriptilin shohsimon kristallar beradi (sezgirlik 0,01 µg).",
            "Соль Рейнеке (остаток в 0,1% HCl и одна капля 0,1% реактива): игольчатые кристаллы; чувствительность по источнику: 0,02 µg. Нортриптилин даёт ветвистые кристаллы (чувствительность 0,01 µg)."),
          "TOKS", loc("TOKS", pdf=135), reagents=["Reinecke salt"]))
add(tlc_free(["amitriptyline", "nortriptyline"],
             N("TLC with two successive developments (benzene–acetone 80:20 to 10 cm, then benzene–dioxane–25% ammonia solution 60:35:5 to 10 cm), spots revealed by a drop of concentrated sulfuric acid; Rfq as printed: amitriptyline 0.74–0.78 (clear spot), nortriptyline 0.38–0.46 (yellow spot); detection limit stated by the source: 0.2 µg. Reference solutions of both bases are run alongside.",
               "TLC ikki ketma-ket yurgizish bilan (benzol–aseton 80:20, 10 sm gacha, so‘ng benzol–dioksan–ammiakning 25% eritmasi 60:35:5, 10 sm gacha), dog‘lar konsentrlangan sulfat kislota tomchisi bilan ochiladi; keltirilgan Rfq: amitriptilin 0,74–0,78 (tiniq dog‘), nortriptilin 0,38–0,46 (sariq dog‘); manba keltirgan aniqlash chegarasi: 0,2 µg. Ikkala asosning guvoh eritmalari yonma-yon yurgiziladi.",
               "TLC с двукратным элюированием (бензол—ацетон 80:20 до 10 см, затем бензол—диоксан—25% раствор аммиака 60:35:5 до 10 см), пятна проявляют каплей концентрированной серной кислоты; приведённые Rfq: амитриптилин 0,74–0,78 (отчётливое пятно), нортриптилин 0,38–0,46 (жёлтое пятно); предел обнаружения по источнику: 0,2 µg. Рядом хроматографируют стандартные растворы обоих оснований."),
             "TOKS", loc("TOKS", pdf=135), data={"two_step": True}))
add(uv("amitriptyline", N("0.1% hydrochloric acid", "0,1% xlorid kislota", "0,1% соляной кислоте"), ["197", "202", "207", "240"], "TOKS", loc("TOKS", pdf=135)))
add(micro("nortriptyline",
          N("Reinecke salt: branched (antler-like) crystals; sensitivity stated by the source: 0.01 µg.",
            "Reyneke tuzi: shohsimon kristallar; manba keltirgan sezgirlik: 0,01 µg.",
            "Соль Рейнеке: ветвистые (рогообразные) кристаллы; чувствительность по источнику: 0,01 µg."),
          "TOKS", loc("TOKS", pdf=135), reagents=["Reinecke salt"]))
add(generic(["amitriptyline", "nortriptyline", "imipramine", "doxepin"], "instrumental",
            N("The source names HPLC for qualitative and quantitative determination of antidepressants and their metabolites, listing the separation of trimipramine, doxepin, amitriptyline, imipramine, desmethyldoxepin, nortriptyline and desipramine, and notes that GC of tricyclic antidepressants needs derivatisation with trifluoroacetic anhydride.",
              "Manba antidepressantlar va ularning metabolitlarini sifat va miqdoriy aniqlash uchun HPLC ni keltiradi, trimipramin, doksepin, amitriptilin, imipramin, dezmetildoksepin, nortriptilin va dezipraminning ajratilishini sanaydi va tritsiklik antidepressantlarning GC si uchun triftorsirka angidrid bilan derivatizatsiya kerakligini ta’kidlaydi.",
              "Источник называет HPLC для качественного и количественного определения антидепрессантов и их метаболитов, перечисляет разделение тримипрамина, доксепина, амитриптилина, имипрамина, десметилдоксепина, нортриптилина и дезипрамина и отмечает, что для GC трициклических антидепрессантов требуется дериватизация трифторуксусным ангидридом."),
            "TOKS", loc("TOKS", pdf=133, to=134), "instrumental", "instrumental", cat="B", data={"methods": ["method-hplc"]}))
add(tlc("mirtazapine", [("EtOAc", 87), ("MeOH", 3), ("H2O", 1.5), ("NH4OH", 0.5)], "silica", "dragendorff_brown", "TOKS", loc("TOKS", pdf=134),
        rf=[(None, "0.42")]))
add(uv("mirtazapine", N("96% ethanol", "96% etanol", "96% этаноле"), ["295"], "TOKS", loc("TOKS", pdf=134)))
add(tlc("venlafaxine", [("EtOAc", 8.5), ("EtOH", 1), ("NH4OH", 0.5)], "silica", "uv_only", "TOKS", loc("TOKS", pdf=133),
        note=N("The source gives the system and the visualisation but no Rf value.", "Manba tizim va ochuvchi reagentni beradi, lekin Rf qiymatini bermaydi.",
               "Источник приводит систему и проявление, но не значение Rf.")))
add(tlc("fluoxetine", [("EtOH", 2), ("CHCl3", 1), ("PhH", 2)], "silica", "uv_only", "TOKS", loc("TOKS", pdf=133),
        note=N("The source gives the system under the brand name Depres (fluoxetine) and no Rf value.", "Manba tizimni Depres (fluoksetin) savdo nomi ostida beradi va Rf qiymatini bermaydi.",
               "Источник приводит систему под торговым названием Depres (флуоксетин) и не приводит значение Rf.")))

# =============================================================== SALICYLIC ACID
add(colour("salicylic-acid", "fecl3", ["zangori-violet"], "TOKS", loc("TOKS", pdf=98, to=99),
           note=N("The colour and complex composition depend on pH (pH 1.8–2.5 pinkish-blue, pH 4–8 red-brown, pH 8–11 yellow). The colour is not destroyed by alcohol (unlike phenol); substances that protect the phenolic hydroxyl (maltol and others) interfere.",
                  "Rang va kompleks tarkibi pH ga bog‘liq (pH 1,8–2,5 ko‘kimtir-pushti, pH 4–8 qizil-qo‘ng‘ir, pH 8–11 sariq). Rang spirt ta’sirida o‘chmaydi (fenoldan farqi); fenol gidroksilini himoyalovchi moddalar (maltol va b.) halaqit beradi.",
                  "Цвет и состав комплекса зависят от pH (pH 1,8–2,5 голубовато-розовый, pH 4–8 красно-коричневый, pH 8–11 жёлтый). Окраска не исчезает от спирта (в отличие от фенола); мешают вещества, защищающие фенольный гидроксил (мальтол и др.).")))
add(colour("salicylic-acid", "bromine_water", ["cloudy-white"], "TOKS", loc("TOKS", pdf=99),
           note=N("White precipitate of tribromophenol with release of carbon dioxide; very sensitive (1:40000) but given by many benzene-ring compounds, so the source assigns it a negative value only: no reaction speaks against salicylic acid, a positive one proves nothing.",
                  "Tribromfenolning oq cho‘kmasi va karbonat angidrid ajralishi; juda sezgir (1:40000), lekin benzol yadrosi saqlovchi ko‘p moddalar ham beradi, shuning uchun manba unga faqat manfiy ahamiyat beradi: reaksiyaning chiqmasligi salitsil kislotaga qarshi dalil, musbat natija esa hech narsani isbotlamaydi.",
                  "Белый осадок трибромфенола с выделением диоксида углерода; очень чувствительна (1:40000), но её дают многие соединения с бензольным ядром, поэтому источник придаёт ей только отрицательное значение: отсутствие реакции говорит против салициловой кислоты, положительная ничего не доказывает.")))
add(generic("salicylic-acid", "odour_test",
            N("Heating with methanol (or ethanol) and concentrated sulfuric acid gives the characteristic odour of methyl salicylate.",
              "Metanol (yoki etanol) va konsentrlangan sulfat kislota bilan qizdirilganda metilsalitsilatning xarakterli hidi chiqadi.",
              "При нагревании с метанолом (или этанолом) и концентрированной серной кислотой появляется характерный запах метилсалицилата."),
            "TOKS", loc("TOKS", pdf=99), "odour", "presumptive"))
add(colour("salicylic-acid", "trinder", ["crimson"], "TOKS", loc("TOKS", pdf=99),
           note=N("Preliminary test on urine or blood serum (mercury(II) chloride and iron nitrite mixture); also iron(III) nitrate in nitric acid gives a red-violet colour with urine or serum.",
                  "Siydik yoki qon zardobida dastlabki sinama (simob(II) xlorid va temir nitrit aralashmasi); temir(III) nitratning nitrat kislotadagi eritmasi ham siydik yoki zardob bilan qizil-binafsha rang beradi.",
                  "Предварительная проба на моче или сыворотке крови (смесь хлорида ртути(II) и нитрита железа); раствор нитрата железа(III) в азотной кислоте также даёт красно-фиолетовый цвет с мочой или сывороткой.")))
add(uv("salicylic-acid", N("0.5 N sodium hydroxide (first value) and 0.1 N sulfuric acid (second value)", "0,5 n natriy ishqori (birinchi qiymat) va 0,1 n sulfat kislota (ikkinchi qiymat)", "0,5 н гидроксиде натрия (первое значение) и 0,1 н серной кислоте (второе значение)"), ["300", "302"], "TOKS", loc("TOKS", pdf=99)))
