import 'package:flutter/services.dart' show MethodChannel;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/lessons/fake_lessons_service.dart';
import '../domain/class_quiz/class_quiz_models.dart' show ClassResult;
import '../domain/lessons/lesson_models.dart';
import '../domain/ports/lessons_ports.dart';

/// Bootstrap’da Supabase sozlangan bo‘lsa [SupabaseLessonsService] bilan
/// almashtiriladi; aks holda DEMO (Fake) adapter (namunaviy darslar).
final lessonsServiceProvider = Provider<LessonsService>(
  (ref) => FakeLessonsService(),
);

/// Server qidiruvi: `''` — to‘liq ro‘yxat.
final lessonListProvider = FutureProvider.autoDispose
    .family<ClassResult<List<LessonSummary>>, String>(
      (ref, query) => ref
          .watch(lessonsServiceProvider)
          .list(query: query.isEmpty ? null : query),
    );

final lessonDeckProvider = FutureProvider.autoDispose
    .family<ClassResult<LessonDeck>, String>(
      (ref, topicId) => ref.watch(lessonsServiceProvider).get(topicId),
    );

/// Ko‘rish oynasida skrinshot/yozib olishni cheklash (Android FLAG_SECURE;
/// iOS’da ishonchli usul yo‘q). Testlarda almashtiriladi.
abstract interface class LessonScreenGuard {
  Future<void> secure();
  Future<void> release();
}

class PlatformLessonScreenGuard implements LessonScreenGuard {
  const PlatformLessonScreenGuard();

  static const _ch = MethodChannel('uz.forensicexpert/secure_screen');

  Future<void> _set(bool on) async {
    try {
      await _ch.invokeMethod<void>('setSecure', on);
    } on Object {
      // Platforma qo‘llamaydi (iOS/web/test): e’tiborsiz.
    }
  }

  @override
  Future<void> secure() => _set(true);
  @override
  Future<void> release() => _set(false);
}

final lessonScreenGuardProvider = Provider<LessonScreenGuard>(
  (ref) => const PlatformLessonScreenGuard(),
);
