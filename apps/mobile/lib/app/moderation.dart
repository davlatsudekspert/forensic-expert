import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/moderation/moderation_models.dart';
import '../domain/ports/moderation_ports.dart';
import '../domain/support/support_models.dart';
import 'providers.dart';
import 'support.dart';

/// Bootstrap’da Supabase sozlangan bo‘lsa almashtiriladi.
final moderationServiceProvider = Provider<ModerationService>(
  (ref) => const UnconfiguredModerationService(),
);

/// Shikoyat formasi: backend ulangan bo‘lsa (kirmagan odam ham yuboradi).
final reportAvailableProvider = Provider<bool>(
  (ref) => ref.watch(moderationServiceProvider).isConfigured,
);

final myReportsProvider = FutureProvider.autoDispose<List<MyReport>?>((ref) {
  if (!ref.watch(authStateProvider).signedIn) return Future.value(null);
  return ref.watch(moderationServiceProvider).myReports();
});

final myBlocksProvider = FutureProvider.autoDispose<List<BlockedAuthor>?>((
  ref,
) {
  if (!ref.watch(authStateProvider).signedIn) return Future.value(null);
  return ref.watch(moderationServiceProvider).myBlocks();
});

/// Hamjamiyat qoidalari qabul qilinganmi (server `my_terms`). `null` — noma’lum.
final communityTermsProvider = FutureProvider.autoDispose<bool?>((ref) {
  if (!ref.watch(authStateProvider).signedIn) return Future.value(null);
  return ref.watch(moderationServiceProvider).communityTermsAccepted();
});

/// Admin statistikasi kengaytmasi (faqat server `my_access.is_admin`).
final adminStatsExtProvider = FutureProvider.autoDispose<AdminStatsExt?>((ref) {
  if (!ref.watch(isAdminProvider)) return Future.value(null);
  return ref.watch(moderationServiceProvider).adminStatsExt();
});

final adminReportsProvider = FutureProvider.autoDispose
    .family<AdminPage<AdminReport>?, (AdminReportFilter, int)>((ref, a) {
      if (!ref.watch(isAdminProvider)) return Future.value(null);
      return ref
          .watch(moderationServiceProvider)
          .adminReports(a.$1, limit: a.$2);
    });
