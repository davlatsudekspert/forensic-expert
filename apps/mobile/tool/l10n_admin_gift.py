#!/usr/bin/env python3
"""Admin panelidan Pro sovg‘a qilish uchun ARB kalitlari — idempotent."""
import json
import pathlib

ARB = pathlib.Path(__file__).resolve().parent.parent / "lib/core/l10n/arb"

# key: (en, ru, uz, description)
ROWS = [
]

PLACEHOLDERS: dict = {}


def main() -> None:
    for lang, index in {"en": 0, "ru": 1, "uz": 2}.items():
        path = ARB / f"app_{lang}.arb"
        data = json.loads(path.read_text(encoding="utf-8"))
        changed = False
        for row in ROWS:
            key, text, description = row[0], row[1 + index], row[4]
            if data.get(key) != text:
                data[key] = text
                changed = True
            if lang == "en":
                meta = {"description": description}
                if key in PLACEHOLDERS:
                    meta["placeholders"] = PLACEHOLDERS[key]
                if data.get(f"@{key}") != meta:
                    data[f"@{key}"] = meta
                    changed = True
        if changed:
            path.write_text(
                json.dumps(data, ensure_ascii=False, indent=2) + "\n",
                encoding="utf-8",
            )
        print(f"l10n_admin_gift: {lang} {'updated' if changed else 'unchanged'}")


if __name__ == "__main__":
    main()
