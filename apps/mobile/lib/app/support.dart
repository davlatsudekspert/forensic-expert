import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/ports/support_ports.dart';
import '../domain/support/support_models.dart';
import 'account.dart';
import 'providers.dart';

/// Bootstrap’da Supabase sozlangan bo‘lsa almashtiriladi.
final supportServiceProvider = Provider<SupportService>(
  (ref) => const UnconfiguredSupportService(),
);

/// Bo‘lim ko‘rinadimi (backend ulangan yig‘ma).
final supportAvailableProvider = Provider<bool>(
  (ref) => ref.watch(supportServiceProvider).isConfigured,
);

final mySupportThreadsProvider =
    FutureProvider.autoDispose<List<SupportThread>?>((ref) {
      final auth = ref.watch(authStateProvider);
      if (!auth.signedIn) return Future.value(null);
      return ref.watch(supportServiceProvider).myThreads();
    });

final supportThreadProvider = FutureProvider.autoDispose
    .family<SupportThread?, String>(
      (ref, id) => ref.watch(supportServiceProvider).thread(id),
    );

/// O‘qilmagan admin javoblari (Profil tabidagi belgi va ochilish banneri).
/// Push/email yo‘q — ilova ochilganda va murojaat ko‘rilganda yangilanadi.
final supportUnreadProvider = FutureProvider<int>((ref) async {
  final auth = ref.watch(authStateProvider);
  final svc = ref.watch(supportServiceProvider);
  if (!auth.signedIn || !svc.isConfigured) return 0;
  return svc.unreadCount();
});

/// Admin (faqat server `my_access` javobidan; email’dan HECH QACHON).
final isAdminProvider = Provider<bool>(
  (ref) => ref.watch(serverAccessProvider).value?.isAdmin ?? false,
);

final adminStatsProvider = FutureProvider.autoDispose<AdminStats?>((ref) {
  if (!ref.watch(isAdminProvider)) return Future.value(null);
  return ref.watch(supportServiceProvider).adminStats();
});

/// Inbox sahifasi: (saralash, nechta yuklangan).
final adminInboxProvider = FutureProvider.autoDispose
    .family<AdminPage<SupportThread>?, (SupportInboxFilter, int)>((ref, a) {
      if (!ref.watch(isAdminProvider)) return Future.value(null);
      return ref
          .watch(supportServiceProvider)
          .adminInbox(a.$1, limit: a.$2, offset: 0);
    });

final adminUsersProvider = FutureProvider.autoDispose
    .family<AdminPage<AdminUserSummary>?, AdminUserFilter>((ref, f) {
      if (!ref.watch(isAdminProvider)) return Future.value(null);
      return ref.watch(supportServiceProvider).adminUsers(f);
    });

final adminAuditProvider = FutureProvider.autoDispose<List<AdminAuditEntry>?>((
  ref,
) {
  if (!ref.watch(isAdminProvider)) return Future.value(null);
  return ref.watch(supportServiceProvider).adminAuditLog();
});
