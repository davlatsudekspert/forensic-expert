"""Entries part 2: cocaine, cannabinoids, phenylalkylamines, dissociatives, LSD."""
from sm_core import N, colour, generic, loc, micro, tlc, tlc_free, uv
from sm_core import loc as _loc
from substance_methods_data import E, UNODC_REM, add

# =============================================================== COCAINE
add(colour(["cocaine"], "cobalt_thiocyanate", ["blue"], "UNODC", loc("UNODC", printed=42),
           note=N("The source states that this includes illicit cocaine base preparations such as crack, and that a similar colour may occur with other controlled drugs (methaqualone, phencyclidine) and with non-controlled substances.",
                  "Manba bunga kokain asosining noqonuniy preparatlari (masalan, krek) ham kirishini va o‘xshash rang boshqa nazorat ostidagi moddalar (metakvalon, fensiklidin) hamda nazoratsiz moddalar bilan ham chiqishi mumkinligini bildiradi.",
                  "Источник указывает, что это относится и к нелегальным препаратам основания кокаина (например, крэк) и что сходная окраска возможна с другими контролируемыми веществами (метаквалон, фенциклидин) и неконтролируемыми веществами.")))
add(colour(["cocaine"], "scott", ["blue", "pink", "blue"], "UNODC", loc("UNODC", printed=43),
           note=N("Sequence in the UNODC procedure: blue with the cobalt reagent, pink after the acid step, blue again in the lower chloroform layer. The source adds that only a very few other substances give a similar sequence. In the teaching book the same test (cobalt thiocyanate–glycerol, HCl, chloroform) is described with the blue colour disappearing on hydrochloric acid and a dark blue chloroform layer (PDF p. 58).",
                  "UNODC tartibida rang ketma-ketligi: kobalt reaktivi bilan ko‘k, kislotali bosqichdan keyin pushti, pastki xloroform qatlamida yana ko‘k. Manba faqat juda kam boshqa moddalar o‘xshash ketma-ketlik berishini qo‘shimcha qiladi. O‘quv qo‘llanmada xuddi shu sinama (kobalt tiotsianat–glitserin, HCl, xloroform) ko‘k rang xlorid kislota ta’sirida o‘chishi va xloroform qatlami to‘q ko‘k bo‘lishi bilan tavsiflangan (PDF 58-bet).",
                  "Последовательность в процедуре UNODC: синий с кобальтовым реактивом, розовый после кислотной стадии, снова синий в нижнем хлороформном слое. Источник добавляет, что лишь очень немногие другие вещества дают сходную последовательность. В учебном пособии та же проба (тиоцианат кобальта—глицерин, HCl, хлороформ) описана с исчезновением синего цвета от соляной кислоты и тёмно-синим хлороформным слоем (PDF с. 58)."),
           ))
add(generic("cocaine", "odour_test",
            N("Methyl benzoate odour test: compare the odour of the test material with a reference sample of methyl benzoate (brief sniff from a safe distance, about 15–20 cm). The source adds that only a very few non-controlled drugs give a similar odour.",
              "Metilbenzoat hidi sinamasi: tekshiriluvchi materialning hidini metilbenzoat standart namunasi hidi bilan solishtirish (xavfsiz masofadan, taxminan 15–20 sm, qisqa hidlash). Manba faqat juda kam nazoratsiz moddalar o‘xshash hid berishini qo‘shimcha qiladi.",
              "Проба по запаху метилбензоата: запах исследуемого материала сравнивают с запахом стандартного образца метилбензоата (короткий вдох с безопасного расстояния, около 15–20 см). Источник добавляет, что лишь очень немногие неконтролируемые вещества дают сходный запах."),
            "UNODC", loc("UNODC", printed=43, to=44), "odour", "presumptive"))
add(colour(["cocaine"], "wagner", ["brown"], "UNODC", loc("UNODC", printed=44), kind="colour_test",
           note=N("Brown precipitate with cocaine hydrochloride; cocaine base gives no precipitate. Many other controlled and non-controlled drugs give the same reaction, so the source uses it only as a secondary test after the cobalt thiocyanate, Scott and methyl benzoate tests.",
                  "Kokain gidroxlorid bilan qo‘ng‘ir cho‘kma; kokain asosi cho‘kma bermaydi. Ko‘p boshqa nazorat ostidagi va nazoratsiz moddalar ham xuddi shu reaksiyani beradi, shuning uchun manba uni faqat kobalt tiotsianat, Skott va metilbenzoat sinamalaridan keyin ikkilamchi sinama sifatida ishlatadi.",
                  "Бурый осадок с гидрохлоридом кокаина; основание кокаина осадка не даёт. Многие другие контролируемые и неконтролируемые вещества дают ту же реакцию, поэтому источник использует её только как вторичную пробу после проб с тиоцианатом кобальта, Скотта и метилбензоатом.")))
add(micro("cocaine",
          N("Potassium permanganate with hydrochloric acid: rectangular red-violet crystals.",
            "Kaliy permanganat va xlorid kislota: to‘g‘ri to‘rtburchak shaklidagi qizil-binafsha kristallar.",
            "Перманганат калия с соляной кислотой: прямоугольные красно-фиолетовые кристаллы."),
          "GMT", loc("GMT", pdf=58), reagents=["potassium permanganate"]))
add(tlc_free(["cocaine", "benzoylecgonine"],
             N("TLC on Sorbton, Sorbfil or Kieselgel G 60 in three systems, Rf×100 as printed in the source — system 1: chloroform–dioxane–ethyl acetate–25% ammonia solution (25:60:10:5); system 2: methanol–25% ammonia solution (100:1.5); system 3: cyclohexane–toluene–diethylamine (75:15:10). Cocaine 81 / 59 / 56; benzoylecgonine 0 / 25 / 0; ecgonine 0 / 84 / 0; methylecgonine 61 / 65 / 44; cinnamoylcocaine 83 / 59 / 51; benzocaine 77 / 80 / 11; procaine 61 / 55 / 10; methadone 75 / 41 / 74. Visualisation is not stated for this table.",
               "TLC (Sorbton, Sorbfil yoki Kizelgel G 60) uch tizimda, manbadagi Rf×100 qiymatlari — 1-tizim: xloroform–dioksan–etilatsetat–ammiakning 25% eritmasi (25:60:10:5); 2-tizim: metanol–ammiakning 25% eritmasi (100:1,5); 3-tizim: siklogeksan–toluol–dietilamin (75:15:10). Kokain 81 / 59 / 56; benzoilekgonin 0 / 25 / 0; ekgonin 0 / 84 / 0; metilekgonin 61 / 65 / 44; sinnamoilkokain 83 / 59 / 51; benzokain 77 / 80 / 11; prokain 61 / 55 / 10; metadon 75 / 41 / 74. Bu jadval uchun ochuvchi reagent ko‘rsatilmagan.",
               "TLC на Sorbton, Sorbfil или Kieselgel G 60 в трёх системах, Rf×100 по источнику — система 1: хлороформ—диоксан—этилацетат—25% раствор аммиака (25:60:10:5); система 2: метанол—25% раствор аммиака (100:1,5); система 3: циклогексан—толуол—диэтиламин (75:15:10). Кокаин 81 / 59 / 56; бензоилэкгонин 0 / 25 / 0; экгонин 0 / 84 / 0; метилэкгонин 61 / 65 / 44; циннамоилкокаин 83 / 59 / 51; бензокаин 77 / 80 / 11; прокаин 61 / 55 / 10; метадон 75 / 41 / 74. Проявление для этой таблицы не указано."),
             "GMT", loc("GMT", pdf=58, to=59, tbl=3),
             data={"rf100": {"cocaine": [81, 59, 56], "benzoylecgonine": [0, 25, 0]}},
             note=N("In system 2 cocaine and cinnamoylcocaine have the same printed value (59), and in system 1 their values are close (81 and 83), so a spot at the cocaine position does not exclude related compounds.",
                    "2-tizimda kokain va sinnamoilkokainning keltirilgan qiymati bir xil (59), 1-tizimda esa yaqin (81 va 83), shuning uchun kokain o‘rnidagi dog‘ yaqin birikmalarni istisno qilmaydi.",
                    "В системе 2 у кокаина и циннамоилкокаина одинаковое приведённое значение (59), а в системе 1 значения близки (81 и 83), поэтому пятно на месте кокаина не исключает родственные соединения.")))
add(uv("cocaine", N("water acidified with hydrochloric acid (hydrochloride; absorbance read at one wavelength for quantification)", "xlorid kislota bilan nordonlashtirilgan suv (gidroxlorid; miqdoriy aniqlash uchun optik zichlik bitta to‘lqin uzunligida o‘lchanadi)", "воде, подкисленной соляной кислотой (гидрохлорид; оптическая плотность для количественного определения измеряется при одной длине волны)"), ["234"], "GMT", loc("GMT", pdf=59),
       note=N("The source quantifies cocaine hydrochloride by the absorbance at 234 nm against a calibration line; this is a quantitation step, not an identification.",
              "Manba kokain gidroxloridini kalibrlash chizig‘i bo‘yicha 234 nm dagi optik zichlik orqali miqdoriy aniqlaydi; bu miqdoriy bosqich, aynanlikni aniqlash emas.",
              "Источник определяет кокаина гидрохлорид по оптической плотности при 234 нм по градуировочной линии; это этап количественного определения, а не идентификации.")))
add(generic("cocaine", "instrumental",
            N("The source describes HPLC of cocaine with UV detection (phosphate buffer–acetonitrile 80:20, flow 100 µL/min, detection at 210, 234, 254, 276 and 302 nm). In the SWGDRUG scheme liquid chromatography is a category B technique.",
              "Manba kokainni UB-detektorli HPLC bilan tahlil qilishni tavsiflaydi (fosfat bufer–asetonitril 80:20, tezlik 100 µL/min, 210, 234, 254, 276 va 302 nm da aniqlash). SWGDRUG sxemasida suyuqlik xromatografiyasi B toifasidagi usul.",
              "Источник описывает HPLC кокаина с УФ-детектированием (фосфатный буфер—ацетонитрил 80:20, скорость 100 µL/мин, детектирование при 210, 234, 254, 276 и 302 нм). В схеме SWGDRUG жидкостная хроматография относится к категории B."),
            "GMT", loc("GMT", pdf=59), "instrumental", "instrumental", cat="B", data={"methods": ["method-hplc"]}))

# =============================================================== CANNABINOIDS
CANN = ["thc", "cbd"]
add(colour(["thc"], "fast_blue_b", ["purple-red"], "UNODC", loc("UNODC", printed=41),
           note=N("Result: purple-red colour of the lower chloroform layer (the colour of the upper layer is ignored). The source adds that only a very few other plant materials give a similar reaction. The test indicates cannabis material, not the THC content.",
                  "Natija: pastki xloroform qatlamining binafsha-qizil rangi (yuqori qatlam rangi hisobga olinmaydi). Manba faqat juda kam boshqa o‘simlik materiallari o‘xshash reaksiya berishini qo‘shimcha qiladi. Sinama kanop materialini ko‘rsatadi, THC miqdorini emas.",
                  "Результат: пурпурно-красный цвет нижнего хлороформного слоя (цвет верхнего слоя не учитывается). Источник добавляет, что лишь очень немногие другие растительные материалы дают сходную реакцию. Проба указывает на материал каннабиса, а не на содержание THC.")))
add(colour(["thc"], "duquenois_levine", ["violet"], "UNODC", loc("UNODC", printed=41, to=42),
           note=N("Result: violet colour of the lower chloroform layer. The source adds that only a very few other natural products give a similar reaction.",
                  "Natija: pastki xloroform qatlamining binafsha rangi. Manba faqat juda kam boshqa tabiiy moddalar o‘xshash reaksiya berishini qo‘shimcha qiladi.",
                  "Результат: фиолетовый цвет нижнего хлороформного слоя. Источник добавляет, что лишь очень немногие другие природные продукты дают сходную реакцию.")))
add(colour(CANN, ["pauli", "fast_blue_b"], ["red-pink", "greenish-blue", "dark-pink"], "GMT", loc("GMT", pdf=66), timing=None,
           sensitivity="1 µg",
           note=N("Alcoholic extract spotted on filter paper and sprayed with a freshly prepared reagent; with cannabinoids first red-pink, then bluish, finally dark pink. The source states that these reactions are not specific to cannabis: they can also be given by cannabis plants that contain no THC and by other cannabinoids.",
                  "Spirtli ekstrakt filtr qog‘oziga nuqta qilib tomiziladi va yangi tayyorlangan reaktiv purkaladi; kannabinoidlar bilan avval qizil-pushti, so‘ng ko‘kish, oxirida to‘q pushti. Manba bu reaksiyalar nashaga xos emasligini ta’kidlaydi: ularni tarkibida THC bo‘lmagan nasha o‘simliklari va boshqa kannabinoidlar ham berishi mumkin.",
                  "Спиртовое извлечение наносят пятном на фильтровальную бумагу и опрыскивают свежеприготовленным реактивом; с каннабиноидами сначала красно-розовый, затем синеватый, в конце тёмно-розовый. Источник подчёркивает, что эти реакции не специфичны для каннабиса: их могут давать и растения каннабиса без THC, и другие каннабиноиды.")))
add(colour(CANN, "duquenois", ["pink", "blue", "dark-pink"], "GMT", loc("GMT", pdf=66), sensitivity="1 µg",
           note=N("Colour sequence as described by the source after adding concentrated hydrochloric acid; this differs from the single violet colour reported by UNODC for the Duquenois–Levine test, so the two descriptions should not be mixed. The source states that these reactions are not specific to cannabis.",
                  "Manba tavsifidagi rang ketma-ketligi (konsentrlangan xlorid kislota qo‘shilgandan keyin); bu UNODC ning Duquenois–Levine sinamasi uchun keltirgan yagona binafsha rangidan farq qiladi, shuning uchun ikki tavsifni aralashtirmaslik kerak. Manba bu reaksiyalar nashaga xos emasligini ta’kidlaydi.",
                  "Последовательность цветов по описанию источника после добавления концентрированной соляной кислоты; она отличается от единственного фиолетового цвета, указанного UNODC для пробы Дюкенуа—Левина, поэтому два описания не следует смешивать. Источник подчёркивает, что эти реакции не специфичны для каннабиса.")))
add(colour(CANN, "beke", ["red-brown"], "GMT", loc("GMT", pdf=66), sensitivity="1 µg",
           note=N("Ethyl acetate extract of the sample, decolourised with activated charcoal, residue in acetone plus fresh reagent. The source states that these reactions are not specific to cannabis.",
                  "Namunaning etilatsetatli ekstrakti faollashtirilgan ko‘mir bilan rangsizlantiriladi, qoldiq asetonda eritilib yangi reaktiv qo‘shiladi. Manba bu reaksiyalar nashaga xos emasligini ta’kidlaydi.",
                  "Этилацетатное извлечение пробы обесцвечивают активированным углём, остаток растворяют в ацетоне и добавляют свежий реактив. Источник подчёркивает, что эти реакции не специфичны для каннабиса.")))
add(tlc_free(CANN,
             N("TLC of an ethanolic cannabis extract on silica gel (silicic acid or KSK, activated at 110 °C for 30 min) impregnated with dimethylformamide, developed twice in cyclohexane to 15 cm, visualised with Pauli reagent or Fast Blue B; Rf1 as printed (silica / KSK): cannabidiolic acid 0.14±0.05 / 0.13±0.05; cannabidiol 0.32±0.05 / 0.41±0.05; cannabinol 0.75±0.05 / 0.75±0.05; tetrahydrocannabinol 0.98±0.01 / 0.91±0.05. Spot colours with Fast Blue B: cannabidiol yellow-red, cannabinol and tetrahydrocannabinol pink-red; with Pauli reagent: cannabidiol light yellow, cannabinol yellow, tetrahydrocannabinol deep yellow.",
               "Nasha spirtli ekstraktining TLC si: dimetilformamid shimdirilgan silikagel (kremniy kislotasi yoki KSK, 110 °C da 30 daqiqa faollashtirilgan) plastinkada, siklogeksanda ikki marta 15 sm gacha yurgiziladi, Pauli reaktivi yoki Mustahkam ko‘k B bilan ochiladi; keltirilgan Rf1 (silikagel / KSK): kannabidiol kislotasi 0,14±0,05 / 0,13±0,05; kannabidiol 0,32±0,05 / 0,41±0,05; kannabinol 0,75±0,05 / 0,75±0,05; tetragidrokannabinol 0,98±0,01 / 0,91±0,05. Mustahkam ko‘k B bilan dog‘ ranglari: kannabidiol sariq-qizil, kannabinol va tetragidrokannabinol pushti-qizil; Pauli reaktivi bilan: kannabidiol och sariq, kannabinol sariq, tetragidrokannabinol to‘q sariq.",
               "TLC спиртового извлечения конопли на силикагеле (кремниевая кислота или KSK, активирован при 110 °C 30 мин), пропитанном диметилформамидом, двукратное элюирование циклогексаном до 15 см, проявление реактивом Паули или прочным синим Б; приведённые Rf1 (силикагель / KSK): каннабидиоловая кислота 0,14±0,05 / 0,13±0,05; каннабидиол 0,32±0,05 / 0,41±0,05; каннабинол 0,75±0,05 / 0,75±0,05; тетрагидроканнабинол 0,98±0,01 / 0,91±0,05. Цвет пятен с прочным синим Б: каннабидиол жёлто-красный, каннабинол и тетрагидроканнабинол розово-красные; с реактивом Паули: каннабидиол светло-жёлтый, каннабинол жёлтый, тетрагидроканнабинол насыщенно-жёлтый."),
             "GMT", loc("GMT", pdf=68, to=69, tbl=5),
             data={"system": "DMF-impregnated silica, cyclohexane x2", "rf1": {"thc": ["0.98±0.01", "0.91±0.05"]}},
             note=N("Rf values depend on plate, activation and development conditions and are meaningful only with a cannabis reference extract run on the same plate (the source prepares one).",
                    "Rf qiymatlari plastinka, faollashtirish va yurgizish sharoitiga bog‘liq va faqat xuddi shu plastinkada yurgizilgan nasha guvoh ekstrakti bilan ma’noga ega (manba uni tayyorlaydi).",
                    "Значения Rf зависят от пластинки, активации и условий хроматографирования и имеют смысл только с контрольным экстрактом каннабиса на той же пластинке (источник описывает его приготовление).")))
add(tlc_free(CANN,
             N("Paper chromatography (S-grade paper impregnated with the dimethylformamide phase, cyclohexane phase as mobile phase, 250 mm run, Pauli reagent or Fast Blue B): Rf cannabidiol 0.21±0.05, cannabinol 0.56±0.05, tetrahydrocannabinol 0.83±0.05; Fast Blue B colours yellowish-pink, red-pink, violet; Pauli colours light yellow, yellow, deep yellow (in the same order).",
               "Qog‘oz xromatografiyasi (dimetilformamid fazasi shimdirilgan «S» markali qog‘oz, harakatlanuvchi faza — siklogeksan fazasi, 250 mm yurish, Pauli reaktivi yoki Mustahkam ko‘k B): Rf kannabidiol 0,21±0,05, kannabinol 0,56±0,05, tetragidrokannabinol 0,83±0,05; Mustahkam ko‘k B ranglari sarg‘ish-pushti, qizil-pushti, binafsha; Pauli ranglari och sariq, sariq, to‘q sariq (shu tartibda).",
               "Бумажная хроматография (бумага марки «S», пропитанная диметилформамидной фазой, подвижная фаза — циклогексановая фаза, пробег 250 мм, реактив Паули или прочный синий Б): Rf каннабидиол 0,21±0,05, каннабинол 0,56±0,05, тетрагидроканнабинол 0,83±0,05; цвета с прочным синим Б: желтовато-розовый, красно-розовый, фиолетовый; цвета с реактивом Паули: светло-жёлтый, жёлтый, насыщенно-жёлтый (в том же порядке)."),
             "GMT", loc("GMT", pdf=67, to=68, tbl=4),
             data={"technique": "paper chromatography"}))
add(generic(["thc"], "caveat",
            N("The source states that a sample cannot be concluded to be cannabis without detecting tetrahydrocannabinol or a pharmacological test, and that the colour reactions are not specific to cannabis.",
              "Manba tetragidrokannabinol aniqlanmasdan yoki farmakologik tekshiruvsiz namunani nasha deb xulosa qilib bo‘lmasligini va rang reaksiyalari nashaga xos emasligini bildiradi.",
              "Источник указывает, что без обнаружения тетрагидроканнабинола или фармакологической пробы нельзя заключить, что образец — каннабис, и что цветные реакции не специфичны для каннабиса."),
            "GMT", loc("GMT", pdf=70), "supporting", "supporting"))
add(generic(["thc", "cbd"], "caveat",
            N("In the SWGDRUG scheme, for herbal cannabis macroscopic and microscopic examinations count as separate category B techniques when documented details of botanical features are recorded; the laboratory defines the acceptance criteria. The teaching book also puts a morphological examination of the exhibit first (PDF p. 62).",
              "SWGDRUG sxemasida o‘t ko‘rinishidagi nasha uchun makroskopik va mikroskopik tekshiruvlar botanik belgilarning hujjatlashtirilgan tafsilotlari qayd etilganda alohida B toifasidagi usullar hisoblanadi; qabul mezonlarini laboratoriya belgilaydi. O‘quv qo‘llanma ham ashyoviy dalilni avval morfologik tekshirishni qo‘yadi (PDF 62-bet).",
              "В схеме SWGDRUG для травяного каннабиса макроскопическое и микроскопическое исследования считаются отдельными методами категории B, если зафиксированы документированные детали ботанических признаков; критерии приемлемости определяет лаборатория. Учебное пособие также ставит морфологическое исследование вещественного доказательства на первое место (PDF с. 62)."),
            "SWG", _loc("SWG", sec=("IIIB.4.2 (printed p. 20); IIIB.5.1 (printed p. 21)", "IIIB.4.2 (bosma 20-bet); IIIB.5.1 (bosma 21-bet)", "IIIB.4.2 (печатная с. 20); IIIB.5.1 (печатная с. 21)")), "supporting", "supporting", cat="B"))
add(generic(["thc"], "instrumental",
            N("Gas chromatography with flame-ionisation detection for cannabinoid profile and content: 3% SE-30 column, column temperature 212 °C, injector and detector 250 °C, internal standard cocaine hydrochloride (retention times are printed in the source).",
              "Kannabinoidlar tarkibi va miqdori uchun alanga-ionlanish detektorli gaz xromatografiyasi: 3% SE-30 kolonka, kolonka harorati 212 °C, injektor va detektor 250 °C, ichki standart — kokain gidroxlorid (ushlanish vaqtlari manbada keltirilgan).",
              "Газовая хроматография с пламенно-ионизационным детектором для профиля и содержания каннабиноидов: колонка 3% SE-30, температура колонки 212 °C, инжектор и детектор 250 °C, внутренний стандарт — кокаина гидрохлорид (времена удерживания приведены в источнике)."),
            "GMT", loc("GMT", pdf=69), "instrumental", "instrumental", cat="B", data={"methods": ["method-gc-fid"]}))

# =============================================================== PHENYLALKYLAMINES
AMP = ["amphetamine", "methamphetamine"]
add(colour(AMP, "marquis", ["orange", "brown"], "UNODC", loc("UNODC", printed=45),
           note=N("The source gives this result for amphetamine and methamphetamine together; other amphetamine derivatives give other colours with the same reagent, and similar colours may occur with other substances.",
                  "Manba bu natijani amfetamin va metamfetamin uchun birgalikda keltiradi; boshqa amfetamin hosilalari shu reaktiv bilan boshqa ranglar beradi, o‘xshash ranglar esa boshqa moddalar bilan ham chiqishi mumkin.",
                  "Источник приводит этот результат для амфетамина и метамфетамина вместе; другие производные амфетамина дают с тем же реактивом иные цвета, а сходные цвета возможны и с другими веществами.")))
add(colour(AMP, "sulfuric", ["colourless"], "UNODC", loc("UNODC", printed=45, to=46),
           note=N("The source uses the absence of colour with concentrated sulfuric acid to separate amphetamine and methamphetamine from other amphetamine derivatives, many of which react.",
                  "Manba konsentrlangan sulfat kislota bilan rang bo‘lmasligidan amfetamin va metamfetaminni boshqa amfetamin hosilalaridan farqlash uchun foydalanadi (ularning ko‘pchiligi reaksiyaga kirishadi).",
                  "Источник использует отсутствие окраски с концентрированной серной кислотой, чтобы отличить амфетамин и метамфетамин от других производных амфетамина, многие из которых реагируют.")))
add(colour("methamphetamine", "simon", ["blue"], "UNODC", loc("UNODC", printed=46),
           note=N("The source states that other methamphetamine derivatives (MDMA, DMMA, PMMA) and other N-substituted derivatives (etilamfetamine, MDE) give the same reaction.",
                  "Manba metamfetaminning boshqa hosilalari (MDMA, DMMA, PMMA) va boshqa N-almashgan hosilalar (etilamfetamin, MDE) xuddi shu reaksiyani berishini bildiradi.",
                  "Источник указывает, что другие производные метамфетамина (MDMA, DMMA, PMMA) и другие N-замещённые производные (этиламфетамин, MDE) дают ту же реакцию.")))
add(colour("amphetamine", "simon_acetone", ["purple"], "UNODC", loc("UNODC", printed=47),
           note=N("The source states that other amphetamine derivatives (DOB, DMA, DOET, PMA, MDA, TMA) give the same reaction, so purple does not single out amphetamine.",
                  "Manba amfetaminning boshqa hosilalari (DOB, DMA, DOET, PMA, MDA, TMA) xuddi shu reaksiyani berishini bildiradi, shuning uchun binafsha rang amfetaminni ajratib ko‘rsatmaydi.",
                  "Источник указывает, что другие производные амфетамина (DOB, DMA, DOET, PMA, MDA, TMA) дают ту же реакцию, поэтому пурпурный цвет не выделяет амфетамин.")))
add(colour("methamphetamine", "marquis", ["brown"], "GMT", loc("GMT", pdf=86, tbl=11)))
add(colour(["amphetamine", "methamphetamine", "ephedrine", "mdma", "mda", "mdea"], "ninhydrin", ["violet"], "GMT", loc("GMT", pdf=80),
           note=N("The source gives a violet colour with ninhydrin solution for phenylalkylamines in general (extract of biological material); in its TLC table the colour differs between substances (for example MDA yellow).",
                  "Manba biologik ob’ekt ajralmasidagi fenilalkilaminlar uchun ningidrin eritmasi bilan binafsha rangni umumiy tarzda keltiradi; TLC jadvalida rang moddalar bo‘yicha farq qiladi (masalan, MDA sariq).",
                  "Источник приводит фиолетовый цвет с раствором нингидрина для фенилалкиламинов в целом (извлечение из биологического материала); в его таблице TLC цвет различается по веществам (например, MDA жёлтый).")))
add(tlc_free(["methamphetamine"],
             N("TLC in chloroform–acetone–ethanol–25% ammonia solution (20:3:1:20) on a Merck plate and on Sorbfil: Rf 0.25 and 0.38 respectively; zone colours: Marquis reagent brown, ninhydrin violet.",
               "TLC (xloroform–aseton–etanol–ammiakning 25% eritmasi, 20:3:1:20) Merck plastinkasida va Sorbfilda: Rf mos ravishda 0,25 va 0,38; zona ranglari: Marki reaktivi bilan qo‘ng‘ir, ningidrin bilan binafsha.",
               "TLC в системе хлороформ—ацетон—этанол—25% раствор аммиака (20:3:1:20) на пластинке Merck и на Сорбфиле: Rf 0,25 и 0,38 соответственно; цвета зон: реактив Марки — коричневый, нингидрин — фиолетовый."),
             "GMT", loc("GMT", pdf=87, tbl=12), data={"system": "CHCl3-Me2CO-EtOH-NH3 20:3:1:20"}))
add(tlc_free(["mdma"],
             N("TLC in chloroform–acetone–ethanol–25% ammonia solution (20:3:1:20) on a Merck plate and on Sorbfil: Rf 0.12 and 0.23 respectively; zone colours: Marquis reagent blue-black / green-black, ninhydrin violet.",
               "TLC (xloroform–aseton–etanol–ammiakning 25% eritmasi, 20:3:1:20) Merck plastinkasida va Sorbfilda: Rf mos ravishda 0,12 va 0,23; zona ranglari: Marki reaktivi bilan ko‘kimtir-qora / yashil-qora, ningidrin bilan binafsha.",
               "TLC в системе хлороформ—ацетон—этанол—25% раствор аммиака (20:3:1:20) на пластинке Merck и на Сорбфиле: Rf 0,12 и 0,23 соответственно; цвета зон: реактив Марки — синевато-чёрный / зеленовато-чёрный, нингидрин — фиолетовый."),
             "GMT", loc("GMT", pdf=87, tbl=12), data={"system": "CHCl3-Me2CO-EtOH-NH3 20:3:1:20"}))
add(tlc_free(["mda"],
             N("TLC in chloroform–acetone–ethanol–25% ammonia solution (20:3:1:20) on a Merck plate and on Sorbfil: Rf 0.44 and 0.66 respectively; zone colours: Marquis reagent blue-black / green-black, ninhydrin yellow.",
               "TLC (xloroform–aseton–etanol–ammiakning 25% eritmasi, 20:3:1:20) Merck plastinkasida va Sorbfilda: Rf mos ravishda 0,44 va 0,66; zona ranglari: Marki reaktivi bilan ko‘kimtir-qora / yashil-qora, ningidrin bilan sariq.",
               "TLC в системе хлороформ—ацетон—этанол—25% раствор аммиака (20:3:1:20) на пластинке Merck и на Сорбфиле: Rf 0,44 и 0,66 соответственно; цвета зон: реактив Марки — синевато-чёрный / зеленовато-чёрный, нингидрин — жёлтый."),
             "GMT", loc("GMT", pdf=87, tbl=12), data={"system": "CHCl3-Me2CO-EtOH-NH3 20:3:1:20"}))
add(tlc_free(["mdea"],
             N("TLC in chloroform–acetone–ethanol–25% ammonia solution (20:3:1:20) on a Merck plate and on Sorbfil: Rf 0.27 and 0.46 respectively; zone colours: Marquis reagent blue-black / green-black; the ninhydrin colour is recorded as unclear.",
               "TLC (xloroform–aseton–etanol–ammiakning 25% eritmasi, 20:3:1:20) Merck plastinkasida va Sorbfilda: Rf mos ravishda 0,27 va 0,46; zona ranglari: Marki reaktivi bilan ko‘kimtir-qora / yashil-qora; ningidrin rangi noaniq deb qayd etilgan.",
               "TLC в системе хлороформ—ацетон—этанол—25% раствор аммиака (20:3:1:20) на пластинке Merck и на Сорбфиле: Rf 0,27 и 0,46 соответственно; цвета зон: реактив Марки — синевато-чёрный / зеленовато-чёрный; цвет с нингидрином отмечен как неопределённый."),
             "GMT", loc("GMT", pdf=87, tbl=12), data={"system": "CHCl3-Me2CO-EtOH-NH3 20:3:1:20"}))
add(tlc_free(["amphetamine", "ephedrine"],
             N("TLC of phenylalkylamines in chloroform–acetone–ethanol–25% ammonia solution (20:3:1:20) with ninhydrin visualisation: the source gives a single Rf of 0.36 for phenylalkylamines in general (not a value specific to one substance). The source's table for individual substances in this system does not include amphetamine.",
               "Fenilalkilaminlarning TLC si xloroform–aseton–etanol–ammiakning 25% eritmasi (20:3:1:20) tizimida, ningidrin bilan ochish: manba umuman fenilalkilaminlar uchun yagona Rf 0,36 ni beradi (bitta moddaga xos qiymat emas). Manbaning shu tizimdagi alohida moddalar jadvalida amfetamin yo‘q.",
               "TLC фенилалкиламинов в системе хлороформ—ацетон—этанол—25% раствор аммиака (20:3:1:20) с проявлением нингидрином: источник приводит единое значение Rf 0,36 для фенилалкиламинов в целом (не значение для одного вещества). В таблице источника по отдельным веществам для этой системы амфетамина нет."),
             "GMT", loc("GMT", pdf=80), data={"system": "CHCl3-Me2CO-EtOH-NH3 20:3:1:20"}))
add(uv(AMP + ["ephedrine"], N("0.1 M hydrochloric acid", "0,1 M xlorid kislota", "0,1 М соляной кислоте"), ["251", "257", "263"], "GMT", loc("GMT", pdf=87),
       note=N("The source prints identical maxima for amphetamine, methamphetamine, methylephedrine, norpseudoephedrine, norephedrine and ephedrine, so UV cannot tell these substances apart.",
              "Manba amfetamin, metamfetamin, metilefedrin, norpsevdoefedrin, norefedrin va efedrin uchun bir xil maksimumlarni keltiradi, shuning uchun UB bu moddalarni bir-biridan ajratmaydi.",
              "Источник приводит одинаковые максимумы для амфетамина, метамфетамина, метилэфедрина, норпсевдоэфедрина, норэфедрина и эфедрина, поэтому УФ не различает эти вещества.")))
add(uv(["mdma", "mda"], N("0.1 M hydrochloric acid", "0,1 M xlorid kislota", "0,1 М соляной кислоте"), ["235", "286"], "GMT", loc("GMT", pdf=87),
       note=N("The source prints the same two maxima for MDA, MDMA, N-ethyl-MDA (234 and 286 nm) and MBDB.",
              "Manba xuddi shu ikki maksimumni MDA, MDMA, N-etil-MDA (234 va 286 nm) va MBDB uchun keltiradi.",
              "Источник приводит те же два максимума для MDA, MDMA, N-этил-MDA (234 и 286 нм) и MBDB.")))
add(uv(["mdea"], N("0.1 M hydrochloric acid (N-ethyl-MDA)", "0,1 M xlorid kislota (N-etil-MDA)", "0,1 М соляной кислоте (N-этил-MDA)"), ["234", "286"], "GMT", loc("GMT", pdf=87)))
add(colour(["mdma", "mda", "mdea"], "marquis", ["blue-black", "green-black"], "GMT", loc("GMT", pdf=86, tbl=11),
           note=N("The same two colours are printed for MBDB and BDB; the UNODC manual reports a black colour for MDA, MDMA and MDE.",
                  "Xuddi shu ikki rang MBDB va BDB uchun ham keltirilgan; UNODC qo‘llanmasi MDA, MDMA va MDE uchun qora rangni beradi.",
                  "Те же два цвета приведены для MBDB и BDB; руководство UNODC указывает чёрный цвет для MDA, MDMA и MDE.")))
add(colour(["mdma", "mda", "mdea"], "marquis", ["black"], "UNODC", loc("UNODC", printed=45), note=UNODC_REM))
add(colour(["mdma", "mda", "mdea"], "gallic", ["bright-green", "dark-green"], "UNODC", loc("UNODC", printed=47), rng=True,
           note=N("The source lists MDA, MDMA, MDE (N-ethyl-MDA), N-hydroxy-MDA and MMDA together; similar or other colours may occur with other substances.",
                  "Manba MDA, MDMA, MDE (N-etil-MDA), N-gidroksi-MDA va MMDA ni birgalikda keltiradi; boshqa moddalar ham o‘xshash yoki boshqa rang berishi mumkin.",
                  "Источник перечисляет MDA, MDMA, MDE (N-этил-MDA), N-гидрокси-MDA и MMDA вместе; другие вещества могут давать сходную или иную окраску.")))
add(colour(["mdma", "mdea"], "simon", ["blue"], "UNODC", loc("UNODC", printed=46),
           note=N("MDMA and N-ethyl-MDA (MDE) are listed by the source among the N-substituted methamphetamine derivatives that give the same blue colour as methamphetamine.",
                  "MDMA va N-etil-MDA (MDE) manbada metamfetamin bilan bir xil ko‘k rang beradigan N-almashgan metamfetamin hosilalari qatorida keltirilgan.",
                  "MDMA и N-этил-MDA (MDE) названы в источнике среди N-замещённых производных метамфетамина, дающих тот же синий цвет, что и метамфетамин.")))
add(colour(["mda"], "simon_acetone", ["purple"], "UNODC", loc("UNODC", printed=47),
           note=N("The source lists tenamfetamine (MDA) among the amphetamine derivatives that give the same purple colour as amphetamine.",
                  "Manba tenamfetamin (MDA) ni amfetamin bilan bir xil binafsha rang beradigan amfetamin hosilalari qatorida keltiradi.",
                  "Источник включает тенамфетамин (MDA) в число производных амфетамина, дающих тот же пурпурный цвет, что и амфетамин.")))
# ephedrine
add(micro("ephedrine",
          N("Dragendorff reagent: dark-red needle crystals. Reinecke salt (1% freshly prepared): four-sided reddish-pink crystals after 5–10 minutes.",
            "Dragendorf reaktivi: to‘q qizil rangli ninasimon kristallar. Reyneke tuzi (yangi tayyorlangan 1% eritma): 5–10 daqiqadan keyin to‘rt qirrali qizg‘ish-pushti kristallar.",
            "Реактив Драгендорфа: тёмно-красные игольчатые кристаллы. Соль Рейнеке (свежеприготовленный 1% раствор): через 5–10 минут четырёхгранные красновато-розовые кристаллы."),
          "GMT", loc("GMT", pdf=76, to=77), recipes=["recipe-dragendorff"], reagents=["Dragendorff reagent", "Reinecke salt"]))
add(colour("ephedrine", "cuso4_cs2", ["yellow-brown"], "GMT", loc("GMT", pdf=76),
           note=N("The benzene layer turns yellow or brown after shaking.", "Silkitilgandan keyin benzol qatlami sariq yoki qo‘ng‘ir rangga bo‘yaladi.",
                  "После встряхивания бензольный слой окрашивается в жёлтый или коричневый цвет.")))
add(colour("ephedrine", "marquis", ["orange"], "GMT", loc("GMT", pdf=80),
           note=N("Given by the source for phenylalkylamines extracted from biological material in general.",
                  "Manba buni biologik ob’ektdan ajratilgan fenilalkilaminlar uchun umumiy tarzda keltiradi.",
                  "Источник приводит это для фенилалкиламинов, извлечённых из биологического материала, в целом.")))
add(tlc("ephedrine", [("CHCl3", 48), ("Me2CO", 2)], "silica", "ninhydrin", "GMT", loc("GMT", pdf=77),
        rf=[(None, "0.28")],
        note=N("In the same system the source gives Rf 0.71 for ephedrone; in a separate passage ephedrine and ephedrone give ink-coloured spots on a pink background.",
               "Xuddi shu tizimda manba efedron uchun Rf 0,71 ni beradi; alohida bandda efedrin va efedron pushti fonda siyoh rangli dog‘lar beradi.",
               "В той же системе источник приводит Rf 0,71 для эфедрона; в отдельном месте эфедрин и эфедрон дают чернильные пятна на розовом фоне.")))

# =============================================================== DISSOCIATIVES / HALLUCINOGENS
add(colour("pcp", "marquis", ["light-pink"], "GMT", loc("GMT", pdf=91)))
add(colour("pcp", "mandelin", ["orange"], "GMT", loc("GMT", pdf=91)))
add(colour("pcp", "ehrlich", ["red"], "GMT", loc("GMT", pdf=91)))
add(colour("pcp", "scott", ["blue"], "GMT", loc("GMT", pdf=91),
           note=N("Reagent: 1 drop of 16% hydrochloric acid and 1 drop of 2.5% cobalt thiocyanate. UNODC notes that cobalt thiocyanate can also give a blue colour with cocaine and methaqualone.",
                  "Reaktiv: 16% xlorid kislotadan 1 tomchi va 2,5% kobalt tiotsianatdan 1 tomchi. UNODC kobalt tiotsianat kokain va metakvalon bilan ham ko‘k rang berishi mumkinligini ta’kidlaydi.",
                  "Реактив: 1 капля 16% соляной кислоты и 1 капля 2,5% тиоцианата кобальта. UNODC отмечает, что тиоцианат кобальта может давать синий цвет также с кокаином и метаквалоном.")))
add(tlc_free(["pcp"],
             N("TLC on silica gel, Rf of phencyclidine as printed: ethyl acetate–methanol–25% ammonia solution (85:10:5) 0.84; cyclohexane–toluene–diethylamine (75:15:10) on silica treated with 0.1 mol/L KOH 0.73; chloroform–methanol (90:10) on silica treated with 0.1 mol/L KOH 0.35. Visualisation: UV light, potassium iodoplatinate, Dragendorff reagent (Munier modification).",
               "Silikagelda TLC, fensiklidinning keltirilgan Rf qiymatlari: etilatsetat–metanol–ammiakning 25% eritmasi (85:10:5) 0,84; siklogeksan–toluol–dietilamin (75:15:10), 0,1 mol/L KOH bilan ishlangan silikagelda 0,73; xloroform–metanol (90:10), 0,1 mol/L KOH bilan ishlangan silikagelda 0,35. Ochuvchi reagent: UB nuri, kaliy yodplatinat, Dragendorf reaktivi (Myunye modifikatsiyasi).",
               "TLC на силикагеле, приведённые Rf фенциклидина: этилацетат—метанол—25% раствор аммиака (85:10:5) 0,84; циклогексан—толуол—диэтиламин (75:15:10) на силикагеле, обработанном 0,1 моль/л KOH, 0,73; хлороформ—метанол (90:10) на силикагеле, обработанном 0,1 моль/л KOH, 0,35. Проявление: УФ-свет, иодоплатинат калия, реактив Драгендорфа (модификация Мунье)."),
             "GMT", loc("GMT", pdf=91, to=92), data={"systems": 3}))
add(colour("ketamine", "cuso4_ether", ["wine-pink"], "GMT", loc("GMT", pdf=92),
           note=N("The ether layer turns pink-violet (residue of a chloroform extract, 0.1 M HCl, 10% copper sulfate, 10% sodium hydroxide, ether).",
                  "Efir qatlami pushti-binafsha rangga o‘tadi (xloroformli ajralma qoldig‘i, 0,1 M HCl, 10% mis sulfat, 10% natriy ishqori, efir).",
                  "Эфирный слой окрашивается в розово-фиолетовый цвет (остаток хлороформного извлечения, 0,1 М HCl, 10% сульфат меди, 10% гидроксид натрия, эфир).")))
add(colour("ketamine", "nitrite_naphthol", ["cherry-red"], "GMT", loc("GMT", pdf=92),
           note=N("After heating with sulfuric acid and sodium nitrite and reduction with zinc, the filtrate with sodium nitrite and alkaline β-naphthol turns red-cherry; with small amounts light pink, later brown-violet, then yellow-green.",
                  "Sulfat kislota va natriy nitrit bilan qizdirish hamda rux bilan qaytarishdan keyin filtrat natriy nitrit va ishqoriy β-naftol bilan qizil-olcha rangga o‘tadi; oz miqdorda och pushti, keyin qo‘ng‘ir-binafsha, so‘ng sariq-yashil.",
                  "После нагревания с серной кислотой и нитритом натрия и восстановления цинком фильтрат с нитритом натрия и щелочным β-нафтолом становится красно-вишнёвым; при малых количествах светло-розовый, затем коричнево-фиолетовый, затем жёлто-зелёный.")))
add(micro("ketamine",
          N("Nessler reagent: colourless needle-shaped microcrystals in clusters.",
            "Nessler reaktivi: rangsiz, yig‘ilgan ninasimon mikrokristallar.",
            "Реактив Несслера: бесцветные игольчатые микрокристаллы в скоплениях."),
          "GMT", loc("GMT", pdf=93), recipes=["recipe-nessler"], reagents=["Nessler reagent"]))
add(tlc_free(["ketamine"],
             N("TLC on silica gel G (Merck), Rf of ketamine as printed: methanol–25% ammonia solution (100:1.5) 0.59; cyclohexane–toluene–diethylamine (75:15:10) 0.73; chloroform–methanol (90:10) 0.35; ethyl acetate–methanol–25% ammonia solution (85:10:5) 0.84; methanol 0.23; chloroform–methanol–propionic acid (72:18:10) 0.48. Visualisation: acidified iodoplatinate (orange-brown spot), iodine vapour (dark blue spot).",
               "Silikagel G (Merck) da TLC, ketaminning keltirilgan Rf qiymatlari: metanol–ammiakning 25% eritmasi (100:1,5) 0,59; siklogeksan–toluol–dietilamin (75:15:10) 0,73; xloroform–metanol (90:10) 0,35; etilatsetat–metanol–ammiakning 25% eritmasi (85:10:5) 0,84; metanol 0,23; xloroform–metanol–propion kislota (72:18:10) 0,48. Ochuvchi reagent: kislotali yodplatinat (zarg‘aldoq-qo‘ng‘ir dog‘), yod bug‘lari (to‘q ko‘k dog‘).",
               "TLC на силикагеле G (Merck), приведённые Rf кетамина: метанол—25% раствор аммиака (100:1,5) 0,59; циклогексан—толуол—диэтиламин (75:15:10) 0,73; хлороформ—метанол (90:10) 0,35; этилацетат—метанол—25% раствор аммиака (85:10:5) 0,84; метанол 0,23; хлороформ—метанол—пропионовая кислота (72:18:10) 0,48. Проявление: подкисленный иодоплатинат (оранжево-коричневое пятно), пары иода (тёмно-синее пятно)."),
             "GMT", loc("GMT", pdf=93), data={"systems": 6}))
add(uv("ketamine", N("0.1 M hydrochloric acid", "0,1 M xlorid kislota", "0,1 М соляной кислоте"), ["269", "276"], "GMT", loc("GMT", pdf=93)))
add(generic("ketamine", "instrumental",
            N("The source describes gas chromatography (3% SE-30 column, retention index RI 1840), HPLC (C18 column, water–acetonitrile–2.5 M sulfuric acid 50:50:0.1, UV-diode detection, retention time 4.18) and lists mass-spectral peaks.",
              "Manba gaz xromatografiyasini (3% SE-30 kolonka, ushlanish indeksi RI 1840), HPLC ni (C18 kolonka, suv–asetonitril–2,5 M sulfat kislota 50:50:0,1, UB-diod detektor, ushlanish vaqti 4,18) tavsiflaydi va mass-spektr cho‘qqilarini keltiradi.",
              "Источник описывает газовую хроматографию (колонка 3% SE-30, индекс удерживания RI 1840), HPLC (колонка C18, вода—ацетонитрил—2,5 М серная кислота 50:50:0,1, УФ-диодный детектор, время удерживания 4,18) и приводит пики масс-спектра."),
            "GMT", loc("GMT", pdf=93), "instrumental", "instrumental", cat="B", data={"methods": ["method-hplc", "method-gcms"]}))
add(colour("lsd", "marquis", ["orange", "brown", "violet"], "GMT", loc("GMT", pdf=96),
           note=N("Colour sequence: orange-brown turning violet.", "Rang ketma-ketligi: zarg‘aldoq-qo‘ng‘ir rang binafshaga o‘tadi.",
                  "Последовательность: оранжево-коричневый цвет переходит в фиолетовый.")))
add(colour("lsd", "van_urk", ["red-violet"], "GMT", loc("GMT", pdf=96),
           note=N("The source states that this is a general reaction of ergot alkaloids (red-violet or violet colour).",
                  "Manba bu zamburug‘ alkaloidlari uchun umumiy reaksiya ekanini bildiradi (qizil-binafsha yoki binafsha rang).",
                  "Источник указывает, что это общая реакция алкалоидов спорыньи (красно-фиолетовый или фиолетовый цвет).")))
add(colour("lsd", "ehrlich", ["violet"], "UNODC", loc("UNODC", printed=52), timing="minutes",
           note=N("For paper impregnated with a suspected LSD dose, one dosage form together with the paper is placed on the spot plate. A similar colour may occur with other substances.",
                  "Qog‘ozga shimdirilgan taxminiy LSD dozasi uchun bitta doza qog‘ozi bilan birga tomchi plastinkasiga qo‘yiladi. O‘xshash rang boshqa moddalar bilan ham chiqishi mumkin.",
                  "Для бумаги с предполагаемой дозой LSD одну дозу вместе с бумагой помещают на пластину для капельных проб. Сходная окраска возможна и с другими веществами.")))
add(tlc("lsd", [[("CHCl3", 20), ("Me2CO", 20), ("EtOH", 3), ("NH3", 1)], [("EtOAc", 5), ("iPrOH", 5), ("NH3", 1)], [("hexane", 2), ("Me2CO", 2), ("NH3", 0.2)]],
        "silufol_uv", "uv_366_ehrlich", "GMT", loc("GMT", pdf=96),
        note=N("The source gives a single Rf of 0.57 for LSD without naming which of the three systems it belongs to, so it is not reproduced as a system-specific value.",
               "Manba LSD uchun uchta tizimning qaysi biriga tegishli ekanini ko‘rsatmasdan yagona Rf 0,57 ni beradi, shuning uchun u tizimga xos qiymat sifatida keltirilmaydi.",
               "Источник приводит единое значение Rf 0,57 для LSD, не указывая, к какой из трёх систем оно относится, поэтому оно не воспроизводится как значение для конкретной системы.")))
add(uv("lsd", N("0.1 M hydrochloric acid (first value) and 0.1 M sodium hydroxide (second value)", "0,1 M xlorid kislota (birinchi qiymat) va 0,1 M natriy gidroksid (ikkinchi qiymat)", "0,1 М соляной кислоте (первое значение) и 0,1 М гидроксиде натрия (второе значение)"), ["315", "310"], "GMT", loc("GMT", pdf=96)))
add(uv("psilocybin", N("water, pH above 7.0", "suv, pH 7,0 dan yuqori", "воде при pH выше 7,0"), ["269", "282", "292"], "GMT", loc("GMT", pdf=99),
       note=N("At pH below 7.0 the source gives 268 nm for psilocybin.", "pH 7,0 dan past bo‘lganda manba psilotsibin uchun 268 nm ni keltiradi.",
              "При pH ниже 7,0 источник приводит для псилоцибина 268 нм.")))
