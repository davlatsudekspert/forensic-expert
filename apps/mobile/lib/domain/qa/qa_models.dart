/// «Savol-javob (Hamjamiyat)» domen modellari.
///
/// Serverdagi qoidalar mijozda takrorlanmaydi — bu yerda faqat server
/// javobining o‘qilishi va ekranda ko‘rsatish uchun kerakli hisob-kitob bor.
/// Vakolat (kim javob yozadi, kim pin qiladi) har doim serverda tekshiriladi.
library;

/// Postdagi tillar. Server ham shu uchtasini qabul qiladi.
enum QaLang {
  uz('uz'),
  ru('ru'),
  en('en');

  const QaLang(this.wire);

  final String wire;

  static QaLang? fromWire(Object? value) {
    for (final l in values) {
      if (l.wire == value) return l;
    }
    return null;
  }

  /// Ilova tili kodidan (`Locale.languageCode`) post tili.
  static QaLang fromLocale(String languageCode) =>
      fromWire(languageCode) ?? QaLang.uz;
}

/// Hamjamiyatdagi rol. Server `qa_profiles.role` bilan bir xil.
enum QaRole {
  forensicPhysician('forensic_physician'),
  forensicChemist('forensic_chemist'),
  labTechnician('lab_technician'),
  student('student'),
  other('other');

  const QaRole(this.wire);

  final String wire;

  /// Hujjat bilan tasdiqlanishi mumkin bo‘lgan rollar (server ham shunday).
  bool get verifiable =>
      this == forensicPhysician ||
      this == forensicChemist ||
      this == labTechnician;

  static QaRole? fromWire(Object? value) {
    for (final r in values) {
      if (r.wire == value) return r;
    }
    return null;
  }
}

/// Tasdiqlash holati.
enum QaStatus {
  unverified('unverified'),
  verified('verified'),
  rejected('rejected'),
  suspended('suspended');

  const QaStatus(this.wire);

  final String wire;

  static QaStatus fromWire(Object? value) {
    for (final s in values) {
      if (s.wire == value) return s;
    }
    return QaStatus.unverified;
  }
}

/// Server qaytargan qisqa mashina sababi. Hujjatdan olingan matn emas.
enum QaReason {
  documentOk('document_ok'),
  notACredential('not_a_credential'),
  unreadable('unreadable'),
  roleMismatch('role_mismatch'),
  lowConfidence('low_confidence'),
  expired('expired'),
  manualCheck('manual_check'),
  reported('reported');

  const QaReason(this.wire);

  final String wire;

  static QaReason? fromWire(Object? value) {
    for (final r in values) {
      if (r.wire == value) return r;
    }
    return null;
  }
}

/// Post holati.
enum QaPostStatus {
  published('published'),
  moderation('moderation'),
  removed('removed');

  const QaPostStatus(this.wire);

  final String wire;

  static QaPostStatus fromWire(Object? value) {
    for (final s in values) {
      if (s.wire == value) return s;
    }
    return QaPostStatus.moderation;
  }
}

/// Maxfiylik filtri topgan narsa (serverdagi `qa_privacy_flags`).
enum QaPrivacyFlag {
  caseNumber('case_number'),
  personName('person_name'),
  dateAndPlace('date_and_place'),
  contact('contact'),
  identifier('identifier');

  const QaPrivacyFlag(this.wire);

  final String wire;

  static QaPrivacyFlag? fromWire(Object? value) {
    for (final f in values) {
      if (f.wire == value) return f;
    }
    return null;
  }
}

DateTime? _time(Object? value) =>
    value is String ? DateTime.tryParse(value)?.toLocal() : null;

List<String> _strings(Object? value) => [
  if (value is List)
    for (final e in value)
      if (e is String) e,
];

/// Foydalanuvchining hamjamiyatdagi profili (`qa_profiles`).
///
/// E‘tibor bering: bu yerda ism, diplom raqami yoki email yo‘q — server ham
/// ularni saqlamaydi.
class QaProfile {
  const QaProfile({
    required this.status,
    this.role,
    this.countryCode,
    this.reason,
    this.manual = false,
    this.decidedAt,
  });

  factory QaProfile.fromJson(Map<String, Object?> json) => QaProfile(
    status: QaStatus.fromWire(json['status']),
    role: QaRole.fromWire(json['role']),
    countryCode: json['country_code'] as String?,
    reason: QaReason.fromWire(json['reason']),
    manual: json['manual'] == true,
    decidedAt: _time(json['decided_at']),
  );

  static const unverified = QaProfile(status: QaStatus.unverified);

  final QaStatus status;
  final QaRole? role;
  final String? countryCode;
  final QaReason? reason;

  /// Qo‘lda tekshirilgan belgi (AI qarori bilan yo‘qolmaydi).
  final bool manual;
  final DateTime? decidedAt;

  bool get isVerified => status == QaStatus.verified;
}

/// `qa_status` javobі: profil, mavjud teglar, bugungi urinishlar.
class QaMe {
  const QaMe({
    required this.profile,
    required this.tags,
    required this.attemptsToday,
    required this.canAnswer,
  });

  factory QaMe.fromJson(Map<String, Object?> json) {
    final profile = json['profile'];
    return QaMe(
      profile: profile is Map
          ? QaProfile.fromJson(profile.cast<String, Object?>())
          : QaProfile.unverified,
      tags: _strings(json['tags']),
      attemptsToday: (json['attempts_today'] as num?)?.toInt() ?? 0,
      canAnswer: json['can_answer'] == true,
    );
  }

  static const empty = QaMe(
    profile: QaProfile.unverified,
    tags: [],
    attemptsToday: 0,
    canAnswer: false,
  );

  final QaProfile profile;
  final List<String> tags;
  final int attemptsToday;

  /// Javob yozish huquqi — serverdan. Mijoz o‘zi hal qilmaydi.
  final bool canAnswer;

  /// Kuniga 3 urinish (egasining qoidasi); server ham shu chegarani qo‘yadi.
  static const dailyVerifyAttempts = 3;

  int get attemptsLeft =>
      (dailyVerifyAttempts - attemptsToday).clamp(0, dailyVerifyAttempts);
}

/// Ro‘yxatdagi savol.
class QaQuestionSummary {
  const QaQuestionSummary({
    required this.id,
    required this.lang,
    required this.title,
    required this.excerpt,
    required this.tags,
    required this.pinned,
    required this.answerCount,
    required this.hasAccepted,
    required this.isMine,
    this.authorRole,
    this.createdAt,
  });

  factory QaQuestionSummary.fromJson(Map<String, Object?> json) =>
      QaQuestionSummary(
        id: '${json['id']}',
        lang: QaLang.fromWire(json['lang']) ?? QaLang.uz,
        title: '${json['title'] ?? ''}',
        excerpt: '${json['excerpt'] ?? ''}',
        tags: _strings(json['tags']),
        pinned: json['pinned'] == true,
        answerCount: (json['answer_count'] as num?)?.toInt() ?? 0,
        hasAccepted: json['has_accepted'] == true,
        isMine: json['is_mine'] == true,
        authorRole: QaRole.fromWire(json['author_role']),
        createdAt: _time(json['created_at']),
      );

  final String id;
  final QaLang lang;
  final String title;
  final String excerpt;
  final List<String> tags;
  final bool pinned;
  final int answerCount;
  final bool hasAccepted;
  final bool isMine;

  /// Faqat tasdiqlangan mutaxassisning roli keladi; aks holda `null`.
  final QaRole? authorRole;
  final DateTime? createdAt;

  bool get authorVerified => authorRole != null;
}

/// `qa_feed` javobi.
class QaFeed {
  const QaFeed({required this.total, required this.items});

  factory QaFeed.fromJson(Map<String, Object?> json) => QaFeed(
    total: (json['total'] as num?)?.toInt() ?? 0,
    items: [
      if (json['items'] case final List<Object?> list)
        for (final e in list)
          if (e is Map) QaQuestionSummary.fromJson(e.cast<String, Object?>()),
    ],
  );

  static const empty = QaFeed(total: 0, items: []);

  final int total;
  final List<QaQuestionSummary> items;
}

/// Savolga javob.
class QaAnswer {
  const QaAnswer({
    required this.id,
    required this.lang,
    required this.body,
    required this.score,
    required this.myVote,
    required this.accepted,
    required this.isMine,
    this.authorRole,
    this.createdAt,
  });

  factory QaAnswer.fromJson(Map<String, Object?> json) => QaAnswer(
    id: '${json['id']}',
    lang: QaLang.fromWire(json['lang']) ?? QaLang.uz,
    body: '${json['body'] ?? ''}',
    score: (json['score'] as num?)?.toInt() ?? 0,
    myVote: (json['my_vote'] as num?)?.toInt() ?? 0,
    accepted: json['accepted'] == true,
    isMine: json['is_mine'] == true,
    authorRole: QaRole.fromWire(json['author_role']),
    createdAt: _time(json['created_at']),
  );

  final String id;
  final QaLang lang;
  final String body;
  final int score;

  /// −1, 0 yoki 1.
  final int myVote;
  final bool accepted;
  final bool isMine;
  final QaRole? authorRole;
  final DateTime? createdAt;

  bool get authorVerified => authorRole != null;

  QaAnswer copyWith({int? score, int? myVote, bool? accepted}) => QaAnswer(
    id: id,
    lang: lang,
    body: body,
    score: score ?? this.score,
    myVote: myVote ?? this.myVote,
    accepted: accepted ?? this.accepted,
    isMine: isMine,
    authorRole: authorRole,
    createdAt: createdAt,
  );
}

/// Bitta savol sahifasi.
class QaQuestion {
  const QaQuestion({
    required this.id,
    required this.lang,
    required this.title,
    required this.body,
    required this.tags,
    required this.status,
    required this.pinned,
    required this.isMine,
    required this.answers,
    this.acceptedAnswerId,
    this.authorRole,
    this.createdAt,
  });

  factory QaQuestion.fromJson(Map<String, Object?> json) => QaQuestion(
    id: '${json['id']}',
    lang: QaLang.fromWire(json['lang']) ?? QaLang.uz,
    title: '${json['title'] ?? ''}',
    body: '${json['body'] ?? ''}',
    tags: _strings(json['tags']),
    status: QaPostStatus.fromWire(json['status']),
    pinned: json['pinned'] == true,
    isMine: json['is_mine'] == true,
    acceptedAnswerId: json['accepted_answer_id'] as String?,
    authorRole: QaRole.fromWire(json['author_role']),
    createdAt: _time(json['created_at']),
    answers: [
      if (json['answers'] case final List<Object?> list)
        for (final e in list)
          if (e is Map) QaAnswer.fromJson(e.cast<String, Object?>()),
    ],
  );

  final String id;
  final QaLang lang;
  final String title;
  final String body;
  final List<String> tags;
  final QaPostStatus status;
  final bool pinned;
  final bool isMine;
  final String? acceptedAnswerId;
  final QaRole? authorRole;
  final DateTime? createdAt;
  final List<QaAnswer> answers;

  bool get authorVerified => authorRole != null;
}

/// `qa_my` — o‘z savollari va javoblari (holati bilan).
class QaMine {
  const QaMine({
    required this.profile,
    required this.questions,
    required this.answers,
  });

  factory QaMine.fromJson(Map<String, Object?> json) {
    final profile = json['profile'];
    return QaMine(
      profile: profile is Map
          ? QaProfile.fromJson(profile.cast<String, Object?>())
          : QaProfile.unverified,
      questions: [
        if (json['questions'] case final List<Object?> list)
          for (final e in list)
            if (e is Map) QaMineItem.fromJson(e.cast<String, Object?>()),
      ],
      answers: [
        if (json['answers'] case final List<Object?> list)
          for (final e in list)
            if (e is Map) QaMineItem.fromJson(e.cast<String, Object?>()),
      ],
    );
  }

  static const empty = QaMine(
    profile: QaProfile.unverified,
    questions: [],
    answers: [],
  );

  final QaProfile profile;
  final List<QaMineItem> questions;
  final List<QaMineItem> answers;
}

/// `qa_my` ro‘yxatidagi bitta yozuv (savol yoki javob).
class QaMineItem {
  const QaMineItem({
    required this.id,
    required this.status,
    this.title,
    this.questionId,
    this.answerCount = 0,
    this.score = 0,
    this.createdAt,
  });

  factory QaMineItem.fromJson(Map<String, Object?> json) => QaMineItem(
    id: '${json['id']}',
    status: QaPostStatus.fromWire(json['status']),
    title: json['title'] as String?,
    questionId: json['question_id'] as String?,
    answerCount: (json['answer_count'] as num?)?.toInt() ?? 0,
    score: (json['score'] as num?)?.toInt() ?? 0,
    createdAt: _time(json['created_at']),
  );

  final String id;
  final QaPostStatus status;
  final String? title;

  /// Javob uchun — qaysi savolga.
  final String? questionId;
  final int answerCount;
  final int score;
  final DateTime? createdAt;
}

/// Savol yoki javob yuborish natijasi.
class QaPostResult {
  const QaPostResult({
    required this.id,
    required this.status,
    this.flags = const [],
  });

  factory QaPostResult.fromJson(Map<String, Object?> json) => QaPostResult(
    id: json['id'] as String?,
    status: QaPostStatus.fromWire(json['status']),
    flags: [
      if (json['flags'] case final List<Object?> list)
        for (final e in list) ?QaPrivacyFlag.fromWire(e),
    ],
  );

  final String? id;
  final QaPostStatus status;

  /// Bo‘sh bo‘lmasa — maxfiylik filtri ishladi va post moderatsiyaga tushdi.
  final List<QaPrivacyFlag> flags;

  bool get held => status != QaPostStatus.published;
}

/// Shikoyat natijasi.
class QaReportResult {
  const QaReportResult({required this.reports, required this.hidden});

  factory QaReportResult.fromJson(Map<String, Object?> json) => QaReportResult(
    reports: (json['reports'] as num?)?.toInt() ?? 0,
    hidden: json['hidden'] == true,
  );

  final int reports;

  /// Uch xil foydalanuvchi shikoyat qilgani uchun yashirildi.
  final bool hidden;
}

/// Mashina tarjimasi (serverda keshlangan) yoki asl matn.
class QaTranslation {
  const QaTranslation({
    required this.body,
    this.title,
    this.engine,
    this.isSource = false,
  });

  factory QaTranslation.fromJson(Map<String, Object?> json) => QaTranslation(
    body: '${json['body'] ?? ''}',
    title: json['title'] as String?,
    engine: json['engine'] as String?,
    isSource: json['source'] == true,
  );

  final String body;
  final String? title;

  /// Qaysi dvigatel tarjima qilgani (`cf:…`, `gemini:…`). Asl matnda `null`.
  final String? engine;

  /// Post allaqachon shu tilda — tarjima qilinmagan.
  final bool isSource;

  /// «Mashina tarjimasi» belgisi ko‘rsatiladimi.
  bool get isMachine => !isSource && engine != null;
}

/// Hujjat tekshiruvi natijasi.
class QaVerifyOutcome {
  const QaVerifyOutcome({
    required this.status,
    this.reason,
    this.attemptsToday,
    this.error,
  });

  factory QaVerifyOutcome.fromJson(Map<String, Object?> json) =>
      QaVerifyOutcome(
        status: QaStatus.fromWire(json['status']),
        reason: QaReason.fromWire(json['reason']),
        attemptsToday: (json['attempts_today'] as num?)?.toInt(),
      );

  /// Tarmoq yoki server xatosi (`too_many_requests`, `upstream`, …).
  static QaVerifyOutcome failed(String error) =>
      QaVerifyOutcome(status: QaStatus.unverified, error: error);

  final QaStatus status;
  final QaReason? reason;
  final int? attemptsToday;
  final String? error;

  bool get verified => error == null && status == QaStatus.verified;
  bool get rejected => error == null && status == QaStatus.rejected;
}

/// Admin moderatsiya navbati.
class QaModerationQueue {
  const QaModerationQueue({
    required this.questions,
    required this.answers,
    required this.suspended,
  });

  factory QaModerationQueue.fromJson(Map<String, Object?> json) =>
      QaModerationQueue(
        questions: [
          if (json['questions'] case final List<Object?> list)
            for (final e in list)
              if (e is Map) QaFlaggedPost.fromJson(e.cast<String, Object?>()),
        ],
        answers: [
          if (json['answers'] case final List<Object?> list)
            for (final e in list)
              if (e is Map) QaFlaggedPost.fromJson(e.cast<String, Object?>()),
        ],
        suspended: [
          if (json['suspended'] case final List<Object?> list)
            for (final e in list)
              if (e is Map)
                QaSuspendedProfile.fromJson(e.cast<String, Object?>()),
        ],
      );

  static const empty = QaModerationQueue(
    questions: [],
    answers: [],
    suspended: [],
  );

  final List<QaFlaggedPost> questions;
  final List<QaFlaggedPost> answers;
  final List<QaSuspendedProfile> suspended;

  bool get isEmpty => questions.isEmpty && answers.isEmpty && suspended.isEmpty;

  int get length => questions.length + answers.length + suspended.length;
}

/// Moderatsiyadagi post.
class QaFlaggedPost {
  const QaFlaggedPost({
    required this.id,
    required this.lang,
    required this.body,
    required this.status,
    required this.flags,
    required this.reports,
    this.title,
    this.questionId,
    this.createdAt,
  });

  factory QaFlaggedPost.fromJson(Map<String, Object?> json) => QaFlaggedPost(
    id: '${json['id']}',
    lang: QaLang.fromWire(json['lang']) ?? QaLang.uz,
    body: '${json['body'] ?? ''}',
    status: QaPostStatus.fromWire(json['status']),
    flags: [
      if (json['flags'] case final List<Object?> list)
        for (final e in list) ?QaPrivacyFlag.fromWire(e),
    ],
    reports: (json['reports'] as num?)?.toInt() ?? 0,
    title: json['title'] as String?,
    questionId: json['question_id'] as String?,
    createdAt: _time(json['created_at']),
  );

  final String id;
  final QaLang lang;
  final String body;
  final QaPostStatus status;
  final List<QaPrivacyFlag> flags;
  final int reports;
  final String? title;
  final String? questionId;
  final DateTime? createdAt;

  bool get isAnswer => questionId != null;
}

/// To‘xtatilgan belgi (admin ro‘yxati). Ism va email yo‘q — faqat ID.
class QaSuspendedProfile {
  const QaSuspendedProfile({
    required this.userId,
    this.role,
    this.countryCode,
    this.reason,
    this.decidedAt,
  });

  factory QaSuspendedProfile.fromJson(Map<String, Object?> json) =>
      QaSuspendedProfile(
        userId: '${json['user_id']}',
        role: QaRole.fromWire(json['role']),
        countryCode: json['country_code'] as String?,
        reason: QaReason.fromWire(json['reason']),
        decidedAt: _time(json['decided_at']),
      );

  final String userId;
  final QaRole? role;
  final String? countryCode;
  final QaReason? reason;
  final DateTime? decidedAt;
}

/// Admin harakati (`qa_moderate`).
enum QaModerationAction {
  publish('publish'),
  remove('remove'),
  pin('pin'),
  unpin('unpin'),
  reinstate('reinstate'),
  suspend('suspend');

  const QaModerationAction(this.wire);

  final String wire;
}

/// Shikoyat/moderatsiya nishoni.
enum QaTargetType {
  question('question'),
  answer('answer'),
  user('user');

  const QaTargetType(this.wire);

  final String wire;
}

/// Tekshirishga yuborilgan hujjat — **faqat xotirada**.
///
/// Bu obyekt diskka yozilmaydi va server ham saqlamaydi: so‘rov tugashi bilan
/// yo‘qoladi. Shu sababli unda fayl yo‘li emas, baytlar saqlanadi.
class QaDocument {
  const QaDocument({required this.bytes, required this.mimeType});

  /// Server qabul qiladigan turlar.
  static const allowedMimeTypes = <String>[
    'image/jpeg',
    'image/png',
    'image/webp',
    'application/pdf',
  ];

  /// 6 MiB — server chegarasi bilan bir xil.
  static const maxBytes = 6 * 1024 * 1024;

  final List<int> bytes;
  final String mimeType;

  bool get isAllowed =>
      allowedMimeTypes.contains(mimeType) &&
      bytes.isNotEmpty &&
      bytes.length <= maxBytes;
}
