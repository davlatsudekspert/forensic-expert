import 'models.dart';
import 'normalizer.dart';
import 'ranker.dart';

/// Xotiradagi indeks — testlar, kichik to‘plamlar va FTS5 natijalarini
/// solishtirish uchun «oracle».
class InMemorySearchIndex implements SearchIndex {
  InMemorySearchIndex(
    Iterable<SearchTerm> terms, {
    this._ranker = const SearchRanker(),
  }) : _terms = List.unmodifiable(terms);

  final List<SearchTerm> _terms;
  final SearchRanker _ranker;

  SearchNormalizer get _normalizer => _ranker.normalizer;

  @override
  Future<SearchResults> search(SearchQuery query) async {
    final key = _normalizer.searchKey(query.text);
    if (key.isEmpty) return const SearchResults({});
    final hits = <SearchHit>[];
    for (final t in _terms) {
      final hit = _ranker.score(t, key, preferredLang: query.preferredLang);
      if (hit != null) hits.add(hit);
    }
    return _ranker.group(hits, query.limitPerCategory);
  }
}
