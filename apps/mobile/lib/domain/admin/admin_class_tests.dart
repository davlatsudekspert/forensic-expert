import 'package:flutter/foundation.dart';

/// Admin: o‘tkazilgan test turi — jonli sinf yoki guruh vazifasi.
enum AdminClassTestKind {
  live('live'),
  assignment('assignment');

  const AdminClassTestKind(this.wire);

  final String wire;

  static AdminClassTestKind? parse(Object? v) => switch (v) {
    'live' => live,
    'assignment' => assignment,
    _ => null,
  };
}

/// Ro‘yxat qatori (`admin_class_tests`).
@immutable
class AdminClassTest {
  const AdminClassTest({
    required this.kind,
    required this.id,
    required this.at,
    required this.teacherName,
    required this.teacherEmail,
    required this.topicTitle,
    required this.questionCount,
    required this.participants,
    required this.finished,
    this.groupName,
    this.code,
    this.status = '',
    this.avgScore100,
  });

  final AdminClassTestKind kind;
  final String id;
  final DateTime? at;
  final String teacherName;
  final String teacherEmail;
  final String? groupName;
  final String? code;
  final String topicTitle;
  final String status;
  final int questionCount;

  /// Jonli sinf: qatnashganlar; vazifa: guruh a’zolari.
  final int participants;

  /// Yakunlaganlar (vazifa) yoki qatnashganlar (jonli sinf).
  final int finished;

  /// 100 ballik o‘rtacha; hech kim yakunlamagan bo‘lsa `null`.
  final double? avgScore100;

  static AdminClassTest? tryParse(Map<String, Object?> j) {
    final kind = AdminClassTestKind.parse(j['kind']);
    final id = j['id'];
    if (kind == null || id is! String || id.isEmpty) return null;
    String s(Object? v) => v is String ? v : '';
    int n(Object? v) => v is num ? v.toInt() : 0;
    final avg = j['avg_score100'];
    final group = s(j['group_name']);
    final code = s(j['code']);
    return AdminClassTest(
      kind: kind,
      id: id,
      at: DateTime.tryParse(s(j['at']))?.toLocal(),
      teacherName: s(j['teacher_name']),
      teacherEmail: s(j['teacher_email']),
      groupName: group.isEmpty ? null : group,
      code: code.isEmpty ? null : code,
      topicTitle: s(j['topic_title']),
      status: s(j['status']),
      questionCount: n(j['question_count']),
      participants: n(j['participants']),
      finished: n(j['finished']),
      avgScore100: avg is num ? avg.toDouble() : null,
    );
  }
}

/// Bitta test natijasi qatori (`admin_class_test_detail`).
@immutable
class AdminClassTestResult {
  const AdminClassTestResult({
    required this.nickname,
    this.correct,
    this.total,
    this.finishedAt,
  });

  final String nickname;

  /// Vazifani boshlamagan/yubormagan a’zoda `null`.
  final int? correct;
  final int? total;
  final DateTime? finishedAt;

  bool get done => correct != null && (total ?? 0) > 0;

  static AdminClassTestResult? tryParse(Map<String, Object?> j) {
    final nick = j['nickname'];
    if (nick is! String || nick.isEmpty) return null;
    final c = j['correct'];
    final t = j['total'];
    final f = j['finished_at'];
    return AdminClassTestResult(
      nickname: nick,
      correct: c is num ? c.toInt() : null,
      total: t is num ? t.toInt() : null,
      finishedAt: f is String ? DateTime.tryParse(f)?.toLocal() : null,
    );
  }
}
