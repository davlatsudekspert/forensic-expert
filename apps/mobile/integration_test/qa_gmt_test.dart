// REAL-ILOVA QA — «Giyohvand moddalar tahlili» (GMT) kartalari va o‘quv testi.
//
// Haqiqiy ilova (`bootstrap()`), haqiqiy yo‘riqnoma asseti va imzolangan pilot
// paket, Linux desktop dvigateli. Akkaunt — MOCK, tarmoq — o‘chirilgan.
// Pro huquqi YO‘Q (bepul foydalanuvchi): kartalar va savollar ochiq bo‘lishi
// kerak (egasi qarori, 2026-10-09).
//
//   QA_OUT=docs/qa/gmt_20261009 QA_MODE=student xvfb-run -a flutter test \
//     integration_test/qa_gmt_test.dart -d linux --dart-define=FE_AUTH_MODE=mock
//   QA_MODE=professional — mutaxassis sinovi (kamroq skrinshot, 320 dp).
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/app/study.dart';
import 'package:integration_test/integration_test.dart';

import 'qa/harness.dart';
import 'qa/qa_env.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final env = Platform.environment;
  final lang = env['QA_LANG'] ?? 'uz';
  final mode = env['QA_MODE'] ?? 'student';
  final expert = mode == 'professional';

  testWidgets('QA real app — GMT ($lang-$mode)', (tester) async {
    final net = NoNetworkOverrides();
    HttpOverrides.global = net;
    final qa = await launchRealApp(
      tester,
      role: 'gmt-$lang-$mode',
      prefs: {
        'fe.settings.locale': lang,
        'fe.settings.theme': 'light',
        'fe.settings.mode': mode,
        'fe.settings.disclaimer_version': 1,
      },
      overrides: [studySeedProvider.overrideWithValue(() => 3)],
    );
    qa.lang = lang;

    Future<void> open(String route) async {
      goTo(tester, route);
      await qa.settle(maxMs: 6000);
      await qa.scrollToTop();
    }

    void expectKey(String key) {
      if (find.byKey(Key(key)).evaluate().isEmpty) {
        throw StateError('topilmadi: $key');
      }
    }

    void expectText(Pattern p) {
      if (!qa.showsText(p)) throw StateError('matn topilmadi: $p');
    }

    Future<void> answerFirstOption() async {
      await qa.tapFinder(find.byKey(const Key('study.quiz.option.0')));
      await qa.tapFinder(find.byKey(const Key('study.quiz.check')));
      final ok = find.byKey(const Key('study.quiz.feedback.ok'));
      final bad = find.byKey(const Key('study.quiz.feedback.wrong'));
      if (ok.evaluate().isEmpty && bad.evaluate().isEmpty) {
        throw StateError('javob natijasi ko‘rinmadi');
      }
    }

    const deck = 'teaching.gmt';

    if (!expert) {
      // ----------------------------------------------- TALABA (bepul)
      await qa.step('GMT: guidelines list', (s) async {
        await open(Routes.guidelines);
        await qa.scrollBy(900);
        expectText(RegExp('Opiatlar va opioidlar|Опиаты|Opiates'));
      });
      await qa.step('GMT: opioids card (attribution, free)', (s) async {
        await open(Routes.guideline('guideline.chem.gmt_opioids'));
        expectKey('guideline.toksAttribution');
        expectText(RegExp('Yuldashev Z.A.'));
      });
      await qa.step('GMT: cannabis card scrolled', (s) async {
        await open(Routes.guideline('guideline.chem.gmt_cannabis'));
        expectKey('guideline.toksAttribution');
        await qa.scrollBy(1200);
      });
      await qa.step('GMT: legal note card', (s) async {
        await open(Routes.guideline('guideline.chem.gmt_uz_control_lists'));
        await qa.scrollBy(500);
        expectText(RegExp('lex.uz'));
      });
      await qa.step('GMT: quiz question', (s) async {
        await open(Routes.studyQuiz(deck));
        expectKey('study.quiz.stem');
      });
      await qa.step('GMT: quiz answered + sources', (s) async {
        await answerFirstOption();
        await qa.scrollBy(400);
      });
      // Qolgan ekranlar skrinshotsiz: bepul foydalanuvchida barcha 9 karta
      // ochiladi va atribusiya qatori bor.
      for (final id in const [
        'gmt_analysis_scheme',
        'gmt_cocaine',
        'gmt_phenylalkylamines',
        'gmt_barbiturates',
        'gmt_benzodiazepines',
        'gmt_precursors',
      ]) {
        await qa.step('GMT: open $id', (s) async {
          await open(Routes.guideline('guideline.chem.$id'));
          expectKey('guideline.toksAttribution');
        }, shot: false);
      }
    } else {
      // ------------------------------------------- MUTAXASSIS (320 dp)
      await qa.setSize(const Size(320, 640));
      await qa.step('GMT expert 320: benzodiazepines card', (s) async {
        await open(Routes.guideline('guideline.chem.gmt_benzodiazepines'));
        expectKey('guideline.toksAttribution');
      });
      await qa.step('GMT expert: study hub', (s) async {
        await open(Routes.study);
        expectKey('study.deck.$deck');
      }, shot: false);
      await qa.step('GMT expert 320: quiz answered', (s) async {
        await open(Routes.studyQuiz(deck));
        await answerFirstOption();
      });
      await qa.step('GMT expert: precursors card', (s) async {
        await open(Routes.guideline('guideline.chem.gmt_precursors'));
        expectKey('guideline.toksAttribution');
      }, shot: false);
    }

    qa.restoreErrorHandler();
    qa.writeResults();
    printSummary(qa);
    HttpOverrides.global = null;
  });
}
