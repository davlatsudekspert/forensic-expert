import 'dart:async';
import 'dart:io';

import '../../domain/ports/backend_ports.dart';
import '../../domain/ports/publication_ports.dart';
import '../../domain/publications/publication_models.dart';
import 'supabase_rest.dart';

/// Supabase RPC: `list_published` (anon ham), `my_publications`,
/// `save_draft`, `submit_publication`, `report_publication`,
/// `can_moderate_publications`, `moderation_queue`, `moderate_publication`.
/// Jadvalga to‘g‘ridan-to‘g‘ri kirish yo‘q — faqat SECURITY DEFINER RPC.
class SupabasePublicationService implements PublicationService {
  SupabasePublicationService({
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

  /// [public] — kirmagan foydalanuvchi uchun anon kalit bilan.
  Future<RestResponse?> _rpc(
    String name,
    Map<String, Object?> body, {
    bool public = false,
  }) async {
    String? token;
    if (auth.current.signedIn) token = await auth.accessToken();
    if (token == null && !public) return null;
    try {
      return await _http.send(
        'POST',
        _cfg.url.resolve('rest/v1/rpc/$name'),
        headers: {
          'apikey': _cfg.anonKey,
          'Authorization': 'Bearer ${token ?? _cfg.anonKey}',
        },
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

  List<Publication>? _list(RestResponse? r) => r == null || !r.ok
      ? null
      : [
          for (final e in r.list)
            if (e is Map) Publication.fromJson(e.cast<String, Object?>()),
        ];

  @override
  Future<List<Publication>?> listPublished() async =>
      _list(await _rpc('list_published', const {'p_limit': 200}, public: true));

  @override
  Future<List<Publication>?> myPublications() async =>
      _list(await _rpc('my_publications', const {}));

  @override
  Future<String?> saveDraft(PublicationDraft draft) async {
    final r = await _rpc('save_draft', {
      'p_id': draft.id,
      'p_data': draft.toJson(),
    });
    return r != null && r.ok && r.json is String ? r.json! as String : null;
  }

  @override
  Future<SubmitResult> submit(String id) async {
    final r = await _rpc('submit_publication', {'p_id': id});
    return r != null && r.ok
        ? SubmitResult.fromWire(r.json)
        : SubmitResult.failed;
  }

  @override
  Future<ReportResult> report(
    String id,
    ReportReason reason,
    String details,
  ) async {
    final r = await _rpc('report_publication', {
      'p_id': id,
      'p_reason': reason.wire,
      'p_details': details,
    });
    return r != null && r.ok
        ? ReportResult.fromWire(r.json)
        : ReportResult.failed;
  }

  @override
  Future<bool> canModerate() async {
    final r = await _rpc('can_moderate_publications', const {});
    return r != null && r.ok && r.json == true;
  }

  @override
  Future<ModerationQueue?> moderationQueue() async {
    final r = await _rpc('moderation_queue', const {});
    return r != null && r.ok ? ModerationQueue.fromJson(r.map) : null;
  }

  @override
  Future<ModerationResult> moderate(
    String id,
    PublicationStatus to,
    String? comment,
  ) async {
    final r = await _rpc('moderate_publication', {
      'p_id': id,
      'p_to': to.wire,
      'p_comment': comment,
    });
    return r != null && r.ok
        ? ModerationResult.fromWire(r.json)
        : ModerationResult.failed;
  }
}
