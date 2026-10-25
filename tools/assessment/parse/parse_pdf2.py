import re,json
from parse_pdf import lines_of,clean,parse_marker
def blocks_sud(fn):
    L=lines_of(fn);xmax=max(x1 for *_,x1,t in L if t.strip())
    blocks=[];cur=[]
    for pn,x0,y0,x1,t in L:
        if t.strip()=='':
            if cur: blocks.append(cur);cur=[]
        else: cur.append((clean(t),x1))
    if cur: blocks.append(cur)
    return blocks,xmax
def parse_sud(fn):
    blocks,xmax=blocks_sud(fn);qs=[];n=1
    # blocks may be split by page boundary: merge blocks that don't start with a number
    merged=[]
    for b in blocks:
        if re.match(r'^%d\.'%n,b[0][0]) :
            merged.append(list(b));n+=1
        elif merged: merged[-1]+=b
    out=[]
    for b in merged:
        m=re.match(r'^(\d+)\.\s*(.*)$',b[0][0]);num=int(m.group(1))
        lines=[(m.group(2),b[0][1])]+b[1:]
        # question end: first line ending with : or ?
        qi=None
        for i,(t,x) in enumerate(lines):
            if re.search(r'[:?]\s*$',t) and i<len(lines)-1: qi=i;break
        if qi is None: qi=0
        qtxt=' '.join(t for t,_ in lines[:qi+1]);rest=lines[qi+1:]
        opts=None
        for th in (30,45,60,80,100,20):
            o=[]
            wrapped=False
            for t,x in rest:
                if wrapped and o: o[-1]=clean(o[-1]+' '+t)
                else: o.append(t)
                wrapped=x>xmax-th
            if len(o)==4: opts=o;break
        if opts is None: opts=[t for t,_ in rest]
        out.append({'n':num,'q':clean(qtxt),'opts':opts})
    return out
if __name__=='__main__':
    st=parse_sud('sudtib' if False else 'sud-tibbieti-testsajtgauzb435.pdf')
    bad=[q for q in st if len(q['opts'])!=4]
    print(len(st),'bad',len(bad))
    for q in bad[:8]: print(q['n'],q['q'][:80],q['opts'])
    json.dump(st,open('sud_tib_q.json','w'),ensure_ascii=False)
    pa=parse_marker('134-patanatom-test-sajt-uzb-441.pdf')
    seq=[q['n'] for q in pa]
    print('pat',len(pa),[ (a,b) for a,b in zip(seq,seq[1:]) if b!=a+1][:10], seq[-1])
