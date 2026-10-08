/// «Ekspert maqolalari» — sof Dart domen modeli va holat o‘tish qoidalari.
///
/// Haqiqiy qoidalar serverda (`supabase/migrations/20261008000000_publications.sql`,
/// `private.publication_transition_ok`); bu yerdagi nusxa faqat UI uchun
/// (qaysi tugmani ko‘rsatish). Server baribir har bir o‘tishni tekshiradi.
///
/// Muhim: maqola yuborilishi yoki nashr etilishi uning ilmiy tasdiqlanganini
/// bildirmaydi. Pullik obuna moderatsiya natijasiga ta’sir qilmaydi.
library;

enum PublicationStatus {
  draft('DRAFT'),
  submitted('SUBMITTED'),
  screening('SCREENING'),
  inReview('IN_REVIEW'),
  approved('APPROVED'),
  rejected('REJECTED'),
  published('PUBLISHED'),
  retracted('RETRACTED'),
  superseded('SUPERSEDED');

  const PublicationStatus(this.wire);

  /// Server qiymati.
  final String wire;

  static PublicationStatus? fromWire(Object? v) {
    for (final s in values) {
      if (s.wire == v) return s;
    }
    return null;
  }

  /// Yakuniy holat (keyin hech qanday o‘tish yo‘q).
  bool get isTerminal =>
      this == PublicationStatus.retracted ||
      this == PublicationStatus.superseded;

  /// Muallif tahrirlashi mumkin (`save_draft`).
  bool get authorEditable =>
      this == PublicationStatus.draft || this == PublicationStatus.rejected;
}

enum PublicationActor { author, moderator }

/// Ruxsat etilgan o‘tishlar (server bilan bir xil). Holatni o‘tkazib
/// yuborish mumkin emas.
abstract final class PublicationTransitions {
  static const _moderator = <PublicationStatus, List<PublicationStatus>>{
    PublicationStatus.submitted: [PublicationStatus.screening],
    PublicationStatus.screening: [PublicationStatus.inReview],
    PublicationStatus.inReview: [
      PublicationStatus.approved,
      PublicationStatus.rejected,
    ],
    PublicationStatus.approved: [PublicationStatus.published],
    PublicationStatus.published: [
      PublicationStatus.retracted,
      PublicationStatus.superseded,
    ],
  };

  static const _author = <PublicationStatus, List<PublicationStatus>>{
    PublicationStatus.draft: [PublicationStatus.submitted],
    PublicationStatus.rejected: [PublicationStatus.draft],
  };

  static List<PublicationStatus> next(
    PublicationStatus from,
    PublicationActor actor,
  ) =>
      (actor == PublicationActor.author ? _author : _moderator)[from] ??
      const [];

  static bool allowed(
    PublicationStatus from,
    PublicationStatus to,
    PublicationActor actor,
  ) => next(from, actor).contains(to);

  /// Moderator izohi majburiy bo‘lgan qarorlar.
  static bool commentRequired(PublicationStatus to) =>
      to == PublicationStatus.rejected || to == PublicationStatus.retracted;
}

/// Yuborishdan oldingi tekshiruv natijasi.
enum SubmitIssue {
  missingTitle,
  missingAbstract,
  missingDiscipline,
  missingConfirmations,
}

enum PublicationLanguage { uz, ru, en }

/// Muallif kiritadigan ma’lumot (`save_draft` uchun).
class PublicationDraft {
  const PublicationDraft({
    this.id,
    this.title = '',
    this.abstract = '',
    this.keywords = const [],
    this.language = PublicationLanguage.uz,
    this.disciplineCode,
    this.coauthors = const [],
    this.affiliation = '',
    this.doi = '',
    this.referenceList = '',
    this.externalUrl = '',
    this.rightsConfirmed = false,
    this.publicationConsent = false,
    this.noPersonalDataConfirmed = false,
  });

  factory PublicationDraft.fromPublication(Publication p) => PublicationDraft(
    id: p.id,
    title: p.title,
    abstract: p.abstract,
    keywords: p.keywords,
    language: p.language,
    disciplineCode: p.disciplineCode,
    coauthors: p.coauthors,
    affiliation: p.affiliation ?? '',
    doi: p.doi ?? '',
    referenceList: p.referenceList ?? '',
    externalUrl: p.externalUrl ?? '',
    rightsConfirmed: p.rightsConfirmed,
    publicationConsent: p.publicationConsent,
    noPersonalDataConfirmed: p.noPersonalDataConfirmed,
  );

  final String? id;
  final String title;
  final String abstract;
  final List<String> keywords;
  final PublicationLanguage language;
  final String? disciplineCode;
  final List<String> coauthors;
  final String affiliation;
  final String doi;
  final String referenceList;
  final String externalUrl;
  final bool rightsConfirmed;
  final bool publicationConsent;
  final bool noPersonalDataConfirmed;

  bool get allConfirmed =>
      rightsConfirmed && publicationConsent && noPersonalDataConfirmed;

  /// Yuborish uchun yetishmayotganlar (bo‘sh — yuborish mumkin).
  Set<SubmitIssue> get submitIssues => {
    if (title.trim().isEmpty) SubmitIssue.missingTitle,
    if (abstract.trim().isEmpty) SubmitIssue.missingAbstract,
    if (disciplineCode == null) SubmitIssue.missingDiscipline,
    if (!allConfirmed) SubmitIssue.missingConfirmations,
  };

  Map<String, Object?> toJson() => {
    'title': title.trim(),
    'abstract': abstract.trim(),
    'keywords': [
      for (final k in keywords)
        if (k.trim().isNotEmpty) k.trim(),
    ],
    'language': language.name,
    'discipline_code': disciplineCode,
    'coauthors': [
      for (final c in coauthors)
        if (c.trim().isNotEmpty) {'name': c.trim()},
    ],
    'affiliation': affiliation.trim(),
    'doi': doi.trim(),
    'reference_list': referenceList.trim(),
    'external_url': externalUrl.trim(),
    'rights_confirmed': rightsConfirmed,
    'publication_consent': publicationConsent,
    'no_personal_data_confirmed': noPersonalDataConfirmed,
  };

  /// «a, b; c» → [a, b, c].
  static List<String> splitKeywords(String raw) => [
    for (final k in raw.split(RegExp('[,;\n]')))
      if (k.trim().isNotEmpty) k.trim(),
  ];

  static List<String> splitLines(String raw) => [
    for (final k in raw.split('\n'))
      if (k.trim().isNotEmpty) k.trim(),
  ];
}

class PublicationEvent {
  const PublicationEvent({
    required this.from,
    required this.to,
    this.note,
    this.at,
  });

  final PublicationStatus? from;
  final PublicationStatus to;
  final String? note;
  final DateTime? at;
}

class PublicationReview {
  const PublicationReview({required this.decision, this.comment, this.at});

  final PublicationStatus decision;
  final String? comment;
  final DateTime? at;
}

class Publication {
  const Publication({
    required this.id,
    required this.status,
    required this.title,
    this.abstract = '',
    this.keywords = const [],
    this.language = PublicationLanguage.uz,
    this.disciplineCode,
    this.coauthors = const [],
    this.affiliation,
    this.doi,
    this.referenceList,
    this.externalUrl,
    this.version = 1,
    this.supersedes,
    this.publishedAt,
    this.updatedAt,
    this.rightsConfirmed = false,
    this.publicationConsent = false,
    this.noPersonalDataConfirmed = false,
    this.events = const [],
    this.reviews = const [],
    this.own = false,
  });

  factory Publication.fromJson(Map<String, Object?> j) {
    String? str(String k) => switch (j[k]) {
      final String s when s.trim().isNotEmpty => s,
      _ => null,
    };
    List<Object?> list(String k) => switch (j[k]) {
      final List<Object?> l => l,
      _ => const [],
    };
    Map<String, Object?> map(Object? o) => switch (o) {
      final Map<Object?, Object?> m => m.cast<String, Object?>(),
      _ => const {},
    };
    return Publication(
      id: str('id') ?? '',
      status:
          PublicationStatus.fromWire(j['status']) ??
          PublicationStatus.published,
      title: str('title') ?? '',
      abstract: str('abstract') ?? '',
      keywords: [
        for (final k in list('keywords'))
          if (k is String) k,
      ],
      language:
          PublicationLanguage.values.asNameMap()[j['language']] ??
          PublicationLanguage.uz,
      disciplineCode: str('discipline_code'),
      coauthors: [
        for (final c in list('coauthors'))
          if (c is String) c else if (map(c)['name'] case final String n) n,
      ],
      affiliation: str('affiliation'),
      doi: str('doi'),
      referenceList: str('reference_list'),
      externalUrl: str('external_url'),
      version: (j['version'] as num?)?.toInt() ?? 1,
      supersedes: str('supersedes'),
      publishedAt: DateTime.tryParse(str('published_at') ?? ''),
      updatedAt: DateTime.tryParse(str('updated_at') ?? ''),
      rightsConfirmed: j['rights_confirmed'] == true,
      publicationConsent: j['publication_consent'] == true,
      noPersonalDataConfirmed: j['no_personal_data_confirmed'] == true,
      events: [
        for (final e in list('events').map(map))
          if (PublicationStatus.fromWire(e['to']) case final to?)
            PublicationEvent(
              from: PublicationStatus.fromWire(e['from']),
              to: to,
              note: e['note'] as String?,
              at: DateTime.tryParse('${e['at']}'),
            ),
      ],
      reviews: [
        for (final r in list('reviews').map(map))
          if (PublicationStatus.fromWire(r['decision']) case final d?)
            PublicationReview(
              decision: d,
              comment: r['comment'] as String?,
              at: DateTime.tryParse('${r['at']}'),
            ),
      ],
      own: j['own'] == true,
    );
  }

  final String id;
  final PublicationStatus status;
  final String title;
  final String abstract;
  final List<String> keywords;
  final PublicationLanguage language;
  final String? disciplineCode;
  final List<String> coauthors;
  final String? affiliation;
  final String? doi;
  final String? referenceList;
  final String? externalUrl;
  final int version;
  final String? supersedes;
  final DateTime? publishedAt;
  final DateTime? updatedAt;
  final bool rightsConfirmed;
  final bool publicationConsent;
  final bool noPersonalDataConfirmed;

  /// Holat tarixi (faqat muallif va moderatorga).
  final List<PublicationEvent> events;

  /// Moderator qarorlari va izohlari (moderator kimligi berilmaydi).
  final List<PublicationReview> reviews;

  /// Moderatsiya navbatida: o‘z maqolasi (server uni moderatsiya qilishga
  /// ruxsat bermaydi).
  final bool own;

  /// Oxirgi moderator izohi.
  String? get lastComment {
    for (final r in reviews.reversed) {
      if (r.comment case final c? when c.trim().isNotEmpty) return c;
    }
    return null;
  }
}

/// Shikoyat sababi (`report_publication`).
enum ReportReason {
  plagiarism('PLAGIARISM'),
  personalData('PERSONAL_DATA'),
  copyright('COPYRIGHT'),
  misinformation('MISINFORMATION'),
  abuse('ABUSE'),
  other('OTHER');

  const ReportReason(this.wire);
  final String wire;

  static ReportReason? fromWire(Object? v) {
    for (final r in values) {
      if (r.wire == v) return r;
    }
    return null;
  }
}

class PublicationReport {
  const PublicationReport({
    required this.publicationId,
    required this.title,
    required this.reason,
    this.details,
  });

  final String publicationId;
  final String title;
  final ReportReason reason;
  final String? details;
}

class ModerationQueue {
  const ModerationQueue({this.items = const [], this.reports = const []});

  factory ModerationQueue.fromJson(Map<String, Object?> j) {
    List<Map<String, Object?>> maps(Object? o) => [
      if (o is List)
        for (final e in o)
          if (e is Map) e.cast<String, Object?>(),
    ];
    return ModerationQueue(
      items: [for (final m in maps(j['items'])) Publication.fromJson(m)],
      reports: [
        for (final m in maps(j['reports']))
          PublicationReport(
            publicationId: '${m['publication_id']}',
            title: '${m['title'] ?? ''}',
            reason: ReportReason.fromWire(m['reason']) ?? ReportReason.other,
            details: m['details'] as String?,
          ),
      ],
    );
  }

  final List<Publication> items;
  final List<PublicationReport> reports;
}

enum SubmitResult {
  submitted,
  confirmationsRequired,
  incomplete,
  invalidState,
  notFound,
  failed;

  static SubmitResult fromWire(Object? v) => switch (v) {
    'SUBMITTED' => submitted,
    'CONFIRMATIONS_REQUIRED' => confirmationsRequired,
    'INCOMPLETE' => incomplete,
    'INVALID_STATE' => invalidState,
    'NOT_FOUND' => notFound,
    _ => failed,
  };
}

enum ModerationResult {
  done,
  forbiddenOwn,
  invalidTransition,
  commentRequired,
  failed;

  static ModerationResult fromWire(Object? v) => switch (v) {
    'FORBIDDEN_OWN' => forbiddenOwn,
    'INVALID_TRANSITION' => invalidTransition,
    'COMMENT_REQUIRED' => commentRequired,
    final String s when PublicationStatus.fromWire(s) != null => done,
    _ => failed,
  };
}

enum ReportResult {
  reported,
  alreadyReported,
  failed;

  static ReportResult fromWire(Object? v) => switch (v) {
    'REPORTED' => reported,
    'ALREADY_REPORTED' => alreadyReported,
    _ => failed,
  };
}
