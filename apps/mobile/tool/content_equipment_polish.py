"""Equipment pack polish (visual audit Q1–Q6, 2026-11-01). Idempotent."""
import json, re, sys
P = 'assets/content/equipment/equipment_v1.json'
d = json.load(open(P))
ABBR = r'(HPLC-DAD|LC-DAD|KT|MRT|PMCT|PMCTA|PMMR|GC|LC|MS|HPLC|TLC|UB|DNK|UV-Vis|GC-MS|LC-MS/MS|COHb|Rf)'
SUF = r'(ga|da|dan|ning|ni|lar|larda|dagi|dek)'
def text(s):
    return re.sub(rf'\b{ABBR} {SUF}\b', r'\1\2', s)
def page(p):
    p = p.replace('ilovadagi yo‘riqnoma orqali', 'umumiy havola')
    p = re.sub(r'kitob beti (\d+)[–-](\d+)', r'\1–\2-betlar', p)
    p = re.sub(r'kitob beti (\d+)', r'\1-bet', p)
    p = re.sub(r'\b[sp]\.(\d+)[–-](\d+)', r'\1–\2-betlar', p)
    p = re.sub(r'\b[sp]\.(\d+)', r'\1-bet', p)
    return p
def walk(v):
    if isinstance(v, str): return text(v)
    if isinstance(v, list): return [walk(x) for x in v]
    if isinstance(v, dict): return {k: (walk(x) if k not in ('id','image','group','sources','links') else x) for k, x in v.items()}
    return v
items = []
for it in d['items']:
    it = walk(it)
    merged = {}
    for s in it.get('sources', []):
        s = dict(s); s['page'] = page(s.get('page', ''))
        k = (s.get('author'), s.get('title'))
        if k in merged:
            m = merged[k]
            if s['page'] and s['page'] not in m['page'].split('; '):
                m['page'] = m['page'] + '; ' + s['page']
            for f in ('doi', 'pmid'):
                if s.get(f) and not m.get(f): m[f] = s[f]
        else:
            merged[k] = s
    for m in merged.values():
        parts = m['page'].split('; ')
        if len(parts) > 1 and 'umumiy havola' in parts:
            m['page'] = '; '.join(x for x in parts if x != 'umumiy havola')
    it['sources'] = list(merged.values())
    if it['id'] == 'virtopsy' and it.get('national') and 'matbuot xabari' not in it['national']:
        it['national'] = it['national'].rstrip('.') + ' (markaz matbuot xabari, 2026).'
    items.append(it)
d['items'] = items
json.dump(d, open(P, 'w'), ensure_ascii=False, indent=1)
print('ok', sum(len(i['sources']) for i in items))
