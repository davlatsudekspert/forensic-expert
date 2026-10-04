import 'dart:convert';
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
      final k = bundle.content;
      for (final s in [
        ...k.recipes.map((e) => e.status),
        ...k.screeningTests.map((e) => e.status),
        ...k.methods.map((e) => e.status),
        ...k.emergingIssues.map((e) => e.status),
      ]) {
        expect(s, ScientificStatus.needsReview);
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
      final sources = {for (final s in bundle.content.sources) s.sourceId: s};
      for (final i in bundle.content.instruments) {
        expect(i.officialSourceId, isNotEmpty);
        expect(
          sources[i.officialSourceId]!.sourceClass,
          SourceClass.primaryOfficial,
          reason: i.id,
        );
      }
    });

    test('PHASE 4 domenlari: har biri kamida bitta real manbali yozuv', () {
      final k = bundle.content;
      final areas = {for (final t in k.topics) t.area};
      expect(
        areas,
        containsAll([
          KnowledgeArea.forensicMedicine,
          KnowledgeArea.biochemistry,
        ]),
      );
      expect(k.recipes, isNotEmpty);
      expect(k.screeningTests, isNotEmpty);
      expect(k.methods, isNotEmpty);
      expect(k.emergingIssues, isNotEmpty);
      expect(k.jurisdictions.map((j) => j.id), contains('GB'));
      final cited = {for (final c in k.claims) c.entityId};
      for (final id in [
        ...k.topics.map((t) => t.id),
        ...k.recipes.map((r) => r.reagentId),
        ...k.screeningTests.map((t) => t.id),
        ...k.methods.map((m) => m.id),
        ...k.emergingIssues.map((e) => e.id),
      ]) {
        expect(cited, contains(id), reason: '$id — manbali claim yo‘q');
      }
    });

    test('retsept taxmin qilinmagan; skrining ≠ tasdiqlash', () {
      for (final r in bundle.content.recipes) {
        // Ochiq manbada tasdiqlangan retsept topilmagan.
        expect(r.hasPreparationData, isFalse, reason: r.id);
        expect(r.ingredients, isEmpty);
      }
      for (final t in bundle.content.screeningTests) {
        expect(t.confirmatoryMethodIds, isNotEmpty);
        expect(t.supportsDefinitiveIdentification, isFalse);
        expect(t.cutoff, isNull, reason: 'manbasiz cutoff yo‘q');
      }
    });

    test('UK: hudud bo‘yicha qoida, Shimoliy Irlandiya — ma’lumot yo‘q', () {
      final k = bundle.content;
      final cells =
          JurisdictionResolver(
            jurisdictions: k.jurisdictions,
            instruments: k.instruments,
            rules: k.jurisdictionalRules,
          ).compareCells(
            jurisdictionIds: const ['GB-ENG', 'GB-WLS', 'GB-SCT', 'GB-NIR'],
            subjectType: 'substance',
            subjectId: 'ethanol',
            at: DateTime.utc(2026, 10, 4),
            includeUnreviewed: true,
          );
      Map<String, Object?>? blood(int i) =>
          ((cells[i].rules.single.$1.value['limits']! as Map)['blood'] as Map)
              .cast();
      expect(blood(0)!['value'], 80);
      expect(blood(1)!['value'], 80);
      expect(blood(2)!['value'], 50); // SSI 2014/328 (aniqroq hudud)
      expect(cells[3].hasData, isFalse); // xulosa chiqarilmaydi
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

    test('FE027: ko‘rib chiqilgan ma’lumot jimgina pasaytirilmaydi', () async {
      final c = bundle.content.claims.first;
      final reviewedPrev = ContentBundle(
        channel: BundleChannel.development,
        claims: [
          Claim(
            claimId: c.claimId,
            entityType: c.entityType,
            entityId: c.entityId,
            field: c.field,
            value: c.value,
            domain: c.domain,
            declaredStatus: ScientificStatus.reviewed,
            evidenceLevel: c.evidenceLevel,
          ),
        ],
      );
      await expectLater(
        const PackBuilder().build(
          bundle: bundle,
          outDir: Directory('${tmp.path}/reg'),
          builtAt: DateTime.utc(2026, 10, 4),
          previous: reviewedPrev,
        ),
        throwsA(
          isA<PipelineValidationError>().having(
            (e) => e.report.hasCode(RuleCodes.silentReviewRegression),
            'FE027',
            isTrue,
          ),
        ),
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
        expect(await d.metaValue('pack_version'), '2026.10.2');
        expect(await d.metaValue('bundle_format'), 'fe-bundle/2');
        expect(await d.metaValue('component_version.jurisdiction'), isNotNull);
        final k = await d
            .customSelect(
              'SELECT entity_type, COUNT(*) AS n FROM knowledge_entities '
              "WHERE review_status = 'NEEDS_REVIEW' GROUP BY 1",
            )
            .get();
        expect(
          {for (final r in k) r.read<String>('entity_type')},
          containsAll([
            'topic',
            'reagent',
            'screening_test',
            'method',
            'emerging_issue',
          ]),
        );
        final payload = await d
            .customSelect(
              'SELECT payload_json FROM knowledge_entities '
              "WHERE entity_type = 'screening_test'",
            )
            .getSingle();
        expect(
          KnowledgeJson.screeningFrom(
            jsonDecode(payload.read<String>('payload_json')),
          ).confirmatoryMethodIds,
          isNotEmpty,
        );
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
        expect(await top('livor mortis'), 'fm-livor-mortis');
        expect(await top('Marquis'), 'reagent-marquis');
        expect(await top('нитазен'), 'emg-nitazenes');
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
