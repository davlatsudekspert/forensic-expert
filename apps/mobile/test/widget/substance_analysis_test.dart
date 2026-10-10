import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/routes.dart';

import '../helpers/fake_store.dart';
import '../helpers/pilot_content.dart';
import '../helpers/pump_app.dart';

/// «Tahlil» bo‘limi (modda sahifasi) va namuna sahifasidagi teskari ro‘yxat —
/// HAQIQIY pilot paket, o‘zbek tilida.
void main() {
  late PilotContent pilot;
  setUpAll(() async => pilot = await loadPilotContent());

  Future<ProviderContainer> open(WidgetTester tester, String location) =>
      pumpApp(
        tester,
        settings: completedSettings(lang: 'uz'),
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

  Finder inAnalysis(String entityId, Finder f) =>
      find.descendant(of: find.byKey(Key('analysis.$entityId')), matching: f);

  testWidgets('morfin: «Tahlil» — Qon, LC-MS/MS, manba va holat', (
    tester,
  ) async {
    await open(tester, Routes.libraryEntry('morphine'));
    // «Shu sahifada» indeksida birinchi.
    expect(find.byKey(const Key('entry.index.analysis')), findsOneWidget);
    await see(tester, find.byKey(const Key('analysis.morphine')));
    await see(tester, find.byKey(const Key('measured.morphine.blood')));
    expect(inAnalysis('morphine', find.text('Qon')), findsOneWidget);
    await see(
      tester,
      find.byKey(const Key('analysis.method.morphine.method-lcmsms')),
    );
    // Skrining sinamalari qo‘shilgandan keyin LC-MS/MS ikki joyda chiqadi:
    // «Tahlil usullari» ro‘yxatida va skriningdan keyingi tasdiqlovchi usul
    // sifatida — shuning uchun bitta emas, kamida bitta kutiladi.
    expect(
      inAnalysis(
        'morphine',
        find.text(
          'LC-MS/MS (suyuqlik xromatografiyasi — tandem mass-spektrometriya)',
        ),
      ),
      findsWidgets,
    );
    // Metod namunaga bog‘lanmagan — halol izoh.
    expect(
      find.byKey(const Key('analysis.notPaired.morphine')),
      findsOneWidget,
    );
    // Hech biri «tasdiqlangan» emas; dalil darajasi ko‘rinadi.
    expect(inAnalysis('morphine', find.text('Tekshirilmagan')), findsWidgets);
    expect(inAnalysis('morphine', find.text('Tasdiqlangan')), findsNothing);
    // Metabolitlar.
    await see(
      tester,
      find.byKey(
        const Key(
          'analysis.metabolite.morphine.MR-MORPHINE-MORPHINE-3-GLUCURONIDE--M3G-',
        ),
      ),
    );
    // Konsentratsiya ≠ chegara ogohlantirishi saqlangan.
    await see(
      tester,
      find.byKey(const Key('entry.concentration.notThreshold')),
    );

    // Namunaga o‘tish.
    await see(tester, find.byKey(const Key('measured.morphine.blood')));
    await tester.tap(find.byKey(const Key('measured.morphine.blood')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('specimen.blood')), findsOneWidget);
  });

  testWidgets('manba tugmasi provenance oynasini ochadi', (tester) async {
    await open(tester, Routes.libraryEntry('morphine'));
    final src = find.byKey(
      const Key('analysis.source.C-MORPHINE-ANALYTICAL_METHOD-P5'),
    );
    await see(tester, src);
    await tester.tap(src.first);
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsOneWidget);
  });

  testWidgets('etilenglikol: Qon va Siydik', (tester) async {
    await open(tester, Routes.libraryEntry('ethylene-glycol'));
    await see(tester, find.byKey(const Key('measured.ethylene-glycol.urine')));
    expect(inAnalysis('ethylene-glycol', find.text('Qon')), findsOneWidget);
    expect(inAnalysis('ethylene-glycol', find.text('Siydik')), findsOneWidget);
  });

  testWidgets('etanol: namuna yo‘q — metodlar modda darajasida', (
    tester,
  ) async {
    await open(tester, Routes.libraryEntry('ethanol'));
    await see(tester, find.byKey(const Key('analysis.noSpecimens.ethanol')));
    await see(
      tester,
      find.byKey(const Key('analysis.method.ethanol.method-gc-fid')),
    );
    expect(
      inAnalysis(
        'ethanol',
        find.text('GC-FID (alanga-ionlanish detektorli gaz xromatografiyasi)'),
      ),
      findsOneWidget,
    );
    expect(
      inAnalysis('ethanol', find.text('Bug‘ fazali gaz xromatografiyasi')),
      findsOneWidget,
    );
  });

  testWidgets('kokain: skrining → tasdiqlovchi metodlar', (tester) async {
    await open(tester, Routes.libraryEntry('cocaine'));
    await see(
      tester,
      find.byKey(const Key('analysis.confirm.cocaine.method-gcms')),
    );
    expect(
      find.byKey(const Key('screened.cocaine.scr-immunoassay-drugs')),
      findsOneWidget,
    );
    expect(
      inAnalysis(
        'cocaine',
        find.text(
          'Skrining natijasi taxminiy — u tasdiqlovchi usul bilan '
          'tasdiqlanishi shart.',
        ),
      ),
      findsOneWidget,
    );
  });

  testWidgets('GHB: tahlil ma’lumoti yo‘q — bo‘sh holat, soxta qator yo‘q', (
    tester,
  ) async {
    await open(tester, Routes.libraryEntry('ghb'));
    await see(tester, find.byKey(const Key('analysis.empty.ghb')));
    expect(find.byKey(const Key('analysis.ghb')), findsNothing);
    expect(
      find.text(
        'Kontent paketida bu modda uchun hozircha manbali tahlil ma’lumoti '
        '(namuna, usul yoki metabolit) yo‘q.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('namuna sahifasi: shu namunada tahlil qilingan moddalar', (
    tester,
  ) async {
    await open(tester, Routes.specimen('blood'));
    expect(find.text('Bu namunada tahlil qilingan moddalar'), findsOneWidget);
    final chip = find.byKey(const Key('specimen.substance.blood.morphine'));
    await see(tester, chip);
    expect(
      find.descendant(of: chip, matching: find.text('Morfin')),
      findsOneWidget,
    );
    await tester.tap(chip);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('entry.index.analysis')), findsOneWidget);
  });
}
