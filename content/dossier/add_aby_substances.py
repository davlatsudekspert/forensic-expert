#!/usr/bin/env python3
"""Simob, sirka kislotasi, ammiak — ABY mavzulari uchun yetishmayotgan moddalar.

ABY'da bu uch moddaning sud-kimyoviy aniqlash usuli bor, lekin ular
kutubxonada modda sifatida yo'q edi; shuning uchun ABY usuliga modda
sahifasidan borib bo'lmasdi.

Har bir qiymat PubChem PUG REST'dan JONLI olinadi (qo'lda yozilmaydi);
bitta CID qaytmasa — to'xtaydi. Struktura RDKit bilan PubChem SMILES'dan
chiziladi (mavjud `draw_structures.py` bilan bir xil sozlama).

Modda faqat identifikatsiya + ABY havolasi bilan kiradi. Tahlil, metabolit
yoki konsentratsiya YOZILMAYDI: manbasi yo'q narsa to'qilmaydi.

Skript idempotent.
"""
import datetime
import hashlib
import json
import sys
import urllib.parse
import urllib.request
from pathlib import Path

from rdkit import Chem
from rdkit.Chem import rdDepictor
from rdkit.Chem.Draw import rdMolDraw2D

ROOT = Path(__file__).resolve().parents[2]
BUNDLE = ROOT / "content/pilot/bundle.json"
STRUCT_DIR = ROOT / "content/phase5/images/structures"
TODAY = datetime.date.today().isoformat()

# id, PubChem nomi, guruh, (en, ru, uz), ABY mavzusi
SUBSTANCES = [
    ("mercury", "mercury", "metals_inorganic",
     ("Mercury", "Ртуть", "Simob"), "aby-tox-mercury"),
    ("acetic-acid", "acetic acid", "alcohols_volatiles",
     ("Acetic acid", "Уксусная кислота", "Sirka kislotasi"),
     "aby-tox-acetic-acid"),
    ("ammonia", "ammonia", "toxic_gases",
     ("Ammonia", "Аммиак", "Ammiak"), "aby-tox-ammonia"),
]
ABY_ALL = ["aby-tox-urine-express", "aby-tox-isolation-methods"]


def get(url):
    with urllib.request.urlopen(url, timeout=30) as r:
        return json.loads(r.read())


def pubchem(name):
    q = urllib.parse.quote(name)
    base = "https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound"
    cids = get(f"{base}/name/{q}/cids/JSON")["IdentifierList"]["CID"]
    if len(cids) != 1:
        raise SystemExit(f"{name}: bitta CID emas: {cids}")
    cid = cids[0]
    props = get(f"{base}/cid/{cid}/property/MolecularFormula,MolecularWeight,"
                f"InChIKey,IUPACName,SMILES/JSON")["PropertyTable"]["Properties"][0]
    smiles = props.get("SMILES") or props.get("CanonicalSMILES")
    if not smiles:
        raise SystemExit(f"{name}: SMILES yo'q")
    return cid, props, smiles


def draw(smiles, path):
    mol = Chem.MolFromSmiles(smiles)
    if mol is None:
        raise SystemExit(f"SMILES o'qilmadi: {smiles}")
    d = rdMolDraw2D.MolDraw2DCairo(640, 440)
    o = d.drawOptions()
    o.clearBackground = False
    o.bondLineWidth = 2
    o.fixedFontSize = 26
    o.padding = 0.08
    o.useBWAtomPalette()
    rdDepictor.Compute2DCoords(mol)
    rdMolDraw2D.PrepareAndDrawMolecule(d, mol)
    d.FinishDrawing()
    png = d.GetDrawingText()
    path.write_bytes(png)
    return hashlib.sha256(png).hexdigest()


def main() -> int:
    b = json.loads(BUNDLE.read_text())
    have_sub = {s["substance_id"] for s in b["substances"]}
    have_src = {s["source_id"] for s in b["sources"]}
    have_claim = {c["claim_id"] for c in b["claims"]}
    have_img = {i["image_id"] for i in b["images"]}
    have_link = {(l["from"], l["to"], l["relation"]) for l in b["links"]}
    topics = {t["topic_id"] for t in b["topics"]}
    STRUCT_DIR.mkdir(parents=True, exist_ok=True)
    added = 0
    for sid, pname, group, (en, ru, uz), aby in SUBSTANCES:
        if aby not in topics:
            raise SystemExit(f"{aby} mavzusi bazada yo'q")
        if sid in have_sub:
            continue
        cid, p, smiles = pubchem(pname)
        formula = p["MolecularFormula"]
        b["substances"].append({
            "substance_id": sid, "canonical_name": sid,
            "entity_kind": "substance", "molecular_formula": formula,
            "tier_access": "pro", "group": group,
            "names": {"en": en, "ru": ru, "uz": uz},
            "translation_status": {k: "machine_draft"
                                   for k in ("en", "ru", "uz")},
            "synonyms": [],
        })
        src = f"SRC-PUBCHEM-{cid}"
        if src not in have_src:
            b["sources"].append({
                "source_id": src, "source_type": "database",
                "title": f"PubChem Compound Summary for CID {cid} ({en})",
                "organization": "National Center for Biotechnology "
                                "Information (NCBI), U.S. National Library "
                                "of Medicine",
                "official_url": f"https://pubchem.ncbi.nlm.nih.gov/compound/{cid}",
                "accessed_date": TODAY, "tier": "tier2",
                "evidence_level": "C", "license_mode": "openReuse",
                "identifier_verified": True,
                "notes": "PubChem PUG REST orqali avtomatik; bitta CID. "
                         "Reviewer tasdig'ini talab qiladi.",
            })
        cid_claim = f"C-{sid.upper()}-IDENTITY"
        if cid_claim not in have_claim:
            b["claims"].append({
                "claim_id": cid_claim, "entity_type": "substance",
                "entity_id": sid, "field": "identity", "domain": "tox",
                "declared_status": "NEEDS_REVIEW", "evidence_level": "C",
                "layer": "international_scientific",
                "is_structured_value": True,
                "value": {
                    "pubchem_cid": cid, "molecular_formula": formula,
                    "molecular_weight": str(p["MolecularWeight"]),
                    "inchikey": p["InChIKey"],
                    "iupac_name": p["IUPACName"],
                },
            })
            b["citations"].append({"claim_id": cid_claim, "source_id": src,
                                   "locator": "Computed Properties"})
        img = f"IMG-STRUCT-{sid}"
        if img not in have_img:
            path = STRUCT_DIR / f"{sid}.png"
            sha = draw(smiles, path)
            b["images"].append({
                "image_id": img, "kind": "chemical_structure",
                "entity_id": sid,
                "file": f"../phase5/images/structures/{sid}.png",
                "sha256": sha,
                "title": {"en": f"Chemical structure: {en}",
                          "ru": f"Химическая структура: {ru}",
                          "uz": f"Kimyoviy tuzilishi: {uz}"},
                "alt": {"en": f"2D chemical structure diagram of {en} ({formula})",
                        "ru": f"Двумерная структурная формула: {ru}",
                        "uz": f"Ikki o‘lchamli struktura formulasi: {uz}"},
                "license": "original_depiction_of_factual_data",
                "attribution": f"Structure drawn from PubChem CID {cid} "
                               "SMILES with RDKit",
                "is_original_diagram": True,
                "represents_real_data": False,
                "creator": "FORENSIC EXPERT content pipeline (RDKit depiction)",
                "source_name": "PubChem (structure data: SMILES)",
                "source_url": f"https://pubchem.ncbi.nlm.nih.gov/compound/{cid}",
                "accessed_date": TODAY,
            })
        for t in [aby] + ABY_ALL:
            if (sid, t, "related_topic") not in have_link:
                b["links"].append({"from": sid, "to": t,
                                   "relation": "related_topic",
                                   "basis": "editorial:aby-order"})
        # ABY mavzusidan modda sahifasiga qaytish bog'lamasi ham shu yo'nalishda
        added += 1
        print(f"  + {sid}: CID {cid}, {formula}")
    BUNDLE.write_text(json.dumps(b, ensure_ascii=False, indent=1) + "\n")
    print(f"qo'shildi: {added} modda")
    return 0


if __name__ == "__main__":
    sys.exit(main())
