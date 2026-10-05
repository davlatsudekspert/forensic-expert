import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/routes.dart';

import '../helpers/fake_store.dart';
import '../helpers/pilot_content.dart';
import '../helpers/pump_app.dart';

/// Real-device polish skrinshotlari — HAQIQIY pilot paket bilan.
/// Nusxa: `docs/screenshots/polish/`.
void main() {
  late PilotContent pilot;
  setUpAll(() async => pilot = await loadPilotContent());

  const conc = Key('claim.context.C-BRODIFACOUM-REPORTED_CONCENTRATION-P5');
  final cases =
      <
        ({
          String name,
          String lang,
          ThemeMode theme,
          String route,
          Key? scrollTo,
          bool store,
        })
      >[
        (
          name: 'pol_01_home_uz',
          lang: 'uz',
          theme: ThemeMode.light,
          route: Routes.home,
          scrollTo: null,
          store: false,
        ),
        (
          name: 'pol_02_substances_uz',
          lang: 'uz',
          theme: ThemeMode.light,
          route: Routes.librarySection('substances'),
          scrollTo: null,
          store: false,
        ),
        (
          name: 'pol_03_specimen_conc_uz',
          lang: 'uz',
          theme: ThemeMode.light,
          route: Routes.specimen('serum-plasma'),
          scrollTo: conc,
          store: false,
        ),
        (
          name: 'pol_04_tools_uz',
          lang: 'uz',
          theme: ThemeMode.light,
          route: Routes.tools,
          scrollTo: null,
          store: false,
        ),
        (
          name: 'pol_05_sources_empty_uz',
          lang: 'uz',
          theme: ThemeMode.light,
          route: Routes.librarySection('references'),
          scrollTo: null,
          store: false,
        ),
        (
          name: 'pol_06_ai_uz',
          lang: 'uz',
          theme: ThemeMode.light,
          route: Routes.ai,
          scrollTo: null,
          store: false,
        ),
        (
          name: 'pol_07_paywall_uz',
          lang: 'uz',
          theme: ThemeMode.light,
          route: Routes.purchase,
          scrollTo: null,
          store: false,
        ),
        (
          name: 'pol_08_profile_uz',
          lang: 'uz',
          theme: ThemeMode.light,
          route: Routes.profile,
          scrollTo: const Key('profile.accountNotConnected'),
          store: false,
        ),
        (
          name: 'pol_09_home_en_dark',
          lang: 'en',
          theme: ThemeMode.dark,
          route: Routes.home,
          scrollTo: null,
          store: false,
        ),
        (
          name: 'pol_10_tool_status_en',
          lang: 'en',
          theme: ThemeMode.light,
          route: Routes.tool('tool.lab.dilution'),
          scrollTo: const Key('calc.statusPanel'),
          store: false,
        ),
        (
          name: 'pol_11_specimen_conc_ru_dark',
          lang: 'ru',
          theme: ThemeMode.dark,
          route: Routes.specimen('serum-plasma'),
          scrollTo: conc,
          store: false,
        ),
        (
          name: 'pol_12_ai_ru_dark',
          lang: 'ru',
          theme: ThemeMode.dark,
          route: Routes.ai,
          scrollTo: null,
          store: false,
        ),
        (
          name: 'pol_13_substances_en_dark',
          lang: 'en',
          theme: ThemeMode.dark,
          route: Routes.librarySection('substances'),
          scrollTo: null,
          store: false,
        ),
        (
          name: 'pol_14_paywall_ru',
          lang: 'ru',
          theme: ThemeMode.light,
          route: Routes.purchase,
          scrollTo: null,
          store: false,
        ),
      ];

  for (final c in cases) {
    testWidgets(c.name, (tester) async {
      await pumpApp(
        tester,
        settings: completedSettings(lang: c.lang, theme: c.theme),
        initialLocation: c.route,
        testFixtures: false,
        overrides: [
          ...pilot.overrides,
          entitlementServiceProvider.overrideWithValue(
            FakeStore(withOffers: c.store),
          ),
        ],
      );
      await settleImages(tester);
      final target = c.scrollTo;
      if (target != null) {
        await tester.scrollUntilVisible(
          find.byKey(target),
          300,
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
