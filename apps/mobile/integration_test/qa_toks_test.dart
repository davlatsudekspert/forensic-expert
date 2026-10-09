// REAL-ILOVA QA — «TOKSIKOLOGIK KIMYO» KARTALARI VA SAVOLLARI
// (prof. Yuldashev Z.A. o‘quv-uslubiy majmuasi; muallif ruxsati bilan,
// barcha uchun bepul).
//
// Haqiqiy ilova (`bootstrap()`), haqiqiy yo‘riqnoma paketi, Linux desktop.
// Akkaunt — MOCK, Pro YO‘Q (bepul foydalanuvchi), tarmoq — o‘chirilgan.
//
// Muhit: QA_MODE=student|professional  QA_LANG=uz|ru|en  QA_SHOTS=0 (skrinshotsiz)
//   QA_OUT=/tmp/t xvfb-run -a flutter test integration_test/qa_toks_test.dart \
//     -d linux --dart-define=FE_AUTH_MODE=mock
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:integration_test/integration_test.dart';

import 'qa/harness.dart';
import 'qa/qa_env.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final env = Platform.environment;
  final lang = env['QA_LANG'] ?? 'uz';
  final mode = env['QA_MODE'] ?? 'student';
  final shots = env['QA_SHOTS'] != '0';
  final role = 'toks-$lang-$mode';

  testWidgets('QA real app — TOKS cards and quiz ($role)', (tester) async {
    final net = NoNetworkOverrides();
    HttpOverrides.global = net;
    final qa = await launchRealApp(
      tester,
      role: role,
      prefs: {
        'fe.settings.locale': lang,
        'fe.settings.theme': 'light',
        'fe.settings.mode': mode,
        'fe.settings.disclaimer_version': 1,
      },
    );
    qa.lang = lang;
    await qa.setSize(const Size(390, 844));

    final attribution = switch (lang) {
      'ru' => 'с разрешения автора, бесплатно для всех',
      'en' => 'free for everyone',
      _ => 'muallif ruxsati bilan, barcha uchun bepul',
    };

    Future<void> open(String route) async {
      goTo(tester, route);
      await qa.settle(maxMs: 6000);
      await qa.scrollToTop();
    }

    Future<void> scrollIn(String key, double dy) async {
      final f = find.descendant(
        of: find.byKey(Key(key)),
        matching: find.byType(Scrollable),
      );
      if (f.evaluate().isEmpty) return qa.scrollBy(dy);
      final st = tester.state<ScrollableState>(f.first);
      final p = st.position;
      p.jumpTo((p.pixels + dy).clamp(0, p.maxScrollExtent));
      await qa.settle();
    }

    void expectKey(String key, QaStep s) {
      if (find.byKey(Key(key)).evaluate().isEmpty) {
        s.passed = false;
        s.notes.add('KUTILGAN ELEMENT YO‘Q: $key');
      }
    }

    // ------------------------------------------------ ro‘yxat (bepul, Pro’siz)
    await qa.step('Guidelines list toks cards', shot: shots, (s) async {
      await open(Routes.guidelines);
      await qa.scrollUntil(
        find.byKey(const Key('guidelines.card.guideline.chem.toks_isolation')),
      );
      expectKey('guidelines.card.guideline.chem.toks_isolation', s);
    });

    // ------------------------------------------------------- uchta karta
    const cards = [
      ('Isolation card top', 'guideline.chem.toks_isolation', 0.0),
      ('Metal poisons methods', 'guideline.chem.toks_metal_poisons', 1400.0),
      ('Pesticides card cautions', 'guideline.chem.toks_pesticides', 3600.0),
    ];
    for (final (title, id, dy) in cards) {
      await qa.step(title, shot: shots, (s) async {
        await open(Routes.guideline(id));
        expectKey('guideline.toksAttribution', s);
        qa.expectText(attribution, s, why: 'manba qatori');
        expectKey('guideline.index.refs', s);
        if (dy > 0) await scrollIn('guideline.detail', dy);
      });
    }
    await qa.step('Volatile card references', shot: false, (s) async {
      await open(Routes.guideline('guideline.chem.toks_volatile_poisons'));
      expectKey('guideline.toksAttribution', s);
      await scrollIn('guideline.detail', 50000);
      expectKey('guideline.ref.toks_majmua2025', s);
    });
    await qa.step('Mineralization card', shot: false, (s) async {
      await open(Routes.guideline('guideline.chem.toks_mineralization'));
      expectKey('guideline.toksAttribution', s);
    });

    // ---------------------------------------------- o‘quv rejimi va test
    await qa.step('Study hub toks deck', shot: shots, (s) async {
      await open(Routes.study);
      await qa.scrollUntil(find.byKey(const Key('study.deck.teaching.toks')));
      expectKey('study.deck.teaching.toks', s);
      expectKey('study.attribution.teaching.toks', s);
      final f = find.byKey(const Key('study.deck.teaching.toks'));
      if (f.evaluate().isNotEmpty) {
        await tester.ensureVisible(f);
        await qa.settle();
      }
    });
    await qa.step('Toks quiz question', shot: false, (s) async {
      await open(Routes.studyQuiz('teaching.toks'));
      expectKey('study.quiz.stem', s);
      expectKey('study.quiz.option.3', s);
    });
    await qa.step('Toks quiz answered', shot: shots, (s) async {
      await qa.tapFinder(find.byKey(const Key('study.quiz.option.0')));
      await qa.tapFinder(find.byKey(const Key('study.quiz.check')));
      bool isPages(Widget w) =>
          w.key is ValueKey<String> &&
          (w.key! as ValueKey<String>).value.startsWith('study.source.pages.');
      await qa.scrollUntil(find.byWidgetPredicate(isPages));
      if (find.byWidgetPredicate(isPages).evaluate().isEmpty) {
        s.passed = false;
        s.notes.add('manba sahifasi ko‘rsatilmadi');
      }
    });
    await qa.step('Toks flashcard', shot: false, (s) async {
      await open(Routes.studyCards('teaching.toks'));
      expectKey('study.front', s);
    });

    // ------------------------------------------- kichik ekran, katta matn
    await qa.setSize(const Size(320, 640));
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    await qa.step('320 2x volatile card', shot: shots, (s) async {
      await open(Routes.guideline('guideline.chem.toks_volatile_poisons'));
      await scrollIn('guideline.detail', -100000);
      await scrollIn('guideline.detail', 380);
      expectKey('guideline.toksAttribution', s);
    });
    await qa.step('320 2x toks quiz', shot: shots, (s) async {
      await open(Routes.studyQuiz('teaching.toks'));
      expectKey('study.quiz.stem', s);
    });
    tester.platformDispatcher.clearTextScaleFactorTestValue();

    qa.restoreErrorHandler();
    qa.writeResults();
    printSummary(qa);
    HttpOverrides.global = null;
  });
}
