import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/routes.dart';

import '../helpers/pilot_content.dart';
import '../helpers/pump_app.dart';

/// Mutaxassis rejimi (egasi, 2026-11-06): Asosiy tab pastki qismi
/// (Ish stoli → Usullar va apparatlar → Ma’lumotnomalar), Ekspertiza
/// yo‘nalishlari («tayyor» va «Tez orada») va Vositalar.
void main() {
  late PilotContent pilot;
  setUpAll(() async => pilot = await loadPilotContent());

  Future<void> shot(
    WidgetTester tester,
    String name,
    String location, {
    Key? scrollTo,
  }) async {
    await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz'),
      size: const Size(390, 844),
      initialLocation: location,
      testFixtures: false,
      overrides: [...pilot.overrides],
    );
    await settleImages(tester);
    if (scrollTo != null) {
      await tester.scrollUntilVisible(
        find.byKey(scrollTo),
        200,
        scrollable: find.byType(Scrollable).hitTestable().first,
      );
      await tester.pumpAndSettle();
    }
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/$name.png'),
    );
  }

  testWidgets('mx_home_top_uz', (t) => shot(t, 'mx_home_top_uz', Routes.home));
  testWidgets(
    'mx_home_refs_uz',
    (t) => shot(
      t,
      'mx_home_refs_uz',
      Routes.home,
      scrollTo: const Key('home.instruments'),
    ),
  );
  testWidgets('mx_areas_uz', (t) => shot(t, 'mx_areas_uz', Routes.areas));
  testWidgets('mx_tools_uz', (t) => shot(t, 'mx_tools_uz', Routes.tools));
}
