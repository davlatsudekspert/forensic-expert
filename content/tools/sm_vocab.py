"""Vocabulary + renderers for the substance-level «Tekshirish usullari» layer.

Every user-visible sentence is rendered from a small controlled vocabulary in
all three UI languages (uz / ru / en) so that numbers, units, formulas and
abbreviations are identical by construction (content/tools/translation_qa.py
re-checks them). Nothing here carries a scientific fact: facts live in
substance_methods_data.py, each with a source id and a locator.
"""
from __future__ import annotations

LANGS = ("en", "uz", "ru")

# --------------------------------------------------------------------------
# Colours (ru: nominative masculine, used after «цвет:»)
# --------------------------------------------------------------------------
COLOURS = {
    "violet": ("violet", "binafsha", "фиолетовый"),
    "purple": ("purple", "to‘q binafsha", "пурпурный"),
    "light-violet": ("light violet", "och binafsha", "светло-фиолетовый"),
    "reddish-purple": ("reddish-purple", "qizg‘ish-binafsha", "красновато-пурпурный"),
    "red-violet": ("red-violet", "qizil-binafsha", "красно-фиолетовый"),
    "brownish-purple": ("brownish purple", "qo‘ng‘ir-binafsha", "коричневато-пурпурный"),
    "blue-violet": ("blue-violet", "ko‘k-binafsha", "сине-фиолетовый"),
    "violet-blue": ("violet-blue", "binafsha-ko‘k", "фиолетово-синий"),
    "pink": ("pink", "pushti", "розовый"),
    "light-pink": ("light pink", "och pushti", "светло-розовый"),
    "violet-pink": ("violet-pink", "binafsha-pushti", "фиолетово-розовый"),
    "red-pink": ("red-pink", "qizil-pushti", "красно-розовый"),
    "pink-red": ("pink-red", "pushti-qizil", "розово-красный"),
    "red": ("red", "qizil", "красный"),
    "dark-red": ("dark red", "to‘q qizil", "тёмно-красный"),
    "crimson": ("crimson", "alvon qizil", "малиновый"),
    "cherry-red": ("cherry red", "olcha qizil", "вишнёво-красный"),
    "red-brown": ("red-brown", "qizil-qo‘ng‘ir", "красно-коричневый"),
    "reddish-brown": ("reddish-brown", "qizg‘ish-qo‘ng‘ir", "красновато-коричневый"),
    "blood-red": ("blood-red", "qon-qizil", "кроваво-красный"),
    "orange": ("orange", "zarg‘aldoq", "оранжевый"),
    "dark-orange": ("dark orange", "to‘q zarg‘aldoq", "тёмно-оранжевый"),
    "yellow": ("yellow", "sariq", "жёлтый"),
    "deep-yellow": ("deep yellow", "to‘q sariq", "насыщенно-жёлтый"),
    "yellow-orange": ("yellow-orange", "sariq-zarg‘aldoq", "жёлто-оранжевый"),
    "yellow-brown": ("yellow-brown", "sariq-qo‘ng‘ir", "жёлто-коричневый"),
    "yellow-green": ("yellow-green", "sariq-yashil", "жёлто-зелёный"),
    "green-yellow": ("greenish yellow", "yashil-sariq", "зеленовато-жёлтый"),
    "green": ("green", "yashil", "зелёный"),
    "bright-green": ("bright green", "yorqin yashil", "ярко-зелёный"),
    "dark-green": ("dark green", "to‘q yashil", "тёмно-зелёный"),
    "light-green": ("light green", "och yashil", "светло-зелёный"),
    "dirty-green": ("dirty green", "iflos yashil", "грязно-зелёный"),
    "emerald-green": ("emerald green", "zumrad yashil", "изумрудно-зелёный"),
    "brown-green": ("brownish green", "qo‘ng‘ir-yashil", "коричнево-зелёный"),
    "light-brown-green": ("light brownish green", "och qo‘ng‘ir-yashil", "светло-коричнево-зелёный"),
    "blue": ("blue", "ko‘k", "синий"),
    "dirty-blue": ("dirty blue", "iflos ko‘k", "грязно-синий"),
    "blue-green": ("blue-green", "ko‘k-yashil", "сине-зелёный"),
    "pale-blue": ("light blue", "havorang", "голубой"),
    "greenish-blue": ("greenish blue", "zangori", "зеленовато-синий"),
    "dark-blue": ("dark blue", "to‘q ko‘k", "тёмно-синий"),
    "brown": ("brown", "qo‘ng‘ir", "коричневый"),
    "light-brown": ("light brown", "och qo‘ng‘ir", "светло-коричневый"),
    "dark-brown": ("dark brown", "to‘q qo‘ng‘ir", "тёмно-коричневый"),
    "black": ("black", "qora", "чёрный"),
    "blue-black": ("blue-black", "ko‘kimtir-qora", "синевато-чёрный"),
    "green-black": ("green-black", "yashil-qora", "зеленовато-чёрный"),
    "grey": ("grey", "kulrang", "серый"),
    "light-grey": ("light grey", "och kulrang", "светло-серый"),
    "colourless": ("no colour", "rang hosil bo‘lmaydi", "окраска не возникает"),
    "red-purple-ish": ("reddish-violet", "qizg‘ish-binafsha rang", "красновато-фиолетовый"),
    "cloudy-white": ("white turbidity", "oq loyqa", "белая муть"),
    "purple-red": ("purple-red", "binafsha-qizil", "пурпурно-красный"),
    "violet-red-ink": ("ink-coloured (dark)", "siyoh rang", "чернильный (тёмный)"),
    "wine-pink": ("pink-violet", "pushti-binafsha", "розово-фиолетовый"),
    "red-bluish": ("bluish red", "ko‘kish qizil", "синевато-красный"),
    "pinkish-yellow": ("yellowish pink", "sarg‘ish-pushti", "желтовато-розовый"),
    "light-yellow": ("light yellow", "och sariq", "светло-жёлтый"),
    "deep-red": ("deep red", "to‘q qizil", "тёмно-красный"),
    "red-ish-pink": ("reddish pink", "qizg‘ish pushti", "красновато-розовый"),
    "pink-then-blue-then-darkpink": ("pink", "pushti", "розовый"),
    "dark-red-brown": ("dark red-brown", "to‘q qizil-qo‘ng‘ir", "тёмно-красно-коричневый"),
    "brown-yellow-grey": ("grey", "kulrang", "серый"),
    "yellowish-brown": ("yellowish brown", "sarg‘ish-qo‘ng‘ir", "желтовато-коричневый"),
    "light-greenish-yellow": ("light green", "och yashil", "светло-зелёный"),
    "dark-violet": ("dark violet", "to‘q binafsha", "тёмно-фиолетовый"),
    "dark-pink": ("dark pink", "to‘q pushti", "тёмно-розовый"),
    "lemon-yellow": ("lemon yellow", "limon sariq", "лимонно-жёлтый"),
    "ink-blue": ("blue", "ko‘k", "синий"),
    "zangori-violet": ("violet with a green-blue tint", "zangori-binafsha", "зеленовато-синевато-фиолетовый"),
}


def colours(seq, lang):
    i = LANGS.index(lang)
    return " → ".join(COLOURS[c][i] for c in seq)


# --------------------------------------------------------------------------
# Reagents; recipe ids link to bundle.json recipes[] (owner's compilation)
# --------------------------------------------------------------------------
R = {
    "marquis": ("Marquis reagent", "Marki reaktivi", "реактив Марки", "recipe-marquis"),
    "mecke": ("Mecke reagent", "Mecke reaktivi", "реактив Мекке", "recipe-mecke"),
    "mandelin": ("Mandelin reagent", "Mandelin reaktivi", "реактив Манделина", "recipe-mandelin"),
    "frohde": ("Fröhde reagent", "Frede reaktivi", "реактив Фреде", "recipe-frohde"),
    "erdmann": ("Erdmann reagent", "Erdman reaktivi", "реактив Эрдмана", "recipe-erdmann"),
    "dragendorff": ("Dragendorff reagent", "Dragendorf reaktivi", "реактив Драгендорфа", "recipe-dragendorff"),
    "dragendorff_munier": ("Dragendorff reagent, Munier modification", "Dragendorf reaktivi (Myunye modifikatsiyasi)",
                           "реактив Драгендорфа (модификация Мунье)", "recipe-dragendorff-munier"),
    "wagner": ("Wagner reagent (iodine in potassium iodide)", "Vagner reaktivi (yodning kaliy yodiddagi eritmasi)",
               "реактив Вагнера (раствор иода в иодиде калия)", "recipe-wagner"),
    "cobalt_thiocyanate": ("cobalt thiocyanate", "kobalt rodanid (kobalt tiotsianat)", "роданид кобальта (тиоцианат кобальта)",
                           "recipe-cobalt-thiocyanate"),
    "scott": ("modified cobalt thiocyanate (Scott) test", "o‘zgartirilgan kobalt tiotsianat (Skott) sinamasi",
              "модифицированная реакция с тиоцианатом кобальта (Скотта)", "recipe-cobalt-thiocyanate"),
    "duquenois": ("Duquenois reagent", "Duquenois reaktivi", "реактив Дюкенуа", "recipe-duquenois"),
    "duquenois_levine": ("Duquenois–Levine test", "Duquenois–Levine sinamasi", "реакция Дюкенуа—Левина", "recipe-duquenois"),
    "nessler": ("Nessler reagent", "Nessler reaktivi", "реактив Несслера", "recipe-nessler"),
    "trinder": ("Trinder reagent", "Trinder reaktivi", "реактив Триндера", "recipe-trinder"),
    "bromine_water": ("bromine water", "bromli suv", "бромная вода", "recipe-bromine-water"),
    "fuchsin_sulfurous": ("fuchsin–sulfurous acid", "fuksin–sulfit kislota", "фуксинсернистая кислота",
                          "recipe-fuchsin-sulfurous-acid"),
    "k2cr2o7": ("potassium dichromate", "kaliy dixromat", "дихромат калия", "recipe-potassium-dichromate-solution"),
    "lead_acetate_paper": ("lead acetate paper", "qo‘rg‘oshin atsetat qog‘ozi", "бумага с ацетатом свинца",
                           "recipe-lead-acetate-paper"),
    "hgbr2_paper": ("mercury(II) bromide paper (Sanger–Black)", "simob(II) bromid qog‘ozi (Sanger–Blek)",
                    "бумага с бромидом ртути(II) (Зангер—Блэк)", "recipe-mercury-halide-paper"),
    "ag_ddc": ("silver diethyldithiocarbamate in pyridine", "kumush dietilditiokarbamat (piridinda)",
               "диэтилдитиокарбамат серебра (в пиридине)", "recipe-silver-diethyldithiocarbamate-pyridine"),
    "dithizone": ("dithizone", "ditizon", "дитизон", "recipe-dithizone-solution"),
    "diazo_sulfanilic": ("diazotised sulfanilic acid", "diazotirlangan sulfanil kislota", "диазотированная сульфаниловая кислота",
                         "recipe-diazotised-sulfanilic-acid"),
    "molybdate": ("ammonium molybdate", "ammoniy molibdat", "молибдат аммония", "recipe-ammonium-molybdate-solution"),
    "fpn": ("FPN reagent", "FPN reaktivi", "реактив ФПН", "recipe-fpn"),
    # reagents without a recipe in the owner's compilation
    "nitric": ("concentrated nitric acid", "konsentrlangan nitrat kislota", "концентрированная азотная кислота", None),
    "sulfuric": ("concentrated sulfuric acid", "konsentrlangan sulfat kislota", "концентрированная серная кислота", None),
    "hcl_conc": ("concentrated hydrochloric acid", "konsentrlangan xlorid kislota", "концентрированная соляная кислота", None),
    "fecl3": ("iron(III) chloride", "temir(III) xlorid", "хлорид железа(III)", None),
    "fe2so43": ("iron(III) sulfate (UNODC reagent 2)", "temir(III) sulfat (UNODC 2-reaktiv)",
                "сульфат железа(III) (реактив 2 UNODC)", None),
    "k3fe": ("potassium hexacyanoferrate(III) with iron(III) chloride", "kaliy geksasianoferrat(III) va temir(III) xlorid",
             "гексацианоферрат(III) калия с хлоридом железа(III)", None),
    "fast_blue_b": ("Fast Blue B salt", "Mustahkam ko‘k B tuzi", "соль прочного синего Б", None),
    "pauli": ("Pauli reagent (diazotised sulfanilic acid in sodium carbonate)",
              "Pauli reaktivi (natriy karbonatdagi diazotirlangan sulfanil kislota)",
              "реактив Паули (диазотированная сульфаниловая кислота в карбонате натрия)", None),
    "beke": ("Beke reagent (sulfuric acid–ethanol)", "Buke reaktivi (sulfat kislota–etanol)",
             "реактив Бёке (серная кислота—этанол)", None),
    "simon": ("Simon test", "Simon sinamasi", "реакция Саймона", None),
    "simon_acetone": ("Simon test with acetone", "Simon sinamasi (aseton bilan)", "реакция Саймона с ацетоном", None),
    "gallic": ("gallic acid test", "galla kislotasi sinamasi", "реакция с галловой кислотой", None),
    "zimmermann": ("Zimmermann test", "Simmerman sinamasi", "реакция Циммермана", None),
    "vitali": ("Vitali–Morin test", "Vitali–Moren sinamasi", "реакция Витали—Морена", None),
    "hcl_test": ("hydrochloric acid test", "xlorid kislota sinamasi", "реакция с соляной кислотой", None),
    "dille": ("Dille–Koppanyi test", "Dille–Koppani sinamasi", "реакция Дилле—Коппаньи", None),
    "co_ammonia": ("cobalt salt with ammonia and methanol", "kobalt tuzi, ammiak va metanol", "соль кобальта с аммиаком и метанолом", None),
    "co_ipa": ("cobalt acetate with isopropylamine (in chloroform)", "kobalt atsetat va izopropilamin (xloroformda)",
              "ацетат кобальта с изопропиламином (в хлороформе)", None),
    "isonitroso": ("isonitrosobarbituric acid iron complex", "izonitrozobarbitur kislotaning temirli kompleksi",
                   "железный комплекс изонитрозобарбитуровой кислоты", None),
    "ninhydrin": ("ninhydrin", "ningidrin", "нингидрин", None),
    "ehrlich": ("Ehrlich reagent (p-dimethylaminobenzaldehyde)", "Erlix reaktivi (p-dimetilaminobenzaldegid)",
                "реактив Эрлиха (п-диметиламинобензальдегид)", None),
    "van_urk": ("van Urk reagent (p-dimethylaminobenzaldehyde, H2SO4, iron(III) chloride)",
                "van-Urk reaktivi (p-dimetilaminobenzaldegid, H2SO4, temir(III) xlorid)",
                "реактив ван Урка (п-диметиламинобензальдегид, H2SO4, хлорид железа(III))", None),
    "liebermann": ("Liebermann reagent", "Libermann reaktivi", "реактив Либермана", None),
    "h2so4_hno3": ("concentrated sulfuric and nitric acids (1:1)", "konsentrlangan sulfat va nitrat kislotalar (1:1)",
                   "концентрированные серная и азотная кислоты (1:1)", None),
    "citric_ac2o": ("citric acid in acetic anhydride (1%), on heating", "limon kislotaning sirka angidriddagi 1% eritmasi (qizdirilganda)",
                    "1% раствор лимонной кислоты в уксусном ангидриде (при нагревании)", None),
    "k2cr2o7_h2so4": ("potassium dichromate with concentrated H2SO4", "kaliy dixromat va konsentrlangan H2SO4",
                      "дихромат калия с концентрированной H2SO4", None),
    "cuso4_ether": ("copper sulfate and sodium hydroxide, ether layer", "mis sulfat va natriy ishqori (efir qatlami)",
                    "сульфат меди и гидроксид натрия (эфирный слой)", None),
    "nitrite_naphthol": ("reduction, then sodium nitrite and β-naphthol", "qaytarish, so‘ng natriy nitrit va β-naftol",
                         "восстановление, затем нитрит натрия и β-нафтол", None),
    "cuso4_cs2": ("copper sulfate and carbon disulfide (benzene layer)", "mis sulfat va oltingugurt uglerodi (benzol qatlami)",
                  "сульфат меди и сероуглерод (бензольный слой)", None),
    "bratton": ("Bratton–Marshall reaction after acid hydrolysis", "kislotali gidrolizdan keyingi Bratton–Marshall reaksiyasi",
                "реакция Браттона—Маршалла после кислотного гидролиза", None),
    "belstein": ("Beilstein flame test (copper wire)", "Beylshteyn sinamasi (mis sim)", "проба Бейльштейна (медная проволока)", None),
    "salicyl_methyl": ("heating with methanol and concentrated H2SO4 (methyl salicylate odour)",
                       "metanol va konsentrlangan H2SO4 bilan qizdirish (metilsalitsilat hidi)",
                       "нагревание с метанолом и концентрированной H2SO4 (запах метилсалицилата)", None),
    "iodoform": ("iodoform reaction (iodine in alkali)", "yodoform reaksiyasi (yodning ishqordagi eritmasi)",
                 "иодоформная реакция (иод в щёлочи)", None),
    "nitroprusside": ("sodium nitroprusside in alkali", "natriy nitroprussid (ishqoriy muhitda)", "нитропруссид натрия в щёлочи", None),
    "fehling_resorcinol": ("alkaline resorcinol on heating", "ishqoriy rezorsin (qizdirilganda)", "щелочной резорцин при нагревании", None),
    "prussian": ("iron(II) sulfate, then acidification (Prussian blue)", "temir(II) sulfat, so‘ng nordonlashtirish (Berlin zangorisi)",
                 "сульфат железа(II) с последующим подкислением (берлинская лазурь)", None),
    "marsh": ("Marsh test", "Marsh sinamasi", "проба Марша", None),
    "malachite": ("malachite green (or brilliant green) in toluene", "malaxit yashili (yoki brilliant yashili), toluolda",
                  "малахитовый зелёный (или бриллиантовый зелёный) в толуоле", None),
    "cholinesterase": ("cholinesterase inhibition", "xolinesterazani ingibirlash", "ингибирование холинэстеразы", None),
    "spectroscope": ("hand spectroscope (visible-region absorption bands)", "spektroskop (ko‘rinadigan sohadagi yutilish yo‘llari)",
                     "спектроскоп (полосы поглощения в видимой области)", None),
    "formaldehyde_codeine": ("codeine with concentrated sulfuric acid", "kodein va konsentrlangan sulfat kislota", "кодеин с концентрированной серной кислотой", None),
    "dichromate_bio": ("dichromate oxidation", "bixromat bilan oksidlash", "окисление дихроматом", None),
}


def reagent(key, lang):
    return R[key][LANGS.index(lang)]


def recipe_of(key):
    return R[key][3]


# --------------------------------------------------------------------------
# Solvent components for TLC mobile phases
# --------------------------------------------------------------------------
SOLV = {
    "EtOAc": ("ethyl acetate", "etilatsetat", "этилацетат"),
    "MeOH": ("methanol", "metanol", "метанол"),
    "NH3": ("25% ammonia solution", "ammiakning 25% eritmasi", "25% раствор аммиака"),
    "CHCl3": ("chloroform", "xloroform", "хлороформ"),
    "Me2CO": ("acetone", "aseton", "ацетон"),
    "Et2NH": ("diethylamine", "dietilamin", "диэтиламин"),
    "C6H12": ("cyclohexane", "siklogeksan", "циклогексан"),
    "PhMe": ("toluene", "toluol", "толуол"),
    "diox": ("dioxane", "dioksan", "диоксан"),
    "PhH": ("benzene", "benzol", "бензол"),
    "EtOH": ("ethanol", "etanol", "этанол"),
    "Et2O": ("diethyl ether", "dietil efiri", "диэтиловый эфир"),
    "AcOH": ("glacial acetic acid", "muzlovchi sirka kislota", "ледяная уксусная кислота"),
    "BuOH": ("n-butanol", "n-butanol", "н-бутанол"),
    "hexane": ("hexane", "geksan", "гексан"),
    "H2O": ("water", "suv", "вода"),
    "iPrOH": ("isopropanol", "izopropanol", "изопропанол"),
    "DMF": ("dimethylformamide", "dimetilformamid", "диметилформамид"),
    "EtCOOH": ("propionic acid", "propion kislota", "пропионовая кислота"),
    "PrOH": ("propanol", "propanol", "пропанол"),
    "NH4OH": ("25% ammonium hydroxide", "ammoniy gidroksidning 25% eritmasi", "25% гидроксид аммония"),
    "EtOH_NH3": ("ethanol–25% ammonia solution (1:1)", "etanol–ammiakning 25% eritmasi (1:1)", "этанол—25% раствор аммиака (1:1)"),
    "iAmOH": ("isoamyl alcohol", "izoamil spirti", "изоамиловый спирт"),
}


def system(parts, lang):
    """parts: [("EtOAc", 17), ("MeOH", 2), ...] → «ethyl acetate–methanol–… (17:2:1)»"""
    i = LANGS.index(lang)
    names = "–".join(SOLV[k][i] for k, _ in parts)
    ratio = ":".join(str(v) for _, v in parts)
    return f"{names} ({ratio})"


PLATES = {
    "silica": ("silica gel", "silikagel", "силикагель"),
    "silica_g": ("silica gel G (Merck)", "silikagel G (Merck)", "силикагель G (Merck)"),
    "silufol": ("Silufol", "Silufol", "Силуфол"),
    "sorbfil": ("Sorbfil", "Sorbfil", "Сорбфил"),
    "silufol_uv": ("Silufol UV-254", "Silufol UV-254", "Силуфол UV-254"),
    "ksk": ("silica gel KSK", "silikagel KSK", "силикагель KSK"),
    "merck": ("Merck plate", "Merck plastinkasi", "пластинка Merck"),
    "silica_koh": ("silica gel treated with 0.1 mol/L KOH", "0,1 mol/L KOH bilan ishlangan silikagel",
                   "силикагель, обработанный 0,1 моль/л KOH"),
    "paper": ("chromatography paper (DMF-saturated)", "xromatografik qog‘oz (DMF bilan to‘yintirilgan)",
              "хроматографическая бумага (насыщенная ДМФА)"),
    "silica_dmf": ("silica gel plate impregnated with dimethylformamide", "dimetilformamid shimdirilgan silikagel plastinka",
                   "пластинка с силикагелем, пропитанная диметилформамидом"),
    "sorbton": ("Sorbton / Sorbfil / Kieselgel G 60", "Sorbton / Sorbfil / Kizelgel G 60", "Сорбтон / Сорбфил / Kieselgel G 60"),
    "not_stated": ("plate not stated in the source", "manbada plastinka ko‘rsatilmagan", "пластинка в источнике не указана"),
}

VIS = {
    "marquis_or_frohde": ("Marquis or Fröhde reagent", "Marki yoki Frede reaktivi", "реактив Марки или Фреде"),
    "dragendorff_munier": ("Dragendorff reagent (Munier modification)", "Dragendorf reaktivi (Myunye modifikatsiyasi)",
                           "реактив Драгендорфа (модификация Мунье)"),
    "dragendorff": ("Dragendorff reagent", "Dragendorf reaktivi", "реактив Драгендорфа"),
    "iodoplatinate": ("acidified iodoplatinate reagent", "kislotali yodplatinat reaktivi", "подкисленный иодоплатинатный реактив"),
    "iodoplatinate_plain": ("potassium iodoplatinate", "kaliy yodplatinat", "иодоплатинат калия"),
    "mandelin": ("Mandelin reagent", "Mandelin reaktivi", "реактив Манделина"),
    "fast_blue": ("Fast Blue B or Pauli reagent", "Mustahkam ko‘k B yoki Pauli reaktivi", "прочный синий Б или реактив Паули"),
    "ninhydrin": ("ninhydrin in acetone", "ningidrinning asetondagi eritmasi", "раствор нингидрина в ацетоне"),
    "uv_366_ehrlich": ("UV light (366 nm), then Ehrlich reagent", "UB nuri (366 nm), so‘ng Erlix reaktivi",
                       "УФ-свет (366 нм), затем реактив Эрлиха"),
    "uv_dragendorff": ("UV light (254 nm) and Dragendorff reagent", "UB nuri (254 nm) va Dragendorf reaktivi",
                       "УФ-свет (254 нм) и реактив Драгендорфа"),
    "uv_iodoplat_dragendorff": ("UV light, potassium iodoplatinate, Dragendorff reagent (Munier modification)",
                                "UB nuri, kaliy yodplatinat, Dragendorf reaktivi (Myunye modifikatsiyasi)",
                                "УФ-свет, иодоплатинат калия, реактив Драгендорфа (модификация Мунье)"),
    "h2so4_etoh": ("concentrated H2SO4–ethanol (1:9) or Marquis reagent", "konsentrlangan H2SO4–etanol (1:9) yoki Marki reaktivi",
                   "концентрированная H2SO4—этанол (1:9) или реактив Марки"),
    "h2so4_drop": ("a drop of concentrated H2SO4", "konsentrlangan H2SO4 tomchisi", "капля концентрированной H2SO4"),
    "diphenylcarbazone": ("diphenylcarbazone solution, then mercury sulfate solution",
                          "difenilkarbazon eritmasi, so‘ng simob sulfat eritmasi", "раствор дифенилкарбазона, затем раствор сульфата ртути"),
    "thiosulfate": ("sodium thiosulfate solution", "natriy tiosulfat eritmasi", "раствор тиосульфата натрия"),
    "dragendorff_brown": ("Dragendorff reagent (brown spot)", "Dragendorf reaktivi (qo‘ng‘ir dog‘)", "реактив Драгендорфа (коричневое пятно)"),
    "uv_only": ("UV light, Dragendorff and Mandelin reagents", "UB nuri, Dragendorf va Mandelin reaktivlari",
                "УФ-свет, реактивы Драгендорфа и Манделина"),
    "marquis": ("Marquis reagent", "Marki reaktivi", "реактив Марки"),
    "h2so4_etoh_1": ("concentrated H2SO4–ethanol (1:9) or Marquis reagent", "konsentrlangan H2SO4–etanol (1:9) yoki Marki reaktivi",
                     "концентрированная H2SO4—этанол (1:9) или реактив Марки"),
    "iodoplat_iodine": ("acidified iodoplatinate (orange-brown spot), iodine vapour (dark blue spot)",
                        "kislotali yodplatinat (zarg‘aldoq-qo‘ng‘ir dog‘), yod bug‘lari (to‘q ko‘k dog‘)",
                        "подкисленный иодоплатинат (оранжево-коричневое пятно), пары иода (тёмно-синее пятно)"),
    "bromophenol_acetic": ("bromophenol blue reagent, then 5% acetic acid", "bromfenol ko‘ki reaktivi, so‘ng 5% sirka kislota",
                           "реактив бромфеноловый синий, затем 5% уксусная кислота"),
    "none_stated": ("visualisation not stated in the source", "manbada ochuvchi reagent ko‘rsatilmagan",
                    "проявляющий реагент в источнике не указан"),
}

# --------------------------------------------------------------------------
# Fixed sentences
# --------------------------------------------------------------------------
TAG = {
    "presumptive": (
        "Presumptive result only: it cannot establish identity by itself.",
        "Faqat taxminiy natija: u o‘zi bilan modda aynanligini isbotlay olmaydi.",
        "Только предположительный результат: сам по себе он не устанавливает идентичность.",
    ),
    "tlc": (
        "Presumptive result only: identity needs comparison with a reference standard run on the same plate and an orthogonal method.",
        "Faqat taxminiy natija: aynanlikni aniqlash uchun xuddi shu plastinkada yurgizilgan standart bilan taqqoslash va ortogonal usul kerak.",
        "Только предположительный результат: для установления идентичности нужны сравнение со стандартом, пропущенным на той же пластинке, и ортогональный метод.",
    ),
    "micro": (
        "Presumptive result only: many substances form crystals of similar shape, so a crystal test cannot establish identity by itself and needs a comparison control.",
        "Faqat taxminiy natija: ko‘p moddalar o‘xshash shakldagi kristallar hosil qiladi, shuning uchun kristall sinamasi o‘zi bilan aynanlikni isbotlay olmaydi va solishtirma nazorat kerak.",
        "Только предположительный результат: многие вещества образуют кристаллы сходной формы, поэтому кристаллическая проба сама по себе не устанавливает идентичность и требует контрольного сравнения.",
    ),
    "uv": (
        "Supporting evidence only: a UV spectrum does not identify a compound by itself, because compounds with similar chromophores have similar maxima.",
        "Faqat yordamchi dalil: UB-spektr o‘zi bilan birikmani aniqlamaydi, chunki o‘xshash xromofor guruhli birikmalarning maksimumlari o‘xshash bo‘ladi.",
        "Только вспомогательное свидетельство: УФ-спектр сам по себе не идентифицирует соединение, так как соединения со сходными хромофорами имеют сходные максимумы.",
    ),
    "supporting": (
        "Supporting evidence only: it does not establish identity by itself.",
        "Faqat yordamchi dalil: u o‘zi bilan aynanlikni isbotlamaydi.",
        "Только вспомогательное свидетельство: само по себе оно не устанавливает идентичность.",
    ),
    "immuno": (
        "Screening result only: immunoassay results are presumptive and need confirmation by a mass-spectrometric method.",
        "Faqat skrining natijasi: immunoanaliz natijalari taxminiy bo‘lib, mass-spektrometrik usul bilan tasdiqlanishi kerak.",
        "Только результат скрининга: результаты иммуноанализа предположительные и требуют подтверждения масс-спектрометрическим методом.",
    ),
    "instrumental": (
        "Instrumental method: confirmation needs a validated method and a comparison with a reference standard; it may be unavailable in a local laboratory.",
        "Instrumental usul: tasdiqlash uchun validatsiyadan o‘tgan usul va standart bilan taqqoslash kerak; mahalliy laboratoriyada mavjud bo‘lmasligi mumkin.",
        "Инструментальный метод: для подтверждения нужны валидированный метод и сравнение со стандартом; в местной лаборатории он может быть недоступен.",
    ),
    "odour": (
        "Presumptive result only: an odour is a subjective observation and cannot establish identity.",
        "Faqat taxminiy natija: hid sub’ektiv kuzatuv bo‘lib, aynanlikni isbotlay olmaydi.",
        "Только предположительный результат: запах — субъективное наблюдение и не устанавливает идентичность.",
    ),
    "physical": (
        "Supporting evidence only: a melting point is a general physical characteristic and does not identify a substance by itself.",
        "Faqat yordamchi dalil: suyuqlanish harorati umumiy fizik xarakteristika bo‘lib, moddani o‘zi bilan aniqlamaydi.",
        "Только вспомогательное свидетельство: температура плавления — общая физическая характеристика и сама по себе не идентифицирует вещество.",
    ),
}

FAMILY_LABEL = {
    "colour_test": ("Colour (spot) test", "Rangli (tomchi) sinama", "Цветная (капельная) реакция"),
    "odour_test": ("Odour test", "Hid bo‘yicha sinama", "Проба по запаху"),
    "tlc": ("Thin-layer chromatography (TLC)", "Yupqa qatlamli xromatografiya (TLC)", "Тонкослойная хроматография (TLC)"),
    "microcrystal": ("Microcrystalline test", "Mikrokristalloskopik sinama", "Микрокристаллоскопическая проба"),
    "uv_spectrum": ("UV absorption", "UB yutilish", "УФ-поглощение"),
    "photometric": ("Photometric / colorimetric determination", "Fotometrik / kolorimetrik aniqlash", "Фотометрическое / колориметрическое определение"),
    "immunoassay": ("Immunoassay screening", "Immunoanaliz skriningi", "Иммуноанализ (скрининг)"),
    "instrumental": ("Instrumental confirmatory method", "Instrumental tasdiqlovchi usul", "Инструментальный подтверждающий метод"),
    "physical": ("Melting point", "Suyuqlanish harorati", "Температура плавления"),
    "caveat": ("Known limitation / interference", "Ma’lum cheklov / halaqit beruvchi omil", "Известное ограничение / помеха"),
    "spectroscopy": ("Spectroscopy", "Spektroskopiya", "Спектроскопия"),
    "chemical": ("Chemical reaction", "Kimyoviy reaksiya", "Химическая реакция"),
}
