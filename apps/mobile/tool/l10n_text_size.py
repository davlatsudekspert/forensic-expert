"""Profil: shrift o‘lchami sozlamasi (egasi talabi, 2026-11-01) — uz/ru/en.
Tartib: `l10n_pm_diagrams.py` dan keyin, `l10n_ux_audit.py` dan oldin. Idempotent."""
import json, pathlib
D = pathlib.Path(__file__).resolve().parent.parent / 'lib/core/l10n/arb'
K = {
 'settingsTextSize': ('Shrift o‘lchami', 'Размер шрифта', 'Text size'),
 'textSizeNormal': ('Oddiy', 'Обычный', 'Normal'),
 'textSizeLarge': ('Katta', 'Крупный', 'Large'),
 'textSizeXLarge': ('Juda katta', 'Очень крупный', 'Extra large'),
}
for i, lang in enumerate(('uz', 'ru', 'en')):
    f = D / f'app_{lang}.arb'
    b = json.loads(f.read_text(encoding='utf-8'))
    for k, v in K.items():
        b[k] = v[i]
        if lang == 'en':
            b['@' + k] = {'description': 'Profile: in-app text size setting.'}
    f.write_text(json.dumps(b, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
print('l10n_text_size:', len(K), 'keys')
