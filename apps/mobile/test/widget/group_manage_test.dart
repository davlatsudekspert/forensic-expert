import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/floating_nav_flag.dart';
import 'package:forensic_expert/domain/plan/plan_models.dart';

import '../helpers/class_groups_world.dart';
import '../helpers/pump_app.dart' show testDefaultPlan;

/// Ustoz guruhni arxivlaydi / o‘chiradi: tasdiq oynasi, so‘ng ro‘yxatdan yo‘qoladi.
void main() {
  setUpAll(() => testDefaultPlan = Plan.teacher);
  tearDownAll(() => testDefaultPlan = null);
  setUp(() => floatingNavEnabled = true);

  for (final delete in [false, true]) {
    testWidgets(delete ? 'guruhni o‘chirish' : 'guruhni arxivlash', (
      tester,
    ) async {
      final w = GroupsWorld.real();
      final g = w.backend.create('teacher', 'Guruh X').value!;
      await w.open(tester, uid: 'teacher', location: Routes.group(g.id));
      expect(find.byKey(const Key('grp.manageMenu')), findsOneWidget);

      await tester.tap(find.byKey(const Key('grp.manageMenu')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key(delete ? 'grp.delete' : 'grp.archive')));
      await tester.pumpAndSettle();
      // Tasdiq oynasi chiqadi; hali hech narsa o‘chmagan.
      expect(find.byKey(const Key('grp.manageYes')), findsOneWidget);
      expect(w.backend.list('teacher').value!.teaching.length, 1);

      await tester.tap(find.byKey(const Key('grp.manageYes')));
      await tester.pumpAndSettle();
      expect(w.backend.list('teacher').value!.teaching, isEmpty);
    });
  }
}
