# Global Search: fan bo‘yicha filtr va bog‘langan (modda → metod) natija.
import json, collections
D = "lib/core/l10n/arb"
K = collections.OrderedDict()
def k(key, desc, en, ru, uz, ph=None):
    K[key] = (desc, en, ru, uz, ph)
S = {"type": "String"}
k("searchDisciplineFilter","Semantics label of the discipline filter chip row on the search screen.","Filter results by discipline","Фильтр результатов по дисциплине","Natijalarni fan bo‘yicha saralash")
k("searchDisciplineAll","Chip: no discipline filter.","All disciplines","Все дисциплины","Barcha fanlar")
k("searchLinkedVia","Result meta: a method shown because a matching substance is linked to it in the sources.","Linked to {name} (mentioned in source)","Связано с: {name} (упомянуто в источнике)","{name} bilan bog‘liq (manbada tilga olingan)",{"name":S})
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
