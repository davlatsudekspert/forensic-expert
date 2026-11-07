import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/domain/assessment/assessment_models.dart';

AssessmentBundle _load() => AssessmentBundle.fromJson(
  (jsonDecode(
    File('assets/content/assessment/assessment_v1.json').readAsStringSync(),
  ) as Map).cast<String, Object?>(),
);

void main() {
  final bundle = _load();

  test(
    '3 mutaxassislik, har birida c23/c1/c0 toifalari; 1270 og‘zaki savol',
    () {
      expect(bundle.specialties.map((s) => s.id), [
        'sud_tib',
        'pat_anat',
        'sud_kimyo',
      ]);
      for (final s in bundle.specialties) {
        expect(s.categories.map((c) => c.id), ['c23', 'c1', 'c0']);
      }
      expect(bundle.specialties.fold(0, (a, s) => a + s.total), 1270);
      final ids = [
        for (final s in bundle.specialties)
          for (final c in s.categories)
            for (final q in c.questions) q.id,
      ];
      expect(ids.toSet().length, ids.length, reason: 'id lar noyob');
      for (final s in bundle.specialties) {
        for (final c in s.categories) {
          for (final q in c.questions) {
            expect(q.text.trim(), isNotEmpty, reason: q.id);
          }
        }
      }
    },
  );

  test('test savollari: 4 ta aniq variant; kalit faqat manba bilan', () {
    var graded = 0;
    for (final s in bundle.specialties) {
      final seen = <String>{};
      expect(s.tests, isNotEmpty);
      for (final t in s.tests) {
        expect(seen.add(t.id), isTrue, reason: 'id takror: ${t.id}');
        expect(t.options.length, 4, reason: t.id);
        expect(
          t.options.toSet().length,
          4,
          reason: 'variantlar bir xil: ${t.id}',
        );
        expect(t.text.trim(), isNotEmpty);
        if (t.key == null) {
          expect(t.keySource, isNull, reason: t.id);
          continue;
        }
        graded++;
        expect(t.key, inInclusiveRange(0, 3), reason: t.id);
        final src = t.keySource;
        expect(src, isNotNull, reason: 'manbasiz kalit: ${t.id}');
        switch (src!.kind) {
          case 'teacher':
            break;
          case 'book':
            expect(src.title, isNotEmpty, reason: t.id);
            expect(src.page, greaterThan(0), reason: t.id);
            expect(src.quote.length, greaterThan(15), reason: t.id);
          case 'web':
            expect(src.url, startsWith('http'), reason: t.id);
            expect(src.title, isNotEmpty, reason: t.id);
            expect(src.quote.length, greaterThan(15), reason: t.id);
          default:
            fail('noma’lum manba turi: ${src.kind} (${t.id})');
        }
      }
    }
    expect(graded, greaterThan(700));
  });

  group('testlar tili (ru/en, yo‘q bo‘lsa uz)', () {
    Map<String, Object?> q0() => {
      'id': 'x.t.001',
      'n': 1,
      'text': 'Savol',
      'options': ['a', 'b', 'c', 'd'],
      'key': 2,
      'text_ru': 'Вопрос',
      'options_ru': ['а', 'б', 'в', 'г'],
      'ru_src': 'official',
      'text_en': 'Question',
      'options_en': ['A', 'B', 'C', 'D'],
      'en_src': 'llm',
    };

    test('ru — rasmiy, en — mashina tarjimasi, kalit o‘zgarmaydi', () {
      final ru = AssessmentTestQuestion.fromJson(q0(), lang: 'ru');
      expect(ru.text, 'Вопрос');
      expect(ru.options, ['а', 'б', 'в', 'г']);
      expect(ru.textSource, AssessmentTextSource.official);
      expect(ru.key, 2);
      final en = AssessmentTestQuestion.fromJson(q0(), lang: 'en');
      expect(en.text, 'Question');
      expect(en.textSource, AssessmentTextSource.machine);
      final uz = AssessmentTestQuestion.fromJson(q0());
      expect(uz.text, 'Savol');
      expect(uz.textSource, AssessmentTextSource.original);
    });

    test('tarjima yo‘q yoki variantlar to‘liq emas — o‘zbekcha', () {
      final j = q0()
        ..remove('text_en')
        ..['options_ru'] = ['а', 'б'];
      for (final lang in ['ru', 'en']) {
        final q = AssessmentTestQuestion.fromJson(j, lang: lang);
        expect(q.text, 'Savol');
        expect(q.options, ['a', 'b', 'c', 'd']);
        expect(q.textSource, AssessmentTextSource.original);
      }
    });

    test('haqiqiy paket: barcha testlar ru va en da, 4 variant, kalit bir xil', () {
      final raw = (jsonDecode(
        File('assets/content/assessment/assessment_v1.json').readAsStringSync(),
      ) as Map).cast<String, Object?>();
      final uz = AssessmentBundle.fromJson(raw);
      var official = 0;
      for (final lang in ['ru', 'en']) {
        final b = AssessmentBundle.fromJson(raw, lang: lang);
        for (final s in b.specialties) {
          final base = uz.specialty(s.id)!.tests;
          expect(s.tests.length, base.length);
          for (var i = 0; i < s.tests.length; i++) {
            final t = s.tests[i];
            expect(
              t.textSource,
              isNot(AssessmentTextSource.original),
              reason: '${t.id} $lang',
            );
            expect(t.options.length, 4, reason: t.id);
            expect(t.key, base[i].key, reason: t.id);
            expect(t.text, isNot(base[i].text), reason: t.id);
            if (lang == 'ru' && t.textSource == AssessmentTextSource.official) {
              official++;
            }
            if (lang == 'en') {
              expect(t.textSource, AssessmentTextSource.machine);
            }
          }
        }
      }
      // Rasmiy RU bilan tasdiqlangan juftlar (docs/ASSESSMENT_RU_ALIGNMENT.md).
      expect(official, greaterThan(800));
    });
  });
}
