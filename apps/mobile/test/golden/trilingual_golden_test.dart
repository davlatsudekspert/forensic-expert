import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/core/design/theme.dart';
import 'package:forensic_expert/core/design/tokens.dart';
import 'package:forensic_expert/core/l10n/generated/app_localizations.dart';
import 'package:forensic_expert/core/widgets/fe_components.dart';
import 'package:forensic_expert/domain/evidence/evidence_models.dart';
import 'package:forensic_expert/domain/learn/study_models.dart';
import 'package:forensic_expert/domain/library/library_models.dart';
import 'package:forensic_expert/features/evidence/presentation/localized_content.dart';
import 'package:forensic_expert/features/evidence/presentation/research_screens.dart';
import 'package:forensic_expert/features/learn/presentation/study_screens.dart';
import 'package:forensic_expert/features/legal/presentation/instrument_title.dart';

/// Phase C vizual nazorati: uch tilli qatlamli kartalar (tarjima birinchi,
/// holat, «Asl matn», halol «tarjima yo‘q») — 390 va 320 dp, yorug‘/qorong‘i.
/// Nusxa: `docs/qa/l10n_c_20261009/goldens/`.
void main() {
  const quote =
      'For example, basic lipophilic drugs with a volume of distribution '
      'above 3 L/kg are prone to PMR.';
  const claimId = 'C-TOX-POSTMORTEM-REDISTRIBUTION-PRINCIPLE-P8';
  const title =
      'Postmortem redistribution of drugs: a systematic review of '
      'mechanisms, site-dependent concentration differences and '
      'interpretive pitfalls in forensic toxicology casework';
  const translated = {
    'uz': (
      quote:
          'Masalan, taqsimlanish hajmi 3 L/kg dan yuqori bo‘lgan asosli '
          'lipofil dori vositalari PMR ga uchrashi ehtimoli yuqori.',
      title:
          'Dori vositalarining o‘limdan keyingi qayta taqsimlanishi (PMR): '
          'mexanizmlar, namuna joyiga bog‘liq konsentratsiya farqlari va '
          'sud-toksikologik talqindagi xatolar — tizimli sharh',
    ),
    'ru': (
      quote:
          'Например, основные липофильные препараты с объёмом распределения '
          'более 3 L/kg склонны к PMR.',
      title:
          'Посмертное перераспределение лекарственных средств (PMR): '
          'систематический обзор механизмов, различий концентраций и ошибок '
          'интерпретации',
    ),
  };

  ContentTranslationRow row(
    String kind,
    String id,
    String src,
    String lang,
    String text,
  ) => ContentTranslationRow.tryParse(
    kind: kind,
    id: id,
    lang: lang,
    sourceSha256: TextTranslation.hashOf(src),
    text: text,
    status: 'machine_draft',
  )!;

  final translations = ContentTranslations.of([
    for (final MapEntry(key: lang, value: v) in translated.entries) ...[
      row(ContentTextKind.claimExcerpt, claimId, quote, lang, v.quote),
      row(ContentTextKind.researchTitle, 'R-1', title, lang, v.title),
    ],
  ]);

  const item = StudyItem(
    id: 'topic.tox-pmr',
    kind: StudyItemKind.topicExcerpt,
    deckId: 'discipline.forensicToxicology',
    prompt: LocalizedText({'en': 'PMR'}),
    answer: LocalizedText({'en': quote}),
    answerIsQuote: true,
    claimId: claimId,
    status: ScientificStatus.needsReview,
    isTestData: false,
    citations: [],
    origin: StudyOrigin.knowledgeEntry,
    originId: 'tox-pmr',
  );
  const research = [
    ResearchEntry(
      id: 'R-1',
      kind: ResearchKind.systematicReview,
      title: title,
      evidenceLevel: 'A',
      peerReviewed: true,
      status: ScientificStatus.needsReview,
      authors: ['Pélissier-Alicot AL', 'Gaulier JM'],
      container: 'Journal of Analytical Toxicology',
      year: '2003',
    ),
    ResearchEntry(
      id: 'R-2',
      kind: ResearchKind.journalArticle,
      title:
          'Vitreous humor potassium as a marker of the postmortem interval: '
          'a critical appraisal',
      evidenceLevel: 'B',
      peerReviewed: true,
      status: ScientificStatus.needsReview,
      authors: ['Madea B'],
      container: 'Forensic Science International',
      year: '2005',
    ),
  ];
  final law = JurisdictionalInstrument(
    id: 'UZ-LAW-813-I',
    jurisdictionId: 'UZ',
    type: InstrumentType.law,
    titles: const {
      'en':
          'Law of the Republic of Uzbekistan “On Narcotic Drugs and '
          'Psychotropic Substances”',
      'uz':
          'O‘zbekiston Respublikasining «Giyohvandlik vositalari va psixotrop '
          'moddalar to‘g‘risida»gi Qonuni',
      'ru':
          'Закон Республики Узбекистан «О наркотических средствах и '
          'психотропных веществах»',
    },
    officialSourceId: 'SRC',
    effectiveFrom: DateTime(1999, 8, 19),
    version: '1',
    status: ScientificStatus.needsReview,
    language: 'ru',
    translationStatus: TranslationStatus.machineDraft,
  );

  Widget page(BuildContext context) => ListView(
    padding: const EdgeInsets.all(FeSpace.md),
    children: [
      FeCard(
        padding: const EdgeInsets.all(FeSpace.md),
        child: Builder(builder: (context) => const StudyAnswerText(item: item)),
      ),
      const SizedBox(height: FeSpace.sm),
      for (final r in research) ResearchTile(entry: r),
      const SizedBox(height: FeSpace.sm),
      FeCard(
        padding: const EdgeInsets.all(FeSpace.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InstrumentTitle(instrument: law),
            const SizedBox(height: FeSpace.sm),
            const LocalizedContentText(
              kind: ContentTextKind.conflictText,
              id: 'CF-1',
              source:
                  'The source reports partial overlap with blood values in '
                  'natural-cause deaths (n = 12, 2.7–33 ng/mL).',
              style: null,
            ),
          ],
        ),
      ),
    ],
  );

  for (final (lang, width, dark) in [
    ('uz', 390.0, false),
    ('uz', 320.0, false),
    ('ru', 320.0, true),
    ('en', 390.0, false),
  ]) {
    final name = 'trilingual_${lang}_${width.toInt()}${dark ? '_dark' : ''}';
    testWidgets(name, (tester) async {
      tester.view.physicalSize = Size(width, 1500) * 2;
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            contentTranslationsProvider.overrideWithValue(translations),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: dark ? FeThemeBuilder.dark() : FeThemeBuilder.light(),
            locale: Locale(lang),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: Builder(builder: page)),
          ),
        ),
      );
      await tester.pumpAndSettle();
      // «Asl manbadagi iqtibosni ko‘rish» ochilgan holat ham ko‘rinsin.
      final toggle = find.byKey(
        const Key('l10n.originalToggle.claim_excerpt.$claimId'),
      );
      if (toggle.evaluate().isNotEmpty) {
        await tester.tap(toggle);
        await tester.pumpAndSettle();
      }
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/$name.png'),
      );
    });
  }
}
