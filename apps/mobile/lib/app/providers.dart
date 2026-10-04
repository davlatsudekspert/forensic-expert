import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/flags.dart';
import '../core/telemetry/telemetry.dart';
import '../data/fixtures/test_fixtures.dart';
import '../data/local/content_store.dart';
import '../data/offline/offline_ai.dart';
import '../data/offline/offline_backend.dart';
import '../data/offline/offline_billing.dart';
import '../domain/jurisdiction/jurisdiction_catalog.dart';
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

/// Kutubxona manbasi. PHASE 2: TEST fixture’lar (aniq belgilangan).
final libraryRepositoryProvider = Provider<LibraryRepository>(
  (ref) => FeFlags.showTestFixtures
      ? const FixtureLibraryRepository()
      : const EmptyLibraryRepository(),
);

final learnRepositoryProvider = Provider<LearnRepository>(
  (ref) => FeFlags.showTestFixtures
      ? const FixtureLearnRepository()
      : const EmptyLearnRepository(),
);

/// Telemetriya — PHASE 2 da hech narsa yubormaydi.
final telemetryProvider = Provider<TelemetrySink>(
  (ref) => const NoopTelemetrySink(),
);

/// Jurisdiction Layer. Hozircha faqat yurisdiksiyalar ro‘yxati bor —
/// rasmiy hujjat va qoidalar yo‘q (ular imzolangan kontent paketidan keladi).
/// Shu sababli har qanday yurisdiksiya uchun natija — «kontent yuklanmagan».
final jurisdictionResolverProvider = Provider<JurisdictionResolver>(
  (ref) => JurisdictionResolver(
    jurisdictions: JurisdictionCatalog.seed,
    instruments: const [],
    rules: const [],
  ),
);
