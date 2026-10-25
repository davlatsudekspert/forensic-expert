import json,re,difflib
def norm(s):
    s=s.lower()
    for a in "‘’ʻʼ`´'": s=s.replace(a,'')
    s=s.replace('х','x')
    return re.sub(r'[^a-z0-9а-я]+',' ',s).strip()
dk=json.load(open('docx_keyed.json'))
kim=json.load(open('tests_parsed.json'))['sud_kimyo']
# fix Q154 bad
byq={}
for d in dk: byq.setdefault(norm(d['q']),[]).append(d)
res=[];nomatch=[];conflicts=[]
for p in kim:
    cands=byq.get(norm(p['q']),[])
    if not cands:
        # fuzzy
        ks=list(byq)
        m=difflib.get_close_matches(norm(p['q']),ks,n=1,cutoff=0.93)
        cands=byq[m[0]] if m else []
    idxs=set()
    for d in cands:
        kt=norm(d['opts'][d['key']])
        for i,o in enumerate(p['opts']):
            if norm(o)==kt or difflib.SequenceMatcher(None,norm(o),kt).ratio()>0.94: idxs.add(i);break
    found=list(idxs)[0] if len(idxs)==1 else None
    if len(idxs)>1: conflicts.append(p['n'])
    res.append(found)
    if found is None: nomatch.append(p['n'])
print('pdf',len(kim),'keyed',sum(r is not None for r in res),'unkeyed',len(nomatch))
json.dump({'keys':res},open('kimyo_keys.json','w'))
# agreement test: positional first
print('first-option==key',sum(1 for r in res if r==0),'of',sum(r is not None for r in res))
print('conflicts',conflicts)
json.dump({'keys':res,'conflicts':conflicts},open('kimyo_keys.json','w'))
