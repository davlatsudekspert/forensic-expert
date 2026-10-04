import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/routes.dart';

import '../helpers/fake_store.dart';
import '../helpers/pilot_content.dart';
import '../helpers/pump_app.dart';

/// PHASE 12 yakuniy UI auditi: PHASE 7–11 da qo‘shilgan ekranlar haqiqiy
/// pilot paket bilan, 320 dp kichik ekranda, katta shriftda (×2.0) va uch
/// tilda overflow / layout xatosisiz chiziladi (pastgacha aylantirib).
void main() {
  late PilotContent pilot;
  setUpAll(() async => pilot = await loadPilotContent());

  final routes = <String>[
    Routes.discipline('forensic_genetics'),
    Routes.discipline('forensic_entomology'),
    Routes.knowledgeEntry('method-lcmsms'),
    Routes.knowledgeEntry('reagent-marquis'),
    Routes.knowledgeEntry('fm-algor-mortis'),
    Routes.libraryEntry('morphine'),
    Routes.jurisdiction('DE'),
    Routes.jurisdiction('UZ'),
    Routes.compare,
    Routes.conflicts,
    Routes.specimens,
    Routes.libraryStandards,
    Routes.reviewStatus,
    Routes.ai,
    Routes.profile,
  ];

  for (final lang in ['en', 'ru', 'uz']) {
    group('$lang · 320dp · ×2.0', () {
      for (final route in routes) {
        testWidgets(route, (tester) async {
          await pumpApp(
            tester,
            size: const Size(320, 568),
            textScale: 2.0,
            settings: completedSettings(lang: lang),
            initialLocation: route,
            testFixtures: false,
            overrides: [
              ...pilot.overrides,
              entitlementServiceProvider.overrideWithValue(
                FakeStore(owned: true),
              ),
            ],
          );
          expect(tester.takeException(), isNull);
          final scrollables = find.byType(Scrollable);
          if (scrollables.evaluate().isNotEmpty) {
            for (var i = 0; i < 6; i++) {
              await tester.drag(scrollables.first, const Offset(0, -500));
              await tester.pumpAndSettle();
              expect(tester.takeException(), isNull);
            }
          }
        });
      }
    });
  }
}
