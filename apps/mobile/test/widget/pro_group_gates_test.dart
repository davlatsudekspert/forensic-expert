// Guruh testi: guruh yaratish va test o‘tkazish — Ustoz Pro (egasi qarori, 2026-10-24);
// talabaning guruhga qo‘shilishi va testni yechishi HOZIRCHA BEPUL (2026-10-31).
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/floating_nav_flag.dart';
import 'package:forensic_expert/core/widgets/pro_lock_card.dart';
import 'package:forensic_expert/domain/plan/plan_models.dart';

import '../helpers/class_groups_world.dart';
import '../helpers/plan_fakes.dart';

void main() {
  setUp(() {
    floatingNavEnabled = true;
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
  });
  tearDown(() => debugDefaultTargetPlatformOverride = null);

  String realTopic(GroupsWorld w) =>
      w.topics.firstWhere((t) => !t.id.contains('~')).id;

  Future<void> scrollTo(WidgetTester tester, Key target) async {
    await tester.scrollUntilVisible(
      find.byKey(target),
      150,
      scrollable: find
          .descendant(
            of: find.byKey(const Key('grp.lesson.list')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.ensureVisible(find.byKey(target));
    await tester.pumpAndSettle();
  }

  Finder lockOn(String key) => find.descendant(
    of: find.byKey(Key(key), skipOffstage: false),
    matching: find.byIcon(Icons.lock_outline),
  );

  Future<GroupsWorld> openLessonTest(WidgetTester tester, {Plan? plan}) async {
    final w = GroupsWorld.real();
    w.backend.create('teacher', 'Guruh A');
    await w.open(
      tester,
      uid: 'teacher',
      location: Routes.groupLessonTest(realTopic(w)),
      extra: planOverrides(plan),
    );
    return w;
  }

  testWidgets('bepul: hamma savol soni qulfli → Pro sahifasi', (tester) async {
    await openLessonTest(tester);
    await scrollTo(tester, const Key('grp.count.20'));
    expect(lockOn('grp.count.10'), findsOneWidget);
    expect(lockOn('grp.count.15'), findsOneWidget);
    expect(lockOn('grp.count.20'), findsOneWidget);
    await tester.tap(find.byKey(const Key('grp.count.20')));
    await frames(tester);
    expect(find.byKey(const Key('pro.includes.teacher')), findsOneWidget);
    await closeApp(tester);
  });

  testWidgets('Ustoz Pro: 20 savol tanlanadi', (tester) async {
    await openLessonTest(tester, plan: Plan.teacher);
    await scrollTo(tester, const Key('grp.count.20'));
    expect(lockOn('grp.count.20'), findsNothing);
    await tester.tap(find.byKey(const Key('grp.count.20')));
    await frames(tester);
    expect(find.byKey(const Key('pro.includes.teacher')), findsNothing);
    expect(
      tester.widget<ChoiceChip>(find.byKey(const Key('grp.count.20'))).selected,
      isTrue,
    );
    await closeApp(tester);
  });

  testWidgets('bepul: yangi guruh qulfli (bepul guruh yo‘q)', (tester) async {
    await openLessonTest(tester);
    await scrollTo(tester, const Key('grp.lesson.newGroup'));
    expect(lockOn('grp.lesson.newGroup'), findsOneWidget);
    await tester.tap(find.byKey(const Key('grp.lesson.newGroup')));
    await frames(tester);
    expect(find.byKey(const Key('pro.includes.teacher')), findsOneWidget);
    await closeApp(tester);
  });

  testWidgets('Guruhlar sahifasi: guruh yaratish qulfli', (tester) async {
    final w = GroupsWorld.real();
    w.backend.create('teacher', 'Guruh A');
    await w.open(tester, uid: 'teacher', location: Routes.groups);
    expect(lockOn('grp.createButton'), findsOneWidget);
    await w.open(tester, uid: 'teacher', location: Routes.groupNew);
    expect(
      find.byKey(const Key('pro.lock.unlimitedGroupTests')),
      findsOneWidget,
    );
    await closeApp(tester);
  });

  testWidgets('Ustoz Pro: ikkinchi guruh yaratish ochiq', (tester) async {
    final w = GroupsWorld.real();
    w.backend.create('teacher', 'Guruh A');
    await w.open(
      tester,
      uid: 'teacher',
      location: Routes.groupNew,
      extra: planOverrides(Plan.teacher),
    );
    expect(find.byType(ProLockCard), findsNothing);
    expect(find.byKey(const Key('grp.nameField')), findsOneWidget);
    await closeApp(tester);
  });

  testWidgets(
    'talaba (Pro’siz): guruhga qo‘shilish BEPUL (2026-10-31 qarori)',
    (tester) async {
      final w = GroupsWorld.real();
      await w.open(tester, uid: 'student1', location: Routes.groupJoin);
      expect(find.byKey(const Key('pro.lock.fullQuizBank')), findsNothing);
      expect(find.byType(ProLockCard), findsNothing);
      await closeApp(tester);
    },
  );
}
