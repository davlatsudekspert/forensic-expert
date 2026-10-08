#!/usr/bin/env python3
"""Assemble content/guidelines/guidelines_v1.json (fe-guidelines/1).

Sources:
  src/card_*.json   - one card per file (authored content)
  references.json   - verified bibliography (single source of truth)

Only references actually cited by at least one card are embedded.
Run from anywhere:  python3 content/guidelines/build.py
"""
import json
import pathlib

HERE = pathlib.Path(__file__).resolve().parent
SECTION_ORDER = [
    "basis", "scope", "methods", "advantages",
    "limitations", "factors", "cautions", "alternatives",
]


def main() -> None:
    refs = json.loads((HERE / "references.json").read_text(encoding="utf-8"))["references"]
    cards = []
    for path in sorted((HERE / "src").glob("card_*.json")):
        card = json.loads(path.read_text(encoding="utf-8"))
        card["sections"].sort(key=lambda s: SECTION_ORDER.index(s["key"]))
        cited = []
        for s in card["sections"]:
            for k in s["citations"]:
                if k not in cited:
                    cited.append(k)
        card["reference_keys"] = cited
        cards.append(card)

    used = {k for c in cards for k in c["reference_keys"]}
    out = {
        "schema": "fe-guidelines/1",
        "generated_by": "content/guidelines/build.py",
        "language_order": ["uz", "ru", "en"],
        "section_order": SECTION_ORDER,
        "cards": cards,
        "references": [r for r in refs if r["key"] in used],
    }
    target = HERE / "guidelines_v1.json"
    target.write_text(json.dumps(out, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"wrote {target.relative_to(HERE.parent.parent)}: "
          f"{len(cards)} cards, {len(out['references'])} references")


if __name__ == "__main__":
    main()
