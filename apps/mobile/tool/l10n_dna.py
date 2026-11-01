"""DNK bo‘limi (2026-11-01) UI matnlari — uz/ru/en. Idempotent.

Tartib: `l10n_group_wording.py` dan keyin, `l10n_ux_audit.py` dan oldin.
Kontent (mavzular, savollar) asli o‘zbekcha; ru/en’da «tarjima kutilmoqda».
"""
import json, pathlib
D = pathlib.Path(__file__).resolve().parent.parent / 'lib/core/l10n/arb'
K = {
 'dnaTitle': ('DNK ekspertizasi', 'ДНК-экспертиза', 'Forensic DNA'),
 'dnaSubtitle': ('Sud-tibbiy molekulyar-genetik ekspertiza: namunalar, laboratoriya, talqin, sud',
                 'Судебно-медицинская молекулярно-генетическая экспертиза: образцы, лаборатория, интерпретация, суд',
                 'Forensic molecular genetics: samples, laboratory, interpretation, court'),
 'dnaIntro': ('Bo‘lim xalqaro tavsiyalar (ISFG, SWGDAM, ENFSI) va ilmiy adabiyot asosida tuzilgan. Har bir bayon manbasi va manbadagi joyi bilan berilgan.',
              'Раздел составлен по международным рекомендациям (ISFG, SWGDAM, ENFSI) и научной литературе. Каждое положение дано с источником и местом в нём.',
              'Built on international recommendations (ISFG, SWGDAM, ENFSI) and the scientific literature. Every statement is given with its source and location.'),
 'dnaCoreBody': ('STR, namunalar, talqin va sudda so‘roq', 'STR, образцы, интерпретация, допрос в суде', 'STR, samples, interpretation, court'),
 'homeNewTitle': ('YANGI BO‘LIMLAR', 'НОВЫЕ РАЗДЕЛЫ', 'NEW SECTIONS'),
 'homeNewVirtopsy': ('Virtual autopsiya', 'Виртуальная аутопсия', 'Virtual autopsy'),
 'dnaQuestionNumbered': ('{n}. {q}', '{n}. {q}', '{n}. {q}'),
 'dnaTopics': ('Mavzular', 'Темы', 'Topics'),
 'dnaCourt': ('Sudda so‘roq', 'Допрос в суде', 'Testifying in court'),
 'dnaCourtIntro': ('DNK ekspertiga beriladigan savollar: to‘g‘ri javob va ekspert aytmasligi kerak bo‘lgan narsa.',
                   'Вопросы эксперту по ДНК: корректный ответ и то, чего эксперт утверждать не должен.',
                   'Questions put to a DNA expert: a sound answer and what the expert must not claim.'),
 'dnaAnswer': ('Javob', 'Ответ', 'Answer'),
 'dnaBoundary': ('Ekspert aytmaydi', 'Эксперт не утверждает', 'The expert does not claim'),
 'dnaQuote': ('Asl matn', 'Исходный текст', 'Original text'),
 'dnaEquipment': ('DNK laboratoriyasi apparatlari', 'Оборудование ДНК-лаборатории', 'DNA laboratory equipment'),
 'dnaStatementCount': ('{n} ta manbali bayon', 'Положений с источником: {n}', '{n} sourced statements'),
 'dnaCourtCount': ('{n} ta savol', 'Вопросов: {n}', '{n} questions'),
 'dnaPendingTranslation': ('', 'Текст пока на узбекском — перевод готовится.', 'Text is in Uzbek for now — translation pending.'),
}
for i, lang in enumerate(('uz', 'ru', 'en')):
    f = D / f'app_{lang}.arb'
    b = json.loads(f.read_text(encoding='utf-8'))
    for k, v in K.items():
        b[k] = v[i] if v[i] or lang != 'uz' else 'Matn o‘zbek tilida.'
        if lang == 'en':
            meta = {'description': 'DNA (forensic genetics) section UI.'}
            if '{n}' in v[2]:
                meta['placeholders'] = {'n': {'type': 'int'}}
            if '{q}' in v[2]:
                meta['placeholders']['q'] = {'type': 'String'}
            b['@' + k] = meta
    f.write_text(json.dumps(b, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
print('l10n_dna:', len(K), 'keys')
