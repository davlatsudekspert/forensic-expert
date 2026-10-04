# PHASE 4 lokalizatsiya kalitlari (global bilim tizimi, premium UX).
# RU/UZ — review qilinmagan qoralama (RG-11).
import json, collections
D = "lib/core/l10n/arb"
K = collections.OrderedDict()
def k(key, desc, en, ru, uz, ph=None):
    K[key] = (desc, en, ru, uz, ph)
S = {"type": "String"}
I = {"type": "int"}

k("statusDraft","Scientific status: draft, not yet submitted for review.","Draft","Черновик","Qoralama")

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
