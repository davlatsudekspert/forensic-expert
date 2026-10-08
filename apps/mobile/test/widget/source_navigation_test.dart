import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/routes.dart';

import '../helpers/pilot_content.dart';
import '../helpers/pump_app.dart';

/// Ikki tomonlama provenance navigatsiyasi (HAQIQIY pilot paket):
/// yozuv → manba sahifasi → bog‘langan yozuv → Back.
void main() {
  late PilotContent pilot;
  setUpAll(() async => pilot = await loadPilotContent());

  testWidgets('morfin → manba → bog‘langan yozuvlar → Back', (tester) async {
    await pumpApp(
      tester,
      settings: completedSettings(),
      initialLocation: Routes.libraryEntry('morphine'),
      testFixtures: false,
      overrides: pilot.overrides,
    );
    await settleImages(tester);
    final tile = find.byKey(const Key('source.SRC-PMC8400298'));
    await tester.scrollUntilVisible(
      tile,
      400,
      scrollable: find.byType(Scrollable).hitTestable().first,
    );
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
    // Manba sahifasi: to‘liq bibliografiya + shu manbaga tayangan yozuvlar.
    expect(find.text('Source'), findsWidgets);
    expect(find.byKey(const Key('sourceLink.morphine')), findsOneWidget);
    expect(find.textContaining('Linked records'), findsOneWidget);
    // Back — yozuvga qaytadi (dead end yo‘q).
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('sourceLink.morphine')), findsNothing);
    expect(tile, findsOneWidget);
  });

  testWidgets('noma’lum manba — bo‘sh holat, uydirma yo‘q', (tester) async {
    await pumpApp(
      tester,
      settings: completedSettings(),
      initialLocation: Routes.source('SRC-DOES-NOT-EXIST'),
      testFixtures: false,
      overrides: pilot.overrides,
    );
    expect(
      find.text('Source not found in the offline database.'),
      findsOneWidget,
    );
  });
}
