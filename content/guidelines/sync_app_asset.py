#!/usr/bin/env python3
"""Copy guidelines_v1.json into the app asset without internal fields.

`omitted_unverified` is an internal working field and is never shipped
(apps/mobile/test/unit/guidelines_content_test.dart checks this).
Run after build.py + validate.py:  python3 content/guidelines/sync_app_asset.py
"""
import json
import pathlib

HERE = pathlib.Path(__file__).resolve().parent
TARGET = HERE.parent.parent / "apps/mobile/assets/content/guidelines/guidelines_v1.json"
INTERNAL = ("omitted_unverified",)


def main() -> None:
    data = json.loads((HERE / "guidelines_v1.json").read_text(encoding="utf-8"))
    for card in data["cards"]:
        for f in INTERNAL:
            card.pop(f, None)
    TARGET.write_text(json.dumps(data, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
    print(f"wrote {TARGET.relative_to(HERE.parent.parent)}: {len(data['cards'])} cards")


if __name__ == "__main__":
    main()
