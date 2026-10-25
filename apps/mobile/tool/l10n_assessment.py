# «Bilim va malakani baholash» bo‘limi (egasi qarori, 2026-10-25): rasmiy og‘zaki
# imtihon savollari (tmbm.ssv.uz) va test mashqlari. Ogohlantirish/“kafolat”
# jumlalari YO‘Q (egasi talabi). Idempotent: faqat shu fayldagi kalitlar.
# CLAUDE.md tartibida: l10n_pro_plans.py dan keyin, l10n_ux_audit.py dan oldin:
#   cd apps/mobile && python3 tool/l10n_assessment.py && flutter gen-l10n
import json, collections, re
D = "lib/core/l10n/arb"
K = collections.OrderedDict()


def k(key, desc, en, ru, uz, ph=None):
    K[key] = (desc, en, ru, uz, ph or {})


S = {'n': 'int'}
k('assessmentTitle', 'Section title (home tile, screen title, menus).',
  'Knowledge & Skills Assessment',
  'Проверка знаний и компетенций',
  'Bilim va malakani baholash')
k('assessmentSubtitle', 'Home tile body.',
  'Questions and tests for forensic medicine, pathological anatomy and forensic chemistry',
  'Вопросы и тесты по судебной медицине, патологической анатомии и судебной химии',
  'Sud tibbiyoti, patologik anatomiya va sud kimyosi bo‘yicha savollar va testlar')
k('assessmentIntro', 'Hub intro line.',
  'Official oral-exam question lists and practice tests by specialty and qualification category.',
  'Официальные перечни вопросов устного экзамена и тренировочные тесты по специальностям и квалификационным категориям.',
  'Mutaxassislik va malaka toifalari bo‘yicha rasmiy og‘zaki imtihon savollari ro‘yxati va test mashqlari.')
k('assessmentSpecSudTib', 'Specialty: forensic medical examination.',
  'Forensic medical examination',
  'Судебно-медицинская экспертиза',
  'Sud-tibbiy ekspertiza')
k('assessmentSpecPatAnat', 'Specialty: pathological anatomy.',
  'Pathological anatomy',
  'Патологическая анатомия',
  'Patologik anatomiya')
k('assessmentSpecSudKimyo', 'Specialty: forensic chemical examination.',
  'Forensic chemical examination',
  'Судебно-химическая экспертиза',
  'Sud-kimyogar ekspertiza')
k('assessmentCatC23', 'Qualification category group: third and second.',
  'Third and second category',
  'Третья и вторая категория',
  'Uchinchi va ikkinchi toifa')
k('assessmentCatC1', 'Qualification category: first.',
  'First category',
  'Первая категория',
  'Birinchi toifa')
k('assessmentCatC0', 'Qualification category: highest.',
  'Highest category',
  'Высшая категория',
  'Oliy toifa')
k('assessmentTabOral', 'Tab: oral exam questions.',
  'Oral questions',
  'Устные вопросы',
  'Og‘zaki savollar')
k('assessmentTabTests', 'Tab: tests.',
  'Tests',
  'Тесты',
  'Testlar')
k('assessmentCountQuestions', 'Number of questions.',
  '{n} questions',
  'Вопросов: {n}',
  '{n} ta savol', S)
k('assessmentCountTests', 'Number of tests.',
  '{n} tests',
  'Тестов: {n}',
  '{n} ta test', S)
k('assessmentReadyProgress', 'Personal progress: ready questions.',
  '{done} of {total} ready',
  'Готово: {done} из {total}',
  '{done}/{total} tayyor', {'done': 'int', 'total': 'int'})
k('assessmentSearchHint', 'Search field hint.',
  'Search questions',
  'Поиск по вопросам',
  'Savollar bo‘yicha qidirish')
k('assessmentNoResults', 'Empty search result.',
  'Nothing found',
  'Ничего не найдено',
  'Hech narsa topilmadi')
k('assessmentUzOnly', 'Hint: question text language.',
  'Questions are shown in Uzbek, exactly as in the official list.',
  'Вопросы приведены на узбекском языке, как в официальном перечне.',
  'Savollar rasmiy ro‘yxatdagi kabi o‘zbek tilida keltirilgan.')
k('assessmentSourceLine', 'Source line.',
  'Source: {source}',
  'Источник: {source}',
  'Manba: {source}', {'source': 'String'})
k('assessmentSourceName', 'Official source name of the question lists.',
  'Center for Assessing the Qualification of Medical and Pharmaceutical Workers (tmbm.ssv.uz)',
  'Центр оценки квалификации медицинских и фармацевтических работников (tmbm.ssv.uz)',
  'Tibbiyot va farmatsevtika xodimlarining malakasini baholash markazi (tmbm.ssv.uz)')
k('assessmentMarkReady', 'Button: mark question as ready.',
  'Mark as ready',
  'Отметить как выученный',
  'Tayyor deb belgilash')
k('assessmentUnmarkReady', 'Button: remove ready mark.',
  'Remove ready mark',
  'Снять отметку',
  'Belgini olib tashlash')
k('assessmentReadyChip', 'Chip on a ready question.',
  'Ready',
  'Готов',
  'Tayyor')
k('assessmentAskAi', 'Button: send the question to Forensic AI.',
  'Ask Forensic AI',
  'Спросить Forensic AI',
  'Forensic AI’dan so‘rash')
k('assessmentQuestionNo', 'Question number label.',
  'Question {n}',
  'Вопрос {n}',
  '{n}-savol', S)
k('assessmentTestStart', 'Button: start practice.',
  'Start practice',
  'Начать тренировку',
  'Mashqni boshlash')
k('assessmentTestPool', 'Number of tests with a confirmed answer key.',
  '{n} questions with a confirmed answer key',
  'Вопросов с подтверждённым ключом: {n}',
  'Javob kaliti tasdiqlangan savollar: {n} ta', S)
k('assessmentTestUnkeyed', 'Number of tests without a confirmed key (not in practice).',
  '{n} questions have no confirmed answer yet and are not included in practice.',
  'У {n} вопросов ключ пока не подтверждён, они не включены в тренировку.',
  '{n} ta savolning javob kaliti hali tasdiqlanmagan, ular mashqqa kiritilmagan.', S)
k('assessmentTestNone', 'No test has a confirmed key yet.',
  'Answer keys for this specialty are being verified against the books.',
  'Ключи для этой специальности сверяются с учебниками.',
  'Bu mutaxassislik uchun javob kalitlari kitoblar bo‘yicha tekshirilmoqda.')
k('assessmentTestList', 'Button: list all test questions.',
  'All test questions',
  'Все тестовые вопросы',
  'Barcha test savollari')
k('assessmentKeyPending', 'Label on a test question without a confirmed key.',
  'Answer key not confirmed',
  'Ключ не подтверждён',
  'Javob kaliti tasdiqlanmagan')
k('assessmentCorrect', 'Answer feedback: correct.',
  'Correct',
  'Верно',
  'To‘g‘ri')
k('assessmentWrong', 'Answer feedback: wrong.',
  'Incorrect',
  'Неверно',
  'Noto‘g‘ri')
k('assessmentCorrectAnswer', 'Shows the correct answer text.',
  'Correct answer: {a}',
  'Правильный ответ: {a}',
  'To‘g‘ri javob: {a}', {'a': 'String'})
k('assessmentAnswerSource', 'Where the answer key comes from.',
  'Answer source: {src}',
  'Источник ответа: {src}',
  'Javob manbasi: {src}', {'src': 'String'})
k('assessmentKeyTeacher', 'Key source: file supplied by the teacher.',
  'answer-keyed test bank supplied by the teacher (Toxicological chemistry)',
  'тестовый банк с ключами от преподавателя (токсикологическая химия)',
  'ustoz taqdim etgan kalitli test banki (Toksikologik kimyo)')
k('assessmentBookPage', 'Book citation with the PDF page of the supplied file.',
  '{title}, PDF p. {page}',
  '{title}, PDF, с. {page}',
  '{title}, PDF {page}-bet', {'title': 'String', 'page': 'int'})
k('assessmentNext', 'Button: next question.',
  'Next',
  'Далее',
  'Keyingisi')
k('assessmentFinish', 'Button: finish practice.',
  'Finish',
  'Завершить',
  'Yakunlash')
k('assessmentResultTitle', 'Result screen title.',
  'Result',
  'Результат',
  'Natija')
k('assessmentResultScore', 'Result score.',
  '{c} of {n} correct',
  'Верно: {c} из {n}',
  '{c} / {n} to‘g‘ri', {'c': 'int', 'n': 'int'})
k('assessmentRetry', 'Button: practice again.',
  'Practice again',
  'Повторить',
  'Qayta mashq qilish')
k('assessmentMistakes', 'Heading: questions answered wrongly.',
  'Review your mistakes',
  'Разбор ошибок',
  'Xatolar tahlili')
k('assessmentEmpty', 'Fallback when the question pack is missing.',
  'The question pack could not be loaded.',
  'Не удалось загрузить набор вопросов.',
  'Savollar to‘plamini yuklab bo‘lmadi.')
k('assessmentOpenSource', 'Link text to the official page.',
  'Official list',
  'Официальный перечень',
  'Rasmiy ro‘yxat')

for idx, code in enumerate(["en", "ru", "uz"]):
    p = f"{D}/app_{code}.arb"
    text = open(p, encoding="utf-8").read()
    data = json.loads(text)
    for key, (desc, en, ru, uz, ph) in K.items():
        val = (en, ru, uz)[idx]
        entries = [(key, val)]
        if code == "en":
            meta = {"description": desc}
            if ph:
                meta["placeholders"] = {n: {"type": t} for n, t in ph.items()}
            entries.append(("@" + key, meta))
        for kk, vv in entries:
            line = f"  {json.dumps(kk, ensure_ascii=False)}: {json.dumps(vv, ensure_ascii=False)}"
            if kk in data:
                text = re.sub(r"(?ms)^  " + re.escape(json.dumps(kk, ensure_ascii=False)) + r": .*?(,?)\n(?=  \"|\}$)",
                              lambda m: line + m.group(1) + "\n", text, count=1)
            else:
                body = text.rstrip()
                assert body.endswith("}")
                text = body[:-1].rstrip() + ",\n" + line + "\n}\n"
        data = json.loads(text)
    json.loads(text)
    open(p, "w", encoding="utf-8").write(text)
print(len(K), "keys")
