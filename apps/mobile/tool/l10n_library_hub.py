#!/usr/bin/env python3
"""Kutubxona (egasi, 2026-11-05): yangi guruhlar, qidiruv va aniq birliklar
(uz/ru/en). Tartib: `l10n_programs_areas.py` dan keyin, `flutter gen-l10n`
dan oldin. Idempotent."""
import collections, json, pathlib

D = pathlib.Path(__file__).resolve().parent.parent / 'lib/core/l10n/arb'
K = collections.OrderedDict()
C = {'count': 'int'}


def k(key, desc, uz, ru, en, ph=None):
    K[key] = (desc, ph, uz, ru, en)


k('libraryGroupNorms', 'Library hub: group of norms and documents.',
  'Me’yorlar va hujjatlar', 'Нормы и документы', 'Norms and documents')
k('libraryGroupEvidence', 'Library hub: group of evidence and scientific sources.',
  'Dalillar va ilmiy manbalar', 'Доказательства и научные источники',
  'Evidence and scientific sources')
k('libraryGroupMore', 'Library hub: group of training and community items.',
  'Tayyorgarlik va hamjamiyat', 'Подготовка и сообщество',
  'Training and community')
k('librarySearchHint', 'Library hub: search field hint.',
  'Kutubxonadan qidiring: modda, usul, reagent, manba',
  'Поиск в библиотеке: вещество, метод, реагент, источник',
  'Search the library: substance, method, reagent, source')


def unit(key, desc, uz, ru3, en1, en2):
    one, few, many = ru3
    k(key, desc, '{count} ' + uz,
      '{count, plural, one{{count} %s} few{{count} %s} many{{count} %s} other{{count} %s}}' % (one, few, many, few),
      '{count, plural, =1{1 %s} other{{count} %s}}' % (en1, en2), C)


unit('libraryUnitSubstances', 'Library card unit: substances.', 'modda',
     ('вещество', 'вещества', 'веществ'), 'substance', 'substances')
unit('libraryUnitMethods', 'Library card unit: methods.', 'usul',
     ('метод', 'метода', 'методов'), 'method', 'methods')
unit('libraryUnitReagents', 'Library card unit: reagents.', 'reagent',
     ('реагент', 'реагента', 'реагентов'), 'reagent', 'reagents')
unit('libraryUnitTests', 'Library card unit: screening tests.', 'test',
     ('тест', 'теста', 'тестов'), 'test', 'tests')
unit('libraryUnitSpecimens', 'Library card unit: specimens.', 'namuna',
     ('образец', 'образца', 'образцов'), 'specimen', 'specimens')
unit('libraryUnitTerms', 'Library card unit: glossary terms.', 'atama',
     ('термин', 'термина', 'терминов'), 'term', 'terms')
unit('libraryUnitDocuments', 'Library card unit: documents.', 'hujjat',
     ('документ', 'документа', 'документов'), 'document', 'documents')
unit('libraryUnitGuidelines', 'Library card unit: guidelines.', 'yo‘riqnoma',
     ('руководство', 'руководства', 'руководств'), 'guideline', 'guidelines')
unit('libraryUnitStudies', 'Library card unit: research records.', 'tadqiqot',
     ('исследование', 'исследования', 'исследований'), 'study', 'studies')
unit('libraryUnitSources', 'Library card unit: sources.', 'manba',
     ('источник', 'источника', 'источников'), 'source', 'sources')
unit('libraryUnitConflicts', 'Library card unit: evidence conflicts.', 'ziddiyat',
     ('противоречие', 'противоречия', 'противоречий'), 'conflict', 'conflicts')
unit('libraryUnitQuestions', 'Library card unit: court questions.', 'savol',
     ('вопрос', 'вопроса', 'вопросов'), 'question', 'questions')

for i, lang in enumerate(('uz', 'ru', 'en')):
    f = D / f'app_{lang}.arb'
    b = json.loads(f.read_text(encoding='utf-8'),
                   object_pairs_hook=collections.OrderedDict)
    for key, (desc, ph, *vals) in K.items():
        b[key] = vals[i]
        if lang == 'en':
            meta = collections.OrderedDict(description=desc)
            if ph:
                meta['placeholders'] = collections.OrderedDict(
                    (n, collections.OrderedDict(type=t)) for n, t in ph.items())
            b['@' + key] = meta
    f.write_text(json.dumps(b, ensure_ascii=False, indent=2) + '\n',
                 encoding='utf-8')
print('l10n_library_hub:', len(K), 'keys')
