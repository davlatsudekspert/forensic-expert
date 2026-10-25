import re,json
lines=[l.rstrip() for l in open('qa_up/qa.txt',encoding='utf8').read().split('\n')][1:]
isA=re.compile(r'^\s*[AА]\s*\)')
isOpt=re.compile(r'^\s*[A-DАВССД]\s*\)')
items=[];cur=None;state='q'
for l in lines:
    if not l.strip(): continue
    if state=='q':
        if isA.match(l):
            state='o';cur['opt_lines']=[l.strip()]
        else:
            if cur is None or cur.get('opt_lines'):
                cur={'q_lines':[l.strip()],'opt_lines':[]};items.append(cur)
            else: cur['q_lines'].append(l.strip())
    else:
        if isOpt.match(l) or not re.match(r'^\s*(\d+\s*\.|[A-ZА-Я])',l) or len(cur['opt_lines'])<4 and not re.match(r'^\s*\d+\s*\.',l):
            cur['opt_lines'].append(l.strip())
            if re.match(r'^\s*[DД]\s*\)',l) or ( len(cur['opt_lines'])==1 and re.search(r'[DД]\s*\)',l)): state='q'
        else:
            state='q'; cur={'q_lines':[l.strip()],'opt_lines':[]};items.append(cur)
def split_opts(text):
    pos=[];start=0
    for want in 'ABCD':
        alts={'A':'AА','B':'BВ','C':'CС','D':'DД'}[want]
        m=re.compile(r'(?:(?<=\s)|^|(?<=\*))['+alts+r']\s*\)\s*').search(text,start)
        if not m: return None
        pos.append((m.start(),m.end()));start=m.end()
    return [text[pos[i][1]:(pos[i+1][0] if i<3 else len(text))].strip() for i in range(4)]
out=[];bad=[]
for it in items:
    q=' '.join(it['q_lines']); num=None
    m=re.match(r'^\s*(\d{1,3})\s*\.\s*(.*)$',q)
    if m: num=int(m.group(1));q=m.group(2)
    o=split_opts(' '.join(it['opt_lines'])) if it['opt_lines'] else None
    if not o: bad.append((num,q[:50]));continue
    stars=[i for i,x in enumerate(o) if '*' in x]
    if len(stars)!=1: bad.append((num,q[:50],len(stars)));continue
    o2=[' '.join(x.replace('*','').split()) for x in o]
    out.append({'n':num,'q':' '.join(q.split()),'opts':o2,'key':stars[0]})
print('items',len(items),'ok',len(out),'bad',len(bad))
for b in bad[:25]: print(b)
json.dump(out,open('docx_keyed.json','w'),ensure_ascii=False)
