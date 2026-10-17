import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/pro/analysis_plan.dart';
import '../domain/pro/pro_search.dart';
import 'providers.dart';

/// Paketdan qurilgan kengaytirilgan qidiruv indeksi (offline, qurilmada).
final proSearchIndexProvider = Provider<ProSearchIndex>(
  (ref) => ProSearchIndex.build(
    library: ref.watch(libraryRepositoryProvider),
    knowledge: ref.watch(knowledgeRepositoryProvider),
    evidence: ref.watch(evidenceDataProvider),
    provenance: ref.watch(provenanceIndexProvider),
  ),
);

/// Modda bo‘yicha tahlil rejasi — faqat paketdagi manbali ma’lumotlardan.
final analysisPlanProvider = Provider.family<AnalysisPlan, String>(
  (ref, entityId) => AnalysisPlan.build(
    entityId: entityId,
    analysis: ref.watch(substanceAnalysisProvider(entityId)),
    knowledge: ref.watch(knowledgeRepositoryProvider),
    provenance: ref.watch(provenanceIndexProvider),
    evidence: ref.watch(evidenceDataProvider),
  ),
);
