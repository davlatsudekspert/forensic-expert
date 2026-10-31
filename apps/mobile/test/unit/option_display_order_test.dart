import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/domain/class_groups/variant_draw.dart';

List<int> _order(String user, String q, {int n = 4, String a = 'asg-1'}) =>
    optionDisplayOrder(assignmentId: a, userId: user, questionId: q, count: n);

void main() {
  group('optionDisplayOrder', () {
    test('deterministik: qayta chaqirilganda tartib bir xil', () {
      expect(_order('stu1', 'q1'), _order('stu1', 'q1'));
      expect(_order('stu1', 'q9', n: 5), _order('stu1', 'q9', n: 5));
    });

    test('to‘plam o‘zgarmaydi: har doim 0..n-1 permutatsiyasi', () {
      for (var u = 0; u < 30; u++) {
        for (var q = 0; q < 10; q++) {
          for (final n in [2, 3, 4, 5, 6]) {
            final o = _order('u$u', 'q$q', n: n);
            expect(o.length, n);
            expect([...o]..sort(), List.generate(n, (i) => i));
          }
        }
      }
    });

    test('ikki talabada tartib farqli (to‘plam bir xil)', () {
      var differing = 0;
      for (var q = 0; q < 20; q++) {
        final a = _order('stu1', 'q$q');
        final b = _order('stu2', 'q$q');
        expect([...a]..sort(), [...b]..sort());
        if (a.join() != b.join()) differing++;
      }
      // 4 variant — 24 tartib; tasodifan bir xil bo‘lishi mumkin, lekin
      // 20 savolning ko‘pchiligida farq qiladi.
      expect(differing, greaterThanOrEqualTo(15));
    });

    test('talaba tartibi savolga ham, testga ham bog‘liq', () {
      final byQuestion = {
        for (var q = 0; q < 20; q++) _order('stu1', 'q$q').join(),
      };
      expect(byQuestion.length, greaterThan(5));
      final differsByTest = [
        for (var q = 0; q < 20; q++)
          _order('stu1', 'q$q').join() !=
              _order('stu1', 'q$q', a: 'asg-2').join(),
      ].where((d) => d).length;
      expect(differsByTest, greaterThanOrEqualTo(10));
    });

    test('talaba yo‘q yoki variant < 2 — asl tartib', () {
      expect(_order('', 'q1'), [0, 1, 2, 3]);
      expect(
        optionDisplayOrder(
          assignmentId: 'a',
          userId: null,
          questionId: 'q',
          count: 3,
        ),
        [0, 1, 2],
      );
      expect(_order('stu1', 'q1', n: 1), [0]);
      expect(_order('stu1', 'q1', n: 0), isEmpty);
    });

    test('A-D barcha o‘rinlarga tushadi (tekis taqsimot)', () {
      final firstCounts = List<int>.filled(4, 0);
      for (var u = 0; u < 400; u++) {
        firstCounts[_order('user-$u', 'q1').first]++;
      }
      for (final c in firstCounts) {
        expect(c, inInclusiveRange(60, 140));
      }
    });
  });

  test('variantMaxCount: hovuzning yarmi, pastga yaxlitlangan', () {
    expect(variantMaxCount(24), 12);
    expect(variantMaxCount(15), 7);
    expect(variantMaxCount(1), 0);
    expect(variantMaxCount(0), 0);
    // Shu songa tushirilsa variant rejimi ruxsat etiladi.
    for (final p in [2, 7, 15, 24, 30]) {
      expect(variantAllowed(p, variantMaxCount(p)), isTrue);
    }
  });
}
