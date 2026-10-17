import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/routes.dart';

import '../helpers/fake_store.dart';
import '../helpers/pilot_content.dart';
import '../helpers/pump_app.dart';

void main() {
  late PilotContent pilot;
  setUpAll(() async => pilot = await loadPilotContent());

  Future<void> shot(
    WidgetTester tester,
    String route,
    String name, {
    double scroll = 0,
  }) async {
    await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz'),
      initialLocation: route,
      size: const Size(390, 1400),
      pixelRatio: 1.5,
      testFixtures: false,
      overrides: [
        ...pilot.overrides,
        entitlementServiceProvider.overrideWithValue(FakeStore(owned: true)),
      ],
    );
    await settleImages(tester);
    if (scroll > 0) {
      await tester.drag(find.byType(Scrollable).first, Offset(0, -scroll));
      await settleImages(tester);
    }
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/$name.png'),
    );
  }

  testWidgets('fenazepam — tahlil bo‘limi', (tester) async {
    await shot(
      tester,
      Routes.libraryEntry('phenazepam'),
      'chain_phenazepam',
      scroll: 700,
    );
  });

  testWidgets('TLC usul kartasi', (tester) async {
    await shot(
      tester,
      Routes.knowledgeEntry('method-tlc'),
      'chain_method_tlc',
      scroll: 900,
    );
  });
}
