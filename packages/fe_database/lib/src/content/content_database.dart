import 'package:drift/drift.dart';

part 'content_database.g.dart';

/// content.db — imzolangan kontent paketidan keladigan, ilovada faqat
/// o‘qiladigan ilmiy baza.
///
/// Ochish usuli platformaga bog‘liq emas: ilova (`drift_flutter`) yoki
/// test (`NativeDatabase.memory()`) [QueryExecutor] beradi.
@DriftDatabase(include: {'content_schema.drift'})
class ContentDatabase extends _$ContentDatabase {
  ContentDatabase(super.executor);

  /// Kontent sxemasi versiyasi — `PackManifest.schemaVersion` bilan mos.
  static const contentSchemaVersion = 1;

  @override
  int get schemaVersion => contentSchemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// Sog‘lomlik tekshiruvi (paket o‘rnatilgandan keyin, 24.2, 5-qadam).
  Future<bool> integrityOk() async {
    final rows = await customSelect('PRAGMA integrity_check').get();
    return rows.length == 1 && rows.single.data.values.first == 'ok';
  }

  /// Bazada test ma’lumot bormi (production ilova buni rad etadi).
  Future<bool> containsTestData() async {
    final row = await customSelect(
      'SELECT '
      '(SELECT COUNT(*) FROM sources WHERE is_test_data = 1) + '
      '(SELECT COUNT(*) FROM claims WHERE is_test_data = 1) + '
      '(SELECT COUNT(*) FROM substances WHERE is_test_data = 1) + '
      '(SELECT COUNT(*) FROM concentration_records WHERE is_test_data = 1) '
      'AS n',
    ).getSingle();
    return row.read<int>('n') > 0;
  }

  /// FTS5 indeksini `search_terms` jadvalidan qayta quradi.
  Future<void> rebuildSearchIndex() => customStatement(
    "INSERT INTO search_fts_tri(search_fts_tri) VALUES ('rebuild')",
  );

  Future<String?> metaValue(String key) async {
    final row = await (select(
      contentMeta,
    )..where((t) => t.metaKey.equals(key))).getSingleOrNull();
    return row?.metaValue;
  }
}
