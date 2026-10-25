import json,re,sys
W='/tmp/claude-0/-home-user-forensic-expert/06d2c950-1e58-56ea-9182-1c3fb48b561e/scratchpad/qwork'
cache={}
def pages(b):
    if b not in cache:
        t=open(f'{W}/book_{b}.txt',encoding='utf8').read()
        p=re.split(r'\n=====\[[^\]]+\] PDF-SAHIFA (\d+)=====\n',t)
        cache[b]={int(p[i]):re.sub(r'\s+',' ',p[i+1]) for i in range(1,len(p),2)}
    return cache[b]
d=json.load(open(sys.argv[1]))
bad=0
for q in d:
    for i,pt in enumerate(q['points']):
        qu=re.sub(r'\s+',' ',pt['quote']).strip()
        pg=pages(pt['book']).get(pt['page'],'')
        if qu not in pg or len(pt['quote'])>300:
            bad+=1; print('BAD',q['id'],i,len(pt['quote']),qu[:80])
print('entries',len(d),'bad',bad)
