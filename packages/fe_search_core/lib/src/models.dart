import 'package:meta/meta.dart';

/// Global Search natija toifalari (6-bo‘lim talabidagi tartibda).
/// Qidiruv toifalari. Yangi toifa qo‘shish — faqat shu ro‘yxat va ilova
/// guruhlash xaritasi (PHASE 4: global taksonomiya).
enum SearchCategory {
  substance,
  metabolite,
  method,
  calculator,
  topic,
  learning,
  glossary,
  caseStudy,
  reference,
  reagent,
  solution,
  screeningTest,
  forensicMedicineTopic,
  biochemistryTopic,
  standard,
  law,
  lesson,
  emergingIssue,
}

/// Indeksdagi termin turi — reytingga ta’sir qiladi.
enum TermKind {
  canonical,
  localized,
  synonym,
  abbreviation,
  misspelling,
  formula,
}

/// Indekslanadigan bitta termin. Bitta yozuvning ko‘p terminlari bo‘ladi
/// (canonical nom, EN/RU/UZ nomlari, sinonimlar).
@immutable
class SearchTerm {
  const SearchTerm({
    required this.entityId,
    required this.category,
    required this.term,
    required this.kind,
    this.lang,
    this.weight = 1.0,
  });

  final String entityId;
  final SearchCategory category;
  final String term;
  final TermKind kind;

  /// `en`, `ru`, `uz` yoki `null` (tildan mustaqil: formula va h.k.).
  final String? lang;
  final double weight;
}

/// Moslik turi — kuchlidan kuchsizga.
enum MatchType { exact, prefix, fuzzy }

@immutable
class SearchHit {
  const SearchHit({
    required this.entityId,
    required this.category,
    required this.matchedTerm,
    required this.matchType,
    required this.score,
  });

  final String entityId;
  final SearchCategory category;
  final String matchedTerm;
  final MatchType matchType;
  final double score;

  @override
  String toString() =>
      'SearchHit($entityId, ${category.name}, "$matchedTerm", ${matchType.name}, '
      '${score.toStringAsFixed(3)})';
}

@immutable
class SearchQuery {
  const SearchQuery(this.text, {this.preferredLang, this.limitPerCategory = 5});

  final String text;

  /// Foydalanuvchi interfeysi tili — shu tildagi terminlar ustun.
  final String? preferredLang;
  final int limitPerCategory;
}

/// Kategoriyalangan natija.
@immutable
class SearchResults {
  const SearchResults(this.byCategory);

  final Map<SearchCategory, List<SearchHit>> byCategory;

  bool get isEmpty => byCategory.values.every((l) => l.isEmpty);

  List<SearchHit> get all => [for (final l in byCategory.values) ...l];
}

/// Qidiruv indeksi kontrakti. Implementatsiyalar:
/// * `InMemorySearchIndex` — testlar va kichik to‘plamlar;
/// * `fe_database` dagi SQLite FTS5 indeksi — production.
abstract interface class SearchIndex {
  Future<SearchResults> search(SearchQuery query);
}
