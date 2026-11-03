#!/usr/bin/env python3
"""Ustoz stolim → «Og‘zaki imtihon (bilet)»: mavzu bo‘yicha bilet, savollar
dars slaydlaridan, ustoz 0–20 ball qo‘yadi (egasi, 2026-11-03). Tartib:
`l10n_oral_exam.py` dan keyin. Idempotent."""
import collections, json, pathlib

D = pathlib.Path(__file__).resolve().parent.parent / 'lib/core/l10n/arb'
I = {'type': 'int'}
K = collections.OrderedDict()


def k(key, desc, uz, ru, en, ph=None):
    K[key] = (desc, uz, ru, en, ph)


k('teacherOralDeskBody', 'Teacher desk card: topic-based oral exam.',
  'Mavzu bo‘yicha 5 savollik bilet, baholaysiz',
  'Билет из 5 вопросов по теме, оцениваете вы',
  'A 5-question ticket by topic, graded by you')
k('teacherOralIntro', 'Topic picker explanation.',
  'Bir yoki bir nechta mavzu tanlang. Har talabaga shu mavzulardan 5 ta '
  'savollik bilet chiqadi, savollar keyingi talabaga takrorlanmaydi. Har '
  'savolga 0–20 ball qo‘yasiz, jami 100. Savol va javob kaliti darsingiz '
  'slaydlaridan olinadi.',
  'Выберите одну или несколько тем. Каждому студенту выдаётся билет из 5 '
  'вопросов по этим темам; следующему студенту вопросы не повторяются. За '
  'каждый вопрос вы ставите 0–20 баллов, всего 100. Вопросы и ключ ответа '
  'берутся из слайдов вашего занятия.',
  'Pick one or more topics. Each student gets a 5-question ticket from '
  'these topics, and questions are not repeated for the next student. You '
  'score each question 0–20, 100 in total. Questions and the answer key are '
  'taken from your lesson slides.')
k('teacherOralSelected', 'How many topics are selected.',
  'Tanlandi: {n} ta mavzu', 'Выбрано тем: {n}', 'Topics selected: {n}',
  {'n': I})
k('teacherOralBuild', 'Open the ticket screen for the selected topics.',
  'Bilet tuzish', 'Составить билет', 'Make a ticket')
k('teacherOralClearSelection', 'Clear the topic selection.',
  'Tanlovni tozalash', 'Сбросить выбор', 'Clear selection')
k('teacherOralPickHint', 'Shown when no topic is selected yet.',
  'Avval kamida bitta mavzuni belgilang',
  'Сначала отметьте хотя бы одну тему',
  'Select at least one topic first')
k('teacherOralNoQuestions', 'Selected lessons have no usable questions.',
  'Tanlangan darslarda bilet uchun savol topilmadi. Boshqa mavzuni tanlang.',
  'В выбранных занятиях не найдено вопросов для билета. Выберите другую тему.',
  'No ticket questions were found in the selected lessons. Pick another topic.')
k('teacherOralChangeTopics', 'Go back to the topic picker.',
  'Mavzularni o‘zgartirish', 'Изменить темы', 'Change topics')
k('teacherOralKeyNote', 'Under the answer key.',
  'Dars slaydidan (asl matn).', 'Из слайда занятия (исходный текст).',
  'From the lesson slide (original text).')

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
print('l10n_teacher_oral:', len(K), 'keys')
