import 'package:flutter/services.dart' show MethodChannel;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/settings/app_settings.dart' show UserMode;
import '../core/settings/settings_controller.dart';
import '../data/lessons/fake_lessons_service.dart';
import '../domain/class_quiz/class_quiz_models.dart' show ClassResult;
import '../domain/lessons/lesson_models.dart';
import '../domain/ports/lessons_ports.dart';
import 'class_quiz.dart';

/// Bootstrap’da Supabase sozlangan bo‘lsa [SupabaseLessonsService] bilan
/// almashtiriladi; aks holda DEMO (Fake) adapter (namunaviy darslar).
final lessonsServiceProvider = Provider<LessonsService>(
  (ref) => FakeLessonsService(),
);

/// Hamma rejimga ochiq kurs (serverda `audience = 'all'`).
const openLessonCourse = 'Apparatlar bilan ishlash';

/// Server qidiruvi: `''` — to‘liq ro‘yxat. Ustoz darslari faqat «Ustoz»
/// rejimida ko‘rinadi: Mutaxassis/Talaba rejimida (server roli, masalan
/// admin, bo‘lsa ham) faqat ochiq kurs qoladi.
final lessonListProvider = FutureProvider.autoDispose
    .family<ClassResult<List<LessonSummary>>, String>((ref, query) async {
      final mode = ref.watch(
        settingsControllerProvider.select((s) => s.userMode),
      );
      final res = await ref
          .watch(lessonsServiceProvider)
          .list(query: query.isEmpty ? null : query);
      final items = res.value;
      if (mode == UserMode.teacher || items == null) return res;
      return ClassResult.ok([
        for (final s in items)
          if (s.course == openLessonCourse) s,
      ]);
    });

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

/// Dars bilan bog‘liq test mavzusi (`class_topics` da `deck_id` yoki uning
/// `~ru`/`~en` varianti) bormi. Yuklanayotgan yoki xatoda — `false`.
final lessonQuizAvailableProvider = Provider.autoDispose.family<bool, String>((
  ref,
  deckId,
) {
  if (deckId.isEmpty) return false;
  final topics = ref.watch(classTopicsProvider).value?.value;
  if (topics == null) return false;
  final base = ClassQuizBank.baseId(deckId);
  return topics.any((t) => ClassQuizBank.baseId(t.id) == base);
});
