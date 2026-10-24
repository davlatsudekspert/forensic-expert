// Ustoz Pro: guruh testi — 1 guruh va 10 savol bepul, ko‘prog‘i qulfli.
// Talabaning ustoz bergan testni yechishi va QR bilan qo‘shilishi — doim bepul.
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

  testWidgets('bepul: 10 savol ochiq, 15 va 20 qulfli → Pro sahifasi', (
    tester,
  ) async {
    await openLessonTest(tester);
    await scrollTo(tester, const Key('grp.count.20'));
    expect(lockOn('grp.count.10'), findsNothing);
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

  testWidgets('bepul: ikkinchi guruh qulfli (1 guruh bepul)', (tester) async {
    await openLessonTest(tester);
    await scrollTo(tester, const Key('grp.lesson.newGroup'));
    expect(lockOn('grp.lesson.newGroup'), findsOneWidget);
    await tester.tap(find.byKey(const Key('grp.lesson.newGroup')));
    await frames(tester);
    expect(find.byKey(const Key('pro.includes.teacher')), findsOneWidget);
    await closeApp(tester);
  });

  testWidgets('Guruhlar sahifasi: ikkinchi guruh yaratish qulfli', (
    tester,
  ) async {
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

  testWidgets('talaba: guruhga qo‘shilish va test yechish — doim bepul', (
    tester,
  ) async {
    final w = GroupsWorld.real();
    await w.open(tester, uid: 'student1', location: Routes.groupJoin);
    expect(find.byType(ProLockCard), findsNothing);
    expect(find.byIcon(Icons.lock_outline), findsNothing);
    await closeApp(tester);
  });
}
