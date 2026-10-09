import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/core/design/theme.dart';
import 'package:forensic_expert/core/l10n/generated/app_localizations.dart';
import 'package:forensic_expert/domain/evidence/evidence_models.dart';
import 'package:forensic_expert/domain/learn/study_models.dart';
import 'package:forensic_expert/domain/library/library_models.dart';
import 'package:forensic_expert/features/evidence/presentation/localized_content.dart';
import 'package:forensic_expert/features/evidence/presentation/research_screens.dart';
import 'package:forensic_expert/features/learn/presentation/study_screens.dart';
import 'package:forensic_expert/features/legal/presentation/instrument_title.dart';

/// Phase C — uch tilli ko‘rsatish qatlami: tarjima birinchi, holat UI
/// tilida, «Asl matn» yig‘ilgan, tarjima yo‘qligi ochiq aytiladi.
void main() {
  ContentTranslationRow row(
    String kind,
    String id,
    String source,
    String lang,
    String text, {
    String status = 'machine_draft',
  }) => ContentTranslationRow.tryParse(
    kind: kind,
    id: id,
    lang: lang,
    sourceSha256: TextTranslation.hashOf(source),
    text: text,
    status: status,
  )!;

  Future<void> pump(
    WidgetTester tester,
    Widget child, {
    String lang = 'uz',
    ContentTranslations translations = ContentTranslations.empty,
    double width = 390,
  }) async {
    tester.view.physicalSize = Size(width, 900) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          contentTranslationsProvider.overrideWithValue(translations),
        ],
        child: MaterialApp(
          theme: FeThemeBuilder.light(),
          locale: Locale(lang),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: child,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('holat belgisi UI tilida', () {
    const expected = {
      'uz': [
        'Avtomatik tarjima — tekshirilmagan',
        'Avtomatik tarjima — atamalar tekshirilgan, mazmuni tekshirilmagan',
        'Avtomatik tarjima — raqam va birliklar tekshirilgan, mutaxassis ko‘rmagan',
        'Tarjima mutaxassis tomonidan tekshirilgan',
        'Rasmiy matn',
      ],
      'ru': [
        'Автоматический перевод — не проверен',
        'Автоматический перевод — термины сверены, содержание не проверено',
        'Автоматический перевод — числа и единицы сверены, специалист не проверял',
        'Перевод проверен специалистом',
        'Официальный текст',
      ],
      'en': [
        'Machine translation — not reviewed',
        'Machine translation — terminology checked, content not reviewed',
        'Machine translation — numbers and units checked, not reviewed by an expert',
        'Translation reviewed by an expert',
        'Official text',
      ],
    };
    for (final MapEntry(key: lang, value: labels) in expected.entries) {
      testWidgets(lang, (tester) async {
        await pump(
          tester,
          Column(
            children: [
              for (final s in ContentTranslationStatus.values)
                TranslationStatusBadge(status: s),
            ],
          ),
          lang: lang,
        );
        for (final label in labels) {
          expect(find.text(label), findsOneWidget, reason: label);
        }
      });
    }
  });

  group('LocalizedContentText', () {
    const src = 'Vitreous potassium rises after death.';
    const kind = ContentTextKind.conflictText;
    final tr = ContentTranslations.of([
      row(
        kind,
        'K1',
        src,
        'uz',
        'O‘limdan keyin ko‘z ichi suyuqligida kaliy oshadi.',
      ),
    ]);
    Widget view() =>
        const LocalizedContentText(kind: kind, id: 'K1', source: src);

    testWidgets('uz: tarjima → holat → «Asl matn» (yig‘ilgan → ochiladi)', (
      tester,
    ) async {
      await pump(tester, view(), translations: tr);
      final text = find.text(
        'O‘limdan keyin ko‘z ichi suyuqligida kaliy oshadi.',
      );
      expect(text, findsOneWidget);
      expect(find.text('Avtomatik tarjima — tekshirilmagan'), findsOneWidget);
      expect(find.text(src), findsNothing);
      expect(
        tester.getTopLeft(text).dy,
        lessThan(tester.getTopLeft(find.text('Asl matn')).dy),
      );
      await tester.tap(find.byKey(const Key('l10n.originalToggle.$kind.K1')));
      await tester.pumpAndSettle();
      expect(find.text(src), findsOneWidget);
      expect(find.text('Asl matnni yashirish'), findsOneWidget);
      final orig = tester.widget<Text>(find.text(src));
      expect(orig.locale, const Locale('en'));
      await tester.tap(find.byKey(const Key('l10n.originalToggle.$kind.K1')));
      await tester.pumpAndSettle();
      expect(find.text(src), findsNothing);
    });

    testWidgets('ru: tarjima yo‘q — halol xabar ruscha + asl matn', (
      tester,
    ) async {
      await pump(tester, view(), lang: 'ru', translations: tr);
      expect(
        find.text(
          'Русский перевод этого текста ещё не подготовлен — язык оригинала: английский',
        ),
        findsOneWidget,
      );
      expect(find.text(src), findsOneWidget);
      expect(find.text('Оригинал'), findsNothing);
    });

    testWidgets('en: asl matn, hech qanday belgi yo‘q', (tester) async {
      await pump(tester, view(), lang: 'en', translations: tr);
      expect(find.text(src), findsOneWidget);
      expect(find.byKey(const Key('l10n.missing.$kind.K1')), findsNothing);
      expect(find.text('Original text'), findsNothing);
    });

    testWidgets('en UI, rus tilidagi asl: inglizcha xabar', (tester) async {
      await pump(
        tester,
        const LocalizedContentText(
          kind: kind,
          id: 'K2',
          source: 'Приготовление реактивов',
          originalLang: 'ru',
        ),
        lang: 'en',
      );
      expect(
        find.text(
          'An English translation of this text is not available yet — original language: Russian',
        ),
        findsOneWidget,
      );
    });

    testWidgets('reviewed — «tekshirilmagan» belgisi yo‘q', (tester) async {
      await pump(
        tester,
        view(),
        translations: ContentTranslations.of([
          row(
            kind,
            'K1',
            src,
            'uz',
            'Tekshirilgan tarjima.',
            status: 'reviewed',
          ),
        ]),
      );
      expect(find.text('Tekshirilgan tarjima.'), findsOneWidget);
      expect(
        find.text('Tarjima mutaxassis tomonidan tekshirilgan'),
        findsOneWidget,
      );
      expect(find.textContaining('tekshirilmagan'), findsNothing);
    });

    testWidgets('qisqa qiymat: tarjima yo‘q — «asl tili: ingliz» yorlig‘i', (
      tester,
    ) async {
      await pump(
        tester,
        const LocalizedInlineText(
          kind: ContentTextKind.screeningField,
          id: 'scr#analyte',
          source: 'opiates (class-based)',
        ),
      );
      expect(
        find.textContaining('opiates (class-based)  (asl tili: ingliz)'),
        findsOneWidget,
      );
    });
  });

  group('huquqiy hujjat nomi (titles[lang])', () {
    final uzLaw = JurisdictionalInstrument(
      id: 'UZ-LAW-813-I',
      jurisdictionId: 'UZ',
      type: InstrumentType.law,
      titles: const {
        'en': 'Law “On Narcotic Drugs and Psychotropic Substances”',
        'uz': '«Giyohvandlik vositalari va psixotrop moddalar to‘g‘risida»gi Qonun',
        'ru': 'Закон «О наркотических средствах и психотропных веществах»',
        '_date_precision': 'day',
      },
      officialSourceId: 'SRC',
      effectiveFrom: DateTime(1999),
      version: '1',
      status: ScientificStatus.needsReview,
      language: 'ru',
      translationStatus: TranslationStatus.machineDraft,
    );
    final greenList = JurisdictionalInstrument(
      id: 'INT-INCB-GL-36',
      jurisdictionId: 'INT',
      type: InstrumentType.controlledSubstanceSchedule,
      titles: const {'en': 'Green List, 36th edition'},
      officialSourceId: 'SRC',
      effectiveFrom: DateTime(2024),
      version: '36',
      status: ScientificStatus.needsReview,
    );

    testWidgets('uz: o‘zbekcha nom + norasmiy tarjima + asl (rasmiy) nomi', (
      tester,
    ) async {
      await pump(tester, InstrumentTitle(instrument: uzLaw));
      expect(find.text(uzLaw.titles['uz']!), findsOneWidget);
      expect(
        find.text('Nomning norasmiy tarjimasi — tekshirilmagan'),
        findsOneWidget,
      );
      expect(find.text('Asl nomi: ${uzLaw.titles['ru']}'), findsOneWidget);
      expect(find.text(uzLaw.titles['en']!), findsNothing);
    });

    testWidgets('ru: rasmiy nom (rus tilida)', (tester) async {
      await pump(tester, InstrumentTitle(instrument: uzLaw), lang: 'ru');
      expect(find.text(uzLaw.titles['ru']!), findsOneWidget);
      expect(find.text('Официальное название (язык: русский)'), findsOneWidget);
    });

    testWidgets('en: inglizcha nom — norasmiy tarjima', (tester) async {
      await pump(tester, InstrumentTitle(instrument: uzLaw), lang: 'en');
      expect(find.text(uzLaw.titles['en']!), findsOneWidget);
      expect(
        find.text('Unofficial translation of the title — not reviewed'),
        findsOneWidget,
      );
    });

    testWidgets('uz: faqat inglizcha nom — ochiq xabar', (tester) async {
      await pump(tester, InstrumentTitle(instrument: greenList));
      expect(find.text('Green List, 36th edition'), findsOneWidget);
      expect(
        find.text('Nomning o‘zbekcha tarjimasi hali yo‘q — asl tili: ingliz'),
        findsOneWidget,
      );
      expect(instrumentTitleOf(greenList, 'uz').missingTranslation, isTrue);
    });
  });

  group('o‘quv testi iqtibosi — tarjima birinchi', () {
    const quote =
        'For example, basic lipophilic drugs with a volume of distribution '
        'above 3 L/kg are prone to PMR.';
    const uz =
        'Masalan, taqsimlanish hajmi 3 L/kg dan yuqori bo‘lgan asosli lipofil '
        'dori vositalari PMR ga uchrashi ehtimoli yuqori.';
    const claimId = 'C-TOX-PMR-P8';
    const item = StudyItem(
      id: 'topic.tox-pmr',
      kind: StudyItemKind.topicExcerpt,
      deckId: 'discipline.forensicToxicology',
      prompt: LocalizedText({'en': 'PMR', 'uz': 'PMR', 'ru': 'PMR'}),
      answer: LocalizedText({'en': quote}),
      answerIsQuote: true,
      claimId: claimId,
      status: ScientificStatus.needsReview,
      isTestData: false,
      citations: [],
      origin: StudyOrigin.knowledgeEntry,
      originId: 'tox-pmr',
    );
    final tr = ContentTranslations.of([
      row(ContentTextKind.claimExcerpt, claimId, quote, 'uz', uz),
    ]);

    testWidgets('uz: o‘zbekcha matn, asl iqtibos tugma ortida', (tester) async {
      await pump(tester, const StudyAnswerText(item: item), translations: tr);
      expect(find.text(uz), findsOneWidget);
      expect(find.text('Manbadagi iqtibos (tarjima)'), findsOneWidget);
      expect(find.text('Avtomatik tarjima — tekshirilmagan'), findsOneWidget);
      expect(find.text(quote), findsNothing);
      final toggle = find.text('Asl manbadagi iqtibosni ko‘rish');
      expect(toggle, findsOneWidget);
      await tester.tap(toggle);
      await tester.pumpAndSettle();
      expect(find.text(quote), findsOneWidget);
    });

    testWidgets('ru: tarjima yo‘q — halol xabar va asl iqtibos', (
      tester,
    ) async {
      await pump(
        tester,
        const StudyAnswerText(item: item),
        lang: 'ru',
        translations: tr,
      );
      expect(find.text(quote), findsOneWidget);
      expect(
        find.text(
          'Русский перевод этого текста ещё не подготовлен — язык оригинала: английский',
        ),
        findsOneWidget,
      );
    });

    testWidgets('en: asl iqtibos, belgisiz', (tester) async {
      await pump(
        tester,
        const StudyAnswerText(item: item),
        lang: 'en',
        translations: tr,
      );
      expect(find.text(quote), findsOneWidget);
      expect(
        find.byKey(const Key('l10n.missing.claim_excerpt.$claimId')),
        findsNothing,
      );
    });
  });

  group('tadqiqot sarlavhasi — 320 dp', () {
    const title =
        'Postmortem redistribution of drugs: a systematic review of '
        'mechanisms, site-dependent concentration differences and '
        'interpretive pitfalls in forensic toxicology casework';
    const uzTitle =
        'Dori vositalarining o‘limdan keyingi qayta taqsimlanishi (PMR): '
        'mexanizmlar, namuna olingan joyga bog‘liq konsentratsiya farqlari '
        'va sud-toksikologik talqindagi xatolar — tizimli sharh';
    const entry = ResearchEntry(
      id: 'R-PMR-1',
      kind: ResearchKind.systematicReview,
      title: title,
      evidenceLevel: 'A',
      peerReviewed: true,
      status: ScientificStatus.needsReview,
      authors: ['Pélissier-Alicot AL', 'Gaulier JM'],
      container: 'Journal of Analytical Toxicology',
      year: '2003',
    );

    testWidgets('tarjima → «Asl nomi» → mualliflar; overflow yo‘q', (
      tester,
    ) async {
      await pump(
        tester,
        const ResearchTile(entry: entry),
        width: 320,
        translations: ContentTranslations.of([
          row(ContentTextKind.researchTitle, entry.id, title, 'uz', uzTitle),
        ]),
      );
      expect(tester.takeException(), isNull);
      final tr = find.byKey(
        const Key('title.translated.research_title.R-PMR-1'),
      );
      final orig = find.byKey(const Key('research.originalTitle.R-PMR-1'));
      final meta = find.textContaining('Journal of Analytical Toxicology');
      expect(tr, findsOneWidget);
      expect(orig, findsOneWidget);
      expect(tester.getTopLeft(tr).dy, lessThan(tester.getTopLeft(orig).dy));
      expect(tester.getTopLeft(orig).dy, lessThan(tester.getTopLeft(meta).dy));
      expect(find.text('Avtomatik tarjima — tekshirilmagan'), findsOneWidget);
      // Uzun sarlavha o‘raladi (bir qatordan baland), kartadan chiqmaydi.
      expect(tester.getSize(tr).height, greaterThan(40));
      expect(tester.getSize(tr).width, lessThanOrEqualTo(320 - 32));
      expect(
        find.byKey(const Key('research.originalLang.R-PMR-1')),
        findsNothing,
      );
    });

    testWidgets('tarjima yo‘q — asl sarlavha + «asl tili: ingliz» belgisi', (
      tester,
    ) async {
      await pump(tester, const ResearchTile(entry: entry), width: 320);
      expect(tester.takeException(), isNull);
      expect(find.text(title), findsOneWidget);
      expect(
        find.byKey(const Key('research.originalLang.R-PMR-1')),
        findsOneWidget,
      );
      expect(find.text('asl tili: ingliz'), findsOneWidget);
    });
  });
}
