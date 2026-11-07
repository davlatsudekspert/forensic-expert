import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/settings/app_settings.dart';
import 'package:forensic_expert/core/settings/settings_repository.dart';
import 'package:forensic_expert/features/ai/presentation/ai_screen.dart';
import 'package:forensic_expert/features/home/presentation/home_screen.dart';
import 'package:forensic_expert/features/home/presentation/search_screen.dart';
import 'package:forensic_expert/features/library/presentation/library_screen.dart';
import 'package:forensic_expert/features/placeholder/presentation/in_development_view.dart';
import 'package:forensic_expert/features/profile/presentation/profile_screen.dart';
import 'package:forensic_expert/features/tools/presentation/module_hub_screen.dart';
import 'package:forensic_expert/features/tools/presentation/tools_screen.dart';

import '../helpers/pump_app.dart';

void main() {
  testWidgets(
    'pastki navigatsiya: 4 ta bo‘lim + Kutubxona Asosiy tugmasi orqali',
    (tester) async {
      await pumpApp(tester, settings: completedSettings());
      for (final (key, type) in [
        ('nav.tools', ToolsScreen),
        ('nav.ai', AiScreen),
        ('nav.profile', ProfileScreen),
        ('nav.home', HomeScreen),
      ]) {
        await tester.ensureVisible(find.byKey(Key(key)));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(Key(key)));
        await tester.pumpAndSettle();
        expect(find.byType(type), findsOneWidget, reason: key);
      }
      // Kutubxona — tab emas; Asosiy tepasidagi katta tugma orqali.
      await tester.tap(find.byKey(const Key('nav.library')));
      await tester.pumpAndSettle();
      expect(find.byType(LibraryScreen), findsOneWidget);
    },
  );

  testWidgets('Home modullari va Global Search kirish nuqtasi', (tester) async {
    await pumpApp(tester, settings: completedSettings());
    // Mutaxassis Asosiyda (2026-11-06): fanlar kartalari yo‘q — ular
    // Ekspertiza yo‘nalishlari ichida; Ma’lumotnomalar va Ish stolim bor.
    expect(find.byKey(const Key('home.areas')), findsOneWidget);
    for (final m in ['Substances', 'Forensic AI']) {
      // Ekspert «Ish stolim»i ham «Forensic AI» kartasini beradi.
      expect(
        find.text(m),
        m == 'Forensic AI' ? findsWidgets : findsOneWidget,
        reason: m,
      );
    }
    await tester.ensureVisible(find.byKey(const Key('home.search')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('home.search')));
    await tester.pumpAndSettle();
    expect(find.byType(SearchScreen), findsOneWidget);
  });

  testWidgets('modul sahifasi mavjud manbali yozuvlarni ko‘rsatadi '
      '(bo‘sh holat emas)', (tester) async {
    await pumpApp(
      tester,
      settings: completedSettings(),
      initialLocation: Routes.areas,
    );
    await tester.tap(find.byKey(const Key('areas.chemistry')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('moduleHub.sourcedNote')), findsOneWidget);
    expect(find.byKey(const Key('moduleHub.substances')), findsOneWidget);
    expect(find.byType(AvailabilityStateView), findsNothing);
    expect(find.byType(BackButton), findsOneWidget);
  });

  testWidgets('tab almashganda stack holati saqlanadi', (tester) async {
    await pumpApp(tester, settings: completedSettings(mode: UserMode.teacher));
    await tester.ensureVisible(find.byKey(const Key('home.module.toxicology')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('home.module.toxicology')));
    await tester.pumpAndSettle();
    expect(find.byType(ModuleHubScreen), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('nav.tools')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('nav.tools')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('nav.home')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('nav.home')));
    await tester.pumpAndSettle();
    // Home tabida modul sahifasi hali ochiq.
    expect(find.byType(ModuleHubScreen), findsOneWidget);
  });

  testWidgets('Profil: til va tema o‘zgaradi va saqlanadi', (tester) async {
    final repo = InMemorySettingsRepository(completedSettings());
    await pumpApp(tester, settings: completedSettings(), repository: repo);
    // Professional → Talaba.
    await tester.ensureVisible(find.byKey(const Key('nav.profile')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('nav.profile')));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Dark'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(repo.value.themeMode, ThemeMode.dark);
    expect(
      Theme.of(tester.element(find.byType(ProfileScreen))).brightness,
      Brightness.dark,
    );

    await tester.ensureVisible(find.byKey(const Key('profile.language')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('profile.language')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('picker.language.ru')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('picker.language.ru')));
    await tester.pumpAndSettle();
    expect(repo.value.locale, const Locale('ru'));
    expect(find.text('Профиль'), findsWidgets);
  });

  testWidgets('Profil: rejimni keyinchalik o‘zgartirish', (tester) async {
    final repo = InMemorySettingsRepository(completedSettings());
    await pumpApp(tester, settings: completedSettings(), repository: repo);
    // Professional → Talaba.
    await tester.ensureVisible(find.byKey(const Key('nav.profile')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('nav.profile')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('profile.mode')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('profile.mode')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('picker.mode.student')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('picker.mode.student')));
    await tester.pumpAndSettle();
    expect(repo.value.userMode, UserMode.student);
  });

  testWidgets('AI tabida PII ogohlantirishi doim ko‘rinadi', (tester) async {
    await pumpApp(tester, settings: completedSettings());
    await tester.ensureVisible(find.byKey(const Key('nav.ai')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('nav.ai')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('ai.piiWarning')), findsOneWidget);
    expect(find.text('AI is temporarily unavailable'), findsOneWidget);
  });

  testWidgets('rejimga qarab Home tezkor amallari va bo‘limlar tartibi', (
    tester,
  ) async {
    // Talaba («Mening akademiyam», egasi qarori, 2026-11-04): «Asosiy fanlar»
    // kartasi yo‘q. Mutaxassisda asosiy fanlar eng tepada (2026-10-31).
    await pumpApp(tester, settings: completedSettings(mode: UserMode.student));
    expect(find.text('Core disciplines'), findsNothing);
    expect(find.byKey(const Key('home.core')), findsNothing);
    for (final m in ['forensicMedicine', 'toxicology']) {
      expect(find.byKey(Key('home.module.$m')), findsNothing);
    }
    // Takrorlar yo‘q (egasi talabi, 2026-11-01): O‘qish — «O‘qish stolim»
    // ichida; tepada «Yangi bo‘limlar».
    expect(find.byKey(const Key('home.module.learn')), findsNothing);
    expect(find.byKey(const Key('desk.student')), findsOneWidget);
    // «Ilmiy va amaliy bo‘limlar» (home.new) endi ekran o‘rtasida: skroll bilan.
    await tester.scrollUntilVisible(
      find.byKey(const Key('home.new')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byKey(const Key('home.new')), findsOneWidget);
    expect(find.byKey(const Key('home.tools')), findsNothing);
    // Mutaxassis: asosiy fanlar → Ish stolim → moddalar, usullar,
    // kalkulyatorlar, AI.
    await pumpApp(tester, settings: completedSettings());
    // «Asosiy fanlar» Mutaxassisdan olib tashlandi (2026-11-06).
    expect(find.text('Core disciplines'), findsNothing);
    // Kalkulyatorlar, AI va Sudda so‘roq — «Ish stolim»da (takror yo‘q).
    expect(find.byKey(const Key('home.tools')), findsNothing);
    expect(find.byKey(const Key('home.courtPrep')), findsNothing);
    for (final m in ['forensicMedicine', 'toxicology']) {
      expect(find.byKey(Key('home.module.$m')), findsNothing);
    }
    expect(find.byKey(const Key('home.module.laboratory')), findsNothing);
    // Mutaxassis (2026-11-05): ixcham tartib — Ekspertiza yo‘nalishlari,
    // Usullar va apparatlar, Ma’lumotnomalar (Moddalar, Yo‘riqnomalar).
    expect(find.byKey(const Key('home.areas')), findsOneWidget);
    expect(find.byKey(const Key('home.methodsDevices')), findsOneWidget);
    // Apparatlar bilan ishlash kursi Ma’lumotnomalarda (1 bosish).
    expect(find.byKey(const Key('home.instruments')), findsOneWidget);
    expect(find.byKey(const Key('home.module.methods')), findsNothing);
    expect(find.byKey(const Key('home.module.ai')), findsNothing);
  });
}
