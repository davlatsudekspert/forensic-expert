import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/widgets/common.dart';

import '../helpers/fake_store.dart';
import '../helpers/pilot_content.dart';
import '../helpers/pump_app.dart';

/// Reaktiv retsepti sahifasi — HAQIQIY pilot paket (ilova egasi to‘plami).
void main() {
  late PilotContent pilot;
  setUpAll(() async => pilot = await loadPilotContent());

  Future<void> open(
    WidgetTester tester,
    String id, {
    String lang = 'uz',
    bool owned = false,
    Size size = const Size(390, 844),
  }) => pumpApp(
    tester,
    settings: completedSettings(lang: lang),
    size: size,
    initialLocation: Routes.knowledgeEntry(id),
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

  testWidgets('Dragendorf (uz): xavflar, tarkib, bosqichlar, asl matn', (
    tester,
  ) async {
    await open(tester, 'reagent-dragendorff');
    expect(find.text('Dragendorf reaktivi'), findsWidgets);
    expect(find.byType(UnverifiedBanner), findsWidgets);
    // Xavflar sahifa boshida, bepul foydalanuvchiga ham ochiq.
    expect(find.byKey(const Key('reagent.hazardBanner')), findsOneWidget);
    expect(find.byKey(const Key('reagent.hazard.ghs')), findsWidgets);
    expect(find.textContaining('PubChem CID'), findsWidgets);

    await see(tester, find.byKey(const Key('reagent.machineDraft')));
    await see(tester, find.byKey(const Key('reagent.ingredients.own')));
    expect(find.text('asosli vismut nitrat'), findsOneWidget);
    expect(find.text('27,2 g'), findsOneWidget);
    expect(find.text('100 ml gacha'), findsOneWidget);
    await see(
      tester,
      find.textContaining('1. 20 ml nitrat kislotada (zichligi 1,18)'),
    );
    // Oldingi manba (PMC) retsepti alohida variant sifatida qoladi.
    await see(tester, find.byKey(const Key('reagent.ingredients.pmc')));
    expect(
      find.textContaining('Dragendorf reaktivi 70 ml distillangan suv'),
      findsOneWidget,
    );

    // «Asl matn (rus)» — yopiq, bosilganda ochiladi.
    await see(tester, find.byKey(const Key('reagent.originalText')));
    expect(find.text('Asl matn (rus)'), findsOneWidget);
    expect(find.byKey(const Key('reagent.originalText.body')), findsNothing);
    await tester.tap(find.text('Asl matn (rus)'));
    await tester.pumpAndSettle();
    await see(tester, find.byKey(const Key('reagent.originalText.body')));
    expect(
      find.textContaining('В 20 мл азотной кислоты (пл. 1,18)'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('benzidin qog‘ozi (bepul): xavf ogohlantirishi ko‘rinadi', (
    tester,
  ) async {
    await open(tester, 'reagent-benzidine-paper');
    expect(find.byKey(const Key('reagent.hazardBanner')), findsOneWidget);
    expect(find.byKey(const Key('reagent.hazard.general')), findsWidgets);
    expect(find.textContaining('tayyorlamaslik tavsiya etiladi'), findsOne);
    // Egasi qarori: egasi to‘plamidagi barcha retseptlar bepul.
    expect(find.byKey(const Key('knowledge.locked')), findsNothing);
  });

  testWidgets('ditizon (bepul): GHS topilmagan modda «tekshirilmagan»', (
    tester,
  ) async {
    await open(tester, 'reagent-dithizone-solution');
    expect(find.byKey(const Key('knowledge.locked')), findsNothing);
    await see(
      tester,
      find.textContaining('Xavflilik ma’lumotlari to‘liq tekshirilmagan'),
    );
    expect(find.textContaining('xavfsiz degani emas'), findsOneWidget);
  });

  testWidgets('Fehling (ru, 320 dp, Pro): variantlar, toshma yo‘q', (
    tester,
  ) async {
    await open(
      tester,
      'reagent-fehling',
      lang: 'ru',
      owned: true,
      size: const Size(320, 640),
    );
    await see(tester, find.byKey(const Key('reagent.variant.a')));
    await see(tester, find.byKey(const Key('reagent.ingredients.a')));
    expect(find.text('34,66 г'), findsOneWidget);
    expect(find.text('2–3 капли'), findsOneWidget);
    await see(tester, find.byKey(const Key('reagent.variant.b')));
    await see(tester, find.byKey(const Key('reagent.ingredients.b')));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Folin (en): noaniqlik kartasi va raqamsiz miqdor izohi', (
    tester,
  ) async {
    await open(tester, 'reagent-folin-ciocalteu', lang: 'en', owned: true);
    await see(tester, find.text('until dissolved').first);
    await see(tester, find.text('to 1000 mL'));
    await see(tester, find.byKey(const Key('reagent.ambiguities')));
    expect(find.textContaining('OCR error'), findsWidgets);
  });
}
