import json,re,sys
files={'sud_tib':'8e24dea0.txt','sud_kimyo':'a72f5bf6.txt','pat_anat':'fb2f2d10.txt','toks':'bc9ab0dc.txt'}
out={}
for sid,f in files.items():
    cats={'c23':[],'c1':[],'c0':[]};cur=None
    for line in open('/tmp/ru_oral/'+f,encoding='utf8'):
        t=re.sub(r'\s+',' ',line).strip()
        if not t: continue
        if t.startswith('Вопросы для третьей'): cur='c23';continue
        if t.startswith('Вопросы для первой'): cur='c1';continue
        if t.startswith('Вопросы для высшей'): cur='c0';continue
        if cur:
            if cats[cur] and cats[cur][-1].endswith(','):
                cats[cur][-1]+=' '+t
            else:
                cats[cur].append(t)
    out[sid]=cats
    print(sid,{k:len(v) for k,v in cats.items()})
json.dump(out,open(sys.argv[1],'w'),ensure_ascii=False,indent=1)
