import 'dart:convert';
import 'dart:io';

import 'package:fe_content_schema/fe_content_schema.dart'
    show ForensicDiscipline;
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/search_service.dart';
import 'package:forensic_expert/data/fixtures/test_fixtures.dart';
import 'package:forensic_expert/domain/ai/retrieval_scoring.dart';
import 'package:forensic_expert/domain/guidelines/guideline_models.dart';

import '../helpers/pilot_content.dart';

/// Global Search: ko‘p tilli sinonimlar, ko‘p so‘zli so‘rov va fan filtri
/// (HAQIQIY pilot paket + yo‘riqnomalar).
void main() {
  late AppSearchService service;

  setUpAll(() async {
    final pilot = await loadPilotContent();
    final guidelines = GuidelineBundle.fromJson(
      (jsonDecode(
        File('assets/content/guidelines/guidelines_v1.json').readAsStringSync(),
      ) as Map).cast<String, Object?>(),
    );
    service = AppSearchService.build(
      library: pilot.library,
      learn: const EmptyLearnRepository(),
      knowledge: pilot.knowledge,
      instruments: pilot.legal.instruments,
      research: pilot.evidence.research,
      provenance: pilot.provenance,
      guidelines: guidelines,
      links: pilot.evidence.links,
    );
  });

  List<String> ids(AppSearchResult r, SearchGroup g) => [
    for (final h in r.groups[g]!) h.entityId,
  ];

  group('sinonimlar (UZ/RU/EN)', () {
    for (final q in ['alkogol', 'spirt', 'алкоголь', 'спирт', 'alcohol']) {
      test('«$q» → etanol moddasi, GX metodi va yo‘riqnoma', () async {
        final r = await service.search(q);
        expect(ids(r, SearchGroup.substances), contains('ethanol'));
        expect(ids(r, SearchGroup.methods), contains('method-headspace-gc'));
        expect(
          ids(r, SearchGroup.guidelines),
          contains('guideline.chem.ethanol_gc'),
        );
      });
    }

    test('bog‘langan metod qayerdan kelgani ko‘rsatiladi', () async {
      final r = await service.search('alkogol');
      expect(r.linkedVia['method-headspace-gc'], 'ethanol');
    });

    test('«metanol» / «метанол» → methanol', () async {
      for (final q in ['metanol', 'метанол', 'methyl alcohol']) {
        expect(
          ids(await service.search(q), SearchGroup.substances),
          contains('methanol'),
          reason: q,
        );
      }
    });

    test('YuQX / ТСХ / TLC → yupqa qatlamli xromatografiya', () async {
      for (final q in ['YuQX', 'ТСХ', 'TLC']) {
        expect(
          ids(await service.search(q), SearchGroup.guidelines),
          contains('guideline.chem.tlc_screening'),
          reason: q,
        );
      }
    });

    test('qon / кровь / blood — bir xil namuna', () async {
      final blood = ids(await service.search('blood'), SearchGroup.methods);
      expect(blood, isNotEmpty);
      for (final q in ['qon', 'кровь']) {
        expect(
          ids(await service.search(q), SearchGroup.methods),
          contains(blood.first),
          reason: q,
        );
      }
    });
  });

  group('ko‘p so‘zli so‘rov', () {
    test('«etanol qon» bo‘sh emas, ikkala so‘zga mos yozuv birinchi', () async {
      final r = await service.search('etanol qon');
      expect(r.isEmpty, isFalse);
      final all = [for (final g in r.groups.values) ...g]
        ..sort((a, b) => b.score.compareTo(a.score));
      expect(all.first.entityId, 'guideline.chem.ethanol_gc');
      expect(ids(r, SearchGroup.substances), contains('ethanol'));
    });

    test('«methanol GC» → methanol va GC natijalari', () async {
      final r = await service.search('methanol GC');
      expect(ids(r, SearchGroup.substances), contains('methanol'));
      expect(r.groups[SearchGroup.methods], isNotEmpty);
    });
  });

  group('fan filtri', () {
    test('faqat natijasi bor fanlar ro‘yxatda', () async {
      final r = await service.search('etanol');
      expect(r.disciplines, contains(ForensicDiscipline.forensicToxicology));
      expect(
        r.disciplines,
        isNot(contains(ForensicDiscipline.forensicOdontology)),
      );
      expect(r.discipline, isNull);
    });

    test('filtr natijalarni cheklaydi', () async {
      final all = await service.search('etanol');
      final tox = await service.search(
        'etanol',
        discipline: ForensicDiscipline.forensicToxicology,
      );
      expect(tox.discipline, ForensicDiscipline.forensicToxicology);
      expect(tox.disciplines, all.disciplines);
      for (final g in tox.groups.values) {
        for (final h in g) {
          expect(
            service.disciplinesOf(h.entityId),
            contains(ForensicDiscipline.forensicToxicology),
            reason: h.entityId,
          );
        }
      }
      expect(ids(tox, SearchGroup.substances), contains('ethanol'));
    });

    test('natijasi yo‘q fan — filtr qo‘llanmaydi', () async {
      final r = await service.search(
        'etanol',
        discipline: ForensicDiscipline.digitalForensics,
      );
      expect(r.discipline, isNull);
      expect(r.isEmpty, isFalse);
    });
  });

  test('fixture bilan ham ishlaydi (havolasiz)', () async {
    final s = AppSearchService.build(
      library: const FixtureLibraryRepository(),
      learn: const FixtureLearnRepository(),
    );
    final r = await s.search('alkogol');
    expect(ids(r, SearchGroup.substances), contains('TEST-SUB-ETOH'));
    expect(r.disciplines, contains(ForensicDiscipline.forensicToxicology));
  });

  test('AI retrieval ham shu sinonimlardan foydalanadi', () {
    expect(
      RetrievalText.queryTokens('metanol'),
      containsAll(['metanol', 'methanol']),
    );
    expect(RetrievalText.queryTokens('jigar'), contains('liver'));
    // Kirill / ko‘p so‘zli shakllar hujjat tokenlariga qo‘shilmaydi.
    expect(RetrievalText.queryTokens('alkogol'), isNot(contains('этанол')));
    expect(
      RetrievalText.queryTokens('alkogol'),
      isNot(contains('ethyl alcohol')),
    );
  });
}
