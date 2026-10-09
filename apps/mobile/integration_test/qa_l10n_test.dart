// REAL-ILOVA QA — UCH TILLI AUDIT (Phase A, 2026-10-09). Faqat o‘qish:
// ilova yoki kontent o‘zgartirilmaydi.
//
// Egasi ko‘rsatgan nuqsonli ekranlarni tanlangan tilda ochib, skrinshot va
// ekrandagi BARCHA matnlarni (`screen_texts_<rol>.json`) saqlaydi. Matnlar
// keyin `tool/lang_audit.py --screens …` bilan aralash-til detektoridan
// o‘tkaziladi (asl iqtibos/bibliografiya ham ekranda ko‘rinadi — shuning
// uchun natija qo‘lda ko‘rib chiqiladi).
//
// Muhit: QA_LANG=uz|ru|en  QA_OUT=<katalog>
//   QA_MODE=professional|student (standart: professional — EXPERT)
//   QA_WIDTH=390|320 (mantiqiy piksel; standart 390)
//   QA_LANG=ru ./tool/qa_real_app.sh l10n
//
// Phase C (2026-10-09): tarjima birinchi, «Asl matn» ochilishi, huquqiy
// hujjat nomi UI tilida — qo‘shimcha qadamlar oxirida.
import 'dart:convert';
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
  final mode = env['QA_MODE'] ?? 'professional';
  final width = double.tryParse(env['QA_WIDTH'] ?? '') ?? 390;
  final suffix = [
    lang,
    if (mode != 'professional') mode,
    if (width != 390) '${width.toInt()}',
  ].join('-');

  testWidgets('QA real app — L10N AUDIT ($suffix)', (tester) async {
    final net = NoNetworkOverrides();
    HttpOverrides.global = net;
    final qa = await launchRealApp(
      tester,
      role: 'l10n-$suffix',
      prefs: {
        'fe.settings.locale': lang,
        'fe.settings.theme': 'light',
        'fe.settings.mode': mode,
        'fe.settings.disclaimer_version': 1,
      },
      overrides: [
        // Pro — faqat test override (xarid simulyatsiyasi emas): pullik
        // ilmiy yozuvlar ham ko‘rinsin.
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
    if (width != 390) await qa.setSize(Size(width, 844));
    final texts = <String, List<String>>{};

    Future<void> open(String route) async {
      goTo(tester, Routes.home);
      await qa.settle();
      goTo(tester, route);
      await qa.settle(maxMs: 6000);
      await qa.scrollToTop();
    }

    Future<void> shot(String title, Future<void> Function() body) async {
      await qa.step(title, (s) async {
        await body();
        texts[title] = qa.visibleTexts();
      });
    }

    // 1. O‘quv testi: PMR iqtibosi (egasi misoli 1 va «1 tadan 1-savol»).
    await shot('Study quiz forensicToxicology deck', () async {
      await open(Routes.studyQuiz('discipline.mixed'));
    });
    await shot('Study quiz answered', () async {
      final o = find.byKey(const Key('study.quiz.option.0'));
      if (o.evaluate().isEmpty) return;
      await qa.tapFinder(o);
      final check = find.byKey(const Key('study.quiz.check'));
      if (check.evaluate().isNotEmpty) await qa.tapFinder(check);
    });
    await shot('Study cards forensicMedicine deck', () async {
      await open(Routes.studyCards('discipline.forensicMedicine'));
    });
    await shot('Study hub', () async => open(Routes.study));

    // 2. «O‘limdan keyingi o‘zgarishlar» — tadqiqotlar ro‘yxati.
    await shot('FM postmortem changes research list', () async {
      await open(Routes.researchFor('fm-postmortem-changes'));
    });
    await shot('Research list all', () async => open(Routes.research));

    // 3. Ilmiy kartalar (mavzu + yo‘riqnoma).
    await shot('Topic card PMR', () async {
      await open(Routes.knowledgeEntry('tox-postmortem-redistribution'));
    });
    await shot('Topic card PMR scrolled', () async => qa.scrollBy(700));
    await shot('Topic card livor mortis', () async {
      await open(Routes.knowledgeEntry('fm-livor-mortis'));
    });
    await shot('Guideline card CO-COHb', () async {
      await open(Routes.guideline('guideline.chem.co_cohb_determination'));
    });
    await shot('Guideline card CO-COHb sources', () async {
      await qa.scrollBy(20000);
    });

    // 4. «Sudda so‘roq»: O‘zbekiston JPK iqtibosi.
    await shot('Court card rights UZ', () async {
      await open(Routes.courtPrepQuestion('court.q.rights_uz'));
    });
    await shot('Court card rights UZ sources', () async {
      await qa.scrollBy(20000);
    });

    // 5. Reaktiv, skrining, ziddiyat, huquqiy holat, standartlar.
    await shot('Reagent Dragendorff', () async {
      await open(Routes.knowledgeEntry('reagent-dragendorff'));
    });
    await shot('Reagent Dragendorff scrolled', () async => qa.scrollBy(1400));
    await shot('Screening opiates immunoassay', () async {
      await open(Routes.knowledgeEntry('scr-immunoassay-opiates'));
    });
    await shot('Conflict vitreous potassium', () async {
      await open(Routes.conflict('CF-VITREOUS-K-PMI'));
    });
    await shot('Jurisdiction UZ', () async {
      await open(Routes.jurisdiction('UZ'));
    });
    await shot('Morphine legal status', () async {
      await open(Routes.libraryEntry('morphine'));
      final f = find.byKey(const Key('entry.index.legal'));
      if (f.evaluate().isNotEmpty) await qa.tapFinder(f);
    });
    await shot('Standards', () async => open(Routes.libraryStandards));

    // 6. AI (oflayn/mock): savol → javob.
    await shot('AI screen', () async => open(Routes.ai));
    await shot('AI answer PMR', () async {
      final input = find.byKey(const Key('ai.input'));
      if (input.evaluate().isEmpty) return;
      await qa.enterText(input, switch (lang) {
        'ru' => 'Что такое посмертное перераспределение?',
        'en' => 'What is postmortem redistribution?',
        _ => 'O‘limdan keyingi qayta taqsimlanish nima?',
      });
      final send = find.byKey(const Key('ai.send'));
      if (send.evaluate().isNotEmpty) await qa.tapFinder(send);
      await qa.settle(maxMs: 8000);
    });
    await shot('AI answer scrolled', () async => qa.scrollBy(900));

    // 7. Phase C: tarjima birinchi + «Asl matn» ochilishi.
    Finder keyPrefix(String p) => find.byWidgetPredicate(
      (w) =>
          w.key is ValueKey<String> &&
          (w.key! as ValueKey<String>).value.startsWith(p),
    );
    await shot('C Study quiz quote original opened', () async {
      await open(Routes.studyQuiz('discipline.forensicToxicology'));
      final t = keyPrefix('l10n.originalToggle.claim_excerpt.');
      if (t.evaluate().isNotEmpty) await qa.tapFinder(t.first);
    });
    await shot('C Topic card PMR original opened', () async {
      await open(Routes.knowledgeEntry('tox-postmortem-redistribution'));
      final t = keyPrefix('l10n.originalToggle.claim_excerpt.');
      if (t.evaluate().isNotEmpty) {
        await qa.scrollUntil(t.first);
        await qa.tapFinder(t.first);
      }
    });
    await shot('C Morphine context and limitations', () async {
      await open(Routes.libraryEntry('morphine'));
      final f = keyPrefix('claim.context.');
      if (f.evaluate().isNotEmpty) await qa.scrollUntil(f.first);
    });
    await shot('C Conflicts list', () async => open(Routes.conflicts));
    await shot('C Jurisdiction GB legal titles', () async {
      await open(Routes.jurisdiction('GB'));
    });

    File('${qa.outDir.path}/screen_texts_l10n-$suffix.json').writeAsStringSync(
      const JsonEncoder.withIndent(' ').convert({'lang': lang, 'steps': texts}),
    );
    qa.restoreErrorHandler();
    qa.writeResults();
    printSummary(qa);
    HttpOverrides.global = null;
  });
}
