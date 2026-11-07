#!/usr/bin/env python3
"""sud_kimyo: UZ (rus tiliga tarjima qilingan, ru_llm_sud_kimyo.txt) va rasmiy RU orasida nomzod juftlar.
Natija faqat taklif (konsolga); yakuniy qaror qo‘lda: data/align_sud_kimyo.json.
Ishlatish: python3 -I match_sud_kimyo.py 0 200"""
import json, re, itertools, sys, os
D = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'data')
def toks(s):
    s=s.lower().replace('ё','е')
    w=re.findall(r'[a-zа-я0-9]+',s)
    return {x[:5] for x in w if len(x)>=3 or x.isdigit()} or {s.strip()}
def J(a,b): return len(a&b)/len(a|b) if a|b else 0
L={int(l.split('|')[0]):l.rstrip('\n').split('|')[1:] for l in open(os.path.join(D,'ru_llm_sud_kimyo.txt'))}
R={r['n']:r for r in json.load(open(os.path.join(D,'ru_parsed_sud_kimyo.json')))}
FL={n:(toks(v[0]),[toks(o) for o in v[1:]]) for n,v in L.items()}
FR={n:(toks(r['q']),[toks(o) for o in r['opts']]) for n,r in R.items()}
out=[]
for a in L:
    qa,oa=FL[a]
    for b in R:
        qb,ob=FR[b]
        M=[[J(oa[i],ob[j]) for j in range(4)] for i in range(4)]
        ps=sorted(itertools.permutations(range(4)),key=lambda p:-(sum(M[i][p[i]] for i in range(4))+(0.05 if p==(0,1,2,3) else 0)))
        p=ps[0]; av=sum(M[i][p[i]] for i in range(4))/4; q=J(qa,qb)
        if q>=0.25 and av>=0.25: out.append((q+av+(0.05 if p==(0,1,2,3) else 0),a,b,list(p),q,[round(M[i][p[i]],2) for i in range(4)]))
out.sort(reverse=True)
ua,ub,res=set(),set(),[]
for s,a,b,p,q,m in out:
    if a in ua or b in ub: continue
    ua.add(a); ub.add(b); res.append([a,b,p,round(q,2),m])
json.dump(res,open(os.devnull,'w'))
print(len(res))
lo,hi=int(sys.argv[1]),int(sys.argv[2])
for a,b,p,q,m in res[lo:hi]:
    diff=[i for i in range(4) if m[i]<0.6]
    s=f"{a}>{b} q{q} {'p'+str(p) if p!=[0,1,2,3] else ''}"
    if q<0.5: s+=f"\n  Lq:{L[a][0][:90]}\n  Rq:{R[b]['q'][:90]}"
    for i in diff: s+=f"\n  {i}: {L[a][1+i][:55]} ~ {R[b]['opts'][p[i]][:55]}"
    print(s)
