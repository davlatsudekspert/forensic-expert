import 'dart:async';

import '../../domain/ports/app_version_ports.dart';
import 'supabase_rest.dart';

/// `POST /rest/v1/rpc/app_version_info` (anon kalit; kirish talab qilinmaydi).
/// `x-fe-build` / `x-fe-platform` sarlavhalarini transport o‘zi qo‘shadi.
class SupabaseAppVersionService implements AppVersionService {
  SupabaseAppVersionService({
    required SupabaseConfig config,
    RestTransport? transport,
    this.timeout = const Duration(seconds: 6),
  }) : _cfg = config,
       _http = transport ?? HttpClientTransport(timeout: timeout);

  final SupabaseConfig _cfg;
  final RestTransport _http;
  final Duration timeout;

  @override
  Future<AppVersionInfo?> fetch() async {
    try {
      final r = await _http
          .send(
            'POST',
            _cfg.url.resolve('rest/v1/rpc/app_version_info'),
            headers: {
              'apikey': _cfg.anonKey,
              'Authorization': 'Bearer ${_cfg.anonKey}',
            },
            jsonBody: const <String, Object?>{},
          )
          .timeout(timeout);
      if (!r.ok) return null;
      // PostgREST skalyar/jadval qaytarsa ham: `[ {...} ]` yoki `{...}`.
      final j = r.json;
      return AppVersionInfo.tryParse(j is List && j.isNotEmpty ? j.first : j);
    } on Object {
      return null;
    }
  }
}
