// REAL-ILOVA QA — SPEKTROFOTOMETRIYA (2026-10-09).
//
// Haqiqiy ilova (`bootstrap()`), haqiqiy yo‘riqnoma paketi, Linux desktop
// dvigateli. Akkaunt yo‘q, tarmoq — o‘chirilgan; Pro kirish faqat test
// override bilan (xarid simulyatsiyasi emas).
// Ishga tushirish:
//   QA_MODE=student      ./tool/qa_real_app.sh spectro
//   QA_MODE=professional QA_PRO=1 ./tool/qa_real_app.sh spectro
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/l10n/generated/app_localizations.dart';
import 'package:forensic_expert/domain/ports/billing_ports.dart';
import 'package:integration_test/integration_test.dart';

import 'qa/harness.dart';
import 'qa/qa_env.dart';

const _card = 'guideline.chem.uvvis_drug_analysis';
const _tool = 'tool.lab.beer_lambert';

/// Kalkulyator maydonlari kalitni bevosita `TextField` ga qo‘yadi.
Finder _field(String key) => find.byKey(Key(key));

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final env = Platform.environment;
  final mode = env['QA_MODE'] ?? 'student';
  final pro = env['QA_PRO'] == '1';

  testWidgets('QA real app — SPECTRO ($mode${pro ? ', Pro' : ''})', (
    tester,
  ) async {
    final net = NoNetworkOverrides();
    HttpOverrides.global = net;
    final l = lookupAppLocalizations(const Locale('uz'));
    final qa = await launchRealApp(
      tester,
      role: 'spectro',
      prefs: {
        'fe.settings.locale': 'uz',
        'fe.settings.theme': 'light',
        'fe.settings.mode': mode,
        'fe.settings.disclaimer_version': 1,
      },
      overrides: [
        if (pro)
          accessProvider.overrideWithValue(
            const Entitlements(
              tier: PlanTier.professionalPro,
              status: EntitlementStatus.active,
              source: EntitlementSource.promo,
              verification: EntitlementVerification.serverVerified,
            ),
          ),
      ],
    );

    Future<void> open(String route) async {
      // Xuddi shu manzilga `go` sahifa holatini saqlab qoladi — toza holat
      // uchun avval boshqa sahifaga o‘tiladi.
      goTo(tester, Routes.tools);
      await qa.settle();
      goTo(tester, route);
      await qa.settle();
      await qa.scrollToTop();
    }

    // Matn daraxtda bor, lekin ekrandan tashqarida bo‘lishi mumkin —
    // skrinshot uchun ko‘rinadigan joyga suriladi.
    Future<void> reveal(Finder f) async {
      await qa.scrollUntil(f);
      if (f.evaluate().isNotEmpty) {
        await Scrollable.ensureVisible(tester.element(f.first), alignment: 0.3);
        await qa.settle();
      }
    }

    Future<void> calc() async {
      await qa.tapFinder(find.byKey(const Key('calc.calculate')));
      final r = find.byKey(const Key('calc.result'));
      await qa.scrollUntil(r);
      if (r.evaluate().isNotEmpty) {
        await Scrollable.ensureVisible(
          tester.element(r.first),
          alignment: 0.25,
        );
        await qa.settle();
      }
    }

    // ------------------------------------------------------- yo‘riqnomalar
    await qa.step('[$mode] Yo‘riqnomalar: UB-spektrofotometriya kartasi', (
      s,
    ) async {
      await open(Routes.guidelines);
      await qa.scrollUntil(find.textContaining('UB-ko‘rinadigan'));
      qa.expectText('UB-ko‘rinadigan spektrofotometriya', s);
    });

    await qa.step('[$mode] Karta ochildi: sarlavha va ilmiy asos', (s) async {
      await open(Routes.guideline(_card));
      qa.expectText('Buger–Lambert–Ber', s);
    });

    await qa.step('[$mode] Karta: ehtiyot choralari (faqat UB spektri emas)', (
      s,
    ) async {
      await reveal(find.textContaining('faqat UB spektri'));
      qa.expectText('faqat UB spektri', s);
    });

    await qa.step('[$mode] Karta: bog‘liq vositalar va manbalar', (s) async {
      await reveal(find.text(l.toolBeerLambertName));
      qa.expectText(l.toolBeerLambertName, s);
      qa.expectText(l.toolLodName, s);
    });

    await qa.step('[$mode] Bog‘liq vosita → Ber–Lambert sahifasi', (s) async {
      await qa.tapText(l.toolBeerLambertName);
      await qa.settle();
      if (pro) {
        qa.expectText(l.calcBeerBasis, s);
      } else {
        // Talaba (Pro’siz): aniq tarif nomi bilan qulf kartasi.
        qa.expectText(l.calcLockedTitle, s);
      }
    });

    if (pro) {
      // c = A/(ε·l) = 0,45 / (15000 × 1) = 3·10⁻⁵ mol/L = 30 µmol/L.
      await qa.step('Ber–Lambert: c = 0,45/(15000·1) → 30 µmol/L', (s) async {
        await open(Routes.tool(_tool));
        await qa.enterText(_field('calc.absorbance'), '0,45');
        await qa.enterText(_field('calc.absorptivity'), '15000');
        await calc();
        qa.expectText(RegExp(r'^30 µmol/L$'), s);
      });

      // A = a·l·c = 25 × 1 × 0,020 g/L = 0,5 (massaviy asos, mg/L).
      await qa.step('Ber–Lambert: massaviy asos, A = 25·1·20 mg/L → 0,5', (
        s,
      ) async {
        await open(Routes.tool(_tool));
        await qa.tapFinder(find.byKey(const Key('calc.unknown.absorbance')));
        await qa.tapFinder(find.byKey(const Key('calc.basis.mass')));
        await qa.enterText(_field('calc.absorptivity'), '25');
        await qa.enterText(_field('calc.conc'), '20');
        await calc();
        qa.expectText(RegExp(r'^0,5$'), s);
      });

      await qa.step('Ber–Lambert: bo‘sh maydon — tushunarli xato', (s) async {
        await open(Routes.tool(_tool));
        await qa.tapFinder(find.byKey(const Key('calc.calculate')));
        qa.expectText(l.calcErrorRequired, s);
      }, shot: false);

      await qa.step('Ber–Lambert → Kalibrlash vositasi', (s) async {
        await qa.scrollUntil(
          find.byKey(const Key('calc.related.tool.lab.calibration')),
        );
        await qa.tapFinder(
          find.byKey(const Key('calc.related.tool.lab.calibration')),
        );
        await qa.settle();
        if (find.byKey(const Key('calc.points')).evaluate().isEmpty) {
          s.passed = false;
          s.notes.add('Kalibrlash sahifasi ochilmadi');
        }
      }, shot: false);

      await qa.setSize(const Size(320, 640));
      await qa.step('320 dp: Ber–Lambert natijasi', (s) async {
        await open(Routes.tool(_tool));
        await qa.enterText(_field('calc.absorbance'), '0,45');
        await qa.enterText(_field('calc.absorptivity'), '15000');
        await calc();
        qa.expectText(RegExp(r'^30 µmol/L$'), s);
      });
      await qa.setSize(const Size(390, 844));
    }

    await qa.step('Tarmoq o‘chiq', (s) async {
      s.notes.add('Bloklangan HTTP urinishlari: ${net.attempts}');
    }, shot: false);

    qa.restoreErrorHandler();
    qa.writeResults();
    printSummary(qa);
    HttpOverrides.global = null;
  });
}
