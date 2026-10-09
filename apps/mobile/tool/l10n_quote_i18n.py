# Manbadan iqtibos ostidagi avtomatik tarjima va manba bo‘limlari nomlari.
# Ishga tushirish: apps/mobile ichida `python3 tool/l10n_quote_i18n.py`, so‘ng
# `flutter gen-l10n`.
import json, collections
D = "lib/core/l10n/arb"
K = collections.OrderedDict()
def k(key, desc, en, ru, uz, ph=None):
    K[key] = (desc, en, ru, uz, ph)
S = {"type": "String"}
k("quoteMachineTranslation","Label above an automatic translation shown under a verbatim source excerpt. Must say it is automatic and not verified.","Automatic translation · not verified","Автоматический перевод · не проверен","Avtomatik tarjima · tekshirilmagan")
k("quoteMachineTranslationSemantics","Screen-reader label for the automatic translation block.","Automatic translation of the source excerpt, not verified by an expert. The original text above is the citation.","Автоматический перевод цитаты из источника, не проверен экспертом. Цитатой является оригинальный текст выше.","Manbadan iqtibosning avtomatik tarjimasi, ekspert tomonidan tekshirilmagan. Iqtibos — yuqoridagi asl matn.")
k("quoteOriginalTitle","Secondary line under a translated research title.","Original title: {title}","Оригинальное название: {title}","Asl sarlavha: {title}",{"title":S})
k("sourceSectionRef","Locator of the quoted passage inside the source.","§ {section}","§ {section}","§ {section}",{"section":S})
k("sectionAbstract","Article section name.","Abstract","Аннотация","Annotatsiya")
k("sectionIntroduction","Article section name.","Introduction","Введение","Kirish")
k("sectionBackground","Article section name.","Background","Предпосылки","Asos")
k("sectionMethods","Article section name.","Methods","Методы","Usullar")
k("sectionResults","Article section name.","Results","Результаты","Natijalar")
k("sectionDiscussion","Article section name.","Discussion","Обсуждение","Muhokama")
k("sectionConclusion","Article section name.","Conclusions","Выводы","Xulosalar")
k("sectionCaseReport","Article section name.","Case report","Описание случая","Holat tavsifi")
k("sectionFigure","Article section name.","Figure","Рисунок","Rasm")
k("sectionTable","Article section name.","Table","Таблица","Jadval")
k("sectionSupplement","Article section name.","Supplementary material","Дополнительные материалы","Qo‘shimcha materiallar")
k("sectionTitle","Article section name.","Title","Заголовок","Sarlavha")
k("researchAuthorsEtAl","Short author list: first author followed by et al.","{author} et al.","{author} и др.","{author} va boshq.",{"author":S})
k("sectionComputedProperties","PubChem record section name.","Computed properties","Вычисленные свойства","Hisoblangan xossalar")
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
