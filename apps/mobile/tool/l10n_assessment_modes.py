#!/usr/bin/env python3
"""«Bilim va malakani baholash» — test mashq usullari: aralash, bloklab,
xatolarim, imtihon rejimi (egasi so‘rovi, 2026-11-02). Tartib:
`l10n_listen_auto.py` dan keyin. Idempotent."""
import collections, json, pathlib

D = pathlib.Path(__file__).resolve().parent.parent / 'lib/core/l10n/arb'
I = {'type': 'int'}
# kalit: (tavsif, uz, ru, en, placeholderlar)
K = collections.OrderedDict()


def k(key, desc, uz, ru, en, ph=None):
    K[key] = (desc, uz, ru, en, ph)


k('assessmentMasteredLine', 'Specialty tests tab: mastered progress.',
  'O‘zlashtirildi: {x} / {y}', 'Освоено: {x} / {y}', 'Mastered: {x} / {y}',
  {'x': I, 'y': I})
k('assessmentModesTitle', 'Heading above the practice modes.',
  'Mashq usuli', 'Режим тренировки', 'Practice mode')
k('assessmentModeRandom', 'Practice mode: random 50.',
  'Aralash mashq', 'Смешанная тренировка', 'Mixed practice')
k('assessmentModeRandomDesc', 'Random mode description.',
  '50 ta tasodifiy savol, har javobdan keyin natija',
  '50 случайных вопросов, результат после каждого ответа',
  '50 random questions, verdict after every answer')
k('assessmentModeBlocks', 'Practice mode: blocks of 50 in order.',
  'Bloklab yechish', 'Решение блоками', 'Solve by blocks')
k('assessmentModeBlocksDesc', 'Blocks mode description.',
  'Savollar tartib bilan, 50 tadan blok',
  'Вопросы по порядку, блоки по 50',
  'Questions in order, blocks of 50')
k('assessmentModeMistakes', 'Practice mode: my mistakes.',
  'Xatolarim ({n})', 'Мои ошибки ({n})', 'My mistakes ({n})', {'n': I})
k('assessmentModeMistakesDesc', 'Mistakes mode description.',
  'Savol ketma-ket 2 marta to‘g‘ri javobdan keyin ro‘yxatdan chiqadi',
  'Вопрос уходит из списка после 2 верных ответов подряд',
  'A question leaves the list after 2 correct answers in a row')
k('assessmentModeMistakesEmpty', 'Mistakes mode hint when there are none.',
  'Hozircha xato yo‘q — noto‘g‘ri javoblaringiz shu yerga tushadi',
  'Ошибок пока нет — неверные ответы появятся здесь',
  'No mistakes yet — wrong answers will appear here')
k('assessmentModeExam', 'Practice mode: exam.',
  'Imtihon rejimi', 'Режим экзамена', 'Exam mode')
k('assessmentModeExamDesc', 'Exam mode description.',
  '50 savol, 60 daqiqa, natija faqat oxirida',
  '50 вопросов, 60 минут, результат только в конце',
  '50 questions, 60 minutes, result only at the end')
k('assessmentBlocksPick', 'Heading on the block picker.',
  'Blokni tanlang', 'Выберите блок', 'Choose a block')
k('assessmentBlockRange', 'Block label, e.g. 1–50.',
  'Savollar {a}–{b}', 'Вопросы {a}–{b}', 'Questions {a}–{b}', {'a': I, 'b': I})
k('assessmentBlockBest', 'Best saved score of a block.',
  'Eng yaxshi: {c}/{n}', 'Лучший результат: {c}/{n}', 'Best: {c}/{n}',
  {'c': I, 'n': I})
k('assessmentBlockUnsolved', 'Block not yet solved.',
  'Yechilmagan', 'Не решён', 'Not solved')
k('assessmentExamHint', 'Exam: note while answering.',
  'Natija imtihon oxirida ko‘rsatiladi',
  'Результат будет показан в конце экзамена',
  'The result is shown at the end of the exam')
k('assessmentExamTimeUp', 'Exam: time ran out.',
  'Vaqt tugadi', 'Время вышло', 'Time is up')
k('assessmentExamTimer', 'Exam countdown in the app bar (semantic label).',
  'Qolgan vaqt: {t}', 'Осталось: {t}', 'Time left: {t}', {'t': {'type': 'String'}})

for i, lang in enumerate(('uz', 'ru', 'en')):
    f = D / f'app_{lang}.arb'
    b = json.loads(f.read_text(encoding='utf-8'),
                   object_pairs_hook=collections.OrderedDict)
    for key, (desc, *vals, ph) in K.items():
        b[key] = vals[i]
        if lang == 'en':
            m = collections.OrderedDict(description=desc)
            if ph:
                m['placeholders'] = {n: dict(t) for n, t in ph.items()}
            b['@' + key] = m
    f.write_text(json.dumps(b, ensure_ascii=False, indent=2) + '\n',
                 encoding='utf-8')
print('l10n_assessment_modes:', len(K), 'keys')
