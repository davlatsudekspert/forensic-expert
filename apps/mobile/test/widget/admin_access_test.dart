import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/account.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/router.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/domain/admin/admin_models.dart';
import 'package:forensic_expert/domain/ports/account_ports.dart';
import 'package:forensic_expert/domain/ports/billing_ports.dart';

import '../helpers/fake_store.dart';
import '../helpers/pilot_content.dart';
import '../helpers/pump_app.dart';
import '../helpers/referral_fakes.dart';

class _FakeAccount implements AccountService {
  _FakeAccount({this.access = ServerAccess.none, this.data});

  final ServerAccess access;
  final AdminDashboard? data;
  final devices = <String>[];
  final grants = <(String, String?)>[];

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

  @override
  Future<AdminGrantResult> setAccess(String email, String? tier) async {
    grants.add((email, tier));
    return AdminGrantResult.granted;
  }
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
      'tier': 'professionalPro',
      'is_admin': true,
    },
  ],
});

void main() {
  group('server grant', () {
    test('grant store’dan yuqori bo‘lsa — Pro (server tasdiqlagan)', () {
      final e = mergeServerGrant(
        Entitlements.free,
        const ServerAccess(tier: PlanTier.professionalPro),
      );
      expect(e.effectiveTier, PlanTier.professionalPro);
      expect(e.verification, EntitlementVerification.serverVerified);
      expect(
        mergeServerGrant(Entitlements.free, ServerAccess.none),
        same(Entitlements.free),
      );
      expect(
        ServerAccess.fromJson({'tier': 'hacker', 'is_admin': 'yes'}).tier,
        isNull,
      );
      expect(
        ServerAccess.fromJson({'tier': 'hacker', 'is_admin': 'yes'}).isAdmin,
        isFalse,
      );
    });
  });

  late PilotContent pilot;
  setUpAll(() async => pilot = await loadPilotContent());

  testWidgets('egasi grant’i PDF tugmasini ochadi (store — bepul)', (
    tester,
  ) async {
    final acc = _FakeAccount(
      access: const ServerAccess(tier: PlanTier.professionalPro),
    );
    await pumpApp(
      tester,
      settings: completedSettings(),
      initialLocation: Routes.source('SRC-PMC8400298'),
      testFixtures: false,
      overrides: [
        ...pilot.overrides,
        authRepositoryProvider.overrideWithValue(await signedInMockAuth()),
        entitlementServiceProvider.overrideWithValue(FakeStore()),
        accountServiceProvider.overrideWithValue(acc),
      ],
    );
    expect(find.byIcon(Icons.picture_as_pdf_outlined), findsOneWidget);
    expect(acc.devices, isNotEmpty);
  });

  testWidgets('admin: Profil’da panel, statistika va Pro berish', (
    tester,
  ) async {
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
    final email = find.byKey(const Key('admin.grantEmail'));
    await tester.scrollUntilVisible(
      email,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(email, 'friend@lab.uz');
    // Tugma faqat manzil haqiqiy ko‘rinsa ochiladi — rebuild kutiladi.
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('admin.grant')));
    await tester.pumpAndSettle();
    expect(acc.grants.single, ('friend@lab.uz', 'professionalPro'));
    expect(find.text('Granted: Professional Pro'), findsOneWidget);
    // Keyingi odamga tayyor bo‘lsin: maydon tozalanadi, tugmalar yopiladi.
    expect(tester.widget<TextField>(email).controller!.text, isEmpty);
    expect(
      tester.widget<FilledButton>(find.byKey(const Key('admin.grant'))).enabled,
      isFalse,
    );
  });

  testWidgets('admin: xato pochta — tugmalar yopiq, xato matni chiqadi', (
    tester,
  ) async {
    final acc = _FakeAccount(
      access: const ServerAccess(isAdmin: true),
      data: _dash,
    );
    await pumpApp(
      tester,
      settings: completedSettings(),
      initialLocation: Routes.admin,
      overrides: [
        authRepositoryProvider.overrideWithValue(await signedInMockAuth()),
        accountServiceProvider.overrideWithValue(acc),
      ],
    );
    final email = find.byKey(const Key('admin.grantEmail'));
    await tester.scrollUntilVisible(
      email,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    // Bo‘sh maydon: hali xato emas, lekin hech narsa yuborilmaydi.
    expect(find.text('This is not an e-mail address.'), findsNothing);
    for (final key in ['admin.grant', 'admin.grantStudent', 'admin.revoke']) {
      expect(
        tester.widget<ButtonStyleButton>(find.byKey(Key(key))).enabled,
        isFalse,
        reason: key,
      );
    }
    await tester.enterText(email, 'friend@lab');
    await tester.pumpAndSettle();
    expect(find.text('This is not an e-mail address.'), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byKey(const Key('admin.grant'))).enabled,
      isFalse,
    );
    expect(acc.grants, isEmpty);
  });

  testWidgets('admin: «Talaba Pro» — studentPro yuboriladi', (tester) async {
    final acc = _FakeAccount(
      access: const ServerAccess(isAdmin: true),
      data: _dash,
    );
    await pumpApp(
      tester,
      settings: completedSettings(),
      initialLocation: Routes.admin,
      overrides: [
        authRepositoryProvider.overrideWithValue(await signedInMockAuth()),
        accountServiceProvider.overrideWithValue(acc),
      ],
    );
    final email = find.byKey(const Key('admin.grantEmail'));
    await tester.scrollUntilVisible(
      email,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.enterText(email, 'student@uni.uz');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('admin.grantStudent')));
    await tester.pumpAndSettle();
    expect(acc.grants.single, ('student@uni.uz', 'studentPro'));
    expect(find.text('Granted: Student Pro'), findsOneWidget);
  });

  testWidgets('admin: olib tashlash tasdiq so‘raydi; bekor qilsa — yubormaydi', (
    tester,
  ) async {
    final acc = _FakeAccount(
      access: const ServerAccess(isAdmin: true),
      data: _dash,
    );
    await pumpApp(
      tester,
      settings: completedSettings(),
      initialLocation: Routes.admin,
      overrides: [
        authRepositoryProvider.overrideWithValue(await signedInMockAuth()),
        accountServiceProvider.overrideWithValue(acc),
      ],
    );
    final email = find.byKey(const Key('admin.grantEmail'));
    await tester.scrollUntilVisible(
      email,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.enterText(email, 'friend@lab.uz');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('admin.revoke')));
    await tester.pumpAndSettle();
    expect(find.text('Remove access?'), findsOneWidget);
    await tester.tap(find.byKey(const Key('admin.revoke.cancel')));
    await tester.pumpAndSettle();
    expect(acc.grants, isEmpty);

    await tester.tap(find.byKey(const Key('admin.revoke')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('admin.revoke.confirm')));
    await tester.pumpAndSettle();
    expect(acc.grants.single, ('friend@lab.uz', null));
  });

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
