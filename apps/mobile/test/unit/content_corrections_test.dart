import 'package:fe_content_schema/fe_content_schema.dart' show KnowledgeArea;
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/domain/library/library_models.dart';

import '../helpers/pilot_content.dart';

/// Ilmiy audit (2026-11-01): fanlar aralashmasin.
void main() {
  late PilotContent c;
  setUpAll(() async => c = await loadPilotContent());

  test('kokain barqarorligi — Toksikologiyada, Biokimyoda emas', () {
    final e = c.knowledge.byId('bio-cocaine-stability')!;
    expect(e.area, KnowledgeArea.toxicology);
    expect(
      c.knowledge.topicsIn(KnowledgeArea.biochemistry).map((x) => x.id),
      isNot(contains('bio-cocaine-stability')),
    );
  });

  test('mavzuga tegishli bo‘lmagan iqtiboslar ko‘rsatilmaydi', () {
    final ids = {
      for (final id in [
        'fm-death-investigation',
        'method-validation',
        'method-lcmsms',
      ])
        ...c.knowledge.byId(id)!.claims.map((x) => x.claimId),
    };
    expect(ids, isNot(contains('C-FM-DEATH-INVESTIGATION-DEFINITION-P5')));
    expect(ids, isNot(contains('C-METHOD-VALIDATION-LIMITATION-P5')));
    expect(ids, isNot(contains('C-METHOD-LCMSMS-PRINCIPLE-P5')));
    // Qolgan to‘g‘ri iqtiboslar saqlanadi.
    expect(ids, contains('C-METHOD-VALIDATION-PRINCIPLE-P5'));
  });

  test('GHB — sedativ-gipnotiklar guruhida', () {
    final ghb = c.library
        .entries(LibrarySection.substances)
        .firstWhere((e) => e.id == 'ghb');
    expect(ghb.group, 'sedatives_hypnotics');
  });
}
