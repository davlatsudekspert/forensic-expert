# Iqtibos eksporti (GOST / Vancouver / APA) — manba, yo‘riqnoma adabiyoti,
# research va provenance oynasidagi «Iqtibosni nusxalash» hamda sahifadagi
# «Barcha manbalar ro‘yxati». Idempotent: qayta ishga tushirish xavfsiz.
# Ishga tushirish:
#   cd apps/mobile && python3 tool/l10n_citations.py && flutter gen-l10n
# O‘zbekcha — adabiy lotin: o‘ g‘ (U+2018) va ’ (U+2019).
import json, collections
D = "lib/core/l10n/arb"
K = collections.OrderedDict()
def k(key, desc, en, ru, uz, ph=None):
    K[key] = (desc, en, ru, uz, ph)
I = {"type": "int"}

k("citeCopy", "Action on a source/reference: open the sheet to copy a formatted bibliographic citation.",
  "Copy citation", "Копировать для списка литературы", "Iqtibosni nusxalash")
k("citeAllSources", "Page action (substance/guideline): copy a numbered list of all sources on this page.",
  "Copy reference list", "Список всех источников", "Barcha manbalar ro‘yxati")
k("citeListTitle", "Citation sheet title for the page-level reference list.",
  "Reference list · {count}", "Список источников · {count}", "Manbalar ro‘yxati · {count}", {"count": I})
k("citeStyleLabel", "Citation sheet: label above the style selector.",
  "Citation style", "Стиль оформления", "Rasmiylashtirish uslubi")
k("citeStyleGost", "Citation style name: GOST R 7.0.100-2018.",
  "GOST", "ГОСТ", "GOST")
k("citeStyleVancouver", "Citation style name: Vancouver.",
  "Vancouver", "Ванкувер", "Vancouver")
k("citeStyleApa", "Citation style name: APA 7th edition.",
  "APA 7", "APA 7", "APA 7")
k("citeCopyButton", "Citation sheet: copy button.",
  "Copy", "Копировать", "Nusxalash")
k("citeCopied", "Snackbar after copying one citation.",
  "Citation copied", "Ссылка скопирована", "Iqtibos nusxalandi")
k("citeListCopied", "Snackbar after copying the reference list.",
  "{count, plural, =1{1 reference copied} other{{count} references copied}}",
  "{count, plural, one{Скопирован {count} источник} few{Скопировано {count} источника} other{Скопировано {count} источников}}",
  "{count, plural, other{{count} ta manba nusxalandi}}", {"count": I})
k("citeVerifyNote", "One-line note under citations: the app is a reference tool; the expert must verify sources.",
  "The app is a reference tool: verify each source against the original before citing it in an expert conclusion.",
  "Приложение — справочный инструмент: перед включением в заключение сверьте каждый источник с оригиналом.",
  "Ilova — ma’lumotnoma vosita: xulosaga kiritishdan oldin har bir manbani asl nusxa bilan tekshiring.")

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
