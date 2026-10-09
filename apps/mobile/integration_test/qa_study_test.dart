// REAL-ILOVA QA — O‘QUV TESTI VA TERMINOLOGIYA (Phase E/F, 2026-10-09).
//
// Haqiqiy ilova (`bootstrap()`), haqiqiy imzolangan pilot paket va
// yo‘riqnoma asset’i, Linux desktop dvigateli. Akkaunt — MOCK, tarmoq —
// o‘chirilgan, Pro huquqi YO‘Q (bepul foydalanuvchi). Har bir rol (TALABA,
// MUTAXASSIS) × til (uz, ru, en) uchun: to‘plamlar, mashq (javob → izoh →
// «Manbani ochish»), «To‘g‘ri / Noto‘g‘ri», imtihon, kartadagi GC-MS havolasi,
// 320 dp.
//
//   QA_OUT=docs/qa/l10n_ef_20261009 ./tool/qa_real_app.sh study
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/app/study.dart';
import 'package:forensic_expert/core/settings/app_settings.dart';
import 'package:forensic_expert/core/settings/settings_controller.dart';
import 'package:forensic_expert/domain/learn/study_models.dart';
import 'package:integration_test/integration_test.dart';

import 'qa/harness.dart';
import 'qa/qa_env.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('QA real app — STUDY (Phase E/F)', (tester) async {
    final net = NoNetworkOverrides();
    HttpOverrides.global = net;
    final qa = await launchRealApp(
      tester,
      role: 'study',
      prefs: {
        'fe.settings.locale': 'uz',
        'fe.settings.theme': 'light',
        'fe.settings.mode': 'student',
        'fe.settings.disclaimer_version': 1,
      },
      overrides: [studySeedProvider.overrideWithValue(() => 3)],
    );

    Future<void> open(String route) async {
      goTo(tester, Routes.home);
      await qa.settle();
      goTo(tester, route);
      await qa.settle(maxMs: 6000);
      await qa.scrollToTop();
    }

    void expectKey(String key) {
      if (find.byKey(Key(key)).evaluate().isEmpty) {
        throw StateError('topilmadi: $key');
      }
    }

    void expectPrefix(String prefix) {
      final f = find.byWidgetPredicate(
        (w) =>
            w.key is ValueKey<String> &&
            (w.key! as ValueKey<String>).value.startsWith(prefix),
      );
      if (f.evaluate().isEmpty) throw StateError('topilmadi: $prefix*');
    }

    void expectText(Pattern p) {
      if (!qa.showsText(p)) throw StateError('matn topilmadi: $p');
    }

    Future<void> scrollToPrefix(String prefix) async {
      final f = find.byWidgetPredicate(
        (w) =>
            w.key is ValueKey<String> &&
            (w.key! as ValueKey<String>).value.startsWith(prefix),
      );
      await qa.scrollUntil(f);
    }

    /// Mashqda bitta javob: variant → tekshirish → izoh.
    Future<void> answerPractice() async {
      await qa.tapFinder(find.byKey(const Key('study.quiz.option.0')));
      await qa.tapFinder(find.byKey(const Key('study.quiz.check')));
    }

    final settings = containerOf(tester)
        .read(settingsControllerProvider.notifier);

    for (final (mode, roleName) in const [
      (UserMode.student, 'STUDENT'),
      (UserMode.professional, 'EXPERT'),
    ]) {
      await settings.setUserMode(mode);
      for (final lang in const ['uz', 'ru', 'en']) {
        await settings.setLocale(Locale(lang));
        qa.lang = lang;
        await qa.setSize(const Size(390, 844));
        final tag = '$roleName $lang';

        await qa.step('$tag: study hub decks and modes', (s) async {
          await open(Routes.study);
          await qa.scrollUntil(
            find.byKey(const Key('study.deck.teaching.toks')),
          );
          expectKey('study.exam.teaching.toks');
          expectKey('study.examCount.teaching.toks');
          if (lang != 'uz') expectKey('study.examUnavailable.teaching.toks');
        });

        await qa.step('$tag: hub mixed topics deck', (s) async {
          await open(Routes.study);
          await qa.scrollUntil(
            find.byKey(const Key('study.deck.discipline.mixed')),
          );
          expectKey('study.deck.discipline.mixed');
        });

        await qa.step('$tag: practice toks answered with explanation', (
          s,
        ) async {
          await open(Routes.studyQuiz('teaching.toks'));
          expectKey('study.mode.practice');
          expectKey('study.mode.banner.practice');
          await answerPractice();
          await scrollToPrefix('study.explanation.');
          expectPrefix('study.explanation.text.');
          expectPrefix('study.quiz.openSource.');
        });

        await qa.step('$tag: practice toks open source', (s) async {
          final f = find.byWidgetPredicate(
            (w) =>
                w.key is ValueKey<String> &&
                (w.key! as ValueKey<String>).value.startsWith(
                  'study.quiz.openSource.',
                ),
          );
          await qa.tapFinder(f.first);
          expectKey('guideline.detail');
        });

        await qa.step('$tag: practice topics translated quote', (s) async {
          // Bepul foydalanuvchida mavjud birinchi fan to‘plami.
          final decks = containerOf(tester).read(studyCatalogProvider).decks;
          final deck = decks.firstWhere(
            (d) => d.kind == StudyDeckKind.discipline && !d.isMixed,
            orElse: () =>
                decks.firstWhere((d) => d.kind == StudyDeckKind.discipline),
          );
          s.notes.add('deck: ${deck.id}');
          await open(Routes.studyQuiz(deck.id));
          expectKey('study.quiz.stem');
          if (lang != 'en') expectPrefix('study.quote.translated.');
          await answerPractice();
          await scrollToPrefix('study.explanation.');
          expectPrefix('study.explanation.');
        });

        await qa.step('$tag: mixed deck practice (true/false or MC)', (
          s,
        ) async {
          await open(Routes.studyQuiz('discipline.mixed'));
          expectKey('study.quiz.stem');
          await answerPractice();
          await scrollToPrefix('study.explanation.');
          expectPrefix('study.explanation.');
        });

        await qa.step('$tag: exam', (s) async {
          await open(Routes.studyQuiz('teaching.toks', exam: true));
          if (lang != 'uz') {
            expectKey('study.quiz.unavailable');
            return;
          }
          expectKey('study.mode.exam');
          expectKey('study.mode.banner.exam');
          for (var n = 0; n < 40; n++) {
            final next = find.byKey(const Key('study.quiz.next'));
            if (next.evaluate().isEmpty) break;
            await qa.tapFinder(find.byKey(const Key('study.quiz.option.1')));
            await qa.tapFinder(next);
          }
          expectKey('study.exam.percent');
          expectKey('study.quiz.score');
        });

        if (lang == 'uz') {
          await qa.step('$tag: exam review explanations', (s) async {
            await qa.scrollUntil(find.byKey(const Key('study.quiz.review.0')));
            expectPrefix('study.explanation.text.');
          });
        }

        await qa.step('$tag: guideline card abbreviation link sheet', (
          s,
        ) async {
          await open(Routes.guideline('guideline.chem.method_comparison'));
          // Kartadagi bosiladigan qisqartmalar (GC-MS afzal). Karta matnidagi
          // GX-MS / ГХ-МС kabi shakllar havola bo‘lmaydi — ularni kontent
          // (D) bosqichi kanonik shaklga keltiradi.
          final links = <String, TapGestureRecognizer>{};
          void collect() {
            for (final e in find.byType(SelectableText).evaluate()) {
              (e.widget as SelectableText).textSpan?.visitChildren((x) {
                if (x is TextSpan && x.recognizer is TapGestureRecognizer) {
                  links.putIfAbsent(
                    x.text!,
                    () => x.recognizer! as TapGestureRecognizer,
                  );
                }
                return true;
              });
            }
          }

          for (var i = 0; i < 12 && !links.containsKey('GC-MS'); i++) {
            collect();
            await qa.scrollBy(700);
          }
          s.notes.add('links: ${links.keys.join(', ')}');
          final link = links['GC-MS'] ?? links.values.firstOrNull;
          if (link == null) throw StateError('qisqartma havolasi topilmadi');
          if (!links.containsKey('GC-MS')) {
            s.notes.add('GC-MS kartada kanonik shaklda emas (kontent D)');
          }
          link.onTap!();
          await qa.settle();
          expectKey('glossary.sheet');
          expectKey('glossary.explanation');
          expectKey('glossary.badge.machineDraft');
        });

        await qa.step('$tag: 320 dp practice explanation', (s) async {
          await qa.setSize(const Size(320, 640));
          await open(Routes.studyQuiz('teaching.gmt'));
          await answerPractice();
          await scrollToPrefix('study.explanation.');
          expectPrefix('study.explanation.text.');
        });

        await qa.step('$tag: 320 dp hub', (s) async {
          await open(Routes.study);
          await qa.scrollUntil(
            find.byKey(const Key('study.deck.teaching.gmt')),
          );
          expectKey('study.exam.teaching.gmt');
        });
        await qa.setSize(const Size(390, 844));

        if (lang == 'uz' && mode == UserMode.student) {
          await qa.step('$tag: counter text style', (s) async {
            await open(Routes.studyQuiz('teaching.gmt'));
            expectText(RegExp(r'^1-savol / \d+ ta$'));
          });
        }
      }
    }

    qa
      ..writeResults()
      ..restoreErrorHandler();
    printSummary(qa);
  });
}
