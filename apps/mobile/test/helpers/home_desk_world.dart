import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/professional.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/study.dart';
import 'package:forensic_expert/core/settings/app_settings.dart';
import 'package:forensic_expert/data/fixtures/test_fixtures.dart'
    show EmptyLibraryRepository, FixtureLearnRepository;
import 'package:forensic_expert/domain/knowledge/knowledge_models.dart';
import 'package:forensic_expert/domain/learn/study_models.dart';
import 'package:forensic_expert/domain/library/library_models.dart';
import 'package:forensic_expert/domain/professional/professional_models.dart';
import 'package:forensic_expert/features/home/daily_fact.dart';

import 'pump_app.dart';
import 'study_fixtures.dart' show TestLibrary;

/// Mutaxassislik profili (qurilmadagi), faqat Home sinovlari uchun.
LocalUserProfile profileOf(Specialty s) => LocalUserProfile(
  professional: ProfessionalProfile(
    fullName: 'Sample Name',
    country: 'UZ',
    organization: 'Forensic laboratory',
    position: 'Expert',
    primarySpecialty: s,
    education: 'MSc',
  ),
);

SourceView deskSource(String id, {SourceLifecycle? lifecycle}) => SourceView(
  sourceId: id,
  title: 'Source book $id',
  sourceType: 'book',
  evidenceLevel: 'B',
  licenseMode: 'metadata_only',
  identifierVerified: true,
  journal: 'Series X',
  year: 2024,
  locator: 'p. 32',
  lifecycle: lifecycle ?? SourceLifecycle.current,
);

/// Manbali, `statement` va `locator_i18n` li da’vo.
ClaimView deskClaim(
  String id, {
  String text = 'Statement text',
  Map<String, String>? locator,
  List<SourceView>? sources,
  Map<String, String>? statement,
}) => ClaimView(
  claimId: id,
  field: 'colour_test',
  value: {
    'statement': statement ?? {'uz': '$text ($id)'},
    'locator_i18n': ?locator,
  },
  status: ScientificStatus.needsReview,
  evidenceLevel: 'B',
  version: 1,
  layer: KnowledgeLayer.internationalScientific,
  sources: sources ?? [deskSource('S-$id')],
  reviewCount: 0,
  lifecycle: ClaimLifecycle.current,
);

LibraryEntry deskSubstance(
  String id,
  List<ClaimView> claims, {
  bool testData = false,
}) => LibraryEntry(
  id: id,
  section: LibrarySection.substances,
  name: LocalizedText({
    'uz': 'Modda $id',
    'ru': 'Вещество $id',
    'en': 'Sub $id',
  }),
  status: ScientificStatus.needsReview,
  isTestData: testData,
  details: EntryDetails(
    entityKind: 'substance',
    packVersion: 'test',
    channel: 'development',
    translationStatus: const {},
    claims: claims,
    legalRules: const [],
  ),
);

KnowledgeEntry deskTopic(
  String id,
  List<ClaimView> claims, {
  KnowledgeArea area = KnowledgeArea.forensicMedicine,
  bool testData = false,
}) => KnowledgeEntry(
  id: id,
  kind: KnowledgeKind.topic,
  area: area,
  name: LocalizedText({'uz': 'Mavzu $id', 'ru': 'Тема $id', 'en': 'Topic $id'}),
  status: ScientificStatus.needsReview,
  isTestData: testData,
  claims: claims,
  sources: const [],
);

/// Bugungi savol uchun yaroqli element (3 distraktor, sahifa bilan).
StudyItem deskQuestionItem(int n, {String? pages = '45-46'}) {
  LocalizedText t(String s) =>
      LocalizedText({'uz': '$s uz', 'ru': '$s ru', 'en': '$s en'});
  return StudyItem(
    id: 'gq.test.q$n',
    kind: StudyItemKind.guidelineQuestion,
    deckId: 'teaching.test',
    domain: 'gq:test',
    prompt: t('Savol $n'),
    answer: t('Javob $n'),
    status: ScientificStatus.needsReview,
    isTestData: false,
    citations: [
      StudyCitation(
        title: 'Toksikologik kimyo (kitob)',
        detail: 'Yuldashev · 2025',
        pages: pages,
      ),
    ],
    origin: StudyOrigin.guideline,
    originId: 'guideline.test',
    distractors: [t('Xato A$n'), t('Xato B$n'), t('Xato C$n')],
    explanation: t('Izoh $n'),
  );
}

StudyCatalog deskCatalog(List<StudyItem> items) => StudyCatalog([
  StudyDeck(
    id: 'teaching.test',
    kind: StudyDeckKind.teachingMaterial,
    key: 'test',
    items: items,
  ),
]);

final deskLibrary = TestLibrary([
  deskSubstance('alpha', [
    deskClaim(
      'C-a1',
      locator: {'uz': 'Yuldashev Z.A., «Toksikologik kimyo» (2025), 32-bet'},
    ),
  ]),
  deskSubstance('beta', [deskClaim('C-b1')]),
]);

final deskKnowledge = ListKnowledgeRepository([
  deskTopic('fm-1', [deskClaim('C-f1')]),
]);

/// Home’ni berilgan rol/mutaxassislik bilan ishga tushiradi.
Future<ProviderContainer> pumpHome(
  WidgetTester tester, {
  UserMode mode = UserMode.professional,
  String lang = 'uz',
  Specialty? specialty,
  Size size = const Size(390, 844),
  double textScale = 1,
  ThemeMode theme = ThemeMode.light,
  DateTime? now,
  LibraryRepository? library,
  KnowledgeRepository? knowledge,
  StudyCatalog? catalog,
  List<Override> extra = const [],
}) {
  // Fixture’lar faqat o‘z repozitoriyimiz berilmaganda; berilsa — ikkalasi
  // ham aniq (bo‘sh yoki berilgan) o‘rnatiladi (bir provayder ikki marta
  // override qilinmaydi).
  final custom = library != null || knowledge != null;
  return pumpApp(
    tester,
    settings: completedSettings(lang: lang, mode: mode, theme: theme),
    size: size,
    textScale: textScale,
    testFixtures: !custom,
    overrides: [
      if (specialty != null)
        initialProfileProvider.overrideWithValue(profileOf(specialty)),
      workbenchClockProvider.overrideWithValue(
        () => now ?? DateTime(2026, 10, 31, 9),
      ),
      if (custom) ...[
        libraryRepositoryProvider.overrideWithValue(
          library ?? const EmptyLibraryRepository(),
        ),
        knowledgeRepositoryProvider.overrideWithValue(
          knowledge ?? const EmptyKnowledgeRepository(),
        ),
        learnRepositoryProvider.overrideWithValue(
          const FixtureLearnRepository(),
        ),
      ],
      if (catalog != null) studyCatalogProvider.overrideWithValue(catalog),
      ...extra,
    ],
  );
}
