#!/usr/bin/env python3
"""Deck JSON tekshiruvi (docs/lessons/DECK_SPEC_V2.md).

  python3 tools/lessons/validate_deck.py out/*.json [--strict]

Chiqish: har deck uchun xatolar; --strict bo‘lsa ogohlantirishlar ham xato.
"""
import json
import sys

LIM = {
    "table": {"header": (1, 4, 40), "rows": (1, 6, 40)},
    "flow": {"nodes": (2, 6, 40)},
    "steps": {"items": (2, 6, None)},
    "compare": {"columns": (2, 3, None)},
    "tree": {"children": (1, 6, None)},
    "facts": {"items": (1, 6, None)},
    "reaction": {"reagents": (1, 3, 40), "products": (1, 3, 40)},
    "cycle": {"nodes": (3, 6, 28)},
}


def L(s, n, where, errs):
    if not isinstance(s, str):
        errs.append(f"{where}: matn emas")
    elif len(s) > n:
        errs.append(f"{where}: {len(s)}>{n} belgi: {s[:40]}…")


def lst(v, lo, hi, maxlen, where, errs):
    if not isinstance(v, list) or not (lo <= len(v) <= hi):
        errs.append(f"{where}: ro‘yxat {lo}–{hi} bo‘lishi kerak")
        return []
    if maxlen:
        for i, s in enumerate(v):
            L(s, maxlen, f"{where}[{i}]", errs)
    return v


def check_image(im, where, errs, backend_host=None):
    """`image` maydoni (DECK_SPEC_V2 §2a): https + ishonchli host, PNG/JPG."""
    from urllib.parse import urlparse
    if not isinstance(im, dict):
        errs.append(f"{where}: obyekt emas")
        return
    u = urlparse(str(im.get("url") or ""))
    h = (u.hostname or "").lower()
    ok_host = h == "upload.wikimedia.org" or (
        h == backend_host if backend_host else h.endswith(".supabase.co"))
    if u.scheme != "https" or u.username or not ok_host:
        errs.append(f"{where}.url: faqat https va ishonchli host (backend/upload.wikimedia.org)")
    if not u.path.lower().endswith((".png", ".jpg", ".jpeg")):
        errs.append(f"{where}.url: PNG/JPG bo‘lishi kerak")
    L(im.get("caption", ""), 80, f"{where}.caption", errs)
    if not im.get("credit"):
        errs.append(f"{where}.credit: muallif/litsenziya/manba kerak")
    else:
        L(im["credit"], 120, f"{where}.credit", errs)
    if im.get("kind") not in ("photo", "scheme"):
        errs.append(f"{where}.kind: photo|scheme")


def check_diagram(d, where, errs):
    k = d.get("kind")
    if k not in LIM:
        errs.append(f"{where}: noma’lum kind {k!r}")
        return
    if "caption" in d and d["caption"] is not None:
        L(d["caption"], 80, f"{where}.caption", errs)
    if k == "table":
        h = lst(d.get("header"), 1, 4, 40, f"{where}.header", errs)
        rows = lst(d.get("rows"), 1, 6, None, f"{where}.rows", errs)
        for i, r in enumerate(rows):
            if not isinstance(r, list) or (h and len(r) != len(h)):
                errs.append(f"{where}.rows[{i}]: ustun soni header bilan teng emas")
            else:
                for j, c in enumerate(r):
                    L(c, 40, f"{where}.rows[{i}][{j}]", errs)
    elif k == "flow":
        lst(d.get("nodes"), 2, 6, 40, f"{where}.nodes", errs)
    elif k == "steps":
        for i, it in enumerate(lst(d.get("items"), 2, 6, None, f"{where}.items", errs)):
            L(it.get("title", ""), 30, f"{where}.items[{i}].title", errs)
            L(it.get("text", ""), 80, f"{where}.items[{i}].text", errs)
    elif k == "compare":
        for i, c in enumerate(lst(d.get("columns"), 2, 3, None, f"{where}.columns", errs)):
            L(c.get("title", ""), 24, f"{where}.columns[{i}].title", errs)
            lst(c.get("items"), 1, 5, 60, f"{where}.columns[{i}].items", errs)
    elif k == "tree":
        L(d.get("root", ""), 30, f"{where}.root", errs)
        for i, c in enumerate(lst(d.get("children"), 1, 6, None, f"{where}.children", errs)):
            L(c.get("label", ""), 26, f"{where}.children[{i}].label", errs)
            if c.get("items"):
                lst(c["items"], 1, 3, 40, f"{where}.children[{i}].items", errs)
    elif k == "facts":
        for i, it in enumerate(lst(d.get("items"), 1, 6, None, f"{where}.items", errs)):
            L(it.get("label", ""), 24, f"{where}.items[{i}].label", errs)
            L(str(it.get("value", "")), 20, f"{where}.items[{i}].value", errs)
            if it.get("unit"):
                L(it["unit"], 12, f"{where}.items[{i}].unit", errs)
    elif k == "reaction":
        lst(d.get("reagents"), 1, 3, 40, f"{where}.reagents", errs)
        lst(d.get("products"), 1, 3, 40, f"{where}.products", errs)
        if d.get("conditions"):
            L(d["conditions"], 40, f"{where}.conditions", errs)
        if d.get("observation"):
            L(d["observation"], 60, f"{where}.observation", errs)
    elif k == "cycle":
        lst(d.get("nodes"), 3, 6, 28, f"{where}.nodes", errs)


def check_deck(path, strict):
    errs, warns = [], []
    j = json.load(open(path, encoding="utf-8"))
    d = j.get("deck", j)
    slides = d.get("slides") or []
    if not (38 <= len(slides) <= 42):
        warns.append(f"slayd soni {len(slides)} (38–42 kutiladi)")
    kinds, dia = set(), 0
    for i, s in enumerate(slides):
        w = f"slide[{i}]"
        L(s.get("title", ""), 70, f"{w}.title", errs)
        bl = s.get("bullets") or []
        if not (1 <= len(bl) <= 5):
            warns.append(f"{w}: bullet soni {len(bl)} (2–5)")
        for b_i, b in enumerate(bl):
            L(b.get("text", ""), 160, f"{w}.bullets[{b_i}]", errs)
            src = b.get("source") or {}
            if not src.get("page"):
                errs.append(f"{w}.bullets[{b_i}]: source.page yo‘q")
        if s.get("image"):
            check_image(s["image"], f"{w}.image", errs)
        dg = s.get("diagram")
        if dg:
            dia += 1
            kinds.add(dg.get("kind"))
            check_diagram(dg, f"{w}.diagram", errs)
    if slides and dia < 16:
        warns.append(f"diagrammali slaydlar {dia} (≥16 kutiladi)")
    if slides and len(kinds) < 4:
        warns.append(f"diagramma turlari {sorted(k for k in kinds if k)} (≥4 xil kutiladi)")
    mcq = d.get("mcq") or []
    if len(mcq) != 20:
        warns.append(f"mcq soni {len(mcq)} (20 kutiladi)")
    for i, q in enumerate(mcq):
        opts = q.get("options") or []
        if len(opts) != 4 or not isinstance(q.get("correct_index"), int) or not 0 <= q["correct_index"] < 4:
            errs.append(f"mcq[{i}]: 4 variant va to‘g‘ri correct_index kerak")
        if not (q.get("source") or {}).get("page"):
            errs.append(f"mcq[{i}]: source.page yo‘q")
        if not q.get("explanation"):
            errs.append(f"mcq[{i}]: explanation yo‘q")
    if strict:
        errs += warns
        warns = []
    return errs, warns


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    strict = "--strict" in sys.argv
    bad = 0
    for p in args:
        errs, warns = check_deck(p, strict)
        if errs or warns:
            print(f"== {p}")
            for e in errs:
                print("  XATO:", e)
            for w in warns:
                print("  ogoh:", w)
        bad += bool(errs)
    print(f"{len(args)} deck, {bad} xatoli")
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
