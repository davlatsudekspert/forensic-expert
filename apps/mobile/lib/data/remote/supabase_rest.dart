import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Supabase REST (GoTrue / PostgREST / Storage) uchun yengil mijoz — SDK’siz.
///
/// Konfiguratsiya: `--dart-define=FE_SUPABASE_URL=https://<ref>.supabase.co`
/// va `--dart-define=FE_SUPABASE_ANON_KEY=<anon/publishable key>`. Anon kalit
/// ochiq (RLS bilan himoyalangan); **service-role kalit ilovaga hech qachon
/// kirmaydi**. So‘rov/javob tanalari, kodlar va tokenlar jurnalga yozilmaydi.
class SupabaseConfig {
  const SupabaseConfig({required this.url, required this.anonKey});

  final Uri url;
  final String anonKey;

  static SupabaseConfig? fromEnvironment() {
    const url = String.fromEnvironment('FE_SUPABASE_URL');
    const key = String.fromEnvironment('FE_SUPABASE_ANON_KEY');
    final uri = Uri.tryParse(url);
    if (url.isEmpty || key.isEmpty || uri == null || uri.scheme != 'https') {
      return null;
    }
    return SupabaseConfig(url: uri, anonKey: key);
  }
}

/// HTTP javobi: status va JSON (Map yoki List) yoki xom baytlar.
class RestResponse {
  const RestResponse(this.status, this.json);

  final int status;
  final Object? json;

  bool get ok => status >= 200 && status < 300;

  Map<String, Object?> get map => switch (json) {
    final Map<Object?, Object?> m => m.cast<String, Object?>(),
    _ => const {},
  };

  List<Object?> get list => switch (json) {
    final List<Object?> l => l,
    _ => const [],
  };
}

/// Transport — testlarda soxta implementatsiya bilan almashtiriladi.
abstract interface class RestTransport {
  Future<RestResponse> send(
    String method,
    Uri uri, {
    Map<String, String> headers,
    Object? jsonBody,
    List<int>? bytes,
    String? contentType,
  });
}

class HttpClientTransport implements RestTransport {
  HttpClientTransport({
    HttpClient? client,
    this.timeout = const Duration(seconds: 20),
  }) : _client = client ?? HttpClient();

  final HttpClient _client;
  final Duration timeout;

  @override
  Future<RestResponse> send(
    String method,
    Uri uri, {
    Map<String, String> headers = const {},
    Object? jsonBody,
    List<int>? bytes,
    String? contentType,
  }) async {
    if (uri.scheme != 'https') {
      throw const SocketException('HTTPS required');
    }
    final req = await _client.openUrl(method, uri).timeout(timeout);
    headers.forEach(req.headers.set);
    if (bytes != null) {
      req.headers.set(
        HttpHeaders.contentTypeHeader,
        contentType ?? 'application/octet-stream',
      );
      req.add(bytes);
    } else if (jsonBody != null) {
      req.headers.contentType = ContentType.json;
      req.write(jsonEncode(jsonBody));
    }
    final res = await req.close().timeout(timeout);
    final text = await res.transform(utf8.decoder).join().timeout(timeout);
    Object? json;
    if (text.isNotEmpty) {
      try {
        json = jsonDecode(text);
      } on FormatException {
        json = null;
      }
    }
    return RestResponse(res.statusCode, json);
  }
}
