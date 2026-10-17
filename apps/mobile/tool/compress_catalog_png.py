#!/usr/bin/env python3
"""Ekranlar katalogi PNG’larini 256 rangga siqadi (ko‘rib chiqish uchun yetarli,
hajm ~3 marta kichik). Ishlatish (apps/mobile ichida):
    python3 tool/compress_catalog_png.py ../../docs/qa/screen_catalog_20261017
"""
import glob
import os
import sys

from PIL import Image

d = sys.argv[1] if len(sys.argv) > 1 else "../../docs/qa/screen_catalog_20261017"
for f in glob.glob(os.path.join(d, "*.png")):
    im = Image.open(f).convert("RGB")
    im.quantize(
        colors=256, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.NONE
    ).save(f, optimize=True)
print("ok")
