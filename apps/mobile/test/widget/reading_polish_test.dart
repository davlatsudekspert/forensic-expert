import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/guidelines.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/routes.dart';

import '../helpers/fake_store.dart';
import '../helpers/pilot_content.dart';
import '../helpers/pump_app.dart';

/// O‘qish tajribasi sayqali — HAQIQIY pilot paket, o‘zbek tilida:
/// «Qisqacha» xulosa (faqat mavjud manbali ma’lumotdan), qidiruvda Pro
/// belgisi. Xavfsizlik elementlari (holat, manbalar, «chegara emas»)
/// joyida qolishi tekshiriladi.
void main() {
  late PilotContent pilot;
  setUpAll(() async => pilot = await loadPilotContent());

  Future<ProviderContainer> open(
    WidgetTester tester,
    String location, {
    bool owned = true,
    Size size = const Size(390, 844),
    double textScale = 1,
  }) => pumpApp(
    tester,
    settings: completedSettings(lang: 'uz'),
    initialLocation: location,
    testFixtures: false,
    size: size,
    textScale: textScale,
    overrides: [
      ...pilot.overrides,
      entitlementServiceProvider.overrideWithValue(FakeStore(owned: owned)),
      // Haqiqiy yo‘riqnomalar fayli (ilova bilan birga keladigan).
      guidelineBundleLoaderProvider.overrideWithValue(
        () async =>
            File('assets/content/guidelines/guidelines_v1.json')
                .readAsStringSync(),
      ),
    ],
  );

  Finder inGlance(String id, Finder f) =>
      find.descendant(of: find.byKey(Key('entry.glance.$id')), matching: f);

  testWidgets('etanol: «Qisqacha» — formula, usullar, metabolitlar, manbalar', (
    tester,
  ) async {
    await open(tester, Routes.libraryEntry('ethanol'));
    expect(find.byKey(const Key('entry.glance.ethanol')), findsOneWidget);
    // Identifikatsiya claim’idan (PubChem) — yangi fakt emas.
    expect(inGlance('ethanol', find.text('C2H6O · 46.07 g/mol')), findsOne);
    // Usullar — «Tahlil» bo‘limidagi manbali bog‘lanishlar nomlari.
    expect(
      inGlance(
        'ethanol',
        find.textContaining(
          'GC-FID (alanga-ionlanish detektorli gaz xromatografiyasi)',
        ),
      ),
      findsOne,
    );
    // Metabolit nomi UI tilida (Phase D tarjimasi, Phase C qatlami).
    expect(inGlance('ethanol', find.textContaining('atsetaldegid')), findsOne);
    expect(
      inGlance('ethanol', find.textContaining('acetaldehyde')),
      findsNothing,
    );
    // Manbasiz namuna yo‘q — soxta qator ham yo‘q.
    expect(find.byKey(const Key('entry.glance.row.specimens')), findsNothing);
    expect(find.byKey(const Key('entry.glance.row.sources')), findsOne);
    // Holat ogohlantirishi va «Ma’lumotlar kelib chiqishi» joyida.
    expect(
      find.text('Ma’lumot hali ekspert tomonidan tasdiqlanmagan'),
      findsOne,
    );
    expect(find.byKey(const Key('entry.provenance')), findsOne);

    // «Manbalar» qatori sahifadagi manbalar ro‘yxatiga olib boradi.
    await tester.tap(find.byKey(const Key('entry.glance.row.sources')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('source.meta.SRC-PUBCHEM-702')).hitTestable(),
      findsOne,
    );
  });

  testWidgets('morfin (Pro, bepul rejim): faqat sonlar va qulf, manba ochiq', (
    tester,
  ) async {
    await open(tester, Routes.libraryEntry('morphine'), owned: false);
    expect(find.byKey(const Key('entry.glance.morphine')), findsOneWidget);
    // Yopiq tafsilot nomlari ko‘rinmaydi, faqat son.
    expect(inGlance('morphine', find.textContaining('LC-MS/MS')), findsNothing);
    expect(inGlance('morphine', find.text('Kimyoviy formula')), findsNothing);
    expect(inGlance('morphine', find.byIcon(Icons.lock_outline)), findsWidgets);
    expect(
      inGlance('morphine', find.textContaining('Pro’da ochiladi')),
      findsOne,
    );
    expect(find.byKey(const Key('entry.glance.row.sources')), findsOne);
    // Qulf qatori qulf kartasiga olib boradi.
    await tester.tap(find.byKey(const Key('entry.glance.row.methods')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('locked.unlock')).hitTestable(), findsOne);
  });

  testWidgets('morfin (Pro): konsentratsiya qatori → «chegara emas» bloki', (
    tester,
  ) async {
    await open(tester, Routes.libraryEntry('morphine'));
    expect(inGlance('morphine', find.textContaining('Qon')), findsOne);
    await tester.tap(find.byKey(const Key('entry.glance.row.concentrations')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('entry.concentration.notThreshold')).hitTestable(),
      findsOne,
    );
  });

  testWidgets('320 dp, 2x matn: «Qisqacha» toshmaydi', (tester) async {
    await open(
      tester,
      Routes.libraryEntry('morphine'),
      size: const Size(320, 640),
      textScale: 2,
    );
    expect(find.byKey(const Key('entry.glance.morphine')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('qidiruv (bepul): Pro yozuvi oldindan belgilanadi', (
    tester,
  ) async {
    await open(tester, Routes.searchWith('morfin'), owned: false);
    await tester.pumpAndSettle();
    final hit = find.byKey(const Key('search.hit.morphine'));
    expect(hit, findsOne);
    expect(
      find.descendant(
        of: hit,
        matching: find.byKey(const Key('search.hit.locked')),
      ),
      findsOne,
    );
    // Bepul yozuv (etanol) — qulfsiz.
    await tester.enterText(find.byKey(const Key('search.field')), 'etanol');
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const Key('search.hit.ethanol')),
        matching: find.byKey(const Key('search.hit.locked')),
      ),
      findsNothing,
    );
  });

  testWidgets('qidiruv (Pro): qulf belgisi yo‘q', (tester) async {
    await open(tester, Routes.searchWith('morfin'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('search.hit.morphine')), findsOne);
    expect(find.byKey(const Key('search.hit.locked')), findsNothing);
  });

  testWidgets('yo‘riqnomalar ro‘yxati: bo‘lim va manba soni', (tester) async {
    await open(tester, Routes.guidelines);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('guidelines.meta.guideline.chem.ethanol_gc')),
      findsOne,
    );
    expect(find.textContaining('8 bo‘lim'), findsWidgets);
  });
}
