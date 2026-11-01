import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/routes.dart';

import '../helpers/pilot_content.dart';
import '../helpers/pump_app.dart';

/// Murda dog‘lari, qotishi va sovishi sxemalari (G‘iyosov 2018) — HAQIQIY
/// pilot paket bilan, sxema kartasi ko‘rinadigan joyda.
void main() {
  late PilotContent content;
  setUpAll(() async => content = await loadPilotContent());

  for (final (id, key) in const [
    ('fm-livor-mortis', 'livor'),
    ('fm-rigor-mortis', 'rigor'),
    ('fm-algor-mortis', 'algor'),
  ]) {
    for (final lang in const ['uz', 'ru']) {
      testWidgets('pmd_${key}_$lang', (tester) async {
        await pumpApp(
          tester,
          settings: completedSettings(lang: lang),
          size: const Size(390, 900),
          pixelRatio: 1.5,
          testFixtures: false,
          initialLocation: Routes.knowledgeEntry(id),
          overrides: content.overrides,
        );
        await tester.pumpAndSettle();
        final card = find.byKey(Key('pmd.$key'));
        await tester.scrollUntilVisible(
          card,
          300,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        expect(find.byKey(Key('pmd.$key.source')), findsOneWidget);
        await expectLater(
          card,
          matchesGoldenFile('goldens/pmd_${key}_$lang.png'),
        );
      });
    }
  }
}
