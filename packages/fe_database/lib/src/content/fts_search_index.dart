import 'package:drift/drift.dart';
import 'package:fe_search_core/fe_search_core.dart';

import 'content_database.dart';

/// SQLite FTS5 (trigram) asosidagi Global Search indeksi.
///
/// Ikki bosqich:
/// 1. **Nomzodlar** — SQL: aniq/prefiks kalit (`search_key` indeksi) va
///    trigram FTS (typo uchun).
/// 2. **Reyting** — `fe_search_core` [SearchRanker] (in-memory indeks bilan
///    bir xil qoidalar → natijalar mos bo‘lishi testda tekshiriladi).
class FtsSearchIndex implements SearchIndex {
  FtsSearchIndex(this._db, {this._ranker = const SearchRanker()});

  final ContentDatabase _db;
  final SearchRanker _ranker;

  static const _candidateLimit = 400;

  @override
  Future<SearchResults> search(SearchQuery query) async {
    final key = _ranker.normalizer.searchKey(query.text);
    if (key.isEmpty) return const SearchResults({});

    final rows = await _db
        .customSelect(
          'SELECT entity_id, category, lang, term, term_kind, weight '
          'FROM search_terms WHERE search_key >= ?1 AND search_key < ?2 '
          '${key.length >= 3 ? 'UNION SELECT entity_id, category, lang, term, term_kind, weight '
                    'FROM search_terms WHERE term_id IN '
                    '(SELECT rowid FROM search_fts_tri WHERE search_fts_tri MATCH ?3 LIMIT $_candidateLimit)' : ''}',
          variables: [
            Variable<String>(key),
            Variable<String>('$key\u{FFFF}'),
            if (key.length >= 3) Variable<String>(_trigramQuery(key)),
          ],
          readsFrom: {_db.searchTerms},
        )
        .get();

    final hits = <SearchHit>[];
    for (final r in rows) {
      final term = SearchTerm(
        entityId: r.read<String>('entity_id'),
        category: SearchCategory.values.byName(r.read<String>('category')),
        term: r.read<String>('term'),
        kind: TermKind.values.byName(r.read<String>('term_kind')),
        lang: r.readNullable<String>('lang'),
        weight: r.read<double>('weight'),
      );
      final hit = _ranker.score(term, key, preferredLang: query.preferredLang);
      if (hit != null) hits.add(hit);
    }
    return _ranker.group(hits, query.limitPerCategory);
  }

  /// Kalit trigramlarini OR bilan birlashtirilgan FTS5 so‘rovi.
  /// Har bir trigram qo‘shtirnoq ichida — maxsus belgilar xavfsiz.
  static String _trigramQuery(String key) {
    final grams = <String>{};
    for (var i = 0; i + 3 <= key.length; i++) {
      grams.add(key.substring(i, i + 3).replaceAll('"', '""'));
    }
    return grams.map((g) => '"$g"').join(' OR ');
  }
}

/// Terminlarni bazaga yozish (content pipeline va testlar uchun).
extension SearchTermWriter on ContentDatabase {
  Future<void> insertSearchTerms(
    Iterable<SearchTerm> terms, {
    String entityType = 'substance',
  }) async {
    const normalizer = SearchNormalizer();
    await batch((b) {
      for (final t in terms) {
        b.insert(
          searchTerms,
          SearchTermsCompanion.insert(
            entityType: entityType,
            entityId: t.entityId,
            category: t.category.name,
            lang: Value(t.lang),
            term: t.term,
            searchKey: normalizer.searchKey(t.term),
            termKind: t.kind.name,
            weight: Value(t.weight),
          ),
        );
      }
    });
    await rebuildSearchIndex();
  }
}
