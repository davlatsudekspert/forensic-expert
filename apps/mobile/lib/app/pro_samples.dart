import 'package:fe_content_schema/fe_content_schema.dart' show KnowledgeArea;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/knowledge/knowledge_models.dart';
import '../domain/library/library_models.dart';
import 'providers.dart';
import 'routes.dart';

/// Qulfli (Pro) bo‘lim ichida ko‘rsatiladigan qisqa namuna manbai
/// (Bepul/Pro bo‘linishi, 2026-10-31): har bo‘limning dastlabki yozuvlari.
enum ProSampleSource {
  reagents,
  screening,
  methods,
  emerging,
  histology,
  laboratory,
  substances,
  research,
}

/// Namuna soni: bo‘limning birinchi 2 ta yozuvi.
const proSampleCount = 2;

/// Namuna qatori (til bo‘yicha nom + ochiladigan yo‘l).
class ProSampleItem {
  const ProSampleItem({
    required this.id,
    required this.name,
    required this.route,
  });

  final String id;
  final LocalizedText name;
  final String route;
}

/// Bo‘lim → dastlabki [proSampleCount] yozuv (repozitoriy tartibida).
final proSamplesProvider =
    Provider.family<List<ProSampleItem>, ProSampleSource>((ref, source) {
      final knowledge = ref.watch(knowledgeRepositoryProvider);
      List<ProSampleItem> fromKnowledge(List<KnowledgeEntry> list) => [
        for (final e in list.take(proSampleCount))
          ProSampleItem(
            id: e.id,
            name: e.name,
            route: Routes.knowledgeEntry(e.id),
          ),
      ];
      return switch (source) {
        ProSampleSource.reagents => fromKnowledge(
          knowledge.byKind(KnowledgeKind.reagent),
        ),
        ProSampleSource.screening => fromKnowledge(
          knowledge.byKind(KnowledgeKind.screeningTest),
        ),
        ProSampleSource.methods => fromKnowledge(
          knowledge.byKind(KnowledgeKind.method),
        ),
        ProSampleSource.emerging => fromKnowledge(
          knowledge.byKind(KnowledgeKind.emergingIssue),
        ),
        ProSampleSource.histology => fromKnowledge(
          knowledge.topicsIn(KnowledgeArea.histology),
        ),
        ProSampleSource.laboratory => fromKnowledge(
          knowledge.topicsIn(KnowledgeArea.laboratory),
        ),
        ProSampleSource.substances => [
          for (final e
              in ref
                  .watch(libraryRepositoryProvider)
                  .entries(LibrarySection.substances)
                  .take(proSampleCount))
            ProSampleItem(
              id: e.id,
              name: e.name,
              route: Routes.libraryEntry(e.id),
            ),
        ],
        ProSampleSource.research => [
          for (final r
              in ref.watch(evidenceDataProvider).research.take(proSampleCount))
            ProSampleItem(
              id: r.id,
              name: LocalizedText({'en': r.title}),
              route: Routes.researchEntry(r.id),
            ),
        ],
      };
    });

/// Barcha namunalar identifikatorlari: ularning yozuv sahifasi qulfsiz
/// ochiladi (namuna o‘qiladigan bo‘lishi uchun).
final proSampleIdsProvider = Provider<Set<String>>((ref) {
  return {
    for (final s in ProSampleSource.values)
      for (final i in ref.watch(proSamplesProvider(s))) i.id,
  };
});
