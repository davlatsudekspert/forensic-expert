import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/guidelines.dart';
import 'package:forensic_expert/app/routes.dart';

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
    final semantics = tester.ensureSemantics();
    await open(tester, Routes.libraryEntry('ethanol'));
    expect(find.byKey(const Key('entry.glance.ethanol')), findsOneWidget);
    // Identifikatsiya claim’idan (PubChem) — yangi fakt emas.
    expect(inGlance('ethanol', find.text('C2H6O · 46.07 g/mol')), findsOne);
    // Usullar — «Tahlil» bo‘limidagi manbali bog‘lanishlar: ekranda qisqa
    // nom chiplari, to‘liq nom — semantik yorliqda (yangi fakt yo‘q).
    expect(inGlance('ethanol', find.text('GC-FID')), findsOne);
    expect(inGlance('ethanol', find.text('LC-MS/MS')), findsOne);
    expect(
      inGlance(
        'ethanol',
        find.bySemanticsLabel(
          RegExp(
            'GC-FID \\(alanga-ionlanish detektorli gaz xromatografiyasi\\)',
          ),
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
    // Ixcham holat chipi; to‘liq ma’no semantik yorliqda.
    expect(find.text('Ekspert hali tasdiqlamagan'), findsOne);
    expect(
      find.bySemanticsLabel('Ma’lumot hali ekspert tomonidan tasdiqlanmagan'),
      findsOne,
    );
    expect(find.byKey(const Key('entry.provenance')), findsOne);

    // «Manbalar» qatori sahifadagi manbalar ro‘yxatiga olib boradi.
    await tester.tap(find.byKey(const Key('entry.glance.row.sources')));
    await tester.pumpAndSettle();
    // Etanolga HS-GC-FID manbalari qo‘shilgandan keyin ro‘yxat uzaydi,
    // shuning uchun kerakli manbagacha aylantiriladi.
    final pubchem = find.byKey(const Key('source.meta.SRC-PUBCHEM-702'));
    await tester.dragUntilVisible(
      pubchem,
      find.byType(Scrollable).first,
      const Offset(0, -240),
      maxIteration: 60,
    );
    await tester.pumpAndSettle();
    expect(pubchem.hitTestable(), findsOne);
    semantics.dispose();
  });

  testWidgets('morfin: «Qisqacha» to‘liq — qulf belgisi va «Pro» yo‘q', (
    tester,
  ) async {
    await open(tester, Routes.libraryEntry('morphine'));
    expect(find.byKey(const Key('entry.glance.morphine')), findsOneWidget);
    expect(inGlance('morphine', find.byIcon(Icons.lock_outline)), findsNothing);
    expect(
      inGlance('morphine', find.textContaining(RegExp(r'\bPro\b'))),
      findsNothing,
    );
    expect(find.byKey(const Key('entry.glance.row.sources')), findsOne);
    // Usullar qatori «Tahlil» bo‘limiga olib boradi (qulf kartasiga emas).
    await tester.tap(find.byKey(const Key('entry.glance.row.methods')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('locked.unlock')), findsNothing);
  });

  testWidgets('morfin: konsentratsiya qatori → «chegara emas» bloki', (
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

  testWidgets('qidiruv: qulf belgisi yo‘q', (tester) async {
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
