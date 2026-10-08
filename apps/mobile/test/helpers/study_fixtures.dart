import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:forensic_expert/domain/guidelines/guideline_models.dart';
import 'package:forensic_expert/domain/knowledge/knowledge_models.dart';
import 'package:forensic_expert/domain/learn/study_models.dart';
import 'package:forensic_expert/domain/library/library_models.dart';

/// O‘quv rejimi testlari uchun TEST yozuvlar (ilmiy ma’noga ega emas —
/// barcha matnlar «TEST» belgili joy to‘ldiruvchilar).
SourceView testSource(
  String id, {
  SourceLifecycle lifecycle = SourceLifecycle.current,
}) => SourceView(
  sourceId: id,
  title: 'TEST source $id',
  sourceType: 'journal_article',
  evidenceLevel: 'B',
  licenseMode: 'metadata_only',
  identifierVerified: false,
  journal: 'TEST journal',
  year: 2020,
  lifecycle: lifecycle,
);

ClaimView testClaim(
  String id,
  String field,
  Map<String, Object?> value, {
  List<SourceView>? sources,
  ScientificStatus status = ScientificStatus.needsReview,
  ClaimLifecycle lifecycle = ClaimLifecycle.needsReview,
}) => ClaimView(
  claimId: id,
  field: field,
  value: value,
  status: status,
  evidenceLevel: 'B',
  version: 1,
  layer: KnowledgeLayer.internationalScientific,
  sources: sources ?? [testSource('SRC-$id')],
  reviewCount: 0,
  lifecycle: lifecycle,
);

KnowledgeEntry testTopic(
  String id, {
  KnowledgeArea area = KnowledgeArea.forensicMedicine,
  List<ClaimView>? claims,
  EntryAccess access = EntryAccess.free,
  ScientificStatus status = ScientificStatus.needsReview,
}) => KnowledgeEntry(
  id: id,
  kind: KnowledgeKind.topic,
  area: area,
  name: LocalizedText({
    'en': 'TEST topic $id',
    'ru': 'TEST тема $id',
    'uz': 'TEST mavzu $id',
  }),
  status: status,
  access: access,
  isTestData: true,
  claims:
      claims ??
      [
        testClaim('C-$id', 'definition', {'excerpt': 'TEST excerpt for $id.'}),
      ],
  sources: const [],
);

LibraryEntry testSubstance(
  String id, {
  String formula = 'TEST-F',
  String? group = 'test_group',
  EntryAccess access = EntryAccess.free,
  List<SourceView>? sources,
}) {
  final claim = testClaim('C-$id-IDENTITY', 'identity', {
    'molecular_formula': formula,
  }, sources: sources);
  return LibraryEntry(
    id: id,
    section: LibrarySection.substances,
    name: LocalizedText({'en': 'TEST substance $id'}),
    status: ScientificStatus.needsReview,
    isTestData: true,
    access: access,
    group: group,
    details: EntryDetails(
      entityKind: 'substance',
      packVersion: 'test',
      channel: 'development',
      translationStatus: const {},
      claims: [claim],
      legalRules: const [],
    ),
  );
}

class TestLibrary implements LibraryRepository {
  const TestLibrary(this.items);

  final List<LibraryEntry> items;

  @override
  List<LibraryEntry> entries(LibrarySection section) => [
    for (final e in items)
      if (e.section == section) e,
  ];

  @override
  LibraryEntry? byId(String id) {
    for (final e in items) {
      if (e.id == id) return e;
    }
    return null;
  }
}

GuidelineBundle testGuidelines({bool withRefs = true}) =>
    GuidelineBundle.fromJson({
      'schema': 'fe-guidelines/1',
      'cards': [
        for (final id in ['g1', 'g2'])
          {
            'id': 'guideline.test.$id',
            'discipline_codes': ['forensic_chemistry'],
            'status': 'VERIFIED',
            'translation_status': {
              'uz': 'AUTHORED',
              'ru': 'DRAFT',
              'en': 'DRAFT',
            },
            'title': {'uz': 'TEST yo‘riqnoma $id', 'en': 'TEST guideline $id'},
            'summary': {'uz': 'TEST mazmun $id', 'en': 'TEST summary $id'},
            'sections': [
              {
                'key': 'basis',
                'title': {'en': 'TEST'},
                'body': {'en': 'TEST'},
                'citations': withRefs ? ['ref.$id'] : <String>[],
              },
            ],
          },
      ],
      'references': [
        for (final id in ['g1', 'g2'])
          {'key': 'ref.$id', 'title': 'TEST reference $id', 'year': '2020'},
      ],
    });

/// Uchta to‘plamli tayyor katalog (vidjet testlari uchun).
StudyCatalog testStudyCatalog() => StudyCatalogBuilder.build(
  knowledge: ListKnowledgeRepository([
    for (final id in ['A', 'B', 'C', 'D']) testTopic(id),
  ]),
  library: TestLibrary([
    testSubstance('s1', formula: 'TEST-F1'),
    testSubstance('s2', formula: 'TEST-F2'),
    testSubstance('s3', formula: 'TEST-F3'),
  ]),
  guidelines: testGuidelines(),
);
