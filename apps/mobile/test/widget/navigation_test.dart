import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/core/settings/app_settings.dart';
import 'package:forensic_expert/core/settings/settings_repository.dart';
import 'package:forensic_expert/features/ai/presentation/ai_screen.dart';
import 'package:forensic_expert/features/home/presentation/home_screen.dart';
import 'package:forensic_expert/features/home/presentation/search_screen.dart';
import 'package:forensic_expert/features/library/presentation/library_screen.dart';
import 'package:forensic_expert/features/placeholder/presentation/in_development_view.dart';
import 'package:forensic_expert/features/profile/presentation/profile_screen.dart';
import 'package:forensic_expert/features/tools/presentation/tools_screen.dart';

import '../helpers/pump_app.dart';

void main() {
  testWidgets('pastki navigatsiya: 5 ta tab', (tester) async {
    await pumpApp(tester, settings: completedSettings());
    for (final (key, type) in [
      ('nav.tools', ToolsScreen),
      ('nav.library', LibraryScreen),
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
  });

  testWidgets('Home modullari va Global Search kirish nuqtasi', (tester) async {
    await pumpApp(tester, settings: completedSettings());
    for (final m in [
      'Forensic Medicine',
      'Forensic Toxicology',
      'Laboratory',
      'Substance Library',
      'Learn',
      'Forensic AI',
    ]) {
      expect(find.text(m), findsOneWidget, reason: m);
    }
    await tester.ensureVisible(find.byKey(const Key('home.search')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('home.search')));
    await tester.pumpAndSettle();
    expect(find.byType(SearchScreen), findsOneWidget);
  });

  testWidgets('modul sahifasi ilmiy kontent ko‘rsatmaydi (placeholder)', (
    tester,
  ) async {
    await pumpApp(tester, settings: completedSettings());
    await tester.ensureVisible(find.byKey(const Key('home.module.toxicology')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('home.module.toxicology')));
    await tester.pumpAndSettle();
    expect(find.byType(InDevelopmentView), findsOneWidget);
  });

  testWidgets('tab almashganda stack holati saqlanadi', (tester) async {
    await pumpApp(tester, settings: completedSettings());
    await tester.ensureVisible(find.byKey(const Key('home.module.laboratory')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('home.module.laboratory')));
    await tester.pumpAndSettle();
    expect(find.byType(InDevelopmentView), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('nav.tools')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('nav.tools')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('nav.home')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('nav.home')));
    await tester.pumpAndSettle();
    // Home tabida laboratoriya sahifasi hali ochiq.
    expect(find.text('Laboratory'), findsWidgets);
    expect(find.byType(InDevelopmentView), findsOneWidget);
  });

  testWidgets('Profil: til va tema o‘zgaradi va saqlanadi', (tester) async {
    final repo = InMemorySettingsRepository(completedSettings());
    await pumpApp(tester, settings: completedSettings(), repository: repo);
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
    await tester.ensureVisible(find.byKey(const Key('nav.profile')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('nav.profile')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('profile.mode')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('profile.mode')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Research / Education'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Research / Education'));
    await tester.pumpAndSettle();
    expect(repo.value.userMode, UserMode.research);
  });

  testWidgets('AI tabida PII ogohlantirishi doim ko‘rinadi', (tester) async {
    await pumpApp(tester, settings: completedSettings());
    await tester.ensureVisible(find.byKey(const Key('nav.ai')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('nav.ai')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('ai.piiWarning')), findsOneWidget);
    expect(find.text('Forensic AI is not connected yet'), findsOneWidget);
  });

  testWidgets('rejimga qarab Home modullari tartibi', (tester) async {
    await pumpApp(tester, settings: completedSettings(mode: UserMode.student));
    final learn = tester.getTopLeft(find.text('Learn'));
    final tox = tester.getTopLeft(find.text('Forensic Toxicology'));
    expect(
      learn.dy < tox.dy || (learn.dy == tox.dy && learn.dx < tox.dx),
      isTrue,
    );
  });
}
