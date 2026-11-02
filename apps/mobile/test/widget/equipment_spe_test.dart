import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/equipment.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/settings/app_settings.dart';
import 'package:forensic_expert/domain/equipment/equipment.dart';

import '../helpers/pump_app.dart';

/// «Qattiq fazali ekstraksiya (SPE)» kartochkasi — haqiqiy paket: manbali,
/// qadamlar rasmdagi bosqichlarga mos, rasm fayli bor, izoh — «sxema».
final _pack = File('assets/content/equipment/equipment_v1.json')
    .readAsStringSync();

void main() {
  EquipmentItem spe() {
    final b = EquipmentBundle.fromJson(
      (jsonDecode(_pack) as Map).cast<String, Object?>(),
    );
    final i = b.byId('spe');
    expect(i, isNotNull, reason: 'SPE kartochkasi paketda bo‘lishi kerak');
    return i!;
  }

  test('SPE: manbali, 6 qadam, sxema, rasm fayli mavjud', () {
    final i = spe();
    expect(i.group, EquipmentGroup.lab);
    expect(i.schematic, isTrue);
    expect(i.steps.length, 6, reason: '5 bosqich + tahlilga tayyorlash');
    expect(i.sources.length, greaterThanOrEqualTo(5));
    expect(i.sources.every((s) => s.valid), isTrue);
    expect(i.national, contains('Sud-kimyo bo‘limiga'));
    expect(i.methods, contains('method-spe'));
    expect(File(i.image).existsSync(), isTrue, reason: i.image);
  });

  test('SPE: faktlar manba bilan tekshirildi (asosiy raqamlar saqlangan)', () {
    final i = spe();
    final all = [...i.use, ...i.care, ...i.steps].join(' ');
    // Restek qo‘llanmasi: vakuum 30–60 s, quritish 1–10 daqiqa; LCGC: ~1 mL/min.
    expect(all, contains('30–60 soniya'));
    expect(all, contains('1–10 daqiqa'));
    expect(all, contains('1 mL/min'));
    // Platoff va Gere (1991): NIDA laboratoriyalarida 40–50 %.
    expect(all, contains('40–50 foiz'));
  });

  testWidgets('SPE kartasi: sxema izohi, 6 qadam, manbalar', (t) async {
    await pumpApp(
      t,
      settings: completedSettings(lang: 'uz', mode: UserMode.professional),
      initialLocation: Routes.equipmentItem('spe'),
      overrides: [equipmentLoaderProvider.overrideWithValue(() async => _pack)],
    );
    await t.pumpAndSettle();
    expect(find.textContaining('Sxema (original chizma)'), findsOneWidget);
    expect(find.textContaining('AI yordamida chizilgan'), findsNothing);
    final steps = find.textContaining('Kondisionlash:');
    await t.scrollUntilVisible(
      steps,
      300,
      scrollable: find.byType(Scrollable).last,
    );
    expect(steps, findsOneWidget);
    expect(find.textContaining('Ekstraktni tahlilga tayyorlash:'), findsOne);
    expect(t.takeException(), isNull);
  });
}
