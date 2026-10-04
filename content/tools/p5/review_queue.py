#!/usr/bin/env python3
"""Reviewer navbati (review queue) — bundle.json dan.

Har bir element: claim / qoida / rasm / tarjima → aniq manba, asl jumla,
taklif qilingan tuzilgan qiymat, domen, kerakli reviewer roli, manba turi,
litsenziya, talab (four-eyes) va joriy holat.

Rollar ajratilgan: scientific (toksikologiya/biokimyo), analytical (lab),
medicine_histology (sud tibbiyoti / gistologiya), legal (yurisdiksiya),
translation (RU/UZ nomlar). Muallif o‘z claim’ini tasdiqlay olmaydi —
StatusResolver muallif review’ini hisobga olmaydi.

Chiqish: review/queue.json, review/queue.csv, review/REVIEW_QUEUE.md
"""
import collections, csv, json

ROLE = {"tox": "scientific", "lab": "analytical", "fm": "medicine_histology", "legal": "legal",
        "edu": "scientific", "i18n": "translation"}
REQUIRED = {"scientific": 2, "analytical": 2, "medicine_histology": 2, "legal": 1, "translation": 1}


def main():
    b = json.load(open("pilot/bundle.json"))
    src = {s["source_id"]: s for s in b["sources"]}
    cit = collections.defaultdict(list)
    for c in b["citations"]:
        cit[c["claim_id"]].append(c)
    items = []
    for c in b["claims"]:
        role = ROLE[c["domain"]]
        if c["entity_id"].startswith("his-"):
            role = "medicine_histology"
        for ci in cit[c["claim_id"]] or [{}]:
            s = src.get(ci.get("source_id"), {})
            v = dict(c["value"])
            excerpt = v.pop("excerpt", None)
            items.append(dict(kind="claim", id=c["claim_id"], entity=c["entity_id"], field=c["field"],
                              domain=c["domain"], role=role, required_reviews=REQUIRED[role],
                              source_id=s.get("source_id"), source_title=s.get("title"), source_type=s.get("source_type"),
                              doi=s.get("doi"), url=s.get("official_url"), locator=ci.get("locator"),
                              license=s.get("license_mode"), evidence_level=c["evidence_level"],
                              extracted_evidence=excerpt, proposed_value=v, status=c["declared_status"]))
    for r in b["rules"]:
        items.append(dict(kind="legal_rule", id=r["rule_id"], entity=r["subject_id"], field=r["rule_type"],
                          domain="legal", role="legal", required_reviews=REQUIRED["legal"],
                          source_id=next((i["official_source_id"] for i in b["instruments"] if i["instrument_id"] == r["instrument_id"]), None),
                          proposed_value=r["value"], extracted_evidence=r["value"].get("excerpt") or "; ".join(r["value"].get("rows", [])),
                          status=r["review_status"]))
    for im in b.get("images", []):
        items.append(dict(kind="image", id=im["image_id"], entity=im["entity_id"], field="image_license",
                          domain="i18n" if False else "legal", role="legal", required_reviews=1,
                          url=im.get("source_url"), license=im["license"], extracted_evidence=im.get("caption_original"),
                          proposed_value=dict(attribution=im["attribution"], alt=im["alt"]["en"],
                                              represents_real_data=im["represents_real_data"]),
                          status="NEEDS_REVIEW"))
    for s in b["substances"]:
        if any(v != "reviewed" for v in s["translation_status"].values()):
            items.append(dict(kind="translation", id=f"I18N-{s['substance_id']}", entity=s["substance_id"],
                              field="names", domain="i18n", role="translation", required_reviews=1,
                              proposed_value=s["names"], status="NEEDS_REVIEW"))
    json.dump(items, open("review/queue.json", "w"), ensure_ascii=False, indent=1)
    cols = ["kind", "id", "entity", "field", "role", "required_reviews", "status", "evidence_level",
            "source_id", "doi", "url", "locator", "license", "extracted_evidence", "proposed_value"]
    with open("review/queue.csv", "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=cols, extrasaction="ignore")
        w.writeheader()
        for it in items:
            row = dict(it)
            row["proposed_value"] = json.dumps(it.get("proposed_value"), ensure_ascii=False)
            w.writerow(row)
    by_role = collections.Counter(i["role"] for i in items)
    by_kind = collections.Counter(i["kind"] for i in items)
    md = ["# Reviewer navbati (avtomatik yaratilgan)", "",
          f"Jami element: **{len(items)}** — barchasi `NEEDS_REVIEW`. Muallif o‘z claim’ini tasdiqlay olmaydi.", "",
          "| Rol | Element | Har biriga kerakli review |", "|---|---|---|"]
    for r, n in by_role.most_common():
        md.append(f"| {r} | {n} | {REQUIRED[r]} |")
    md += ["", "| Tur | Soni |", "|---|---|"] + [f"| {k} | {n} |" for k, n in by_kind.most_common()]
    md += ["", "To‘liq ro‘yxat: `content/review/queue.csv` (jadval) va `queue.json`.",
           "Har bir qatorda: aniq manba (DOI/URL, bo‘lim), manbadan olingan asl jumla,",
           "taklif qilingan tuzilgan qiymat, domen, rol, litsenziya va holat bor.", "",
           "## Namuna (har roldan 3 ta)", ""]
    shown = collections.Counter()
    for it in items:
        if shown[it["role"]] >= 3:
            continue
        shown[it["role"]] += 1
        md.append(f"- **{it['role']}** · `{it['id']}` · {it['entity']} / {it['field']} — "
                  f"{(it.get('extracted_evidence') or '')[:160]} — manba: {it.get('doi') or it.get('url') or it.get('source_id')}")
    open("review/REVIEW_QUEUE.md", "w").write("\n".join(md) + "\n")
    print(len(items), dict(by_role), dict(by_kind))


if __name__ == "__main__":
    main()
