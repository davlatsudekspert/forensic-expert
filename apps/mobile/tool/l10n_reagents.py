# Reaktiv retseptlari sahifasi (ilova egasi to‘plami, 2026-10-09) — UI matnlari.
# Idempotent: qayta ishga tushirish xavfsiz.
# Ishga tushirish (CLAUDE.md tartibi: l10n_ux_audit.py dan oldin):
#   cd apps/mobile && python3 tool/l10n_reagents.py && python3 tool/l10n_ux_audit.py && flutter gen-l10n
# O‘zbekcha — adabiy lotin: o‘ g‘ (U+2018) va ’ (U+2019).
import collections
import json

D = "lib/core/l10n/arb"
K = collections.OrderedDict()


def k(key, desc, en, ru, uz, ph=None):
    K[key] = (desc, en, ru, uz, ph)


S = {"type": "String"}
I = {"type": "int"}

# ------------------------------------------------------------- xavf kartalari
k("reagentHazardBanner", "Reagent page: prominent banner above hazard cards (count of hazard notes).",
  "{count, plural, =1{1 hazard note — read before preparing} other{{count} hazard notes — read before preparing}}",
  "{count, plural, one{{count} предупреждение об опасности — прочитайте до приготовления} few{{count} предупреждения об опасности — прочитайте до приготовления} other{{count} предупреждений об опасности — прочитайте до приготовления}}",
  "{count, plural, other{{count} ta xavf ogohlantirishi — tayyorlashdan oldin o‘qing}}",
  {"count": I})
k("reagentHazardGhs", "Hazard card label: GHS hazard statements taken from PubChem.",
  "GHS hazard statements (PubChem)", "Формулировки опасности СГС (PubChem)",
  "GHS xavf bayonotlari (PubChem)")
k("reagentHazardGeneral", "Hazard card label: general safety advice written by the app (not a cited source).",
  "General safety advice (app guidance)", "Общая рекомендация по безопасности (от приложения)",
  "Umumiy xavfsizlik tavsiyasi (ilova izohi)")

# ------------------------------------------------------------- retsept bo‘limi
k("reagentRecipeSource", "Reagent page: which source the preparation comes from.",
  "Source: {title}", "Источник: {title}", "Manba: {title}", {"title": S})
k("reagentMachineDraft", "Reagent page: Uzbek/English texts are automatic drafts, not yet reviewed.",
  "Translation is an automatic draft and has not been reviewed by a specialist. Numbers are copied from the source unchanged; check them against the original text below.",
  "Перевод — автоматический черновик, специалистом не проверен. Числа перенесены из источника без изменений; сверяйте с исходным текстом ниже.",
  "Tarjima — avtomatik qoralama, mutaxassis tomonidan tekshirilmagan. Raqamlar manbadan o‘zgarishsiz olingan; quyidagi asl matn bilan solishtiring.")
k("reagentVariant", "Reagent page: heading of an alternative preparation method.",
  "Method {label}", "Способ {label}", "Usul: {label}", {"label": S})
k("reagentMakeUpTo", "Ingredient amount: make the volume up to this value («до 100 мл»).",
  "to {value}", "до {value}", "{value} gacha", {"value": S})
k("reagentUnitG", "Unit: grams.", "g", "г", "g")
k("reagentUnitMl", "Unit: millilitres.", "mL", "мл", "ml")
k("reagentUnitL", "Unit: litres.", "L", "л", "l")
k("reagentDropsAmount", "Ingredient amount in drops; value is the formatted number or range, count selects the plural form.",
  "{count, plural, =1{{value} drop} other{{value} drops}}",
  "{count, plural, one{{value} капля} few{{value} капли} other{{value} капель}}",
  "{count, plural, other{{value} tomchi}}", {"count": I, "value": S})
k("reagentPurpose", "Reagent page: purpose stated in the source.",
  "Purpose (from the source)", "Назначение (по источнику)", "Qo‘llanishi (manba bo‘yicha)")
k("reagentNote", "Reagent page: additional note from the source.",
  "Note from the source", "Примечание из источника", "Manbadagi izoh")
k("reagentAmbiguity", "Reagent page: card listing ambiguities / OCR errors found in the source text.",
  "Check against the original", "Сверьте с оригиналом", "Asl matn bilan tekshiring")
k("reagentOriginalText", "Reagent page: collapsible section with the original Russian source text.",
  "Original text (Russian)", "Исходный текст (рус.)", "Asl matn (rus)")
k("reagentOriginalHint", "Reagent page: hint under the original text heading.",
  "Verbatim from the source, kept for traceability (OCR errors not corrected).",
  "Дословно из источника, для прослеживаемости (ошибки распознавания не исправлены).",
  "Manbadan so‘zma-so‘z, kuzatuvchanlik uchun (OCR xatolari tuzatilmagan).")

k("reusePermissionGranted", "Reuse status chip: content-rights permission from the owner/author is on record (copyright only; NOT a legal permit for handling hazardous substances).",
  "RIGHTS HOLDER'S PERMISSION", "С РАЗРЕШЕНИЯ ПРАВООБЛАДАТЕЛЯ", "MUALLIF/EGASI RUXSATI BILAN")

# Eski kalitlar (idempotent tozalash).
OLD = ["reagentUnitDrop"]

for idx, code in enumerate(["en", "ru", "uz"]):
    p = f"{D}/app_{code}.arb"
    data = json.load(open(p, encoding="utf-8"), object_pairs_hook=collections.OrderedDict)
    for key in OLD:
        data.pop(key, None)
        data.pop("@" + key, None)
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
