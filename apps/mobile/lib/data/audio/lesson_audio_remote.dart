import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../remote/supabase_rest.dart' show BytesFetcher, HttpClientTransport;

/// Dars ovozi (oldindan tayyorlangan MP3) — ochiq R2 ombori.
/// Fayl yo‘q bo‘lsa (404 / tarmoq) — chaqiruvchi hozirgi ovoz yo‘lini ishlatadi.
const String kLessonAudioBase =
    'https://pub-c98fba3748ef4acf8dd1600b2b325ab6.r2.dev/audio/lesson';

/// `…/audio/lesson/<deck>/<lang>/<NN>.mp3`. Faqat ru/en va xavfsiz deck id.
/// [slide] — 1 dan boshlanadigan slayd raqami.
String? lessonAudioUrl({
  required String deckId,
  required String lang,
  required int slide,
}) {
  if (lang != 'ru' && lang != 'en') return null;
  if (slide < 1 || slide > 999) return null;
  if (!RegExp(r'^[A-Za-z0-9_.\-]{1,120}$').hasMatch(deckId)) return null;
  return '$kLessonAudioBase/$deckId/$lang/${slide.toString().padLeft(2, '0')}.mp3';
}

/// Faylni telefonga yuklab, mahalliy yo‘lini qaytaradi (keshlanadi).
/// Topilmasa yoki xato bo‘lsa — null. Tarmoq — umumiy transport orqali
/// ([HttpClientTransport]); testlarda [fetcher] almashtiriladi.
Future<String?> fetchLessonAudio(String url, {BytesFetcher? fetcher}) async {
  try {
    final dir = await getTemporaryDirectory();
    final safe = url.replaceAll(RegExp(r'[^A-Za-z0-9]'), '_');
    final name = safe.length > 140 ? safe.substring(safe.length - 140) : safe;
    final file = File('${dir.path}/$name.mp3');
    if (await file.exists() && await file.length() > 1000) return file.path;
    final bytes = await (fetcher ?? HttpClientTransport()).getBytes(
      Uri.parse(url),
      maxBytes: 12 * 1024 * 1024,
    );
    if (bytes == null || bytes.length < 1000) return null;
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  } on Object {
    return null;
  }
}
