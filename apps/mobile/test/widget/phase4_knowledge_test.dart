import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/widgets/common.dart';
import 'package:forensic_expert/domain/knowledge/knowledge_models.dart';

import '../helpers/fake_store.dart';
import '../helpers/pilot_content.dart';
import '../helpers/pump_app.dart';

/// PHASE 4 bilim sohalari — HAQIQIY pilot paket bilan.
void main() {
  late PilotContent pilot;
  setUpAll(() async => pilot = await loadPilotContent());

  Future<void> open(
    WidgetTester tester,
    String location, {
    bool owned = false,
    String jurisdiction = 'INT',
  }) => pumpApp(
    tester,
    settings: completedSettings().copyWith(jurisdictionId: jurisdiction),
    initialLocation: location,
    testFixtures: false,
    overrides: [
      ...pilot.overrides,
      entitlementServiceProvider.overrideWithValue(FakeStore(owned: owned)),
    ],
  );

  Future<void> see(WidgetTester tester, Finder f) async {
    await tester.dragUntilVisible(
      f,
      find.byType(ListView).first,
      const Offset(0, -250),
    );
    await tester.pumpAndSettle();
    expect(f, findsWidgets);
  }

  test('pilot: barcha bilim yozuvlari NEEDS_REVIEW, TEST DATA yo‘q', () {
    for (final kind in KnowledgeKind.values) {
      for (final e in pilot.knowledge.byKind(kind)) {
        expect(e.status, ScientificStatus.needsReview, reason: e.id);
        expect(e.isTestData, isFalse, reason: e.id);
        expect(e.allSources, isNotEmpty, reason: e.id);
      }
    }
  });

  testWidgets('Marquis: retsept taxmin qilinmagan, manbalar ochiq', (
    tester,
  ) async {
    await open(tester, Routes.knowledgeEntry('reagent-marquis'));
    expect(find.byType(UnverifiedBanner), findsWidgets);
    await see(tester, find.byKey(const Key('reagent.noRecipe')));
    expect(find.byKey(const Key('reagent.ingredients')), findsNothing);
    await see(tester, find.byKey(const Key('source.SRC-PMC11961553')));
  });

  testWidgets('skrining: «skrining ≠ tasdiqlash» va tasdiqlovchi metod', (
    tester,
  ) async {
    await open(tester, Routes.knowledgeEntry('scr-immunoassay-drugs'));
    expect(find.byKey(const Key('screening.banner')), findsOneWidget);
    await see(tester, find.byKey(const Key('screening.confirm.method-gcms')));
    // Manbasiz cut-off ko‘rsatilmaydi — «manbada ko‘rsatilmagan».
    expect(
      find.text('Not stated in the sources — not estimated'),
      findsWidgets,
    );
  });

  testWidgets('Lifetime yozuvda ham cheklovlar va manbalar ochiq', (
    tester,
  ) async {
    await open(tester, Routes.knowledgeEntry('fm-postmortem-interval'));
    await see(tester, find.byKey(const Key('knowledge.locked')));
    await see(
      tester,
      find.byKey(const Key('claim.C-FM-POSTMORTEM-INTERVAL-LIMITATION')),
    );
    await see(tester, find.byKey(const Key('source.SRC-PMC10861637')));
  });

  testWidgets('metodlar 4 turga ajratilgan, bo‘sh turlar halol', (
    tester,
  ) async {
    await open(tester, Routes.knowledge(KnowledgeKind.method.name));
    expect(find.byKey(const Key('methods.kindNote')), findsOneWidget);
    expect(find.byKey(const Key('knowledge.method-gcms')), findsOneWidget);
    await see(tester, find.byKey(const Key('methods.empty.institutionalSop')));
  });

  testWidgets(
    'sud tibbiyoti: 25 mavzudan 19 tasi manbali (PHASE 7: rigor mortis; PHASE 8: PMCT), manbasizlari «ma’lumot yo‘q»',
    (tester) async {
      await open(tester, Routes.forensicMedicine);
      expect(find.text('19 of 25 topics have sourced content'), findsOneWidget);
      // Rigor mortis endi manbali (PHASE 7) — manbasiz qator yo‘q.
      expect(find.byKey(const Key('fm.topic.rigorMortis')), findsNothing);
      await see(tester, find.byKey(const Key('fm.topic.sharpForceInjury')));
    },
  );

  testWidgets(
    'solishtirish: Shotlandiya 50 mg, Sh. Irlandiya — ma’lumot yo‘q',
    (tester) async {
      await open(tester, Routes.compare);
      expect(find.byKey(const Key('compare.notAdvice')), findsOneWidget);
      await see(tester, find.byKey(const Key('compare.cell.GB-ENG')));
      await see(
        tester,
        find.byKey(const Key('legal.R-GB-SCT-ETHANOL-DRINK-DRIVE-LIMIT')),
      );
      await see(
        tester,
        find.byKey(
          const Key('legal.R-GB-SCT-ETHANOL-DRINK-DRIVE-LIMIT.overrides'),
        ),
      );
      await see(tester, find.byKey(const Key('compare.noData.GB-NIR')));
    },
  );

  testWidgets('etanol, GB-SCT tanlangan: SSI qoidasi, GB qoidasi o‘rniga', (
    tester,
  ) async {
    await open(
      tester,
      Routes.libraryEntry('ethanol'),
      owned: true,
      jurisdiction: 'GB-SCT',
    );
    await see(
      tester,
      find.byKey(const Key('legal.R-GB-SCT-ETHANOL-DRINK-DRIVE-LIMIT.blood')),
    );
    expect(
      find.byKey(const Key('legal.R-GB-ETHANOL-DRINK-DRIVE-LIMIT')),
      findsNothing,
    );
    expect(find.byKey(const Key('legal.noNational')), findsNothing);
  });

  testWidgets('Home: oflayn baza kartochkasi va yangi bo‘limlar', (
    tester,
  ) async {
    await open(tester, Routes.home);
    expect(find.byKey(const Key('home.database')), findsOneWidget);
    await see(tester, find.byKey(const Key('home.module.screening')));
    await tester.tap(find.byKey(const Key('home.module.screening')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('screening.banner')), findsOneWidget);
  });

  testWidgets('AI: lokal manbalar (AI javobi emas) va xulosa bloki', (
    tester,
  ) async {
    await open(tester, Routes.ai);
    Future<void> ask(String q) async {
      await tester.enterText(find.byKey(const Key('ai.input')), q);
      await tester.ensureVisible(find.byKey(const Key('ai.findSources')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('ai.findSources')));
      await tester.pumpAndSettle();
    }

    await ask('livor mortis');
    expect(find.byKey(const Key('ai.result.retrievalOnly')), findsOneWidget);
    expect(
      find.byKey(const Key('ai.chunk.C-FM-LIVOR-MORTIS-DEFINITION')),
      findsOneWidget,
    );
    await ask('determine the cause of death');
    expect(
      find.byKey(const Key('ai.blocked.finalCauseOrManner')),
      findsOneWidget,
    );
  });

  testWidgets('Student: real manbali kurs, imtihon savollari to‘qilmagan', (
    tester,
  ) async {
    await open(tester, Routes.learn);
    expect(find.byKey(const Key('learn.course.course.postmortem')), findsOne);
    expect(find.byKey(const Key('learn.progress')), findsOneWidget);
    await open(tester, Routes.exam);
    expect(find.byKey(const Key('exam.empty')), findsOneWidget);
  });

  testWidgets('TEST fixture: to‘liq retsept holati (TEST DATA belgisi bilan)', (
    tester,
  ) async {
    await pumpApp(
      tester,
      settings: completedSettings(),
      initialLocation: Routes.knowledgeEntry('TEST-REAGENT-1'),
    );
    expect(find.text('SAMPLE'), findsWidgets);
    await see(tester, find.byKey(const Key('reagent.ingredients')));
    expect(find.byKey(const Key('reagent.noRecipe')), findsNothing);
    expect(find.byKey(const Key('reagent.orderNotStated')), findsNothing);
  });

  testWidgets('eritma kalkulyatori: molyar massasiz — xato, taxmin yo‘q', (
    tester,
  ) async {
    await pumpApp(
      tester,
      settings: completedSettings(),
      initialLocation: Routes.tool('tool.lab.solution'),
      overrides: [
        entitlementServiceProvider.overrideWithValue(FakeStore(owned: true)),
      ],
    );
    await tester.enterText(
      find.descendant(
        of: find.byKey(const Key('calc.solution.conc')),
        matching: find.byType(TextField),
      ),
      '0.1',
    );
    await tester.enterText(
      find.descendant(
        of: find.byKey(const Key('calc.solution.vol')),
        matching: find.byType(TextField),
      ),
      '100',
    );
    await tester.ensureVisible(find.byKey(const Key('calc.calculate')));
    await tester.tap(find.byKey(const Key('calc.calculate')));
    await tester.pumpAndSettle();
    // 0.1 g/L × 0.1 L = 0.01 g = 10 mg (ta’rifiy hisob).
    expect(find.text('10.0 mg'), findsOneWidget);
  });
}
