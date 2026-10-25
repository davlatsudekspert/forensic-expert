import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/routes.dart';

import '../helpers/pilot_content.dart';
import '../helpers/pump_app.dart';

/// Egasi bergan manbalar (ustoz kitoblari) ekranda «tasdiqlangan
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
    overrides: [...pilot.overrides],
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
    // Ro‘yxat qatorida «Manba keltirilgan» emas, «Tasdiqlangan manba».
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
      find.descendant(of: chip, matching: find.text('Xalqaro adabiyot')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: chip, matching: find.text('Tasdiqlangan manba')),
      findsNothing,
    );
  });

  testWidgets('modda «Tahlil»ida kitob usullari: rangli, TLC, UB — to‘liq', (
    tester,
  ) async {
    await open(tester, Routes.libraryEntry('phenobarbital'));
    await scrollTo(tester, find.byKey(const Key('analysis.s2.phenobarbital')));
    for (final (id, text) in const [
      ('C-SM-PHENOBARBITAL-COLOUR_TEST-02', 'Kobalt tuzi, ammiak va metanol'),
      ('C-SM-PHENOBARBITAL-TLC_SYSTEM-01', 'xloroform–n-butanol'),
      ('C-SM-PHENOBARBITAL-UV_SPECTRUM-01', '239, 254 nm'),
    ]) {
      final card = find.byKey(Key('claim.$id'));
      await scrollTo(tester, card);
      expect(
        find.descendant(of: card, matching: find.textContaining(text)),
        findsWidgets,
        reason: id,
      );
    }
  });

  testWidgets('THC-COOH: maqoladan olingan qator — tasdiqlash kerak', (
    tester,
  ) async {
    await open(tester, Routes.libraryEntry('thc-cooh'));
    final liver = find.byKey(const Key('measured.thc-cooh.liver'));
    await scrollTo(tester, liver);
    expect(
      find.descendant(
        of: liver,
        matching: find.textContaining('Xalqaro adabiyot'),
      ),
      findsOneWidget,
    );
  });
}
