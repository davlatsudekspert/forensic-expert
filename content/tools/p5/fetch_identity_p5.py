#!/usr/bin/env python3
"""PHASE 5: ustuvor moddalar identifikatsiyasi — PubChem PUG REST.

Kirish: phase5/substances_priority.tsv
Chiqish: phase5/identity.json

* Nom → CID. Bir nechta CID qaytsa — `ambiguous` (reviewer hal qiladi),
  birinchi CID taxminan tanlanmaydi.
* Xossalar va SMILES — PubChem’dan (struktura rasmi shu SMILES’dan chiziladi).
* Sinonimlar — faqat PubChem ro‘yxatidan, kod/identifikatorlar filtrlanadi.
"""
import datetime, json, re, sys, urllib.parse

sys.path.insert(0, __file__.rsplit("/", 1)[0])
from fehttp import get  # noqa: E402

BASE = "https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound"
PROPS = "Title,MolecularFormula,MolecularWeight,InChIKey,IUPACName,SMILES"
BAD_SYN = re.compile(
    r"^\d+-\d+-\d$|UNII|CHEBI|DTXSID|DTXCID|SCHEMBL|CHEMBL|NSC|BRN|EINECS|"
    r"HSDB|CCRIS|AKOS|MFCD|ZINC|Tox21|NCGC|BIDD|BSPBio|KBio|SPECTRUM|Prestwick|"
    r"\(\+/-\)|\[|\]|;|^[A-Z0-9\-]{10,}$", re.I)


def load_list():
    rows = []
    for line in open("phase5/substances_priority.tsv", encoding="utf-8"):
        if line.startswith("#") or not line.strip():
            continue
        p = line.rstrip("\n").split("\t")
        p += [""] * (7 - len(p))
        rows.append(dict(id=p[0], query=p[1], group=p[2], en=p[3], ru=p[4],
                         uz=p[5], incb_name=p[6]))
    return rows


def main():
    accessed = datetime.date.today().isoformat()
    out = []
    for s in load_list():
        q = urllib.parse.quote(s["query"])
        rec = dict(s, accessed=accessed)
        try:
            cids = get(f"{BASE}/name/{q}/cids/JSON")["IdentifierList"]["CID"]
        except Exception as e:  # noqa: BLE001
            rec.update(status="unresolved", error=str(e))
            out.append(rec)
            print("UNRESOLVED", s["id"], e)
            continue
        if len(cids) != 1:
            rec.update(status="ambiguous", cids=cids[:10])
            print("AMBIGUOUS", s["id"], cids[:5])
            out.append(rec)
            continue
        cid = cids[0]
        p = get(f"{BASE}/cid/{cid}/property/{PROPS}/JSON")["PropertyTable"]["Properties"][0]
        syn = get(f"{BASE}/cid/{cid}/synonyms/JSON")["InformationList"]["Information"][0].get("Synonym", [])
        clean = []
        for x in syn[:60]:
            if len(x) > 40 or BAD_SYN.search(x):
                continue
            if x.lower() in {c.lower() for c in clean}:
                continue
            clean.append(x)
            if len(clean) >= 6:
                break
        rec.update(status="resolved", pubchem_cid=cid, title=p.get("Title"),
                   molecular_formula=p["MolecularFormula"],
                   molecular_weight=p["MolecularWeight"], inchikey=p["InChIKey"],
                   iupac_name=p.get("IUPACName"), smiles=p.get("SMILES"),
                   synonyms=clean,
                   source_url=f"https://pubchem.ncbi.nlm.nih.gov/compound/{cid}")
        out.append(rec)
    json.dump(out, open("phase5/identity.json", "w"), ensure_ascii=False, indent=1)
    st = {}
    for r in out:
        st[r["status"]] = st.get(r["status"], 0) + 1
    print(st)


if __name__ == "__main__":
    main()
