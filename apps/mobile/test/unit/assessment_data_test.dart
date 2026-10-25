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
}
