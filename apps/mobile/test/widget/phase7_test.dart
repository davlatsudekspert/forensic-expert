import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/app/search_service.dart';
import 'package:forensic_expert/data/fixtures/test_fixtures.dart';
import 'package:forensic_expert/domain/evidence/evidence_models.dart';

import '../helpers/fake_store.dart';
import '../helpers/pilot_content.dart';
import '../helpers/pump_app.dart';

/// PHASE 7: tasdiqlanadigan kontent pipeline’i — provenance, hayot sikli,
/// ziddiyatlar, namunalar, standartlar, bilim zanjiri, review holati.
void main() {
  late PilotContent pilot;
  setUpAll(() async => pilot = await loadPilotContent());

  Future<ProviderContainer> open(
    WidgetTester tester,
    String location, {
    String lang = 'en',
  }) => pumpApp(
    tester,
    settings: completedSettings(lang: lang),
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

  group('kontent qoidalari (pilot paket)', () {
    test('HUMAN VERIFIED = 0: reviewer va reviewer harakati yo‘q', () {
      final r = pilot.provenance.review;
      expect(r.humanVerified, 0);
      expect(r.reviewed, 0);
      expect(r.reviewActions, 0);
      expect(r.reviewers, 0);
      expect(r.total, greaterThan(400));
    });

    test('retraksiya: bog‘liq claim RETRACTED, boshqalar joriy emas', () {
      final retracted = pilot.provenance.notCurrentBySource;
      expect(retracted.map((c) => c.claimId), ['C-FM-ALGOR-MORTIS-DEFINITION']);
      final src = retracted.single.sources.single;
      expect(src.lifecycle, SourceLifecycle.retracted);
      expect(src.lifecycleBasis, contains('39575351'));
      // Hech bir claim CURRENT emas (review yo‘q).
      expect(
        pilot.provenance.claimsById.values.where(
          (c) => c.lifecycle == ClaimLifecycle.current,
        ),
        isEmpty,
      );
    });

    test(
      'har bir konsentratsiya claim’ida qat’iy kontekst; pilot — qo‘lda',
      () {
        final conc = [
          for (final c in pilot.provenance.claimsById.values)
            if (c.field == 'reported_concentration') c,
        ];
        expect(conc, isNotEmpty);
        for (final c in conc) {
          final ctx = c.strictContext!;
          for (final k in StrictConcentrationContext.requiredKeys) {
            expect(ctx.containsKey(k), isTrue, reason: '${c.claimId}.$k');
          }
        }
        final morphine = pilot
            .provenance
            .claimsById['C-MORPHINE-REPORTED_CONCENTRATION-P5']!
            .strictContext!;
        expect(morphine['curation'], 'pilot_manual');
        expect(morphine['sampling'], 'postmortem');
        // Iqtibosda yo‘q maydon to‘qilmagan.
        expect(morphine['study_size'], StrictConcentrationContext.notStated);
      },
    );

    test('metabolit roli faqat iqtibosda aytilganda', () {
      final index = pilot.provenance;
      for (final m in index.metabolites) {
        final basis = index.claimsById[m.basisClaimId];
        expect(basis, isNotNull, reason: m.id);
        if (m.kind != MetaboliteRelationKind.metabolite) {
          expect(
            (basis!.excerpt ?? '').toLowerCase(),
            contains(switch (m.kind) {
              MetaboliteRelationKind.activeMetabolite => 'active',
              MetaboliteRelationKind.inactiveMetabolite => 'inactive',
              MetaboliteRelationKind.marker => 'marker',
              _ => 'artifact',
            }),
            reason: m.id,
          );
        }
      }
    });

    test('PHASE 7 graf qirralari kuzatiladigan asosga ega', () {
      final index = pilot.provenance;
      final ruleIds = {for (final r in pilot.legal.rules) r.id};
      final standardIds = {for (final s in index.standards) s.id};
      final relationIds = {for (final m in index.metabolites) m.id};
      final p7 = [
        for (final l in pilot.evidence.links)
          if (l.relation.requiresTraceableBasis) l,
      ];
      expect(p7, isNotEmpty);
      for (final GraphLink l in p7) {
        expect(
          index.claimsById.containsKey(l.basis) ||
              ruleIds.contains(l.basis) ||
              standardIds.contains(l.basis) ||
              relationIds.contains(l.basis),
          isTrue,
          reason: '${l.fromId} -> ${l.toId} (${l.basis})',
        );
      }
    });

    test('standartlar: R1 almashtirilgan, litsenziyalilar arxivlanmagan', () {
      final s = {for (final x in pilot.provenance.standards) x.id: x};
      expect(s['STD-ICH-Q2R1']!.status, StandardStatus.superseded);
      expect(s['STD-ICH-Q2R1']!.supersededBy, 'STD-ICH-Q2R2');
      expect(s['STD-OSAC-2025-S-0010']!.status, StandardStatus.proposed);
      for (final x in s.values) {
        if (x.reuse == ReuseStatus.licenseRequired) expect(x.sha256, isNull);
      }
    });
  });

  testWidgets(
    'provenance oynasi: tasdiqlanmagan, tier, litsenziya, hayot sikli',
    (tester) async {
      await open(tester, Routes.libraryEntry('morphine'));
      const key = Key('claim.provenance.C-MORPHINE-REPORTED_CONCENTRATION-P5');
      await see(tester, find.byKey(key));
      await tester.tap(find.byKey(key));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('provenance.sheet')), findsOneWidget);
      expect(
        find.text('NOT VERIFIED — EXPERT CONFIRMATION REQUIRED'),
        findsOneWidget,
      );
      final sheet = find.descendant(
        of: find.byKey(const Key('provenance.sheet')),
        matching: find.byType(Scrollable),
      );
      await tester.dragUntilVisible(
        find.byKey(const Key('provenance.sourceLifecycle.SRC-PMC7578170')),
        sheet.first,
        const Offset(0, -200),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('B — peer-reviewed'), findsOneWidget);
      expect(find.text('Open reuse'), findsOneWidget);
      expect(find.text('Not retracted'), findsOneWidget);
      expect(find.textContaining('Retraction check:'), findsOneWidget);
    },
  );

  testWidgets('qat’iy kontekst: «manbada ko‘rsatilmagan» ochiq ko‘rinadi', (
    tester,
  ) async {
    await open(tester, Routes.libraryEntry('morphine'));
    await see(
      tester,
      find.byKey(
        const Key('claim.context.C-MORPHINE-REPORTED_CONCENTRATION-P5'),
      ),
    );
    expect(find.text('post-mortem'), findsWidgets);
    expect(find.text('not stated in the source'), findsWidgets);
  });

  testWidgets('retraksiya qilingan manba — CRITICAL banner (algor mortis)', (
    tester,
  ) async {
    await open(tester, Routes.knowledgeEntry('fm-algor-mortis'));
    await see(
      tester,
      find.byKey(const Key('claim.retracted.C-FM-ALGOR-MORTIS-DEFINITION')),
    );
  });

  testWidgets('EVIDENCE CONFLICT: banner → ziddiyat sahifasi', (tester) async {
    await open(tester, Routes.libraryEntry('methadone'));
    const key = Key(
      'claim.conflict.C-METHADONE-REPORTED_CONCENTRATION-P5.'
      'CF-METHADONE-PM-VS-LIVING',
    );
    await see(tester, find.byKey(key));
    await tester.tap(find.byKey(key));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('conflict.CF-METHADONE-PM-VS-LIVING')),
      findsOneWidget,
    );
    expect(find.text('Open — awaiting reviewer decision'), findsOneWidget);
  });

  testWidgets('ziddiyatlar ro‘yxati — 4 ta, hech biri hal qilinmagan', (
    tester,
  ) async {
    await open(tester, Routes.conflicts);
    for (final k in pilot.provenance.conflicts) {
      await see(tester, find.byKey(Key('conflicts.${k.id}')));
    }
    expect(pilot.provenance.conflicts, hasLength(4));
  });

  testWidgets('metabolitlar: faol / nofaol rol faqat manbali', (tester) async {
    await open(tester, Routes.libraryEntry('thc'));
    await see(tester, find.byKey(const Key('metabolite.MR-THC-THC-COOH')));
    expect(find.textContaining('Inactive metabolite'), findsWidgets);
    expect(find.textContaining('Active metabolite'), findsWidgets);
  });

  testWidgets('modda sahifasi: metabolitlar, namunalar, skrining, zanjir', (
    tester,
  ) async {
    await open(tester, Routes.libraryEntry('cocaine'));
    await see(
      tester,
      find.byKey(const Key('metabolite.MR-COCAINE-BENZOYLECGONINE')),
    );
    await see(tester, find.byKey(const Key('measured.cocaine.blood')));
    await see(
      tester,
      find.byKey(const Key('screened.cocaine.scr-immunoassay-drugs')),
    );
    await see(tester, find.byKey(const Key('chain.open.cocaine')));
    await tester.tap(find.byKey(const Key('chain.open.cocaine')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('chain.cocaine')), findsOneWidget);
    await see(
      tester,
      find.byKey(const Key('chain.cocaine.scr-immunoassay-drugs')),
    );
    await see(
      tester,
      find.byKey(const Key('chain.cocaine.R-US-COCAINE-CONTROL')),
    );
  });

  testWidgets('namunalar: ro‘yxat va vitreous sahifasi', (tester) async {
    await open(tester, Routes.specimens);
    await see(tester, find.byKey(const Key('specimens.vitreous')));
    await tester.tap(find.byKey(const Key('specimens.vitreous')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('specimen.vitreous')), findsOneWidget);
    await see(tester, find.byKey(const Key('claim.C-SPEC-VITREOUS-USE-P7')));
    await see(
      tester,
      find.byKey(const Key('claim.context.C-6-MAM-REPORTED_CONCENTRATION-P5')),
    );
  });

  testWidgets('standartlar katalogi: superseded, LICENSE REQUIRED, proposed', (
    tester,
  ) async {
    await open(tester, Routes.libraryStandards);
    await see(
      tester,
      find.byKey(const Key('standards.catalogue.STD-ICH-Q2R1')),
    );
    expect(find.text('Superseded by STD-ICH-Q2R2'), findsOneWidget);
    await see(tester, find.text('LICENSE REQUIRED'));
    await see(tester, find.text('Proposed — not yet published'));
  });

  testWidgets('review holati: HUMAN VERIFIED = 0, rollar va harakatlar', (
    tester,
  ) async {
    await open(tester, Routes.reviewStatus);
    expect(
      tester.widget<Text>(find.byKey(const Key('review.humanVerified'))).data,
      '0',
    );
    expect(
      tester.widget<Text>(find.byKey(const Key('review.actions'))).data,
      '0',
    );
    expect(
      tester.widget<Text>(find.byKey(const Key('review.retracted'))).data,
      '1',
    );
    for (final r in ReviewerRole.values) {
      await see(tester, find.byKey(Key('review.role.${r.code}')));
    }
    await see(tester, find.text('FLAG_CONFLICT'));
  });

  testWidgets('Library hub: namunalar, ziddiyatlar, review', (tester) async {
    await open(tester, Routes.library);
    await see(tester, find.byKey(const Key('library.hub.specimens')));
    await see(tester, find.byKey(const Key('library.hub.conflicts')));
    await see(tester, find.byKey(const Key('library.hub.review')));
  });

  testWidgets('metod: nashr etilgan metod — laboratoriya SOP emas', (
    tester,
  ) async {
    await open(tester, Routes.knowledgeEntry('method-gcms'));
    await see(tester, find.byKey(const Key('method.publishedNote')));
  });

  testWidgets('DE yurisdiksiyasi: BtMG pilot hujjati ko‘rinadi', (
    tester,
  ) async {
    await open(tester, Routes.jurisdiction('DE'));
    await see(tester, find.byKey(const Key('instrument.DE-BTMG-ANL')));
  });

  testWidgets('LOD/LOQ: ICH Q2(R2) havolasi (RG-25)', (tester) async {
    await open(tester, Routes.tool('tool.lab.lod_loq'));
    await see(tester, find.textContaining('ICH Q2(R2)'));
  });

  group('qidiruv (EN/RU/UZ)', () {
    late AppSearchService search;
    setUpAll(() {
      search = AppSearchService.build(
        library: pilot.library,
        learn: const EmptyLearnRepository(),
        knowledge: pilot.knowledge,
        instruments: pilot.legal.instruments,
        research: pilot.evidence.research,
        provenance: pilot.provenance,
      );
    });

    Future<bool> finds(String q, String id, SearchGroup g) async =>
        ((await search.search(q)).groups[g] ?? const []).any(
          (h) => h.entityId == id,
        );

    test('namuna: vitreous / стекловидное / shishasimon', () async {
      for (final q in ['vitreous', 'стекловидное', 'shishasimon']) {
        expect(
          await finds(q, 'vitreous', SearchGroup.methods),
          isTrue,
          reason: q,
        );
      }
    });

    test('standart: E2329 va Q2(R2)', () async {
      expect(
        await finds('E2329', 'STD-ASTM-E2329-25', SearchGroup.standardsLaws),
        isTrue,
      );
      expect(
        await finds('Q2(R2)', 'STD-ICH-Q2R2', SearchGroup.standardsLaws),
        isTrue,
      );
    });
  });
}
