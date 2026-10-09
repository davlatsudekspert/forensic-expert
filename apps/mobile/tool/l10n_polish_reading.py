# O‘qish tajribasi (kutubxona, modda sahifasi, yo‘riqnomalar, manbalar,
# qidiruv) — sayqal matnlari. Idempotent: qayta ishga tushirish xavfsiz.
# Ishga tushirish:
#   cd apps/mobile && python3 tool/l10n_polish_reading.py && flutter gen-l10n
# O‘zbekcha — adabiy lotin: o‘ g‘ (U+2018) va ’ (U+2019).
import json, collections
D = "lib/core/l10n/arb"
K = collections.OrderedDict()
def k(key, desc, en, ru, uz, ph=None):
    K[key] = (desc, en, ru, uz, ph)
S = {"type": "String"}
I = {"type": "int"}

# ------------------------------------------------ modda sahifasi: «Qisqacha»
k("rdGlanceTitle", "Substance page: compact summary card title.",
  "At a glance", "Кратко", "Qisqacha")
k("rdGlanceNote", "Substance page: summary card note (no new facts; built from the sections below).",
  "From the sourced sections below. Quotes and status are inside each section.",
  "Из разделов ниже, с источниками. Цитаты и статус — внутри каждого раздела.",
  "Quyidagi manbali bo‘limlardan. Iqtibos va holat — har bir bo‘lim ichida.")
k("rdGlanceFormula", "Summary row: molecular formula and weight.",
  "Formula", "Формула", "Kimyoviy formula")
k("rdGlanceMolarMass", "Summary row: molecular weight value from the identity record (PubChem), with unit.",
  "{value} g/mol", "{value} г/моль", "{value} g/mol", {"value": S})
k("rdGlanceSpecimens", "Summary row: specimens with sourced values.",
  "Specimens", "Образцы", "Namunalar")
k("rdGlanceMethods", "Summary row: analytical methods named in sources.",
  "Methods", "Методы", "Usullar")
k("rdGlanceMetabolites", "Summary row: metabolites.",
  "Metabolites", "Метаболиты", "Metabolitlar")
k("rdGlanceConcentrations", "Summary row: reported concentrations (count).",
  "Concentrations", "Концентрации", "Konsentratsiyalar")
k("rdGlanceSources", "Summary row: sources (count).",
  "Sources", "Источники", "Manbalar")
k("rdGlanceRecords", "Count of sourced records.",
  "{count, plural, =1{1 sourced record} other{{count} sourced records}}",
  "{count, plural, one{{count} запись с источником} few{{count} записи с источником} other{{count} записей с источником}}",
  "{count, plural, other{{count} ta manbali yozuv}}", {"count": I})
k("rdSourcesCount", "Count of sources / references.",
  "{count, plural, =1{1 source} other{{count} sources}}",
  "{count, plural, one{{count} источник} few{{count} источника} other{{count} источников}}",
  "{count, plural, other{{count} ta manba}}", {"count": I})
k("rdGlanceMore", "Suffix after a shortened list of names.",
  "+{count} more", "ещё {count}", "yana {count} ta", {"count": I})
k("rdGlanceLockedHint", "Summary card when details are locked: what is behind Pro (counts only).",
  "Details below open with Pro. Names, warnings and sources stay free.",
  "Подробности ниже открываются в Pro. Названия, предупреждения и источники остаются бесплатными.",
  "Quyidagi tafsilotlar Pro’da ochiladi. Nomlar, ogohlantirishlar va manbalar bepul qoladi.")
k("rdJumpTo", "Semantics hint: tap to jump to a section on this page.",
  "Go to section", "Перейти к разделу", "Bo‘limga o‘tish")

# ------------------------------------------------------------ yo‘riqnomalar
k("rdGuidelineMeta", "Guideline list row: number of sections and references.",
  "{sections} sections · {refs}", "Разделов: {sections} · {refs}",
  "{sections} bo‘lim · {refs}", {"sections": I, "refs": S})

for idx, code in enumerate(["en", "ru", "uz"]):
    p = f"{D}/app_{code}.arb"
    data = json.load(open(p, encoding="utf-8"), object_pairs_hook=collections.OrderedDict)
    for key, (desc, en, ru, uz, ph) in K.items():
        data[key] = (en, ru, uz)[idx]
        if code == "en":
            meta = {"description": desc}
            if ph:
                meta["placeholders"] = ph
            data["@" + key] = meta
    json.dump(data, open(p, "w", encoding="utf-8"), ensure_ascii=False, indent=2)
    open(p, "a").write("\n")
print(len(K), "keys")
