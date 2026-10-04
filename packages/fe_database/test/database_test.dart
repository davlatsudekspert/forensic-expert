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

  group('Jurisdiction Layer (schema v2)', () {
    Future<void> seed() async {
      await db
          .into(db.sources)
          .insert(
            SourcesCompanion.insert(
              sourceId: 'TEST-SRC-OFFICIAL',
              sourceType: 'official_document',
              title: 'TEST DATA — official source placeholder',
              tier: 1,
              evidenceLevel: 'A',
              licenseMode: 'openReuse',
              reviewStatus: 'NEEDS_REVIEW',
              isTestData: const Value(1),
            ),
          );
      // ISO 3166 user-assigned kod (XA) — real davlat emas.
      await db
          .into(db.jurisdictions)
          .insert(
            JurisdictionsCompanion.insert(
              jurisdictionId: 'XA',
              level: 'country',
            ),
          );
      await db
          .into(db.jurisdictionalInstruments)
          .insert(
            JurisdictionalInstrumentsCompanion.insert(
              instrumentId: 'TEST-INST-XA',
              jurisdictionId: 'XA',
              instrumentType: 'controlled_substance_schedule',
              officialSourceId: 'TEST-SRC-OFFICIAL',
              effectiveFrom: '2020-01-01',
              version: 'TEST-v1',
              reviewStatus: 'NEEDS_REVIEW',
              isTestData: const Value(1),
            ),
          );
    }

    ClaimsCompanion claim({
      required String id,
      String layer = 'international_scientific',
      String? jurisdictionId,
      String? instrumentId,
    }) => ClaimsCompanion.insert(
      claimId: id,
      entityType: 'substance',
      entityId: 'TEST-SUB-X',
      field: 'legal_status',
      valueJson: '{}',
      domain: 'legal',
      reviewStatus: 'NEEDS_REVIEW',
      evidenceLevel: 'C',
      updatedAt: '2026-10-04',
      isTestData: const Value(1),
      knowledgeLayer: Value(layer),
      jurisdictionId: Value(jurisdictionId),
      instrumentId: Value(instrumentId),
    );

    test('claim qatlami standart — international_scientific', () async {
      await seed();
      await db.into(db.claims).insert(claim(id: 'TEST-C-SCI'));
      final row = await (db.select(
        db.claims,
      )..where((t) => t.claimId.equals('TEST-C-SCI'))).getSingle();
      expect(row.knowledgeLayer, 'international_scientific');
      expect(row.jurisdictionId, equals(null));
    });

    test('yurisdiksion claim yurisdiksiya va hujjatga bog‘lanadi', () async {
      await seed();
      await db
          .into(db.claims)
          .insert(
            claim(
              id: 'TEST-C-JUR',
              layer: 'jurisdictional',
              jurisdictionId: 'XA',
              instrumentId: 'TEST-INST-XA',
            ),
          );
      expect(await db.containsTestData(), isTrue);
    });

    test('qatlamlar aralashmaydi (CHECK)', () async {
      await seed();
      // Ilmiy claim davlatga bog‘lana olmaydi.
      await expectLater(
        db.into(db.claims).insert(claim(id: 'TEST-C1', jurisdictionId: 'XA')),
        throwsA(isA<SqliteException>()),
      );
      // Yurisdiksion claim hujjatsiz bo‘lmaydi.
      await expectLater(
        db
            .into(db.claims)
            .insert(
              claim(
                id: 'TEST-C2',
                layer: 'jurisdictional',
                jurisdictionId: 'XA',
              ),
            ),
        throwsA(isA<SqliteException>()),
      );
      // Noma’lum qatlam.
      await expectLater(
        db.into(db.claims).insert(claim(id: 'TEST-C3', layer: 'national')),
        throwsA(isA<SqliteException>()),
      );
    });

    test('kuchga kirish davri va rasmiy manba majburiy', () async {
      await seed();
      await expectLater(
        db
            .into(db.jurisdictionalInstruments)
            .insert(
              JurisdictionalInstrumentsCompanion.insert(
                instrumentId: 'TEST-INST-BAD',
                jurisdictionId: 'XA',
                instrumentType: 'law',
                officialSourceId: 'TEST-SRC-OFFICIAL',
                effectiveFrom: '2024-01-01',
                effectiveTo: const Value('2023-01-01'),
                version: 'TEST-v1',
                reviewStatus: 'NEEDS_REVIEW',
                isTestData: const Value(1),
              ),
            ),
        throwsA(isA<SqliteException>()),
      );
      await expectLater(
        db
            .into(db.jurisdictionalInstruments)
            .insert(
              JurisdictionalInstrumentsCompanion.insert(
                instrumentId: 'TEST-INST-NOSRC',
                jurisdictionId: 'XA',
                instrumentType: 'law',
                officialSourceId: 'TEST-SRC-MISSING',
                effectiveFrom: '2024-01-01',
                version: 'TEST-v1',
                reviewStatus: 'NEEDS_REVIEW',
                isTestData: const Value(1),
              ),
            ),
        throwsA(isA<SqliteException>()),
      );
    });
  });

  test('UserDatabase bookmark skeleti', () async {
    final u = UserDatabase(NativeDatabase.memory());
    await u.addBookmark('substance', 'TEST-SUB-METH', DateTime.utc(2026));
    expect((await u.allBookmarks()).single.entityId, 'TEST-SUB-METH');
    await u.close();
  });
}
