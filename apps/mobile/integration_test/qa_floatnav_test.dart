// REAL-ILOVA QA — suzuvchi pastki menyu (kFloatingNav): Asosiy yuqori holat,
// pastga skroll (ixcham), yuqoriga (to‘liq), Vositalar / AI / Profil /
// Kutubxona / modda detali, qorong‘i mavzu, 320 dp. Akkaunt MOCK, tarmoq
// o‘chirilgan. Ishga tushirish: `tool/qa_real_app.sh floatnav`.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/l10n/generated/app_localizations.dart';
import 'package:forensic_expert/core/settings/settings_controller.dart';
import 'package:integration_test/integration_test.dart';

import 'qa/harness.dart';
import 'qa/qa_env.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('QA real app — FLOATING NAV', (tester) async {
    HttpOverrides.global = NoNetworkOverrides();
    final l = lookupAppLocalizations(const Locale('uz'));
    final qa = await launchRealApp(tester, role: 'floatnav');
    SettingsController settings() =>
        containerOf(tester).read(settingsControllerProvider.notifier);

    Future<void> dragMain(double dy) async {
      final st = qa.mainScrollable();
      if (st == null) return;
      await tester.drag(find.byWidget(st.widget).first, Offset(0, dy));
      await qa.settle();
    }

    await qa.step('Til tanlash', (s) async {
      qa.expectText('O‘zbekcha', s);
    }, langCheck: false);
    await qa.step('Ogohlantirish', (s) async {
      await qa.tapText('O‘zbekcha');
      await qa.tapText(l.actionContinue);
    });
    await qa.step('Rejim', (s) async {
      await qa.tapFinder(find.byKey(const Key('disclaimer.accept')));
      await qa.tapFinder(find.byKey(const Key('mode.student')));
      await qa.tapFinder(find.byKey(const Key('mode.continue')));
    });
    await qa.step('Asosiy yuqori (to‘liq menyu)', (s) async {
      await qa.tapFinder(find.byKey(const Key('account.skip')));
      qa.expectText(l.homeGreetingStudent, s);
      expect(find.byKey(const Key('nav.floating')), findsOneWidget);
      expect(find.byKey(const Key('home.library')), findsOneWidget);
    });
    final full = tester.getSize(find.byKey(const Key('nav.floating')));
    await qa.step('Asosiy pastga skroll (ixcham menyu)', (s) async {
      await dragMain(-500);
      final c = tester.getSize(find.byKey(const Key('nav.floating')));
      if (c.width >= full.width) s.passed = false;
      s.notes.add('full=$full compact=$c');
    });
    await qa.step('Asosiy yuqoriga skroll (to‘liq qaytdi)', (s) async {
      await dragMain(300);
      final c = tester.getSize(find.byKey(const Key('nav.floating')));
      if (c.width != full.width) s.passed = false;
    });
    await qa.step('Asosiy oxiri (menyu ostida to‘silmaydi)', (s) async {
      await qa.scrollBy(5000);
    });
    await qa.scrollToTop();
    await qa.step('Kutubxona tugmasi → Kutubxona', (s) async {
      await qa.tapFinder(find.byKey(const Key('home.library')));
      qa.expectText(l.libraryTitle, s);
    });
    await qa.step('Kutubxona oxiri', (s) async {
      await qa.scrollBy(5000);
    });
    await qa.step('Vositalar', (s) async {
      await qa.tapFinder(find.byKey(const Key('nav.tools')));
      qa.expectText(l.toolsTitle, s);
    });
    await qa.step('Vositalar oxiri', (s) async {
      await qa.scrollBy(5000);
    });
    await qa.step('AI', (s) async {
      await qa.tapFinder(find.byKey(const Key('nav.ai')));
    });
    await qa.step('AI oxiri', (s) async {
      await qa.scrollBy(5000);
    });
    await qa.step('Profil', (s) async {
      await qa.tapFinder(find.byKey(const Key('nav.profile')));
      qa.expectText(l.profileTitle, s);
    });
    await qa.step('Profil oxiri', (s) async {
      await qa.scrollBy(5000);
    });
    await qa.step('Modda detali', (s) async {
      goTo(tester, Routes.library);
      await qa.settle();
      goTo(tester, '/library/section/substances');
      await qa.settle();
    });
    await qa.step('Modda detali (birinchi yozuv)', (s) async {
      await qa.tapText('2C-B');
    });
    await qa.step('Modda detali oxiri', (s) async {
      await qa.scrollBy(8000);
    });
    await qa.step('Qorong‘i Asosiy', (s) async {
      await settings().setThemeMode(ThemeMode.dark);
      goTo(tester, Routes.home);
      await qa.settle();
      await qa.scrollToTop();
    });
    await qa.step('Qorong‘i Asosiy pastga (ixcham)', (s) async {
      await dragMain(-500);
    });
    await qa.step('Qorong‘i Profil', (s) async {
      await qa.tapFinder(find.byKey(const Key('nav.profile')));
    });
    await settings().setThemeMode(ThemeMode.light);
    await qa.setSize(const Size(320, 640));
    await qa.step('320 dp Asosiy', (s) async {
      goTo(tester, Routes.home);
      await qa.settle();
      await qa.scrollToTop();
    });
    await qa.step('320 dp Asosiy pastga', (s) async {
      await dragMain(-500);
    });
    qa.lang = 'ru';
    await qa.step('320 dp ru Asosiy', (s) async {
      await settings().setLocale(const Locale('ru'));
      goTo(tester, Routes.home);
      await qa.settle();
      await qa.scrollToTop();
    });
    await qa.setSize(const Size(390, 844));
    qa.writeResults();
    printSummary(qa);
    qa.restoreErrorHandler();
  });
}
