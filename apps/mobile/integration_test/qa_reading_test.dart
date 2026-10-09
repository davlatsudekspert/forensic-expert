// REAL-ILOVA QA — O‘QISH TAJRIBASI (kutubxona, modda sahifalari, usullar,
// yo‘riqnomalar, manbalar, qidiruv).
//
// Haqiqiy ilova (`bootstrap()`), haqiqiy imzolangan pilot kontent paketi,
// Linux desktop dvigateli. Akkaunt — MOCK, tarmoq — o‘chirilgan. Onboarding
// tugagan holatdan boshlanadi (sozlamalar oldindan yozilgan).
//
// Muhit:
//   QA_LANG=uz|ru|en   QA_MODE=student|professional
//   QA_PRO=1           (Pro huquq — faqat test override, store’siz)
//   QA_THEME=dark      QA_OUT=<katalog>
//
//   QA_OUT=/tmp/r xvfb-run -a flutter test integration_test/qa_reading_test.dart \
//     -d linux --dart-define=FE_AUTH_MODE=mock
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/domain/ports/billing_ports.dart';
import 'package:integration_test/integration_test.dart';

import 'qa/harness.dart';
import 'qa/qa_env.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final env = Platform.environment;
  final lang = env['QA_LANG'] ?? 'uz';
  final mode = env['QA_MODE'] ?? 'student';
  final pro = env['QA_PRO'] == '1';
  final dark = env['QA_THEME'] == 'dark';
  final role = '$lang-$mode${pro ? '-pro' : ''}${dark ? '-dark' : ''}';

  testWidgets('QA real app — READING ($role)', (tester) async {
    final net = NoNetworkOverrides();
    HttpOverrides.global = net;
    final qa = await launchRealApp(
      tester,
      role: 'reading-$role',
      prefs: {
        'fe.settings.locale': lang,
        'fe.settings.theme': dark ? 'dark' : 'light',
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
    qa.lang = lang;

    Future<void> open(String route) async {
      goTo(tester, route);
      await qa.settle(maxMs: 6000);
      await qa.scrollToTop();
    }

    Future<void> jump(String id) async {
      final f = find.byKey(Key('entry.index.$id'));
      if (f.evaluate().isEmpty) return;
      await tester.ensureVisible(f);
      await qa.settle();
      await tester.tap(f, warnIfMissed: false);
      await qa.settle();
    }

    /// [key] ichidagi ro‘yxatni aylantiradi (SelectableText’ning ichki
    /// Scrollable’i «asosiy» deb tanlanmasin).
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

    // --------------------------------------------------- kutubxona markazi
    await qa.step('Library hub', (s) async => open(Routes.library));
    await qa.step('Library hub scrolled', (s) async => qa.scrollBy(600));
    await qa.step('Substances list', (s) async {
      await open(Routes.librarySection('substances'));
    });

    // ------------------------------------- etanol: talaba/mutaxassis sahifasi
    await qa.step('Ethanol top', (s) async {
      await open(Routes.libraryEntry('ethanol'));
    });
    await qa.step('Ethanol scroll 1', (s) async => qa.scrollBy(700));
    await qa.step('Ethanol Tahlil', (s) async => jump('analysis'));
    await qa.step('Ethanol Tahlil 2', (s) async => qa.scrollBy(600));
    await qa.step('Ethanol concentrations', (s) async {
      await qa.scrollToTop();
      await jump('reported_concentration');
    });
    await qa.step('Ethanol concentrations 2', (s) async => qa.scrollBy(600));
    await qa.step('Ethanol where from sheet', (s) async {
      bool isProv(Widget w) =>
          w.key is ValueKey<String> &&
          (w.key! as ValueKey<String>).value.startsWith('claim.provenance.');
      final f = find.byWidgetPredicate(isProv);
      await tester.ensureVisible(f.first);
      await qa.settle();
      await tester.tap(f.first, warnIfMissed: false);
    });
    await qa.step('Ethanol sources', (s) async {
      await qa.back();
      await qa.scrollToTop();
      await jump('sources');
    });
    await qa.step('Ethanol bottom', (s) async => qa.scrollBy(5000));

    // ------------------------------- «morfin qonda qanday tahlil qilinadi?»
    await qa.step('Search morfin qon', (s) async {
      goTo(tester, Routes.home);
      await qa.settle();
      await open(
        Routes.searchWith(switch (lang) {
          'ru' => 'морфин кровь',
          'en' => 'morphine blood',
          _ => 'morfin qon',
        }),
      );
    });
    await qa.step('Morphine top', (s) async {
      await open(Routes.libraryEntry('morphine'));
    });
    await qa.step('Morphine scroll', (s) async => qa.scrollBy(700));
    await qa.step('Morphine Tahlil', (s) async {
      await qa.scrollToTop();
      await jump('analysis');
    });
    await qa.step('Morphine Tahlil 2', (s) async => qa.scrollBy(600));
    await qa.step('Morphine concentrations', (s) async {
      await qa.scrollToTop();
      await jump('reported_concentration');
    });

    // ----------------------------------------------- usullar (headspace GC)
    await qa.step('Methods list', (s) async {
      await open(Routes.knowledge('method'));
    });
    await qa.step('Headspace GC top', (s) async {
      await open(Routes.knowledgeEntry('method-headspace-gc'));
    });
    await qa.step('Headspace GC scroll', (s) async => qa.scrollBy(700));

    // ------------------------------------------------------- yo‘riqnomalar
    await qa.step('Guidelines list', (s) async => open(Routes.guidelines));
    await qa.step('Ethanol GC guideline', (s) async {
      await open(Routes.guideline('guideline.chem.ethanol_gc'));
    });
    await qa.step('Guideline scroll', (s) async {
      await scrollIn('guideline.detail', 800);
    });
    await qa.step('Guideline references', (s) async {
      await scrollIn('guideline.detail', 50000);
      await scrollIn('guideline.detail', -500);
    });

    // ------------------------------------------------ manbalar, namunalar
    await qa.step('Sources list', (s) async => open(Routes.sources));
    await qa.step('Source detail', (s) async {
      await qa.tapFinder(find.byIcon(Icons.chevron_right));
    });
    await qa.step('Specimens list', (s) async => open(Routes.specimens));
    await qa.step('Specimen blood', (s) async {
      await open(Routes.specimen('blood'));
    });
    await qa.step('Research list', (s) async => open(Routes.research));
    await qa.step('Research detail', (s) async {
      await open(Routes.researchFor('ethanol'));
      bool isRow(Widget w) =>
          w.key is ValueKey<String> &&
          (w.key! as ValueKey<String>).value.startsWith('research.RS-');
      await qa.tapFinder(find.byWidgetPredicate(isRow));
    });
    await qa.step('Disciplines', (s) async => open(Routes.disciplines));

    // -------------------------------------------------------------- qidiruv
    for (final q in switch (lang) {
      'ru' => ['алкоголь', 'этанол кровь'],
      'en' => ['alcohol', 'ethanol blood'],
      _ => ['alkogol', 'etanol qon', 'headspace'],
    }) {
      await qa.step('Search $q', (s) async {
        goTo(tester, Routes.home);
        await qa.settle();
        await open(Routes.searchWith(q));
      });
    }

    // ------------------------------------- kichik ekran, katta matn (2x)
    await qa.setSize(const Size(320, 640));
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    await qa.step('320 2x ethanol', (s) async {
      await open(Routes.libraryEntry('ethanol'));
    });
    await qa.step('320 2x ethanol Tahlil', (s) async => jump('analysis'));
    await qa.step('320 2x guideline', (s) async {
      await open(Routes.guideline('guideline.chem.ethanol_gc'));
    });
    await qa.step('320 2x search', (s) async {
      goTo(tester, Routes.home);
      await qa.settle();
      await open(Routes.searchWith(lang == 'uz' ? 'etanol qon' : 'ethanol'));
    });
    tester.platformDispatcher.clearTextScaleFactorTestValue();

    qa.restoreErrorHandler();
    qa.writeResults();
    printSummary(qa);
    HttpOverrides.global = null;
  });
}
