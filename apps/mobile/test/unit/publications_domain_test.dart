import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/domain/publications/publication_models.dart';

void main() {
  const author = PublicationActor.author;
  const mod = PublicationActor.moderator;

  group('holat o‘tishlari (server bilan bir xil)', () {
    test('to‘liq yo‘l: DRAFT → … → PUBLISHED', () {
      const path = [
        (PublicationStatus.draft, PublicationStatus.submitted, author),
        (PublicationStatus.submitted, PublicationStatus.screening, mod),
        (PublicationStatus.screening, PublicationStatus.inReview, mod),
        (PublicationStatus.inReview, PublicationStatus.approved, mod),
        (PublicationStatus.approved, PublicationStatus.published, mod),
      ];
      for (final (from, to, actor) in path) {
        expect(PublicationTransitions.allowed(from, to, actor), isTrue);
      }
    });

    test('holatni o‘tkazib yuborib bo‘lmaydi', () {
      for (final (from, to) in const [
        (PublicationStatus.draft, PublicationStatus.published),
        (PublicationStatus.submitted, PublicationStatus.approved),
        (PublicationStatus.submitted, PublicationStatus.published),
        (PublicationStatus.screening, PublicationStatus.approved),
        (PublicationStatus.inReview, PublicationStatus.published),
        (PublicationStatus.approved, PublicationStatus.retracted),
      ]) {
        expect(PublicationTransitions.allowed(from, to, mod), isFalse);
        expect(PublicationTransitions.allowed(from, to, author), isFalse);
      }
    });

    test(
      'muallif moderator o‘tishlarini qila olmaydi (o‘zi nashr etmaydi)',
      () {
        for (final s in PublicationStatus.values) {
          for (final to in PublicationTransitions.next(s, author)) {
            expect(to, isNot(PublicationStatus.published));
            expect(to, isNot(PublicationStatus.approved));
          }
        }
        expect(
          PublicationTransitions.next(PublicationStatus.rejected, author),
          [PublicationStatus.draft],
        );
        expect(
          PublicationTransitions.next(PublicationStatus.draft, mod),
          isEmpty,
        );
      },
    );

    test('rad/qaytarib olish — moderator izohi majburiy', () {
      expect(PublicationTransitions.next(PublicationStatus.inReview, mod), [
        PublicationStatus.approved,
        PublicationStatus.rejected,
      ]);
      expect(PublicationTransitions.next(PublicationStatus.published, mod), [
        PublicationStatus.retracted,
        PublicationStatus.superseded,
      ]);
      expect(
        PublicationTransitions.commentRequired(PublicationStatus.rejected),
        isTrue,
      );
      expect(
        PublicationTransitions.commentRequired(PublicationStatus.retracted),
        isTrue,
      );
      expect(
        PublicationTransitions.commentRequired(PublicationStatus.approved),
        isFalse,
      );
    });

    test('yakuniy holatlar', () {
      for (final s in [
        PublicationStatus.retracted,
        PublicationStatus.superseded,
      ]) {
        expect(s.isTerminal, isTrue);
        expect(PublicationTransitions.next(s, mod), isEmpty);
        expect(PublicationTransitions.next(s, author), isEmpty);
      }
      expect(PublicationStatus.draft.authorEditable, isTrue);
      expect(PublicationStatus.rejected.authorEditable, isTrue);
      expect(PublicationStatus.submitted.authorEditable, isFalse);
    });

    test('server qiymatlari', () {
      for (final s in PublicationStatus.values) {
        expect(PublicationStatus.fromWire(s.wire), s);
      }
      expect(PublicationStatus.fromWire('HACKED'), isNull);
      expect(ModerationResult.fromWire('SCREENING'), ModerationResult.done);
      expect(
        ModerationResult.fromWire('FORBIDDEN_OWN'),
        ModerationResult.forbiddenOwn,
      );
      expect(ModerationResult.fromWire(null), ModerationResult.failed);
      expect(
        SubmitResult.fromWire('CONFIRMATIONS_REQUIRED'),
        SubmitResult.confirmationsRequired,
      );
      expect(ReportResult.fromWire('REPORTED'), ReportResult.reported);
    });
  });

  group('yuborish shartlari', () {
    test('uchala tasdiq va majburiy maydonlar', () {
      const empty = PublicationDraft();
      expect(empty.submitIssues, {
        SubmitIssue.missingTitle,
        SubmitIssue.missingAbstract,
        SubmitIssue.missingDiscipline,
        SubmitIssue.missingConfirmations,
      });
      const two = PublicationDraft(
        title: 'T',
        abstract: 'A',
        disciplineCode: 'forensic_toxicology',
        rightsConfirmed: true,
        publicationConsent: true,
      );
      expect(two.submitIssues, {SubmitIssue.missingConfirmations});
      const ok = PublicationDraft(
        title: 'T',
        abstract: 'A',
        disciplineCode: 'forensic_toxicology',
        rightsConfirmed: true,
        publicationConsent: true,
        noPersonalDataConfirmed: true,
      );
      expect(ok.submitIssues, isEmpty);
    });

    test('toJson va matnni bo‘lish', () {
      expect(PublicationDraft.splitKeywords('a, b; ,c\nd'), [
        'a',
        'b',
        'c',
        'd',
      ]);
      final j = const PublicationDraft(
        title: '  T  ',
        coauthors: ['A. One', ' '],
        language: PublicationLanguage.ru,
      ).toJson();
      expect(j['title'], 'T');
      expect(j['coauthors'], [
        {'name': 'A. One'},
      ]);
      expect(j['language'], 'ru');
      expect(j['no_personal_data_confirmed'], isFalse);
    });
  });

  test('Publication.fromJson: xavfsiz o‘qish, vaqt chizig‘i, izoh', () {
    final p = Publication.fromJson({
      'id': 'p1',
      'status': 'REJECTED',
      'title': 'Ethanol',
      'keywords': ['a', 3],
      'language': 'xx',
      'coauthors': [
        {'name': 'A. One'},
        'B. Two',
      ],
      'version': 2,
      'events': [
        {'from': null, 'to': 'DRAFT', 'at': '2026-10-08T10:00:00Z'},
        {'from': 'DRAFT', 'to': 'BOGUS'},
        {'from': 'DRAFT', 'to': 'SUBMITTED'},
      ],
      'reviews': [
        {'decision': 'IN_REVIEW', 'comment': null},
        {'decision': 'REJECTED', 'comment': 'Add methods'},
      ],
    });
    expect(p.status, PublicationStatus.rejected);
    expect(p.keywords, ['a']);
    expect(p.language, PublicationLanguage.uz);
    expect(p.coauthors, ['A. One', 'B. Two']);
    expect(p.version, 2);
    expect(p.events.map((e) => e.to), [
      PublicationStatus.draft,
      PublicationStatus.submitted,
    ]);
    expect(p.lastComment, 'Add methods');
    final d = PublicationDraft.fromPublication(p);
    expect(d.id, 'p1');
    expect(d.allConfirmed, isFalse);

    final q = ModerationQueue.fromJson({
      'items': [
        {'id': 'x', 'status': 'SUBMITTED', 'title': 'X', 'own': true},
      ],
      'reports': [
        {'publication_id': 'x', 'title': 'X', 'reason': 'PLAGIARISM'},
      ],
    });
    expect(q.items.single.own, isTrue);
    expect(q.reports.single.reason, ReportReason.plagiarism);
  });
}
