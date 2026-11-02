import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/catalog/catalog.dart';
import 'providers.dart';

/// Bootstrap’da Supabase sozlangan bo‘lsa [SupabaseCatalogService].
final catalogServiceProvider = Provider<CatalogService>(
  (ref) => const UnconfiguredCatalogService(),
);

/// Katalog ro‘yxati: (tur, qidiruv).
final catalogListProvider = FutureProvider.autoDispose
    .family<CatalogResult<List<CatalogEntry>>, (CatalogKind, String)>((
      ref,
      key,
    ) {
      ref.watch(authStateProvider.select((s) => s.userId));
      return ref.watch(catalogServiceProvider).list(key.$1, query: key.$2);
    });

/// O‘z holatim: yulduzchalarim soni va katalog roziliklari.
final catalogMeProvider = FutureProvider.autoDispose<CatalogMe>((ref) async {
  final uid = ref.watch(authStateProvider.select((s) => s.userId));
  final svc = ref.watch(catalogServiceProvider);
  if (uid == null || !svc.isConfigured) return CatalogMe.empty;
  return (await svc.me()).value ?? CatalogMe.empty;
});
