#!/usr/bin/env python3
"""PHASE 7: reviewer paketlari (review packets) — pilot doirasi.

Har bir paket bitta tekshiriladigan obyekt uchun: claim, manba (tier,
qayta foydalanish, hayot sikli), iqtibos va uning joyi, nima uchun muhim,
ziddiyatlar, taklif qilingan qiymat, cheklovlar, tarjimalar, joriy holat,
kerakli reviewer roli va ruxsat etilgan harakatlar.

Paket — reviewer uchun ish varag‘i, tasdiq emas. Harakat (APPROVE / REJECT /
REQUEST_CHANGE / FLAG_CONFLICT / FLAG_OUTDATED) faqat haqiqiy, ro‘yxatdagi
reviewer tomonidan yoziladi; bu skript hech qanday harakat yozmaydi.

Chiqish: review/packets/index.json, review/packets/<role>/<id>.json,
         review/packets/README.md
"""
import collections, json, os, shutil

import assemble_p7 as p7

ROLE = {"tox": "forensic_toxicology", "fm": "forensic_medicine",
        "lab": "laboratory_analytical", "legal": "legal_jurisdiction",
        "i18n": "translation", "edu": "scientific_editor"}
REQUIRED = {"forensic_toxicology": 2, "forensic_medicine": 2, "laboratory_analytical": 2,
            "forensic_biochemistry": 2, "legal_jurisdiction": 1, "translation": 1}
ACTIONS = ["APPROVE", "REJECT", "REQUEST_CHANGE", "FLAG_CONFLICT", "FLAG_OUTDATED"]

WHY = {
    "reported_concentration": "Concentration values are often misread as thresholds; the reviewer must confirm specimen, population, statistic and that the value is reported in context only.",
    "metabolites": "Metabolite identity drives which analyte is targeted and how a finding is interpreted.",
    "metabolism_note": "Metabolic pathway statements support interpretation of parent/metabolite findings.",
    "identity": "Identifiers (formula, InChIKey, CID) anchor every other record about the substance.",
    "analytical_method": "Links the substance to an analytical technique; does not imply a validated method for any laboratory.",
    "definition": "Definitions are shown to students and practitioners as the canonical meaning of the term.",
    "limitation": "Limitations prevent over-interpretation of a finding.",
    "marker": "A marker claim can be used to support time-since-death or exposure reasoning.",
    "use": "Describes when a specimen is used; affects sampling advice.",
    "detection_window": "Detection windows affect the interpretation of negative results.",
    "control_status": "Legal status depends on jurisdiction and date; must be checked against the official text.",
}


def main():
    b = json.load(open("pilot/bundle.json"))
    src = {s["source_id"]: s for s in b["sources"]}
    cit = collections.defaultdict(list)
    for c in b["citations"]:
        cit[c["claim_id"]].append(c)
    names = {s["substance_id"]: s["names"] for s in b["substances"]}
    names.update({t["topic_id"]: t["names"] for t in b["topics"]})
    names.update({s["specimen_id"]: s["names"] for s in b["specimens"]})
    conflicts = collections.defaultdict(list)
    for k in b["conflicts"]:
        for cid in k["claim_ids"]:
            conflicts[cid].append(dict(conflict_id=k["conflict_id"], kind=k["kind"],
                                       question=k["question"], note=k["note"]))
    scope = set(p7.PILOT + p7.PILOT_METABOLITES + [s["specimen_id"] for s in b["specimens"]]
                + ["fm-rigor-mortis", "fm-algor-mortis", "fm-livor-mortis",
                   "fm-postmortem-changes", "fm-postmortem-interval", "fm-blunt-trauma",
                   "fm-decomposition", "bio-vitreous-potassium", "bio-vitreous-glucose",
                   "bio-ethanol-neoformation", "bio-cocaine-stability", "bio-sampling-site"])
    for k in b["conflicts"]:
        scope.add(k["entity_id"])

    out = "review/packets"
    shutil.rmtree(out, ignore_errors=True)
    index = []

    def emit(p):
        d = os.path.join(out, p["required_role"])
        os.makedirs(d, exist_ok=True)
        json.dump(p, open(os.path.join(d, p["packet_id"] + ".json"), "w"),
                  ensure_ascii=False, indent=2)
        index.append({k: p[k] for k in ("packet_id", "subject_id", "kind", "entity_id",
                                        "field", "required_role", "required_reviews",
                                        "status", "lifecycle", "has_conflict")})

    for c in b["claims"]:
        if c["entity_id"] not in scope:
            continue
        role = ROLE[c["domain"]]
        if c["entity_id"].startswith("bio-"):
            role = "forensic_biochemistry"
        if c["field"] == "analytical_method":
            role = "laboratory_analytical"
        sources = []
        lifecycle = "NEEDS_REVIEW"
        for ci in cit[c["claim_id"]]:
            s = src[ci["source_id"]]
            if s.get("lifecycle") in ("retracted", "withdrawn"):
                lifecycle = "RETRACTED"
            sources.append(dict(
                source_id=s["source_id"], title=s["title"], type=s["source_type"],
                doi=s.get("doi"), pmid=s.get("pmid"), url=s.get("official_url"),
                tier={"tier1": "A", "tier2": "B", "tier3": "C"}.get(s["tier"]),
                evidence_level=s["evidence_level"], license_mode=s["license_mode"],
                lifecycle=s.get("lifecycle", "current"),
                lifecycle_basis=s.get("lifecycle_basis"), locator=ci.get("locator")))
        v = dict(c["value"])
        excerpt = v.pop("excerpt", None)
        ctx = v.pop("context_strict", None)
        packet = dict(
            packet_id=f"P-{c['claim_id']}", subject_id=c["claim_id"], kind="claim",
            subject_version=c.get("version", 1), entity_id=c["entity_id"],
            entity_names=names.get(c["entity_id"]), field=c["field"], domain=c["domain"],
            required_role=role, required_reviews=REQUIRED.get(role, 1),
            allowed_actions=ACTIONS, status=c["declared_status"], lifecycle=lifecycle,
            claim=dict(excerpt=excerpt, location=v.get("section"), proposed_value=v),
            sources=sources, why_it_matters=WHY.get(c["field"], "Shown to users as sourced evidence."),
            conflicts=conflicts.get(c["claim_id"], []), has_conflict=c["claim_id"] in conflicts,
            limitations=(ctx or {}).get("limitations", []),
            concentration_context=ctx,
            translations=dict(entity_names=names.get(c["entity_id"]),
                              status="machine_draft (RU/UZ) — translation reviewer required"),
            reviewer_checklist=[
                "Excerpt matches the source at the stated location.",
                "Proposed value says no more than the excerpt.",
                "Source is current (not retracted/superseded) and the licence allows this use.",
                "Context and limitations are complete; nothing is presented as a threshold.",
                "Conflicts listed are fairly described.",
            ],
            review_actions=[])
        if lifecycle == "RETRACTED":
            packet["reviewer_checklist"].insert(0, "SOURCE RETRACTED: decide REJECT or replacement source; claim must not be shown as current.")
        emit(packet)

    for r in b["rules"]:
        if r["subject_id"] not in scope or r["instrument_id"].startswith("INT-"):
            continue
        emit(dict(
            packet_id=f"P-{r['rule_id']}", subject_id=r["rule_id"], kind="legal_rule",
            subject_version=r.get("version", 1), entity_id=r["subject_id"],
            entity_names=names.get(r["subject_id"]), field=r["rule_type"], domain="legal",
            required_role="legal_jurisdiction", required_reviews=1,
            allowed_actions=ACTIONS, status=r["review_status"], lifecycle="NEEDS_REVIEW",
            claim=dict(excerpt=r["value"].get("entry_text") or r["value"].get("excerpt"),
                       location=r.get("article_section"), proposed_value=r["value"]),
            sources=[dict(instrument_id=r["instrument_id"])],
            why_it_matters=WHY["control_status"], conflicts=[], has_conflict=False,
            limitations=["NEEDS LEGAL REVIEW — not legal advice.",
                         "Exact list-entry match only; generic or class clauses are not evaluated."],
            concentration_context=None, translations=None,
            reviewer_checklist=["Entry exists in the official consolidated text on the review date.",
                                "Schedule/class is correct and in force.",
                                "Exceptions or preparations clauses do not change the status."],
            review_actions=[]))

    os.makedirs(out, exist_ok=True)
    json.dump(dict(generated_from=b["pack_version"], human_reviewers=0,
                   review_actions=0, packets=len(index), items=index),
              open(os.path.join(out, "index.json"), "w"), ensure_ascii=False, indent=2)
    by_role = collections.Counter(i["required_role"] for i in index)
    with open(os.path.join(out, "README.md"), "w") as f:
        f.write("# Review packets — PHASE 7 pilot\n\n")
        f.write(f"Pack {b['pack_version']}. Packets: **{len(index)}**. "
                "Human reviewers: **0**. Review actions recorded: **0**.\n\n")
        f.write("Packets are worksheets for qualified reviewers. Nothing here is approved. "
                "Status changes only through real reviewer actions (see docs/27).\n\n")
        f.write("| Role | Packets | Required reviews |\n|---|---|---|\n")
        for role, n in sorted(by_role.items()):
            f.write(f"| {role} | {n} | {REQUIRED.get(role, 1)} |\n")
        f.write(f"\nWith EVIDENCE CONFLICT: {sum(i['has_conflict'] for i in index)}. "
                f"RETRACTED source: {sum(i['lifecycle'] == 'RETRACTED' for i in index)}.\n")
    print(dict(by_role), "conflicts:", sum(i["has_conflict"] for i in index))


if __name__ == "__main__":
    main()
