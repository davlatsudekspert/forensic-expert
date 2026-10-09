"""Yo‘riqnoma kartasi → «Ilmiy lug‘at» atamalari: `term_ids` qatorini
`content/guidelines/src/card_*.json` fayllariga yozadi (umumiy yordamchi).

Bog‘lanish ANIQ (xaritadan), matndan taxmin qilinmaydi. Kartalar qo‘lda
formatlangan JSON — faqat bitta `"term_ids": [...]` qatori almashtiriladi
(`related_tool_ids` qatoridan keyin). Idempotent.

Foydalanuvchilar: `toks_terms.py` (T-TOKS-*), `gmt_card_terms.py` (T-GMT-*).
"""
import json
import pathlib
import re

ROOT = pathlib.Path(__file__).resolve().parents[2]
CARDS = ROOT / "content/guidelines/src"
BUNDLE = ROOT / "content/pilot/bundle.json"

_TERM_LINE = re.compile(r'^  "term_ids": \[[^\]]*\],\n', re.M)
_ANCHOR = re.compile(r'^  "related_tool_ids": \[[^\]]*\],\n', re.M)


def bundle_term_ids() -> set[str]:
    bundle = json.loads(BUNDLE.read_text(encoding="utf-8"))
    return {t["term_id"] for t in bundle.get("term_translations", [])}


def write_card_terms(mapping: dict[str, list[str]], known: set[str]) -> int:
    """[mapping]: karta ID → to‘liq term_id lar. Har bir ID [known] da bo‘lishi
    shart. Yozilgan kartalar sonini qaytaradi."""
    done = 0
    for path in sorted(CARDS.glob("card_*.json")):
        raw = path.read_text(encoding="utf-8")
        cid = json.loads(raw)["id"]
        if cid not in mapping:
            continue
        ids = mapping[cid]
        assert len(set(ids)) == len(ids), f"{cid}: takroriy atama"
        for t in ids:
            assert t in known, f"{cid}: noma’lum atama {t}"
        line = '  "term_ids": [' + ", ".join(f'"{t}"' for t in ids) + "],\n"
        text = _TERM_LINE.sub("", raw)
        m = _ANCHOR.search(text)
        assert m, f"{path.name}: related_tool_ids qatori topilmadi"
        text = text[: m.end()] + line + text[m.end():]
        json.loads(text)  # buzilmaganini tekshirish
        if text != raw:
            path.write_text(text, encoding="utf-8")
        done += 1
    assert done == len(mapping), "ba’zi kartalar topilmadi"
    return done
