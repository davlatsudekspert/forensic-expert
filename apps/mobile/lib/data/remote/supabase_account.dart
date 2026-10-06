import 'dart:async';
import 'dart:io';

import '../../domain/admin/admin_models.dart';
import '../../domain/ports/account_ports.dart';
import '../../domain/ports/backend_ports.dart';
import 'supabase_rest.dart';

/// Supabase RPC: `my_access`, `register_device`, `admin_dashboard`,
/// `admin_set_access`. Vakolat serverda tekshiriladi (identity_admin).
class SupabaseAccountService implements AccountService {
  SupabaseAccountService({
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

  Future<RestResponse?> _rpc(String name, Map<String, Object?> body) async {
    if (!auth.current.signedIn) return null;
    final token = await auth.accessToken();
    if (token == null) return null;
    try {
      return await _http.send(
        'POST',
        _cfg.url.resolve('rest/v1/rpc/$name'),
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

  @override
  Future<ServerAccess?> myAccess() async {
    final r = await _rpc('my_access', const {});
    return r != null && r.ok ? ServerAccess.fromJson(r.map) : null;
  }

  @override
  Future<void> registerDevice({
    required String platform,
    required String version,
    required String locale,
    String? region,
  }) async {
    await _rpc('register_device', {
      'p_platform': platform,
      'p_version': version,
      'p_locale': locale,
      'p_region': region,
    });
  }

  @override
  Future<AdminDashboard?> dashboard() async {
    final r = await _rpc('admin_dashboard', const {});
    return r != null && r.ok ? AdminDashboard.fromJson(r.map) : null;
  }

  @override
  Future<AdminGrantResult> setAccess(String email, String? tier) async {
    final r = await _rpc('admin_set_access', {
      'p_email': email.trim(),
      'p_tier': tier,
    });
    if (r == null || !r.ok) return AdminGrantResult.failed;
    return switch (r.json) {
      'GRANTED' => AdminGrantResult.granted,
      'REVOKED' => AdminGrantResult.revoked,
      'NOT_FOUND' => AdminGrantResult.notFound,
      'INVALID_TIER' => AdminGrantResult.invalid,
      _ => AdminGrantResult.failed,
    };
  }
}
