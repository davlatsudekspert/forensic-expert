// Admin «O‘tkazilgan testlar»: ro‘yxat (ustoz, guruh, o‘rtacha ball/baho)
// va bitta test natijalari.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/account.dart';
import 'package:forensic_expert/app/plan.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/data/plan/fake_plan_service.dart';
import 'package:forensic_expert/domain/admin/admin_class_tests.dart';
import 'package:forensic_expert/domain/admin/admin_models.dart';

import '../helpers/pump_app.dart';

void main() {
  final tests = [
    AdminClassTest(
      kind: AdminClassTestKind.assignment,
      id: 'a1',
      at: DateTime(2026, 11, 2, 9, 50),
      teacherName: 'Qutbiddin Siddiqov',
      teacherEmail: 'q@example.uz',
      groupName: '402',
      topicTitle: 'Oraliq nazorat: Sud tibbiyoti',
      questionCount: 10,
      participants: 12,
      finished: 10,
      avgScore100: 83.4,
    ),
    AdminClassTest(
      kind: AdminClassTestKind.live,
      id: 'l1',
      at: DateTime(2026, 11, 1, 10),
      teacherName: 'Davlat',
      teacherEmail: 'd@example.uz',
      code: '123456',
      topicTitle: 'Jonli sinf mavzusi',
      questionCount: 5,
      participants: 5,
      finished: 5,
    ),
  ];

  Future<FakeAdminPlanService> open(
    WidgetTester tester, {
    bool admin = true,
  }) async {
    final svc = FakeAdminPlanService(
      tests: tests,
      results: {
        'a1': const [
          AdminClassTestResult(nickname: 'Dilnoza', correct: 9, total: 10),
          AdminClassTestResult(nickname: 'Jasur'),
        ],
      },
    );
    await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz'),
      initialLocation: Routes.adminClassTests,
      overrides: [
        serverAccessProvider.overrideWith(
          (ref) async => ServerAccess(isAdmin: admin),
        ),
        adminPlanServiceProvider.overrideWithValue(svc),
      ],
    );
    return svc;
  }

  testWidgets('ro‘yxat: ustoz, guruh, o‘rtacha ball va baho; natijalar', (
    tester,
  ) async {
    final svc = await open(tester);
    expect(find.byKey(const Key('adminTests.list')), findsOneWidget);
    expect(find.text('Ustoz: Qutbiddin Siddiqov'), findsOneWidget);
    expect(find.text('Guruh: 402'), findsOneWidget);
    expect(find.text('10 / 12 topshirdi'), findsOneWidget);
    expect(find.text('O‘rtacha ball (100): 83.4 · Baho: 4'), findsOneWidget);
    expect(find.text('Hali natija yo‘q'), findsOneWidget);
    await tester.tap(find.byKey(const Key('adminTests.item.a1')));
    await tester.pumpAndSettle();
    expect(svc.calls, contains('classTestDetail:a1'));
    expect(find.text('Dilnoza'), findsOneWidget);
    expect(find.text('Ball (100): 90.0 · Baho: 5'), findsOneWidget);
    expect(find.text('Topshirmagan'), findsOneWidget);
  });

  testWidgets('admin emas: ochilmaydi', (tester) async {
    await open(tester, admin: false);
    expect(find.byKey(const Key('adminTests.list')), findsNothing);
  });
}
