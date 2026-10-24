import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/floating_nav_flag.dart';
import 'package:forensic_expert/core/l10n/generated/app_localizations.dart';
import 'package:forensic_expert/domain/class_groups/class_groups_models.dart';
import 'package:forensic_expert/domain/plan/plan_models.dart';

import '../helpers/class_groups_world.dart';
import '../helpers/pump_app.dart' show testDefaultPlan;

AppLocalizations _l(WidgetTester tester) =>
    AppLocalizations.of(tester.element(find.byType(Scaffold).first));

/// Haqiqiy bankdagi birinchi uz mavzu.
String _realTopic(GroupsWorld w) =>
    w.topics.firstWhere((t) => !t.id.contains('~')).id;

Future<void> _scrollTo(WidgetTester tester, Key list, Key target) async {
  await tester.scrollUntilVisible(
    find.byKey(target),
    150,
    scrollable: find
        .descendant(of: find.byKey(list), matching: find.byType(Scrollable))
        .first,
  );
  await tester.ensureVisible(find.byKey(target));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => testDefaultPlan = Plan.teacher);
  tearDownAll(() => testDefaultPlan = null);
  setUp(() {
    floatingNavEnabled = true;
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
  });
  tearDown(() => debugDefaultTargetPlatformOverride = null);

  testWidgets('maxsus son va daqiqa («Boshqa…»), sozlamalar serverga boradi', (
    tester,
  ) async {
    final w = GroupsWorld.real();
    final topic = _realTopic(w);
    final g = w.backend.create('teacher', 'Guruh B').value!;
    await w.open(
      tester,
      uid: 'teacher',
      location: Routes.groupAssignFor(g.id, topic),
    );
    await _scrollTo(
      tester,
      const Key('grp.assignList'),
      const Key('grp.count.custom'),
    );
    await tester.tap(find.byKey(const Key('grp.count.custom')));
    await frames(tester);
    await tester.enterText(find.byKey(const Key('grp.customField')), '25');
    await tester.tap(find.byKey(const Key('grp.customOk')));
    await frames(tester);
    await _scrollTo(
      tester,
      const Key('grp.assignList'),
      const Key('grp.time.custom'),
    );
    await tester.tap(find.byKey(const Key('grp.time.custom')));
    await frames(tester);
    await tester.enterText(find.byKey(const Key('grp.customField')), '7');
    await tester.tap(find.byKey(const Key('grp.customOk')));
    await frames(tester);
    await _scrollTo(
      tester,
      const Key('grp.assignList'),
      const Key('grp.open.3'),
    );
    await tester.tap(find.byKey(const Key('grp.open.3')));
    await frames(tester);
    await _scrollTo(
      tester,
      const Key('grp.assignList'),
      const Key('grp.assignSubmit'),
    );
    await tester.tap(find.byKey(const Key('grp.assignSubmit')));
    await frames(tester);
    final a = w.backend.detail('teacher', g.id).value!.assignments.single;
    expect(a.questionCount, 25);
    expect(a.timeLimitMin, 7);
    expect(a.dueAt, w.now.add(const Duration(days: 3)));
    expect(a.variantMode, isFalse, reason: '30 < 2 × 25 — variant o‘chadi');
    await closeApp(tester);
  });

  for (final (size, scale) in [
    (const Size(390, 844), 1.0),
    (const Size(360, 640), 1.3),
  ]) {
    testWidgets('«Umumiy test»: manbadan hammasini tanlash → 50 savol → 20 '
        'daqiqa → variant → yuborish → talaba yechadi → natija ustozda '
        '(${size.width.toInt()}×${size.height.toInt()}, ${scale}x)', (
      tester,
    ) async {
      final w = GroupsWorld.real();
      final g = w.backend.create('teacher', '4-kurs, 2-guruh').value!;
      w.backend.join('stu', code: g.code!, nickname: 'G’ayrat');
      await w.open(
        tester,
        uid: 'teacher',
        size: size,
        textScale: scale,
        location: Routes.group(g.id),
      );
      await tester.tap(find.byKey(const Key('grp.mixedButton')));
      await frames(tester);
      const list = Key('grp.mixedList');
      // Manba: «Sud tibbiyoti · 4-kurs, davolash ishi» (10 mavzu × 30).
      const src = 'sud-tibbiyoti-4-davolash';
      await _scrollTo(tester, list, const Key('grp.source.$src'));
      await tester.tap(
        find
            .descendant(
              of: find.byKey(const Key('grp.source.$src')),
              matching: find.byType(ListTile),
            )
            .first,
      );
      await frames(tester);
      final all = find.byKey(const Key('grp.sourceAll.$src'));
      await _scrollTo(tester, list, const Key('grp.sourceAll.$src'));
      await tester.tap(all.first);
      await frames(tester);
      await _scrollTo(tester, list, const Key('grp.count.50'));
      await tester.tap(find.byKey(const Key('grp.count.50')));
      await frames(tester);
      await _scrollTo(tester, list, const Key('grp.time.20'));
      await tester.tap(find.byKey(const Key('grp.time.20')));
      await frames(tester);
      await _scrollTo(tester, list, const Key('grp.variantSwitch'));
      expect(
        tester
            .widget<SwitchListTile>(find.byKey(const Key('grp.variantSwitch')))
            .value,
        isTrue,
      );
      await _scrollTo(tester, list, const Key('grp.mixedPreviewButton'));
      await tester.tap(find.byKey(const Key('grp.mixedPreviewButton')));
      await frames(tester);
      expect(find.byKey(const Key('grp.mixedPreview')), findsOneWidget);
      await tester.tapAt(const Offset(20, 40));
      await frames(tester);
      await _scrollTo(tester, list, const Key('grp.mixedSubmit'));
      await tester.tap(find.byKey(const Key('grp.mixedSubmit')));
      await frames(tester);
      final a = w.backend.detail('teacher', g.id).value!.assignments.single;
      expect(a.questionCount, 50);
      expect(a.timeLimitMin, 20);
      expect(a.variantMode, isTrue);
      expect(a.topics.length, greaterThan(1));
      expect(a.poolSize, 100, reason: 'variant: 2N, navbatma-navbat');
      expect(a.topicTitle, startsWith('Umumiy test: '));
      // Talaba yechadi → natija ustoz panelida.
      final qs = w.backend.open('stu', a.id).value!.questions;
      expect(qs, hasLength(50));
      expect(qs.map((q) => q.id).toSet(), hasLength(50));
      w.backend.submit('stu', a.id, {for (final q in qs) q.id: 0});
      await frames(tester, 6);
      final l = _l(tester);
      expect(find.text(l.grpCounts(0, 0, 1)), findsOneWidget);
      // «Testni yopish»: AppBar’da doim ko‘rinadi; ro‘yxatdagisi ham
      // suzuvchi menyu ostida qolmaydi va bosiladi.
      final bar = find.byKey(const Key('grp.closeTestBar'));
      expect(bar, findsOneWidget);
      expect(tester.getRect(bar).top, greaterThanOrEqualTo(0));
      final close = find.byKey(const Key('grp.closeTest'));
      final nav = find.byKey(const Key('nav.floating'));
      await tester.ensureVisible(close);
      await tester.pumpAndSettle();
      expect(tester.getRect(close).bottom, lessThan(tester.getRect(nav).top));
      await tester.tap(close);
      await frames(tester);
      expect(find.byKey(const Key('grp.closeYes')), findsOneWidget);
      await tester.tap(find.byKey(const Key('grp.closeYes')));
      await frames(tester);
      expect(
        w.backend.detail('teacher', g.id).value!.assignments.single.closed,
        isTrue,
      );
      expect(tester.takeException(), isNull);
      await closeApp(tester);
    });
  }

  testWidgets('topshirish sahifasi 360×640, shrift 1.3x — taşmasiz', (
    tester,
  ) async {
    final w = GroupsWorld.real();
    final g = w.backend.create('teacher', 'Guruh C').value!;
    await w.open(
      tester,
      uid: 'teacher',
      size: const Size(360, 640),
      textScale: 1.3,
      location: Routes.groupAssignFor(g.id, _realTopic(w)),
    );
    expect(tester.takeException(), isNull);
    await _scrollTo(
      tester,
      const Key('grp.assignList'),
      const Key('grp.assignSubmit'),
    );
    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('grp.assignSubmit')), findsOneWidget);
    await closeApp(tester);
  });

  test('server talabi: maxsus son ≤ hovuz, daqiqa 1–180', () {
    final now = DateTime(2026, 10, 18);
    expect(
      AssignmentDraft(
        topicId: 'x',
        questionCount: 120,
        dueAt: now.add(const Duration(days: 1)),
      ).validate(poolSize: 150, now: now),
      isNull,
    );
    expect(
      const AssignmentDraft(
        topicId: 'x',
        questionCount: 5,
        timeLimitMin: 181,
      ).validate(poolSize: 150, now: now),
      GroupFailure.invalidSettings,
    );
  });
}
