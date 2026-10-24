// Admin (server roli) — VIP: hamma Pro funksiya ochiq; oddiy foydalanuvchi —
// faqat o‘z rejasi (egasi qarori, 2026-10-24).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/account.dart';
import 'package:forensic_expert/app/plan.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/settings/app_settings.dart';
import 'package:forensic_expert/domain/admin/admin_models.dart';
import 'package:forensic_expert/domain/plan/plan_models.dart';
import 'package:forensic_expert/features/class_groups/presentation/groups_screens.dart';

import '../helpers/pump_app.dart';

void main() {
  for (final admin in [true, false]) {
    testWidgets('admin=$admin: Pro funksiyalar', (tester) async {
      final c = await pumpApp(
        tester,
        settings: completedSettings(lang: 'uz', mode: UserMode.student),
        initialLocation: Routes.groupJoin,
        overrides: [
          serverAccessProvider.overrideWith(
            (ref) async => ServerAccess(isAdmin: admin),
          ),
        ],
      );
      await tester.pumpAndSettle();
      for (final f in ProFeature.values) {
        expect(c.read(proAllowedProvider(f)), admin, reason: f.name);
      }
      expect(
        find.byType(GroupJoinScreen),
        admin ? findsOneWidget : findsNothing,
      );
      expect(
        find.byKey(const Key('pro.lock.fullQuizBank')),
        admin ? findsNothing : findsOneWidget,
      );
    });
  }
}
