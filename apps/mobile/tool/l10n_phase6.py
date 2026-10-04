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
