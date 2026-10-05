import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/routes.dart';

import '../helpers/fake_store.dart';
import '../helpers/pilot_content.dart';
import '../helpers/pump_app.dart';

/// Real qurilma o‘lchamlari: 320 / 360 / 390 / 430 dp, matn ×1.0 / ×1.3 /
/// ×2.0, EN / RU (dark) / UZ, haqiqiy pilot paket — overflow, kesilish va
/// layout xatosi yo‘q (pastgacha aylantirib).
void main() {
  late PilotContent pilot;
  setUpAll(() async => pilot = await loadPilotContent());

  const widths = [320.0, 360.0, 390.0, 430.0];
  const scales = [1.0, 1.3, 2.0];
  final screens = [
    Routes.home,
    Routes.librarySection('substances'),
    Routes.specimen('serum-plasma'),
    Routes.tools,
    Routes.tool('tool.lab.dilution'),
    Routes.ai,
    Routes.purchase,
    Routes.profile,
  ];

  for (final lang in ['en', 'ru', 'uz']) {
    final theme = lang == 'ru' ? ThemeMode.dark : ThemeMode.light;
    for (final w in widths) {
      for (final scale in scales) {
        group('$lang · ${theme.name} · ${w.toInt()}dp · ×$scale', () {
          for (final route in screens) {
            testWidgets(route, (tester) async {
              await pumpApp(
                tester,
                size: Size(w, w * 1.9),
                textScale: scale,
                settings: completedSettings(lang: lang, theme: theme),
                initialLocation: route,
                testFixtures: false,
                overrides: [
                  ...pilot.overrides,
                  entitlementServiceProvider.overrideWithValue(
                    FakeStore(withOffers: false),
                  ),
                ],
              );
              expect(tester.takeException(), isNull);
              final s = find.byType(Scrollable).hitTestable();
              for (var i = 0; i < 4 && s.evaluate().isNotEmpty; i++) {
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
