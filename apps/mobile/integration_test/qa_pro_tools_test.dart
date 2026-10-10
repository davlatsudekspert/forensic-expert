// REAL-ILOVA QA — PRO VOSITALAR (kengaytirilgan qidiruv, tahlil rejasi).
//
// Haqiqiy ilova (`bootstrap()`), haqiqiy imzolangan pilot kontent paketi,
// Linux desktop dvigateli. Akkaunt — MOCK, tarmoq — o‘chirilgan.
//
// Muhit:
//   QA_LANG=uz|ru|en   QA_MODE=student|professional   QA_PRO=1   QA_OUT=<dir>
//   QA_THEME=light|dark
//
//   # STUDENT (bepul):
//   QA_OUT=docs/qa/pro_tools_20261010/uz_student ./tool/qa_real_app.sh pro_tools
//   # EXPERT (Pro test override):
//   QA_MODE=professional QA_PRO=1 QA_OUT=docs/qa/pro_tools_20261010/uz_expert \
//     ./tool/qa_real_app.sh pro_tools
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final theme = env['QA_THEME'] ?? 'light';
  final pro = env['QA_PRO'] == '1';

  String tr(String uz, String ru, String en) => switch (lang) {
    'ru' => ru,
    'en' => en,
    _ => uz,
  };

  testWidgets('QA real app — PRO TOOLS ($lang-$mode${pro ? '-pro' : ''})', (
    tester,
  ) async {
    final net = NoNetworkOverrides();
    HttpOverrides.global = net;
    final qa = await launchRealApp(
      tester,
      // qa_real_app.sh `results_pro_tools.json` ni kutadi.
      role: 'pro_tools',
      prefs: {
        'fe.settings.locale': lang,
        'fe.settings.theme': theme,
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

    void expectKey(String k, QaStep s, {bool present = true}) {
      final found = find.byKey(Key(k)).evaluate().isNotEmpty;
      if (found != present) {
        s.passed = false;
        s.notes.add(present ? 'KALIT YO‘Q: $k' : 'KUTILMAGAN KALIT: $k');
      }
    }

    Future<void> tapKey(String k) async {
      final f = find.byKey(Key(k));
      await qa.scrollUntil(f);
      await qa.tapFinder(f);
    }

    // ------------------------------------------------ oddiy qidiruv (o‘zgarmagan)
    await qa.step('Oddiy qidiruv morfin + Pro kirish', (s) async {
      await open(Routes.searchWith(tr('morfin', 'морфин', 'morphine')));
      await qa.settle(maxMs: 3000);
      if (find.byKey(const Key('search.hit.morphine')).evaluate().isEmpty) {
        // Birinchi yuklanishda indeks hali bo‘sh bo‘lishi mumkin: qayta yozish.
        await qa.enterText(
          find.byKey(const Key('search.field')),
          tr('morfin', 'морфин', 'morphine'),
        );
        s.notes.add('NOTE: initialQuery natijasi bo‘sh edi, qayta yozilgach topildi');
      }
      expectKey('search.hit.morphine', s);
      expectKey('search.pro.entry', s);
    });

    if (!pro) {
      // ============================================================ STUDENT
      await qa.step('Pro qidiruv: bepul ko‘rinish', (s) async {
        await open(Routes.proSearchWith('morfin'));
        expectKey('pro.preview', s);
        expectKey('pro.unlock', s);
        expectKey('pro.field', s, present: false);
        qa.expectText(
          tr('Kengaytirilgan qidiruv', 'Расширенный поиск', 'Advanced search'),
          s,
        );
      });
      await qa.step('Tahlil rejasi kirishi (etanol, bepul yozuv)', (s) async {
        await open(Routes.libraryEntry('ethanol'));
        await scrollTo(const Key('analysis.plan.entry.ethanol'));
        expectKey('analysis.plan.entry.ethanol', s);
      });
      await qa.step('Tahlil rejasi: qisqa ko‘rinish + tarif', (s) async {
        await tapKey('analysis.plan.entry.ethanol');
        expectKey('plan.preview', s);
        expectKey('plan.summary', s);
        expectKey('plan.unlock', s);
        expectKey('plan.block.presumptive', s, present: false);
        expectKey('plan.copy', s, present: false);
      });
      await qa.step('Tahlil rejasi: tarif tugmasi tariflarga olib boradi', (
        s,
      ) async {
        await tapKey('plan.unlock');
        qa.expectText(
          tr('Tariflar', 'Тарифы', 'Plans'),
          s,
          why: 'tariflar sahifasi',
        );
      });
      await qa.setSize(const Size(320, 640));
      await qa.step('320 dp: tahlil rejasi (bepul)', (s) async {
        await open(Routes.homePlan('ethanol'));
        expectKey('plan.unlock', s);
      });
      await qa.step('320 dp: Pro qidiruv (bepul)', (s) async {
        await open(Routes.proSearch);
        expectKey('pro.unlock', s);
      });
    } else {
      // ============================================================= EXPERT
      await qa.step('Pro qidiruv: boshlang‘ich', (s) async {
        await open(Routes.proSearch);
        expectKey('pro.field', s);
        expectKey('pro.unlock', s, present: false);
        expectKey('pro.start', s);
      });
      await qa.step('Pro qidiruv: morfin (uch tilda)', (s) async {
        await qa.enterText(
          find.byKey(const Key('pro.field')),
          tr('morfin', 'морфин', 'morphine'),
        );
        expectKey('pro.hit.morphine', s);
      });
      await qa.step('Faset: namuna Qon', (s) async {
        await qa.enterText(find.byKey(const Key('pro.field')), '');
        await tapKey('pro.facet.specimen');
        await tapKey('pro.facet.specimen.blood');
        expectKey('pro.hit.morphine', s);
        expectKey('pro.count', s);
      });
      await qa.step('Faset: metod oilasi LC-MS', (s) async {
        await tapKey('pro.facet.family');
        await tapKey('pro.facet.family.lcMs');
        expectKey('pro.hit.morphine', s);
      });
      await qa.step('Faset: sinf Opioidlar + dalil darajasi', (s) async {
        await tapKey('pro.facet.substanceClass');
        await tapKey('pro.facet.substanceClass.opioids');
        expectKey('pro.hit.morphine', s);
      });
      await qa.step('Faset birikmasi + noto‘g‘ri matn: bo‘sh natija', (
        s,
      ) async {
        await qa.enterText(find.byKey(const Key('pro.field')), 'zzzzqq');
        expectKey('pro.noResults', s);
      });
      await qa.step('Aniq moslik va ibora', (s) async {
        await tapKey('pro.exact');
        await qa.enterText(
          find.byKey(const Key('pro.field')),
          tr('"morfin"', '"морфин"', '"morphine"'),
        );
        expectKey('pro.hit.morphine', s);
      });
      await qa.step('Teskari qidiruv: namuna → analitlar', (s) async {
        await open(Routes.proSearch);
        await tapKey('pro.tab.reverse');
        await tapKey('pro.reverse.target.blood');
        expectKey('pro.reverse.hit.morphine', s);
      });
      await qa.step('Teskari qidiruv: metod → moddalar', (s) async {
        await tapKey('pro.reverse.mode.method');
        await tapKey('pro.reverse.target.method-lcmsms');
        expectKey('pro.reverse.hit.morphine', s);
      });
      await qa.step('Teskari qidiruv: reagent → moddalar (halol holat)', (
        s,
      ) async {
        await tapKey('pro.reverse.mode.reagent');
        // Paketda reagent–modda bog‘lanishi bo‘lmasa — izoh; bo‘lsa — ro‘yxat.
        final none = find.byKey(const Key('pro.reverse.none')).evaluate();
        if (none.isEmpty && find.byType(ChoiceChip).evaluate().length < 4) {
          s.passed = false;
          s.notes.add('reagent rejimi bo‘sh va izohsiz');
        }
      });
      await qa.step('Tahlil rejasi: kokain (boshi)', (s) async {
        await open(Routes.homePlan('cocaine'));
        for (final k in [
          'specimens',
          'presumptive',
          'confirmation',
          'interferences',
          'limits',
          'reminder',
        ]) {
          expectKey('plan.block.$k', s);
        }
        expectKey('plan.copy', s);
        expectKey('plan.unlock', s, present: false);
      });
      await qa.step('Tahlil rejasi: kokain — taxminiy testlar', (s) async {
        await scrollTo(const Key('plan.block.presumptive'));
        expectKey('plan.noReagents', s);
      });
      await qa.step('Tahlil rejasi: kokain — tasdiqlash', (s) async {
        await scrollTo(const Key('plan.confirm.method-gcms'));
        expectKey('plan.confirm.method-gcms', s);
        expectKey('plan.confirm.method-lcmsms', s);
        qa.expectText(
          tr(
            'Tasdiqlash shart',
            'Требуется подтверждение',
            'Confirmation required',
          ),
          s,
        );
      });
      await qa.step('Tahlil rejasi: kokain — halaqitlar', (s) async {
        await scrollTo(const Key('plan.interferences'));
        expectKey('plan.interferences', s);
      });
      await qa.step('Tahlil rejasi: kokain — talqin chegaralari', (s) async {
        await scrollTo(const Key('plan.limits'));
        expectKey('plan.limits', s);
      });
      await qa.step('Tahlil rejasi: kokain — xulosa uchun eslatma', (s) async {
        await scrollTo(const Key('plan.footnote'));
        expectKey('plan.reminder.presumptiveOnly', s);
        expectKey('plan.reminder.confirmationDocumented', s);
        expectKey('plan.reminder.nothingVerified', s);
      });
      await qa.step('Nusxalash: iqtiboslar bilan', (s) async {
        await qa.scrollToTop();
        await Clipboard.setData(const ClipboardData(text: ''));
        await tapKey('plan.copy');
        final data = await Clipboard.getData(Clipboard.kTextPlain);
        final text = data?.text ?? '';
        if (!text.contains('[1') || !text.contains('DOI: 10.')) {
          s.passed = false;
          s.notes.add('nusxada iqtibos/manba ro‘yxati yo‘q (${text.length})');
        }
        qa.expectText(
          tr(
            'Reja to‘liq iqtiboslari bilan nusxalandi',
            'План скопирован с полными ссылками',
            'Plan copied with full citations',
          ),
          s,
        );
      });
      await qa.step('Tahlil rejasi: manba tugmasi (provenance)', (s) async {
        await scrollTo(const Key('plan.block.specimens'));
        final src = find.byWidgetPredicate(
          (w) =>
              w.key is ValueKey<String> &&
              (w.key! as ValueKey<String>).value.startsWith('plan.source.'),
        );
        await qa.tapFinder(src);
      });
      await qa.back();
      await qa.step(
        'Tahlil rejasi: morfin (skrining yo‘q, metod bog‘lanmagan)',
        (s) async {
          await open(Routes.homePlan('morphine'));
          expectKey('plan.empty.presumptive', s);
          await scrollTo(const Key('plan.notPaired'));
          expectKey('plan.notPaired', s);
        },
      );
      await qa.step('Tahlil rejasi: GHB (ma’lumot yo‘q)', (s) async {
        await open(Routes.homePlan('ghb'));
        expectKey('plan.noData', s);
      });
      await qa.step('Modda sahifasidan reja ochiladi (etanol)', (s) async {
        await open(Routes.libraryEntry('ethanol'));
        await tapKey('analysis.plan.entry.ethanol');
        expectKey('plan.block.reminder', s);
      });
      await qa.setSize(const Size(320, 640));
      await qa.step('320 dp: tahlil rejasi fentanil', (s) async {
        await open(Routes.homePlan('fentanyl'));
        await scrollTo(const Key('plan.block.limits'));
      });
      await qa.step('320 dp: Pro qidiruv filtrlar', (s) async {
        await open(Routes.proSearch);
        await tapKey('pro.facet.family');
      });
    }

    qa.restoreErrorHandler();
    qa.writeResults();
    printSummary(qa);
    HttpOverrides.global = null;
  });
}
