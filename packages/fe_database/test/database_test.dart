import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:fe_database/fe_database.dart';
import 'package:fe_search_core/fe_search_core.dart';
import 'package:test/test.dart';

import '../../fe_search_core/test/fixtures/terminology_test_data.dart';

// TEST DATA — barcha yozuvlar `TEST-` prefiksli va `is_test_data = 1`.
void main() {
  late ContentDatabase db;

  setUp(() async {
    db = ContentDatabase(NativeDatabase.memory());
    await db.insertSearchTerms(terminologyTestData);
  });
  tearDown(() => db.close());

  test(
    'bundled SQLite FTS5 trigram tokenizer’ni qo‘llab-quvvatlaydi',
    () async {
      final v = await db
          .customSelect('SELECT sqlite_version() AS v')
          .getSingle();
      final parts = v.read<String>('v').split('.').map(int.parse).toList();
      expect(
        parts[0] > 3 || (parts[0] == 3 && parts[1] >= 34),
        isTrue,
        reason: 'trigram requires SQLite >= 3.34',
      );
    },
  );

  test('integrity_check va schema versiyasi', () async {
    expect(await db.integrityOk(), isTrue);
    expect(db.schemaVersion, ContentDatabase.contentSchemaVersion);
  });

  test(
    '"fatal" konsentratsiya toifasini baza o‘zi rad etadi (CHECK)',
    () async {
      await db
          .into(db.sources)
          .insert(
            SourcesCompanion.insert(
              sourceId: 'TEST-SRC',
              sourceType: 'journal_article',
              title: 'TEST DATA',
              tier: 1,
              evidenceLevel: 'B',
              licenseMode: 'openReuse',
              reviewStatus: 'NEEDS_REVIEW',
              isTestData: const Value(1),
            ),
          );
      await db
          .into(db.substances)
          .insert(
            SubstancesCompanion.insert(
              substanceId: 'TEST-SUB-X',
              canonicalName: 'test substance x',
              entityKind: 'drug',
              tierAccess: 'free',
              reviewStatus: 'NEEDS_REVIEW',
              contentVersion: 'TEST',
              isTestData: const Value(1),
            ),
          );
      await db
          .into(db.claims)
          .insert(
            ClaimsCompanion.insert(
              claimId: 'TEST-CLAIM',
              entityType: 'substance',
              entityId: 'TEST-SUB-X',
              field: 'concentration',
              valueJson: '{}',
              domain: 'tox',
              reviewStatus: 'NEEDS_REVIEW',
              evidenceLevel: 'B',
              updatedAt: '2026-10-04',
              isTestData: const Value(1),
            ),
          );
      expect(
        () => db
            .into(db.concentrationRecords)
            .insert(
              ConcentrationRecordsCompanion.insert(
                recordId: 'TEST-REC',
                substanceId: 'TEST-SUB-X',
                category: 'fatal_threshold',
                specimenCode: 'TEST',
                population: 'TEST',
                valueType: 'single',
                unit: 'TEST-UNIT',
                claimId: 'TEST-CLAIM',
                isTestData: const Value(1),
              ),
            ),
        throwsA(isA<SqliteException>()),
      );
      expect(await db.containsTestData(), isTrue);
    },
  );

  test('bo‘sh baza test ma’lumot saqlamaydi', () async {
    final empty = ContentDatabase(NativeDatabase.memory());
    expect(await empty.containsTestData(), isFalse);
    await empty.close();
  });

  group('FtsSearchIndex', () {
    late FtsSearchIndex fts;
    late InMemorySearchIndex oracle;
    setUp(() {
      fts = FtsSearchIndex(db);
      oracle = InMemorySearchIndex(terminologyTestData);
    });

    final queries = [
      'methamphetamine',
      'метамфетамин',
      'metamfetamin',
      'metamfetamn',
      'fentanly',
      'морфн',
      'парацет',
      'acetaminophen',
      'этиловый спирт',
      'amfetamin',
      'GC MS',
      'разведение',
      "o'lim vaqti",
      'oʻlim',
      'zzzzqqq',
      'et',
    ];

    for (final q in queries) {
      test('FTS natijasi in-memory oracle bilan mos: "$q"', () async {
        final a = await fts.search(SearchQuery(q));
        final b = await oracle.search(SearchQuery(q));
        List<String> ids(SearchResults r) => [
          for (final e in r.byCategory.entries)
            for (final h in e.value) '${e.key.name}:${h.entityId}',
        ];
        expect(ids(a), ids(b));
      });
    }

    test('ko‘p tilli so‘rov FTS orqali canonical yozuvni topadi', () async {
      for (final q in ['methamphetamine', 'метамфетамин', 'metamfetamin']) {
        final r = await fts.search(SearchQuery(q));
        expect(
          r.byCategory[SearchCategory.substance]!.first.entityId,
          'TEST-SUB-METH',
        );
      }
    });
  });

  test('UserDatabase bookmark skeleti', () async {
    final u = UserDatabase(NativeDatabase.memory());
    await u.addBookmark('substance', 'TEST-SUB-METH', DateTime.utc(2026));
    expect((await u.allBookmarks()).single.entityId, 'TEST-SUB-METH');
    await u.close();
  });
}
