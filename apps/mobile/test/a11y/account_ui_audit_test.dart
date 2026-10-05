import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/router.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/data/auth/mock_auth_repository.dart';
import 'package:forensic_expert/domain/ports/billing_ports.dart';

import '../helpers/fake_store.dart';
import '../helpers/pump_app.dart';

/// Akkaunt va obuna ekranlari: 320 dp, shrift ×2.0, EN/RU/UZ, light/dark;
/// xato, bo‘sh (store yo‘q) va backend ulanmagan holatlarda overflow yoki
/// layout xatosi yo‘q; aralash til yo‘q (inglizcha kalit so‘zlar RU/UZ’da
/// ko‘rinmaydi).
void main() {
  const screens = [
    Routes.accountSignIn,
    Routes.accountRegister,
    Routes.accountVerify,
    Routes.accountForgot,
    Routes.accountReset,
    Routes.accountDelete,
    Routes.purchase,
    Routes.profile,
    Routes.aiDisclaimer,
  ];

  // Inglizcha UI so‘zlari — RU/UZ ekranida chiqmasligi kerak.
  const englishWords = [
    'Sign in',
    'Create account',
    'Password',
    'Restore purchases',
    'Subscription',
    'Delete account',
    'Monthly',
    'Yearly',
    'Verify',
  ];

  Future<void> scrollAll(WidgetTester tester) async {
    final s = find.byType(Scrollable).hitTestable();
    if (s.evaluate().isEmpty) return;
    for (var i = 0; i < 8; i++) {
      await tester.drag(s.first, const Offset(0, -400));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  }

  for (final lang in ['en', 'ru', 'uz']) {
    for (final theme in [ThemeMode.light, ThemeMode.dark]) {
      for (final signedIn in [false, true]) {
        group('$lang · ${theme.name} · signedIn=$signedIn · 320dp ×2.0', () {
          for (final route in screens) {
            testWidgets(route, (tester) async {
              final auth = MockAuthRepository();
              if (signedIn) {
                await auth.register(
                  email: 'audit@lab.uz',
                  password: 'TestPassw0rd!',
                  acceptedTermsVersion: 'v',
                );
                await auth.verifyEmail(
                  email: 'audit@lab.uz',
                  code: auth.outbox.last.code!,
                );
              }
              final c = await pumpApp(
                tester,
                size: const Size(320, 568),
                textScale: 2.0,
                settings: completedSettings(lang: lang, theme: theme),
                overrides: [
                  authRepositoryProvider.overrideWithValue(auth),
                  entitlementServiceProvider.overrideWithValue(
                    signedIn
                        ? FakeStore(
                            tier: PlanTier.professionalPro,
                            status: EntitlementStatus.gracePeriod,
                          )
                        : FakeStore(withOffers: false),
                  ),
                ],
              );
              c.read(routerProvider).go(route, extra: 'audit@lab.uz');
              await tester.pumpAndSettle();
              expect(tester.takeException(), isNull);
              // Xato holati: bo‘sh forma yuborish.
              final submit = find.byKey(const Key('auth.submit'));
              if (submit.evaluate().isNotEmpty) {
                await tester.ensureVisible(submit);
                await tester.pumpAndSettle();
                await tester.tap(submit, warnIfMissed: false);
                await tester.pumpAndSettle();
                expect(tester.takeException(), isNull);
              }
              await scrollAll(tester);
              if (lang != 'en') {
                for (final w in englishWords) {
                  expect(find.text(w), findsNothing, reason: '$route: $w');
                }
              }
            });
          }
        });
      }
    }
  }
}
