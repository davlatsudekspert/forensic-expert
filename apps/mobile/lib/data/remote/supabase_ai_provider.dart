import 'dart:async';
import 'dart:io';

import '../../domain/ai/ai_architecture.dart';
import '../../domain/ports/backend_ports.dart';
import 'supabase_rest.dart';

/// Gemini — faqat server orqali (`supabase/functions/ai-answer`).
///
/// Ilovada AI kaliti yo‘q: `GEMINI_API_KEY` faqat Edge Function
/// muhitida. Ilova faqat lokal (imzolangan) bazadan olingan bo‘laklarni
/// yuboradi; javobdagi har bir iqtibos [CitationResolver] tomonidan qayta
/// tekshiriladi. Savol va javob jurnalga yozilmaydi.
///
/// Yoqish: `--dart-define=FE_AI_REMOTE=true` va Supabase konfiguratsiyasi.
/// Aks holda ilova «Namoyish · ulanmagan» holatida qoladi.
class SupabaseAiProvider implements AiProvider {
  SupabaseAiProvider({
    required SupabaseConfig config,
    required AuthRepository auth,
    RestTransport? transport,
  }) : _cfg = config,
       _authRepo = auth,
       _http = transport ?? HttpClientTransport();

  final SupabaseConfig _cfg;
  final AuthRepository _authRepo;
  final RestTransport _http;

  static const enabled = bool.fromEnvironment('FE_AI_REMOTE');

  static AiProvider? fromEnvironment(AuthRepository auth) {
    final cfg = SupabaseConfig.fromEnvironment();
    if (!enabled || cfg == null) return null;
    return SupabaseAiProvider(config: cfg, auth: auth);
  }

  @override
  bool get isConfigured => true;

  @override
  Future<AiDraft> generate(AiPrompt prompt) async {
    final token = await _authRepo.accessToken();
    if (token == null) throw const AiUnavailable('not_signed_in');
    try {
      final r = await _http.send(
        'POST',
        _cfg.url.resolve('functions/v1/ai-answer'),
        headers: {'apikey': _cfg.anonKey, 'Authorization': 'Bearer $token'},
        jsonBody: {
          'question': prompt.question.text,
          'lang': prompt.question.languageCode,
          'experience': prompt.experience.name,
          'chunks': [
            for (final c in prompt.chunks)
              {'id': c.chunkId, 'title': c.title ?? '', 'text': c.text},
          ],
        },
      );
      if (!r.ok) throw AiUnavailable('${r.map['error'] ?? r.status}');
      final cited = r.map['cited'];
      return AiDraft(
        text: '${r.map['text'] ?? ''}',
        citedChunkIds: [
          if (cited is List)
            for (final id in cited)
              if (id is String) id,
        ],
      );
    } on SocketException {
      throw const AiUnavailable('offline');
    } on TimeoutException {
      throw const AiUnavailable('offline');
    }
  }
}

/// Server AI vaqtincha mavjud emas (offline, limit, sozlanmagan).
class AiUnavailable implements Exception {
  const AiUnavailable(this.code);

  final String code;

  @override
  String toString() => 'AiUnavailable($code)';
}
