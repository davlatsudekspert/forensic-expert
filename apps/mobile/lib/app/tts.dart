import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/audio/audioplayers_tts_player.dart';
import '../domain/ports/tts_ports.dart';

/// Bootstrap’da Supabase sozlangan bo‘lsa `SupabaseTtsService` bilan
/// almashtiriladi; aks holda «Tinglash» tugmasi ko‘rinmaydi.
final ttsServiceProvider = Provider<TtsService>(
  (ref) => const UnconfiguredTtsService(),
);

/// Har bir «Tinglash» tugmasi ijrochini birinchi bosishda yaratadi va
/// yo‘q bo‘lganda to‘xtatib, bo‘shatadi. Testlarda soxta ijrochi beriladi.
final ttsPlayerFactoryProvider = Provider<TtsPlayer Function()>(
  (ref) => AudioplayersTtsPlayer.new,
);
