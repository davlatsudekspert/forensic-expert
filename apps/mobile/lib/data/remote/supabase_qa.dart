import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../domain/ports/backend_ports.dart';
import '../../domain/ports/qa_ports.dart';
import '../../domain/qa/qa_models.dart';
import 'supabase_rest.dart';

/// «Savol-javob (Hamjamiyat)» uchun Supabase adapteri.
///
/// RPC: `qa_status`, `qa_feed`, `qa_question`, `qa_my`, `qa_ask`,
/// `qa_answer`, `qa_vote`, `qa_accept`, `qa_report`, `qa_admin_queue`,
/// `qa_moderate` — hammasi SECURITY DEFINER. Jadvalga to‘g‘ridan-to‘g‘ri
/// kirish yo‘q (RLS yoniq, policy yo‘q).
///
/// Edge Function: `qa-verify-expert` (hujjat tekshiruvi — **fayl
/// saqlanmaydi**, faqat so‘rov tanasida ketadi) va `qa-translate`
/// (serverdagi tarjima + kesh). Ikkisi ham imzolangan foydalanuvchi
/// tokenini talab qiladi; hech qanday AI kaliti ilovada yo‘q.
class SupabaseQaService implements QaService {
  SupabaseQaService({
    required SupabaseConfig config,
    required this.auth,
    RestTransport? transport,
  }) : _cfg = config,
       _http = transport ?? HttpClientTransport();

  final SupabaseConfig _cfg;
  final AuthRepository auth;
  final RestTransport _http;

  @override
  bool get isConfigured => true;

  Future<RestResponse?> _post(Uri uri, Map<String, Object?> body) async {
    if (!auth.current.signedIn) return null;
    final token = await auth.accessToken();
    if (token == null) return null;
    try {
      return await _http.send(
        'POST',
        uri,
        headers: {'apikey': _cfg.anonKey, 'Authorization': 'Bearer $token'},
        jsonBody: body,
      );
    } on SocketException {
      return null;
    } on TimeoutException {
      return null;
    } on HandshakeException {
      return null;
    }
  }

  Future<RestResponse?> _rpc(String name, Map<String, Object?> body) =>
      _post(_cfg.url.resolve('rest/v1/rpc/$name'), body);

  Future<RestResponse?> _fn(String name, Map<String, Object?> body) =>
      _post(_cfg.url.resolve('functions/v1/$name'), body);

  @override
  Future<QaMe?> status() async {
    final r = await _rpc('qa_status', const {});
    return r != null && r.ok ? QaMe.fromJson(r.map) : null;
  }

  @override
  Future<QaFeed?> feed({
    String? tag,
    String? query,
    int limit = 20,
    int offset = 0,
  }) async {
    final r = await _rpc('qa_feed', {
      'p_tag': tag,
      'p_query': query,
      'p_limit': limit,
      'p_offset': offset,
    });
    return r != null && r.ok ? QaFeed.fromJson(r.map) : null;
  }

  @override
  Future<QaQuestion?> question(String id) async {
    final r = await _rpc('qa_question', {'p_id': id});
    return r != null && r.ok && r.json is Map
        ? QaQuestion.fromJson(r.map)
        : null;
  }

  @override
  Future<QaMine?> mine() async {
    final r = await _rpc('qa_my', const {});
    return r != null && r.ok ? QaMine.fromJson(r.map) : null;
  }

  @override
  Future<QaPostResult?> ask({
    required QaLang lang,
    required String title,
    required String body,
    List<String> tags = const [],
  }) async {
    final r = await _rpc('qa_ask', {
      'p_lang': lang.wire,
      'p_title': title,
      'p_body': body,
      'p_tags': tags,
    });
    return r != null && r.ok ? QaPostResult.fromJson(r.map) : null;
  }

  @override
  Future<QaPostResult?> answer({
    required String questionId,
    required QaLang lang,
    required String body,
  }) async {
    final r = await _rpc('qa_answer', {
      'p_question_id': questionId,
      'p_lang': lang.wire,
      'p_body': body,
    });
    return r != null && r.ok ? QaPostResult.fromJson(r.map) : null;
  }

  @override
  Future<QaAnswer?> vote(String answerId, int value) async {
    final r = await _rpc('qa_vote', {
      'p_answer_id': answerId,
      'p_value': value,
    });
    if (r == null || !r.ok) return null;
    // Server faqat yangi ballni qaytaradi; qolgan maydonlar chaqiruvchida.
    return QaAnswer.fromJson({
      'id': answerId,
      'body': '',
      'score': r.map['score'],
      'my_vote': r.map['my_vote'],
    });
  }

  @override
  Future<bool> accept(String questionId, String? answerId) async {
    final r = await _rpc('qa_accept', {
      'p_question_id': questionId,
      'p_answer_id': answerId,
    });
    return r != null && r.ok;
  }

  @override
  Future<QaReportResult?> report({
    required QaTargetType target,
    required String id,
    required String reason,
  }) async {
    final r = await _rpc('qa_report', {
      'p_target_type': target.wire,
      'p_target_id': id,
      'p_reason': reason,
    });
    return r != null && r.ok ? QaReportResult.fromJson(r.map) : null;
  }

  @override
  Future<QaTranslation?> translate({
    required QaTargetType target,
    required String id,
    required QaLang lang,
  }) async {
    final r = await _fn('qa-translate', {
      'target_type': target.wire,
      'target_id': id,
      'lang': lang.wire,
    });
    return r != null && r.ok && r.json is Map
        ? QaTranslation.fromJson(r.map)
        : null;
  }

  @override
  Future<QaVerifyOutcome> verify({
    required QaRole role,
    required String countryCode,
    required QaDocument document,
    required QaLang lang,
  }) async {
    if (!document.isAllowed) return QaVerifyOutcome.failed('bad_document');
    // Hujjat faqat shu so‘rov tanasida ketadi: diskka yozilmaydi, keshlanmaydi
    // va jurnalga tushmaydi (bu yerda hech narsa log qilinmaydi).
    final r = await _fn('qa-verify-expert', {
      'role': role.wire,
      'country': countryCode,
      'mime': document.mimeType,
      'data': base64Encode(document.bytes),
      'lang': lang.wire,
    });
    if (r == null) return QaVerifyOutcome.failed('offline');
    if (!r.ok) return QaVerifyOutcome.failed('${r.map['error'] ?? r.status}');
    return QaVerifyOutcome.fromJson(r.map);
  }

  @override
  Future<QaModerationQueue?> moderationQueue() async {
    final r = await _rpc('qa_admin_queue', const {'p_limit': 50});
    return r != null && r.ok ? QaModerationQueue.fromJson(r.map) : null;
  }

  @override
  Future<bool> moderate({
    required QaModerationAction action,
    required QaTargetType target,
    required String id,
    String? reason,
  }) async {
    final r = await _rpc('qa_moderate', {
      'p_action': action.wire,
      'p_target_type': target.wire,
      'p_target_id': id,
      'p_reason': reason,
    });
    return r != null && r.ok;
  }
}
