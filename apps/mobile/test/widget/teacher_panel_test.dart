import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/class_quiz.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/settings/app_settings.dart';
import 'package:forensic_expert/data/class_quiz/fake_class_quiz_service.dart';
import 'package:forensic_expert/features/class_quiz/presentation/class_quiz_host_screen.dart';
import 'package:forensic_expert/features/class_quiz/presentation/class_quiz_hub_screen.dart';
import 'package:forensic_expert/features/class_quiz/presentation/teacher_panel_screen.dart';

import '../helpers/pump_app.dart';

/// «Ustoz paneli»: Asosiydan 1 bosish, har bir amal ≤ 2 bosish; ustoz
/// rolida karta tezkor amallardan keyin (yuqorida), aks holda bo‘limlardan
/// keyin. Yangi backend yo‘q — mavjud «Sinfda test» oqimi.
void main() {
  Future<void> tapKey(WidgetTester tester, String key) async {
    final f = find.byKey(Key(key));
    await tester.ensureVisible(f);
    await tester.pumpAndSettle();
    await tester.tap(f);
    await tester.pumpAndSettle();
  }

  for (final mode in UserMode.values) {
    testWidgets('ustoz (${mode.name}): karta yuqorida, 3 amal ≤ 2 bosish', (
      tester,
    ) async {
      await pumpApp(
        tester,
        settings: completedSettings(lang: 'uz', mode: mode),
      );
      final card = find.byKey(const Key('home.teacher'));
      expect(card, findsOneWidget);
      expect(find.text('Ustoz paneli'), findsOneWidget);
      // Ustoz rolida — bo‘limlar to‘ridan oldin.
      expect(
        tester.getTopLeft(card).dy,
        lessThan(
          tester.getTopLeft(find.byKey(const Key('home.allDisciplines'))).dy,
        ),
      );

      // 1-bosish: panel; 2-bosish: «Test o‘tkazish» → mavzu tanlash.
      await tapKey(tester, 'home.teacher');
      expect(find.byType(TeacherPanelScreen), findsOneWidget);
      expect(find.byKey(const Key('class.demoBanner')), findsOneWidget);
      await tapKey(tester, 'teacher.run');
      expect(find.byType(ClassCreateScreen), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      // «Natijalar va CSV» → ro‘yxat (hali bo‘sh — tushunarli bo‘sh holat).
      await tapKey(tester, 'teacher.results');
      expect(find.byType(TeacherResultsScreen), findsOneWidget);
      expect(find.byKey(const Key('teacher.resultsEmpty')), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      // «Sinfga qo‘shilish (talaba)» → kod kiritish.
      await tapKey(tester, 'teacher.join');
      expect(find.byType(ClassQuizHubScreen), findsOneWidget);
      expect(find.byKey(const Key('class.codeField')), findsOneWidget);
    });
  }

  testWidgets('ustoz emas: karta pastda, ustoz amallari yopiq va izohli', (
    tester,
  ) async {
    final backend = FakeClassQuizBackend();
    await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz', mode: UserMode.student),
      overrides: [
        classQuizServiceProvider.overrideWithValue(
          FakeClassQuizService(backend, userId: 'student-1'),
        ),
      ],
    );
    final card = find.byKey(const Key('home.teacher'));
    await tester.ensureVisible(card);
    await tester.pumpAndSettle();
    expect(
      tester.getTopLeft(card).dy,
      greaterThan(
        tester.getTopLeft(find.byKey(const Key('home.allDisciplines'))).dy,
      ),
    );
    expect(find.text('Ustoz kodi bilan sinfda testga qo‘shiling'), findsOne);
    await tapKey(tester, 'home.teacher');
    expect(find.byKey(const Key('teacher.notTeacherNote')), findsOneWidget);
    // Yopiq amal hech qayerga olib bormaydi.
    await tapKey(tester, 'teacher.run');
    expect(find.byType(ClassCreateScreen), findsNothing);
    expect(find.byType(TeacherPanelScreen), findsOneWidget);
    // Talaba uchun qo‘shilish ochiq.
    await tapKey(tester, 'teacher.join');
    expect(find.byType(ClassQuizHubScreen), findsOneWidget);
  });

  testWidgets('320 dp, ×2 matn, ru/en: panel toshmaydi', (tester) async {
    for (final lang in ['ru', 'en', 'uz']) {
      await pumpApp(
        tester,
        settings: completedSettings(lang: lang),
        size: const Size(320, 640),
        textScale: 2,
        initialLocation: Routes.teacher,
      );
      expect(find.byType(TeacherPanelScreen), findsOneWidget);
      expect(tester.takeException(), isNull, reason: lang);
    }
  });
}
