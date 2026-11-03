import 'dart:math';

import '../../domain/class_quiz/class_quiz_models.dart';
import '../../domain/oral_group/oral_group_models.dart';
import '../../domain/ports/oral_group_ports.dart';

class _P {
  _P(this.id, this.userId, this.name, this.ticketNo, this.joinedAt);

  final String id;
  final String userId;
  final String name;
  final int ticketNo;
  final DateTime joinedAt;
  DateTime? readyAt;
  DateTime? calledAt;
  List<int>? scores;
  DateTime? gradedAt;
  bool kicked = false;
  int leaveCount = 0;
  DateTime? lastLeftAt;
}

class _S {
  _S({
    required this.id,
    required this.code,
    required this.teacherId,
    required this.title,
    required this.tickets,
    required this.prepSeconds,
    required this.createdAt,
  });

  final String id;
  final String code;
  final String teacherId;
  final String title;
  final List<List<OralGroupQuestion>> tickets;
  final int prepSeconds;
  final DateTime createdAt;
  OralGroupStatus status = OralGroupStatus.open;
  DateTime? finishedAt;
  final participants = <_P>[];
}

/// Server o‘rnidagi xotira modeli (`oral_*` SQL funksiyalaridagi qoidalarning
/// nusxasi): tasodifiy bo‘sh bilet, ism tekshiruvi 2..40, «full», chetlatilgan
/// qayta kira olmaydi, tugagan sessiyaga yangi talaba kirmaydi, ball 0..20 va
/// bilet savollari soniga teng, tartib (baholanmagan → tayyor → qo‘shilgan).
/// **Productionga ulanmaydi.** Ustoz va talaba bitta jarayonda
/// [FakeOralGroupService] ko‘rinishlari orqali ishlaydi.
class FakeOralGroupBackend {
  FakeOralGroupBackend({
    DateTime Function()? clock,
    Random? rng,
    Set<String>? teachers,
    this.allowSelfJoin = false,
    this.demoBots = 0,
    Set<String>? takenCodes,
  }) : now = clock ?? DateTime.now,
       _rng = rng ?? Random(),
       teachers = teachers ?? <String>{},
       takenCodes = takenCodes ?? <String>{};

  final DateTime Function() now;
  final Random _rng;
  final Set<String> teachers;

  /// Demo: ustoz o‘z imtihoniga ham qo‘shila oladi.
  final bool allowSelfJoin;

  /// Demo: har yangi sessiyaga shuncha “DEMO” talaba qo‘shiladi.
  final int demoBots;

  /// «Guruh testi» kodlari (to‘qnashmaslik uchun).
  final Set<String> takenCodes;

  final _sessions = <String, _S>{};
  final _attempts = <String, int>{};
  int _seq = 0;

  String _id(String p) => '$p${++_seq}';

  _S? _byCode(String code) =>
      _sessions.values.where((s) => s.code == code).firstOrNull;

  static const _forbidden = ClassResult<Never>.fail(ClassFailure.forbidden);

  bool isTeacher(String user) => teachers.contains(user);

  OralGroupSession _info(_S s, {bool counts = false}) {
    final active = s.participants.where((p) => !p.kicked);
    return OralGroupSession(
      id: s.id,
      code: s.code,
      title: s.title,
      status: s.status,
      ticketCount: s.tickets.length,
      prepSeconds: s.prepSeconds,
      createdAt: s.createdAt,
      finishedAt: s.finishedAt,
      joined: counts ? active.length : 0,
      graded: counts ? active.where((p) => p.gradedAt != null).length : 0,
    );
  }

  List<OralGroupQuestion> _questions(_S s, int no) => [
    for (final q in s.tickets[no - 1])
      OralGroupQuestion(id: q.id, text: q.text),
  ];

  // ----------------------------------------------------------- ustoz

  ClassResult<OralGroupSession> create(
    String user,
    String title,
    List<List<OralGroupQuestion>> tickets,
    int prepSeconds,
  ) {
    if (!isTeacher(user)) return _forbidden;
    if (tickets.isEmpty ||
        tickets.length > OralGroupRules.maxStudents ||
        prepSeconds < 0 ||
        prepSeconds > OralGroupRules.maxPrepMinutes * 60 ||
        title.runes.length > 300) {
      return const ClassResult.fail(ClassFailure.invalidSettings);
    }
    for (final t in tickets) {
      if (t.isEmpty || t.length > 10) {
        return const ClassResult.fail(ClassFailure.invalidTicket);
      }
      for (final q in t) {
        if (q.id.isEmpty ||
            q.id.runes.length > OralGroupRules.idMax ||
            q.text.isEmpty ||
            q.text.runes.length > OralGroupRules.textMax) {
          return const ClassResult.fail(ClassFailure.invalidTicket);
        }
      }
    }
    final open = _sessions.values.where(
      (s) => s.teacherId == user && s.status == OralGroupStatus.open,
    );
    if (open.length >= 10) {
      return const ClassResult.fail(ClassFailure.tooManySessions);
    }
    String? code;
    for (var i = 0; i < 30; i++) {
      final c = ClassCode.generate(_rng);
      if (_byCode(c) == null && !takenCodes.contains(c)) {
        code = c;
        break;
      }
    }
    if (code == null) return const ClassResult.fail(ClassFailure.tryAgain);
    final s = _S(
      id: _id('os'),
      code: code,
      teacherId: user,
      title: title.trim(),
      tickets: [
        for (final t in tickets)
          [for (final q in t) OralGroupQuestion(id: q.id, text: q.text.trim())],
      ],
      prepSeconds: prepSeconds,
      createdAt: now().toUtc(),
    );
    _sessions[s.id] = s;
    for (var i = 0; i < min(demoBots, s.tickets.length); i++) {
      _addParticipant(s, 'demo-bot-$i', 'DEMO ${i + 1}');
    }
    return ClassResult.ok(_info(s));
  }

  ClassResult<List<OralGroupSession>> mine(String user) {
    final list = [
      for (final s in _sessions.values)
        if (s.teacherId == user) s,
    ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return ClassResult.ok([for (final s in list) _info(s, counts: true)]);
  }

  _S? _owned(String user, String id) {
    final s = _sessions[id];
    return s != null && s.teacherId == user ? s : null;
  }

  ClassResult<OralGroupTeacherState> teacherState(String user, String id) {
    final s = _owned(user, id);
    if (s == null) return _forbidden;
    final ps = [
      for (final p in s.participants)
        if (!p.kicked) p,
    ];
    ps.sort((a, b) {
      final ga = a.gradedAt != null ? 1 : 0;
      final gb = b.gradedAt != null ? 1 : 0;
      if (ga != gb) return ga - gb;
      if (a.readyAt != null && b.readyAt != null) {
        final c = a.readyAt!.compareTo(b.readyAt!);
        if (c != 0) return c;
      } else if (a.readyAt != null) {
        return -1;
      } else if (b.readyAt != null) {
        return 1;
      }
      return a.joinedAt.compareTo(b.joinedAt);
    });
    return ClassResult.ok(
      OralGroupTeacherState(
        session: _info(s),
        tickets: [
          for (var i = 1; i <= s.tickets.length; i++)
            OralGroupTicket(no: i, questions: _questions(s, i)),
        ],
        participants: [
          for (final p in ps)
            OralGroupParticipant(
              id: p.id,
              name: p.name,
              ticketNo: p.ticketNo,
              joinedAt: p.joinedAt,
              readyAt: p.readyAt,
              calledAt: p.calledAt,
              scores: p.scores == null ? null : [...p.scores!],
              gradedAt: p.gradedAt,
              leaveCount: p.leaveCount,
              lastLeftAt: p.lastLeftAt,
            ),
        ],
      ),
    );
  }

  _P? _live(_S s, String pid) =>
      s.participants.where((p) => p.id == pid && !p.kicked).firstOrNull;

  ClassResult<void> call(String user, String id, String pid) {
    final s = _owned(user, id);
    if (s == null) return _forbidden;
    final p = _live(s, pid);
    if (p == null) return const ClassResult.fail(ClassFailure.notFound);
    p.calledAt ??= now().toUtc();
    return const ClassResult.ok(null);
  }

  ClassResult<int> grade(String user, String id, String pid, List<int> scores) {
    final s = _owned(user, id);
    if (s == null) return _forbidden;
    final p = _live(s, pid);
    if (p == null) return const ClassResult.fail(ClassFailure.notFound);
    if (scores.length != s.tickets[p.ticketNo - 1].length ||
        scores.any((x) => x < 0 || x > OralGroupRules.maxScore)) {
      return const ClassResult.fail(ClassFailure.invalidScores);
    }
    p.scores = [...scores];
    p.gradedAt = now().toUtc();
    p.calledAt ??= p.gradedAt;
    return ClassResult.ok(scores.fold<int>(0, (a, b) => a + b));
  }

  ClassResult<void> kick(String user, String id, String pid) {
    final s = _owned(user, id);
    if (s == null) return _forbidden;
    final p = _live(s, pid);
    if (p == null) return const ClassResult.fail(ClassFailure.notFound);
    p.kicked = true;
    return const ClassResult.ok(null);
  }

  ClassResult<void> finish(String user, String id) {
    final s = _owned(user, id);
    if (s == null) return _forbidden;
    s.status = OralGroupStatus.finished;
    s.finishedAt ??= now().toUtc();
    return const ClassResult.ok(null);
  }

  // ----------------------------------------------------------- talaba

  _P _addParticipant(_S s, String user, String name) {
    final taken = {
      for (final p in s.participants)
        if (!p.kicked) p.ticketNo,
    };
    final free = [
      for (var i = 1; i <= s.tickets.length; i++)
        if (!taken.contains(i)) i,
    ];
    final p = _P(
      _id('op'),
      user,
      name,
      free[_rng.nextInt(free.length)],
      now().toUtc(),
    );
    s.participants.add(p);
    return p;
  }

  /// Ism tekshiruvi (server: `oral_name_check`): uzunlik 2..40, so‘ng
  /// laqab filtri boshi va oxiriga (20 belgidan).
  NicknameCheck _nameCheck(String raw) {
    final t = OralName.clean(raw);
    if (!OralName.validLength(t)) return NicknameCheck.length;
    final runes = t.runes.toList();
    String part(Iterable<int> r) => String.fromCharCodes(r);
    final a = ClassNickname.check(part(runes.take(20)));
    if (a != NicknameCheck.ok) {
      return a == NicknameCheck.length ? NicknameCheck.chars : a;
    }
    if (runes.length > 20) {
      final b = ClassNickname.check(part(runes.skip(runes.length - 20)));
      if (b != NicknameCheck.ok) {
        return b == NicknameCheck.length ? NicknameCheck.chars : b;
      }
    }
    return NicknameCheck.ok;
  }

  ClassResult<OralGroupJoinInfo> join(
    String user,
    String rawCode,
    String name,
  ) {
    final n = now();
    final k = '$user|${n.year}-${n.month}-${n.day}-${n.hour}';
    final attempts = (_attempts[k] ?? 0) + 1;
    _attempts[k] = attempts;
    if (attempts > 30) return const ClassResult.fail(ClassFailure.rateLimited);
    final code = ClassCode.normalize(rawCode);
    if (code == null) return const ClassResult.fail(ClassFailure.badCode);
    final s = _byCode(code);
    if (s == null) return const ClassResult.fail(ClassFailure.notFound);
    if (s.teacherId == user && !allowSelfJoin) {
      return const ClassResult.fail(ClassFailure.ownSession);
    }
    final existing = s.participants.where((p) => p.userId == user).firstOrNull;
    if (existing != null) {
      if (existing.kicked) return const ClassResult.fail(ClassFailure.kicked);
      return ClassResult.ok(
        OralGroupJoinInfo(participantId: existing.id, session: _info(s)),
      );
    }
    if (s.status != OralGroupStatus.open) {
      return const ClassResult.fail(ClassFailure.finished);
    }
    switch (_nameCheck(name)) {
      case NicknameCheck.length:
        return const ClassResult.fail(ClassFailure.nickLength);
      case NicknameCheck.chars:
        return const ClassResult.fail(ClassFailure.nickChars);
      case NicknameCheck.blocked:
        return const ClassResult.fail(ClassFailure.nickBlocked);
      case NicknameCheck.ok:
        break;
    }
    final taken = s.participants.where((p) => !p.kicked).length;
    if (taken >= s.tickets.length) {
      return const ClassResult.fail(ClassFailure.full);
    }
    final p = _addParticipant(s, user, OralName.clean(name));
    return ClassResult.ok(
      OralGroupJoinInfo(participantId: p.id, session: _info(s)),
    );
  }

  ClassResult<OralGroupMyState> myState(String user, String id) {
    final s = _sessions[id];
    if (s == null) return const ClassResult.fail(ClassFailure.notFound);
    final p = s.participants
        .where((x) => x.userId == user && !x.kicked)
        .firstOrNull;
    if (p == null) return const ClassResult.fail(ClassFailure.notJoined);
    final graded = p.gradedAt != null;
    return ClassResult.ok(
      OralGroupMyState(
        session: _info(s),
        name: p.name,
        ticketNo: p.ticketNo,
        questions: _questions(s, p.ticketNo),
        joinedAt: p.joinedAt,
        readyAt: p.readyAt,
        calledAt: p.calledAt,
        gradedAt: p.gradedAt,
        scores: graded ? [...p.scores!] : null,
        total: graded ? p.scores!.fold<int>(0, (a, b) => a + b) : null,
        serverNow: now().toUtc(),
        leaveCount: p.leaveCount,
      ),
    );
  }

  ClassResult<int> reportLeave(String user, String id) {
    final s = _sessions[id];
    final p = s?.participants
        .where((x) => x.userId == user && !x.kicked)
        .firstOrNull;
    if (s == null ||
        p == null ||
        p.gradedAt != null ||
        s.status != OralGroupStatus.open) {
      return const ClassResult.fail(ClassFailure.notAllowed);
    }
    p.leaveCount++;
    p.lastLeftAt = now().toUtc();
    return ClassResult.ok(p.leaveCount);
  }

  ClassResult<void> ready(String user, String id) {
    final s = _sessions[id];
    final p = s?.participants
        .where((x) => x.userId == user && !x.kicked)
        .firstOrNull;
    if (s == null ||
        p == null ||
        p.gradedAt != null ||
        s.status != OralGroupStatus.open) {
      return const ClassResult.fail(ClassFailure.notAllowed);
    }
    p.readyAt ??= now().toUtc();
    return const ClassResult.ok(null);
  }
}

/// Bitta foydalanuvchi ko‘rinishi. Demo rejimda [demo] `true`.
class FakeOralGroupService implements OralGroupService {
  FakeOralGroupService(
    this.backend, {
    required this.userId,
    this.demo = true,
    this.signInRequired = false,
  });

  final FakeOralGroupBackend backend;
  final String userId;
  final bool demo;
  final bool signInRequired;

  @override
  bool get isConfigured => true;
  @override
  bool get isDemo => demo;
  @override
  bool get requiresSignIn => signInRequired;

  @override
  Future<ClassResult<OralGroupSession>> createSession({
    required String title,
    required List<List<OralGroupQuestion>> tickets,
    required int prepSeconds,
  }) async => backend.create(userId, title, tickets, prepSeconds);

  @override
  Future<ClassResult<List<OralGroupSession>>> mySessions() async =>
      backend.mine(userId);

  @override
  Future<ClassResult<OralGroupTeacherState>> teacherState(
    String sessionId,
  ) async => backend.teacherState(userId, sessionId);

  @override
  Future<ClassResult<void>> call(
    String sessionId,
    String participantId,
  ) async => backend.call(userId, sessionId, participantId);

  @override
  Future<ClassResult<int>> grade(
    String sessionId,
    String participantId,
    List<int> scores,
  ) async => backend.grade(userId, sessionId, participantId, scores);

  @override
  Future<ClassResult<void>> kick(
    String sessionId,
    String participantId,
  ) async => backend.kick(userId, sessionId, participantId);

  @override
  Future<ClassResult<void>> finish(String sessionId) async =>
      backend.finish(userId, sessionId);

  @override
  Future<ClassResult<OralGroupJoinInfo>> join({
    required String code,
    required String name,
  }) async => backend.join(userId, code, name);

  @override
  Future<ClassResult<OralGroupMyState>> myState(String sessionId) async =>
      backend.myState(userId, sessionId);

  @override
  Future<ClassResult<void>> ready(String sessionId) async =>
      backend.ready(userId, sessionId);

  @override
  Future<ClassResult<int>> reportLeave(String sessionId) async =>
      backend.reportLeave(userId, sessionId);
}
