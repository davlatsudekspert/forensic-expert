import 'dart:async';
import 'dart:io';

import '../../domain/catalog/catalog.dart';
import '../../domain/ports/backend_ports.dart';
import '../remote/supabase_rest.dart';

/// Katalog RPC’lari: `catalog_list`, `catalog_star_toggle`, `catalog_me`,
/// `catalog_set_visible` (faqat hisobga kirgan foydalanuvchi).
class SupabaseCatalogService implements CatalogService {
  SupabaseCatalogService({
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

  Future<CatalogResult<Object?>> _rpc(
    String name,
    Map<String, Object?> body,
  ) async {
    if (!auth.current.signedIn) {
      return const CatalogResult.fail(CatalogFailure.notSignedIn);
    }
    final token = await auth.accessToken();
    if (token == null) {
      return const CatalogResult.fail(CatalogFailure.notSignedIn);
    }
    try {
      final r = await _http.send(
        'POST',
        _cfg.url.resolve('rest/v1/rpc/$name'),
        headers: {'apikey': _cfg.anonKey, 'Authorization': 'Bearer $token'},
        jsonBody: body,
      );
      if (r.status == 401 || r.status == 403) {
        return const CatalogResult.fail(CatalogFailure.notSignedIn);
      }
      if (r.status == 404) {
        return const CatalogResult.fail(CatalogFailure.notConfigured);
      }
      if (!r.ok) return const CatalogResult.fail(CatalogFailure.server);
      final j = r.json;
      if (j is Map && j['ok'] == false) {
        return CatalogResult.fail(
          j['error'] == 'not_found'
              ? CatalogFailure.notFound
              : CatalogFailure.server,
        );
      }
      return CatalogResult.ok(j);
    } on SocketException {
      return const CatalogResult.fail(CatalogFailure.offline);
    } on TimeoutException {
      return const CatalogResult.fail(CatalogFailure.offline);
    } on HandshakeException {
      return const CatalogResult.fail(CatalogFailure.offline);
    } on FormatException {
      return const CatalogResult.fail(CatalogFailure.server);
    }
  }

  @override
  Future<CatalogResult<List<CatalogEntry>>> list(
    CatalogKind kind, {
    String? query,
  }) async {
    final q = query?.trim();
    final r = await _rpc('catalog_list', {
      'p_kind': kind.wire,
      'p_query': (q == null || q.isEmpty) ? null : q,
      'p_limit': 200,
    });
    if (!r.ok) return CatalogResult.fail(r.failure!);
    final v = r.value;
    if (v is! List) return const CatalogResult.fail(CatalogFailure.server);
    return CatalogResult.ok([
      for (final e in v)
        if (e is Map) ?CatalogEntry.tryParse(e.cast<String, Object?>()),
    ]);
  }

  @override
  Future<CatalogResult<(bool, int)>> toggleStar(String targetId) async {
    final r = await _rpc('catalog_star_toggle', {'p_target': targetId});
    if (!r.ok) return CatalogResult.fail(r.failure!);
    final m = r.value;
    if (m is! Map) return const CatalogResult.fail(CatalogFailure.server);
    final n = m['stars'];
    return CatalogResult.ok((m['starred'] == true, n is num ? n.toInt() : 0));
  }

  @override
  Future<CatalogResult<CatalogMe>> me() async {
    final r = await _rpc('catalog_me', const {});
    if (!r.ok) return CatalogResult.fail(r.failure!);
    final m = r.value;
    if (m is! Map) return const CatalogResult.ok(CatalogMe.empty);
    return CatalogResult.ok(CatalogMe.fromJson(m.cast<String, Object?>()));
  }

  @override
  Future<CatalogResult<void>> setVisible(CatalogKind kind, bool on) async {
    final r = await _rpc('catalog_set_visible', {
      'p_kind': kind.wire,
      'p_on': on,
    });
    if (!r.ok) return CatalogResult.fail(r.failure!);
    return const CatalogResult.ok(null);
  }
}
