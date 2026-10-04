import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/core/settings/app_settings.dart';
import 'package:forensic_expert/core/settings/settings_repository.dart';
import 'package:forensic_expert/features/home/presentation/home_screen.dart';
import 'package:forensic_expert/features/onboarding/presentation/disclaimer_screen.dart';
import 'package:forensic_expert/features/onboarding/presentation/language_screen.dart';
import 'package:forensic_expert/features/onboarding/presentation/mode_screen.dart';

import '../helpers/pump_app.dart';

void main() {
  testWidgets('birinchi ekran — til tanlash (login yo‘q)', (tester) async {
    await pumpApp(tester);
    expect(find.byType(LanguageScreen), findsOneWidget);
    expect(find.text('FORENSIC EXPERT'), findsOneWidget);
    expect(find.text('Evidence · Science · Precision'), findsOneWidget);
    // Uchala til o‘z nomi bilan.
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Русский'), findsOneWidget);
    expect(find.text('O‘zbekcha'), findsOneWidget);
    // «Choose your language» uch tilda.
    expect(find.text('Choose your language'), findsOneWidget);
    expect(find.text('Выберите язык'), findsOneWidget);
    expect(find.text('Tilni tanlang'), findsOneWidget);
    // Login yoki boshqa ekran yo‘q.
    expect(find.byType(DisclaimerScreen), findsNothing);
    expect(find.byType(HomeScreen), findsNothing);
  });

  testWidgets('til tanlanmaguncha davom etib bo‘lmaydi', (tester) async {
    await pumpApp(tester);
    final button = tester.widget<FilledButton>(
      find.byKey(const Key('language.continue')),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('to‘liq onboarding: O‘zbekcha → disclaimer → rejim → Home', (
    tester,
  ) async {
    final repo = InMemorySettingsRepository();
    await pumpApp(tester, repository: repo);

    await tester.ensureVisible(find.byKey(const Key('language.option.uz')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('language.option.uz')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('language.continue')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('language.continue')));
    await tester.pumpAndSettle();

    expect(find.byType(DisclaimerScreen), findsOneWidget);
    expect(find.text('Ilmiy ogohlantirish'), findsOneWidget);
    expect(repo.value.locale, const Locale('uz'));

    await tester.ensureVisible(find.byKey(const Key('disclaimer.accept')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('disclaimer.accept')));
    await tester.pumpAndSettle();
    expect(find.byType(ModeScreen), findsOneWidget);
    expect(
      find.text('Forensic Expert’dan qanday foydalanasiz?'),
      findsOneWidget,
    );

    await tester.ensureVisible(find.byKey(const Key('mode.student')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('mode.student')));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(
      find.text('Modda, metod, formula, mavzu yoki manbani qidiring…'),
      findsOneWidget,
    );
    expect(repo.value.onboardingComplete, isTrue);
    expect(repo.value.userMode, UserMode.student);
  });

  testWidgets('saqlangan til bilan qayta ochilganda til ekrani chiqmaydi', (
    tester,
  ) async {
    await pumpApp(tester, settings: completedSettings(lang: 'ru'));
    expect(find.byType(LanguageScreen), findsNothing);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Главная'), findsWidgets);
  });

  testWidgets('til tanlangan, lekin disclaimer qabul qilinmagan → disclaimer', (
    tester,
  ) async {
    await pumpApp(tester, settings: const AppSettings(locale: Locale('en')));
    expect(find.byType(DisclaimerScreen), findsOneWidget);
  });

  testWidgets(
    'onboarding tugamaguncha shell’ga to‘g‘ridan-to‘g‘ri kirib bo‘lmaydi',
    (tester) async {
      await pumpApp(tester, initialLocation: '/home');
      expect(find.byType(LanguageScreen), findsOneWidget);
    },
  );
}
