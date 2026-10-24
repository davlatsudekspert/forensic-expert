import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/l10n/generated/app_localizations.dart';
import 'package:forensic_expert/domain/plan/plan_models.dart';

import '../helpers/pump_app.dart';

/// Ekranlar katalogi ko‘rigi (2026-10-17): «to‘g‘ri kiritish» holatlarida
/// natija o‘rniga xato chiqqan edi. Sabab — katalog skripti har maydonga «2»
/// yozgan (2 kg vazn, Tr = Ta = 2 °C, tozalik 2, bitta kalibrlash nuqtasi):
/// bu kiritishlar haqiqatan noto‘g‘ri, kalkulyatorlar to‘g‘ri rad etgan.
/// Bu test har kalkulyatorni haqiqiy (o‘nlik vergulli) kiritish bilan, qo‘lda
/// hisoblangan ma’lum javobga solishtiradi. Qiymatlar katalogdagi
/// `calcSamples` bilan bir xil.
void main() {
  setUpAll(() => testDefaultPlan = Plan.expert);
  tearDownAll(() => testDefaultPlan = null);
  final uz = lookupAppLocalizations(const Locale('uz'));

  Future<void> open(WidgetTester tester, String toolId) async {
    await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz'),
      initialLocation: Routes.tool(toolId),
    );
  }

  Finder input(String key) {
    final inside = find.descendant(
      of: find.byKey(Key(key)),
      matching: find.byType(EditableText),
    );
    return inside.evaluate().isEmpty ? find.byKey(Key(key)) : inside.first;
  }

  Future<void> type(WidgetTester tester, String key, String v) async {
    await tester.ensureVisible(input(key));
    await tester.enterText(input(key), v);
    await tester.pump();
  }

  Future<void> tap(WidgetTester tester, String key) async {
    // Markazga: pastki suzuvchi navigatsiya tugmani yopib qo‘ymasin.
    await Scrollable.ensureVisible(
      tester.element(find.byKey(Key(key))),
      alignment: 0.5,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key(key)));
    await tester.pumpAndSettle();
  }

  Future<void> calculate(WidgetTester tester) => tap(tester, 'calc.calculate');

  void noError() => expect(find.byKey(const Key('calc.error')), findsNothing);

  String primary(WidgetTester tester) =>
      tester.widget<Text>(find.byKey(const Key('calc.result.primary'))).data!;

  testWidgets('Henssge: Tr 30, Ta 15 °C, 70 kg, c = 1 → ~9,7 soat', (
    tester,
  ) async {
    await open(tester, 'tool.fm.pmi_henssge');
    await type(tester, 'calc.rectal', '30');
    await type(tester, 'calc.ambient', '15');
    await type(tester, 'calc.weight', '70');
    await calculate(tester);
    noError();
    // Q = 15/22,2 = 0,676; B = −1,2815·70^−0,625 + 0,0284 = −0,0617;
    // 1,25·e^(Bt) − 0,25·e^(5Bt) = Q → t ≈ 9,7 soat (qo‘lda yechilgan).
    expect(primary(tester), uz.calcHoursValue('9,7'));
    expect(find.text('0,676'), findsOneWidget); // Q
  });

  testWidgets('Henssge: o‘nlik vergul «36,5» qabul qilinadi', (tester) async {
    await open(tester, 'tool.fm.pmi_henssge');
    await type(tester, 'calc.rectal', '36,5');
    await type(tester, 'calc.ambient', '18,5');
    await type(tester, 'calc.weight', '82,5');
    await calculate(tester);
    noError();
    expect(find.byKey(const Key('calc.result.primary')), findsOneWidget);
  });

  testWidgets('Widmark: erkak 70 kg, 100 mL 40 %, 1 soat → 0,25–0,48 ‰', (
    tester,
  ) async {
    await open(tester, 'tool.tox.widmark');
    await type(tester, 'calc.weight', '70');
    await type(tester, 'calc.drink.0.volume', '100');
    await type(tester, 'calc.drink.0.abv', '40');
    await type(tester, 'calc.hours', '1');
    await calculate(tester);
    noError();
    // A = 100·0,40·0,789 = 31,56 g; m·r = 70·0,7 = 49.
    // min = 31,56·0,7/49 − 0,20·1 = 0,25; max = 31,56·0,9/49 − 0,10·1 = 0,48;
    // cho‘qqi = 31,56/49 = 0,64 ‰.
    expect(primary(tester), '0,25–0,48 ‰');
    expect(find.text('0,64 ‰'), findsOneWidget);
    expect(find.text('31,6 g'), findsOneWidget);
  });

  testWidgets('Teskari hisob: 0,5 ‰, 2 soat → 0,69–0,97 ‰', (tester) async {
    await open(tester, 'tool.tox.back_calculation');
    await type(tester, 'calc.bac', '0,5');
    await type(tester, 'calc.hours', '2');
    await calculate(tester);
    noError();
    // 0,5 + 2·0,10/1,055 = 0,69; 0,5 + 2·0,25/1,055 = 0,97.
    expect(primary(tester), '0,69–0,97 ‰');
  });

  testWidgets('Suyultirish: 10 mg/mL → 1 mg/mL, 100 mL → V₁ = 10 mL', (
    tester,
  ) async {
    await open(tester, 'tool.lab.dilution');
    await type(tester, 'calc.field.c1', '10');
    await type(tester, 'calc.field.c2', '1');
    await type(tester, 'calc.field.v2', '100');
    await calculate(tester);
    noError();
    expect(find.text('10 mL'), findsOneWidget);
  });

  testWidgets('Eritma: 10 g/L × 100 mL, tozalik 1 → 1 g', (tester) async {
    await open(tester, 'tool.lab.solution');
    await type(tester, 'calc.solution.conc', '10');
    await type(tester, 'calc.solution.vol', '100');
    await calculate(tester);
    noError();
    expect(
      tester.widget<Text>(find.byKey(const Key('calc.result'))).data,
      '1 g',
    );
  });

  testWidgets('Foizli eritma: 5 % (m/V) × 200 mL → 10 g', (tester) async {
    await open(tester, 'tool.lab.percent');
    await type(tester, 'calc.percent', '5');
    await type(tester, 'calc.total', '200');
    await calculate(tester);
    noError();
    expect(primary(tester), '10 g');
  });

  testWidgets('Molyarlik: 584,4 mg NaCl, M 58,44, 100 mL, tozalik 1 → 0,1 M', (
    tester,
  ) async {
    await open(tester, 'tool.lab.molarity');
    // Tozalik maydoni standart «1» — 1 qabul qilinadi (0 < p ≤ 1).
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('calc.purity')))
          .controller!
          .text,
      '1',
    );
    await type(tester, 'calc.mass', '584,4');
    await type(tester, 'calc.mm', '58,44');
    await type(tester, 'calc.volume', '100');
    await calculate(tester);
    noError();
    // 0,5844 g / (58,44 g/mol · 0,1 L) = 0,1 mol/L.
    expect(primary(tester), '0,1 mol/L');
    expect(find.text('100 mmol/L'), findsOneWidget);
    expect(find.text('5,844 g/L'), findsOneWidget);
  });

  testWidgets('Molyarlik: tozalik ulush (0,98) — ha; foiz (98) — tushunarli '
      'xato', (tester) async {
    await open(tester, 'tool.lab.molarity');
    await type(tester, 'calc.mass', '584,4');
    await type(tester, 'calc.mm', '58,44');
    await type(tester, 'calc.volume', '100');
    await type(tester, 'calc.purity', '0,98');
    await calculate(tester);
    noError();
    expect(primary(tester), '0,098 mol/L');
    await type(tester, 'calc.purity', '98');
    await calculate(tester);
    expect(find.text(uz.calcErrorPurity), findsOneWidget);
  });

  testWidgets('Kalibrlash: 5 nuqta → qiyalik 0,19699…, R² > 0,999', (
    tester,
  ) async {
    await open(tester, 'tool.lab.calibration');
    await type(
      tester,
      'calc.points',
      '0 0,02\n1 0,21\n2 0,39\n5 1,01\n10 1,98',
    );
    await calculate(tester);
    noError();
    // x̄ = 3,6; ȳ = 0,722; Sxx = 65,2; Sxy = 12,844 → b = 0,196994.
    expect(find.text('0,196994'), findsOneWidget);
    expect(find.text('5'), findsWidgets); // n
  });

  testWidgets('LOD/LOQ: σ 0,1, S 2 → 0,165 va 0,5', (tester) async {
    await open(tester, 'tool.lab.lod_loq');
    await type(tester, 'calc.sigma', '0,1');
    await type(tester, 'calc.slope', '2');
    await calculate(tester);
    noError();
    // DL = 3,3·0,1/2; QL = 10·0,1/2 (ICH Q2(R2)).
    expect(find.text('0,165'), findsOneWidget);
    expect(find.text('0,5'), findsOneWidget);
  });

  testWidgets('LOD/LOQ: regressiyadan σ va S, so‘ng hisob', (tester) async {
    await open(tester, 'tool.lab.lod_loq');
    await type(
      tester,
      'calc.points',
      '0 0,02\n1 0,21\n2 0,39\n5 1,01\n10 1,98',
    );
    await tap(tester, 'calc.regress');
    await calculate(tester);
    noError();
    expect(find.byKey(const Key('calc.result')), findsOneWidget);
  });

  testWidgets('Tavsifiy statistika: 5 qiymat → o‘rtacha 0,514, SD 0,0230217', (
    tester,
  ) async {
    await open(tester, 'tool.lab.descriptive_stats');
    await type(tester, 'calc.values', '0,52 0,49 0,55 0,51 0,50');
    await calculate(tester);
    noError();
    // Σ(x − x̄)² = 0,00212; s = √(0,00212/4) = 0,0230217.
    expect(find.text('0,514'), findsOneWidget);
    expect(find.text('0,51'), findsOneWidget); // mediana
    expect(find.text('0,0230217'), findsOneWidget);
    expect(find.text(uz.calcStatsWarnSd), findsNothing);
  });

  testWidgets('Birlik: 1,5 mg/L = 1500 ng/mL', (tester) async {
    await open(tester, 'tool.conv.concentration_units');
    await type(tester, 'calc.value', '1,5');
    await calculate(tester);
    noError();
    expect(find.text('1500 ng/mL'), findsOneWidget);
  });

  testWidgets('Etanol birliklari: 0,8 ‰ = 0,844 g/L', (tester) async {
    await open(tester, 'tool.conv.ethanol_units');
    await type(tester, 'calc.value', '0,8');
    await calculate(tester);
    noError();
    // g/L = ‰ · 1,055; mmol/L = 0,844 / 46,07 · 1000 = 18,3199.
    expect(find.text('0,844'), findsOneWidget);
    expect(find.text('18,3199'), findsOneWidget);
  });

  testWidgets('Beer–Lambert: 0,45 / (15000 × 1) = 30 µmol/L', (tester) async {
    await open(tester, 'tool.lab.beer_lambert');
    await type(tester, 'calc.absorbance', '0,45');
    await type(tester, 'calc.absorptivity', '15000');
    await type(tester, 'calc.path', '1');
    await calculate(tester);
    noError();
    expect(primary(tester), '30 µmol/L');
  });

  testWidgets('yorliqlar maydon ustida va to‘liq (320 dp, qisqartirilmaydi)', (
    tester,
  ) async {
    await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz'),
      initialLocation: Routes.tool('tool.lab.dilution'),
      size: const Size(320, 640),
    );
    // Avval suzuvchi yorliq «Boshlang‘ich konse…» bo‘lib kesilardi.
    final label = find.text(uz.calcStockConc);
    expect(label, findsOneWidget);
    final text = tester.widget<Text>(label);
    expect(text.overflow, isNot(TextOverflow.ellipsis));
    expect(text.maxLines, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('modul ID/versiyasi «Texnik ma’lumot» ichida yig‘ilgan', (
    tester,
  ) async {
    await open(tester, 'tool.tox.widmark');
    expect(find.textContaining('tox.ethanol.widmark'), findsNothing);
    await tap(tester, 'calc.techInfo');
    expect(
      find.text(uz.calcTechModule('tox.ethanol.widmark', '1.0.0')),
      findsOneWidget,
    );
  });
}
