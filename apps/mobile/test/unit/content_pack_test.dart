import 'dart:io';

import 'package:fe_content_package/fe_content_package.dart';
import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/data/content/bundled_pack.dart';
import 'package:forensic_expert/data/content/content_library_repository.dart';
import 'package:forensic_expert/domain/library/library_models.dart';
import 'package:forensic_expert/domain/ports/billing_ports.dart';

import '../helpers/pilot_content.dart';

/// Ilovaga kiritilgan haqiqiy pilot paket.
void main() {
  late Directory root;
  setUp(() => root = Directory.systemTemp.createTempSync('fe_pack'));
  tearDown(() => root.deleteSync(recursive: true));

  BundledPackInstaller installer({
    String channel = 'development',
    Map<String, String>? keys,
  }) => BundledPackInstaller(
    root: root,
    assets: DiskAssetBundle(),
    acceptedChannel: channel,
    trustedKeys: keys,
  );

  test('imzo tekshiruvidan o‘tib o‘rnatiladi; qayta o‘rnatilmaydi', () async {
    final r = await installer().ensureInstalled();
    expect(r!.outcome, InstallOutcome.installed);
    expect(File('${root.path}/active/content.db').existsSync(), isTrue);
    expect(await installer().ensureInstalled(), isNull);
  });

  test('production yig‘ma development paketni rad etadi', () async {
    final r = await installer(channel: 'production').ensureInstalled();
    expect(r!.outcome, InstallOutcome.rejectedByVerifier);
    expect(r.rejection, PackRejection.wrongChannel);
    expect(Directory('${root.path}/active').existsSync(), isFalse);
  });

  test('noma’lum kalit — rad etiladi', () async {
    final r = await installer(keys: {'development-000000000000': 'AAAA'})
        .ensureInstalled();
    expect(r!.rejection, PackRejection.unknownKey);
  });

  group('kutubxona (content.db)', () {
    late ContentLibraryRepository repo;
    setUpAll(() async => repo = await loadPilotLibrary());

    test('137 ta modda, TEST DATA yo‘q, hech biri VERIFIED emas', () {
      final all = repo.entries(LibrarySection.substances);
      expect(all, hasLength(137));
      for (final e in all) {
        expect(e.isTestData, isFalse);
        expect(e.status, ScientificStatus.needsReview, reason: e.id);
        expect(e.details!.channel, 'development');
        for (final c in e.details!.claims) {
          expect(c.reviewCount, 0);
          expect(c.sources, isNotEmpty, reason: c.claimId);
          expect(c.layer, KnowledgeLayer.internationalScientific);
        }
      }
    });

    test('bepul demo — aynan AccessPolicy chegarasida', () {
      final free = repo
          .entries(LibrarySection.substances)
          .where((e) => e.access == EntryAccess.free);
      expect(free.length, AccessPolicy.freeEntriesPerSection);
    });

    test('provenance: identifikatsiya, iqtibos, litsenziya', () {
      final methanol = repo.byId('methanol')!.details!;
      expect(methanol.claim('identity')!.value['pubchem_cid'], 887);
      expect(methanol.claim('metabolites')!.excerpt, contains('formic acid'));
      // Author manuscript — iqtibos matni ilovaga kiritilmagan.
      final fentanyl = repo.byId('fentanyl')!.details!;
      expect(fentanyl.claim('metabolites')!.items, contains('norfentanyl'));
      expect(fentanyl.claim('metabolites')!.excerpt, isNull);
      expect(repo.byId('paracetamol')!.synonyms, contains('acetaminophen'));
    });

    test('yurisdiksiya qatlami alohida: INT qoidalari INCB manbasi bilan', () {
      // PHASE 7: GB/US/DE qoidalari ham bor — INT qatlami alohida tekshiriladi.
      List<LegalRuleView> intRules(String id) => [
        for (final r in repo.byId(id)!.details!.legalRules)
          if (r.jurisdictionId == 'INT') r,
      ];
      final rule = intRules('morphine').single;
      expect(rule.jurisdictionId, 'INT');
      expect(rule.schedules, ['I']);
      expect(rule.status, ScientificStatus.needsReview);
      expect(rule.source.title, contains('Yellow List'));
      final heroin = intRules('heroin').single;
      expect(heroin.schedules, ['I', 'IV']);
      final thc = intRules('thc').single;
      expect(thc.datePrecision, 'year');
      // Ro‘yxatlarda yo‘q moddalar uchun qoida YARATILMAGAN.
      expect(intRules('tramadol'), isEmpty);
      expect(intRules('pregabalin'), isEmpty);
    });
  });
}
