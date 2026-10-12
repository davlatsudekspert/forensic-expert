import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/routes.dart';

import '../helpers/fake_store.dart';
import '../helpers/pilot_content.dart';
import '../helpers/pump_app.dart';

/// Egasi bergan manbalar (ABY, ustoz kitoblari) ekranda «tasdiqlangan
/// manba» deb ko‘rinadi; xorijiy maqola/tezis — «tasdiqlash kerak».
/// «Bu ma’lumot qayerdan?» oynasida esa tahlilning o‘zi ko‘rinadi.
void main() {
  late PilotContent pilot;
  setUpAll(() async => pilot = await loadPilotContent());

  Future<void> open(WidgetTester tester, String route) => pumpApp(
    tester,
    settings: completedSettings(lang: 'uz'),
    initialLocation: route,
    testFixtures: false,
    overrides: [
      ...pilot.overrides,
      entitlementServiceProvider.overrideWithValue(FakeStore(owned: true)),
    ],
  );

  /// Uzun sahifada kartalar lazy quriladi: topilguncha pastga suramiz.
  Future<void> scrollTo(WidgetTester tester, Finder f) async {
    for (var i = 0; i < 80 && f.evaluate().isEmpty; i++) {
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -300));
      await tester.pump();
    }
    await tester.pumpAndSettle();
    expect(f, findsWidgets);
    await tester.ensureVisible(f.first);
    await tester.pumpAndSettle();
  }

  testWidgets('fenobarbital UB spektri: manba tasdiqlangan, tahlil ko‘rinadi', (
    tester,
  ) async {
    await open(tester, Routes.libraryEntry('phenobarbital'));
    const id = 'C-SM-PHENOBARBITAL-UV_SPECTRUM-01';
    // Tahlil ro‘yxatidagi «manbani ko‘rsat» tugmasi (skrinshotdagi yo‘l).
    final src = find.byKey(const Key('analysis.source.$id'));
    await scrollTo(tester, src);
    // Ro‘yxat qatorida «Tekshirilmagan» emas, «Tasdiqlangan manba».
    expect(find.textContaining('Tasdiqlangan manba'), findsWidgets);
    await tester.tap(src);
    await tester.pumpAndSettle();
    final sheet = find.byKey(const Key('provenance.sheet'));
    expect(sheet, findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('provenance.verification')),
        matching: find.textContaining('Tasdiqlangan manba'),
      ),
      findsOneWidget,
    );
    // Tahlilning o‘zi ko‘rinadi, «iqtibos ko‘rsatilmaydi» deb jim qolmaydi.
    expect(
      find.descendant(
        of: sheet,
        matching: find.byKey(const Key('provenance.statement')),
      ),
      findsOneWidget,
    );
    expect(find.textContaining('239, 254 nm'), findsWidgets);
    expect(find.textContaining('iqtibos ko‘rsatilmaydi'), findsNothing);
  });

  testWidgets('xorijiy maqola (morfin konsentratsiyasi): tasdiqlash kerak', (
    tester,
  ) async {
    await open(tester, Routes.libraryEntry('morphine'));
    const id = 'C-MORPHINE-REPORTED_CONCENTRATION-P5';
    final chip = find.byKey(const Key('claim.trust.$id'));
    await scrollTo(tester, chip);
    expect(
      find.descendant(of: chip, matching: find.text('Tasdiqlash kerak')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: chip, matching: find.text('Tasdiqlangan manba')),
      findsNothing,
    );
  });
}
