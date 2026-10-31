import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/guidelines/guideline_models.dart';
import '../domain/learn/study_models.dart';
import 'guidelines.dart';
import 'plan.dart' show proStrictProvider;
import 'providers.dart';

/// O‘quv rejimi katalogi — kutubxona, bilim yozuvlari va yo‘riqnomalardan
/// (faqat manbasi bor yozuvlar).
final studyCatalogProvider = Provider<StudyCatalog>((ref) {
  return StudyCatalogBuilder.build(
    knowledge: ref.watch(knowledgeRepositoryProvider),
    library: ref.watch(libraryRepositoryProvider),
    guidelines: ref.watch(guidelinesProvider).value ?? GuidelineBundle.empty,
  );
});

/// Talabaga bepul kartochkalar to‘plami (1 fan): katalogdagi birinchisi.
///
/// Qat’iy Bepul/Pro bo‘linishida (2026-10-31) mustaqil kartochkalar ham Pro:
/// bepul to‘plam yo‘q.
final studyFreeDeckIdProvider = Provider<String?>(
  (ref) => ref.watch(proStrictProvider)
      ? null
      : ref.watch(studyCatalogProvider).decks.firstOrNull?.id,
);

/// Manbalar hali yuklanmoqdami (bo‘sh holat o‘rniga skelet ko‘rsatish uchun).
final studyCatalogLoadingProvider = Provider<bool>(
  (ref) => ref.watch(guidelinesProvider).isLoading,
);

/// Bootstrap’da SharedPreferences bilan override qilinadi.
final studyProgressStoreProvider = Provider<StudyProgressStore>(
  (ref) => InMemoryStudyProgressStore(),
);

/// Soat (testlarda almashtiriladi).
final studyClockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// Test uchun seed manbai (testlarda — qat’iy qiymat).
final studySeedProvider = Provider<int Function()>(
  (ref) =>
      () => DateTime.now().microsecondsSinceEpoch,
);

final studyProgressProvider =
    NotifierProvider<StudyProgressController, Map<String, LeitnerCard>>(
      StudyProgressController.new,
    );

/// Leitner qutilari — faqat lokal.
class StudyProgressController extends Notifier<Map<String, LeitnerCard>> {
  @override
  Map<String, LeitnerCard> build() =>
      ref.read(studyProgressStoreProvider).load();

  Future<void> _set(Map<String, LeitnerCard> next) async {
    state = next;
    await ref.read(studyProgressStoreProvider).save(next);
  }

  Future<void> record(String itemId, {required bool knew}) => _set({
    ...state,
    itemId: LeitnerScheduler.review(
      state[itemId],
      knew: knew,
      now: ref.read(studyClockProvider)(),
    ),
  });

  Future<void> reset(Iterable<String> itemIds) {
    final ids = itemIds.toSet();
    return _set({
      for (final e in state.entries)
        if (!ids.contains(e.key)) e.key: e.value,
    });
  }
}
