import 'package:flutter/services.dart' show MethodChannel;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/settings/app_settings.dart' show UserMode;
import '../core/settings/settings_controller.dart';
import '../data/lessons/fake_lessons_service.dart';
import '../data/lessons/narration_overlay.dart';
import '../domain/class_quiz/class_quiz_models.dart' show ClassResult;
import '../domain/lessons/lesson_models.dart';
import '../domain/lessons/lesson_taxonomy.dart';
import '../domain/ports/lessons_ports.dart';
import 'class_quiz.dart';

/// Bootstrap’da Supabase sozlangan bo‘lsa [SupabaseLessonsService] bilan
/// almashtiriladi; aks holda DEMO (Fake) adapter (namunaviy darslar).
final lessonsServiceProvider = Provider<LessonsService>(
  (ref) => FakeLessonsService(),
);

/// Hamma rejimga ochiq kurs (serverda `audience = 'all'`).
const openLessonCourse = 'Apparatlar bilan ishlash';

/// Server qidiruvi: `''` — to‘liq ro‘yxat, rejimga qarab saralangan (server
/// roli, masalan admin, buni o‘zgartirmaydi).
final lessonListProvider = FutureProvider.autoDispose
    .family<ClassResult<List<LessonSummary>>, String>((ref, query) async {
      final mode = ref.watch(
        settingsControllerProvider.select((s) => s.userMode),
      );
      final res = await ref
          .watch(lessonsServiceProvider)
          .list(query: query.isEmpty ? null : query);
      final items = res.value;
      if (items == null) return res;
      // Rejimlar aralashmaydi: Ustoz — ustoz darslari; Mutaxassis —
      // «Apparatlar bilan ishlash» va Sud-kimyoviy ekspertiza ma’ruzalari
      // (Toksikologik kimyo, Sud-tibbiy toksikologiya; egasi, 2026-11-07);
      // Talaba — hamma mavzu (o‘qish, tinglash,
      // o‘zi test yechish; egasi so‘rovi, 2026-11-02).
      return ClassResult.ok([
        for (final s in items)
          if (switch (mode) {
            UserMode.teacher => s.course != openLessonCourse,
            UserMode.professional =>
              LessonTaxonomy.professionalCourses.contains(s.course),
            UserMode.student => true,
            _ => false,
          })
            s,
      ]);
    });

/// Ilova ichidagi tushuntirishlar manbasi (testlarda almashtiriladi).
final narrationSourceProvider = Provider<NarrationSource>(
  (ref) => const AssetNarrationSource(),
);

final lessonDeckProvider = FutureProvider.autoDispose
    .family<ClassResult<LessonDeck>, String>((ref, topicId) async {
      final lang = ref.watch(
        settingsControllerProvider.select(
          (s) => s.locale?.languageCode ?? 'uz',
        ),
      );
      final res = await ref
          .watch(lessonsServiceProvider)
          .get(topicId, lang: lang);
      final deck = res.value;
      if (deck == null || deck.deckId.isEmpty) return res;
      final items = await ref.watch(narrationSourceProvider).load(deck.deckId);
      return ClassResult.ok(applyNarration(deck, items));
    });

/// Darsning asl (o‘zbekcha) deck’i — tarjima qilingan deck bilan bir xil
/// tuzilmani tanlash uchun (og‘zaki bilet savollari id’lari). Tushuntirishlar
/// (narration) qo‘shilmaydi.
final lessonDeckUzProvider = FutureProvider.autoDispose
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

/// Dars bilan bog‘liq test mavzusi (`class_practice_topics` da `deck_id` yoki uning
/// `~ru`/`~en` varianti) bormi. Yuklanayotgan yoki xatoda — `false`.
final lessonQuizAvailableProvider = Provider.autoDispose.family<bool, String>((
  ref,
  deckId,
) {
  if (deckId.isEmpty) return false;
  final topics = ref.watch(classPracticeTopicsProvider).value?.value;
  if (topics == null) return false;
  final base = ClassQuizBank.baseId(deckId);
  return topics.any((t) => ClassQuizBank.baseId(t.id) == base);
});

/// Dars ko‘rgichida avto-varaqlash tanlovi (rejim va tezlik).
class LessonAutoPrefs {
  const LessonAutoPrefs({this.auto = false, this.seconds = 30});

  /// Ruxsat etilgan tezliklar (soniya). `0` — «Ovoz tugagach»: slayd
  /// ovozda o‘qib bo‘lingach keyingisiga o‘tadi va o‘qishni davom ettiradi.
  static const options = <int>[voice, 15, 30, 60];

  /// «Ovoz tugagach» rejimi.
  static const voice = 0;

  final bool auto;
  final int seconds;

  LessonAutoPrefs copyWith({bool? auto, int? seconds}) => LessonAutoPrefs(
    auto: auto ?? this.auto,
    seconds: seconds ?? this.seconds,
  );
}

/// Tanlovni qurilmada saqlash (faqat bu ikki qiymat; shaxsiy ma’lumot yo‘q).
abstract interface class LessonAutoStore {
  Future<LessonAutoPrefs> load();
  Future<void> save(LessonAutoPrefs prefs);
}

class PrefsLessonAutoStore implements LessonAutoStore {
  const PrefsLessonAutoStore();

  static const _kAuto = 'lesson.autoAdvance';
  static const _kSeconds = 'lesson.autoSeconds';

  @override
  Future<LessonAutoPrefs> load() async {
    try {
      final p = await SharedPreferences.getInstance();
      final s = p.getInt(_kSeconds);
      return LessonAutoPrefs(
        auto: p.getBool(_kAuto) ?? false,
        seconds: LessonAutoPrefs.options.contains(s) ? s! : 30,
      );
    } on Object {
      return const LessonAutoPrefs();
    }
  }

  @override
  Future<void> save(LessonAutoPrefs prefs) async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setBool(_kAuto, prefs.auto);
      await p.setInt(_kSeconds, prefs.seconds);
    } on Object {
      // Saqlab bo‘lmasa — keyingi safar standart qiymat.
    }
  }
}

final lessonAutoStoreProvider = Provider<LessonAutoStore>(
  (ref) => const PrefsLessonAutoStore(),
);
