import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/account.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/router.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/domain/admin/admin_models.dart';
import 'package:forensic_expert/domain/ports/account_ports.dart';

import '../helpers/pilot_content.dart';
import '../helpers/pump_app.dart';
import '../helpers/referral_fakes.dart';

class _FakeAccount implements AccountService {
  _FakeAccount({this.access = ServerAccess.none, this.data});

  final ServerAccess access;
  final AdminDashboard? data;
  final devices = <String>[];

  @override
  bool get isConfigured => true;

  @override
  Future<ServerAccess?> myAccess() async => access;

  @override
  Future<void> registerDevice({
    required String platform,
    required String version,
    required String locale,
    String? region,
  }) async => devices.add(platform);

  @override
  Future<AdminDashboard?> dashboard() async => access.isAdmin ? data : null;
}

final _dash = AdminDashboard.fromJson({
  'totals': {'users': 12, 'android': 8, 'ios': 3, 'ai_requests': '40'},
  'regions': [
    {'region': 'UZ', 'users': 9},
    {'region': '??', 'users': 2},
  ],
  'daily': [
    {'day': '2026-10-06', 'signups': 5},
  ],
  'users': [
    {
      'email': 'expert@lab.uz',
      'platforms': 'android',
      'region': 'UZ',
      'is_admin': true,
    },
  ],
});

void main() {
  group('server access', () {
    test('admin faqat server javobidan; begona qiymat admin bermaydi', () {
      expect(ServerAccess.fromJson({'is_admin': true}).isAdmin, isTrue);
      expect(ServerAccess.fromJson({'is_admin': 'yes'}).isAdmin, isFalse);
      expect(ServerAccess.none.isAdmin, isFalse);
    });
  });

  late PilotContent pilot;
  setUpAll(() async => pilot = await loadPilotContent());

  testWidgets('manba sahifasi: PDF tugmasi hamma uchun ochiq', (tester) async {
    final acc = _FakeAccount();
    await pumpApp(
      tester,
      settings: completedSettings(),
      initialLocation: Routes.source('SRC-PMC8400298'),
      testFixtures: false,
      overrides: [
        ...pilot.overrides,
        authRepositoryProvider.overrideWithValue(await signedInMockAuth()),
        accountServiceProvider.overrideWithValue(acc),
      ],
    );
    expect(find.byIcon(Icons.picture_as_pdf_outlined), findsOneWidget);
    expect(acc.devices, isNotEmpty);
  });

  testWidgets(
    'admin: Profil’da panel va statistika; tarif berish bo‘limi yo‘q',
    (tester) async {
      final acc = _FakeAccount(
        access: const ServerAccess(isAdmin: true),
        data: _dash,
      );
      await pumpApp(
        tester,
        settings: completedSettings(),
        initialLocation: Routes.profile,
        overrides: [
          authRepositoryProvider.overrideWithValue(await signedInMockAuth()),
          accountServiceProvider.overrideWithValue(acc),
        ],
      );
      await tester.tap(find.byKey(const Key('profile.admin')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('admin.stats')), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(find.text('Android'), findsOneWidget);
      expect(find.text('UZ'), findsWidgets);
      // To‘lov/Pro qatlami olib tashlangan: tarif berish maydoni va tugmalari yo‘q.
      for (final k in [
        'admin.grantEmail',
        'admin.grant',
        'admin.grantStudent',
        'admin.revoke',
      ]) {
        expect(
          find.byKey(Key(k), skipOffstage: false),
          findsNothing,
          reason: k,
        );
      }
    },
  );

  testWidgets('oddiy foydalanuvchi: panel ko‘rinmaydi, to‘g‘ridan ham yopiq', (
    tester,
  ) async {
    final c = await pumpApp(
      tester,
      settings: completedSettings(),
      initialLocation: Routes.profile,
      overrides: [
        authRepositoryProvider.overrideWithValue(await signedInMockAuth()),
        accountServiceProvider.overrideWithValue(_FakeAccount(data: _dash)),
      ],
    );
    expect(find.byKey(const Key('profile.admin')), findsNothing);
    c.read(routerProvider).go(Routes.admin);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('admin.forbidden')), findsOneWidget);
    expect(find.byKey(const Key('admin.stats')), findsNothing);
  });
}
