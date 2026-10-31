import 'dart:async';

import 'package:forensic_expert/domain/ports/tts_ports.dart';

/// «Tinglash» testlari uchun soxta ijrochi va servis (platforma kanallarisiz).
class FakeTtsPlayer implements TtsPlayer {
  // ignore: close_sinks
  final complete = StreamController<void>.broadcast();
  final calls = <String>[];
  bool disposed = false;
  Object? playError;

  @override
  Stream<void> get onComplete => complete.stream;

  @override
  Future<void> play(String path) async {
    calls.add('play:$path');
    if (playError != null) throw playError!;
  }

  @override
  Future<void> pause() async => calls.add('pause');

  @override
  Future<void> resume() async => calls.add('resume');

  @override
  Future<void> stop() async => calls.add('stop');

  @override
  Future<void> dispose() async {
    calls.add('dispose');
    disposed = true;
  }
}

class FakeTtsService implements TtsService {
  FakeTtsService({this.configured = true});

  final bool configured;
  Completer<TtsAudio>? pending;
  TtsFailure? fail;
  TtsAudio audio = const TtsAudio(['/tmp/a.wav']);
  final texts = <String>[];

  @override
  bool get isConfigured => configured;

  @override
  Future<TtsAudio> synthesize(String text) {
    texts.add(text);
    if (fail != null) return Future.error(TtsException(fail!));
    return pending?.future ?? Future.value(audio);
  }
}
