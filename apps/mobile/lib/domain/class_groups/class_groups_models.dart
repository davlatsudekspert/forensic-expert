/// «Ustoz–talaba testi» — guruhlar va asinxron mavzu testlari (domen).
///
/// Qoidalar serverda (`supabase/migrations/20261018050000_class_groups.sql`).
/// Bu yerdagi sof funksiyalar (kod, taxallus, vaqt ko‘rinishi) server bilan
/// bir xil natija berishi kerak va testlar bilan qo‘riqlanadi
/// (`test/guards/class_groups_guard_test.dart`).
///
/// Xavfsizlik: to‘g‘ri javoblar talabaga ochilishdan oldin hech qachon
/// kelmaydi ([GroupTestResult.revealed]); ustozga talabaning faqat taxallusi
/// ko‘rinadi.
library;

import 'package:flutter/foundation.dart';

import '../class_quiz/class_quiz_models.dart';

export '../class_quiz/class_quiz_models.dart'
    show ClassNickname, ClassSource, NicknameCheck;

/// Chegaralar (server CHECK’lari bilan bir xil).
abstract final class GroupRules {
  static const int maxMembers = 200;
  static const int minQuestions = 1;

  /// Tez tanlov tugmalari ko‘pi bilan 50; «Boshqa…» bilan hovuzgacha (200).
  static const int maxQuestions = 200;
  static const int presetMaxQuestions = 50;

  /// «Vaqt chegarasi» tez tanlovlari (daqiqa); standart — 10.
  static const List<int> timeLimitPresets = [10, 15, 20, 30, 45, 60];
  static const int defaultTimeLimit = 10;

  /// «Test qancha vaqt ochiq turadi» (kun); standart — 1 kun.
  static const List<int> openDaysPresets = [1, 3, 7];
  static const int defaultOpenDays = 1;
  static const int minTimeLimit = 1;
  static const int maxTimeLimit = 180;
  static const int graceSeconds = 30;
  static const int nameMin = 2;
  static const int nameMax = 60;
  static const int codeLength = 8;

  /// Teskari sanoq faqat oxirgi soatda (vaqt chegarasi bo‘lmasa).
  static const Duration countdownWindow = Duration(hours: 1);
}

enum GroupCodeCheck { ok, ambiguous, bad }

/// Guruh taklif kodi: 8 belgi, alifboda **0, O, 1, I, L yo‘q** (qo‘lda
/// adashtirilmasin). Server: `private.group_code_check`.
abstract final class GroupCode {
  static const alphabet = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
  static final _ok = RegExp(r'^[A-HJKMNP-Z2-9]{8}$');
  static final _word = RegExp(r'^[A-Z0-9]{8}$');
  static final _ambiguous = RegExp('[01OIL]');

  /// Katta harf; bo‘shliq va chiziqcha olib tashlanadi.
  static String clean(String? raw) =>
      (raw ?? '').replaceAll(RegExp(r'[\s-]'), '').toUpperCase();

  static GroupCodeCheck check(String? raw) {
    final c = clean(raw);
    if (_ok.hasMatch(c)) return GroupCodeCheck.ok;
    if (_word.hasMatch(c) && _ambiguous.hasMatch(c)) {
      return GroupCodeCheck.ambiguous;
    }
    return GroupCodeCheck.bad;
  }

  /// To‘g‘ri kod yoki `null`.
  static String? normalize(String? raw) =>
      check(raw) == GroupCodeCheck.ok ? clean(raw) : null;

  /// O‘qish uchun: `ABCD 2345`.
  static String display(String code) =>
      code.length == 8 ? '${code.substring(0, 4)} ${code.substring(4)}' : code;

  /// Hammaga bir xil QR / havola: `forensicexpert://app/g/<KOD>[?a=<test>]`.
  static Uri link(String code, {String? assignmentId}) => Uri(
    scheme: 'forensicexpert',
    host: 'app',
    path: '/g/$code',
    queryParameters: assignmentId == null ? null : {'a': assignmentId},
  );

  /// Havoladan (`…/g/<kod>?a=…`, `?code=…`) kod va topshiriq.
  static GroupInvite? fromUri(Uri uri) {
    final segs = uri.pathSegments;
    final i = segs.indexOf('g');
    final raw = i >= 0 && i + 1 < segs.length
        ? segs[i + 1]
        : uri.queryParameters['code'];
    final code = normalize(raw);
    if (code == null) return null;
    return GroupInvite(
      code: code,
      assignmentId: _uuid(uri.queryParameters['a']),
    );
  }

  /// QR yoki joylangan istalgan matndan (havola, «Kod: ABCD 2345», oddiy kod).
  static GroupInvite? fromText(String? text) {
    if (text == null) return null;
    final t = text.trim();
    final direct = normalize(t);
    if (direct != null) return GroupInvite(code: direct);
    for (final word in t.split(RegExp(r'\s+'))) {
      final uri = Uri.tryParse(word);
      if (uri != null && uri.pathSegments.contains('g')) {
        final inv = fromUri(uri);
        if (inv != null) return inv;
      }
    }
    final m = RegExp(
      r'(?<![A-Za-z0-9])([A-Za-z2-9]{4})[\s-]?([A-Za-z2-9]{4})(?![A-Za-z0-9])',
    ).firstMatch(t);
    final code = m == null ? null : normalize('${m.group(1)}${m.group(2)}');
    return code == null ? null : GroupInvite(code: code);
  }

  static String? _uuid(String? v) =>
      v != null &&
          RegExp(
            r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
          ).hasMatch(v)
      ? v
      : null;
}

/// Taklif: guruh kodi va (ixtiyoriy) shu QR bilan ochiladigan test.
@immutable
class GroupInvite {
  const GroupInvite({required this.code, this.assignmentId});

  final String code;
  final String? assignmentId;

  @override
  bool operator ==(Object other) =>
      other is GroupInvite &&
      other.code == code &&
      other.assignmentId == assignmentId;

  @override
  int get hashCode => Object.hash(code, assignmentId);
}

/// Xizmatning kutilgan xatolari (server `error` kodlari + tarmoq).
enum GroupFailure {
  notConfigured,
  notSignedIn,
  offline,
  server,
  forbidden,
  rateLimited,
  badCode,
  codeAmbiguous,
  notFound,
  nicknameRequired,
  groupFull,
  nickLength,
  nickChars,
  nickBlocked,
  nickTaken,
  badName,
  tooManyGroups,
  invalidSettings,
  badDue,
  revealNeedsDue,
  notEnoughQuestions,
  variantPoolSmall,
  tooManyAssignments,
  closed,
  pastDue,
  notStarted,
  alreadySubmitted,
  timeOver,
  notSubmitted;

  static GroupFailure fromServer(Object? code) => switch (code) {
    'rate_limited' => rateLimited,
    'bad_code' => badCode,
    'code_ambiguous' => codeAmbiguous,
    'not_found' => notFound,
    'nickname_required' => nicknameRequired,
    'group_full' => groupFull,
    'nick_length' => nickLength,
    'nick_chars' => nickChars,
    'nick_blocked' => nickBlocked,
    'nick_taken' => nickTaken,
    'bad_name' => badName,
    'too_many_groups' => tooManyGroups,
    'invalid_settings' => invalidSettings,
    'bad_due' => badDue,
    'reveal_needs_due' => revealNeedsDue,
    'not_enough_questions' => notEnoughQuestions,
    'variant_pool_small' => variantPoolSmall,
    'too_many_assignments' => tooManyAssignments,
    'closed' => closed,
    'past_due' => pastDue,
    'not_started' => notStarted,
    'already_submitted' => alreadySubmitted,
    'time_over' => timeOver,
    'not_submitted' => notSubmitted,
    _ => server,
  };

  /// Taxallus maydoniga tegishli xato.
  bool get isNickname =>
      this == nickLength ||
      this == nickChars ||
      this == nickBlocked ||
      this == nickTaken ||
      this == nicknameRequired;

  /// Kod maydoniga tegishli xato.
  bool get isCode =>
      this == badCode || this == codeAmbiguous || this == notFound;
}

/// Muvaffaqiyat qiymati yoki aniq xato.
@immutable
class GroupCall<T> {
  const GroupCall.ok(T this.value) : failure = null, extra = const {};
  const GroupCall.fail(GroupFailure this.failure, [this.extra = const {}])
    : value = null;

  final T? value;
  final GroupFailure? failure;

  /// Xato bilan kelgan qo‘shimcha (masalan `group_name`, `available`).
  final Map<String, Object?> extra;

  bool get ok => failure == null;
}

int _int(Object? v, [int d = 0]) => v is num ? v.toInt() : d;
int? _intOrNull(Object? v) => v is num ? v.toInt() : null;
String _str(Object? v, [String d = '']) => v is String ? v : d;
List<Object?> _list(Object? v) => v is List ? v : const [];
Map<String, Object?> _map(Object? v) =>
    v is Map ? v.cast<String, Object?>() : const {};
DateTime? _date(Object? v) =>
    v is String ? DateTime.tryParse(v)?.toUtc() : null;

@immutable
class GroupInfo {
  const GroupInfo({
    required this.id,
    required this.name,
    required this.memberCount,
    this.code,
    this.nickname,
    this.memberLimit = GroupRules.maxMembers,
  });

  factory GroupInfo.fromJson(Map<String, Object?> j) => GroupInfo(
    id: _str(j['id']),
    name: _str(j['name']),
    memberCount: _int(j['member_count']),
    memberLimit: _int(j['member_limit'], GroupRules.maxMembers),
    code: j['code'] is String ? j['code']! as String : null,
    nickname: j['nickname'] is String ? j['nickname']! as String : null,
  );

  final String id;
  final String name;
  final int memberCount;
  final int memberLimit;

  /// Faqat ustozga keladi.
  final String? code;

  /// Talaba ro‘yxatida — o‘z taxallusi.
  final String? nickname;
}

@immutable
class GroupList {
  const GroupList({
    required this.isTeacher,
    required this.teaching,
    required this.member,
  });

  factory GroupList.fromJson(Map<String, Object?> j) => GroupList(
    isTeacher: j['is_teacher'] == true,
    teaching: [
      for (final g in _list(j['teaching'])) GroupInfo.fromJson(_map(g)),
    ],
    member: [for (final g in _list(j['member'])) GroupInfo.fromJson(_map(g))],
  );

  final bool isTeacher;
  final List<GroupInfo> teaching;
  final List<GroupInfo> member;
}

@immutable
class GroupMember {
  const GroupMember({required this.id, required this.nickname});

  factory GroupMember.fromJson(Map<String, Object?> j) =>
      GroupMember(id: _str(j['id']), nickname: _str(j['nickname']));

  final String id;
  final String nickname;
}

enum RevealPolicy {
  /// Muddat tugagach (yoki ustoz yopgach).
  afterDue,

  /// Faqat ustoz yopgach.
  afterClose;

  String get wire => this == afterDue ? 'after_due' : 'after_close';

  static RevealPolicy parse(Object? v) =>
      v == 'after_due' ? afterDue : afterClose;
}

/// Talabaning shu testdagi holati.
enum MyTestState {
  notStarted,
  solving,
  finished;

  static MyTestState parse(Object? v) => switch (v) {
    'solving' => solving,
    'finished' => finished,
    _ => notStarted,
  };
}

@immutable
class GroupAssignment {
  const GroupAssignment({
    required this.id,
    required this.groupId,
    required this.topicId,
    required this.topicTitle,
    required this.questionCount,
    required this.variantMode,
    required this.reveal,
    required this.closed,
    required this.revealed,
    this.timeLimitMin,
    this.dueAt,
    this.createdAt,
    this.serverNow,
    this.poolSize = 0,
    this.started = 0,
    this.finished = 0,
    this.myState = MyTestState.notStarted,
    this.myScore,
    this.myTotal,
    this.topics = const [],
  });

  factory GroupAssignment.fromJson(Map<String, Object?> j) => GroupAssignment(
    id: _str(j['id']),
    groupId: _str(j['group_id']),
    topicId: _str(j['topic_id']),
    topicTitle: _str(j['topic_title']),
    questionCount: _int(j['question_count']),
    timeLimitMin: _intOrNull(j['time_limit_min']),
    dueAt: _date(j['due_at']),
    variantMode: j['variant_mode'] == true,
    reveal: RevealPolicy.parse(j['reveal_policy']),
    closed: j['status'] == 'closed',
    revealed: j['revealed'] == true,
    createdAt: _date(j['created_at']),
    serverNow: _date(j['server_now']),
    poolSize: _int(j['pool_size']),
    started: _int(j['started']),
    finished: _int(j['finished']),
    myState: MyTestState.parse(j['my_state']),
    myScore: _intOrNull(j['my_score']),
    myTotal: _intOrNull(j['my_total']),
    topics: [for (final t in _list(j['topics'])) _str(t)],
  );

  final String id;
  final String groupId;
  final String topicId;
  final String topicTitle;
  final int questionCount;
  final int? timeLimitMin;
  final DateTime? dueAt;
  final bool variantMode;
  final RevealPolicy reveal;
  final bool closed;
  final bool revealed;
  final DateTime? createdAt;
  final DateTime? serverNow;
  final int poolSize;

  /// Ustozga: nechta talaba boshlagan / tugatgan.
  final int started;
  final int finished;

  /// Talabaga: o‘z holati.
  final MyTestState myState;
  final int? myScore;
  final int? myTotal;

  /// Tanlangan mavzular («Umumiy test» — bir nechta).
  final List<String> topics;

  bool get isMixed => topics.length > 1;
}

@immutable
class GroupDetail {
  const GroupDetail({
    required this.isTeacher,
    required this.group,
    required this.assignments,
    this.members = const [],
    this.nickname,
  });

  factory GroupDetail.fromJson(Map<String, Object?> j) => GroupDetail(
    isTeacher: j['role'] == 'teacher',
    group: GroupInfo.fromJson(_map(j['group'])),
    members: [
      for (final m in _list(j['members'])) GroupMember.fromJson(_map(m)),
    ],
    assignments: [
      for (final a in _list(j['assignments']))
        GroupAssignment.fromJson(_map(a)),
    ],
    nickname: j['nickname'] is String ? j['nickname']! as String : null,
  );

  final bool isTeacher;
  final GroupInfo group;
  final List<GroupMember> members;
  final List<GroupAssignment> assignments;
  final String? nickname;
}

/// Ustoz sozlaydigan «Mavzu testi».
@immutable
class AssignmentDraft {
  const AssignmentDraft({
    required this.topicId,
    required this.questionCount,
    this.topics,
    this.title,
    this.timeLimitMin,
    this.dueAt,
    this.variantMode = false,
    this.reveal = RevealPolicy.afterClose,
  });

  final String topicId;

  /// «Umumiy test»: bir nechta mavzu (navbatma-navbat). `null` — [topicId].
  final List<String>? topics;

  /// «Umumiy test» nomi (tahrirlanadi).
  final String? title;

  bool get isMixed => topics != null;

  List<String> get topicIds => topics ?? [topicId];
  final int questionCount;
  final int? timeLimitMin;
  final DateTime? dueAt;
  final bool variantMode;
  final RevealPolicy reveal;

  /// Mijoz tomonidagi tekshiruv (server baribir tekshiradi).
  GroupFailure? validate({required int poolSize, required DateTime now}) {
    if (questionCount < GroupRules.minQuestions ||
        questionCount > GroupRules.maxQuestions) {
      return GroupFailure.invalidSettings;
    }
    final t = timeLimitMin;
    if (t != null &&
        (t < GroupRules.minTimeLimit || t > GroupRules.maxTimeLimit)) {
      return GroupFailure.invalidSettings;
    }
    if (poolSize < questionCount) return GroupFailure.notEnoughQuestions;
    if (variantMode && poolSize < questionCount * 2) {
      return GroupFailure.variantPoolSmall;
    }
    final due = dueAt;
    if (due != null && !due.isAfter(now.add(const Duration(minutes: 1)))) {
      return GroupFailure.badDue;
    }
    if (reveal == RevealPolicy.afterDue && due == null) {
      return GroupFailure.revealNeedsDue;
    }
    return null;
  }
}

/// Qo‘shilish natijasi.
@immutable
class GroupJoinInfo {
  const GroupJoinInfo({
    required this.isTeacher,
    required this.group,
    this.nickname,
    this.alreadyMember = false,
    this.assignmentId,
  });

  factory GroupJoinInfo.fromJson(Map<String, Object?> j) => GroupJoinInfo(
    isTeacher: j['role'] == 'teacher',
    group: GroupInfo.fromJson(_map(j['group'])),
    nickname: j['nickname'] is String ? j['nickname']! as String : null,
    alreadyMember: j['already_member'] == true,
    assignmentId: j['assignment_id'] is String
        ? j['assignment_id']! as String
        : null,
  );

  /// Ustoz o‘z kodini ochdi — a’zo qilinmagan.
  final bool isTeacher;
  final GroupInfo group;
  final String? nickname;
  final bool alreadyMember;

  /// QR’dagi test shu guruhga tegishli bo‘lsa — uning id si.
  final String? assignmentId;
}

/// Talabaga ko‘rinadigan savol (to‘g‘ri javobsiz).
@immutable
class GroupQuestion {
  const GroupQuestion({
    required this.id,
    required this.text,
    required this.options,
  });

  factory GroupQuestion.fromJson(Map<String, Object?> j) => GroupQuestion(
    id: _str(j['id']),
    text: _str(j['text']),
    options: [for (final o in _list(j['options'])) _str(o)],
  );

  final String id;
  final String text;
  final List<String> options;
}

/// Ochilgan urinish: savollar, server vaqtlari, saqlangan javoblar.
@immutable
class GroupAttempt {
  const GroupAttempt({
    required this.assignment,
    required this.finished,
    required this.questions,
    required this.answers,
    this.startedAt,
    this.endsAt,
    this.serverNow,
    this.score,
    this.total,
  });

  factory GroupAttempt.fromJson(Map<String, Object?> j) => GroupAttempt(
    assignment: GroupAssignment.fromJson(_map(j['assignment'])),
    finished: j['state'] == 'finished',
    questions: [
      for (final q in _list(j['questions'])) GroupQuestion.fromJson(_map(q)),
    ],
    answers: {
      for (final e in _map(j['answers']).entries)
        if (e.value is num) e.key: (e.value! as num).toInt(),
    },
    startedAt: _date(j['started_at']),
    endsAt: _date(j['ends_at']),
    serverNow: _date(j['server_now']),
    score: _intOrNull(j['score']),
    total: _intOrNull(j['total']),
  );

  final GroupAssignment assignment;
  final bool finished;
  final List<GroupQuestion> questions;
  final Map<String, int> answers;
  final DateTime? startedAt;

  /// Urinish oynasining oxiri (imtiyozsiz): muddat / vaqt chegarasi /
  /// yopilish. `null` — cheklanmagan.
  final DateTime? endsAt;
  final DateTime? serverNow;
  final int? score;
  final int? total;
}

@immutable
class GroupSubmitInfo {
  const GroupSubmitInfo({
    required this.score,
    required this.total,
    required this.late,
    required this.revealed,
  });

  factory GroupSubmitInfo.fromJson(Map<String, Object?> j) => GroupSubmitInfo(
    score: _int(j['score']),
    total: _int(j['total']),
    late: j['late'] == true,
    revealed: j['revealed'] == true,
  );

  final int score;
  final int total;

  /// Vaqt tugagan edi: oxirgi saqlangan javoblar hisoblandi.
  final bool late;
  final bool revealed;
}

@immutable
class GroupResultItem {
  const GroupResultItem({
    required this.id,
    required this.text,
    required this.options,
    this.myAnswer,
    this.correctIndex,
    this.isCorrect,
    this.explanation = '',
    this.source,
  });

  factory GroupResultItem.fromJson(Map<String, Object?> j) => GroupResultItem(
    id: _str(j['id']),
    text: _str(j['text']),
    options: [for (final o in _list(j['options'])) _str(o)],
    myAnswer: _intOrNull(j['my_answer']),
    correctIndex: _intOrNull(j['correct_index']),
    isCorrect: j['is_correct'] is bool ? j['is_correct']! as bool : null,
    explanation: _str(j['explanation']),
    source: j['source'] is Map ? ClassSource.fromJson(_map(j['source'])) : null,
  );

  final String id;
  final String text;
  final List<String> options;
  final int? myAnswer;

  /// Faqat ochilgach.
  final int? correctIndex;
  final bool? isCorrect;
  final String explanation;
  final ClassSource? source;
}

@immutable
class GroupTestResult {
  const GroupTestResult({
    required this.assignment,
    required this.score,
    required this.total,
    required this.revealed,
    required this.items,
    this.expired = false,
  });

  factory GroupTestResult.fromJson(Map<String, Object?> j) => GroupTestResult(
    assignment: GroupAssignment.fromJson(_map(j['assignment'])),
    score: _int(j['score']),
    total: _int(j['total']),
    revealed: j['revealed'] == true,
    expired: j['finish_reason'] == 'expired',
    items: [
      for (final i in _list(j['items'])) GroupResultItem.fromJson(_map(i)),
    ],
  );

  final GroupAssignment assignment;
  final int score;
  final int total;
  final bool revealed;
  final bool expired;
  final List<GroupResultItem> items;
}

/// Ustoz paneli / katta ekran qatori.
enum BoardState {
  joined,
  solving,
  finished;

  static BoardState parse(Object? v) => switch (v) {
    'solving' => solving,
    'finished' => finished,
    _ => joined,
  };
}

@immutable
class GroupBoardRow {
  const GroupBoardRow({
    required this.memberId,
    required this.nickname,
    required this.state,
    this.score,
    this.total,
    this.answered = 0,
  });

  factory GroupBoardRow.fromJson(Map<String, Object?> j) => GroupBoardRow(
    memberId: _str(j['member_id']),
    nickname: _str(j['nickname']),
    state: BoardState.parse(j['state']),
    score: _intOrNull(j['score']),
    total: _intOrNull(j['total']),
    answered: _int(j['answered']),
  );

  final String memberId;
  final String nickname;
  final BoardState state;
  final int? score;
  final int? total;
  final int answered;
}

@immutable
class GroupBoard {
  const GroupBoard({
    required this.assignment,
    required this.group,
    required this.rows,
  });

  factory GroupBoard.fromJson(Map<String, Object?> j) => GroupBoard(
    assignment: GroupAssignment.fromJson(_map(j['assignment'])),
    group: GroupInfo.fromJson(_map(j['group'])),
    rows: [for (final r in _list(j['rows'])) GroupBoardRow.fromJson(_map(r))],
  );

  final GroupAssignment assignment;
  final GroupInfo group;
  final List<GroupBoardRow> rows;

  int count(BoardState s) => rows.where((r) => r.state == s).length;
}

/// Ustoz «Talaba ko‘rinishida sinash» uchun hovuz savoli (to‘g‘ri javob bilan).
@immutable
class GroupPoolQuestion {
  const GroupPoolQuestion({
    required this.id,
    required this.text,
    required this.options,
    required this.correctIndex,
    this.explanation = '',
  });

  factory GroupPoolQuestion.fromJson(Map<String, Object?> j) =>
      GroupPoolQuestion(
        id: _str(j['id']),
        text: _str(j['text']),
        options: [for (final o in _list(j['options'])) _str(o)],
        correctIndex: _int(j['correct_index']),
        explanation: _str(j['explanation']),
      );

  final String id;
  final String text;
  final List<String> options;
  final int correctIndex;
  final String explanation;
}

@immutable
class GroupPreview {
  const GroupPreview({required this.assignment, required this.pool});

  factory GroupPreview.fromJson(Map<String, Object?> j) => GroupPreview(
    assignment: GroupAssignment.fromJson(_map(j['assignment'])),
    pool: [
      for (final q in _list(j['pool'])) GroupPoolQuestion.fromJson(_map(q)),
    ],
  );

  final GroupAssignment assignment;
  final List<GroupPoolQuestion> pool;
}

/// Vaqt ko‘rinishi: server soati bilan farq ([serverNow]) hisobga olinadi.
///
/// * Vaqt chegarasi bor — har doim teskari sanoq.
/// * Faqat muddat — ekranda sana («Muddat: 20-okt, 18:00»); teskari sanoq
///   faqat oxirgi soatda ([GroupRules.countdownWindow]).
@immutable
class GroupClock {
  const GroupClock({
    required this.endsAt,
    required this.hasTimeLimit,
    required this.skew,
  });

  /// [serverNow] va qurilma vaqti ([deviceNow]) farqi — keyingi hisoblar
  /// server soati bo‘yicha.
  factory GroupClock.of(GroupAttempt a, DateTime deviceNow) => GroupClock(
    endsAt: a.endsAt,
    hasTimeLimit: a.assignment.timeLimitMin != null,
    skew: a.serverNow == null
        ? Duration.zero
        : a.serverNow!.difference(deviceNow.toUtc()),
  );

  final DateTime? endsAt;
  final bool hasTimeLimit;
  final Duration skew;

  DateTime serverTime(DateTime deviceNow) => deviceNow.toUtc().add(skew);

  /// Qolgan vaqt (cheklanmagan bo‘lsa `null`, manfiy bo‘lmaydi).
  Duration? remaining(DateTime deviceNow) {
    final e = endsAt;
    if (e == null) return null;
    final r = e.difference(serverTime(deviceNow));
    return r.isNegative ? Duration.zero : r;
  }

  bool showCountdown(DateTime deviceNow) {
    final r = remaining(deviceNow);
    if (r == null) return false;
    return hasTimeLimit || r <= GroupRules.countdownWindow;
  }

  bool expired(DateTime deviceNow) => remaining(deviceNow) == Duration.zero;
}
