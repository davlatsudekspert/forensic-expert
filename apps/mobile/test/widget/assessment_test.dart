import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/assessment.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/settings/app_settings.dart';
import 'package:forensic_expert/domain/plan/plan_models.dart';

import '../helpers/pump_app.dart';

/// Haqiqiy savollar paketi (ilova asset’i) — fake-async zonadan tashqarida.
final _pack = File('assets/content/assessment/assessment_v1.json')
    .readAsStringSync();

List<Override> _overrides() => [
  assessmentLoaderProvider.overrideWithValue(() async => _pack),
];

Finder _key(String k) => find.byKey(Key(k));

Future<void> _scrollTo(WidgetTester tester, Finder f) async {
  await tester.scrollUntilVisible(
    f,
    300,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

/// Elementni ekran o‘rtasiga olib kelib bosadi (pastki menyu ortida qolmasin).
Future<void> _tapCentered(WidgetTester tester, Finder f) async {
  await Scrollable.ensureVisible(tester.element(f), alignment: 0.5);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => testDefaultPlan = Plan.expert);
  tearDownAll(() => testDefaultPlan = null);

  testWidgets('mutaxassis: Home → «Bilim va malakani baholash» → mutaxassislik '
      '→ toifa → savol → tayyor belgisi (ogohlantirishlarsiz)', (tester) async {
    final c = await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz'),
      overrides: _overrides(),
    );
    final tile = _key('home.assessment');
    await _scrollTo(tester, tile);
    expect(
      find.descendant(
        of: tile,
        matching: find.text('Bilim va malakani baholash'),
      ),
      findsOne,
    );
    await tester.tap(tile);
    await tester.pumpAndSettle();

    // Hub: uchta mutaxassislik, ogohlantirish matnlari yo‘q.
    for (final id in ['sud_tib', 'pat_anat', 'sud_kimyo']) {
      expect(_key('assessment.spec.$id'), findsOne);
    }
    expect(find.textContaining('kafolat'), findsNothing);
    expect(find.textContaining('rasmiy imtihon savollari emas'), findsNothing);
    expect(find.textContaining('Toifaga tayyorlanish'), findsNothing);

    await tester.tap(_key('assessment.spec.sud_kimyo'));
    await tester.pumpAndSettle();
    for (final cat in ['c23', 'c1', 'c0']) {
      expect(_key('assessment.cat.$cat'), findsOne);
    }
    // Qidiruv: bitta savol qoladi/kamayadi; birinchi natijani ochamiz.
    final q = _key('assessment.q.sud_kimyo.c23.001');
    expect(q, findsOne);
    await tester.enterText(_key('assessment.search'), 'zaharsiz toifa yo‘q');
    await tester.pumpAndSettle();
    expect(q, findsNothing);
    expect(find.text('Hech narsa topilmadi'), findsOne);
    await tester.enterText(_key('assessment.search'), '');
    await tester.pumpAndSettle();

    await tester.tap(q);
    await tester.pumpAndSettle();
    expect(_key('assessment.detail.sud_kimyo.c23.001'), findsOne);
    await tester.tap(_key('assessment.markReady'));
    await tester.pumpAndSettle();
    expect(c.read(assessmentProgressProvider), contains('sud_kimyo.c23.001'));
    expect(find.text('Belgini olib tashlash'), findsOne);
    expect(_key('assessment.askAi'), findsOne);
  });

  testWidgets('test mashqi: kalitli savollar, javob → izoh, yakuniy natija', (
    tester,
  ) async {
    await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz'),
      overrides: _overrides(),
      initialLocation: Routes.assessmentSpecialty('sud_kimyo'),
    );
    await tester.tap(find.text('Testlar'));
    await tester.pumpAndSettle();
    expect(_key('assessment.testsHeader'), findsOne);
    await tester.tap(_key('assessment.testStart'));
    await tester.pumpAndSettle();
    expect(find.text('1 / 20'), findsOne);
    for (var i = 0; i < 20; i++) {
      await _tapCentered(tester, _key('assessment.opt.0'));
      expect(_key('assessment.verdict'), findsOne);
      await _tapCentered(tester, _key('assessment.next'));
    }
    expect(_key('assessment.score'), findsOne);
    expect(_key('assessment.retry'), findsOne);
  });

  testWidgets('«Foydalanilgan adabiyotlar»: kitob, ustoz banki va jahon '
      'adabiyoti; javobda asos iqtibosi ko‘rinadi', (tester) async {
    await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz'),
      overrides: _overrides(),
      initialLocation: Routes.assessment,
    );
    await tester.tap(_key('assessment.sourcesEntry'));
    await tester.pumpAndSettle();
    expect(_key('assessment.sources'), findsOne);
    expect(find.text('Darsliklar va qo‘llanmalar'), findsOne);
    expect(find.text('Ustoz taqdim etgan test banki'), findsOne);
    expect(find.text('Jahon adabiyoti va qonunchilik'), findsOne);
    expect(find.textContaining('G‘iyosov'), findsWidgets);
    expect(find.textContaining('lex.uz'), findsWidgets);
    expect(find.textContaining('tasdiqlanmagan'), findsNothing);
  });

  testWidgets('talaba: bo‘lim yo‘q — Home’da plitka yo‘q, havola Asosiyga', (
    tester,
  ) async {
    await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz', mode: UserMode.student),
      overrides: _overrides(),
      initialLocation: Routes.assessment,
    );
    expect(_key('assessment.hub'), findsNothing);
    expect(_key('home.assessment'), findsNothing);
  });

  testWidgets('ustoz rejimida ham bor; ru/en nomlar', (tester) async {
    for (final (lang, name) in [
      ('ru', 'Проверка знаний и компетенций'),
      ('en', 'Knowledge & Skills Assessment'),
    ]) {
      await pumpApp(
        tester,
        settings: completedSettings(lang: lang, mode: UserMode.teacher),
        overrides: _overrides(),
      );
      final tile = _key('home.assessment');
      await _scrollTo(tester, tile);
      expect(find.descendant(of: tile, matching: find.text(name)), findsOne);
      await tester.pumpWidget(const SizedBox());
    }
  });
}
