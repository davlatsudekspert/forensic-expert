// REAL-ILOVA QA — IQTIBOS EKSPORTI (GOST / Vancouver / APA).
//
// Haqiqiy ilova (`bootstrap()`), haqiqiy imzolangan pilot kontent paketi,
// Linux desktop dvigateli. Akkaunt — MOCK, tarmoq — o‘chirilgan.
//
// Muhit: QA_LANG=uz|ru|en  QA_MODE=student|professional  QA_SHOTS=0 (rasmsiz)
//
//   QA_OUT=docs/qa/citations_20261009 ./tool/qa_real_app.sh citations
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/l10n/generated/app_localizations.dart';
import 'package:integration_test/integration_test.dart';

import 'qa/harness.dart';
import 'qa/qa_env.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final env = Platform.environment;
  final lang = env['QA_LANG'] ?? 'uz';
  final mode = env['QA_MODE'] ?? 'student';
  final shots = env['QA_SHOTS'] != '0';
  final l = lookupAppLocalizations(Locale(lang));

  testWidgets('QA real app — CITATIONS ($lang-$mode)', (tester) async {
    final net = NoNetworkOverrides();
    HttpOverrides.global = net;
    final qa = await launchRealApp(
      tester,
      role: 'citations-$lang-$mode',
      prefs: {
        'fe.settings.locale': lang,
        'fe.settings.theme': 'light',
        'fe.settings.mode': mode,
        'fe.settings.disclaimer_version': 1,
      },
    );
    qa.lang = lang;

    /// Haqiqiy tizim buferi (GTK). Javob bo‘lmasa — null (qayd qilinadi).
    Future<String?> clipboard() async {
      final d = await tester.runAsync(
        () =>
            Clipboard.getData(Clipboard.kTextPlain)
                .timeout(const Duration(seconds: 3), onTimeout: () => null),
      );
      return d?.text;
    }

    Future<void> open(String route) async {
      goTo(tester, route);
      await qa.settle(maxMs: 6000);
      await qa.scrollToTop();
    }

    Future<void> jump(String id) async {
      final f = find.byKey(Key('entry.index.$id'));
      await tester.ensureVisible(f);
      await qa.settle();
      await tester.tap(f, warnIfMissed: false);
      await qa.settle();
    }

    await qa.step('Ethanol sources section', shot: shots, (s) async {
      await open(Routes.libraryEntry('ethanol'));
      await jump('sources');
      qa.expectText(l.citeAllSources, s);
      if (find.byTooltip(l.citeCopy).evaluate().isEmpty) {
        s.passed = false;
        s.notes.add('manba kartasida «${l.citeCopy}» yo‘q');
      }
    });

    await qa.step('Ethanol reference list sheet', shot: shots, (s) async {
      await qa.tapText(l.citeAllSources);
      qa.expectText(l.citeVerifyNote, s);
      if (find.byKey(const Key('cite.preview')).evaluate().isEmpty) {
        s.passed = false;
        s.notes.add('ko‘rinish yo‘q');
      }
    });

    await qa.step('Ethanol list copied', shot: shots, (s) async {
      await qa.tapFinder(find.byKey(const Key('cite.copy')), scroll: false);
      final text = await clipboard();
      if (text == null) {
        s.notes.add('tizim buferi o‘qilmadi (Xvfb) — SnackBar tekshirildi');
      } else {
        final lines = text.split('\n');
        s.notes.add('${lines.length} qator; 1-qator: ${lines.first}');
        for (final (i, line) in lines.indexed) {
          if (!line.startsWith('${i + 1}. ')) {
            s.passed = false;
            s.notes.add('raqamlash buzilgan: $line');
          }
        }
        if (lang != 'en' &&
            !text.contains(switch (lang) {
              'ru' => '[Электронный ресурс]',
              _ => '[Elektron resurs]',
            })) {
          s.passed = false;
          s.notes.add('GOST elektron resurs belgisi yo‘q');
        }
      }
      if (find.byType(SnackBar).evaluate().isEmpty) {
        s.passed = false;
        s.notes.add('«nusxalandi» xabari yo‘q');
      }
    });

    await qa.step('Single source citation (Vancouver)', shot: shots, (s) async {
      await qa.tapFinder(find.byTooltip(l.citeCopy).first);
      await qa.tapText(l.citeStyleVancouver);
      final preview = tester.widget<SelectableText>(
        find.byKey(const Key('cite.preview')),
      );
      s.notes.add('Vancouver: ${preview.data}');
      await qa.tapFinder(find.byKey(const Key('cite.copy')), scroll: false);
      qa.expectText(l.citeCopied, s);
    });

    await qa.step('Guideline reference list', shot: shots, (s) async {
      await open(Routes.guideline('guideline.chem.ethanol_gc'));
      final f = find.text(l.citeAllSources);
      await qa.scrollUntil(f);
      await qa.tapFinder(f);
      final preview = tester.widget<SelectableText>(
        find.byKey(const Key('cite.preview')),
      );
      s.notes.add('1-qator: ${preview.data!.split('\n').first}');
      await qa.tapFinder(find.byKey(const Key('cite.copy')), scroll: false);
    });

    await qa.setSize(const Size(320, 640));
    await qa.step('320dp citation sheet', shot: shots, (s) async {
      await open(Routes.libraryEntry('ethanol'));
      await jump('sources');
      await qa.tapText(l.citeAllSources);
      if (find.byKey(const Key('cite.copy')).hitTestable().evaluate().isEmpty) {
        s.passed = false;
        s.notes.add('320 dp: «Nusxalash» ko‘rinmaydi');
      }
    });
    await qa.back();

    qa.restoreErrorHandler();
    qa.writeResults();
    printSummary(qa);
    HttpOverrides.global = null;
  });
}
