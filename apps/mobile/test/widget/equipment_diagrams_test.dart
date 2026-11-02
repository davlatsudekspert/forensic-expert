import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:forensic_expert/app/equipment.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/features/equipment/presentation/equipment_diagrams.dart';
import 'package:forensic_expert/features/equipment/presentation/worked_example_screen.dart';

import '../helpers/pump_app.dart';

void main() {
  final equip = File('assets/content/equipment/equipment_v1.json')
      .readAsStringSync();

  Future<void> open(WidgetTester tester, String id) => pumpApp(
    tester,
    settings: completedSettings(lang: 'uz'),
    size: const Size(390, 5200),
    initialLocation: Routes.equipmentItem(id),
    proEnabled: false,
    overrides: [equipmentLoaderProvider.overrideWithValue(() async => equip)],
  );

  testWidgets('spektrofotometr: COHb cho‘qqilari sxemasi va tartib', (
    tester,
  ) async {
    await open(tester, 'uv_vis');
    expect(find.byKey(const Key('equipment.cohbSpectrum')), findsOneWidget);
    expect(find.textContaining('228–229-betlar'), findsWidgets);
    // Avval nolga qo‘yish, oxirida qonni CO bilan to‘yintirish.
    expect(find.textContaining('Avval apparatni nolga qo‘yish'), findsOne);
    expect(find.textContaining('Qonni is gazi (CO) bilan'), findsOne);
  });

  testWidgets('GC-MS: cho‘qqilarni o‘qish kartasi', (tester) async {
    await open(tester, 'gc_ms');
    expect(find.byKey(const Key('equipment.gcmsReading')), findsOneWidget);
    expect(find.byKey(const Key('equipment.cohbSpectrum')), findsNothing);
  });

  testWidgets('tropikamid misoli: sxema, kalibrlash, manbalar', (tester) async {
    final json = File('assets/content/worked_examples/tropicamide_uv.json')
        .readAsStringSync();
    await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz'),
      size: const Size(390, 5200),
      initialLocation: Routes.workedExample('tropicamide_uv'),
      proEnabled: false,
      overrides: [
        workedExampleLoaderProvider.overrideWithValue((_) async => json),
      ],
    );
    expect(find.byKey(const Key('worked.tropicamide_uv')), findsOneWidget);
    expect(find.byKey(const Key('worked.calibration')), findsOneWidget);
    expect(find.textContaining('408 nm'), findsWidgets);
    expect(find.byKey(const Key('worked.source')), findsNWidgets(3));
  });

  testWidgets('spektrofotometr sahifasida tropikamid misoliga kirish', (
    tester,
  ) async {
    await open(tester, 'uv_vis');
    expect(
      find.byKey(const Key('equipment.worked.tropicamide_uv')),
      findsOneWidget,
    );
  });

  testWidgets('fenobarbital misoli: pH spektrlari va ajratib olish', (
    tester,
  ) async {
    final json = File(
      'assets/content/worked_examples/phenobarbital_blood_uv.json',
    ).readAsStringSync();
    await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz'),
      size: const Size(390, 5200),
      initialLocation: Routes.workedExample('phenobarbital_blood_uv'),
      proEnabled: false,
      overrides: [
        workedExampleLoaderProvider.overrideWithValue((_) async => json),
      ],
    );
    expect(find.byKey(const Key('worked.spectra')), findsOneWidget);
    expect(find.byKey(const Key('worked.calibration')), findsOneWidget);
    expect(find.textContaining('260 nm'), findsWidgets);
  });

  testWidgets('GC-MS moddalar: mass-spektrlar va manbalar', (tester) async {
    final json = File('assets/content/worked_examples/gcms_drugs_qp2020.json')
        .readAsStringSync();
    await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz'),
      size: const Size(390, 9000),
      initialLocation: Routes.workedExample('gcms_drugs_qp2020'),
      proEnabled: false,
      overrides: [
        workedExampleLoaderProvider.overrideWithValue((_) async => json),
      ],
    );
    expect(find.byKey(const Key('worked.ms.Kokain')), findsOneWidget);
    expect(find.byKey(const Key('worked.ms.Tramadol')), findsOneWidget);
    expect(find.textContaining('asosiy ion 82'), findsOneWidget);
  });

  test('usullar sahifasi uchun misollar', () {
    expect(EquipmentDiagrams.forMethod('method-uvvis'), isNotNull);
    expect(EquipmentDiagrams.forMethod('method-gcms'), isNotNull);
    expect(EquipmentDiagrams.forMethod('method-tlc'), isNull);
  });
}
