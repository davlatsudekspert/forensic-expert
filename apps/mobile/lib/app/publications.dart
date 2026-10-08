import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/flags.dart';
import '../domain/ports/publication_ports.dart';
import '../domain/publications/publication_models.dart';
import 'account.dart';
import 'providers.dart';

/// Bootstrap’da Supabase sozlangan bo‘lsa almashtiriladi.
final publicationServiceProvider = Provider<PublicationService>(
  (ref) => const UnconfiguredPublicationService(),
);

/// Yig‘ish bayrog‘i `FE_PUBLICATIONS` (testlarda almashtiriladi).
final publicationsFlagProvider = Provider<bool>((ref) => FeFlags.publications);

/// Bo‘lim (hub plitkasi, ro‘yxat, yuborish) ko‘rinadimi: bayroq yoqilgan
/// yoki foydalanuvchi admin (egasi sinab ko‘rishi uchun). O‘qish bepul —
/// obuna talab qilinmaydi.
final publicationsVisibleProvider = Provider<bool>((ref) {
  if (ref.watch(publicationsFlagProvider)) return true;
  return ref.watch(serverAccessProvider).value?.isAdmin ?? false;
});

/// Moderator (identity_admin yoki publication_moderator) — serverdan.
final canModeratePublicationsProvider = FutureProvider<bool>((ref) async {
  final auth = ref.watch(authStateProvider);
  final svc = ref.watch(publicationServiceProvider);
  if (!auth.signedIn || !svc.isConfigured) return false;
  return svc.canModerate();
});

final publishedPublicationsProvider =
    FutureProvider.autoDispose<List<Publication>?>(
      (ref) => ref.watch(publicationServiceProvider).listPublished(),
    );

final myPublicationsProvider = FutureProvider.autoDispose<List<Publication>?>((
  ref,
) {
  final auth = ref.watch(authStateProvider);
  if (!auth.signedIn) return Future.value(null);
  return ref.watch(publicationServiceProvider).myPublications();
});

final moderationQueueProvider = FutureProvider.autoDispose<ModerationQueue?>((
  ref,
) async {
  if (!await ref.watch(canModeratePublicationsProvider.future)) return null;
  return ref.watch(publicationServiceProvider).moderationQueue();
});

/// Bitta maqola: nashr etilganlar, o‘zimniki yoki moderatsiya navbatidan.
final publicationByIdProvider = FutureProvider.autoDispose
    .family<Publication?, String>((ref, id) async {
      Publication? find(List<Publication>? l) {
        for (final p in l ?? const <Publication>[]) {
          if (p.id == id) return p;
        }
        return null;
      }

      return find(await ref.watch(publishedPublicationsProvider.future)) ??
          find(await ref.watch(myPublicationsProvider.future)) ??
          find((await ref.watch(moderationQueueProvider.future))?.items);
    });
