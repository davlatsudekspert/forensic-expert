import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/router.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/data/auth/mock_auth_repository.dart';
import 'package:forensic_expert/domain/ports/billing_ports.dart';

import '../helpers/fake_store.dart';
import '../helpers/pump_app.dart';

/// Release: akkaunt va obuna ekranlari (MOCK backend, TEST narx).
/// Nusxa: `docs/screenshots/release/`.
void main() {
  Future<MockAuthRepository> signedIn() async {
    final a = MockAuthRepository();
    await a.register(
      email: 'expert@lab.uz',
      password: 'TestPassw0rd!',
      acceptedTermsVersion: 'v',
    );
    await a.verifyEmail(email: 'expert@lab.uz', code: a.outbox.last.code!);
    return a;
  }

  final cases =
      <
        ({
          String name,
          String lang,
          ThemeMode theme,
          String route,
          bool auth,
          FakeStore store,
          Key? scrollTo,
        })
      >[
        (
          name: 'rc_01_paywall_en',
          lang: 'en',
          theme: ThemeMode.light,
          route: Routes.purchase,
          auth: false,
          store: FakeStore(price: 'TEST 1.00'),
          scrollTo: null,
        ),
        (
          name: 'rc_02_paywall_pro_ru_dark',
          lang: 'ru',
          theme: ThemeMode.dark,
          route: Routes.purchase,
          auth: true,
          store: FakeStore(price: 'TEST 1.00', owned: true),
          scrollTo: const Key('paywall.tier.professionalPro'),
        ),
        (
          name: 'rc_03_paywall_no_store_uz',
          lang: 'uz',
          theme: ThemeMode.light,
          route: Routes.purchase,
          auth: false,
          store: FakeStore(withOffers: false),
          scrollTo: null,
        ),
        (
          name: 'rc_04_register_en',
          lang: 'en',
          theme: ThemeMode.light,
          route: Routes.accountRegister,
          auth: false,
          store: FakeStore(),
          scrollTo: null,
        ),
        (
          name: 'rc_05_signin_ru',
          lang: 'ru',
          theme: ThemeMode.light,
          route: Routes.accountSignIn,
          auth: false,
          store: FakeStore(),
          scrollTo: null,
        ),
        (
          name: 'rc_06_verify_uz_dark',
          lang: 'uz',
          theme: ThemeMode.dark,
          route: Routes.accountVerify,
          auth: false,
          store: FakeStore(),
          scrollTo: null,
        ),
        (
          name: 'rc_07_profile_account_en',
          lang: 'en',
          theme: ThemeMode.light,
          route: Routes.profile,
          auth: true,
          store: FakeStore(
            tier: PlanTier.studentPro,
            status: EntitlementStatus.cancelledActiveUntilExpiry,
          ),
          scrollTo: const Key('profile.restore'),
        ),
        (
          name: 'rc_08_delete_account_en',
          lang: 'en',
          theme: ThemeMode.light,
          route: Routes.accountDelete,
          auth: true,
          store: FakeStore(),
          scrollTo: null,
        ),
        (
          name: 'rc_09_profile_guest_uz',
          lang: 'uz',
          theme: ThemeMode.light,
          route: Routes.profile,
          auth: false,
          store: FakeStore(),
          scrollTo: const Key('profile.emailCode'),
        ),
      ];

  for (final c in cases) {
    testWidgets(c.name, (tester) async {
      final auth = c.auth ? await signedIn() : MockAuthRepository();
      final container = await pumpApp(
        tester,
        settings: completedSettings(lang: c.lang, theme: c.theme),
        overrides: [
          authRepositoryProvider.overrideWithValue(auth),
          entitlementServiceProvider.overrideWithValue(c.store),
        ],
      );
      container.read(routerProvider).go(c.route, extra: 'expert@lab.uz');
      await tester.pumpAndSettle();
      final target = c.scrollTo;
      if (target != null) {
        await tester.scrollUntilVisible(
          find.byKey(target),
          200,
          scrollable: find.byType(Scrollable).hitTestable().first,
        );
        await tester.pumpAndSettle();
      }
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/${c.name}.png'),
      );
    });
  }
}
