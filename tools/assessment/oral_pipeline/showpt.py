import json,sys,glob
def load(f):
    d=json.load(open(f)); return d if isinstance(d,list) else d.get('questions',d)
qid,i=sys.argv[1],int(sys.argv[2])
for f in glob.glob('oral_out_*.json'):
    if 'pilot' in f: continue
    for q in load(f):
        if q['id']==qid:
            for k in (i-1,i,i+1):
                if 0<=k<len(q['points']): print(f'[{k}]',q['points'][k]['text'][:230])
