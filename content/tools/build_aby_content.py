#!/usr/bin/env python3
"""Merge the ABY-derived records (Uzbek only) into content/pilot/bundle.json.
Run AFTER build_substance_methods.py and build_ethanol_gc_content.py.

  python3 content/tools/build_aby_content.py            # write bundle.json
  python3 content/tools/build_aby_content.py --check    # CI: bundle.json already contains exactly this

Owner's decision (docs/DECISIONS.md, 2026-10-10):
  * ABY is cited openly as a source, with its own numbering as the locator
    («ABY, G bo'limi, № ABY.G.16.2025 amaliyoti, 2.3-band»).
  * Nothing is copied: there is no `value.excerpt`; every statement is our own
    wording in `value.statement` with ONLY the `uz` key.
  * `value.locale_only = "uz"` / topic `locale_only = "uz"`: the record and the
    topic exist only in the Uzbek interface — no placeholder, no translation.
  * Free (tier_access = free), never behind the Pro paywall.
  * The guide's own file is not in the repository, in app assets or in Supabase.
"""
from __future__ import annotations

import argparse
import json
import pathlib
import sys

HERE = pathlib.Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))

import aby_data  # noqa: E402

ROOT = HERE.parents[1]
BUNDLE = ROOT / "content/pilot/bundle.json"

CLAIM_PREFIX = "C-ABY-"
TOPIC_PREFIX = "aby-"


def aby_claims():
    claims, cits = [], []
    for cid, etype, ent, field, eclass, locator, text in aby_data.CLAIMS:
        short_loc = locator.split("№ ", 1)[-1].replace(" amaliyoti", "", 1)
        value = {
            "statement": {"uz": text},
            "locale_only": "uz",
            "translation_status": {"uz": "authored"},
            "section": short_loc,
            "method_family": "aby_practice",
            "evidence_class": eclass,
            "scope": "substance" if etype == "substance" else "topic",
            "locator_i18n": {"uz": locator},
            "source_i18n": {"uz": aby_data.SOURCE_I18N_UZ},
            "source_check": {"level": "guide_text_read"},
        }
        claims.append({
            "claim_id": cid, "entity_type": etype, "entity_id": ent, "field": field,
            "domain": "lab", "declared_status": "NEEDS_REVIEW", "evidence_level": "C",
            # The layer taxonomy (international_scientific | international_standard | jurisdictional)
            # has no «national methodological guide» value, and `jurisdictional` would require a legal
            # instrument to anchor to. The record is a professional-practice statement, so it stays in
            # the scientific layer; its national origin is carried by the source and the locator.
            "layer": "international_scientific", "is_structured_value": False, "value": value,
        })
        cits.append({"claim_id": cid, "source_id": aby_data.SRC_ID, "locator": short_loc})
    return claims, cits


def merge(b: dict) -> dict:
    b["claims"] = [c for c in b["claims"] if not c["claim_id"].startswith(CLAIM_PREFIX)]
    kept = {c["claim_id"] for c in b["claims"]}
    b["citations"] = [c for c in b["citations"] if c["claim_id"] in kept]
    b["sources"] = [s for s in b["sources"] if s["source_id"] != aby_data.SRC_ID]
    b["topics"] = [t for t in b["topics"] if not t["topic_id"].startswith(TOPIC_PREFIX)]

    b["sources"].append(aby_data.SOURCE)
    ac, acit = aby_claims()
    b["claims"].extend(ac)
    b["citations"].extend(acit)
    for tid, area, name in aby_data.TOPICS:
        b["topics"].append({
            "topic_id": tid, "area": area, "tier_access": "free", "locale_only": "uz",
            # Uzbek-only name: there is no Russian or English version of this topic, and the
            # app filters the whole entry out of the other two languages
            # (LocaleFilteredKnowledgeRepository), so a copy of the Uzbek text under an `en`
            # key would only pollute the search index.
            "names": {"uz": name},
        })
    return b


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--check", action="store_true")
    a = ap.parse_args()
    b = json.loads(BUNDLE.read_text(encoding="utf-8"))
    out = json.dumps(merge(b), indent=2, ensure_ascii=False) + "\n"
    if a.check:
        if BUNDLE.read_text(encoding="utf-8") != out:
            print("bundle.json is not up to date: run build_aby_content.py")
            return 1
        print("bundle.json up to date (ABY records)")
        return 0
    BUNDLE.write_text(out, encoding="utf-8")
    print(f"sources +1, claims +{len(aby_data.CLAIMS)}, topics +{len(aby_data.TOPICS)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
