// Ustoz stolim → «Og‘zaki imtihon (bilet)»: kartochka tartibi, mavzu tanlash,
// bilet (dars slaydlaridan), 0–20 ball, saqlash, takrorlanmaslik, rejim
// himoyasi.
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/class_quiz.dart';
import 'package:forensic_expert/app/lessons.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/app/teacher_oral.dart';
import 'package:forensic_expert/core/settings/app_settings.dart';
import 'package:forensic_expert/data/class_quiz/fake_class_quiz_service.dart';
import 'package:forensic_expert/data/lessons/fake_lessons_service.dart';
import 'package:forensic_expert/domain/plan/plan_models.dart';
import 'package:forensic_expert/features/teacher_oral/presentation/teacher_oral_screens.dart';

import '../helpers/pump_app.dart';

Map<String, Object?> _deck(String id, String course, List<String> titles) => {
  'ok': true,
  'topic_id': id,
  'title': 'Mavzu $id',
  'course': course,
  'deck_id': '$id-deck',
  'source_lang': 'uz',
  'deck': {
    'topic': 'Mavzu $id',
    'slides': [
      for (final t in titles)
        {
          'title': t,
          'bullets': [
            {
              'text': '$t — asosiy fikr',
              'source': {'author': 'Aliyev', 'title': 'Kitob', 'page': '12'},
            },
          ],
        },
    ],
  },
};

final _decks = {
  'a1': _deck('a1', '4-kurs · Davolash', [
    'Kirish: mashg‘ulot maqsadi va rejasi',
    'Tan jarohatlarining yuridik tasnifi',
    'Hayot uchun xavf mezoni',
    'Sog‘liqning buzilish davomiyligi',
    'Tezkor savol 1: tasnif',
    'Sun’iy kasalliklar',
    'Sun’iy kasalliklar (davomi)',
    'Xulosa',
  ]),
  'b1': _deck('b1', '5-kurs · Davolash', [
    'Kirish',
    'Jinsni aniqlash',
    'Jinsiy yetuklikni aniqlash',
    'Homiladorlik va tug‘ruqni aniqlash',
    'Nasl qoldirish qobiliyatini aniqlash',
    'Nazorat savollari',
  ]),
};

Finder _key(String k) => find.byKey(Key(k));

Future<void> _tap(WidgetTester tester, Finder f) async {
  await Scrollable.ensureVisible(tester.element(f), alignment: 0.5);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => testDefaultPlan = Plan.expert);
  tearDownAll(() => testDefaultPlan = null);

  List<Override> overrides({
    bool teacher = true,
    Map<String, Map<String, Object?>>? decks,
  }) => [
    classQuizServiceProvider.overrideWithValue(
      FakeClassQuizService(
        FakeClassQuizBackend(teachers: {if (teacher) 't1'}),
        userId: 't1',
        demo: false,
      ),
    ),
    lessonsServiceProvider.overrideWithValue(
      FakeLessonsService(
        isTeacher: teacher,
        demo: false,
        decks: decks ?? _decks,
      ),
    ),
    teacherOralRandomProvider.overrideWithValue(math.Random(7)),
  ];

  testWidgets('Ustoz stolim: kartochka yozma testdan keyin, tartibli', (
    tester,
  ) async {
    await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz', mode: UserMode.teacher),
      overrides: overrides(),
    );
    await tester.pumpAndSettle();
    final ids = [
      'teachLessons',
      'teachRun',
      'teachOral',
      'teachGroups',
      'teachResults',
    ];
    final at = {
      for (final id in ids) id: tester.getTopLeft(_key('workbench.$id')),
    };
    // 2 ustun: Darslar | Guruh testi; Og‘zaki imtihon | Guruhlar; Natijalar.
    expect(at['teachLessons']!.dy, at['teachRun']!.dy);
    expect(at['teachOral']!.dy, at['teachGroups']!.dy);
    expect(at['teachOral']!.dy, greaterThan(at['teachRun']!.dy));
    expect(at['teachOral']!.dx, at['teachLessons']!.dx);
    expect(at['teachResults']!.dy, greaterThan(at['teachOral']!.dy));
    // Oxirgi yolg‘iz karta to‘liq kenglikda (bo‘sh katak yo‘q).
    final row = tester.getSize(_key('workbench.teachLessons')).width;
    expect(
      tester.getSize(_key('workbench.teachResults')).width,
      greaterThan(row * 1.5),
    );
    expect(find.text('Og‘zaki imtihon (bilet)'), findsOne);
    expect(find.text('Mavzu bo‘yicha 5 savollik bilet, baholaysiz'), findsOne);

    await _tap(tester, _key('workbench.teachOral'));
    expect(find.byType(TeacherOralTopicsScreen), findsOne);
  });

  testWidgets('mavzu tanlash → bilet → ball → saqlash → takrorlanmaydi', (
    tester,
  ) async {
    final c = await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz', mode: UserMode.teacher),
      overrides: overrides(),
      initialLocation: Routes.teacherOral,
    );
    await tester.pumpAndSettle();
    expect(_key('toral.intro'), findsOne);
    expect(find.text('4-kurs · Davolash'), findsOne);
    expect(find.text('5-kurs · Davolash'), findsOne);
    expect(
      tester.widget<FilledButton>(_key('toral.build')).onPressed,
      isNull,
      reason: 'mavzu tanlanmaguncha bilet tuzilmaydi',
    );
    expect(find.text('Avval kamida bitta mavzuni belgilang'), findsOne);

    await _tap(tester, _key('toral.topic.a1'));
    await _tap(tester, _key('toral.topic.b1'));
    expect(find.text('Tanlandi: 2 ta mavzu'), findsOne);
    await _tap(tester, _key('toral.build'));
    expect(find.byType(TeacherOralExamScreen), findsOne);

    // a1: 4 savol (kirish, tezkor savol, xulosa — yo‘q; davomi — qo‘shilgan),
    // b1: 4 savol.
    expect(find.text('Ishlatilgan savollar: 0 / 8'), findsOne);
    expect(find.text('Hozircha natija yo‘q'), findsOne);

    await _tap(tester, _key('oral.draw'));
    final first = c.read(teacherOralProvider).questionIds;
    expect(first, hasLength(5));
    expect(first.where((x) => x.startsWith('a1#')), isNotEmpty);
    expect(first.where((x) => x.startsWith('b1#')), isNotEmpty);
    expect(find.text('Bilet № 1'), findsOne);
    expect(find.text('Kirish: mashg‘ulot maqsadi va rejasi'), findsNothing);
    expect(tester.widget<FilledButton>(_key('oral.save')).onPressed, isNull);

    // Javob kaliti: slayd bandi va manbasi.
    await _tap(tester, _key('oral.key.0'));
    expect(find.textContaining('— asosiy fikr'), findsWidgets);
    expect(find.textContaining('Aliyev, Kitob'), findsWidgets);

    // Slayder bilan ball.
    final slider = _key('oral.slider.0');
    await tester.ensureVisible(slider);
    await tester.pumpAndSettle();
    await tester.tap(slider);
    await tester.pumpAndSettle();
    expect(c.read(teacherOralProvider).scores[0], isNotNull);

    final scores = [20, 18, 12, 10, 0];
    for (var i = 0; i < 5; i++) {
      c.read(teacherOralProvider.notifier).setScore(i, scores[i]);
    }
    await tester.pumpAndSettle();
    expect(find.text('Jami: 60 / 100'), findsOne);
    await tester.enterText(_key('oral.name'), 'Ali Valiyev');
    await tester.pumpAndSettle();
    await _tap(tester, _key('oral.save'));
    expect(find.text('Natija saqlandi: 60 / 100'), findsOne);
    expect(find.text('Ali Valiyev'), findsOne);
    expect(find.text('Ishlatilgan savollar: 5 / 8'), findsOne);
    final saved = c.read(teacherOralProvider).data.history.first;
    expect(saved.title, 'Mavzu a1 · Mavzu b1');
    expect(saved.total, 60);

    // Keyingi talaba: 3 ta yangi qoldi (< 5) — yangi aylanish, xabar bilan.
    await _tap(tester, _key('oral.draw'));
    expect(c.read(teacherOralProvider).questionIds, hasLength(5));
    expect(_key('oral.poolReset'), findsOne);
    expect(find.text('Bilet № 2'), findsOne);
  });

  testWidgets('bitta mavzu: savollar takrorlanmaydi', (tester) async {
    final c = await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz', mode: UserMode.teacher),
      overrides: overrides(
        decks: {
          'c1': _deck('c1', '4-kurs', [
            for (var i = 1; i <= 12; i++) 'Savolli slayd $i',
          ]),
        },
      ),
      initialLocation: Routes.teacherOralTicket('c1'),
    );
    await tester.pumpAndSettle();
    expect(find.text('Ishlatilgan savollar: 0 / 12'), findsOne);
    await _tap(tester, _key('oral.draw'));
    final first = c.read(teacherOralProvider).questionIds.toSet();
    for (var i = 0; i < 5; i++) {
      c.read(teacherOralProvider.notifier).setScore(i, 10);
    }
    await tester.pumpAndSettle();
    await _tap(tester, _key('oral.save'));
    await _tap(tester, _key('oral.draw'));
    final second = c.read(teacherOralProvider).questionIds.toSet();
    expect(second.intersection(first), isEmpty);
    expect(_key('oral.poolReset'), findsNothing);
  });

  testWidgets('savol yo‘q darslar: tushunarli xabar', (tester) async {
    await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz', mode: UserMode.teacher),
      overrides: overrides(
        decks: {
          'e1': _deck('e1', '4-kurs', ['Kirish', 'Xulosa']),
        },
      ),
      initialLocation: Routes.teacherOralTicket('e1'),
    );
    await tester.pumpAndSettle();
    expect(_key('toral.noQuestions'), findsOne);
  });

  for (final mode in [UserMode.student, UserMode.professional]) {
    testWidgets('${mode.name}: ustoz bileti ochilmaydi (Asosiyga qaytadi)', (
      tester,
    ) async {
      await pumpApp(
        tester,
        settings: completedSettings(lang: 'uz', mode: mode),
        overrides: overrides(),
        initialLocation: Routes.teacherOral,
      );
      await tester.pumpAndSettle();
      expect(find.byType(TeacherOralTopicsScreen), findsNothing);
      expect(_key('workbench.teachOral'), findsNothing);
    });
  }

  for (final lang in ['uz', 'ru', 'en']) {
    testWidgets('320 dp, 2.0 shrift, $lang: to‘lib ketmaydi', (tester) async {
      final c = await pumpApp(
        tester,
        settings: completedSettings(lang: lang, mode: UserMode.teacher),
        overrides: overrides(),
        initialLocation: Routes.teacherOral,
        size: const Size(320, 640),
        textScale: 2,
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: '$lang: tanlash');
      await tester.scrollUntilVisible(
        _key('toral.topic.a1'),
        200,
        scrollable: find
            .descendant(
              of: _key('toral.list'),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.pumpAndSettle();
      await tester.tap(_key('toral.topic.a1'));
      await tester.pumpAndSettle();
      await tester.tap(_key('toral.build'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        _key('oral.draw'),
        200,
        scrollable: find
            .descendant(
              of: _key('toral.ticketList'),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.pumpAndSettle();
      await tester.tap(_key('oral.draw'));
      await tester.pumpAndSettle();
      expect(c.read(teacherOralProvider).questionIds, hasLength(4));
      expect(tester.takeException(), isNull, reason: '$lang: bilet');
    });
  }
}
