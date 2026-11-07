import json,sys,re
sys.path.insert(0,'/tmp/pilot'); sys.path.insert(0,'/home/user/fe-pro/tools/slides')
import dx, build_pptx, srcmap
from u38_ru import RU
from u38_en import EN
d=json.load(open('/tmp/pilot/u38.deck.json')); S=dx.extract(d)
num=lambda s: sorted(re.findall(r'\d+(?:[.,]\d+)?',s))
bad=[]
for (p,uz),ru,en in zip(S,RU,EN):
    for nm,t in (('ru',ru),('en',en)):
        a=num(uz); b=num(t.replace(',','.') if False else t)
        norm=lambda L:[x.replace(',','.') for x in L]
        if norm(a)!=norm(b): bad.append((nm,uz[:50],a,b))
print('numeric mismatches',len(bad)); [print(x) for x in bad]
for lang,T in (('uz',[t for _,t in S]),('ru',RU),('en',EN)):
    dd=dx.apply(d,S,T); dd['lang']=lang
    if lang!='uz': dd=srcmap.localize(dd,lang)
    json.dump(dd,open(f'/tmp/pilot/u38_{lang}.json','w'),ensure_ascii=False)
    build_pptx.build(dd,f'/tmp/pilot/ktp26-u-38_{lang}.pptx',lang)
print('built')
