import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/professional.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/settings/app_settings.dart';

import '../helpers/fake_store.dart';
import '../helpers/pilot_content.dart';
import '../helpers/professional_fixtures.dart';
import '../helpers/pump_app.dart';

/// Ro‘yxatdan o‘tish va taqriz ekranlari: 320 / 360 / 390 / 430 dp ×
/// matn 1.0 / 1.3 / 2.0 × EN / RU (dark) / UZ — overflow va layout xatosi
/// yo‘q (pastgacha aylantirib).
void main() {
  late PilotContent pilot;
  setUpAll(() async => pilot = await loadPilotContent());

  const widths = [320.0, 360.0, 390.0, 430.0];
  const scales = [1.0, 1.3, 2.0];
  final screens = [
    Routes.mode,
    Routes.welcomeAccount,
    Routes.profileEdit,
    Routes.verification,
    Routes.verificationDocuments,
    Routes.reviewDashboard,
    Routes.profile,
    Routes.libraryEntry('morphine'),
    Routes.module('toxicology'),
    Routes.knowledge('method'),
  ];

  for (final lang in ['en', 'ru', 'uz']) {
    final theme = lang == 'ru' ? ThemeMode.dark : ThemeMode.light;
    for (final w in widths) {
      for (final scale in scales) {
        group('$lang · ${theme.name} · ${w.toInt()}dp · ×$scale', () {
          for (final route in screens) {
            testWidgets(route, (tester) async {
              final onboarding = route == Routes.mode;
              await pumpApp(
                tester,
                size: Size(w, w * 1.9),
                textScale: scale,
                settings: onboarding
                    ? AppSettings(
                        locale: Locale(lang),
                        themeMode: theme,
                        acceptedDisclaimerVersion: currentDisclaimerVersion,
                      )
                    : completedSettings(lang: lang, theme: theme),
                initialLocation: onboarding ? null : route,
                testFixtures: false,
                overrides: [
                  ...pilot.overrides,
                  entitlementServiceProvider.overrideWithValue(
                    FakeStore(withOffers: false),
                  ),
                  // Ish joyi to‘liq ko‘rinishi uchun FIXTURE taqrizchi.
                  if (route == Routes.reviewDashboard)
                    professionalIdentityProvider.overrideWithValue(
                      fixtureToxReviewer,
                    ),
                ],
              );
              if (onboarding) {
                await tester.tap(find.byKey(const Key('mode.professional')));
                await tester.pumpAndSettle();
              }
              expect(tester.takeException(), isNull);
              final s = find.byType(Scrollable).hitTestable();
              for (var i = 0; i < 6 && s.evaluate().isNotEmpty; i++) {
                await tester.drag(s.first, const Offset(0, -600));
                await tester.pumpAndSettle();
                expect(tester.takeException(), isNull);
              }
            });
          }
        });
      }
    }
  }
}
