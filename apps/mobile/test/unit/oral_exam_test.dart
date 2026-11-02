import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/domain/assessment/oral_exam.dart';

void main() {
  final pool = [for (var i = 0; i < 12; i++) 'q$i'];

  test('bilet: 5 ta noyob savol, ishlatilganlar chiqmaydi', () {
    final used = <String>{'q0', 'q1', 'q2'};
    final r = drawOralTicket(pool: pool, used: used, rng: math.Random(1));
    expect(r.reset, isFalse);
    expect(r.ids.length, oralExamTicketSize);
    expect(r.ids.toSet().length, oralExamTicketSize);
    expect(r.ids.any(used.contains), isFalse);
  });

  test('takrorlanmaslik: 12 savolda ikki bilet to‘qnashmaydi, uchinchisida '
      'aylanish qaytadan boshlanadi', () {
    final rng = math.Random(7);
    final used = <String>{};
    final a = drawOralTicket(pool: pool, used: used, rng: rng);
    used.addAll(a.ids);
    final b = drawOralTicket(pool: pool, used: used, rng: rng);
    used.addAll(b.ids);
    expect(a.ids.toSet().intersection(b.ids.toSet()), isEmpty);
    expect(b.reset, isFalse);
    // 10 ta ishlatildi, 2 ta qoldi (<5): yangi aylanish.
    final c = drawOralTicket(pool: pool, used: used, rng: rng);
    expect(c.reset, isTrue);
    expect(c.ids.length, oralExamTicketSize);
  });

  test('kichik yoki bo‘sh havza', () {
    expect(
      drawOralTicket(pool: const [], used: {}, rng: math.Random(1)).ids,
      isEmpty,
    );
    final small = drawOralTicket(
      pool: const ['a', 'b', 'c'],
      used: {'a'},
      rng: math.Random(1),
    );
    expect(small.reset, isFalse);
    expect(small.ids.toSet(), {'a', 'b', 'c'}.difference({'a'}));
  });

  test('natija: jami, JSON aylanishi, ball 0–20 bilan cheklanadi', () {
    const r = OralExamResult(
      atMs: 1,
      spec: 'sud_tib',
      cat: 'c1',
      name: 'Ali',
      questionIds: ['a', 'b', 'c', 'd', 'e'],
      scores: [20, 15, 10, 5, 0],
    );
    expect(r.total, 50);
    final data = OralExamData.empty
        .withUsed('sud_tib', 'c1', {'a', 'b'})
        .withResult(r);
    final back = OralExamData.fromJson(jsonDecode(data.encode()));
    expect(back.usedFor('sud_tib', 'c1'), {'a', 'b'});
    expect(back.history.single.total, 50);
    expect(back.history.single.name, 'Ali');
    final clamped = OralExamResult.fromJson({
      's': [99, -3],
    });
    expect(clamped.scores, [20, 0]);
    expect(OralExamData.fromJson('xato'), same(OralExamData.empty));
  });

  test('tarix chegarasi va tozalash (ishlatilganlar saqlanadi)', () {
    var d = OralExamData.empty.withUsed('s', 'c', {'x'});
    for (var i = 0; i < oralExamHistoryLimit + 5; i++) {
      d = d.withResult(
        OralExamResult(
          atMs: i,
          spec: 's',
          cat: 'c',
          name: '',
          questionIds: [],
          scores: const [],
        ),
      );
    }
    expect(d.history.length, oralExamHistoryLimit);
    expect(d.history.first.atMs, oralExamHistoryLimit + 4);
    final cleared = d.withoutHistory();
    expect(cleared.history, isEmpty);
    expect(cleared.usedFor('s', 'c'), {'x'});
  });
}
