import 'dart:io';

import 'package:drift/native.dart';
import 'package:fe_content_package/fe_content_package.dart';
import 'package:fe_content_pipeline/fe_content_pipeline.dart';
import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:fe_database/fe_database.dart' as db;
import 'package:fe_search_core/fe_search_core.dart';
import 'package:test/test.dart';

/// Haqiqiy pilot to‘plami (`content/pilot/bundle.json`) bilan sinov.
void main() {
  final bundleFile = File('../../content/pilot/bundle.json');
  late PipelineBundle bundle;
  late Directory tmp;

  setUpAll(() {
    bundle = BundleCodec.decode(bundleFile.readAsStringSync());
  });
  setUp(() => tmp = Directory.systemTemp.createTempSync('fe_pipe'));
  tearDown(() => tmp.deleteSync(recursive: true));

  group('pilot to‘plami — qat’iy qoidalar', () {
    test('10–20 ta pilot yozuv', () {
      expect(bundle.substances.length, inInclusiveRange(10, 20));
    });

    test('hech bir claim, hujjat yoki qoida VERIFIED/REVIEWED emas', () {
      for (final c in bundle.content.claims) {
        expect(
          c.declaredStatus,
          ScientificStatus.needsReview,
          reason: c.claimId,
        );
      }
      for (final i in bundle.content.instruments) {
        expect(i.status, ScientificStatus.needsReview);
      }
      for (final r in bundle.content.jurisdictionalRules) {
        expect(r.status, ScientificStatus.needsReview);
      }
      expect(bundle.content.reviews, isEmpty);
    });

    test('TEST DATA yo‘q (pilot — haqiqiy manbalar)', () {
      expect(bundle.content.sources.where((s) => s.isTestData), isEmpty);
      expect(bundle.content.claims.where((c) => c.isTestData), isEmpty);
      for (final s in bundle.substances) {
        expect(s.substanceId.startsWith('TEST-'), isFalse);
      }
    });

    test('har bir claim manbaga ega; manbalar identifikatori tekshirilgan', () {
      final cited = {for (final c in bundle.content.citations) c.claimId};
      for (final c in bundle.content.claims) {
        expect(cited, contains(c.claimId));
      }
      for (final s in bundle.content.sources) {
        expect(s.identifierVerified, isTrue, reason: s.sourceId);
        expect(s.accessedDate, isNotNull, reason: s.sourceId);
      }
    });

    test('iqtibos matni faqat ochiq litsenziyali manbadan', () {
      final sources = {for (final s in bundle.content.sources) s.sourceId: s};
      final byClaim = {
        for (final c in bundle.content.citations) c.claimId: c.sourceId,
      };
      for (final c in bundle.content.claims) {
        if (c.value['excerpt'] == null) continue;
        final src = sources[byClaim[c.claimId]]!;
        expect(src.licenseMode, SourceLicenseMode.openReuse, reason: c.claimId);
      }
    });

    test('ilmiy va huquqiy qatlam aralashmagan', () {
      for (final c in bundle.content.claims) {
        expect(c.layer, KnowledgeLayer.internationalScientific);
        expect(c.jurisdictionId, isNull);
        expect(c.domain, isNot(ContentDomain.legal));
      }
      for (final i in bundle.content.instruments) {
        expect(i.jurisdictionId, 'INT');
        expect(i.officialSourceId, isNotEmpty);
      }
    });

    test('bepul demo: ko‘pi bilan 3 ta yozuv', () {
      expect(
        bundle.substances.where((s) => s.tierAccess == 'free').length,
        lessThanOrEqualTo(3),
      );
    });
  });

  group('validator', () {
    test('development kanal — xatosiz', () {
      final r = const ContentValidator().validate(bundle.content);
      expect(r.isValid, isTrue, reason: r.issues.join('\n'));
    });

    test(
      'production kanal — rad etiladi (FE008), paket yaratilmaydi',
      () async {
        final prod = bundle.withChannel(BundleChannel.production);
        final out = Directory('${tmp.path}/prod');
        await expectLater(
          const PackBuilder().build(
            bundle: prod,
            outDir: out,
            builtAt: DateTime.utc(2026, 10, 4),
            signingSeed: List.filled(32, 7),
          ),
          throwsA(
            isA<PipelineValidationError>().having(
              (e) => e.report.hasCode(RuleCodes.unpublishableStatus),
              'FE008',
              isTrue,
            ),
          ),
        );
        expect(out.existsSync(), isFalse);
      },
    );

    test('production kaliti tashqaridan berilmasa — paket yo‘q', () async {
      // Validator’dan o‘tadigan minimal production to‘plami ham kalitsiz
      // imzolanmaydi.
      final empty = BundleCodec.decode(
        '{"format":"fe-bundle/1","pack_version":"2026.10.1",'
        '"channel":"production","jurisdictions":[],"sources":[],'
        '"substances":[],"claims":[],"citations":[],"instruments":[],'
        '"rules":[],"reviewers":[],"reviews":[]}',
      );
      await expectLater(
        const PackBuilder().build(
          bundle: empty,
          outDir: Directory('${tmp.path}/p'),
          builtAt: DateTime.utc(2026),
        ),
        throwsStateError,
      );
    });

    test('noma’lum format va enum — xato', () {
      expect(
        () => BundleCodec.decode('{"format":"x"}'),
        throwsA(isA<BundleFormatException>()),
      );
    });
  });

  group('paket', () {
    late BuiltPack pack;
    setUp(() async {
      pack = await const PackBuilder().build(
        bundle: bundle,
        outDir: Directory('${tmp.path}/pack'),
        builtAt: DateTime.utc(2026, 10, 4),
      );
    });

    Future<PackVerification> verify({
      Map<String, List<int>>? files,
      PackChannel accepted = PackChannel.development,
    }) => PackVerifier(TrustedKeys({pack.keyId: pack.publicKey})).verify(
      manifestBytes: File('${pack.directory.path}/manifest.json')
          .readAsBytesSync(),
      signature: File('${pack.directory.path}/manifest.sig').readAsBytesSync(),
      files:
          files ??
          {
            'content.db': File('${pack.directory.path}/content.db')
                .readAsBytesSync(),
          },
      context: InstallContext(
        currentPackVersion: null,
        appVersion: AppVersion.parse('0.1.0'),
        acceptedChannel: accepted,
        supportedSchemaVersions: {db.ContentDatabase.contentSchemaVersion},
      ),
    );

    test('imzo va yaxlitlik tekshiruvidan o‘tadi', () async {
      expect((await verify()).isValid, isTrue);
    });

    test(
      'production qabul qiladigan ilova development paketni rad etadi',
      () async {
        expect(
          (await verify(accepted: PackChannel.production)).rejection,
          PackRejection.wrongChannel,
        );
      },
    );

    test('buzilgan baza — hashMismatch', () async {
      final bytes = File('${pack.directory.path}/content.db').readAsBytesSync();
      bytes[bytes.length ~/ 2] ^= 0xff;
      expect(
        (await verify(files: {'content.db': bytes})).rejection,
        PackRejection.hashMismatch,
      );
    });

    test(
      'baza: sxema, TEST DATA yo‘q, qidiruv EN/RU/UZ va metabolit',
      () async {
        final d = db.ContentDatabase(
          NativeDatabase(File('${pack.directory.path}/content.db')),
        );
        addTearDown(d.close);
        expect(await d.integrityOk(), isTrue);
        expect(await d.containsTestData(), isFalse);
        expect(await d.metaValue('pack_version'), '2026.10.1');
        expect(await d.metaValue('channel'), 'development');
        final fts = db.FtsSearchIndex(d);
        Future<String?> top(String q) async {
          final r = await fts.search(SearchQuery(q));
          for (final hits in r.byCategory.values) {
            if (hits.isNotEmpty) return hits.first.entityId;
          }
          return null;
        }

        expect(await top('methamphetamine'), 'methamphetamine');
        expect(await top('метамфетамин'), 'methamphetamine');
        expect(await top('metamfetamin'), 'methamphetamine');
        expect(await top('acetaminophen'), 'paracetamol');
        expect(await top('norfentanyl'), 'fentanyl');
        expect(await top('fentanly'), 'fentanyl');
        // FK: barcha citation’lar mavjud manbaga ishora qiladi.
        final orphan = await d
            .customSelect(
              'SELECT COUNT(*) AS n FROM citations c LEFT JOIN sources s '
              'ON s.source_id = c.source_id WHERE s.source_id IS NULL',
            )
            .getSingle();
        expect(orphan.read<int>('n'), 0);
      },
    );
  });
}
