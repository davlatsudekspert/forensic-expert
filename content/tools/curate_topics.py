#!/usr/bin/env python3
"""Qabul qilingan mavzu nomzodlariga metama’lumot (NCBI esummary) qo‘shib,
verify_excerpts.py formatiga o‘tkazadi: pilot/candidates/curated_topics.json"""
import glob, json, time, urllib.request

ESUMMARY = ("https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi"
            "?db=pmc&retmode=json&id={id}")


def main():
    cur = json.load(open("pilot/curation_p4.json"))
    accept = cur["accept"]
    out = []
    for path in sorted(glob.glob("pilot/candidates/topics_*.json")):
        for c in json.load(open(path)):
            if c.get("status") != "found" or c["topic"] not in accept:
                continue
            pmc = c["pmcid"][3:]
            for i in range(5):
                try:
                    with urllib.request.urlopen(ESUMMARY.format(id=pmc), timeout=60) as r:
                        res = json.load(r)["result"][pmc]
                    break
                except Exception:  # noqa: BLE001
                    time.sleep(2 ** (i + 1))
            ids = {a["idtype"]: a["value"] for a in res.get("articleids", [])}
            out.append(dict(
                substance=c["topic"], field=c["field"], status="found",
                pmcid=c["pmcid"], pmid=ids.get("pmid"), doi=ids.get("doi"),
                title=res.get("title"), journal=res.get("fulljournalname"),
                year=(res.get("pubdate") or "")[:4], license=c["license"],
                section=c.get("section") or "", verbatim_sentence=c["verbatim_sentence"],
                metabolites=c["key_terms"], note=accept[c["topic"]]))
            time.sleep(0.4)
    json.dump(out, open("pilot/candidates/curated_topics.json", "w"),
              ensure_ascii=False, indent=2)
    print(len(out), "curated")


if __name__ == "__main__":
    main()
