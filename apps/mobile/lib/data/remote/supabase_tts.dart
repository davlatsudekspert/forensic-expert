import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';

import '../../domain/ports/backend_ports.dart';
import '../../domain/ports/tts_ports.dart';
import 'supabase_rest.dart';

/// Ikkilik javobli POST (WAV). [RestTransport] javobni matn deb o‘qiydi,
/// shuning uchun ovoz uchun alohida transport kerak.
class TtsHttpResponse {
  const TtsHttpResponse(this.status, this.bytes);

  final int status;
  final List<int> bytes;
}

abstract interface class TtsHttp {
  Future<TtsHttpResponse> postJson(
    Uri uri, {
    required Map<String, String> headers,
    required Map<String, Object?> body,
  });
}

class HttpClientTtsHttp implements TtsHttp {
  HttpClientTtsHttp({
    HttpClient? client,
    // Keshsiz abzas ~7–10 s; zaxira bilan 90 s.
    this.timeout = const Duration(seconds: 90),
    this.maxBytes = 32 * 1024 * 1024,
  }) : _client = client ?? HttpClient();

  final HttpClient _client;
  final Duration timeout;
  final int maxBytes;

  @override
  Future<TtsHttpResponse> postJson(
    Uri uri, {
    required Map<String, String> headers,
    required Map<String, Object?> body,
  }) async {
    if (uri.scheme != 'https') throw const SocketException('HTTPS required');
    final req = await _client.openUrl('POST', uri).timeout(timeout);
    headers.forEach(req.headers.set);
    req.headers.contentType = ContentType.json;
    req.write(jsonEncode(body));
    final res = await req.close().timeout(timeout);
    final out = BytesBuilder(copy: false);
    await for (final chunk in res.timeout(timeout)) {
      out.add(chunk);
      if (out.length > maxBytes) {
        throw const HttpException('response too large');
      }
    }
    return TtsHttpResponse(res.statusCode, out.takeBytes());
  }
}

/// «Tinglash»: ovoz faqat server orqali (`supabase/functions/tts`, Gemini TTS).
///
/// * Kalit ilovada yo‘q; so‘rov `apikey` + foydalanuvchi tokeni bilan ketadi.
/// * Tayyor WAV qurilmada `<applicationSupport>/tts/<sha256(voice|style|text)>.wav`
///   ostida saqlanadi: o‘sha matn ikkinchi marta tarmoqsiz (va kirmasdan)
///   ijro etiladi.
/// * Matn > 4000 belgi bo‘lsa, abzaslar chegarasida bo‘laklarga bo‘linadi va
///   bo‘laklar ketma-ket sintez qilinadi (har biri alohida keshlanadi);
///   [TtsAudio.paths] ijrochi tomonidan ketma-ket o‘ynaladi. Bo‘lak yarmida
///   xato bo‘lsa, tayyor bo‘laklar keshda qoladi va qayta urinish ularni
///   qayta so‘ramaydi.
/// * Matn, token va ovoz jurnalga yozilmaydi.
///
/// Ovoz/uslub UI’da qattiq yozilmagan: `--dart-define=FE_TTS_VOICE=...`
/// (bo‘sh — server standarti).
class SupabaseTtsService implements TtsService {
  SupabaseTtsService({
    required SupabaseConfig config,
    required AuthRepository auth,
    TtsHttp? http,
    Future<Directory> Function()? cacheDir,
    this.voice = const String.fromEnvironment('FE_TTS_VOICE'),
    this.style = '',
  }) : _cfg = config,
       _authRepo = auth,
       _http = http ?? HttpClientTtsHttp(),
       _cacheDir = cacheDir ?? _defaultCacheDir;

  final SupabaseConfig _cfg;
  final AuthRepository _authRepo;
  final TtsHttp _http;
  final Future<Directory> Function() _cacheDir;
  final String voice;
  final String style;

  @override
  bool get isConfigured => true;

  static Future<Directory> _defaultCacheDir() async {
    final base = await getApplicationSupportDirectory();
    return Directory('${base.path}${Platform.pathSeparator}tts');
  }

  /// Kesh fayl nomi: sha256(voice|style|text).
  static String cacheKey(String voice, String style, String text) =>
      sha256.convert(utf8.encode('$voice|$style|$text')).toString();

  @override
  Future<TtsAudio> synthesize(String text) async {
    final parts = splitTtsText(text);
    if (parts.isEmpty) throw const TtsException(TtsFailure.empty);
    final dir = await _cacheDir();
    final paths = <String>[];
    for (final part in parts) {
      paths.add(await _synthesizePart(dir, part));
    }
    return TtsAudio(paths);
  }

  Future<String> _synthesizePart(Directory dir, String text) async {
    final file = File(
      '${dir.path}${Platform.pathSeparator}${cacheKey(voice, style, text)}.wav',
    );
    try {
      if (await file.exists() && await file.length() > _wavHeader) {
        return file.path;
      }
    } on FileSystemException {
      // Kesh o‘qilmasa — serverdan olamiz.
    }

    final token = await _authRepo.accessToken();
    if (token == null) throw const TtsException(TtsFailure.notSignedIn);

    final TtsHttpResponse r;
    try {
      r = await _http.postJson(
        _cfg.url.resolve('functions/v1/tts'),
        headers: {'apikey': _cfg.anonKey, 'Authorization': 'Bearer $token'},
        body: {
          'text': text,
          if (voice.isNotEmpty) 'voice': voice,
          if (style.isNotEmpty) 'style': style,
        },
      );
    } on TimeoutException {
      throw const TtsException(TtsFailure.busy);
    } on HttpException {
      throw const TtsException(TtsFailure.offline);
    } on IOException {
      // SocketException, HandshakeException va h.k.
      throw const TtsException(TtsFailure.offline);
    }

    if (r.status != 200) throw TtsException(_failureFor(r));
    if (!_looksLikeWav(r.bytes)) throw const TtsException(TtsFailure.busy);

    try {
      await dir.create(recursive: true);
      // Yarim yozilgan fayl keshda qolmasligi uchun: vaqtinchalik → rename.
      final tmp = File('${file.path}.part');
      await tmp.writeAsBytes(r.bytes, flush: true);
      await tmp.rename(file.path);
    } on FileSystemException {
      // Saqlab bo‘lmadi (joy yo‘q): ijro uchun baribir kerak — vaqtinchalik fayl.
      throw const TtsException(TtsFailure.busy);
    }
    return file.path;
  }

  static const _wavHeader = 44;

  static bool _looksLikeWav(List<int> b) =>
      b.length > _wavHeader &&
      b[0] == 0x52 && // R
      b[1] == 0x49 && // I
      b[2] == 0x46 && // F
      b[3] == 0x46; // F

  static TtsFailure _failureFor(TtsHttpResponse r) {
    String? code;
    try {
      final j = jsonDecode(utf8.decode(r.bytes, allowMalformed: true));
      if (j is Map && j['error'] is String) code = j['error'] as String;
    } on FormatException {
      code = null;
    }
    return switch (r.status) {
      401 => TtsFailure.notSignedIn,
      413 => TtsFailure.tooLong,
      422 => TtsFailure.empty,
      429 =>
        code == 'too_many_requests' ? TtsFailure.dailyLimit : TtsFailure.busy,
      503 when code == 'not_configured' => TtsFailure.notConfigured,
      _ => TtsFailure.busy,
    };
  }
}
