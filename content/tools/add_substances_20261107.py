#!/usr/bin/env python3
"""Yangi moddalar (2026-11-07): manbalarda tekshirish usuli bor, lekin kutubxonada yo‘q edi.

Commit f40d3357 dagi to‘rt manba (ketamin 2023, YuSSX 2023, «Анализ наркотических
веществ II» 2023, bioob’ektdan ajratish 2024) barbital, barbamil, butobarbital, geksenal,
benzonal, dipazin, tizersin, xlordiazepoksid, nitrazepam, ergot alkaloidlari, piretroidlar va
neonikotinoidlar uchun usul beradi, lekin bu moddalar bundle.json da yo‘q edi — usullar
tushirib qoldirilgan edi. Egasi ularni qo‘shishga rozilik bergan (2026-11-07).

Identifikatsiya (formula, molekulyar massa, InChIKey, IUPAC nomi) PubChem PUG REST'dan
JONLI olinadi — repo'da 140 moddaning barchasi shu yo‘l bilan (SRC-PUBCHEM-<CID>); bitta
CID qaytmasa skript to‘xtaydi. Struktura RDKit bilan PubChem SMILES'dan chiziladi
(add_aby_substances.py / draw_structures.py sozlamasi). CAS raqami sxemada yo‘q va
yozilmaydi; huquqiy (nazorat ro‘yxati) holati yozilmaydi — repo'da O‘zbekiston ro‘yxatining
manbali jadvali yo‘q.

Sinonimlar faqat manba matnidagi nomlar (masalan, «Барбамил», «Тизерцин», «Детсис») va
xalqaro nomlar; savdo/eski nom → INN moslashuvi PubChem nom qidiruvi bilan tekshirilgan
(barbamyl → 2164, benzonal → 12938, diprazine → 4927, tizertsin → 72287, chlozepid → 2712,
decis → 40585, danitol → 47326). «Гексенал = гексобарбитал» — manbaning o‘zida
(«Анализ…II», 15-bet: «(гексенал, гексобарбитал)»).

Usullar bu yerda YOZILMAYDI: ular substance_methods_data7.py da va
build_substance_methods.py tomonidan quriladi. Skript idempotent (bor moddani o‘tkazib
yuboradi). Ishga tushirish tartibi: shu skript → build_substance_methods.py.
"""
import datetime
import hashlib
import json
import sys
import urllib.parse
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BUNDLE = ROOT / "content/pilot/bundle.json"
STRUCT_DIR = ROOT / "content/phase5/images/structures"
TODAY = datetime.date.today().isoformat()

# id, PubChem nomi, kutilgan CID, guruh, (en, ru, uz), sinonimlar
SUBSTANCES = [
    ("barbital", "barbital", 2294, "barbiturates",
     ("Barbital", "Барбитал", "Barbital"), []),
    ("amobarbital", "amobarbital", 2164, "barbiturates",
     ("Amobarbital", "Амобарбитал", "Amobarbital"), ["barbamil", "barbamyl", "Барбамил"]),
    ("butobarbital", "butobarbital", 6473, "barbiturates",
     ("Butobarbital", "Бутобарбитал", "Butobarbital"), []),
    ("hexobarbital", "hexobarbital", 3608, "barbiturates",
     ("Hexobarbital", "Гексобарбитал", "Geksobarbital"), ["geksenal", "hexenal", "Гексенал"]),
    ("benzobarbital", "benzobarbital", 12938, "barbiturates",
     ("Benzobarbital", "Бензобарбитал", "Benzobarbital"), ["benzonal", "Бензонал"]),
    ("promethazine", "promethazine", 4927, "pharmaceuticals",
     ("Promethazine", "Прометазин", "Prometazin"), ["diprazin", "diprazine", "Дипразин"]),
    ("levomepromazine", "levomepromazine", 72287, "antipsychotics",
     ("Levomepromazine", "Левомепромазин", "Levomepromazin"),
     ["tizersin", "tisercin", "Тизерцин", "methotrimeprazine"]),
    ("chlordiazepoxide", "chlordiazepoxide", 2712, "benzodiazepines",
     ("Chlordiazepoxide", "Хлордиазепоксид", "Xlordiazepoksid"), ["xlozepid", "chlozepid", "Хлозепид"]),
    ("nitrazepam", "nitrazepam", 4506, "benzodiazepines",
     ("Nitrazepam", "Нитразепам", "Nitrazepam"), []),
    ("ergotamine", "ergotamine", 8223, "pharmaceuticals",
     ("Ergotamine", "Эрготамин", "Ergotamin"), []),
    ("ergometrine", "ergometrine", 443884, "pharmaceuticals",
     ("Ergometrine", "Эргометрин", "Ergometrin"), ["ergonovine"]),
    ("cypermethrin", "cypermethrin", 2912, "pesticides",
     ("Cypermethrin", "Циперметрин", "Sipermetrin"), ["tsipermetrin", "Тсиперметрин"]),
    ("deltamethrin", "deltamethrin", 40585, "pesticides",
     ("Deltamethrin", "Дельтаметрин", "Deltametrin"), ["Decis", "Detsis", "Детсис"]),
    ("fenpropathrin", "fenpropathrin", 47326, "pesticides",
     ("Fenpropathrin", "Фенпропатрин", "Fenpropatrin"), ["Danitol", "Данитол"]),
    ("imidacloprid", "imidacloprid", 86287518, "pesticides",
     ("Imidacloprid", "Имидаклоприд", "Imidakloprid"), []),
    ("acetamiprid", "acetamiprid", 213021, "pesticides",
     ("Acetamiprid", "Ацетамиприд", "Atsetamiprid"), ["asetamiprid"]),
]


def get(url):
    with urllib.request.urlopen(url, timeout=30) as r:
        return json.loads(r.read())


def pubchem(name, expected):
    q = urllib.parse.quote(name)
    base = "https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound"
    cids = get(f"{base}/name/{q}/cids/JSON")["IdentifierList"]["CID"]
    if cids != [expected]:
        raise SystemExit(f"{name}: kutilgan CID {expected}, PubChem: {cids}")
    props = get(f"{base}/cid/{expected}/property/MolecularFormula,MolecularWeight,"
                f"InChIKey,IUPACName,SMILES/JSON")["PropertyTable"]["Properties"][0]
    smiles = props.get("SMILES") or props.get("CanonicalSMILES")
    if not smiles:
        raise SystemExit(f"{name}: SMILES yo'q")
    return props, smiles


def draw(smiles, path):
    from rdkit import Chem
    from rdkit.Chem import rdDepictor
    from rdkit.Chem.Draw import rdMolDraw2D
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
    b = json.loads(BUNDLE.read_text(encoding="utf-8"))
    have_sub = {s["substance_id"] for s in b["substances"]}
    have_src = {s["source_id"] for s in b["sources"]}
    have_claim = {c["claim_id"] for c in b["claims"]}
    have_img = {i["image_id"] for i in b["images"]}
    STRUCT_DIR.mkdir(parents=True, exist_ok=True)
    added = 0
    for sid, pname, cid, group, (en, ru, uz), syn in SUBSTANCES:
        if sid in have_sub:
            continue
        p, smiles = pubchem(pname, cid)
        formula = p["MolecularFormula"]
        b["substances"].append({
            "substance_id": sid, "canonical_name": sid,
            "entity_kind": "substance", "molecular_formula": formula,
            "tier_access": "pro", "group": group,
            "names": {"en": en, "ru": ru, "uz": uz},
            "translation_status": {k: "machine_draft" for k in ("en", "ru", "uz")},
            "synonyms": syn,
        })
        src = f"SRC-PUBCHEM-{cid}"
        if src not in have_src:
            b["sources"].append({
                "source_id": src, "source_type": "database",
                "title": f"PubChem Compound Summary for CID {cid} ({en})",
                "organization": "National Center for Biotechnology Information (NCBI), "
                                "U.S. National Library of Medicine",
                "official_url": f"https://pubchem.ncbi.nlm.nih.gov/compound/{cid}",
                "accessed_date": TODAY, "tier": "tier2",
                "evidence_level": "C", "license_mode": "openReuse",
                "identifier_verified": True,
                "notes": "PubChem PUG REST orqali avtomatik; bitta CID. "
                         "Reviewer tasdig'ini talab qiladi.",
            })
            have_src.add(src)
        claim = f"C-{sid.upper()}-IDENTITY"
        if claim not in have_claim:
            b["claims"].append({
                "claim_id": claim, "entity_type": "substance",
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
            b["citations"].append({"claim_id": claim, "source_id": src,
                                   "locator": "Computed Properties"})
        img = f"IMG-STRUCT-{sid}"
        if img not in have_img:
            sha = draw(smiles, STRUCT_DIR / f"{sid}.png")
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
                "attribution": f"Structure drawn from PubChem CID {cid} SMILES with RDKit",
                "is_original_diagram": True,
                "represents_real_data": False,
                "creator": "FORENSIC EXPERT content pipeline (RDKit depiction)",
                "source_name": "PubChem (structure data: SMILES)",
                "source_url": f"https://pubchem.ncbi.nlm.nih.gov/compound/{cid}",
                "accessed_date": TODAY,
            })
        added += 1
        print(f"  + {sid}: CID {cid}, {formula}")
    BUNDLE.write_text(json.dumps(b, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(f"qo'shildi: {added} modda")
    return 0


if __name__ == "__main__":
    sys.exit(main())
