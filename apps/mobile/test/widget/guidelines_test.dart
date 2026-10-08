import 'dart:async';
import 'dart:convert';

import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/account.dart';
import 'package:forensic_expert/app/guidelines.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/router.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/domain/admin/admin_models.dart';
import 'package:forensic_expert/domain/guidelines/guideline_models.dart';
import 'package:forensic_expert/domain/guidelines/practice_catalog.dart';
import 'package:forensic_expert/domain/ports/account_ports.dart';

import '../helpers/pump_app.dart';
import '../helpers/referral_fakes.dart';

/// Test kontenti — haqiqiy ilmiy da’vo emas (faqat tuzilma tekshiruvi).
final _bundle = jsonEncode({
  'schema': 'fe-guidelines/1',
  'cards': [
    {
      'id': 'gl.chem.test',
      'discipline_codes': ['forensic_chemistry'],
      // Fayl VERIFIED desa ham — ekspert ko‘rigisiz NEEDS_REVIEW bo‘ladi.
      'status': 'VERIFIED',
      'updated': '2026-10-08',
      'title': {'uz': 'Sinov kartasi', 'en': 'Test card'},
      'translation_status': {'uz': 'AUTHORED', 'en': 'DRAFT'},
      'keywords': {
        'ru': ['газовая хроматография'],
        'en': ['gas chromatography'],
      },
      'related_tool_ids': ['tool.conv.ethanol_units'],
      'sections': [
        {
          'key': 'basis',
          'title': {'uz': 'Ilmiy asos', 'en': 'Scientific basis'},
          'body': {'uz': 'Sinov matni.', 'en': 'Test text.'},
          'citations': ['r1'],
        },
      ],
    },
  ],
  'references': [
    {
      'key': 'r1',
      'authors': ['Author A'],
      'title': 'Test reference',
      'journal': 'Test Journal',
      'year': 2000,
      'doi': '10.0000/test',
      'verified_via': 'fixture',
    },
  ],
});

final _catalog = jsonEncode({
  'source': {
    'source_id': 'restricted-test',
    'title_uz': 'Yopiq test manbasi',
    'year': 2025,
  },
  'normative': [
    {'source_id': 'law-test', 'title_uz': 'Test qonuni'},
  ],
  'tags': {
    'gc': [
      'gaz xromatografiyasi',
      'газовая хроматография',
      'gas chromatography',
    ],
  },
  'records': [
    {
      'code': 'X.G.1.2025',
      'code_original': 'X.G1.2025',
      'section': 'G',
      'title_uz': 'Sinov amaliyoti',
      'page_start': 10,
      'page_end': 12,
      'method_tags': ['gc'],
      'related_normative': ['law-test'],
      'independent_cards': ['gl.chem.test'],
    },
    {
      'code': 'X.A.1.2025',
      'section': 'A',
      'title_uz': 'Boshqa amaliyot',
      'page_start': 1,
    },
  ],
});

class _Account implements AccountService {
  const _Account(this.access);

  final ServerAccess access;

  @override
  bool get isConfigured => true;

  @override
  Future<ServerAccess?> myAccess() async => access;

  @override
  Future<void> registerDevice({
    required String platform,
    required String version,
    required String locale,
    String? region,
  }) async {}

  @override
  Future<AdminDashboard?> dashboard() async => null;

  @override
  Future<AdminGrantResult> setAccess(String email, String? tier) async =>
      AdminGrantResult.granted;
}

void main() {
  test('model: VERIFIED fayl ham NEEDS_REVIEW; fallback til belgilanadi', () {
    final b = GuidelineBundle.fromJson(
      (jsonDecode(_bundle) as Map).cast<String, Object?>(),
    );
    final card = b.cards.single;
    expect(card.status, ScientificStatus.needsReview);
    expect(card.area, GuidelineArea.forensicChemistry);
    expect(card.title.pick('ru').isFallback, isTrue);
    expect(card.title.pick('en').text, 'Test card');
    expect(
      b.referencesOf(card).single.link.toString(),
      'https://doi.org/10.0000/test',
    );
    expect(
      () => GuidelineBundle.fromJson({'schema': 'other'}),
      throwsFormatException,
    );
  });

  test(
    'yopiq katalog: asl kod saqlanadi, noto‘g‘ri fayl import qilinmaydi',
    () async {
      final store = MemoryPracticeCatalogStore();
      final cat = await importPracticeCatalog(store, _catalog);
      final r = cat.records.first;
      expect(r.code, 'X.G.1.2025');
      expect(r.codeOriginal, 'X.G1.2025');
      expect(r.codeWasNormalized, isTrue);
      expect(cat.searchTermsOf(r), contains('газовая хроматография'));
      expect(await store.read(), isNotNull);

      final empty = MemoryPracticeCatalogStore();
      await expectLater(
        importPracticeCatalog(empty, '{"records": []}'),
        throwsFormatException,
      );
      expect(await empty.read(), isNull);
    },
  );

  testWidgets('Yo‘riqnomalar: ro‘yxat, uch tilli qidiruv, karta va manba', (
    tester,
  ) async {
    await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz'),
      initialLocation: Routes.guidelines,
      overrides: [
        guidelineBundleLoaderProvider.overrideWithValue(() async => _bundle),
      ],
    );
    expect(find.text('Yo‘riqnomalar'), findsWidgets);
    expect(find.byKey(const Key('guidelines.card.gl.chem.test')), findsOne);
    // Admin bo‘lmagan foydalanuvchi — yopiq katalog yo‘q.
    expect(find.byKey(const Key('guidelines.restricted')), findsNothing);

    await tester.enterText(
      find.byKey(const Key('guidelines.search')),
      'газовая',
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('guidelines.card.gl.chem.test')), findsOne);
    await tester.enterText(
      find.byKey(const Key('guidelines.search')),
      'vjvjvj',
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('guidelines.noResults')), findsOne);

    await tester.enterText(find.byKey(const Key('guidelines.search')), '');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('guidelines.card.gl.chem.test')));
    await tester.pumpAndSettle();
    expect(find.text('Sinov kartasi'), findsOne);
    expect(
      find.textContaining(RegExp('ilmiy asos', caseSensitive: false)),
      findsOne,
    );
    expect(find.byKey(const Key('guideline.ref.r1')), findsOne);
    // O‘zbekcha — asl matn: qoralama ogohlantirishi yo‘q.
    expect(find.byKey(const Key('guideline.draftTranslation')), findsNothing);
  });

  testWidgets('ruscha: tarjima yo‘q — asl til ochiq ko‘rsatiladi', (
    tester,
  ) async {
    await pumpApp(
      tester,
      settings: completedSettings(lang: 'ru'),
      initialLocation: Routes.guideline('gl.chem.test'),
      overrides: [
        guidelineBundleLoaderProvider.overrideWithValue(() async => _bundle),
      ],
    );
    expect(find.byKey(const Key('guideline.fallback')), findsOne);
  });

  testWidgets('admin: qurilmadagi yopiq katalog, filtr va bog‘lanish', (
    tester,
  ) async {
    final c = await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz'),
      initialLocation: Routes.guidelines,
      overrides: [
        guidelineBundleLoaderProvider.overrideWithValue(() async => _bundle),
        authRepositoryProvider.overrideWithValue(await signedInMockAuth()),
        accountServiceProvider.overrideWithValue(
          const _Account(ServerAccess(isAdmin: true)),
        ),
        practiceCatalogStoreProvider.overrideWithValue(
          MemoryPracticeCatalogStore(_catalog),
        ),
      ],
    );
    expect(find.byKey(const Key('guidelines.restricted')), findsOne);
    unawaited(c.read(routerProvider).push(Routes.practiceCatalog));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('practice.X.G.1.2025')), findsOne);
    expect(find.byKey(const Key('practice.X.A.1.2025')), findsOne);

    await tester.enterText(
      find.byKey(const Key('practice.search')),
      'gas chromatography',
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('practice.X.A.1.2025')), findsNothing);
    await tester.tap(find.byKey(const Key('practice.X.G.1.2025')));
    await tester.pumpAndSettle();
    expect(find.textContaining('X.G1.2025'), findsOne);
    expect(find.text('Sinov kartasi'), findsOne);
    expect(find.text('Test qonuni'), findsOne);
  });

  testWidgets('oddiy foydalanuvchi: yopiq katalog fayli o‘qilmaydi', (
    tester,
  ) async {
    final c = await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz'),
      initialLocation: Routes.guidelines,
      overrides: [
        guidelineBundleLoaderProvider.overrideWithValue(() async => _bundle),
        authRepositoryProvider.overrideWithValue(await signedInMockAuth()),
        accountServiceProvider.overrideWithValue(
          const _Account(ServerAccess.none),
        ),
        practiceCatalogStoreProvider.overrideWithValue(
          MemoryPracticeCatalogStore(_catalog),
        ),
      ],
    );
    expect(await c.read(practiceCatalogProvider.future), isNull);
    expect(find.byKey(const Key('guidelines.restricted')), findsNothing);
  });
}
