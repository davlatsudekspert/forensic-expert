#!/usr/bin/env python3
"""Promo rolik ovozi: narration_*.json dagi har `ru` qatori uchun MP3
(edge-tts) va `durations.json` (ms). Faqat GitHub Actions’da ishlatiladi
(WebSocket kerak). Foydalanish: tts.py <out_dir> <narration.json>..."""
import asyncio, json, pathlib, subprocess, sys

import edge_tts


async def say(text, voice, path):
    for attempt in range(4):
        try:
            await edge_tts.Communicate(text, voice, rate='-4%').save(str(path))
            return
        except edge_tts.exceptions.NoAudioReceived:
            if attempt == 3:
                raise
            await asyncio.sleep(3 * (attempt + 1))


async def main():
    out = pathlib.Path(sys.argv[1])
    out.mkdir(parents=True, exist_ok=True)
    durations = {}
    for path in sys.argv[2:]:
        spec = json.loads(pathlib.Path(path).read_text(encoding='utf-8'))
        voice = spec.get('voice', 'ru-RU-DmitryNeural')
        for line in spec['lines']:
            mp3 = out / f"{line['id']}.mp3"
            # `parts`: bir qatorda bir nechta ovoz (masalan, nom inglizcha);
            # aks holda butun `ru` matni qator/fayl ovozida.
            parts = line.get('parts') or [
                {'text': line['ru'], 'voice': line.get('voice', voice)}]
            pieces = []
            for k, part in enumerate(parts):
                piece = out / f"{line['id']}.part{k}.mp3"
                await say(part['text'], part.get('voice', voice), piece)
                pieces.append(piece)
            if len(pieces) == 1:
                pieces[0].rename(mp3)
            else:
                lst = out / f"{line['id']}.txt"
                lst.write_text(''.join(f"file '{x.name}'\n" for x in pieces))
                subprocess.check_call([
                    'ffmpeg', '-v', 'error', '-y', '-f', 'concat', '-safe', '0',
                    '-i', str(lst), '-ar', '24000', '-ac', '1', '-b:a', '64k',
                    str(mp3)])
                for x in pieces + [lst]:
                    x.unlink()
            ms = float(subprocess.check_output([
                'ffprobe', '-v', 'error', '-show_entries', 'format=duration',
                '-of', 'csv=p=0', str(mp3)]).decode().strip()) * 1000
            durations[line['id']] = round(ms)
            print(line['id'], voice, round(ms), 'ms')
    (out / 'durations.json').write_text(json.dumps(durations, indent=1))


asyncio.run(main())
