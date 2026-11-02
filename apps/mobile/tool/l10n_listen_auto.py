"""Dars «Tinglash» — ovoz tugagach avtomatik davom etish (egasi so‘rovi,
2026-11-02). Tartib: `l10n_student_panel.py` dan keyin. Idempotent."""
import json, pathlib
D = pathlib.Path(__file__).resolve().parent.parent / 'lib/core/l10n/arb'
K = {
 'lessonAutoVoice': ('Ovoz tugagach', 'После озвучки', 'After narration'),
 'lessonAutoVoiceRunning': ('Avto: o‘qib bo‘lingach keyingi slayd', 'Авто: после озвучки — следующий слайд', 'Auto: next slide after narration'),
 'lessonListenDone': ('Slayd o‘qib bo‘lindi', 'Слайд озвучен', 'Slide finished'),
 'lessonListenContinue': ('Davom ettirish', 'Продолжить', 'Continue'),
}
for i, lang in enumerate(('uz', 'ru', 'en')):
    f = D / f'app_{lang}.arb'
    b = json.loads(f.read_text(encoding='utf-8'))
    for k, v in K.items():
        b[k] = v[i]
        if lang == 'en':
            b['@' + k] = {'description': 'Lesson viewer: continuous listening.'}
    f.write_text(json.dumps(b, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
print('l10n_listen_auto:', len(K), 'keys')
