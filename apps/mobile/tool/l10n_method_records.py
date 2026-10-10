# Usul rejimi bo'limi (modda sahifasi): bo'lim sarlavhasi va claim maydonlari yorliqlari.
# Idempotent: qayta ishga tushirish xavfsiz.
# Ishga tushirish (CLAUDE.md tartibi: l10n_method_images.py dan keyin, l10n_ux_audit.py dan oldin):
#   cd apps/mobile && python3 tool/l10n_method_records.py && python3 tool/l10n_ux_audit.py && flutter gen-l10n
# O'zbekcha — adabiy lotin: o' g' (U+2018) va ' (U+2019).
import collections
import json

D = "lib/core/l10n/arb"
K = collections.OrderedDict()


def k(key, desc, en, ru, uz):
    K[key] = (desc, en, ru, uz)


k("detailMethodRecords",
  "Substance page: section heading for sourced method records (sample preparation, instrument set-up, quality control, interferences, validation, specimens, limitations).",
  "Method conditions and limits (sourced)",
  "Условия метода и ограничения (по источникам)",
  "Usul sharoitlari va cheklovlari (manbalardan)")
k("claimFieldSamplePreparation", "Label of a sourced method record: sample preparation.",
  "Sample preparation", "Подготовка пробы", "Namunani tayyorlash")
k("claimFieldInstrumentation", "Label of a sourced method record: instrument set-up (columns, detector, gases, temperatures).",
  "Instrument set-up", "Настройка прибора", "Asbob sozlamasi")
k("claimFieldQc", "Label of a sourced method record: calibration and quality control.",
  "Calibration and quality control", "Калибровка и контроль качества", "Kalibrlash va sifat nazorati")
k("claimFieldInterference", "Label of a sourced method record: identification and interfering substances.",
  "Identification and interference", "Идентификация и мешающие вещества", "Aynanlik va halaqit beruvchi moddalar")
k("claimFieldValidation", "Label of a sourced method record: method performance and validation figures.",
  "Method performance", "Характеристики метода", "Usul ko‘rsatkichlari")
k("claimFieldSpecimens", "Label of a sourced method record: other specimens analysed with the method.",
  "Other specimens", "Другие образцы", "Boshqa namunalar")
k("claimFieldLimitation", "Label of a sourced method record: limitation of the method or of the result.",
  "Limitation", "Ограничение", "Cheklov")

for idx, code in enumerate(["en", "ru", "uz"]):
    p = f"{D}/app_{code}.arb"
    data = json.load(open(p, encoding="utf-8"), object_pairs_hook=collections.OrderedDict)
    for key, (desc, en, ru, uz) in K.items():
        data[key] = (en, ru, uz)[idx]
        if code == "en":
            data["@" + key] = {"description": desc}
    json.dump(data, open(p, "w", encoding="utf-8"), ensure_ascii=False, indent=2)
    open(p, "a").write("\n")
print(len(K), "keys")
