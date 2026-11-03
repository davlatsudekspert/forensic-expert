#!/usr/bin/env python3
"""Xom videodan magenta belgisini topadi: marker_video_t (s). Ishlatish: sync.py raw.mkv"""
import subprocess, sys
def marker_time(raw, scan=40):
    W,H=39,84
    p=subprocess.Popen(['ffmpeg','-loglevel','error','-t',str(scan),'-i',raw,'-vf',f'scale={W}:{H}:flags=area,fps=30','-f','rawvideo','-pix_fmt','rgb24','-'],stdout=subprocess.PIPE)
    n=W*H*3; i=0; first=None; last=None
    while True:
        b=p.stdout.read(n)
        if len(b)<n: break
        r=sum(b[0::3])/(W*H); g=sum(b[1::3])/(W*H); bl=sum(b[2::3])/(W*H)
        mag = r>240 and g<12 and bl>240
        if mag:
            if first is None: first=i/30
            last=i/30
        elif first is not None: break
        i+=1
    p.kill()
    return first,last
if __name__=='__main__':
    print(marker_time(sys.argv[1]))
