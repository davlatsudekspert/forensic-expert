import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/routes.dart';

import '../helpers/fake_store.dart';
import '../helpers/pilot_content.dart';
import '../helpers/pump_app.dart';

/// «Scientific Luxury» dizayn tizimi — Home ierarxiyasining pastki
/// qismlari (fan kartalari, kutubxona/vositalar) turli mavzu, til,
/// 320 dp va katta shriftda.
void main() {
  late PilotContent pilot;
  setUpAll(() async => pilot = await loadPilotContent());

  final cases = <(String, String, ThemeMode, Size, double, Key)>[
    (
      'lux_01_home_areas_uz_dark',
      'uz',
      ThemeMode.dark,
      const Size(390, 844),
      1,
      const Key('home.module.biochemistry'),
    ),
    (
      'lux_02_home_resources_en_light',
      'en',
      ThemeMode.light,
      const Size(390, 844),
      1,
      const Key('home.tools'),
    ),
    (
      'lux_03_home_areas_ru_320_x2',
      'ru',
      ThemeMode.light,
      const Size(320, 640),
      2,
      const Key('home.module.toxicology'),
    ),
    (
      'lux_04_home_resources_ru_dark_320_x2',
      'ru',
      ThemeMode.dark,
      const Size(320, 640),
      2,
      const Key('home.library'),
    ),
  ];

  for (final (name, lang, theme, size, scale, target) in cases) {
    testWidgets(name, (tester) async {
      await pumpApp(
        tester,
        settings: completedSettings(lang: lang, theme: theme),
        size: size,
        textScale: scale,
        initialLocation: Routes.home,
        testFixtures: false,
        overrides: [
          ...pilot.overrides,
          entitlementServiceProvider.overrideWithValue(
            FakeStore(withOffers: false),
          ),
        ],
      );
      await settleImages(tester);
      await tester.scrollUntilVisible(
        find.byKey(target),
        200,
        scrollable: find.byType(Scrollable).hitTestable().first,
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/$name.png'),
      );
    });
  }
}
