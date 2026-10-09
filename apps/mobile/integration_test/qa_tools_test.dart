// REAL-ILOVA QA — PROFESSIONAL VOSITALAR va O‘QUV REJIMI.
//
// Haqiqiy ilova (`bootstrap()`), haqiqiy pilot kontent paketi, Linux desktop
// dvigateli. Akkaunt yo‘q, tarmoq — o‘chirilgan; Pro kirish faqat test
// override bilan (xarid simulyatsiyasi emas — `accessProvider`).
// Ishga tushirish: `./tool/qa_real_app.sh tools`.
//
// Har kalkulyator real qiymatlar bilan, natija qo‘lda hisob bilan
// solishtiriladi (izohlarda).
import 'dart:io';

import 'package:fe_calc_engine/fe_calc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/app/study.dart';
import 'package:forensic_expert/core/l10n/generated/app_localizations.dart';
import 'package:forensic_expert/core/settings/settings_controller.dart';
import 'package:forensic_expert/domain/ports/billing_ports.dart';
import 'package:integration_test/integration_test.dart';

import 'qa/harness.dart';
import 'qa/qa_env.dart';

Finder _field(String key) =>
    find.descendant(of: find.byKey(Key(key)), matching: find.byType(TextField));

Finder _keyPrefix(String prefix) => find.byWidgetPredicate(
  (w) =>
      w.key is ValueKey<String> &&
      (w.key! as ValueKey<String>).value.startsWith(prefix),
);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('QA real app — TOOLS & LEARN', (tester) async {
    final net = NoNetworkOverrides();
    HttpOverrides.global = net;
    var l = lookupAppLocalizations(const Locale('uz'));
    String? clipboard;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          clipboard = (call.arguments as Map)['text'] as String?;
        }
        return null;
      },
    );
    const pro = Entitlements(
      tier: PlanTier.professionalPro,
      status: EntitlementStatus.active,
      source: EntitlementSource.promo,
      verification: EntitlementVerification.serverVerified,
    );
    final qa = await launchRealApp(
      tester,
      role: 'tools',
      prefs: {
        'fe.settings.locale': 'uz',
        'fe.settings.theme': 'light',
        'fe.settings.mode': 'professional',
        'fe.settings.disclaimer_version': 1,
      },
      overrides: [accessProvider.overrideWithValue(pro)],
    );

    Future<void> open(String toolId) async {
      goTo(tester, Routes.tool(toolId));
      await qa.settle();
      await qa.scrollToTop();
    }

    Future<void> calc() async {
      await qa.tapFinder(find.byKey(const Key('calc.calculate')));
      await qa.scrollUntil(find.byKey(const Key('calc.result')));
      final r = find.byKey(const Key('calc.result'));
      if (r.evaluate().isNotEmpty) {
        // Natija kartasi ekranning yuqori qismida (sarlavhasi bilan).
        await Scrollable.ensureVisible(
          tester.element(r.first),
          alignment: 0.25,
        );
        await qa.settle();
      }
    }

    // ------------------------------------------------------------- vositalar
    await qa.step('Vositalar ro‘yxati (Pro)', (s) async {
      goTo(tester, Routes.tools);
      await qa.settle();
      qa.expectText(l.toolDilutionName, s);
    });

    // C₁ = 10 mg/mL, C₂ = 0,5 mg/mL, V₂ = 100 mL → V₁ = 0,5·100/10 = 5 mL.
    await qa.step('Suyultirish: o‘nlik vergul «0,5» → V₁ = 5 mL', (s) async {
      await open('tool.lab.dilution');
      await qa.enterText(_field('calc.field.c1'), '10');
      await qa.enterText(_field('calc.field.c2'), '0,5');
      await qa.enterText(_field('calc.field.v2'), '100');
      await calc();
      qa.expectText(RegExp(r'^5 mL$'), s);
    });

    // Birlik o‘zgardi (V₂: mL → L) — eski natija qolmasligi kerak.
    await qa.step('Suyultirish: birlik almashtirildi → eski natija yo‘q', (
      s,
    ) async {
      await qa.scrollToTop();
      final dd = find.descendant(
        of: find.byKey(const Key('calc.field.v2')),
        matching: find.byType(DropdownButtonFormField<Unit>),
      );
      await qa.tapFinder(dd);
      await tester.tap(find.text('L').last, warnIfMissed: false);
      await qa.settle();
      qa.expectNoText(RegExp(r'^5 mL$'), s, why: 'eskirgan natija');
      await calc();
      // 0,5·100 L/10 = 5 L.
      qa.expectText(RegExp(r'^5 L$'), s);
    });

    await qa.step('Suyultirish: natijani nusxalash', (s) async {
      final copy = find.byKey(const Key('calc.copy'));
      await qa.tapFinder(copy);
      if (clipboard == null || !clipboard!.contains('5 L')) {
        s.passed = false;
        s.notes.add('Bufer: $clipboard');
      }
    });

    await qa.step('Suyultirish: manfiy qiymat → xato', (s) async {
      await qa.scrollToTop();
      await qa.enterText(_field('calc.field.c1'), '-10');
      await qa.tapFinder(find.byKey(const Key('calc.calculate')));
      qa.expectText(l.calcErrorPositive, s);
    });

    // 0,25 mg/L = 250 ng/mL.
    await qa.step('Konvertor: 0,25 mg/L → 250 ng/mL', (s) async {
      await open('tool.conv.concentration_units');
      await qa.enterText(find.byKey(const Key('calc.value')), '0,25');
      await calc();
      qa.expectText(RegExp(r'^250 ng/mL$'), s);
    });

    // 584,4 mg / (58,44 g/mol · 0,1 L) = 0,1 mol/L.
    await qa.step('Molyarlik: NaCl 584,4 mg, 100 mL → 0,1 mol/L', (s) async {
      await open('tool.lab.molarity');
      await qa.enterText(find.byKey(const Key('calc.mass')), '584,4');
      await qa.enterText(find.byKey(const Key('calc.mm')), '58,44');
      await qa.enterText(find.byKey(const Key('calc.volume')), '100');
      await calc();
      qa.expectText(RegExp(r'^0[,.]1 mol/L$'), s);
    });

    // 0,9 % (w/v) · 500 mL / 100 = 4,5 g.
    await qa.step('Foizli eritma: 0,9 % w/v, 500 mL → 4,5 g', (s) async {
      await open('tool.lab.percent');
      await qa.enterText(find.byKey(const Key('calc.percent')), '0,9');
      await qa.enterText(find.byKey(const Key('calc.total')), '500');
      await calc();
      qa.expectText(RegExp(r'^4[,.]5 g$'), s);
    });

    // «0,5 0,7 0,9» — uchta qiymat: o‘rtacha 0,7; SD 0,2; CV 28,57 %.
    await qa.step('Statistika: «0,5 0,7 0,9» → n = 3, o‘rtacha 0,7', (s) async {
      await open('tool.lab.descriptive_stats');
      await qa.enterText(find.byKey(const Key('calc.values')), '0,5 0,7 0,9');
      await calc();
      qa.expectText(RegExp(r'^0[,.]7$'), s);
      qa.expectText(RegExp(r'^0[,.]2$'), s, why: 'SD');
    });

    await qa.step('Statistika: matn kiritildi → xato', (s) async {
      await qa.scrollToTop();
      await qa.enterText(find.byKey(const Key('calc.values')), '1 2 abc');
      await qa.tapFinder(find.byKey(const Key('calc.calculate')));
      qa.expectText(l.calcErrorValues, s);
    }, shot: false);

    await qa.step('Kalibrlash: o‘nlik vergulli «x y» juftliklari', (s) async {
      await open('tool.lab.calibration');
      await qa.enterText(
        find.byKey(const Key('calc.points')),
        '0 0,1\n1 2,0\n2 4,1\n3 5,9\n4 8,1',
      );
      await calc();
      // b = 1,99; a = 0,08 (qo‘lda: Σxy = 50,2 …).
      qa.expectText(RegExp(r'^1[,.]99$'), s);
    });

    await qa.step('LOD/LOQ: regressiyadan σ va S → DL, QL', (s) async {
      await open('tool.lab.lod_loq');
      await qa.enterText(
        find.byKey(const Key('calc.points')),
        '0 0.1\n1 2.0\n2 4.1\n3 5.9\n4 8.1',
      );
      await qa.tapFinder(find.byKey(const Key('calc.regress')));
      await calc();
      qa.expectText('ICH Q2(R2)', s);
    });

    // A = 500·0,40·0,789 = 157,8 g; m·r = 56; cho‘qqi 2,82 ‰;
    // min = 157,8·0,7/56 − 0,2·2 = 1,57 ‰; max = 157,8·0,9/56 − 0,1·2 = 2,34 ‰.
    await qa.step('Widmark: 80 kg, 500 mL 40 %, 2 soat → 1,57–2,34 ‰', (
      s,
    ) async {
      await open('tool.tox.widmark');
      await qa.enterText(find.byKey(const Key('calc.weight')), '80');
      await qa.enterText(find.byKey(const Key('calc.drink.0.volume')), '500');
      await qa.enterText(find.byKey(const Key('calc.drink.0.abv')), '40');
      await qa.enterText(find.byKey(const Key('calc.hours')), '2');
      await calc();
      qa.expectText(RegExp(r'1[,.]57 ‰'), s);
      qa.expectText(RegExp(r'2[,.]34 ‰'), s);
    });

    await qa.step('Widmark: vazn 5 kg → tushunarli xato', (s) async {
      await qa.scrollToTop();
      await qa.enterText(find.byKey(const Key('calc.weight')), '5');
      await qa.tapFinder(find.byKey(const Key('calc.calculate')));
      qa.expectText(l.calcErrorWeight, s);
    });

    await qa.step('Teskari hisob: 0,8 ‰, 2 soat', (s) async {
      await open('tool.tox.back_calculation');
      await qa.enterText(find.byKey(const Key('calc.bac')), '0,8');
      await qa.enterText(find.byKey(const Key('calc.hours')), '2');
      await calc();
      // β g/L/soat → ‰: 0,8 + 0,10·2/1,055 = 0,99; 0,8 + 0,25·2/1,055 = 1,27.
      qa.expectText(RegExp(r'0[,.]99–1[,.]27 ‰'), s);
    });

    // 0,5 ‰ · 1,055 = 0,5275 g/L; 52,75 mg/dL; 11,45 mmol/L.
    await qa.step('Etanol birliklari: 0,5 ‰ → 0,5275 g/L', (s) async {
      await open('tool.conv.ethanol_units');
      await qa.enterText(find.byKey(const Key('calc.value')), '0,5');
      await calc();
      qa.expectText(RegExp(r'^0[,.]5275$'), s);
    });

    // Q = (30 − 15)/(37,2 − 15) = 0,676; B = −0,0617 → t ≈ 9,7 soat.
    await qa.step('Henssge (PMI): Tr 30, Ta 15, 70 kg → ≈ 9,7 soat', (s) async {
      await open('tool.fm.pmi_henssge');
      await qa.enterText(find.byKey(const Key('calc.rectal')), '30');
      await qa.enterText(find.byKey(const Key('calc.ambient')), '15');
      await qa.enterText(find.byKey(const Key('calc.weight')), '70');
      await calc();
      qa.expectText(RegExp(r'9[,.]7'), s);
      qa.expectText('PMI', s);
    });

    await qa.step('Henssge: Ta 25 °C → > 23 °C formulasi ko‘rsatiladi', (
      s,
    ) async {
      await qa.scrollToTop();
      await qa.enterText(find.byKey(const Key('calc.ambient')), '25');
      await calc();
      await qa.scrollUntil(find.textContaining('1.11'));
      qa.expectText(RegExp(r'1[.,]11'), s);
    });

    await qa.step('Henssge: Tr < Ta → xato', (s) async {
      await qa.scrollToTop();
      await qa.enterText(find.byKey(const Key('calc.rectal')), '20');
      await qa.tapFinder(find.byKey(const Key('calc.calculate')));
      qa.expectText(l.calcErrorRectal, s);
    }, shot: false);

    // ------------------------------------------------------------ o‘quv
    await qa.step('Ta’lim markazi', (s) async {
      goTo(tester, Routes.learn);
      await qa.settle();
      qa.expectText(l.studyTitle, s);
    });

    await qa.step('O‘quv rejimi: to‘plamlar', (s) async {
      goTo(tester, Routes.study);
      await qa.settle(maxMs: 6000);
      qa.expectText(l.learnFlashcards, s);
    });

    await qa.step('Kartochka: old tomoni', (s) async {
      await qa.tapFinder(_keyPrefix('study.cards.'));
      qa.expectText(l.flashcardShowAnswer, s);
    });

    await qa.step('Kartochka: aylantirish (javob)', (s) async {
      await qa.tapFinder(find.byKey(const Key('study.reveal')));
      qa.expectText(l.flashcardKnew, s);
    });

    var graded = 0;
    await qa.step('Kartochka: Bildim / Bilmadim (Leitner)', (s) async {
      await qa.tapFinder(find.byKey(const Key('study.knew')));
      graded++;
      for (var i = 0; i < 2; i++) {
        if (find.byKey(const Key('study.reveal')).evaluate().isEmpty) break;
        await qa.tapFinder(find.byKey(const Key('study.reveal')));
        await qa.tapFinder(find.byKey(const Key('study.didntKnow')));
        graded++;
      }
      final progress = containerOf(tester).read(studyProgressProvider);
      if (progress.length < graded) {
        s.passed = false;
        s.notes.add('Leitner: ${progress.length} < $graded');
      }
    });

    await qa.step('O‘quv rejimi: muddati kelganlar soni yangilandi', (s) async {
      goTo(tester, Routes.study);
      await qa.settle();
    }, shot: false);

    await qa.step('Test: 1-savol', (s) async {
      await qa.tapFinder(_keyPrefix('study.quiz.'));
      qa.expectText(l.quizCheck, s);
    });

    var answered = 0;
    await qa.step('Test: javob → tekshirish → manba', (s) async {
      await qa.tapFinder(find.byKey(const Key('study.quiz.option.0')));
      await qa.tapFinder(find.byKey(const Key('study.quiz.check')));
      await qa.scrollUntil(find.byKey(const Key('study.quiz.next')));
    });

    await qa.step('Test: oxirigacha → natija va xatolar', (s) async {
      for (var i = 0; i < 40; i++) {
        final next = find.byKey(const Key('study.quiz.next'));
        if (next.evaluate().isEmpty) {
          await qa.tapFinder(find.byKey(const Key('study.quiz.option.1')));
          await qa.tapFinder(find.byKey(const Key('study.quiz.check')));
        }
        await qa.tapFinder(find.byKey(const Key('study.quiz.next')));
        answered++;
        if (find.byKey(const Key('study.quiz.score')).evaluate().isNotEmpty) {
          break;
        }
      }
      await qa.scrollToTop();
      if (find.byKey(const Key('study.quiz.score')).evaluate().isEmpty) {
        s.passed = false;
        s.notes.add('natija ekrani chiqmadi');
      }
      s.notes.add('javoblar: $answered');
    });

    await qa.step('Test: xatolar ro‘yxati', (s) async {
      await qa.scrollBy(500);
    });

    await qa.step('Xato → manbani ochish', (s) async {
      final src = _keyPrefix('study.source.');
      await qa.tapFinder(src);
    });

    // --------------------------------------------------- ru / en, ekranlar
    Future<void> lang(String code) async {
      await containerOf(tester)
          .read(settingsControllerProvider.notifier)
          .setLocale(Locale(code));
      l = lookupAppLocalizations(Locale(code));
      qa.lang = code;
      await qa.settle();
    }

    await lang('ru');
    await qa.step('RU: Henssge (Посмертный интервал)', (s) async {
      await open('tool.fm.pmi_henssge');
      await qa.enterText(find.byKey(const Key('calc.rectal')), '30');
      await qa.enterText(find.byKey(const Key('calc.ambient')), '15');
      await qa.enterText(find.byKey(const Key('calc.weight')), '70');
      await calc();
      qa.expectText('Посмертный интервал (PMI)', s);
    }, langCheck: false);

    await lang('en');
    await qa.step('EN: Widmark', (s) async {
      await open('tool.tox.widmark');
      await qa.enterText(find.byKey(const Key('calc.weight')), '80');
      await qa.enterText(find.byKey(const Key('calc.drink.0.volume')), '500');
      await qa.enterText(find.byKey(const Key('calc.drink.0.abv')), '40');
      await qa.enterText(find.byKey(const Key('calc.hours')), '2');
      await calc();
      qa.expectText(RegExp(r'1\.57 ‰'), s);
    }, langCheck: false);

    await lang('uz');
    await qa.setSize(const Size(320, 640));
    await qa.step('320 dp: Widmark natijasi', (s) async {
      await open('tool.tox.widmark');
      await qa.enterText(find.byKey(const Key('calc.weight')), '80');
      await qa.enterText(find.byKey(const Key('calc.drink.0.volume')), '500');
      await qa.enterText(find.byKey(const Key('calc.drink.0.abv')), '40');
      await qa.enterText(find.byKey(const Key('calc.hours')), '2');
      await calc();
    });

    tester.platformDispatcher.textScaleFactorTestValue = 2;
    await qa.step('320 dp + 2× matn: Suyultirish', (s) async {
      await open('tool.lab.dilution');
    });
    await qa.step('320 dp + 2× matn: kartochka', (s) async {
      goTo(tester, Routes.study);
      await qa.settle();
      await qa.tapFinder(_keyPrefix('study.cards.'));
    });
    tester.platformDispatcher.clearTextScaleFactorTestValue();

    await qa.setSize(const Size(390, 844));
    await containerOf(tester)
        .read(settingsControllerProvider.notifier)
        .setThemeMode(ThemeMode.dark);
    await qa.step('Tungi rejim: Henssge natijasi', (s) async {
      await open('tool.fm.pmi_henssge');
      await qa.enterText(find.byKey(const Key('calc.rectal')), '30');
      await qa.enterText(find.byKey(const Key('calc.ambient')), '15');
      await qa.enterText(find.byKey(const Key('calc.weight')), '70');
      await calc();
    });
    await qa.step('Tungi rejim: test savoli', (s) async {
      goTo(tester, Routes.study);
      await qa.settle();
      await qa.tapFinder(_keyPrefix('study.quiz.'));
    });

    await qa.step('Tarmoq o‘chiq', (s) async {
      s.notes.add('Bloklangan HTTP urinishlari: ${net.attempts}');
    }, shot: false);

    qa.restoreErrorHandler();
    qa.writeResults();
    printSummary(qa);
    HttpOverrides.global = null;
  });
}
