// REAL-ILOVA QA — USTOZ: «Ustoz stolim» → Og‘zaki imtihon (bilet) (mavzu
// bo‘yicha, slayd sarlavhalaridan), shuningdek Talaba/Mutaxassis uchun yopiqligi.
// Haqiqiy ilova (`bootstrap()`), demo darslar (FakeLessonsService), MOCK
// akkaunt, tarmoq o‘chiq.
// Ishga tushirish: `QA_OUT=/dev/shm/qa_toral tool/qa_real_app.sh teacheroral`.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/router.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/app/teacher_oral.dart';
import 'package:forensic_expert/core/l10n/generated/app_localizations.dart';
import 'package:forensic_expert/core/settings/app_settings.dart';
import 'package:forensic_expert/core/settings/settings_controller.dart';
import 'package:forensic_expert/domain/lessons/lesson_oral.dart';
import 'package:integration_test/integration_test.dart';

import 'qa/harness.dart';
import 'qa/qa_env.dart';

final _cyrillic = RegExp('[А-Яа-яЁё]');

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('QA real app — TEACHER ORAL (ustoz bileti)', (tester) async {
    final net = NoNetworkOverrides();
    HttpOverrides.global = net;
    final l = lookupAppLocalizations(const Locale('uz'));
    final qa = await launchRealApp(tester, role: 'teacheroral');
    SettingsController settings() =>
        containerOf(tester).read(settingsControllerProvider.notifier);

    const topics = ['demo-toks', 'demo-trauma', 'demo-asfiksiya'];
    final selKey = topicSelectionKey(topics);

    void hygiene(QaStep s) {
      final cyr = qa.visibleTexts().where(_cyrillic.hasMatch).toList();
      if (cyr.isNotEmpty) {
        s.passed = false;
        s.notes.add('KIRILCHA: ${cyr.take(3).join(' | ')}');
      }
    }

    void need(QaStep s, String key, {bool present = true}) {
      final has = find.byKey(Key(key)).evaluate().isNotEmpty;
      if (has != present) {
        s.passed = false;
        s.notes.add(present ? '$key yo‘q' : '$key kutilmagan edi');
      }
    }

    Future<void> open(String route) async {
      goTo(tester, route);
      await qa.settle(maxMs: 5000);
      await qa.scrollToTop();
    }

    // ----------------------------------------------------------- onboarding
    await qa.step('Onboarding: til', (s) async {
      await qa.tapText('O‘zbekcha');
      await qa.tapText(l.actionContinue);
      qa.expectText(l.disclaimerTitle, s);
    });
    await qa.step('Tushundim → Rejim: Ustoz', (s) async {
      await qa.tapText(l.disclaimerAccept);
      await qa.tapFinder(find.byKey(const Key('mode.teacher')));
      qa.expectText(l.modeTeacherNote, s);
    });
    await qa.step('Davom → Boshlash → USTOZ Asosiy', (s) async {
      await qa.tapFinder(find.byKey(const Key('mode.continue')));
      await qa.tapFinder(find.byKey(const Key('account.skip')));
      qa.expectText('Rejim: Ustoz', s);
      hygiene(s);
    });
    await qa.step('USTOZ: kirish (MOCK)', (s) async {
      final auth = containerOf(tester).read(authRepositoryProvider);
      await tester.runAsync(
        () => auth.requestEmailCode('oral.ustoz@example.test'),
      );
      final code = lastMockCode(tester)!;
      await tester.runAsync(
        () =>
            auth.verifyEmailCode(email: 'oral.ustoz@example.test', code: code),
      );
      await qa.settle(maxMs: 3000);
      await open(Routes.home);
      need(s, 'desk.teacher');
    }, shot: false);

    // ------------------------------------------------------------ Asosiy
    await qa.step('Asosiy: stolda «Og‘zaki imtihon (bilet)» kartasi', (
      s,
    ) async {
      await open(Routes.home);
      final f = find.byKey(const Key('workbench.teachOral'));
      await qa.scrollUntil(f);
      if (f.evaluate().isEmpty) {
        s.passed = false;
        s.notes.add('workbench.teachOral yo‘q');
      } else {
        await tester.ensureVisible(f.first);
        await qa.settle();
        qa.expectText(l.oralExamStart, s);
        qa.expectText(l.teacherOralDeskBody, s);
      }
      hygiene(s);
    });

    await qa.step('Karta bosildi → mavzu tanlash (izoh ko‘rinadi)', (s) async {
      await qa.tapFinder(find.byKey(const Key('workbench.teachOral')));
      need(s, 'toral.list');
      need(s, 'toral.intro');
      need(s, 'toral.search');
      qa.expectText(l.teacherOralIntro, s);
      qa.expectText(l.teacherOralPickHint, s);
      final build = tester.widget<FilledButton>(
        find.byKey(const Key('toral.build')),
      );
      if (build.onPressed != null) {
        s.passed = false;
        s.notes.add('mavzu tanlanmay turib «Bilet tuzish» faol');
      }
      hygiene(s);
    });

    await qa.step('Demo mavzular ro‘yxatda', (s) async {
      for (final t in topics) {
        need(s, 'toral.topic.$t');
      }
      need(s, 'toral.course.all');
    });

    await qa.step('Qidiruv: «asfiksiya» ro‘yxatni toraytiradi', (s) async {
      await qa.enterText(find.byKey(const Key('toral.search')), 'asfiksiya');
      need(s, 'toral.topic.demo-asfiksiya');
      need(s, 'toral.topic.demo-toks', present: false);
      await qa.enterText(find.byKey(const Key('toral.search')), '');
      need(s, 'toral.topic.demo-toks');
    });

    await qa.step('Bitta mavzu belgilandi → «Tanlandi: 1»', (s) async {
      await qa.tapFinder(find.byKey(const Key('toral.topic.demo-toks')));
      qa.expectText(l.teacherOralSelected(1), s);
    });
    await qa.step('Yana ikkitasi → «Tanlandi: 3», tugma faol', (s) async {
      await qa.tapFinder(find.byKey(const Key('toral.topic.demo-trauma')));
      await qa.tapFinder(find.byKey(const Key('toral.topic.demo-asfiksiya')));
      qa.expectText(l.teacherOralSelected(3), s);
      final build = tester.widget<FilledButton>(
        find.byKey(const Key('toral.build')),
      );
      if (build.onPressed == null) {
        s.passed = false;
        s.notes.add('«Bilet tuzish» o‘chiq');
      }
    });

    await qa.step('320×640: mavzu tanlash', (s) async {
      await qa.setSize(const Size(320, 640));
      need(s, 'toral.build');
      hygiene(s);
    });
    await qa.setSize(const Size(390, 844));

    await qa.step('Bilet tuzish → savollar havzasi', (s) async {
      await qa.tapFinder(find.byKey(const Key('toral.build')));
      need(s, 'toral.ticketList');
      need(s, 'oral.pool');
      need(s, 'oral.draw');
      need(s, 'toral.changeTopics');
      qa.expectText('Ishlatilgan savollar: 0 /', s);
      final pool = containerOf(tester)
          .read(teacherOralPoolProvider(selKey))
          .value;
      s.notes.add('havza: ${pool?.questions.length} savol');
      if (pool == null || pool.questions.length < 5) {
        s.passed = false;
        s.notes.add('havza 5 dan kam');
      }
      hygiene(s);
    });

    late Set<String> first;
    late int poolSize;
    await qa.step('Bilet chiqarildi: 5 savol, ball yo‘q, saqlab bo‘lmaydi', (
      s,
    ) async {
      await qa.tapFinder(find.byKey(const Key('oral.draw')));
      qa.expectText(l.oralExamTicketNo(1), s);
      qa.expectText(l.oralExamTotal(0), s);
      for (var i = 0; i < 5; i++) {
        need(s, 'oral.q.$i');
      }
      final st = containerOf(tester).read(teacherOralProvider);
      first = st.questionIds.toSet();
      poolSize = containerOf(tester)
          .read(teacherOralPoolProvider(selKey))
          .value!
          .questions
          .length;
      if (first.length != 5) {
        s.passed = false;
        s.notes.add('bilet ${first.length} ta savol');
      }
      final save = tester.widget<FilledButton>(
        find.byKey(const Key('oral.save')),
      );
      if (save.onPressed != null) {
        s.passed = false;
        s.notes.add('ball qo‘yilmay turib saqlash faol');
      }
      qa.expectText('Ishlatilgan savollar: 5 / $poolSize', s);
      hygiene(s);
    });

    await qa.step('Javob kaliti ochiladi (slayd bandlari + manba)', (s) async {
      await qa.tapFinder(find.byKey(const Key('oral.key.0')));
      qa.expectText(l.teacherOralKeyNote, s);
      qa.expectText('• ', s);
      qa.expectText('Namuna A.', s, why: 'manba qatori');
      hygiene(s);
    });

    await qa.step('Slayderlar bilan 5 savolga ball', (s) async {
      for (var i = 0; i < 5; i++) {
        await qa.tapFinder(find.byKey(Key('oral.slider.$i')));
      }
      final st = containerOf(tester).read(teacherOralProvider);
      if (!st.allScored) {
        s.passed = false;
        s.notes.add('allScored=false');
      }
      s.notes.add('jami ${st.total}');
      hygiene(s);
    });

    await qa.step('Ism kiritildi → Saqlash faol', (s) async {
      await qa.enterText(find.byKey(const Key('oral.name')), 'QA Talaba Bir');
      final save = tester.widget<FilledButton>(
        find.byKey(const Key('oral.save')),
      );
      if (save.onPressed == null) {
        s.passed = false;
        s.notes.add('Saqlash o‘chiq');
      }
    });

    await qa.step('Saqlandi: tarixda ko‘rinadi', (s) async {
      await qa.tapFinder(find.byKey(const Key('oral.save')));
      qa.expectText('Natija saqlandi:', s);
      qa.expectText('QA Talaba Bir', s);
      need(s, 'oral.draw');
      need(s, 'oral.historyEmpty', present: false);
      need(s, 'oral.clearHistory');
      hygiene(s);
    });

    await qa.step('Ikkinchi bilet', (s) async {
      await qa.tapFinder(find.byKey(const Key('oral.draw')));
      qa.expectText(l.oralExamTicketNo(2), s);
      final st = containerOf(tester).read(teacherOralProvider);
      final second = st.questionIds.toSet();
      if (poolSize >= 10) {
        if (second.intersection(first).isNotEmpty) {
          s.passed = false;
          s.notes.add('TAKRORLANDI: ${second.intersection(first)}');
        }
        need(s, 'oral.poolReset', present: false);
        qa.expectText('Ishlatilgan savollar: 10 / $poolSize', s);
      } else {
        s.notes.add('havza $poolSize < 10: takror ruxsat, reset hisobi');
        final fresh = poolSize - 5;
        final expectReset = fresh < 5;
        need(s, 'oral.poolReset', present: expectReset);
        if (expectReset) qa.expectText(l.oralExamPoolReset, s);
      }
      s.notes.add('2-bilet: ${st.questionIds}');
      hygiene(s);
    });

    await qa.step('320×640: bilet (kalit ochiq)', (s) async {
      await qa.setSize(const Size(320, 640));
      await qa.scrollToTop();
      final k = find.byKey(const Key('oral.key.1'));
      await qa.tapFinder(k);
      need(s, 'oral.q.1');
      hygiene(s);
    });
    await qa.step('320×640: bilet (pastga, tarix)', (s) async {
      await qa.scrollBy(4000);
      need(s, 'oral.resetPool');
      qa.expectText('QA Talaba Bir', s);
      hygiene(s);
    });
    await qa.setSize(const Size(390, 844));

    await qa.step('«Mavzularni o‘zgartirish» → mavzu tanlashga qaytadi', (
      s,
    ) async {
      await qa.scrollToTop();
      await qa.tapFinder(find.byKey(const Key('toral.changeTopics')));
      need(s, 'toral.list');
      need(s, 'toral.build');
      hygiene(s);
    });

    await qa.step('Tarmoq o‘chiq: oflayn ishladi', (s) async {
      s.notes.add('Bloklangan HTTP urinishlari: ${net.attempts}');
    }, shot: false);

    // -------------------------------------- Talaba / Mutaxassis: yopiq
    for (final (mode, name) in [
      (UserMode.student, 'TALABA'),
      (UserMode.professional, 'MUTAXASSIS'),
    ]) {
      await qa.step('$name: Asosiyda karta yo‘q', (s) async {
        await settings().setUserMode(mode);
        await open(Routes.home);
        need(s, 'workbench.teachOral', present: false);
        need(s, 'desk.teacher', present: false);
        await qa.scrollBy(4000);
        need(s, 'workbench.teachOral', present: false);
        qa.expectNoText(l.teacherOralIntro, s);
      });
      await qa.step('$name: /home/teacher/oral Asosiyga qaytaradi', (s) async {
        goTo(tester, Routes.teacherOral);
        await qa.settle(maxMs: 4000);
        need(s, 'toral.list', present: false);
        qa.expectNoText(l.teacherOralIntro, s);
        goTo(tester, Routes.teacherOralTicket(selKey));
        await qa.settle(maxMs: 4000);
        need(s, 'toral.ticketList', present: false);
        goTo(tester, Routes.teacherOral);
        await qa.settle(maxMs: 4000);
        final loc = containerOf(tester)
            .read(routerProvider)
            .routeInformationProvider
            .value
            .uri
            .path;
        s.notes.add('joylashuv: $loc');
        if (loc != Routes.home) {
          s.passed = false;
          s.notes.add('Asosiyga qaytmadi');
        }
      });
    }

    qa.restoreErrorHandler();
    qa.writeResults();
    printSummary(qa);
    HttpOverrides.global = null;
  });
}
