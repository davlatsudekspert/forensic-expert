import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:test/test.dart';

void main() {
  test('kamida 20 ta forensic fan, kodlar noyob va barqaror', () {
    expect(ForensicDiscipline.values.length, greaterThanOrEqualTo(20));
    final codes = {for (final d in ForensicDiscipline.values) d.code};
    expect(codes.length, ForensicDiscipline.values.length);
    for (final d in ForensicDiscipline.values) {
      expect(ForensicDiscipline.fromCode(d.code), d);
    }
    // Har bir guruhda kamida bitta fan.
    for (final g in DisciplineGroup.values) {
      expect(ForensicDiscipline.values.where((d) => d.group == g), isNotEmpty);
    }
    expect(ForensicDiscipline.forensicPsychiatry.referenceOnly, isTrue);
  });

  test('har bir bilim sohasi va FM mavzusi fanga xaritalangan', () {
    for (final a in KnowledgeArea.values) {
      expect(disciplineOfArea(a), isA<ForensicDiscipline>());
    }
    for (final t in ForensicMedicineTopic.values) {
      expect(disciplineOfFmTopic(t), isA<ForensicDiscipline>());
    }
    expect(
      disciplineOfFmTopic(ForensicMedicineTopic.odontology),
      ForensicDiscipline.forensicOdontology,
    );
  });

  test('hujjat turlari: faqat qonun/regulation qonuniy majburiy', () {
    for (final k in DocumentKind.values) {
      final binding = k.binding == BindingNature.legallyBinding;
      expect(
        binding,
        k == DocumentKind.law || k == DocumentKind.regulation,
        reason: '$k',
      );
    }
    expect(
      documentKindOfInstrument(InstrumentType.officialGuideline),
      DocumentKind.guideline,
    );
    expect(documentKindOfMethod(MethodKind.institutionalSop), DocumentKind.sop);
    expect(
      documentKindOfResearch(ResearchKind.caseReport),
      DocumentKind.scientificArticle,
    );
  });

  test('yangi research turlari: dalil chegarasi va peer-review', () {
    expect(ResearchKind.guideline.maxEvidence, EvidenceLevel.a);
    expect(ResearchKind.validationStudy.maxEvidence, EvidenceLevel.b);
    expect(ResearchKind.caseSeries.maxEvidence, EvidenceLevel.d);
    expect(ResearchKind.guideline.isPeerReviewedFullArticle, isFalse);
    expect(
      ResearchKind.fromCode('validation_study'),
      ResearchKind.validationStudy,
    );
  });

  test(
    'forensik dolzarblik dalil sifatidan alohida, standart — baholanmagan',
    () {
      final r = EvidenceJson.researchFrom({
        'research_id': 'RS-x',
        'kind': 'journal_article',
        'title': 'T',
        'doi': '10.1/x',
        'evidence_level': 'B',
        'review_status': 'NEEDS_REVIEW',
      });
      expect(r.forensicRelevance, ForensicRelevance.unassessed);
      expect(ForensicRelevance.fromCode('direct'), ForensicRelevance.direct);
    },
  );

  test('kontent shablonlari: bo‘lim kodlari noyob, har turda research bor', () {
    for (final k in TemplateKind.values) {
      final s = ContentTemplates.of(k);
      expect({for (final x in s) x.code}.length, s.length, reason: '$k');
      expect(
        s.any((x) => x.relations.contains(LinkRelation.research)),
        isTrue,
        reason: '$k',
      );
    }
    // Reported concentration o‘z bo‘limida (banner bilan) — boshqa
    // bo‘limga tushmaydi.
    final conc = ContentTemplates.substance.where(
      (x) => x.claimFields.contains('reported_concentration'),
    );
    expect(conc.single.code, 'reported_concentrations');
  });

  test('emerging issue: last_checked aylanma JSON', () {
    final e = KnowledgeJson.emergingFrom({
      'issue_id': 'e1',
      'category': 'syntheticOpioids',
      'titles': {'en': 'x'},
      'source_ids': ['S'],
      'evidence_type': 'peerReviewed',
      'status': 'NEEDS_REVIEW',
      'last_checked': '2026-10-04',
    });
    expect(e.lastCheckedAt, DateTime(2026, 10, 4));
    expect(KnowledgeJson.emerging(e)['last_checked'], '2026-10-04');
  });
}
