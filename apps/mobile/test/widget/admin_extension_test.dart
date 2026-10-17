import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/account.dart';
import 'package:forensic_expert/app/moderation.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/qa.dart';
import 'package:forensic_expert/app/router.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/app/support.dart';
import 'package:forensic_expert/data/support/in_memory_moderation_service.dart';
import 'package:forensic_expert/data/support/in_memory_support_service.dart';
import 'package:forensic_expert/domain/admin/admin_models.dart';
import 'package:forensic_expert/domain/moderation/moderation_models.dart';
import 'package:forensic_expert/domain/ports/qa_ports.dart';
import 'package:forensic_expert/domain/qa/qa_models.dart';
import 'package:forensic_expert/domain/support/support_models.dart';

import '../helpers/pump_app.dart';
import '../helpers/referral_fakes.dart';
import '../helpers/support_fakes.dart';

Future<void> _tap(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

Future<void> _search(WidgetTester tester, Key key, String text) async {
  await tester.enterText(find.byKey(key), text);
  await tester.testTextInput.receiveAction(TextInputAction.search);
  await tester.pumpAndSettle();
}

class _Qa implements QaService {
  _Qa(this.data);

  final QaQuestion data;
  final answered = <String>[];

  @override
  bool get isConfigured => true;

  @override
  Future<QaMe?> status() async => const QaMe(
    profile: QaProfile(
      status: QaStatus.verified,
      role: QaRole.forensicChemist,
      countryCode: 'UZ',
      manual: true,
    ),
    tags: ['toxicology'],
    attemptsToday: 0,
    canAnswer: true,
  );

  @override
  Future<QaFeed?> feed({
    String? tag,
    String? query,
    int limit = 20,
    int offset = 0,
  }) async => QaFeed.empty;

  @override
  Future<QaQuestion?> question(String id) async => data;

  @override
  Future<QaMine?> mine() async => QaMine.empty;

  @override
  Future<QaPostResult?> ask({
    required QaLang lang,
    required String title,
    required String body,
    List<String> tags = const [],
  }) async => null;

  @override
  Future<QaPostResult?> answer({
    required String questionId,
    required QaLang lang,
    required String body,
  }) async {
    answered.add(body);
    return const QaPostResult(id: 'a9', status: QaPostStatus.published);
  }

  @override
  Future<QaAnswer?> vote(String answerId, int value) async => null;

  @override
  Future<bool> accept(String questionId, String? answerId) async => true;

  @override
  Future<QaReportResult?> report({
    required QaTargetType target,
    required String id,
    required String reason,
  }) async => const QaReportResult(reports: 1, hidden: false);

  @override
  Future<QaTranslation?> translate({
    required QaTargetType target,
    required String id,
    required QaLang lang,
  }) async => null;

  @override
  Future<QaVerifyOutcome> verify({
    required QaRole role,
    required String countryCode,
    required QaDocument document,
    required QaLang lang,
  }) async => QaVerifyOutcome.failed('upstream');

  @override
  Future<QaModerationQueue?> moderationQueue() async => null;

  @override
  Future<bool> moderate({
    required QaModerationAction action,
    required QaTargetType target,
    required String id,
    String? reason,
  }) async => true;
}

final _otherQuestion = QaQuestion(
  id: 'q1',
  lang: QaLang.en,
  title: 'Postmortem ethanol',
  body: 'How do we separate postmortem formation from antemortem intake?',
  tags: const ['toxicology'],
  status: QaPostStatus.published,
  pinned: false,
  isMine: false,
  acceptedAnswerId: null,
  authorRole: QaRole.forensicChemist,
  createdAt: DateTime.utc(2026, 10, 2),
  answers: const [
    QaAnswer(
      id: 'a1',
      lang: QaLang.en,
      body: 'Check vitreous humour and n-propanol as a marker.',
      score: 2,
      myVote: 0,
      accepted: false,
      isMine: false,
      authorRole: QaRole.forensicPhysician,
    ),
  ],
);

void main() {
  const wide = Size(800, 1100);

  Future<InMemoryModerationService> seeded({bool admin = true}) async {
    final svc = InMemoryModerationService(isAdmin: admin);
    await svc.submitReport(
      const ReportDraft(
        kind: ReportKind.advertising,
        body: 'Fake 100% discount spam',
        contact: 'spam@example.com',
        target: ReportTarget.qaQuestion,
        targetId: 'q1',
      ),
    );
    await svc.submitReport(
      const ReportDraft(kind: ReportKind.bug, body: 'App closes on startup'),
    );
    return svc;
  }

  testWidgets(
    'oddiy foydalanuvchi: yangi admin sahifalari yopiq, ma’lumot yo‘q',
    (tester) async {
      final mod = await seeded(admin: false);
      final c = await pumpApp(
        tester,
        settings: completedSettings(),
        initialLocation: Routes.profile,
        overrides: [
          authRepositoryProvider.overrideWithValue(await signedInMockAuth()),
          accountServiceProvider.overrideWithValue(FakeAccountService()),
          supportServiceProvider.overrideWithValue(
            InMemorySupportService(stats: fixtureAdminStats),
          ),
          moderationServiceProvider.overrideWithValue(mod),
        ],
      );
      expect(find.byKey(const Key('profile.admin')), findsNothing);
      // Shikoyat yuborish — hamma uchun ochiq.
      expect(find.byKey(const Key('profile.report')), findsOneWidget);
      for (final r in [Routes.admin, Routes.adminReports, Routes.adminUsers]) {
        c.read(routerProvider).go(r);
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('admin.forbidden')),
          findsOneWidget,
          reason: r,
        );
        expect(find.byKey(const Key('admin.ext')), findsNothing, reason: r);
        expect(
          find.byKey(const Key('adminReports.list')),
          findsNothing,
          reason: r,
        );
        expect(find.textContaining('Fake 100%'), findsNothing, reason: r);
      }
    },
  );

  testWidgets(
    'backend’siz yig‘ma: Profilda shikoyat qatori yo‘q, forma halol',
    (tester) async {
      final c = await pumpApp(
        tester,
        settings: completedSettings(),
        initialLocation: Routes.profile,
        overrides: [
          authRepositoryProvider.overrideWithValue(await signedInMockAuth()),
        ],
      );
      expect(find.byKey(const Key('profile.report')), findsNothing);
      c.read(routerProvider).go(Routes.report);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('report.unavailable')), findsOneWidget);
      expect(find.byKey(const Key('contact.line')), findsOneWidget);
      expect(find.byKey(const Key('report.send')), findsNothing);
    },
  );

  testWidgets(
    'admin: kengaytirilgan statistika halol izohlar va do‘kon havolalari bilan',
    (tester) async {
      final mod = await seeded();
      await pumpApp(
        tester,
        settings: completedSettings(),
        size: wide,
        initialLocation: Routes.admin,
        overrides: [
          authRepositoryProvider.overrideWithValue(await signedInMockAuth()),
          accountServiceProvider.overrideWithValue(
            FakeAccountService(access: const ServerAccess(isAdmin: true)),
          ),
          supportServiceProvider.overrideWithValue(
            InMemorySupportService(isAdmin: true, stats: fixtureAdminStats),
          ),
          moderationServiceProvider.overrideWithValue(mod),
        ],
      );
      final ext = find.byKey(const Key('admin.ext'));
      await tester.ensureVisible(ext);
      await tester.pumpAndSettle();
      expect(ext, findsOneWidget);
      // Sotuvlar: halol «0 — to‘lov tizimi yo‘q»; «hozir tizimda» — mavjud emas.
      expect(
        find.text('Sales: 0 — there is no payment system.'),
        findsOneWidget,
      );
      expect(find.textContaining('Online now: not available'), findsOneWidget);
      expect(
        find.textContaining('stored on the device, not counted'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Downloads: the server cannot see them'),
        findsOneWidget,
      );
      expect(find.byKey(const Key('admin.ext.asc')), findsOneWidget);
      expect(find.byKey(const Key('admin.ext.play')), findsOneWidget);
      // Ochiq shikoyatlar soni (2 ta) bo‘lim plitkasida.
      expect(find.byKey(const Key('admin.nav.reports')), findsOneWidget);
      expect(find.text('Open reports'), findsOneWidget);
    },
  );

  testWidgets(
    'admin: shikoyat ro‘yxati — qidiruv, izoh, hal qilindi, qayta ochish',
    (tester) async {
      final mod = await seeded();
      await pumpApp(
        tester,
        settings: completedSettings(),
        size: wide,
        initialLocation: Routes.adminReports,
        overrides: [
          authRepositoryProvider.overrideWithValue(await signedInMockAuth()),
          accountServiceProvider.overrideWithValue(
            FakeAccountService(access: const ServerAccess(isAdmin: true)),
          ),
          supportServiceProvider.overrideWithValue(
            InMemorySupportService(isAdmin: true, stats: fixtureAdminStats),
          ),
          moderationServiceProvider.overrideWithValue(mod),
        ],
      );
      expect(find.text('Fake 100% discount spam'), findsOneWidget);
      expect(find.text('App closes on startup'), findsOneWidget);
      expect(find.text('me@example.com'), findsWidgets);

      // Qidiruv: «%» maxsus belgi emas — faqat «100%» bor yozuv chiqadi.
      await _search(tester, const Key('adminReports.search'), '100%');
      expect(find.text('Fake 100% discount spam'), findsOneWidget);
      expect(find.text('App closes on startup'), findsNothing);
      await _search(tester, const Key('adminReports.search'), '_');
      expect(find.byKey(const Key('adminReports.empty')), findsOneWidget);
      expect(mod.lastSearches, containsAll(['100%', '_']));
      await _search(tester, const Key('adminReports.search'), '');

      // Tur bo‘yicha saralash.
      await _tap(tester, find.byKey(const Key('adminReports.kind.BUG')));
      expect(find.text('Fake 100% discount spam'), findsNothing);
      expect(find.text('App closes on startup'), findsOneWidget);
      await _tap(tester, find.byKey(const Key('adminReports.kind.any')));

      // Izoh yozish va hal qilish.
      await tester.enterText(
        find.byKey(const Key('adminReports.note.r0')),
        'Spam, account warned',
      );
      await _tap(tester, find.byKey(const Key('adminReports.saveNote.r0')));
      expect(mod.reports[0].adminNote, 'Spam, account warned');
      await _tap(tester, find.byKey(const Key('adminReports.toggle.r0')));
      expect(mod.reports[0].resolved, isTrue);
      // «Ochiq» ro‘yxatdan chiqib ketdi.
      expect(find.text('Fake 100% discount spam'), findsNothing);
      await _tap(tester, find.byKey(const Key('adminReports.status.resolved')));
      expect(find.text('Fake 100% discount spam'), findsOneWidget);
      expect(find.text('Reopen'), findsOneWidget);
      await _tap(tester, find.byKey(const Key('adminReports.toggle.r0')));
      expect(mod.reports[0].resolved, isFalse);
    },
  );

  group('foydalanuvchi amallari', () {
    Future<(InMemoryModerationService, String)> openUsers(
      WidgetTester tester,
    ) async {
      final auth = await signedInMockAuth();
      final selfId = auth.current.account!.userId;
      final mod = InMemoryModerationService(isAdmin: true, selfId: selfId)
        ..admins.add('u1');
      final support =
          InMemorySupportService(isAdmin: true, stats: fixtureAdminStats)
            ..users.addAll([
              ...fixtureAdminUsers,
              AdminUserSummary.fromJson({
                'id': selfId,
                'email': 'me@forensic.test',
                'roles': ['identity_admin'],
                'status': 'ACTIVE',
              }),
            ]);
      await pumpApp(
        tester,
        settings: completedSettings(),
        size: wide,
        initialLocation: Routes.adminUsers,
        overrides: [
          authRepositoryProvider.overrideWithValue(auth),
          accountServiceProvider.overrideWithValue(
            FakeAccountService(access: const ServerAccess(isAdmin: true)),
          ),
          supportServiceProvider.overrideWithValue(support),
          moderationServiceProvider.overrideWithValue(mod),
        ],
      );
      return (mod, selfId);
    }

    testWidgets(
      'qidiruv matni (100%) xom yuboriladi; rol berish sabab talab qiladi',
      (tester) async {
        final (mod, _) = await openUsers(tester);
        await _tap(
          tester,
          find.byKey(const Key('adminUsers.actions.student@univ.test')),
        );
        expect(find.byKey(const Key('userActions.sheet')), findsOneWidget);
        // Sababsiz — xato, serverga so‘rov ketmaydi.
        await _tap(tester, find.byKey(const Key('userActions.moderator')));
        expect(
          find.text('The reason must be at least 5 characters.'),
          findsOneWidget,
        );
        expect(mod.roleCalls, isEmpty);
        await tester.enterText(
          find.byKey(const Key('userActions.reason')),
          'Helps review articles',
        );
        await _tap(tester, find.byKey(const Key('userActions.moderator')));
        expect(mod.roleCalls.single.$1, 'u2');
        expect(mod.roleCalls.single.$2, ManagedRole.publicationModerator);
        expect(mod.roleCalls.single.$3, isTrue);
        expect(find.text('Role granted.'), findsOneWidget);
        expect(find.byKey(const Key('userActions.sheet')), findsNothing);
      },
    );

    testWidgets('hisobni to‘xtatish: tasdiq oynasi, sabab, so‘ng natija', (
      tester,
    ) async {
      final (mod, _) = await openUsers(tester);
      await _tap(
        tester,
        find.byKey(const Key('adminUsers.actions.expert@lab.test')),
      );
      await tester.enterText(
        find.byKey(const Key('userActions.reason')),
        'Repeated spam',
      );
      await _tap(tester, find.byKey(const Key('userActions.suspend')));
      // Tasdiq oynasi — bekor qilinsa hech narsa yuborilmaydi.
      expect(find.textContaining('signed out everywhere'), findsOneWidget);
      await _tap(tester, find.byKey(const Key('userActions.confirm.cancel')));
      expect(mod.suspensionCalls, isEmpty);
      await _tap(tester, find.byKey(const Key('userActions.suspend')));
      await _tap(tester, find.byKey(const Key('userActions.confirm.ok')));
      expect(mod.suspensionCalls.single, ('u3', true, 'Repeated spam'));
      expect(
        find.text('Account suspended. Its sessions were closed.'),
        findsOneWidget,
      );
    });

    testWidgets('admin to‘xtatilmaydi; o‘z qatorida amallar yo‘q', (
      tester,
    ) async {
      final (mod, _) = await openUsers(tester);
      await _tap(
        tester,
        find.byKey(const Key('adminUsers.actions.owner@forensic.test')),
      );
      expect(
        find.byKey(const Key('userActions.adminProtected')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('userActions.suspend')), findsNothing);
      expect(find.byKey(const Key('userActions.removeAdmin')), findsOneWidget);
      // Adminlikni olib tashlash — tasdiq so‘raydi.
      await tester.enterText(
        find.byKey(const Key('userActions.reason')),
        'Left the team',
      );
      await _tap(tester, find.byKey(const Key('userActions.removeAdmin')));
      expect(find.text('Remove admin role?'), findsOneWidget);
      await _tap(tester, find.byKey(const Key('userActions.confirm.cancel')));
      expect(mod.roleCalls, isEmpty);
      // Yopamiz va o‘z qatorini ochamiz.
      Navigator.of(tester.element(find.byKey(const Key('userActions.sheet'))))
          .pop();
      await tester.pumpAndSettle();
      await _tap(
        tester,
        find.byKey(const Key('adminUsers.actions.me@forensic.test')),
      );
      expect(find.byKey(const Key('userActions.self')), findsOneWidget);
      expect(find.byKey(const Key('userActions.suspend')), findsNothing);
      expect(find.byKey(const Key('userActions.moderator')), findsNothing);
      expect(find.byKey(const Key('userActions.removeAdmin')), findsNothing);
    });
  });

  group('shikoyat formasi', () {
    testWidgets('kirmagan foydalanuvchi yuboradi; tekshiruv; soatiga 5 ta', (
      tester,
    ) async {
      final mod = InMemoryModerationService(signedIn: false);
      final c = await pumpApp(
        tester,
        settings: completedSettings(),
        initialLocation: Routes.report,
        overrides: [moderationServiceProvider.overrideWithValue(mod)],
      );
      expect(find.byKey(const Key('report.body')), findsOneWidget);
      expect(find.byKey(const Key('contact.line')), findsOneWidget);
      // Bo‘sh — tekshiruv xatosi.
      await _tap(tester, find.byKey(const Key('report.send')));
      expect(find.text('Write at least 5 characters.'), findsOneWidget);
      expect(mod.reports, isEmpty);
      for (var i = 0; i < 5; i++) {
        // Muvaffaqiyatli yuborilgach forma yopiladi — qayta ochamiz.
        c.read(routerProvider).go(Routes.report);
        await tester.pumpAndSettle();
        if (i == 0) {
          // Tur tanlash.
          await _tap(tester, find.byKey(const Key('report.kind')));
          await tester.tap(find.text('Advertising').last);
          await tester.pumpAndSettle();
        }
        await tester.enterText(
          find.byKey(const Key('report.body')),
          'Spam message number $i',
        );
        await _tap(tester, find.byKey(const Key('report.send')));
      }
      expect(mod.reports, hasLength(5));
      expect(mod.reports.first.kind, ReportKind.advertising);
      expect(mod.reports.every((r) => r.anonymous), isTrue);
      c.read(routerProvider).go(Routes.report);
      await tester.pumpAndSettle();
      // Oldingi xabarlar navbatda turmasin.
      tester
          .state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger).first)
          .clearSnackBars();
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('report.body')),
        'Sixth message in an hour',
      );
      await _tap(tester, find.byKey(const Key('report.send')));
      expect(mod.reports, hasLength(5));
      expect(
        find.text('You can send up to 5 reports per hour. Try again later.'),
        findsOneWidget,
      );
    });

    testWidgets('kirgan foydalanuvchi faqat o‘z shikoyatini ko‘radi', (
      tester,
    ) async {
      final mod = InMemoryModerationService();
      await mod.submitReport(
        const ReportDraft(kind: ReportKind.bug, body: 'My own bug report'),
      );
      await pumpApp(
        tester,
        settings: completedSettings(),
        initialLocation: Routes.report,
        overrides: [
          authRepositoryProvider.overrideWithValue(await signedInMockAuth()),
          moderationServiceProvider.overrideWithValue(mod),
        ],
      );
      expect(find.byKey(const Key('report.mine.r0')), findsOneWidget);
      expect(find.text('Under review'), findsOneWidget);
      // Matni va admin izohi ko‘rsatilmaydi.
      expect(find.text('My own bug report'), findsNothing);
    });
  });

  group('Savol-javob: qoidalar va bloklash', () {
    Future<(InMemoryModerationService, _Qa)> openQuestion(
      WidgetTester tester, {
      required bool accepted,
    }) async {
      final mod = InMemoryModerationService(termsAccepted: accepted);
      final qa = _Qa(_otherQuestion);
      await pumpApp(
        tester,
        settings: completedSettings(),
        initialLocation: Routes.qaQuestion('q1'),
        overrides: [
          qaFlagProvider.overrideWithValue(true),
          qaServiceProvider.overrideWithValue(qa),
          moderationServiceProvider.overrideWithValue(mod),
          authRepositoryProvider.overrideWithValue(await signedInMockAuth()),
        ],
      );
      return (mod, qa);
    }

    Future<void> writeAnswer(WidgetTester tester) async {
      final field = find.byKey(const Key('qa.answer.body'));
      await tester.ensureVisible(field);
      await tester.pumpAndSettle();
      await tester.enterText(
        field,
        'Bu yerda kamida o‘ttiz belgidan iborat javob matni turibdi.',
      );
      await tester.pumpAndSettle();
      await _tap(tester, find.byKey(const Key('qa.answer.send')));
    }

    testWidgets('qoidalar qabul qilinmaguncha javob yuborilmaydi', (
      tester,
    ) async {
      final (mod, qa) = await openQuestion(tester, accepted: false);
      await writeAnswer(tester);
      expect(find.byKey(const Key('terms.list')), findsOneWidget);
      expect(find.byKey(const Key('terms.draft')), findsOneWidget);
      expect(find.byKey(const Key('terms.zeroTolerance')), findsOneWidget);
      expect(find.byKey(const Key('contact.line')), findsOneWidget);
      expect(qa.answered, isEmpty);
      // Belgisiz «Qabul qilish» o‘chiq.
      final accept = find.byKey(const Key('terms.accept'));
      await tester.ensureVisible(accept);
      await tester.pumpAndSettle();
      expect(tester.widget<FilledButton>(accept).onPressed, isNull);
      await _tap(tester, find.byKey(const Key('terms.agree')));
      await _tap(tester, accept);
      expect(mod.termsAccepted, isTrue);
      // Qabuldan so‘ng javob yuboriladi.
      expect(find.byKey(const Key('terms.list')), findsNothing);
    });

    testWidgets('rad etilsa javob yuborilmaydi', (tester) async {
      final (mod, qa) = await openQuestion(tester, accepted: false);
      await writeAnswer(tester);
      await _tap(tester, find.byKey(const Key('terms.decline')));
      expect(mod.termsAccepted, isFalse);
      expect(qa.answered, isEmpty);
    });

    testWidgets('qoidalar qabul qilingan bo‘lsa to‘siq yo‘q', (tester) async {
      final (_, qa) = await openQuestion(tester, accepted: true);
      await writeAnswer(tester);
      expect(find.byKey(const Key('terms.list')), findsNothing);
      expect(qa.answered, hasLength(1));
    });

    testWidgets('javob muallifini bloklash: tasdiq va natija', (tester) async {
      final (mod, _) = await openQuestion(tester, accepted: true);
      await _tap(tester, find.byKey(const Key('qa.block.a1')));
      expect(find.text('Block this author?'), findsOneWidget);
      await _tap(tester, find.byKey(const Key('qa.block.cancel')));
      expect(mod.blocks, isEmpty);
      await _tap(tester, find.byKey(const Key('qa.block.a1')));
      await _tap(tester, find.byKey(const Key('qa.block.confirm')));
      expect(mod.blocks, ['a1']);
      expect(find.text('Author blocked.'), findsOneWidget);
    });

    testWidgets(
      'bloklanganlar ro‘yxati: kimligi ko‘rsatilmaydi, blokdan chiqarish',
      (tester) async {
        final mod = InMemoryModerationService()..blocks.add('b1');
        await pumpApp(
          tester,
          settings: completedSettings(),
          initialLocation: Routes.qaBlocked,
          overrides: [
            qaFlagProvider.overrideWithValue(true),
            qaServiceProvider.overrideWithValue(_Qa(_otherQuestion)),
            moderationServiceProvider.overrideWithValue(mod),
            authRepositoryProvider.overrideWithValue(await signedInMockAuth()),
          ],
        );
        expect(find.text('Blocked author'), findsOneWidget);
        await _tap(tester, find.byKey(const Key('blocked.unblock.b1')));
        expect(mod.blocks, isEmpty);
        expect(find.byKey(const Key('blocked.empty')), findsOneWidget);
      },
    );

    testWidgets('qoidalar sahifasida bloklanganlar va ko‘rinadigan aloqa bor', (
      tester,
    ) async {
      await pumpApp(
        tester,
        settings: completedSettings(),
        initialLocation: Routes.qaRules,
        overrides: [
          qaFlagProvider.overrideWithValue(true),
          qaServiceProvider.overrideWithValue(_Qa(_otherQuestion)),
          moderationServiceProvider.overrideWithValue(
            InMemoryModerationService(),
          ),
          authRepositoryProvider.overrideWithValue(await signedInMockAuth()),
        ],
      );
      expect(find.byKey(const Key('qa.rules.blocked')), findsOneWidget);
      expect(find.byKey(const Key('contact.line')), findsOneWidget);
    });
  });
}
