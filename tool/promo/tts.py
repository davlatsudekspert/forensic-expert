#!/usr/bin/env python3
"""Promo rolik ovozi: narration_*.json dagi har `ru` qatori uchun MP3
(edge-tts) va `durations.json` (ms). Faqat GitHub Actions’da ishlatiladi
(WebSocket kerak). Foydalanish: tts.py <out_dir> <narration.json>..."""
import asyncio, json, pathlib, subprocess, sys

import edge_tts


async def main():
    out = pathlib.Path(sys.argv[1])
    out.mkdir(parents=True, exist_ok=True)
    durations = {}
    for path in sys.argv[2:]:
        spec = json.loads(pathlib.Path(path).read_text(encoding='utf-8'))
        voice = spec.get('voice', 'ru-RU-DmitryNeural')
        for line in spec['lines']:
            mp3 = out / f"{line['id']}.mp3"
            await edge_tts.Communicate(line['ru'], voice, rate='-4%').save(str(mp3))
            ms = float(subprocess.check_output([
                'ffprobe', '-v', 'error', '-show_entries', 'format=duration',
                '-of', 'csv=p=0', str(mp3)]).decode().strip()) * 1000
            durations[line['id']] = round(ms)
            print(line['id'], voice, round(ms), 'ms')
    (out / 'durations.json').write_text(json.dumps(durations, indent=1))


asyncio.run(main())
