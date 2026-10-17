// REAL-ILOVA QA — UX AUDIT (2026-10-17): asosiy ekranlarni TALABA va
// MUTAXASSIS rejimida, 390 va 320 dp, yorug‘ va qorong‘i mavzuda, bo‘sh/xato
// holatlarda ko‘rib chiqadi va skrinshot oladi. Akkaunt MOCK, tarmoq o‘chiq.
// Ishga tushirish: `tool/qa_real_app.sh ux_audit`.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/l10n/generated/app_localizations.dart';
import 'package:forensic_expert/core/settings/app_settings.dart';
import 'package:forensic_expert/core/settings/settings_controller.dart';
import 'package:integration_test/integration_test.dart';

import 'qa/harness.dart';
import 'qa/qa_env.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('QA real app — UX AUDIT', (tester) async {
    HttpOverrides.global = NoNetworkOverrides();
    final l = lookupAppLocalizations(const Locale('uz'));
    final qa = await launchRealApp(tester, role: 'ux_audit');
    SettingsController settings() =>
        containerOf(tester).read(settingsControllerProvider.notifier);

    Future<void> open(String route) async {
      goTo(tester, route);
      await qa.settle(maxMs: 5000);
      await qa.scrollToTop();
    }

    await qa.step('Onboarding', (s) async {
      await qa.tapText('O‘zbekcha');
      await qa.tapText(l.actionContinue);
    }, shot: false);
    await qa.step('Ogohlantirish', (s) async {
      qa.expectText(l.disclaimerTitle, s);
    });
    await qa.step('Rejim tanlash', (s) async {
      await qa.tapText(l.disclaimerAccept);
      qa.expectText(l.modeStudent, s);
    });
    await qa.step('Hisob taklifi', (s) async {
      await qa.tapText(l.modeStudent);
      await qa.tapText(l.actionContinue);
    });
    await qa.step('TALABA Asosiy', (s) async {
      await qa.tapFinder(find.byKey(const Key('account.skip')));
    });
    await qa.step('TALABA Asosiy pastki', (s) async {
      await qa.scrollBy(4000);
    });
    await qa.step('TALABA Kutubxona', (s) async {
      await open(Routes.library);
    });
    await qa.step('TALABA Kutubxona pastki', (s) async {
      await qa.scrollBy(4000);
    });
    await qa.step('TALABA Vositalar', (s) async {
      await open(Routes.tools);
    });
    await qa.step('TALABA Vositalar pastki', (s) async {
      await qa.scrollBy(4000);
    });
    await qa.step('TALABA O‘qish va testlar', (s) async {
      await open(Routes.learn);
    });
    await qa.step('TALABA O‘quv rejimi', (s) async {
      await open(Routes.study);
    });
    await qa.step('TALABA Sinfda test', (s) async {
      await open(Routes.classQuiz);
    });
    // ------------------------------------------- USTOZ PANELI (premium dizayn)
    // Demo sinf serveri (ma’lumot shu qurilmada; demo foydalanuvchi ustoz).
    await qa.step('USTOZ paneli: Asosiydan 1 bosish', (s) async {
      await open(Routes.home);
      await qa.tapFinder(find.byKey(const Key('home.teacher')));
      qa.expectText(l.teacherPanelTitle, s);
      qa.expectText(l.teacherRunTitle, s);
      qa.expectText(l.teacherResultsTitle, s);
      qa.expectText(l.teacherJoinTitle, s);
    });
    await qa.step('USTOZ: Test o‘tkazish → mavzu (2-bosish)', (s) async {
      await qa.tapFinder(find.byKey(const Key('teacher.run')));
      qa.expectText(l.classNewTitle, s);
    });
    await qa.step('USTOZ: mavzu → kod va QR', (s) async {
      await qa.tapFinder(find.byKey(const Key('class.topic.demo-topic')));
      await qa.tapFinder(find.byKey(const Key('class.createSubmit')));
      await qa.settle(maxMs: 4000);
      if (find.byKey(const Key('class.code')).evaluate().isEmpty) {
        s.passed = false;
        s.notes.add('kod ko‘rinmadi');
      }
    });
    await qa.step('USTOZ: Natijalar va CSV (2-bosish)', (s) async {
      await open(Routes.teacher);
      await qa.tapFinder(find.byKey(const Key('teacher.results')));
      qa.expectText(l.teacherResultsTitle, s);
      if (find.byKey(const Key('teacher.resultsList')).evaluate().isEmpty) {
        s.passed = false;
        s.notes.add('natijalar ro‘yxati yo‘q');
      }
    });
    await qa.step('USTOZ: Sinfga qo‘shilish (talaba, 2-bosish)', (s) async {
      await open(Routes.teacher);
      await qa.tapFinder(find.byKey(const Key('teacher.join')));
      if (find.byKey(const Key('class.codeField')).evaluate().isEmpty) {
        s.passed = false;
        s.notes.add('kod maydoni yo‘q');
      }
    });
    await qa.step('TALABA Yo‘riqnomalar', (s) async {
      await open(Routes.guidelines);
    });
    await qa.step('TALABA Fanlar', (s) async {
      await open(Routes.disciplines);
    });
    await qa.step('TALABA Moddalar ro‘yxati', (s) async {
      await open(Routes.librarySection('substances'));
    });
    await qa.step('TALABA Modda: Etanol', (s) async {
      await qa.tapText('Etanol');
    });
    await qa.step('TALABA Modda: Tahlil bo‘limi', (s) async {
      await qa.scrollUntil(find.text('Tahlil usullari'));
    });
    await qa.step('TALABA Ish daftari (bo‘sh)', (s) async {
      await open(Routes.casebook);
    });
    await qa.step('TALABA AI', (s) async {
      await open(Routes.ai);
    });
    await qa.step('TALABA Profil', (s) async {
      await open(Routes.profile);
    });
    await qa.step('TALABA Ilova haqida', (s) async {
      await open(Routes.about);
    });
    await qa.step('TALABA Taklif (referral)', (s) async {
      await open(Routes.referral);
    });

    // --------------------------------------------------- qorong‘i mavzu
    await settings().setThemeMode(ThemeMode.dark);
    await qa.step('QORONG‘I Asosiy', (s) async {
      await open(Routes.home);
    });
    await qa.step('QORONG‘I Vositalar', (s) async {
      await open(Routes.tools);
    });
    await qa.step('QORONG‘I Kutubxona', (s) async {
      await open(Routes.library);
    });
    await qa.step('QORONG‘I AI', (s) async {
      await open(Routes.ai);
    });
    await qa.step('QORONG‘I Profil', (s) async {
      await open(Routes.profile);
    });
    await qa.step('QORONG‘I Sinfda test', (s) async {
      await open(Routes.classQuiz);
    });
    await qa.step('QORONG‘I Ustoz paneli', (s) async {
      await open(Routes.teacher);
    });
    await qa.step('QORONG‘I Modda: Etanol', (s) async {
      await open(Routes.libraryEntry('ethanol'));
    });
    await settings().setThemeMode(ThemeMode.light);

    // ------------------------------------------------------------ 320 dp
    await qa.setSize(const Size(320, 640));
    for (final e in {
      'Asosiy': Routes.home,
      'Kutubxona': Routes.library,
      'Vositalar': Routes.tools,
      'O‘qish': Routes.learn,
      'Sinfda test': Routes.classQuiz,
      'Ustoz paneli': Routes.teacher,
      'Modda Etanol': Routes.libraryEntry('ethanol'),
      'Yo‘riqnomalar': Routes.guidelines,
      'AI': Routes.ai,
      'Profil': Routes.profile,
    }.entries) {
      await qa.step('320 TALABA ${e.key}', (s) async {
        await open(e.value);
      });
    }

    // ------------------------------------------------------- MUTAXASSIS
    await qa.setSize(const Size(390, 844));
    await settings().setUserMode(
      UserMode.professional,
      role: 'forensicToxicologist',
    );
    await qa.step('MUTAXASSIS Asosiy', (s) async {
      await open(Routes.home);
    });
    await qa.step('MUTAXASSIS Asosiy pastki', (s) async {
      await qa.scrollBy(4000);
    });
    await qa.step('MUTAXASSIS Vositalar', (s) async {
      await open(Routes.tools);
    });
    await qa.step('MUTAXASSIS Kutubxona', (s) async {
      await open(Routes.library);
    });
    await qa.step('MUTAXASSIS Sudda so‘roq', (s) async {
      await open(Routes.courtPrep);
    });
    await qa.step('MUTAXASSIS Profil', (s) async {
      await open(Routes.profile);
    });
    await qa.step('MUTAXASSIS Profil pastki', (s) async {
      await qa.scrollBy(4000);
    });
    await qa.step('MUTAXASSIS Maqolalar', (s) async {
      await open(Routes.publications);
    });
    await qa.setSize(const Size(320, 640));
    await qa.step('320 MUTAXASSIS Asosiy', (s) async {
      await open(Routes.home);
    });
    await qa.step('320 MUTAXASSIS Vositalar', (s) async {
      await open(Routes.tools);
    });
    await qa.step('320 MUTAXASSIS Profil', (s) async {
      await open(Routes.profile);
    });
    await qa.setSize(const Size(390, 844));

    qa.writeResults();
    printSummary(qa);
    qa.restoreErrorHandler();
  });
}
