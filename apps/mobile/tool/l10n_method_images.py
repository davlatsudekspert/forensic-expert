# Usul sahifasidagi real-ma'lumot rasmlari: «boshqa modda misoli» yorlig'i va izohi.
# Idempotent: qayta ishga tushirish xavfsiz.
# Ishga tushirish (CLAUDE.md tartibi: l10n_legal_url.py dan keyin, l10n_ux_audit.py dan oldin):
#   cd apps/mobile && python3 tool/l10n_method_images.py && python3 tool/l10n_ux_audit.py && flutter gen-l10n
# O'zbekcha — adabiy lotin: o' g' (U+2018) va ' (U+2019).
import collections
import json

D = "lib/core/l10n/arb"
K = collections.OrderedDict()


def k(key, desc, en, ru, uz):
    K[key] = (desc, en, ru, uz)


k("imageOtherSubstanceChip",
  "Chip on a method-page figure that shows a real measurement of a specific substance: it is an example for another substance.",
  "Example: another substance", "Пример: другое вещество", "Misol: boshqa modda")
k("imageOtherSubstanceNote",
  "Short note under a method-page figure of a specific substance: it does not belong to the substance the reader came from.",
  "This figure is from another substance's example; it shows how the method works and does not belong to the substance you came from. The title names the substance shown.",
  "Этот рисунок взят из примера по другому веществу; он показывает принцип метода и не относится к веществу, с которого вы пришли. Название рисунка указывает показанное вещество.",
  "Bu rasm boshqa modda misolida; usul tamoyilini ko‘rsatadi va siz kelgan moddaga tegishli emas. Qaysi modda ko‘rsatilgani sarlavhada yozilgan.")

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
