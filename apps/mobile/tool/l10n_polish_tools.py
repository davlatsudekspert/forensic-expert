# Professional vositalar (kalkulyatorlar) — 2026-10-09 «polish tools» matnlari.
# Idempotent: kalit bo‘lsa — qiymati yangilanadi, bo‘lmasa — qo‘shiladi.
# Ishga tushirish:
#   cd apps/mobile && python3 tool/l10n_polish_tools.py && flutter gen-l10n
# O‘zbekcha — adabiy lotin: o‘ g‘ (U+2018) va ’ (U+2019).
import json, collections
D = "lib/core/l10n/arb"
K = collections.OrderedDict()
def k(key, desc, en, ru, uz, ph=None):
    K[key] = (desc, en, ru, uz, ph)
S = {"type": "String"}

# ------------------------------------------------------------- umumiy
k("calcCopyResult", "Button: copy the calculation result as text.",
  "Copy result", "Скопировать результат", "Natijani nusxalash")
k("calcCopied", "Snackbar after copying a result.",
  "Result copied with inputs, formula and method version.",
  "Результат скопирован вместе с исходными данными, формулой и версией метода.",
  "Natija kiritilgan qiymatlar, formula va usul versiyasi bilan nusxalandi.")
k("calcCopyInputs", "Heading inside the copied text.", "Inputs", "Исходные данные", "Kiritilgan qiymatlar")
k("calcErrorRequired", "Validation: a required field is empty.",
  "Fill in all required fields.", "Заполните все обязательные поля.",
  "Barcha majburiy maydonlarni to‘ldiring.")
k("calcEstimatedRange", "Headline row: estimated min–max range.",
  "Estimated range", "Оценочный диапазон", "Baholangan oraliq")
k("calcLockedTitle", "Locked calculator card title.",
  "Included in Expert Pro", "Входит в Эксперт Pro", "Mutaxassis Pro tarkibida")
k("calcLockedBody", "Locked calculator card body.",
  "This calculator opens with the Expert Pro plan. Dilution and the concentration unit converter are free.",
  "Этот калькулятор доступен в тарифе Эксперт Pro. Разведение и конвертер единиц концентрации — бесплатны.",
  "Bu kalkulyator Mutaxassis Pro tarifida ochiladi. Suyultirish va konsentratsiya birliklari konvertori — bepul.")

# --------------------------------------------------------- statistika
k("calcStatsValues", "Field label: list of values.",
  "Values (separate with spaces, “;” or new lines; decimal 0.5 or 0,5)",
  "Значения (через пробел, «;» или с новой строки; десятичные 0,5 или 0.5)",
  "Qiymatlar (bo‘shliq, «;» yoki yangi qator bilan; o‘nlik 0,5 yoki 0.5)")
k("calcRegPoints", "Field label: calibration points.",
  "Calibration points: one “x y” or “x; y” pair per line",
  "Точки калибровки: по одной паре «x y» или «x; y» в строке",
  "Kalibrlash nuqtalari: har qatorda bitta «x y» yoki «x; y» juftligi")
k("calcLodUnitNote", "Note under LOD/LOQ result.",
  "DL and QL are in the concentration units of the calibration x axis.",
  "DL и QL — в единицах концентрации оси x калибровки.",
  "DL va QL kalibrlash x o‘qidagi konsentratsiya birligida.")

# ------------------------------------------------------- teskari hisob
k("calcBacMeasured", "Field label: measured blood alcohol.",
  "Measured blood alcohol", "Измеренная концентрация в крови",
  "O‘lchangan qondagi alkogol")
k("calcBackAssumptionBeta", "Assumption bullet.",
  "β = 0.10–0.25 g/L/h (10–25 mg/100 mL/h) covers most people (Jones 2010). For ‰ (g/kg) β is converted with blood density 1.055 g/mL.",
  "β = 0,10–0,25 г/л/ч (10–25 мг/100 мл/ч) охватывает большинство людей (Jones 2010). Для ‰ (г/кг) β пересчитывается через плотность крови 1,055 г/мл.",
  "β = 0,10–0,25 g/L/soat (10–25 mg/100 mL/soat) ko‘pchilik odamlarni qamraydi (Jones 2010). ‰ (g/kg) uchun β qon zichligi 1,055 g/mL bilan qayta hisoblanadi.")

# -------------------------------------------------------------- Henssge
k("calcHenssgeFormulaLow", "Caption: which Henssge equation is applied.",
  "Applied: ambient ≤ 23 °C", "Применена: среда ≤ 23 °C", "Qo‘llangan: muhit ≤ 23 °C")
k("calcHenssgeFormulaHigh", "Caption: which Henssge equation is applied.",
  "Applied: ambient > 23 °C", "Применена: среда > 23 °C", "Qo‘llangan: muhit > 23 °C")


def main():
    for lang, idx in (("en", 1), ("ru", 2), ("uz", 3)):
        p = f"{D}/app_{lang}.arb"
        data = json.load(open(p, encoding="utf-8"), object_pairs_hook=collections.OrderedDict)
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
    print(f"l10n_polish_tools: {len(K)} keys")


if __name__ == "__main__":
    main()
