#!/usr/bin/env python3
"""Nomzod jumlalarni kuratsiya qilish.

1) Avtomatik filtr (qat’iy): hayvon / in vitro hayvon modellari, kalibrlash,
   LOD/LOQ, qo‘shilgan (spiked) namunalar, dozalash va farmakokinetik
   tajriba jumlalari konsentratsiya dalili sifatida qabul qilinmaydi.
2) Qo‘lda rad etish: phase5/curation_manual.json — {target: {"reject": [pmcid…], "reason": ...}}.
3) Har bir maqsad uchun birinchi o‘tgan nomzod tanlanadi.

Chiqish: phase5/curated_<name>.json va rad etilganlar ro‘yxati sabablari bilan.
"""
import json, re, sys

ANIMAL = re.compile(r"\b(rats?|mice|mouse|murine|dogs?|canine|pigs?|porcine|rabbits?|"
                    r"monkeys?|primates?|horses?|cattle|bovine|sheep|fish|zebrafish|larva[el]?|"
                    r"insects?|blowfl|maggots?|chicken|poultry|animals?)\b", re.I)
NOT_CASE = re.compile(r"\bLOD\b|\bLOQ\b|limits? of (detection|quantif)|calibrat|linear(ity)?|"
                      r"spiked|fortified|standard solution|recover(y|ies)|administered|"
                      r"\bdose[ds]?\b|mg/kg body|bioavailab|half-life|Cmax|t1/2|in vitro|"
                      r"cut-?off|cutoff|threshold", re.I)


def ok(field, s):
    if ANIMAL.search(s):
        return "animal"
    if field == "reported_concentration" and NOT_CASE.search(s):
        return "not_case_concentration"
    if field == "metabolism" and re.search(r"\bin vitro\b|microsom|hepatocyte", s, re.I):
        return None  # inson in vitro metabolizm — ruxsat (reviewer baholaydi)
    return None


def main():
    cand = json.load(open(sys.argv[1]))
    out_name = sys.argv[2]
    try:
        manual = json.load(open(sys.argv[3] if len(sys.argv) > 3 else "phase5/curation_manual.json"))
    except FileNotFoundError:
        manual = {}
    accepted, rejected = [], []
    for t in cand:
        rej_manual = set(manual.get(t["target"], {}).get("reject", []))
        chosen = None
        for c in t.get("candidates", []):
            why = ok(t["field"], c["sentence"])
            if c["pmcid"] in rej_manual:
                why = "manual: " + manual[t["target"]].get("reason", "")
            if why:
                rejected.append(dict(target=t["target"], pmcid=c["pmcid"], reason=why,
                                     sentence=c["sentence"]))
                continue
            if not c.get("doi") and not c.get("pmid"):
                rejected.append(dict(target=t["target"], pmcid=c["pmcid"],
                                     reason="no DOI/PMID", sentence=c["sentence"]))
                continue
            chosen = c
            break
        if chosen:
            accepted.append(dict(target=t["target"], entity=t["entity"], field=t["field"], **chosen))
        elif t["status"] == "found":
            pass
    json.dump(accepted, open(f"phase5/curated_{out_name}.json", "w"), ensure_ascii=False, indent=1)
    json.dump(rejected, open(f"phase5/rejected_{out_name}.json", "w"), ensure_ascii=False, indent=1)
    by = {}
    for a in accepted:
        by[a["field"]] = by.get(a["field"], 0) + 1
    print("accepted", len(accepted), by, "rejected", len(rejected))


if __name__ == "__main__":
    main()
