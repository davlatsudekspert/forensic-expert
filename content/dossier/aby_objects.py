#!/usr/bin/env python3
"""ABY yozuvlariga «Ob'ekt» maydonini qo'shish (qon / siydik / ichki a'zo …).

Nega kerak: ABY matnida ob'ekt aytilgan («10 ml siydik yoki qon»), lekin u
oddiy matn ichida edi — ekranda alohida ko'rinmasdi va filtrlab bo'lmasdi.
Ekspert xulosa yozayotganda birinchi bo'lib «qaysi ob'ektdan?» degan savolga
javob kerak.

Qoida: ob'ekt faqat ABY matnining o'zidan olinadi, taxmin qilinmaydi.
Matnda aytilmagan bo'lsa — `objects` bo'sh qoladi va `objects_stated: false`
yoziladi; ekranda «ABY matnida ob'ekt ko'rsatilmagan» deb turadi.

So'z chegarasi bilan qidiriladi: «qon» so'zi «qonun» ichida ham uchraydi.

Skript idempotent.
"""
import json
import re
import sys
from pathlib import Path

BUNDLE = Path(__file__).resolve().parents[2] / "content/pilot/bundle.json"

# ob'ekt → o'zbekcha shakllari (qo'shimchalar bilan)
PATTERNS = {
    "blood": r"\bqon(?:da|ni|ning|dan|ga|i|lar\w*)?\b",
    "urine": r"\bsiydik\w*\b",
    "liver": r"\bjigar\w*\b",
    "gastric": r"\bme[’']da\w*\b",
    "kidney": r"\bbuyrak\w*\b",
    "lung": r"\bo[‘']pka\w*\b",
    "hair": r"\bsoch\w*\b",
    "brain": r"\bmiya\w*\b",
    "muscle": r"\bmushak\w*\b",
    "bile": r"o[‘']t pufag\w*",
    "intestine": r"\bichak\w*\b",
    "trachea": r"\btraxeya\w*\b",
    "plasma": r"\bplazma\w*\b",
    "serum": r"\bzardob\w*\b",
    "saliva": r"\bso[‘']lak\w*\b",
    "semen": r"\bsperma\w*\b",
    "faeces": r"\bnajas\w*\b",
    "vomit": r"\bqusuq\w*\b",
    "organs": r"ichki a[’']zo\w*",
}


def main() -> int:
    b = json.loads(BUNDLE.read_text())
    stated = missing = 0
    for c in b["claims"]:
        if not c["claim_id"].startswith("C-ABY"):
            continue
        v = c["value"]
        st = v.get("statement")
        text = st.get("uz", "") if isinstance(st, dict) else (st or "")
        found = sorted(k for k, p in PATTERNS.items()
                       if re.search(p, text, re.IGNORECASE))
        v["objects"] = found
        v["objects_stated"] = bool(found)
        if found:
            stated += 1
        else:
            missing += 1
    BUNDLE.write_text(json.dumps(b, ensure_ascii=False, indent=1) + "\n")
    print(f"ABY yozuvlari: {stated} tasida ob'ekt ABY matnida aytilgan, "
          f"{missing} tasida aytilmagan (taxmin qilinmadi)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
