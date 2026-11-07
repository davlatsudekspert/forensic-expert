// Og‘zaki imtihon savollari (rasmiy malaka biletlari, ustoz mavzu biletlari)
// ilova tilida: ru/en, yo‘q bo‘lsa — asl o‘zbekcha; id’lar barcha tillarda
// bir xil.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/domain/assessment/assessment_models.dart';
import 'package:forensic_expert/domain/lessons/lesson_models.dart';
import 'package:forensic_expert/domain/lessons/lesson_oral.dart';

Map<String, Object?> _raw() => (jsonDecode(
  File('assets/content/assessment/assessment_v1.json').readAsStringSync(),
) as Map).cast<String, Object?>();

LessonDeck _deck(String id, List<String> titles, {String lang = 'uz'}) =>
    LessonDeck(
      topicId: id,
      title: 'Mavzu $id',
      course: '4-kurs',
      deckId: '$id-deck',
      sourceLang: lang,
      slides: [
        for (final t in titles)
          LessonSlide(
            title: t,
            bullets: [LessonBullet(text: '$t · band')],
          ),
      ],
    );

void main() {
  final raw = _raw();
  final uz = AssessmentBundle.fromJson(raw);
  final ru = AssessmentBundle.fromJson(raw, lang: 'ru');
  final en = AssessmentBundle.fromJson(raw, lang: 'en');

  List<AssessmentQuestion> all(AssessmentBundle b) => [
    for (final s in b.specialties)
      for (final c in s.categories) ...c.questions,
  ];

  group('rasmiy og‘zaki savollar (1270)', () {
    test('hammasi ru va en tilida; id va tartib o‘zgarmaydi', () {
      final u = all(uz), r = all(ru), e = all(en);
      expect(u, hasLength(1270));
      expect(r.map((q) => q.id), u.map((q) => q.id));
      expect(e.map((q) => q.id), u.map((q) => q.id));
      for (var i = 0; i < u.length; i++) {
        expect(u[i].textSource, AssessmentTextSource.original);
        expect(r[i].textSource, isNot(AssessmentTextSource.original));
        expect(e[i].textSource, AssessmentTextSource.machine);
        expect(r[i].text, isNot(u[i].text), reason: u[i].id);
        expect(e[i].text, isNot(u[i].text), reason: u[i].id);
        // Ruscha — kirillcha, inglizcha — lotincha.
        expect(RegExp('[а-яА-Я]').hasMatch(r[i].text), isTrue);
        expect(RegExp('[а-яА-Я]').hasMatch(e[i].text), isFalse);
      }
    });

    test('rasmiy ruscha matn bilan moslangan savollar bor va belgilangan', () {
      final r = all(ru);
      final official = r
          .where((q) => q.textSource == AssessmentTextSource.official)
          .length;
      expect(official, greaterThan(500));
      expect(official, lessThan(r.length));
      final q = ru.specialty('pat_anat')!.categories[2].questions.first;
      expect(q.textSource, AssessmentTextSource.official);
      expect(q.text, startsWith('Нормативные документы'));
    });

    test('LLM tarjima: raqamlar (modda, daraja) saqlanadi', () {
      final u = all(uz), r = all(ru), e = all(en);
      final digits = RegExp(r'\d+');
      for (var i = 0; i < u.length; i++) {
        final need = digits.allMatches(u[i].text).map((m) => m[0]).toSet();
        if (r[i].textSource == AssessmentTextSource.machine) {
          final got = digits.allMatches(r[i].text).map((m) => m[0]).toSet();
          expect(got.containsAll(need), isTrue, reason: u[i].id);
        }
        if (u[i].id.startsWith('pat_anat') ||
            r[i].textSource == AssessmentTextSource.machine) {
          final got = digits.allMatches(e[i].text).map((m) => m[0]).toSet();
          expect(got.containsAll(need), isTrue, reason: u[i].id);
        }
      }
    });

    test('tarjima yo‘q yoki bo‘sh — asl o‘zbekcha (to‘qilmaydi)', () {
      final q = AssessmentQuestion.fromJson({
        'id': 'x.c23.001',
        'n': 1,
        'text': 'Asl savol',
        'text_ru': '  ',
      }, lang: 'ru');
      expect(q.text, 'Asl savol');
      expect(q.textSource, AssessmentTextSource.original);
      final e = AssessmentQuestion.fromJson({
        'id': 'x.c23.001',
        'n': 1,
        'text': 'Asl savol',
        'text_en': 'Original question',
        'en_src': 'llm',
      }, lang: 'en');
      expect(e.text, 'Original question');
      expect(e.textSource, AssessmentTextSource.machine);
      // Qo‘llanmaydigan til (qozoq) — o‘zbekcha.
      expect(
        AssessmentQuestion.fromJson({
          'text': 'Asl savol',
          'text_ru': 'Вопрос',
        }, lang: 'kk').text,
        'Asl savol',
      );
    });
  });

  group('ustoz mavzu bileti: tarjima qilingan deck', () {
    final uzDeck = _deck('t1', [
      'Kirish: mashg‘ulot maqsadi',
      'Tan jarohatlarining yuridik tasnifi',
      'Hayot uchun xavf mezoni',
      'Hayot uchun xavf mezoni (davomi)',
      '2-bo‘lim: Sun’iy kasalliklar',
      'Xulosa',
    ]);
    final ruDeck = _deck('t1', [
      'Введение: цель занятия',
      'Юридическая классификация телесных повреждений',
      'Критерий опасности для жизни',
      'Критерий опасности для жизни (продолжение)',
      'Раздел 2: Искусственные болезни',
      'Заключение',
    ], lang: 'ru');

    test('id’lar o‘zbekcha bilan bir xil, matn va bandlar ruscha', () {
      final base = lessonOralQuestions(uzDeck);
      final loc = lessonOralQuestionsLocalized(uzDeck, ruDeck);
      expect(loc.map((q) => q.id), base.map((q) => q.id));
      expect(loc.map((q) => q.id), ['t1#1', 't1#2', 't1#4']);
      expect(loc.map((q) => q.text), [
        'Юридическая классификация телесных повреждений',
        'Критерий опасности для жизни',
        'Искусственные болезни',
      ]);
      // «(продолжение)» bandlari ham qo‘shilgan.
      expect(loc[1].bullets.map((b) => b.text), [
        'Критерий опасности для жизни · band',
        'Критерий опасности для жизни (продолжение) · band',
      ]);
    });

    test('tarjima deck’i mos kelmasa — o‘zbekcha savollar', () {
      final short = _deck('t1', ['Введение', 'Классификация'], lang: 'ru');
      expect(
        lessonOralQuestionsLocalized(uzDeck, short).map((q) => q.text),
        lessonOralQuestions(uzDeck).map((q) => q.text),
      );
      expect(lessonOralQuestionsLocalized(uzDeck, null).map((q) => q.id), [
        't1#1',
        't1#2',
        't1#4',
      ]);
    });

    test('ru/en xizmat slaydlari (o‘zbekcha deck yo‘q bo‘lsa) savol emas', () {
      for (final t in [
        'Введение',
        'Введение: цель занятия',
        'Заключение',
        'Выводы',
        'Контрольные вопросы',
        'План лекции',
        'Литература',
        'Introduction',
        'Conclusion',
        'Summary',
        'Control questions',
        'Lesson plan',
        'Glossary',
      ]) {
        expect(lessonOralQuestionText(t), '', reason: t);
      }
      expect(
        lessonOralQuestionText('Критерий опасности для жизни'),
        'Критерий опасности для жизни',
      );
      expect(
        lessonOralQuestionText('Introduction routes of poisons'),
        isNot(''),
        reason: '«Introduction» + ikki nuqtasiz davom — savol bo‘lishi mumkin',
      );
      expect(lessonOralSlideTitle('Table 3: Criteria (continued)'), 'Criteria');
    });
  });
}
