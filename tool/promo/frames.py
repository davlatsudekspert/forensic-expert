#!/usr/bin/env python3
"""Sahna kadrlari (tekshiruv): frames.py <raw.mkv> <events.json> <outdir> [k]"""
import json,sys,subprocess,os
sys.path.insert(0,os.path.dirname(__file__))
from sync import marker_time
raw,ev,out=sys.argv[1:4]; k=float(sys.argv[4]) if len(sys.argv)>4 else 1.0
E=json.load(open(ev)); os.makedirs(out,exist_ok=True)
m=[e for e in E if e['type']=='marker'][0]['epoch']; st=[e for e in E if e['type']=='start'][0]['epoch']
mv,_=marker_time(raw)
def vt(epoch): return mv+(epoch-m)/1000.0   # real-time video t
for e in E:
    if e['type']=='scene':
        a,b=vt(e['start']),vt(e['end'])
        for j,f in enumerate((0.15,0.5,0.85)):
            t=a+(b-a)*f
            subprocess.run(['ffmpeg','-loglevel','error','-y','-ss',f'{t:.2f}','-i',raw,'-frames:v','1','-vf','scale=390:-1',f'{out}/{e["id"]}_{j}.png'])
print('marker',mv)
