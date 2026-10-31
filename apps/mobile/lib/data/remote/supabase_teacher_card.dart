import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import '../../domain/ports/backend_ports.dart';
import '../../domain/ports/teacher_card_ports.dart';
import '../../domain/teacher_card/teacher_card.dart';
import 'supabase_rest.dart';

/// «Ustoz kartasi» uchun Supabase adapteri.
///
/// RPC (SECURITY DEFINER, `supabase/migrations/20261031020000_teacher_card.sql`):
/// `teacher_card_get_mine`, `teacher_card_upsert`, `teacher_card_for_group`,
/// `teacher_card_delete` (`teacher_card_get(p_teacher)` ham mavjud, ilova
/// guruh orqali so‘raydi). Rasm/logotip — xususiy `teacher-cards` bucket
/// (`<uid>/(photo|logo)-<uuid>.<ext>`): yuklash/o‘chirish — egasi, o‘qish —
/// Storage RLS (egasi yoki kartasi ko‘rinadigan ustozning guruh a’zosi);
/// ommaviy yoki imzolangan URL ishlatilmaydi. Jadvalga to‘g‘ridan-to‘g‘ri
/// kirish yo‘q. Kutilgan xatolar `{ok:false,error}`; huquq xatosi HTTP 403.
class SupabaseTeacherCardService implements TeacherCardService {
  SupabaseTeacherCardService({
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

  static const bucket = 'teacher-cards';

  final SupabaseConfig _cfg;
  final AuthRepository auth;
  final RestTransport _http;
  final BytesFetcher _fetcher;
  final Random _random;

  @override
  bool get isConfigured => true;

  Future<TeacherCardResult<Map<String, Object?>>> _call(
    String method,
    String path, {
    Map<String, Object?>? json,
    List<int>? bytes,
    String? contentType,
    bool storage = false,
  }) async {
    if (!auth.current.signedIn) {
      return const TeacherCardResult.fail(TeacherCardFailure.notSignedIn);
    }
    final token = await auth.accessToken();
    if (token == null) {
      return const TeacherCardResult.fail(TeacherCardFailure.notSignedIn);
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
        return const TeacherCardResult.fail(TeacherCardFailure.notSignedIn);
      }
      if (r.status == 403) {
        return const TeacherCardResult.fail(TeacherCardFailure.forbidden);
      }
      // RPC yo‘q — migratsiya hali qo‘llanmagan.
      if (r.status == 404 && !storage) {
        return const TeacherCardResult.fail(TeacherCardFailure.notConfigured);
      }
      if (!r.ok) {
        // Storage RLS rad etsa 400/403 qaytaradi: rasm yuklanmadi.
        return const TeacherCardResult.fail(TeacherCardFailure.server);
      }
      final m = r.map;
      if (m['ok'] == false) {
        return TeacherCardResult.fail(
          TeacherCardFailure.fromServer(m['error']),
        );
      }
      return TeacherCardResult.ok(m);
    } on SocketException {
      return const TeacherCardResult.fail(TeacherCardFailure.offline);
    } on TimeoutException {
      return const TeacherCardResult.fail(TeacherCardFailure.offline);
    } on HandshakeException {
      return const TeacherCardResult.fail(TeacherCardFailure.offline);
    }
  }

  Future<TeacherCardResult<Map<String, Object?>>> _rpc(
    String name,
    Map<String, Object?> body,
  ) => _call('POST', 'rest/v1/rpc/$name', json: body);

  TeacherCardResult<TeacherCard?> _card(
    TeacherCardResult<Map<String, Object?>> r,
  ) {
    final v = r.value;
    if (v == null) return TeacherCardResult.fail(r.failure!);
    try {
      final c = v['card'];
      return TeacherCardResult.ok(
        c is Map ? TeacherCard.fromJson(c.cast<String, Object?>()) : null,
      );
    } on Object {
      return const TeacherCardResult.fail(TeacherCardFailure.server);
    }
  }

  @override
  Future<TeacherCardResult<TeacherCard?>> mine() async =>
      _card(await _rpc('teacher_card_get_mine', const {}));

  @override
  Future<TeacherCardResult<TeacherCard?>> forGroup(String groupId) async =>
      _card(await _rpc('teacher_card_for_group', {'p_group': groupId}));

  /// RFC 4122 v4 (kriptografik tasodifiy) — fayl nomi uchun.
  String _uuid() {
    final b = List<int>.generate(16, (_) => _random.nextInt(256));
    b[6] = (b[6] & 0x0f) | 0x40;
    b[8] = (b[8] & 0x3f) | 0x80;
    final h = b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();
    return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-'
        '${h.substring(16, 20)}-${h.substring(20)}';
  }

  /// Rasmni yuklaydi; storage yo‘li yoki xato.
  Future<TeacherCardResult<String>> _upload(
    String uid,
    String kind,
    Uint8List bytes,
  ) async {
    final type = TeacherImageKind.of(bytes);
    if (type == null) {
      return const TeacherCardResult.fail(TeacherCardFailure.invalidImage);
    }
    if (bytes.length > TeacherCardLimits.imageBytes) {
      return const TeacherCardResult.fail(TeacherCardFailure.imageTooLarge);
    }
    final path = '$uid/$kind-${_uuid()}.${type.ext}';
    final r = await _call(
      'POST',
      'storage/v1/object/$bucket/$path',
      bytes: bytes,
      contentType: type.mime,
      storage: true,
    );
    if (!r.ok) return TeacherCardResult.fail(r.failure!);
    return TeacherCardResult.ok(path);
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
  Future<TeacherCardResult<TeacherCard>> save(
    TeacherCardDraft draft, {
    TeacherCard? previous,
  }) async {
    final uid = auth.current.userId;
    if (!auth.current.signedIn || uid == null || uid.isEmpty) {
      return const TeacherCardResult.fail(TeacherCardFailure.notSignedIn);
    }
    final err = draft.error;
    if (err != null) {
      return TeacherCardResult.fail(switch (err) {
        TeacherCardDraftError.name => TeacherCardFailure.invalidName,
        TeacherCardDraftError.workplace => TeacherCardFailure.invalidWorkplace,
        TeacherCardDraftError.bio => TeacherCardFailure.invalidBio,
        TeacherCardDraftError.image => TeacherCardFailure.imageTooLarge,
        TeacherCardDraftError.social => TeacherCardFailure.invalidSocial,
      });
    }
    String? photo = draft.removePhoto ? null : previous?.photoPath;
    String? logo = draft.removeLogo ? null : previous?.logoPath;
    final uploaded = <String>[];
    Future<TeacherCardResult<TeacherCard>> fail(TeacherCardFailure f) async {
      for (final p in uploaded) {
        await _remove(p);
      }
      return TeacherCardResult.fail(f);
    }

    if (draft.photo != null) {
      final r = await _upload(uid, 'photo', draft.photo!);
      if (!r.ok) return fail(r.failure!);
      photo = r.value;
      uploaded.add(photo!);
    }
    if (draft.logo != null) {
      final r = await _upload(uid, 'logo', draft.logo!);
      if (!r.ok) return fail(r.failure!);
      logo = r.value;
      uploaded.add(logo!);
    }
    final r = await _rpc('teacher_card_upsert', {
      'p_display_name': draft.displayName.trim(),
      'p_workplace': draft.workplace.trim(),
      'p_bio': draft.bio.trim(),
      'p_photo_path': photo,
      'p_logo_path': logo,
      'p_socials': {for (final e in draft.socials.entries) e.key.key: e.value},
      'p_visible': draft.visible,
    });
    if (!r.ok) return fail(r.failure!);
    final c = _card(r);
    final card = c.value;
    if (card == null) return fail(TeacherCardFailure.server);
    // Almashtirilgan/olib tashlangan eski fayllar (best effort).
    for (final old in [previous?.photoPath, previous?.logoPath]) {
      if (old != null && old != photo && old != logo) await _remove(old);
    }
    return TeacherCardResult.ok(card);
  }

  @override
  Future<TeacherCardResult<void>> delete() async {
    final r = await _rpc('teacher_card_delete', const {});
    final v = r.value;
    if (v == null) return TeacherCardResult.fail(r.failure!);
    for (final k in ['photo_path', 'logo_path']) {
      final p = v[k];
      if (p is String) await _remove(p);
    }
    return const TeacherCardResult.ok(null);
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
        maxBytes: TeacherCardLimits.imageBytes + 1024,
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
