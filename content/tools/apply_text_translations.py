#!/usr/bin/env python3
"""Avtomatik (machine_draft) matn tarjimalarini bundle.json ga qo‘shadi.

Kirish (commit qilingan):
  pilot/translations/excerpts_i18n.json        — claim/rule iqtiboslari (uz, ru)
  pilot/translations/research_titles_i18n.json — tadqiqot sarlavhalari (ixtiyoriy)

Chiqish: pilot/bundle.json ichidagi `text_translations` ro‘yxati.

Qoidalar:
- Asl (inglizcha) iqtibos o‘zgarmaydi — u dalil. Tarjima alohida qatlam.
- Status faqat `machine_draft` (validator FE041 boshqasini rad etadi).
- `source_sha256` joriy asl matn bilan mos kelmasa, tarjima eskirgan —
  bundle’ga kirmaydi va ro‘yxat sifatida chop etiladi.

Ishga tushirish (content/ ichidan): python3 tools/apply_text_translations.py
"""
import hashlib
import json
import os
import sys

BUNDLE = "pilot/bundle.json"
EXCERPTS = "pilot/translations/excerpts_i18n.json"
TITLES = "pilot/translations/research_titles_i18n.json"
LANGS = ("uz", "ru")


def sha(text):
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


def load(path):
    if not os.path.exists(path):
        return None
    data = json.load(open(path))
    if data.get("status") != "machine_draft":
        sys.exit(f"{path}: status must be machine_draft")
    return data


def rows(kind, source_by_id, entries, stale):
    out = []
    for target_id, e in sorted((entries or {}).items()):
        src = source_by_id.get(target_id)
        if src is None or sha(src) != e.get("source_sha256"):
            stale.append(f"{kind}:{target_id}")
            continue
        for lang in LANGS:
            text = (e.get(lang) or "").strip()
            if not text:
                continue
            out.append({
                "target_type": kind,
                "target_id": target_id,
                "lang": lang,
                "source_sha256": e["source_sha256"],
                "text": text,
                "status": "machine_draft",
            })
    return out


def apply(b):
    """`b` (bundle dict) ichida `text_translations` ni yangilaydi."""
    claim_src = {c["claim_id"]: c["value"]["excerpt"] for c in b["claims"]
                 if isinstance(c.get("value"), dict) and c["value"].get("excerpt")}
    rule_src = {r["rule_id"]: r["value"]["excerpt"] for r in b["rules"]
                if isinstance(r.get("value"), dict) and r["value"].get("excerpt")}
    research_src = {r["research_id"]: r["title"] for r in b["research"]}

    stale = []
    out = []
    ex = load(EXCERPTS)
    if ex:
        out += rows("claim_excerpt", claim_src, ex.get("claims"), stale)
        out += rows("rule_excerpt", rule_src, ex.get("rules"), stale)
    ti = load(TITLES)
    if ti:
        out += rows("research_title", research_src, ti.get("research"), stale)

    b["text_translations"] = out
    return {"rows": len(out), "stale": stale}


def main():
    b = json.load(open(BUNDLE))
    r = apply(b)
    json.dump(b, open(BUNDLE, "w"), ensure_ascii=False, indent=2)
    print(f"text_translations: {r['rows']} rows; stale skipped: {len(r['stale'])}")
    for s in r["stale"]:
        print("  STALE", s)


if __name__ == "__main__":
    main()
