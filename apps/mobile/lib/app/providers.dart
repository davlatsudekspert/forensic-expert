import 'dart:typed_data';

import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/flags.dart';
import '../core/telemetry/telemetry.dart';
import '../data/content/content_evidence_loader.dart';
import '../data/content/content_knowledge_repository.dart';
import '../data/content/content_library_repository.dart';
import '../data/content/content_provenance.dart';
import '../data/fixtures/knowledge_fixtures.dart';
import '../data/fixtures/test_fixtures.dart';
import '../data/local/content_store.dart';
import '../data/offline/offline_ai.dart';
import '../data/offline/offline_backend.dart';
import '../data/offline/offline_billing.dart';
import '../domain/ai/ai_architecture.dart';
import '../domain/ai/local_retrieval.dart';
import '../domain/evidence/evidence_models.dart';
import '../domain/jurisdiction/jurisdiction_catalog.dart';
import '../domain/knowledge/knowledge_models.dart';
import '../domain/learn/learn_models.dart';
import '../domain/library/library_models.dart';
import '../domain/ports/ai_ports.dart';
import '../domain/ports/backend_ports.dart';
import '../domain/ports/billing_ports.dart';

/// Dependency injection nuqtasi. Feature’lar `lib/data` ni to‘g‘ridan-to‘g‘ri
/// import qilmaydi — faqat shu provayderlar orqali (architecture testi).
///
/// PHASE 1 default’lari: hammasi offline, tarmoq so‘rovi yo‘q.

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => const OfflineAuthRepository(),
);

final syncRepositoryProvider = Provider<SyncRepository>(
  (ref) => const DisabledSyncRepository(),
);

final contentUpdateRepositoryProvider = Provider<ContentUpdateRepository>(
  (ref) => const DisabledContentUpdateRepository(),
);

final entitlementServiceProvider = Provider<EntitlementService>(
  (ref) => const StoreUnavailableEntitlementService(),
);

/// Forensic AI ruxsati Lifetime’dan alohida (server xarajati bor).
final aiEntitlementServiceProvider = Provider<AiEntitlementService>(
  (ref) => const NoAiEntitlementService(),
);

final aiAssistantProvider = Provider<AiAssistant>(
  (ref) => const UnavailableAiAssistant(),
);

final piiScannerProvider = Provider<PiiScanner>(
  (ref) => const RegexPiiScanner(),
);

/// LLM provayderi — PHASE 4 da ulanmagan (kalit ilovada yo‘q).
final aiProviderProvider = Provider<AiProvider>(
  (ref) => const UnconfiguredAiProvider(),
);

/// Forensic AI marshrutizatori: xavfsizlik → kvota → lokal qidiruv →
/// provayder → citation tekshiruvi. Til — qidiruv natijasi sarlavhalari uchun.
final aiRouterProvider = Provider.family<AiRouter, String>((ref, lang) {
  final library = ref.watch(libraryRepositoryProvider);
  final knowledge = ref.watch(knowledgeRepositoryProvider);
  final sourceIds = <String>{
    for (final e in library.entries(LibrarySection.substances))
      for (final s in e.details?.allSources ?? const <SourceView>[]) s.sourceId,
    for (final kind in KnowledgeKind.values)
      for (final e in knowledge.byKind(kind))
        for (final s in e.allSources) s.sourceId,
  };
  return AiRouter(
    safety: SafetyPolicy(ref.watch(piiScannerProvider)),
    retrieval: LocalRetrievalProvider(
      library: library,
      knowledge: knowledge,
      languageCode: lang,
    ),
    provider: ref.watch(aiProviderProvider),
    citations: CitationResolver(knownSourceIds: sourceIds),
  );
});

final contentStoreProvider = Provider<ContentStore>(
  (ref) => LocalContentStore(),
);

/// Ilmiy baza holati — lazy, birinchi kadrdan keyin so‘raladi.
final contentStatusProvider = FutureProvider<ContentStatus>(
  (ref) => ref.watch(contentStoreProvider).status(),
);

/// Identifikatorlar siyosati (CAS — konfiguratsiya orqali, default o‘chirilgan).
final identifierPolicyProvider = Provider<IdentifierPolicy>(
  (ref) => IdentifierPolicy.conservativeDefault(),
);

/// Imzolangan kontent paketidan yuklangan kutubxona (lazy, birinchi
/// so‘rovda; startup’ni kutdirmaydi).
final contentLibraryProvider = FutureProvider<LibraryRepository?>((ref) async {
  final db = await ref.watch(contentStoreProvider).openActive();
  return db == null ? null : ContentLibraryRepository.load(db);
});

/// Kutubxona manbasi: kontent paketi; yuklanayotganda yoki paket bo‘lmasa
/// — bo‘sh. TEST fixture’lar faqat `FE_TEST_FIXTURES=true` da.
final libraryRepositoryProvider = Provider<LibraryRepository>(
  (ref) => FeFlags.showTestFixtures
      ? const FixtureLibraryRepository()
      : ref.watch(contentLibraryProvider).value ??
            const EmptyLibraryRepository(),
);

final learnRepositoryProvider = Provider<LearnRepository>(
  (ref) => FeFlags.showTestFixtures
      ? const FixtureLearnRepository()
      : ContentLearnRepository(ref.watch(knowledgeRepositoryProvider)),
);

/// Telemetriya — PHASE 2 da hech narsa yubormaydi.
final telemetryProvider = Provider<TelemetrySink>(
  (ref) => const NoopTelemetrySink(),
);

/// Kontent paketidagi manba va claim’lar (kutubxona va bilim sohalari
/// uchun umumiy, bir marta o‘qiladi).
final contentProvenanceProvider = FutureProvider<ContentProvenance?>((
  ref,
) async {
  final db = await ref.watch(contentStoreProvider).openActive();
  return db == null ? null : ContentProvenance.load(db);
});

/// Bilim sohalari (mavzular, reagentlar, skrining, metodlar, yangi
/// muammolar) — imzolangan paketdan.
final contentKnowledgeProvider = FutureProvider<KnowledgeRepository?>((
  ref,
) async {
  final db = await ref.watch(contentStoreProvider).openActive();
  if (db == null) return null;
  return ContentKnowledgeLoader.load(
    db,
    provenance: await ref.watch(contentProvenanceProvider.future),
  );
});

final knowledgeRepositoryProvider = Provider<KnowledgeRepository>(
  (ref) => FeFlags.showTestFixtures
      ? FixtureKnowledgeRepository()
      : ref.watch(contentKnowledgeProvider).value ??
            const EmptyKnowledgeRepository(),
);

final contentLegalFutureProvider = FutureProvider<ContentLegalData?>((
  ref,
) async {
  final db = await ref.watch(contentStoreProvider).openActive();
  if (db == null) return null;
  return ContentLegalData.load(
    db,
    provenance: await ref.watch(contentProvenanceProvider.future),
  );
});

/// Yuklangan yurisdiksiya ma’lumoti (`null` — paket yo‘q / yuklanmoqda).
final contentLegalDataProvider = Provider<ContentLegalData?>(
  (ref) => ref.watch(contentLegalFutureProvider).value,
);

/// Jurisdiction Layer: ilova katalogi (faqat nomlar) + kontent paketidagi
/// yurisdiksiyalar, rasmiy hujjatlar va qoidalar. Paketda ma’lumot yo‘q
/// yurisdiksiya uchun natija — «ma’lumot yo‘q» (xulosa chiqarilmaydi).
final jurisdictionResolverProvider = Provider<JurisdictionResolver>((ref) {
  final data = ref.watch(contentLegalDataProvider);
  final byId = {for (final j in JurisdictionCatalog.seed) j.id: j};
  for (final j in data?.jurisdictions ?? const <Jurisdiction>[]) {
    // Paket nomlari katalog tarjimalarini o‘chirmaydi (birlashtiriladi).
    final seed = byId[j.id];
    byId[j.id] = seed == null
        ? j
        : Jurisdiction(
            id: j.id,
            level: j.level,
            parentId: j.parentId,
            iso3166: j.iso3166,
            names: {...seed.names, ...j.names},
          );
  }
  return JurisdictionResolver(
    jurisdictions: byId.values,
    instruments: data?.instruments ?? const [],
    rules: data?.rules ?? const [],
  );
});

final legalCatalogProvider = Provider<LegalCatalog>(
  (ref) => ref.watch(contentLegalDataProvider)?.catalog ?? LegalCatalog.empty,
);

/// Tekshirilmagan (NEEDS_REVIEW) huquqiy qoidalar ko‘rsatiladimi.
/// Faqat development/pilot kanalda — har doim status belgisi bilan.
/// Production kanalda faqat reviewer tasdiqlagan qoidalar.
final showUnreviewedLegalProvider = Provider<bool>(
  (ref) => FeFlags.contentChannel != 'production',
);

/// Research / Evidence Library, bilim grafigi va rasmlar katalogi.
final contentEvidenceProvider = FutureProvider<EvidenceData?>((ref) async {
  final db = await ref.watch(contentStoreProvider).openActive();
  return db == null ? null : ContentEvidenceLoader.load(db);
});

final evidenceDataProvider = Provider<EvidenceData>(
  (ref) => FeFlags.showTestFixtures
      ? EvidenceData.empty
      : ref.watch(contentEvidenceProvider).value ?? EvidenceData.empty,
);

/// Rasm baytlari — kerak bo‘lganda bazadan (offline).
final imageBytesLoaderProvider = FutureProvider<ImageBytesLoader>((ref) async {
  final db = await ref.watch(contentStoreProvider).openActive();
  return db == null ? const NoImageBytesLoader() : DbImageBytesLoader(db);
});

final imageBytesProvider = FutureProvider.family<Uint8List?, String>((
  ref,
  imageId,
) async {
  final loader = await ref.watch(imageBytesLoaderProvider.future);
  return loader.load(imageId);
});

/// Joriy kirish huquqi (store o‘zgarishlarini kuzatadi).
final entitlementsProvider = StreamProvider<Entitlements>(
  (ref) => ref.watch(entitlementServiceProvider).watch(),
);

/// UI uchun sinxron qiymat: oqim hali kelmagan bo‘lsa — servisning joriy holati.
final accessProvider = Provider<Entitlements>(
  (ref) =>
      ref.watch(entitlementsProvider).value ??
      ref.watch(entitlementServiceProvider).current,
);
