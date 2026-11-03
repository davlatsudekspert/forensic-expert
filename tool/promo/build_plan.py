#!/usr/bin/env python3
"""Sahna minimal davomiyliklari (plan.json) va audio jadvali.
   build_plan.py <video> -> $PROMO_WORK/<video>.plan.json
Qoida: audio_i = max(sahna_boshi+0.15, oldingi_audio_oxiri+0.25);
sahna uzunligi >= audio_i + dur_i + 0.7 - sahna_boshi.
Kartalar (ffmpeg): intro 2.5 s (ovoz bilan birga boshlanadi, sahnaga o'tadi),
outro/thanks - ovoz davomiyligiga qarab."""
import json, sys
SP='/tmp/claude-0/-home-user-forensic-expert/175c64be-a763-5e6d-b5d4-87e9aa8fedc6/scratchpad'
vid=sys.argv[1]
nar=json.load(open(f'/home/user/fe-docs/tool/promo/narration_{vid}.json'))
dur=json.load(open(f'{SP}/promo_audio/durations.json'))
CARDS={'intro':2.5,'outro':None,'thanks':None}
def plan(vid):
    t=0.0; prev_end=-1; out={}; audio={}
    for ln in nar['lines']:
        sc=ln['scene']; d=dur[ln['id']]/1000
        if sc=='intro':
            a=0.2; audio[ln['id']]=a; prev_end=a+d; t=2.5; continue
        a=max(t+0.15,prev_end+0.25); audio[ln['id']]=a; prev_end=a+d
        if sc in ('outro','thanks'):
            length=max(3.0,a+d+0.8-t) if sc=='outro' else max(5.0,a+d+0.8-t)
        else:
            length=a+d+0.7-t
        out[sc]=int(length*1000); t+=length
    return out,audio,t
if __name__=='__main__':
    out,audio,total=plan(vid)
    json.dump(out,open(f'{SP}/promo_work/{vid}.plan.json','w'),indent=1)
    print(out, 'total ~',round(total,1))
