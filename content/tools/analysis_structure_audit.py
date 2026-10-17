#!/usr/bin/env python3
"""«Tahlil» bo‘limi (3 qism) bo‘yicha modda qamrovi auditi.

Ilovadagi tartib (egasi topshirig‘i, 2026-10-17):
  1. Test (ekspress / skrining)
  2. Sifat reaksiyalari (rangli reaktivlar va boshqa taxminiy sinamalar)
  3. Miqdoriy aniqlash (GC-MS, LC-MS/MS, UB-spektrofotometriya va boshqalar)

`content/pilot/bundle.json` dan hisoblanadi; ABY yozuvlari (C-ABY-*, SRC-ABY-2025,
`editorial:aby-order` bog‘lanishlari) HISOBGA OLINMAYDI. Natija:
docs/ANALYSIS_STRUCTURE_AUDIT_2026-10-17.md (jadval qismi shu skript bilan yangilanadi).

Usage: python3 content/tools/analysis_structure_audit.py [--check]
"""
from __future__ import annotations

import argparse
import json
import pathlib
import sys
from collections import Counter, defaultdict

ROOT = pathlib.Path(__file__).resolve().parents[2]
BUNDLE = ROOT / "content/pilot/bundle.json"
DOC = ROOT / "docs/ANALYSIS_STRUCTURE_AUDIT_2026-10-17.md"
BEGIN = "<!-- AUTO:BEGIN -->"
END = "<!-- AUTO:END -->"

# Ilova bilan bir xil guruhlash (substance_analysis_section.dart: analysisSectionOf).
SECTION_FIELDS = {
    1: ["express_test", "immunoassay_screen", "odour_test"],
    2: ["colour_test", "chemical_test", "microcrystal_test", "tlc_system", "melting_point", "method_caveat"],
    3: ["confirmatory_method", "analytical_method", "sample_preparation", "uv_spectrum", "photometric_assay",
        "spectroscopy"],
}
# Ilovadagi analysisQualitative* to‘plamlari bilan bir xil.
QUAL_SCREENINGS = {"scr-colour-tests", "scr-microcrystal-tests"}
QUAL_METHODS = {"method-tlc"}
SECTION_TITLE = {1: "1. Test", 2: "2. Sifat", 3: "3. Miqdoriy"}


def short_source(sid: str) -> str:
    if sid == "SRC-YULDASHEV-GMT-2024":
        return "Y-GMT"
    if sid == "SRC-YULDASHEV-TOKS-2025":
        return "Y-TOKS"
    if sid == "SRC-UNODC-STNAR-13":
        return "UNODC"
    if sid == "SRC-SWGDRUG-8-2":
        return "SWGDRUG"
    if sid.startswith("SRC-ABY"):
        return "ABY"
    if sid.startswith(("SRC-PMC", "SRC-PM", "SRC-PMID")):
        return "LIT"
    return "boshqa"


def compute(bundle: dict):
    cit = defaultdict(list)
    for c in bundle["citations"]:
        cit[c["claim_id"]].append(c["source_id"])
    claims = {c["claim_id"]: c for c in bundle["claims"]}
    field_to_sec = {f: s for s, fs in SECTION_FIELDS.items() for f in fs}

    # modda -> bo‘lim -> {manbalar: soni}
    data: dict[str, dict[int, Counter]] = defaultdict(lambda: {1: Counter(), 2: Counter(), 3: Counter()})
    graph: dict[str, Counter] = defaultdict(Counter)

    for c in bundle["claims"]:
        if c["entity_type"] != "substance" or c["claim_id"].startswith("C-ABY"):
            continue
        sec = field_to_sec.get(c["field"])
        if sec is None:
            continue
        srcs = {short_source(s) for s in cit[c["claim_id"]]} - {"ABY"}
        if not srcs:
            continue
        for s in srcs:
            data[c["entity_id"]][sec][s] += 1

    # Graf: skrining (screened_by) -> 1; analysed_by / confirmed_by -> 3.
    for l in bundle["links"]:
        if l["basis"].startswith("editorial:"):
            continue
        rel = l["relation"]
        if rel == "screened_by":
            if l["to"] in QUAL_SCREENINGS:
                graph[l["from"]]["qual"] += 1
            else:
                graph[l["from"]]["screened"] += 1
        elif rel == "analysed_by":
            if l["to"] in QUAL_METHODS:
                graph[l["from"]]["qual"] += 1
            else:
                graph[l["from"]]["analysed"] += 1
    return data, graph


def render(bundle: dict) -> str:
    data, graph = compute(bundle)
    subs = sorted(bundle["substances"], key=lambda s: (s.get("group") or "", s["substance_id"]))
    rows = []
    full = Counter()
    per_sec = Counter()
    for s in subs:
        sid = s["substance_id"]
        d = data.get(sid, {1: Counter(), 2: Counter(), 3: Counter()})
        g = graph.get(sid, Counter())
        has = {
            1: bool(d[1]) or g["screened"] > 0,
            2: bool(d[2]) or g["qual"] > 0,
            3: bool(d[3]) or g["analysed"] > 0,
        }
        n = sum(has.values())
        full[n] += 1
        for k, v in has.items():
            if v:
                per_sec[k] += 1

        def cell(sec: int) -> str:
            parts = [f"{k}×{v}" for k, v in sorted(d[sec].items())]
            if sec == 2 and g["qual"]:
                parts.append(f"graf-sinama×{g['qual']}")
            if sec == 1 and g["screened"]:
                parts.append(f"graf-skrining×{g['screened']}")
            if sec == 3 and g["analysed"]:
                parts.append(f"graf-usul×{g['analysed']}")
            return ", ".join(parts) if parts else "—"

        rows.append((sid, s.get("group") or "", cell(1), cell(2), cell(3), f"{n}/3"))
    out = []
    out.append(f"Moddalar: **{len(subs)}**. Hisoblash: `python3 content/tools/analysis_structure_audit.py` (ABY hisobga olinmagan).")
    out.append("")
    out.append("| Bo‘lim | Kamida 1 ta manbali yozuvi bor moddalar |")
    out.append("|---|---|")
    for k in (1, 2, 3):
        out.append(f"| {SECTION_TITLE[k]} | {per_sec[k]} / {len(subs)} |")
    out.append("")
    out.append("| Nechta bo‘lim to‘ldirilgan | Moddalar |")
    out.append("|---|---|")
    for n in (3, 2, 1, 0):
        out.append(f"| {n}/3 | {full[n]} |")
    out.append("")
    out.append("Belgilar: `Y-GMT` / `Y-TOKS` = Yuldashev kitoblari (GMT-2024, TOKS-2025); `UNODC` = ST/NAR/13; `SWGDRUG` = v8.2; `LIT` = ochiq maqola (PMC/PubMed); `graf-skrining` / `graf-sinama` / `graf-usul` = manbali graf bog‘lanishi (skrining testi / rangli-mikrokristall-TLC sinamasi / tahlil usuli).")
    out.append("")
    # Guruh bo‘yicha bo‘shliqlar (kimga qaysi manba kerakligini ko‘rsatish uchun).
    miss = defaultdict(lambda: {1: [], 2: [], 3: []})
    for sid, grp, c1, c2, c3, _ in rows:
        for k, c in ((1, c1), (2, c2), (3, c3)):
            if c == "—":
                miss[grp][k].append(sid)
    out.append("**Guruh bo‘yicha bo‘sh bo‘limlar (manbali yozuvi yo‘q moddalar soni / guruhdagi jami)**")
    out.append("")
    out.append("| Guruh | Jami | 1. Test bo‘sh | 2. Sifat bo‘sh | 3. Miqdoriy bo‘sh |")
    out.append("|---|---|---|---|---|")
    totals = Counter(g for _, g, *_ in rows)
    for grp in sorted(totals):
        m = miss[grp]
        out.append(f"| {grp} | {totals[grp]} | {len(m[1])} | {len(m[2])} | {len(m[3])}"
                   + (f" ({', '.join(m[3])})" if m[3] else "") + " |")
    out.append("")
    out.append("| Modda | Guruh | 1. Test | 2. Sifat | 3. Miqdoriy | Jami |")
    out.append("|---|---|---|---|---|---|")
    for r in rows:
        out.append("| " + " | ".join(r) + " |")
    return "\n".join(out)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--check", action="store_true")
    args = ap.parse_args()
    bundle = json.loads(BUNDLE.read_text(encoding="utf-8"))
    table = render(bundle)
    text = DOC.read_text(encoding="utf-8") if DOC.exists() else f"{BEGIN}\n{END}\n"
    if BEGIN not in text:
        text += f"\n{BEGIN}\n{END}\n"
    head, rest = text.split(BEGIN, 1)
    _, tail = rest.split(END, 1)
    new = f"{head}{BEGIN}\n{table}\n{END}{tail}"
    if args.check:
        if new != text:
            print("ANALYSIS_STRUCTURE_AUDIT eskirgan: skriptni qayta ishga tushiring", file=sys.stderr)
            return 1
        return 0
    DOC.write_text(new, encoding="utf-8")
    print(f"written {DOC}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
