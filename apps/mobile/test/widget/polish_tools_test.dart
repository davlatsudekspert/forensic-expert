import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/l10n/generated/app_localizations.dart';
import 'package:forensic_expert/features/tools/presentation/lab_calculators.dart';

import '../helpers/fake_store.dart';
import '../helpers/pump_app.dart';

/// 2026-10-09 «polish tools»: kalkulyator UI xatolari va qulayliklari.
void main() {
  Future<void> open(
    WidgetTester tester,
    String toolId, {
    String lang = 'uz',
    bool owned = true,
  }) => pumpApp(
    tester,
    settings: completedSettings(lang: lang),
    initialLocation: Routes.tool(toolId),
    overrides: [
      entitlementServiceProvider.overrideWithValue(FakeStore(owned: owned)),
    ],
  );

  Future<void> type(WidgetTester tester, Finder f, String v) async {
    await tester.ensureVisible(f);
    await tester.enterText(f, v);
    await tester.pump();
  }

  Finder field(String key) => find.descendant(
    of: find.byKey(Key(key)),
    matching: find.byType(TextField),
  );

  Future<void> calculate(WidgetTester tester) async {
    await tester.ensureVisible(find.byKey(const Key('calc.calculate')));
    await tester.tap(find.byKey(const Key('calc.calculate')));
    await tester.pumpAndSettle();
  }

  final uz = lookupAppLocalizations(const Locale('uz'));
  final en = lookupAppLocalizations(const Locale('en'));

  group('formatNumber', () {
    test('butun son «.0» siz, o‘nlik vergul, darajali yozuv', () {
      expect(formatNumber(1000), '1000');
      expect(formatNumber(5), '5');
      expect(formatNumber(0.5275, decimal: ','), '0,5275');
      expect(formatNumber(1.5e-7, decimal: ','), '1,5 × 10⁻⁷');
      expect(formatNumber(2.5e12), '2,5 × 10¹²'.replaceAll(',', '.'));
    });
  });

  group('Suyultirish', () {
    testWidgets('«5.0 mL» emas «5 mL»; vergulli kiritish', (tester) async {
      await open(tester, 'tool.lab.dilution');
      await type(tester, field('calc.field.c1'), '10');
      await type(tester, field('calc.field.c2'), '0,5');
      await type(tester, field('calc.field.v2'), '100');
      await calculate(tester);
      expect(find.text('5 mL'), findsOneWidget);
    });

    testWidgets('birlik yoki qiymat o‘zgarsa eski natija o‘chadi', (
      tester,
    ) async {
      await open(tester, 'tool.lab.dilution');
      await type(tester, field('calc.field.c1'), '10');
      await type(tester, field('calc.field.c2'), '1');
      await type(tester, field('calc.field.v2'), '100');
      await calculate(tester);
      expect(find.byKey(const Key('calc.result')), findsOneWidget);
      // Qiymat o‘zgardi → natija yo‘q (eski raqam yangi kiritishga
      // tegishli deb o‘qilmasin).
      await type(tester, field('calc.field.v2'), '50');
      expect(find.byKey(const Key('calc.result')), findsNothing);
      await calculate(tester);
      expect(find.text('5 mL'), findsOneWidget);
      // Topiladigan qiymat (yoki birlik) o‘zgardi.
      await tester.ensureVisible(find.byKey(const Key('calc.unknown.c2')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('calc.unknown.c2')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('calc.result')), findsNothing);
    });

    testWidgets('bo‘sh maydon — aniq xabar', (tester) async {
      await open(tester, 'tool.lab.dilution');
      await calculate(tester);
      expect(find.text(uz.calcErrorRequired), findsOneWidget);
    });
  });

  group('Widmark', () {
    testWidgets('uz: o‘nlik vergul, oraliq va nusxa (kiritilganlar bilan)', (
      tester,
    ) async {
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied = (call.arguments as Map)['text'] as String?;
          }
          return null;
        },
      );
      await open(tester, 'tool.tox.widmark');
      await type(tester, find.byKey(const Key('calc.weight')), '80');
      await type(tester, find.byKey(const Key('calc.drink.0.volume')), '500');
      await type(tester, find.byKey(const Key('calc.drink.0.abv')), '40');
      await type(tester, find.byKey(const Key('calc.hours')), '2');
      await calculate(tester);
      // A = 157,8 g; min = 157,8·0,7/56 − 0,4; max = 157,8·0,9/56 − 0,2.
      expect(find.text('1,57–2,34 ‰'), findsOneWidget);
      await tester.ensureVisible(find.byKey(const Key('calc.copy')));
      await tester.tap(find.byKey(const Key('calc.copy')));
      await tester.pumpAndSettle();
      expect(copied, contains(uz.toolWidmarkName));
      expect(copied, contains('500 mL × 40 %'));
      expect(copied, contains('1,57–2,34 ‰'));
      expect(copied, contains('tox.ethanol.widmark · v1.0.0'));
      expect(find.text(uz.calcCopied), findsOneWidget);
    });

    testWidgets('Pro’siz: «Mutaxassis Pro tarkibida» qulfi', (tester) async {
      await open(tester, 'tool.tox.widmark', owned: false, lang: 'en');
      expect(find.byKey(const Key('tool.lockedCard')), findsOneWidget);
      expect(find.text(en.calcLockedTitle), findsOneWidget);
      expect(find.byKey(const Key('calc.calculate')), findsNothing);
    });
  });

  group('Teskari hisob', () {
    testWidgets('‰: β g/L/soat qon zichligi bilan o‘tkaziladi', (tester) async {
      await open(tester, 'tool.tox.back_calculation');
      await type(tester, find.byKey(const Key('calc.bac')), '0,8');
      await type(tester, find.byKey(const Key('calc.hours')), '2');
      await calculate(tester);
      // 0,8 + 0,10·2/1,055 = 0,99; 0,8 + 0,25·2/1,055 = 1,27.
      expect(find.text('0,99–1,27 ‰'), findsOneWidget);
    });
  });

  group('Henssge (PMI)', () {
    testWidgets('Ta > 23 °C — qo‘llangan 1,11/0,11 tenglama ko‘rsatiladi', (
      tester,
    ) async {
      await open(tester, 'tool.fm.pmi_henssge', lang: 'en');
      expect(find.text(en.calcHenssgeFormulaLow), findsOneWidget);
      await type(tester, find.byKey(const Key('calc.rectal')), '30');
      await type(tester, find.byKey(const Key('calc.ambient')), '25');
      await type(tester, find.byKey(const Key('calc.weight')), '70');
      await calculate(tester);
      expect(find.text(en.calcHenssgeFormulaHigh), findsOneWidget);
      expect(find.textContaining('1.11·e^(Bt)'), findsOneWidget);
      expect(find.text('Estimated postmortem interval (PMI)'), findsOneWidget);
    });
  });

  group('Statistika va kalibrlash', () {
    testWidgets('«0,5 0,7 0,9» — n = 3, o‘rtacha 0,7', (tester) async {
      await open(tester, 'tool.lab.descriptive_stats');
      await type(tester, find.byKey(const Key('calc.values')), '0,5 0,7 0,9');
      await calculate(tester);
      expect(find.text('3'), findsWidgets);
      expect(find.text('0,7'), findsWidgets);
      expect(find.text('0,2'), findsOneWidget);
    });

    testWidgets('vergulli «x y» kalibrlash nuqtalari', (tester) async {
      await open(tester, 'tool.lab.calibration');
      await type(
        tester,
        find.byKey(const Key('calc.points')),
        '0 0,1\n1 2,0\n2 4,1\n3 5,9\n4 8,1',
      );
      await calculate(tester);
      expect(find.text(uz.calcErrorPoints), findsNothing);
      expect(find.text('1,99'), findsOneWidget);
    });
  });
}
