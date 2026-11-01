"""DNK paketi: o‘zbekcha atama yoniga birinchi uchraganda inglizcha asl
atama (egasi qarori, 2026-11-01: «inglizcha qolsin»). Idempotent."""
import json, re, sys
GLOSS = [
    (r'\b(propozitsiya)(lar|ning|ni|lari|larning|dan|da|ga)?\b', 'proposition'),
    (r'\b(faoliyat darajasi)(da|dagi|ni|ning)?\b', 'activity level'),
    (r'\b(manba darajasi)(da|dagi|ni|ning)?\b', 'source level'),
]
def gloss(text):
    for pat, en in GLOSS:
        if f'({en})' in text:
            continue
        text = re.sub(pat, lambda m: f'{m.group(0)} ({en})', text, count=1)
    return text
for p in sys.argv[1:]:
    d = json.load(open(p))
    n = 0
    for t in d['topics']:
        for s in t['statements']:
            new = gloss(s['uz']); n += new != s['uz']; s['uz'] = new
    for q in d['court_questions']:
        for k in ('q', 'good_answer_uz', 'boundary_uz'):
            if q.get(k):
                new = gloss(q[k]); n += new != q[k]; q[k] = new
    json.dump(d, open(p, 'w'), ensure_ascii=False, indent=1)
    print(p, n, 'texts glossed')
