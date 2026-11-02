import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/assessment.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/settings/app_settings.dart';
import 'package:forensic_expert/domain/assessment/assessment_test_stats.dart';
import 'package:forensic_expert/domain/plan/plan_models.dart';

import '../helpers/pump_app.dart';

/// Haqiqiy savollar paketi (ilova asset’i) — fake-async zonadan tashqarida.
final _pack = File('assets/content/assessment/assessment_v1.json')
    .readAsStringSync();

/// Og‘zaki javoblar (mutaxassislik bo‘yicha) — haqiqiy asset’lar.
final _oral = {
  for (final id in ['sud_tib', 'pat_anat', 'sud_kimyo'])
    id: File('assets/content/assessment/oral_$id.json').readAsStringSync(),
};

List<Override> _overrides() => [
  assessmentLoaderProvider.overrideWithValue(() async => _pack),
  oralLoaderProvider.overrideWithValue((id) async => _oral[id]!),
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

/// (javobi bor savol, javobi yo‘q savol) — haqiqiy paketdan.
(String, String) _answeredAndSoon() {
  final pack = jsonDecode(_pack) as Map<String, Object?>;
  final spec = (pack['specialties']! as List)
      .cast<Map<String, Object?>>()
      .firstWhere((s) => s['id'] == 'pat_anat');
  final answers =
      (jsonDecode(_oral['pat_anat']!) as Map<String, Object?>)['answers']!
          as Map<String, Object?>;
  String? yes;
  String? no;
  for (final c in (spec['categories']! as List).cast<Map<String, Object?>>()) {
    for (final q in (c['questions']! as List).cast<Map<String, Object?>>()) {
      final id = q['id']! as String;
      if (answers.containsKey(id)) {
        yes ??= id;
      } else {
        no ??= id;
      }
    }
  }
  return (yes!, no!);
}

/// To‘g‘ri variantni bosadi (savol matni bo‘yicha paketdan kalitni topadi).
Future<void> _answerQ(
  WidgetTester tester, {
  required bool right,
  bool settle = true,
}) async {
  final pack = jsonDecode(_pack) as Map<String, Object?>;
  final spec = (pack['specialties']! as List)
      .cast<Map<String, Object?>>()
      .firstWhere((s) => s['id'] == 'sud_kimyo');
  final texts = <String, int>{
    for (final q in (spec['tests']! as List).cast<Map<String, Object?>>())
      if (q['key'] is int) q['text']! as String: q['key']! as int,
  };
  int? key;
  for (final e in texts.entries) {
    if (find.text(e.key).evaluate().isNotEmpty) key = e.value;
  }
  expect(key, isNotNull);
  final idx = right ? key! : (key! + 1) % 4;
  final f = _key('assessment.opt.$idx');
  await Scrollable.ensureVisible(tester.element(f), alignment: 0.5);
  await tester.pump();
  await tester.tap(f);
  await (settle ? tester.pumpAndSettle() : tester.pump());
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
    await _tapCentered(tester, _key('assessment.markReady'));
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
    // Bir mashqda 50 ta savol (egasi, 2026-11-02).
    expect(find.text('1 / 50'), findsOne);
    for (var i = 0; i < 50; i++) {
      await _tapCentered(tester, _key('assessment.opt.0'));
      expect(_key('assessment.verdict'), findsOne);
      await _tapCentered(tester, _key('assessment.next'));
    }
    expect(_key('assessment.score'), findsOne);
    expect(_key('assessment.retry'), findsOne);
  });

  testWidgets(
    'rejimlar ro‘yxati: aralash, bloklab, xatolarim (0 — o‘chirilgan), '
    'imtihon; o‘zlashtirildi qatori',
    (tester) async {
      await pumpApp(
        tester,
        settings: completedSettings(lang: 'uz'),
        overrides: _overrides(),
        initialLocation: Routes.assessmentSpecialty('sud_kimyo'),
      );
      await tester.tap(find.text('Testlar'));
      await tester.pumpAndSettle();
      expect(_key('assessment.testStart'), findsOne);
      expect(_key('assessment.mode.blocks'), findsOne);
      expect(_key('assessment.mode.exam'), findsOne);
      expect(find.text('Xatolarim (0)'), findsOne);
      expect(find.textContaining('Hozircha xato yo‘q'), findsOne);
      expect(find.textContaining('O‘zlashtirildi: 0 / '), findsOne);
      // Xatolarim 0 bo‘lsa bosilmaydi.
      await tester.tap(_key('assessment.mode.mistakes'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(_key('assessment.testsHeader'), findsOne);
      expect(_key('assessment.run.sud_kimyo'), findsNothing);
    },
  );

  testWidgets(
    'bloklab yechish: bloklar ro‘yxati, blok tartib bilan, eng yaxshi '
    'ball saqlanadi',
    (tester) async {
      final c = await pumpApp(
        tester,
        settings: completedSettings(lang: 'uz'),
        overrides: _overrides(),
        initialLocation: Routes.assessmentSpecialty('sud_kimyo'),
      );
      await tester.tap(find.text('Testlar'));
      await tester.pumpAndSettle();
      await _tapCentered(tester, _key('assessment.mode.blocks'));
      expect(_key('assessment.blocks.sud_kimyo'), findsOne);
      expect(find.text('Savollar 1–50'), findsOne);
      expect(find.text('Savollar 51–100'), findsOne);
      expect(find.text('Yechilmagan'), findsWidgets);
      await tester.tap(_key('assessment.block.0'));
      await tester.pumpAndSettle();
      expect(find.text('1 / 50'), findsOne);
      // Birinchi savol — blokdagi eng kichik raqamli savol.
      final pack = jsonDecode(_pack) as Map<String, Object?>;
      final spec = (pack['specialties']! as List)
          .cast<Map<String, Object?>>()
          .firstWhere((s) => s['id'] == 'sud_kimyo');
      final graded =
          (spec['tests']! as List)
              .cast<Map<String, Object?>>()
              .where((q) => q['key'] is int)
              .toList()
            ..sort((a, b) => (a['n']! as int).compareTo(b['n']! as int));
      expect(find.text(graded.first['text']! as String), findsOne);
      // 50 tadan 1 tasi to‘g‘ri, qolgani noto‘g‘ri.
      for (var i = 0; i < 50; i++) {
        await _answerQ(tester, right: i == 0);
        expect(_key('assessment.verdict'), findsOne);
        await _tapCentered(tester, _key('assessment.next'));
      }
      expect(c.read(assessmentTestStatsProvider).bestScore('sud_kimyo', 0), 1);
      expect(c.read(assessmentTestStatsProvider).mistakeCount('sud_kimyo'), 49);
      // Orqaga: blok ro‘yxatida natija ko‘rinadi.
      final router = tester.element(_key('assessment.score'));
      Navigator.of(router).pop();
      await tester.pumpAndSettle();
      expect(find.text('Eng yaxshi: 1/50'), findsOne);
    },
  );

  testWidgets('xatolarim: ketma-ket 2 to‘g‘ri javobdan keyin chiqadi, xato '
      'seriyani 0 qiladi', (tester) async {
    final pack = jsonDecode(_pack) as Map<String, Object?>;
    final spec = (pack['specialties']! as List)
        .cast<Map<String, Object?>>()
        .firstWhere((s) => s['id'] == 'sud_kimyo');
    final id =
        (spec['tests']! as List).cast<Map<String, Object?>>().firstWhere(
              (q) => q['key'] is int,
            )['id']!
            as String;
    final store = InMemoryAssessmentTestStatsStore();
    await store.save(
      AssessmentTestStats.empty.recordAnswer('sud_kimyo', id, isCorrect: false),
    );
    final c = await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz'),
      overrides: [
        ..._overrides(),
        assessmentTestStatsStoreProvider.overrideWithValue(store),
      ],
      initialLocation: Routes.assessmentSpecialty('sud_kimyo'),
    );
    await tester.tap(find.text('Testlar'));
    await tester.pumpAndSettle();
    expect(find.text('Xatolarim (1)'), findsOne);
    await _tapCentered(tester, _key('assessment.mode.mistakes'));
    expect(find.text('1 / 1'), findsOne);
    // 1-to‘g‘ri: hali ro‘yxatda.
    await _answerQ(tester, right: true);
    expect(c.read(assessmentTestStatsProvider).mistakes['sud_kimyo']![id], 1);
    await _tapCentered(tester, _key('assessment.next'));
    // Qayta: bu safar xato — seriya 0.
    await _tapCentered(tester, _key('assessment.retry'));
    await _answerQ(tester, right: false);
    expect(c.read(assessmentTestStatsProvider).mistakes['sud_kimyo']![id], 0);
    await _tapCentered(tester, _key('assessment.next'));
    // Ketma-ket ikkita to‘g‘ri: ro‘yxatdan chiqadi.
    await _tapCentered(tester, _key('assessment.retry'));
    await _answerQ(tester, right: true);
    await _tapCentered(tester, _key('assessment.next'));
    expect(c.read(assessmentTestStatsProvider).mistakeCount('sud_kimyo'), 1);
    await _tapCentered(tester, _key('assessment.retry'));
    await _answerQ(tester, right: true);
    expect(c.read(assessmentTestStatsProvider).mistakeCount('sud_kimyo'), 0);
    expect(
      c.read(assessmentTestStatsProvider).masteredCount('sud_kimyo', [id]),
      1,
    );
  });

  testWidgets('imtihon rejimi: taymer ko‘rinadi, javob paytida natija yo‘q, '
      'oxirida ball va xatolar ro‘yxati; xatolar «Xatolarim»ga tushadi', (
    tester,
  ) async {
    final c = await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz'),
      overrides: _overrides(),
      initialLocation: Routes.assessmentTest('sud_kimyo', mode: 'exam'),
    );
    await tester.pump();
    await tester.pump();
    expect(_key('assessment.timer'), findsOne);
    expect(find.text('60:00'), findsOne);
    await tester.pump(const Duration(seconds: 5));
    expect(find.text('59:55'), findsOne);
    expect(find.text('1 / 50'), findsOne);
    for (var i = 0; i < 50; i++) {
      await _answerQ(tester, right: i < 40, settle: false);
      expect(_key('assessment.verdict'), findsNothing);
      expect(find.text('To‘g‘ri'), findsNothing);
      expect(_key('assessment.examHint'), findsOne);
      final next = _key('assessment.next');
      await Scrollable.ensureVisible(tester.element(next), alignment: 0.5);
      await tester.pump();
      await tester.tap(next);
      await tester.pump();
    }
    await tester.pumpAndSettle();
    expect(_key('assessment.score'), findsOne);
    expect(find.text('40 / 50 to‘g‘ri'), findsOne);
    expect(_key('assessment.timer'), findsNothing);
    expect(find.text('Xatolar tahlili'), findsOne);
    expect(c.read(assessmentTestStatsProvider).mistakeCount('sud_kimyo'), 10);
  });

  testWidgets('imtihon rejimi: vaqt tugasa avtomatik yakunlanadi', (
    tester,
  ) async {
    await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz'),
      overrides: _overrides(),
      initialLocation: Routes.assessmentTest('sud_kimyo', mode: 'exam'),
    );
    await tester.pump();
    await tester.pump();
    await _answerQ(tester, right: true, settle: false);
    await tester.pump(const Duration(minutes: 60));
    await tester.pumpAndSettle();
    expect(_key('assessment.timeUp'), findsOne);
    expect(find.text('Vaqt tugadi'), findsOne);
    expect(find.text('1 / 50 to‘g‘ri'), findsOne);
  });

  testWidgets('noma’lum rejim — aralash; eski havola ishlaydi', (tester) async {
    await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz'),
      overrides: _overrides(),
      initialLocation: '/library/assessment/sud_kimyo/test?mode=zzz&b=x',
    );
    await tester.pumpAndSettle();
    expect(find.text('1 / 50'), findsOne);
    expect(_key('assessment.timer'), findsNothing);
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

  testWidgets('ustozda yo‘q; mutaxassisda ru/en nomlar', (tester) async {
    await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz', mode: UserMode.teacher),
      overrides: _overrides(),
      initialLocation: Routes.assessment,
    );
    expect(_key('assessment.hub'), findsNothing);
    expect(_key('home.assessment'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    for (final (lang, name) in [
      ('ru', 'Проверка знаний и компетенций'),
      ('en', 'Knowledge & Skills Assessment'),
    ]) {
      await pumpApp(
        tester,
        settings: completedSettings(lang: lang),
        overrides: _overrides(),
      );
      final tile = _key('home.assessment');
      await _scrollTo(tester, tile);
      expect(find.descendant(of: tile, matching: find.text(name)), findsOne);
      await tester.pumpWidget(const SizedBox());
    }
  });

  testWidgets('og‘zaki savol: javobi bor — bandlar va manba oynasi; yo‘q — '
      '«tez kunda»', (tester) async {
    final (yes, no) = _answeredAndSoon();
    await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz'),
      overrides: _overrides(),
      initialLocation: Routes.assessmentQuestion('pat_anat', yes),
    );
    expect(_key('assessment.answer'), findsOne);
    expect(_key('assessment.answerNote'), findsOne);
    expect(find.text('Javob (adabiyot asosida)'), findsOne);
    expect(_key('assessment.answerSoon'), findsNothing);
    // Birinchi bandning manbasi — iqtibos bilan alohida oynada.
    await tester.tap(find.byIcon(Icons.menu_book_outlined).first);
    await tester.pumpAndSettle();
    expect(_key('assessment.sourceSheet'), findsOne);
    expect(find.text('Asl matn'), findsOne);

    await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz'),
      overrides: _overrides(),
      initialLocation: Routes.assessmentQuestion('pat_anat', no),
    );
    expect(_key('assessment.answerSoon'), findsOne);
    expect(find.text('Javob tez kunda qo‘shiladi'), findsOne);
    expect(_key('assessment.answer'), findsNothing);
  });

  testWidgets('javob ekrani: eng uzun javoblar 320 px / 2.0 shrift / uch til / '
      'qorong‘i rejimda xatosiz chiqadi', (tester) async {
    // Har mutaxassislikdan eng ko‘p bandli javob.
    final ids = <(String, String)>[];
    for (final spec in ['sud_tib', 'pat_anat', 'sud_kimyo']) {
      final answers =
          (jsonDecode(_oral[spec]!) as Map<String, Object?>)['answers']!
              as Map<String, Object?>;
      String? best;
      var n = -1;
      for (final e in answers.entries) {
        final len = ((e.value! as Map<String, Object?>)['p']! as List).length;
        if (len > n) {
          n = len;
          best = e.key;
        }
      }
      ids.add((spec, best!));
    }
    for (final (spec, id) in ids) {
      for (final lang in ['uz', 'ru', 'en']) {
        await pumpApp(
          tester,
          settings: completedSettings(lang: lang),
          overrides: _overrides(),
          size: const Size(320, 640),
          textScale: 2,
          platformBrightness: Brightness.dark,
          initialLocation: Routes.assessmentQuestion(spec, id),
        );
        expect(_key('assessment.answer'), findsOne, reason: '$spec $lang');
        expect(tester.takeException(), isNull, reason: '$spec $lang');
        // Oxirigacha aylantirib chiqamiz — render xatosi bo‘lmasin.
        final scroll = find.byType(Scrollable).first;
        await tester.drag(scroll, const Offset(0, -6000));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '$spec $lang end');
        await tester.pumpWidget(const SizedBox());
      }
    }
  });
}
