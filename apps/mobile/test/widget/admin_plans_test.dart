// Admin «Pro berish»: email + reja + muddat, ro‘yxat, olib tashlash.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/account.dart';
import 'package:forensic_expert/app/plan.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/data/plan/fake_plan_service.dart';
import 'package:forensic_expert/domain/admin/admin_models.dart';
import 'package:forensic_expert/domain/plan/plan_models.dart';
import 'package:forensic_expert/domain/ports/plan_ports.dart';

import '../helpers/pump_app.dart';

void main() {
  Future<FakeAdminPlanService> open(
    WidgetTester tester, {
    bool admin = true,
    List<AdminPlanRow>? rows,
  }) async {
    final svc = FakeAdminPlanService(rows: rows);
    await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz'),
      initialLocation: Routes.adminPlans,
      overrides: [
        serverAccessProvider.overrideWith(
          (ref) async => ServerAccess(isAdmin: admin),
        ),
        adminPlanServiceProvider.overrideWithValue(svc),
      ],
    );
    return svc;
  }

  Future<void> tapKey(WidgetTester tester, String key) async {
    final f = find.byKey(Key(key));
    await tester.ensureVisible(f);
    await tester.pumpAndSettle();
    await tester.tap(f);
    await tester.pumpAndSettle();
  }

  testWidgets('admin emas: ekran ochilmaydi', (tester) async {
    await open(tester, admin: false);
    expect(find.byKey(const Key('adminPlans.list')), findsNothing);
    expect(find.byKey(const Key('admin.forbidden')), findsOneWidget);
  });

  testWidgets('berish: email + reja + muddat → ro‘yxatda paydo bo‘ladi', (
    tester,
  ) async {
    final svc = await open(tester);
    expect(find.byKey(const Key('adminPlans.empty')), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('adminPlans.email')),
      'Ali@Lab.uz',
    );
    await tapKey(tester, 'adminPlans.plan.teacher');
    await tapKey(tester, 'adminPlans.days.90');
    await tapKey(tester, 'adminPlans.grant');
    expect(svc.calls, contains('set:Ali@Lab.uz:teacher'));
    expect(find.text('Reja berildi.'), findsOneWidget);
    expect(find.byKey(const Key('adminPlans.row.ali@lab.uz')), findsOneWidget);
    expect(find.textContaining('Ustoz Pro'), findsWidgets);
    expect(
      find.textContaining('Ustoz Pro · Administrator bergan'),
      findsOneWidget,
    );
  });

  testWidgets('noto‘g‘ri email: tushunarli xato, serverga so‘rov yo‘q', (
    tester,
  ) async {
    final svc = await open(tester);
    await tester.enterText(find.byKey(const Key('adminPlans.email')), 'abc');
    await tapKey(tester, 'adminPlans.grant');
    expect(find.text('To‘g‘ri email manzil kiriting.'), findsOneWidget);
    expect(svc.calls.where((c) => c.startsWith('set')), isEmpty);
  });

  testWidgets('olib tashlash: qator o‘chadi', (tester) async {
    final svc = await open(
      tester,
      rows: [
        AdminPlanRow(
          email: 'ali@lab.uz',
          plan: Plan.expert,
          source: PlanSource.admin,
          expiresAt: DateTime.now().add(const Duration(days: 10)),
          updatedAt: DateTime.now(),
        ),
      ],
    );
    expect(find.byKey(const Key('adminPlans.row.ali@lab.uz')), findsOneWidget);
    await tapKey(tester, 'adminPlans.remove.ali@lab.uz');
    expect(svc.calls, contains('set:ali@lab.uz:null'));
    expect(find.text('Reja olib tashlandi.'), findsOneWidget);
    expect(find.byKey(const Key('adminPlans.row.ali@lab.uz')), findsNothing);
  });

  testWidgets('admin panelda «Pro berish» bo‘limi bor', (tester) async {
    await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz'),
      initialLocation: Routes.admin,
      overrides: [
        serverAccessProvider.overrideWith(
          (ref) async => const ServerAccess(isAdmin: true),
        ),
        adminDashboardProvider.overrideWith(
          (ref) async => const AdminDashboard(totals: {}),
        ),
        adminPlanServiceProvider.overrideWithValue(FakeAdminPlanService()),
      ],
    );
    expect(find.byKey(const Key('admin.nav.plans')), findsOneWidget);
  });
}
