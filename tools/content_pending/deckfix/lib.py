import json,copy,os
W=os.path.dirname(os.path.abspath(__file__))
GIY={"author":"G‘iyosov Z.A.","title":"Sud tibbiyoti: darslik, Toshkent: Global Books nashriyoti"}
ISK={"author":"Iskandarov A.I., Qo‘ldoshev D.R.","title":"Sud tibbiyoti (tibbiyot instituti talabalari uchun), Toshkent (egasi taqdim etgan; yopiq foydalanish)"}
PIG={"author":"Пиголкин Ю.И., Баринов Е.Х., Богомолов Д.В., Богомолова И.Н.","title":"Судебная медицина: учебник для вузов, М.: ГЭОТАР-МЕД (egasi taqdim etgan; yopiq foydalanish)"}
TAG={"author":"Тагаев Н.Н. (Tagaev N.N.)","title":"Судебная медицина: учебник, Харьков: Факт (egasi taqdim etgan; yopiq foydalanish)"}
SIM={"author":"Payne-James J., Jones R., Karch S.B., Manlove J.","title":"Simpson's Forensic Medicine, 13th ed."}
ROM={"author":"Ромодановский П.О., Баринов Е.Х.","title":"Судебная медицина в схемах и рисунках: учебное пособие, М.: Проспект (egasi taqdim etgan; yopiq foydalanish)"}
def src(base,page): d=dict(base); d["page"]=str(page); return {"page":d["page"],"title":d["title"],"author":d["author"]}
def slide(title,bullets,notes,base=None,diagram=None):
    """bullets: list of (text,base,page)"""
    return {"title":title,"bullets":[{"text":t,"source":src(b,p),"uncertain":False} for t,b,p in bullets],"diagram":diagram,"teacher_notes":notes}
def load(deck_id):
    return json.load(open(f"{W}/work/orig_{deck_id}.json"))
def build(deck_id,plan,sources_add=(),drop_extras=(),extras_add=(),changes_extra=None):
    """plan: list of ('k',idx) | ('r',idx,patchdict) | ('n',slide)"""
    o=load(deck_id); deck=copy.deepcopy(o['deck']); old=o['deck']['slides']
    new=[];changes=[];used=set()
    for i,p in enumerate(plan):
        if p[0]=='k': new.append(copy.deepcopy(old[p[1]])); used.add(p[1])
        elif p[0]=='r':
            s=copy.deepcopy(old[p[1]]); s.update(p[2]); new.append(s); used.add(p[1])
            changes.append({"slide_index":len(new)-1,"action":"rewritten","reason":p[3] if len(p)>3 else "mavzuga moslashtirildi","old_index":p[1]})
        else:
            new.append(p[1]); changes.append({"slide_index":len(new)-1,"action":"new","reason":p[2] if len(p)>2 else "mavzuni to‘ldiruvchi yangi slayd"})
    for i,s in enumerate(old):
        if i not in used: changes.append({"slide_index":None,"action":"removed","reason":f"eski #{i} «{s['title']}» — mavzuga aloqasi yo‘q yoki boshqa mavzuga oid","old_index":i})
    deck['slides']=new
    deck['extras']=[e for j,e in enumerate(deck.get('extras',[])) if j not in set(drop_extras)]+list(extras_add)
    deck['sources']=deck.get('sources',[])+list(sources_add)
    return o,deck,changes
def write(deck_id,o,deck,changes,qrep,not_found):
    out={"deck_id":deck_id,"title":o['title'],"new_deck":deck,"changes":changes,"quiz_replacements":qrep,"not_found":not_found}
    json.dump(out,open(f"{W}/{deck_id}.json","w"),ensure_ascii=False,separators=(',',':'))
    validate(deck_id)
def validate(deck_id):
    out=json.load(open(f"{W}/{deck_id}.json")); d=out['new_deck']; bad=[]
    if len(d['slides'])!=len(d['slides']): pass
    n=0
    for i,s in enumerate(d['slides']):
        for b in s['bullets']:
            n+=1
            if not b.get('source') or not str(b['source'].get('page','')).strip(): bad.append((i,'nopage',b['text'][:40]))
            if len(b['text'])>160: bad.append((i,'long%d'%len(b['text']),b['text'][:30]))
    txt=json.dumps(out,ensure_ascii=False)
    if '__keep' in txt or 'placeholder' in txt.lower(): bad.append('placeholder')
    for q in out['quiz_replacements']:
        if len(q['options'])!=4 or not (0<=q['correct_index']<4) or not q.get('explanation') or not q.get('source'): bad.append(('quiz',q['replaces_id']))
    print(deck_id,'slides',len(d['slides']),'bullets',n,'bad',bad)
    return bad

_QS=None
def Q(deck_id,pos,question,correct,wrongs,expl,base,page,seed=0):
    global _QS
    qs=json.load(open(f"{W}/work/quiz_all.json"))
    row=[x for x in qs if x['topic_id']==deck_id and x['position']==pos][0]
    k=(pos*3+seed+1)%4
    opts=list(wrongs); opts.insert(k,correct)
    return {"replaces_id":row['id'],"replaces_position":pos,"topic_id":deck_id,"topic_title":row['topic_title'],"position":pos,"question":question,"options":opts,"correct_index":k,"explanation":expl,"source":src(base,page),"is_demo":False}
