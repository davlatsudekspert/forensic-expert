#!/usr/bin/env python3
"""Pilot moddalar identifikatsiyasini PubChem PUG REST’dan oladi.

Natija: content/pilot/identity.generated.json
Har bir qiymat REAL so‘rovdan olinadi (qo‘lda yozilmaydi). Agar so‘rov
muvaffaqiyatsiz bo‘lsa yoki bir nechta CID qaytsa — yozuv `unresolved`
bo‘lib qoladi va reviewer’ga yuboriladi. Hech narsa taxmin qilinmaydi.
"""
import datetime, json, sys, time, urllib.parse, urllib.request

PILOT = [
    # (substance_id, PubChem so‘rov nomi, EN nom)
    ("ethanol", "ethanol", "Ethanol"),
    ("methanol", "methanol", "Methanol"),
    ("ethylene-glycol", "ethylene glycol", "Ethylene glycol"),
    ("morphine", "morphine", "Morphine"),
    ("heroin", "diamorphine", "Heroin (diacetylmorphine)"),
    ("6-mam", "6-monoacetylmorphine", "6-Monoacetylmorphine (6-MAM)"),
    ("fentanyl", "fentanyl", "Fentanyl"),
    ("tramadol", "tramadol", "Tramadol"),
    ("methamphetamine", "methamphetamine", "Methamphetamine"),
    ("cocaine", "cocaine", "Cocaine"),
    ("thc", "dronabinol", "Δ9-Tetrahydrocannabinol (THC)"),
    ("alprazolam", "alprazolam", "Alprazolam"),
    ("phenazepam", "phenazepam", "Phenazepam"),
    ("amitriptyline", "amitriptyline", "Amitriptyline"),
    ("paracetamol", "acetaminophen", "Paracetamol (acetaminophen)"),
    ("pregabalin", "pregabalin", "Pregabalin"),
    ("carbon-monoxide", "carbon monoxide", "Carbon monoxide"),
    ("chlorpyrifos", "chlorpyrifos", "Chlorpyrifos"),
    ("aluminium-phosphide", "aluminum phosphide", "Aluminium phosphide"),
    ("phosphine", "phosphine", "Phosphine"),
]

BASE = "https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound"
PROPS = "MolecularFormula,MolecularWeight,InChIKey,IUPACName"


def get(url):
    with urllib.request.urlopen(url, timeout=30) as r:
        return json.load(r)


def main():
    accessed = datetime.date.today().isoformat()
    out = []
    for sid, query, en in PILOT:
        q = urllib.parse.quote(query)
        rec = {"substance_id": sid, "query": query, "name_en": en,
               "accessed": accessed}
        try:
            cids = get(f"{BASE}/name/{q}/cids/JSON")["IdentifierList"]["CID"]
            rec["cids_returned"] = cids
            if len(cids) != 1:
                rec["status"] = "unresolved_multiple_cids"
            cid = cids[0]
            p = get(f"{BASE}/cid/{cid}/property/{PROPS}/JSON")
            p = p["PropertyTable"]["Properties"][0]
            rec.update({
                "pubchem_cid": cid,
                "molecular_formula": p.get("MolecularFormula"),
                "molecular_weight": p.get("MolecularWeight"),
                "inchikey": p.get("InChIKey"),
                "iupac_name": p.get("IUPACName"),
                "source_url": f"https://pubchem.ncbi.nlm.nih.gov/compound/{cid}",
            })
            rec.setdefault("status", "resolved")
        except Exception as e:  # noqa: BLE001
            rec["status"] = f"error: {e}"
        out.append(rec)
        time.sleep(0.3)  # PubChem: ≤ 5 so‘rov/s
    json.dump(out, open("pilot/identity.generated.json", "w"),
              ensure_ascii=False, indent=2)
    bad = [r for r in out if r["status"] != "resolved"]
    print(f"{len(out)} substances, {len(bad)} need attention")
    for r in bad:
        print(" ", r["substance_id"], r["status"], r.get("cids_returned"))


if __name__ == "__main__":
    sys.exit(main())
