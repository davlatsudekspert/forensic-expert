import 'package:fe_search_core/fe_search_core.dart';
import 'package:test/test.dart';

/// Katta indeksda xatoli qidiruv: aniq qisqa termin uzun terminlardan
/// (masalan, «X immunoassay», «X test strips») yuqori turishi shart.
void main() {
  test('fuzzy: qisqa to‘liq o‘xshash termin uzun termindan yuqori', () async {
    final index = InMemorySearchIndex([
      const SearchTerm(
        entityId: 'fentanyl',
        category: SearchCategory.substance,
        term: 'Fentanyl',
        kind: TermKind.canonical,
      ),
      const SearchTerm(
        entityId: 'scr-fentanyl-ia',
        category: SearchCategory.screeningTest,
        term: 'Fentanyl immunoassay',
        kind: TermKind.canonical,
      ),
      const SearchTerm(
        entityId: 'scr-fts',
        category: SearchCategory.screeningTest,
        term: 'Fentanyl test strips',
        kind: TermKind.canonical,
      ),
    ]);
    final r = await index.search(const SearchQuery('fentanly'));
    final all = [for (final h in r.byCategory.values) ...h]
      ..sort((a, b) => b.score.compareTo(a.score));
    expect(all.first.entityId, 'fentanyl');
    expect(all.length, 3);
  });
}
