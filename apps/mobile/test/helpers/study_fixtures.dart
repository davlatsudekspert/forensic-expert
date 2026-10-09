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

/// TEST yo‘riqnoma kartalari ([cards] ta, sud-kimyo yo‘nalishi).
///
/// [quiz] — birinchi kartaga 5 ta muallif savoli (3 distraktor, uch tilli
/// izoh, aniq `cite`) qo‘shiladi; [authored] — barcha tillar `AUTHORED`
/// (aks holda ru/en `DRAFT`).
GuidelineBundle testGuidelines({
  bool withRefs = true,
  int cards = 4,
  bool quiz = false,
  bool authored = false,
}) => GuidelineBundle.fromJson({
  'schema': 'fe-guidelines/1',
  'cards': [
    for (var n = 1; n <= cards; n++)
      {
        'id': 'guideline.test.g$n',
        'discipline_codes': ['forensic_chemistry'],
        'status': 'VERIFIED',
        'translation_status': {
          'uz': 'AUTHORED',
          'ru': authored ? 'AUTHORED' : 'DRAFT',
          'en': authored ? 'AUTHORED' : 'DRAFT',
        },
        'title': {
          'uz': 'TEST yo‘riqnoma g$n',
          'ru': 'TEST руководство g$n',
          'en': 'TEST guideline g$n',
        },
        'summary': {
          'uz': 'TEST mazmun g$n',
          'ru': 'TEST содержание g$n',
          'en': 'TEST summary g$n',
        },
        'sections': [
          {
            'key': 'basis',
            'title': {
              'uz': 'TEST bo‘lim',
              'ru': 'TEST раздел',
              'en': 'TEST section',
            },
            'body': {'en': 'TEST body with GC-MS'},
            'citations': withRefs ? ['ref.g$n'] : <String>[],
          },
        ],
        if (quiz && n == 1)
          'quiz': [
            for (var q = 1; q <= 5; q++)
              {
                'id': 'tq$q',
                'q': {
                  'uz': 'TEST savol $q?',
                  'ru': 'TEST вопрос $q?',
                  'en': 'TEST question $q?',
                },
                'a': {
                  'uz': 'TEST javob $q',
                  'ru': 'TEST ответ $q',
                  'en': 'TEST answer $q',
                },
                'd': {
                  for (final (lang, w) in const [
                    ('uz', 'xato'),
                    ('ru', 'ошибка'),
                    ('en', 'wrong'),
                  ])
                    lang: [for (var d = 1; d <= 3; d++) 'TEST $w $q.$d'],
                },
                'e': {
                  'uz': 'TEST izoh $q: GC-MS bilan tasdiqlanadi',
                  'ru': 'TEST пояснение $q: подтверждается GC-MS',
                  'en': 'TEST explanation $q: confirmed by GC-MS',
                },
                'cite': ['ref.g1'],
              },
          ],
      },
  ],
  'references': [
    for (var n = 1; n <= cards; n++)
      {'key': 'ref.g$n', 'title': 'TEST reference g$n', 'year': '2020'},
  ],
});

/// To‘rtta to‘plamli tayyor katalog (vidjet testlari uchun): mavzular,
/// moddalar va yo‘riqnomalar — har birida 4 ta element (bir soha).
StudyCatalog testStudyCatalog({bool quiz = false, bool authored = false}) =>
    StudyCatalogBuilder.build(
      knowledge: ListKnowledgeRepository([
        for (final id in ['A', 'B', 'C', 'D']) testTopic(id),
      ]),
      library: TestLibrary([
        testSubstance('s1', formula: 'C1H4-TEST'),
        testSubstance('s2', formula: 'C2H6-TEST'),
        testSubstance('s3', formula: 'C3H8-TEST'),
        testSubstance('s4', formula: 'C4H10-TEST'),
      ]),
      guidelines: testGuidelines(quiz: quiz, authored: authored),
    );
