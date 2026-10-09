import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/account.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/publications.dart';
import 'package:forensic_expert/app/router.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/domain/admin/admin_models.dart';
import 'package:forensic_expert/domain/ports/account_ports.dart';
import 'package:forensic_expert/domain/ports/publication_ports.dart';
import 'package:forensic_expert/domain/publications/publication_models.dart';

import '../helpers/pump_app.dart';
import '../helpers/referral_fakes.dart';

class _FakeAccount implements AccountService {
  const _FakeAccount({this.admin = false});

  final bool admin;

  @override
  bool get isConfigured => true;

  @override
  Future<ServerAccess?> myAccess() async => ServerAccess(isAdmin: admin);

  @override
  Future<void> registerDevice({
    required String platform,
    required String version,
    required String locale,
    String? region,
  }) async {}

  @override
  Future<AdminDashboard?> dashboard() async => null;

  @override
  Future<AdminGrantResult> setAccess(String email, String? tier) async =>
      AdminGrantResult.failed;
}

class _FakePublications implements PublicationService {
  _FakePublications({
    this.published = const [],
    this.moderator = false,
    this.queue = const ModerationQueue(),
  });

  final List<Publication> published;
  final bool moderator;
  final ModerationQueue queue;
  final drafts = <PublicationDraft>[];
  final submitted = <String>[];
  final moderated = <(String, PublicationStatus, String?)>[];

  @override
  bool get isConfigured => true;

  @override
  Future<List<Publication>?> listPublished() async => published;

  @override
  Future<List<Publication>?> myPublications() async => const [];

  @override
  Future<String?> saveDraft(PublicationDraft draft) async {
    drafts.add(draft);
    return 'new-id';
  }

  @override
  Future<SubmitResult> submit(String id) async {
    // Server bilan bir xil: oxirgi qoralamada uchala tasdiq bo‘lishi shart.
    if (!drafts.last.allConfirmed) return SubmitResult.confirmationsRequired;
    submitted.add(id);
    return SubmitResult.submitted;
  }

  @override
  Future<ReportResult> report(
    String id,
    ReportReason reason,
    String details,
  ) async => ReportResult.reported;

  @override
  Future<bool> canModerate() async => moderator;

  @override
  Future<ModerationQueue?> moderationQueue() async => moderator ? queue : null;

  @override
  Future<ModerationResult> moderate(
    String id,
    PublicationStatus to,
    String? comment,
  ) async {
    if (!moderator) return ModerationResult.failed;
    moderated.add((id, to, comment));
    return ModerationResult.done;
  }
}

final _published = [
  Publication(
    id: 'p1',
    status: PublicationStatus.published,
    title: 'Postmortem ethanol formation',
    abstract: 'Ethanol in decomposed bodies.',
    keywords: const ['ethanol'],
    disciplineCode: 'forensic_toxicology',
    coauthors: const ['A. Karimov'],
    publishedAt: DateTime.utc(2026, 10, 1),
  ),
  const Publication(
    id: 'p2',
    status: PublicationStatus.published,
    title: 'STR mixtures',
    abstract: 'Interpreting DNA mixtures.',
    disciplineCode: 'forensic_genetics',
  ),
];

late WidgetTester _tester;

void main() {
  late ProviderContainer container;
  Future<void> go(String location) async {
    container.read(routerProvider).go(location);
    await _tester.pumpAndSettle();
  }

  Future<void> pump(
    WidgetTester tester, {
    required String at,
    bool flag = true,
    bool admin = false,
    bool signedIn = false,
    _FakePublications? svc,
  }) async {
    _tester = tester;
    container = await pumpApp(
      tester,
      settings: completedSettings(),
      initialLocation: at,
      overrides: [
        publicationsFlagProvider.overrideWithValue(flag),
        publicationServiceProvider.overrideWithValue(
          svc ?? _FakePublications(),
        ),
        accountServiceProvider.overrideWithValue(_FakeAccount(admin: admin)),
        if (signedIn)
          authRepositoryProvider.overrideWithValue(await signedInMockAuth()),
      ],
    );
  }

  testWidgets('bo‘sh ro‘yxat: bo‘sh holat va ogohlantirish', (tester) async {
    await pump(tester, at: Routes.publications);
    expect(find.byKey(const Key('publications.empty')), findsOneWidget);
    expect(
      find.text(
        'Submitting an article does not mean it has been scientifically '
        'verified.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('nashr etilganlar: qidiruv, fan filtri va maqola sahifasi', (
    tester,
  ) async {
    await pump(
      tester,
      at: Routes.publications,
      svc: _FakePublications(published: _published),
    );
    expect(find.byKey(const Key('publications.item.p1')), findsOneWidget);
    expect(find.byKey(const Key('publications.item.p2')), findsOneWidget);
    final genetics = find.byKey(
      const Key('publications.discipline.forensic_genetics'),
    );
    await tester.ensureVisible(genetics);
    await tester.pumpAndSettle();
    await tester.tap(genetics);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('publications.item.p1')), findsNothing);
    expect(find.byKey(const Key('publications.item.p2')), findsOneWidget);
    final all = find.byKey(const Key('publications.discipline.all'));
    await tester.ensureVisible(all);
    await tester.pumpAndSettle();
    await tester.tap(all);
    await tester.enterText(
      find.byKey(const Key('publications.search')),
      'ETHANOL',
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('publications.item.p2')), findsNothing);
    await tester.enterText(
      find.byKey(const Key('publications.search')),
      'nothing-like-this',
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('publications.filterEmpty')), findsOneWidget);
    await tester.enterText(find.byKey(const Key('publications.search')), '');
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('publications.item.p1')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('publication.detail')), findsOneWidget);
    expect(find.byKey(const Key('publication.notice')), findsOneWidget);
    expect(find.byKey(const Key('publication.status')), findsOneWidget);
    expect(find.text('Published'), findsOneWidget);
    // Kirmagan foydalanuvchi shikoyat qila olmaydi.
    expect(find.byKey(const Key('publication.report')), findsNothing);
  });

  testWidgets('bayroq o‘chiq, oddiy foydalanuvchi: bo‘lim yopiq', (
    tester,
  ) async {
    await pump(tester, at: Routes.library, flag: false);
    expect(
      find.byKey(const Key('library.hub.publications'), skipOffstage: false),
      findsNothing,
    );
    expect(find.byKey(const Key('library.hub')), findsOneWidget);
    await go(Routes.publications);
    expect(find.byKey(const Key('publications.unavailable')), findsOneWidget);
  });

  testWidgets('bayroq o‘chiq, admin: hub plitkasi ko‘rinadi', (tester) async {
    await pump(
      tester,
      at: Routes.library,
      flag: false,
      admin: true,
      signedIn: true,
      svc: _FakePublications(published: _published),
    );
    final tile = find.byKey(const Key('library.hub.publications'));
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    expect(tile, findsOneWidget);
    expect(
      find.descendant(of: tile, matching: find.text('2 records')),
      findsOneWidget,
    );
    await tester.tap(tile);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('publications.item.p1')), findsOneWidget);
  });

  testWidgets('yuborish: uchala tasdiqsiz tugma o‘chiq', (tester) async {
    final svc = _FakePublications();
    await pump(tester, at: Routes.publicationSubmit, signedIn: true, svc: svc);
    expect(find.byKey(const Key('submit.pii')), findsOneWidget);
    await tester.enterText(find.byKey(const Key('submit.title')), 'Title');
    await tester.enterText(find.byKey(const Key('submit.abstract')), 'Text');
    await tester.tap(find.byKey(const Key('submit.discipline')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Analytical science').last);
    await tester.pumpAndSettle();

    FilledButton send() => tester.widget<FilledButton>(
      find.byKey(const Key('submit.send'), skipOffstage: false),
    );
    expect(send().onPressed, isNull);

    Future<void> check(String key) async {
      final f = find.byKey(Key(key));
      await tester.ensureVisible(f);
      await tester.pumpAndSettle();
      await tester.tap(f);
      await tester.pumpAndSettle();
    }

    await check('submit.confirm.rights');
    await check('submit.confirm.consent');
    expect(send().onPressed, isNull, reason: 'ikkita tasdiq yetarli emas');

    // Qoralamani tasdiqlarsiz ham saqlash mumkin.
    await check('submit.saveDraft');
    expect(svc.drafts.single.allConfirmed, isFalse);
    expect(svc.submitted, isEmpty);

    await check('submit.confirm.noPii');
    expect(send().onPressed, isNotNull);
    await check('submit.send');
    expect(svc.submitted, ['new-id']);
    expect(svc.drafts.last.disciplineCode, 'analytical_science');
    expect(svc.drafts.last.allConfirmed, isTrue);
  });

  testWidgets('yuborish: kirmagan foydalanuvchiga kirish taklifi', (
    tester,
  ) async {
    await pump(tester, at: Routes.publicationSubmit);
    expect(
      find.byKey(const Key('publications.signInRequired')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('submit.form')), findsNothing);
  });

  testWidgets('oddiy foydalanuvchi moderatsiyani ko‘rmaydi', (tester) async {
    final svc = _FakePublications(published: _published);
    await pump(tester, at: Routes.publications, signedIn: true, svc: svc);
    expect(find.byKey(const Key('publications.mine')), findsOneWidget);
    expect(find.byKey(const Key('publications.moderation')), findsNothing);
    await go(Routes.publicationsModeration);
    expect(find.byKey(const Key('moderation.forbidden')), findsOneWidget);
    expect(find.byKey(const Key('moderation.queue')), findsNothing);
  });

  testWidgets('admin navbatni ko‘radi va holatni o‘tkazadi', (tester) async {
    final svc = _FakePublications(
      moderator: true,
      queue: const ModerationQueue(
        items: [
          Publication(
            id: 'q1',
            status: PublicationStatus.submitted,
            title: 'Queued paper',
          ),
          Publication(
            id: 'q2',
            status: PublicationStatus.inReview,
            title: 'Own paper',
            own: true,
          ),
        ],
      ),
    );
    await pump(
      tester,
      at: Routes.publications,
      flag: false,
      admin: true,
      signedIn: true,
      svc: svc,
    );
    await tester.tap(find.byKey(const Key('publications.moderation')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('moderation.queue')), findsOneWidget);
    expect(find.text('Queued paper'), findsOneWidget);
    // O‘z maqolasi uchun tugmalar yo‘q.
    expect(find.byKey(const Key('moderation.own.q2')), findsOneWidget);
    expect(
      find.byKey(const Key('moderation.action.q2.APPROVED')),
      findsNothing,
    );
    // SUBMITTED → faqat SCREENING (o‘tkazib yuborish yo‘q).
    expect(
      find.byKey(const Key('moderation.action.q1.SCREENING')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('moderation.action.q1.PUBLISHED')),
      findsNothing,
    );
    await tester.tap(find.byKey(const Key('moderation.action.q1.SCREENING')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('moderation.confirm')));
    await tester.pumpAndSettle();
    expect(svc.moderated.single, ('q1', PublicationStatus.screening, null));
    expect(find.text('Updated.'), findsOneWidget);
  });
}
