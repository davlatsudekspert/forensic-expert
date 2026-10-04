import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/domain/knowledge/knowledge_models.dart';

import '../helpers/fake_store.dart';
import '../helpers/pilot_content.dart';
import '../helpers/pump_app.dart';

/// PHASE 8: ko‘p tarmoqli professional kengaytma.
void main() {
  late PilotContent pilot;
  setUpAll(() async => pilot = await loadPilotContent());

  Future<ProviderContainer> open(WidgetTester tester, String location) =>
      pumpApp(
        tester,
        settings: completedSettings(),
        initialLocation: location,
        testFixtures: false,
        overrides: [
          ...pilot.overrides,
          entitlementServiceProvider.overrideWithValue(FakeStore(owned: true)),
        ],
      );

  Future<void> see(WidgetTester tester, Finder f) async {
    await tester.dragUntilVisible(
      f.first,
      find.byType(Scrollable).first,
      const Offset(0, -250),
    );
    await tester.pumpAndSettle();
    expect(f, findsWidgets);
  }

  test('yangi fanlar: har birida manbali mavzu, hammasi NEEDS_REVIEW', () {
    final topics = pilot.knowledge.byKind(KnowledgeKind.topic);
    final byDisc = {
      for (final d in [
        ForensicDiscipline.forensicGenetics,
        ForensicDiscipline.forensicEntomology,
        ForensicDiscipline.forensicMicrobiology,
        ForensicDiscipline.forensicRadiology,
      ])
        d: [
          for (final t in topics)
            if (t.effectiveDiscipline == d) t,
        ],
    };
    for (final e in byDisc.entries) {
      expect(e.value, isNotEmpty, reason: e.key.code);
      for (final t in e.value) {
        expect(t.claims, isNotEmpty, reason: t.id);
        for (final c in t.claims) {
          expect(c.status, ScientificStatus.needsReview);
          expect(c.sources, isNotEmpty);
        }
      }
    }
  });

  test(
    'metodlar: barchasi «ta’limiy umumlashma» (validatsiya da’vosi yo‘q)',
    () {
      for (final m in pilot.knowledge.byKind(KnowledgeKind.method)) {
        expect(
          m.method!.effectiveEvidenceType,
          MethodEvidenceType.educationalSummary,
          reason: m.id,
        );
      }
    },
  );

  test('reagentlar: manbasiz retsept yo‘q', () {
    for (final r in pilot.knowledge.byKind(KnowledgeKind.reagent)) {
      final rec = r.recipe!;
      if (rec.hasPreparationData) expect(rec.sourceIds, isNotEmpty);
    }
  });

  testWidgets('genetika fani sahifasi: manbali mavzu → claim', (tester) async {
    await open(tester, Routes.discipline('forensic_genetics'));
    await see(
      tester,
      find.byKey(const Key('discipline.topic.gen-str-profiling')),
    );
    await tester.tap(
      find.byKey(const Key('discipline.topic.gen-str-profiling')),
    );
    await tester.pumpAndSettle();
    await see(
      tester,
      find.byKey(const Key('claim.C-GEN-STR-PROFILING-PRINCIPLE-P8')),
    );
  });

  testWidgets('metod sahifasi: dalil turi belgisi', (tester) async {
    await open(tester, Routes.knowledgeEntry('method-lcmsms'));
    await see(tester, find.byKey(const Key('method.evidenceType')));
    expect(find.text('Educational summary'), findsWidgets);
  });

  testWidgets('reagent: retsept yo‘q — to‘qilmaydi', (tester) async {
    await open(tester, Routes.knowledgeEntry('reagent-marquis'));
    await see(tester, find.byKey(const Key('reagent.noRecipe')));
  });
}
