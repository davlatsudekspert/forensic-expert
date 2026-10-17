import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/aby_flag.dart';
import 'package:forensic_expert/domain/knowledge/knowledge_models.dart';
import 'package:forensic_expert/features/profile/presentation/sources_authors_screen.dart';

import '../helpers/pilot_content.dart';
import '../helpers/pump_app.dart';
import '../helpers/study_fixtures.dart';

/// Milliy amaliyot yo‘riqnomasidan (ABY, 2025) olingan yozuvlar.
/// Egasining qarori (`docs/DECISIONS.md`, 2026-10-10):
///   * manba sifatida ochiq keltiriladi, aniq joyi bilan;
///   * so‘zma-so‘z iqtibos yo‘q — mazmuni o‘z so‘zlarimiz bilan;
///   * faqat o‘zbek tilida (ru/en da yozuv ham, mavzu ham ko‘rinmaydi);
///   * bepul (paywall ortida emas);
///   * yo‘riqnoma faylining o‘zi repoda / paketda yo‘q.
void main() {
  // ABY yashirin bo‘lsa-da, ABY kontentining o‘zi shu testda tekshiriladi.
  setUpAll(() => abyContentEnabled = true);
  tearDownAll(() => abyContentEnabled = false);

  late PilotContent pilot;
  setUpAll(() async => pilot = await loadPilotContent());

  test('paketda: 94 ABY yozuvi, faqat o‘zbekcha, iqtibossiz, bepul', () {
    final topics = [
      for (final area in KnowledgeArea.values)
        for (final e in pilot.knowledge.topicsIn(area))
          if (e.id.startsWith('aby-')) e,
    ];
    expect(topics.length, 39);
    final claims = [
      for (final e in topics) ...e.claims,
      // Modda sahifalaridagi ABY yozuvlari (etanol, metanol, CO).
      for (final id in const [
        'ethanol',
        'methanol',
        'carbon-monoxide',
        'amitriptyline',
        'carbamazepine',
      ])
        ...?pilot.library
            .byId(id)
            ?.details
            ?.claims
            .where((c) => c.claimId.startsWith('C-ABY-')),
    ];
    expect(claims.length, 94);
    for (final c in claims) {
      // `C-ABY-…` — yo‘riqnomadan olingan yozuv; `C-ABYX-…` — uning ustiga
      // yozilgan, xalqaro manbaga tayangan ekspert eslatmasi.
      expect(c.claimId, startsWith('C-ABY'));
      // Hech bir yozuvda so‘zma-so‘z iqtibos yo‘q.
      expect(c.excerpt, isNull, reason: c.claimId);
      expect(c.visibleIn('uz'), isTrue, reason: c.claimId);
      expect(c.visibleIn('ru'), isFalse, reason: c.claimId);
      expect(c.visibleIn('en'), isFalse, reason: c.claimId);
      // Matn va aniq joyi o‘zbekcha; ABY nomi bilan keltiriladi.
      expect(c.statementFor('uz'), isNotNull, reason: c.claimId);
      if (!c.claimId.startsWith('C-ABYX-')) {
        expect(c.locatorFor('uz'), contains('ABY'), reason: c.claimId);
        expect(c.locatorFor('uz'), contains('.2025'), reason: c.claimId);
      }
      expect(c.status, ScientificStatus.needsReview, reason: c.claimId);
      if (c.claimId.startsWith('C-ABYX-')) {
        // Ekspert eslatmasi yo‘riqnomaga emas, xalqaro manbaga tayanadi.
        expect(c.sources, isNotEmpty, reason: c.claimId);
        expect(
          c.sources.every((s) => s.sourceId != 'SRC-ABY-2025'),
          isTrue,
          reason: c.claimId,
        );
      } else {
        expect(
          c.sources.map((s) => s.sourceId),
          contains('SRC-ABY-2025'),
          reason: c.claimId,
        );
      }
    }
  });

  test('yo‘riqnomaning fayli paketda yo‘q — faqat unga havola', () {
    final src = pilot.knowledge
        .topicsIn(KnowledgeArea.toxicology)
        .expand((e) => e.allSources)
        .firstWhere((s) => s.sourceId == 'SRC-ABY-2025');
    expect(src.title, contains('yo‘riqnomasi'));
    // Hujjat internetda yo‘q va ilovaga ham kiritilmagan: havola berilmaydi.
    expect(src.url, anyOf(isNull, isEmpty));
  });

  test('til filtri: faqat o‘zbekcha mavzu boshqa tilda ro‘yxatda yo‘q', () {
    final uzOnly = testTopic(
      'aby-test-only',
      claims: [
        testClaim('C-ABY-TEST', 'principle', {
          'statement': {'uz': 'Faqat o‘zbekcha amaliyot'},
          'locale_only': 'uz',
          'translation_status': {'uz': 'authored'},
        }),
      ],
    );
    final normal = testTopic('plain-topic');
    final inner = ListKnowledgeRepository([uzOnly, normal]);
    for (final (lang, ids) in const [
      ('uz', ['aby-test-only', 'plain-topic']),
      ('ru', ['plain-topic']),
      ('en', ['plain-topic']),
    ]) {
      final repo = LocaleFilteredKnowledgeRepository(inner, lang);
      expect(
        repo.topicsIn(KnowledgeArea.forensicMedicine).map((e) => e.id),
        ids,
        reason: lang,
      );
      expect(repo.byKind(KnowledgeKind.topic).map((e) => e.id), ids);
      // Havola bilan kelgan bo‘lsa ham ochilmaydi (bo‘sh sahifa bo‘lmasin).
      expect(
        repo.byId('aby-test-only') != null,
        lang == 'uz',
        reason: 'byId $lang',
      );
    }
  });

  for (final lang in const ['uz', 'ru', 'en']) {
    testWidgets('$lang: ABY mavzusi faqat o‘zbekcha ochiladi', (tester) async {
      await pumpApp(
        tester,
        settings: completedSettings(lang: lang),
        initialLocation: Routes.knowledgeEntry('aby-tox-opiates'),
        testFixtures: false,
        overrides: [...pilot.overrides],
      );
      final statement = find.byKey(
        const Key('claim.statement.C-ABY-TOX-OPI-01'),
      );
      if (lang == 'uz') {
        expect(statement, findsOneWidget);
        expect(find.textContaining('ABY'), findsWidgets);
      } else {
        expect(statement, findsNothing);
        expect(find.textContaining('ABY'), findsNothing);
      }
    });
  }

  testWidgets('minnatdorchilik sahifasida ABY tuzuvchilari yozilgan', (
    tester,
  ) async {
    await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz'),
      initialLocation: Routes.aboutSources,
      testFixtures: false,
      overrides: [...pilot.overrides],
    );
    expect(find.byKey(const Key('sourcesAuthors.list')), findsOneWidget);
    final texts = tester
        .widgetList<Text>(find.byType(Text))
        .map((w) => w.data ?? '')
        .join(' | ');
    expect(texts, contains('Sh.I. Ro‘ziev'));
    expect(texts, contains('A.Z. Otamurodov'));
    expect(texts, contains('Respublika sud-tibbiy ekspertiza'));
    // Sahifa faqat o‘zbek tilida.
    expect(SourcesAuthorsScreen.languageCode, 'uz');
  });

  testWidgets('ABY yozuvida ob’ekt alohida qator bo‘lib turadi (qon, siydik)', (
    tester,
  ) async {
    await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz'),
      initialLocation: Routes.knowledgeEntry('aby-tox-benzodiazepines'),
      testFixtures: false,
      overrides: [...pilot.overrides],
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('claim.objects.C-ABY-TOX-BZD-01')), findsOne);
    expect(find.textContaining('Ob’ekt'), findsWidgets);
    expect(find.textContaining('qon'), findsWidgets);
    expect(find.textContaining('siydik'), findsWidgets);
  });

  test('ABY ob’ekti: faqat matnda aytilgani, taxmin yo‘q', () {
    final claims = [
      for (final area in KnowledgeArea.values)
        for (final e in pilot.knowledge.topicsIn(area))
          if (e.id.startsWith('aby-')) ...e.claims,
    ];
    expect(claims, isNotEmpty);
    for (final c in claims) {
      // Har ABY yozuvi ob’ekt holatini e’lon qiladi.
      expect(c.objectsStated, isNotNull, reason: c.claimId);
      // Aytilmagan bo‘lsa — ro‘yxat bo‘sh; aytilgan bo‘lsa — bo‘sh emas.
      expect(c.objects.isNotEmpty, c.objectsStated, reason: c.claimId);
    }
    final bzd = claims.firstWhere((c) => c.claimId == 'C-ABY-TOX-BZD-01');
    expect(bzd.objects, ['blood', 'urine']);
  });
}
