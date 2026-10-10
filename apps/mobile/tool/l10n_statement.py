#!/usr/bin/env python3
"""Manbaga asoslangan bayon (iqtibos emas) uchun ARB kalitlari — idempotent."""
import json
import pathlib

ARB = pathlib.Path(__file__).resolve().parent.parent / "lib/core/l10n/arb"

KEYS = {
    "detailSourcedStatement": {
        "en": "Based on the source (not a direct quotation)",
        "ru": "По источнику (не дословная цитата)",
        "uz": "Manbaga asoslangan bayon (so‘zma-so‘z iqtibos emas)",
    },
}
DESCRIPTIONS = {
    "detailSourcedStatement": (
        "Label above a claim body that paraphrases a source we may not quote."
    ),
}


def main() -> None:
    for lang in ("en", "ru", "uz"):
        path = ARB / f"app_{lang}.arb"
        data = json.loads(path.read_text(encoding="utf-8"))
        changed = False
        for key, values in KEYS.items():
            if data.get(key) != values[lang]:
                data[key] = values[lang]
                changed = True
            if lang == "en" and f"@{key}" not in data:
                data[f"@{key}"] = {"description": DESCRIPTIONS[key]}
                changed = True
        if changed:
            path.write_text(
                json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
            )
        print(f"l10n_statement: {lang} {'updated' if changed else 'unchanged'}")


if __name__ == "__main__":
    main()
