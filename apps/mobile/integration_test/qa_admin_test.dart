// REAL-ILOVA QA — ADMIN (identity_admin) yo‘li.
//
// Haqiqiy ilova (`bootstrap()`), haqiqiy router va Linux desktop dvigateli.
// Akkaunt — MOCK, admin huquqi — soxta «server» `my_access` javobi
// (`QaAccountService(admin: true)`), murojaatlar serveri — xotiradagi
// `InMemorySupportService`. Tarmoq — o‘chirilgan.
//
// Bu UI testi: serverdagi haqiqiy cheklovlar (RLS, identity_admin, RPC)
// `supabase/tests/*.sql` da lokal PostgreSQL’da tekshiriladi.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/account.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/app/support.dart';
import 'package:forensic_expert/core/l10n/generated/app_localizations.dart';
import 'package:forensic_expert/data/support/in_memory_support_service.dart';
import 'package:forensic_expert/domain/support/support_models.dart';
import 'package:integration_test/integration_test.dart';

import 'qa/harness.dart';
import 'qa/qa_env.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('QA real app — ADMIN', (tester) async {
    final net = NoNetworkOverrides();
    HttpOverrides.global = net;
    final l = lookupAppLocalizations(const Locale('uz'));
    final ru = lookupAppLocalizations(const Locale('ru'));
    final en = lookupAppLocalizations(const Locale('en'));

    // Soxta server ma’lumotlari (FIXTURE): 3 ta asosiy murojaat + 25 ta
    // to‘ldiruvchi (sahifalash uchun), 30 ta foydalanuvchi.
    final support = InMemorySupportService(isAdmin: true, stats: qaAdminStats)
      ..users.addAll(qaAdminUsers());
    for (var i = 1; i <= 25; i++) {
      support.seedThread(
        category: SupportCategory.general,
        subject: 'Umumiy savol №$i',
        body: 'To‘ldiruvchi murojaat $i.',
        authorEmail:
            'user${(i % 28 + 1).toString().padLeft(2, '0')}'
            '@example.test',
      );
    }
    final sciId = support.seedThread(
      category: SupportCategory.scientificError,
      subject: 'Xato: Etanol',
      body: 'Yarim chiqarilish davri manbadagidan farq qiladi.',
      authorEmail: 'expert@example.test',
      relatedEntity: 'substance:ethanol',
    );
    support.seedThread(
      category: SupportCategory.suggestion,
      subject: 'Tungi navbat uchun qorong‘i mavzu',
      body: 'Kechasi ishlaganda qorong‘iroq mavzu kerak.',
      authorEmail: 'student@example.test',
    );
    final bugId = support.seedThread(
      category: SupportCategory.bug,
      subject: 'Qidiruvda ilova yopilib qoladi',
      body: '«morfin» deb yozganda ilova yopiladi (Android 14).',
      authorEmail: 'user03@example.test',
    );

    final qa = await launchRealApp(
      tester,
      role: 'admin',
      overrides: [
        accountServiceProvider.overrideWithValue(QaAccountService(admin: true)),
        supportServiceProvider.overrideWithValue(support),
      ],
    );

    // ------------------------------------------------- onboarding + kirish
    await qa.step('Onboarding → MOCK OTP bilan kirish', (s) async {
      await qa.tapText('O‘zbekcha');
      await qa.tapText(l.actionContinue);
      await qa.tapText(l.disclaimerAccept);
      await qa.tapText(l.modeStudent);
      await qa.tapText(l.actionContinue);
      await qa.tapText('Hisobsiz davom etish');
      goTo(tester, Routes.accountEmailCode);
      await qa.settle();
      await mockSignIn(qa, tester, 'qa.admin@example.test');
      goTo(tester, Routes.profile);
      await qa.settle();
      qa.expectText('qa.admin@example.test', s);
    }, shot: false);

    await qa.step('Profil: «${l.adminTitle}» qatori (server is_admin)', (
      s,
    ) async {
      await qa.scrollUntil(find.byKey(const Key('profile.admin')));
      if (find.byKey(const Key('profile.admin')).evaluate().isEmpty) {
        s.passed = false;
        s.notes.add('Admin qatori yo‘q');
      }
      qa.expectText(l.adminTitle, s);
    });

    // ---------------------------------------------------------- panel
    await qa.step('Boshqaruv paneli: statistika (FIXTURE)', (s) async {
      clearSnackBars(tester);
      await qa.tapFinder(find.byKey(const Key('profile.admin')));
      for (final k in ['admin.overview', 'admin.sections']) {
        if (find.byKey(Key(k)).evaluate().isEmpty) {
          s.passed = false;
          s.notes.add('$k yo‘q');
        }
      }
      qa.expectText('128', s);
      qa.expectText(l.admOverview, s);
      qa.expectText(l.admNavInboxHint(3), s);
      qa.expectText(l.admStatVerified, s);
    });

    await qa.step('Panel: davlatlar va 14 kunlik grafik', (s) async {
      await qa.scrollUntil(find.byKey(const Key('admin.chart')));
      if (find.byKey(const Key('admin.chart')).evaluate().isEmpty) {
        s.notes.add('admin.chart topilmadi (scroll)');
      }
      await qa.scrollUntil(find.text(l.adminRegions));
      qa.expectText(l.adminRegions, s);
      qa.expectText(l.adminUnknownRegion, s, why: '?? → Noma’lum');
    }, shot: false);

    // ---------------------------------------------------------- inbox
    await qa.step('Murojaatlar qutisi: «${l.admFilterAwaiting}»', (s) async {
      goTo(tester, Routes.admin);
      await qa.settle();
      await qa.tapFinder(find.byKey(const Key('admin.nav.inbox')));
      qa.expectText(l.admNavInbox, s);
      qa.expectText(l.admShown(25, 28), s);
      qa.expectText('Qidiruvda ilova yopilib qoladi', s);
      qa.expectText('student@example.test', s);
      if (find.byKey(const Key('adminInbox.more')).evaluate().isEmpty) {
        await qa.scrollUntil(find.byKey(const Key('adminInbox.more')));
      }
      await qa.tapFinder(find.byKey(const Key('adminInbox.more')));
      qa.expectText(l.admShown(28, 28), s, why: '«Yana yuklash»');
      await qa.scrollToTop();
    });

    await qa.step('Inbox: turkum «${l.supCatScientificError}»', (s) async {
      await qa.tapFinder(find.byKey(const Key('adminInbox.category')));
      await tester.tap(
        find.text(l.supCatScientificError).last,
        warnIfMissed: false,
      );
      await qa.settle();
      qa.expectText('Xato: Etanol', s);
      qa.expectText(l.admShown(1, 1), s);
      qa.expectNoText('Qidiruvda ilova yopilib qoladi', s);
      // Turkumni qaytarish.
      await qa.tapFinder(find.byKey(const Key('adminInbox.category')));
      await tester.tap(find.text(l.admAllCategories).last, warnIfMissed: false);
      await qa.settle();
    }, shot: false);

    await qa.step('Inbox: qidiruv «user03» + holat filtrlari', (s) async {
      await qa.enterText(find.byKey(const Key('adminInbox.search')), 'user03');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await qa.settle();
      qa.expectText('Qidiruvda ilova yopilib qoladi', s);
      qa.expectNoText('Xato: Etanol', s);
      await qa.tapFinder(find.byKey(const Key('adminInbox.status.CLOSED')));
      if (find.byKey(const Key('adminInbox.empty')).evaluate().isEmpty) {
        s.passed = false;
        s.notes.add('«Yopilgan» filtrida bo‘sh holat yo‘q');
      }
      await qa.tapFinder(find.byKey(const Key('adminInbox.status.AWAITING')));
      await qa.enterText(find.byKey(const Key('adminInbox.search')), '');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await qa.settle();
    }, shot: false);

    await qa.step('Murojaatni ochish (muallif, bog‘liq yozuv nomi)', (s) async {
      await qa.tapFinder(find.byKey(Key('support.thread.$sciId')));
      qa.expectText(l.admAuthor('expert@example.test'), s);
      qa.expectText(l.supRelated('Etanol'), s, why: 'xom id emas');
      qa.expectNoText('substance:ethanol', s);
      qa.expectText('Yarim chiqarilish davri', s);
    });

    await qa.step('«${l.admReply}» → javob yuborildi', (s) async {
      await qa.enterText(
        find.byKey(const Key('admin.reply')),
        'Rahmat! Manba qayta tekshirildi, yozuv tuzatiladi.',
      );
      await qa.tapFinder(find.byKey(const Key('admin.replySend')));
      await qa.settle();
      qa.expectText('Rahmat! Manba qayta tekshirildi', s);
      qa.expectText(l.supStatusAnswered, s);
      qa.expectText(l.admReplySent, s, why: 'SnackBar');
      final th = (await support.thread(sciId))!;
      if (th.status != SupportStatus.answered) {
        s.passed = false;
        s.notes.add('Holat: ${th.status}');
      }
    });

    await qa.step('Holat → «${l.supStatusClosed}»', (s) async {
      clearSnackBars(tester);
      await qa.settle();
      await qa.tapFinder(find.byKey(const Key('admin.status')));
      qa.expectText(l.supStatusInReview, s);
      await qa.tapFinder(find.byKey(const Key('admin.status.CLOSED')));
      await qa.settle();
      qa.expectText(l.supStatusClosed, s);
      if ((await support.thread(sciId))!.status != SupportStatus.closed) {
        s.passed = false;
        s.notes.add('Serverda holat yopilmadi');
      }
    });

    await qa.step('Inbox: yopilgan murojaat «Javob kutmoqda»da yo‘q', (
      s,
    ) async {
      clearSnackBars(tester);
      await qa.back();
      await qa.settle();
      await qa.scrollToTop();
      qa.expectNoText('Xato: Etanol', s);
      await qa.tapFinder(find.byKey(const Key('adminInbox.status.CLOSED')));
      qa.expectText('Xato: Etanol', s);
      qa.expectText(l.supStatusClosed, s);
    }, shot: false);

    // ------------------------------------------------------- foydalanuvchilar
    await qa.step('Foydalanuvchilar: 1-sahifa (25/30)', (s) async {
      goTo(tester, Routes.adminUsers);
      await qa.settle();
      qa.expectText(l.admNavUsers, s);
      qa.expectText(l.admShown(25, 30), s);
      qa.expectText('owner@example.test', s);
      qa.expectText(l.adminPrivacyNote, s);
      qa.expectText(l.tierProfessionalPro, s, why: 'tarif nomi');
      qa.expectText(RegExp(l.adminAndroid), s);
      for (final raw in ['professionalPro', 'studentPro', ' android', ' ios']) {
        qa.expectNoText(raw, s, why: 'xom kod');
      }
    });

    await qa.step('Foydalanuvchilar: «${l.admNext}» → 2-sahifa', (s) async {
      await qa.tapFinder(find.byKey(const Key('adminUsers.next')));
      await qa.settle();
      await qa.scrollToTop();
      qa.expectText('user28@example.test', s);
      qa.expectNoText('owner@example.test', s);
      await qa.tapFinder(find.byKey(const Key('adminUsers.prev')));
      await qa.scrollToTop();
      qa.expectText('owner@example.test', s, why: '«Oldingi»');
    }, shot: false);

    await qa.step('Foydalanuvchilar: qidiruv + rol/tarif filtri', (s) async {
      await qa.enterText(find.byKey(const Key('adminUsers.search')), 'user07');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await qa.settle();
      qa.expectText('user07@example.test', s);
      qa.expectNoText('user08@example.test', s);
      await qa.enterText(find.byKey(const Key('adminUsers.search')), '');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await qa.settle();
      await qa.tapFinder(find.byKey(const Key('adminUsers.role.moderator')));
      qa.expectText('moderator@example.test', s);
      qa.expectText(l.admRolePublicationModerator, s, why: 'rol nomi');
      qa.expectNoText('publication_moderator', s, why: 'xom kod');
      qa.expectNoText('owner@example.test', s);
      await qa.tapFinder(find.byKey(const Key('adminUsers.role.any')));
      await qa.tapFinder(find.byKey(const Key('adminUsers.tier.pro')));
      qa.expectText('owner@example.test', s);
      qa.expectText('user07@example.test', s);
      qa.expectNoText('user08@example.test', s);
    });

    // ------------------------------------------------------------- jurnal
    await qa.step('Amallar jurnali (javob, holat, ochish)', (s) async {
      goTo(tester, Routes.adminAudit);
      await qa.settle();
      qa.expectText(l.admActSupportReply, s);
      qa.expectText(l.admActSupportStatus, s);
      qa.expectText(l.admActSupportView, s);
      qa.expectNoText('Rahmat! Manba', s, why: 'jurnalda xabar matni yo‘q');
      qa.expectNoText('SUPPORT_', s, why: 'xom kod');
      qa.expectNoText('CLOSED', s, why: 'xom holat kodi');
      qa.expectText('${l.supStatusAnswered} → ${l.supStatusClosed}', s);
    });

    // ---------------------------------------------------- ru va en (qisqa)
    Future<void> setLang(String label) async {
      goTo(tester, Routes.profileLanguage);
      await qa.settle();
      await qa.tapText(label);
    }

    qa.lang = 'ru';
    await qa.step('RU: панель и обращения', (s) async {
      await setLang('Русский');
      goTo(tester, Routes.admin);
      await qa.settle();
      qa.expectText(ru.admOverview, s);
      goTo(tester, Routes.adminInbox);
      await qa.settle();
      qa.expectText(ru.admNavInbox, s);
      qa.expectText(ru.admFilterAwaiting, s);
      qa.expectNoText(l.admFilterAwaiting, s, why: 'uz qoldig‘i');
    }, langCheck: false);

    qa.lang = 'en';
    await qa.step('EN: audit log and users', (s) async {
      await setLang('English');
      goTo(tester, Routes.adminUsers);
      await qa.settle();
      qa.expectText(en.admNavUsers, s);
      goTo(tester, Routes.adminAudit);
      await qa.settle();
      qa.expectText(en.admNavAudit, s);
      qa.expectText(en.admActSupportReply, s);
    }, langCheck: false);

    qa.lang = 'uz';
    await qa.step('Til: O‘zbekcha (qaytish)', (s) async {
      await setLang('O‘zbekcha');
      goTo(tester, Routes.admin);
      await qa.settle();
      qa.expectText(l.admOverview, s);
    }, shot: false);

    // ------------------------------------------------- kichik ekran 320×640
    await qa.setSize(const Size(320, 640));
    for (final (title, route) in [
      ('320×640: boshqaruv paneli', Routes.admin),
      ('320×640: murojaatlar qutisi', Routes.adminInbox),
      ('320×640: murojaat (admin)', Routes.adminThread(bugId)),
      ('320×640: foydalanuvchilar', Routes.adminUsers),
    ]) {
      await qa.step(title, (s) async {
        goTo(tester, route);
        await qa.settle(maxMs: 6000);
        await qa.scrollToTop();
      });
    }

    await qa.step('Tarmoq o‘chiq: hech bir HTTP so‘rov muvaffaqiyatli emas', (
      s,
    ) async {
      s.notes.add('Bloklangan HTTP urinishlari: ${net.attempts}');
    }, shot: false);

    qa.restoreErrorHandler();
    qa.writeResults();
    printSummary(qa);
    HttpOverrides.global = null;
  });
}
