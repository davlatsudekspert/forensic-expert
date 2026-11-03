// REAL-ILOVA QA — «Guruh og‘zaki imtihoni» (QR): USTOZ + TALABA, 2026-11-03.
//
// Haqiqiy ilova (`bootstrap()`), MOCK akkaunt, tarmoq o‘chiq. Demo server
// xotirada: bitta qurilma ham ustoz, ham talaba (3 ta DEMO talaba avtomatik
// qo‘shiladi). Doskada ball yo‘qligi, talaba o‘z ballini ko‘rishi, rol
// himoyasi, 320 dp tekshiriladi.
// Ishga tushirish: `QA_OUT=/dev/shm/qa_oralgroup tool/qa_real_app.sh oralgroup`.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/oral_group.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/routes.dart';
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

  testWidgets('QA real app — ORAL GROUP (ustoz + talaba)', (tester) async {
    final net = NoNetworkOverrides();
    HttpOverrides.global = net;
    final l = lookupAppLocalizations(const Locale('uz'));
    final qa = await launchRealApp(tester, role: 'oralgroup');
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

    Future<String> sessionId() async {
      final r = await tester.runAsync(
        () => containerOf(tester).read(oralGroupServiceProvider).mySessions(),
      );
      return r!.value!.first.id;
    }

    Future<String> sessionCode() async {
      final r = await tester.runAsync(
        () => containerOf(tester).read(oralGroupServiceProvider).mySessions(),
      );
      return r!.value!.first.code;
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
        () => auth.requestEmailCode('oralgroup.ustoz@example.test'),
      );
      final code = lastMockCode(tester)!;
      await tester.runAsync(
        () => auth.verifyEmailCode(
          email: 'oralgroup.ustoz@example.test',
          code: code,
        ),
      );
      await qa.settle(maxMs: 3000);
      await open(Routes.teacherOral);
      need(s, 'toral.list');
    }, shot: false);

    // ------------------------------------------------------------ tanlash
    await qa.step('Mavzu tanlash: ikki tugma, mavzusiz «Guruhga (QR)» yopiq', (
      s,
    ) async {
      need(s, 'toral.build');
      need(s, 'toral.group');
      qa.expectText(l.oralGroupButton, s);
      qa.expectText(l.teacherOralBuild, s);
      final g = tester.widget<OutlinedButton>(
        find.byKey(const Key('toral.group')),
      );
      if (g.onPressed != null) {
        s.passed = false;
        s.notes.add('mavzusiz «Guruhga (QR)» faol');
      }
      hygiene(s);
    });
    await qa.step('Kurs chiplari to‘liq kenglikda, chapdan boshlanadi', (
      s,
    ) async {
      final chips = find.byKey(const Key('toral.courses'));
      if (chips.evaluate().isNotEmpty) {
        final w = tester.getSize(chips).width;
        final screen = tester.view.physicalSize.width;
        final left = tester
            .getTopLeft(find.byKey(const Key('toral.course.all')))
            .dx;
        s.notes.add('chiplar kengligi $w / ekran $screen, chap=$left');
        if (w < screen - 40) {
          s.passed = false;
          s.notes.add('chiplar to‘liq kenglikda emas');
        }
      }
    });
    await qa.step('320×640: ikki tugma tartibli', (s) async {
      await qa.setSize(const Size(320, 640));
      await qa.tapFinder(find.byKey(const Key('toral.topic.demo-toks')));
      need(s, 'toral.build');
      need(s, 'toral.group');
      hygiene(s);
    });
    await qa.setSize(const Size(390, 844));
    await qa.step('Uch mavzu → «Guruhga (QR)» → sozlash', (s) async {
      await qa.tapFinder(find.byKey(const Key('toral.topic.demo-trauma')));
      await qa.tapFinder(find.byKey(const Key('toral.topic.demo-asfiksiya')));
      await qa.tapFinder(find.byKey(const Key('toral.group')));
      need(s, 'oralgroup.setupList');
      need(s, 'oralgroup.count');
      need(s, 'oralgroup.start');
      qa.expectText(l.oralGroupSetupIntro, s);
      final pool = containerOf(tester).read(oralGroupMySessionsProvider).value;
      s.notes.add('mavzular kaliti: $selKey; faol: ${pool?.value?.length}');
      hygiene(s);
    });
    await qa.step('Sozlash: 5 talaba, 10 daqiqa, takror ogohlantirishi', (
      s,
    ) async {
      await qa.enterText(find.byKey(const Key('oralgroup.count')), '5');
      await qa.tapFinder(find.byKey(const Key('oralgroup.prep.10')));
      need(s, 'oralgroup.available');
      hygiene(s);
    });
    await qa.step('320×640: sozlash', (s) async {
      await qa.setSize(const Size(320, 640));
      need(s, 'oralgroup.start');
      hygiene(s);
    });
    await qa.setSize(const Size(390, 844));
    await qa.step('Boshlash → doska (QR + kod, 3 DEMO talaba)', (s) async {
      await qa.tapFinder(find.byKey(const Key('oralgroup.start')));
      need(s, 'class.qr');
      need(s, 'oralgroup.joinLink');
      need(s, 'oralgroup.grid');
      qa.expectText(l.oralGroupJoinedCount(3, 5), s);
      qa.expectText('DEMO 1', s);
      // Doskada BALL yo‘q.
      if (qa.showsText('/ 100')) {
        s.passed = false;
        s.notes.add('doskada ball ko‘rinadi');
      }
      hygiene(s);
    });
    await qa.step('320×640: doska', (s) async {
      await qa.setSize(const Size(320, 640));
      need(s, 'class.qr');
      hygiene(s);
    });
    await qa.step('320×640: doska (pastga: tugmalar)', (s) async {
      await qa.scrollBy(4000);
      need(s, 'oralgroup.queueButton');
      need(s, 'oralgroup.finishButton');
      hygiene(s);
    });
    await qa.setSize(const Size(390, 844));

    // ------------------------------------------------------ talaba (shu qurilma)
    late String code;
    late String id;
    await qa.step('TALABA: QR havolasi (t=oral) qo‘shilish ekranini ochadi', (
      s,
    ) async {
      code = await sessionCode();
      id = await sessionId();
      goTo(tester, '/join/$code?t=oral');
      await qa.settle(maxMs: 5000);
      need(s, 'oralgroup.joinCode');
      need(s, 'oralgroup.joinName');
      qa.expectText(l.oralJoinTitle, s);
      hygiene(s);
    });
    await qa.step('TALABA: noto‘g‘ri ism → xato matni', (s) async {
      await qa.enterText(find.byKey(const Key('oralgroup.joinName')), 'A');
      await qa.tapFinder(find.byKey(const Key('oralgroup.joinSubmit')));
      qa.expectText(l.oralErrNameLength, s);
    });
    await qa.step('TALABA: ism kiritildi → bilet ekrani', (s) async {
      await qa.enterText(
        find.byKey(const Key('oralgroup.joinName')),
        'QA Talaba',
      );
      await qa.tapFinder(find.byKey(const Key('oralgroup.joinSubmit')));
      need(s, 'oralgroup.ticketNo');
      need(s, 'oralgroup.ready');
      for (var i = 0; i < 5; i++) {
        need(s, 'oralgroup.q.$i');
      }
      // Javob kaliti talabaga ko‘rinmaydi.
      need(s, 'oral.key.0', present: false);
      qa.expectText('Tayyorlanish vaqti:', s);
      hygiene(s);
    });
    await qa.step('320×640: talaba bileti', (s) async {
      await qa.setSize(const Size(320, 640));
      need(s, 'oralgroup.ticketNo');
      hygiene(s);
    });
    await qa.setSize(const Size(390, 844));
    await qa.step('TALABA: «Javobga tayyorman» → Navbatdasiz', (s) async {
      await qa.tapFinder(find.byKey(const Key('oralgroup.ready')));
      qa.expectText(l.oralPlayWaiting, s);
      need(s, 'oralgroup.ready', present: false);
    });

    await qa.step('TALABA: ilovadan chiqdi → qaytdi (ustozga ko‘rinadi)', (
      s,
    ) async {
      for (final st in [
        AppLifecycleState.inactive,
        AppLifecycleState.hidden,
        AppLifecycleState.paused,
        AppLifecycleState.hidden,
        AppLifecycleState.inactive,
        AppLifecycleState.resumed,
      ]) {
        tester.binding.handleAppLifecycleStateChanged(st);
      }
      // Holat har 3 s so‘raladi: yangi hisob ko‘rinishini kutamiz.
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(seconds: 4)),
      );
      await qa.settle(maxMs: 4000);
      need(s, 'oralgroup.leaveCount');
      qa.expectText(l.oralPlayLeaveCount(1), s);
      need(s, 'ac.studentNote');
      hygiene(s);
    });

    // ------------------------------------------------------------ navbat
    await qa.step('USTOZ: navbatda talaba «Tayyor» bo‘limida', (s) async {
      await open(Routes.oralGroupQueue(id));
      need(s, 'oralgroup.queueList');
      qa.expectText(l.oralGroupSectionReady(1), s);
      qa.expectText('QA Talaba', s);
      qa.expectText(l.oralGroupSectionJoined(3), s);
      if (find.textContaining('ilovadan chiqdi').evaluate().isEmpty) {
        s.passed = false;
        s.notes.add('chiqish belgisi (ilovadan chiqdi) yo‘q');
      }
      hygiene(s);
    });
    await qa.step('USTOZ: talabani bosdi → chaqirildi, baholash ekrani', (
      s,
    ) async {
      await qa.tapText('QA Talaba');
      need(s, 'oralgroup.gradeList');
      qa.expectText(l.oralGroupGradeTitle, s);
      qa.expectText('QA Talaba', s);
      for (var i = 0; i < 5; i++) {
        need(s, 'oral.q.$i');
      }
      final save = tester.widget<FilledButton>(
        find.byKey(const Key('oralgroup.save')),
      );
      if (save.onPressed != null) {
        s.passed = false;
        s.notes.add('ball qo‘yilmay turib Saqlash faol');
      }
      hygiene(s);
    });
    await qa.step('USTOZ: javob kaliti ochiladi (mahalliy havzadan)', (
      s,
    ) async {
      await qa.tapFinder(find.byKey(const Key('oral.key.0')));
      qa.expectText(l.teacherOralKeyNote, s);
      hygiene(s);
    });
    await qa.step('320×640: baholash', (s) async {
      await qa.setSize(const Size(320, 640));
      need(s, 'oralgroup.save');
      hygiene(s);
    });
    await qa.setSize(const Size(390, 844));
    await qa.step('USTOZ: 5 savolga ball → Saqlash → navbat', (s) async {
      for (var i = 0; i < 5; i++) {
        await qa.tapFinder(find.byKey(Key('oral.slider.$i')));
      }
      await qa.tapFinder(find.byKey(const Key('oralgroup.save')));
      qa.expectText(l.oralGroupSectionGraded(1), s);
      need(s, 'oralgroup.queueList');
      hygiene(s);
    });

    // -------------------------------------------- talaba o‘z natijasini ko‘radi
    await qa.step('TALABA: o‘z balini ko‘radi (Jami: x / 100)', (s) async {
      await open(Routes.oralPlay(id));
      await qa.settle(maxMs: 4000);
      need(s, 'oralgroup.result');
      need(s, 'oralgroup.total');
      qa.expectText('/ 100', s);
      need(s, 'oralgroup.score.0');
      hygiene(s);
    });

    // ------------------------------------------------------------ doska va natija
    await qa.step('USTOZ: doskada «baholandi», ball yo‘q', (s) async {
      await open(Routes.oralGroupHost(id));
      // «Baho saqlandi: x / 100» snackbar’i o‘tib ketsin (u doska emas).
      await tester.pump(const Duration(seconds: 6));
      await qa.settle();
      qa.expectText(l.oralGroupStatusGraded, s);
      if (qa.showsText('/ 100')) {
        s.passed = false;
        s.notes.add('doskada ball ko‘rinadi');
      }
      hygiene(s);
    });
    await qa.step('USTOZ: natijalar ro‘yxati', (s) async {
      await open(Routes.oralGroupResults(id));
      need(s, 'oralgroup.resultsList');
      qa.expectText('QA Talaba', s);
      qa.expectText('/ 100', s);
      need(s, 'oralgroup.export');
      hygiene(s);
    });
    await qa.step('USTOZ: yakunlash (tasdiq bilan)', (s) async {
      await open(Routes.oralGroupHost(id));
      await qa.tapFinder(find.byKey(const Key('oralgroup.finishButton')));
      qa.expectText(l.oralGroupFinishTitle, s);
      await qa.tapFinder(find.byKey(const Key('oralgroup.finishConfirm')));
      need(s, 'oralgroup.finishedBanner');
      need(s, 'oralgroup.finishButton', present: false);
      hygiene(s);
    });
    await qa.step('Faol imtihonlar ro‘yxati (yakunlangan bo‘limda)', (s) async {
      await open(Routes.teacherOralGroup);
      need(s, 'oralgroup.noTopics');
      qa.expectText(l.oralGroupFinishedSection, s);
      hygiene(s);
    });

    // ------------------------------------------------------------ xatolar
    await qa.step('TALABA: noto‘g‘ri kod → tushunarli xato', (s) async {
      goTo(tester, Routes.oralJoinWith('123456'));
      await qa.settle(maxMs: 4000);
      await qa.enterText(find.byKey(const Key('oralgroup.joinName')), 'Vali');
      await qa.tapFinder(find.byKey(const Key('oralgroup.joinSubmit')));
      qa.expectText(l.oralErrNotFound, s);
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
      await qa.step('$name: guruh imtihoni ustoz marshrutlari yopiq', (
        s,
      ) async {
        await settings().setUserMode(mode);
        await open(Routes.home);
        need(s, 'workbench.teachOral', present: false);
        for (final r in [
          Routes.teacherOralGroup,
          Routes.oralGroupHost(id),
          Routes.oralGroupQueue(id),
          Routes.oralGroupResults(id),
        ]) {
          goTo(tester, r);
          await qa.settle(maxMs: 4000);
          need(s, 'oralgroup.setupList', present: false);
          need(s, 'class.qr', present: false);
          need(s, 'oralgroup.queueList', present: false);
          need(s, 'oralgroup.resultsList', present: false);
        }
      });
      await qa.step('$name: QR kodni kiritib qo‘shila oladi (join ekrani)', (
        s,
      ) async {
        goTo(tester, Routes.oralJoinWith(code));
        await qa.settle(maxMs: 4000);
        need(s, 'oralgroup.joinName');
        hygiene(s);
      });
    }

    qa.restoreErrorHandler();
    qa.writeResults();
    printSummary(qa);
    HttpOverrides.global = null;
  });
}
