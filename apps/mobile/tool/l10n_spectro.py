# Spektrofotometriya (2026-10-09): Buger–Lambert–Ber kalkulyatori matnlari.
# Idempotent: kalit bo‘lsa — qiymati yangilanadi, bo‘lmasa — qo‘shiladi.
# Tartib (CLAUDE.md): … l10n_polish_reading.py → l10n_spectro.py → l10n_ux_audit.py
# Ishga tushirish:
#   cd apps/mobile && python3 tool/l10n_spectro.py && python3 tool/l10n_ux_audit.py && flutter gen-l10n
# O‘zbekcha — adabiy lotin: o‘ g‘ (U+2018) va ’ (U+2019).
import collections
import json

D = "lib/core/l10n/arb"
K = collections.OrderedDict()


def k(key, desc, en, ru, uz, ph=None):
    K[key] = (desc, en, ru, uz, ph)


k("toolBeerLambertName", "Tool name: Beer–Lambert calculator.",
  "Beer–Lambert law (A = ε·l·c)",
  "Закон Бугера–Ламберта–Бера (A = ε·l·c)",
  "Buger–Lambert–Ber qonuni (A = ε·l·c)")
k("toolBeerLambertDesc", "Tool description: Beer–Lambert calculator.",
  "Find absorbance, concentration or absorptivity from A = ε·l·c, on a molar or mass basis, with units.",
  "Расчёт оптической плотности, концентрации или коэффициента поглощения по A = ε·l·c — на молярной или массовой основе, с единицами.",
  "A = ε·l·c bo‘yicha optik zichlik, konsentratsiya yoki yutilish koeffitsientini topish — molyar yoki massaviy asosda, birliklar bilan.")
k("calcBeerAbsorbance", "Field/result label: absorbance A.",
  "Absorbance", "Оптическая плотность", "Optik zichlik")
k("calcBeerAbsorptivityMolar", "Field/result label: molar absorptivity ε.",
  "Molar absorptivity", "Молярный коэффициент поглощения", "Molyar yutilish koeffitsienti")
k("calcBeerAbsorptivityMass", "Field/result label: specific (mass) absorptivity a.",
  "Specific (mass) absorptivity", "Удельный (массовый) коэффициент поглощения",
  "Solishtirma (massaviy) yutilish koeffitsienti")
k("calcBeerConcentration", "Field/result label: concentration c.",
  "Concentration", "Концентрация", "Konsentratsiya")
k("calcBeerPath", "Field label: optical path length l.",
  "Path length (l)", "Толщина слоя (l)", "Kyuveta qalinligi (l)")
k("calcBeerResultUnit", "Dropdown label: unit of the calculated concentration.",
  "Result unit (c)", "Единица результата (c)", "Natija birligi (c)")
k("calcBeerBasis", "Label above the basis choice (molar or mass).",
  "Absorptivity basis", "Основа коэффициента поглощения", "Yutilish koeffitsienti asosi")
k("calcBeerBasisMolar", "Choice: molar basis.",
  "Molar (ε, mol/L)", "Молярный (ε, моль/л)", "Molyar (ε, mol/L)")
k("calcBeerBasisMass", "Choice: mass basis.",
  "Mass (a, g/L)", "Массовый (a, г/л)", "Massaviy (a, g/L)")
k("calcBeerFormulaNote", "Note under the formula: symbols and units.",
  "A — absorbance (dimensionless); ε — molar absorptivity, L·mol⁻¹·cm⁻¹ (or a — mass absorptivity, L·g⁻¹·cm⁻¹); l — path length, cm; c — concentration, mol/L (or g/L).",
  "A — оптическая плотность (безразмерная); ε — молярный коэффициент поглощения, л·моль⁻¹·см⁻¹ (или a — массовый, л·г⁻¹·см⁻¹); l — толщина слоя, см; c — концентрация, моль/л (или г/л).",
  "A — optik zichlik (o‘lchamsiz); ε — molyar yutilish koeffitsienti, L·mol⁻¹·cm⁻¹ (yoki a — massaviy, L·g⁻¹·cm⁻¹); l — kyuveta qalinligi, cm; c — konsentratsiya, mol/L (yoki g/L).")
k("calcBeerErrorBasis", "Validation: concentration unit does not match the basis.",
  "The concentration unit does not match the absorptivity basis: use mol/L units with molar ε and g/L-type units with mass a.",
  "Единица концентрации не соответствует основе коэффициента: с молярным ε — моль/л, с массовым a — единицы типа г/л.",
  "Konsentratsiya birligi koeffitsient asosiga mos emas: molyar ε bilan — mol/L, massaviy a bilan — g/L turidagi birliklar.")
k("calcBeerAssumptionDefinition", "Assumption bullet.",
  "Definitional relationship: absorbance is proportional to path length and concentration. No absorptivity values are built in — enter a value from your own calibration or a verified source for the same wavelength, solvent and pH.",
  "Определительное соотношение: оптическая плотность пропорциональна толщине слоя и концентрации. Значения коэффициентов в приложение не встроены — вводите значение из собственной калибровки или проверенного источника для той же длины волны, растворителя и pH.",
  "Ta’rifiy munosabat: optik zichlik kyuveta qalinligi va konsentratsiyaga proporsional. Ilovada koeffitsient qiymatlari yo‘q — qiymatni o‘z kalibrlashingizdan yoki tekshirilgan manbadan, xuddi shu to‘lqin uzunligi, erituvchi va pH uchun kiriting.")
k("calcBeerAssumptionBlank", "Assumption bullet.",
  "A is the sample absorbance corrected for the blank (reagent or matrix blank) at the chosen wavelength.",
  "A — оптическая плотность образца за вычетом холостой пробы (реагентной или матричной) при выбранной длине волны.",
  "A — tanlangan to‘lqin uzunligida bo‘sh (reagent yoki matritsa) namunaga nisbatan tuzatilgan namuna optik zichligi.")
k("calcBeerLimitationLinear", "Limitation bullet.",
  "Valid only within the working range where linearity has been shown by calibration; ICH Q2(R2) §3.2.2.1 recommends at least five concentrations across the range. Outside it, dilute the sample or use the calibration curve.",
  "Действует только в рабочем диапазоне, где линейность подтверждена калибровкой; ICH Q2(R2) §3.2.2.1 рекомендует не менее пяти концентраций по диапазону. Вне его разбавьте образец или используйте калибровочный график.",
  "Faqat chiziqlilik kalibrlash bilan ko‘rsatilgan ishchi oraliqda amal qiladi; ICH Q2(R2) §3.2.2.1 oraliq bo‘ylab kamida beshta konsentratsiyani tavsiya qiladi. Undan tashqarida namunani suyultiring yoki kalibrlash grafigidan foydalaning.")
k("calcBeerLimitationIdentity", "Limitation bullet.",
  "Absorbance does not identify a substance. UV-Vis has low specificity; identity must be confirmed by another technique (for example, chromatography with mass spectrometry).",
  "Оптическая плотность не идентифицирует вещество. УФ-видимая спектрофотометрия малоспецифична; идентичность подтверждается другим методом (например, хроматографией с масс-спектрометрией).",
  "Optik zichlik moddani identifikatsiya qilmaydi. UB-ko‘rinadigan spektrofotometriyaning o‘ziga xosligi past; modda boshqa usul bilan (masalan, xromatografiya va mass-spektrometriya) tasdiqlanishi kerak.")
k("calcBeerReference", "Reference bullet for the Beer–Lambert calculator.",
  "IUPAC Gold Book: “Beer–Lambert law”, doi:10.1351/goldbook.B00626 · Swinehart DF. The Beer-Lambert law. J Chem Educ 1962;39(7):333, doi:10.1021/ed039p333 · Linearity: ICH Q2(R2) (2023), §3.2.2.1.",
  "IUPAC Gold Book: «Beer–Lambert law», doi:10.1351/goldbook.B00626 · Swinehart DF. The Beer-Lambert law. J Chem Educ 1962;39(7):333, doi:10.1021/ed039p333 · Линейность: ICH Q2(R2) (2023), §3.2.2.1.",
  "IUPAC Gold Book: «Beer–Lambert law», doi:10.1351/goldbook.B00626 · Swinehart DF. The Beer-Lambert law. J Chem Educ 1962;39(7):333, doi:10.1021/ed039p333 · Chiziqlilik: ICH Q2(R2) (2023), §3.2.2.1.")
k("calcBeerRelatedTools", "Section header: links to calibration and LOD/LOQ tools.",
  "Related tools: calibration and limits",
  "Связанные инструменты: калибровка и пределы",
  "Bog‘liq vositalar: kalibrlash va chegaralar")


def main():
    for lang, idx in (("en", 1), ("ru", 2), ("uz", 3)):
        p = f"{D}/app_{lang}.arb"
        with open(p, encoding="utf-8") as f:
            data = json.load(f, object_pairs_hook=collections.OrderedDict)
        for key, v in K.items():
            data[key] = v[idx]
            if lang == "en":
                meta = collections.OrderedDict(description=v[0])
                if v[4]:
                    meta["placeholders"] = v[4]
                data["@" + key] = meta
        with open(p, "w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
            f.write("\n")
    print(f"l10n_spectro: {len(K)} keys")


if __name__ == "__main__":
    main()
