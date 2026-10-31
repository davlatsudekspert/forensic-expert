// Bepul / Pro bo‘linishi (2026-10-31): talaba guruhga qo‘shiladi va ustoz bergan
// testni YECHADI (bepul); natijada faqat ballni ko‘radi — to‘g‘ri javoblar,
// izoh va xatolar tahlili Pro. Bayroq o‘chiq bo‘lsa — avvalgidek.
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/plan.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/floating_nav_flag.dart';
import 'package:forensic_expert/core/widgets/pro_lock_card.dart';
import 'package:forensic_expert/domain/class_groups/class_groups_models.dart';
import 'package:forensic_expert/domain/plan/plan_models.dart';
import 'package:forensic_expert/features/class_groups/presentation/test_screens.dart';

import '../helpers/class_groups_world.dart';
import '../helpers/plan_fakes.dart';

const _correctText = '50% va undan yuqori';

Future<({String gid, String aid})> _setup(
  GroupsWorld w, {
  required bool solved,
}) async {
  final g = w.backend.create('teacher', '4-kurs, 2-guruh').value!;
  w.backend.join('s1', code: g.code!, nickname: 'Talaba 1');
  final a = (await w.backend.createAssignment(
    'teacher',
    g.id,
    const AssignmentDraft(
      topicId: 'tox-co',
      questionCount: 4,
      timeLimitMin: 15,
    ),
  )).value!;
  if (solved) {
    final qs = w.backend.open('s1', a.id).value!.questions;
    w.backend.submit('s1', a.id, {
      for (final q in qs) q.id: q.options.indexOf(_correctText),
    });
    // Ustoz testni yopadi → javoblar ochiladi (server qarori).
    w.backend.closeAssignment('teacher', a.id);
  }
  return (gid: g.id, aid: a.id);
}

void main() {
  setUp(() {
    floatingNavEnabled = true;
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
  });
  tearDown(() => debugDefaultTargetPlatformOverride = null);

  Future<void> openResult(
    WidgetTester tester, {
    required bool strict,
    Plan? plan,
  }) async {
    final w = GroupsWorld();
    final s = await _setup(w, solved: true);
    await w.open(
      tester,
      uid: 's1',
      location: Routes.groupResult(s.gid, s.aid),
      extra: [
        proStrictProvider.overrideWithValue(strict),
        ...planOverrides(plan),
      ],
    );
  }

  testWidgets('qat’iy, bepul talaba: ball ko‘rinadi, javoblar/izoh Pro', (
    tester,
  ) async {
    await openResult(tester, strict: true);
    expect(find.byKey(const Key('grp.score')), findsOneWidget);
    expect(find.byKey(const Key('grp.item.0')), findsNothing);
    expect(find.byKey(const Key('pro.lock.groupTestReview')), findsOneWidget);
    expect(tester.takeException(), isNull);
    await closeApp(tester);
  });

  testWidgets('qat’iy, pullik reja: javoblar va izoh ko‘rinadi', (
    tester,
  ) async {
    await openResult(tester, strict: true, plan: Plan.student);
    expect(find.byKey(const Key('grp.item.0')), findsOneWidget);
    expect(find.byType(ProLockCard), findsNothing);
    await closeApp(tester);
  });

  testWidgets('bayroq o‘chiq: javoblar avvalgidek ochiq', (tester) async {
    await openResult(tester, strict: false);
    expect(find.byKey(const Key('grp.item.0')), findsOneWidget);
    expect(find.byType(ProLockCard), findsNothing);
    await closeApp(tester);
  });

  testWidgets('qat’iy, bepul talaba: testni YECHA oladi (qulf yo‘q)', (
    tester,
  ) async {
    final w = GroupsWorld();
    final s = await _setup(w, solved: false);
    await w.open(
      tester,
      uid: 's1',
      location: Routes.groupTest(s.gid, s.aid),
      extra: [proStrictProvider.overrideWithValue(true)],
    );
    expect(find.byType(GroupTestScreen), findsOneWidget);
    expect(find.byType(ProLockCard), findsNothing);
    await closeApp(tester);
  });
}
