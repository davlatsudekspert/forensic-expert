#!/usr/bin/env python3
"""Promo montaj v2 (REVISION 1): assemble_v2.py <ustoz2> (16:9) [k] [audio_dir]
 - ilova videosi to'liq balandlikda (888x1920), yumaloq burchak;
 - subtitr: yarim shaffof yumaloq quti (PNG overlay), sahnaga qarab pastda/tepada;
 - yangi audio (durations.json), rahmat kartasi (thanks + thanks_note bitta karta).
Raw yozuv va events.json qayta yozilmaydi."""
import json, os, subprocess, sys, re
sys.path.insert(0, os.path.dirname(__file__))
from sync import marker_time
from PIL import Image, ImageDraw, ImageFont
vid=sys.argv[1]; K=float(sys.argv[2]) if len(sys.argv)>2 else 6.0
SP='/tmp/claude-0/-home-user-forensic-expert/175c64be-a763-5e6d-b5d4-87e9aa8fedc6/scratchpad'
audio_dir=sys.argv[3] if len(sys.argv)>3 else f'{SP}/promo_audio'
W=f'{SP}/promo_work'; REC=f'{W}/rec'; TMP=f'{W}/asmw_{vid}'; OUT=f'{SP}/promo_out'
os.makedirs(TMP,exist_ok=True); os.makedirs(OUT,exist_ok=True)
APP='/home/user/fe-pro/apps/mobile'; FONTS=f'{APP}/assets/fonts'
BG=(15,30,43); BGHEX='0x0F1E2B'; GOLD=(214,178,96); WHITE=(245,245,242); MUTED=(176,190,202)
nar=json.load(open(f'/home/user/fe-docs/tool/promo/narration_{vid}.json'))['lines']
dur={k:v/1000 for k,v in json.load(open(f'{audio_dir}/durations.json')).items()}
POS=json.load(open(f'{W}/subpos_{vid}.json')) if os.path.exists(f'{W}/subpos_{vid}.json') else {}
def sh(cmd):
    r=subprocess.run(cmd,capture_output=True,text=True)
    if r.returncode: print(' '.join(cmd)); print(r.stderr[-2500:]); sys.exit(1)
FF=['ffmpeg','-loglevel','error','-y']; FPS=30
SERIF=f'{FONTS}/source_serif_4/SourceSerif4-Bold.ttf'
INTER=f'{FONTS}/inter/Inter-SemiBold.ttf'; INTERR=f'{FONTS}/inter/Inter-Regular.ttf'
def font(p,s): return ImageFont.truetype(p,s)
OUTRO_SUB={'ustoz':'Dalil · Ilm · Aniqlik','yuldashev':'Dalil · Ilm · Aniqlik','talaba':'Har kuni — ishonch bilan o‘rganing','ozi':'Har kuni — ishonch bilan tayyorlaning','ustoz2':'Dalil · Ilm · Aniqlik'}[vid]
INTRO_SUB={'ustoz':'Ustozlar uchun','talaba':'Talabalar uchun','yuldashev':'Toksikologik kimyo','ozi':'Talabalar uchun','ustoz2':'Ustozlar uchun'}[vid]
NOTE=[l for l in nar if l['scene']=='thanks_note'][0]['uz']
if vid=='yuldashev':
    THANKS='Professor Yuldashev Z.A. va hammualliflarga — ularning o‘quv materiallari talaba va mutaxassislar uchun ishonchli bilim manbai'
    BOOKS=['Toksikologik kimyo modulidan o‘quv-uslubiy majmua (TFI, 2025)','Giyohvand moddalar tahlili. O‘quv qo‘llanma (Toshkent, 2024)']
else:
    THANKS='Professor G‘iyosov Z.A. va barcha mualliflarga — ularning mehnati talaba va ustozlar uchun ishonchli bilim manbai'
    if vid in('talaba','ozi'):
        THANKS='Professorlar G‘iyosov\u00a0Z.A., Yuldashev\u00a0Z.A. va barcha mualliflarga — ularning mehnati talaba va ustozlar uchun ishonchli bilim manbai'
    BOOKS=[]
def base():
    im=Image.new('RGB',(1920,1080),BG); d=ImageDraw.Draw(im)
    for y in range(1080):
        t=y/1079; d.line([(0,y),(1920,y)],fill=tuple(int(BG[i]*(1-t)+(26,48,66)[i]*t) for i in range(3)))
    return im
def wrap(d,text,f,maxw):
    out=[];cur=''
    for w in text.split(' '):
        t=(cur+' '+w).strip()
        if d.textlength(t,font=f)<=maxw: cur=t
        else: out.append(cur);cur=w
    out.append(cur); return out
def centered(d,text,y,f,fill,maxw=940,lh=1.35):
    for ln in wrap(d,text,f,maxw):
        w=d.textlength(ln,font=f); d.text(((1080-w)/2,y),ln,font=f,fill=fill); y+=int(f.size*lh)
    return y
def emblem():
    p=f'{APP}/assets/brand/3.0x/emblem_full_dark.png'
    if not os.path.exists(p): p=f'{APP}/assets/brand/emblem_full_dark.png'
    return Image.open(p).convert('RGBA')
def card_brand(kind,sub):
    im=base(); d=ImageDraw.Draw(im)
    e=emblem().resize((300,300),Image.LANCZOS); im.paste(e,(390,560),e)
    y=centered(d,'FORENSIC EXPERT',920,font(SERIF,92),GOLD)
    d.line([(440,y+10),(640,y+10)],fill=GOLD,width=3)
    if sub: centered(d,sub,y+50,font(INTER,54),WHITE)
    p=f'{TMP}/card_{kind}.png'; im.save(p); return p
def card_thanks():
    im=base(); d=ImageDraw.Draw(im)
    y=centered(d,"Rahmat!",340,font(SERIF,190),GOLD)
    d.line([(440,y+20),(640,y+20)],fill=GOLD,width=3)
    y=centered(d,THANKS,y+70,font(INTER,50),WHITE,maxw=900)+30
    for b in BOOKS:
        f=font(INTERR,38); lines=wrap(d,b,f,820)
        d.text((100,y+6),'•',font=font(INTER,38),fill=GOLD)
        for ln in lines: d.text((150,y),ln,font=f,fill=MUTED); y+=52
        y+=14
    y+=50
    d.line([(90,y),(990,y)],fill=(60,84,104),width=2); y+=36
    f=font(INTERR,36)
    for ln in wrap(d,NOTE,f,880): d.text((100,y),ln,font=f,fill=MUTED); y+=52
    p=f'{TMP}/card_thanks.png'; im.save(p); return p

def centered_w(d,text,y,f,fill,maxw=1500,lh=1.3,cx=960):
    for ln in wrap(d,text,f,maxw):
        wd=d.textlength(ln,font=f); d.text((cx-wd/2,y),ln,font=f,fill=fill); y+=int(f.size*lh)
    return y
def card_brand(kind,sub):
    im=base(); d=ImageDraw.Draw(im)
    e=emblem().resize((260,260),Image.LANCZOS); im.paste(e,(830,200),e)
    y=centered_w(d,'FORENSIC EXPERT',500,font(SERIF,100),GOLD)
    d.line([(860,y+10),(1060,y+10)],fill=GOLD,width=3)
    if sub: centered_w(d,sub,y+50,font(INTER,52),WHITE)
    p=f'{TMP}/card_{kind}.png'; im.save(p); return p
def card_thanks():
    im=base(); d=ImageDraw.Draw(im)
    y=centered_w(d,"Rahmat!",120,font(SERIF,170),GOLD)
    d.line([(860,y+10),(1060,y+10)],fill=GOLD,width=3)
    y=centered_w(d,THANKS,y+50,font(INTER,46),WHITE,maxw=1400)+20
    for b in BOOKS:
        y=centered_w(d,'• '+b,y,font(INTERR,34),MUTED,maxw=1400)+6
    y+=30
    d.line([(300,y),(1620,y)],fill=(60,84,104),width=2); y+=26
    centered_w(d,NOTE,y,font(INTERR,32),MUTED,maxw=1400)
    p=f'{TMP}/card_thanks.png'; im.save(p); return p
# ---------------------------------------------------------------- sahnalar
def load_src(name):
    ev=json.load(open(f'{REC}/{name}.events.json'))
    m_ep=[e for e in ev if e['type']=='marker'][0]['epoch']
    mv,_=marker_time(f'{REC}/{name}.raw.mkv'); assert mv is not None
    return {'raw':f'{REC}/{name}.raw.mkv','m_ep':m_ep,'mv':mv,'scenes':{e['id']:e for e in ev if e['type']=='scene'}}
MAIN=load_src(vid)
EXTRAS={'ustoz':['ustoz_extra','ustoz_lit'],'talaba':['talaba_extra','talaba_extra2','talaba_lit','talaba_desk','extra5','extra6','extra8'],'yuldashev':['talaba_extra','yuldashev_spe','extra5'],'ozi':[],'ustoz2':[]}[vid]
SRC={sid:MAIN for sid in MAIN['scenes']}
for nm in EXTRAS:
    if os.path.exists(f'{REC}/{nm}.events.json'):
        ex=load_src(nm)
        for sid in ex['scenes']: SRC[sid]=ex
scenes={sid:SRC[sid]['scenes'][sid] for sid in SRC}
def vt(ep,src): return src['mv']+(ep-src['m_ep'])/1000.0
AW=500; PX=1340
mask=Image.new('L',(AW,1080),0); ImageDraw.Draw(mask).rounded_rectangle([0,0,AW-1,1079],radius=30,fill=255); mask.save(f'{TMP}/mask.png')
def enc(): return ['-c:v','libx264','-preset','veryfast','-crf','12','-pix_fmt','yuv420p']
def mk_card(name,png,length,fin,fout):
    n=round(length*FPS); out=f'{TMP}/seg_{name}.mp4'
    sh(FF+['-loop','1','-framerate',str(FPS),'-i',png,'-vf',f'fade=t=in:st=0:d={fin}:color={BGHEX},fade=t=out:st={n/FPS-fout:.3f}:d={fout}:color={BGHEX},format=yuv420p','-frames:v',str(n)]+enc()+[out])
    return out,n
def mk_scene(sc,need,fin=0,fout=0):
    src=SRC[sc]; e=scenes[sc]; a,b=vt(e['start'],src),vt(e['end'],src); L=(b-a)/K
    total=max(L,need); n=round(total*FPS); out=f'{TMP}/seg_{sc}.mp4'
    pad=max(0.0,total-L)
    fades=''
    if fin: fades+=f',fade=t=in:st=0:d={fin}:color={BGHEX}'
    if fout: fades+=f',fade=t=out:st={n/FPS-fout:.3f}:d={fout}:color={BGHEX}'
    tp=f',tpad=stop_mode=clone:stop_duration={pad+0.2:.3f}' if pad>0 else ''
    fc=(f'[1:v]setpts=(PTS-STARTPTS)/{K},fps={FPS}{tp},scale={AW}:1080:flags=lanczos,format=yuva420p[a];'
        f'[2:v]format=gray[m];[a][m]alphamerge[ar];[0:v][ar]overlay={PX}:0:format=auto,format=yuv420p{fades}[v]')
    sh(FF+['-f','lavfi','-i',f'color=c={BGHEX}:s=1920x1080:r={FPS}','-ss',f'{a:.3f}','-t',f'{b-a:.3f}','-i',src['raw'],'-loop','1','-framerate',str(FPS),'-i',f'{TMP}/mask.png',
          '-filter_complex',fc,'-map','[v]','-frames:v',str(n)]+enc()+[out])
    return out,n,L
tl=[]; t=0.0; audio=[]; prev_end=-1.0
order=[l for l in nar]
scene_ids=[l['scene'] for l in nar if l['scene'] in scenes]
first_scene,last_scene=scene_ids[0],scene_ids[-1]
card_start=None
for ln in nar:
    sc=ln['scene']; d=dur[ln['id']]
    if sc=='intro':
        p,n=mk_card('intro',card_brand('intro',INTRO_SUB),2.5,0.5,0.4); a=0.2
        tl.append((sc,p,n,0.0,t)); audio.append((ln,a,sc)); prev_end=a+d; t+=n/FPS; continue
    if sc=='thanks':
        a=max(t+0.3,prev_end+0.25); audio.append((ln,a,sc)); prev_end=a+d; card_start=t; continue
    if sc=='thanks_note':
        a=prev_end+0.35; audio.append((ln,a,sc)); prev_end=a+d
        length=prev_end+0.8-card_start
        p,n=mk_card('thanks',card_thanks(),length,0.5,0.4)
        tl.append(('thanks',p,n,0.0,card_start)); t=card_start+n/FPS; continue
    if sc=='outro':
        a=max(t+0.2,prev_end+0.25); length=max(3.0,a+d+0.9-t)
        p,n=mk_card('outro',card_brand('outro',OUTRO_SUB),length,0.5,0.6)
        tl.append((sc,p,n,0.0,t)); audio.append((ln,a,sc)); prev_end=a+d; t+=n/FPS; continue
    a=max(t+0.15,prev_end+0.25); need=a+d+0.4-t
    p,n,L=mk_scene(sc,need,fin=0.4 if sc==first_scene else 0,fout=0.4 if sc==last_scene and False else 0)
    if L<need: print(f'  {sc}: yozuv {L:.1f}s < kerak {need:.1f}s -> oxirgi kadr ushlab turiladi')
    audio.append((ln,a,sc)); prev_end=a+d; tl.append((sc,p,n,L,t)); t+=n/FPS
total=t
open(f'{TMP}/list.txt','w').write(''.join(f"file '{p}'\n" for _,p,_,_,_ in tl))
sh(FF+['-f','concat','-safe','0','-i',f'{TMP}/list.txt','-c','copy',f'{TMP}/video_nosub.mp4'])
# --------------------------------------------------------------- subtitrlar
SF=font(INTER,44)
dm=ImageDraw.Draw(Image.new('RGB',(10,10)))
def split_sub(txt,maxc=60):
    if len(txt)<=maxc: return [txt]
    mid=len(txt)/2; best=None; bm=None
    for mm in re.finditer(r'(?<=[,:;.]) | — ',txt):
        c=(mm.start()+mm.end())/2
        if best is None or abs(c-mid)<abs(best-mid): best=c; bm=mm
    if bm is None:
        sp=[i for i,ch in enumerate(txt) if ch==' ']; i=min(sp,key=lambda i:abs(i-mid)); a,b=txt[:i],txt[i+1:]
    else:
        a=txt[:bm.start()+(1 if txt[bm.start()] in ',:;.' else 0)].strip(); b=txt[bm.end():].strip()
    return split_sub(a,maxc)+split_sub(b,maxc)
def sub_png(text,name):
    lines=wrap(dm,text,SF,1040)
    if len(lines)>2: return None
    w=int(max(dm.textlength(l,font=SF) for l in lines))+72; h=len(lines)*60+52
    im=Image.new('RGBA',(w,h),(0,0,0,0)); d=ImageDraw.Draw(im)
    d.rounded_rectangle([0,0,w-1,h-1],radius=26,fill=(12,22,32,224))
    y=26
    for l in lines:
        lw=d.textlength(l,font=SF); d.text(((w-lw)/2,y-4),l,font=SF,fill=(255,255,255,255)); y+=60
    p=f'{TMP}/{name}.png'; im.save(p); return p,w,h

STEPF=font(INTER,52); HEADF=font(INTER,34)
def steps_png(steps,name):
    W_,H_=1160,560
    im=Image.new('RGBA',(W_,H_),(0,0,0,0)); d=ImageDraw.Draw(im)
    d.rounded_rectangle([0,0,W_-1,H_-1],radius=30,fill=(12,22,32,190))
    d.text((44,30),'QADAMLAR',font=HEADF,fill=GOLD+(255,))
    y=96
    for i,t in enumerate(steps,1):
        d.ellipse([44,y+4,44+60,y+64],fill=GOLD+(255,))
        nw=d.textlength(str(i),font=STEPF); d.text((74-nw/2,y+2),str(i),font=STEPF,fill=(15,30,43,255))
        for ln in wrap(d,t,STEPF,980):
            d.text((130,y+2),ln,font=STEPF,fill=(255,255,255,255)); y+=64
        y+=26
    p=f'{TMP}/{name}.png'; im.save(p); return p,W_,H_
subs=[]  # (png,x,y,start,end)
k=0
for ln,a,sc in audio:
    if sc=='thanks' or sc=='thanks_note': continue
    d=dur[ln['id']]; maxc=62
    while True:
        chunks=split_sub(ln['uz'],maxc); res=[sub_png(c,f's{k}_{i}') for i,c in enumerate(chunks)]
        if all(res): break
        maxc-=6
    k+=1; tot=sum(len(c) for c in chunks); x0=a
    for c,r in zip(chunks,res):
        dd=d*len(c)/tot; p,w,h=r
        pos=POS.get(sc,'bottom')
        y=1000-h  # BITTA qat'iy joy (barcha sahnalar): pastki chekka 1850; «Manba» qatori ochiq qoladi
        subs.append((p,80+(1180-w)//2,y,x0,x0+dd)); x0+=dd
STEPS={l['scene']:l['steps'] for l in nar if l.get('steps')}
for sc,pth,n,Lx,t0 in tl:
    if sc in STEPS:
        pp,pw,ph=steps_png(STEPS[sc],f'steps_{sc}')
        subs.append((pp,80,230,t0+0.2,t0+n/FPS-0.1))
ins=[]; fcs=[]; prev='[0:v]'
for i,(p,x,y,s,e) in enumerate(subs):
    ins+=['-loop','1','-framerate',str(FPS),'-t',f'{total:.2f}','-i',p]
    out=f'[v{i}]'
    fcs.append(f"{prev}[{i+1}:v]overlay={x}:{y}:enable='between(t,{s:.3f},{e:.3f})'{out}"); prev=out
# audio
base_i=len(subs)+1; ain=[]; afl=[]
for j,(ln,a,sc) in enumerate(audio):
    ain+=['-i',f"{audio_dir}/{ln['id']}.mp3"]; ms=int(a*1000)
    afl.append(f'[{base_i+j}:a]aresample=44100,aformat=channel_layouts=mono,adelay={ms}|{ms}[a{j}]')
mix=''.join(f'[a{j}]' for j in range(len(audio)))
afl.append(f'{mix}amix=inputs={len(audio)}:normalize=0:duration=longest,loudnorm=I=-16:TP=-1.5:LRA=11,apad=whole_dur={total:.3f},aformat=channel_layouts=stereo[aout]')
final=f'{OUT}/FORENSIC_EXPERT_{vid}_ru_uz_16x9.mp4'
fc=';'.join(fcs+afl)
sh(FF+['-i',f'{TMP}/video_nosub.mp4']+ins+ain+['-filter_complex',fc,'-map',prev,'-map','[aout]',
   '-c:v','libx264','-crf','18','-preset','slow','-pix_fmt','yuv420p','-r','30','-c:a','aac','-b:a','160k','-t',f'{total:.3f}','-movflags','+faststart',final])
print('OK',final,round(total,1),'s')
json.dump({'timeline':[(s,round(n/FPS,2),round(tt,2)) for s,_,n,_,tt in tl],'audio':[(l['id'],round(a,2),sc) for l,a,sc in audio],'subs':[(round(s,2),round(e,2),y) for _,_,y,s,e in subs]},open(f'{TMP}/timeline.json','w'),indent=1)
