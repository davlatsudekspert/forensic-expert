import 'dart:math';

import '../../domain/class_groups/class_groups_models.dart';
import '../../domain/class_groups/variant_draw.dart';
import '../../domain/ports/class_groups_ports.dart';
import '../class_quiz/class_quiz_demo_bank.dart';

class _Group {
  _Group(this.id, this.teacherId, this.name, this.code, this.createdAt);

  final String id;
  final String teacherId;
  final String name;
  final String code;
  final DateTime createdAt;
  final members = <_Member>[];
}

class _Member {
  _Member(this.id, this.userId, this.nickname, this.joinedAt);

  final String id;
  final String userId;
  final String nickname;
  final DateTime joinedAt;
}

class _Q {
  _Q(
    this.id,
    this.text,
    this.options,
    this.correct,
    this.explanation,
    this.source,
  );

  final String id;
  final String text;
  final List<String> options;
  final int correct;
  final String explanation;
  final ClassSource source;
}

class _Assignment {
  _Assignment({
    required this.id,
    required this.groupId,
    required this.topicId,
    required this.topicTitle,
    required this.draft,
    required this.pool,
    required this.createdAt,
  });

  final String id;
  final String groupId;
  final String topicId;
  final String topicTitle;
  final AssignmentDraft draft;
  final Map<String, _Q> pool;
  final DateTime createdAt;
  DateTime? closedAt;
  final attempts = <String, _Attempt>{}; // userId → urinish
}

class _Attempt {
  _Attempt(this.questionIds, this.startedAt);

  final List<String> questionIds;
  final DateTime startedAt;
  final answers = <String, int>{};
  DateTime? submittedAt;
  int? score;
  bool expired = false;
}

/// Server o‘rnidagi xotira modeli — SQL funksiyalaridagi qoidalarning nusxasi
/// (kod alifbosi, taxallus, 200 chegara, variant tanlovi, vaqt oynasi +
/// imtiyoz, javoblarni ochish, rate limit). Demo rejim va testlar uchun;
/// **productionga ulanmaydi**. Bir nechta foydalanuvchi bitta backend ustida
/// [FakeClassGroupsService] ko‘rinishlari orqali ishlaydi.
class FakeClassGroupsBackend {
  FakeClassGroupsBackend({
    required this.topics,
    Set<String>? teachers,
    bool Function(String uid)? isTeacher,
    DateTime Function()? clock,
    Random? rng,
    this.demoStudents = 0,
  }) : _teacherFn = isTeacher ?? (teachers ?? <String>{}).contains,
       now = clock ?? DateTime.now,
       _rng = rng ?? Random();

  /// Savollar banki (ilova asseti) — mavzular.
  final Future<List<ClassBankTopic>> Function() topics;

  /// Ustoz roli (serverda — account_roles; demo’da — chaqiruvchi beradi).
  final bool Function(String uid) _teacherFn;
  final DateTime Function() now;
  final Random _rng;

  /// Demo: yangi guruhga shuncha «DEMO» talaba qo‘shiladi va berilgan testni
  /// asta-sekin yechadi (jonli panelni ko‘rsatish uchun).
  final int demoStudents;

  final _groups = <String, _Group>{};
  final _assignments = <String, _Assignment>{};
  final _joinAttempts = <String, List<DateTime>>{};

  static const _grace = Duration(seconds: GroupRules.graceSeconds);

  String _id() {
    final hex = [
      for (var i = 0; i < 16; i++)
        _rng.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ].join();
    final s =
        '${hex.substring(0, 8)}-${hex.substring(8, 12)}-4${hex.substring(13, 16)}-'
        '8${hex.substring(17, 20)}-${hex.substring(20, 32)}';
    return s;
  }

  String _code() {
    String c;
    do {
      c = String.fromCharCodes([
        for (var i = 0; i < GroupRules.codeLength; i++)
          GroupCode.alphabet.codeUnitAt(
            _rng.nextInt(GroupCode.alphabet.length),
          ),
      ]);
    } while (_groups.values.any((g) => g.code == c));
    return c;
  }

  bool _isTeacher(String uid) => _teacherFn(uid);

  bool _revealed(_Assignment a) =>
      a.closedAt != null ||
      (a.draft.reveal == RevealPolicy.afterDue &&
          a.draft.dueAt != null &&
          !now().isBefore(a.draft.dueAt!));

  DateTime? _windowEnd(_Assignment a, DateTime started) {
    final ends = <DateTime>[
      if (a.draft.dueAt != null) a.draft.dueAt!,
      if (a.draft.timeLimitMin != null)
        started.add(Duration(minutes: a.draft.timeLimitMin!)),
      if (a.closedAt != null) a.closedAt!,
    ];
    if (ends.isEmpty) return null;
    return ends.reduce((x, y) => x.isBefore(y) ? x : y);
  }

  void _finalize(_Assignment a, _Attempt t, {required bool expired}) {
    if (t.submittedAt != null) return;
    t.submittedAt = now();
    t.expired = expired;
    t.score = t.questionIds
        .where((q) => t.answers[q] == a.pool[q]!.correct)
        .length;
  }

  void _finalizeExpired(_Assignment a) {
    for (final t in a.attempts.values) {
      final end = _windowEnd(a, t.startedAt);
      if (t.submittedAt == null &&
          end != null &&
          end.add(_grace).isBefore(now())) {
        _finalize(a, t, expired: true);
      }
    }
  }

  GroupInfo _info(_Group g, {required bool withCode, String? nickname}) =>
      GroupInfo(
        id: g.id,
        name: g.name,
        memberCount: g.members.length,
        code: withCode ? g.code : null,
        nickname: nickname,
      );

  GroupAssignment _assignmentInfo(_Assignment a, {String? forUser}) {
    final t = forUser == null ? null : a.attempts[forUser];
    return GroupAssignment(
      id: a.id,
      groupId: a.groupId,
      topicId: a.topicId,
      topicTitle: a.topicTitle,
      questionCount: a.draft.questionCount,
      timeLimitMin: a.draft.timeLimitMin,
      dueAt: a.draft.dueAt,
      variantMode: a.draft.variantMode,
      reveal: a.draft.reveal,
      closed: a.closedAt != null,
      revealed: _revealed(a),
      createdAt: a.createdAt,
      serverNow: now(),
      poolSize: a.pool.length,
      started: a.attempts.length,
      finished: a.attempts.values.where((x) => x.submittedAt != null).length,
      myState: t == null
          ? MyTestState.notStarted
          : t.submittedAt == null
          ? MyTestState.solving
          : MyTestState.finished,
      myScore: t?.score,
      myTotal: t?.submittedAt == null ? null : t!.questionIds.length,
    );
  }

  // ------------------------------------------------------------- umumiy

  GroupCall<GroupList> list(String uid) => GroupCall.ok(
    GroupList(
      isTeacher: _isTeacher(uid),
      teaching: [
        for (final g in _groups.values.toList().reversed)
          if (g.teacherId == uid && _isTeacher(uid)) _info(g, withCode: true),
      ],
      member: [
        for (final g in _groups.values.toList().reversed)
          for (final m in g.members)
            if (m.userId == uid)
              _info(g, withCode: false, nickname: m.nickname),
      ],
    ),
  );

  GroupCall<GroupDetail> detail(String uid, String groupId) {
    final g = _groups[groupId];
    if (g == null) return const GroupCall.fail(GroupFailure.forbidden);
    final list = [
      for (final a in _assignments.values.toList().reversed)
        if (a.groupId == g.id) a,
    ];
    list.forEach(_finalizeExpired);
    if (g.teacherId == uid && _isTeacher(uid)) {
      return GroupCall.ok(
        GroupDetail(
          isTeacher: true,
          group: _info(g, withCode: true),
          members: [
            for (final m
                in [...g.members]..sort(
                  (a, b) => a.nickname.toLowerCase().compareTo(
                    b.nickname.toLowerCase(),
                  ),
                ))
              GroupMember(id: m.id, nickname: m.nickname),
          ],
          assignments: [for (final a in list) _assignmentInfo(a)],
        ),
      );
    }
    final me = g.members.where((m) => m.userId == uid).firstOrNull;
    if (me == null) return const GroupCall.fail(GroupFailure.forbidden);
    return GroupCall.ok(
      GroupDetail(
        isTeacher: false,
        group: _info(g, withCode: false),
        nickname: me.nickname,
        assignments: [for (final a in list) _assignmentInfo(a, forUser: uid)],
      ),
    );
  }

  // -------------------------------------------------------------- ustoz

  GroupCall<GroupInfo> create(String uid, String name) {
    if (!_isTeacher(uid)) return const GroupCall.fail(GroupFailure.forbidden);
    final n = name.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (n.length < GroupRules.nameMin || n.length > GroupRules.nameMax) {
      return const GroupCall.fail(GroupFailure.badName);
    }
    if (_groups.values.where((g) => g.teacherId == uid).length >= 30) {
      return const GroupCall.fail(GroupFailure.tooManyGroups);
    }
    final g = _Group(_id(), uid, n, _code(), now());
    _groups[g.id] = g;
    for (var i = 1; i <= demoStudents; i++) {
      g.members.add(_Member(_id(), 'demo-student-$i', 'DEMO $i', now()));
    }
    return GroupCall.ok(_info(g, withCode: true));
  }

  _Group? _owned(String uid, String groupId) {
    final g = _groups[groupId];
    return g != null && g.teacherId == uid && _isTeacher(uid) ? g : null;
  }

  _Assignment? _ownedAssignment(String uid, String aid) {
    final a = _assignments[aid];
    return a != null && _owned(uid, a.groupId) != null ? a : null;
  }

  GroupCall<void> removeMember(String uid, String groupId, String memberId) {
    final g = _owned(uid, groupId);
    if (g == null) return const GroupCall.fail(GroupFailure.forbidden);
    final m = g.members.where((x) => x.id == memberId).firstOrNull;
    if (m == null) return const GroupCall.fail(GroupFailure.notFound);
    g.members.remove(m);
    for (final a in _assignments.values) {
      if (a.groupId == g.id) a.attempts.remove(m.userId);
    }
    return const GroupCall.ok(null);
  }

  Future<GroupCall<GroupAssignment>> createAssignment(
    String uid,
    String groupId,
    AssignmentDraft d,
  ) async {
    final g = _owned(uid, groupId);
    if (g == null) return const GroupCall.fail(GroupFailure.forbidden);
    final topic = (await topics()).where((t) => t.id == d.topicId).firstOrNull;
    final pool = topic?.questions ?? const <ClassBankQuestion>[];
    final err = d.validate(poolSize: pool.length, now: now());
    if (err != null) {
      return GroupCall.fail(err, {
        'available': pool.length,
        'needed': d.questionCount * 2,
      });
    }
    final qs = <String, _Q>{};
    for (var i = 0; i < pool.length && i < 200; i++) {
      final b = pool[i];
      final perm = [0, 1, 2, 3]..shuffle(_rng);
      // Bankdagi barqaror id (yagona indeks bilan bir xil); demo
      // to‘plamda id yo‘q — mavzu + tartib raqami.
      final id = b.id.isNotEmpty
          ? b.id
          : '${d.topicId}#${(i + 1).toString().padLeft(3, '0')}';
      qs[id] = _Q(
        id,
        b.question,
        [for (final p in perm) b.options[p]],
        perm.indexOf(b.correctIndex),
        b.explanation,
        b.source,
      );
    }
    final a = _Assignment(
      id: _id(),
      groupId: g.id,
      topicId: d.topicId,
      topicTitle: topic!.title,
      draft: d,
      pool: qs,
      createdAt: now(),
    );
    _assignments[a.id] = a;
    // Demo talabalar: biri boshlaydi, biri tugatadi (jonli panel uchun).
    for (final m in g.members.where((m) => m.userId.startsWith('demo-'))) {
      final t = _start(a, m.userId);
      if (m.userId.endsWith('1')) {
        for (final q in t.questionIds) {
          t.answers[q] = _rng.nextBool() ? a.pool[q]!.correct : 0;
        }
        _finalize(a, t, expired: false);
      }
    }
    return GroupCall.ok(_assignmentInfo(a));
  }

  GroupCall<void> closeAssignment(String uid, String aid) {
    final a = _ownedAssignment(uid, aid);
    if (a == null) return const GroupCall.fail(GroupFailure.forbidden);
    a.closedAt ??= now();
    return const GroupCall.ok(null);
  }

  GroupCall<GroupBoard> board(String uid, String aid) {
    final a = _ownedAssignment(uid, aid);
    if (a == null) return const GroupCall.fail(GroupFailure.forbidden);
    _finalizeExpired(a);
    final g = _groups[a.groupId]!;
    final rows = [
      for (final m in g.members)
        () {
          final t = a.attempts[m.userId];
          return GroupBoardRow(
            memberId: m.id,
            nickname: m.nickname,
            state: t == null
                ? BoardState.joined
                : t.submittedAt == null
                ? BoardState.solving
                : BoardState.finished,
            score: t?.score,
            total: t?.submittedAt == null ? null : t!.questionIds.length,
            answered: t?.answers.length ?? 0,
          );
        }(),
    ]..sort(boardOrder);
    return GroupCall.ok(
      GroupBoard(
        assignment: _assignmentInfo(a),
        group: _info(g, withCode: true),
        rows: rows,
      ),
    );
  }

  /// Server `order by` bilan bir xil: tugatganlar ball bo‘yicha, keyin
  /// yechayotganlar, keyin qo‘shilganlar; teng bo‘lsa — taxallus.
  static int boardOrder(GroupBoardRow x, GroupBoardRow y) {
    int rank(GroupBoardRow r) => switch (r.state) {
      BoardState.finished => 0,
      BoardState.solving => 1,
      BoardState.joined => 2,
    };
    final c = rank(x).compareTo(rank(y));
    if (c != 0) return c;
    final s = (y.score ?? -1).compareTo(x.score ?? -1);
    if (s != 0) return s;
    return x.nickname.toLowerCase().compareTo(y.nickname.toLowerCase());
  }

  GroupCall<GroupPreview> preview(String uid, String aid) {
    final a = _ownedAssignment(uid, aid);
    if (a == null) return const GroupCall.fail(GroupFailure.forbidden);
    final ids = a.pool.keys.toList()..sort();
    return GroupCall.ok(
      GroupPreview(
        assignment: _assignmentInfo(a),
        pool: [
          for (final id in ids)
            GroupPoolQuestion(
              id: id,
              text: a.pool[id]!.text,
              options: a.pool[id]!.options,
              correctIndex: a.pool[id]!.correct,
              explanation: a.pool[id]!.explanation,
            ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------- talaba

  bool _bumpJoin(String uid) {
    final cutoff = now().subtract(const Duration(hours: 1));
    final l = (_joinAttempts[uid] ??= [])
      ..removeWhere((t) => t.isBefore(cutoff));
    l.add(now());
    return l.length <= 30;
  }

  GroupCall<GroupJoinInfo> join(
    String uid, {
    required String code,
    String? nickname,
    String? assignmentId,
  }) {
    if (!_bumpJoin(uid)) return const GroupCall.fail(GroupFailure.rateLimited);
    switch (GroupCode.check(code)) {
      case GroupCodeCheck.ambiguous:
        return const GroupCall.fail(GroupFailure.codeAmbiguous);
      case GroupCodeCheck.bad:
        return const GroupCall.fail(GroupFailure.badCode);
      case GroupCodeCheck.ok:
        break;
    }
    final c = GroupCode.clean(code);
    final g = _groups.values.where((x) => x.code == c).firstOrNull;
    if (g == null) return const GroupCall.fail(GroupFailure.notFound);
    final a = assignmentId == null ? null : _assignments[assignmentId];
    final aid = a != null && a.groupId == g.id ? a.id : null;
    if (g.teacherId == uid) {
      return GroupCall.ok(
        GroupJoinInfo(
          isTeacher: true,
          group: _info(g, withCode: true),
          assignmentId: aid,
        ),
      );
    }
    final me = g.members.where((m) => m.userId == uid).firstOrNull;
    if (me != null) {
      return GroupCall.ok(
        GroupJoinInfo(
          isTeacher: false,
          group: _info(g, withCode: false),
          nickname: me.nickname,
          alreadyMember: true,
          assignmentId: aid,
        ),
      );
    }
    final nick = ClassNickname.clean(nickname ?? '');
    if (nick.isEmpty) {
      return GroupCall.fail(GroupFailure.nicknameRequired, {
        'group_name': g.name,
      });
    }
    if (g.members.length >= GroupRules.maxMembers) {
      return const GroupCall.fail(GroupFailure.groupFull);
    }
    switch (ClassNickname.check(nick)) {
      case NicknameCheck.length:
        return const GroupCall.fail(GroupFailure.nickLength);
      case NicknameCheck.chars:
        return const GroupCall.fail(GroupFailure.nickChars);
      case NicknameCheck.blocked:
        return const GroupCall.fail(GroupFailure.nickBlocked);
      case NicknameCheck.ok:
        break;
    }
    if (g.members.any((m) => m.nickname.toLowerCase() == nick.toLowerCase())) {
      return const GroupCall.fail(GroupFailure.nickTaken);
    }
    final m = _Member(_id(), uid, nick, now());
    g.members.add(m);
    return GroupCall.ok(
      GroupJoinInfo(
        isTeacher: false,
        group: _info(g, withCode: false),
        nickname: nick,
        assignmentId: aid,
      ),
    );
  }

  GroupCall<void> leave(String uid, String groupId) {
    final g = _groups[groupId];
    final removed = g?.members.where((m) => m.userId == uid).toList() ?? [];
    if (removed.isEmpty) return const GroupCall.fail(GroupFailure.forbidden);
    g!.members.removeWhere((m) => m.userId == uid);
    return const GroupCall.ok(null);
  }

  _Assignment? _memberAssignment(String uid, String aid) {
    final a = _assignments[aid];
    if (a == null) return null;
    final g = _groups[a.groupId]!;
    return g.members.any((m) => m.userId == uid) ? a : null;
  }

  _Attempt _start(_Assignment a, String uid) => a.attempts[uid] ??= _Attempt(
    drawVariant(
      assignmentId: a.id,
      userId: a.draft.variantMode ? uid : commonUser,
      pool: a.pool.keys.toList()..sort(),
      count: a.draft.questionCount,
    ),
    now(),
  );

  GroupAttempt _attemptInfo(_Assignment a, _Attempt t) => GroupAttempt(
    assignment: _assignmentInfo(a),
    finished: t.submittedAt != null,
    questions: t.submittedAt != null
        ? const []
        : [
            for (final id in t.questionIds)
              GroupQuestion(
                id: id,
                text: a.pool[id]!.text,
                options: a.pool[id]!.options,
              ),
          ],
    answers: Map.of(t.answers),
    startedAt: t.startedAt,
    endsAt: _windowEnd(a, t.startedAt),
    serverNow: now(),
    score: t.score,
    total: t.submittedAt == null ? null : t.questionIds.length,
  );

  GroupCall<GroupAttempt> open(String uid, String aid) {
    final a = _memberAssignment(uid, aid);
    if (a == null) return const GroupCall.fail(GroupFailure.forbidden);
    _finalizeExpired(a);
    if (!a.attempts.containsKey(uid)) {
      if (a.closedAt != null) return const GroupCall.fail(GroupFailure.closed);
      final due = a.draft.dueAt;
      if (due != null && !now().isBefore(due)) {
        return const GroupCall.fail(GroupFailure.pastDue);
      }
    }
    return GroupCall.ok(_attemptInfo(a, _start(a, uid)));
  }

  bool _late(_Assignment a, _Attempt t) {
    final end = _windowEnd(a, t.startedAt);
    return end != null && now().isAfter(end.add(_grace));
  }

  void _merge(_Attempt t, Map<String, int> answers) {
    for (final e in answers.entries) {
      if (t.questionIds.contains(e.key) && e.value >= 0 && e.value <= 3) {
        t.answers[e.key] = e.value;
      }
    }
  }

  GroupCall<void> save(String uid, String aid, Map<String, int> answers) {
    final a = _memberAssignment(uid, aid);
    if (a == null) return const GroupCall.fail(GroupFailure.forbidden);
    final t = a.attempts[uid];
    if (t == null) return const GroupCall.fail(GroupFailure.notStarted);
    if (t.submittedAt != null) {
      return const GroupCall.fail(GroupFailure.alreadySubmitted);
    }
    if (_late(a, t)) return const GroupCall.fail(GroupFailure.timeOver);
    _merge(t, answers);
    return const GroupCall.ok(null);
  }

  GroupCall<GroupSubmitInfo> submit(
    String uid,
    String aid,
    Map<String, int> answers,
  ) {
    final a = _memberAssignment(uid, aid);
    if (a == null) return const GroupCall.fail(GroupFailure.forbidden);
    final t = a.attempts[uid];
    if (t == null) return const GroupCall.fail(GroupFailure.notStarted);
    if (t.submittedAt != null) {
      return const GroupCall.fail(GroupFailure.alreadySubmitted);
    }
    final late = _late(a, t);
    if (!late) _merge(t, answers);
    _finalize(a, t, expired: late);
    return GroupCall.ok(
      GroupSubmitInfo(
        score: t.score!,
        total: t.questionIds.length,
        late: late,
        revealed: _revealed(a),
      ),
    );
  }

  GroupCall<GroupTestResult> result(String uid, String aid) {
    final a = _memberAssignment(uid, aid);
    if (a == null) return const GroupCall.fail(GroupFailure.forbidden);
    _finalizeExpired(a);
    final t = a.attempts[uid];
    if (t == null || t.submittedAt == null) {
      return const GroupCall.fail(GroupFailure.notSubmitted);
    }
    final rev = _revealed(a);
    return GroupCall.ok(
      GroupTestResult(
        assignment: _assignmentInfo(a, forUser: uid),
        score: t.score!,
        total: t.questionIds.length,
        revealed: rev,
        expired: t.expired,
        items: [
          for (final id in t.questionIds)
            GroupResultItem(
              id: id,
              text: a.pool[id]!.text,
              options: a.pool[id]!.options,
              myAnswer: t.answers[id],
              correctIndex: rev ? a.pool[id]!.correct : null,
              isCorrect: rev ? t.answers[id] == a.pool[id]!.correct : null,
              explanation: rev ? a.pool[id]!.explanation : '',
              source: rev ? a.pool[id]!.source : null,
            ),
        ],
      ),
    );
  }

  /// Demo/test: talaba qo‘shish (xuddi QR bilan qo‘shilgandek).
  String? codeOf(String groupId) => _groups[groupId]?.code;
}

/// Bitta foydalanuvchi ko‘rinishi ([FakeClassGroupsBackend] ustida).
class FakeClassGroupsService implements ClassGroupsService {
  FakeClassGroupsService(
    this.backend, {
    required this.userIdOf,
    this.demo = true,
  });

  final FakeClassGroupsBackend backend;

  /// Hozirgi foydalanuvchi (kirmagan bo‘lsa — `null`).
  final String? Function() userIdOf;

  /// Demo belgisi (testlar va kadrlar uchun o‘chiriladi).
  final bool demo;

  @override
  bool get isConfigured => true;
  @override
  bool get isDemo => demo;
  @override
  String? get userId => userIdOf();

  Future<GroupCall<T>> _as<T>(GroupCall<T> Function(String uid) f) async {
    final uid = userIdOf();
    if (uid == null) return GroupCall<T>.fail(GroupFailure.notSignedIn);
    return f(uid);
  }

  @override
  Future<GroupCall<GroupList>> list() => _as(backend.list);
  @override
  Future<GroupCall<GroupDetail>> detail(String groupId) =>
      _as((u) => backend.detail(u, groupId));
  @override
  Future<GroupCall<GroupInfo>> create(String name) =>
      _as((u) => backend.create(u, name));
  @override
  Future<GroupCall<void>> removeMember(String groupId, String memberId) =>
      _as((u) => backend.removeMember(u, groupId, memberId));
  @override
  Future<GroupCall<GroupAssignment>> createAssignment(
    String groupId,
    AssignmentDraft draft,
  ) async {
    final uid = userIdOf();
    if (uid == null) return const GroupCall.fail(GroupFailure.notSignedIn);
    return backend.createAssignment(uid, groupId, draft);
  }

  @override
  Future<GroupCall<void>> closeAssignment(String assignmentId) =>
      _as((u) => backend.closeAssignment(u, assignmentId));
  @override
  Future<GroupCall<GroupBoard>> board(String assignmentId) =>
      _as((u) => backend.board(u, assignmentId));
  @override
  Future<GroupCall<GroupPreview>> preview(String assignmentId) =>
      _as((u) => backend.preview(u, assignmentId));
  @override
  Future<GroupCall<GroupJoinInfo>> join({
    required String code,
    String? nickname,
    String? assignmentId,
  }) => _as(
    (u) => backend.join(
      u,
      code: code,
      nickname: nickname,
      assignmentId: assignmentId,
    ),
  );
  @override
  Future<GroupCall<void>> leave(String groupId) =>
      _as((u) => backend.leave(u, groupId));
  @override
  Future<GroupCall<GroupAttempt>> open(String assignmentId) =>
      _as((u) => backend.open(u, assignmentId));
  @override
  Future<GroupCall<void>> save(String assignmentId, Map<String, int> answers) =>
      _as((u) => backend.save(u, assignmentId, answers));
  @override
  Future<GroupCall<GroupSubmitInfo>> submit(
    String assignmentId,
    Map<String, int> answers,
  ) => _as((u) => backend.submit(u, assignmentId, answers));
  @override
  Future<GroupCall<GroupTestResult>> result(String assignmentId) =>
      _as((u) => backend.result(u, assignmentId));
}
