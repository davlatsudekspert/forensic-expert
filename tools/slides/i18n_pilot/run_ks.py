import json,sys,re
sys.path.insert(0,'/tmp/pilot'); sys.path.insert(0,'/home/user/fe-pro/tools/slides')
import dx, build_pptx, srcmap
from ks_ru_a import RU_A
from ks_ru_b import RU_B
from ks_en_a import EN_A
from ks_en_b import EN_B
RU=RU_A+RU_B; EN=EN_A+EN_B
d=json.load(open('/tmp/pilot/ks.deck.json')); S=dx.extract(d)
assert len(S)==len(RU)==len(EN)==411,(len(S),len(RU),len(EN))
num=lambda s: [x.replace(',','.') for x in re.findall(r'\d+(?:[.,]\d+)?',s)]
bad=[]
for i,((p,uz),ru,en) in enumerate(zip(S,RU,EN)):
    for nm,t in (('ru',ru),('en',en)):
        if sorted(num(uz))!=sorted(num(t)): bad.append((i,nm,uz[:60],num(uz),num(t)))
print('numeric mismatches',len(bad)); [print(x) for x in bad]
SUB={'uz':'Toksikologik kimyo · ma’ruza taqdimoti','ru':'Токсикологическая химия · лекционная презентация','en':'Toxicological chemistry · lecture presentation'}
for lang,T in (('uz',[t for _,t in S]),('ru',RU),('en',EN)):
    dd=dx.apply(d,S,T); dd['lang']=lang; dd['subtitle']=SUB[lang]
    if lang!='uz': dd=srcmap.localize(dd,lang)
    json.dump(dd,open(f'/tmp/pilot/ks_{lang}.json','w'),ensure_ascii=False)
    build_pptx.build(dd,f'/tmp/pilot/toks-21-toks-ksantin_{lang}.pptx',lang)
print('built')
