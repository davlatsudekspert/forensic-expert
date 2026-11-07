"""Entries part 7: substances added on 2026-11-07 (content/tools/add_substances_20261107.py).

The four sources of part 6 (and one already-located line of the 2024 teaching book) give methods
for substances that were not in the bundle: barbital, amobarbital (barbamil), butobarbital,
hexobarbital (geksenal), benzobarbital (benzonal), promethazine (diprazin), levomepromazine
(tizersin), chlordiazepoxide, nitrazepam, ergotamine, ergometrine, the pyrethroids cypermethrin,
deltamethrin (Decis) and fenpropathrin (Danitol), and the neonicotinoids imidacloprid and
acetamiprid.

Same rules as parts 1–6: every value as printed, exact locator, paraphrase only, no
reagent-preparation recipes, garbled items skipped. Skipped on purpose:
  * lysergic acid — the sources give it only in test questions, no method text;
  * NARK table 5 (p. 24, benzophenones) — garbled, as in part 6;
  * the last, cut-off row of the YuSSX benzodiazepine table (a chlordiazepoxide metabolite);
  * thiamethoxam and thiacloprid — only named in a list (PRIM printed p. 31), no method;
  * the 2024 teaching book (GMT) sections on these substances — the copy available in this
    session has no page markers, so no exact PDF-page locator can be given (except the van Urk
    line, PDF p. 96, already located in part 2).

Class entries of part 6 (barbiturates, 1,4-benzodiazepines, phenothiazines) are extended to the
new members of the class: the source states them for the class as a whole.
"""
from sm_core import N, colour, generic, isolation, loc, micro, tlc, tlc_free, uv, ysec
from substance_methods_data import E, add
import substance_methods_data6 as d6

NEW_BARB = ["barbital", "amobarbital", "butobarbital", "hexobarbital"]
NEW_BZD = ["chlordiazepoxide", "nitrazepam"]
NEW_PTZ = ["promethazine", "levomepromazine"]
PART6_SRC = ("YUSSX", "NARK", "PRIM")


def _extend(old_subs, new_subs, families=None, replace=None):
    """Copy part-6 class entries (same text, same locator) to the new class members."""
    picked = [e for e in E if e["src"] in PART6_SRC and e["subs"] == old_subs
              and (families is None or e["family"] in families)]
    assert picked, old_subs
    for e in picked:
        c = dict(e, subs=list(new_subs))
        if replace:
            text = dict(c["text"])
            for lang, (a, b) in replace.items():
                assert a in text[lang], (lang, a)
                text[lang] = text[lang].replace(a, b)
            c["text"] = text
        add(c)


# =============================================================== BARBITURATES
# class entries: isolation (YuSSX 3.2.1; NARK pp. 5, 10; PRIM pp. 12–14), colour, microcrystal, HPLC
_extend(d6.BARB, NEW_BARB, families={"isolation", "colour_test", "microcrystal", "instrumental"})

MICRO = {
    "chlorzinc": N("chlorzinc-iodine", "xlorsinkyod", "хлорцинкйод"),
    "fe_ki": N("iron(III) chloride–potassium iodide", "temir(III) xlorid–kaliy yodid", "хлорид железа(III)–йодид калия"),
    "cuprate": N("potassium diiodocuprate in iodine solution", "yod eritmasidagi kaliy diyodokuprat",
                 "дийодокупрат калия в растворе йода"),
    "ki_acid": N("acidified ethanolic potassium iodide", "nordonlashtirilgan spirtli kaliy yodid",
                 "подкисленный спиртовой раствор йодида калия"),
}
MICRO_EN = {"chlorzinc": "chlorzinc-iodine", "fe_ki": "iron(III) chloride–potassium iodide",
            "cuprate": "potassium diiodocuprate", "ki_acid": "acidified potassium iodide"}


def _micro_barb(sub, name, keys):
    lst = tuple("; ".join(MICRO[k][i] for k in keys) for i in range(3))
    add(micro(sub,
              N(f"{name[0]} is listed by the source among the barbiturates that give crystalline precipitates (dry residue of the chloroform extract, moist chamber, 15 min, microscope) with: {lst[0]}.",
                f"Manba {name[1]}ni quyidagi reaktivlar bilan kristall cho‘kma beradigan barbituratlar qatorida keltiradi (xloroformli ajratmaning quruq qoldig‘i, nam kamera, 15 daqiqa, mikroskop): {lst[1]}.",
                f"Источник называет {name[2]} среди барбитуратов, дающих кристаллические осадки (сухой остаток хлороформного извлечения, влажная камера, 15 мин, микроскоп) с: {lst[2]}."),
              "NARK", loc("NARK", pdf=6), reagents=[MICRO_EN[k] for k in keys]))


_micro_barb("barbital", ("Barbital", "barbital", "барбитал"), ["chlorzinc", "ki_acid"])
_micro_barb("amobarbital", ("Barbamil (amobarbital sodium)", "barbamil (amobarbital natriy)", "барбамил (амобарбитал натрия)"),
            ["chlorzinc", "fe_ki", "cuprate"])
_micro_barb("butobarbital", ("Butobarbital", "butobarbital", "бутобарбитал"), ["chlorzinc", "fe_ki", "cuprate", "ki_acid"])
_micro_barb("hexobarbital", ("Geksenal (hexobarbital sodium)", "geksenal (geksobarbital natriy)", "гексенал (гексобарбитал натрия)"),
            ["ki_acid"])

for sub, (a, b_, c) in {"barbital": ("0.31", "0.41", "0.51"), "amobarbital": ("0.36", "0.52", "0.74"),
                        "butobarbital": ("0.38", "0.50", "0.68")}.items():
    add(tlc(sub, d6.SYS_ABC, "silica_g_act", "uv254_hg_dpc", "NARK", loc("NARK", pdf=10, to=11, tbl=3),
            rf=[(d6.A_, a), (d6.B_, b_), (d6.C_, c)], note=d6.TLC_BARB_NOTE))
add(tlc("amobarbital", [("CHCl3", 70), ("BuOH", 40), ("NH3", 5)], "not_stated", "dpc_hgso4", "NARK",
        loc("NARK", pdf=10, to=11),
        note=N("Given in the source for barbamil (amobarbital sodium): the chloroform extract of the acidic solution is applied with a reference (0.01% solution in methanol) 2 cm away, developed to 10 cm; barbiturate spots are blue-violet or red-violet.",
               "Manbada barbamil (amobarbital natriy) uchun keltirilgan: kislotali eritmaning xloroformli ajratmasi 2 sm narida standart (metanoldagi 0,01% eritma) bilan tomiziladi, 10 sm gacha ko‘tariladi; barbiturat dog‘lari ko‘k-binafsha yoki qizil-binafsha.",
               "Приведено в источнике для барбамила (амобарбитал натрия): хлороформное извлечение из кислого раствора наносят вместе со стандартом (0,01% раствор в метаноле) на расстоянии 2 см, хроматографируют до 10 см; пятна барбитуратов сине-фиолетовые или красно-фиолетовые.")))


def _uv_barb(sub, name, group, ph13):
    add(generic(sub, "uv_spectrum",
                N(f"UV absorption of the residue dissolved in 5 mL of water: the source names {name[0]} among the {group[0]} barbiturates, which show a maximum at about 240 nm at pH ~10 (1 drop of 2 M ammonia); at pH ~2 (2 M sulfuric acid) this maximum disappears; at pH ~13 (4 M sodium hydroxide) a maximum appears at {ph13} nm.",
                  f"5 ml suvda eritilgan qoldiqning UB yutilishi: manba {name[1]}ni {group[1]} barbituratlar qatorida nomlaydi; ular pH ~10 da (1 tomchi 2 M ammiak) taxminan 240 nm da maksimum beradi; pH ~2 da (2 M sulfat kislota) bu maksimum yo‘qoladi; pH ~13 da (4 M natriy gidroksid) {ph13} nm da maksimum paydo bo‘ladi.",
                  f"УФ-поглощение остатка, растворённого в 5 мл воды: источник называет {name[2]} среди {group[2]} барбитуратов, которые при pH ~10 (1 капля 2 М аммиака) имеют максимум около 240 нм; при pH ~2 (2 М серная кислота) этот максимум исчезает; при pH ~13 (4 М гидроксид натрия) появляется максимум при {ph13} нм."),
                "NARK", loc("NARK", pdf=15), "uv", "supporting", cat="B"))


G55 = ("5,5-substituted", "5,5-o‘rinbosarli", "5,5-замещённых")
_uv_barb("barbital", ("barbital", "barbital", "барбитал"), G55, "255")
_uv_barb("amobarbital", ("barbamil (amobarbital sodium)", "barbamil (amobarbital natriy)", "барбамил (амобарбитал натрия)"), G55, "255")
_uv_barb("butobarbital", ("butobarbital", "butobarbital", "бутобарбитал"), G55, "255")
_uv_barb("hexobarbital", ("geksenal (hexobarbital)", "geksenal (geksobarbital)", "гексенал (гексобарбитал)"),
         ("1,5,5-substituted", "1,5,5-o‘rinbosarli", "1,5,5-замещённых"), "240")

PHOTO_TAIL = N("or differential spectrophotometry: ΔD = D(pH 13) − D(pH 10) at 260 nm, calculated with the specific absorbance of a reference standard measured at the same pH values.",
               "yoki differensial spektrofotometriya: 260 nm da ΔD = D(pH 13) − D(pH 10), xuddi shu pH qiymatlarida o‘lchangan standart namunaning solishtirma nur yutish ko‘rsatkichi bo‘yicha hisoblanadi.",
               "или дифференциальная спектрофотометрия: ΔD = D(pH 13) − D(pH 10) при 260 нм, расчёт по удельному показателю поглощения стандартного образца при тех же pH.")


def _photo_barb(sub, residue):
    add(generic(sub, "photometric",
                N(f"Quantitation after isolation with water acidified with sulfuric acid: photocolorimetry of the violet cobalt acetate (0.125% in methanol) – isopropylamine (50% in methanol) complex (green filter, 20 mm cell), {residue[0]}; {PHOTO_TAIL[0]}",
                  f"Sulfat kislota bilan nordonlashtirilgan suv bilan ajratilgandan keyin miqdoriy aniqlash: binafsha rangli kobalt atsetat (metanolda 0,125%) – izopropilamin (metanolda 50%) kompleksini fotokolorimetriya qilish (yashil svetofiltr, 20 mm kyuveta), {residue[1]}; {PHOTO_TAIL[1]}",
                  f"Количественное определение после изолирования водой, подкисленной серной кислотой: фотоколориметрия фиолетового комплекса ацетат кобальта (0,125% в метаноле) – изопропиламин (50% в метаноле) (зелёный светофильтр, кювета 20 мм), {residue[2]}; {PHOTO_TAIL[2]}"),
                "NARK", loc("NARK", pdf=15, to=16), "supporting", "supporting"))


_photo_barb("barbital", N("the dry residue of barbital being dissolved in 6 mL of chloroform",
                          "bunda barbital quruq qoldig‘i 6 ml xloroformda eritiladi",
                          "причём сухой остаток барбитала растворяют в 6 мл хлороформа"))
_photo_barb("hexobarbital", N("the dry residue of geksenal being dissolved in 6 mL of chloroform",
                              "bunda geksenal quruq qoldig‘i 6 ml xloroformda eritiladi",
                              "причём сухой остаток гексенала растворяют в 6 мл хлороформа"))
_photo_barb("amobarbital", N("the dry residue of barbamil being dissolved in 2 mL of methanol and made up to 6 mL with chloroform",
                             "bunda barbamil quruq qoldig‘i 2 ml metanolda eritilib, xloroform bilan 6 ml gacha yetkaziladi",
                             "причём сухой остаток барбамила растворяют в 2 мл метанола и доводят хлороформом до 6 мл"))

YUSSX_NOTE = N("Such values apply only to the stated system and need a reference standard run in the same series.",
               "Bu qiymatlar faqat ko‘rsatilgan tizimga taalluqli va xuddi shu seriyada yurgizilgan standart namunani talab qiladi.",
               "Эти значения относятся только к указанной системе и требуют стандарта, пропущенного в той же серии.")


def _yussx_data(sub, name, cond, vr, wl, ratios, sec, note=None):
    wl_en = ", ".join(wl[:-1]) + " and " + wl[-1]
    wl_uz = ", ".join(wl[:-1]) + " va " + wl[-1]
    wl_ru = ", ".join(wl[:-1]) + " и " + wl[-1]
    r_en = ", ".join(ratios)
    r_c = ", ".join(r.replace(".", ",") for r in ratios)
    main = N(f"Chromatographic data printed for {name[0]} under HPLC conditions (1) of the source ({cond[0]}): retention volume {vr} µL; UV spectral ratios S(λ)/S(210 nm) at {wl_en} nm: {r_en}. {YUSSX_NOTE[0]}",
             f"Manbaning (1) HPLC sharoitida ({cond[1]}) {name[1]} uchun keltirilgan xromatografik ma’lumotlar: ushlanish hajmi {vr} µL; {wl_uz} nm dagi UB spektral nisbatlar S(λ)/S(210 nm): {r_c}. {YUSSX_NOTE[1]}",
             f"Хроматографические данные для {name[2]} в условиях HPLC (1) источника ({cond[2]}): объём удерживания {vr} мкл; спектральные отношения УФ S(λ)/S(210 нм) при {wl_ru} нм: {r_c}. {YUSSX_NOTE[2]}")
    add(generic(sub, "instrumental", main, "YUSSX", loc("YUSSX", sec=ysec(sec)), "instrumental", "instrumental", cat="B",
                data={"methods": ["method-hplc"], "retention_volume_uL": vr}, note=note))


MIL_C18 = N("Milichrom, Separon C18", "Milixrom, Separon C18", "«Милихром», Separon C18")
WL_B = ["220", "230", "240", "250", "260", "280", "300"]
_yussx_data("barbital", ("barbital", "barbital", "барбитала"), MIL_C18, "933", WL_B,
            ["0.615", "0.088", "0.027", "0.010", "0.007", "0.000", "0.001"], "3.2.1")
_yussx_data("amobarbital", ("barbamil (amobarbital sodium)", "barbamil (amobarbital natriy)", "барбамила (амобарбитал натрия)"),
            MIL_C18, "1753", WL_B, ["0.576", "0.076", "0.03", "0.014", "0.011", "0.003", "0"], "3.2.1")

# benzobarbital (benzonal): PRIM only
add(isolation("benzobarbital",
              N("Isolation with water acidified with hydrochloric acid (method of Gruss–Hardy, given by the source for benzonal): the object is mixed with water acidified with hydrochloric acid (pH 2.0–3.0), 50 g of ammonium sulfate and 200 mL of a chloroform–ethanol mixture are added, left for 2 h and filtered; the aqueous layer is discarded, the organic layer is evaporated, the residue is taken up in hot water, filtered, cooled and extracted 3 times with chloroform; the chloroform solution is washed with phosphate buffer pH 7.4. Benzonal and its metabolite phenobarbital are sought in the chloroform layer, benzoic acid in the buffer layer.",
                "Xlorid kislota bilan nordonlashtirilgan suv yordamida ajratib olish (Gruss–Xardi usuli, manbada benzonal uchun keltirilgan): ob’ektga xlorid kislota bilan nordonlashtirilgan suv (pH 2,0–3,0) qo‘shilib aralashtiriladi, 50 g ammoniy sulfat va 200 ml xloroform–etil spirti aralashmasi qo‘shilib, 2 soat qoldiriladi va filtrlanadi; suvli qatlam tashlanadi, organik qatlam bug‘latiladi, qoldiqqa issiq suv qo‘shilib filtrlanadi, sovutiladi va 3 marta xloroform bilan ekstraksiyalanadi; xloroformli eritma pH 7,4 fosfat bufer bilan yuviladi. Xloroformli qatlamda benzonal va uning metaboliti fenobarbital, bufer qatlamida benzoy kislota tekshiriladi.",
                "Изолирование водой, подкисленной хлористоводородной кислотой (метод Грусс–Харди, приведён источником для бензонала): к объекту добавляют воду, подкисленную хлористоводородной кислотой (pH 2,0–3,0), 50 г сульфата аммония и 200 мл смеси хлороформ–этанол, оставляют на 2 ч и фильтруют; водный слой отбрасывают, органический упаривают, остаток обрабатывают горячей водой, фильтруют, охлаждают и 3 раза экстрагируют хлороформом; хлороформный раствор промывают фосфатным буфером pH 7,4. В хлороформном слое исследуют бензонал и его метаболит фенобарбитал, в буферном — бензойную кислоту."),
              "PRIM", loc("PRIM", printed=13), note=d6._with_card(None), data={"methods": ["method-lle"], "group": 3}))

# =============================================================== PHENOTHIAZINES
_extend(["chlorpromazine"], NEW_PTZ, families={"instrumental"},
        replace={"en": ("no retention value for chlorpromazine is printed", "no retention value for this substance is printed"),
                 "uz": ("aminazin uchun ushlanish qiymati keltirilmagan", "bu modda uchun ushlanish qiymati keltirilmagan"),
                 "ru": ("время удерживания аминазина не приведено", "время удерживания этого вещества не приведено")})
PTZ_CLASS = N("The source states that chlorpromazine and other phenothiazine derivatives give this colour; it does not distinguish one derivative from another.",
              "Manba bu rangni aminazin va boshqa fenotiazin hosilalari berishini bildiradi; u bir hosilani boshqasidan ajratmaydi.",
              "Источник указывает, что эту окраску дают аминазин и другие производные фенотиазина; она не различает отдельные производные.")
for sub in NEW_PTZ:
    add(colour(sub, "fecl3", ["pinkish-lilac"], "NARK", loc("NARK", pdf=18, to=19),
               note=N(f"Preliminary urine test: 1 mL of urine with 1 mL of a reagent of 10% sulfuric acid and 5% iron(III) chloride (80:20). {PTZ_CLASS[0]}",
                      f"Peshobda dastlabki sinama: 1 ml peshob va 1 ml 10% sulfat kislota hamda 5% temir(III) xlorid (80:20) reaktivi. {PTZ_CLASS[1]}",
                      f"Предварительная проба с мочой: 1 мл мочи и 1 мл реактива из 10% серной кислоты и 5% хлорида железа(III) (80:20). {PTZ_CLASS[2]}")))
    add(colour(sub, "fpn", ["pink"], "NARK", loc("NARK", pdf=19),
               note=N(f"Preliminary urine test (1 mL of urine + 1 mL of FPN reagent). {PTZ_CLASS[0]}",
                      f"Peshobda dastlabki sinama (1 ml peshob + 1 ml FPN reaktivi). {PTZ_CLASS[1]}",
                      f"Предварительная проба с мочой (1 мл мочи + 1 мл реактива FPN). {PTZ_CLASS[2]}")))

# promethazine (diprazin), NARK p. 20
PMZ_NOTE = N("The source calls the drug diprazin (promethazine); its sub-heading reads «colour reactions of aminazine», but the text describes diprazin. The test is done on the dry residue on a slide; compare with a reference standard run in parallel.",
             "Manba dorini diprazin (prometazin) deb ataydi; kichik sarlavhada «aminazinning rang reaksiyalari» deyilgan, lekin matn diprazin haqida. Sinama buyum oynasidagi quruq qoldiqda o‘tkaziladi; parallel yurgizilgan standart bilan solishtiring.",
             "Источник называет препарат дипразином (прометазин); подзаголовок гласит «реакции окрашивания аминазина», но текст описывает дипразин. Проба выполняется с сухим остатком на предметном стекле; сравнивайте со стандартом, исследуемым параллельно.")
add(colour("promethazine", "sulfuric", ["purple-red"], "NARK", loc("NARK", pdf=20), note=PMZ_NOTE))
add(colour("promethazine", "nitric", ["pale-purple-red", "yellow"], "NARK", loc("NARK", pdf=20), note=PMZ_NOTE))
add(colour("promethazine", "hcl_conc", ["pinkish-violet", "purple-violet"], "NARK", loc("NARK", pdf=20), note=PMZ_NOTE))
add(colour("promethazine", "marquis", ["purple"], "NARK", loc("NARK", pdf=20), note=PMZ_NOTE))
add(colour("promethazine", "mandelin", ["green", "purple"], "NARK", loc("NARK", pdf=20), note=PMZ_NOTE))
add(generic("promethazine", "chemical",
            N("Vitali–Morin reaction: the source states that diprazin (promethazine) gives this reaction; no colour is stated.",
              "Vitali–Moren reaksiyasi: manba diprazin (prometazin) bu reaksiyani berishini bildiradi; rang ko‘rsatilmagan.",
              "Реакция Витали—Морена: источник указывает, что дипразин (прометазин) даёт эту реакцию; окраска не указана."),
            "NARK", loc("NARK", pdf=20), "presumptive", "presumptive", reagents=["Vitali–Morin test"]))
add(tlc("promethazine", [("PhH", 75), ("diox", 20), ("NH3", 5)], "not_stated", "marquis_or_hno3_etoh", "NARK", loc("NARK", pdf=19, to=20),
        note=N("The source says that diprazin is detected by TLC «as stated above», i.e. by the method given for aminazine on p. 19 (development to 13 cm, reference on the same plate); no Rf or spot colour is given for diprazin.",
               "Manba diprazin TLC usulida «yuqorida ko‘rsatilganidek», ya’ni 19-betdagi aminazin usulida aniqlanishini bildiradi (13 sm gacha ko‘tarish, xuddi shu plastinkada standart); diprazin uchun Rf yoki dog‘ rangi keltirilmagan.",
               "Источник указывает, что дипразин обнаруживают методом TLC «как указано выше», т. е. по методике для аминазина на с. 19 (хроматографирование до 13 см, стандарт на той же пластинке); Rf и окраска пятна для дипразина не приведены.")))
add(uv("promethazine", N("water–ethanol (1:1)", "suv–etanol (1:1)", "смеси воды и этанола (1:1)"), ["252", "301"], "NARK", loc("NARK", pdf=20)))
add(uv("promethazine", N("0.01 N hydrochloric acid", "0,01 n xlorid kislota", "0,01 н хлористоводородной кислоте"), ["249", "300"], "NARK", loc("NARK", pdf=20),
       note=N("The source gives the second maximum as «about 300 nm».", "Manba ikkinchi maksimumni «taxminan 300 nm» deb beradi.",
              "Второй максимум источник приводит как «около 300 нм».")))
add(generic("promethazine", "spectroscopy",
            N("Infrared spectrum of diprazin (promethazine; potassium bromide disc), main peaks: 1459, 1222, 757 cm⁻¹.",
              "Diprazinning (prometazin) infraqizil spektri (kaliy bromid diski), asosiy cho‘qqilar: 1459, 1222, 757 cm⁻¹.",
              "ИК-спектр дипразина (прометазин; диск с бромидом калия), основные пики: 1459, 1222, 757 см⁻¹."),
            "NARK", loc("NARK", pdf=20), "instrumental", "instrumental", cat="A", data={"methods": ["method-spectroscopy"]}))

# levomepromazine (tizersin), NARK pp. 20–21
LMZ_NOTE = N("The source calls the drug tizersin (levomepromazine); compare with a reference standard run in parallel.",
             "Manba dorini tizersin (levomepromazin) deb ataydi; parallel yurgizilgan standart bilan solishtiring.",
             "Источник называет препарат тизерцином (левомепромазин); сравнивайте со стандартом, исследуемым параллельно.")
add(colour("levomepromazine", ["marquis", "frohde"], ["red-bluish"], "NARK", loc("NARK", pdf=20),
           note=N(f"Dry residue of the ethanolic solution in a porcelain dish, 1–2 drops of the reagent. {LMZ_NOTE[0]}",
                  f"Spirtli eritmaning chinni kosachadagi quruq qoldig‘i, 1–2 tomchi reaktiv. {LMZ_NOTE[1]}",
                  f"Сухой остаток спиртового раствора в фарфоровой чашке, 1–2 капли реактива. {LMZ_NOTE[2]}")))
add(colour("levomepromazine", "mandelin", ["red-violet"], "NARK", loc("NARK", pdf=20),
           note=N(f"To 1 mL of the test solution 0.1 mL of Mandelin reagent is added, the liquid is shaken and cooled in ice water, then 5 mL of concentrated sulfuric acid is added. {LMZ_NOTE[0]}",
                  f"1 ml tekshiriladigan eritmaga 0,1 ml Mandelin reaktivi qo‘shiladi, suyuqlik chayqatilib muzli suvda sovutiladi, so‘ng 5 ml konsentrlangan sulfat kislota qo‘shiladi. {LMZ_NOTE[1]}",
                  f"К 1 мл исследуемого раствора прибавляют 0,1 мл реактива Манделина, жидкость взбалтывают и охлаждают в ледяной воде, затем прибавляют 5 мл концентрированной серной кислоты. {LMZ_NOTE[2]}")))
add(tlc_free("levomepromazine",
             N("TLC of tizersin (levomepromazine): plate not stated in the source; chamber saturated with ammonia solution–ethanol (1:1), ethyl acetate and acetone (4:90:45); spots developed with 50% sulfuric acid in ethanol, then the plate is kept for 3–5 min in a drying oven at 100 °C. No Rf or spot colour is given.",
               "Tizersin (levomepromazin) TLC si: manbada plastinka ko‘rsatilmagan; kamera ammiak eritmasi–etanol (1:1), etilatsetat va aseton (4:90:45) bug‘lari bilan to‘yintiriladi; dog‘lar etanoldagi 50% sulfat kislota bilan ochiladi, so‘ng plastinka 100 °C li quritish shkafida 3–5 daqiqa saqlanadi. Rf yoki dog‘ rangi keltirilmagan.",
               "TLC тизерцина (левомепромазин): пластинка в источнике не указана; камера насыщена парами смеси раствор аммиака–этанол (1:1), этилацетат и ацетон (4:90:45); пятна проявляют 50% раствором серной кислоты в этаноле, затем пластинку на 3–5 мин помещают в сушильный шкаф при 100 °C. Rf и окраска пятна не приведены."),
             "NARK", loc("NARK", pdf=20), data={"systems": ["ammonia solution–ethanol (1:1)–ethyl acetate–acetone (4:90:45)"]}))
add(uv("levomepromazine", N("ethanol", "etanol", "этаноле"), ["255", "310"], "NARK", loc("NARK", pdf=20)))
add(uv("levomepromazine", N("0.1 N hydrochloric acid", "0,1 n xlorid kislota", "0,1 н хлористоводородной кислоте"), ["251", "302"], "NARK",
       loc("NARK", pdf=20, to=21)))
add(generic("levomepromazine", "spectroscopy",
            N("Infrared spectrum of tizersin base (levomepromazine; potassium bromide disc), main peaks: 1587, 1460, 1269, 1446 cm⁻¹.",
              "Tizersin (levomepromazin) asosining infraqizil spektri (kaliy bromid diski), asosiy cho‘qqilar: 1587, 1460, 1269, 1446 cm⁻¹.",
              "ИК-спектр основания тизерцина (левомепромазин; диск с бромидом калия), основные пики: 1587, 1460, 1269, 1446 см⁻¹."),
            "NARK", loc("NARK", pdf=21), "instrumental", "instrumental", cat="A", data={"methods": ["method-spectroscopy"]}))

# =============================================================== 1,4-BENZODIAZEPINES
_extend(d6.BZD, NEW_BZD)  # isolation pp. 24, 27; TLC p. 24; colour pp. 27, 29; microcrystal pp. 27–28
_extend(["diazepam", "oxazepam"], NEW_BZD, families={"instrumental"})  # YuSSX 3.2.3 class conditions
WL_Z = ["220", "230", "240", "250", "260", "280", "309"]
MIL = N("Milichrom, column 62 × 2 mm", "Milixrom, 62 × 2 mm kolonka", "«Милихром», колонка 62 × 2 мм")
MS_NOTE = N("The source does not state the ionisation mode or the relative intensities.",
            "Manba ionlash usulini va nisbiy intensivliklarni ko‘rsatmaydi.",
            "Источник не указывает способ ионизации и относительные интенсивности.")
DZ_TLC = N("TLC on silica gel (fixed layer) or Silufol plates: ethyl acetate–25% ammonia–methanol (26:1.6:3.3) or chloroform–acetone (9:1); spots developed with Dragendorff reagent.",
           "Silikagel (mustahkamlangan qatlam) yoki Silufol plastinkalarida TLC: etilatsetat–25% ammiak–metanol (26:1,6:3,3) yoki xloroform–aseton (9:1); dog‘lar Dragendorf reaktivi bilan ochiladi.",
           "TLC на пластинках с закреплённым слоем силикагеля или «Силуфол»: этилацетат–25% аммиак–метанол (26:1,6:3,3) или хлороформ–ацетон (9:1); пятна проявляют реактивом Драгендорфа.")

# chlordiazepoxide, NARK pp. 28–29
add(isolation("chlordiazepoxide",
              N("Isolation from biological material: 25 g of the minced object is soaked for 1 h with 100 mL of water acidified with hydrochloric acid to pH 1, 3 times; the combined extracts are centrifuged, the centrifugate is made alkaline with saturated sodium hydroxide to pH 10 and extracted 3 times with chloroform (25, 15 and 15 mL); the combined chloroform extracts are used for detection and quantitation.",
                "Biologik materialdan ajratib olish: 25 g maydalangan ob’ekt xlorid kislota bilan pH 1 gacha nordonlashtirilgan 100 ml suvda 1 soatdan 3 marta bo‘ktiriladi; birlashtirilgan ajratmalar sentrifuga qilinib, sentrifugat to‘yingan natriy gidroksid bilan pH 10 gacha ishqorlantiriladi va 3 marta xloroform bilan (25, 15 va 15 ml) ekstraksiyalanadi; birlashtirilgan xloroformli ajratmalar aniqlash va miqdoriy tahlil uchun ishlatiladi.",
                "Изолирование из биологического материала: 25 г измельчённого объекта настаивают 1 ч со 100 мл воды, подкисленной хлористоводородной кислотой до pH 1, 3 раза; объединённые вытяжки центрифугируют, центрифугат подщелачивают насыщенным раствором гидроксида натрия до pH 10 и 3 раза экстрагируют хлороформом (по 25, 15 и 15 мл); объединённые хлороформные вытяжки используют для обнаружения и количественного определения."),
              "NARK", loc("NARK", pdf=28), data={"specimen": "organs", "methods": ["method-lle"]}))
add(colour("chlordiazepoxide", "bratton", ["cherry-red"], "NARK", loc("NARK", pdf=28),
           note=N("Preliminary test in blood plasma or urine (5 or 10 mL): made alkaline with ammonia and extracted twice with 10 mL of chloroform; the extract is shaken with 5 mL of 6 M hydrochloric acid, and the acid layer is heated (water bath, then 30 min at 125 °C on a paraffin bath), giving 2-amino-5-chlorobenzophenone; then sodium nitrite, ammonium sulfamate and N-(1-naphthyl)ethylenediamine dihydrochloride are added in turn.",
                  "Qon plazmasi yoki peshobda dastlabki sinama (5 yoki 10 ml): ammiak bilan ishqorlantirilib, 2 marta 10 ml xloroform bilan ekstraksiyalanadi; ekstrakt 5 ml 6 M xlorid kislota bilan chayqatiladi, kislotali qatlam qizdiriladi (suv hammomi, so‘ng parafin hammomida 125 °C da 30 daqiqa) va 2-amino-5-xlorbenzofenon hosil bo‘ladi; so‘ng navbat bilan natriy nitrit, ammoniy sulfaminat va N-(1-naftil)etilendiamin digidroxlorid qo‘shiladi.",
                  "Предварительная проба в плазме крови или моче (5 или 10 мл): подщелачивают аммиаком и дважды экстрагируют 10 мл хлороформа; экстракт обрабатывают 5 мл 6 М хлористоводородной кислоты, кислый слой нагревают (водяная баня, затем 30 мин при 125 °C на парафиновой бане), образуется 2-амино-5-хлорбензофенон; затем последовательно прибавляют нитрит натрия, сульфаминат аммония и N-(1-нафтил)этилендиамина дигидрохлорид.")))
add(colour("chlordiazepoxide", "ninhydrin", ["brown"], "NARK", loc("NARK", pdf=28),
           note=N("Done as described for diazepam (ethanolic solution, about 10 mg of ninhydrin, water bath, then ethanol).",
                  "Diazepam uchun tavsiflangandek bajariladi (spirtli eritma, taxminan 10 mg ningidrin, suv hammomi, so‘ng etanol).",
                  "Выполняют, как описано для диазепама (спиртовой раствор, около 10 мг нингидрина, водяная баня, затем этанол).")))
add(colour("chlordiazepoxide", "marquis", ["yellow"], "NARK", loc("NARK", pdf=28, to=29)))
add(colour("chlordiazepoxide", "frohde", ["orange"], "NARK", loc("NARK", pdf=29)))
add(colour("chlordiazepoxide", "vitali", ["yellow"], "NARK", loc("NARK", pdf=29)))
add(tlc_free("chlordiazepoxide", DZ_TLC, "NARK", loc("NARK", pdf=29, to=30),
             note=N("The source says chlordiazepoxide is detected by TLC in the same way as diazepam; the conditions are those given for diazepam. No Rf is given.",
                    "Manba xlordiazepoksid TLC usulida diazepam kabi aniqlanishini bildiradi; sharoitlar diazepam uchun berilgan. Rf keltirilmagan.",
                    "Источник указывает, что хлордиазепоксид обнаруживают методом TLC так же, как диазепам; условия приведены для диазепама. Rf не приведены."),
             data={"systems": ["ethyl acetate–25% ammonia–methanol (26:1.6:3.3)", "chloroform–acetone (9:1)"]}))
add(uv("chlordiazepoxide", N("0.1 M sodium hydroxide", "0,1 M natriy gidroksid", "0,1 М растворе гидроксида натрия"), ["243", "260"], "NARK", loc("NARK", pdf=29)))
add(uv("chlordiazepoxide", N("0.1 M sulfuric acid", "0,1 M sulfat kislota", "0,1 М растворе серной кислоты"), ["245", "306"], "NARK", loc("NARK", pdf=29)))
add(uv("chlordiazepoxide", N("0.1 M hydrochloric acid", "0,1 M xlorid kislota", "0,1 М растворе хлористоводородной кислоты"), ["246", "308"], "NARK", loc("NARK", pdf=29)))
add(generic("chlordiazepoxide", "spectroscopy",
            N("Infrared spectrum of chlordiazepoxide base (potassium bromide disc), main peaks: 1625, 1458, 760 cm⁻¹. Mass spectrum, ions listed by the source: m/z 282, 299, 284, 283, 241, 56, 301, 253.",
              "Xlordiazepoksid asosining infraqizil spektri (kaliy bromid diski), asosiy cho‘qqilar: 1625, 1458, 760 cm⁻¹. Mass-spektr, manba keltirgan ionlar: m/z 282, 299, 284, 283, 241, 56, 301, 253.",
              "ИК-спектр основания хлордиазепоксида (диск с бромидом калия), основные пики: 1625, 1458, 760 см⁻¹. Масс-спектр, ионы по источнику: m/z 282, 299, 284, 283, 241, 56, 301, 253."),
            "NARK", loc("NARK", pdf=29), "instrumental", "instrumental", cat="A", data={"methods": ["method-spectroscopy"]}, note=MS_NOTE))
_yussx_data("chlordiazepoxide", ("xlozepid (chlordiazepoxide)", "xlozepid (xlordiazepoksid)", "хлозепида (хлордиазепоксид)"), MIL, "1662", WL_Z,
            ["0.600", "0.391", "0.591", "0.944", "0.332", "0.046", "0.095"], "3.2.3",
            note=N("The source lists the compound as «Xlozepid», a Russian name of chlordiazepoxide.",
                   "Manba birikmani «Xlozepid» deb keltiradi — bu xlordiazepoksidning rus tilidagi nomi.",
                   "Источник приводит соединение как «хлозепид» — русское название хлордиазепоксида."))

# nitrazepam, NARK pp. 30–31
add(isolation("nitrazepam",
              N("Isolation from biological objects: 25 g of the minced object is soaked for 1 h with 100 mL of water acidified with hydrochloric acid to pH 1; the combined acidic extract is extracted 3 times (20, 15 and 15 mL) with chloroform–ethyl acetate (1:1), then made alkaline to pH 10 and again extracted 3 times (20, 15 and 15 mL) with the same mixture; the extracts are examined for nitrazepam.",
                "Biologik ob’ektlardan ajratib olish: 25 g maydalangan ob’ekt xlorid kislota bilan pH 1 gacha nordonlashtirilgan 100 ml suvda 1 soat bo‘ktiriladi; birlashtirilgan kislotali ajratma 3 marta (20, 15 va 15 ml) xloroform–etilatsetat (1:1) bilan ekstraksiyalanadi, so‘ng pH 10 gacha ishqorlantirilib, yana 3 marta (20, 15 va 15 ml) shu aralashma bilan ekstraksiyalanadi; ajratmalar nitrazepamga tekshiriladi.",
                "Изолирование из биологических объектов: 25 г измельчённого объекта настаивают 1 ч со 100 мл воды, подкисленной хлористоводородной кислотой до pH 1; объединённое кислое извлечение трижды (по 20, 15 и 15 мл) экстрагируют смесью хлороформ–этилацетат (1:1), затем подщелачивают до pH 10 и также трижды (по 20, 15 и 15 мл) экстрагируют той же смесью; вытяжки исследуют на наличие нитразепама."),
              "NARK", loc("NARK", pdf=30), data={"specimen": "organs", "methods": ["method-lle"]}))
add(generic("nitrazepam", "colour_test",
            N("Detection in urine: 5 mL of urine made alkaline with ammonia to pH 10 is reduced with 2–5 g of sodium dithionite (shaken 10 min, then 1 h at 50 °C), extracted with methylene chloride–ethyl acetate (1:1); the organic layer is treated with borax solution, then with hydrochloric acid; the acidic aqueous phase, cooled in ice water, is treated with sodium nitrite and ammonium sulfamate, then N-(1-naphthyl)ethylenediamine dihydrochloride: a cherry-red colour indicates nitrazepam.",
              "Peshobda aniqlash: ammiak bilan pH 10 gacha ishqorlantirilgan 5 ml peshob 2–5 g natriy ditionit bilan qaytariladi (10 daqiqa chayqatiladi, so‘ng 50 °C da 1 soat), metilenxlorid–etilatsetat (1:1) bilan ekstraksiyalanadi; organik qatlam bura eritmasi, so‘ng xlorid kislota bilan ishlanadi; muzli suvda sovutilgan kislotali suvli fazaga natriy nitrit va ammoniy sulfaminat, so‘ng N-(1-naftil)etilendiamin digidroxlorid qo‘shiladi: olcha-qizil rang nitrazepam borligini ko‘rsatadi.",
              "Обнаружение в моче: 5 мл мочи, подщелочённой аммиаком до pH 10, восстанавливают 2–5 г дитионита натрия (взбалтывают 10 мин, затем 1 ч при 50 °C), экстрагируют смесью метиленхлорид–этилацетат (1:1); органический слой обрабатывают раствором буры, затем хлористоводородной кислотой; к кислой водной фазе, охлаждённой в ледяной воде, прибавляют нитрит натрия и сульфаминат аммония, затем N-(1-нафтил)этилендиамина дигидрохлорид: вишнёво-красная окраска указывает на нитразепам."),
            "NARK", loc("NARK", pdf=30), "presumptive", "presumptive", cat="C",
            reagents=["sodium dithionite", "sodium nitrite", "ammonium sulfamate", "N-(1-naphthyl)ethylenediamine dihydrochloride"]))
add(micro("nitrazepam",
          N("Crystal and precipitation reactions with the dry residue on a slide: 0.1 M iodine solution — needle-shaped crystals after a few minutes; HgI2/KI solution — amorphous precipitate; 5% potassium ferricyanide — prism-shaped crystals; PbI2/KI solution — red crystals after 30 min (microscope).",
            "Buyum oynasidagi quruq qoldiq bilan kristall va cho‘ktirish reaksiyalari: 0,1 M yod eritmasi — bir necha daqiqada ignasimon kristallar; HgI2/KI eritmasi — amorf cho‘kma; 5% kaliy ferritsianid — prizma shaklidagi kristallar; PbI2/KI eritmasi — 30 daqiqadan keyin qizil kristallar (mikroskop).",
            "Реакции кристаллообразования и осаждения с сухим остатком на предметном стекле: 0,1 М раствор йода — через несколько минут игольчатые кристаллы; раствор HgI2/KI — аморфный осадок; 5% раствор феррицианида калия — кристаллы в виде призм; раствор PbI2/KI — через 30 мин кристаллы красного цвета (микроскоп)."),
          "NARK", loc("NARK", pdf=30), reagents=["iodine solution", "HgI2/KI", "potassium ferricyanide", "PbI2/KI"]))
add(tlc("nitrazepam", [("EtOAc", 85), ("MeOH", 10), ("NH3", 5)], "silica", "dragendorff", "NARK", loc("NARK", pdf=30, to=31),
        note=N("Plates with a fixed silica gel layer or Silufol; the source applies this to nitrazepam and its metabolites. No Rf is given.",
               "Mustahkamlangan silikagel qatlamli yoki Silufol plastinkalari; manba buni nitrazepam va uning metabolitlari uchun qo‘llaydi. Rf keltirilmagan.",
               "Пластинки с закреплённым слоем силикагеля или «Силуфол»; источник применяет это к нитразепаму и его метаболитам. Rf не приведены.")))
add(uv("nitrazepam", N("ethanol", "etanol", "этаноле"), ["218", "260"], "NARK", loc("NARK", pdf=31)))
add(uv("nitrazepam", N("0.1 M sulfuric acid", "0,1 M sulfat kislota", "0,1 М растворе серной кислоты"), ["277"], "NARK", loc("NARK", pdf=31),
       note=N("The source adds an inflection at about 340 nm.", "Manba taxminan 340 nm da egilish borligini qo‘shimcha qiladi.",
              "Источник добавляет перегиб около 340 нм.")))
add(generic("nitrazepam", "spectroscopy",
            N("Infrared spectrum of nitrazepam (potassium bromide disc), main peaks: 1692, 1615, 1352, 702 cm⁻¹. Mass spectrum, ions listed by the source: m/z 280, 253, 281, 206, 234, 252, 254, 264.",
              "Nitrazepamning infraqizil spektri (kaliy bromid diski), asosiy cho‘qqilar: 1692, 1615, 1352, 702 cm⁻¹. Mass-spektr, manba keltirgan ionlar: m/z 280, 253, 281, 206, 234, 252, 254, 264.",
              "ИК-спектр нитразепама (диск с бромидом калия), основные пики: 1692, 1615, 1352, 702 см⁻¹. Масс-спектр, ионы по источнику: m/z 280, 253, 281, 206, 234, 252, 254, 264."),
            "NARK", loc("NARK", pdf=31), "instrumental", "instrumental", cat="A", data={"methods": ["method-spectroscopy"]}, note=MS_NOTE))
_yussx_data("nitrazepam", ("nitrazepam", "nitrazepam", "нитразепама"), MIL, "1624", WL_Z,
            ["0.919", "0.653", "0.541", "0.616", "0.808", "0.843", "0.620"], "3.2.3")

# =============================================================== ERGOT ALKALOIDS (NARK pp. 39–40; PRIM p. 14)
ERGOT = ["ergotamine", "ergometrine"]
ERG_CLASS = N("The source gives this for ergot alkaloids as a group.", "Manba buni ergoalkaloidlar guruhi uchun keltiradi.",
              "Источник приводит это для эргоалкалоидов как группы.")
add(isolation(ERGOT,
              N("Isolation of ergot alkaloids: the material is soaked 3 times in acetone–water (5:3); acetone is distilled off from the combined extracts at 60 °C; the aqueous phase is acidified with 10% oxalic acid to pH 2.5 and extracted 3 times with 15 mL of chloroform (this chloroform extract is set aside), then made alkaline with 25% ammonia to pH 8.0–9.0 (maximum extraction) and extracted 3 times with 20 mL of chloroform; after chromatographic clean-up the content is determined spectrophotometrically.",
                "Ergoalkaloidlarni ajratib olish: material aseton–suv (5:3) aralashmasida 3 marta bo‘ktiriladi; birlashtirilgan ajratmalardan aseton 60 °C da haydaladi; suvli faza 10% oksalat kislota bilan pH 2,5 gacha nordonlashtirilib, 3 marta 15 ml xloroform bilan ekstraksiyalanadi (bu xloroformli ajratma alohida olinadi), so‘ng 25% ammiak bilan pH 8,0–9,0 gacha (eng yuqori ekstraksiya) ishqorlantirilib, 3 marta 20 ml xloroform bilan ekstraksiyalanadi; xromatografik tozalashdan keyin miqdori spektrofotometrik usulda aniqlanadi.",
                "Изолирование эргоалкалоидов: материал 3 раза настаивают со смесью ацетон–вода (5:3); из объединённых вытяжек отгоняют ацетон при 60 °C; водную фазу подкисляют 10% щавелевой кислотой до pH 2,5 и 3 раза экстрагируют хлороформом по 15 мл (это хлороформное извлечение отделяют), затем подщелачивают 25% аммиаком до pH 8,0–9,0 (максимальная экстракция) и 3 раза экстрагируют хлороформом по 20 мл; после хроматографической очистки содержание определяют спектрофотометрически."),
              "NARK", loc("NARK", pdf=39), note=ERG_CLASS, data={"methods": ["method-lle"]}))
add(isolation(ERGOT,
              N("Water–acetone method of V.A. Kartashov for ergot alkaloids: soaking 3 times in water–acetone (5:3), removal of acetone at 60 °C, aqueous part to pH 2.5 with oxalic acid and extracted 3 times with 15 mL of chloroform, then to pH 8.0–9.0 with 25% ammonia and extracted 3 times with 20 mL of chloroform; the chloroform extracts are evaporated, cleaned up by TLC, and the substance is identified and quantified by spectrophotometry.",
                "Ergoalkaloidlar uchun V.A. Kartashovning suv–aseton usuli: suv–aseton (5:3) aralashmasida 3 marta bo‘ktirish, asetonni 60 °C da haydash, suvli qismni oksalat kislota bilan pH 2,5 ga keltirib, 3 marta 15 ml xloroform bilan ekstraksiyalash, so‘ng 25% ammiak bilan pH 8,0–9,0 ga keltirib, 3 marta 20 ml xloroform bilan ekstraksiyalash; xloroformli ajratmalar bug‘latiladi, TLC usulida tozalanadi, modda spektrofotometriya bilan aniqlanadi va miqdori o‘lchanadi.",
                "Водно-ацетоновый метод В.А. Карташова для эргоалкалоидов: 3-кратное настаивание со смесью вода–ацетон (5:3), отгонка ацетона при 60 °C, водную часть доводят щавелевой кислотой до pH 2,5 и 3 раза экстрагируют хлороформом по 15 мл, затем 25% аммиаком до pH 8,0–9,0 и 3 раза экстрагируют хлороформом по 20 мл; хлороформные извлечения упаривают, очищают методом TLC, вещество идентифицируют и определяют количественно спектрофотометрически."),
              "PRIM", loc("PRIM", printed=14), note=d6._with_card(ERG_CLASS), data={"methods": ["method-lle"], "group": 3}))
ERG_SPRAY = N("silica gel or Silufol plates; spots revealed by spraying with 10% silver nitrate (brown), 1% potassium permanganate (orange spot), potassium dichromate in 20% sulfuric acid (blue) or 0.5% p-dimethylaminobenzaldehyde in 65% sulfuric acid (blue)",
              "silikagel yoki Silufol plastinkalari; dog‘lar 10% kumush nitrat (qo‘ng‘ir), 1% kaliy permanganat (zarg‘aldoq dog‘), 20% sulfat kislotadagi kaliy dixromat (ko‘k) yoki 65% sulfat kislotadagi 0,5% p-dimetilaminobenzaldegid (ko‘k) purkab ochiladi",
              "пластинки с силикагелем или «Силуфол»; пятна обнаруживают опрыскиванием 10% нитратом серебра (коричневое), 1% перманганатом калия (оранжевое пятно), дихроматом калия в 20% серной кислоте (синее) или 0,5% п-диметиламинобензальдегидом в 65% серной кислоте (синее)")
for sub, sys_, nm in (("ergometrine", N("n-butanol–n-hexane–25% ammonia (20:15:0.5)", "n-butanol–n-geksan–25% ammiak (20:15:0,5)", "н-бутанол–н-гексан–25% аммиак (20:15:0,5)"),
                       N("ergometrine", "ergometrin", "эргометрина")),
                      ("ergotamine", N("acetone–chloroform–water (3:1:0.5)", "aseton–xloroform–suv (3:1:0,5)", "ацетон–хлороформ–вода (3:1:0,5)"),
                       N("ergotamine", "ergotamin", "эрготамина"))):
    add(tlc_free(sub,
                 N(f"TLC of ergot alkaloids: {ERG_SPRAY[0]}. Solvent system given for {nm[0]}: {sys_[0]}. No Rf is given.",
                   f"Ergoalkaloidlar TLC si: {ERG_SPRAY[1]}. {nm[1].capitalize()} uchun berilgan erituvchilar tizimi: {sys_[1]}. Rf keltirilmagan.",
                   f"TLC эргоалкалоидов: {ERG_SPRAY[2]}. Система растворителей для {nm[2]}: {sys_[2]}. Rf не приведены."),
                 "NARK", loc("NARK", pdf=39, to=40), data={"systems": [sys_[0]]}))
add(uv("ergometrine", N("water (ergometrine maleate)", "suv (ergometrin maleat)", "воде (эргометрина малеат)"), ["311"], "NARK", loc("NARK", pdf=40),
       note=N("Minimum at 269 nm.", "Minimum — 269 nm da.", "Минимум — при 269 нм.")))
add(uv("ergotamine", N("solution of ergotamine hydrotartrate", "ergotamin gidrotartrat eritmasi", "растворе эрготамина гидротартрата"), ["318"], "NARK", loc("NARK", pdf=40),
       note=N("Minimum at 272 nm.", "Minimum — 272 nm da.", "Минимум — при 272 нм.")))
for sub, nm, wl in (("ergometrine", N("ergometrine maleate", "ergometrin maleat", "эргометрина малеата"), "311"),
                    ("ergotamine", N("ergotamine tartrate", "ergotamin tartrat", "эрготамина тартрата"), "314")):
    add(generic(sub, "photometric",
                N(f"Quantitation by UV absorbance at {wl} nm ({nm[0]}); the content is calculated by absolute calibration.",
                  f"Miqdoriy aniqlash {wl} nm dagi UB nur yutish bo‘yicha ({nm[1]}); miqdor mutlaq kalibrlash usulida hisoblanadi.",
                  f"Количественное определение по УФ-поглощению при {wl} нм ({nm[2]}); содержание рассчитывают методом абсолютной калибровки."),
                "NARK", loc("NARK", pdf=40), "supporting", "supporting"))
add(generic(ERGOT, "photometric",
            N("Extraction-photometric determination: with tropaeolin 00 at pH 4.6 ergot alkaloids give yellow compounds that are well extracted by chloroform; on adding 1% sulfuric acid in methanol the chloroform solutions turn red-violet.",
              "Ekstraksion-fotometrik aniqlash: ergoalkaloidlar pH 4,6 da tropeolin 00 bilan xloroform bilan yaxshi ekstraksiyalanadigan sariq rangli birikmalar hosil qiladi; metanoldagi 1% sulfat kislota qo‘shilganda xloroformli eritmalar qizil-binafsha rangga kiradi.",
              "Экстракционно-фотометрическое определение: эргоалкалоиды с тропеолином 00 при pH 4,6 дают окрашенные в жёлтый цвет соединения, хорошо экстрагируемые хлороформом; при добавлении 1% раствора серной кислоты в метаноле хлороформные растворы приобретают красно-фиолетовую окраску."),
            "NARK", loc("NARK", pdf=40), "supporting", "supporting", reagents=["tropaeolin 00"], note=ERG_CLASS))
add(generic(ERGOT, "instrumental",
            N("HPLC: the source names a Milichrom 4-A microcolumn liquid chromatograph with UV-spectrophotometric detection for the qualitative and quantitative determination of ergometrine maleate, ergotamine tartrate and ergotoxine; no column, mobile phase or retention values are given.",
              "HPLC: manba ergometrin maleat, ergotamin tartrat va ergotoksinni sifat va miqdoriy aniqlash uchun UB-spektrofotometrik detektorli Milixrom 4-A mikrokolonkali suyuqlik xromatografini nomlaydi; kolonka, harakatlanuvchi faza yoki ushlanish qiymatlari keltirilmagan.",
              "HPLC: источник называет микроколоночный жидкостный хроматограф «Милихром 4-А» с УФ-спектрофотометрическим детектором для качественного и количественного определения эргометрина малеата, эрготамина тартрата и эрготоксина; колонка, подвижная фаза и параметры удерживания не приведены."),
            "NARK", loc("NARK", pdf=40), "instrumental", "instrumental", cat="B", data={"methods": ["method-hplc"]}))
add(colour(ERGOT, "van_urk", ["red-violet"], "GMT", loc("GMT", pdf=96),
           note=N("The source gives this reaction under LSD and states that it is a general reaction of ergot alkaloids (red-violet or violet colour).",
                  "Manba bu reaksiyani LSD bo‘limida keltiradi va u zamburug‘ (ergot) alkaloidlari uchun umumiy reaksiya ekanini bildiradi (qizil-binafsha yoki binafsha rang).",
                  "Источник приводит эту реакцию в разделе LSD и указывает, что это общая реакция алкалоидов спорыньи (красно-фиолетовый или фиолетовый цвет).")))

# =============================================================== SYNTHETIC PYRETHROIDS (PRIM printed pp. 29–30)
PYR_PROC = N("Isolation of synthetic pyrethroids (the source names cypermethrin, Danitol and Decis): blood — 5 mL brought to pH 8–9 with sodium hydroxide, 2 mL of saturated sodium chloride and 10 mL of an organic solvent added, centrifuged 5 min, the organic layer taken, repeated twice more; urine — 25 mL with 3 g of sodium chloride brought to pH 8–9 with 0.1 M sodium hydroxide and extracted 3 times (30, 20, 20 mL), the extracts passed through anhydrous sodium sulfate and concentrated on a rotary evaporator; organs — 10 g minced with 1–3 mL of water brought to pH 9.0–9.5 with 0.1 M sodium hydroxide, shaken with 15 mL of the solvent and 5 mL of saturated sodium chloride for 1 h, repeated twice more. The dry residue is examined by TLC, HPLC and UV spectrophotometry.",
             "Sintetik piretroidlarni ajratib olish (manba sipermetrin, Danitol va Detsisni nomlaydi): qon — 5 ml natriy gidroksid bilan pH 8–9 ga keltiriladi, 2 ml to‘yingan natriy xlorid va 10 ml organik erituvchi qo‘shiladi, 5 daqiqa sentrifuga qilinadi, organik qatlam ajratiladi, yana 2 marta takrorlanadi; peshob — 25 ml 3 g natriy xlorid bilan 0,1 M natriy gidroksid yordamida pH 8–9 ga keltirilib, 3 marta (30, 20, 20 ml) ekstraksiyalanadi, ekstraktlar suvsiz natriy sulfat orqali o‘tkazilib, rotor-vakuum bug‘latgichda quyultiriladi; a’zolar — 10 g maydalangan ob’ekt 1–3 ml suv bilan 0,1 M natriy gidroksid yordamida pH 9,0–9,5 ga keltirilib, 15 ml erituvchi va 5 ml to‘yingan natriy xlorid bilan 1 soat chayqatiladi, yana 2 marta takrorlanadi. Quruq qoldiq TLC, HPLC va UB-spektrofotometriya usullarida tekshiriladi.",
             "Изолирование синтетических пиретроидов (источник называет циперметрин, данитол и децис): кровь — 5 мл доводят гидроксидом натрия до pH 8–9, добавляют 2 мл насыщенного раствора хлорида натрия и 10 мл органического растворителя, центрифугируют 5 мин, отделяют органический слой, повторяют ещё 2 раза; моча — 25 мл с 3 г хлорида натрия доводят 0,1 М гидроксидом натрия до pH 8–9 и экстрагируют 3 раза (30, 20, 20 мл), экстракты пропускают через безводный сульфат натрия и концентрируют на роторном испарителе; органы — 10 г измельчённого объекта с 1–3 мл воды доводят 0,1 М гидроксидом натрия до pH 9,0–9,5, встряхивают 1 ч с 15 мл растворителя и 5 мл насыщенного раствора хлорида натрия, повторяют ещё 2 раза. Сухой остаток исследуют методами TLC, HPLC и УФ-спектрофотометрии.")
PYR_NOTE = N("The source's heading spells the first compound «Спирметрин»; its table gives «Тсиперметрин» (cypermethrin). Danitol and Decis are trade names (fenpropathrin and deltamethrin).",
             "Manba sarlavhasida birinchi birikma «Спирметрин» deb yozilgan; jadvalda «Тсиперметрин» (sipermetrin). Danitol va Detsis — savdo nomlari (fenpropatrin va deltametrin).",
             "В заголовке источника первое соединение написано «Спирметрин»; в таблице — «Тсиперметрин» (циперметрин). Данитол и децис — торговые названия (фенпропатрин и дельтаметрин).")
for sub, nm, rec in (
        ("cypermethrin", N("cypermethrin", "sipermetrin", "циперметрина"),
         N("chloroform: urine 79.50%, blood 75.66%, organ 50.54%", "xloroform: peshob 79,50%, qon 75,66%, a’zo 50,54%",
           "хлороформ: моча 79,50%, кровь 75,66%, орган 50,54%")),
        ("fenpropathrin", N("Danitol (fenpropathrin)", "Danitol (fenpropatrin)", "данитола (фенпропатрин)"),
         N("urine — ethyl acetate 78.30%; blood — hexane–ethyl acetate (1:1) 67.20%; organ — ethyl acetate 50.00%",
           "peshob — etilatsetat 78,30%; qon — geksan–etilatsetat (1:1) 67,20%; a’zo — etilatsetat 50,00%",
           "моча — этилацетат 78,30%; кровь — гексан–этилацетат (1:1) 67,20%; орган — этилацетат 50,00%")),
        ("deltamethrin", N("Decis (deltamethrin)", "Detsis (deltametrin)", "дециса (дельтаметрин)"),
         N("chloroform: urine 78.56%, blood 77.60%, organ 51.46%", "xloroform: peshob 78,56%, qon 77,60%, a’zo 51,46%",
           "хлороформ: моча 78,56%, кровь 77,60%, орган 51,46%"))):
    add(isolation(sub,
                  N(f"{PYR_PROC[0]} Extractant and recovery printed for {nm[0]}: {rec[0]}.",
                    f"{PYR_PROC[1]} {nm[1][0].upper() + nm[1][1:]} uchun keltirilgan ekstragent va ajralish darajasi: {rec[1]}.",
                    f"{PYR_PROC[2]} Экстрагент и степень извлечения для {nm[2]}: {rec[2]}."),
                  "PRIM", loc("PRIM", printed=29, to=30), note=d6._with_card(PYR_NOTE),
                  data={"methods": ["method-lle"], "group": 4}))

# =============================================================== NEONICOTINOIDS (PRIM printed pp. 31–33)
NEO = ["imidacloprid", "acetamiprid"]
NEO_NOTE = N("The source describes these procedures for imidacloprid and acetamiprid together (model samples).",
             "Manba bu usullarni imidakloprid va atsetamiprid uchun birgalikda tavsiflaydi (model namunalar).",
             "Источник описывает эти методики для имидаклоприда и ацетамиприда вместе (модельные пробы).")
add(isolation(NEO,
              N("Isolation from blood: 10 mL of blood is brought to pH 2.0–2.5 with 10% sulfuric acid and left for 2 h at room temperature, centrifuged, and the centrifugate is washed with 10 mL of diethyl ether to remove ballast substances; the aqueous part is brought to pH 9.0–9.5 with 25% ammonia and extracted 3 times with 10 mL of chloroform; the extracts are filtered through 3–5 g of anhydrous sodium sulfate and evaporated at room temperature; the residue is dissolved in 1 mL of ethanol and cleaned up by TLC.",
                "Qondan ajratib olish: 10 ml qon 10% sulfat kislota bilan pH 2,0–2,5 ga keltirilib, xona haroratida 2 soat qoldiriladi, sentrifuga qilinadi, sentrifugat 10 ml dietil efiri bilan ballast moddalardan tozalanadi; suvli qism 25% ammiak bilan pH 9,0–9,5 ga keltirilib, 3 marta 10 ml xloroform bilan ekstraksiyalanadi; ekstraktlar 3–5 g suvsiz natriy sulfat orqali filtrlanib, xona haroratida bug‘latiladi; quruq qoldiq 1 ml etanolda eritilib, TLC usulida tozalanadi.",
                "Изолирование из крови: 10 мл крови доводят 10% серной кислотой до pH 2,0–2,5 и оставляют на 2 ч при комнатной температуре, центрифугируют, центрифугат очищают от балластных веществ 10 мл диэтилового эфира; водную часть доводят 25% аммиаком до pH 9,0–9,5 и 3 раза экстрагируют хлороформом по 10 мл; экстракты фильтруют через 3–5 г безводного сульфата натрия и упаривают при комнатной температуре; сухой остаток растворяют в 1 мл этанола и очищают методом TLC."),
              "PRIM", loc("PRIM", printed=32), note=d6._with_card(NEO_NOTE),
              data={"specimen": "blood", "methods": ["method-lle"], "group": 4}))
add(isolation(NEO,
              N("Isolation from urine: 25 mL of urine is brought to pH 2.0–2.5 with 10% sulfuric acid and left for 2 h at room temperature, washed twice with 10 mL of chloroform (the extracts are discarded); the aqueous part is brought to pH 9.0–9.5 with 25% ammonia and processed further as for blood.",
                "Peshobdan ajratib olish: 25 ml peshob 10% sulfat kislota bilan pH 2,0–2,5 ga keltirilib, xona haroratida 2 soat qoldiriladi, 2 marta 10 ml xloroform bilan yuviladi (ekstraktlar tashlanadi); suvli qism 25% ammiak bilan pH 9,0–9,5 ga keltirilib, keyin qondagi kabi davom ettiriladi.",
                "Изолирование из мочи: 25 мл мочи доводят 10% серной кислотой до pH 2,0–2,5 и оставляют на 2 ч при комнатной температуре, дважды промывают 10 мл хлороформа (экстракты отбрасывают); водную часть доводят 25% аммиаком до pH 9,0–9,5 и далее обрабатывают, как кровь."),
              "PRIM", loc("PRIM", printed=32), note=d6._with_card(NEO_NOTE),
              data={"specimen": "urine", "methods": ["method-lle"], "group": 4}))
add(isolation(NEO,
              N("Isolation from organs (liver): 100 g of minced object is covered with 0.02 M sulfuric acid (pH 2.0–2.5) and left for 2 h with shaking, then soaked twice more for 1 h; the combined extracts are centrifuged, washed with 10 mL of ethyl acetate (acetamiprid) or 10 mL of diethyl ether (imidacloprid), brought to pH 9.0 with 25% ammonia and extracted 3 times with 10 mL of chloroform; the extracts are dried through 3–5 g of anhydrous sodium sulfate and evaporated at room temperature; the residue is dissolved in 1 mL of 95% ethanol, cleaned up by TLC and analysed by UV spectrophotometry and HPLC.",
                "A’zolardan (jigar) ajratib olish: 100 g maydalangan ob’ekt 0,02 M sulfat kislota (pH 2,0–2,5) bilan qoplanib, chayqatib turgan holda 2 soat qoldiriladi, so‘ng yana 2 marta 1 soatdan bo‘ktiriladi; birlashtirilgan ajratmalar sentrifuga qilinadi, 10 ml etilatsetat (atsetamiprid) yoki 10 ml dietil efiri (imidakloprid) bilan tozalanadi, 25% ammiak bilan pH 9,0 ga keltirilib, 3 marta 10 ml xloroform bilan ekstraksiyalanadi; ekstraktlar 3–5 g suvsiz natriy sulfat orqali quritilib, xona haroratida bug‘latiladi; quruq qoldiq 1 ml 95% etanolda eritilib, TLC usulida tozalanadi va UB-spektrofotometriya hamda HPLC usullarida tahlil qilinadi.",
                "Изолирование из органов (печень): 100 г измельчённого объекта заливают 0,02 М серной кислотой (pH 2,0–2,5) и оставляют на 2 ч при встряхивании, затем ещё дважды настаивают по 1 ч; объединённые извлечения центрифугируют, очищают 10 мл этилацетата (ацетамиприд) или 10 мл диэтилового эфира (имидаклоприд), доводят 25% аммиаком до pH 9,0 и 3 раза экстрагируют хлороформом по 10 мл; экстракты сушат через 3–5 г безводного сульфата натрия и упаривают при комнатной температуре; сухой остаток растворяют в 1 мл 95% этанола, очищают методом TLC и анализируют методами УФ-спектрофотометрии и HPLC."),
              "PRIM", loc("PRIM", printed=33), note=d6._with_card(NEO_NOTE),
              data={"specimen": "organs", "methods": ["method-lle"], "group": 4}))
