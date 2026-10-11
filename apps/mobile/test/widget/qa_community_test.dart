import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/qa.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/domain/ports/qa_ports.dart';
import 'package:forensic_expert/domain/qa/qa_models.dart';
import 'package:forensic_expert/features/qa/qa_document_picker.dart';

import '../helpers/pump_app.dart';
import '../helpers/referral_fakes.dart';

/// Server o‘rnida — tarmoqqa chiqmaydi. AI ham, baza ham chaqirilmaydi.
class _FakeQa implements QaService {
  _FakeQa({
    this.configured = true,
    this.me = QaMe.empty,
    this.feedData = QaFeed.empty,
    this.questionData,
    this.mineData = QaMine.empty,
    this.askResult,
    this.verifyOutcome,
  });

  final bool configured;
  final QaMe me;
  final QaFeed feedData;
  final QaQuestion? questionData;
  final QaMine mineData;
  final QaPostResult? askResult;
  final QaVerifyOutcome? verifyOutcome;

  final asked = <String>[];
  final answered = <String>[];
  final votes = <(String, int)>[];
  final accepted = <(String, String?)>[];
  final reports = <(QaTargetType, String, String)>[];
  final verified = <QaDocument>[];
  final moderated = <(QaModerationAction, QaTargetType, String)>[];
  final translated = <String>[];

  @override
  bool get isConfigured => configured;

  @override
  Future<QaMe?> status() async => me;

  @override
  Future<QaFeed?> feed({
    String? tag,
    String? query,
    int limit = 20,
    int offset = 0,
  }) async {
    if (query == null || query.isEmpty) return feedData;
    return QaFeed(
      total: feedData.total,
      items: [
        for (final q in feedData.items)
          if (q.title.toLowerCase().contains(query.toLowerCase())) q,
      ],
    );
  }

  @override
  Future<QaQuestion?> question(String id) async => questionData;

  @override
  Future<QaMine?> mine() async => mineData;

  @override
  Future<QaPostResult?> ask({
    required QaLang lang,
    required String title,
    required String body,
    List<String> tags = const [],
  }) async {
    asked.add(title);
    return askResult;
  }

  @override
  Future<QaPostResult?> answer({
    required String questionId,
    required QaLang lang,
    required String body,
  }) async {
    answered.add(body);
    return askResult;
  }

  @override
  Future<QaAnswer?> vote(String answerId, int value) async {
    votes.add((answerId, value));
    return null;
  }

  @override
  Future<bool> accept(String questionId, String? answerId) async {
    accepted.add((questionId, answerId));
    return true;
  }

  @override
  Future<QaReportResult?> report({
    required QaTargetType target,
    required String id,
    required String reason,
  }) async {
    reports.add((target, id, reason));
    return const QaReportResult(reports: 1, hidden: false);
  }

  @override
  Future<QaTranslation?> translate({
    required QaTargetType target,
    required String id,
    required QaLang lang,
  }) async {
    translated.add(id);
    return const QaTranslation(
      body: 'Mashina matni',
      title: 'Mashina sarlavhasi',
      engine: 'cf:@cf/meta/m2m100-1.2b',
    );
  }

  @override
  Future<QaVerifyOutcome> verify({
    required QaRole role,
    required String countryCode,
    required QaDocument document,
    required QaLang lang,
  }) async {
    verified.add(document);
    return verifyOutcome ?? QaVerifyOutcome.failed('upstream');
  }

  @override
  Future<QaModerationQueue?> moderationQueue() async => null;

  @override
  Future<bool> moderate({
    required QaModerationAction action,
    required QaTargetType target,
    required String id,
    String? reason,
  }) async {
    moderated.add((action, target, id));
    return true;
  }
}

class _FakePicker implements QaDocumentPicker {
  _FakePicker(this.document);

  final QaDocument? document;

  @override
  Future<QaDocument?> pick() async => document;
}

final _feed = QaFeed(
  total: 2,
  items: [
    QaQuestionSummary(
      id: 'q1',
      lang: QaLang.uz,
      title: 'Chirigan jasadda etanol',
      excerpt: 'Postmortem etanol hosil bo‘lishini qanday ajratamiz?',
      tags: const ['toxicology'],
      pinned: true,
      answerCount: 1,
      hasAccepted: true,
      isMine: false,
      authorRole: QaRole.forensicChemist,
      createdAt: DateTime.utc(2026, 10, 1),
    ),
    const QaQuestionSummary(
      id: 'q2',
      lang: QaLang.en,
      title: 'STR mixture interpretation',
      excerpt: 'Two-person mixture, low template.',
      tags: ['dna'],
      pinned: false,
      answerCount: 0,
      hasAccepted: false,
      isMine: true,
    ),
  ],
);

final _question = QaQuestion(
  id: 'q1',
  lang: QaLang.en,
  title: 'Postmortem ethanol',
  body: 'How do we separate postmortem formation from antemortem intake?',
  tags: const ['toxicology'],
  status: QaPostStatus.published,
  pinned: false,
  isMine: true,
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

const _verifiedMe = QaMe(
  profile: QaProfile(
    status: QaStatus.verified,
    role: QaRole.forensicChemist,
    countryCode: 'UZ',
    manual: true,
  ),
  tags: ['toxicology', 'dna'],
  attemptsToday: 0,
  canAnswer: true,
);

const _unverifiedMe = QaMe(
  profile: QaProfile.unverified,
  tags: ['toxicology', 'dna'],
  attemptsToday: 2,
  canAnswer: false,
);

QaDocument _document(int bytes, [String mime = 'image/jpeg']) =>
    QaDocument(bytes: List.filled(bytes, 1), mimeType: mime);

void main() {
  late ProviderContainer container;

  Future<void> pump(
    WidgetTester tester, {
    required String at,
    bool flag = true,
    bool signedIn = true,
    String lang = 'uz',
    Size size = const Size(390, 844),
    double textScale = 1,
    _FakeQa? svc,
    QaDocumentPicker? picker,
  }) async {
    container = await pumpApp(
      tester,
      settings: completedSettings(lang: lang),
      initialLocation: at,
      size: size,
      textScale: textScale,
      overrides: [
        qaFlagProvider.overrideWithValue(flag),
        qaServiceProvider.overrideWithValue(svc ?? _FakeQa()),
        if (picker != null) qaDocumentPickerProvider.overrideWithValue(picker),
        if (signedIn)
          authRepositoryProvider.overrideWithValue(await signedInMockAuth()),
      ],
    );
  }

  testWidgets('server ulanmagan bo‘lsa bo‘lim ko‘rinmaydi', (tester) async {
    await pump(tester, at: Routes.qa, svc: _FakeQa(configured: false));
    expect(find.byKey(const Key('qa.unavailable')), findsOneWidget);
    expect(find.byKey(const Key('qa.list')), findsNothing);
    expect(container.read(qaVisibleProvider), isFalse);
  });

  testWidgets('kirmagan foydalanuvchiga kirish taklif qilinadi', (
    tester,
  ) async {
    await pump(tester, at: Routes.qa, signedIn: false);
    expect(find.byKey(const Key('qa.signInRequired')), findsOneWidget);
  });

  testWidgets('ro‘yxat: qadalgan, eng yaxshi javob, tasdiqlangan muallif', (
    tester,
  ) async {
    await pump(
      tester,
      at: Routes.qa,
      svc: _FakeQa(me: _verifiedMe, feedData: _feed),
    );
    expect(find.byKey(const Key('qa.card.q1')), findsOneWidget);
    expect(find.byKey(const Key('qa.card.q2')), findsOneWidget);
    expect(find.text('Qadalgan'), findsOneWidget);
    expect(find.byKey(const Key('qa.verifiedBadge')), findsWidgets);
    // Qidiruv serverga boradi; soxta server sarlavha bo‘yicha filtrlaydi.
    await tester.enterText(find.byKey(const Key('qa.search')), 'STR');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('qa.card.q1')), findsNothing);
    expect(find.byKey(const Key('qa.card.q2')), findsOneWidget);
  });

  testWidgets('tasdiqlanmagan foydalanuvchi javob yoza olmaydi', (
    tester,
  ) async {
    await pump(
      tester,
      at: Routes.qaQuestion('q1'),
      svc: _FakeQa(me: _unverifiedMe, questionData: _question),
    );
    expect(find.byKey(const Key('qa.answer.locked')), findsOneWidget);
    expect(find.byKey(const Key('qa.answer.body')), findsNothing);
  });

  testWidgets('tasdiqlangan mutaxassis javob yozadi va maxfiylik filtri '
      'ushlab qolsa sabab ko‘rsatiladi', (tester) async {
    final svc = _FakeQa(
      me: _verifiedMe,
      questionData: _question,
      askResult: const QaPostResult(
        id: 'a2',
        status: QaPostStatus.moderation,
        flags: [QaPrivacyFlag.caseNumber],
      ),
    );
    await pump(tester, at: Routes.qaQuestion('q1'), svc: svc);
    final field = find.byKey(const Key('qa.answer.body'));
    await tester.ensureVisible(field);
    await tester.pumpAndSettle();
    await tester.enterText(
      field,
      'Bu yerda kamida o‘ttiz belgidan iborat javob matni turibdi.',
    );
    await tester.pumpAndSettle();
    final send = find.byKey(const Key('qa.answer.send'));
    await tester.ensureVisible(send);
    await tester.pumpAndSettle();
    await tester.tap(send);
    await tester.pumpAndSettle();
    expect(svc.answered, hasLength(1));
    expect(find.byKey(const Key('qa.flags')), findsOneWidget);
    // Ogohlantirishda ham, filtr natijasida ham shu ibora chiqadi.
    expect(find.textContaining('ish yoki ekspertiza raqami'), findsWidgets);
  });

  testWidgets('savol berish: maxfiylik ogohlantirishi va rasm yo‘qligi', (
    tester,
  ) async {
    await pump(
      tester,
      at: Routes.qaAsk,
      svc: _FakeQa(me: _verifiedMe),
    );
    expect(find.byKey(const Key('qa.privacyWarning')), findsOneWidget);
    expect(find.byKey(const Key('qa.noImages')), findsOneWidget);
    // Rasm biriktirish tugmasi umuman yo‘q.
    expect(find.byIcon(Icons.attach_file), findsNothing);
    expect(find.byIcon(Icons.photo_outlined), findsNothing);
  });

  testWidgets('tarjima: belgi va «Asl matn» qaytishi', (tester) async {
    final svc = _FakeQa(me: _verifiedMe, questionData: _question);
    await pump(tester, at: Routes.qaQuestion('q1'), svc: svc, lang: 'uz');
    final translate = find.byKey(const Key('qa.translate.q1'));
    await tester.ensureVisible(translate);
    await tester.pumpAndSettle();
    await tester.tap(translate);
    await tester.pumpAndSettle();
    expect(svc.translated, contains('q1'));
    expect(find.text('Mashina tarjimasi'), findsOneWidget);
    expect(find.text('Mashina matni'), findsOneWidget);
    final original = find.byKey(const Key('qa.original.q1'));
    await tester.ensureVisible(original);
    await tester.pumpAndSettle();
    await tester.tap(original);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('qa.machineTranslation.q1')), findsNothing);
    expect(
      find.textContaining('How do we separate postmortem formation'),
      findsOneWidget,
    );
  });

  for (final (lang, promise) in const [
    ('uz', 'Fayl SAQLANMAYDI'),
    ('ru', 'Файл НЕ сохраняется'),
    ('en', 'The file is NOT stored'),
  ]) {
    testWidgets('tasdiqlash ekrani «fayl saqlanmaydi» deydi ($lang)', (
      tester,
    ) async {
      await pump(
        tester,
        at: Routes.qaVerify,
        svc: _FakeQa(me: _unverifiedMe),
        lang: lang,
      );
      expect(find.byKey(const Key('qa.verify.notStored')), findsOneWidget);
      expect(find.textContaining(promise), findsOneWidget);
    });
  }

  testWidgets('tasdiqlash: qolgan urinishlar va juda katta fayl rad etiladi', (
    tester,
  ) async {
    final svc = _FakeQa(me: _unverifiedMe);
    await pump(
      tester,
      at: Routes.qaVerify,
      svc: svc,
      picker: _FakePicker(_document(QaDocument.maxBytes + 1)),
    );
    expect(find.text('Bugun 1 urinish qoldi'), findsOneWidget);
    final pick = find.byKey(const Key('qa.verify.pick'));
    await tester.ensureVisible(pick);
    await tester.pumpAndSettle();
    await tester.tap(pick);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('qa.verify.badDocument')), findsOneWidget);
    final send = tester.widget<FilledButton>(
      find.byKey(const Key('qa.verify.send')),
    );
    expect(send.onPressed, isNull);
    expect(svc.verified, isEmpty);
  });

  testWidgets('tasdiqlash: hujjat yuboriladi va javob ko‘rsatiladi', (
    tester,
  ) async {
    final svc = _FakeQa(
      me: _unverifiedMe,
      verifyOutcome: const QaVerifyOutcome(
        status: QaStatus.verified,
        reason: QaReason.documentOk,
        attemptsToday: 1,
      ),
    );
    await pump(
      tester,
      at: Routes.qaVerify,
      svc: svc,
      picker: _FakePicker(_document(2048)),
    );
    final pick = find.byKey(const Key('qa.verify.pick'));
    await tester.ensureVisible(pick);
    await tester.pumpAndSettle();
    await tester.tap(pick);
    await tester.pumpAndSettle();
    final send = find.byKey(const Key('qa.verify.send'));
    await tester.ensureVisible(send);
    await tester.pumpAndSettle();
    await tester.tap(send);
    await tester.pumpAndSettle();
    expect(svc.verified, hasLength(1));
    expect(find.byKey(const Key('qa.verify.accepted')), findsOneWidget);
    // Hujjat yuborilgandan keyin ekranda qolmaydi.
    expect(find.byKey(const Key('qa.verify.chosen')), findsNothing);
  });

  testWidgets('tasdiqlash rad etilsa sabab tushunarli', (tester) async {
    final svc = _FakeQa(
      me: _unverifiedMe,
      verifyOutcome: const QaVerifyOutcome(
        status: QaStatus.rejected,
        reason: QaReason.notACredential,
        attemptsToday: 1,
      ),
    );
    await pump(
      tester,
      at: Routes.qaVerify,
      svc: svc,
      picker: _FakePicker(_document(2048)),
    );
    final pick = find.byKey(const Key('qa.verify.pick'));
    await tester.ensureVisible(pick);
    await tester.pumpAndSettle();
    await tester.tap(pick);
    await tester.pumpAndSettle();
    final sendRejected = find.byKey(const Key('qa.verify.send'));
    await tester.ensureVisible(sendRejected);
    await tester.pumpAndSettle();
    await tester.tap(sendRejected);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('qa.verify.rejected')), findsOneWidget);
    expect(
      find.textContaining('fayl kasbiy hujjatga o‘xshamaydi'),
      findsOneWidget,
    );
  });

  testWidgets('320 dp va katta matnda ro‘yxat sig‘adi', (tester) async {
    await pump(
      tester,
      at: Routes.qa,
      svc: _FakeQa(me: _verifiedMe, feedData: _feed),
      size: const Size(320, 640),
      textScale: 1.3,
    );
    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('qa.card.q1')), findsOneWidget);
  });

  testWidgets('admin bo‘lmaganga moderatsiya navbati berilmaydi', (
    tester,
  ) async {
    await pump(
      tester,
      at: Routes.qaModeration,
      svc: _FakeQa(me: _verifiedMe),
    );
    expect(find.byKey(const Key('qa.moderation.adminOnly')), findsOneWidget);
    expect(find.byKey(const Key('qa.moderation')), findsNothing);
  });

  testWidgets('menikilar: tekshiruvdagi post holati bilan ko‘rinadi', (
    tester,
  ) async {
    await pump(
      tester,
      at: Routes.qaMine,
      svc: _FakeQa(
        me: _verifiedMe,
        mineData: QaMine(
          profile: _verifiedMe.profile,
          questions: [
            QaMineItem(
              id: 'q9',
              status: QaPostStatus.moderation,
              title: 'Tekshiruvdagi savol',
              createdAt: DateTime.utc(2026, 10, 3),
            ),
          ],
          answers: const [],
        ),
      ),
    );
    expect(find.byKey(const Key('qa.mine.q9')), findsOneWidget);
    expect(find.text('Tekshiruvda'), findsOneWidget);
  });
}
