"""Entry constructors for substance_methods_data.py (render only; no facts)."""
from __future__ import annotations

from sm_vocab import (COLOURS, LANGS, PLATES, R, SOLV, TAG, VIS, colours, reagent,
                      recipe_of, system)

# ---------------------------------------------------------------- sources
SRC = {
    "GMT": {
        "source_id": "SRC-YULDASHEV-GMT-2024",
        "short": ("Yuldashev et al., «Giyohvand moddalar tahlili» (2024)",
                  "Yuldashev Z.A. va boshq., «Giyohvand moddalar tahlili» (2024)",
                  "Юлдашев З.А. и др., «Анализ наркотических веществ» (2024)"),
    },
    "TOKS": {
        "source_id": "SRC-YULDASHEV-TOKS-2025",
        "short": ("Yuldashev, Umarova, «Toksikologik kimyo» teaching complex (2025)",
                  "Yuldashev Z.A., Umarova G.Q., «Toksikologik kimyo» o‘quv-uslubiy majmua (2025)",
                  "Юлдашев З.А., Умарова Г.К., «Токсикологическая химия», учебно-методический комплекс (2025)"),
    },
    "UNODC": {
        "source_id": "SRC-UNODC-STNAR-13",
        "short": ("UNODC, Rapid Testing Methods of Drugs of Abuse (ST/NAR/13/Rev.1)",
                  "UNODC, Rapid Testing Methods of Drugs of Abuse (ST/NAR/13/Rev.1)",
                  "UNODC, Rapid Testing Methods of Drugs of Abuse (ST/NAR/13/Rev.1)"),
    },
    "SWG": {
        "source_id": "SRC-SWGDRUG-8-2",
        "short": ("SWGDRUG Recommendations, version 8.2 (2024)",
                  "SWGDRUG Recommendations, 8.2-versiya (2024)",
                  "SWGDRUG Recommendations, версия 8.2 (2024)"),
    },
}

PAGE = ("p.", "bet", "с.")


def _pg(lang, n):
    return {"en": f"p. {n}", "uz": f"{n}-bet", "ru": f"с. {n}"}[lang]


def _pgs(lang, a, b=None):
    if b is None:
        return _pg(lang, a)
    return {"en": f"pp. {a}–{b}", "uz": f"{a}–{b}-betlar", "ru": f"сс. {a}–{b}"}[lang]


def loc(key, pdf=None, printed=None, to=None, tbl=None, sec=None):
    """Tri-lingual locator with the short source name, e.g.
    «Yuldashev …(2024), PDF p. 24 (printed p. 23), Table 2»."""
    out = {}
    for i, lang in enumerate(LANGS):
        base = SRC[key]["short"][i]
        if key == "GMT":
            n = pdf
            part = (f"PDF p. {n} (printed p. {n - 1})" if lang == "en" else
                    f"PDF {n}-bet (bosma {n - 1}-bet)" if lang == "uz" else
                    f"PDF с. {n} (печатная с. {n - 1})")
            if to:
                part = (f"PDF pp. {n}–{to}" if lang == "en" else
                        f"PDF {n}–{to}-betlar" if lang == "uz" else f"PDF сс. {n}–{to}")
        elif key == "UNODC":
            n = printed
            part = (f"printed p. {n} (PDF p. {n + 10})" if lang == "en" else
                    f"bosma {n}-bet (PDF {n + 10}-bet)" if lang == "uz" else
                    f"печатная с. {n} (PDF с. {n + 10})")
            if to:
                part = (f"printed pp. {n}–{to}" if lang == "en" else
                        f"bosma {n}–{to}-betlar" if lang == "uz" else f"печатные сс. {n}–{to}")
        elif key == "TOKS":
            n = pdf
            part = _pgs(lang, n, to)
        elif key == "SWG":
            part = sec  # sec already tri via caller
            part = part[i] if isinstance(part, tuple) else part
        else:
            raise KeyError(key)
        if tbl is not None:
            part += {"en": f", Table {tbl}", "uz": f", {tbl}-jadval", "ru": f", табл. {tbl}"}[lang]
        if sec and key != "SWG":
            s = sec[i] if isinstance(sec, tuple) else sec
            part += f", {s}"
        out[lang] = f"{base}, {part}"
    return out


def N(en, uz, ru):
    return (en, uz, ru)


def dnum(s, lang):
    return s.replace(".", ",") if lang in ("uz", "ru") else s


# ---------------------------------------------------------------- renderers
def _tag(kind):
    return TAG[kind]


def _join(main, extra, kind):
    """main/extra: tri tuples → tri dict with the fixed honesty tag appended."""
    out = {}
    for i, lang in enumerate(LANGS):
        parts = [main[i]]
        if extra:
            parts.append(extra[i])
        parts.append(_tag(kind)[i])
        out[lang] = " ".join(p for p in parts if p)
    return out


def _colour_phrase(seq, rng, i, lang):
    if rng:
        sep = {"en": " to ", "uz": " – ", "ru": " – "}[lang]
        return sep.join(COLOURS[c][i] for c in seq)
    return " → ".join(COLOURS[c][i] for c in seq)


TIMING = {
    None: ("", "", ""),
    "slow": (" (the change is slow)", " (o‘zgarish sekin boradi)", " (изменение происходит медленно)"),
    "rapid_then_slow": (" (first a rapid change, then a slow one)", " (avval tez, so‘ng sekin o‘zgaradi)",
                        " (сначала быстрое, затем медленное изменение)"),
    "immediate": (" (immediately)", " (darhol)", " (сразу)"),
    "on_standing": (" (on standing)", " (turganda)", " (при стоянии)"),
    "on_heating": (" (on heating)", " (qizdirilganda)", " (при нагревании)"),
    "minutes": (" (within a few minutes)", " (bir necha daqiqa ichida)", " (в течение нескольких минут)"),
}


def colour(subs, rks, seq, src, loc_, rng=False, timing=None, note=None, kind="colour_test", tag="presumptive",
           layer="substance", sensitivity=None):
    """Colour / spot test entry. rks: reagent key or list of keys."""
    rks = [rks] if isinstance(rks, str) else rks
    text = {}
    main = []
    for i, lang in enumerate(LANGS):
        names = ", ".join(R[k][i] for k in rks) if len(rks) > 1 else R[rks[0]][i]
        ph = _colour_phrase(seq, rng, i, lang)
        t = TIMING[timing][i]
        if lang == "en":
            main.append(f"{names[0].upper() + names[1:]}: colour {ph}{t}.")
        elif lang == "uz":
            main.append(f"{names[0].upper() + names[1:]}: rang — {ph}{t}.")
        else:
            main.append(f"{names[0].upper() + names[1:]}: цвет — {ph}{t}.")
    if sensitivity:
        sens = {"en": f" Sensitivity stated by the source: {dnum(sensitivity, 'en')}.",
                "uz": f" Manba keltirgan sezgirlik: {dnum(sensitivity, 'uz')}.",
                "ru": f" Чувствительность по источнику: {dnum(sensitivity, 'ru')}."}
        main = [m + sens[l] for m, l in zip(main, LANGS)]
    text = _join(tuple(main), note, tag)
    return dict(subs=subs if isinstance(subs, list) else [subs], family=kind, text=text, src=src, loc=loc_,
                cls="presumptive", cat="C" if kind == "colour_test" else None,
                recipes=[recipe_of(k) for k in rks if recipe_of(k)], reagents=[R[k][0] for k in rks],
                data={"colours": seq, "range": rng}, layer=layer)


def tlc(subs, parts, plate, vis, src, loc_, rf=None, note=None, layer="substance", extra_systems=None):
    """TLC entry. parts: [(solvent_key, ratio)…] or a list of such lists (several systems)."""
    systems = parts if isinstance(parts[0], list) else [parts]
    main = []
    for i, lang in enumerate(LANGS):
        ss = "; ".join(system(p, lang) for p in systems)
        pl = PLATES[plate][i]
        vs = VIS[vis][i]
        if lang == "en":
            m = f"TLC on {pl}: mobile phase {ss}; visualisation: {vs}."
        elif lang == "uz":
            m = f"TLC — {pl}: harakatlanuvchi faza {ss}; ochuvchi reagent: {vs}."
        else:
            m = f"TLC — {pl}: подвижная фаза {ss}; проявление: {vs}."
        if rf:
            rr = "; ".join(f"{(lab[i] + ' ') if lab else ''}Rf {dnum(v, lang)}" for lab, v in rf)
            if lang == "en":
                m += f" Rf value(s) as printed in the source for this system: {rr}."
            elif lang == "uz":
                m += f" Manbada shu tizim uchun keltirilgan Rf qiymat(lar)i: {rr}."
            else:
                m += f" Значения Rf, приведённые в источнике для этой системы: {rr}."
        main.append(m)
    text = _join(tuple(main), note, "tlc")
    return dict(subs=subs if isinstance(subs, list) else [subs], family="tlc", text=text, src=src, loc=loc_,
                cls="presumptive", cat="B", recipes=[], reagents=[VIS[vis][0]],
                data={"systems": systems, "plate": plate, "rf": rf or []}, layer=layer)


def tlc_free(subs, main, src, loc_, data=None, note=None, layer="substance"):
    """TLC entry with hand-written tri text (tables with several plates/systems)."""
    return dict(subs=subs if isinstance(subs, list) else [subs], family="tlc", text=_join(main, note, "tlc"), src=src,
                loc=loc_, cls="presumptive", cat="B", recipes=[], reagents=[], data=data or {}, layer=layer)


def micro(subs, main, src, loc_, recipes=None, note=None, layer="substance", reagents=None):
    return dict(subs=subs if isinstance(subs, list) else [subs], family="microcrystal", text=_join(main, note, "micro"),
                src=src, loc=loc_, cls="presumptive", cat="B", recipes=recipes or [], reagents=reagents or [],
                data={}, layer=layer)


def uv(subs, medium, maxima, src, loc_, note=None, layer="substance"):
    """UV maxima. medium: tri tuple; maxima: list of numbers (nm) as strings."""
    main = []
    for i, lang in enumerate(LANGS):
        vals = ", ".join(maxima)
        vals = dnum(vals, lang)
        if lang == "en":
            main.append(f"UV absorption maxima in {medium[i]}: {vals} nm.")
        elif lang == "uz":
            main.append(f"UB yutilish maksimumlari ({medium[i]}): {vals} nm.")
        else:
            main.append(f"Максимумы УФ-поглощения ({medium[i]}): {vals} нм.")
    return dict(subs=subs if isinstance(subs, list) else [subs], family="uv_spectrum", text=_join(tuple(main), note, "uv"),
                src=src, loc=loc_, cls="supporting", cat="B", recipes=[], reagents=[],
                data={"medium": medium[0], "nm": maxima}, layer=layer)


def generic(subs, family, main, src, loc_, tag, cls, cat=None, recipes=None, reagents=None, note=None,
            layer="substance", data=None):
    return dict(subs=subs if isinstance(subs, list) else [subs], family=family, text=_join(main, note, tag),
                src=src, loc=loc_, cls=cls, cat=cat, recipes=recipes or [], reagents=reagents or [],
                data=data or {}, layer=layer)
