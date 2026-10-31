/// «Sinfda test» (Kahoot uslubidagi jonli sinf testi) — domen.
///
/// Qoidalar serverda (`supabase/migrations/20261017010000_class_quiz.sql`);
/// bu yerdagi sof funksiyalar (kod, laqab, ball, aralashtirish, CSV) server
/// bilan **bir xil** natija berishi kerak va test bilan tekshiriladi.
///
/// Xavfsizlik: to‘g‘ri javob savol ochiq paytida mijozga **hech qachon**
/// kelmaydi ([ClassStudentState.reveal] faqat vaqt tugagach); ustozga talabaning
/// faqat laqabi ko‘rinadi (ism va email yo‘q).
library;

import 'dart:math';

import 'package:flutter/foundation.dart';

/// Chegaralar (server CHECK’lari bilan bir xil).
abstract final class ClassQuizRules {
  static const int minQuestions = 5;
  static const int maxQuestions = 20;

  /// Savol soni chiplari (+ «Boshqa» — min/max ichida); standart — 10.
  static const List<int> questionPresets = [10, 15, 20];
  static const int defaultQuestions = 10;
  static const int minStudents = 5;
  static const int maxStudents = 200;

  /// Har savolga vaqt: server `class_create_session` — 5..300 butun son.
  static const int minSeconds = 5;
  static const int maxSeconds = 300;

  /// Tez tanlov chiplari (ixtiyoriy butun son ham mumkin); standart — 30.
  static const List<int> secondsChoices = [15, 30, 45, 60];
  static const int defaultSeconds = 30;

  static bool validSeconds(int s) => s >= minSeconds && s <= maxSeconds;
  static const int nickMin = 2;
  static const int nickMax = 20;
  static const int codeLength = 6;

  /// Ball: to‘g‘ri bo‘lsa 500 + tezlik bonusi (0..500).
  static const int basePoints = 500;
  static const int speedBonus = 500;

  /// Tarmoq kechikishi uchun server beradigan imtiyoz va to‘g‘ri javob
  /// ochilishidan oldingi kutish (ms).
  static const int submitGraceMs = 1000;
  static const int revealDelayMs = 1500;

  /// Tugagach sessiya saqlanadigan muddat.
  static const int retentionDays = 30;
}

/// Test o‘tkazish rejimi (server `class_sessions.pace`).
///
/// [host] — ustoz boshqaradi (standart, avvalgidek): savol va vaqt hammaga
/// umumiy, ustoz «Keyingi» bosadi. [self] — har kim o‘z tezligida: har
/// talabaning o‘z savoli, o‘z taymeri (savolni ochgan paytdan, server soati),
/// keyingisiga o‘zi o‘tadi; ustoz progress doskasini ko‘radi.
enum ClassPace {
  host,
  self;

  static ClassPace parse(Object? v) => v == 'self' ? self : host;

  /// Server qiymati (`host` / `self`).
  String get wire => name;
}

/// Sinf sozlamalari.
@immutable
class ClassQuizSettings {
  const ClassQuizSettings({
    this.questionCount = ClassQuizRules.defaultQuestions,
    this.studentLimit = 30,
    this.seconds = ClassQuizRules.defaultSeconds,
    this.pace = ClassPace.host,
  });

  final int questionCount;
  final int studentLimit;
  final int seconds;

  /// Rejim; standart — ustoz boshqaradi (o‘zgarmagan xulq).
  final ClassPace pace;

  bool get valid =>
      questionCount >= ClassQuizRules.minQuestions &&
      questionCount <= ClassQuizRules.maxQuestions &&
      studentLimit >= ClassQuizRules.minStudents &&
      studentLimit <= ClassQuizRules.maxStudents &&
      ClassQuizRules.validSeconds(seconds);

  ClassQuizSettings copyWith({
    int? questionCount,
    int? studentLimit,
    int? seconds,
    ClassPace? pace,
  }) => ClassQuizSettings(
    questionCount: questionCount ?? this.questionCount,
    studentLimit: studentLimit ?? this.studentLimit,
    seconds: seconds ?? this.seconds,
    pace: pace ?? this.pace,
  );
}

/// 6 xonali sinf kodi.
abstract final class ClassCode {
  static final _re = RegExp(r'^[0-9]{6}$');

  /// Bo‘shliq va defislarni olib tashlaydi; 6 raqam bo‘lmasa `null`.
  static String? normalize(String? raw) {
    if (raw == null) return null;
    final s = raw.replaceAll(RegExp(r'[\s-]'), '');
    return _re.hasMatch(s) ? s : null;
  }

  /// Faqat demo/fake adapter uchun (haqiqiy kod serverda CSPRNG bilan).
  static String generate(Random rng) =>
      rng.nextInt(1000000).toString().padLeft(ClassQuizRules.codeLength, '0');

  /// Proyektorda o‘qish uchun: `123 456`.
  static String display(String code) =>
      code.length == 6 ? '${code.substring(0, 3)} ${code.substring(3)}' : code;

  /// Ilova ichidagi yo‘l: `/join/<kod>` (deep link → router).
  static String routeFor(String code) => '/join/$code';

  /// Kiruvchi havoladan kodni ajratadi: `https://<domen>/join/123456`,
  /// `forensicexpert://app/join/123456`, `/join/123456` yoki `?code=123456`.
  static String? extract(Uri uri) {
    final segs = uri.pathSegments;
    final i = segs.indexOf('join');
    if (i >= 0 && i + 1 < segs.length) return normalize(segs[i + 1]);
    return normalize(uri.queryParameters['code']);
  }

  /// QR / ulashish havolasi: ommaviy domen bo‘lsa `https://<domen>/join/<kod>`,
  /// aks holda ilova sxemasi `forensicexpert://app/join/<kod>`.
  static Uri joinLink(String code, {Uri? publicBase}) {
    if (publicBase != null) {
      final path = publicBase.path.endsWith('/')
          ? publicBase.path
          : '${publicBase.path}/';
      return publicBase.replace(path: '${path}join/$code');
    }
    return Uri(scheme: 'forensicexpert', host: 'app', path: '/join/$code');
  }

  /// QR ichidagi matndan (havola yoki oddiy 6 raqam) kod.
  static String? fromScanned(String? text) {
    if (text == null) return null;
    final t = text.trim();
    final direct = normalize(t);
    if (direct != null) return direct;
    final uri = Uri.tryParse(t);
    return uri == null ? null : extract(uri);
  }

  /// Joylangan istalgan matndan kod: havola, taklif matni («Kod: 123 456»)
  /// yoki oddiy raqam. Topilmasa `null`.
  static String? fromText(String? text) {
    if (text == null) return null;
    final direct = fromScanned(text);
    if (direct != null) return direct;
    for (final word in text.split(RegExp(r'\s+'))) {
      final uri = Uri.tryParse(word.trim());
      final fromLink = uri == null ? null : extract(uri);
      if (fromLink != null) return fromLink;
    }
    final m = RegExp(r'(?<!\d)(\d{3})[\s-]?(\d{3})(?!\d)').firstMatch(text);
    return m == null ? null : '${m.group(1)}${m.group(2)}';
  }
}

enum NicknameCheck { ok, length, chars, blocked }

/// Laqab qoidalari (server `private.class_nick_check` nusxasi — ro‘yxatlar
/// bir xil; migratsiya 20261018040000_class_quiz_fixes.sql).
abstract final class ClassNickname {
  /// Istalgan joyda (so‘zlar orasida yashirilsa ham) ushlanadi.
  static const _stems = [
    'fuck', 'shit', 'bitch', 'cunt', 'nigger', 'nigga', 'whore', 'slut',
    'pussy', 'asshole', 'blyat', 'blyad', 'pidor', 'pidar', 'mudak', 'pizd',
    'gandon', 'jalab', 'qanjiq', 'onangni', 'sikaman', 'сука',
    'блядь', 'бляд', 'пизд', 'хуй', 'мудак', 'пидор', 'гандон', 'долбоеб',
    'долбоёб', //
  ];

  /// Faqat so‘z BOSHIDA (Глеба, Себастьян, Ebaldiyev o‘tadi).
  static const _prefixes = [
    'ебат', 'ебал', 'ебан', 'ебло', 'еблан', 'ебуч', 'ебну', 'ёбан', 'ёбну',
    'заеб', 'заёб', 'уеба', 'уебо', 'уёб', 'yebat', 'yeban', 'yebal', 'zaeb',
    'zayeb', //
  ];

  /// Faqat to‘liq so‘z.
  static const _exact = [
    'sik', 'huy', 'xuy', 'hui', 'suka', 'sex', 'ebal', 'ebat', 'eban',
    'ebalo', 'еб', 'ёб', //
  ];

  static String _norm(String s) => s
      .toLowerCase()
      .replaceAll('0', 'o')
      .replaceAll('1', 'i')
      .replaceAll('3', 'e')
      .replaceAll('4', 'a')
      .replaceAll('5', 's')
      .replaceAll('@', 'a')
      .replaceAll(r'$', 's')
      .replaceAll(RegExp(r'[^\p{L}]', unicode: true), '');

  /// iPhone klaviaturasi (Smart Punctuation) `'` ni `’` ga almashtiradi;
  /// o‘zbekcha oʻ/gʻ ham turli belgilar bilan yoziladi. Hammasi oddiy `'`
  /// ga keltiriladi (server `private.nick_fold` bilan bir xil ro‘yxat:
  /// ’ ‘ ʻ ʼ ` ´ ′). Aks holda «G’ayrat» rad etilardi.
  static const apostrophes = '\u2019\u2018\u02BB\u02BC`\u00B4\u2032';
  static final _apos = RegExp('[$apostrophes]');

  static String fold(String raw) => raw.replaceAll(_apos, "'");

  /// Apostroflarni `'` ga keltiradi, ketma-ket bo‘shliqlarni bittaga,
  /// chetlarini kesadi.
  static String clean(String raw) =>
      fold(raw).trim().replaceAll(RegExp(r'\s+'), ' ');

  static NicknameCheck check(String raw) {
    final t = clean(raw);
    final len = t.runes.length;
    if (len < ClassQuizRules.nickMin || len > ClassQuizRules.nickMax) {
      return NicknameCheck.length;
    }
    if (RegExp(r'[\u0000-\u001F\u007F<>{}\[\]\\|^~;"`]').hasMatch(t)) {
      return NicknameCheck.chars;
    }
    if (!RegExp(r"[^\s_.'’-]").hasMatch(t)) return NicknameCheck.chars;
    final norm = _norm(t);
    for (final s in _stems) {
      if (norm.contains(s)) return NicknameCheck.blocked;
    }
    // So‘zlar: tinish belgilari bo‘yicha VA faqat bo‘shliq bo‘yicha (е.б.а.т.ь).
    final lower = t.toLowerCase();
    final words = [
      ...lower.split(RegExp(r'[^\p{L}0-9@$]+', unicode: true)),
      ...lower.split(RegExp(r'\s+')),
    ];
    for (final w in words) {
      final nw = _norm(w);
      if (nw.isEmpty) continue;
      if (_exact.contains(nw)) return NicknameCheck.blocked;
      for (final p in _prefixes) {
        if (nw.startsWith(p)) return NicknameCheck.blocked;
      }
    }
    return NicknameCheck.ok;
  }

  /// Profil to‘liq ismidan laqab taklifi (akkauntga kirgan talaba uchun
  /// avtomatik to‘ldirish). 20 belgidan oshsa: «Ism F.» ko‘rinishi, aks holda
  /// qirqiladi. Laqab filtridan o‘tmasa yoki bo‘sh bo‘lsa — `''` (maydon
  /// bo‘sh qoladi, talaba o‘zi yozadi).
  static String fromProfileName(String? fullName) {
    final t = clean(fullName ?? '');
    if (t.isEmpty) return '';
    var cand = t;
    if (cand.runes.length > ClassQuizRules.nickMax) {
      final words = t.split(' ');
      cand = words.length > 1
          ? '${words.first} ${String.fromCharCode(words[1].runes.first)}.'
          : t;
      if (cand.runes.length > ClassQuizRules.nickMax) {
        cand = String.fromCharCodes(cand.runes.take(ClassQuizRules.nickMax));
      }
      cand = cand.trim();
    }
    return check(cand) == NicknameCheck.ok ? cand : '';
  }

  /// Takror laqabga 2, 3, … qo‘shadi (20 belgidan oshmaydi).
  static String dedupe(String nick, Iterable<String> taken) {
    final lower = {for (final t in taken) t.toLowerCase()};
    final base = clean(nick);
    var cand = base;
    var n = 1;
    while (lower.contains(cand.toLowerCase())) {
      n++;
      final suffix = '$n';
      final chars = base.runes.toList();
      final keep = ClassQuizRules.nickMax - suffix.length;
      cand =
          '${String.fromCharCodes(chars.length > keep ? chars.sublist(0, keep) : chars)}$suffix';
    }
    return cand;
  }
}

/// Ball hisoblash (server `private.class_points` bilan bir xil).
abstract final class ClassScoring {
  static int points({
    required bool correct,
    required int elapsedMs,
    required int limitMs,
  }) {
    if (!correct || limitMs <= 0) return 0;
    final e = elapsedMs.clamp(0, limitMs);
    return ClassQuizRules.basePoints +
        (ClassQuizRules.speedBonus * (limitMs - e)) ~/ limitMs;
  }
}

// Variantlar tartibi: serverdagi (sessiya yaratilganda bir marta
// aralashtirilgan) tartib — proyektor va talaba telefonlarida bir xil, A/B/C/D
// harflari ikkala ekranda bir xil variantni bildiradi.

enum ClassSessionStatus {
  lobby,
  running,
  finished;

  static ClassSessionStatus parse(Object? v) => switch (v) {
    'running' => running,
    'finished' => finished,
    _ => lobby,
  };
}

/// Hozirgi savol fazasi.
enum ClassPhase {
  lobby,
  open,
  closed,
  finished;

  static ClassPhase parse(Object? v) => switch (v) {
    'open' => open,
    'closed' => closed,
    'finished' => finished,
    _ => lobby,
  };
}

/// Xizmatning kutilgan xato turlari (server `error` kodlari + tarmoq).
enum ClassFailure {
  notConfigured,
  notSignedIn,
  offline,
  server,
  forbidden,
  badCode,
  notFound,
  rateLimited,
  ownSession,
  finished,
  kicked,
  alreadyStarted,
  full,
  nickLength,
  nickChars,
  nickBlocked,
  invalidSettings,
  tooManySessions,
  notEnoughQuestions,
  badState,
  noParticipants,
  notCurrent,
  timeOver,
  alreadyAnswered,
  badOption,
  notFinished,
  notClosed,
  badReason;

  static ClassFailure fromServer(Object? code) => switch (code) {
    'bad_code' => badCode,
    'not_found' => notFound,
    'rate_limited' => rateLimited,
    'own_session' => ownSession,
    'finished' => finished,
    'kicked' => kicked,
    'already_started' => alreadyStarted,
    'full' => full,
    'nick_length' => nickLength,
    'nick_chars' => nickChars,
    'nick_blocked' => nickBlocked,
    'invalid_settings' => invalidSettings,
    'too_many_sessions' => tooManySessions,
    'not_enough_questions' => notEnoughQuestions,
    'bad_state' => badState,
    'no_participants' => noParticipants,
    'not_current' => notCurrent,
    'time_over' => timeOver,
    'already_answered' => alreadyAnswered,
    'bad_option' => badOption,
    'not_finished' => notFinished,
    'not_closed' => notClosed,
    'bad_reason' => badReason,
    _ => server,
  };
}

/// Muvaffaqiyat qiymati yoki aniq xato.
@immutable
class ClassResult<T> {
  const ClassResult.ok(T this.value) : failure = null;
  const ClassResult.fail(ClassFailure this.failure) : value = null;

  final T? value;
  final ClassFailure? failure;

  bool get ok => failure == null;
}

int _int(Object? v, [int d = 0]) => v is num ? v.toInt() : d;
String _str(Object? v, [String d = '']) => v is String ? v : d;
List<Object?> _list(Object? v) => v is List ? v : const [];
Map<String, Object?> _map(Object? v) =>
    v is Map ? v.cast<String, Object?>() : const {};

/// Ustoz ko‘ra oladigan mavzu (savol banki).
@immutable
class ClassTopic {
  const ClassTopic({
    required this.id,
    required this.title,
    required this.count,
    this.isDemo = false,
    this.course = '',
  });

  factory ClassTopic.fromJson(Map<String, Object?> j) => ClassTopic(
    id: _str(j['topic_id']),
    title: _str(j['title']),
    count: _int(j['count']),
    isDemo: j['is_demo'] == true,
    course: _str(j['course']),
  );

  final String id;
  final String title;
  final int count;
  final bool isDemo;

  /// Dars kursi (server `lesson_topics.course`); bo‘sh — noma’lum.
  final String course;
}

@immutable
class ClassSessionInfo {
  const ClassSessionInfo({
    required this.id,
    required this.code,
    required this.topicId,
    required this.topicTitle,
    required this.status,
    required this.currentIndex,
    required this.total,
    required this.studentLimit,
    required this.seconds,
    this.joined,
    this.pace = ClassPace.host,
  });

  factory ClassSessionInfo.fromJson(Map<String, Object?> j) => ClassSessionInfo(
    id: _str(j['id']),
    code: _str(j['code']),
    topicId: _str(j['topic_id']),
    topicTitle: _str(j['topic_title']),
    status: ClassSessionStatus.parse(j['status']),
    currentIndex: _int(j['current_index'], -1),
    total: _int(j['total']),
    studentLimit: _int(j['student_limit']),
    seconds: _int(j['seconds'], ClassQuizRules.defaultSeconds),
    joined: j['joined'] == null ? null : _int(j['joined']),
    pace: ClassPace.parse(j['pace']),
  );

  final String id;
  final String code;
  final String topicId;
  final String topicTitle;
  final ClassSessionStatus status;
  final int currentIndex;
  final int total;
  final int studentLimit;
  final int seconds;
  final int? joined;

  /// Eski serverda maydon yo‘q — [ClassPace.host].
  final ClassPace pace;

  bool get isSelfPaced => pace == ClassPace.self;
}

@immutable
class ClassOption {
  const ClassOption({required this.id, required this.text, this.count});

  factory ClassOption.fromJson(Map<String, Object?> j) => ClassOption(
    id: _str(j['id']),
    text: _str(j['text']),
    count: j['count'] == null ? null : _int(j['count']),
  );

  final String id;
  final String text;

  /// Faqat ustoz paneli: shu variantni tanlaganlar soni.
  final int? count;
}

/// Savol manbasi (muallif, sarlavha, bet).
@immutable
class ClassSource {
  const ClassSource({
    this.author = '',
    this.title = '',
    this.page = '',
    this.translation = '',
    this.checked = false,
  });

  factory ClassSource.fromJson(Map<String, Object?> j) => ClassSource(
    author: _str(j['author']),
    title: _str(j['title']),
    page: _str(j['page']),
    translation: _str(j['translation']),
    checked: _checked(j['checked']),
  );

  static bool _checked(Object? v) =>
      v is Map && _str(v['method']) == 'source_compare';

  final String author;
  final String title;

  /// Bet raqami («263», «12–23») yoki joy («I bob, 1.4»). «-», «--» — bo‘sh.
  final String page;

  /// Savol matni tarjima holati: bo‘sh — asl til; `auto_unreviewed` —
  /// avtomatik tarjima, tekshirilmagan (ilova shu belgini ko‘rsatadi).
  final String translation;

  /// Savol javobi ko‘rsatilgan manba bilan solishtirilgan (`source.checked`).
  /// Bu ekspert tasdig‘i EMAS — faqat manba bilan solishtirish belgisi.
  final bool checked;

  bool get isEmpty => author.isEmpty && title.isEmpty;

  bool get isMachineTranslation => translation == 'auto_unreviewed';

  /// Tarjimasi hali yo‘q: matn asl (o‘zbekcha), «tarjima kutilmoqda».
  bool get isTranslationPending => translation == 'pending';

  /// Bet/joy bo‘sh yoki faqat chiziqcha bo‘lsa `null`.
  String? get cleanPage {
    final p = page.trim();
    return RegExp(r'^[\s\-–—.]*$').hasMatch(p) ? null : p;
  }

  /// Faqat raqamlar va oraliq («263», «12–23», «85, 86») — «-bet» qo‘shiladi;
  /// aks holda («I bob, 1.4») joy sifatida o‘zicha ko‘rsatiladi.
  bool get pageIsNumeric =>
      cleanPage != null && RegExp(r'^[0-9][0-9\s,–—\-]*$').hasMatch(cleanPage!);
}

/// Talabaga ko‘rinadigan savol (to‘g‘ri javobsiz).
@immutable
class ClassQuestionView {
  const ClassQuestionView({
    required this.index,
    required this.text,
    required this.options,
  });

  factory ClassQuestionView.fromJson(Map<String, Object?> j) =>
      ClassQuestionView(
        index: _int(j['index']),
        text: _str(j['text']),
        options: [
          for (final o in _list(j['options'])) ClassOption.fromJson(_map(o)),
        ],
      );

  final int index;
  final String text;
  final List<ClassOption> options;
}

/// Vaqt tugagach ochiladigan to‘g‘ri javob.
@immutable
class ClassReveal {
  const ClassReveal({
    required this.correctOption,
    required this.explanation,
    required this.myCorrect,
    required this.myPoints,
  });

  factory ClassReveal.fromJson(Map<String, Object?> j) => ClassReveal(
    correctOption: _str(j['correct_option']),
    explanation: _str(j['explanation']),
    myCorrect: j['my_correct'] == true,
    myPoints: _int(j['my_points']),
  );

  final String correctOption;
  final String explanation;
  final bool myCorrect;
  final int myPoints;
}

@immutable
class ClassLeaderRow {
  const ClassLeaderRow({
    required this.participantId,
    required this.nickname,
    required this.score,
    required this.correct,
    required this.rank,
    this.avgMs,
  });

  factory ClassLeaderRow.fromJson(Map<String, Object?> j) => ClassLeaderRow(
    participantId: _str(j['participant_id']),
    nickname: _str(j['nickname']),
    score: _int(j['score']),
    correct: _int(j['correct']),
    rank: _int(j['rank']),
    avgMs: j['avg_ms'] is num && (j['avg_ms'] as num) > 0
        ? (j['avg_ms'] as num).toInt()
        : null,
  );

  /// To‘g‘ri javoblar bo‘yicha o‘rtacha vaqt (ms); server yubormasa — `null`.
  final int? avgMs;

  final String participantId;
  final String nickname;
  final int score;
  final int correct;
  final int rank;
}

/// Self rejimda talabaning o‘z bosqichi: [ready] — birinchi savolni hali
/// ochmagan; [question] — o‘z savoli (ochiq yoki yopilgan); [done] — o‘z
/// savollarini tugatgan.
enum ClassSelfStage {
  ready,
  question,
  done;

  static ClassSelfStage? parse(Object? v) => switch (v) {
    'ready' => ready,
    'question' => question,
    'done' => done,
    _ => null,
  };
}

/// Talaba uchun sessiya holati (polling natijasi).
@immutable
class ClassStudentState {
  const ClassStudentState({
    required this.session,
    required this.phase,
    required this.remainingMs,
    required this.joined,
    required this.nickname,
    required this.score,
    required this.correct,
    this.kicked = false,
    this.rank,
    this.question,
    this.myOption,
    this.reveal,
    this.leaderboard = const [],
    this.selfStage,
    this.position = 0,
    this.answeredCount = 0,
  });

  factory ClassStudentState.fromJson(Map<String, Object?> j) {
    final kicked = j['kicked'] == true;
    return ClassStudentState(
      session: ClassSessionInfo.fromJson(j),
      kicked: kicked,
      phase: ClassPhase.parse(j['phase']),
      remainingMs: _int(j['remaining_ms']),
      joined: _int(j['joined']),
      nickname: _str(j['nickname']),
      score: _int(j['score']),
      correct: _int(j['correct']),
      rank: j['rank'] == null ? null : _int(j['rank']),
      question: j['question'] is Map
          ? ClassQuestionView.fromJson(_map(j['question']))
          : null,
      myOption: j['my_option'] as String?,
      reveal: j['reveal'] is Map
          ? ClassReveal.fromJson(_map(j['reveal']))
          : null,
      leaderboard: [
        for (final r in _list(j['leaderboard']))
          ClassLeaderRow.fromJson(_map(r)),
      ],
      selfStage: ClassSelfStage.parse(j['stage']),
      position: _int(j['my_position']),
      answeredCount: _int(j['answered']),
    );
  }

  /// Faqat self rejimda (ketayotgan sessiya): talabaning o‘z bosqichi.
  final ClassSelfStage? selfStage;

  /// Self rejim: o‘z tartibimdagi hozirgi savol o‘rni (0 dan).
  final int position;

  /// Self rejim: shu paytgacha berilgan javoblar soni.
  final int answeredCount;

  final ClassSessionInfo session;
  final bool kicked;
  final ClassPhase phase;
  final int remainingMs;
  final int joined;
  final String nickname;
  final int score;
  final int correct;
  final int? rank;
  final ClassQuestionView? question;

  /// Shu savolga o‘zim tanlagan variant (bo‘lsa).
  final String? myOption;

  /// Faqat vaqt tugagach (server qaror qiladi).
  final ClassReveal? reveal;
  final List<ClassLeaderRow> leaderboard;

  ClassSessionStatus get status => session.status;
}

/// Qo‘shilish natijasi.
@immutable
class ClassJoinInfo {
  const ClassJoinInfo({
    required this.sessionId,
    required this.participantId,
    required this.nickname,
    required this.session,
  });

  factory ClassJoinInfo.fromJson(Map<String, Object?> j) => ClassJoinInfo(
    sessionId: _str(j['session_id']),
    participantId: _str(j['participant_id']),
    nickname: _str(j['nickname']),
    session: ClassSessionInfo.fromJson(_map(j['session'])),
  );

  final String sessionId;
  final String participantId;
  final String nickname;
  final ClassSessionInfo session;
}

@immutable
class ClassParticipant {
  const ClassParticipant({
    required this.id,
    required this.nickname,
    this.answered = false,
    this.progress,
    this.leaveCount = 0,
    this.lastLeftAt,
  });

  /// `answered` — server qo‘shgan maydon (joriy savolga javob berdimi); eski
  /// serverda yo‘q bo‘lsa `false`. Qaysi variant tanlangani hech qachon kelmaydi.
  factory ClassParticipant.fromJson(Map<String, Object?> j) => ClassParticipant(
    id: _str(j['id']),
    nickname: _str(j['nickname']),
    answered: j['answered'] == true,
    progress: j.containsKey('position') ? ClassSelfProgress.fromJson(j) : null,
    leaveCount: _int(j['leave_count']),
    lastLeftAt: j['last_left_at'] is String
        ? DateTime.tryParse(j['last_left_at']! as String)
        : null,
  );

  final String id;
  final String nickname;
  final bool answered;

  /// Test paytida ilovadan chiqqan marta (server sanaydi; eski serverda 0).
  /// Faqat ustozga ishora — ballga ta’sir qilmaydi.
  final int leaveCount;
  final DateTime? lastLeftAt;

  /// Faqat self rejimda (ustoz doskasi): talabaning progressi.
  final ClassSelfProgress? progress;
}

/// Self rejimda ustozga ko‘rinadigan talaba progressi (faqat sonlar; qaysi
/// variant tanlangani yo‘q).
@immutable
class ClassSelfProgress {
  const ClassSelfProgress({
    required this.position,
    required this.answered,
    required this.correct,
    required this.done,
  });

  factory ClassSelfProgress.fromJson(Map<String, Object?> j) =>
      ClassSelfProgress(
        position: _int(j['position']),
        answered: _int(j['answered_count']),
        correct: _int(j['correct_count']),
        done: j['done'] == true,
      );

  /// Nechanchi savolda (1 dan; 0 — hali boshlamagan).
  final int position;
  final int answered;
  final int correct;
  final bool done;

  bool get started => position > 0;
}

/// Ustozning joriy savol bo‘yicha jonli ko‘rinishi (to‘g‘ri javob bilan).
@immutable
class ClassCurrentQuestion {
  const ClassCurrentQuestion({
    required this.index,
    required this.text,
    required this.options,
    required this.correctOption,
    required this.explanation,
    required this.answered,
    required this.correctCount,
  });

  factory ClassCurrentQuestion.fromJson(Map<String, Object?> j) =>
      ClassCurrentQuestion(
        index: _int(j['index']),
        text: _str(j['text']),
        options: [
          for (final o in _list(j['options'])) ClassOption.fromJson(_map(o)),
        ],
        correctOption: _str(j['correct_option']),
        explanation: _str(j['explanation']),
        answered: _int(j['answered']),
        correctCount: _int(j['correct_count']),
      );

  final int index;
  final String text;
  final List<ClassOption> options;
  final String correctOption;
  final String explanation;
  final int answered;
  final int correctCount;

  /// To‘g‘ri javoblar ulushi (0–100); javob yo‘q bo‘lsa `null`.
  int? get correctPct =>
      answered == 0 ? null : (100 * correctCount / answered).round();
}

@immutable
class ClassHardQuestion {
  const ClassHardQuestion({
    required this.index,
    required this.text,
    required this.answered,
    required this.correctPct,
  });

  factory ClassHardQuestion.fromJson(Map<String, Object?> j) =>
      ClassHardQuestion(
        index: _int(j['index']),
        text: _str(j['text']),
        answered: _int(j['answered']),
        correctPct: _int(j['correct_pct']),
      );

  final int index;
  final String text;
  final int answered;
  final int correctPct;
}

/// «Qiyin savol» muhokama varaqasi uchun tafsilot (faqat ustoz, sessiya
/// tugagach; `class_hardest_detail`). Talaba ismlari yo‘q — faqat jami.
@immutable
class ClassHardDetail {
  const ClassHardDetail({
    required this.index,
    required this.text,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.source,
    required this.answered,
    required this.correctPct,
    this.optionCounts = const [],
  });

  factory ClassHardDetail.fromJson(Map<String, Object?> j) {
    final opts = [
      for (final o in _list(j['options'])) o is Map ? _str(o['text']) : _str(o),
    ];
    return ClassHardDetail(
      index: _int(j['index']),
      text: _str(j['text']),
      options: opts,
      correctIndex: _int(j['correct_index']),
      explanation: _str(j['explanation']),
      source: ClassSource.fromJson(_map(j['source'])),
      answered: _int(j['answered']),
      correctPct: _int(j['correct_pct']),
      optionCounts: [for (final c in _list(j['option_counts'])) _int(c)],
    );
  }

  final int index;
  final String text;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final ClassSource source;
  final int answered;

  /// To‘g‘ri javoblar foizi (0–100).
  final int correctPct;

  /// Har variantni tanlaganlar soni (A, B, C, D); bo‘lmasa — bo‘sh.
  final List<int> optionCounts;

  /// Xato foizi (talabalar nomsiz, faqat umumiy).
  int get wrongPct => (100 - correctPct).clamp(0, 100);
}

@immutable
class ClassDashboard {
  const ClassDashboard({
    required this.session,
    required this.phase,
    required this.remainingMs,
    required this.joined,
    required this.participants,
    required this.leaderboard,
    required this.hardest,
    required this.reports,
    this.current,
    this.revealed = false,
    this.selfOpened = 0,
    this.selfDone = 0,
  });

  /// `revealed` — server (private.class_revealed): vaqt tugab, javob qabul
  /// qilish imtiyozi ham o‘tgan. Eski serverda maydon yo‘q bo‘lsa — avvalgi
  /// qoida (faza `open` emas).
  factory ClassDashboard.fromJson(Map<String, Object?> j) => ClassDashboard(
    session: ClassSessionInfo.fromJson(j),
    phase: ClassPhase.parse(j['phase']),
    revealed: j.containsKey('revealed')
        ? j['revealed'] == true
        : const {'closed', 'finished'}.contains(j['phase']),
    remainingMs: _int(j['remaining_ms']),
    joined: _int(j['joined']),
    participants: [
      for (final p in _list(j['participants']))
        ClassParticipant.fromJson(_map(p)),
    ],
    leaderboard: [
      for (final r in _list(j['leaderboard'])) ClassLeaderRow.fromJson(_map(r)),
    ],
    hardest: [
      for (final h in _list(j['hardest'])) ClassHardQuestion.fromJson(_map(h)),
    ],
    reports: _int(j['reports']),
    current: j['current'] is Map
        ? ClassCurrentQuestion.fromJson(_map(j['current']))
        : null,
    selfOpened: _int(_map(j['self'])['opened']),
    selfDone: _int(_map(j['self'])['done']),
  );

  /// Self rejim: birinchi savolni ochgan / hammasini tugatgan talabalar soni.
  final int selfOpened;
  final int selfDone;

  final ClassSessionInfo session;
  final ClassPhase phase;
  final int remainingMs;
  final int joined;
  final List<ClassParticipant> participants;
  final List<ClassLeaderRow> leaderboard;
  final List<ClassHardQuestion> hardest;
  final int reports;
  final ClassCurrentQuestion? current;

  /// Proyektor to‘g‘ri javob, sonlar va izohni faqat shunda ko‘rsatadi.
  final bool revealed;

  /// Ishtirokchining ilovadan chiqish soni (reyting qatori `participantId`
  /// bo‘yicha); topilmasa 0.
  int leaveCountOf(String participantId) =>
      participants
          .where((p) => p.id == participantId)
          .firstOrNull
          ?.leaveCount ??
      0;
}

/// Tugagach talabaning bitta savol bo‘yicha natijasi.
@immutable
class ClassResultItem {
  const ClassResultItem({
    required this.index,
    required this.text,
    required this.options,
    required this.myOption,
    required this.correctOption,
    required this.isCorrect,
    required this.points,
    required this.explanation,
    required this.source,
  });

  factory ClassResultItem.fromJson(Map<String, Object?> j) => ClassResultItem(
    index: _int(j['index']),
    text: _str(j['text']),
    options: [
      for (final o in _list(j['options'])) ClassOption.fromJson(_map(o)),
    ],
    myOption: j['my_option'] as String?,
    correctOption: _str(j['correct_option']),
    isCorrect: j['is_correct'] == true,
    points: _int(j['points']),
    explanation: _str(j['explanation']),
    source: ClassSource.fromJson(_map(j['source'])),
  );

  final int index;
  final String text;
  final List<ClassOption> options;
  final String? myOption;
  final String correctOption;
  final bool isCorrect;
  final int points;
  final String explanation;
  final ClassSource source;

  bool get unanswered => myOption == null;
}

@immutable
class ClassMyResults {
  const ClassMyResults({
    required this.nickname,
    required this.score,
    required this.correct,
    required this.total,
    required this.participants,
    required this.items,
    this.rank,
  });

  factory ClassMyResults.fromJson(Map<String, Object?> j) => ClassMyResults(
    nickname: _str(j['nickname']),
    score: _int(j['score']),
    rank: j['rank'] == null ? null : _int(j['rank']),
    correct: _int(j['correct']),
    total: _int(j['total']),
    participants: _int(j['participants']),
    items: [
      for (final i in _list(j['items'])) ClassResultItem.fromJson(_map(i)),
    ],
  );

  final String nickname;
  final int score;
  final int? rank;
  final int correct;
  final int total;
  final int participants;
  final List<ClassResultItem> items;

  /// Xato yoki javobsiz savollar (tushuntirish va manba shu yerda ko‘rsatiladi).
  List<ClassResultItem> get mistakes => [
    for (final i in items)
      if (!i.isCorrect) i,
  ];
}

@immutable
class ClassExportRow {
  const ClassExportRow({
    required this.nickname,
    required this.score,
    required this.correct,
    required this.answered,
    required this.avgMs,
    required this.rank,
  });

  factory ClassExportRow.fromJson(Map<String, Object?> j) => ClassExportRow(
    nickname: _str(j['nickname']),
    score: _int(j['score']),
    correct: _int(j['correct']),
    answered: _int(j['answered']),
    avgMs: _int(j['avg_ms']),
    rank: _int(j['rank']),
  );

  final String nickname;
  final int score;
  final int correct;
  final int answered;
  final int avgMs;
  final int rank;
}

@immutable
class ClassExport {
  const ClassExport({required this.session, required this.rows});

  factory ClassExport.fromJson(Map<String, Object?> j) => ClassExport(
    session: ClassSessionInfo.fromJson(_map(j['session'])),
    rows: [for (final r in _list(j['rows'])) ClassExportRow.fromJson(_map(r))],
  );

  final ClassSessionInfo session;
  final List<ClassExportRow> rows;
}

/// Ustoz hisobi: rol serverdan.
@immutable
class ClassQuizMe {
  const ClassQuizMe({this.isTeacher = false});

  factory ClassQuizMe.fromJson(Map<String, Object?> j) =>
      ClassQuizMe(isTeacher: j['is_teacher'] == true);

  final bool isTeacher;
}

/// Natijani CSV’ga aylantirish. Ustunlar: laqab, ball, to‘g‘ri soni, javoblar
/// vaqti (o‘rtacha, soniya). Sarlavhalar ASCII; fayl nomi ham ASCII.
abstract final class ClassResultsCsv {
  static const header = 'laqab,ball,togri_soni,javob_vaqti_s';

  /// Formula in’yeksiyasidan himoya (`=`, `+`, `-`, `@`, tab, CR).
  static String cell(String v) {
    var s = v.replaceAll('\r', ' ').replaceAll('\n', ' ');
    if (s.isNotEmpty && '=+-@\t'.contains(s[0])) s = "'$s";
    if (s.contains(',') || s.contains('"') || s.contains(';')) {
      s = '"${s.replaceAll('"', '""')}"';
    }
    return s;
  }

  static String build(List<ClassExportRow> rows) {
    final b = StringBuffer('$header\r\n');
    for (final r in rows) {
      final secs = (r.avgMs / 1000).toStringAsFixed(1);
      b.write('${cell(r.nickname)},${r.score},${r.correct},$secs\r\n');
    }
    return b.toString();
  }

  /// `guruh_test_123456_2026-10-17.csv` — faqat ASCII.
  static String fileName(String code, DateTime date) {
    final d = date.toIso8601String().substring(0, 10);
    final c = code.replaceAll(RegExp(r'[^0-9]'), '');
    return 'guruh_test_${c.isEmpty ? 'sessiya' : c}_$d.csv';
  }
}
