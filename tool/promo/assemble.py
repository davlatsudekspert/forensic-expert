#!/usr/bin/env python3
"""Promo montaj: assemble.py <ustoz|talaba|yuldashev> [k]
Kiruvchi: promo_work/rec/<v>.raw.mkv + <v>.events.json, narration json, MP3.
Chiqish: promo_out/FORENSIC_EXPERT_<v>_ru_uz.mp4 (1080x1920, 30 fps)."""
import json, os, subprocess, sys, math, re
sys.path.insert(0, os.path.dirname(__file__))
from sync import marker_time
from PIL import Image, ImageDraw, ImageFont
vid=sys.argv[1]; K=float(sys.argv[2]) if len(sys.argv)>2 else 1.0
SP='/tmp/claude-0/-home-user-forensic-expert/175c64be-a763-5e6d-b5d4-87e9aa8fedc6/scratchpad'
W=f'{SP}/promo_work'; REC=f'{W}/rec'; TMP=f'{W}/asm_{vid}'; OUT=f'{SP}/promo_out'
os.makedirs(TMP,exist_ok=True); os.makedirs(OUT,exist_ok=True)
APP='/home/user/fe-pro/apps/mobile'
FONTS=f'{APP}/assets/fonts'
BG=(15,30,43); BGHEX='0x0F1E2B'
GOLD=(214,178,96); WHITE=(245,245,242); MUTED=(170,184,196)
nar=json.load(open(f'/home/user/fe-docs/tool/promo/narration_{vid}.json'))['lines']
dur={k:v/1000 for k,v in json.load(open(f'{SP}/promo_audio/durations.json')).items()}
audio_dir=f'{SP}/promo_audio'
def sh(cmd):
    r=subprocess.run(cmd,capture_output=True,text=True)
    if r.returncode: print(' '.join(cmd)); print(r.stderr[-2000:]); sys.exit(1)
FF=['ffmpeg','-loglevel','error','-y']

# ---------------------------------------------------------------- kartalar
CARDS={
 'ustoz':{'intro':('Ustozlar uchun',[]),
          'outro':('Dalil · Ilm · Aniqlik',['Darslar prof. G‘iyosov Z.A. darsliklari asosida'])},
 'talaba':{'intro':('Talabalar uchun',[]),
           'outro':('Dalil · Ilm · Aniqlik',['Darslar prof. G‘iyosov Z.A. darsliklari asosida'])},
 'yuldashev':{'intro':('Toksikologik kimyo',[]),
              'outro':('Dalil · Ilm · Aniqlik',[]),
              'thanks':None},
}[vid]
def font(path,size): return ImageFont.truetype(path,size)
SERIF=f'{FONTS}/source_serif_4/SourceSerif4-Bold.ttf'
INTER=f'{FONTS}/inter/Inter-SemiBold.ttf'; INTERR=f'{FONTS}/inter/Inter-Regular.ttf'
def base():
    im=Image.new('RGB',(1080,1920),BG)
    d=ImageDraw.Draw(im)
    for y in range(1920):  # yengil gradient
        t=y/1919; c=tuple(int(BG[i]*(1-t)+(26,48,66)[i]*t) for i in range(3)); d.line([(0,y),(1080,y)],fill=c)
    return im
def centered(d,text,y,f,fill,maxw=940):
    words=text.split(); lines=[]; cur=''
    for w in words:
        t=(cur+' '+w).strip()
        if d.textlength(t,font=f)<=maxw: cur=t
        else: lines.append(cur); cur=w
    lines.append(cur)
    for ln in lines:
        w=d.textlength(ln,font=f); d.text(((1080-w)/2,y),ln,font=f,fill=fill); y+=int(f.size*1.35)
    return y
def emblem():
    p=f'{APP}/assets/brand/3.0x/emblem_full_dark.png'
    if not os.path.exists(p): p=f'{APP}/assets/brand/emblem_full_dark.png'
    return Image.open(p).convert('RGBA')
def card(kind,sub,small):
    im=base(); d=ImageDraw.Draw(im)
    e=emblem(); e=e.resize((300,300),Image.LANCZOS); im.paste(e,(390,560),e)
    y=centered(d,'FORENSIC EXPERT',920,font(SERIF,92),GOLD)
    d.line([(440,y+10),(640,y+10)],fill=GOLD,width=3)
    y=centered(d,sub,y+50,font(INTER,54),WHITE)
    for s in small: y=centered(d,s,y+60,font(INTERR,38),MUTED,maxw=860)
    p=f'{TMP}/card_{kind}.png'; im.save(p); return p
def thanks_card():
    im=base(); d=ImageDraw.Draw(im)
    y=centered(d,'Rahmat!',380,font(SERIF,190),GOLD)
    d.line([(440,y+20),(640,y+20)],fill=GOLD,width=3)
    y=centered(d,'Yuldashev Z.A. ustoz va hammualliflarga — ushbu bo‘limlar asosi bo‘lgan o‘quv materiallari uchun',y+70,font(INTER,50),WHITE,maxw=900)
    y+=60
    for s in ['Toksikologik kimyo modulidan o‘quv-uslubiy majmua (TFI, 2025)','Giyohvand moddalar tahlili. O‘quv qo‘llanma (Toshkent, 2024)']:
        d.text((90,y+8),'•',font=font(INTER,38),fill=GOLD)
        y=centered_left(d,s,y,font(INTERR,38),MUTED,130,860)+22
    p=f'{TMP}/card_thanks.png'; im.save(p); return p
def centered_left(d,text,y,f,fill,x,maxw):
    words=text.split(); cur=''; lines=[]
    for w in words:
        t=(cur+' '+w).strip()
        if d.textlength(t,font=f)<=maxw: cur=t
        else: lines.append(cur); cur=w
    lines.append(cur)
    for ln in lines: d.text((x,y),ln,font=f,fill=fill); y+=int(f.size*1.35)
    return y
# ------------------------------------------------------------- sahnalar
ev=json.load(open(f'{REC}/{vid}.events.json'))
m_ep=[e for e in ev if e['type']=='marker'][0]['epoch']
mv,_=marker_time(f'{REC}/{vid}.raw.mkv'); assert mv is not None,'marker topilmadi'
scenes={e['id']:e for e in ev if e['type']=='scene'}
def vt(ep): return mv+(ep-m_ep)/1000.0
# mask
mask=Image.new('L',(720,1558),0); ImageDraw.Draw(mask).rounded_rectangle([0,0,719,1557],radius=46,fill=255); mask.save(f'{TMP}/mask.png')
segs=[]; # (scene, path, frames)
FPS=30
def mk_card(kind,length,fin=0.5,fout=0.5):
    if kind=='thanks': png=thanks_card()
    else: png=card(kind,*CARDS[kind])
    n=round(length*FPS); out=f'{TMP}/seg_{kind}.mp4'
    sh(FF+['-loop','1','-framerate',str(FPS),'-i',png,'-vf',f'fade=t=in:st=0:d={fin}:color={BGHEX},fade=t=out:st={length-fout:.3f}:d={fout}:color={BGHEX},format=yuv420p','-frames:v',str(n),'-c:v','libx264','-preset','veryfast','-crf','12',out])
    return out,n
def mk_scene(sc,fin=0,fout=0):
    e=scenes[sc]; a,b=vt(e['start']),vt(e['end']); L=(b-a)/K; n=round(L*FPS)
    out=f'{TMP}/seg_{sc}.mp4'
    fades=''
    if fin: fades+=f',fade=t=in:st=0:d={fin}:color={BGHEX}'
    if fout: fades+=f',fade=t=out:st={n/FPS-fout:.3f}:d={fout}:color={BGHEX}'
    fc=(f'[1:v]setpts=(PTS-STARTPTS)/{K},fps={FPS},scale=720:1558:flags=lanczos,format=yuva420p[a];'
        f'[2:v]format=gray[m];[a][m]alphamerge[ar];[0:v][ar]overlay=180:40:format=auto,format=yuv420p{fades}[v]')
    sh(FF+['-f','lavfi','-i',f'color=c={BGHEX}:s=1080x1920:r={FPS}','-ss',f'{a:.3f}','-t',f'{b-a:.3f}','-i',f'{REC}/{vid}.raw.mkv','-loop','1','-framerate',str(FPS),'-i',f'{TMP}/mask.png',
            '-filter_complex',fc,'-map','[v]','-frames:v',str(n),'-c:v','libx264','-preset','veryfast','-crf','12',out])
    return out,n
order=[l['scene'] for l in nar]
# audio satirlarini sahnalarga bog'lash, vaqt jadvali
tl=[]; t=0.0; audio=[]; prev_end=-1
first_scene=[s for s in order if s in scenes][0]; last_scene=[s for s in order if s in scenes][-1]
for ln in nar:
    sc=ln['scene']; d=dur[ln['id']]
    if sc=='intro':
        p,n=mk_card('intro',2.5,fin=0.5,fout=0.4); a=0.2
        tl.append((sc,p,n)); audio.append((ln,a)); prev_end=a+d; t+=n/FPS; continue
    if sc in ('outro','thanks'):
        a=max(t+0.15,prev_end+0.25)
        length=max(3.0 if sc=='outro' else 5.0, a+d+0.9-t)
        p,n=mk_card(sc,length,fin=0.5,fout=0.6 if sc=='outro' else 0.4)
        tl.append((sc,p,n)); audio.append((ln,a)); prev_end=a+d; t+=n/FPS; continue
    p,n=mk_scene(sc,fin=0.4 if sc==first_scene else 0, fout=0.4 if sc==last_scene else 0)
    a=max(t+0.15,prev_end+0.25); audio.append((ln,a)); prev_end=a+d
    need=a+d+0.4-t
    if n/FPS<need: print(f'OGOHLANTIRISH: {sc} sahna {n/FPS:.1f}s < kerak {need:.1f}s')
    tl.append((sc,p,n)); t+=n/FPS
total=t
open(f'{TMP}/list.txt','w').write(''.join(f"file '{p}'\n" for _,p,_ in tl))
sh(FF+['-f','concat','-safe','0','-i',f'{TMP}/list.txt','-c','copy',f'{TMP}/video_nosub.mp4'])
# ----------------------------------------------------------- subtitrlar
def split_sub(txt,maxc=62):
    if len(txt)<=maxc: return [txt]
    mid=len(txt)/2; best=None
    for mm in re.finditer(r'(?<=[,:;—]) |(?<=\.) | — ',txt):
        c=(mm.start()+mm.end())/2
        if best is None or abs(c-mid)<abs(best-mid): best=c; bm=mm
    if best is None:
        sp=[i for i,ch in enumerate(txt) if ch==' ']; i=min(sp,key=lambda i:abs(i-mid)); a,b=txt[:i],txt[i+1:]
    else: a,b=txt[:bm.start()+ (1 if txt[bm.start()] in ',:;.' else 0)].strip(),txt[bm.end():].strip()
    return split_sub(a,maxc)+split_sub(b,maxc)
def ts(x):
    h=int(x//3600); m=int(x%3600//60); s=x%60; return f'{h}:{m:02d}:{s:05.2f}'
ass=['[Script Info]','ScriptType: v4.00+','PlayResX: 1080','PlayResY: 1920','WrapStyle: 0','ScaledBorderAndShadow: yes','',
 '[V4+ Styles]','Format: Name,Fontname,Fontsize,PrimaryColour,SecondaryColour,OutlineColour,BackColour,Bold,Italic,Underline,StrikeOut,ScaleX,ScaleY,Spacing,Angle,BorderStyle,Outline,Shadow,Alignment,MarginL,MarginR,MarginV,Encoding',
 'Style: Sub,Inter SemiBold,46,&H00FFFFFF,&H00FFFFFF,&H00000000,&H00000000,0,0,0,0,100,100,0,0,1,3,1,2,70,70,92,1','',
 '[Events]','Format: Layer,Start,End,Style,Name,MarginL,MarginR,MarginV,Effect,Text']
for ln,a in audio:
    d=dur[ln['id']]; chunks=split_sub(ln['uz']); tot=sum(len(c) for c in chunks); x=a
    for c in chunks:
        dd=d*len(c)/tot
        ass.append(f'Dialogue: 0,{ts(x)},{ts(x+dd)},Sub,,0,0,0,,{c}'); x+=dd
open(f'{TMP}/subs.ass','w').write('\n'.join(ass)+'\n')
# ------------------------------------------------------------------ audio
ins=[]; fl=[]
for i,(ln,a) in enumerate(audio):
    ins+=['-i',f"{audio_dir}/{ln['id']}.mp3"]; ms=int(a*1000)
    fl.append(f'[{i+1}:a]aresample=44100,aformat=channel_layouts=mono,adelay={ms}|{ms}[a{i}]')
mix=''.join(f'[a{i}]' for i in range(len(audio)))
fl.append(f'{mix}amix=inputs={len(audio)}:normalize=0:duration=longest,loudnorm=I=-16:TP=-1.5:LRA=11,apad=whole_dur={total:.3f},aformat=channel_layouts=stereo[aout]')
final=f'{OUT}/FORENSIC_EXPERT_{vid}_ru_uz.mp4'
sh(FF+['-i',f'{TMP}/video_nosub.mp4']+ins+['-filter_complex',';'.join(fl),
   '-vf',f"ass={TMP}/subs.ass:fontsdir={FONTS}/inter",'-map','0:v','-map','[aout]',
   '-c:v','libx264','-crf','18','-preset','slow','-pix_fmt','yuv420p','-r','30','-c:a','aac','-b:a','160k','-t',f'{total:.3f}','-movflags','+faststart',final])
print('OK',final,round(total,1),'s')
json.dump({'timeline':[(s,n/FPS) for s,_,n in tl],'audio':[(l['id'],a) for l,a in audio]},open(f'{TMP}/timeline.json','w'),indent=1)
