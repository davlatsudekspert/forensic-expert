import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/widgets/common.dart';
import 'package:forensic_expert/data/content/content_library_repository.dart';

import '../helpers/fake_store.dart';
import '../helpers/pilot_content.dart';
import '../helpers/pump_app.dart';

/// Haqiqiy pilot paket bilan UI: provenance, ogohlantirish, paywall.
void main() {
  late PilotContent pilot;
  late ContentLibraryRepository repo;
  setUpAll(() async {
    pilot = await loadPilotContent();
    repo = pilot.library;
  });

  Future<void> open(
    WidgetTester tester,
    String id, {
    bool owned = false,
    String jurisdiction = 'INT',
  }) async {
    await pumpApp(
      tester,
      settings: completedSettings().copyWith(jurisdictionId: jurisdiction),
      initialLocation: Routes.libraryEntry(id),
      testFixtures: false,
      overrides: [
        ...pilot.overrides,
        entitlementServiceProvider.overrideWithValue(FakeStore(owned: owned)),
      ],
    );
  }

  Future<void> see(WidgetTester tester, Finder f) async {
    await tester.dragUntilVisible(
      f,
      find.byType(ListView).first,
      const Offset(0, -250),
    );
    await tester.pumpAndSettle();
    expect(f, findsWidgets);
  }

  testWidgets('bepul demo yozuv: ilmiy qatlam, iqtibos va manbalar ochiq', (
    tester,
  ) async {
    await open(tester, 'methanol');
    // «MA’LUMOT TEKSHIRILMAGAN — EKSPERT TASDIG‘I KERAK» banneri.
    expect(find.byType(UnverifiedBanner), findsOneWidget);
    expect(find.byKey(const Key('badge.freeDemo')), findsOneWidget);
    expect(find.byKey(const Key('entry.provenance')), findsOneWidget);
    expect(find.text('No expert reviews yet (2 required)'), findsOneWidget);
    expect(find.byKey(const Key('entry.locked')), findsNothing);
    await see(tester, find.byKey(const Key('claim.C-METHANOL-IDENTITY')));
    await see(
      tester,
      find.byKey(const Key('claim.excerpt.C-METHANOL-METABOLITES')),
    );
    await see(tester, find.byKey(const Key('source.SRC-PMC11728796')));
  });

  testWidgets('Lifetime yozuv qulflangan: ogohlantirish va manbalar ochiq', (
    tester,
  ) async {
    await open(tester, 'morphine');
    expect(find.byKey(const Key('badge.lifetime')), findsOneWidget);
    expect(find.byKey(const Key('entry.provenance')), findsOneWidget);
    await see(tester, find.byKey(const Key('entry.locked')));
    // Ilmiy tafsilot va huquqiy qatlam yopiq.
    expect(find.byKey(const Key('claim.C-MORPHINE-METABOLITES')), findsNothing);
    expect(find.byKey(const Key('entry.layer.jurisdiction')), findsNothing);
    // Manbalar paywall ortida EMAS.
    await see(tester, find.byKey(const Key('source.SRC-PMC9134088')));
    await see(tester, find.byKey(const Key('source.SRC-INCB-YELLOW-LIST-65')));
  });

  testWidgets('Lifetime egasi: claim va INT nazorat qoidasi ko‘rinadi', (
    tester,
  ) async {
    await open(tester, 'morphine', owned: true);
    expect(find.byKey(const Key('entry.locked')), findsNothing);
    await see(tester, find.byKey(const Key('claim.C-MORPHINE-METABOLITES')));
    await see(tester, find.byKey(const Key('legal.R-INT-MORPHINE-YELLOW')));
    expect(
      find.textContaining('Single Convention on Narcotic Drugs, 1961'),
      findsWidgets,
    );
  });

  testWidgets(
    'UZ tanlanganda: INT qoidasi meros, milliy kontent yo‘qligi aytiladi',
    (tester) async {
      await open(tester, 'fentanyl', owned: true, jurisdiction: 'UZ');
      await see(tester, find.byKey(const Key('legal.R-INT-FENTANYL-YELLOW')));
      await see(tester, find.byKey(const Key('legal.noNational')));
      // Litsenziya ruxsat bermagan iqtibos ko‘rsatilmaydi.
      await see(
        tester,
        find.byKey(const Key('claim.withheld.C-FENTANYL-METABOLITES')),
      );
    },
  );

  testWidgets('kutubxona ro‘yxati: demo va Lifetime belgilari', (tester) async {
    await pumpApp(
      tester,
      settings: completedSettings(),
      initialLocation: Routes.library,
      testFixtures: false,
      overrides: [libraryRepositoryProvider.overrideWithValue(repo)],
    );
    expect(find.byKey(const Key('badge.freeDemo')), findsWidgets);
    expect(find.byKey(const Key('badge.lifetime')), findsWidgets);
    expect(find.text('TEST DATA'), findsNothing);
  });
}
