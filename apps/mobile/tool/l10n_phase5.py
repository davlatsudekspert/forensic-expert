# PHASE 5 lokalizatsiya kalitlari. RU/UZ — review qilinmagan qoralama (RG-11).
import json, collections
D = "lib/core/l10n/arb"
K = collections.OrderedDict()
def k(key, desc, en, ru, uz, ph=None):
    K[key] = (desc, en, ru, uz, ph)
S = {"type": "String"}
I = {"type": "int"}

# Modullar
k("moduleHistology","Home module.","Forensic histology","Судебная гистология","Sud gistologiyasi")
k("moduleResearch","Home module.","Research & evidence","Исследования и доказательства","Tadqiqotlar va dalillar")

# Modda guruhlari (tahririy)
G = [("alcohols_volatiles","Alcohols & volatiles","Спирты и летучие вещества","Spirtlar va uchuvchan moddalar"),
 ("toxic_gases","Toxic gases","Токсичные газы","Toksik gazlar"),
 ("opioids","Opioids","Опиоиды","Opioidlar"),
 ("stimulants","Stimulants","Стимуляторы","Stimulyatorlar"),
 ("cannabinoids","Cannabinoids","Каннабиноиды","Kannabinoidlar"),
 ("hallucinogens_dissociatives","Hallucinogens & dissociatives","Галлюциногены и диссоциативы","Gallyutsinogenlar va dissotsiativlar"),
 ("benzodiazepines","Benzodiazepines","Бензодиазепины","Benzodiazepinlar"),
 ("sedatives_hypnotics","Sedatives & hypnotics","Седативные и снотворные","Sedativ va uxlatuvchi"),
 ("barbiturates","Barbiturates","Барбитураты","Barbituratlar"),
 ("antidepressants","Antidepressants","Антидепрессанты","Antidepressantlar"),
 ("antipsychotics","Antipsychotics","Антипсихотики","Antipsixotiklar"),
 ("anticonvulsants","Anticonvulsants","Противосудорожные","Antikonvulsantlar"),
 ("pharmaceuticals","Common pharmaceuticals","Распространённые лекарства","Keng tarqalgan dorilar"),
 ("adulterants","Adulterants","Примеси (адюльтеранты)","Aralashmalar (adulterantlar)"),
 ("pesticides","Pesticides & rodenticides","Пестициды и родентициды","Pestitsidlar va rodentitsidlar"),
 ("metals_inorganic","Metals & inorganic poisons","Металлы и неорганические яды","Metallar va anorganik zaharlar")]
for g,en,ru,uz in G:
    k("group_"+g,"Substance group (editorial navigation).",en,ru,uz)
k("groupAll","Substance group filter: all.","All groups","Все группы","Barcha guruhlar")
k("groupEditorialNote","Explains groups are editorial.","Groups are editorial navigation, not a scientific classification claim.","Группы — редакционная навигация, а не научная классификация.","Guruhlar — tahririy navigatsiya, ilmiy tasnif da’vosi emas.")

# Modda sahifasi bo‘limlari
k("detailAnalyticalMethods","Substance section.","Analytical methods (from sources)","Аналитические методы (из источников)","Analitik metodlar (manbalardan)")
k("detailReportedConcentrations","Substance section.","Reported concentrations","Сообщённые концентрации","Xabar qilingan konsentratsiyalar")
k("concentrationNotThreshold","Permanent banner for reported concentrations.","Reported values from individual studies or cases — NOT toxic, lethal or legal thresholds. Interpretation depends on specimen, case context, tolerance and postmortem changes.","Значения из отдельных исследований или случаев — НЕ токсические, летальные или правовые пороги. Интерпретация зависит от образца, контекста, толерантности и посмертных изменений.","Alohida tadqiqot yoki holatlardan olingan qiymatlar — toksik, o‘ldiruvchi yoki huquqiy chegara EMAS. Talqin namuna, holat konteksti, tolerantlik va o‘limdan keyingi o‘zgarishlarga bog‘liq.")
k("concentrationSpecimen","Specimen chips label.","Specimen","Образец","Namuna")
k("concentrationContext","Context label.","Context: {context}","Контекст: {context}","Kontekst: {context}",{"context":S})
k("detailStructure","Chemical structure section.","Chemical structure","Химическая структура","Kimyoviy tuzilish")
k("detailRelated","Knowledge graph section.","Related professional content","Связанные профессиональные материалы","Bog‘liq professional materiallar")
k("relationAnalysedBy","Graph relation label.","Analysed by (mentioned in source)","Анализируется методом (упомянуто в источнике)","Tahlil metodi (manbada tilga olingan)")
k("relationMetabolism","Graph relation label.","Mentioned together in a metabolism source","Упомянуто вместе в источнике о метаболизме","Metabolizm manbasida birga tilga olingan")
k("relationConfirmedBy","Graph relation label.","Confirmatory methods","Подтверждающие методы","Tasdiqlovchi metodlar")
k("relationRelatedTopic","Graph relation label.","Related topics","Связанные темы","Bog‘liq mavzular")
k("relationResearch","Graph relation label.","Research & evidence","Исследования и доказательства","Tadqiqotlar va dalillar")
k("relationBasis","Basis of a link.","Basis: {basis}","Основание: {basis}","Asos: {basis}",{"basis":S})
k("researchMore","Show all research for entity.","All research ({count})","Все исследования ({count})","Barcha tadqiqotlar ({count})",{"count":I})

# Research
k("researchTitle","Research library title.","Research & evidence library","Библиотека исследований","Tadqiqotlar kutubxonasi")
k("researchNote","Research library explainer.","Metadata and links only — full texts are not copied. Dissertations, theses and conference papers are not shown at the level of peer-reviewed full articles.","Только метаданные и ссылки — полные тексты не копируются. Диссертации, тезисы и материалы конференций не приравниваются к рецензируемым статьям.","Faqat metadata va havolalar — to‘liq matn ko‘chirilmaydi. Dissertatsiya, tezis va konferensiya materiallari peer-reviewed maqola bilan teng ko‘rsatilmaydi.")
k("researchAll","Research filter all.","All","Все","Barchasi")
k("researchPeerReviewed","Badge.","Peer-reviewed","Рецензируемая","Taqrizdan o‘tgan")
k("researchNotPeerReviewed","Badge.","Not a peer-reviewed article","Не рецензируемая статья","Taqrizdan o‘tgan maqola emas")
k("researchEvidence","Evidence level badge.","Evidence {level}","Доказательность {level}","Dalil darajasi {level}",{"level":S})
k("researchCopyLink","Copy link action.","Copy link","Копировать ссылку","Havolani nusxalash")
k("researchLinkCopied","Snackbar.","Link copied","Ссылка скопирована","Havola nusxalandi")
k("researchLinked","Linked entities heading.","Linked records","Связанные записи","Bog‘liq yozuvlar")
k("researchCount","Count.","{count} records","{count} записей","{count} ta yozuv",{"count":I})
k("researchSourceApi","Source API.","Indexed via {api}","Индексировано через {api}","{api} orqali indekslangan",{"api":S})
R = [("journal_article","Journal article","Статья","Maqola"),("review","Review","Обзор","Sharh (review)"),
 ("systematic_review","Systematic review","Систематический обзор","Tizimli sharh"),("meta_analysis","Meta-analysis","Метаанализ","Meta-tahlil"),
 ("case_report","Case report","Описание случая","Holat tavsifi"),("conference_abstract","Conference abstract","Тезисы конференции","Konferensiya tezisi"),
 ("conference_paper","Conference paper","Доклад конференции","Konferensiya maqolasi"),("dissertation","Doctoral dissertation","Докторская диссертация","Doktorlik dissertatsiyasi"),
 ("thesis","Thesis (Master’s / other)","Диссертация (магистерская / др.)","Dissertatsiya (magistr / boshqa)"),
 ("official_report","Official report","Официальный отчёт","Rasmiy hisobot"),("standard","Standard / guideline","Стандарт / руководство","Standart / qo‘llanma")]
for code,en,ru,uz in R:
    kk="researchKind"+"".join(w.capitalize() for w in code.split("_"))
    k(kk,"Research kind.",en,ru,uz)

# Rasmlar
k("imageSchematic","Image badge.","Schematic — not experimental data","Схема — не экспериментальные данные","Sxema — eksperimental ma’lumot emas")
k("imageRealData","Image badge.","Figure from a published study","Рисунок из опубликованного исследования","Nashr qilingan tadqiqotdan rasm")
k("imageDepiction","Image badge.","Structure depiction (computed)","Изображение структуры (рассчитано)","Struktura tasviri (hisoblangan)")
k("imageLicense","Image license.","License: {license}","Лицензия: {license}","Litsenziya: {license}",{"license":S})
k("imageAttribution","Attribution heading.","Attribution","Атрибуция","Atribusiya")
k("imageOriginalCaption","Original caption heading.","Original caption (source language)","Оригинальная подпись","Asl izoh (manba tilida)")
k("imageOpen","Open image semantics.","Open image: {title}","Открыть изображение: {title}","Rasmni ochish: {title}",{"title":S})
k("imageUnavailable","Image fallback.","Image unavailable offline","Изображение недоступно офлайн","Rasm oflayn mavjud emas")
k("imagesHeading","Gallery heading.","Scientific visuals","Научные иллюстрации","Ilmiy tasvirlar")
k("licenseOriginalWork","License label.","Original work (FORENSIC EXPERT)","Оригинальная работа (FORENSIC EXPERT)","Original ish (FORENSIC EXPERT)")
k("licenseFactualDepiction","License label.","Original depiction of factual data","Оригинальное изображение фактических данных","Faktik ma’lumotning original tasviri")

# Gistologiya
k("histologyNote","Histology disclaimer.","Reference information for professionals. The app and Forensic AI do not provide histological diagnoses.","Справочная информация для специалистов. Приложение и Forensic AI не ставят гистологических диагнозов.","Mutaxassislar uchun ma’lumotnoma. Ilova va Forensic AI gistologik tashxis qo‘ymaydi.")
k("fieldCaseObservation","Claim field.","Case observation (single case)","Наблюдение (единичный случай)","Holat kuzatuvi (bitta holat)")
k("fieldComposition","Claim field.","Composition (as stated in source)","Состав (как в источнике)","Tarkib (manbadagidek)")
k("fieldConfirmation","Claim field.","Confirmation requirement","Требование подтверждения","Tasdiqlash talabi")

# Metadata yorliqlari
k("metaAuthors","Research metadata label.","Authors","Авторы","Mualliflar")
k("metaContainer","Research metadata label.","Journal / conference","Журнал / конференция","Jurnal / konferensiya")
k("metaInstitution","Research metadata label.","Institution","Учреждение","Muassasa")
k("metaDegree","Research metadata label.","Degree","Степень","Ilmiy daraja")
k("metaYear","Research metadata label.","Year","Год","Yil")
k("metaCreator","Image metadata label.","Creator","Автор изображения","Tasvir muallifi")
k("metaSource","Image metadata label.","Source","Источник","Manba")
k("metaAccessed","Image metadata label.","Accessed","Дата обращения","Murojaat sanasi")

# Analitik texnikalar (qisqartmalar xalqaro)
T = [("tlc","TLC (thin-layer chromatography)","ТСХ (тонкослойная хроматография)","TLC (yupqa qatlamli xromatografiya)"),
 ("gc","GC","ГХ","GC"),("gcFid","GC-FID","ГХ-ПИД","GC-FID"),("headspaceGc","Headspace GC","Парофазная ГХ","Headspace GC"),
 ("gcMs","GC-MS","ГХ-МС","GC-MS"),("hplc","HPLC","ВЭЖХ","HPLC"),("lcMsMs","LC-MS/MS","ЖХ-МС/МС","LC-MS/MS"),
 ("uvVis","UV-Vis spectrophotometry","УФ-видимая спектрофотометрия","UV-Vis spektrofotometriya"),
 ("immunoassay","Immunoassay","Иммуноанализ","Immunoanaliz"),("spectroscopy","Spectroscopy","Спектроскопия","Spektroskopiya"),
 ("samplePreparation","Sample preparation","Пробоподготовка","Namuna tayyorlash"),("extraction","Extraction","Экстракция","Ekstraksiya"),
 ("calibration","Calibration","Калибровка","Kalibrlash"),("qualityControl","Quality control","Контроль качества","Sifat nazorati"),
 ("validation","Method validation","Валидация методики","Metod validatsiyasi"),("uncertainty","Measurement uncertainty","Неопределённость измерений","O‘lchash noaniqligi"),
 ("statistics","Statistics","Статистика","Statistika")]
for code,en,ru,uz in T:
    k("tech_"+code,"Analytical technique name.",en,ru,uz)

# Metod bo‘limlari
MS = [("purpose","Purpose","Назначение","Maqsad"),("scope","Scope","Область применения","Qo‘llanish sohasi"),
 ("analytes","Analytes","Аналиты","Analitlar"),("specimens","Specimens","Образцы","Namunalar"),
 ("principle","Principle","Принцип","Prinsip"),("equipment","Equipment","Оборудование","Jihozlar"),
 ("reagents","Reagents","Реагенты","Reagentlar"),("samplePreparation","Sample preparation","Пробоподготовка","Namuna tayyorlash"),
 ("calibrationQc","Calibration and QC","Калибровка и контроль качества","Kalibrlash va sifat nazorati"),
 ("workflow","Workflow","Порядок работы","Ish tartibi"),("interpretation","Interpretation","Интерпретация","Talqin"),
 ("limitations","Limitations","Ограничения","Cheklovlar"),("validationStatus","Validation status","Статус валидации","Validatsiya holati")]
for code,en,ru,uz in MS:
    k("methodSection_"+code,"Method section heading.",en,ru,uz)

for idx, code in enumerate(["en","ru","uz"]):
    p = f"{D}/app_{code}.arb"
    data = json.load(open(p, encoding="utf-8"), object_pairs_hook=collections.OrderedDict)
    for key,(desc,en,ru,uz,ph) in K.items():
        data[key] = (en,ru,uz)[idx]
        if code == "en":
            meta = {"description": desc}
            if ph: meta["placeholders"] = ph
            data["@"+key] = meta
    json.dump(data, open(p,"w",encoding="utf-8"), ensure_ascii=False, indent=2)
    open(p,"a").write("\n")
print(len(K), "keys")
