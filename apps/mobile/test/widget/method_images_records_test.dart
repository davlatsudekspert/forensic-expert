import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/aby_flag.dart';
import 'package:forensic_expert/domain/evidence/evidence_models.dart';
import 'package:forensic_expert/domain/knowledge/knowledge_models.dart';
import 'package:forensic_expert/domain/library/library_models.dart';
import 'package:forensic_expert/features/evidence/presentation/scientific_image.dart';

import '../helpers/pilot_content.dart';
import '../helpers/pump_app.dart';
import '../helpers/study_fixtures.dart';

/// 1) Usul sahifasidagi real o‘lchov rasmlari «boshqa modda misoli» deb
///    belgilanadi (uch tilda); sxema va struktura rasmlari belgilanmaydi.
/// 2) Usul rejimi bo‘limi (etanol, GC-FID): `value.statement` matni, aniq joyi,
///    avtomatik tarjima belgisi.
/// 3) `value.locale_only`: bitta tilga bog‘langan yozuv boshqa tilda umuman
///    ko‘rinmaydi (bo‘sh joy ham, «tarjima yo‘q» ham chiqmaydi).
void main() {
  // ABY yashirin bo‘lsa-da, ABY kontentining o‘zi shu testda tekshiriladi.
  setUpAll(() => abyContentEnabled = true);
  tearDownAll(() => abyContentEnabled = false);

  late PilotContent pilot;
  setUpAll(() async => pilot = await loadPilotContent());

  Future<void> open(
    WidgetTester tester,
    String lang,
    String route, {
    List<Override> extra = const [],
  }) => pumpApp(
    tester,
    settings: completedSettings(lang: lang),
    initialLocation: route,
    testFixtures: false,
    overrides: [...pilot.overrides, ...extra],
  );

  ImageMeta image(String kind, String entity, {required bool real}) =>
      ImageMeta(
        id: 'img-$entity-$kind',
        kind: ImageKind.values.firstWhere((k) => k.code == kind),
        entityId: entity,
        title: const LocalizedText({'en': 't', 'ru': 't', 'uz': 't'}),
        alt: const LocalizedText({'en': 'a', 'ru': 'a', 'uz': 'a'}),
        license: 'CC-BY-4.0',
        attribution: 'x',
        isOriginalDiagram: !real,
        representsRealData: real,
      );

  test(
    'isOtherSubstanceExample: faqat usul sahifasidagi real o‘lchov rasmi',
    () {
      expect(
        isOtherSubstanceExample(
          image('chromatogram', 'method-gcms', real: true),
        ),
        isTrue,
      );
      expect(
        isOtherSubstanceExample(image('tlc_plate', 'method-tlc', real: true)),
        isTrue,
      );
      // Umumiy sxema — biror moddaga tegishli emas.
      expect(
        isOtherSubstanceExample(image('schematic', 'method-gcms', real: false)),
        isFalse,
      );
      // Moddaning o‘z rasmi (struktura) — boshqa modda emas.
      expect(
        isOtherSubstanceExample(
          image('chemical_structure', 'ethanol', real: false),
        ),
        isFalse,
      );
    },
  );

  test('ClaimView: locale_only, statement va locator tilga qarab', () {
    final both = testClaim('C-A', 'principle', {
      'statement': {'en': 'English', 'uz': 'Uzbek', 'ru': 'Russian'},
      'locator_i18n': {'en': 'p. 1', 'uz': '1-bet', 'ru': 'с. 1'},
      'translation_status': {'en': 'authored', 'uz': 'machine_draft'},
    });
    final uzOnly = testClaim('C-U', 'principle', {
      'statement': {'uz': 'Faqat o‘zbekcha'},
      'locale_only': 'uz',
    });
    expect(both.visibleIn('ru'), isTrue);
    expect(both.statementFor('ru'), 'Russian');
    expect(both.locatorFor('uz'), '1-bet');
    expect(both.translationStatusFor('uz'), 'machine_draft');
    // Tarjima bo‘lmasa, locale_only bo‘lmagan yozuv inglizchaga qaytadi.
    final partial = testClaim('C-P', 'principle', {
      'statement': {'en': 'English', 'uz': 'Uzbek'},
    });
    expect(partial.statementFor('ru'), 'English');
    expect(uzOnly.visibleIn('uz'), isTrue);
    expect(uzOnly.visibleIn('ru'), isFalse);
    expect(uzOnly.visibleIn('en'), isFalse);
    // locale_only yozuv hech qachon boshqa tilga «tushmaydi».
    expect(uzOnly.statementFor('ru'), isNull);
    expect(uzOnly.statementFor('en'), isNull);
    expect(visibleClaims([both, uzOnly], 'ru').map((c) => c.claimId), ['C-A']);
    expect(visibleClaims([both, uzOnly], 'uz').map((c) => c.claimId), [
      'C-A',
      'C-U',
    ]);
  });

  for (final lang in const ['uz', 'ru', 'en']) {
    testWidgets('$lang: GC-MS usul sahifasida boshqa moddaning real rasmi '
        'ko‘rsatilmaydi', (tester) async {
      await open(tester, lang, Routes.knowledgeEntry('method-gcms'));
      await tester.pumpAndSettle();
      // Paketda bunday rasm bor (5-MAPB), lekin usul kartasida chiqmaydi:
      // foydalanuvchi kelgan moddaga aloqasi yo‘q.
      final meta = pilot.evidence.imagesFor('method-gcms');
      expect(meta.where(isOtherSubstanceExample), isNotEmpty);
      // Galereya qoladi — umumiy sxema uchun; lekin boshqa moddaning real
      // o‘lchov rasmi va uning yorlig‘i yo‘q.
      expect(find.byType(OtherSubstanceExampleNote), findsNothing);
      for (final m in meta.where(isOtherSubstanceExample)) {
        expect(find.byKey(Key('image.${m.id}')), findsNothing, reason: m.id);
      }
    });
  }

  testWidgets('TLC usul sahifasida kannabinoid plastinkasi yo‘q', (
    tester,
  ) async {
    await open(tester, 'uz', Routes.knowledgeEntry('method-tlc'));
    await tester.pumpAndSettle();
    expect(
      pilot.evidence.imagesFor('method-tlc').where(isOtherSubstanceExample),
      isEmpty,
      reason: 'rasm o‘zi ko‘rsatayotgan moddaga ko‘chirilgan',
    );
    expect(find.byType(OtherSubstanceExampleNote), findsNothing);
  });

  testWidgets('kannabinoid plastinkasi THC modda sahifasida turadi', (
    tester,
  ) async {
    expect(
      pilot.evidence.imagesFor('thc').map((m) => m.id),
      contains('IMG-EXT-pmc9558087-ac2c01627_0004'),
    );
  });

  testWidgets('modda sahifasi (etanol): struktura rasmida belgi yo‘q', (
    tester,
  ) async {
    await open(tester, 'uz', Routes.libraryEntry('ethanol'));
    expect(find.byType(OtherSubstanceExampleNote), findsNothing);
    expect(find.text('Misol: boshqa modda'), findsNothing);
  });

  for (final (lang, label) in const [
    ('uz', 'Namunani tayyorlash'),
    ('ru', 'Подготовка пробы'),
    ('en', 'Sample preparation'),
  ]) {
    testWidgets('$lang: etanol — usul rejimi bo‘limi (HS-GC-FID)', (
      tester,
    ) async {
      await open(tester, lang, Routes.libraryEntry('ethanol'));
      Future<void> see(Finder f) async {
        await tester.dragUntilVisible(
          f,
          find.byType(ListView).first,
          const Offset(0, -300),
        );
        await tester.pumpAndSettle();
      }

      final stmt = find.byKey(const Key('claim.statement.C-EP-ETHANOL-02'));
      await see(stmt);
      expect(stmt, findsOneWidget);
      expect(
        find.byKey(const Key('methodRecord.label.C-EP-ETHANOL-02')),
        findsOneWidget,
      );
      expect(find.text(label), findsWidgets);
      // Aniq joyi (manba nomi + bo‘lim) ko‘rsatiladi.
      final locator = find.byKey(const Key('claim.locator.C-EP-ETHANOL-02'));
      expect(locator, findsOneWidget);
      expect(
        (tester.widget(locator) as Text).data,
        contains('Taylor et al., Molecules 2022'),
      );
      // Avtomatik tarjima belgisi faqat uz/ru da (inglizcha matn — asl).
      final draft = find.byKey(
        const Key('claim.statement.draft.C-EP-ETHANOL-02'),
      );
      expect(draft, lang == 'en' ? findsNothing : findsOneWidget);
    });
  }

  for (final lang in const ['uz', 'ru', 'en']) {
    testWidgets('$lang: locale_only=uz yozuv faqat o‘zbekcha ko‘rinadi', (
      tester,
    ) async {
      final topic = testTopic(
        'locale-t',
        claims: [
          testClaim('C-BOTH', 'principle', {
            'statement': {'en': 'Both EN', 'uz': 'Both UZ', 'ru': 'Both RU'},
            'translation_status': {'uz': 'machine_draft'},
          }),
          testClaim('C-UZONLY', 'principle', {
            'statement': {'uz': 'Faqat o‘zbek tilida matn'},
            'locale_only': 'uz',
            'translation_status': {'uz': 'authored'},
          }),
        ],
      );
      await pumpApp(
        tester,
        settings: completedSettings(lang: lang),
        initialLocation: Routes.knowledgeEntry('locale-t'),
        testFixtures: false,
        overrides: [
          knowledgeRepositoryProvider.overrideWithValue(
            ListKnowledgeRepository([topic]),
          ),
        ],
      );
      expect(find.byKey(const Key('claim.statement.C-BOTH')), findsOneWidget);
      final uzOnly = find.byKey(const Key('claim.statement.C-UZONLY'));
      if (lang == 'uz') {
        expect(uzOnly, findsOneWidget);
        expect(find.text('Faqat o‘zbek tilida matn'), findsOneWidget);
      } else {
        // Bo‘sh joy ham, «tarjima yo‘q» ham, inglizcha matn ham chiqmaydi.
        expect(uzOnly, findsNothing);
        expect(find.byKey(const Key('claim.C-UZONLY')), findsNothing);
        expect(find.byKey(const Key('claim.withheld.C-UZONLY')), findsNothing);
        expect(find.text('Faqat o‘zbek tilida matn'), findsNothing);
      }
    });
  }

  for (final lang in const ['uz', 'ru', 'en']) {
    testWidgets('$lang: «Manbalar va mualliflar» faqat o‘zbekcha interfeysda', (
      tester,
    ) async {
      await pumpApp(
        tester,
        settings: completedSettings(lang: lang),
        initialLocation: Routes.about,
      );
      final row = find.byKey(const Key('about.sourcesAuthors'));
      if (lang != 'uz') {
        expect(row, findsNothing);
        return;
      }
      await tester.dragUntilVisible(
        row,
        find.byType(Scrollable).first,
        const Offset(0, -200),
      );
      await tester.tap(row);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('sourcesAuthors.intro')), findsOneWidget);
      expect(find.textContaining('Z.A. Yuldashev'), findsWidgets);
      expect(
        find.textContaining('Abduraxmonov Toshtemirovich'),
        findsOneWidget,
      );
    });
  }
}
