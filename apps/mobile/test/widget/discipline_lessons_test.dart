// Fan sahifasidagi «Darslar: prezentatsiya va guruh testi» bo‘limi va «Ustoz»
// rejimi (egasi topshirig‘i, 2026-10-24).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/class_quiz.dart';
import 'package:forensic_expert/app/lessons.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/settings/app_settings.dart';
import 'package:forensic_expert/data/class_quiz/fake_class_quiz_service.dart';
import 'package:forensic_expert/data/lessons/fake_lessons_service.dart';
import 'package:forensic_expert/features/class_groups/presentation/lesson_group_test_screen.dart';
import 'package:forensic_expert/features/lessons/presentation/lesson_viewer_screen.dart';

import '../helpers/pump_app.dart';

Map<String, Object?> _deck(String id, String course) => {
  'ok': true,
  'topic_id': id,
  'title': 'Dars $id',
  'course': course,
  'deck_id': '$id-deck',
  'source_lang': 'uz',
  'deck': {
    'topic': 'Dars $id',
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

void main() {
  /// Elementni ko‘rinadigan va suzuvchi menyu ostida qolmaydigan joyga suradi.
  Future<void> reveal(WidgetTester tester, String code, Finder f) async {
    await tester.ensureVisible(f);
    await tester.pumpAndSettle();
    final dy = tester.getCenter(f).dy;
    if (dy > 640) {
      await tester.drag(
        find.byKey(Key('disciplineDetail.$code')),
        Offset(0, 500 - dy),
      );
      await tester.pumpAndSettle();
    }
  }

  Future<void> open(
    WidgetTester tester, {
    required String code,
    bool teacher = true,
    UserMode mode = UserMode.professional,
  }) async {
    final backend = FakeClassQuizBackend(teachers: {if (teacher) 't1'});
    await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz', mode: mode),
      initialLocation: Routes.discipline(code),
      overrides: [
        classQuizServiceProvider.overrideWithValue(
          FakeClassQuizService(backend, userId: 't1', demo: false),
        ),
        lessonsServiceProvider.overrideWithValue(
          FakeLessonsService(
            isTeacher: teacher,
            demo: false,
            decks: {
              'toks-01': _deck('toks-01', 'Toksikologik kimyo'),
              'instr-01': _deck('instr-01', 'Apparatlar bilan ishlash'),
              'ktp-01': _deck('ktp-01', 'Davolash ishi fakulteti'),
            },
          ),
        ),
      ],
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'ustoz: toksikologiya — faqat o‘z darslari, guruh testi tugmasi',
    (tester) async {
      await open(tester, code: 'forensic_toxicology');
      expect(find.byKey(const Key('discipline.lessonsBody')), findsOneWidget);
      expect(
        find.byKey(const Key('discipline.lesson.toks-01')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('discipline.lesson.instr-01')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('discipline.lesson.ktp-01')), findsNothing);
      expect(find.text('Toksikologik kimyo'), findsOneWidget);
      expect(find.text('Apparatlar bilan ishlash'), findsOneWidget);

      await reveal(
        tester,
        'forensic_toxicology',
        find.byKey(const Key('discipline.lessonTest.toks-01')),
      );
      await tester.tap(find.byKey(const Key('discipline.lessonTest.toks-01')));
      await tester.pumpAndSettle();
      expect(find.byType(LessonGroupTestScreen), findsOneWidget);
    },
  );

  testWidgets('ustoz: sud tibbiyoti — fakultet darslari, dars ochiladi', (
    tester,
  ) async {
    await open(tester, code: 'forensic_medicine');
    expect(find.byKey(const Key('discipline.lesson.ktp-01')), findsOneWidget);
    expect(find.byKey(const Key('discipline.lesson.toks-01')), findsNothing);
    await reveal(
      tester,
      'forensic_medicine',
      find.byKey(const Key('discipline.lesson.ktp-01')),
    );
    await tester.tap(find.byKey(const Key('discipline.lesson.ktp-01')));
    await tester.pumpAndSettle();
    expect(find.byType(LessonViewerScreen), findsOneWidget);
  });

  testWidgets('ustoz rejimi, server roli yo‘q — rolni olish havolasi', (
    tester,
  ) async {
    await open(
      tester,
      code: 'forensic_toxicology',
      teacher: false,
      mode: UserMode.teacher,
    );
    expect(
      find.byKey(const Key('discipline.lessonsTeacherOnly')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('discipline.lesson.toks-01')), findsNothing);
  });

  testWidgets('mutaxassis, rol yo‘q — bo‘lim ko‘rinmaydi', (tester) async {
    await open(tester, code: 'forensic_toxicology', teacher: false);
    expect(find.byKey(const Key('discipline.lessonsBody')), findsNothing);
    expect(
      find.byKey(const Key('discipline.lessonsTeacherOnly')),
      findsNothing,
    );
  });

  testWidgets('boshqa fan (genetika) — darslar bo‘limi yo‘q', (tester) async {
    await open(tester, code: 'forensic_genetics');
    expect(find.byKey(const Key('discipline.lessonsBody')), findsNothing);
  });
}
