// REAL-ILOVA QA — REAKTIV RETSEPTLARI (ilova egasi to‘plami, 2026-10-09).
//
// Haqiqiy ilova (`bootstrap()`), haqiqiy imzolangan pilot kontent paketi,
// Linux desktop dvigateli. Akkaunt — MOCK, tarmoq — o‘chirilgan.
//
// Muhit:
//   QA_LANG=uz|ru|en   QA_MODE=student|professional   QA_PRO=1   QA_OUT=<dir>
//
//   ./tool/qa_real_app.sh reagents
//   QA_MODE=professional QA_PRO=1 ./tool/qa_real_app.sh reagents
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

  testWidgets('QA real app — REAGENTS ($lang-$mode${pro ? '-pro' : ''})', (
    tester,
  ) async {
    final net = NoNetworkOverrides();
    HttpOverrides.global = net;
    final qa = await launchRealApp(
      tester,
      // qa_real_app.sh `results_reagents.json` ni kutadi.
      role: 'reagents',
      prefs: {
        'fe.settings.locale': lang,
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
    qa.lang = lang;

    Future<void> open(String route) async {
      goTo(tester, route);
      await qa.settle(maxMs: 6000);
      await qa.scrollToTop();
    }

    Future<void> scrollTo(Key key) async {
      final f = find.byKey(key);
      await qa.scrollUntil(f);
      if (f.evaluate().isNotEmpty) {
        await tester.ensureVisible(f.first);
        await qa.settle();
      }
    }

    // ------------------------------------------------ qidiruv sinonimlari
    await qa.step('Search Dragendorf', (s) async {
      goTo(tester, Routes.home);
      await qa.settle();
      await open(Routes.searchWith('Dragendorf'));
      qa.expectText(switch (lang) {
        'ru' => 'Реактив Драгендорфа',
        'en' => 'Dragendorff reagent',
        _ => 'Dragendorf reaktivi',
      }, s);
    });
    await qa.step('Search Марки', (s) async {
      goTo(tester, Routes.home);
      await qa.settle();
      await open(Routes.searchWith('Марки'));
      qa.expectText(switch (lang) {
        'ru' => 'Реактив Марки',
        'en' => 'Marquis reagent',
        _ => 'Marki reaktivi',
      }, s);
    });

    // ---------------------------------------- 1) Dragendorf (bepul demo)
    await qa.step('Dragendorf top hazards', (s) async {
      await open(Routes.knowledgeEntry('reagent-dragendorff'));
      if (find.byKey(const Key('reagent.hazardBanner')).evaluate().isEmpty) {
        s.passed = false;
        s.notes.add('xavf banneri yo‘q');
      }
      qa.expectText('PubChem CID', s);
    });
    await qa.step('Dragendorf ingredients', (s) async {
      await scrollTo(const Key('reagent.ingredients.own'));
      qa.expectText(
        lang == 'en' ? '27.2 g' : (lang == 'ru' ? '27,2 г' : '27,2 g'),
        s,
      );
    });
    await qa.step('Dragendorf original text', (s) async {
      await scrollTo(const Key('reagent.originalText'));
      await tester.tap(
        find.byKey(const Key('reagent.originalText.tile')),
        warnIfMissed: false,
      );
      await qa.settle();
      await scrollTo(const Key('reagent.originalText.body'));
      qa.expectText('Реактив Драгендорфа', s);
    });

    // ------------------------------------------------ 2) Marki (bepul)
    await qa.step('Marki top', (s) async {
      await open(Routes.knowledgeEntry('reagent-marquis'));
      qa.expectText('PubChem CID', s);
    });
    await qa.step('Marki recipe', (s) async {
      await scrollTo(const Key('reagent.ingredients'));
    });

    // ------- 3) Nessler — egasi qarori: barcha retseptlar bepul (pro=$pro)
    await qa.step('Nessler top', (s) async {
      await open(Routes.knowledgeEntry('reagent-nessler'));
      qa.expectText('PubChem CID', s);
      if (find.byKey(const Key('knowledge.locked')).evaluate().isNotEmpty) {
        s.passed = false;
        s.notes.add('Retsept yopiq — bepul bo‘lishi kerak edi (pro=$pro)');
      }
    });
    await qa.step('Nessler recipe (bepul)', (s) async {
      await scrollTo(const Key('reagent.ingredients'));
    });

    // --------------------------------------------- kichik ekran (320 dp)
    await qa.setSize(const Size(320, 640));
    await qa.step('320 Dragendorf ingredients', (s) async {
      await open(Routes.knowledgeEntry('reagent-dragendorff'));
      await scrollTo(const Key('reagent.ingredients.own'));
    });

    qa.restoreErrorHandler();
    qa.writeResults();
    printSummary(qa);
    HttpOverrides.global = null;
  });
}
