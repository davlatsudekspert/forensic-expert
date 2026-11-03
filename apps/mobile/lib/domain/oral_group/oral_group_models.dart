/// «Guruh og‘zaki imtihoni» (QR) modellari. Server:
/// `supabase/migrations/20261103010000_oral_sessions.sql`.
///
/// Javob kaliti serverga YUBORILMAYDI: biletda faqat savol id’si va matni.
/// Talaba faqat o‘z balini ko‘radi; doskada ball yo‘q.
library;

import 'package:flutter/foundation.dart';

import '../class_quiz/class_quiz_models.dart' show ClassCode, ClassFailure;

int _int(Object? v, [int d = 0]) => v is num ? v.toInt() : d;
String _str(Object? v, [String d = '']) => v is String ? v : d;
List<Object?> _list(Object? v) => v is List ? v : const [];
Map<String, Object?> _map(Object? v) =>
    v is Map ? v.cast<String, Object?>() : const {};
DateTime? _time(Object? v) =>
    v is String ? DateTime.tryParse(v)?.toUtc() : null;

/// Qoidalar (server bilan bir xil).
abstract final class OralGroupRules {
  static const questionsPerTicket = 5;
  static const minStudents = 1;
  static const maxStudents = 200;
  static const defaultStudents = 25;
  static const maxPrepMinutes = 60;
  static const prepChoicesMinutes = [0, 5, 10, 15, 20, 30];
  static const nameMin = 2;
  static const nameMax = 40;
  static const maxScore = 20;
  static const idMax = 160;
  static const textMax = 500;
}

/// Server xato kodi → [ClassFailure] (ism xatolari talaba-laqab xatolariga
/// moslanadi; matnni UI o‘zi tanlaydi).
ClassFailure oralFailureFromServer(Object? code) => switch (code) {
  'name_length' => ClassFailure.nickLength,
  'name_chars' => ClassFailure.nickChars,
  'name_blocked' => ClassFailure.nickBlocked,
  'invalid_ticket' => ClassFailure.invalidTicket,
  'invalid_scores' => ClassFailure.invalidScores,
  'not_joined' => ClassFailure.notJoined,
  'not_allowed' => ClassFailure.notAllowed,
  'try_again' => ClassFailure.tryAgain,
  _ => ClassFailure.fromServer(code),
};

/// Ism tekshiruvi (server `oral_name_check` ning mijoz tomoni: faqat uzunlik).
abstract final class OralName {
  /// Ortiqcha bo‘shliqlar bitta bo‘shliqqa.
  static String clean(String raw) => raw.trim().replaceAll(RegExp(r'\s+'), ' ');

  static bool validLength(String cleaned) {
    final n = cleaned.runes.length;
    return n >= OralGroupRules.nameMin && n <= OralGroupRules.nameMax;
  }

  /// Profil ismidan taklif (40 belgigacha); bo‘sh bo‘lsa — bo‘sh.
  static String fromProfile(String? fullName) {
    final c = clean(fullName ?? '');
    if (c.runes.length <= OralGroupRules.nameMax) return c;
    return String.fromCharCodes(c.runes.take(OralGroupRules.nameMax)).trim();
  }
}

/// QR havolasi: kod «Guruh testi» kodlari bilan to‘qnashmaydi, shuning uchun
/// havola umumiy `/join/<kod>` shaklida; `t=oral` belgisi to‘g‘ridan-to‘g‘ri
/// og‘zaki imtihon qo‘shilish ekranini ochadi.
abstract final class OralGroupLink {
  static const marker = 'oral';

  /// Skaner ekrani `back=1` bilan ochilganda oral havola natijasi: `oral:<kod>`.
  static const scanPrefix = 'oral:';

  /// `oral:<kod>` natijasidan kod (aks holda `null`).
  static String? codeFromScanResult(String? r) =>
      r != null && r.startsWith(scanPrefix)
      ? ClassCode.normalize(r.substring(scanPrefix.length))
      : null;

  static Uri joinLink(String code) => Uri(
    scheme: 'forensicexpert',
    host: 'app',
    path: '/join/$code',
    queryParameters: const {'t': marker},
  );

  static bool isOral(Uri uri) => uri.queryParameters['t'] == marker;

  /// Skanerlangan matn oral havola bo‘lsa — uning kodi, aks holda `null`
  /// (oddiy 6 raqam yoki «Guruh testi» havolasi oral emas).
  static String? codeFromScanned(String? text) {
    if (text == null) return null;
    final uri = Uri.tryParse(text.trim());
    if (uri == null || !isOral(uri)) return null;
    return ClassCode.extract(uri);
  }
}

enum OralGroupStatus {
  open,
  finished;

  static OralGroupStatus parse(Object? v) => v == 'finished' ? finished : open;
}

@immutable
class OralGroupQuestion {
  const OralGroupQuestion({required this.id, required this.text});

  factory OralGroupQuestion.fromJson(Map<String, Object?> j) =>
      OralGroupQuestion(id: _str(j['id']), text: _str(j['text']));

  final String id;
  final String text;

  /// Serverga yuboriladigan shakl (uzunlik chegaralari bilan).
  Map<String, Object?> toJson() => {
    'id': _clip(id, OralGroupRules.idMax),
    'text': _clip(text, OralGroupRules.textMax),
  };

  static String _clip(String s, int max) =>
      s.runes.length <= max ? s : String.fromCharCodes(s.runes.take(max));

  @override
  bool operator ==(Object other) =>
      other is OralGroupQuestion && other.id == id && other.text == text;

  @override
  int get hashCode => Object.hash(id, text);
}

@immutable
class OralGroupTicket {
  const OralGroupTicket({required this.no, required this.questions});

  factory OralGroupTicket.fromJson(Map<String, Object?> j) => OralGroupTicket(
    no: _int(j['no']),
    questions: [
      for (final q in _list(j['questions']))
        OralGroupQuestion.fromJson(_map(q)),
    ],
  );

  final int no;
  final List<OralGroupQuestion> questions;
}

@immutable
class OralGroupSession {
  const OralGroupSession({
    required this.id,
    required this.code,
    this.title = '',
    this.status = OralGroupStatus.open,
    this.ticketCount = 0,
    this.prepSeconds = 0,
    this.createdAt,
    this.finishedAt,
    this.joined = 0,
    this.graded = 0,
  });

  factory OralGroupSession.fromJson(Map<String, Object?> j) => OralGroupSession(
    id: _str(j['id']),
    code: _str(j['code']),
    title: _str(j['title']),
    status: OralGroupStatus.parse(j['status']),
    ticketCount: _int(j['ticket_count']),
    prepSeconds: _int(j['prep_seconds']),
    createdAt: _time(j['created_at']),
    finishedAt: _time(j['finished_at']),
    joined: _int(j['joined']),
    graded: _int(j['graded']),
  );

  final String id;
  final String code;
  final String title;
  final OralGroupStatus status;
  final int ticketCount;
  final int prepSeconds;
  final DateTime? createdAt;
  final DateTime? finishedAt;

  /// Faqat `oral_my_sessions` da: qo‘shilganlar va baholanganlar soni.
  final int joined;
  final int graded;

  bool get isOpen => status == OralGroupStatus.open;
}

@immutable
class OralGroupParticipant {
  const OralGroupParticipant({
    required this.id,
    required this.name,
    required this.ticketNo,
    this.joinedAt,
    this.readyAt,
    this.calledAt,
    this.scores,
    this.gradedAt,
    this.leaveCount = 0,
    this.lastLeftAt,
  });

  factory OralGroupParticipant.fromJson(Map<String, Object?> j) {
    final sc = j['scores'];
    return OralGroupParticipant(
      id: _str(j['id']),
      name: _str(j['name']),
      ticketNo: _int(j['ticket_no']),
      joinedAt: _time(j['joined_at']),
      readyAt: _time(j['ready_at']),
      calledAt: _time(j['called_at']),
      scores: sc is List ? [for (final x in sc) _int(x)] : null,
      gradedAt: _time(j['graded_at']),
      leaveCount: _int(j['leave_count']),
      lastLeftAt: _time(j['last_left_at']),
    );
  }

  final String id;
  final String name;
  final int ticketNo;
  final DateTime? joinedAt;
  final DateTime? readyAt;
  final DateTime? calledAt;
  final List<int>? scores;
  final DateTime? gradedAt;

  /// Ilovadan chiqishlar soni va oxirgisi (anti-cheat belgisi, ayb emas).
  final int leaveCount;
  final DateTime? lastLeftAt;

  bool get isGraded => gradedAt != null;
  bool get isReady => readyAt != null;
  bool get isCalled => calledAt != null;
  int? get total => scores?.fold<int>(0, (a, b) => a + b);
}

/// Ustoz ko‘rinishi: sessiya, biletlar va talabalar.
@immutable
class OralGroupTeacherState {
  const OralGroupTeacherState({
    required this.session,
    required this.tickets,
    required this.participants,
  });

  factory OralGroupTeacherState.fromJson(Map<String, Object?> j) =>
      OralGroupTeacherState(
        session: OralGroupSession.fromJson(_map(j['session'])),
        tickets: [
          for (final t in _list(j['tickets']))
            OralGroupTicket.fromJson(_map(t)),
        ],
        participants: [
          for (final p in _list(j['participants']))
            OralGroupParticipant.fromJson(_map(p)),
        ],
      );

  final OralGroupSession session;
  final List<OralGroupTicket> tickets;
  final List<OralGroupParticipant> participants;

  OralGroupTicket? ticket(int no) {
    for (final t in tickets) {
      if (t.no == no) return t;
    }
    return null;
  }

  OralGroupParticipant? participantByTicket(int no) {
    for (final p in participants) {
      if (p.ticketNo == no) return p;
    }
    return null;
  }

  OralGroupParticipant? participant(String id) {
    for (final p in participants) {
      if (p.id == id) return p;
    }
    return null;
  }

  int get gradedCount => participants.where((p) => p.isGraded).length;
}

@immutable
class OralGroupJoinInfo {
  const OralGroupJoinInfo({required this.participantId, required this.session});

  factory OralGroupJoinInfo.fromJson(Map<String, Object?> j) =>
      OralGroupJoinInfo(
        participantId: _str(j['participant_id']),
        session: OralGroupSession.fromJson(_map(j['session'])),
      );

  final String participantId;
  final OralGroupSession session;
}

/// Talaba ko‘rinishi: o‘z bileti, holati va (baholangach) o‘z bali.
@immutable
class OralGroupMyState {
  const OralGroupMyState({
    required this.session,
    required this.name,
    required this.ticketNo,
    required this.questions,
    this.joinedAt,
    this.readyAt,
    this.calledAt,
    this.gradedAt,
    this.scores,
    this.total,
    this.serverNow,
    this.leaveCount = 0,
  });

  factory OralGroupMyState.fromJson(Map<String, Object?> j) {
    final sc = j['scores'];
    return OralGroupMyState(
      session: OralGroupSession.fromJson(_map(j['session'])),
      name: _str(j['name']),
      ticketNo: _int(j['ticket_no']),
      questions: [
        for (final q in _list(j['questions']))
          OralGroupQuestion.fromJson(_map(q)),
      ],
      joinedAt: _time(j['joined_at']),
      readyAt: _time(j['ready_at']),
      calledAt: _time(j['called_at']),
      gradedAt: _time(j['graded_at']),
      scores: sc is List ? [for (final x in sc) _int(x)] : null,
      total: j['total'] is num ? _int(j['total']) : null,
      serverNow: _time(j['server_now']),
      leaveCount: _int(j['leave_count']),
    );
  }

  final OralGroupSession session;
  final String name;
  final int ticketNo;
  final List<OralGroupQuestion> questions;
  final DateTime? joinedAt;
  final DateTime? readyAt;
  final DateTime? calledAt;
  final DateTime? gradedAt;
  final List<int>? scores;
  final int? total;
  final DateTime? serverNow;
  final int leaveCount;

  bool get isGraded => gradedAt != null;
  bool get isReady => readyAt != null;
  bool get isCalled => calledAt != null;

  /// Tayyorgarlik qolgan vaqti: `joined_at + prep_seconds - server_now`.
  /// [localNow] — qurilma soati; [serverNow] bilan farq (soat siljishi)
  /// tuzatiladi. Tayyorgarlik yo‘q yoki tugagan bo‘lsa — `Duration.zero`.
  Duration prepRemaining({
    required DateTime localNow,
    required DateTime fetchedLocalAt,
  }) {
    final joined = joinedAt;
    final prep = session.prepSeconds;
    if (joined == null || prep <= 0) return Duration.zero;
    // Server soati bo‘yicha “hozir”: serverNow + (localNow - fetchedLocalAt).
    final srv = serverNow;
    final now = srv == null
        ? localNow
        : srv.add(localNow.difference(fetchedLocalAt));
    final left = joined.add(Duration(seconds: prep)).difference(now);
    return left.isNegative ? Duration.zero : left;
  }
}

/// Natijalar CSV (ustoz uchun; tillanadigan sarlavhalar UI’dan keladi).
abstract final class OralGroupCsv {
  /// Formula in’yeksiyasidan himoya va tirnoqlash.
  static String cell(String v) {
    var s = v.replaceAll('\r', ' ').replaceAll('\n', ' ');
    if (s.isNotEmpty && '=+-@\t'.contains(s[0])) s = "'$s";
    if (s.contains(',') || s.contains('"') || s.contains(';')) {
      s = '"${s.replaceAll('"', '""')}"';
    }
    return s;
  }

  /// Baholanganlar ro‘yxati (bilet raqami bo‘yicha). Baholanmaganlar
  /// ball ustunlari bo‘sh holda chiqadi.
  static String build(
    List<OralGroupParticipant> participants, {
    required String nameLabel,
    required String ticketLabel,
    required String totalLabel,
    required String Function(int n) questionLabel,
  }) {
    final rows = [...participants]..sort((a, b) => a.ticketNo - b.ticketNo);
    const n = OralGroupRules.questionsPerTicket;
    final b = StringBuffer(
      [
        cell(nameLabel),
        cell(ticketLabel),
        for (var i = 1; i <= n; i++) cell(questionLabel(i)),
        cell(totalLabel),
      ].join(','),
    )..write('\r\n');
    for (final p in rows) {
      final sc = p.scores;
      b.write(
        [
          cell(p.name),
          '${p.ticketNo}',
          for (var i = 0; i < n; i++)
            sc != null && i < sc.length ? '${sc[i]}' : '',
          sc == null ? '' : '${p.total}',
        ].join(','),
      );
      b.write('\r\n');
    }
    return b.toString();
  }

  /// `og_zaki_imtihon_123456_2026-11-03.csv` — faqat ASCII.
  static String fileName(String code, DateTime date) {
    final d = date.toIso8601String().substring(0, 10);
    final c = code.replaceAll(RegExp(r'[^0-9]'), '');
    return 'og_zaki_imtihon_${c.isEmpty ? 'sessiya' : c}_$d.csv';
  }
}

/// Talabaning oxirgi guruh og‘zaki imtihoni (qurilmada): «Davom etish» uchun.
@immutable
class OralResume {
  const OralResume({
    required this.userKey,
    required this.code,
    required this.sessionId,
  });

  factory OralResume.fromJson(Map<String, Object?> j) => OralResume(
    userKey: _str(j['user']),
    code: _str(j['code']),
    sessionId: _str(j['session']),
  );

  /// Hisob id’si (kirmagan bo‘lsa bo‘sh) — boshqa foydalanuvchiga ko‘rinmaydi.
  final String userKey;
  final String code;
  final String sessionId;

  Map<String, Object?> toJson() => {
    'user': userKey,
    'code': code,
    'session': sessionId,
  };
}
