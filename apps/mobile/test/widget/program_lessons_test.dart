// «Toksikologik kimyo» kursi mavzulari → ilovadagi ma’ruzalar (egasi
// skrinshotlari, 2026-11-07): ma’ruzali mavzuda «Tayyorlanmoqda» yo‘q, bosilsa
// «Darslar»dagi ko‘rgich ochiladi; Pro qulfi saqlanadi; Sud-kimyoviy
// ekspertiza sahifasida Toksikologik kimyo va Sud-tibbiy toksikologiya
// darslari ham bor.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/class_quiz.dart';
import 'package:forensic_expert/app/lessons.dart';
import 'package:forensic_expert/app/programs.dart';
import 'package:forensic_expert/app/router.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/settings/app_settings.dart';
import 'package:forensic_expert/data/class_quiz/fake_class_quiz_service.dart';
import 'package:forensic_expert/data/lessons/fake_lessons_service.dart';
import 'package:forensic_expert/domain/plan/plan_models.dart';
import 'package:forensic_expert/features/lessons/presentation/lesson_viewer_screen.dart';
import 'package:forensic_expert/features/lessons/presentation/lessons_list_screen.dart';

import '../helpers/plan_fakes.dart';
import '../helpers/pump_app.dart';

Map<String, Object?> _deck(String id, String course, String title) => {
  'ok': true,
  'topic_id': id,
  'title': title,
  'course': course,
  'deck_id': '$id-deck',
  'source_lang': 'uz',
  'deck': {
    'topic': title,
    'slides': [
      {
        'title': 'Slayd',
        'bullets': [
          {'text': 'Fikr'},
        ],
      },
    ],
    'sources': const <Object?>[],
  },
};

final _decks = {
  'toks-30-toks-gv-umumiy': _deck(
    'toks-30-toks-gv-umumiy',
    'Toksikologik kimyo',
    'Giyohvandlik vositalari, psixotrop moddalar va prekursorlar',
  ),
  'toks-34-toks-kokain': _deck(
    'toks-34-toks-kokain',
    'Toksikologik kimyo',
    'Kokain va kokain saqlovchi preparatlar',
  ),
  'sud-toks-08': _deck(
    'sud-toks-08',
    'Sud-tibbiy toksikologiya',
    'Narkotik vositalar va psixotrop moddalardan zaharlanish',
  ),
  'instr-01': _deck('instr-01', 'Apparatlar bilan ishlash', 'GX: etanol'),
};

void main() {
  Finder k(String key) => find.byKey(Key(key));

  Future<void> open(
    WidgetTester t,
    String route, {
    Plan? plan = Plan.teacher,
    String lang = 'uz',
    UserMode mode = UserMode.professional,
  }) async {
    final backend = FakeClassQuizBackend(teachers: {'t1'});
    final c = await pumpApp(
      t,
      settings: completedSettings(lang: lang, mode: mode),
      size: const Size(390, 2800),
      overrides: [
        if (plan != null) ...planOverrides(plan),
        programLoaderProvider.overrideWithValue(
          () async => File(toxChemProgramAsset).readAsStringSync(),
        ),
        classQuizServiceProvider.overrideWithValue(
          FakeClassQuizService(backend, userId: 't1', demo: false),
        ),
        lessonsServiceProvider.overrideWithValue(
          FakeLessonsService(isTeacher: false, demo: false, decks: _decks),
        ),
      ],
    );
    c.read(routerProvider).go(route);
    await t.pumpAndSettle();
  }

  Future<void> search(WidgetTester t, String q) async {
    await t.enterText(k('program.search'), q);
    await t.pumpAndSettle();
  }

  testWidgets('ma’ruzali mavzu: «Tayyorlanmoqda» yo‘q, ma’ruzalar ochiladi', (
    t,
  ) async {
    await open(t, Routes.program(toxChemProgramId));
    await search(t, 'polinarkomaniya');
    final tile = k('program.topic.tk-03');
    expect(tile, findsOneWidget);
    expect(
      find.descendant(of: tile, matching: find.text('Tayyorlanmoqda')),
      findsNothing,
    );
    expect(
      find.descendant(of: tile, matching: find.text('Mavjud')),
      findsOneWidget,
    );
    expect(k('program.lectures.tk-03'), findsOneWidget);
    expect(find.text('2 ta ma’ruza'), findsOneWidget);

    await t.tap(tile);
    await t.pumpAndSettle();
    expect(k('program.sheet'), findsOneWidget);
    expect(find.text('Ma’ruzalar: slayd va test'), findsOneWidget);
    // Nomlar «Darslar» ro‘yxatidan.
    expect(
      find.text('Narkotik vositalar va psixotrop moddalardan zaharlanish'),
      findsOneWidget,
    );
    await t.tap(k('program.link.lesson.sud-toks-08'));
    await t.pumpAndSettle();
    expect(find.byType(LessonViewerScreen), findsOneWidget);
    expect(find.text('Slayd'), findsWidgets);
  });

  testWidgets(
    'ma’ruza + boshqa materiallar: avval ma’ruza, so‘ng materiallar',
    (t) async {
      await open(t, Routes.program(toxChemProgramId));
      await search(t, 'Kokainni');
      await t.tap(k('program.topic.tk-34'));
      await t.pumpAndSettle();
      expect(k('program.sheet'), findsOneWidget);
      final lecture = k('program.link.lesson.toks-34-toks-kokain');
      final other = k('program.link.substances.stimulants');
      expect(other, findsOneWidget);
      expect(t.getTopLeft(lecture).dy, lessThan(t.getTopLeft(other).dy));
      await t.tap(lecture);
      await t.pumpAndSettle();
      expect(find.byType(LessonViewerScreen), findsOneWidget);
    },
  );

  testWidgets('mos ma’ruza yo‘q mavzu — «Tayyorlanmoqda» qoladi', (t) async {
    await open(t, Routes.program(toxChemProgramId));
    await search(t, 'So‘lak');
    expect(k('program.topic.tk-49'), findsOneWidget);
    expect(find.text('Tayyorlanmoqda'), findsOneWidget);
    expect(k('program.lectures.tk-49'), findsNothing);
  });

  testWidgets('Pro yo‘q: ma’ruza qulfda — ko‘rgich emas, Pro sahifasi', (
    t,
  ) async {
    await open(t, Routes.program(toxChemProgramId), plan: null);
    await search(t, 'Kokainni');
    await t.tap(k('program.topic.tk-34'));
    await t.pumpAndSettle();
    final lecture = k('program.link.lesson.toks-34-toks-kokain');
    expect(
      find.descendant(of: lecture, matching: find.byIcon(Icons.lock_outline)),
      findsOneWidget,
    );
    await t.tap(lecture);
    await t.pumpAndSettle();
    expect(k('program.sheet'), findsNothing);
    expect(find.byType(LessonViewerScreen), findsNothing);
  });

  for (final lang in ['ru', 'en']) {
    testWidgets('$lang: ma’ruzalar soni va bo‘lim nomi shu tilda', (t) async {
      await open(t, Routes.program(toxChemProgramId), lang: lang);
      await search(t, 'polinarkomaniya');
      expect(
        find.text(lang == 'ru' ? 'Лекций: 2' : '2 lectures'),
        findsOneWidget,
      );
      await t.tap(k('program.topic.tk-03'));
      await t.pumpAndSettle();
      expect(
        find.text(
          lang == 'ru' ? 'Лекции: слайды и тест' : 'Lectures: slides and test',
        ),
        findsOneWidget,
      );
    });
  }

  testWidgets('Sud-kimyoviy ekspertiza: Toksikologik kimyo, Sud-tibbiy '
      'toksikologiya va Apparatlar darslari; kurs ro‘yxatiga havola', (
    t,
  ) async {
    await open(t, Routes.module('toxicology'));
    expect(k('discipline.lessonsBody'), findsOneWidget);
    for (final id in ['toks-34-toks-kokain', 'sud-toks-08', 'instr-01']) {
      expect(k('discipline.lesson.$id'), findsOneWidget, reason: id);
    }
    expect(
      find.text('Farmatsiya fakulteti — Toksikologik kimyo · 2'),
      findsOneWidget,
    );
    expect(find.text('Sud-tibbiy toksikologiya · 1'), findsOneWidget);
    final link = k('discipline.courseList.Sud-tibbiy toksikologiya');
    await t.ensureVisible(link);
    await t.pumpAndSettle();
    await t.tap(link);
    await t.pumpAndSettle();
    expect(find.byType(LessonsListScreen), findsOneWidget);
    expect(k('lessons.row.sud-toks-08'), findsOneWidget);
    expect(k('lessons.row.toks-34-toks-kokain'), findsNothing);
  });
}
