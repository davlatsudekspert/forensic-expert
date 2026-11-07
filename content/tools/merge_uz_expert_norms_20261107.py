#!/usr/bin/env python3
"""O‘zbekiston: sud-tibbiy ekspertizaga oid protsessual/jinoyat normalar
(JPK, JK, eski va yangi sud-ekspertlik qonuni) → MAVJUD pilot/bundle.json.
Manba jadvallari: scratchpad/legal/mk.py (lex.uz dan o‘qilgan, yurist tekshiruvi
kutilmoqda). Idempotent. Hammasi NEEDS_REVIEW; matn o‘z so‘zlarim bilan qisqartirilgan,
rasmiy matn o‘rnini bosmaydi."""
import hashlib, json, os, re, sys
from unittest import mock

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", ".."))
MK = sys.argv[1]            # mk.py yo‘li
SRC = sys.argv[2]           # lex.uz html fayllari katalogi
P = os.path.join(ROOT, "content/pilot/bundle.json")

cap = []
code = open(MK, encoding="utf-8").read()
code = code.replace("def tbl(title,rows,src):", "def tbl(title,rows,src):\n    CAP.append((title,rows,src)); return")
sys.modules["docx"] = mock.MagicMock(); sys.modules["docx.shared"] = mock.MagicMock()
exec(compile(code, "mk", "exec"), {"CAP": cap, "__name__": "mk"})
tables = {t[0][:2].strip(". "): t[1] for t in cap}   # '1','2','3'

DATE = "2026-11-07"
def sha(name):
    return hashlib.sha256(open(os.path.join(SRC, name), "rb").read()).hexdigest()

INSTR = [
 dict(id="UZ-JPK", tbl="1", src="SRC-UZ-JPK", url="https://lex.uz/uz/docs/111460", file="d111460.html", lang="uz",
      title_uz="O‘zbekiston Respublikasining Jinoyat-protsessual kodeksi", title_ru="Уголовно-процессуальный кодекс Республики Узбекистан",
      ref="22.09.1994", pub="1994-09-22", eff_to=None, eff_from=DATE, org="O‘zbekiston Respublikasi",
      note="JPK, lex.uz/uz/docs/111460; matn o‘zbek kirillida o‘qildi (2026-11-07). effective_from — o‘qilgan tahrir sanasi; amaldagi tahrirni yurist tekshirsin."),
 dict(id="UZ-JK", tbl="2", src="SRC-UZ-JK", url="https://lex.uz/uz/docs/111457", file="d111457.html", lang="ru",
      title_uz="O‘zbekiston Respublikasining Jinoyat kodeksi", title_ru="Уголовный кодекс Республики Узбекистан",
      ref="22.09.1994", pub="1994-09-22", eff_to=None, eff_from=DATE, org="O‘zbekiston Respublikasi",
      note="JK, lex.uz/uz/docs/111457; matn rus tilida o‘qildi (2026-11-07). effective_from — o‘qilgan tahrir sanasi."),
 dict(id="UZ-LAW-1152", tbl="3", src="SRC-UZ-LAW-1152", url="https://lex.uz/uz/docs/8265035", file="new.html", lang="uz",
      title_uz="O‘zbekiston Respublikasining «Sud-ekspertlik faoliyati to‘g‘risida»gi Qonuni", title_ru=None,
      ref="11.06.2026, № O‘RQ-1152", pub="2026-06-11", eff_to=None, eff_from="2026-12-13", org="O‘zbekiston Respublikasi",
      note="Kuchga kirish sanasi 2026-12-13 — lex.uz izohiga ko‘ra (qonunning 58-moddasi: rasmiy e’londan 6 oy o‘tgach). Yurist tekshirsin."),
 dict(id="UZ-LAW-249", tbl=None, src="SRC-UZ-LAW-249", url="https://lex.uz/uz/docs/1633102", file="law.html", lang="uz",
      title_uz="O‘zbekiston Respublikasining «Sud ekspertizasi to‘g‘risida»gi Qonuni", title_ru=None,
      ref="01.06.2010, № O‘RQ-249", pub="2010-06-01", eff_to="2026-12-13", eff_from=DATE, org="O‘zbekiston Respublikasi",
      note="O‘RQ-1152 ga asosan 2026-12-13 dan kuchini yo‘qotadi (lex.uz izohi)."),
]
OLD_ROWS = [("15–16", "Sud ekspertining huquqlari va majburiyatlari",
             "JPK 68-modda shu moddalarga havola qiladi. 2026-12-13 dan yangi qonunning 25 va 26-moddalari amal qiladi."),
            ("31", "Qonunchilikni buzganlik uchun javobgarlik", "Umumiy norma; jinoiy javobgarlik JK 238–240 da.")]

def clean(s): return s.replace("**", "").strip()
b = json.load(open(P))
have_s = {s["source_id"] for s in b["sources"]}; have_i = {i["instrument_id"] for i in b["instruments"]}
have_r = {r["rule_id"] for r in b["rules"]}
ns = ni = nr = 0
for I in INSTR:
    if I["src"] not in have_s:
        b["sources"].append({"source_id": I["src"], "source_type": "legislation", "title": I["title_ru"] or I["title_uz"],
            "organization": I["org"], "official_url": I["url"], "accessed_date": DATE, "tier": "tier1", "evidence_level": "A",
            "license_mode": "citeOnly", "identifier_verified": True, "language": I["lang"], "sha256": sha(I["file"]),
            "source_version": DATE, "notes": "Rasmiy hujjat (mualliflik huquqi obyekti emas). Retrieved " + DATE + ". " + I["note"]}); ns += 1
    if I["id"] not in have_i:
        t = {"uz": I["title_uz"]}
        if I["title_ru"]: t["ru"] = I["title_ru"]
        b["instruments"].append({"instrument_id": I["id"], "jurisdiction_id": "UZ", "instrument_type": "law", "titles": t,
            "translation_status": "machine_draft", "official_source_id": I["src"], "official_reference": I["ref"],
            "effective_from": I["eff_from"], **({"effective_to": I["eff_to"]} if I["eff_to"] else {}),
            "version": DATE, "last_verified_at": DATE, "legal_status": "in_force", "publication_date": I["pub"],
            "language": I["lang"] if I["lang"] != "ru" else "ru", "review_status": "NEEDS_REVIEW", "date_precision": "day",
            "internal_note": I["note"] + " NEEDS LEGAL REVIEW."}); ni += 1
    rows = tables[I["tbl"]] if I["tbl"] else OLD_ROWS
    for art, title, summ in rows:
        rid = "R-%s-%s" % (I["id"], re.sub(r"[^0-9A-Za-z]+", "-", art).strip("-"))
        if rid in have_r: continue
        r = {"rule_id": rid, "instrument_id": I["id"], "rule_type": "procedure_requirement", "subject_type": "expert_norm",
             "subject_id": rid.lower(), "article_section": art + "-modda" if not art.endswith("modda") else art,
             "value": {"article": art, "title_uz": clean(title), "summary_uz": clean(summ) or None,
                       "summary_basis": "Qisqartirilgan mazmun (o‘z so‘zlarim bilan); rasmiy matn o‘rnini bosmaydi."},
             "effective_from": I["eff_from"], "review_status": "NEEDS_REVIEW"}
        if I["eff_to"]: r["effective_to"] = I["eff_to"]
        if not r["value"]["summary_uz"]: r["value"].pop("summary_uz")
        b["rules"].append(r); nr += 1
json.dump(b, open(P, "w"), ensure_ascii=False, indent=1)
print("sources", ns, "instruments", ni, "rules", nr)
