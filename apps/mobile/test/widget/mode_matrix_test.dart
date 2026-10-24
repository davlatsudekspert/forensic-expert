import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/class_quiz.dart';
import 'package:forensic_expert/app/lessons.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/settings/app_settings.dart';
import 'package:forensic_expert/data/class_quiz/fake_class_quiz_service.dart';
import 'package:forensic_expert/features/lessons/presentation/lessons_list_screen.dart';

import '../helpers/pump_app.dart';

/// Rejimlar matritsasi (egasi talabi, 2026-10-24): Ustoz paneli va ustoz
/// darslari faqat «Ustoz» rejimida; server roli (admin) buni o‘zgartirmaydi.
void main() {
  for (final mode in UserMode.values) {
    testWidgets('${mode.name}: Asosiy ekran va panel ko‘rinishi', (t) async {
      await pumpApp(
        t,
        settings: completedSettings(lang: 'uz', mode: mode),
        overrides: [
          classQuizServiceProvider.overrideWithValue(
            FakeClassQuizService(FakeClassQuizBackend(), userId: 'u-1'),
          ),
        ],
      );
      expect(
        find.byKey(const Key('home.teacher')),
        mode == UserMode.teacher ? findsOneWidget : findsNothing,
      );
    });

    testWidgets('${mode.name}: darslar ro‘yxati', (t) async {
      await pumpApp(
        t,
        settings: completedSettings(lang: 'uz', mode: mode),
        initialLocation: Routes.lessons,
      );
      if (mode == UserMode.student) {
        // Talabada «Darslar» yo‘q — Asosiyga qaytadi.
        expect(find.byType(LessonsListScreen), findsNothing);
        return;
      }
      expect(find.byType(LessonsListScreen), findsOneWidget);
      final container = ProviderScope.containerOf(
        t.element(find.byType(LessonsListScreen)),
      );
      final res = await container.read(lessonListProvider('').future);
      final courses = {for (final s in res.value!) s.course};
      if (mode == UserMode.teacher) {
        expect(courses.length, greaterThan(1));
      } else {
        expect(courses.difference({openLessonCourse}), isEmpty);
      }
    });
  }
}
