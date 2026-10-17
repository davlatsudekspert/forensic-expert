import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/aby_flag.dart';

import '../helpers/fake_store.dart';
import '../helpers/pilot_content.dart';
import '../helpers/pump_app.dart';

/// Egasi bergan manbalar (ABY, ustoz kitoblari) ekranda «tasdiqlangan
/// manba» deb ko‘rinadi; xorijiy maqola/tezis — «tasdiqlash kerak».
/// «Bu ma’lumot qayerdan?» oynasida esa tahlilning o‘zi ko‘rinadi.
void main() {
  // ABY yashirin bo‘lsa-da, ABY kontentining o‘zi shu testda tekshiriladi.
  setUpAll(() => abyContentEnabled = true);
  tearDownAll(() => abyContentEnabled = false);

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

  testWidgets('modda «Tahlil»ida ABY tartibi: ob’ekt va aniq joyi bilan', (
    tester,
  ) async {
    await open(tester, Routes.libraryEntry('phenobarbital'));
    final block = find.byKey(const Key('analysis.aby.phenobarbital'));
    await scrollTo(tester, block);
    expect(find.text('ABY bo‘yicha tartib va ob’ekt'), findsOneWidget);
    // Barbituratlar yozuvi: to‘liq usul matni va ob’ekt qatori.
    final card = find.byKey(const Key('claim.C-ABY-TOX-BAR-01'));
    await scrollTo(tester, card);
    expect(
      find.descendant(
        of: card,
        matching: find.textContaining('10 ml qon yoki siydik'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('claim.objects.C-ABY-TOX-BAR-01')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: card, matching: find.textContaining('ABY.G.6.2025')),
      findsOneWidget,
    );
  });

  testWidgets('ABY bloki rus tilida umuman ko‘rinmaydi', (tester) async {
    await pumpApp(
      tester,
      settings: completedSettings(lang: 'ru'),
      initialLocation: Routes.libraryEntry('phenobarbital'),
      testFixtures: false,
      overrides: [
        ...pilot.overrides,
        entitlementServiceProvider.overrideWithValue(FakeStore(owned: true)),
      ],
    );
    for (var i = 0; i < 40; i++) {
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -300));
      await tester.pump();
    }
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('analysis.aby.phenobarbital')), findsNothing);
    expect(find.byKey(const Key('claim.C-ABY-TOX-BAR-01')), findsNothing);
  });

  testWidgets('modda «Tahlil»ida kitob usullari: rangli, TLC, UB — to‘liq', (
    tester,
  ) async {
    await open(tester, Routes.libraryEntry('phenobarbital'));
    await scrollTo(
      tester,
      find.byKey(const Key('analysis.book.phenobarbital')),
    );
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

  testWidgets(
    'THC-COOH: ob’ektlar ABY bo‘yicha (qon, siydik…), maqola — tasdiqlash kerak',
    (tester) async {
      await open(tester, Routes.libraryEntry('thc-cooh'));
      final row = find.byKey(
        const Key('analysis.abySpecimen.thc-cooh.aby-tox-cannabinoids'),
      );
      await scrollTo(tester, row);
      expect(
        find.descendant(of: row, matching: find.textContaining('qon')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: row, matching: find.textContaining('siydik')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: row,
          matching: find.textContaining('Tasdiqlangan manba'),
        ),
        findsOneWidget,
      );
      // maqoladan olingan jigar/buyrak qatori «Tasdiqlash kerak» deb turadi.
      final liver = find.byKey(const Key('measured.thc-cooh.liver'));
      await scrollTo(tester, liver);
      expect(
        find.descendant(
          of: liver,
          matching: find.textContaining('Tasdiqlash kerak'),
        ),
        findsOneWidget,
      );
    },
  );
}
