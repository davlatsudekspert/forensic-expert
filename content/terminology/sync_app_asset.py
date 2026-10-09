#!/usr/bin/env python3
"""Validate abbreviation_glossary.json against canonical_terms.json and copy
it into the app asset (apps/mobile/assets/content/terminology/).

Checks: every glossary entry points to a canonical term (canonical_id) with the same
abbreviation; expansion matches the canonical expansion; explanation and
expansion present in uz/ru/en; status is machine_draft / translated /
reviewed (never promoted silently); Uzbek text uses U+2018 for o‘/g‘.

Run:  python3 content/terminology/sync_app_asset.py
"""
import json
import pathlib
import re
import sys

HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parent.parent
TARGET = ROOT / "apps/mobile/assets/content/terminology/abbreviation_glossary.json"
LANGS = ("uz", "ru", "en")
STATUSES = {"machine_draft", "translated", "reviewed"}


def main() -> int:
    canon = json.loads((HERE / "canonical_terms.json").read_text(encoding="utf-8"))
    data = json.loads((HERE / "abbreviation_glossary.json").read_text(encoding="utf-8"))
    errors = []
    canon_by_id = {c["id"]: c for c in canon["terms"]}
    for t in data["terms"]:
        c = canon_by_id.get(t["canonical_id"])
        if c is None:
            errors.append(f"{t['id']}: canonical_id {t['canonical_id']!r} not in canonical_terms.json")
            continue
        if t["abbreviation"] != c["abbr"]:
            errors.append(f"{c['id']}: abbreviation differs")
        for lang in LANGS:
            if t["expansion"].get(lang) != c["expansion"].get(lang):
                errors.append(f"{c['id']}: expansion.{lang} differs from canonical")
    for t in data["terms"]:
        for field in ("expansion", "explanation"):
            for lang in LANGS:
                if not str(t.get(field, {}).get(lang, "")).strip():
                    errors.append(f"{t['id']}: {field}.{lang} missing")
        for lang in LANGS:
            if t.get("status", {}).get(lang) not in STATUSES:
                errors.append(f"{t['id']}: status.{lang} invalid")
        uz = " ".join([t["expansion"]["uz"], t["explanation"]["uz"]])
        if re.search(r"[oOgG]['`ʻ’]", uz):
            errors.append(f"{t['id']}: uz must use U+2018 for o‘/g‘")
    if errors:
        print("\n".join(errors))
        return 1
    TARGET.parent.mkdir(parents=True, exist_ok=True)
    TARGET.write_text(json.dumps(data, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
    print(f"wrote {TARGET.relative_to(ROOT)}: {len(data['terms'])} terms")
    return 0


if __name__ == "__main__":
    sys.exit(main())
