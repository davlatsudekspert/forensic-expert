import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/l10n/generated/app_localizations.dart';

import '../helpers/fake_store.dart';
import '../helpers/pump_app.dart';

/// 2026-10-09 spektrofotometriya: Buger–Lambert–Ber kalkulyatori (UI).
void main() {
  const id = 'tool.lab.beer_lambert';

  Future<void> open(
    WidgetTester tester, {
    String lang = 'uz',
    bool owned = true,
    Size size = const Size(390, 844),
  }) => pumpApp(
    tester,
    settings: completedSettings(lang: lang),
    initialLocation: Routes.tool(id),
    size: size,
    overrides: [
      entitlementServiceProvider.overrideWithValue(FakeStore(owned: owned)),
    ],
  );

  Future<void> type(WidgetTester tester, String key, String v) async {
    final f = find.descendant(
      of: find.byKey(Key(key)),
      matching: find.byType(TextField),
    );
    final target = f.evaluate().isEmpty ? find.byKey(Key(key)) : f;
    await tester.ensureVisible(target);
    await tester.enterText(target, v);
    await tester.pump();
  }

  Future<void> tap(WidgetTester tester, String key) async {
    await tester.scrollUntilVisible(
      find.byKey(Key(key)),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key(key)));
    await tester.pumpAndSettle();
  }

  final uz = lookupAppLocalizations(const Locale('uz'));
  final en = lookupAppLocalizations(const Locale('en'));

  testWidgets('c = A / (ε·l): 0,45 / (15000 × 1) = 30 µmol/L (uz)', (
    tester,
  ) async {
    await open(tester);
    expect(find.text(uz.toolBeerLambertName), findsWidgets);
    await type(tester, 'calc.absorbance', '0,45');
    await type(tester, 'calc.absorptivity', '15000');
    await tap(tester, 'calc.calculate');
    expect(find.byKey(const Key('calc.result.primary')), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const Key('calc.result.primary'))).data,
      '30 µmol/L',
    );
    // Ta’rifiy hisob: manba va cheklovlar ko‘rinadi.
    await tester.dragUntilVisible(
      find.text(uz.calcBeerLimitationIdentity),
      find.byType(Scrollable).first,
      const Offset(0, -300),
    );
    expect(find.textContaining('goldbook.B00626'), findsOneWidget);
  });

  testWidgets('A = a·l·c, massaviy asos: 25 × 1 × 20 mg/L = 0.5 (en)', (
    tester,
  ) async {
    await open(tester, lang: 'en');
    await tap(tester, 'calc.unknown.absorbance');
    await tap(tester, 'calc.basis.mass');
    await type(tester, 'calc.absorptivity', '25');
    await type(tester, 'calc.conc', '20');
    await tap(tester, 'calc.calculate');
    expect(
      tester.widget<Text>(find.byKey(const Key('calc.result.primary'))).data,
      '0.5',
    );
    expect(find.text('${en.calcBeerAbsorbance} (A)'), findsWidgets);
  });

  testWidgets('bo‘sh maydon — tushunarli xato; o‘zgarishda natija o‘chadi', (
    tester,
  ) async {
    await open(tester);
    await tap(tester, 'calc.calculate');
    expect(find.byKey(const Key('calc.error')), findsOneWidget);
    expect(find.textContaining(uz.calcErrorRequired), findsWidgets);
    await type(tester, 'calc.absorbance', '0,3');
    await type(tester, 'calc.absorptivity', '15000');
    await tap(tester, 'calc.calculate');
    expect(find.byKey(const Key('calc.result.primary')), findsOneWidget);
    await type(tester, 'calc.absorbance', '0,6');
    expect(find.byKey(const Key('calc.result.primary')), findsNothing);
    await type(tester, 'calc.absorbance', '-1');
    await tap(tester, 'calc.calculate');
    expect(find.text(uz.calcErrorPositive), findsOneWidget);
  });

  testWidgets('kalibrlash vositasiga havola ishlaydi', (tester) async {
    await open(tester);
    await tester.dragUntilVisible(
      find.byKey(const Key('calc.related.tool.lab.calibration')),
      find.byType(Scrollable).first,
      const Offset(0, -300),
    );
    await tap(tester, 'calc.related.tool.lab.calibration');
    // Kalibrlash sahifasi ochildi: nuqtalar maydoni bor.
    expect(find.byKey(const Key('calc.points')), findsOneWidget);
    expect(find.text(uz.toolCalibrationName), findsWidgets);
  });

  testWidgets('Pro bo‘lmasa — qulf kartasi', (tester) async {
    await open(tester, owned: false);
    expect(find.byKey(const Key('tool.lockedCard')), findsOneWidget);
  });

  testWidgets('320 dp ekranda toshib ketish yo‘q', (tester) async {
    await open(tester, size: const Size(320, 640));
    await type(tester, 'calc.absorbance', '0,45');
    await type(tester, 'calc.absorptivity', '15000');
    await tap(tester, 'calc.calculate');
    expect(tester.takeException(), isNull);
  });
}
