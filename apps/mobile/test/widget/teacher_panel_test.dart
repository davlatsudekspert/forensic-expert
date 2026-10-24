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

  testWidgets('ustoz rejimi: panel «Bo‘limlar» ichida, 3 amal ≤ 2 bosish', (
    tester,
  ) async {
    await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz', mode: UserMode.teacher),
    );
    final card = find.byKey(const Key('home.teacher'));
    await tester.ensureVisible(card);
    await tester.pumpAndSettle();
    expect(card, findsOneWidget);
    expect(find.text('Ustoz paneli'), findsOneWidget);
    // «Bo‘limlar» to‘rida: «Barcha fanlar» plitkasi bilan bir qatorlar oralig‘ida.
    final all = find.byKey(const Key('home.allDisciplines'));
    expect(tester.getTopLeft(card).dy, lessThan(tester.getTopLeft(all).dy));

    await tapKey(tester, 'home.teacher');
    expect(find.byType(TeacherPanelScreen), findsOneWidget);
    expect(find.byKey(const Key('class.demoBanner')), findsOneWidget);
    await tapKey(tester, 'teacher.run');
    expect(find.byType(ClassCreateScreen), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    await tapKey(tester, 'teacher.results');
    expect(find.byType(TeacherResultsScreen), findsOneWidget);
    expect(find.byKey(const Key('teacher.resultsEmpty')), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    await tapKey(tester, 'teacher.join');
    expect(find.byType(ClassQuizHubScreen), findsOneWidget);
    expect(find.byKey(const Key('class.codeField')), findsOneWidget);
  });

  // Egasi qarori (2026-10-24): Talaba va Mutaxassis ustoz panelini
  // ko‘rmaydi va ocha olmaydi (server roli bo‘lsa ham).
  for (final mode in [UserMode.student, UserMode.professional]) {
    testWidgets('${mode.name}: Ustoz paneli yo‘q, havola Asosiyga qaytaradi', (
      tester,
    ) async {
      await pumpApp(
        tester,
        settings: completedSettings(lang: 'uz', mode: mode),
        overrides: [
          classQuizServiceProvider.overrideWithValue(
            FakeClassQuizService(FakeClassQuizBackend(), userId: 'u-1'),
          ),
        ],
      );
      expect(find.byKey(const Key('home.teacher')), findsNothing);
      expect(find.text('Ustoz paneli'), findsNothing);
    });

    testWidgets('${mode.name}: /teacher marshruti yopiq', (tester) async {
      await pumpApp(
        tester,
        settings: completedSettings(lang: 'uz', mode: mode),
        initialLocation: Routes.teacher,
      );
      expect(find.byType(TeacherPanelScreen), findsNothing);
      expect(find.byKey(const Key('home.allDisciplines')), findsOneWidget);
    });
  }

  testWidgets('320 dp, ×2 matn, ru/en: panel toshmaydi', (tester) async {
    for (final lang in ['ru', 'en', 'uz']) {
      await pumpApp(
        tester,
        settings: completedSettings(lang: lang, mode: UserMode.teacher),
        size: const Size(320, 640),
        textScale: 2,
        initialLocation: Routes.teacher,
      );
      expect(find.byType(TeacherPanelScreen), findsOneWidget);
      expect(tester.takeException(), isNull, reason: lang);
    }
  });
}
