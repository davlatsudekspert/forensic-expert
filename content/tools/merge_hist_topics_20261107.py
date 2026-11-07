#!/usr/bin/env python3
"""Gistologiya: 4 ta yangi mavzuni (ochiq PMC iqtiboslari, CC BY) MAVJUD
pilot/bundle.json ga qo‘shadi — butun paketni qayta yig‘masdan (assemble_pilot
keyingi qo‘lda bosqichlarni (guidelines, tahlil, p7–p10) qayta ishlamaydi).
Idempotent: allaqachon bor ID lar o‘tkazib yuboriladi.
Mavzular: his-wound-age-markers, his-lung-asphyxia, his-heat-burn-skin,
his-brain-hypoxia (hammasi NEEDS_REVIEW)."""
import json, os, sys
os.chdir(os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
sys.path[:0] = ["tools", "tools/p5"]
import assemble_p5  # noqa: E402

NEW = ["his-wound-age-markers", "his-lung-asphyxia", "his-heat-burn-skin", "his-brain-hypoxia"]
P = "pilot/bundle.json"
b = json.load(open(P))
existing = ({t["topic_id"] for t in b["topics"]} | {m["method_id"] for m in b["methods"]}
            | {r["reagent_id"] for r in b["recipes"]} | {t["screening_id"] for t in b["screening_tests"]}
            | {e["issue_id"] for e in b["emerging_issues"]})
out = assemble_p5.build_topics(existing, b.get("assembled_at", "2026-11-07"), None)
tk = {t["topic_id"] for t in out["topics"] if t["topic_id"] in NEW}
tag = tuple(x.upper() for x in NEW)
have_t = {t["topic_id"] for t in b["topics"]}
have_c = {c["claim_id"] for c in b["claims"]}
have_s = {s["source_id"] for s in b["sources"]}
have_cit = {(c.get("claim_id"), c.get("source_id")) for c in b["citations"]}
new_claims = [c for c in out["claims"] if any(t in c["claim_id"] for t in tag) and c["claim_id"] not in have_c]
cl_ids = {c["claim_id"] for c in new_claims}
new_cit = [c for c in out["citations"] if c["claim_id"] in cl_ids and (c.get("claim_id"), c.get("source_id")) not in have_cit]
need_src = {c["source_id"] for c in new_cit}
new_src = [s for sid, s in out["sources"].items() if sid in need_src and sid not in have_s]
new_topics = [t for t in out["topics"] if t["topic_id"] in tk and t["topic_id"] not in have_t]
new_links = [l for l in out["links"] if json.dumps(l, sort_keys=True) not in {json.dumps(x, sort_keys=True) for x in b["links"]}
             and (l.get("claim_id") in cl_ids or any(t in json.dumps(l) for t in NEW))]
b["topics"] += new_topics; b["claims"] += new_claims; b["citations"] += new_cit
b["sources"] += new_src; b["links"] += new_links
json.dump(b, open(P, "w"), ensure_ascii=False, indent=1)
print("topics+", len(new_topics), "claims+", len(new_claims), "citations+", len(new_cit),
      "sources+", len(new_src), "links+", len(new_links))
