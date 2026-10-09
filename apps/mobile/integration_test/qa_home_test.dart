// REAL-ILOVA QA — birinchi ishga tushirish, Asosiy va Profil (dizayn sinovi).
//
// Talaba va Mutaxassis sifatida toza o‘rnatishdan boshlab: til → ogohlantirish
// → rejim → hisob tanlovi → Asosiy → Profil → sozlamalar → Ilova haqida;
// so‘ng qorong‘i mavzu, 320 dp + ×2 shrift, ru va en. Akkaunt MOCK, tarmoq
// o‘chirilgan. Ishga tushirish: `tool/qa_real_app.sh home`.
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

  testWidgets('QA real app — FIRST RUN / HOME / PROFILE', (tester) async {
    final net = NoNetworkOverrides();
    HttpOverrides.global = net;
    final l = lookupAppLocalizations(const Locale('uz'));
    final qa = await launchRealApp(tester, role: 'home');
    SettingsController settings() =>
        containerOf(tester).read(settingsControllerProvider.notifier);

    // --------------------------------------------------- TALABA: onboarding
    await qa.step('Til tanlash', (s) async {
      qa.expectText('O‘zbekcha', s);
    }, langCheck: false);

    await qa.step('Ogohlantirish', (s) async {
      await qa.tapText('O‘zbekcha');
      await qa.tapText(l.actionContinue);
      qa.expectText(l.disclaimerAccept, s);
    });

    await qa.step('Rejim mutaxassis (onboarding)', (s) async {
      await qa.tapFinder(find.byKey(const Key('disclaimer.accept')));
      await qa.tapFinder(find.byKey(const Key('mode.professional')));
      await qa.tapFinder(find.byKey(const Key('mode.roles')));
      await qa.tapFinder(find.byKey(const Key('role.forensicToxicologist')));
      qa.expectText(l.modeProfessionalNotVerified, s);
    });

    await qa.step('Rejim talaba', (s) async {
      await qa.scrollToTop();
      await qa.tapFinder(find.byKey(const Key('mode.student')));
      qa.expectText(l.modeStudent, s);
    });

    await qa.step('Hisob tanlovi', (s) async {
      await qa.tapFinder(find.byKey(const Key('mode.continue')));
      qa.expectText(l.accountStartNow, s);
    });

    await qa.step('Asosiy talaba', (s) async {
      await qa.tapFinder(find.byKey(const Key('account.skip')));
      qa.expectText(l.homeGreetingStudent, s);
    });

    await qa.step('Asosiy talaba pastda', (s) async {
      await qa.scrollBy(700);
    });

    await qa.step('Profil talaba', (s) async {
      await qa.tapTooltip('Profil');
      qa.expectText(l.profileTitle, s);
    });

    await qa.step('Profil sozlamalar', (s) async {
      await qa.scrollUntil(find.byKey(const Key('profile.theme')));
      await qa.scrollBy(150);
    });

    await qa.step('Profil oxiri', (s) async {
      await qa.scrollBy(3000);
    });

    await qa.step('Ilova haqida', (s) async {
      goTo(tester, Routes.about);
      await qa.settle();
    });

    // ---------------------------------------------- MUTAXASSIS: rejim + kirish
    await qa.step('Rejim mutaxassis (Profil)', (s) async {
      goTo(tester, Routes.profile);
      await qa.settle();
      goTo(tester, Routes.profileMode);
      await qa.settle();
      await qa.tapFinder(find.byKey(const Key('picker.mode.professional')));
      qa.expectText(l.profileTitle, s);
    }, shot: false);

    await qa.step('Mutaxassis kirish (MOCK OTP)', (s) async {
      await qa.tapFinder(find.byKey(const Key('profile.emailCode')));
      await qa.enterText(find.byType(TextField), 'qa.home@example.test');
      await qa.tapText(l.emailCodeSend);
      await qa.enterText(find.byType(TextField), lastMockCode(tester)!);
      await qa.tapText(l.verifySubmit);
      await qa.settle(maxMs: 4000);
      goTo(tester, Routes.home);
      await qa.settle();
      await qa.scrollToTop();
      qa.expectText(l.homeGreetingExpert, s);
    });

    await qa.step('Asosiy mutaxassis pastda', (s) async {
      await qa.scrollBy(700);
    });

    await qa.step('Profil mutaxassis kirgan', (s) async {
      goTo(tester, Routes.profile);
      await qa.settle();
      await qa.scrollToTop();
      qa.expectText('qa.home@example.test', s);
    });

    // ------------------------------------------------------- qorong‘i mavzu
    await qa.step('Qorong‘i asosiy', (s) async {
      await settings().setThemeMode(ThemeMode.dark);
      goTo(tester, Routes.home);
      await qa.settle();
      await qa.scrollToTop();
    });

    await qa.step('Qorong‘i profil', (s) async {
      goTo(tester, Routes.profile);
      await qa.settle();
      await qa.scrollToTop();
    });

    await qa.step('Qorong‘i ogohlantirish (o‘qish)', (s) async {
      goTo(tester, Routes.profileDisclaimer);
      await qa.settle();
    });

    // ------------------------------------------------- 320 dp + ×2 shrift
    await settings().setThemeMode(ThemeMode.light);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    await qa.setSize(const Size(320, 640));
    await qa.step('320 x2 asosiy', (s) async {
      goTo(tester, Routes.home);
      await qa.settle();
      await qa.scrollToTop();
    });
    await qa.step('320 x2 rejim', (s) async {
      goTo(tester, Routes.profileMode);
      await qa.settle();
    });
    await qa.step('320 x2 profil', (s) async {
      goTo(tester, Routes.profile);
      await qa.settle();
      await qa.scrollToTop();
    });
    tester.platformDispatcher.clearTextScaleFactorTestValue();
    await qa.setSize(const Size(390, 844));

    // ----------------------------------------------------------- ru va en
    qa.lang = 'ru';
    await qa.step('ru asosiy', (s) async {
      await settings().setLocale(const Locale('ru'));
      goTo(tester, Routes.home);
      await qa.settle();
      await qa.scrollToTop();
    });
    await qa.step('ru profil', (s) async {
      goTo(tester, Routes.profile);
      await qa.settle();
      await qa.scrollToTop();
    });
    qa.lang = 'en';
    await qa.step('en asosiy', (s) async {
      await settings().setLocale(const Locale('en'));
      goTo(tester, Routes.home);
      await qa.settle();
      await qa.scrollToTop();
    });
    await qa.step('en profil', (s) async {
      goTo(tester, Routes.profile);
      await qa.settle();
      await qa.scrollToTop();
    });

    if (net.attempts > 0) {
      debugPrint('QA network attempts blocked: ${net.attempts}');
    }
    qa.writeResults();
    printSummary(qa);
    qa.restoreErrorHandler();
  });
}
