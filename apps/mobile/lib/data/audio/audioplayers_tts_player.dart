import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

import '../../domain/ports/tts_ports.dart';

/// [TtsPlayer] — `audioplayers` ustida (Android, iOS, macOS, Linux).
/// Faqat lokal fayl ijro etiladi (tarmoq yo‘q), shuning uchun Android/iOS
/// uchun qo‘shimcha ruxsat yoki konfiguratsiya kerak emas.
class AudioplayersTtsPlayer implements TtsPlayer {
  AudioplayersTtsPlayer() : _player = AudioPlayer();

  final AudioPlayer _player;

  @override
  Stream<void> get onComplete => _player.onPlayerComplete;

  @override
  Future<void> play(String path) =>
      _player.play(DeviceFileSource(path, mimeType: 'audio/wav'));

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> resume() => _player.resume();

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> dispose() => _player.dispose();
}
