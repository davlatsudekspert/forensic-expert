"""Deck JSON <-> tarjima qatorlari. extract(deck)->[(path,text)]; apply(deck, mapping)->deck."""
import copy, json, re
SKIP_KEYS = {"sources", "kind", "source", "layout", "uncertain", "page", "author", "year", "pages", "title_font", "editorial_status", "lang"}
def walk(o, path, out):
    if isinstance(o, dict):
        for k, v in o.items():
            if k in SKIP_KEYS: continue
            walk(v, path + [k], out)
    elif isinstance(o, list):
        for i, v in enumerate(o): walk(v, path + [i], out)
    elif isinstance(o, str) and re.search(r"[A-Za-zА-Яа-яЎўҚқҒғҲҳ‘’']{2}", o):
        out.append((path, o))
def extract(deck):
    out = []; walk(deck, [], out); return out
def put(deck, path, val):
    o = deck
    for p in path[:-1]: o = o[p]
    o[path[-1]] = val
def apply(deck, strings, tr):
    d = copy.deepcopy(deck)
    for (path, _), t in zip(strings, tr): put(d, path, t)
    return d
