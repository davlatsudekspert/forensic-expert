#!/usr/bin/env python3
"""Merge the ethanol GC-FID records (international literature, en/uz/ru) into
content/pilot/bundle.json.  Idempotent: records merged earlier (claim ids `C-EP-ETHANOL-*`,
the sources listed in ethanol_gc_data.NEW_SOURCES) are removed first.
Run AFTER build_substance_methods.py.

  python3 content/tools/build_ethanol_gc_content.py            # write bundle.json
  python3 content/tools/build_ethanol_gc_content.py --check    # CI: bundle.json already contains exactly this

Record shape (same as the C-SM-* records of build_substance_methods.py):
  value.statement      {en, uz, ru}  — our own paraphrase (no value.excerpt)
  value.source_i18n    per-language short source name
  value.locator_i18n   per-language exact place in the source (section / «abstract»)
  value.evidence_class instrumental | presumptive
  value.source_check   how each source was read: full_text | abstract
"""
from __future__ import annotations

import argparse
import json
import pathlib
import sys

HERE = pathlib.Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))

import ethanol_gc_data as eth  # noqa: E402

ROOT = HERE.parents[1]
BUNDLE = ROOT / "content/pilot/bundle.json"

CLAIM_PREFIX = "C-EP-ETHANOL-"
MANAGED_SOURCES = {s["source_id"] for s in eth.NEW_SOURCES}
LANGS = ("en", "uz", "ru")


def _cite_locator(sid: str, sec_key: str | None, lang_idx: int) -> str:
    short = eth.SHORT[sid]
    if sec_key is None:
        return f"{short}, {eth.ABS[lang_idx]}"
    return f"{short}, {eth.TAYLOR_SEC[sec_key][lang_idx]}"


def ethanol_claims():
    claims, cits = [], []
    for c in eth.CLAIMS:
        locs = {}
        for i, lang in enumerate(LANGS):
            locs[lang] = "; ".join(_cite_locator(sid, key, i) for sid, key in c["cites"])
        value = {
            "statement": {l: c[l] for l in LANGS},
            "translation_status": {"en": "authored", "uz": "machine_draft", "ru": "machine_draft"},
            "section": locs["en"],
            "method_family": c["method_family"],
            "evidence_class": "presumptive" if c["method_family"] == "caveat" else "instrumental",
            "scope": "substance",
            "locator_i18n": locs,
            "source_i18n": {
                lang: "; ".join(eth.SHORT[sid] for sid, _ in c["cites"]) for lang in LANGS
            },
            "source_check": {
                "level": c["read"],
                "sources": {sid: ("full_text" if key else "abstract") for sid, key in c["cites"]},
            },
            "data": {"methods": ["method-gc-fid", "method-headspace-gc"]},
        }
        claims.append({
            "claim_id": c["id"], "entity_type": "substance", "entity_id": eth.ENT, "field": c["field"],
            "domain": "lab", "declared_status": "NEEDS_REVIEW", "evidence_level": c["level"],
            "layer": "international_scientific", "is_structured_value": False, "value": value,
        })
        for sid, key in c["cites"]:
            cits.append({"claim_id": c["id"], "source_id": sid,
                         "locator": _cite_locator(sid, key, 0)})
    return claims, cits


def merge(b: dict) -> dict:
    b["claims"] = [c for c in b["claims"] if not c["claim_id"].startswith(CLAIM_PREFIX)]
    gone = {c["claim_id"] for c in b["claims"]}
    b["citations"] = [c for c in b["citations"] if c["claim_id"] in gone]
    b["sources"] = [s for s in b["sources"] if s["source_id"] not in MANAGED_SOURCES]
    b["sources"].extend(eth.NEW_SOURCES)
    ec, ecit = ethanol_claims()
    b["claims"].extend(ec)
    b["citations"].extend(ecit)
    return b


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--check", action="store_true")
    a = ap.parse_args()
    b = json.loads(BUNDLE.read_text(encoding="utf-8"))
    out = json.dumps(merge(b), indent=2, ensure_ascii=False) + "\n"
    if a.check:
        if BUNDLE.read_text(encoding="utf-8") != out:
            print("bundle.json is not up to date: run build_ethanol_gc_content.py")
            return 1
        print("bundle.json up to date (ethanol GC-FID records)")
        return 0
    BUNDLE.write_text(out, encoding="utf-8")
    print(f"sources +{len(eth.NEW_SOURCES)}, claims +{len(eth.CLAIMS)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
