import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import '../../domain/ports/backend_ports.dart';
import '../../domain/ports/student_card_ports.dart';
import '../../domain/student_card/student_card.dart';
import '../../domain/teacher_card/teacher_card.dart' show TeacherImageKind;
import 'supabase_rest.dart';

/// «Talaba kartasi» uchun Supabase adapteri.
///
/// RPC (SECURITY DEFINER, `supabase/migrations/20261031040000_student_card.sql`):
/// `student_card_get_mine`, `student_card_upsert`, `student_card_delete`,
/// `student_cards_for_group`, `student_card_hide_for_me`,
/// `group_student_card_hide`. Rasm — xususiy `student-cards` bucket
/// (`<uid>/photo-<uuid>.<ext>`): yuklash/o‘chirish — egasi, o‘qish — Storage
/// RLS (egasi, guruh ustozi yoki guruhdosh; yashirilgan bo‘lsa yopiq);
/// ommaviy yoki imzolangan URL ishlatilmaydi. Jadvalga to‘g‘ridan-to‘g‘ri
/// kirish yo‘q. Kutilgan xatolar `{ok:false,error}`; huquq xatosi HTTP 403.
class SupabaseStudentCardService implements StudentCardService {
  SupabaseStudentCardService({
    required SupabaseConfig config,
    required this.auth,
    RestTransport? transport,
    BytesFetcher? fetcher,
    Random? random,
  }) : _cfg = config,
       _http = transport ?? HttpClientTransport(),
       _fetcher =
           fetcher ??
           (transport == null ? HttpClientTransport() : _NoFetcher()),
       _random = random ?? Random.secure();

  static const bucket = 'student-cards';

  final SupabaseConfig _cfg;
  final AuthRepository auth;
  final RestTransport _http;
  final BytesFetcher _fetcher;
  final Random _random;

  @override
  bool get isConfigured => true;

  Future<StudentCardResult<Map<String, Object?>>> _call(
    String method,
    String path, {
    Map<String, Object?>? json,
    List<int>? bytes,
    String? contentType,
    bool storage = false,
  }) async {
    if (!auth.current.signedIn) {
      return const StudentCardResult.fail(StudentCardFailure.notSignedIn);
    }
    final token = await auth.accessToken();
    if (token == null) {
      return const StudentCardResult.fail(StudentCardFailure.notSignedIn);
    }
    try {
      final r = await _http.send(
        method,
        _cfg.url.resolve(path),
        headers: {'apikey': _cfg.anonKey, 'Authorization': 'Bearer $token'},
        jsonBody: json,
        bytes: bytes,
        contentType: contentType,
      );
      if (r.status == 401) {
        return const StudentCardResult.fail(StudentCardFailure.notSignedIn);
      }
      if (r.status == 403) {
        return const StudentCardResult.fail(StudentCardFailure.forbidden);
      }
      // RPC yo‘q — migratsiya hali qo‘llanmagan.
      if (r.status == 404 && !storage) {
        return const StudentCardResult.fail(StudentCardFailure.notConfigured);
      }
      if (!r.ok) return const StudentCardResult.fail(StudentCardFailure.server);
      final m = r.map;
      if (m['ok'] == false) {
        return StudentCardResult.fail(
          StudentCardFailure.fromServer(m['error']),
        );
      }
      return StudentCardResult.ok(m);
    } on SocketException {
      return const StudentCardResult.fail(StudentCardFailure.offline);
    } on TimeoutException {
      return const StudentCardResult.fail(StudentCardFailure.offline);
    } on HandshakeException {
      return const StudentCardResult.fail(StudentCardFailure.offline);
    }
  }

  Future<StudentCardResult<Map<String, Object?>>> _rpc(
    String name,
    Map<String, Object?> body,
  ) => _call('POST', 'rest/v1/rpc/$name', json: body);

  StudentCardResult<StudentCard?> _card(
    StudentCardResult<Map<String, Object?>> r,
  ) {
    final v = r.value;
    if (v == null) return StudentCardResult.fail(r.failure!);
    try {
      final c = v['card'];
      return StudentCardResult.ok(
        c is Map ? StudentCard.fromJson(c.cast<String, Object?>()) : null,
      );
    } on Object {
      return const StudentCardResult.fail(StudentCardFailure.server);
    }
  }

  @override
  Future<StudentCardResult<StudentCard?>> mine() async =>
      _card(await _rpc('student_card_get_mine', const {}));

  @override
  Future<StudentCardResult<StudentGroupCards>> forGroup(String groupId) async {
    final r = await _rpc('student_cards_for_group', {'p_group': groupId});
    final v = r.value;
    if (v == null) return StudentCardResult.fail(r.failure!);
    try {
      return StudentCardResult.ok(StudentGroupCards.fromJson(v));
    } on Object {
      return const StudentCardResult.fail(StudentCardFailure.server);
    }
  }

  @override
  Future<StudentCardResult<void>> hideForMe(
    String studentId, {
    bool hide = true,
  }) async {
    final r = await _rpc('student_card_hide_for_me', {
      'p_student': studentId,
      'p_hide': hide,
    });
    return r.ok
        ? const StudentCardResult.ok(null)
        : StudentCardResult.fail(r.failure!);
  }

  @override
  Future<StudentCardResult<void>> hideInGroup(
    String groupId,
    String studentId, {
    bool hide = true,
    String? reason,
  }) async {
    final r = await _rpc('group_student_card_hide', {
      'p_group': groupId,
      'p_student': studentId,
      'p_hide': hide,
      'p_reason': reason,
    });
    return r.ok
        ? const StudentCardResult.ok(null)
        : StudentCardResult.fail(r.failure!);
  }

  /// RFC 4122 v4 (kriptografik tasodifiy) — fayl nomi uchun.
  String _uuid() {
    final b = List<int>.generate(16, (_) => _random.nextInt(256));
    b[6] = (b[6] & 0x0f) | 0x40;
    b[8] = (b[8] & 0x3f) | 0x80;
    final h = b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();
    return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-'
        '${h.substring(16, 20)}-${h.substring(20)}';
  }

  Future<StudentCardResult<String>> _upload(String uid, Uint8List bytes) async {
    final type = TeacherImageKind.of(bytes);
    if (type == null) {
      return const StudentCardResult.fail(StudentCardFailure.invalidImage);
    }
    if (bytes.length > StudentCardLimits.imageBytes) {
      return const StudentCardResult.fail(StudentCardFailure.imageTooLarge);
    }
    final path = '$uid/photo-${_uuid()}.${type.ext}';
    final r = await _call(
      'POST',
      'storage/v1/object/$bucket/$path',
      bytes: bytes,
      contentType: type.mime,
      storage: true,
    );
    if (!r.ok) return StudentCardResult.fail(r.failure!);
    return StudentCardResult.ok(path);
  }

  Future<void> _remove(String? path) async {
    if (path == null || path.isEmpty) return;
    try {
      await _call('DELETE', 'storage/v1/object/$bucket/$path', storage: true);
    } on Object {
      // Eski fayl qolib ketishi mumkin; hisob o‘chirilganda baribir tozalanadi.
    }
  }

  @override
  Future<StudentCardResult<StudentCard>> save(
    StudentCardDraft draft, {
    StudentCard? previous,
  }) async {
    final uid = auth.current.userId;
    if (!auth.current.signedIn || uid == null || uid.isEmpty) {
      return const StudentCardResult.fail(StudentCardFailure.notSignedIn);
    }
    final err = draft.error;
    if (err != null) {
      return StudentCardResult.fail(StudentCardFailure.fromDraft(err));
    }
    String? photo = draft.removePhoto ? null : previous?.photoPath;
    String? uploaded;
    Future<StudentCardResult<StudentCard>> fail(StudentCardFailure f) async {
      await _remove(uploaded);
      return StudentCardResult.fail(f);
    }

    if (draft.photo != null) {
      final r = await _upload(uid, draft.photo!);
      if (!r.ok) return fail(r.failure!);
      photo = r.value;
      uploaded = photo;
    }
    final r = await _rpc('student_card_upsert', {
      'p_display_name': draft.displayName.trim(),
      'p_bio': draft.bio.trim(),
      'p_photo_path': photo,
      'p_visible': draft.visible,
    });
    if (!r.ok) return fail(r.failure!);
    final card = _card(r).value;
    if (card == null) return fail(StudentCardFailure.server);
    final old = previous?.photoPath;
    if (old != null && old != photo) await _remove(old);
    return StudentCardResult.ok(card);
  }

  @override
  Future<StudentCardResult<void>> delete() async {
    final r = await _rpc('student_card_delete', const {});
    final v = r.value;
    if (v == null) return StudentCardResult.fail(r.failure!);
    final p = v['photo_path'];
    if (p is String) await _remove(p);
    return const StudentCardResult.ok(null);
  }

  @override
  Future<Uint8List?> image(String path) async {
    if (!auth.current.signedIn) return null;
    final token = await auth.accessToken();
    if (token == null) return null;
    try {
      final b = await _fetcher.getBytes(
        _cfg.url.resolve('storage/v1/object/authenticated/$bucket/$path'),
        headers: {'apikey': _cfg.anonKey, 'Authorization': 'Bearer $token'},
        maxBytes: StudentCardLimits.imageBytes + 1024,
      );
      return b == null ? null : Uint8List.fromList(b);
    } on Object {
      return null;
    }
  }
}

class _NoFetcher implements BytesFetcher {
  @override
  Future<List<int>?> getBytes(
    Uri uri, {
    Map<String, String> headers = const {},
    int maxBytes = 0,
  }) async => null;
}
