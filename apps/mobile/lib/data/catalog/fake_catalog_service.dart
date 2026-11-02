import '../../domain/catalog/catalog.dart';

/// Soxta katalog (testlar va demo): server qoidalari nusxasi — o‘ziga
/// yulduzcha yo‘q, bitta hisob — bitta yulduzcha.
class FakeCatalogService implements CatalogService {
  FakeCatalogService({
    required this.userIdOf,
    List<CatalogEntry> entries = const [],
    this.me0 = CatalogMe.empty,
  }) : entries = [...entries];

  final String? Function() userIdOf;
  final List<CatalogEntry> entries;
  CatalogMe me0;

  /// target → bosganlar.
  final stars = <String, Set<String>>{};
  final calls = <String>[];

  @override
  bool get isConfigured => true;

  CatalogEntry _view(CatalogEntry e, String me) => e.copyWith(
    stars: e.stars + (stars[e.id]?.length ?? 0),
    starred: stars[e.id]?.contains(me) ?? false,
  );

  @override
  Future<CatalogResult<List<CatalogEntry>>> list(
    CatalogKind kind, {
    String? query,
  }) async {
    final me = userIdOf();
    if (me == null) return const CatalogResult.fail(CatalogFailure.notSignedIn);
    calls.add('list:${kind.wire}');
    final q = (query ?? '').trim().toLowerCase();
    final out = [
      for (final e in entries)
        if (e.kind == kind &&
            (q.isEmpty ||
                e.name.toLowerCase().contains(q) ||
                e.subtitle.toLowerCase().contains(q)))
          _view(e, me),
    ]..sort((a, b) => b.stars.compareTo(a.stars));
    return CatalogResult.ok(out);
  }

  @override
  Future<CatalogResult<(bool, int)>> toggleStar(String targetId) async {
    final me = userIdOf();
    if (me == null) return const CatalogResult.fail(CatalogFailure.notSignedIn);
    if (me == targetId) return const CatalogResult.fail(CatalogFailure.server);
    final base = entries.where((e) => e.id == targetId).firstOrNull;
    if (base == null) return const CatalogResult.fail(CatalogFailure.notFound);
    calls.add('star:$targetId');
    final set = stars.putIfAbsent(targetId, () => <String>{});
    final on = !set.remove(me);
    if (on) set.add(me);
    return CatalogResult.ok((on, base.stars + set.length));
  }

  @override
  Future<CatalogResult<CatalogMe>> me() async {
    if (userIdOf() == null) {
      return const CatalogResult.fail(CatalogFailure.notSignedIn);
    }
    return CatalogResult.ok(me0);
  }

  @override
  Future<CatalogResult<void>> setVisible(CatalogKind kind, bool on) async {
    calls.add('visible:${kind.wire}:$on');
    me0 = CatalogMe(
      stars: me0.stars,
      teacherCatalog: kind == CatalogKind.teacher ? on : me0.teacherCatalog,
      expertCatalog: kind == CatalogKind.expert ? on : me0.expertCatalog,
      expertEligible: me0.expertEligible,
    );
    return const CatalogResult.ok(null);
  }
}
