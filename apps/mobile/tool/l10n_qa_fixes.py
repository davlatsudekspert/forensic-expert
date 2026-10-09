# Real-ilova QA (2026-10-09) topilmalari bo‘yicha lokalizatsiya tuzatishlari.
# Idempotent — kalitlarni qo‘shadi/qiymatlarni o‘rnatadi; qayta ishga
# tushirilsa natija o‘zgarmaydi.
# Ishga tushirish: apps/mobile ichida `python3 tool/l10n_qa_fixes.py`, so‘ng
# `flutter gen-l10n`.
import collections
import json

D = "lib/core/l10n/arb"
LANGS = ["en", "ru", "uz"]

NEW = collections.OrderedDict()


def k(key, desc, en, ru, uz, ph=None):
    NEW[key] = (desc, en, ru, uz, ph)


S = {"type": "String"}

# Kontent paketidagi rasm atribusiyasi inglizcha shablon bilan yozilgan
# («Structure drawn from PubChem CID 702 SMILES with RDKit»). UI uni
# tanlangan tilda ko‘rsatadi; noma’lum atribusiya o‘zgarmaydi.
k(
    "imageAttrPubchemRdkit",
    "Attribution of a computed structure image (PubChem SMILES rendered with RDKit).",
    "Structure drawn from PubChem CID {cid} SMILES with RDKit",
    "Структура построена по SMILES из PubChem CID {cid} с помощью RDKit",
    "Struktura PubChem CID {cid} SMILES asosida RDKit bilan chizilgan",
    {"cid": S},
)
k(
    "imageAttrOriginalSchematic",
    "Attribution of an original schematic drawn by the app team.",
    "Original schematic — FORENSIC EXPERT",
    "Оригинальная схема — FORENSIC EXPERT",
    "Asl sxema — FORENSIC EXPERT",
)


def main():
    for idx, code in enumerate(LANGS):
        p = f"{D}/app_{code}.arb"
        with open(p, encoding="utf-8") as f:
            data = json.load(f, object_pairs_hook=collections.OrderedDict)
        for key, (desc, en, ru, uz, ph) in NEW.items():
            data[key] = (en, ru, uz)[idx]
            if code == "en":
                meta = {"description": desc}
                if ph:
                    meta["placeholders"] = ph
                data["@" + key] = meta
        with open(p, "w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
            f.write("\n")
    print(len(NEW), "keys set")


if __name__ == "__main__":
    main()
