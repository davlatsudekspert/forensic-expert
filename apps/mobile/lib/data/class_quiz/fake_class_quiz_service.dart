import 'dart:math';

import '../../domain/class_quiz/class_quiz_models.dart';
import '../../domain/ports/class_quiz_ports.dart';
import 'class_quiz_demo_bank.dart';

class _Q {
  _Q(this.text, this.options, this.correctId, this.explanation, this.source);

  final String text;
  final List<ClassOption> options;
  final String correctId;
  final String explanation;
  final ClassSource source;
}

class _P {
  _P(
    this.id,
    this.userId,
    this.nickname, {
    this.bot = false,
    this.botIndex = 0,
  });

  final String id;
  final String userId;
  final String nickname;
  final bool bot;
  final int botIndex;
  bool kicked = false;
}

class _A {
  _A(this.optionId, this.correct, this.points, this.elapsedMs);

  final String optionId;
  final bool correct;
  final int points;
  final int elapsedMs;
}

class _S {
  _S({
    required this.id,
    required this.code,
    required this.teacherId,
    required this.topic,
    required this.settings,
    required this.questions,
    required this.createdAt,
  });

  final String id;
  final String code;
  final String teacherId;
  final ClassBankTopic topic;
  final ClassQuizSettings settings;
  final List<_Q> questions;
  final DateTime createdAt;
  ClassSessionStatus status = ClassSessionStatus.lobby;
  int currentIndex = -1;
  DateTime? questionStartedAt;
  DateTime? finishedAt;
  final participants = <_P>[];
  final answers = <String, _A>{}; // "participantId|index"
  final reports = <(String, String)>{}; // (participantId, reporterUserId)
}

/// Server o‘rnidagi xotira modeli: SQL funksiyalaridagi qoidalarning bir xil
/// nusxasi (vaqt oynalari, ball, aralashtirish, bir martalik javob, kod
/// taxmin cheklovi). Butun oqim shu bilan testlanadi; **productionga
/// ulanmaydi**. Bir nechta foydalanuvchi bitta backend ustida
/// [FakeClassQuizService] ko‘rinishlari orqali ishlaydi.
class FakeClassQuizBackend {
  FakeClassQuizBackend({
    DateTime Function()? clock,
    Random? rng,
    List<ClassBankTopic>? topics,
    this.topicLoader,
    Set<String>? teachers,
    this.allowSelfJoin = false,
    this.demoBots = 0,
  }) : now = clock ?? DateTime.now,
       _rng = rng ?? Random(),
       topics = [
         ...(topics ?? [classQuizDemoTopic]),
       ],
       teachers = teachers ?? <String>{};

  final DateTime Function() now;
  final Random _rng;
  final List<ClassBankTopic> topics;
  final Set<String> teachers;

  /// Savollar banki (ilova asseti) — birinchi so‘rovda bir marta yuklanadi.
  final Future<List<ClassBankTopic>> Function()? topicLoader;
  Future<void>? _loading;

  /// Bank yuklanmagan bo‘lsa yuklaydi (xato bo‘lsa — mavjud mavzular bilan
  /// davom etadi; hech narsa to‘qilmaydi).
  Future<void> ensureLoaded() => _loading ??= () async {
    final load = topicLoader;
    if (load == null) return;
    try {
      for (final t in await load()) {
        if (!topics.any((x) => x.id == t.id)) topics.add(t);
      }
    } on Object {
      // Asset o‘qilmadi — bank bo‘sh holati UI’da ko‘rsatiladi.
    }
  }();

  /// Demo: bitta qurilmada ustoz o‘z sinfiga ham qo‘shila oladi.
  final bool allowSelfJoin;

  /// Demo: har yangi sinfga shuncha “DEMO” ishtirokchi qo‘shiladi va
  /// savollarga avtomatik javob beradi (jonli panelni ko‘rsatish uchun).
  final int demoBots;

  final _sessions = <String, _S>{};
  final _attempts = <String, int>{}; // "user|hour" → n
  int _seq = 0;

  String _id(String p) => '$p-${++_seq}';

  _S? _byCode(String code) {
    for (final s in _sessions.values) {
      if (s.code == code) return s;
    }
    return null;
  }

  int _elapsedMs(_S s) => s.questionStartedAt == null
      ? 0
      : now().difference(s.questionStartedAt!).inMilliseconds.clamp(0, 1 << 31);

  int _limitMs(_S s) => s.settings.seconds * 1000;

  ClassPhase _phase(_S s) => switch (s.status) {
    ClassSessionStatus.lobby => ClassPhase.lobby,
    ClassSessionStatus.finished => ClassPhase.finished,
    ClassSessionStatus.running =>
      _elapsedMs(s) < _limitMs(s) ? ClassPhase.open : ClassPhase.closed,
  };

  int _remainingMs(_S s) => s.status != ClassSessionStatus.running
      ? 0
      : max(_limitMs(s) - _elapsedMs(s), 0);

  bool _revealed(_S s) =>
      s.status == ClassSessionStatus.finished ||
      (s.status == ClassSessionStatus.running &&
          _elapsedMs(s) >= _limitMs(s) + ClassQuizRules.revealDelayMs);

  ClassSessionInfo _info(_S s, {bool withJoined = false}) => ClassSessionInfo(
    id: s.id,
    code: s.code,
    topicId: s.topic.id,
    topicTitle: s.topic.title,
    status: s.status,
    currentIndex: s.currentIndex,
    total: s.questions.length,
    studentLimit: s.settings.studentLimit,
    seconds: s.settings.seconds,
    joined: withJoined ? _active(s).length : null,
  );

  List<_P> _active(_S s) => [
    for (final p in s.participants)
      if (!p.kicked) p,
  ];

  /// Demo ishtirokchilari: vaqt o‘tishi bilan joriy savolga javob beradi.
  void _runBots(_S s) {
    if (s.status != ClassSessionStatus.running) return;
    final idx = s.currentIndex;
    final elapsed = _elapsedMs(s);
    final limit = _limitMs(s);
    for (final p in s.participants) {
      if (!p.bot || p.kicked) continue;
      final key = '${p.id}|$idx';
      if (s.answers.containsKey(key)) continue;
      final delay = 1200 + p.botIndex * 1700;
      if (elapsed < delay || delay >= limit) continue;
      final r = Random(idx * 97 + p.botIndex * 31 + 7);
      final q = s.questions[idx];
      final wantCorrect = r.nextDouble() < 0.7;
      final wrong = [
        for (final o in q.options)
          if (o.id != q.correctId) o.id,
      ];
      final opt = wantCorrect ? q.correctId : wrong[r.nextInt(wrong.length)];
      final correct = opt == q.correctId;
      s.answers[key] = _A(
        opt,
        correct,
        ClassScoring.points(correct: correct, elapsedMs: delay, limitMs: limit),
        delay,
      );
    }
  }

  // ---------------------------------------------------------------- public

  ClassQuizMe me(String user) =>
      ClassQuizMe(isTeacher: teachers.contains(user));

  ClassResult<List<ClassTopic>> listTopics(String user) {
    if (!teachers.contains(user)) {
      return const ClassResult.fail(ClassFailure.forbidden);
    }
    return ClassResult.ok([
      for (final t in topics)
        ClassTopic(
          id: t.id,
          title: t.title,
          count: t.questions.length,
          isDemo: t.isDemo,
        ),
    ]);
  }

  ClassResult<ClassSessionInfo> create(
    String user,
    String topicId,
    ClassQuizSettings settings,
  ) {
    if (!teachers.contains(user)) {
      return const ClassResult.fail(ClassFailure.forbidden);
    }
    if (!settings.valid) {
      return const ClassResult.fail(ClassFailure.invalidSettings);
    }
    final active = _sessions.values.where(
      (s) => s.teacherId == user && s.status != ClassSessionStatus.finished,
    );
    if (active.length >= 10) {
      return const ClassResult.fail(ClassFailure.tooManySessions);
    }
    final topic = topics.where((t) => t.id == topicId).firstOrNull;
    if (topic == null || topic.questions.length < settings.questionCount) {
      return const ClassResult.fail(ClassFailure.notEnoughQuestions);
    }
    String code;
    do {
      code = ClassCode.generate(_rng);
    } while (_byCode(code) != null);
    final picked = List.of(topic.questions)..shuffle(_rng);
    final qs = <_Q>[];
    for (final b in picked.take(settings.questionCount)) {
      final perm = [0, 1, 2, 3]..shuffle(_rng);
      final opts = [
        for (var i = 0; i < 4; i++)
          ClassOption(id: 'o$i', text: b.options[perm[i]]),
      ];
      qs.add(
        _Q(
          b.question,
          opts,
          'o${perm.indexOf(b.correctIndex)}',
          b.explanation,
          b.source,
        ),
      );
    }
    final s = _S(
      id: _id('s'),
      code: code,
      teacherId: user,
      topic: topic,
      settings: settings,
      questions: qs,
      createdAt: now(),
    );
    for (var i = 0; i < demoBots && i < settings.studentLimit; i++) {
      s.participants.add(
        _P(_id('p'), 'bot-$i', 'DEMO ${i + 1}', bot: true, botIndex: i),
      );
    }
    _sessions[s.id] = s;
    return ClassResult.ok(_info(s));
  }

  ClassResult<List<ClassSessionInfo>> mine(String user) {
    if (!teachers.contains(user)) {
      return const ClassResult.fail(ClassFailure.forbidden);
    }
    final list = [
      for (final s in _sessions.values)
        if (s.teacherId == user) s,
    ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return ClassResult.ok([for (final s in list) _info(s, withJoined: true)]);
  }

  _S? _owned(String user, String id) {
    if (!teachers.contains(user)) return null;
    final s = _sessions[id];
    return s != null && s.teacherId == user ? s : null;
  }

  ClassResult<ClassJoinInfo> join(String user, String rawCode, String nick) {
    final hour = '${now().year}-${now().month}-${now().day}-${now().hour}';
    final k = '$user|$hour';
    final n = (_attempts[k] ?? 0) + 1;
    _attempts[k] = n;
    if (n > 30) return const ClassResult.fail(ClassFailure.rateLimited);
    final code = ClassCode.normalize(rawCode);
    if (code == null) return const ClassResult.fail(ClassFailure.badCode);
    final s = _byCode(code);
    if (s == null) return const ClassResult.fail(ClassFailure.notFound);
    if (s.teacherId == user && !allowSelfJoin) {
      return const ClassResult.fail(ClassFailure.ownSession);
    }
    if (s.status == ClassSessionStatus.finished) {
      return const ClassResult.fail(ClassFailure.finished);
    }
    final existing = s.participants.where((p) => p.userId == user).firstOrNull;
    if (existing != null) {
      if (existing.kicked) return const ClassResult.fail(ClassFailure.kicked);
      return ClassResult.ok(
        ClassJoinInfo(
          sessionId: s.id,
          participantId: existing.id,
          nickname: existing.nickname,
          session: _info(s),
        ),
      );
    }
    if (s.status != ClassSessionStatus.lobby) {
      return const ClassResult.fail(ClassFailure.alreadyStarted);
    }
    switch (ClassNickname.check(nick)) {
      case NicknameCheck.length:
        return const ClassResult.fail(ClassFailure.nickLength);
      case NicknameCheck.chars:
        return const ClassResult.fail(ClassFailure.nickChars);
      case NicknameCheck.blocked:
        return const ClassResult.fail(ClassFailure.nickBlocked);
      case NicknameCheck.ok:
        break;
    }
    if (_active(s).length >= s.settings.studentLimit) {
      return const ClassResult.fail(ClassFailure.full);
    }
    final p = _P(
      _id('p'),
      user,
      ClassNickname.dedupe(nick, [for (final x in s.participants) x.nickname]),
    );
    s.participants.add(p);
    return ClassResult.ok(
      ClassJoinInfo(
        sessionId: s.id,
        participantId: p.id,
        nickname: p.nickname,
        session: _info(s),
      ),
    );
  }

  ClassResult<void> start(String user, String id) {
    final s = _owned(user, id);
    if (s == null) return const ClassResult.fail(ClassFailure.forbidden);
    if (s.status != ClassSessionStatus.lobby) {
      return const ClassResult.fail(ClassFailure.badState);
    }
    if (_active(s).isEmpty) {
      return const ClassResult.fail(ClassFailure.noParticipants);
    }
    s
      ..status = ClassSessionStatus.running
      ..currentIndex = 0
      ..questionStartedAt = now();
    return const ClassResult.ok(null);
  }

  ClassResult<bool> next(String user, String id) {
    final s = _owned(user, id);
    if (s == null) return const ClassResult.fail(ClassFailure.forbidden);
    if (s.status != ClassSessionStatus.running) {
      return const ClassResult.fail(ClassFailure.badState);
    }
    _runBots(s);
    if (s.currentIndex + 1 >= s.questions.length) {
      s
        ..status = ClassSessionStatus.finished
        ..finishedAt = now();
      return const ClassResult.ok(true);
    }
    s
      ..currentIndex += 1
      ..questionStartedAt = now();
    return const ClassResult.ok(false);
  }

  ClassResult<void> closeQuestion(String user, String id) {
    final s = _owned(user, id);
    if (s == null) return const ClassResult.fail(ClassFailure.forbidden);
    if (s.status != ClassSessionStatus.running) {
      return const ClassResult.fail(ClassFailure.badState);
    }
    _runBots(s);
    s.questionStartedAt = now().subtract(
      Duration(milliseconds: _limitMs(s) + 2000),
    );
    return const ClassResult.ok(null);
  }

  ClassResult<void> finish(String user, String id) {
    final s = _owned(user, id);
    if (s == null) return const ClassResult.fail(ClassFailure.forbidden);
    _runBots(s);
    if (s.status != ClassSessionStatus.finished) {
      s
        ..status = ClassSessionStatus.finished
        ..finishedAt = now();
    }
    return const ClassResult.ok(null);
  }

  ClassResult<void> kick(String user, String id, String participantId) {
    final s = _owned(user, id);
    if (s == null) return const ClassResult.fail(ClassFailure.forbidden);
    for (final p in s.participants) {
      if (p.id == participantId) p.kicked = true;
    }
    return const ClassResult.ok(null);
  }

  _P? _member(String user, String id) {
    final s = _sessions[id];
    if (s == null) return null;
    return s.participants.where((p) => p.userId == user).firstOrNull;
  }

  ClassResult<void> submit(String user, String id, int index, String option) {
    final p = _member(user, id);
    if (p == null || p.kicked) {
      return const ClassResult.fail(ClassFailure.forbidden);
    }
    final s = _sessions[id]!;
    if (s.status != ClassSessionStatus.running || s.currentIndex != index) {
      return const ClassResult.fail(ClassFailure.notCurrent);
    }
    if (!RegExp(r'^o[0-3]$').hasMatch(option)) {
      return const ClassResult.fail(ClassFailure.badOption);
    }
    final elapsed = _elapsedMs(s);
    final limit = _limitMs(s);
    if (elapsed > limit + ClassQuizRules.submitGraceMs) {
      return const ClassResult.fail(ClassFailure.timeOver);
    }
    final key = '${p.id}|$index';
    if (s.answers.containsKey(key)) {
      return const ClassResult.fail(ClassFailure.alreadyAnswered);
    }
    final correct = option == s.questions[index].correctId;
    s.answers[key] = _A(
      option,
      correct,
      ClassScoring.points(correct: correct, elapsedMs: elapsed, limitMs: limit),
      min(elapsed, limit),
    );
    return const ClassResult.ok(null);
  }

  List<ClassLeaderRow> _scores(_S s) {
    final rows = <({_P p, int score, int correct, int avg})>[];
    for (final p in _active(s)) {
      var score = 0;
      var correct = 0;
      var n = 0;
      var sum = 0;
      for (var i = 0; i < s.questions.length; i++) {
        final a = s.answers['${p.id}|$i'];
        if (a == null) continue;
        score += a.points;
        if (a.correct) correct++;
        n++;
        sum += a.elapsedMs;
      }
      rows.add((
        p: p,
        score: score,
        correct: correct,
        avg: n == 0 ? 0 : sum ~/ n,
      ));
    }
    rows.sort((a, b) {
      final c = b.score.compareTo(a.score);
      if (c != 0) return c;
      final d = b.correct.compareTo(a.correct);
      if (d != 0) return d;
      final e = a.avg.compareTo(b.avg);
      return e != 0 ? e : a.p.nickname.compareTo(b.p.nickname);
    });
    final out = <ClassLeaderRow>[];
    for (var i = 0; i < rows.length; i++) {
      final r = rows[i];
      var rank = i + 1;
      if (i > 0) {
        final prev = rows[i - 1];
        if (prev.score == r.score &&
            prev.correct == r.correct &&
            prev.avg == r.avg) {
          rank = out[i - 1].rank;
        }
      }
      out.add(
        ClassLeaderRow(
          participantId: r.p.id,
          nickname: r.p.nickname,
          score: r.score,
          correct: r.correct,
          rank: rank,
        ),
      );
    }
    return out;
  }

  ClassResult<ClassStudentState> state(String user, String id) {
    final p = _member(user, id);
    if (p == null) return const ClassResult.fail(ClassFailure.forbidden);
    final s = _sessions[id]!;
    _runBots(s);
    if (p.kicked) {
      return ClassResult.ok(
        ClassStudentState(
          session: _info(s),
          kicked: true,
          phase: ClassPhase.lobby,
          remainingMs: 0,
          joined: 0,
          nickname: p.nickname,
          score: 0,
          correct: 0,
        ),
      );
    }
    final scores = _scores(s);
    final mine = scores.where((r) => r.participantId == p.id).firstOrNull;
    ClassQuestionView? question;
    String? myOption;
    ClassReveal? reveal;
    var board = const <ClassLeaderRow>[];
    if (s.status == ClassSessionStatus.running) {
      final q = s.questions[s.currentIndex];
      question = ClassQuestionView(
        index: s.currentIndex,
        text: q.text,
        options: q.options,
      );
      final a = s.answers['${p.id}|${s.currentIndex}'];
      myOption = a?.optionId;
      if (_revealed(s)) {
        reveal = ClassReveal(
          correctOption: q.correctId,
          explanation: q.explanation,
          myCorrect: a?.correct ?? false,
          myPoints: a?.points ?? 0,
        );
      }
    } else if (s.status == ClassSessionStatus.finished) {
      board = scores.take(5).toList();
    }
    return ClassResult.ok(
      ClassStudentState(
        session: _info(s),
        phase: _phase(s),
        remainingMs: _remainingMs(s),
        joined: _active(s).length,
        nickname: p.nickname,
        score: mine?.score ?? 0,
        correct: mine?.correct ?? 0,
        rank: mine?.rank,
        question: question,
        myOption: myOption,
        reveal: reveal,
        leaderboard: board,
      ),
    );
  }

  ClassResult<ClassMyResults> myResults(String user, String id) {
    final p = _member(user, id);
    if (p == null || p.kicked) {
      return const ClassResult.fail(ClassFailure.forbidden);
    }
    final s = _sessions[id]!;
    if (s.status != ClassSessionStatus.finished) {
      return const ClassResult.fail(ClassFailure.notFinished);
    }
    final mine = _scores(s).where((r) => r.participantId == p.id).firstOrNull;
    return ClassResult.ok(
      ClassMyResults(
        nickname: p.nickname,
        score: mine?.score ?? 0,
        rank: mine?.rank,
        correct: mine?.correct ?? 0,
        total: s.questions.length,
        participants: _active(s).length,
        items: [
          for (var i = 0; i < s.questions.length; i++)
            () {
              final q = s.questions[i];
              final a = s.answers['${p.id}|$i'];
              return ClassResultItem(
                index: i,
                text: q.text,
                options: q.options,
                myOption: a?.optionId,
                correctOption: q.correctId,
                isCorrect: a?.correct ?? false,
                points: a?.points ?? 0,
                explanation: q.explanation,
                source: q.source,
              );
            }(),
        ],
      ),
    );
  }

  ClassResult<ClassDashboard> dashboard(String user, String id) {
    final s = _owned(user, id);
    if (s == null) return const ClassResult.fail(ClassFailure.forbidden);
    _runBots(s);
    final scores = _scores(s);
    ClassCurrentQuestion? current;
    if (s.status == ClassSessionStatus.running) {
      final q = s.questions[s.currentIndex];
      var answered = 0;
      var correct = 0;
      final counts = <String, int>{};
      for (final p in _active(s)) {
        final a = s.answers['${p.id}|${s.currentIndex}'];
        if (a == null) continue;
        answered++;
        if (a.correct) correct++;
        counts[a.optionId] = (counts[a.optionId] ?? 0) + 1;
      }
      current = ClassCurrentQuestion(
        index: s.currentIndex,
        text: q.text,
        options: [
          for (final o in q.options)
            ClassOption(id: o.id, text: o.text, count: counts[o.id] ?? 0),
        ],
        correctOption: q.correctId,
        explanation: q.explanation,
        answered: answered,
        correctCount: correct,
      );
    }
    final hard = <ClassHardQuestion>[];
    for (var i = 0; i < s.questions.length; i++) {
      final closed =
          s.status == ClassSessionStatus.finished ||
          i < s.currentIndex ||
          (i == s.currentIndex && _phase(s) == ClassPhase.closed);
      if (!closed) continue;
      var n = 0;
      var ok = 0;
      for (final p in _active(s)) {
        final a = s.answers['${p.id}|$i'];
        if (a == null) continue;
        n++;
        if (a.correct) ok++;
      }
      if (n == 0) continue;
      hard.add(
        ClassHardQuestion(
          index: i,
          text: s.questions[i].text,
          answered: n,
          correctPct: (100 * ok / n).round(),
        ),
      );
    }
    hard.sort((a, b) {
      final c = a.correctPct.compareTo(b.correctPct);
      return c != 0 ? c : a.index.compareTo(b.index);
    });
    return ClassResult.ok(
      ClassDashboard(
        session: _info(s),
        phase: _phase(s),
        remainingMs: _remainingMs(s),
        joined: _active(s).length,
        participants: [
          for (final p in _active(s))
            ClassParticipant(id: p.id, nickname: p.nickname),
        ],
        leaderboard: scores.take(10).toList(),
        hardest: hard.take(3).toList(),
        reports: s.reports.length,
        current: current,
      ),
    );
  }

  ClassResult<ClassExport> export(String user, String id) {
    final s = _owned(user, id);
    if (s == null) return const ClassResult.fail(ClassFailure.forbidden);
    _runBots(s);
    final rows = <ClassExportRow>[];
    for (final r in _scores(s)) {
      final p = s.participants.firstWhere((x) => x.id == r.participantId);
      var n = 0;
      var sum = 0;
      for (var i = 0; i < s.questions.length; i++) {
        final a = s.answers['${p.id}|$i'];
        if (a == null) continue;
        n++;
        sum += a.elapsedMs;
      }
      rows.add(
        ClassExportRow(
          nickname: r.nickname,
          score: r.score,
          correct: r.correct,
          answered: n,
          avgMs: n == 0 ? 0 : sum ~/ n,
          rank: r.rank,
        ),
      );
    }
    return ClassResult.ok(ClassExport(session: _info(s), rows: rows));
  }

  ClassResult<void> report(
    String user,
    String id,
    String participantId,
    String reason,
  ) {
    final s = _sessions[id];
    final isMember = _member(user, id) != null && !_member(user, id)!.kicked;
    if (s == null || !(isMember || s.teacherId == user)) {
      return const ClassResult.fail(ClassFailure.forbidden);
    }
    final r = reason.trim();
    if (r.length < 3 || r.length > 200) {
      return const ClassResult.fail(ClassFailure.badReason);
    }
    if (!s.participants.any((p) => p.id == participantId)) {
      return const ClassResult.fail(ClassFailure.notFound);
    }
    s.reports.add((participantId, user));
    return const ClassResult.ok(null);
  }

  /// Test: 30 kun o‘tgan tugagan sessiyalarni o‘chiradi (SQL `class_cleanup`).
  int cleanup() {
    final cutoff = now().subtract(
      const Duration(days: ClassQuizRules.retentionDays),
    );
    final gone = [
      for (final s in _sessions.values)
        if (s.finishedAt != null && s.finishedAt!.isBefore(cutoff)) s.id,
    ];
    gone.forEach(_sessions.remove);
    return gone.length;
  }

  int get sessionCount => _sessions.length;
}

/// Bitta foydalanuvchi ko‘rinishi. Demo rejimda [isDemo] `true`.
class FakeClassQuizService implements ClassQuizService {
  FakeClassQuizService(
    this.backend, {
    required this.userId,
    this.demo = true,
    this.signInRequired = false,
  });

  final FakeClassQuizBackend backend;
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
  Future<ClassResult<ClassQuizMe>> me() async =>
      ClassResult.ok(backend.me(userId));
  @override
  Future<ClassResult<List<ClassTopic>>> topics() async {
    await backend.ensureLoaded();
    return backend.listTopics(userId);
  }

  @override
  Future<ClassResult<ClassSessionInfo>> createSession({
    required String topicId,
    required ClassQuizSettings settings,
  }) async {
    await backend.ensureLoaded();
    return backend.create(userId, topicId, settings);
  }

  @override
  Future<ClassResult<List<ClassSessionInfo>>> mySessions() async =>
      backend.mine(userId);
  @override
  Future<ClassResult<ClassDashboard>> dashboard(String sessionId) async =>
      backend.dashboard(userId, sessionId);
  @override
  Future<ClassResult<void>> start(String sessionId) async =>
      backend.start(userId, sessionId);
  @override
  Future<ClassResult<bool>> next(String sessionId) async =>
      backend.next(userId, sessionId);
  @override
  Future<ClassResult<void>> closeQuestion(String sessionId) async =>
      backend.closeQuestion(userId, sessionId);
  @override
  Future<ClassResult<void>> finish(String sessionId) async =>
      backend.finish(userId, sessionId);
  @override
  Future<ClassResult<void>> kick(
    String sessionId,
    String participantId,
  ) async => backend.kick(userId, sessionId, participantId);
  @override
  Future<ClassResult<ClassExport>> exportResults(String sessionId) async =>
      backend.export(userId, sessionId);
  @override
  Future<ClassResult<ClassJoinInfo>> join({
    required String code,
    required String nickname,
  }) async => backend.join(userId, code, nickname);
  @override
  Future<ClassResult<ClassStudentState>> state(String sessionId) async =>
      backend.state(userId, sessionId);
  @override
  Future<ClassResult<void>> submitAnswer({
    required String sessionId,
    required int questionIndex,
    required String optionId,
  }) async => backend.submit(userId, sessionId, questionIndex, optionId);
  @override
  Future<ClassResult<ClassMyResults>> myResults(String sessionId) async =>
      backend.myResults(userId, sessionId);
  @override
  Future<ClassResult<void>> reportNickname({
    required String sessionId,
    required String participantId,
    required String reason,
  }) async => backend.report(userId, sessionId, participantId, reason);
}
