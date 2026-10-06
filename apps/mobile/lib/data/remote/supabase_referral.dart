import 'dart:async';
import 'dart:io';

import '../../domain/ports/backend_ports.dart';
import '../../domain/ports/referral_ports.dart';
import '../../domain/referral/referral_models.dart';
import 'supabase_rest.dart';

/// Supabase RPC orqali referral (`referral_dashboard`, `claim_referral`).
/// Mukofot yozadigan funksiyalar faqat service role uchun — mijoz ularni
/// chaqira olmaydi (server GRANT’lari).
class SupabaseReferralService implements ReferralService {
  SupabaseReferralService({
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

  Future<Map<String, String>?> _headers() async {
    if (!auth.current.signedIn) return null;
    final token = await auth.accessToken();
    if (token == null) return null;
    return {'apikey': _cfg.anonKey, 'Authorization': 'Bearer $token'};
  }

  Uri _rpc(String name) => _cfg.url.resolve('rest/v1/rpc/$name');

  @override
  Future<ReferralResult> fetch() async {
    final h = await _headers();
    if (h == null) {
      return const ReferralResult.fail(ReferralFailure.notSignedIn);
    }
    try {
      final r = await _http.send(
        'POST',
        _rpc('referral_dashboard'),
        headers: h,
        jsonBody: const <String, Object?>{},
      );
      if (r.status == 401) {
        return const ReferralResult.fail(ReferralFailure.notSignedIn);
      }
      if (!r.ok) return const ReferralResult.fail(ReferralFailure.server);
      return ReferralResult.ok(ReferralDashboard.fromJson(r.map));
    } on FormatException {
      return const ReferralResult.fail(ReferralFailure.server);
    } on SocketException {
      return const ReferralResult.fail(ReferralFailure.offline);
    } on TimeoutException {
      return const ReferralResult.fail(ReferralFailure.offline);
    } on HandshakeException {
      return const ReferralResult.fail(ReferralFailure.offline);
    }
  }

  @override
  Future<ReferralClaimOutcome> claim(String code) async {
    final c = ReferralCode.normalize(code);
    if (c == null) return ReferralClaimOutcome.invalidCode;
    final h = await _headers();
    if (h == null) return ReferralClaimOutcome.notSignedIn;
    try {
      final r = await _http.send(
        'POST',
        _rpc('claim_referral'),
        headers: h,
        jsonBody: {'p_code': c},
      );
      if (r.status == 401) return ReferralClaimOutcome.notSignedIn;
      if (!r.ok) return ReferralClaimOutcome.server;
      return ReferralClaimOutcome.fromServer(r.json);
    } on SocketException {
      return ReferralClaimOutcome.offline;
    } on TimeoutException {
      return ReferralClaimOutcome.offline;
    } on HandshakeException {
      return ReferralClaimOutcome.offline;
    }
  }
}
