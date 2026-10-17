#!/usr/bin/env python3
"""Tadqiqotlar kutubxonasi: mavzuga aloqadorlik tekshiruvi (2026-10-17).

Kontent paketidagi `research` yozuvlari (PubMed / Crossref / Europe PMC
yig‘imi) sud tibbiyoti, toksikologiya, kimyo/analitika, patologiya yoki
huquqqa aloqadorligi bo‘yicha qoidalar (sarlavhadagi kalit so‘zlar + jurnal)
bilan tasniflanadi:

  keep     — aloqador (kuchli belgi sarlavhada yoki jurnal sohaviy);
  suspect  — shubhali (aloqador belgi yo‘q yoki faqat umumiy analitik so‘z):
             O‘CHIRILMAYDI, faqat ro‘yxat (ekspert ko‘rib chiqadi);
  exclude  — aniq aloqasiz (klinik terapiya sinovi, onkologiya, allergologiya,
             oziq-ovqat/atrof-muhit qoldiqlari, hayvonlar, mamlakat sharhi …)
             VA hech qanday sud/toksikologik belgi yo‘q: paketdan chiqariladi.

Ishga tushirish (repo ildizida):
  python3 content/tools/research_relevance.py             # faqat hisobot
  python3 content/tools/research_relevance.py --apply     # chiqarish
  so‘ng: ./tool/update_bundled_pack.sh  (paketni qayta yig‘ish)

`--apply` idempotent: chiqarilganlar `content/pilot/research_excluded.json`
ga yoziladi (assemble_p5.build_research ham shu ro‘yxatni o‘tkazib yuboradi —
qayta yig‘ishda qaytib kirmaydi); bundle’dan research yozuvi, uning
havolalari (`links`) va sarlavha tarjimalari (`text_translations`,
`research_titles_i18n.json`) olib tashlanadi.
"""
from __future__ import annotations

import argparse
import json
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parents[2]
BUNDLE = ROOT / "content/pilot/bundle.json"
TITLES = ROOT / "content/pilot/translations/research_titles_i18n.json"
EXCLUDED = ROOT / "content/pilot/research_excluded.json"
REPORT = ROOT / "docs/RESEARCH_RELEVANCE_20261017.md"

# Sud tibbiyoti / toksikologiya / sud kimyosi / huquq — kuchli belgilar.
STRONG = re.compile(
    r"forens|medico-?legal|legal medicine|coron(?:er|ial)|post-?mortem|autops|"
    r"cadaver|corpse|death|deaths|dead\b|died|fatal|lethal|homicid|suicid|"
    r"poison|intoxicat|overdos|toxic|toxin|envenom|venom|antidote|"
    r"abuse|misuse|illicit|recreational|psychoactive|designer drug|\bNPS\b|"
    r"drug[- ]facilitated|impaired driv|driv(?:er|ers|ing)\b|crime|criminal|court|"
    r"seiz(?:ed|ure)s? (?:drug|sample)|street (?:drug|sample)|adulterant|cutting agent|"
    r"presumptive|spot test|colou?r test|field test|test kit|drug check|"
    r"rigor mortis|livor|algor|decompos|putrefact|drown|diatom|asphyx|hanging|"
    r"strangul|ligature|wound|injur|trauma|gunshot|stab|burn(?:s|ed)?\b|"
    r"stature|sex estimation|age estimation|identification|fingerprint|fingermark|"
    r"thanato|vitreous|time since death|\bPMI\b|"
    r"blood alcohol|breath alcohol|ethanol|alcohol|drunk|"
    r"opioid|opiate|fentanyl|heroin|morphine|cocaine|amphetamine|methamphetamine|"
    r"cannabi|\bTHC\b|benzodiazep|barbiturat|ketamine|xylazine|nitazene|cathinone|"
    r"synthetic cannabinoid|carbon monoxide|cyanide|methanol|ethylene glycol|"
    r"organophosph|pesticid|herbicid|insecticid|paraquat|arsenic|thallium|"
    r"mercury|lead poisoning|phosphide|strychnine|snake|mushroom|amanita|"
    r"psilocybin|ingestion|adverse (?:drug )?(?:event|reaction)",
    re.I,
)

# Umumiy analitik/klinik so‘zlar — yolg‘iz o‘zi aloqadorlik isboti emas.
WEAK = re.compile(
    r"determin|detect|quantif|analy[sz]|chromatograph|mass spectr|LC-MS|GC-MS|"
    r"HPLC|immunoassay|screen|urine|blood|plasma|serum|hair|metabol|"
    r"pharmacokin|glucuronid|exposure|biomarker|histolog|patholog",
    re.I,
)

# Sohaviy jurnallar (sarlavhada belgi bo‘lmasa ham aloqador).
JOURNAL = re.compile(
    r"forens|legal med|medicine,? science,? and the law|toxicol|drug test|"
    r"analytical toxicology|clinical toxicology|police|justice|criminol|"
    r"drug and alcohol|alcohol and alcoholism|addiction|substance use",
    re.I,
)

# Aniq aloqasiz mavzular (kuchli belgi va sohaviy jurnal bo‘lmasa — chiqariladi).
# (regex, sabab, qattiq). Qattiq — sud tibbiyoti mavzusiga bog‘langan bo‘lsa
# ham chiqariladi (oziq-ovqat, atrof-muhit, mamlakat sharhi); yumshoq
# (klinik) — sud tibbiyoti/biokimyo/gistologiya mavzusiga bog‘langan bo‘lsa
# (masalan, o‘limdan keyingi sepsis markerlari) faqat «shubhali».
OFFTOPIC = [
    (r"\brandomi[sz]ed\b|placebo|double-blind|\bphase (?:2|3|II|III)\b|"
     r"efficacy and safety|versus (?:placebo|lenvatinib|no switch)|"
     r"add-on to|non-?inferiority",
     "klinik terapiya sinovi (davolash samaradorligi)", False),
    (r"oncolog|cancer|carcinoma|tumou?r|leuka?emia|lymphoma|chemotherap",
     "onkologiya", False),
    (r"allerg|rhinitis|asthma|\bCOPD\b|lupus|nephritis|multiple sclerosis|"
     r"\bALS\b|amyotrophic|cardiomyopathy|heart failure|obesity|overweight|"
     r"type 2 diabetes|\bHIV\b|COVID|sepsis|optic neuropathy|gout|fibrosis",
     "klinik fan (sud tibbiyoti/toksikologiyaga aloqasiz kasallik)", False),
    (r"\bin food|foodstuff|food (?:sample|product|safety)|\bmilk\b|\bhoney\b|"
     r"\bmeat\b|animal feed|\bfeed\b|residue|livestock|poultry|aquaculture|"
     r"veterinary record|wildlife|\bfish(?:es)?\b|scallop|shellfish",
     "oziq-ovqat / veterinariya / hayvonlar", True),
    (r"activated sludge|biodegrad|wastewater|soil|environmental water|crop|"
     r"drinking water|road-?tunnel|free-chlorine",
     "atrof-muhit / biodegradatsiya", True),
    (r"catalys|catalytic|dehydrogenation|single-crystal electrode|"
     r"personal care products|nanoformulation",
     "sanoat kimyosi / kataliz (sud amaliyotiga aloqasiz)", True),
    (r"onchocerciasis|dermatomyositis", "klinik fan (tropik/revmatologik kasallik)", True),
    (r"^sudan$|in sudan|background notes|initiatives in",
     "mamlakat sharhi (mavzuga aloqasiz)", True),
    (r"biosynthesis of|immunosensor|quenchbody|immunosuppressive compounds",
     "fundamental kimyo/biotexnologiya (sud amaliyotiga aloqasiz)", True),
]

# Sud tibbiyoti / biokimyo / gistologiya mavzulari ID prefikslari.
FORENSIC_TOPIC = re.compile(r"^(?:fm|bio|his)-")

# Oziq-ovqat/hayvon/atrof-muhit mavzusi, lekin sud amaliyotiga oid (masalan
# «Forensic investigation of arson residue», «Human cadaver decomposition …
# gravesoil») — chiqarilmaydi. Bu qoidalar uchun moddaning nomi (pestitsid,
# «rigor mortis» baliqda) yetarli emas.
FORENSIC_EXCEPT = re.compile(
    r"forens|medico-?legal|legal med|post-?mortem|autops|cadaver|corpse|human|"
    r"poison|intoxicat|overdos|death|fatal|homicid|suicid|crime|court",
    re.I,
)
FORENSIC_ONLY = {
    "oziq-ovqat / veterinariya / hayvonlar",
    "atrof-muhit / biodegradatsiya",
}


def classify(r: dict, linked: set[str] = frozenset()) -> tuple[str, str]:
    title = r.get("title") or ""
    journal = r.get("container") or ""
    # Oziq-ovqat / hayvon / atrof-muhit: sud amaliyoti belgisi bo‘lmasa — modda
    # nomi (pestitsid, «rigor mortis» baliqda) bo‘lsa ham chiqariladi.
    for rx, why, hard in OFFTOPIC:
        if (
            why in FORENSIC_ONLY
            and re.search(rx, title, re.I)
            and not FORENSIC_EXCEPT.search(title)
            and not JOURNAL.search(journal)
        ):
            return "exclude", why
    if STRONG.search(title):
        return "keep", "sarlavhada sohaviy belgi"
    if JOURNAL.search(journal):
        return "keep", "sohaviy jurnal"
    # Qattiq qoidalar birinchi (masalan «COVID-19 in Sudan» — mamlakat sharhi).
    for rx, why, hard in sorted(OFFTOPIC, key=lambda o: not o[2]):
        if re.search(rx, title, re.I):
            if not hard and any(FORENSIC_TOPIC.match(x) for x in linked):
                return "suspect", f"{why}, lekin sud tibbiyoti mavzusiga bog‘langan"
            return "exclude", why
    if WEAK.search(title):
        return "suspect", "faqat umumiy analitik/klinik so‘z"
    return "suspect", "sohaviy belgi yo‘q"


def load(p: pathlib.Path):
    return json.loads(p.read_text(encoding="utf-8"))


def dump(p: pathlib.Path, d, indent=None) -> None:
    p.write_text(json.dumps(d, ensure_ascii=False, indent=indent) + "\n", encoding="utf-8")


def report(rows, excluded_prev) -> str:
    ex = [x for x in rows if x[0] == "exclude"]
    su = [x for x in rows if x[0] == "suspect"]
    keep = sum(1 for x in rows if x[0] == "keep")
    out = [
        "# Tadqiqotlar kutubxonasi: mavzuga aloqadorlik tekshiruvi (2026-10-17)",
        "",
        "Skript: `content/tools/research_relevance.py` (qoidalar: sarlavhadagi kalit",
        "so‘zlar + jurnal nomi). Qaror qoidasi: sarlavhada sud tibbiyoti / toksikologiya /",
        "sud kimyosi / huquq belgisi bo‘lsa yoki jurnal sohaviy bo‘lsa — **qoldiriladi**;",
        "aks holda aniq aloqasiz mavzu (klinik terapiya sinovi, onkologiya, allergologiya,",
        "oziq-ovqat/veterinariya, atrof-muhit, mamlakat sharhi) — **paketdan chiqariladi**;",
        "qolganlari — **shubhali** (o‘chirilmaydi, ekspert ko‘rib chiqadi).",
        "",
        f"Natija: jami {len(rows) + len(excluded_prev)} ta yozuv (oldin chiqarilganlar bilan) —",
        f"qoldirildi {keep}, chiqarildi {len(ex) + len(excluded_prev)}, shubhali {len(su)}.",
        "Chiqarilganlar ro‘yxati mashinada o‘qiladigan ko‘rinishda:",
        "`content/pilot/research_excluded.json` (paket qayta yig‘ilganda ham qaytib kirmaydi).",
        "",
        "## Chiqarilgan (aniq aloqasiz)",
        "",
        "| ID | Sarlavha | Jurnal | Sabab |",
        "|---|---|---|---|",
    ]
    allex = [(e["research_id"], e["title"], e.get("container") or "", e["reason"]) for e in excluded_prev]
    allex += [(r["research_id"], r["title"], r.get("container") or "", why) for _, why, r in ex]
    for rid, t, j, why in sorted(allex, key=lambda x: x[3]):
        out.append(f"| `{rid}` | {t.replace('|', '/')} | {j.replace('|', '/')} | {why} |")
    out += [
        "",
        "## Shubhali (o‘chirilmagan — ekspert ko‘rib chiqishi kerak)",
        "",
        "| ID | Sarlavha | Jurnal | Sabab |",
        "|---|---|---|---|",
    ]
    for _, why, r in sorted(su, key=lambda x: (x[1], x[2]["title"])):
        out.append(
            f"| `{r['research_id']}` | {r['title'].replace('|', '/')} | "
            f"{(r.get('container') or '').replace('|', '/')} | {why} |"
        )
    return "\n".join(out) + "\n"


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--apply", action="store_true", help="aniq aloqasizlarni paketdan chiqarish")
    ap.add_argument("--report", default=str(REPORT))
    a = ap.parse_args()

    b = load(BUNDLE)
    prev = load(EXCLUDED)["excluded"] if EXCLUDED.exists() else []
    linked: dict[str, set[str]] = {}
    for x in b["links"]:
        if x.get("relation") == "research":
            linked.setdefault(x["to"], set()).add(x["from"])
    rows = [(*classify(r, linked.get(r["research_id"], set())), r) for r in b["research"]]
    ex_ids = {r["research_id"] for c, _, r in rows if c == "exclude"}
    pathlib.Path(a.report).write_text(report(rows, prev), encoding="utf-8")
    print(
        f"research: {len(rows)} — keep {sum(1 for c, *_ in rows if c == 'keep')}, "
        f"exclude {len(ex_ids)}, suspect {sum(1 for c, *_ in rows if c == 'suspect')}"
        f" (oldin chiqarilgan: {len(prev)}) → {a.report}"
    )
    if not a.apply or not ex_ids:
        return 0
    new_prev = prev + [
        {
            "research_id": r["research_id"],
            "title": r["title"],
            "container": r.get("container"),
            "doi": r.get("doi"),
            "pmid": r.get("pmid"),
            "reason": why,
        }
        for c, why, r in rows
        if c == "exclude"
    ]
    b["research"] = [r for r in b["research"] if r["research_id"] not in ex_ids]
    b["links"] = [
        x for x in b["links"] if x.get("to") not in ex_ids and x.get("from") not in ex_ids
    ]
    b["text_translations"] = [
        x for x in b["text_translations"]
        if not (x.get("target_type") == "research_title" and x.get("target_id") in ex_ids)
    ]
    dump(BUNDLE, b, indent=1)
    if TITLES.exists():
        t = load(TITLES)
        for rid in ex_ids:
            t["research"].pop(rid, None)
        dump(TITLES, t, indent=1)
    dump(
        EXCLUDED,
        {
            "format": "fe.research_excluded/1",
            "note": "content/tools/research_relevance.py --apply; assemble_p5.build_research bularni o‘tkazib yuboradi",
            "excluded": sorted(new_prev, key=lambda e: e["research_id"]),
        },
        indent=1,
    )
    print(f"chiqarildi: {len(ex_ids)} → {EXCLUDED.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
