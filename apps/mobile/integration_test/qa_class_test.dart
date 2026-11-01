// REAL-ILOVA QA — USTOZ + TALABA (sinf / guruh) yo‘li, 2026-11-01.
//
// Haqiqiy ilova (`bootstrap()`), MOCK akkaunt, tarmoq o‘chiq, ustoz va
// talaba bitta qurilmada (demo sinf/guruh serveri xotirada). Har qadamda:
// skrinshot, overflow/exception, kirilcha harf, inglizcha qoldiq va
// «Pro» / pullik belgisi tekshiriladi.
// Ishga tushirish: `QA_OUT=/dev/shm/qa_class tool/qa_real_app.sh class`.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/account.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/l10n/generated/app_localizations.dart';
import 'package:forensic_expert/core/settings/app_settings.dart';
import 'package:forensic_expert/core/settings/settings_controller.dart';
import 'package:integration_test/integration_test.dart';

import 'qa/harness.dart';
import 'qa/qa_env.dart';

final _cyrillic = RegExp('[А-Яа-яЁё]');
final _proText = RegExp(
  r'(\bPro\b|Premium|Pullik|Sotib ol|Obuna|Paywall|Pro\s?·)',
  caseSensitive: false,
);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('QA real app — CLASS (ustoz + talaba)', (tester) async {
    HttpOverrides.global = NoNetworkOverrides();
    final l = lookupAppLocalizations(const Locale('uz'));
    // QA_VIP=1: server «admin» javobi (VIP) — Pro qulflari ostidagi oqimlarni
    // (guruh yaratish, mashq/imtihon) ham ko‘rib chiqish uchun ikkinchi o‘tish.
    final vip = Platform.environment['QA_VIP'] == '1';
    final qa = await launchRealApp(
      tester,
      role: 'class',
      overrides: [
        if (vip)
          accountServiceProvider.overrideWithValue(
            QaAccountService(admin: true),
          ),
      ],
    );
    SettingsController settings() =>
        containerOf(tester).read(settingsControllerProvider.notifier);

    /// Kirilcha, «Pro»/qulf belgisi — har qadam oxirida.
    void hygiene(QaStep s) {
      final cyr = qa.visibleTexts().where(_cyrillic.hasMatch).toList();
      if (cyr.isNotEmpty) {
        s.passed = false;
        s.notes.add('KIRILCHA: ${cyr.take(3).join(' | ')}');
      }
      final pro = qa.visibleTexts().where(_proText.hasMatch).toList();
      if (pro.isNotEmpty) {
        s.passed = false;
        s.notes.add('PRO/PULLIK MATN: ${pro.take(3).join(' | ')}');
      }
      for (final ic in [Icons.lock, Icons.lock_outline]) {
        if (find.byIcon(ic).evaluate().isNotEmpty) {
          s.passed = false;
          s.notes.add('QULF IKONKASI ko‘rinadi');
        }
      }
    }

    Future<void> open(String route) async {
      goTo(tester, route);
      await qa.settle(maxMs: 5000);
      await qa.scrollToTop();
    }

    Future<void> signIn(String email) async {
      final auth = containerOf(tester).read(authRepositoryProvider);
      await tester.runAsync(() async {
        await auth.requestEmailCode(email);
      });
      final code = lastMockCode(tester)!;
      await tester.runAsync(() async {
        await auth.verifyEmailCode(email: email, code: code);
      });
      await qa.settle(maxMs: 3000);
    }

    Future<void> signOut() async {
      final auth = containerOf(tester).read(authRepositoryProvider);
      await tester.runAsync(() => auth.signOut());
      await qa.settle(maxMs: 3000);
    }

    String? groupCode;
    String? classCode;

    // ----------------------------------------------------------- onboarding
    await qa.step('Onboarding: til', (s) async {
      await qa.tapText('O‘zbekcha');
      await qa.tapText(l.actionContinue);
      qa.expectText(l.disclaimerTitle, s);
    });
    await qa.step('Tushundim → rejim tanlash', (s) async {
      await qa.tapText(l.disclaimerAccept);
      qa.expectText(l.modeTeacher, s);
      hygiene(s);
    });
    await qa.step('Rejim: Ustoz → davom', (s) async {
      await qa.tapFinder(find.byKey(const Key('mode.teacher')));
      qa.expectText(l.modeTeacherNote, s);
      hygiene(s);
    });
    await qa.step('Davom etish → hisob taklifi', (s) async {
      await qa.tapFinder(find.byKey(const Key('mode.continue')));
      qa.expectText(l.accountStartNow, s);
    });
    await qa.step('Boshlash → USTOZ Asosiy (yuqori)', (s) async {
      await qa.tapFinder(find.byKey(const Key('account.skip')));
      qa.expectText('Rejim: Ustoz', s);
      if (find.byKey(const Key('home.core')).evaluate().isEmpty) {
        s.passed = false;
        s.notes.add('«Asosiy fanlar» kartasi yo‘q');
      }
      hygiene(s);
    });
    await qa.step('USTOZ Asosiy (pastga)', (s) async {
      await qa.scrollBy(700);
      hygiene(s);
    });
    await qa.step('USTOZ Asosiy (eng pastki)', (s) async {
      await qa.scrollBy(4000);
      hygiene(s);
    });

    await qa.step('USTOZ Asosiy: «Ustoz stolim» stoli', (s) async {
      await open(Routes.home);
      if (find.byKey(const Key('desk.teacher')).evaluate().isEmpty) {
        s.passed = false;
        s.notes.add('desk.teacher yo‘q');
      }
      if (find.byKey(const Key('home.core')).evaluate().isEmpty) {
        s.passed = false;
        s.notes.add('«Asosiy fanlar» kartasi yo‘q');
      }
      await qa.scrollBy(450);
      hygiene(s);
    });
    for (final k in [
      'teachLessons',
      'teachRun',
      'teachGroups',
      'teachResults',
    ]) {
      await qa.step('USTOZ stoli: $k ochiladi', (s) async {
        await open(Routes.home);
        await qa.tapFinder(find.byKey(Key('workbench.$k')));
        hygiene(s);
      });
      await qa.step('USTOZ stoli: $k (pastga)', (s) async {
        await qa.scrollBy(600);
        hygiene(s);
      });
    }
    // --------------------------------------------------------- ustoz paneli
    await qa.step('USTOZ paneli ochiladi', (s) async {
      await open(Routes.teacher);
      qa.expectText(l.teacherPanelTitle, s);
      qa.expectText(l.teacherRunTitle, s);
      qa.expectText(l.teacherResultsTitle, s);
      qa.expectText(l.teacherJoinTitle, s);
      hygiene(s);
    });
    await qa.step('USTOZ paneli (pastga)', (s) async {
      await qa.scrollBy(4000);
      hygiene(s);
    });
    await qa.step('USTOZ: Test o‘tkazish → mavzu tanlash', (s) async {
      await qa.scrollToTop();
      await qa.tapFinder(find.byKey(const Key('teacher.run')));
      qa.expectText(l.classNewTitle, s);
      hygiene(s);
    });
    await qa.step('USTOZ: qidiruv «toksik»', (s) async {
      await qa.enterText(find.byKey(const Key('class.topicSearch')), 'toksik');
      if (find
          .byKey(const Key('class.topic.4-kurs-davolash-10'))
          .evaluate()
          .isEmpty) {
        s.passed = false;
        s.notes.add('«toksik» mavzusi topilmadi');
      }
      hygiene(s);
    });
    await qa.step('USTOZ: mavzu tanlandi', (s) async {
      await qa.tapFinder(
        find.byKey(const Key('class.topic.4-kurs-davolash-10')),
      );
      hygiene(s);
    });
    await qa.step('USTOZ: test yaratildi → kod / QR', (s) async {
      await qa.tapFinder(find.byKey(const Key('class.createSubmit')));
      await qa.settle(maxMs: 4000);
      final f = find.byKey(const Key('class.code'));
      if (f.evaluate().isEmpty) {
        s.passed = false;
        s.notes.add('kod ko‘rinmadi');
      } else {
        final w = f.evaluate().first.widget;
        if (w is Text) classCode = w.data?.replaceAll(RegExp(r'\s'), '');
        s.notes.add('kod: $classCode');
      }
      hygiene(s);
    });
    await qa.step('USTOZ: kod / QR (pastga)', (s) async {
      await qa.scrollBy(600);
      hygiene(s);
    });
    await qa.step('USTOZ: Natijalar', (s) async {
      await open(Routes.teacher);
      await qa.tapFinder(find.byKey(const Key('teacher.results')));
      qa.expectText(l.teacherResultsTitle, s);
      if (find.byKey(const Key('teacher.resultsList')).evaluate().isEmpty) {
        s.passed = false;
        s.notes.add('natijalar ro‘yxati yo‘q');
      }
      hygiene(s);
    });
    await qa.step('USTOZ: Sinfga qo‘shilish (kod maydoni)', (s) async {
      await open(Routes.teacher);
      await qa.tapFinder(find.byKey(const Key('teacher.join')));
      if (find.byKey(const Key('class.codeField')).evaluate().isEmpty) {
        s.passed = false;
        s.notes.add('kod maydoni yo‘q');
      }
      hygiene(s);
    });

    // ---------------------------------------- ustoz: guruh va guruh testi
    await qa.step('USTOZ: kirish (MOCK) → Guruhlar', (s) async {
      await signIn('ustoz.qa@example.test');
      await open(Routes.groups);
      qa.expectText(l.grpTitle, s);
      hygiene(s);
    });
    await qa.step('USTOZ: yangi guruh formasi', (s) async {
      await qa.tapFinder(find.byKey(const Key('grp.createButton')));
      qa.expectText(l.grpCreateTitle, s);
      hygiene(s);
    });
    await qa.step('USTOZ: guruh yaratildi', (s) async {
      await qa.enterText(
        find.byKey(const Key('grp.nameField')),
        'QA 401-guruh',
      );
      await qa.tapFinder(find.byKey(const Key('grp.createSubmit')));
      await qa.settle(maxMs: 4000);
      qa.expectText('QA 401-guruh', s);
      final f = find.byKey(const Key('grp.code'));
      if (f.evaluate().isNotEmpty) {
        final w = f.evaluate().first.widget;
        if (w is Text) groupCode = w.data?.replaceAll(RegExp(r'\s'), '');
      }
      s.notes.add('guruh kodi: $groupCode');
      hygiene(s);
    });
    await qa.step('USTOZ: guruh sahifasi (pastga)', (s) async {
      await qa.scrollBy(500);
      hygiene(s);
    });
    await qa.step('USTOZ: mavzu testi berish → mavzu', (s) async {
      await qa.scrollToTop();
      await qa.tapFinder(find.byKey(const Key('grp.assignButton')));
      qa.expectText(l.grpAssignTitle, s);
      await qa.enterText(find.byKey(const Key('grp.topicSearch')), 'toksik');
      hygiene(s);
    });
    await qa.step('USTOZ: mavzu tanlandi → test berish', (s) async {
      final f = find.byWidgetPredicate(
        (w) => w.key is Key && '${w.key}'.contains('grp.topic.'),
      );
      await qa.tapFinder(f);
      hygiene(s);
    });
    await qa.step('USTOZ: testni berish (yuborish)', (s) async {
      await qa.tapFinder(find.byKey(const Key('grp.assignSubmit')));
      await qa.settle(maxMs: 4000);
      hygiene(s);
    });

    // ------------------------------------------------- TALABA rejimiga
    await signOut();
    await settings().setUserMode(UserMode.student);
    await qa.step('TALABA Asosiy (yuqori)', (s) async {
      await open(Routes.home);
      qa.expectText('Rejim: Talaba', s);
      qa.expectText(l.homeCoreTitle, s);
      qa.expectText(l.studentDeskTitle, s);
      if (find.byKey(const Key('desk.teacher')).evaluate().isNotEmpty) {
        s.passed = false;
        s.notes.add('Talabada Ustoz stoli ko‘rinadi');
      }
      hygiene(s);
    });
    await qa.step('TALABA Asosiy (pastga 1)', (s) async {
      await qa.scrollBy(600);
      hygiene(s);
    });
    await qa.step('TALABA Asosiy (pastga 2)', (s) async {
      await qa.scrollBy(700);
      hygiene(s);
    });
    await qa.step('TALABA Asosiy (eng pastki)', (s) async {
      await qa.scrollBy(4000);
      hygiene(s);
    });

    await qa.step('TALABA: Guruhim (kirishsiz)', (s) async {
      await open(Routes.home);
      await qa.tapFinder(find.byKey(const Key('workbench.deskGroup')));
      hygiene(s);
    });
    await qa.step('TALABA: kirish (MOCK)', (s) async {
      await signIn('talaba.qa@example.test');
      await open(Routes.home);
      hygiene(s);
    });

    for (final e in {
      'Sud tibbiyoti': 'forensicMedicine',
      'Toksikologiya': 'toxicology',
      'Biokimyo': 'biochemistry',
    }.entries) {
      await qa.step('TALABA: ${e.key} (yuqori kartadan)', (s) async {
        await open(Routes.home);
        await qa.tapFinder(find.byKey(Key('home.module.${e.value}')));
        hygiene(s);
      });
      await qa.step('TALABA: ${e.key} (pastga)', (s) async {
        await qa.scrollBy(600);
        hygiene(s);
      });
    }

    await qa.step('TALABA: Bugungi savol — javob', (s) async {
      await open(Routes.home);
      final f = find.byKey(const Key('desk.dailyQuestion'));
      await qa.scrollUntil(f);
      if (f.evaluate().isEmpty) {
        s.passed = false;
        s.notes.add('«Bugungi savol» kartasi yo‘q');
        return;
      }
      await tester.ensureVisible(f);
      await qa.settle();
      await qa.tapFinder(find.byKey(const Key('desk.dailyQuestion.option.1')));
      if (find
          .byKey(const Key('desk.dailyQuestion.feedback'))
          .evaluate()
          .isEmpty) {
        s.passed = false;
        s.notes.add('javobdan keyin izoh/feedback ko‘rinmadi');
      }
      hygiene(s);
    });

    await qa.step('TALABA: Darslar va kitoblar', (s) async {
      await open(Routes.home);
      await qa.tapFinder(find.byKey(const Key('workbench.deskLessons')));
      hygiene(s);
    });
    await qa.step('TALABA: Darslar (pastga)', (s) async {
      await qa.scrollBy(700);
      hygiene(s);
    });
    await qa.step('TALABA: bitta kurs/dars ochish', (s) async {
      await qa.scrollToTop();
      final f = find.byWidgetPredicate(
        (w) => w.key is Key && '${w.key}'.contains('learn.course.'),
      );
      await qa.scrollUntil(f);
      if (f.evaluate().isEmpty) {
        s.notes.add('kurslar yo‘q (bo‘sh holat)');
      } else {
        await qa.tapFinder(f);
      }
      hygiene(s);
    });
    await qa.step('TALABA: dars (ro‘yxatdan biri)', (s) async {
      final f = find.byWidgetPredicate(
        (w) => w.key is Key && '${w.key}'.contains('learn.lesson.'),
      );
      if (f.evaluate().isNotEmpty) {
        await qa.tapFinder(f);
      } else {
        s.notes.add('dars yozuvi topilmadi');
      }
      hygiene(s);
    });

    await qa.step('TALABA: Testlar va kartochkalar', (s) async {
      await open(Routes.home);
      await qa.tapFinder(find.byKey(const Key('workbench.deskTests')));
      hygiene(s);
    });
    await qa.step('TALABA: mashq (to‘plamlardan ochiladiganini topish)', (
      s,
    ) async {
      final f = find.byWidgetPredicate(
        (w) =>
            w.key is Key &&
            '${w.key}'.startsWith('[<\'study.quiz.') &&
            RegExp(r"study\.quiz\.[a-z0-9_.-]+'").hasMatch('${w.key}') &&
            !'${w.key}'.contains(RegExp('feedback|option|check|next|score')),
      );
      await qa.scrollUntil(f);
      final n = f.evaluate().length;
      s.notes.add('mashq tugmalari: $n');
      var opened = false;
      for (var i = 0; i < n && !opened; i++) {
        final cur = find.byWidgetPredicate(
          (w) =>
              w.key is Key &&
              '${w.key}'.startsWith('[<\'study.quiz.') &&
              RegExp(r"study\.quiz\.[a-z0-9_.-]+'").hasMatch('${w.key}') &&
              !'${w.key}'.contains(RegExp('feedback|option|check|next|score')),
        );
        if (cur.evaluate().length <= i) break;
        await qa.tapFinder(
          cur.at(i).evaluate().isEmpty ? cur : cur,
          scroll: false,
        );
        if (find
            .byKey(const Key('study.quiz.option.0'))
            .evaluate()
            .isNotEmpty) {
          opened = true;
        } else {
          s.notes.add(
            'to‘plam #$i yopiq/Pro: ${qa.visibleTexts().take(4).join(' | ')}',
          );
          await qa.back();
        }
      }
      if (!opened) {
        s.passed = false;
        s.notes.add('hech bir mashq ochilmadi');
      }
      hygiene(s);
    });
    for (var i = 1; i <= 3; i++) {
      await qa.step('TALABA: mashq savoli $i', (s) async {
        final opt = find.byKey(const Key('study.quiz.option.0'));
        if (opt.evaluate().isEmpty) {
          s.passed = false;
          s.notes.add('variant yo‘q');
          return;
        }
        await qa.tapFinder(opt);
        await qa.tapFinder(find.byKey(const Key('study.quiz.check')));
        hygiene(s);
      });
      await qa.step('TALABA: mashq izohi $i', (s) async {
        await qa.scrollBy(500);
        hygiene(s);
        final next = find.byKey(const Key('study.quiz.next'));
        if (next.evaluate().isNotEmpty) await qa.tapFinder(next);
      });
    }

    await qa.step('TALABA: Imtihon rejimi', (s) async {
      await open(Routes.home);
      await qa.tapFinder(find.byKey(const Key('workbench.deskExam')));
      hygiene(s);
    });

    // ----------------------------------------- Sinfda test: talaba qo‘shiladi
    await qa.step('TALABA: sinf testiga kod bilan qo‘shilish', (s) async {
      await open(Routes.classJoin);
      if (classCode == null || classCode!.isEmpty) {
        s.passed = false;
        s.notes.add('sinf kodi olinmadi');
        return;
      }
      await qa.enterText(find.byKey(const Key('class.joinCode')), classCode!);
      final nick = find.byKey(const Key('class.nickField'));
      if (nick.evaluate().isNotEmpty) await qa.enterText(nick, 'Talaba QA');
      hygiene(s);
    });
    await qa.step('TALABA: sinf testi — kutish zali', (s) async {
      await qa.tapFinder(find.byKey(const Key('class.joinSubmit')));
      await qa.settle(maxMs: 4000);
      hygiene(s);
    });

    // ------------------------------------------------------- Guruhim
    await qa.step('TALABA: Guruhim (kirgan holat)', (s) async {
      await open(Routes.groups);
      hygiene(s);
    });
    await qa.step('TALABA: kod bilan qo‘shilish', (s) async {
      await qa.tapFinder(find.byKey(const Key('grp.joinButton')));
      if (groupCode == null || groupCode!.isEmpty) {
        s.passed = false;
        s.notes.add('guruh kodi olinmadi (ustoz bosqichi muvaffaqiyatsiz)');
        return;
      }
      await qa.enterText(find.byKey(const Key('grp.codeField')), groupCode!);
      await qa.tapFinder(find.byKey(const Key('grp.joinSubmit')));
      await qa.settle(maxMs: 3000);
      hygiene(s);
    });
    await qa.step('TALABA: taxallus → qo‘shilish', (s) async {
      final nick = find.byKey(const Key('grp.nickField'));
      if (nick.evaluate().isNotEmpty) {
        await qa.enterText(nick, 'Talaba QA');
        await qa.tapFinder(find.byKey(const Key('grp.joinSubmit')));
        await qa.settle(maxMs: 4000);
      }
      hygiene(s);
    });
    await qa.step('TALABA: guruh sahifasi', (s) async {
      final f = find.byWidgetPredicate(
        (w) => w.key is Key && '${w.key}'.contains('grp.myAssignment.'),
      );
      if (f.evaluate().isEmpty) {
        s.notes.add('berilgan test ko‘rinmadi');
      }
      hygiene(s);
    });
    await qa.step('TALABA: guruh testini boshlash', (s) async {
      final start = find.byWidgetPredicate(
        (w) => w.key is Key && '${w.key}'.contains('grp.start.'),
      );
      await qa.scrollUntil(start);
      if (start.evaluate().isEmpty) {
        s.passed = false;
        s.notes.add('«Boshlash» tugmasi yo‘q');
        return;
      }
      await qa.tapFinder(start);
      await qa.settle(maxMs: 4000);
      hygiene(s);
    });
    for (var i = 1; i <= 12; i++) {
      final done = find.byKey(const Key('grp.score')).evaluate().isNotEmpty;
      if (done) break;
      await qa.step('TALABA: guruh testi savol $i', (s) async {
        final opt = find.byKey(const Key('grp.option.0'));
        if (opt.evaluate().isEmpty) {
          s.notes.add('savol ekrani yo‘q');
          return;
        }
        await qa.tapFinder(opt);
        await qa.tapFinder(find.byKey(const Key('grp.confirm')));
        hygiene(s);
        final fin = find.byKey(const Key('grp.finish'));
        if (fin.evaluate().isNotEmpty) {
          await qa.tapFinder(fin);
          await qa.tapFinder(find.byKey(const Key('grp.submitYes')));
          await qa.settle(maxMs: 4000);
        } else {
          final next = find.byKey(const Key('grp.next'));
          if (next.evaluate().isNotEmpty) await qa.tapFinder(next);
        }
      });
    }
    await qa.step('TALABA: natija (ball)', (s) async {
      if (find.byKey(const Key('grp.score')).evaluate().isEmpty) {
        s.passed = false;
        s.notes.add('ball ko‘rinmadi');
      }
      hygiene(s);
    });
    await qa.step('TALABA: natija (pastga)', (s) async {
      await qa.scrollBy(700);
      hygiene(s);
    });

    // ------------------------------------------------ 320 dp va qorong‘i
    await qa.setSize(const Size(320, 640));
    await qa.step('320 TALABA Asosiy (yuqori)', (s) async {
      await open(Routes.home);
      hygiene(s);
    });
    await qa.step('320 TALABA Asosiy (pastga)', (s) async {
      await qa.scrollBy(650);
      hygiene(s);
    });
    await qa.step('320 TALABA Asosiy (pastki)', (s) async {
      await qa.scrollBy(4000);
      hygiene(s);
    });
    await qa.step('320 TALABA Guruhim', (s) async {
      await open(Routes.groups);
      hygiene(s);
    });
    await qa.step('320 USTOZ paneli', (s) async {
      await open(Routes.teacher);
      hygiene(s);
    });
    await qa.setSize(const Size(390, 844));

    await settings().setThemeMode(ThemeMode.dark);
    await qa.step('QORONG‘I TALABA Asosiy (yuqori)', (s) async {
      await open(Routes.home);
      hygiene(s);
    });
    await qa.step('QORONG‘I TALABA Asosiy (pastga)', (s) async {
      await qa.scrollBy(650);
      hygiene(s);
    });
    await qa.step('QORONG‘I TALABA Guruhim', (s) async {
      await open(Routes.groups);
      hygiene(s);
    });
    await qa.step('QORONG‘I USTOZ paneli', (s) async {
      await open(Routes.teacher);
      hygiene(s);
    });
    await settings().setThemeMode(ThemeMode.light);

    qa.writeResults();
    printSummary(qa);
    qa.restoreErrorHandler();
  });
}
