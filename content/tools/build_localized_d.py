#!/usr/bin/env python3
"""Build content/pilot/translations/localized_texts_d.json (Phase D sidecar).

Texts that have NO trilingual field in the v7 content schema (screening
analyte/specimen/principle, evidence-conflict question/note, standard notes,
concentration-context free text, metabolite/list items, app-authored source
title) get draft translations here, one record per (target_type, target_id),
shaped like the proposed `localized_texts` table (docs/L10N_DATA_CONTRACT_D.md):

  {target_type, target_id, source_lang, source_text, source_sha256,
   text: {uz, ru[, en]}, status: "machine_draft"}

Inputs: pilot/bundle.json (originals) + pilot/translations/localized_texts_d.src.json
(drafts keyed by original text). Enum-like context values (not_stated, blood …)
are UI-label codes, not text, and are skipped. Run from the repository root:
  python3 content/tools/build_localized_d.py
"""
import hashlib
import json
import pathlib
import re

ROOT = pathlib.Path(__file__).resolve().parents[2]
BUNDLE = ROOT / "content/pilot/bundle.json"
SRC = ROOT / "content/pilot/translations/localized_texts_d.src.json"
OUT = ROOT / "content/pilot/translations/localized_texts_d.json"
CODE = re.compile(r"[a-z_\-]+|\d+")

# App-authored source title (original language: uz).
EDITORIAL = {
    "ru": "FORENSIC EXPERT — редакционные примечания (общие рекомендации по безопасности, неясности источников); не является научным источником",
    "en": "FORENSIC EXPERT — editorial notes (general safety advice, source ambiguities); not a scientific source",
}


def sha(t):
    return hashlib.sha256(t.encode("utf-8")).hexdigest()


def targets(b):
    for s in b["screening_tests"]:
        for f in ("analyte", "specimen", "principle"):
            yield "screening_field", f"{s['screening_id']}#{f}", s[f]
    for c in b["conflicts"]:
        yield "conflict_text", f"{c['conflict_id']}#question", c["question"]
        yield "conflict_text", f"{c['conflict_id']}#note", c["note"]
    for s in b["standards"]:
        if s.get("note"):
            yield "standard_note", s["standard_id"], s["note"]
    for c in b["claims"]:
        v = c.get("value")
        if not isinstance(v, dict):
            continue
        for k, x in (v.get("context_strict") or {}).items():
            vals = [(f"{k}", x)] if isinstance(x, str) else \
                [(f"{k}[{i}]", y) for i, y in enumerate(x)] if isinstance(x, list) else []
            for key, y in vals:
                if isinstance(y, str) and y.strip() and not CODE.fullmatch(y):
                    yield "context_text", f"{c['claim_id']}#{key}", y
        for i, it in enumerate(v.get("items") or []):
            if isinstance(it, str):
                yield "list_item", f"{c['claim_id']}#items[{i}]", it


def main():
    b = json.loads(BUNDLE.read_text(encoding="utf-8"))
    drafts = json.loads(SRC.read_text(encoding="utf-8"))["texts"]
    records, missing = [], []
    for kind, tid, text in targets(b):
        d = drafts.get(text)
        if not d:
            missing.append(f"{kind}:{tid}")
            continue
        records.append({"target_type": kind, "target_id": tid, "source_lang": "en", "source_text": text,
                        "source_sha256": sha(text), "text": {"uz": d["uz"], "ru": d["ru"]},
                        "status": "machine_draft"})
    # Explanatory card text derived ONLY from the card's sourced claims
    # (derived=true: QA checks that every number/unit comes from those claims).
    claims = {c["claim_id"]: c for c in b["claims"]}
    src_data = json.loads(SRC.read_text(encoding="utf-8"))
    for kind, key in (("topic_body", "topic_bodies"), ("method_body", "method_bodies")):
        for tid, body in src_data.get(key, {}).items():
            src_text = " ".join(claims[c]["value"]["excerpt"] for c in body["claims"])
            records.append({"target_type": kind, "target_id": tid, "source_lang": "en", "derived": True,
                            "source_claims": body["claims"], "source_text": src_text, "source_sha256": sha(src_text),
                            "text": body["text"], "status": "machine_draft"})
    for s in b["sources"]:
        if s["source_id"] == "SRC-FE-EDITORIAL":
            records.append({"target_type": "source_title", "target_id": s["source_id"], "source_lang": "uz",
                            "source_text": s["title"], "source_sha256": sha(s["title"]),
                            "text": dict(EDITORIAL), "status": "machine_draft"})
    out = {
        "format": "fe-localized-texts/1",
        "contract": "docs/L10N_DATA_CONTRACT_D.md",
        "note": "Automatic drafts (machine_draft), NOT reviewed. Originals stay in content.db; a record "
                "applies only while source_sha256 == sha256(utf-8 original). Checked by content/tools/translation_qa.py.",
        "records": records,
    }
    OUT.write_text(json.dumps(out, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
    by = {}
    for r in records:
        by[r["target_type"]] = by.get(r["target_type"], 0) + 1
    print(f"localized_texts_d: {len(records)} records {by}; missing drafts: {len(missing)}")
    for m in missing:
        print("  MISSING", m)


if __name__ == "__main__":
    main()
