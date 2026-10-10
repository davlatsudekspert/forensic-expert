import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/domain/knowledge/knowledge_models.dart';
import 'package:forensic_expert/domain/library/library_models.dart';
import 'package:forensic_expert/features/profile/presentation/sources_authors_screen.dart';

import '../helpers/fake_store.dart';
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
  late PilotContent pilot;
  setUpAll(() async => pilot = await loadPilotContent());

  test('paketda: 32 ABY yozuvi, faqat o‘zbekcha, iqtibossiz, bepul', () {
    final topics = [
      for (final area in KnowledgeArea.values)
        for (final e in pilot.knowledge.topicsIn(area))
          if (e.id.startsWith('aby-')) e,
    ];
    expect(topics.length, 19);
    final claims = [
      for (final e in topics) ...e.claims,
      // Modda sahifalaridagi ABY yozuvlari (etanol, metanol, CO).
      for (final id in const ['ethanol', 'methanol', 'carbon-monoxide'])
        ...?pilot.library
            .byId(id)
            ?.details
            ?.claims
            .where((c) => c.claimId.startsWith('C-ABY-')),
    ];
    expect(claims.length, 32);
    for (final c in claims) {
      expect(c.claimId, startsWith('C-ABY-'));
      // Hech bir yozuvda so‘zma-so‘z iqtibos yo‘q.
      expect(c.excerpt, isNull, reason: c.claimId);
      expect(c.visibleIn('uz'), isTrue, reason: c.claimId);
      expect(c.visibleIn('ru'), isFalse, reason: c.claimId);
      expect(c.visibleIn('en'), isFalse, reason: c.claimId);
      // Matn va aniq joyi o‘zbekcha; ABY nomi bilan keltiriladi.
      expect(c.statementFor('uz'), isNotNull, reason: c.claimId);
      expect(c.locatorFor('uz'), contains('ABY'), reason: c.claimId);
      expect(c.locatorFor('uz'), contains('.2025'), reason: c.claimId);
      expect(c.status, ScientificStatus.needsReview, reason: c.claimId);
      expect(
        c.sources.map((s) => s.sourceId),
        contains('SRC-ABY-2025'),
        reason: c.claimId,
      );
    }
    // Mavzular bepul.
    for (final e in topics) {
      expect(e.access, EntryAccess.free, reason: e.id);
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
        overrides: [
          ...pilot.overrides,
          entitlementServiceProvider.overrideWithValue(FakeStore(owned: true)),
        ],
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
}
