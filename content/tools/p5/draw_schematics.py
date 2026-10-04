#!/usr/bin/env python3
"""Original ilmiy sxemalar (SVG → PNG). Faqat tushuntirish uchun.

Har bir rasmda «Schematic — not experimental data» izohi bor; ular hech
qachon real xromatogramma, spektr yoki mikropreparat sifatida
ko‘rsatilmaydi. Parametr (harorat, oqim, ion, vaqt) YO‘Q.
"""
import hashlib, json, datetime
from xml.sax.saxutils import escape

import cairosvg

INK = "#14232B"; MUTED = "#5B6B73"; ACCENT = "#0F766E"; FILL = "#EEF5F4"; LINE = "#C9D6D9"
W = 1200
FOOT = "Schematic — not experimental data · FORENSIC EXPERT"


def svg(h, body):
    return (f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{h}" '
            f'viewBox="0 0 {W} {h}" font-family="DejaVu Sans, Arial, sans-serif">'
            f'<rect width="{W}" height="{h}" fill="#FFFFFF"/>{body}'
            f'<text x="{W - 24}" y="{h - 18}" font-size="18" fill="{MUTED}" text-anchor="end">{FOOT}</text></svg>')


def fit(text, width, size, bold=False):
    """Matn bloka sig‘ishi uchun shrift o‘lchami (taxminiy kenglik)."""
    k = 0.62 if bold else 0.55
    while size > 12 and len(text) * size * k > width - 24:
        size -= 1
    return size


def box(x, y, w, h, title, sub=None, accent=False):
    t = (f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="16" fill="{FILL if not accent else ACCENT}" '
         f'stroke="{ACCENT}" stroke-width="2.5"/>')
    col = "#FFFFFF" if accent else INK
    ty = y + h / 2 + (0 if sub is None else -10)
    fs = fit(title, w, 26, True)
    t += f'<text x="{x + w / 2}" y="{ty + 8}" font-size="{fs}" font-weight="bold" fill="{col}" text-anchor="middle">{escape(title)}</text>'
    if sub:
        ss = fit(sub, w, 19)
        t += f'<text x="{x + w / 2}" y="{ty + 40}" font-size="{ss}" fill="{"#E6F2F0" if accent else MUTED}" text-anchor="middle">{escape(sub)}</text>'
    return t


def arrow(x1, y1, x2, y2):
    return (f'<line x1="{x1}" y1="{y1}" x2="{x2}" y2="{y2}" stroke="{ACCENT}" stroke-width="4" '
            f'marker-end="url(#a)"/>')


DEFS = (f'<defs><marker id="a" markerUnits="userSpaceOnUse" markerWidth="16" markerHeight="16" '
        f'refX="14" refY="8" orient="auto"><path d="M0,1 L16,8 L0,15 z" fill="{ACCENT}"/></marker></defs>')


def flow(title, steps, rows=None):
    """steps: [(title, sub)] chapdan o‘ngga; qatorda ≤ 4 blok, ilon shaklida."""
    rows = rows or -(-len(steps) // 4)
    per = -(-len(steps) // rows)
    bw, bh, gap = (W - 80 - (per - 1) * 46) / per, 130, 46
    h = 140 + rows * (bh + 70) + 30
    body = DEFS + f'<text x="40" y="70" font-size="34" font-weight="bold" fill="{INK}">{escape(title)}</text>'
    for i, (t, sub) in enumerate(steps):
        r, c = divmod(i, per)
        if r % 2 == 1:
            c = per - 1 - c
        x = 40 + c * (bw + gap)
        y = 120 + r * (bh + 70)
        body += box(x, y, bw, bh, t, sub, accent=(i == len(steps) - 1))
        if i + 1 < len(steps):
            r2, c2 = divmod(i + 1, per)
            if r2 == r:
                if r % 2 == 0:
                    body += arrow(x + bw + 6, y + bh / 2, x + bw + gap - 6, y + bh / 2)
                else:
                    body += arrow(x - 6, y + bh / 2, x - gap + 6, y + bh / 2)
            else:
                body += arrow(x + bw / 2, y + bh + 6, x + bw / 2, y + bh + 62)
    return svg(h, body)


def tlc():
    h = 760
    b = DEFS + f'<text x="40" y="70" font-size="34" font-weight="bold" fill="{INK}">Thin-layer chromatography (TLC) — plate layout</text>'
    b += f'<rect x="600" y="110" width="320" height="560" rx="10" fill="{FILL}" stroke="{INK}" stroke-width="3"/>'
    b += f'<line x1="600" y1="610" x2="920" y2="610" stroke="{MUTED}" stroke-width="2" stroke-dasharray="10 8"/>'
    b += f'<line x1="600" y1="170" x2="920" y2="170" stroke="{ACCENT}" stroke-width="3"/>'
    for i, x in enumerate((680, 760, 840)):
        b += f'<circle cx="{x}" cy="610" r="9" fill="{INK}"/>'
    # Faqat sxematik dog‘lar — real natija emas.
    for x, y in ((680, 420), (760, 330), (840, 500)):
        b += f'<ellipse cx="{x}" cy="{y}" rx="22" ry="14" fill="{ACCENT}" opacity="0.55"/>'
    b += f'<text x="940" y="176" font-size="22" fill="{INK}">Solvent front</text>'
    b += f'<text x="940" y="604" font-size="22" fill="{INK}">Origin</text><text x="940" y="632" font-size="20" fill="{MUTED}">(sample spots)</text>'
    b += f'<text x="40" y="330" font-size="24" fill="{INK}">Rf = distance travelled by spot</text>'
    b += f'<text x="40" y="364" font-size="24" fill="{INK}">÷ distance travelled by solvent</text>'
    b += f'<text x="40" y="420" font-size="20" fill="{MUTED}">Spot positions are illustrative only.</text>'
    b += f'<text x="40" y="460" font-size="22" fill="{MUTED}">Mobile phase rises through</text><text x="40" y="490" font-size="22" fill="{MUTED}">the stationary phase ↑</text>'
    return svg(h, b)


def immunoassay():
    h = 760
    b = DEFS + f'<text x="40" y="70" font-size="34" font-weight="bold" fill="{INK}">Competitive immunoassay — principle</text>'
    b += box(40, 120, 420, 120, "Drug in sample", "competes for binding")
    b += box(40, 280, 420, 120, "Labelled drug", "(conjugate)")
    b += box(740, 190, 420, 140, "Antibody sites", "limited number", accent=True)
    b += arrow(466, 180, 732, 245)
    b += arrow(466, 340, 732, 280)
    b += box(40, 450, 540, 130, "More drug in sample", "→ less labelled drug bound → signal changes")
    b += box(620, 450, 540, 130, "Cross-reacting compounds", "can also bind → false positives")
    b += f'<text x="40" y="640" font-size="24" font-weight="bold" fill="{ACCENT}">A positive screen is presumptive —</text>'
    b += f'<text x="40" y="674" font-size="24" font-weight="bold" fill="{ACCENT}">confirm with a validated method (e.g. GC-MS / LC-MS/MS).</text>'
    return svg(h, b)


def specimens():
    # Faqat namuna nomlari — xossalar haqidagi da’volar rasmda YO‘Q
    # (ular ilovada manbali claim sifatida ko‘rsatiladi).
    rows = [("Femoral (peripheral) blood", ""), ("Cardiac / central blood", ""),
            ("Vitreous humour", ""), ("Urine", ""), ("Cerebrospinal fluid", ""),
            ("Liver", ""), ("Gastric contents", ""), ("Hair", "")]
    h = 160 + len(rows) * 92 + 60
    b = DEFS + f'<text x="40" y="70" font-size="34" font-weight="bold" fill="{INK}">Postmortem specimens — overview</text>'
    for i, (t, s) in enumerate(rows):
        y = 110 + i * 92
        b += f'<rect x="40" y="{y}" width="{W - 80}" height="76" rx="12" fill="{FILL}" stroke="{LINE}" stroke-width="2"/>'
        b += f'<circle cx="80" cy="{y + 38}" r="12" fill="{ACCENT}"/>'
        b += f'<text x="110" y="{y + 47}" font-size="26" font-weight="bold" fill="{INK}">{escape(t)}</text>'
        b += f'<text x="{W - 64}" y="{y + 47}" font-size="21" fill="{MUTED}" text-anchor="end">{escape(s)}</text>'
    b += f'<text x="40" y="{h - 50}" font-size="20" fill="{MUTED}">Properties and limitations of each specimen: see the sourced statements in the app.</text>'
    return svg(h, b)


DIAGRAMS = [
    ("gcms-workflow", "method-gcms", "GC-MS — instrument workflow",
     flow("GC-MS — instrument workflow", [("Injector", "vaporisation"), ("GC column", "in oven: separation"),
          ("Ion source", "e.g. electron ionisation"), ("Mass analyser", "separates ions by m/z"),
          ("Detector", None), ("Data system", "spectrum + library search")])),
    ("lcmsms-workflow", "method-lcmsms", "LC-MS/MS — instrument workflow",
     flow("LC-MS/MS — tandem mass spectrometry workflow", [("LC column", "separation in liquid phase"),
          ("ESI source", "ionisation"), ("Q1", "precursor ion"), ("Collision cell", "fragmentation"),
          ("Q3", "product ions"), ("Detector + data", "transitions / MRM")])),
    ("hsgc-workflow", "method-headspace-gc", "Headspace GC — workflow",
     flow("Headspace GC — workflow (e.g. volatiles)", [("Sealed vial", "sample + internal standard"),
          ("Equilibration", "heated vial"), ("Headspace sampling", "vapour phase only"),
          ("GC separation", None), ("Detector", "e.g. FID / MS")])),
    ("hplc-workflow", "method-hplc", "HPLC — workflow",
     flow("HPLC — workflow", [("Mobile phase + pump", None), ("Injector", None), ("Column", "separation"),
          ("Detector", "e.g. UV / DAD"), ("Chromatogram", "data system")])),
    ("sample-prep-workflow", "method-spe", "Sample preparation — typical workflow",
     flow("Sample preparation — typical workflow", [("Specimen", "blood, urine, tissue"),
          ("Internal standard", "added"), ("Extraction", "SPE / LLE / PPT"),
          ("Evaporation", None), ("Reconstitution", None), ("Instrumental analysis", "GC-MS / LC-MS/MS")], rows=2)),
    ("screen-confirm", "scr-immunoassay-drugs", "Screening → confirmation",
     flow("Screening is presumptive — confirmation is required", [("Screening test", "immunoassay / colour test"),
          ("Presumptive result", "not an identification"), ("Confirmatory analysis", "validated GC-MS / LC-MS/MS"),
          ("Interpretation", "case context + limitations")])),
    ("histology-workflow", "his-sampling", "Histology — laboratory workflow",
     flow("Forensic histology — laboratory workflow", [("Sampling", "at autopsy"), ("Fixation", "e.g. formalin"),
          ("Processing", "dehydration, clearing"), ("Embedding", "paraffin block"),
          ("Sectioning", "microtome"), ("Staining", "e.g. H&E / special stains"),
          ("Microscopy", "interpretation by a pathologist")], rows=2)),
    ("validation-parameters", "method-validation", "Method validation — typical parameters",
     flow("Method validation — typical parameters", [("Selectivity", None), ("Calibration model", None),
          ("Bias / accuracy", None), ("Precision", None), ("LOD / LOQ", None), ("Matrix effects", None),
          ("Carryover", None), ("Stability", None)], rows=2)),
]


def main():
    acc = datetime.date.today().isoformat()
    meta = []
    items = DIAGRAMS + [("tlc-plate", "method-tlc", "TLC — plate layout", tlc()),
                        ("immunoassay-principle", "method-immunoassay", "Competitive immunoassay — principle", immunoassay()),
                        ("postmortem-specimens", "bio-sampling-site", "Postmortem specimens — overview", specimens())]
    for key, entity, title, s in items:
        path = f"phase5/images/schematics/{key}.png"
        cairosvg.svg2png(bytestring=s.encode(), write_to=path, output_width=1200)
        data = open(path, "rb").read()
        meta.append(dict(image_id=f"IMG-SCH-{key}", kind="schematic", entity_id=entity, file=path,
                         sha256=hashlib.sha256(data).hexdigest(), title={"en": title},
                         alt={"en": f"Schematic diagram: {title}. Illustrative, not experimental data."},
                         creator="FORENSIC EXPERT (original diagram)", source_name="FORENSIC EXPERT",
                         source_url=None, license="original_work", attribution="Original schematic — FORENSIC EXPERT",
                         is_original_diagram=True, represents_real_data=False, accessed=acc))
    json.dump(meta, open("phase5/images_schematics.json", "w"), ensure_ascii=False, indent=1)
    print(len(meta))


if __name__ == "__main__":
    main()
