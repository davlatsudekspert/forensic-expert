import 'models.dart';
import 'normalizer.dart';
import 'similarity.dart';

/// Bitta termin uchun moslik va ballni hisoblaydi. Barcha indeks
/// implementatsiyalari (in-memory va FTS5) bir xil reyting qoidasini
/// ishlatishi uchun alohida sinf.
class SearchRanker {
  const SearchRanker({this.normalizer = const SearchNormalizer()});

  final SearchNormalizer normalizer;

  static const _matchBase = {
    MatchType.exact: 1.0,
    MatchType.prefix: 0.75,
    MatchType.fuzzy: 0.5,
  };

  static const _kindWeight = {
    TermKind.canonical: 1.0,
    TermKind.localized: 0.97,
    TermKind.abbreviation: 0.92,
    TermKind.synonym: 0.9,
    TermKind.formula: 0.9,
    TermKind.misspelling: 0.8,
  };

  /// [queryKey] — `normalizer.searchKey(query)`.
  /// Mos kelmasa `null`.
  SearchHit? score(SearchTerm term, String queryKey, {String? preferredLang}) {
    if (queryKey.isEmpty) return null;
    final termKey = normalizer.searchKey(term.term);
    if (termKey.isEmpty) return null;

    MatchType? type;
    var quality = 1.0;
    if (termKey == queryKey) {
      type = MatchType.exact;
    } else if (queryKey.length >= 2 && termKey.startsWith(queryKey)) {
      type = MatchType.prefix;
      quality = queryKey.length / termKey.length;
    } else {
      final allowed = Similarity.allowedEdits(queryKey.length);
      if (allowed > 0) {
        // So‘rov termin boshiga o‘xshashmi (yozilayotgan so‘z) yoki butun terminga.
        final head = termKey.length > queryKey.length + allowed
            ? termKey.substring(0, queryKey.length)
            : termKey;
        final distance = Similarity.editDistance(queryKey, head);
        if (distance <= allowed) {
          type = MatchType.fuzzy;
          quality = 1 - distance / (queryKey.length + 1);
          // Faqat boshi o‘xshash uzunroq termin to‘liq o‘xshash qisqa
          // termindan past turadi (masalan «fentanly» → «Fentanyl» >
          // «Fentanyl immunoassay»).
          if (head.length < termKey.length) {
            quality *= head.length / termKey.length;
          }
        }
      }
    }
    if (type == null) return null;

    var s =
        _matchBase[type]! *
        (0.6 + 0.4 * quality) *
        _kindWeight[term.kind]! *
        term.weight;
    if (preferredLang != null && term.lang == preferredLang) s *= 1.05;
    return SearchHit(
      entityId: term.entityId,
      category: term.category,
      matchedTerm: term.term,
      matchType: type,
      score: s,
    );
  }

  /// Bir yozuvning eng yaxshi mosligini qoldiradi va kategoriyalarga ajratadi.
  SearchResults group(Iterable<SearchHit> hits, int limitPerCategory) {
    final best = <String, SearchHit>{};
    for (final h in hits) {
      final key = '${h.category.name}:${h.entityId}';
      final current = best[key];
      if (current == null || h.score > current.score) best[key] = h;
    }
    final byCategory = <SearchCategory, List<SearchHit>>{};
    for (final h in best.values) {
      byCategory.putIfAbsent(h.category, () => []).add(h);
    }
    final ordered = <SearchCategory, List<SearchHit>>{};
    for (final c in SearchCategory.values) {
      final list = byCategory[c];
      if (list == null) continue;
      list.sort((a, b) {
        final byScore = b.score.compareTo(a.score);
        return byScore != 0 ? byScore : a.matchedTerm.compareTo(b.matchedTerm);
      });
      ordered[c] = list.take(limitPerCategory).toList();
    }
    return SearchResults(ordered);
  }
}
