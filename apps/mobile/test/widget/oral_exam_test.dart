import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/assessment.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/domain/plan/plan_models.dart';

import '../helpers/pump_app.dart';

final _pack = File('assets/content/assessment/assessment_v1.json')
    .readAsStringSync();
final _oral = {
  for (final id in ['sud_tib', 'pat_anat', 'sud_kimyo'])
    id: File('assets/content/assessment/oral_$id.json').readAsStringSync(),
};

List<Override> _overrides() => [
  assessmentLoaderProvider.overrideWithValue(() async => _pack),
  oralLoaderProvider.overrideWithValue((id) async => _oral[id]!),
  oralExamRandomProvider.overrideWithValue(math.Random(42)),
];

Finder _key(String k) => find.byKey(Key(k));

Future<void> _tapCentered(WidgetTester tester, Finder f) async {
  await Scrollable.ensureVisible(tester.element(f), alignment: 0.5);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

int _catSize(String spec, String cat) {
  final p = jsonDecode(_pack) as Map<String, Object?>;
  final s = (p['specialties']! as List).cast<Map<String, Object?>>().firstWhere(
    (x) => x['id'] == spec,
  );
  final c = (s['categories']! as List).cast<Map<String, Object?>>().firstWhere(
    (x) => x['id'] == cat,
  );
  return (c['questions']! as List).length;
}

void main() {
  setUpAll(() => testDefaultPlan = Plan.expert);
  tearDownAll(() => testDefaultPlan = null);

  testWidgets('imtihon kartasi: toifa sahifasidan ochiladi', (tester) async {
    await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz'),
      overrides: _overrides(),
      initialLocation: Routes.assessmentSpecialty('sud_kimyo'),
    );
    await tester.pump();
    await tester.pump();
    expect(find.text('Og‘zaki imtihon (bilet)'), findsOne);
    await _tapCentered(tester, _key('assessment.oralExam'));
    expect(_key('oral.draw'), findsOne);
    expect(find.text('Bilet chiqarish'), findsOne);
  });

  testWidgets('bilet → ballar → saqlash → keyingi bilet takrorlanmaydi; '
      'tarix va tozalash', (tester) async {
    final c = await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz'),
      overrides: _overrides(),
      initialLocation: Routes.assessmentExam('sud_kimyo', 'c23'),
    );
    await tester.pump();
    await tester.pump();
    final total = _catSize('sud_kimyo', 'c23');
    expect(find.text('Ishlatilgan savollar: 0 / $total'), findsOne);
    expect(find.text('Hozircha natija yo‘q'), findsOne);

    await _tapCentered(tester, _key('oral.draw'));
    final first = c.read(oralExamProvider).questionIds;
    expect(first.length, 5);
    expect(find.text('Bilet № 1'), findsOne);
    for (var i = 0; i < 5; i++) {
      expect(_key('oral.q.$i'), findsOne);
    }
    expect(find.text('Jami: 0 / 100'), findsOne);
    expect(
      tester.widget<FilledButton>(_key('oral.save')).onPressed,
      isNull,
      reason: 'hamma savolga ball qo‘yilmaguncha saqlab bo‘lmaydi',
    );

    // Slayder: bitta savolga ball qo‘yiladi.
    final slider = _key('oral.slider.0');
    await tester.ensureVisible(slider);
    await tester.pumpAndSettle();
    await tester.tap(slider);
    await tester.pumpAndSettle();
    expect(c.read(oralExamProvider).scores[0], isNotNull);

    final scores = [20, 15, 10, 5, 0];
    for (var i = 0; i < 5; i++) {
      c.read(oralExamProvider.notifier).setScore(i, scores[i]);
    }
    await tester.pumpAndSettle();
    expect(find.text('Jami: 50 / 100'), findsOne);
    await tester.enterText(_key('oral.name'), 'Ali Valiyev');
    await tester.pumpAndSettle();
    await _tapCentered(tester, _key('oral.save'));
    expect(find.text('Natija saqlandi: 50 / 100'), findsOne);
    expect(_key('oral.draw'), findsOne, reason: 'bilet maydoni bo‘shadi');
    expect(find.text('Ali Valiyev'), findsOne);
    expect(find.text('50 / 100'), findsOne);
    expect(find.text('Ishlatilgan savollar: 5 / $total'), findsOne);

    // Keyingi talaba: boshqa savollar.
    await _tapCentered(tester, _key('oral.draw'));
    final second = c.read(oralExamProvider).questionIds;
    expect(second.toSet().intersection(first.toSet()), isEmpty);
    expect(find.text('Bilet № 2'), findsOne);

    // Tarixni tozalash.
    await _tapCentered(tester, _key('oral.clearHistory'));
    await tester.tap(_key('oral.clearConfirm'));
    await tester.pumpAndSettle();
    expect(find.text('Ali Valiyev'), findsNothing);
    expect(find.text('Hozircha natija yo‘q'), findsOne);

    // Aylanishni qaytadan boshlash.
    await _tapCentered(tester, _key('oral.resetPool'));
    expect(find.text('Ishlatilgan savollar: 0 / $total'), findsOne);
  });

  testWidgets('320 dp, 2.0 shrift, uch til: bilet ekrani to‘lib ketmaydi', (
    tester,
  ) async {
    for (final lang in ['uz', 'ru', 'en']) {
      final c = await pumpApp(
        tester,
        settings: completedSettings(lang: lang),
        overrides: _overrides(),
        initialLocation: Routes.assessmentExam('sud_tib', 'c1'),
        size: const Size(320, 640),
        textScale: 2,
      );
      await tester.pump();
      await tester.pump();
      await tester.tap(_key('oral.draw'));
      await tester.pumpAndSettle();
      expect(c.read(oralExamProvider).questionIds.length, 5);
      expect(tester.takeException(), isNull, reason: lang);
    }
  });
}
