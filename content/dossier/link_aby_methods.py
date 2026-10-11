#!/usr/bin/env python3
"""ABY usullarini tegishli modda guruhlariga bog'lash.

Muammo: ABY'ning sud-kimyoviy aniqlash usullari ilovada bor, lekin ularga
bog'langan modda nol edi. Fenazepam kartasida ABY'ning 1,4-benzodiazepinlarni
benzofenonlar orqali aniqlash usuli ko'rinmasdi — holbuki fenazepam aynan
1,4-benzodiazepin.

Bog'lash faqat ABY matnining o'zi qamrab olgan guruhlar bo'yicha; shubhali
guruh bog'lanmaydi.

Skript idempotent.
"""
import json
import sys
from pathlib import Path

BUNDLE = Path(__file__).resolve().parents[2] / "content/pilot/bundle.json"

# modda guruhi → ABY mavzusi (faqat ABY matni aniq qamragan guruhlar)
BY_GROUP = {
    "opioids": "aby-tox-opiates",
    "barbiturates": "aby-tox-barbiturates",
    "benzodiazepines": "aby-tox-benzodiazepines",
    "cannabinoids": "aby-tox-cannabinoids",
    "metals_inorganic": "aby-tox-metals",
}

# ABY tartibining birinchi bosqichlari — har qanday moddaga tegishli:
# dastlabki ekspress tekshiruv va ajratib olish usullari.
FOR_ALL = ["aby-tox-urine-express", "aby-tox-isolation-methods"]

BASIS = "editorial:aby-order"


def main() -> int:
    b = json.loads(BUNDLE.read_text())
    topics = {t["topic_id"] for t in b["topics"]}
    for t in set(BY_GROUP.values()) | set(FOR_ALL):
        if t not in topics:
            print(f"XATO: {t} mavzusi bazada yo'q")
            return 1
    have = {(l["from"], l["to"], l["relation"]) for l in b["links"]}
    added = 0

    def link(frm, to):
        nonlocal added
        if (frm, to, "related_topic") not in have:
            b["links"].append({
                "from": frm, "to": to,
                "relation": "related_topic", "basis": BASIS,
            })
            have.add((frm, to, "related_topic"))
            added += 1

    per_group = 0
    for s in b["substances"]:
        sid = s["substance_id"]
        for t in FOR_ALL:
            link(sid, t)
        topic = BY_GROUP.get(s.get("group"))
        if topic:
            before = added
            link(sid, topic)
            per_group += added - before
    BUNDLE.write_text(json.dumps(b, ensure_ascii=False, indent=1) + "\n")
    print(f"bog'lamalar: {added} ta qo'shildi "
          f"(guruh bo'yicha {per_group}, qolgani ABY tartibining 1–2 bosqichi)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
