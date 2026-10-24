import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/floating_nav_flag.dart';
import 'package:forensic_expert/core/l10n/generated/app_localizations.dart';
import 'package:forensic_expert/domain/class_groups/class_groups_models.dart';

import '../helpers/class_groups_world.dart';

/// Jonli doska (o‘rin, to‘g‘ri soni, vaqt, holat), «Testni yopish» va
/// «Qiyin savollar» muhokamasi (guruh testi).

AppLocalizations _l(WidgetTester tester) =>
    AppLocalizations.of(tester.element(find.byType(Scaffold).first));

class _Setup {
  _Setup(this.w, this.groupId, this.assignment, this.key, this.ids);

  final GroupsWorld w;
  final String groupId;
  final GroupAssignment assignment;

  /// Savol id → to‘g‘ri indeks.
  final Map<String, int> key;

  /// Talaba uid → doskadagi a’zo id si.
  final Map<String, String> ids;
}

/// 4 talaba: C 10/10 (4 daq), B 8/10 (3 daq), A 8/10 (5 daq), D yechmoqda.
Future<_Setup> _setup({bool finishAll = false}) async {
  final w = GroupsWorld.real();
  final g = w.backend.create('teacher', 'Guruh').value!;
  for (final (uid, name) in [
    ('a', 'Aziza'),
    ('b', 'Bobur'),
    ('c', 'Charos'),
    ('d', 'Dilshod'),
  ]) {
    w.backend.join(uid, code: g.code!, nickname: name);
  }
  final topic = w.topics.firstWhere((t) => !t.id.contains('~')).id;
  final a = (await w.backend.createAssignment(
    'teacher',
    g.id,
    AssignmentDraft(
      topicId: topic,
      questionCount: 10,
      timeLimitMin: 15,
      dueAt: w.now.add(const Duration(days: 1)),
      reveal: RevealPolicy.afterClose,
    ),
  )).value!;
  final key = {
    for (final p in w.backend.preview('teacher', a.id).value!.pool)
      p.id: p.correctIndex,
  };
  final t0 = w.now;
  final attempts = {
    for (final u in ['a', 'b', 'c', 'd']) u: w.backend.open(u, a.id).value!,
  };
  Map<String, int> answers(String u, int wrong) {
    final qs = attempts[u]!.questions;
    return {
      for (final (i, q) in qs.indexed)
        q.id: i < wrong ? (key[q.id]! + 1) % 4 : key[q.id]!,
    };
  }

  // Har kimning vaqti: server soati bo‘yicha boshlanishdan yuborishgacha.
  w.now = t0.add(const Duration(minutes: 3));
  w.backend.submit('b', a.id, answers('b', 2));
  w.now = t0.add(const Duration(minutes: 4));
  w.backend.submit('c', a.id, answers('c', 0));
  w.now = t0.add(const Duration(minutes: 5));
  w.backend.submit('a', a.id, answers('a', 2));
  w.backend.save('d', a.id, {
    for (final q in attempts['d']!.questions.take(3)) q.id: 0,
  });
  if (finishAll) w.backend.submit('d', a.id, answers('d', 8));
  final members = w.backend.detail('teacher', g.id).value!.members;
  final ids = {
    'a': members.firstWhere((m) => m.nickname == 'Aziza').id,
    'b': members.firstWhere((m) => m.nickname == 'Bobur').id,
    'c': members.firstWhere((m) => m.nickname == 'Charos').id,
    'd': members.firstWhere((m) => m.nickname == 'Dilshod').id,
  };
  return _Setup(w, g.id, a, key, ids);
}

String _text(WidgetTester tester, Key k) =>
    tester.widget<Text>(find.byKey(k)).data ?? '';

void main() {
  setUp(() {
    floatingNavEnabled = true;
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
  });
  tearDown(() => debugDefaultTargetPlatformOverride = null);

  test('rankBoardRows: to‘g‘ri soni, teng bo‘lsa vaqt; to‘liq teng — bir '
      'xil o‘rin; yechayotganlar o‘rinsiz', () {
    final t0 = DateTime.utc(2026, 10, 24, 10);
    GroupBoardRow row(
      String n,
      BoardState s, {
      int? score,
      int? mins,
      int answered = 0,
    }) => GroupBoardRow(
      memberId: n,
      nickname: n,
      state: s,
      score: score,
      total: score == null ? null : 10,
      answered: answered,
      startedAt: t0,
      submittedAt: mins == null ? null : t0.add(Duration(minutes: mins)),
    );
    final r = rankBoardRows([
      row('Joined', BoardState.joined),
      row('Solving', BoardState.solving, answered: 4),
      row('Slow', BoardState.finished, score: 8, mins: 9),
      row('Best', BoardState.finished, score: 10, mins: 12),
      row('Fast', BoardState.finished, score: 8, mins: 5),
      row('FastToo', BoardState.finished, score: 8, mins: 5),
    ]);
    expect(r.map((x) => x.row.nickname), [
      'Best',
      'Fast',
      'FastToo',
      'Slow',
      'Solving',
      'Joined',
    ]);
    expect(r.map((x) => x.rank), [1, 2, 2, 4, null, null]);
    expect(r.first.row.spent, const Duration(minutes: 12));
  });

  for (final (size, tag) in [
    (const Size(1920, 1080), '1920x1080'),
    (const Size(1280, 720), '1280x720'),
    (const Size(390, 844), '390x844'),
    (const Size(320, 568), '320x568'),
  ]) {
    testWidgets('katta doska $tag: ism, o‘rin, to‘g‘ri soni, vaqt, holat; '
        'yopish → qiyin savollar', (tester) async {
      final s = await _setup();
      final w = s.w;
      await w.open(
        tester,
        uid: 'teacher',
        size: size,
        iphone: size.width < 600,
        location: Routes.groupBoard(s.groupId, s.assignment.id),
      );
      await frames(tester, 6);
      final l = _l(tester);
      // O‘rinlar: Charos 1 (10/10), Bobur 2 (8/10, 3:00), Aziza 3 (8/10, 5:00).
      expect(_text(tester, Key('grp.bigRank.${s.ids['c']}')), '1');
      expect(_text(tester, Key('grp.bigRank.${s.ids['b']}')), '2');
      expect(_text(tester, Key('grp.bigRank.${s.ids['a']}')), '3');
      expect(_text(tester, Key('grp.bigRank.${s.ids['d']}')), '');
      expect(_text(tester, Key('grp.bigScore.${s.ids['c']}')), '10/10');
      expect(_text(tester, Key('grp.bigScore.${s.ids['b']}')), '8/10');
      expect(_text(tester, Key('grp.bigTime.${s.ids['c']}')), '4:00');
      expect(_text(tester, Key('grp.bigTime.${s.ids['b']}')), '3:00');
      expect(_text(tester, Key('grp.bigTime.${s.ids['a']}')), '5:00');
      expect(_text(tester, Key('grp.bigScore.${s.ids['d']}')), '');
      // Tartib: yuqoridan pastga 1, 2, 3, so‘ng yechayotgan.
      final y = [
        for (final k in ['c', 'b', 'a', 'd'])
          tester.getTopLeft(find.byKey(Key('grp.bigRow.${s.ids[k]}'))).dy,
      ];
      final x0 = tester
          .getTopLeft(find.byKey(Key('grp.bigRow.${s.ids['c']}')))
          .dx;
      final x1 = tester
          .getTopLeft(find.byKey(Key('grp.bigRow.${s.ids['d']}')))
          .dx;
      if (x0 == x1) expect(y, orderedEquals([...y]..sort()));
      expect(find.text('Charos'), findsOneWidget);
      expect(find.text(l.grpColRank), findsWidgets);
      // Ochiq test: «Testni yopish» bor, «Qiyin savollar» bloki yo‘q.
      expect(find.byKey(const Key('grp.board.close')), findsOneWidget);
      expect(find.byKey(const Key('grp.hardest.block')), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byKey(const Key('grp.board.close')));
      await frames(tester);
      await tester.tap(find.byKey(const Key('grp.closeYes')));
      await frames(tester, 10);
      expect(
        w.backend.detail('teacher', s.groupId).value!.assignments.single.closed,
        isTrue,
      );
      expect(find.byKey(const Key('grp.board.closed')), findsOneWidget);
      expect(find.byKey(const Key('grp.hardest.block')), findsOneWidget);
      await tester.ensureVisible(find.byKey(const Key('grp.hardest.open')));
      await tester.tap(find.byKey(const Key('grp.hardest.open')));
      await frames(tester, 8);
      // Muhokama: eng past % savol, variantlar, tushuntirish, manba; ismlar yo‘q.
      expect(find.byKey(const Key('class.discuss')), findsOneWidget);
      expect(find.byKey(const Key('class.discuss.question')), findsOneWidget);
      expect(find.byKey(const Key('class.discuss.wrongPct')), findsOneWidget);
      expect(find.byKey(const Key('class.discuss.option.3')), findsOneWidget);
      expect(
        find.byKey(const Key('class.discuss.explanation')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('class.discuss.source')), findsOneWidget);
      expect(find.text('Charos'), findsNothing);
      expect(find.text('Aziza'), findsNothing);
      expect(tester.takeException(), isNull);
      await closeApp(tester);
    });
  }

  testWidgets('telefon paneli: o‘rin, to‘g‘ri/jami, vaqt; «Qiyin savollar» '
      'bloki yopilgunga qadar izoh bilan', (tester) async {
    final s = await _setup();
    await s.w.open(
      tester,
      uid: 'teacher',
      location: Routes.groupAssignment(s.groupId, s.assignment.id),
    );
    await frames(tester, 6);
    final l = _l(tester);
    expect(_text(tester, Key('grp.rank.${s.ids['c']}')), '1');
    expect(_text(tester, Key('grp.rank.${s.ids['b']}')), '2');
    expect(_text(tester, Key('grp.rank.${s.ids['a']}')), '3');
    expect(_text(tester, Key('grp.score.${s.ids['c']}')), '10/10');
    expect(_text(tester, Key('grp.time.${s.ids['b']}')), '3:00');
    expect(_text(tester, Key('grp.rank.${s.ids['d']}')), FeGlyphsDash.value);
    expect(find.byKey(const Key('grp.hardest.block')), findsOneWidget);
    expect(_text(tester, const Key('grp.hardest.text')), l.grpHardestLocked);
    expect(find.byKey(const Key('grp.hardest.open')), findsNothing);
    await closeApp(tester);
  });

  test('server nusxasi: qiyin savollar faqat ustozga va faqat yopilgach; '
      'eng past % birinchi; ismlar yo‘q', () async {
    final s = await _setup(finishAll: true);
    final b = s.w.backend;
    final aid = s.assignment.id;
    expect(b.hardestDetail('teacher', aid).failure, GroupFailure.notFinished);
    expect(b.hardestDetail('a', aid).failure, GroupFailure.forbidden);
    expect(b.hardestDetail('stranger', aid).failure, GroupFailure.forbidden);
    b.closeAssignment('teacher', aid);
    final r = b.hardestDetail('teacher', aid, limit: 4);
    expect(r.ok, isTrue);
    final items = r.value!;
    expect(items, hasLength(4));
    expect(
      items.map((x) => x.correctPct).toList(),
      orderedEquals([...items.map((x) => x.correctPct)]..sort()),
    );
    expect(items.first.correctPct, lessThan(100));
    for (final (i, x) in items.indexed) {
      expect(x.index, i);
      expect(x.options, hasLength(4));
      expect(x.optionCounts.reduce((p, q) => p + q), x.answered);
      expect(x.optionCounts[x.correctIndex], greaterThan(0));
    }
    expect(r.value.toString(), isNot(contains('Aziza')));
  });
}

/// Doskada «o‘rinsiz» qator belgisi (emdash).
abstract final class FeGlyphsDash {
  static const value = '—';
}
