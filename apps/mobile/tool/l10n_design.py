# «Scientific Luxury» dizayn tizimi — Home ierarxiyasi va umumiy holatlar.
import json, collections
D = "lib/core/l10n/arb"
K = collections.OrderedDict()
def k(key, desc, en, ru, uz, ph=None):
    K[key] = (desc, en, ru, uz, ph)
S = {"type": "String"}
k("homeGreeting","Home header greeting above the role chip.","Welcome","Добро пожаловать","Xush kelibsiz")
k("homeRoleChip","Home header: current usage mode (Professional / Student). Opens mode settings.","Mode: {mode}","Режим: {mode}","Rejim: {mode}",{"mode":S})
k("homeAiEntryBody","Home: subtitle of the AI entry card.","Ask a scientific question. Answers cite their sources.","Задайте научный вопрос. Ответы ссылаются на источники.","Ilmiy savol bering. Javoblar manbalarga iqtibos keltiradi.")
k("homeResourcesHeading","Home section: scientific library and professional tools.","Library & tools","Библиотека и инструменты","Kutubxona va vositalar")
k("homeLibraryBody","Home: subtitle of the scientific library entry.","Substances, methods, standards and references","Вещества, методы, стандарты и источники","Moddalar, usullar, standartlar va manbalar")
k("homeContinueSaved","Home section: recently viewed, recent tools, favourites, recent searches.","Continue & saved","Продолжить и сохранённое","Davom ettirish va saqlanganlar")
k("loadingContent","Screen reader label for a loading skeleton.","Loading…","Загрузка…","Yuklanmoqda…")
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
