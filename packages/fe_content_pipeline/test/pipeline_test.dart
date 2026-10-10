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
    bundle = BundleCodec.decode(
      bundleFile.readAsStringSync(),
      imageRoot: bundleFile.parent.path,
    );
  });
  setUp(() => tmp = Directory.systemTemp.createTempSync('fe_pipe'));
  tearDown(() => tmp.deleteSync(recursive: true));

  group('pilot to‘plami — qat’iy qoidalar', () {
    test('PHASE 5: 100+ modda, har biri PubChem identifikatsiyasi bilan', () {
      expect(bundle.substances.length, greaterThanOrEqualTo(100));
      final withIdentity = {
        for (final c in bundle.content.claims)
          if (c.field == 'identity') c.entityId,
      };
      for (final s in bundle.substances) {
        expect(withIdentity, contains(s.substanceId), reason: s.substanceId);
        expect(s.group, isNotNull, reason: s.substanceId);
      }
    });

    test('konsentratsiya — faqat kontekst bilan, chegara emas (FE032)', () {
      final conc = [
        for (final c in bundle.content.claims)
          if (c.field == 'reported_concentration') c,
      ];
      expect(conc, isNotEmpty);
      for (final c in conc) {
        expect(c.value['not_a_threshold'], isTrue, reason: c.claimId);
        expect(c.value['specimen'], isNotEmpty);
        expect(
          '${c.value['excerpt']}'.toLowerCase(),
          isNot(
            matches(RegExp(r'lethal concentration|toxic range|fatal range')),
          ),
          reason: c.claimId,
        );
      }
    });

    test('research: dublikat yo‘q, tezis/dissertatsiya E darajada', () {
      final keys = <String>{};
      for (final r in bundle.content.research) {
        expect(keys.add(r.dedupKey), isTrue, reason: r.id);
        if (!r.kind.isPeerReviewedFullArticle) {
          expect(r.evidenceLevel, EvidenceLevel.e, reason: r.id);
        }
      }
      expect(
        bundle.content.research.where(
          (r) => r.kind == ResearchKind.dissertation,
        ),
        isNotEmpty,
      );
    });

    test('rasmlar: litsenziya, atribusiya, alt-text; graphic yo‘q', () {
      expect(bundle.content.images.length, greaterThan(100));
      for (final im in bundle.content.images) {
        expect(allowedImageLicenses, contains(im.license), reason: im.id);
        expect(im.attribution, isNotEmpty);
        expect(im.alt['en'], isNotEmpty);
        expect(im.graphic, isFalse);
        if (!im.isOriginalDiagram) {
          expect(im.sourceUrl, isNotNull, reason: im.id);
        }
      }
    });

    test('bilim grafigi: har bir bog‘lanishning asosi bor', () {
      expect(bundle.content.links, isNotEmpty);
      final claims = {for (final c in bundle.content.claims) c.claimId};
      for (final l in bundle.content.links) {
        if (l.relation == LinkRelation.analysedBy ||
            l.relation == LinkRelation.metabolismCoMention) {
          expect(claims, contains(l.basis), reason: '${l.fromId}->${l.toId}');
        }
      }
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
        // Ilova egasi to‘plami (DOI/PMID yo‘q, egasi ruxsati bilan) va
        // tahririy izohlar (dalil emas) — identifikatorsiz, lekin aniq.
        if (s.sourceId == 'SRC-OWNER-REAGENTS') {
          expect(s.licenseAgreementId, 'OWNER-PERMISSION-2026-10-09');
          expect(s.accessedDate, isNotNull);
          continue;
        }
        // Milliy amaliyot yo‘riqnomasi (ABY 2025): DOI/ISBN yo‘q, internetda
        // ham yo‘q — markaz foydalanish huquqini sotib olgan hujjat, aniq
        // joyi hujjatning o‘z raqamlash tartibi bilan beriladi.
        if (s.sourceId == 'SRC-ABY-2025') {
          expect(s.licenseAgreementId, 'OWNER-ABY-USE-RIGHT-2026-10-10');
          expect(s.accessedDate, isNotNull);
          continue;
        }
        if (s.sourceId == 'SRC-FE-EDITORIAL') {
          expect(s.sourceClass.canBackClaim, isFalse);
          continue;
        }
        // Usullar qatlami manbalari: DOI/PMID yo‘q — o‘qilgan rasmiy PDF (URL)
        // yoki muallif ruxsati (licenseAgreementId) bilan aniqlanadi.
        if (const {
          'SRC-YULDASHEV-GMT-2024',
          'SRC-YULDASHEV-TOKS-2025',
          'SRC-UNODC-STNAR-13',
          'SRC-SWGDRUG-8-2',
        }.contains(s.sourceId)) {
          expect(s.accessedDate, isNotNull, reason: s.sourceId);
          expect(
            s.licenseAgreementId != null || s.officialUrl != null,
            isTrue,
            reason: s.sourceId,
          );
          continue;
        }
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
        ...k.recipes
            .where((r) => r.originalSourceId == null)
            .map((r) => r.reagentId),
        ...k.screeningTests.map((t) => t.id),
        ...k.methods.map((m) => m.id),
        ...k.emergingIssues.map((e) => e.id),
      ]) {
        expect(cited, contains(id), reason: '$id — manbali claim yo‘q');
      }
      // Egasi to‘plamidagi retseptlar: claim emas, bevosita manba + asl matn.
      for (final r in k.recipes.where((r) => r.originalSourceId != null)) {
        expect(r.sourceIds, contains(r.originalSourceId), reason: r.id);
        expect(r.originalText, isNotEmpty, reason: r.id);
      }
    });

    test('retsept taxmin qilinmagan; skrining ≠ tasdiqlash', () {
      final excerpts = {
        for (final c in bundle.content.claims) '${c.value['excerpt']}',
      };
      for (final r in bundle.content.recipes) {
        if (!r.hasPreparationData) continue;
        // Retsept bo‘lsa: manba majburiy, qadam manbadagi asl jumla,
        // tartib faqat manba aniq aytgan bo‘lsa raqamlanadi.
        expect(r.sourceIds, isNotEmpty, reason: r.id);
        for (final st in r.steps) {
          // Egasi to‘plami qadamlari: tuzilgan (uz/ru/en) matn, asl band
          // `original_text` da saqlanadi; boshqalari — manbadagi asl jumla.
          if (st.texts.isNotEmpty) {
            expect(r.originalText, isNotEmpty, reason: r.id);
            expect(r.translationStatus, 'machine_draft', reason: r.id);
            continue;
          }
          expect(excerpts, contains(st.text), reason: r.id);
          if (!r.orderExplicitInSource) expect(st.order, isNull);
        }
      }
      expect(
        bundle.content.recipes
            .firstWhere((r) => r.id == 'recipe-mecke')
            .hasPreparationData,
        isFalse,
      );
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

    test('iqtibos tarjimalari: faqat machine_draft, asl matn xeshiga mos', () {
      final c = bundle.content;
      final excerpts = {
        for (final x in c.claims)
          if (x.value['excerpt'] case final String e) x.claimId: e,
      };
      final tt = c.textTranslations
          .where((t) => t.target == TextTranslationTarget.claimExcerpt)
          .toList();
      expect(tt, isNotEmpty);
      for (final t in c.textTranslations) {
        expect(t.status, TextTranslation.machineDraft, reason: t.targetId);
        expect(TextTranslation.languages, contains(t.lang));
      }
      for (final t in tt) {
        expect(t.matches(excerpts[t.targetId]!), isTrue, reason: t.targetId);
        expect(t.text, isNot(excerpts[t.targetId]), reason: t.targetId);
      }
      // Har bir iqtibos uchun uz va ru (asl matn o‘zgarmagan).
      for (final id in excerpts.keys) {
        expect(
          {
            for (final t in tt)
              if (t.targetId == id) t.lang,
          },
          {'uz', 'ru'},
          reason: id,
        );
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

    test('baza: text_translations — faqat machine_draft', () async {
      final d = db.ContentDatabase(
        NativeDatabase(File('${pack.directory.path}/content.db')),
      );
      addTearDown(d.close);
      final rows = await d
          .customSelect(
            'SELECT status, COUNT(*) AS n FROM text_translations GROUP BY 1',
          )
          .get();
      expect(
        {for (final r in rows) r.read<String>('status')},
        {'machine_draft'},
      );
      expect(
        rows.single.read<int>('n'),
        bundle.content.textTranslations.length,
      );
      // CHECK: «tekshirilgan» tarjimani bazaga yozib bo‘lmaydi.
      await expectLater(
        d.customStatement(
          'INSERT INTO text_translations VALUES '
          "('claim_excerpt','X','uz','${'0' * 64}','t','reviewed')",
        ),
        throwsA(anything),
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
        expect(await d.metaValue('pack_version'), bundle.packVersion);
        expect(await d.metaValue('bundle_format'), BundleCodec.format);
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
        final counts = await d
            .customSelect(
              'SELECT (SELECT COUNT(*) FROM research_records) AS r, '
              '(SELECT COUNT(*) FROM images) AS i, '
              '(SELECT COUNT(*) FROM entity_links) AS l',
            )
            .getSingle();
        expect(counts.read<int>('r'), bundle.content.research.length);
        expect(counts.read<int>('i'), bundle.content.images.length);
        expect(counts.read<int>('l'), greaterThan(0));
        final payload = await d
            .customSelect(
              'SELECT payload_json FROM knowledge_entities '
              "WHERE entity_id = 'scr-immunoassay-drugs'",
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
          // Barcha kategoriyalar bo‘yicha eng yuqori ball.
          final all = [for (final h in r.byCategory.values) ...h]
            ..sort((a, b) => b.score.compareTo(a.score));
          return all.isEmpty ? null : all.first.entityId;
        }

        expect(await top('methamphetamine'), 'methamphetamine');
        expect(await top('метамфетамин'), 'methamphetamine');
        expect(await top('metamfetamin'), 'methamphetamine');
        expect(await top('acetaminophen'), 'paracetamol');
        expect(await top('norfentanyl'), 'norfentanyl');
        // Xatoli yozuv: modda eng yaxshi 3 natija ichida (skrining yozuvi
        // «Fentanyl immunoassay» ham to‘g‘ri, yaqin natija).
        final typo = await fts.search(const SearchQuery('fentanly'));
        final ranked = [for (final h in typo.byCategory.values) ...h]
          ..sort((a, b) => b.score.compareTo(a.score));
        expect(ranked.take(3).map((h) => h.entityId), contains('fentanyl'));
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
