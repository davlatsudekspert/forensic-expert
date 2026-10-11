#!/usr/bin/env python3
"""Qolgan ABY mavzularini o'z joyiga bog'lash (boshqa bo'limlar).

39 ta ABY mavzusidan 32 tasi hech qayerga bog'lanmagan edi: ularga faqat
qidiruv orqali tushish mumkin, kerakli modda yoki mavzu sahifasidan emas.

Bog'lash faqat aniq moslikda. Moddasi yoki mavzusi bazada yo'q ABY yozuvi
bog'lanmaydi — o'rniga boshqasi qo'yilmaydi.

Skript idempotent.
"""
import json
import sys
from pathlib import Path

BUNDLE = Path(__file__).resolve().parents[2] / "content/pilot/bundle.json"
BASIS = "editorial:aby-order"

# ABY mavzusi → shu mavzu tegishli bo'lgan yozuvlar (modda yoki mavzu)
MAP = {
    # Toksikologiya — aniq modda
    "aby-tox-diphenhydramine": ["diphenhydramine"],
    "aby-tox-hydrogen-sulfide": ["hydrogen-sulfide"],
    # Fosfororganik birikmalar — ABY shu sinfni qamraydi
    "aby-tox-organophosphates": [
        "chlorpyrifos", "diazinon", "malathion", "parathion",
    ],
    # Fenotiazinlar — ABY shu sinfni qamraydi (xlorpromazin)
    "aby-tox-phenothiazines": ["chlorpromazine"],
    # Sulfonilmochevina hosilalari — bazada metformin biguanid, mos emas:
    # aniq modda yo'q, bog'lanmaydi.
    # Metalli zaharlar — mineralizatsiya ABY usuli
    "aby-tox-metals": ["arsenic-trioxide", "thallium-sulfate"],
    # Sud tibbiyoti mavzulari
    "aby-fm-strangulation": ["fm-asphyxia"],
    "aby-fm-bone-sex": ["fm-anthropology"],
    "aby-fm-bone-age": ["fm-age-estimation"],
    "aby-fm-bone-stature": ["fm-stature-estimation"],
    "aby-fm-photo-identification": ["fm-anthropology"],
    "aby-fm-supravital": ["fm-postmortem-interval"],
    "aby-fm-autopsy-technique": ["fm-death-investigation"],
    "aby-fm-clothing-gunshot": ["fm-firearm"],
    # Gistologiya
    "aby-his-fixation": ["his-fixation"],
    "aby-his-diatoms": ["fm-drowning"],
    # Biologiya
    "aby-bio-blood-presence": ["gen-str-profiling"],
    "aby-bio-hair": ["fm-anthropology"],
}


def main() -> int:
    b = json.loads(BUNDLE.read_text())
    known = ({s["substance_id"] for s in b["substances"]}
             | {t["topic_id"] for t in b["topics"]})
    missing = [t for t in MAP if t not in known]
    missing += [x for v in MAP.values() for x in v if x not in known]
    if missing:
        print("XATO: bazada yo'q:", sorted(set(missing)))
        return 1
    have = {(l["from"], l["to"], l["relation"]) for l in b["links"]}
    added = 0
    for topic, targets in MAP.items():
        for t in targets:
            if (t, topic, "related_topic") not in have:
                b["links"].append({
                    "from": t, "to": topic,
                    "relation": "related_topic", "basis": BASIS,
                })
                have.add((t, topic, "related_topic"))
                added += 1
    BUNDLE.write_text(json.dumps(b, ensure_ascii=False, indent=1) + "\n")
    to = {}
    for l in b["links"]:
        to[l["to"]] = to.get(l["to"], 0) + 1
    aby = [t["topic_id"] for t in b["topics"]
           if t["topic_id"].startswith("aby-")]
    orphan = [t for t in aby if not to.get(t)]
    print(f"+{added} bog'lama; bog'lanmagan ABY mavzusi: {len(orphan)}")
    for t in orphan:
        print("   ", t)
    return 0


if __name__ == "__main__":
    sys.exit(main())
