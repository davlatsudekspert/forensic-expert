import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/instruments.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/settings/app_settings.dart';
import 'package:forensic_expert/domain/plan/plan_models.dart';

import '../helpers/pump_app.dart';

const _dir = 'assets/content/instruments/gc_ms';
final _parts = File('$_dir/gc_ms_parts_3lang.json').readAsStringSync();
final _card = File('$_dir/gc_ms_catalog_card_and_sources.json')
    .readAsStringSync();

List<Override> _overrides() => [
  gcMsLoaderProvider.overrideWithValue(() async => (_parts, _card)),
];

Finder _key(String k) => find.byKey(Key(k));

void main() {
  setUpAll(() => testDefaultPlan = Plan.expert);
  tearDownAll(() => testDefaultPlan = null);

  testWidgets('mutaxassis: Vositalar → GC-MS; rasm bilan izoh va «model emas» '
      'eslatmasi doim ko‘rinadi; qismlar 1–10 panelda', (tester) async {
    await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz'),
      overrides: _overrides(),
      initialLocation: Routes.tools,
    );
    await tester.tap(_key('tools.gcms'));
    await tester.pumpAndSettle();
    expect(_key('gcms.image'), findsOne);
    expect(find.text('Sxematik tasvir — aniq model emas'), findsOne);
    expect(
      find.textContaining('LabGuide chizgan original umumiy sinf sxemasi'),
      findsOne,
    );
    expect(_key('gcms.reviewPending'), findsOne);
    // Panel yopiq; ochilganda 10 ta qism va tamoyil/natija.
    await tester.ensureVisible(_key('gcms.panel'));
    await tester.tap(find.text('Qismlar va ishlash tamoyili'));
    await tester.pumpAndSettle();
    for (var i = 1; i <= 10; i++) {
      await tester.ensureVisible(_key('gcms.part.$i'));
      expect(_key('gcms.part.$i'), findsOne);
    }
    expect(find.text('Ishlash tamoyili'), findsOne);
    expect(find.text('Natija'), findsOne);
    // Manbali qo‘llanish jumlasi + manba.
    await tester.ensureVisible(_key('gcms.source'));
    expect(find.textContaining('StatPearls'), findsWidgets);
  });

  testWidgets('to‘liq ekran: zoom ko‘rinadi, izoh ham doim ko‘rinadi', (
    tester,
  ) async {
    await pumpApp(
      tester,
      settings: completedSettings(lang: 'ru'),
      overrides: _overrides(),
      initialLocation: Routes.gcms,
    );
    await tester.tap(_key('gcms.image'));
    await tester.pumpAndSettle();
    expect(_key('gcms.zoom'), findsOne);
    expect(
      find.text('Схематичное изображение — не фото конкретной модели'),
      findsOne,
    );
    await tester.tap(_key('gcms.close'));
    await tester.pumpAndSettle();
    expect(_key('gcms.zoom'), findsNothing);
  });

  for (final dark in [false, true]) {
    for (final lang in ['uz', 'ru', 'en']) {
      testWidgets('320 px, 2.0 shrift, ${dark ? 'qora' : 'yorug‘'}, $lang: '
          'overflow yo‘q', (tester) async {
        await pumpApp(
          tester,
          settings: completedSettings(
            lang: lang,
            theme: dark ? ThemeMode.dark : ThemeMode.light,
          ),
          size: const Size(320, 640),
          textScale: 2,
          platformBrightness: dark ? Brightness.dark : Brightness.light,
          overrides: _overrides(),
          initialLocation: Routes.gcms,
        );
        final scrollable = find.byKey(const Key('gcms.list'));
        await tester.scrollUntilVisible(
          find.byType(ExpansionTile),
          200,
          scrollable: find
              .descendant(of: scrollable, matching: find.byType(Scrollable))
              .first,
        );
        await Scrollable.ensureVisible(
          tester.element(find.byType(ExpansionTile)),
          alignment: 0.3,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byType(ExpansionTile));
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          _key('gcms.part.10'),
          300,
          scrollable: find
              .descendant(of: scrollable, matching: find.byType(Scrollable))
              .first,
        );
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('talaba va ustoz rejimida plitka yo‘q', (tester) async {
    for (final m in [UserMode.student, UserMode.teacher]) {
      await pumpApp(
        tester,
        settings: completedSettings(lang: 'uz', mode: m),
        overrides: _overrides(),
        initialLocation: Routes.tools,
      );
      expect(_key('tools.gcms'), findsNothing);
      await tester.pumpWidget(const SizedBox());
    }
  });
}
