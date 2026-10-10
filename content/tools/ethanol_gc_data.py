"""Ethanol by GC-FID — international-literature records (en / uz / ru), 2026-10-10.

Scope: how ethanol in blood / urine is measured on a plain gas chromatograph with a flame
ionization detector and a headspace sampler (no mass spectrometer). Generic wording only:
no instrument or column brand is promoted.

Source reading level (stated honestly in `SOURCE_NOTES`):
  * Taylor et al. 2022 (Molecules, PMC9331811, CC BY) — FULL TEXT read (sections quoted in locators);
  * every other article — ABSTRACT / bibliographic record only (PubMed), not the full text.

Not found in the sources read (marked «source check pending» inside the statements):
  * injection mode (split / splitless, split ratio) and inlet temperature;
  * a ready oven temperature programme (the validated methods use an isothermal oven).
"""
from __future__ import annotations

ENT = "ethanol"

SRC_TAYLOR = "SRC-PMC9331811"  # already in the bundle (Molecules 2022)

# (source_id, journal_article record)
NEW_SOURCES = [
    {
        "source_id": "SRC-PM37804205",
        "source_type": "journal_article",
        "title": "Preanalytical factors influencing the results of ethanol analysis in postmortem specimens",
        "authors": ["Olds ML", "Jones AW"],
        "journal": "Journal of Analytical Toxicology",
        "publication_year": 2024,
        "doi": "10.1093/jat/bkad078",
        "pmid": "37804205",
        "official_url": "https://doi.org/10.1093/jat/bkad078",
        "accessed_date": "2026-10-10",
        "tier": "tier2", "evidence_level": "B", "license_mode": "citeOnly", "identifier_verified": True,
        "notes": "PubMed metadata (PMID, DOI) verified 2026-10-10. Checked at ABSTRACT level only; the full text was not read.",
    },
    {
        "source_id": "SRC-PM36346343",
        "source_type": "journal_article",
        "title": "Validation of a New Salt-Assisted HS-GC-FID Method for the Determination of Ethanol in the Vitreous Humor",
        "authors": ["Musile G", "Pigaiani N", "Pasetto E", "Ballotari M", "Tagliaro F", "Bortolotti F"],
        "journal": "Journal of Analytical Toxicology",
        "publication_year": 2023,
        "doi": "10.1093/jat/bkac087",
        "pmid": "36346343",
        "official_url": "https://doi.org/10.1093/jat/bkac087",
        "accessed_date": "2026-10-10",
        "tier": "tier2", "evidence_level": "B", "license_mode": "citeOnly", "identifier_verified": True,
        "notes": "PubMed metadata (PMID, DOI) verified 2026-10-10. Checked at ABSTRACT level only; the full text was not read.",
    },
    {
        "source_id": "SRC-PM27488829",
        "source_type": "journal_article",
        "title": "Development and Validation of a Method for Alcohol Analysis in Brain Tissue by Headspace Gas Chromatography with Flame Ionization Detector",
        "authors": ["Chun HJ", "Poklis JL", "Poklis A", "Wolf CE"],
        "journal": "Journal of Analytical Toxicology",
        "publication_year": 2016,
        "doi": "10.1093/jat/bkw075",
        "pmid": "27488829",
        "official_url": "https://doi.org/10.1093/jat/bkw075",
        "accessed_date": "2026-10-10",
        "tier": "tier2", "evidence_level": "B", "license_mode": "citeOnly", "identifier_verified": True,
        "notes": "PubMed metadata (PMID, DOI) verified 2026-10-10. Checked at ABSTRACT level only (the PMC full text could not be retrieved); the full text was not read.",
    },
    {
        "source_id": "SRC-PM33031530",
        "source_type": "journal_article",
        "title": "Development and Validation of an Analytical Method for Volatiles with Endogenous Production in Putrefaction and Submersion Situations",
        "authors": ["Pinto M", "Eusébio E", "Monteiro C"],
        "journal": "Journal of Analytical Toxicology",
        "publication_year": 2021,
        "doi": "10.1093/jat/bkaa154",
        "pmid": "33031530",
        "official_url": "https://doi.org/10.1093/jat/bkaa154",
        "accessed_date": "2026-10-10",
        "tier": "tier2", "evidence_level": "B", "license_mode": "citeOnly", "identifier_verified": True,
        "notes": "PubMed metadata (PMID, DOI) verified 2026-10-10. Checked at ABSTRACT level only; the full text was not read.",
    },
    {
        "source_id": "SRC-PM39198950",
        "source_type": "journal_article",
        "title": "[A headspace injection double-column dual-detector gas chromatography system for the analysis of 12 volatile compounds such as ethanol in human blood]",
        "authors": ["Zheng QY", "Zhi YJ", "Duan W", "Lü M", "Xiao Y", "Xiang P", "Chen H", "Yun K"],
        "journal": "Se Pu (Chinese Journal of Chromatography)",
        "publication_year": 2024,
        "doi": "10.3724/SP.J.1123.2023.12015",
        "pmid": "39198950",
        "official_url": "https://doi.org/10.3724/SP.J.1123.2023.12015",
        "accessed_date": "2026-10-10",
        "tier": "tier2", "evidence_level": "C", "license_mode": "citeOnly", "identifier_verified": True,
        "notes": "PubMed metadata (PMID, DOI) verified 2026-10-10. Chinese-language article; checked at the English ABSTRACT level only; the full text was not read.",
    },
    {
        "source_id": "SRC-PM28766526",
        "source_type": "journal_article",
        "title": "[The development of the method for the determination of the low-molecular weight alcohol content in the specimens of the biological materials]",
        "authors": ["Afonin DA", "Khatuntsev SV", "Vinogradova OV", "Gorbacheva TV"],
        "journal": "Sudebno-meditsinskaia ekspertiza",
        "publication_year": 2017,
        "doi": "10.17116/sudmed201760329-33",
        "pmid": "28766526",
        "official_url": "https://doi.org/10.17116/sudmed201760329-33",
        "accessed_date": "2026-10-10",
        "tier": "tier2", "evidence_level": "C", "license_mode": "citeOnly", "identifier_verified": True,
        "notes": "PubMed metadata (PMID, DOI) verified 2026-10-10. Russian-language article; checked at the English ABSTRACT level only; the full text was not read.",
    },
    {
        "source_id": "SRC-PM21404443",
        "source_type": "journal_article",
        "title": "Development and validation of a direct headspace GC-FID method for the determination of sevoflurane, desflurane and other volatile compounds of forensic interest in biological fluids: application on clinical and post-mortem samples",
        "authors": ["Kovatsi L", "Giannakis D", "Arzoglou V", "Samanidou V"],
        "journal": "Journal of Separation Science",
        "publication_year": 2011,
        "doi": "10.1002/jssc.201000921",
        "pmid": "21404443",
        "official_url": "https://doi.org/10.1002/jssc.201000921",
        "accessed_date": "2026-10-10",
        "tier": "tier2", "evidence_level": "B", "license_mode": "citeOnly", "identifier_verified": True,
        "notes": "PubMed metadata (PMID, DOI) verified 2026-10-10. Checked at ABSTRACT level only; the full text was not read.",
    },
]

# Short names used in locators / source_i18n
SHORT = {
    SRC_TAYLOR: "Taylor et al., Molecules 2022;27(15):4771",
    "SRC-PM37804205": "Olds, Jones, J Anal Toxicol 2024;48(1):9–26",
    "SRC-PM36346343": "Musile et al., J Anal Toxicol 2023;46(9):e274–e279",
    "SRC-PM27488829": "Chun et al., J Anal Toxicol 2016;40(8):653–658",
    "SRC-PM33031530": "Pinto et al., J Anal Toxicol 2021;45(9):961–968",
    "SRC-PM39198950": "Zheng et al., Se Pu 2024;42(9):909–917",
    "SRC-PM28766526": "Afonin et al., Sud Med Ekspert 2017;60(4):29–33",
    "SRC-PM21404443": "Kovatsi et al., J Sep Sci 2011;34(9):1004–1010",
}

# Section names inside the full-text source (Taylor 2022), tri-lingual
TAYLOR_SEC = {
    "intro": ("section 1 (Introduction), paragraphs 3–4", "1-bo‘lim («Introduction»), 3–4-xatboshilar",
              "раздел 1 («Introduction»), абзацы 3–4"),
    "prep": ("sections 4.3 (Sample Preparation) and 4.4 (Headspace GC-FID Method)",
             "4.3 («Sample Preparation») va 4.4 («Headspace GC-FID Method») bo‘limlari",
             "разделы 4.3 («Sample Preparation») и 4.4 («Headspace GC-FID Method»)"),
    "instr": ("sections 4.2 (Instrumentation), 2.1 (Separation Conditions) and 4.4",
              "4.2 («Instrumentation»), 2.1 («Separation Conditions») va 4.4 bo‘limlari",
              "разделы 4.2 («Instrumentation»), 2.1 («Separation Conditions») и 4.4"),
    "calib": ("sections 2.2 (Linearity), 2.6 (Limit of Detection and Quantification) and 3 (Discussion)",
              "2.2 («Linearity»), 2.6 («Limit of Detection and Quantification») va 3 («Discussion») bo‘limlari",
              "разделы 2.2 («Linearity»), 2.6 («Limit of Detection and Quantification») и 3 («Discussion»)"),
    "sep": ("sections 2.1 (Separation Conditions) and 3 (Discussion)",
            "2.1 («Separation Conditions») va 3 («Discussion») bo‘limlari",
            "разделы 2.1 («Separation Conditions») и 3 («Discussion»)"),
    "unc": ("sections 2.4 (Accuracy) and 2.5 (Uncertainty)",
            "2.4 («Accuracy») va 2.5 («Uncertainty») bo‘limlari",
            "разделы 2.4 («Accuracy») и 2.5 («Uncertainty»)"),
}

ABS = ("abstract", "annotatsiya", "аннотация")  # reading level word, tri

# ---------------------------------------------------------------------------------- claims
# Each: id, field, cites = [(source_id, locator_tri or None for abstract)], read_level, evidence_class,
#       en/uz/ru statement.
CLAIMS = [
    {
        "id": "C-EP-ETHANOL-01",
        "field": "analytical_method",
        "method_family": "instrumental",
        "cites": [(SRC_TAYLOR, "intro")],
        "read": "full_text",
        "level": "B",
        "en": "Routine method for ethanol in blood or urine: static headspace gas chromatography with a flame ionization detector (HS-GC-FID). The specimen is sealed in a vial with an internal-standard solution, warmed so that volatile ethanol passes into the vapour above the liquid, and a portion of that vapour is injected into the chromatograph; no extraction step is needed. The source calls it the industry-standard alcohol technique because it detects volatile compounds with minimal sample preparation. It needs a gas chromatograph with a flame ionization detector and a headspace sampler, not a mass spectrometer; the source lists three ways of transferring the vapour to the column: a filled loop, pressure balancing, and direct injection with a gas-tight syringe. This is an instrumental result and must be confirmed against reference standards run in the same batch.",
        "uz": "Qon yoki siydikdagi etanolni aniqlashning odatiy usuli — alanga-ionlashtiruvchi detektorli statik headspace (bug‘ fazasi) gaz xromatografiyasi (HS-GC-FID). Namuna ichki standart eritmasi bilan idishchaga zich yopiladi, uchuvchan etanol suyuqlik ustidagi bug‘ fazasiga o‘tishi uchun isitiladi va shu bug‘dan bir qismi xromatografga yuboriladi; ekstraksiya bosqichi kerak emas. Manba uni spirt tahlilining sanoat standarti deb ataydi, chunki uchuvchan birikmalar minimal namuna tayyorlash bilan aniqlanadi. Buning uchun alanga-ionlashtiruvchi detektorli gaz xromatografi va headspace dozator kerak, mass-spektrometr shart emas; manba bug‘ni ustunga o‘tkazishning uch yo‘lini sanaydi: to‘ldiriladigan halqa, bosimni tenglashtirish va gaz o‘tkazmaydigan shprisdan to‘g‘ridan-to‘g‘ri kiritish. Bu instrumental natija; xuddi shu seriyada o‘tkazilgan standart namunalar bilan tasdiqlanishi shart.",
        "ru": "Рутинный метод определения этанола в крови или моче — статическая парофазная газовая хроматография с пламенно-ионизационным детектором (HS-GC-FID). Образец герметично закрывают во флаконе с раствором внутреннего стандарта, нагревают, чтобы летучий этанол перешёл в паровую фазу над жидкостью, и вводят в хроматограф часть этого пара; стадия экстракции не нужна. Источник называет его отраслевым стандартом анализа спиртов, поскольку летучие соединения определяются при минимальной подготовке пробы. Нужны газовый хроматограф с пламенно-ионизационным детектором и парофазный дозатор, масс-спектрометр не обязателен; источник перечисляет три способа переноса пара на колонку: заполняемая петля, выравнивание давления и прямой ввод газонепроницаемым шприцем. Это инструментальный результат; его необходимо подтверждать эталонными образцами той же серии.",
    },
    {
        "id": "C-EP-ETHANOL-02",
        "field": "sample_preparation",
        "method_family": "instrumental",
        "cites": [(SRC_TAYLOR, "prep")],
        "read": "full_text",
        "level": "B",
        "en": "Example of a validated sample preparation (one laboratory, one procedure, not a universal rule): 100 µL of blood or urine is added to 1 mL of an aqueous internal-standard solution in a 20 mL headspace vial; the solution contains tert-butanol (25 µL in 500 mL of water) and 2.5 g of sodium metabisulphite as an antioxidant. Each specimen is prepared in duplicate. The vial is equilibrated for 5 minutes with shaking, and 1 mL of the vapour is injected with a gas-tight syringe heated to 70 °C. The authors used no salting-out agent: the large volume of internal-standard solution relative to the specimen prevents salting-out effects that can appear at smaller volumes. The whole analysis takes under 5 minutes.",
        "uz": "Validatsiyadan o‘tgan namuna tayyorlashga misol (bitta laboratoriya, bitta tartib, umumiy qoida emas): 20 ml li headspace idishchaga 100 µL qon yoki siydik va 1 ml suvli ichki standart eritmasi solinadi; eritmada tert-butanol (500 ml suvda 25 µL) va antioksidant sifatida 2,5 g natriy metabisulfit bor. Har bir namuna ikki nusxada tayyorlanadi. Idishcha chayqatilgan holda 5 daqiqa muvozanatlanadi, so‘ng 70 °C gacha isitilgan gaz o‘tkazmaydigan shpris bilan 1 ml bug‘ yuboriladi. Mualliflar tuzlash vositasini ishlatmagan: namunaga nisbatan ichki standart eritmasining katta hajmi kichik hajmlarda paydo bo‘lishi mumkin bo‘lgan tuzlanish ta’sirining oldini oladi. Butun tahlil 5 daqiqadan kam vaqt oladi.",
        "ru": "Пример валидированной пробоподготовки (одна лаборатория, одна методика, не универсальное правило): во флакон для парофазного анализа объёмом 20 мл вносят 100 µL крови или мочи и 1 мл водного раствора внутреннего стандарта; раствор содержит трет-бутанол (25 µL на 500 мл воды) и 2,5 г метабисульфита натрия в качестве антиоксиданта. Каждый образец готовят в двух повторах. Флакон выдерживают для установления равновесия 5 минут при встряхивании, затем вводят 1 мл пара газонепроницаемым шприцем, нагретым до 70 °C. Авторы не применяли высаливающий агент: большой объём раствора внутреннего стандарта по сравнению с образцом предотвращает эффект высаливания, который возможен при меньших объёмах. Весь анализ занимает менее 5 минут.",
    },
    {
        "id": "C-EP-ETHANOL-03",
        "field": "instrumentation",
        "method_family": "instrumental",
        "cites": [(SRC_TAYLOR, "instr")],
        "read": "full_text",
        "level": "B",
        "en": "Instrument set-up of the same validated method (example): two capillary columns of different selectivity made for alcohol analysis (each 30 m × 0.32 mm internal diameter, film 1.8 µm and 0.6 µm) joined to one inlet through a Y connector, each with its own flame ionization detector; helium carrier gas at 2.78 mL/min; hydrogen and air for the flame and nitrogen as make-up gas. The oven is isothermal at 40 °C (the authors tested 40–50 °C); equilibration 5 minutes (5, 10, 15 and 20 minutes were compared); 85 kPa column pressure (150 to 65 kPa were compared). These conditions separate ethanol from tert-butanol and acetaldehyde in under 5 minutes. Injection mode (split or splitless, split ratio) and inlet temperature are given in an instrument table that was not available in the text read: source check pending.",
        "uz": "Shu validatsiyadan o‘tgan usulning asbob sozlamasi (misol): spirt tahlili uchun mo‘ljallangan, tanlovchanligi har xil ikkita kapillyar ustun (har biri 30 m × 0,32 mm ichki diametr, qatlam qalinligi 1,8 µm va 0,6 µm) bitta kirish nuqtasiga Y shaklidagi ulagich orqali ulangan, har birida alohida alanga-ionlashtiruvchi detektor bor; tashuvchi gaz — geliy, 2,78 ml/min; alanga uchun vodorod va havo, to‘ldiruvchi gaz — azot. Termostat izotermik, 40 °C (mualliflar 40–50 °C ni sinab ko‘rgan); muvozanatlash 5 daqiqa (5, 10, 15 va 20 daqiqa taqqoslangan); ustundagi bosim 85 kPa (150 dan 65 kPa gacha taqqoslangan). Bu sharoitda etanol tert-butanol va atsetaldegiddan 5 daqiqadan kam vaqtda ajraladi. Kiritish rejimi (bo‘linish bor yoki yo‘q, bo‘linish nisbati) va kirish nuqtasi harorati o‘qilgan matnda bo‘lmagan asbob jadvalida berilgan: manba tekshirilmoqda.",
        "ru": "Настройка прибора в той же валидированной методике (пример): две капиллярные колонки разной селективности для анализа спиртов (каждая 30 м × 0,32 мм внутренний диаметр, толщина плёнки 1,8 µm и 0,6 µm), соединённые с одним входом через Y-образный разветвитель, у каждой свой пламенно-ионизационный детектор; газ-носитель гелий, 2,78 мл/мин; водород и воздух для пламени, азот как поддувочный газ. Термостат изотермический, 40 °C (авторы испытали 40–50 °C); время установления равновесия 5 минут (сравнивали 5, 10, 15 и 20 минут); давление на колонке 85 кПа (сравнивали от 150 до 65 кПа). В этих условиях этанол отделяется от трет-бутанола и ацетальдегида менее чем за 5 минут. Режим ввода (с делением потока или без деления, коэффициент деления) и температура испарителя приведены в таблице параметров прибора, которой не было в прочитанном тексте: источник проверяется.",
    },
    {
        "id": "C-EP-ETHANOL-04",
        "field": "qc_requirement",
        "method_family": "instrumental",
        "cites": [(SRC_TAYLOR, "calib")],
        "read": "full_text",
        "level": "B",
        "en": "Calibration and quality control in the same validated method: six calibrators of 10, 20, 50, 100, 200 and 400 mg/100 mL; the calibration line must reach a correlation coefficient of at least 0.998 (typical acceptance in England and Wales road-traffic casework; the authors aimed for r² above 0.999); control samples at 20, 80 and 200 mg/100 mL. Every reported result is the mean of four sub-results (duplicate preparations on two columns) and their spread is limited to 2.5 % at and above 80 mg/100 mL and to 2.5 mg/100 mL below 80 mg/100 mL. The lowest calibrator, 10 mg/100 mL, is the limit of quantitation; ethanol was detected at 5 mg/100 mL with a signal-to-noise ratio above 3:1. A blank internal-standard sample run after the highest calibrator and between replicates showed no carryover. These acceptance numbers belong to one laboratory and one jurisdiction; another laboratory must set and document its own.",
        "uz": "Shu validatsiyadan o‘tgan usulda kalibrlash va sifat nazorati: 10, 20, 50, 100, 200 va 400 mg/100 ml li oltita kalibrator; kalibrlash chizig‘ining korrelyatsiya koeffitsienti kamida 0,998 bo‘lishi kerak (Angliya va Uelsda yo‘l harakati bo‘yicha ishlarda odatiy mezon; mualliflar r² ni 0,999 dan yuqori qilishni maqsad qilgan); nazorat namunalari 20, 80 va 200 mg/100 ml da. Har bir bildirilgan natija to‘rtta qisman natijaning (ikki ustunda ikki nusxa) o‘rtachasi, ularning tarqalishi 80 mg/100 ml va undan yuqorida 2,5 % bilan, 80 mg/100 ml dan pastda 2,5 mg/100 ml bilan cheklangan. Eng past kalibrator, 10 mg/100 ml, miqdoriy aniqlash chegarasi; etanol 5 mg/100 ml da signal-shovqin nisbati 3:1 dan yuqori bo‘lganda aniqlangan. Eng yuqori kalibratordan keyin va nusxalar orasida o‘tkazilgan bo‘sh ichki standart namunasida o‘tib qolish kuzatilmagan. Bu qabul raqamlari bitta laboratoriya va bitta yurisdiksiyaga tegishli; boshqa laboratoriya o‘zinikini belgilab, hujjatlashtirishi kerak.",
        "ru": "Калибровка и контроль качества в той же валидированной методике: шесть калибраторов 10, 20, 50, 100, 200 и 400 мг/100 мл; коэффициент корреляции градуировочной прямой должен быть не ниже 0,998 (типичный критерий для дел о дорожном движении в Англии и Уэльсе; авторы стремились к r² выше 0,999); контрольные образцы 20, 80 и 200 мг/100 мл. Каждый сообщаемый результат — среднее из четырёх частных результатов (два повтора на двух колонках), их разброс ограничен 2,5 % при 80 мг/100 мл и выше и 2,5 мг/100 мл ниже 80 мг/100 мл. Наименьший калибратор, 10 мг/100 мл, — предел количественного определения; этанол обнаруживали при 5 мг/100 мл с отношением сигнал/шум выше 3:1. Холостая проба с внутренним стандартом после самого высокого калибратора и между повторами не показала переноса. Эти критерии относятся к одной лаборатории и одной юрисдикции; другая лаборатория должна установить и документировать собственные.",
    },
    {
        "id": "C-EP-ETHANOL-05",
        "field": "sample_preparation",
        "method_family": "instrumental",
        "cites": [("SRC-PM36346343", None), ("SRC-PM33031530", None), ("SRC-PM27488829", None),
                  ("SRC-PM21404443", None), ("SRC-PM28766526", None)],
        "read": "abstract",
        "level": "C",
        "en": "Internal standard: published headspace GC-FID methods for ethanol use tert-butanol (vitreous humour; brain tissue), acetonitrile (blood, urine and vitreous humour; a multi-volatile blood and urine method) or n-propanol (one Russian certified method for blood and urine). A compound that putrefaction can produce is a poor choice for decomposed material: n-propanol is a typical product of post-mortem microbial fermentation, and in one vitreous study it appeared in blood samples whose ethanol was higher than in the vitreous humour. The Russian method measures the internal standard in the original specimen before analysis. Checked at abstract level only, not the full texts.",
        "uz": "Ichki standart: e’lon qilingan headspace GC-FID usullarida etanol uchun tert-butanol (shishasimon tana suyuqligi; miya to‘qimasi), asetonitril (qon, siydik va shishasimon tana suyuqligi; ko‘p uchuvchi birikmalarni aniqlash usuli) yoki n-propanol (qon va siydik uchun bitta rus sertifikatlangan usuli) ishlatilgan. Chirish jarayonida hosil bo‘lishi mumkin bo‘lgan birikma chigan material uchun yomon tanlov: n-propanol o‘limdan keyingi mikrob bijg‘ishining odatiy mahsuloti, va bitta shishasimon tana tadqiqotida u etanoli shishasimon tanadagidan yuqori bo‘lgan qon namunalarida topilgan. Rus usuli tahlildan oldin dastlabki namunada ichki standartning o‘zini ham o‘lchaydi. Faqat annotatsiya darajasida tekshirilgan, to‘liq matnlar o‘qilmagan.",
        "ru": "Внутренний стандарт: в опубликованных методиках HS-GC-FID для этанола применяют трет-бутанол (стекловидное тело; ткань мозга), ацетонитрил (кровь, моча и стекловидное тело; методика определения многих летучих соединений) или н-пропанол (одна российская аттестованная методика для крови и мочи). Для разложившегося материала плохо подходит соединение, которое может образоваться при гниении: н-пропанол — типичный продукт посмертного микробного брожения, и в одном исследовании стекловидного тела он обнаруживался в образцах крови, где этанола было больше, чем в стекловидном теле. Российская методика измеряет внутренний стандарт в исходном образце до анализа. Проверено только на уровне аннотации, полные тексты не прочитаны.",
    },
    {
        "id": "C-EP-ETHANOL-06",
        "field": "interference",
        "method_family": "instrumental",
        "cites": [(SRC_TAYLOR, "sep"), ("SRC-PM33031530", None), ("SRC-PM28766526", None)],
        "read": "full_text",
        "level": "B",
        "en": "Identification and interference: ethanol is identified by its retention on two columns of different selectivity. In the Taylor method one column separated ethanol completely from the common interferences (methanol, isopropanol, acetaldehyde, acetone); the other did not fully separate ethanol from acetone, but acetone at 10 mg/100 mL or below did not disturb ethanol resolution or quantitation. When the two columns disagree because of acetone, the analysis is repeated and the four sub-results from the column that separates acetone are used. Two other published methods also work with two columns of different polarity (a 16-volatile panel for putrefied and submerged bodies; a Russian two-detector method) so that a single peak is never accepted on one retention time alone. Taylor 2022 was read in full; the other two were checked at abstract level.",
        "uz": "Aynanlik va halaqit beruvchi moddalar: etanol tanlovchanligi har xil ikkita ustundagi ushlanish vaqti bo‘yicha aniqlanadi. Taylor usulida bitta ustun etanolni keng tarqalgan halaqit beruvchi moddalardan (metanol, izopropanol, atsetaldegid, aseton) to‘liq ajratgan; ikkinchisi etanolni asetondan to‘liq ajratmagan, ammo 10 mg/100 ml va undan kam aseton etanolning ajralishi va miqdoriy aniqlanishiga xalaqit bermagan. Ikki ustun aseton sababli bir-biridan farq qilsa, tahlil takrorlanadi va asetonni ajratadigan ustunning to‘rtta qisman natijasidan foydalaniladi. Yana ikkita e’lon qilingan usul ham qutbliligi har xil ikkita ustun bilan ishlaydi (chirigan va suvda topilgan jasadlar uchun 16 ta uchuvchi birikma usuli; ikki detektorli rus usuli), shuning uchun bitta cho‘qqi faqat bitta ushlanish vaqtiga qarab qabul qilinmaydi. Taylor 2022 to‘liq o‘qilgan; qolgan ikkitasi annotatsiya darajasida tekshirilgan.",
        "ru": "Идентификация и мешающие вещества: этанол идентифицируют по удерживанию на двух колонках разной селективности. В методике Taylor одна колонка полностью отделяла этанол от распространённых мешающих веществ (метанол, изопропанол, ацетальдегид, ацетон); другая не полностью отделяла этанол от ацетона, но ацетон при 10 мг/100 мл и ниже не мешал разделению и количественному определению этанола. Если колонки расходятся из-за ацетона, анализ повторяют и используют четыре частных результата с колонки, разделяющей ацетон. Ещё две опубликованные методики тоже работают с двумя колонками разной полярности (панель из 16 летучих веществ для гниющих и найденных в воде тел; российская методика с двумя детекторами), поэтому один пик не принимают по единственному времени удерживания. Taylor 2022 прочитана полностью; две другие проверены на уровне аннотации.",
    },
    {
        "id": "C-EP-ETHANOL-07",
        "field": "validation_requirement",
        "method_family": "instrumental",
        "cites": [(SRC_TAYLOR, "unc"), ("SRC-PM39198950", None)],
        "read": "full_text",
        "level": "B",
        "en": "Method performance figures from validated headspace GC-FID work. Taylor et al.: expanded uncertainty at 99.73 % confidence of 5.31 % at 20 mg/100 mL, 3.64 % at 80 mg/100 mL and 1.95 % at 200 mg/100 mL; bias was not significant at 80 and 200 mg/100 mL but was significant at 20 mg/100 mL. Zheng et al. (abstract level): 100 µL of blood or urine with tert-butanol (0.04 g/L) as internal standard; linear range 0.10–3.00 g/L, detection limit 0.05 g/L, recoveries 92.2–111.6 % and relative standard deviations 0.4–7.4 % (n = 6) on two instrument platforms and two column sets; the largest part of the ethanol uncertainty came from the calibration curve. These are the results of those laboratories; a laboratory must establish its own uncertainty and limits during its own validation.",
        "uz": "Validatsiyadan o‘tgan headspace GC-FID ishlaridagi usul ko‘rsatkichlari. Taylor va boshq.: 99,73 % ishonchlilikdagi kengaytirilgan noaniqlik 20 mg/100 ml da 5,31 %, 80 mg/100 ml da 3,64 % va 200 mg/100 ml da 1,95 %; siljish 80 va 200 mg/100 ml da ahamiyatli bo‘lmagan, 20 mg/100 ml da ahamiyatli bo‘lgan. Zheng va boshq. (annotatsiya darajasi): 100 µL qon yoki siydik, ichki standart — tert-butanol (0,04 g/L); chiziqli diapazon 0,10–3,00 g/L, aniqlash chegarasi 0,05 g/L, qaytarilish 92,2–111,6 % va nisbiy standart og‘ish 0,4–7,4 % (n = 6) ikki xil asbob platformasi va ikki xil ustunda; etanol noaniqligining eng katta qismi kalibrlash egri chizig‘idan kelgan. Bular o‘sha laboratoriyalarning natijalari; har bir laboratoriya o‘z validatsiyasida o‘z noaniqligi va chegaralarini belgilashi kerak.",
        "ru": "Показатели методик HS-GC-FID, прошедших валидацию. Taylor и соавт.: расширенная неопределённость при доверительной вероятности 99,73 % равна 5,31 % при 20 мг/100 мл, 3,64 % при 80 мг/100 мл и 1,95 % при 200 мг/100 мл; смещение было незначимым при 80 и 200 мг/100 мл и значимым при 20 мг/100 мл. Zheng и соавт. (уровень аннотации): 100 µL крови или мочи, внутренний стандарт — трет-бутанол (0,04 г/л); линейный диапазон 0,10–3,00 г/л, предел обнаружения 0,05 г/л, степень извлечения 92,2–111,6 % и относительное стандартное отклонение 0,4–7,4 % (n = 6) на двух приборных платформах и двух наборах колонок; наибольший вклад в неопределённость этанола дала градуировочная кривая. Это результаты данных лабораторий; каждая лаборатория должна установить собственную неопределённость и пределы при своей валидации.",
    },
    {
        "id": "C-EP-ETHANOL-08",
        "field": "limitation",
        "method_family": "caveat",
        "cites": [("SRC-PM37804205", None), ("SRC-PM36346343", None)],
        "read": "abstract",
        "level": "B",
        "en": "Limitation for post-mortem blood: ethanol can be formed in a decomposed body by microbial activity and fermentation of blood glucose, so a positive result in putrefied blood does not by itself show drinking before death. The reviewed approaches are: measure ethanol in another specimen (vitreous humour, urine, bile, cerebrospinal fluid) and compare it with blood; look in blood for other volatiles that microbes make (acetaldehyde, n-propanol, n-butanol); use alcohol biomarkers (ethyl glucuronide, ethyl sulfate, phosphatidylethanol); add 1–2 % w/v sodium or potassium fluoride to every post-mortem specimen to stop formation after sampling. In a 75-case study 14 vitreous specimens had lower ethanol than the matching blood, and n-propanol was seen in that blood. The authors of the review propose a reporting cut-off of 0.02 g% instead of 0.01 g% for post-mortem blood and, for an obviously decomposed body, subtracting 0.05 g% from the mean result; these are their proposals, not an accepted rule. Abstract level only.",
        "uz": "O‘limdan keyingi qon uchun cheklov: chigan jasadda etanol mikroblar faoliyati va qon glyukozasining bijg‘ishi natijasida hosil bo‘lishi mumkin, shuning uchun chigan qondagi musbat natijaning o‘zi o‘lim oldidan ichilganini isbotlamaydi. Sharhda keltirilgan yondashuvlar: etanolni boshqa namunada (shishasimon tana suyuqligi, siydik, o‘t, orqa miya suyuqligi) o‘lchab, qon bilan solishtirish; qonda mikroblar hosil qiladigan boshqa uchuvchi moddalarni (atsetaldegid, n-propanol, n-butanol) izlash; spirt biomarkerlaridan (etilglyukuronid, etilsulfat, fosfatidiletanol) foydalanish; namuna olingandan keyin hosil bo‘lishini to‘xtatish uchun har bir o‘limdan keyingi namunaga 1–2 % w/v natriy yoki kaliy ftorid qo‘shish. 75 ta holatni o‘rgangan tadqiqotda 14 ta shishasimon tana namunasida etanol mos qondagidan past bo‘lgan va o‘sha qonda n-propanol ko‘ringan. Sharh mualliflari o‘limdan keyingi qon uchun bildirish chegarasini 0,01 g% o‘rniga 0,02 g% qilishni va aniq chigan jasadda o‘rtacha natijadan 0,05 g% ayirishni taklif qiladi; bular ularning takliflari, qabul qilingan qoida emas. Faqat annotatsiya darajasi.",
        "ru": "Ограничение для посмертной крови: в разложившемся теле этанол может образовываться под действием микроорганизмов и брожения глюкозы крови, поэтому положительный результат в гнилой крови сам по себе не доказывает употребление до смерти. Рассмотренные подходы: измерить этанол в другом образце (стекловидное тело, моча, желчь, спинномозговая жидкость) и сравнить с кровью; искать в крови другие летучие вещества, которые образуют микроорганизмы (ацетальдегид, н-пропанол, н-бутанол); использовать биомаркеры алкоголя (этилглюкуронид, этилсульфат, фосфатидилэтанол); добавлять во все посмертные образцы 1–2 % w/v фторида натрия или калия, чтобы остановить образование после забора. В исследовании 75 случаев в 14 образцах стекловидного тела этанола было меньше, чем в соответствующей крови, и в этой крови был виден н-пропанол. Авторы обзора предлагают порог сообщения 0,02 g% вместо 0,01 g% для посмертной крови и, для явно разложившегося тела, вычитание 0,05 g% из среднего результата; это их предложения, а не принятое правило. Только уровень аннотации.",
    },
    {
        "id": "C-EP-ETHANOL-09",
        "field": "specimens",
        "method_family": "instrumental",
        "cites": [("SRC-PM27488829", None), ("SRC-PM36346343", None), ("SRC-PM33031530", None)],
        "read": "abstract",
        "level": "C",
        "en": "Other specimens analysed by headspace GC-FID. Brain tissue (post-mortem, when blood is unavailable or contaminated): a 4-fold diluted homogenate of unfixed, volatile-free brain; calibrators and controls prepared in that matrix with tert-butanol as internal standard; quantitation limits of 100–110 mg/kg; the matrix effect was not significant. Vitreous humour: a 1:9 dilution with 2.5 mol/L potassium carbonate (salting-out) and 0.0012 mol/L tert-butanol, 2000 µL of vapour injected, isothermal at 40 °C, run time 1.6 minutes; vitreous humour is less affected by putrefaction than blood. A 16-volatile panel (including ethanol, methanol, 1-propanol, 2-propanol, acetone, acetaldehyde) was validated for blood, urine and vitreous humour with limits of detection of 1–8 mg/L. Abstract level only.",
        "uz": "Headspace GC-FID bilan tahlil qilinadigan boshqa namunalar. Miya to‘qimasi (o‘limdan keyin, qon bo‘lmaganda yoki ifloslanganda): fiksatsiya qilinmagan, uchuvchi moddalardan xoli miyaning 4 marta suyultirilgan gomogenati; kalibratorlar va nazorat namunalari shu matritsada tayyorlangan, ichki standart — tert-butanol; miqdoriy aniqlash chegarasi 100–110 mg/kg; matritsa ta’siri ahamiyatli bo‘lmagan. Shishasimon tana suyuqligi: 2,5 mol/L kaliy karbonat (tuzlash) va 0,0012 mol/L tert-butanol bilan 1:9 suyultirish, 2000 µL bug‘ yuboriladi, izotermik 40 °C, tahlil vaqti 1,6 daqiqa; shishasimon tana suyuqligi qonga qaraganda chirishdan kamroq ta’sirlanadi. 16 ta uchuvchi modda (shu jumladan etanol, metanol, 1-propanol, 2-propanol, aseton, atsetaldegid) usuli qon, siydik va shishasimon tana suyuqligi uchun validatsiya qilingan, aniqlash chegaralari 1–8 mg/L. Faqat annotatsiya darajasi.",
        "ru": "Другие образцы, анализируемые методом HS-GC-FID. Ткань мозга (посмертно, когда кровь недоступна или загрязнена): 4-кратно разбавленный гомогенат нефиксированного мозга, не содержащего летучих веществ; калибраторы и контроли приготовлены в этой матрице, внутренний стандарт — трет-бутанол; пределы количественного определения 100–110 мг/кг; влияние матрицы было незначимым. Стекловидное тело: разведение 1:9 раствором карбоната калия 2,5 моль/л (высаливание) и трет-бутанолом 0,0012 моль/л, вводят 2000 µL пара, изотермический режим 40 °C, время анализа 1,6 минуты; стекловидное тело меньше подвержено гниению, чем кровь. Панель из 16 летучих веществ (включая этанол, метанол, 1-пропанол, 2-пропанол, ацетон, ацетальдегид) валидирована для крови, мочи и стекловидного тела с пределами обнаружения 1–8 мг/л. Только уровень аннотации.",
    },
]
