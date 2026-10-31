/// «Tinglash» (matnni ovozga aylantirish) portlari.
///
/// Ovoz serverda (`supabase/functions/tts`) sintez qilinadi; ilova faqat
/// tayyor WAV faylni qurilmada saqlaydi va ijro etadi.
library;

/// Sintez muvaffaqiyatsizligi turlari.
enum TtsFailure {
  /// Kirmagan foydalanuvchi (token yo‘q yoki server 401).
  notSignedIn,

  /// Matn serverning chegarasidan uzun (bo‘laklash bunga yo‘l qo‘ymasligi kerak).
  tooLong,

  /// Matn bo‘sh.
  empty,

  /// Kunlik chegara tugadi (`too_many_requests`).
  dailyLimit,

  /// Vaqtincha band: Google limiti (`quota`), upstream xato yoki kutish vaqti.
  busy,

  /// Tarmoq yo‘q.
  offline,

  /// Server ovoz xizmati sozlanmagan (yoki ilovada Supabase ulanmagan).
  notConfigured,
}

class TtsException implements Exception {
  const TtsException(this.failure);

  final TtsFailure failure;

  @override
  String toString() => 'TtsException(${failure.name})';
}

/// Tayyor ovoz: ketma-ket ijro etiladigan lokal WAV fayllar. Odatda bitta;
/// 4000 belgidan uzun matn abzaslar chegarasida bo‘laklarga bo‘linadi.
class TtsAudio {
  const TtsAudio(this.paths);

  final List<String> paths;
}

abstract interface class TtsService {
  /// `false` bo‘lsa «Tinglash» tugmasi ko‘rsatilmaydi.
  bool get isConfigured;

  /// Matnni ovozga aylantiradi (avval qurilma keshi, so‘ng server).
  /// Xato — [TtsException].
  Future<TtsAudio> synthesize(String text);
}

/// Supabase ulanmagan yig‘ma: tugma ko‘rinmaydi.
class UnconfiguredTtsService implements TtsService {
  const UnconfiguredTtsService();

  @override
  bool get isConfigured => false;

  @override
  Future<TtsAudio> synthesize(String text) =>
      Future.error(const TtsException(TtsFailure.notConfigured));
}

/// Ovoz ijrochisi (platforma plagini ortida). Testlarda soxta bilan almashadi.
abstract interface class TtsPlayer {
  /// Joriy fayl oxiriga yetganda.
  Stream<void> get onComplete;

  /// Lokal fayl yo‘lini boshidan ijro etadi. Ijro boshlanmasa — xato tashlaydi.
  Future<void> play(String path);

  Future<void> pause();

  Future<void> resume();

  Future<void> stop();

  Future<void> dispose();
}

/// Serverning bir so‘rovdagi chegarasi (belgi).
const ttsMaxChars = 4000;

/// Matnni abzaslar chegarasida ≤ [max] belgili bo‘laklarga bo‘ladi.
///
/// Avval bo‘sh qatordan, so‘ng qator uzilishidan, keyin gap oxiridan va
/// oxirgi chora sifatida bo‘shliqdan (yoki qat’iy) bo‘linadi. Bo‘sh bo‘laklar
/// tashlanadi. Bo‘laklarning birikmasi (bo‘shliqlargacha) asl matnni saqlaydi.
List<String> splitTtsText(String text, {int max = ttsMaxChars}) {
  final t = text.trim();
  if (t.isEmpty) return const [];
  if (t.length <= max) return [t];

  // 1) Atomlar: har biri ≤ max.
  final atoms = <String>[];
  for (final para in t.split(RegExp(r'\n\s*\n'))) {
    final p = para.trim();
    if (p.isEmpty) continue;
    if (p.length <= max) {
      atoms.add(p);
    } else {
      atoms.addAll(_splitLong(p, max));
    }
  }

  // 2) Atomlarni ≤ max gacha ketma-ket yig‘ish.
  final out = <String>[];
  var cur = StringBuffer();
  var len = 0;
  for (final a in atoms) {
    final add = len == 0 ? a.length : a.length + 2;
    if (len > 0 && len + add > max) {
      out.add(cur.toString());
      cur = StringBuffer();
      len = 0;
    }
    if (len > 0) cur.write('\n\n');
    cur.write(a);
    len += len == 0 ? a.length : a.length + 2;
  }
  if (len > 0) out.add(cur.toString());
  return out;
}

List<String> _splitLong(String p, int max) {
  final parts = <String>[];
  var rest = p;
  while (rest.length > max) {
    final window = rest.substring(0, max);
    var cut = -1;
    // Gap oxiri (. ! ? va keyingi bo‘shliq/qator), so‘ng qator, so‘ng bo‘shliq.
    for (final m in RegExp(r'[.!?…][\s]').allMatches(window)) {
      cut = m.end;
    }
    if (cut <= 0) cut = window.lastIndexOf('\n') + 1;
    if (cut <= 0) cut = window.lastIndexOf(' ') + 1;
    if (cut <= 0) cut = max; // qat’iy kesish
    parts.add(rest.substring(0, cut).trim());
    rest = rest.substring(cut).trim();
  }
  if (rest.isNotEmpty) parts.add(rest);
  return parts.where((s) => s.isNotEmpty).toList();
}
