import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/equipment.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/settings/app_settings.dart';
import 'package:forensic_expert/domain/equipment/equipment.dart';
import 'package:forensic_expert/features/equipment/presentation/equipment_screens.dart';

import '../helpers/pump_app.dart';

/// «Asbob-uskunalar»: manbasiz yozuv ko‘rsatilmaydi; hub ikki bo‘limli;
/// karta — illyustratsiya izohi, tavsif va manba; boshqa tilda «tarjima
/// kutilmoqda».
const _fixture = {
  'source_lang': 'uz',
  'items': [
    {
      'id': 'gc_ms',
      'group': 'lab',
      'name': 'Gaz xromatografiya – mass-spektrometriya (GC-MS)',
      'what': 'Moddalarni ajratib, mass-spektri bo‘yicha aniqlaydi.',
      'use': ['Biologik namunada moddani aniqlash'],
      'care': <String>[],
      'links': {
        'methods': ['method-gcms'],
        'guides': <String>[],
        'lessons': <String>[],
      },
      'sources': [
        {'author': 'Muallif A.', 'title': 'Kitob', 'page': '12-b.'},
      ],
    },
    {
      'id': 'rib_shears',
      'group': 'morgue',
      'name': 'Qovurg‘a qaychisi',
      'what': 'Ko‘krak qafasini ochishda ishlatiladi.',
      'sources': [
        {'author': 'Muallif B.', 'title': 'Kitob', 'page': '5-b.'},
      ],
    },
    {
      // Manbasiz — paketga kirmaydi.
      'id': 'centrifuge',
      'group': 'lab',
      'name': 'Sentrifuga',
      'what': 'Manbasiz matn.',
      'sources': <Map<String, String>>[],
    },
  ],
};

void main() {
  test('manbasiz yozuv tashlab yuboriladi', () {
    final b = EquipmentBundle.fromJson(
      (jsonDecode(jsonEncode(_fixture)) as Map).cast<String, Object?>(),
    );
    expect(b.items.map((i) => i.id), ['gc_ms', 'rib_shears']);
    expect(b.of(EquipmentGroup.lab).single.methods, ['method-gcms']);
  });

  test('kartochka sarlavhasi: qisqa nom yuqorida', () {
    expect(tileTitle('Gaz xromatografi — mass-spektrometr (GC-MS)'), (
      'GC-MS',
      'Gaz xromatografi — mass-spektrometr',
    ));
    expect(
      tileTitle('Nafasdagi alkogolni o‘lchaydigan asbob (alkotester)').$1,
      'Alkotester',
    );
    expect(tileTitle('Yorug‘lik mikroskopi (sud-gistologiya)').$2, isNull);
  });

  final overrides = [
    equipmentLoaderProvider.overrideWithValue(() async => jsonEncode(_fixture)),
  ];

  testWidgets('hub: Laboratoriya → Morg, karta ochiladi', (t) async {
    await pumpApp(
      t,
      settings: completedSettings(lang: 'uz', mode: UserMode.professional),
      initialLocation: Routes.equipment,
      overrides: overrides,
    );
    await t.pumpAndSettle();
    expect(find.byKey(const Key('equipment.tile.gc_ms')), findsOneWidget);
    expect(find.byKey(const Key('equipment.tile.centrifuge')), findsNothing);
    await t.tap(find.byKey(const Key('equipment.group.morgue')));
    await t.pumpAndSettle();
    expect(find.byKey(const Key('equipment.tile.rib_shears')), findsOneWidget);
    await t.tap(find.byKey(const Key('equipment.tile.rib_shears')));
    await t.pumpAndSettle();
    expect(
      find.byKey(const Key('equipment.detail.rib_shears')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('equipment.illustrationNote')), findsOneWidget);
    expect(find.byKey(const Key('equipment.translationPending')), findsNothing);
    await t.scrollUntilVisible(
      find.byKey(const Key('equipment.source')),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Muallif B. Kitob. 5-b.'), findsOneWidget);
  });

  testWidgets('karta to‘g‘ridan-to‘g‘ri; ru — tarjima kutilmoqda', (t) async {
    await pumpApp(
      t,
      settings: completedSettings(lang: 'ru', mode: UserMode.professional),
      initialLocation: Routes.equipmentItem('gc_ms'),
      overrides: overrides,
    );
    await t.pumpAndSettle();
    expect(
      find.byKey(const Key('equipment.translationPending')),
      findsOneWidget,
    );
  });
}
