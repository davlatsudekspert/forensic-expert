import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/app/search_service.dart';
import 'package:forensic_expert/core/widgets/common.dart';
import 'package:forensic_expert/data/fixtures/test_fixtures.dart';
import 'package:forensic_expert/domain/knowledge/knowledge_models.dart';
import 'package:forensic_expert/domain/library/library_models.dart';

import '../helpers/fake_store.dart';
import '../helpers/pilot_content.dart';
import '../helpers/pump_app.dart';

/// PHASE 5: global toksikologiya bazasi, Research / Evidence Library,
/// ilmiy rasmlar, bilim grafigi, gistologiya — HAQIQIY pilot paket bilan.
void main() {
  late PilotContent pilot;
  setUpAll(() async => pilot = await loadPilotContent());

  Future<void> open(
    WidgetTester tester,
    String location, {
    bool owned = true,
  }) async {
    await pumpApp(
      tester,
      settings: completedSettings(),
      initialLocation: location,
      testFixtures: false,
      overrides: [
        ...pilot.overrides,
        entitlementServiceProvider.overrideWithValue(FakeStore(owned: owned)),
      ],
    );
    await settleImages(tester);
  }

  Future<void> see(WidgetTester tester, Finder f) async {
    await tester.dragUntilVisible(
      f,
      find.byType(Scrollable).first,
      const Offset(0, -250),
    );
    await tester.pumpAndSettle();
    expect(f, findsWidgets);
  }

  final concentrationUnit = RegExp(
    r'\d+(?:[.,]\d+)?\s*(?:ng|µg|μg|ug|mg|mmol|µmol|μmol|nmol|µM|μM|nM|mM)'
    r'(?:\s*/\s*(?:mL|ml|L|l|dL|dl|g|kg))?\b',
  );

  group('kontent qoidalari (pilot paket)', () {
    test('moddalar: hammasi NEEDS_REVIEW, TEST DATA yo‘q, guruhli', () {
      final all = pilot.library.entries(LibrarySection.substances);
      expect(all.length, greaterThanOrEqualTo(100));
      for (final e in all) {
        expect(e.status, ScientificStatus.needsReview, reason: e.id);
        expect(e.isTestData, isFalse, reason: e.id);
        expect(e.group, isNotNull, reason: e.id);
      }
    });

    test('reported concentration: specimen, kontekst va «threshold emas»', () {
      var n = 0;
      for (final e in pilot.library.entries(LibrarySection.substances)) {
        for (final c in e.details!.claims) {
          final text = c.value['excerpt'] as String? ?? '';
          if (c.field == 'reported_concentration') {
            n++;
            expect(c.value['not_a_threshold'], isTrue, reason: c.claimId);
            expect(c.value['specimen'], isNotEmpty, reason: c.claimId);
            expect(c.value['context'], isNotNull, reason: c.claimId);
            expect(c.sources, isNotEmpty, reason: c.claimId);
          } else if (c.field != 'identity') {
            // Konsentratsiya qiymati faqat banner ostidagi bo‘limda.
            expect(
              concentrationUnit.hasMatch(text),
              isFalse,
              reason: '${c.claimId}: $text',
            );
          }
        }
      }
      expect(n, greaterThan(0));
    });

    test('research: dalil darajasi turi bilan chegaralangan, dublikat yo‘q, '
        'hayvon tadqiqoti yo‘q', () {
      final ev = pilot.evidence;
      expect(ev.research.length, greaterThan(500));
      final keys = <String>{};
      final animal = RegExp(
        r'\b(rats?|mice|dogs?|horses?)\b',
        caseSensitive: false,
      );
      for (final r in ev.research) {
        expect(r.status, ScientificStatus.needsReview, reason: r.id);
        expect(
          r.evidenceLevel.compareTo(r.kind.maxEvidence.code) >= 0,
          isTrue,
          reason: '${r.id} ${r.kind} ${r.evidenceLevel}',
        );
        expect(r.peerReviewed, r.kind.isPeerReviewedFullArticle, reason: r.id);
        expect(r.doi ?? r.pmid ?? r.handle ?? r.url, isNotNull, reason: r.id);
        final key = r.doi != null
            ? 'doi:${r.doi!.toLowerCase()}'
            : r.pmid != null
            ? 'pmid:${r.pmid}'
            : 'title:${normalizeTitle(r.title)}';
        expect(keys.add(key), isTrue, reason: 'dublikat: ${r.id}');
        if (animal.hasMatch(r.title)) {
          expect(r.title.toLowerCase(), contains('human'), reason: r.title);
        }
      }
      // Dissertatsiya / tezis / konferensiya — peer-reviewed emas, daraja E.
      for (final k in [
        ResearchKind.dissertation,
        ResearchKind.thesis,
        ResearchKind.conferencePaper,
      ]) {
        final xs = ev.research.where((r) => r.kind == k);
        expect(xs, isNotEmpty, reason: '$k');
        for (final r in xs) {
          expect(r.peerReviewed, isFalse);
          expect(r.evidenceLevel, 'E');
        }
      }
    });

    test('rasmlar: litsenziya ruxsat etilgan, graphic yo‘q, sxema real '
        'ma’lumot emas, alt matn bor', () {
      final ev = pilot.evidence;
      expect(ev.images, isNotEmpty);
      for (final i in ev.images) {
        expect(allowedImageLicenses, contains(i.license), reason: i.id);
        expect(i.attribution, isNotEmpty, reason: i.id);
        expect(i.alt.resolve('en'), isNotEmpty, reason: i.id);
        expect(pilot.images.bytes[i.id], isNotNull, reason: i.id);
        if (i.kind == ImageKind.schematic) {
          expect(i.isOriginalDiagram, isTrue, reason: i.id);
          expect(i.representsRealData, isFalse, reason: i.id);
        }
        if (!i.isOriginalDiagram && i.kind != ImageKind.chemicalStructure) {
          // Tashqi rasm: manba, muallif va murojaat sanasi majburiy.
          expect(i.sourceUrl, isNotNull, reason: i.id);
          expect(i.creator, isNotNull, reason: i.id);
          expect(i.accessedDate, isNotNull, reason: i.id);
          expect(i.license, anyOf('CC BY', 'CC BY 4.0', 'CC0'), reason: i.id);
        }
      }
    });

    test('bilim grafigi: har bir bog‘lanish asosli, uchlari mavjud', () {
      final ev = pilot.evidence;
      final known = <String>{
        for (final s in LibrarySection.values)
          for (final e in pilot.library.entries(s)) e.id,
        for (final k in KnowledgeKind.values)
          for (final e in pilot.knowledge.byKind(k)) e.id,
        for (final r in ev.research) r.id,
        // PHASE 7 tugunlari: namunalar, standartlar, yurisdiksion qoidalar.
        for (final s in pilot.provenance.specimens) s.id,
        for (final s in pilot.provenance.standards) s.id,
        for (final r in pilot.legal.rules) r.id,
      };
      expect(ev.links, isNotEmpty);
      for (final l in ev.links) {
        expect(l.basis, isNotEmpty);
        expect(known, contains(l.fromId), reason: '${l.fromId} → ${l.toId}');
        expect(known, contains(l.toId), reason: '${l.fromId} → ${l.toId}');
      }
    });
  });

  testWidgets('modda: struktura rasmi, konsentratsiya banneri, bog‘liq '
      'materiallar', (tester) async {
    await open(tester, Routes.libraryEntry('morphine'));
    await see(tester, find.byKey(const Key('image.IMG-STRUCT-morphine')));
    await see(
      tester,
      find.byKey(const Key('entry.concentration.notThreshold')),
    );
    await see(tester, find.byKey(const Key('related.morphine')));
  });

  testWidgets('modda Lifetime’siz: dalillar yopiq', (tester) async {
    await open(tester, Routes.libraryEntry('morphine'), owned: false);
    expect(find.byKey(const Key('entry.locked')), findsOneWidget);
    expect(
      find.byKey(const Key('entry.concentration.notThreshold')),
      findsNothing,
    );
  });

  testWidgets('kutubxona: guruh filtri faqat shu guruhni ko‘rsatadi', (
    tester,
  ) async {
    await open(tester, Routes.librarySection('substances'));
    expect(find.byKey(const Key('library.groups')), findsOneWidget);
    final chip = find.byKey(const Key('library.group.opioids'));
    await tester.ensureVisible(chip);
    await tester.tap(chip);
    await tester.pumpAndSettle();
    final opioids = pilot.library
        .entries(LibrarySection.substances)
        .where((e) => e.group == 'opioids')
        .toList();
    expect(opioids, isNotEmpty);
    await see(tester, find.byKey(Key('library.entry.${opioids.first.id}')));
    expect(find.byKey(const Key('library.entry.ethanol')), findsNothing);
  });

  testWidgets('research kutubxonasi: dissertatsiya filtri, peer-review '
      'ogohlantirishi', (tester) async {
    await open(tester, Routes.research);
    final chip = find.byKey(const Key('research.kind.dissertation'));
    await tester.ensureVisible(chip);
    await tester.tap(chip);
    await tester.pumpAndSettle();
    final first = pilot.evidence.research.firstWhere(
      (r) => r.kind == ResearchKind.dissertation,
    );
    await see(tester, find.byKey(Key('research.${first.id}')));
    expect(find.text('Not a peer-reviewed article'), findsWidgets);
  });

  testWidgets(
    'research tafsiloti: metadata, havola nusxasi, to‘liq matn yo‘q',
    (tester) async {
      final r = pilot.evidence.research.firstWhere((x) => x.doi != null);
      await open(tester, Routes.researchEntry(r.id));
      expect(find.byKey(Key('researchDetail.${r.id}')), findsOneWidget);
      expect(find.text(r.doi!), findsOneWidget);
      await see(tester, find.byKey(const Key('research.copyLink')));
    },
  );

  testWidgets('rasm ko‘rgich: litsenziya va attribution to‘liq', (
    tester,
  ) async {
    final img = pilot.evidence.images.firstWhere(
      (i) => i.license == 'CC BY' && !i.isOriginalDiagram,
    );
    await open(tester, Routes.image(img.id));
    expect(find.byKey(Key('imageViewer.${img.id}')), findsOneWidget);
    expect(find.textContaining('CC BY'), findsWidgets);
    expect(find.text(img.attribution), findsOneWidget);
    expect(find.text('Creator'), findsOneWidget);
    expect(find.text('Accessed'), findsOneWidget);
  });

  testWidgets('gistologiya: «tashxis qo‘ymaydi» banneri yuqorida', (
    tester,
  ) async {
    await open(tester, Routes.knowledgeEntry('his-mi-early'));
    expect(find.byKey(const Key('histology.noDiagnosis')), findsOneWidget);
    expect(find.byType(UnverifiedBanner), findsWidgets);
    await see(tester, find.byKey(const Key('gallery.his-mi-early')));
  });

  testWidgets('gistologiya hub: banner va mavzular', (tester) async {
    await open(tester, Routes.histology);
    expect(find.byKey(const Key('histology.noDiagnosis')), findsOneWidget);
    await see(tester, find.byKey(const Key('knowledge.his-ihc')));
  });

  testWidgets('Dragendorff: manbali retsept, takroriy jumla yo‘q', (
    tester,
  ) async {
    await open(tester, Routes.knowledgeEntry('reagent-dragendorff'));
    await see(tester, find.byKey(const Key('reagent.ingredients')));
    expect(find.byKey(const Key('reagent.orderNotStated')), findsOneWidget);
    expect(
      find.textContaining('Dragendorff’s reagent was prepared by mixing'),
      findsOneWidget,
    );
  });

  testWidgets('fentanil test chiziqlari: skrining ≠ tasdiq, jumla bir marta', (
    tester,
  ) async {
    await open(tester, Routes.knowledgeEntry('scr-fentanyl-test-strips'));
    expect(find.byKey(const Key('screening.banner')), findsOneWidget);
    expect(
      find.textContaining('Previous reports indicate that in addition'),
      findsOneWidget,
    );
  });

  testWidgets('LC-MS/MS: texnika nomi lokalizatsiya qilingan', (tester) async {
    await open(tester, Routes.knowledgeEntry('method-lcmsms'), owned: false);
    await see(tester, find.text('LC-MS/MS'));
    expect(find.text('lcMsMs'), findsNothing);
  });

  test('qidiruv: research sarlavhalari indekslangan', () async {
    final service = AppSearchService.build(
      library: pilot.library,
      learn: const EmptyLearnRepository(),
      knowledge: pilot.knowledge,
      research: pilot.evidence.research,
    );
    final r = await service.search('postmortem redistribution');
    final refs = r.groups[SearchGroup.references]!;
    expect(refs, isNotEmpty);
    expect(
      refs.every((h) => pilot.evidence.researchById(h.entityId) != null),
      isTrue,
    );
  });

  testWidgets('qidiruv natijasi research sahifasini ochadi', (tester) async {
    await open(tester, Routes.searchWith('postmortem redistribution'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    final hit = find.byIcon(Icons.menu_book_outlined).first;
    // Ko‘p so‘zli so‘rov bitta so‘zga mos yozuvlarni ham ko‘rsatadi —
    // manbalar guruhi ekrandan pastda bo‘lishi mumkin.
    await tester.ensureVisible(hit);
    await tester.pumpAndSettle();
    await tester.tap(hit);
    await tester.pumpAndSettle();
    expect(
      find.byWidgetPredicate(
        (w) =>
            w.key is ValueKey<String> &&
            (w.key! as ValueKey<String>).value.startsWith('researchDetail.'),
      ),
      findsOneWidget,
    );
  });
}
