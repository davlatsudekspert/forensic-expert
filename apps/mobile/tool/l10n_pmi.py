# PMI = Postmortem interval. Egasi tasdiqlagan yagona termin (2026-10-09):
# uz «O‘limdan keyin o‘tgan vaqt oralig‘i (PMI)», ru «Посмертный интервал (PMI)»,
# en «Postmortem interval (PMI)». «O‘lim vaqti» ishlatilmaydi.
import json, collections
D = "lib/core/l10n/arb"
K = collections.OrderedDict()
def k(key, en, ru, uz):
    K[key] = (en, ru, uz)
k("toolPmiName", "Postmortem interval (PMI) — Henssge", "Посмертный интервал (PMI) — Хенссге", "O‘limdan keyin o‘tgan vaqt oralig‘i (PMI) — Henssge")
k("calcHenssgeTime", "Estimated postmortem interval (PMI)", "Расчётный посмертный интервал (PMI)", "Taxminiy o‘limdan keyin o‘tgan vaqt oralig‘i (PMI)")
k("fmTopicPostmortemInterval", "Postmortem interval (PMI)", "Посмертный интервал (PMI)", "O‘limdan keyin o‘tgan vaqt oralig‘i (PMI)")
for idx, code in enumerate(["en", "ru", "uz"]):
    p = f"{D}/app_{code}.arb"
    data = json.load(open(p, encoding="utf-8"), object_pairs_hook=collections.OrderedDict)
    for key, vals in K.items():
        assert key in data, key
        data[key] = vals[idx]
    json.dump(data, open(p, "w", encoding="utf-8"), ensure_ascii=False, indent=2)
    open(p, "a").write("\n")
print(len(K), "keys")
