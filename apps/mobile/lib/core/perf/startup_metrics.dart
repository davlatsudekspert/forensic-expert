import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Ishga tushish va navigatsiya vaqtini o‘lchash.
///
/// O‘lchovlar `dart:developer` Timeline’ga ham yoziladi — DevTools va
/// `integration_test` (traceAction) ularni ko‘radi. Hech qanday ma’lumot
/// tarmoqqa yuborilmaydi.
class StartupMetrics {
  StartupMetrics._();

  static final StartupMetrics instance = StartupMetrics._();

  final Stopwatch _sinceMain = Stopwatch();
  final Map<String, Duration> _marks = {};

  /// `main()` ning birinchi qatorida chaqiriladi.
  void start() {
    if (!_sinceMain.isRunning) _sinceMain.start();
    developer.Timeline.instantSync('fe.startup.main');
  }

  /// Nomlangan nuqta (main’dan beri o‘tgan vaqt).
  void mark(String name) {
    _marks.putIfAbsent(name, () => _sinceMain.elapsed);
    developer.Timeline.instantSync('fe.startup.$name');
    if (kDebugMode) {
      debugPrint('[perf] $name: ${_marks[name]!.inMilliseconds} ms');
    }
  }

  /// Asinxron qadam davomiyligini o‘lchaydi.
  Future<T> measure<T>(String name, Future<T> Function() action) async {
    final sw = Stopwatch()..start();
    final task = developer.TimelineTask()..start('fe.$name');
    try {
      return await action();
    } finally {
      task.finish();
      _marks['$name.duration'] = sw.elapsed;
      if (kDebugMode) {
        debugPrint('[perf] $name took ${sw.elapsedMilliseconds} ms');
      }
    }
  }

  Duration? operator [](String name) => _marks[name];

  Map<String, Duration> get snapshot => Map.unmodifiable(_marks);

  @visibleForTesting
  void reset() {
    _marks.clear();
    _sinceMain
      ..stop()
      ..reset();
  }
}

/// Standart nuqta nomlari.
abstract final class PerfMarks {
  static const settingsLoaded = 'settings_loaded';
  static const firstFrame = 'first_frame';
  static const settingsLoad = 'settings.load';
  static const contentDbOpen = 'content_db.open';
}
