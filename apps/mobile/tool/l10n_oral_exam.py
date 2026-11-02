#!/usr/bin/env python3
"""«Bilim va malakani baholash» — og‘zaki imtihon: 5 savollik bilet, har
savolga 0–20 ball, jami 100 (egasi so‘rovi, 2026-11-02). Tartib:
`l10n_assessment_modes.py` dan keyin. Idempotent."""
import collections, json, pathlib

D = pathlib.Path(__file__).resolve().parent.parent / 'lib/core/l10n/arb'
I = {'type': 'int'}
S = {'type': 'String'}
K = collections.OrderedDict()


def k(key, desc, uz, ru, en, ph=None):
    K[key] = (desc, uz, ru, en, ph)


k('oralExamStart', 'Specialty oral tab: start the oral exam.',
  'Og‘zaki imtihon (bilet)', 'Устный экзамен (билет)', 'Oral exam (ticket)')
k('oralExamStartDesc', 'Oral exam entry description.',
  '5 ta savol, har biriga 0–20 ball, jami 100 ball',
  '5 вопросов, за каждый 0–20 баллов, всего 100',
  '5 questions, 0–20 points each, 100 in total')
k('oralExamTitle', 'Oral exam screen title.',
  'Og‘zaki imtihon', 'Устный экзамен', 'Oral exam')
k('oralExamTicketNo', 'Ticket heading.',
  'Bilet № {n}', 'Билет № {n}', 'Ticket no. {n}', {'n': I})
k('oralExamName', 'Optional examinee name field.',
  'Talaba ismi (ixtiyoriy)', 'Имя экзаменуемого (необязательно)',
  'Examinee name (optional)')
k('oralExamQuestionN', 'Question label in a ticket.',
  'Savol {n}', 'Вопрос {n}', 'Question {n}', {'n': I})
k('oralExamShowKey', 'Expandable answer key.',
  'Javob kaliti (ustoz uchun)', 'Ключ ответа (для экзаменатора)',
  'Answer key (for the examiner)')
k('oralExamScore', 'Score of a question.',
  'Ball: {s} / 20', 'Баллы: {s} / 20', 'Score: {s} / 20', {'s': I})
k('oralExamUnscored', 'Question has no score yet.',
  'Ball qo‘yilmagan', 'Баллы не выставлены', 'Not scored yet')
k('oralExamTotal', 'Running total.',
  'Jami: {s} / 100', 'Итого: {s} / 100', 'Total: {s} / 100', {'s': I})
k('oralExamSave', 'Save the result and draw the next ticket.',
  'Natijani saqlash va keyingi bilet',
  'Сохранить результат и следующий билет',
  'Save the result and next ticket')
k('oralExamSaveHint', 'Shown while some questions are unscored.',
  'Saqlash uchun hamma savolga ball qo‘ying',
  'Чтобы сохранить, выставьте баллы за все вопросы',
  'Score every question to save')
k('oralExamSaved', 'Snackbar after saving.',
  'Natija saqlandi: {s} / 100', 'Результат сохранён: {s} / 100',
  'Result saved: {s} / 100', {'s': I})
k('oralExamNext', 'Draw a ticket button.',
  'Bilet chiqarish', 'Выдать билет', 'Draw a ticket')
k('oralExamPoolReset', 'Notice: every question was used, a new round began.',
  'Hamma savollar ishlatilgan edi — yangi aylanish boshlandi',
  'Все вопросы были использованы — начат новый круг',
  'Every question was used — a new round has started')
k('oralExamPool', 'Pool usage line.',
  'Ishlatilgan savollar: {used} / {total}',
  'Использовано вопросов: {used} / {total}',
  'Questions used: {used} / {total}', {'used': I, 'total': I})
k('oralExamResetPool', 'Reset the used-questions round.',
  'Savollarni qaytadan boshlash', 'Начать вопросы заново',
  'Restart the question round')
k('oralExamHistory', 'History heading.',
  'Oldingi natijalar', 'Предыдущие результаты', 'Previous results')
k('oralExamHistoryEmpty', 'History is empty.',
  'Hozircha natija yo‘q', 'Результатов пока нет', 'No results yet')
k('oralExamHistoryClear', 'Clear history button.',
  'Tarixni tozalash', 'Очистить историю', 'Clear history')
k('oralExamHistoryClearBody', 'Clear history confirmation text.',
  'Saqlangan barcha natijalar shu telefondan o‘chiriladi.',
  'Все сохранённые результаты будут удалены с этого телефона.',
  'All saved results will be deleted from this phone.')
k('oralExamCancel', 'Cancel in the confirmation.',
  'Bekor qilish', 'Отмена', 'Cancel')
k('oralExamDeviceNote', 'Where results are stored.',
  'Natijalar faqat shu telefonda saqlanadi.',
  'Результаты хранятся только на этом телефоне.',
  'Results are stored on this phone only.')
k('oralExamNoName', 'History row without a name.',
  'Ismsiz', 'Без имени', 'No name')

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
print('l10n_oral_exam:', len(K), 'keys')
