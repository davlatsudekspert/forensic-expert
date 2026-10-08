# Sonlar matnga qattiq yozilmaydi: fanlar soni koddan keladi.
import json, collections
D = "lib/core/l10n/arb"
V = {
 "en": "{count} disciplines — scope and currently available content",
 "ru": "Дисциплин: {count} — охват и доступный контент",
 "uz": "{count} ta fan — qamrov va mavjud kontent",
}
for code, val in V.items():
    p = f"{D}/app_{code}.arb"
    d = json.load(open(p, encoding="utf-8"), object_pairs_hook=collections.OrderedDict)
    d["homeAllDisciplinesBody"] = val
    if code == "en":
        meta = d.get("@homeAllDisciplinesBody", {"description": "All disciplines tile."})
        meta["placeholders"] = {"count": {"type": "int"}}
        d["@homeAllDisciplinesBody"] = meta
    json.dump(d, open(p, "w", encoding="utf-8"), ensure_ascii=False, indent=2)
    open(p, "a").write("\n")
print("ok")
