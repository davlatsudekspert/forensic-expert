import pymupdf,re,json
D='tests_dl/'
def lines_of(fn):
    d=pymupdf.open(D+fn);out=[]
    for pn,pg in enumerate(d):
        for b in pg.get_text('dict')['blocks']:
            for l in b.get('lines',[]):
                t=''.join(s['text'] for s in l['spans'])
                out.append((pn,l['bbox'][0],l['bbox'][1],l['bbox'][2],t))
    return out
def clean(s): return ' '.join(s.replace(' ',' ').split())
def parse_marker(fn):
    L=lines_of(fn);qs=[];cur=None;opt=None;marker=False
    for pn,x0,y0,x1,t in L:
        if t.strip()=='' and 99<x0<103: marker=True;continue
        if t.strip()=='': continue
        m=re.match(r'^\s*(\d+)\s+(.*)$',t) if x0<99 else None
        if m:
            cur={'n':int(m.group(1)),'q':clean(m.group(2)),'opts':[]};qs.append(cur);opt=None;marker=False;continue
        if cur is None: continue
        if marker:
            cur['opts'].append(clean(t));opt=cur['opts'];marker=False
        else:
            if cur['opts']: cur['opts'][-1]=clean(cur['opts'][-1]+' '+t)
            else: cur['q']=clean(cur['q']+' '+t)
    return qs
def parse_blank(fn,rm=None):
    L=lines_of(fn);qs=[];cur=None
    xmax=max(x1 for *_,x1,t in L if t.strip()) 
    wrap=xmax-30
    prev_wrapped=False
    for pn,x0,y0,x1,t in L:
        if t.strip()=='':
            prev_wrapped=False;continue
        m=re.match(r'^\s*(\d+)\.\s*(.*)$',t) if not prev_wrapped else None
        if m and (not qs or int(m.group(1))==qs[-1]['n']+1):
            cur={'n':int(m.group(1)),'q':clean(m.group(2)),'opts':[],'lines':1};qs.append(cur);first=True
        elif cur is not None:
            if prev_wrapped:
                if cur['opts']: cur['opts'][-1]=clean(cur['opts'][-1]+' '+t)
                else: cur['q']=clean(cur['q']+' '+t)
            else:
                # question text ended? if q does not look finished and no opts yet and previous wrapped handled
                cur['opts'].append(clean(t))
        prev_wrapped = x1>wrap
    return qs
if __name__=='__main__':
    pa=parse_marker('134-patanatom-test-sajt-uzb-441.pdf')
    st=parse_blank('sud-tibbieti-testsajtgauzb435.pdf')
    for name,qs in [('pat_anat',pa),('sud_tib',st)]:
        bad=[q for q in qs if len(q['opts'])!=4]
        seq=[q['n'] for q in qs]
        print(name,len(qs),'bad',len(bad),'seq ok',seq==list(range(1,len(qs)+1)))
        for q in bad[:6]: print('  ',q['n'],q['q'][:70],q['opts'])
    json.dump({'pat_anat':pa,'sud_tib':st},open('pdf_parsed2.json','w'),ensure_ascii=False)
