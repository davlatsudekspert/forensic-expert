// Ustoz: mavzu bo‘yicha og‘zaki bilet — slayddan savol ajratish va bilet
// tuzish (aralash, takrorlanmaydi, aylanish).
import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/domain/lessons/lesson_models.dart';
import 'package:forensic_expert/domain/lessons/lesson_oral.dart';

LessonDeck _deck(String id, List<(String, int)> slides) => LessonDeck(
  topicId: id,
  title: 'Mavzu $id',
  course: '4-kurs',
  deckId: '$id-deck',
  sourceLang: 'uz',
  slides: [
    for (final (title, n) in slides)
      LessonSlide(
        title: title,
        bullets: [
          for (var i = 0; i < n; i++) LessonBullet(text: '$title · band $i'),
        ],
      ),
  ],
);

void main() {
  group('lessonOralQuestionText', () {
    test('xizmat slaydlari savol bo‘lmaydi', () {
      for (final t in [
        'Kirish: mashg‘ulot maqsadi va rejasi',
        'Kirish',
        'Xulosa',
        'Xulosa va nazorat savollari',
        'Xulosa: asosiy tamoyillar',
        'Tezkor savol 1: tasnif va chegaralar',
        'Nazorat savollari (2)',
        'Ma’ruza rejasi va tayanch iboralar',
        'Mashg‘ulot maqsadi va rejasi',
        'Kutilayotgan natijalar va jihozlar',
        'Voqea tahlili 2: a’zobuzarlikka shubha',
        'Vaziyatli masala',
        '3-keys: zaharlanish',
        'Keys-topshiriq (kitobdan)',
        'Dars rejasi',
        'Reja va tayanch so‘zlar',
        'Adabiyotlar',
      ]) {
        expect(lessonOralQuestionText(t), isEmpty, reason: t);
      }
    });

    test('haqiqiy savollar qoladi (so‘z o‘zgarmaydi)', () {
      expect(
        lessonOralQuestionText('Tan jarohatlarining yuridik tasnifi'),
        'Tan jarohatlarining yuridik tasnifi',
      );
      expect(
        lessonOralQuestionText('Kirish yo‘li va tashqi sharoit'),
        'Kirish yo‘li va tashqi sharoit',
      );
      expect(
        lessonOralQuestionText('Xulosani baholash va so‘roq'),
        'Xulosani baholash va so‘roq',
      );
      expect(
        lessonOralQuestionText('Sun’iy kasalliklar (davomi)'),
        'Sun’iy kasalliklar',
      );
      expect(
        lessonOralQuestionText('2-bo‘lim: Sud tibbiyoti tarixi'),
        'Sud tibbiyoti tarixi',
      );
    });
  });

  group('lessonOralQuestions', () {
    test('«(davomi)» qo‘shiladi, bandsiz va takror slayd chiqmaydi', () {
      final qs = lessonOralQuestions(
        _deck('a', [
          ('Kirish: reja', 2),
          ('Sun’iy kasalliklar', 2),
          ('Sun’iy kasalliklar (davomi)', 1),
          ('Bandsiz slayd', 0),
          ('Tezkor savol 1', 1),
          ('Jinsni aniqlash', 1),
          ('Xulosa', 3),
        ]),
      );
      expect(qs.map((q) => q.text), ['Sun’iy kasalliklar', 'Jinsni aniqlash']);
      expect(qs.first.id, 'a#1');
      expect(qs.first.bullets, hasLength(3));
      expect(qs.every((q) => q.topicId == 'a'), isTrue);
    });
  });

  group('drawTopicOralTicket', () {
    final pools = {
      'a': [for (var i = 0; i < 6; i++) 'a#$i'],
      'b': [for (var i = 0; i < 6; i++) 'b#$i'],
    };

    test('5 ta savol, ikkala mavzudan aralash', () {
      final r = drawTopicOralTicket(
        pools: pools,
        used: const {},
        rng: math.Random(1),
      );
      expect(r.ids, hasLength(5));
      expect(r.ids.toSet(), hasLength(5));
      expect(r.ids.where((x) => x.startsWith('a#')), isNotEmpty);
      expect(r.ids.where((x) => x.startsWith('b#')), isNotEmpty);
      expect(r.reset, isFalse);
    });

    test('ishlatilgan savollar takrorlanmaydi; tugasa — aylanish', () {
      final used = <String>{};
      for (var n = 0; n < 2; n++) {
        final r = drawTopicOralTicket(
          pools: pools,
          used: used,
          rng: math.Random(n),
        );
        expect(r.ids.any(used.contains), isFalse);
        expect(r.reset, isFalse);
        used.addAll(r.ids);
      }
      // 12 tadan 10 tasi ishlatildi — 2 ta qoldi (< 5): yangi aylanish.
      final r = drawTopicOralTicket(
        pools: pools,
        used: used,
        rng: math.Random(9),
      );
      expect(r.reset, isTrue);
      expect(r.ids, hasLength(5));
    });

    test('jami savol kam bo‘lsa — hammasi', () {
      final r = drawTopicOralTicket(
        pools: const {
          'a': ['a#0', 'a#1'],
        },
        used: const {},
        rng: math.Random(1),
      );
      expect(r.ids.toSet(), {'a#0', 'a#1'});
    });
  });

  test('topicSelectionKey: tartibdan qat’i nazar bir xil', () {
    expect(topicSelectionKey(['b', 'a', 'b']), 'a,b');
  });
}
