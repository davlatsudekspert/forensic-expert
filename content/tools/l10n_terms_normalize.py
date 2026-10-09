#!/usr/bin/env python3
"""Canonical terminology normaliser (Phase D, 2026-10-09). Idempotent.

Decision (content/terminology/canonical_terms.json): international
abbreviations (GC-MS, LC-MS/MS, LC-MS, HPLC, TLC, HPTLC, GC, LC, GLC, GC-FID,
HRMS, PMI, PMR …) are used in ALL UI languages. Local variants
(GX-MS, SX-MS, YuSSX, YuQX, ГХ-МС, ЖХ-МС, ВЭЖХ, ТСХ …) are replaced; the first
mention per card / question gets the expansion in the UI language:
«GC-MS (gaz xromatografiyasi — mass-spektrometriya)».  English one-word
adjectives in Uzbek text are replaced («postmortem» → «o‘limdan keyingi»,
«antemortem» → «o‘limdan oldingi», «methemoglobin» → «metgemoglobin»).

Not touched: `keywords` (search synonyms), `omitted_unverified` (internal),
`references` (bibliography), citation keys, identifiers.

Usage (repository root):
  python3 content/tools/l10n_terms_normalize.py            # guidelines/src + court_prep/src
  python3 content/tools/l10n_terms_normalize.py --check    # exit 1 if anything would change
"""
from __future__ import annotations

import argparse
import json
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parents[2]
TERMS = json.loads((ROOT / "content/terminology/canonical_terms.json").read_text(encoding="utf-8"))
SKIP_KEYS = {"keywords", "omitted_unverified", "translation_status", "references", "id", "key",
             "citations", "locators", "related_tool_ids", "discipline_codes", "status", "updated",
             "icon", "topic", "links", "question_ids"}

_B = r"(?<![\wЀ-ӿ‘’.\-/])"      # left boundary
_E = r"(?![A-Za-z0-9Ѐ-ӿ‘’])"     # right boundary (lower-case uz suffix handled below)

# (pattern, replacement) — longest first. Applied to uz / ru running text.
UZ_RULES = [
    (r"SX-MS\(MS\)", "LC-MS(/MS)"),
    (r"YuSSX[-–]MS/MS", "LC-MS/MS"),
    (r"SX[-–]MS/MS", "LC-MS/MS"),
    (r"SX[-–]MS", "LC-MS"),
    (r"GX[-–]MS", "GC-MS"),
    (r"GX[-–]AID", "GC-FID"),
    (r"YuSSX[-–]DMD", "HPLC-DAD"),
    (r"YuSYuQX", "HPTLC"),
    (r"YuSSX", "HPLC"),
    (r"YuQX", "TLC"),
    (r"YuAMS", "HRMS"),
    (r"GSX", "GLC"),
    (r"SX[-–]UB", "LC-UV"),
    (r"GX", "GC"),
    (r"SX", "LC"),
]
RU_RULES = [
    (r"ВЭЖХ[-–]МС/МС", "LC-MS/MS"),
    (r"ВЭЖХ[-–]МС\(МС\)", "LC-MS(/MS)"),
    (r"ВЭЖХ[-–]МС", "LC-MS"),
    (r"ГХ[-–]МС\(МС\)", "GC-MS(/MS)"),
    (r"ТСХ[-–]МС", "TLC-MS"),
    (r"ЖХ[-–]УФ", "LC-UV"),
    (r"ЖХ[-–]Д[МА]Д", "LC-DAD"),
    (r"ЖХ[-–]МС/МС", "LC-MS/MS"),
    (r"ЖХ[-–]МС\(МС\)", "LC-MS(/MS)"),
    (r"ГХ[-–/]МС", "GC-MS"),
    (r"GC/МС", "GC-MS"),
    (r"ЖХ[-–]МС", "LC-MS"),
    (r"ГХ[-–]ПИД", "GC-FID"),
    (r"ПФ[-–]ГХ[-–]ПИД", "HS-GC-FID"),
    (r"ПФ[-–]ГХ", "HS-GC"),
    (r"ВЭЖХ[-–]Д[МА]Д", "HPLC-DAD"),
    (r"ВЭТСХ", "HPTLC"),
    (r"ВЭЖХ", "HPLC"),
    (r"ТСХ", "TLC"),
    (r"ГЖХ", "GLC"),
    (r"МСВР", "HRMS"),
    (r"ГХ", "GC"),
    (r"ЖХ", "LC"),
]
# «YuQX/YuSYuQX», «GX/MS», «GC-MS/SX-MS»: a slash is a valid neighbour.
_UZ = [(re.compile(r"(?<![\w\u0400-\u04FF‘’.\-])" + p + r"(?![A-Z0-9\u0400-\u04FF])"), r)
       for p, r in UZ_RULES]
_RU = [(re.compile(r"(?<![\w\u0400-\u04FF‘’.\-])" + p + _E), r) for p, r in RU_RULES]

# Uzbek: English one-word adjectives / untranslated words.
UZ_WORDS = [
    (r"\(postmortem redistribution, PMR\)", "(PMR)"),
    (r"\(postmortem redistribution\)", ""),
    (r"o‘limdan keyingi \(postmortem\)", "o‘limdan keyingi"),
    (r"antemortem va perimortem", "o‘limdan oldingi va o‘lim paytidagi"),
    (r"Antemortem va perimortem", "O‘limdan oldingi va o‘lim paytidagi"),
    (r"\bPost-?mortem\b", "O‘limdan keyingi"),
    (r"\bpost-?mortem\b", "o‘limdan keyingi"),
    (r"\bAnte-?mortem\b", "O‘limdan oldingi"),
    (r"\bante-?mortem\b", "o‘limdan oldingi"),
    (r"o‘lim keyingi", "o‘limdan keyingi"),
    (r"\bMethemoglobin", "Metgemoglobin"),
    (r"\bmethemoglobin", "metgemoglobin"),
    (r"(?<![.\w])ethanol\b", "etanol"),
]
_UZW = [(re.compile(p), r) for p, r in UZ_WORDS]

# Terms that get a first-mention expansion.
EXPAND = ["LC-MS/MS", "GC-MS", "LC-MS", "HPLC-DAD", "HPLC", "HPTLC", "TLC", "GC-FID", "GLC", "HRMS",
          "GC", "LC", "PMI", "PMR"]
_TERM = {t["abbr"]: t for t in TERMS["terms"]}


def _abbr_re(abbr: str) -> re.Pattern:
    # «GC» must not match inside «GC-MS», «HPLC» not inside «HPLC-DAD», «LC» not in «HPLC»/«LC-MS».
    return re.compile(r"(?<![\wЀ-ӿ‘’.\-/])" + re.escape(abbr) + r"(?![\wЀ-ӿ‘’\-/(])")


_ABBR = {a: _abbr_re(a) for a in EXPAND}


def _stems(expansion: str) -> list[str]:
    words = re.findall(r"[\w‘’\-]+", expansion.lower())
    return [w[:5] for w in words if len(w) >= 5]


def _norm(s: str) -> str:
    return re.sub(r"[‐-―]", "-", s.lower())


def normalize_text(text: str, lang: str) -> str:
    if lang == "uz":
        for rx, rep in _UZ:
            text = rx.sub(rep, text)
        # attached Uzbek suffix after a Latin abbreviation: «TLCdan» → «TLC dan»
        text = re.sub(r"\b(TLC|HPLC|GC-MS|LC-MS/MS|LC-MS|GC|LC|HPTLC|GLC|HRMS)(?=(?:dan|ga|ning|da|ni|lar)\b)",
                      r"\1 ", text)
        for rx, rep in _UZW:
            text = rx.sub(rep, text)
        text = re.sub(r"  +", " ", text)
    elif lang == "ru":
        for rx, rep in _RU:
            text = rx.sub(rep, text)
        text = text.replace("HPTLC; англ. HPTLC", "HPTLC").replace("(HPTLC; англ. HPTLC)", "(HPTLC)")
        text = text.replace("TLC/HPTLC", "TLC / HPTLC")
    return text


def _has_expansion_near(text: str, start: int, end: int, abbr: str, lang: str) -> bool:
    exp = _TERM[abbr]["expansion"][lang]
    window = _norm(text[max(0, start - 160): end + 90])
    return all(s in window for s in _stems(exp))


def expand_first_mentions(texts: list[tuple[object, str]], lang: str, title_texts: list[str]) -> None:
    """texts: list of (holder dict, lang) in display order; edits holder[lang] in place."""
    done = set()
    # a title that already carries the expansion counts as the first mention
    for t in title_texts:
        for abbr, rx in _ABBR.items():
            m = rx.search(t)
            if m and _has_expansion_near(t, m.start(), m.end(), abbr, lang):
                done.add(abbr)
    for abbr, rx in _ABBR.items():
        if abbr in done:
            continue
        first = None      # (holder, match) of the first mention
        target = None     # first mention outside parentheses
        for holder in texts:
            for m in rx.finditer(holder[lang]):
                if first is None:
                    first = (holder, m)
                    if _has_expansion_near(holder[lang], m.start(), m.end(), abbr, lang):
                        target = "done"
                        break
                depth = holder[lang][: m.start()].count("(") - holder[lang][: m.start()].count(")")
                if depth <= 0:
                    target = (holder, m)
                    break
            if target is not None:
                break
        if first is None or target == "done":
            continue
        holder, m = target if target is not None else first
        s = holder[lang]
        if _has_expansion_near(s, m.start(), m.end(), abbr, lang):
            continue
        exp = _TERM[abbr]["expansion"][lang]
        holder[lang] = s[: m.end()] + f" ({exp})" + s[m.end():]


# Multiple-choice options must stay parallel: an expansion added to one option
# would give the answer away, so expansions are never added under these keys.
NO_EXPAND_KEYS = {"quiz", "options"}


def _tri_holders(obj, out, prose=None, in_prose=True):
    if isinstance(obj, dict):
        if {"uz", "ru", "en"} <= obj.keys() and all(isinstance(obj[k], str) for k in ("uz", "ru", "en")):
            out.append(obj)
            if prose is not None and in_prose:
                prose.append(obj)
            return
        for k, v in obj.items():
            if k in SKIP_KEYS:
                continue
            _tri_holders(v, out, prose, in_prose and k not in NO_EXPAND_KEYS)
    elif isinstance(obj, list):
        for v in obj:
            _tri_holders(v, out, prose, in_prose)


def process_unit(unit: dict) -> None:
    holders, prose = [], []
    _tri_holders(unit, holders, prose)
    for h in holders:
        for lang in ("uz", "ru"):
            h[lang] = normalize_text(h[lang], lang)
    title = unit.get("title") or unit.get("question") or {}
    for lang in ("uz", "ru", "en"):
        titles = [title[lang]] if isinstance(title, dict) and isinstance(title.get(lang), str) else []
        body = [h for h in prose if h is not title]
        expand_first_mentions(body, lang, titles)


def units_of(path: pathlib.Path, data):
    """Card / question / topic / principle / scenario objects of a src file."""
    if path.parent.parent.name == "guidelines":
        return [data]
    out = []
    for key in ("topic",):
        if isinstance(data.get(key), dict):
            out.append(data[key])
    for key in ("topics", "questions", "principles", "scenarios"):
        out += [x for x in data.get(key, []) if isinstance(x, dict)]
    if not out and isinstance(data, dict):
        # answers_*.json overlay: {question_id: {...}}
        out = [v for v in data.values() if isinstance(v, dict)]
    return out


def _apply_raw(raw: str, pairs: list[tuple[str, str]]) -> str:
    """Rewrites changed string values in the raw JSON text (keeps formatting)."""
    cursor = 0
    for old, new in pairs:
        o = json.dumps(old, ensure_ascii=False)
        n = json.dumps(new, ensure_ascii=False)
        i = raw.find(o, cursor)
        if i < 0:
            i = raw.find(o)
        if i < 0:
            raise SystemExit(f"cannot locate string in raw JSON: {old[:80]!r}")
        raw = raw[:i] + n + raw[i + len(o):]
        cursor = i + len(n)
    return raw


def run(check: bool) -> int:
    changed = []
    files = sorted((ROOT / "content/guidelines/src").glob("card_*.json")) + \
        sorted((ROOT / "content/court_prep/src").glob("*.json"))
    for f in files:
        raw = f.read_text(encoding="utf-8")
        data = json.loads(raw)
        units = units_of(f, data)
        before = []
        for u in units:
            hs = []
            _tri_holders(u, hs)
            before.append([(h, dict(h)) for h in hs])
        for u in units:
            process_unit(u)
        pairs = []
        for snap in before:
            for h, old in snap:
                for lang in ("uz", "ru", "en"):
                    if h[lang] != old[lang]:
                        pairs.append((old[lang], h[lang]))
        if pairs:
            changed.append(f)
            if not check:
                new = _apply_raw(raw, pairs)
                assert json.loads(new) == data, f"raw rewrite mismatch in {f}"
                f.write_text(new, encoding="utf-8")
    for f in changed:
        print(("WOULD CHANGE " if check else "normalized ") + str(f.relative_to(ROOT)))
    print(f"l10n_terms_normalize: {len(changed)} file(s) {'need changes' if check else 'changed'}")
    return 1 if (check and changed) else 0


def _canon(text: str) -> str:
    return json.dumps(json.loads(text), ensure_ascii=False, sort_keys=True)


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--check", action="store_true")
    sys.exit(run(ap.parse_args().check))
