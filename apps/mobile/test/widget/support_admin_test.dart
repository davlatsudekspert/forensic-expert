import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/account.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/router.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/app/support.dart';
import 'package:forensic_expert/core/settings/app_settings.dart';
import 'package:forensic_expert/data/support/in_memory_support_service.dart';
import 'package:forensic_expert/domain/admin/admin_models.dart';
import 'package:forensic_expert/domain/support/support_models.dart';
import 'package:forensic_expert/features/support/support_image_picker.dart';

import '../helpers/pump_app.dart';
import '../helpers/referral_fakes.dart';
import '../helpers/support_fakes.dart';

Future<void> _tap(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'talaba: murojaat yaratadi (rozilik shart), admin javobini ko‘radi',
    (tester) async {
      final svc = InMemorySupportService();
      final c = await pumpApp(
        tester,
        settings: completedSettings(mode: UserMode.student),
        initialLocation: Routes.profile,
        overrides: [
          authRepositoryProvider.overrideWithValue(await signedInMockAuth()),
          supportServiceProvider.overrideWithValue(svc),
          supportImagePickerProvider.overrideWithValue(FakeImagePicker()),
        ],
      );
      await _tap(tester, find.byKey(const Key('profile.support')));
      expect(find.byKey(const Key('support.empty')), findsOneWidget);
      await _tap(tester, find.byKey(const Key('support.new')));

      // Bo‘sh forma — validatsiya.
      await _tap(tester, find.byKey(const Key('supportNew.send')));
      expect(find.text('Enter a subject.'), findsOneWidget);
      expect(find.text('Enter a message.'), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('supportNew.subject')),
        'Add a dark theme for night shifts',
      );
      await tester.enterText(
        find.byKey(const Key('supportNew.body')),
        'Please add a darker theme for the lab.',
      );
      await _tap(tester, find.byKey(const Key('supportNew.attach')));
      expect(find.byKey(const Key('supportNew.attachment')), findsOneWidget);
      expect(find.byKey(const Key('supportNew.privacy')), findsOneWidget);
      // Rozilik belgilanmagan — yuborilmaydi.
      await _tap(tester, find.byKey(const Key('supportNew.send')));
      expect(svc.threadIds, isEmpty);
      expect(find.text('Please confirm your consent.'), findsWidgets);

      await _tap(tester, find.byKey(const Key('supportNew.consent')));
      await _tap(tester, find.byKey(const Key('supportNew.send')));
      expect(svc.threadIds, hasLength(1));
      expect(find.text('Add a dark theme for night shifts'), findsOneWidget);
      expect(
        find.text('Please add a darker theme for the lab.'),
        findsOneWidget,
      );
      expect(find.byKey(const Key('support.attachment')), findsOneWidget);

      // Admin javobi (server taqlidi) → belgi va banner.
      svc.simulateAdminReply(svc.threadIds.single, 'Thanks! Planned for 0.5.');
      c.invalidate(supportUnreadProvider);
      c.read(routerProvider).go(Routes.profile);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('nav.profile.badge')), findsOneWidget);
      expect(find.byKey(const Key('profile.supportBanner')), findsOneWidget);
      // Boshqa tabda — pastki banner.
      c.read(routerProvider).go(Routes.home);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('support.replyBanner')), findsOneWidget);
      await _tap(tester, find.byKey(const Key('support.replyBanner.open')));
      expect(find.byKey(const Key('support.list')), findsOneWidget);
      await _tap(
        tester,
        find.byKey(Key('support.thread.${svc.threadIds.single}')),
      );
      expect(find.text('Thanks! Planned for 0.5.'), findsOneWidget);
      expect(find.text('FORENSIC EXPERT team'), findsOneWidget);
      expect(await svc.unreadCount(), 0, reason: 'ochilganda o‘qildi');

      // Javob yozish (oldingi SnackBar tugmani to‘smasin).
      tester
          .state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger).first)
          .clearSnackBars();
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('support.reply')),
        'Great, thank you',
      );
      await _tap(tester, find.byKey(const Key('support.send')));
      expect(find.text('Great, thank you'), findsOneWidget);
      expect(
        (await svc.thread(svc.threadIds.single))!.messages.last.body,
        'Great, thank you',
      );
    },
  );

  testWidgets('kirmagan foydalanuvchi: kirish taklifi', (tester) async {
    await pumpApp(
      tester,
      settings: completedSettings(),
      initialLocation: Routes.support,
      overrides: [
        supportServiceProvider.overrideWithValue(InMemorySupportService()),
      ],
    );
    expect(find.byKey(const Key('support.signInRequired')), findsOneWidget);
  });

  testWidgets('backend’siz yig‘ma: Profil qatori yo‘q, sahifa halol', (
    tester,
  ) async {
    final c = await pumpApp(
      tester,
      settings: completedSettings(),
      initialLocation: Routes.profile,
      overrides: [
        authRepositoryProvider.overrideWithValue(await signedInMockAuth()),
      ],
    );
    expect(find.byKey(const Key('profile.support')), findsNothing);
    c.read(routerProvider).go(Routes.support);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('support.unavailable')), findsOneWidget);
  });

  testWidgets('ekspert: modda sahifasidan «Xato haqida xabar berish»', (
    tester,
  ) async {
    final svc = InMemorySupportService();
    await pumpApp(
      tester,
      settings: completedSettings(),
      initialLocation: Routes.libraryEntry('TEST-SUB-ETOH'),
      overrides: [
        authRepositoryProvider.overrideWithValue(await signedInMockAuth()),
        supportServiceProvider.overrideWithValue(svc),
      ],
    );
    await _tap(tester, find.byKey(const Key('support.reportMenu')));
    await _tap(tester, find.byKey(const Key('support.reportError')));
    expect(find.byKey(const Key('supportNew.related')), findsOneWidget);
    // Xom identifikator emas — yozuv nomi ko‘rsatiladi.
    expect(
      find.descendant(
        of: find.byKey(const Key('supportNew.related')),
        matching: find.textContaining('TEST-SUB-ETOH'),
      ),
      findsNothing,
    );
    expect(find.text('Scientific error'), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('supportNew.body')),
      'The reference range differs from the cited source.',
    );
    await _tap(tester, find.byKey(const Key('supportNew.consent')));
    await _tap(tester, find.byKey(const Key('supportNew.send')));
    final mine = (await svc.myThreads())!.single;
    expect(mine.category, SupportCategory.scientificError);
    expect(mine.relatedEntity, contains('TEST-SUB-ETOH'));
    expect(mine.subject, startsWith('Error in: '));
  });

  testWidgets('admin: panel, inbox, javob, holat, foydalanuvchilar, jurnal', (
    tester,
  ) async {
    final svc = InMemorySupportService(isAdmin: true, stats: fixtureAdminStats)
      ..users.addAll(fixtureAdminUsers);
    final id = svc.seedThread(
      category: SupportCategory.bug,
      subject: 'Search crashes on Android 14',
      body: 'Typing «morphine» closes the app.',
      authorEmail: 'student@univ.test',
    );
    svc.seedThread(
      category: SupportCategory.suggestion,
      subject: 'Offline flashcards',
      body: 'Would love offline decks.',
    );
    final c = await pumpApp(
      tester,
      settings: completedSettings(),
      size: const Size(800, 1100),
      initialLocation: Routes.profile,
      overrides: [
        authRepositoryProvider.overrideWithValue(await signedInMockAuth()),
        accountServiceProvider.overrideWithValue(
          FakeAccountService(access: const ServerAccess(isAdmin: true)),
        ),
        supportServiceProvider.overrideWithValue(svc),
      ],
    );
    await _tap(tester, find.byKey(const Key('profile.admin')));
    expect(find.byKey(const Key('admin.overview')), findsOneWidget);
    expect(find.byKey(const Key('admin.chart')), findsOneWidget);
    expect(find.text('128'), findsWidgets);
    expect(find.textContaining('not stored on the server'), findsOneWidget);

    await _tap(tester, find.byKey(const Key('admin.nav.inbox')));
    expect(find.text('Search crashes on Android 14'), findsOneWidget);
    // Turkum bo‘yicha saralash (faqat taklif).
    await _tap(tester, find.byKey(const Key('adminInbox.status.ALL')));
    await tester.enterText(
      find.byKey(const Key('adminInbox.search')),
      'offline',
    );
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(find.text('Search crashes on Android 14'), findsNothing);
    expect(find.text('Offline flashcards'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('adminInbox.search')), '');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    await _tap(tester, find.byKey(Key('support.thread.$id')));
    expect(find.byKey(const Key('admin.threadAuthor')), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('admin.reply')),
      'Thanks, fixed in 0.4.3.',
    );
    await _tap(tester, find.byKey(const Key('admin.replySend')));
    expect(find.text('Thanks, fixed in 0.4.3.'), findsOneWidget);
    expect((await svc.thread(id))!.status, SupportStatus.answered);

    await _tap(tester, find.byKey(const Key('admin.status')));
    await _tap(tester, find.byKey(const Key('admin.status.CLOSED')));
    expect((await svc.thread(id))!.status, SupportStatus.closed);
    expect(
      svc.audit.map((e) => e.action),
      containsAll(['SUPPORT_REPLY', 'SUPPORT_STATUS']),
    );

    c.read(routerProvider).go(Routes.adminUsers);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('adminUsers.user.owner@forensic.test')),
      findsOneWidget,
    );
    await _tap(tester, find.byKey(const Key('adminUsers.tier.pro')));
    expect(
      find.byKey(const Key('adminUsers.user.student@univ.test')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('adminUsers.user.expert@lab.test')),
      findsOneWidget,
    );

    c.read(routerProvider).go(Routes.adminAudit);
    await tester.pumpAndSettle();
    expect(find.text('Replied to a request'), findsOneWidget);
    expect(find.text('Request status changed'), findsOneWidget);
  });

  testWidgets('oddiy foydalanuvchi: admin marshrutlari — ruxsat yo‘q', (
    tester,
  ) async {
    final svc = InMemorySupportService(isAdmin: true, stats: fixtureAdminStats);
    final c = await pumpApp(
      tester,
      settings: completedSettings(),
      initialLocation: Routes.profile,
      overrides: [
        authRepositoryProvider.overrideWithValue(await signedInMockAuth()),
        accountServiceProvider.overrideWithValue(FakeAccountService()),
        supportServiceProvider.overrideWithValue(svc),
      ],
    );
    expect(find.byKey(const Key('profile.admin')), findsNothing);
    for (final r in [
      Routes.admin,
      Routes.adminInbox,
      Routes.adminThread('thread-1'),
      Routes.adminUsers,
      Routes.adminAudit,
    ]) {
      c.read(routerProvider).go(r);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('admin.forbidden')),
        findsOneWidget,
        reason: r,
      );
      expect(find.text('Access denied'), findsWidgets, reason: r);
      expect(find.byKey(const Key('admin.overview')), findsNothing);
      expect(find.byKey(const Key('adminInbox.list')), findsNothing);
      expect(find.byKey(const Key('adminUsers.list')), findsNothing);
    }
    await _tap(tester, find.byKey(const Key('admin.backToProfile')));
    expect(find.byKey(const Key('profile.support')), findsOneWidget);
  });
}
