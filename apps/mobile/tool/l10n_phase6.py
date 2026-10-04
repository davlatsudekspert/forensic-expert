# PHASE 6 lokalizatsiya kalitlari. RU/UZ — mashina qoralamasi, review kerak (RG-11).
import json, collections
D = "lib/core/l10n/arb"
K = collections.OrderedDict()
def k(key, desc, en, ru, uz, ph=None):
    K[key] = (desc, en, ru, uz, ph)
S = {"type": "String"}
I = {"type": "int"}

# --- Kalkulyatorlar ---------------------------------------------------------
k("toolMolarityDesc","Tool description.","Molar concentration from weighed mass, molar mass and volume.","Молярная концентрация по навеске, молярной массе и объёму.","Tortilgan massa, molyar massa va hajmdan molyar konsentratsiya.")
k("toolUnitsDesc","Tool description.","mg/L, µg/mL, ng/mL, mmol/L; mass ↔ molar with a supplied molar mass.","мг/л, мкг/мл, нг/мл, ммоль/л; массовая ↔ молярная при заданной молярной массе.","mg/L, µg/mL, ng/mL, mmol/L; berilgan molyar massa bilan massa ↔ molyar.")
k("toolPercentName","Tool name.","Percentage solutions","Процентные растворы","Foizli eritmalar")
k("toolPercentDesc","Tool description.","Solute amount for % (w/v), (v/v) or (w/w) by definition.","Количество вещества для % (масс./об.), (об./об.) или (масс./масс.) по определению.","% (w/v), (v/v) yoki (w/w) uchun ta’rif bo‘yicha erigan modda miqdori.")
k("calcValue","Calculator input.","Value","Значение","Qiymat")
k("calcFrom","Calculator input.","From","Из","Dan")
k("calcTo","Calculator input.","To","В","Ga")
k("calcConvertAssumption","Assumption.","Unit prefixes are SI definitions; mass ↔ molar conversion uses ρ = c · M.","Приставки единиц — определения СИ; пересчёт массовой ↔ молярной использует ρ = c · M.","Birlik prefikslari — SI ta’riflari; massa ↔ molyar o‘tish ρ = c · M dan foydalanadi.")
k("calcConvertLimitation","Limitation.","The molar mass must come from a certificate or verified identity data; the calculator never estimates it.","Молярная масса должна браться из сертификата или проверенных идентификационных данных; калькулятор её не оценивает.","Molyar massa sertifikat yoki tekshirilgan identifikatsiya ma’lumotidan olinadi; kalkulyator uni taxmin qilmaydi.")
k("calcMolarityMass","Calculator input.","Weighed mass","Навеска","Tortilgan massa")
k("calcMolarityVolume","Calculator input.","Final volume","Конечный объём","Yakuniy hajm")
k("calcMolarityResult","Calculator output.","Molar concentration","Молярная концентрация","Molyar konsentratsiya")
k("calcMolarityAssumption","Assumption.","Definition of amount-of-substance concentration: c = n / V, with n = m · p / M.","Определение молярной концентрации: c = n / V, где n = m · p / M.","Molyar konsentratsiya ta’rifi: c = n / V, bunda n = m · p / M.")
k("calcPercentBasis","Calculator input.","Percentage basis","Тип процентной концентрации","Foiz turi")
k("calcPercentWv","Option.","% (w/v) — g per 100 mL","% (масс./об.) — г на 100 мл","% (w/v) — 100 mL da g")
k("calcPercentVv","Option.","% (v/v) — mL per 100 mL","% (об./об.) — мл на 100 мл","% (v/v) — 100 mL da mL")
k("calcPercentWw","Option.","% (w/w) — g per 100 g","% (масс./масс.) — г на 100 г","% (w/w) — 100 g da g")
k("calcPercentValue","Calculator input.","Percentage (%)","Процент (%)","Foiz (%)")
k("calcPercentTotalMl","Calculator input.","Total solution volume (mL)","Общий объём раствора (мл)","Eritmaning umumiy hajmi (mL)")
k("calcPercentTotalG","Calculator input.","Total solution mass (g)","Общая масса раствора (г)","Eritmaning umumiy massasi (g)")
k("calcPercentSolute","Calculator output.","Solute amount","Количество растворённого вещества","Erigan modda miqdori")
k("calcPercentAssumption","Assumption.","Percentage definitions as stated for each basis.","Определения процентной концентрации — как указано для каждого типа.","Har bir tur uchun ko‘rsatilgan foiz ta’riflari.")
k("calcPercentLimitationBasis","Limitation.","w/v, v/v and w/w are not interchangeable — use the basis stated in the validated method or SOP.","масс./об., об./об. и масс./масс. не взаимозаменяемы — используйте тип, указанный в валидированной методике или СОП.","w/v, v/v va w/w o‘zaro almashtirilmaydi — validatsiyadan o‘tgan metod yoki SOP’dagi turni ishlating.")
k("calcErrorPercent","Error.","Enter a percentage greater than 0 and at most 100.","Введите процент больше 0 и не более 100.","0 dan katta va 100 dan oshmaydigan foiz kiriting.")
k("calcStatsValues","Calculator input.","Values (separated by spaces, commas or new lines)","Значения (через пробел, запятую или с новой строки)","Qiymatlar (bo‘sh joy, vergul yoki yangi qator bilan)")
k("calcStatsN","Statistic.","n","n","n")
k("calcStatsMean","Statistic.","Mean","Среднее","O‘rtacha")
k("calcStatsMedian","Statistic.","Median","Медиана","Mediana")
k("calcStatsSd","Statistic.","SD (n − 1)","СО (n − 1)","SO (n − 1)")
k("calcStatsCv","Statistic.","CV %","КВ %","VK %")
k("calcStatsMin","Statistic.","Minimum","Минимум","Minimum")
k("calcStatsMax","Statistic.","Maximum","Максимум","Maksimum")
k("calcStatsAssumption","Assumption.","Sample standard deviation with an n − 1 denominator.","Выборочное стандартное отклонение со знаменателем n − 1.","Maxraji n − 1 bo‘lgan tanlanma standart og‘ishi.")
k("calcStatsLimitation","Limitation.","No outlier test or normality check is performed.","Проверка выбросов и нормальности не выполняется.","Chetga chiquvchi qiymat yoki normallik tekshiruvi bajarilmaydi.")
k("calcStatsWarnSd","Warning.","At least two values are needed for SD and CV.","Для СО и КВ нужно не менее двух значений.","SO va VK uchun kamida ikkita qiymat kerak.")
k("calcErrorValues","Error.","Enter numeric values only.","Введите только числовые значения.","Faqat sonli qiymatlar kiriting.")
k("calcRegPoints","Calculator input.","Calibration points (one “x y” pair per line)","Точки калибровки (по одной паре «x y» в строке)","Kalibrlash nuqtalari (har qatorda bitta «x y» juftligi)")
k("calcRegSlope","Statistic.","Slope (b)","Наклон (b)","Qiyalik (b)")
k("calcRegIntercept","Statistic.","Intercept (a)","Свободный член (a)","Kesishma (a)")
k("calcRegR2","Statistic.","R²","R²","R²")
k("calcRegSyx","Statistic.","Residual SD (s_y/x)","Остаточное СО (s_y/x)","Qoldiq SO (s_y/x)")
k("calcRegAssumptionOls","Assumption.","Ordinary least squares, unweighted, y = a + b·x.","Метод наименьших квадратов без весов, y = a + b·x.","Vaznsiz eng kichik kvadratlar usuli, y = a + b·x.")
k("calcRegLimitationRange","Limitation.","Valid only within the calibrated range; weighting and linearity are decided by method validation.","Справедливо только в пределах калибровочного диапазона; взвешивание и линейность определяются валидацией методики.","Faqat kalibrlangan diapazon ichida amal qiladi; vazn va chiziqlilik metod validatsiyasida belgilanadi.")
k("calcRegWarnFew","Warning.","Fewer than five calibration points — interpret with caution.","Менее пяти точек калибровки — интерпретируйте с осторожностью.","Kalibrlash nuqtalari beshtadan kam — ehtiyotkorlik bilan talqin qiling.")
k("calcErrorPoints","Error.","Enter at least three “x y” pairs with different x values.","Введите не менее трёх пар «x y» с разными x.","Kamida uchta turli x qiymatli «x y» juftligini kiriting.")
k("calcLodSigma","Calculator input.","Standard deviation of the response (σ)","Стандартное отклонение отклика (σ)","Javob standart og‘ishi (σ)")
k("calcLodSlope","Calculator input.","Slope of the calibration curve (S)","Наклон калибровочной кривой (S)","Kalibrlash egri chizig‘i qiyaligi (S)")
k("calcLodSigmaBasis","Calculator input.","Basis of σ","Источник σ","σ asosi")
k("calcLodBasisBlank","Option.","SD of blank responses","СО откликов холостых проб","Bo‘sh namunalar javobining SO")
k("calcLodBasisResidual","Option.","Residual SD of the regression line","Остаточное СО регрессии","Regressiya chizig‘ining qoldiq SO")
k("calcLodBasisIntercept","Option.","SD of y-intercepts of regression lines","СО свободных членов регрессий","Regressiya chiziqlari y-kesishmalarining SO")
k("calcLodLod","Statistic.","Detection limit (DL = 3.3σ/S)","Предел обнаружения (DL = 3,3σ/S)","Aniqlash chegarasi (DL = 3,3σ/S)")
k("calcLodLoq","Statistic.","Quantitation limit (QL = 10σ/S)","Предел количественного определения (QL = 10σ/S)","Miqdoriy aniqlash chegarasi (QL = 10σ/S)")
k("calcLodAssumptionSigma","Assumption.","σ is estimated by one of the approaches named in the source: blank SD, residual SD or SD of y-intercepts.","σ оценивается одним из подходов, названных в источнике: СО холостых проб, остаточное СО или СО свободных членов.","σ manbada keltirilgan usullardan biri bilan baholanadi: bo‘sh namuna SO, qoldiq SO yoki y-kesishmalar SO.")
k("calcLodAssumptionLinear","Assumption.","The response is linear near the limit.","Отклик линеен вблизи предела.","Chegara yaqinida javob chiziqli.")
k("calcLodLimitationOne","Limitation.","This is one of several accepted approaches; visual evaluation and signal-to-noise are others.","Это один из нескольких допустимых подходов; другие — визуальная оценка и отношение сигнал/шум.","Bu bir nechta qabul qilingan usuldan biri; boshqalari — vizual baho va signal/shovqin nisbati.")
k("calcLodLimitationVerify","Limitation.","The source requires calculated limits to be confirmed by analysing samples near the limit.","Источник требует подтверждать рассчитанные пределы анализом проб вблизи предела.","Manba hisoblangan chegaralarni chegara yaqinidagi namunalarni tahlil qilib tasdiqlashni talab qiladi.")
k("calcLodReference","Reference.","ICH Q2(R1) Validation of Analytical Procedures: Text and Methodology — §6.3, §7.3","ICH Q2(R1) Validation of Analytical Procedures: Text and Methodology — §6.3, §7.3","ICH Q2(R1) Validation of Analytical Procedures: Text and Methodology — §6.3, §7.3")
k("calcLodReferenceNote","Reference note.","Factors checked against the official ICH PDF text. ICH Q2(R2) supersedes R1 — a reviewer must confirm the current version.","Коэффициенты сверены с официальным PDF ICH. ICH Q2(R2) заменяет R1 — актуальную версию должен подтвердить рецензент.","Koeffitsientlar rasmiy ICH PDF matni bilan solishtirildi. ICH Q2(R2) R1 o‘rnini bosadi — amaldagi versiyani reviewer tasdiqlashi kerak.")
k("calcUseRegression","Action.","Use σ = s_y/x and S from this regression","Взять σ = s_y/x и S из этой регрессии","Shu regressiyadagi σ = s_y/x va S dan foydalanish")
k("calcErrorSigma","Error.","Enter σ > 0 and a non-zero slope.","Введите σ > 0 и ненулевой наклон.","σ > 0 va noldan farqli qiyalik kiriting.")

# --- Yangi enum nomlari -----------------------------------------------------
k("researchKindGuideline","Research kind.","Guideline","Руководство","Qo‘llanma (guideline)")
k("researchKindValidationStudy","Research kind.","Validation study","Валидационное исследование","Validatsiya tadqiqoti")
k("researchKindCaseSeries","Research kind.","Case series","Серия случаев","Holatlar seriyasi")
k("tech_gcMsMs","Analytical technique name.","GC-MS/MS","ГХ-МС/МС","GC-MS/MS")
k("tech_lcMs","Analytical technique name.","LC-MS","ЖХ-МС","LC-MS")
k("tech_hrms","Analytical technique name.","HRMS (high-resolution mass spectrometry)","HRMS (масс-спектрометрия высокого разрешения)","HRMS (yuqori aniqlikdagi mass-spektrometriya)")
k("tech_spectrophotometry","Analytical technique name.","Spectrophotometry","Спектрофотометрия","Spektrofotometriya")
k("emergingCatBiomarkers","Emerging category.","New biomarkers","Новые биомаркеры","Yangi biomarkerlar")
k("emergingCatMethods","Emerging category.","Emerging analytical methods","Новые аналитические методы","Yangi analitik metodlar")
k("emergingCatLegal","Emerging category.","Legal / regulatory updates","Правовые и регуляторные изменения","Huquqiy / normativ yangilanishlar")

# --- Ogohlantirish ierarxiyasi ----------------------------------------------
k("severityCritical","Banner level for screen readers.","Critical","Критично","Muhim ogohlantirish")
k("severityWarning","Banner level for screen readers.","Warning","Предупреждение","Ogohlantirish")
k("severityInfo","Banner level for screen readers.","Information","Информация","Ma’lumot")
k("severityReview","Banner level for screen readers.","Review status","Статус проверки","Tekshiruv holati")

# --- Home ---------------------------------------------------------------------
k("moduleStandardsLaws","Home module.","Law & jurisdictions","Право и юрисдикции","Huquq va yurisdiksiyalar")
k("homeRecentlyViewed","Quick access block.","Recently viewed","Недавно просмотренные","Yaqinda ko‘rilganlar")
k("homeQuickEmpty","Quick access empty state.","Recently viewed records, tools, favourites and searches will appear here. They are stored only on this device.","Здесь появятся недавно просмотренные записи, инструменты, избранное и поиски. Они хранятся только на этом устройстве.","Bu yerda yaqinda ko‘rilgan yozuvlar, vositalar, saralanganlar va qidiruvlar chiqadi. Ular faqat shu qurilmada saqlanadi.")
k("homeJurisdictionChip","Home jurisdiction context.","Jurisdiction: {name}","Юрисдикция: {name}","Yurisdiksiya: {name}",{"name":S})
k("homeChange","Action.","Change","Изменить","O‘zgartirish")
k("homeAllDisciplines","Home tile.","All forensic disciplines","Все судебные дисциплины","Barcha sud-ekspert fanlari")
k("homeAllDisciplinesBody","Home tile body.","20 disciplines — scope and currently available content","20 дисциплин — охват и доступный контент","20 ta fan — qamrov va mavjud kontent")

# --- Fanlar ---------------------------------------------------------------------
D6 = [("forensic_medicine","Forensic medicine","Судебная медицина","Sud tibbiyoti"),
 ("forensic_pathology","Forensic pathology","Судебная патология","Sud patologiyasi"),
 ("clinical_forensic_medicine","Clinical forensic medicine","Клиническая судебная медицина","Klinik sud tibbiyoti"),
 ("forensic_radiology","Forensic radiology & imaging","Судебная радиология и визуализация","Sud radiologiyasi va vizualizatsiya"),
 ("forensic_psychiatry","Forensic psychiatry & psychology","Судебная психиатрия и психология","Sud psixiatriyasi va psixologiyasi"),
 ("forensic_toxicology","Forensic toxicology","Судебная токсикология","Sud toksikologiyasi"),
 ("forensic_chemistry","Forensic chemistry","Судебная химия","Sud kimyosi"),
 ("forensic_biochemistry","Forensic biochemistry","Судебная биохимия","Sud biokimyosi"),
 ("analytical_science","Analytical science","Аналитическая наука","Analitik fan"),
 ("forensic_biology","Forensic biology","Судебная биология","Sud biologiyasi"),
 ("forensic_genetics","Forensic genetics / DNA","Судебная генетика / ДНК","Sud genetikasi / DNK"),
 ("forensic_histology","Forensic histology","Судебная гистология","Sud gistologiyasi"),
 ("forensic_anthropology","Forensic anthropology","Судебная антропология","Sud antropologiyasi"),
 ("forensic_odontology","Forensic odontology","Судебная одонтология","Sud odontologiyasi"),
 ("forensic_microbiology","Forensic microbiology","Судебная микробиология","Sud mikrobiologiyasi"),
 ("forensic_entomology","Forensic entomology","Судебная энтомология","Sud entomologiyasi"),
 ("human_identification","DVI / human identification","DVI / идентификация личности","DVI / shaxsni aniqlash"),
 ("laboratory_quality","Laboratory quality & validation","Качество и валидация в лаборатории","Laboratoriya sifati va validatsiya"),
 ("evidence_handling","Evidence handling & chain of custody","Обращение с доказательствами и цепочка хранения","Ashyoviy dalillar va saqlash zanjiri"),
 ("education_research","Education & research","Образование и исследования","Ta’lim va tadqiqot")]
for code,en,ru,uz in D6:
    key = "disc_" + "".join(w.capitalize() if i else w for i,w in enumerate(code.split("_")))
    k(key,"Forensic discipline name.",en,ru,uz)
k("discGroupMedicine","Discipline group.","Medicine & pathology","Медицина и патология","Tibbiyot va patologiya")
k("discGroupToxChem","Discipline group.","Toxicology & chemistry","Токсикология и химия","Toksikologiya va kimyo")
k("discGroupBioId","Discipline group.","Biology & identification","Биология и идентификация","Biologiya va identifikatsiya")
k("discGroupLab","Discipline group.","Laboratory & quality","Лаборатория и качество","Laboratoriya va sifat")
k("discGroupEdu","Discipline group.","Education & research","Образование и исследования","Ta’lim va tadqiqot")
k("disciplinesTitle","Screen title.","Forensic disciplines","Судебные дисциплины","Sud-ekspert fanlari")
k("disciplinesIntro","Screen intro.","The platform architecture covers these disciplines. Content is added gradually and only with sources and expert review — an empty discipline means “not yet sourced”, not “no knowledge exists”.","Архитектура платформы охватывает эти дисциплины. Контент добавляется постепенно и только с источниками и экспертной проверкой — пустая дисциплина означает «ещё нет источников», а не «знаний нет».","Platforma arxitekturasi shu fanlarni qamraydi. Kontent bosqichma-bosqich va faqat manba hamda ekspert tekshiruvi bilan qo‘shiladi — bo‘sh fan «hali manba yo‘q» degani, «bilim yo‘q» degani emas.")
k("disciplineRecords","Discipline record count.","{count, plural, =0{No sourced records yet} one{1 sourced record} other{{count} sourced records}}","{count, plural, =0{Пока нет записей с источниками} one{1 запись с источником} few{{count} записи с источниками} many{{count} записей с источниками} other{{count} записи с источниками}}","{count, plural, =0{Hali manbali yozuv yo‘q} other{{count} ta manbali yozuv}}",{"count":I})
k("disciplineReferenceOnly","Badge.","Professional reference scope only","Только профессиональный справочный охват","Faqat professional ma’lumotnoma qamrovi")
k("disciplineModules","Section header.","Modules","Модули","Modullar")
k("disciplineTopics","Section header.","Planned topic structure","Планируемая структура тем","Rejalashtirilgan mavzular tuzilmasi")
k("disciplineEmpty","Empty state.","No sourced content in this discipline yet. Records will be added only with verifiable sources and expert review.","В этой дисциплине пока нет контента с источниками. Записи будут добавляться только с проверяемыми источниками и экспертной проверкой.","Bu fanda hali manbali kontent yo‘q. Yozuvlar faqat tekshiriladigan manba va ekspert tekshiruvi bilan qo‘shiladi.")

# --- Yurisdiksiyalar ------------------------------------------------------------
k("jurisdictionsTitle","Screen title.","Law & jurisdictions","Право и юрисдикции","Huquq va yurisdiksiyalar")
k("jurisdictionCurrent","Section header.","Current jurisdiction","Текущая юрисдикция","Joriy yurisdiksiya")
k("jurisdictionLayersTitle","Section header.","Three separate layers","Три отдельных слоя","Uchta alohida qatlam")
k("layerGlobalCore","Layer name.","Global scientific core — the same in every country","Глобальное научное ядро — одинаково во всех странах","Global ilmiy yadro — barcha davlatlarda bir xil")
k("layerIntlStandards","Layer name.","International standards & methods — not law unless adopted","Международные стандарты и методы — не закон, если не приняты","Xalqaro standartlar va metodlar — qabul qilinmaguncha qonun emas")
k("layerCountryLaw","Layer name.","Country / jurisdiction law & procedures — only for the selected jurisdiction","Право и процедуры страны / юрисдикции — только для выбранной юрисдикции","Davlat / yurisdiksiya qonuni va protseduralari — faqat tanlangan yurisdiksiya uchun")
k("jurisdictionViewDetails","Action.","Legal & procedural layer","Правовой и процессуальный слой","Huquqiy va protsessual qatlam")
k("jurisdictionWithContent","Section header.","Jurisdictions with pilot content","Юрисдикции с пилотным контентом","Pilot kontenti bor yurisdiksiyalar")
k("jurisdictionSearchHint","Search hint.","Search country or ISO code","Поиск страны или кода ISO","Davlat yoki ISO kodini qidirish")
k("jurisdictionNotVerified","Empty state.","Content not yet verified for this jurisdiction. Laws of other countries are never shown as a substitute.","Контент для этой юрисдикции ещё не проверен. Законы других стран никогда не показываются вместо него.","Bu yurisdiksiya uchun kontent hali tekshirilmagan. Boshqa davlat qonunlari hech qachon uning o‘rniga ko‘rsatilmaydi.")
k("jurisdictionPilotContent","Coverage label.","Pilot content — needs review","Пилотный контент — требует проверки","Pilot kontent — tekshiruv kerak")
k("jurisdictionNoContentShort","Coverage label.","Content not yet verified","Контент ещё не проверен","Kontent hali tekshirilmagan")
k("jurisdictionChain","Detail line.","Applies via: {chain}","Применяется через: {chain}","Qo‘llanish zanjiri: {chain}",{"chain":S})
k("jurisdictionGlobalWorks","Info banner.","Global scientific content works without selecting a jurisdiction. A jurisdiction is needed only for laws, controlled-substance schedules and national procedures.","Глобальный научный контент работает без выбора юрисдикции. Юрисдикция нужна только для законов, списков контролируемых веществ и национальных процедур.","Global ilmiy kontent yurisdiksiya tanlamasdan ishlaydi. Yurisdiksiya faqat qonunlar, nazoratdagi moddalar ro‘yxatlari va milliy protseduralar uchun kerak.")
k("jurisdictionInstruments","Section header.","Official documents","Официальные документы","Rasmiy hujjatlar")
k("jurisdictionIntlLayer","Section header.","International layer (applies to all)","Международный слой (для всех)","Xalqaro qatlam (hamma uchun)")
k("jurisdictionOwnLayer","Section header.","Jurisdiction-specific layer","Слой конкретной юрисдикции","Aniq yurisdiksiya qatlami")
k("jurisdictionCountryNames","Footnote.","Country names: Unicode CLDR. The list only enables selection — it does not mean legal content exists.","Названия стран: Unicode CLDR. Список только позволяет выбор — это не значит, что есть правовой контент.","Davlat nomlari: Unicode CLDR. Ro‘yxat faqat tanlash imkonini beradi — huquqiy kontent bor degani emas.")
k("docKindLaw","Document kind label.","LAW","ЗАКОН","QONUN")
k("docKindRegulation","Document kind label.","REGULATION","НОРМАТИВНЫЙ АКТ","NORMATIV HUJJAT")
k("docKindStandard","Document kind label.","STANDARD","СТАНДАРТ","STANDART")
k("docKindGuideline","Document kind label.","GUIDELINE","РУКОВОДСТВО","QO‘LLANMA")
k("docKindMethod","Document kind label.","METHOD","МЕТОДИКА","METOD")
k("docKindSop","Document kind label.","SOP","СОП","SOP")
k("docKindArticle","Document kind label.","SCIENTIFIC ARTICLE","НАУЧНАЯ СТАТЬЯ","ILMIY MAQOLA")
k("docKindOfficial","Document kind label.","OFFICIAL DOCUMENT","ОФИЦИАЛЬНЫЙ ДОКУМЕНТ","RASMIY HUJJAT")
k("bindingLegal","Binding nature.","Legally binding in its jurisdiction while in force","Юридически обязателен в своей юрисдикции, пока действует","Kuchda bo‘lsa, o‘z yurisdiksiyasida qonuniy majburiy")
k("bindingVoluntary","Binding nature.","Voluntary unless adopted by law or accreditation","Добровольный, если не принят законом или аккредитацией","Qonun yoki akkreditatsiya qabul qilmaguncha ixtiyoriy")
k("bindingAdvisory","Binding nature.","Advisory — not legally binding","Рекомендательный — не обязателен юридически","Tavsiyaviy — qonuniy majburiy emas")
k("bindingInstitutional","Binding nature.","Applies only within the issuing institution","Действует только в выпустившем учреждении","Faqat chiqargan muassasa ichida amal qiladi")
k("bindingScientific","Binding nature.","Scientific evidence — not a normative document","Научное доказательство — не нормативный документ","Ilmiy dalil — normativ hujjat emas")
k("instrNumber","Field.","Official number","Официальный номер","Rasmiy raqam")
k("instrPublished","Field.","Published","Опубликован","E’lon qilingan")
k("instrEffectiveFrom","Field.","In force from","Действует с","Kuchga kirgan")
k("instrEffectiveTo","Field.","In force until","Действует до","Amal qilish muddati")
k("instrAmended","Field.","Last amended","Последнее изменение","Oxirgi o‘zgartirish")
k("instrVersion","Field.","Version / edition","Версия / редакция","Versiya / tahrir")
k("instrLegalStatus","Field.","Legal status","Правовой статус","Huquqiy holat")
k("instrLanguage","Field.","Official language","Официальный язык","Rasmiy til")
k("instrTranslation","Field.","Translation","Перевод","Tarjima")
k("instrLastVerified","Field.","Last verified","Последняя проверка","Oxirgi tekshiruv")
k("instrReview","Field.","Review status","Статус проверки","Tekshiruv holati")
k("instrSource","Field.","Official source","Официальный источник","Rasmiy manba")
k("instrAuthority","Field.","Authority","Орган","Vakolatli organ")
k("translationNone","Translation status.","Original language only","Только язык оригинала","Faqat asl tilda")

# --- Library hub ----------------------------------------------------------------
k("moduleScreening","Home module.","Rapid & screening tests","Экспресс- и скрининговые тесты","Ekspress va skrining testlari")
k("libraryHubIntro","Library hub intro.","One umbrella for scientific records. Every record shows its source and review status.","Единый раздел научных записей. У каждой записи указаны источник и статус проверки.","Ilmiy yozuvlar uchun yagona markaz. Har bir yozuvda manba va tekshiruv holati ko‘rsatiladi.")
k("libraryStandards","Library section.","Standards & official documents","Стандарты и официальные документы","Standartlar va rasmiy hujjatlar")
k("libraryCount","Record count.","{count, plural, =0{No records yet} one{1 record} other{{count} records}}","{count, plural, =0{Записей пока нет} one{1 запись} few{{count} записи} many{{count} записей} other{{count} записи}}","{count, plural, =0{Hali yozuv yo‘q} other{{count} ta yozuv}}",{"count":I})
k("libraryGroupScience","Library group.","Scientific records","Научные записи","Ilmiy yozuvlar")
k("libraryGroupDocs","Library group.","Documents & evidence","Документы и доказательства","Hujjatlar va dalillar")
k("standardsIntro","Standards screen intro.","Standards, guidelines and methods are labelled by type. Only laws and regulations are legally binding — and only in their own jurisdiction.","Стандарты, руководства и методики помечены по типу. Юридически обязательны только законы и нормативные акты — и только в своей юрисдикции.","Standart, qo‘llanma va metodlar turi bilan belgilangan. Faqat qonun va normativ hujjatlar qonuniy majburiy — va faqat o‘z yurisdiksiyasida.")

# --- Research filtrlari -----------------------------------------------------------
k("researchFilterPeer","Filter chip.","Peer-reviewed only","Только рецензируемые","Faqat taqrizdan o‘tgan")
k("researchFilterOpen","Filter chip.","Open access","Открытый доступ","Ochiq kirish")
k("researchPeriodAll","Filter option.","Any year","Любой год","Istalgan yil")
k("researchPeriodRecent","Filter option.","2020 or later","2020 и позже","2020 va keyin")
k("researchPeriod2010","Filter option.","2010–2019","2010–2019","2010–2019")
k("researchPeriodOlder","Filter option.","Before 2010","До 2010","2010 gacha")
k("researchDisciplineAll","Filter option.","All disciplines","Все дисциплины","Barcha fanlar")
k("researchDiscipline","Filter label.","Discipline","Дисциплина","Fan")
k("researchPeriod","Filter label.","Period","Период","Davr")
k("researchClear","Action.","Clear filters","Сбросить фильтры","Filtrlarni tozalash")
k("researchRelevance","Field.","Forensic relevance","Судебно-экспертная значимость","Sud-ekspert dolzarbligi")
k("relevanceUnassessed","Relevance.","Not yet assessed by a reviewer (separate from evidence level)","Ещё не оценена рецензентом (отдельно от уровня доказательности)","Reviewer hali baholamagan (dalil darajasidan alohida)")
k("relevanceDirect","Relevance.","Direct","Прямая","Bevosita")
k("relevanceSupporting","Relevance.","Supporting","Вспомогательная","Yordamchi")
k("relevanceBackground","Relevance.","Background","Фоновая","Fon ma’lumoti")
k("researchOpenAccess","Field.","Open access","Открытый доступ","Ochiq kirish")
k("researchOpenPmc","Open access value.","Yes — PubMed Central","Да — PubMed Central","Ha — PubMed Central")
k("researchOpenLink","Open access value.","Yes — free full-text link","Да — бесплатная ссылка на полный текст","Ha — to‘liq matnga bepul havola")
k("researchOpenUnknown","Open access value.","Not determined","Не определено","Aniqlanmagan")
k("researchDocKind","Field.","Document type","Тип документа","Hujjat turi")

# --- Modda sahifasi ---------------------------------------------------------------
k("detailOnThisPage","Section index header.","On this page","На этой странице","Shu sahifada")
k("detailNotYetSourced","Section header.","Not yet sourced","Пока без источников","Hali manbasiz")
k("detailJurisdictionShort","Index chip.","Jurisdiction","Юрисдикция","Yurisdiksiya")

k("searchMetaboliteOf","Search result meta.","Metabolite of {name}","Метаболит: {name}","Metabolit: {name}",{"name":S})

# --- AI ---------------------------------------------------------------------------
k("aiBlockedOfficial","AI safety block.","Forensic AI does not write official expert opinions, death certificates or definitive intoxication conclusions. It can help you find and compare sources.","Forensic AI не составляет официальные экспертные заключения, свидетельства о смерти и окончательные выводы об интоксикации. Он может помочь найти и сравнить источники.","Forensic AI rasmiy ekspert xulosasi, o‘lim guvohnomasi yoki zaharlanish bo‘yicha qat’iy xulosa yozmaydi. U manbalarni topish va solishtirishda yordam beradi.")
k("aiJurisdictionRequired","AI notice.","This is a legal or procedural question. Select a jurisdiction first — Forensic AI never assumes one.","Это правовой или процессуальный вопрос. Сначала выберите юрисдикцию — Forensic AI никогда не предполагает её сам.","Bu huquqiy yoki protsessual savol. Avval yurisdiksiyani tanlang — Forensic AI uni hech qachon o‘zi taxmin qilmaydi.")
k("aiSelectJurisdiction","Action.","Select jurisdiction","Выбрать юрисдикцию","Yurisdiksiyani tanlash")

k("aiSectionEvidenceStatus","AI answer section.","Evidence status","Статус доказательств","Dalil holati")
k("aiSampleEvidenceStatus","Placeholder.","Each statement shows the review status and evidence level of the record it comes from.","У каждого утверждения указаны статус проверки и уровень доказательности исходной записи.","Har bir fikr uchun u olingan yozuvning tekshiruv holati va dalil darajasi ko‘rsatiladi.")
k("aiSectionJurisdiction","AI answer section.","Jurisdiction","Юрисдикция","Yurisdiksiya")
k("aiSampleJurisdiction","Placeholder.","Legal statements apply only to the selected jurisdiction; scientific statements are global.","Правовые утверждения относятся только к выбранной юрисдикции; научные — глобальны.","Huquqiy fikrlar faqat tanlangan yurisdiksiyaga tegishli; ilmiy fikrlar global.")
k("aiSectionRelated","AI answer section.","Related records","Связанные записи","Bog‘liq yozuvlar")
k("aiSampleRelated","Placeholder.","Links to the substance, method and research records used in the answer.","Ссылки на записи о веществах, методах и исследованиях, использованные в ответе.","Javobda ishlatilgan modda, metod va tadqiqot yozuvlariga havolalar.")

# --- Kontent shabloni bo‘limlari ---------------------------------------------
k("tpl_overview","Content template section.","Overview","Обзор","Umumiy ma’lumot")
k("tpl_names","Content template section.","Names & synonyms","Названия и синонимы","Nomlar va sinonimlar")
k("tpl_classification","Content template section.","Classification","Классификация","Tasnif")
k("tpl_metabolism","Content template section.","Metabolism","Метаболизм","Metabolizm")
k("tpl_metabolites","Content template section.","Metabolites","Метаболиты","Metabolitlar")
k("tpl_specimens","Content template section.","Specimens","Образцы","Namunalar")
k("tpl_screening","Content template section.","Screening","Скрининг","Skrining")
k("tpl_confirmation","Content template section.","Confirmatory analysis","Подтверждающий анализ","Tasdiqlovchi tahlil")
k("tpl_analyticalMethods","Content template section.","Analytical methods","Аналитические методы","Analitik metodlar")
k("tpl_reportedConcentrations","Content template section.","Reported concentrations","Сообщённые концентрации","Xabar qilingan konsentratsiyalar")
k("tpl_interpretation","Content template section.","Interpretation","Интерпретация","Talqin")
k("tpl_postmortem","Content template section.","Postmortem considerations","Посмертные аспекты","O‘limdan keyingi jihatlar")
k("tpl_stability","Content template section.","Stability","Стабильность","Barqarorlik")
k("tpl_interferences","Content template section.","Interferences","Интерференции","Interferensiyalar")
k("tpl_jurisdiction","Content template section.","Jurisdiction-specific law & methods","Право и методики юрисдикции","Yurisdiksiya qonuni va metodlari")
k("tpl_research","Content template section.","Research & evidence","Исследования и доказательства","Tadqiqotlar va dalillar")
k("tpl_sources","Content template section.","Sources","Источники","Manbalar")
k("tpl_principle","Content template section.","Principle","Принцип","Prinsip")
k("tpl_forensicUse","Content template section.","Forensic use","Судебно-экспертное применение","Sud-ekspert qo‘llanishi")
k("tpl_samplePreparation","Content template section.","Sample preparation","Пробоподготовка","Namuna tayyorlash")
k("tpl_instrumentation","Content template section.","Instrumentation","Приборное оснащение","Asbob-uskunalar")
k("tpl_qualitativeQuantitative","Content template section.","Qualitative / quantitative use","Качественное / количественное применение","Sifat / miqdoriy qo‘llanish")
k("tpl_validation","Content template section.","Validation requirements","Требования к валидации","Validatsiya talablari")
k("tpl_interference","Content template section.","Interference","Интерференция","Interferensiya")
k("tpl_limitations","Content template section.","Limitations","Ограничения","Cheklovlar")
k("tpl_qc","Content template section.","Quality control","Контроль качества","Sifat nazorati")
k("tpl_relatedSubstances","Content template section.","Related substances","Связанные вещества","Bog‘liq moddalar")
k("tpl_relatedReagents","Content template section.","Related reagents","Связанные реагенты","Bog‘liq reagentlar")
k("tpl_purpose","Content template section.","Purpose","Назначение","Maqsad")
k("tpl_composition","Content template section.","Composition","Состав","Tarkib")
k("tpl_preparation","Content template section.","Preparation","Приготовление","Tayyorlash")
k("tpl_storageStability","Content template section.","Storage & stability","Хранение и стабильность","Saqlash va barqarorlik")
k("tpl_safety","Content template section.","Safety","Безопасность","Xavfsizlik")
k("tpl_disposal","Content template section.","Disposal","Утилизация","Utilizatsiya")
k("tpl_linkedMethods","Content template section.","Linked methods & tests","Связанные методы и тесты","Bog‘liq metod va testlar")
k("tpl_technology","Content template section.","Technology","Технология","Texnologiya")
k("tpl_targetSpecimen","Content template section.","Target & specimen","Мишень и образец","Nishon va namuna")
k("tpl_cutoff","Content template section.","Cutoff","Порог отсечения (cutoff)","Cutoff qiymati")
k("tpl_performance","Content template section.","Sensitivity & specificity","Чувствительность и специфичность","Sezgirlik va o‘ziga xoslik")
k("tpl_crossReactivity","Content template section.","Cross-reactivity","Перекрёстная реактивность","Kesishgan reaktivlik")
k("tpl_falseResults","Content template section.","False positives / negatives","Ложноположительные / ложноотрицательные","Soxta musbat / manfiy natijalar")
k("tpl_marker","Content template section.","Marker","Маркер","Marker")
k("tpl_specimen","Content template section.","Specimen","Образец","Namuna")
k("tpl_collectionContext","Content template section.","Collection context","Условия забора","Namuna olish sharoiti")
k("tpl_postmortemLimitations","Content template section.","Postmortem limitations","Посмертные ограничения","O‘limdan keyingi cheklovlar")
k("tpl_analyticalMethod","Content template section.","Analytical method","Аналитический метод","Analitik metod")
k("tpl_interpretationLimitations","Content template section.","Interpretation limitations","Ограничения интерпретации","Talqin cheklovlari")
k("tpl_definition","Content template section.","Definition","Определение","Ta’rif")
k("tpl_findings","Content template section.","Findings","Находки","Topilmalar")
k("tpl_methods","Content template section.","Methods","Методы","Metodlar")
k("templateCoverage","Template coverage.","Sections with sourced data: {filled} of {total}","Разделы с источниками: {filled} из {total}","Manbali bo‘limlar: {filled} / {total}",{"filled":I,"total":I})

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
