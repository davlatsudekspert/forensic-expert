// REAL-ILOVA QA — «SUDDA SO‘ROQ: TAYYORGARLIK» (2026-10-09).
//
// Haqiqiy ilova (`bootstrap()`), haqiqiy kontent paketi (asset), Linux
// desktop dvigateli. Akkaunt yo‘q (mock), tarmoq — o‘chirilgan; Pro kirish
// faqat test override bilan (xarid simulyatsiyasi emas).
// Ishga tushirish:
//   QA_MODE=professional QA_PRO=1 ./tool/qa_real_app.sh court
//   QA_MODE=student               ./tool/qa_real_app.sh court
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/court_prep.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/l10n/generated/app_localizations.dart';
import 'package:forensic_expert/core/settings/settings_controller.dart';
import 'package:forensic_expert/domain/ports/billing_ports.dart';
import 'package:integration_test/integration_test.dart';

import 'qa/harness.dart';
import 'qa/qa_env.dart';

const _card = 'court.q.qual_competence';

Finder _key(String k) => find.byKey(Key(k));

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final env = Platform.environment;
  final mode = env['QA_MODE'] ?? 'professional';
  final pro = env['QA_PRO'] == '1';
  final student = mode == 'student';

  testWidgets('QA real app — COURT ($mode${pro ? ', Pro' : ''})', (
    tester,
  ) async {
    final net = NoNetworkOverrides();
    HttpOverrides.global = net;
    final l = lookupAppLocalizations(const Locale('uz'));
    final qa = await launchRealApp(
      tester,
      role: 'court',
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
      goTo(tester, Routes.tools);
      await qa.settle();
      goTo(tester, route);
      await qa.settle();
      await qa.scrollToTop();
    }

    Future<void> reveal(Finder f, {double alignment = 0.1}) async {
      await qa.scrollUntil(f);
      if (f.evaluate().isNotEmpty) {
        await Scrollable.ensureVisible(
          tester.element(f.first),
          alignment: alignment,
        );
        await qa.settle();
      }
    }

    void expectKey(String k, QaStep s, {bool present = true}) {
      final found = _key(k).evaluate().isNotEmpty;
      if (found != present) {
        s.passed = false;
        s.notes.add('${present ? 'yo‘q' : 'kutilmagan'}: $k');
      }
    }

    // ------------------------------------------------------------ kirish
    await qa.step('[$mode] Asosiy: «Sudda so‘roq» kirish nuqtasi', (s) async {
      await open(Routes.home);
      if (student) {
        await qa.scrollUntil(_key('home.invite'));
        expectKey('home.courtPrep', s, present: false);
      } else {
        await reveal(_key('home.courtPrep'), alignment: 0.4);
        expectKey('home.courtPrep', s);
      }
    }, shot: pro);

    await qa.step('[$mode] Kutubxona → bo‘lim: tamoyillar, mashq, '
        'simulyator, Pro imkoniyatlari', (s) async {
      await open(Routes.library);
      await qa.scrollUntil(_key('library.hub.court'));
      await qa.tapFinder(_key('library.hub.court'));
      await qa.settle();
      qa.expectText(l.courtDisclaimer, s);
      expectKey('court.principles', s);
      expectKey('court.practice', s);
      expectKey('court.simulator', s);
      expectKey('court.locked', s, present: !pro);
      if (!pro) await reveal(_key('court.locked'), alignment: 0.3);
    });

    // ------------------------------------------------- bepul to‘liq karta
    await qa.step('[$mode] Karta: A savol, holat, B qisqa javob', (s) async {
      await open(Routes.courtPrepQuestion(_card));
      expectKey('court.status', s);
      expectKey('court.tests', s);
      await reveal(_key('court.shortAnswer'), alignment: 0.05);
      expectKey('court.locked', s, present: false);
    }, shot: pro);

    await qa.step('[$mode] Karta: C asos va D «Qaysi manbada yozilgan?»', (
      s,
    ) async {
      await open(Routes.courtPrepQuestion(_card));
      await reveal(_key('court.loc.court_uz_cpc'), alignment: 0.3);
      expectKey('court.loc.court_uz_cpc', s);
      qa.expectText(RegExp('78-modda, 2-qism'), s);
    }, shot: pro);

    await qa.step('[$mode] Karta: E/F qo‘shimcha savol, G cheklov, H eksport', (
      s,
    ) async {
      await open(Routes.courtPrepQuestion(_card));
      await qa.scrollUntil(_key('court.followup.0'));
      await qa.tapFinder(_key('court.followup.0'));
      await qa.settle();
      await qa.scrollUntil(_key('court.limitations'));
      expectKey('court.limitations', s);
      await qa.scrollUntil(_key('court.export.bibtex'));
      await qa.tapFinder(_key('court.export.bibtex'));
      await qa.settle();
      qa.expectText(l.courtExportCopied, s);
    }, shot: false);

    await qa.step('[$mode] «Manba tekshirilmagan» belgisi', (s) async {
      await open(Routes.courtPrepQuestion('court.q.qa_accreditation'));
      await reveal(
        _key('court.unverified.court_iso17025_2017'),
        alignment: 0.3,
      );
      expectKey('court.unverified.court_iso17025_2017', s);
      qa.expectText(l.courtSourceUnverified, s);
    }, shot: pro);

    await qa.step('[$mode] Yurisdiksiya O‘zbekiston: huquq va majburiyatlar '
        '(lex.uz)', (s) async {
      await containerOf(tester)
          .read(settingsControllerProvider.notifier)
          .setJurisdiction('UZ');
      await open(Routes.courtPrepTopic('court.topic.rights'));
      expectKey('court.q.court.q.rights_uz', s);
      expectKey('court.q.court.q.rights_intl', s, present: false);
      await open(Routes.courtPrepQuestion('court.q.rights_uz'));
      await reveal(_key('court.loc.court_uz_expertise_law'), alignment: 0.3);
      qa.expectText(RegExp('lex.uz'), s);
      await containerOf(tester)
          .read(settingsControllerProvider.notifier)
          .setJurisdiction('INT');
    }, shot: pro);

    // -------------------------------------------------------- simulyator
    await qa.step('[$mode] Simulyator: asosiy ssenariy, baho 4 mezon', (
      s,
    ) async {
      await open(Routes.courtPrepScenario('court.sim.colour_test'));
      expectKey('court.sim.prompt', s);
      await qa.scrollUntil(_key('court.sim.option.1'));
      await qa.tapFinder(_key('court.sim.option.1'));
      await qa.scrollUntil(_key('court.sim.check'));
      await qa.tapFinder(_key('court.sim.check'));
      await qa.settle();
      await reveal(_key('court.sim.result'), alignment: 0.05);
      qa.expectText(l.courtSimTotal(8, 8), s);
      qa.expectText(l.courtSimReviewNote, s);
    }, shot: pro);

    await qa.step(
      '[$mode] AI tahlili: ${pro ? 'halol «tez orada»' : 'Pro → '
                'tariflar'}',
      (s) async {
        await open(Routes.courtPrepScenario('court.sim.colour_test'));
        await qa.scrollUntil(_key('court.sim.ai'));
        await qa.tapFinder(_key('court.sim.ai'));
        await qa.settle();
        expectKey(pro ? 'court.sim.aiUnavailable' : 'paywall.list', s);
      },
      shot: false,
    );

    await qa.step(
      '[$mode] Rol mashqi: ${pro ? 'ketma-ket 4 rol' : 'Pro → '
                'tariflar'}',
      (s) async {
        await open(Routes.courtPrep);
        await qa.scrollUntil(_key('court.drill'));
        await qa.tapFinder(_key('court.drill'));
        await qa.settle();
        if (!pro) {
          expectKey('paywall.list', s);
          return;
        }
        for (var i = 0; i < 4; i++) {
          await qa.scrollUntil(_key('court.sim.option.1'));
          await qa.tapFinder(_key('court.sim.option.1'));
          await qa.scrollUntil(_key('court.sim.check'));
          await qa.tapFinder(_key('court.sim.check'));
          await qa.settle();
          await qa.scrollUntil(_key('court.sim.next'));
          await qa.tapFinder(_key('court.sim.next'));
          await qa.settle();
        }
        expectKey('court.drill.done', s);
      },
      shot: false,
    );

    await qa.step('[$mode] Statistika va tarix (faqat qurilmada)', (s) async {
      await open(Routes.courtPrepStats);
      if (pro) {
        final n = containerOf(tester).read(courtHistoryProvider).length;
        if (n < 5) {
          s.passed = false;
          s.notes.add('tarixda $n ta urinish (kutilgan ≥5)');
        }
        expectKey('court.stats.average', s);
      } else {
        expectKey('court.locked', s);
      }
    }, shot: pro);

    await qa.step('[$mode] Qidiruv: «LOQ» va bo‘sh natija', (s) async {
      await open(Routes.courtPrep);
      await qa.enterText(_key('court.search'), 'LOQ');
      expectKey('court.q.court.q.method_lod', s);
      await qa.enterText(_key('court.search'), 'zzqqxx');
      expectKey('court.noResults', s);
    }, shot: false);

    await qa.setSize(const Size(320, 640));
    await qa.step('[$mode] 320 dp: karta va manbalar', (s) async {
      await open(Routes.courtPrepQuestion(_card));
      expectKey('court.tests', s);
      await reveal(_key('court.sources'), alignment: 0.05);
    }, shot: pro);
    await qa.step('[$mode] 320 dp: simulyator', (s) async {
      await open(Routes.courtPrepScenario('court.sim.redistribution'));
      expectKey(pro ? 'court.sim.prompt' : 'court.locked', s);
    }, shot: false);
    await qa.setSize(const Size(390, 844));

    await qa.step('Tarmoq o‘chiq (barcha HTTP bloklangan)', (s) async {
      s.notes.add('Bloklangan HTTP urinishlari: ${net.attempts}');
    }, shot: false);

    qa.restoreErrorHandler();
    qa.writeResults();
    printSummary(qa);
    HttpOverrides.global = null;
  });
}
