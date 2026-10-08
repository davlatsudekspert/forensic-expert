import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/guidelines/guideline_models.dart';
import '../domain/learn/study_models.dart';
import '../domain/ports/billing_ports.dart';
import 'guidelines.dart';
import 'providers.dart';

/// O‘quv rejimi katalogi — kutubxona, bilim yozuvlari va yo‘riqnomalardan
/// (faqat manbasi bor yozuvlar). Pullik yozuvlar ruxsat bo‘lsagina.
final studyCatalogProvider = Provider<StudyCatalog>((ref) {
  final access = ref.watch(accessProvider);
  return StudyCatalogBuilder.build(
    knowledge: ref.watch(knowledgeRepositoryProvider),
    library: ref.watch(libraryRepositoryProvider),
    guidelines: ref.watch(guidelinesProvider).value ?? GuidelineBundle.empty,
    substancesUnlocked: AccessPolicy.unlocks(
      ProductFeature.substanceLibrary,
      access,
    ),
    referencesUnlocked: AccessPolicy.unlocks(
      ProductFeature.verifiedReferences,
      access,
    ),
  );
});

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
