#!/usr/bin/env python3
"""Kimyoviy struktura tasvirlari — PubChem SMILES’dan RDKit bilan chiziladi.

* Bu ORIGINAL depiksiya (faktik ma’lumot — SMILES — asosida); tashqi rasm
  ko‘chirilmaydi, litsenziya noaniqligi yo‘q.
* Qora chiziq, shaffof fon — ilovada oq «namuna kartochkasi» ustida
  ko‘rsatiladi (light/dark ikkala rejimda o‘qiladi).
* Stereokimyo SMILES’da bo‘lsa — saqlanadi.

Chiqish: phase5/images/structures/<id>.png + phase5/images_structures.json
"""
import hashlib, json

from rdkit import Chem
from rdkit.Chem import rdDepictor
from rdkit.Chem.Draw import rdMolDraw2D

# Ko‘prikli polisikllar (morfinanlar, kokain) uchun aniqroq 2D joylashuv.
rdDepictor.SetPreferCoordGen(True)


def main():
    ident = json.load(open("phase5/identity.json"))
    meta = []
    for s in ident:
        smi = s.get("smiles")
        mol = Chem.MolFromSmiles(smi) if smi else None
        if mol is None:
            print("skip", s["id"])
            continue
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
        path = f"phase5/images/structures/{s['id']}.png"
        open(path, "wb").write(png)
        meta.append(dict(
            image_id=f"IMG-STRUCT-{s['id']}", kind="chemical_structure",
            entity_id=s["id"], file=path, sha256=hashlib.sha256(png).hexdigest(),
            width=640, height=440,
            title={"en": f"Chemical structure: {s['en']}"},
            alt={"en": f"2D chemical structure diagram of {s['en']} "
                       f"({s['molecular_formula']})"},
            creator="FORENSIC EXPERT content pipeline (RDKit depiction)",
            source_name="PubChem (structure data: SMILES)",
            source_url=s["source_url"], license="original_depiction_of_factual_data",
            attribution=f"Structure drawn from PubChem CID {s['pubchem_cid']} SMILES with RDKit",
            is_original_diagram=True, represents_real_data=False,
            accessed=s["accessed"]))
    json.dump(meta, open("phase5/images_structures.json", "w"), ensure_ascii=False, indent=1)
    print(len(meta), sum(len(open(m["file"], "rb").read()) for m in meta) // 1024, "KB")


if __name__ == "__main__":
    main()
