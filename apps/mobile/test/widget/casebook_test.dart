import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/casebook.dart';
import 'package:forensic_expert/app/guidelines.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/app/share.dart';
import 'package:forensic_expert/domain/casebook/casebook_models.dart';

import '../helpers/pump_app.dart';

/// TEST kontenti — haqiqiy ilmiy da’vo emas (faqat tuzilma tekshiruvi).
final _bundle = jsonEncode({
  'schema': 'fe-guidelines/1',
  'cards': [
    {
      'id': 'gl.test',
      'discipline_codes': ['forensic_chemistry'],
      'status': 'NEEDS_REVIEW',
      'title': {'uz': 'Sinov kartasi', 'en': 'Test card'},
      'translation_status': {'uz': 'AUTHORED', 'en': 'AUTHORED'},
      'sections': [
        {
          'key': 'basis',
          'title': {'uz': 'Ilmiy asos', 'en': 'Basis'},
          'body': {'uz': 'Asos matni.', 'en': 'Basis text.'},
          'citations': ['r1'],
        },
        {
          'key': 'limitations',
          'title': {'uz': 'Cheklovlar', 'en': 'Limitations'},
          'body': {
            'uz': 'Sinov cheklovi matni [r1].',
            'en': 'Test limitation text [r1].',
          },
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
      'pages': '10-29',
      'doi': '10.0000/test',
    },
  ],
});

class _FakeShare implements ShareService {
  final texts = <String>[];

  @override
  Future<void> shareText(String text, {String? subject, Rect? origin}) async =>
      texts.add(text);
}

Future<void> _back(WidgetTester tester) async {
  await tester.tap(find.byType(BackButton).hitTestable().first);
  await tester.pumpAndSettle();
}

void main() {
  final overrides = [
    guidelineBundleLoaderProvider.overrideWithValue(() async => _bundle),
  ];

  testWidgets('Vositalar ekranida kirish nuqtasi; bo‘sh holat va maxfiylik', (
    tester,
  ) async {
    await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz'),
      initialLocation: Routes.tools,
      overrides: overrides,
    );
    expect(find.byKey(const Key('tools.casebook')), findsOne);
    expect(find.text('Ekspert ish daftari'), findsWidgets);
    await tester.tap(find.byKey(const Key('tools.casebook')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('casebook.empty')), findsOne);
    expect(find.text('Daftaringiz bo‘sh'), findsOne);
    expect(find.byKey(const Key('casebook.privacy')), findsOne);
    expect(find.textContaining('Faqat shu qurilmada saqlanadi'), findsOne);
    // Bo‘sh daftarda tozalash menyusi yo‘q.
    expect(find.byKey(const Key('casebook.menu')), findsNothing);
  });

  testWidgets('yozuv yaratish, qayta ochish, tozalash (qurilmada)', (
    tester,
  ) async {
    final store = InMemoryCasebookStore();
    await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz'),
      initialLocation: Routes.casebook,
      overrides: [...overrides, casebookStoreProvider.overrideWithValue(store)],
    );
    await tester.tap(find.byKey(const Key('casebook.new')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('casebook.field.title')),
      'Etanol ishi',
    );
    await tester.enterText(
      find.byKey(const Key('casebook.field.caseRef')),
      'N-12',
    );
    await tester.enterText(
      find.byKey(const Key('casebook.field.body')),
      'Qon namunasi, HS-GC-FID.',
    );
    await tester.ensureVisible(find.byKey(const Key('casebook.save')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('casebook.save')));
    await tester.pumpAndSettle();
    expect(find.text('Shu qurilmada saqlandi'), findsOne);
    expect(store.load().single.title, 'Etanol ishi');
    expect(store.load().single.caseRef, 'N-12');

    // Orqaga — ro‘yxatda yozuv ko‘rinadi.
    await _back(tester);
    await tester.pumpAndSettle();
    expect(find.text('Etanol ishi'), findsOne);
    expect(find.textContaining('N-12'), findsOne);

    // Qayta ochilganda maydonlar tiklanadi.
    await tester.tap(find.text('Etanol ishi'));
    await tester.pumpAndSettle();
    expect(find.text('Qon namunasi, HS-GC-FID.'), findsOne);
    await _back(tester);
    await tester.pumpAndSettle();

    // Butun daftarni tozalash.
    await tester.tap(find.byKey(const Key('casebook.menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('casebook.clearAll')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('casebook.clearConfirm')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('casebook.empty')), findsOne);
    expect(store.load(), isEmpty);
  });

  testWidgets('orqaga qaytganda o‘zgarishlar avtomatik saqlanadi', (
    tester,
  ) async {
    final store = InMemoryCasebookStore();
    await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz'),
      initialLocation: Routes.casebook,
      overrides: [...overrides, casebookStoreProvider.overrideWithValue(store)],
    );
    await tester.tap(find.byKey(const Key('casebook.new')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('casebook.field.title')),
      'Qoralama',
    );
    await _back(tester);
    await tester.pumpAndSettle();
    expect(store.load().single.title, 'Qoralama');
  });

  testWidgets(
    'yo‘riqnoma cheklovini daftarga qo‘shish: manba va joyi bilan; eksport',
    (tester) async {
      final store = InMemoryCasebookStore();
      final share = _FakeShare();
      await pumpApp(
        tester,
        settings: completedSettings(lang: 'uz'),
        initialLocation: Routes.guideline('gl.test'),
        overrides: [
          ...overrides,
          casebookStoreProvider.overrideWithValue(store),
          shareServiceProvider.overrideWithValue(share),
        ],
      );
      // Faqat cheklov bo‘limida tugma bor (asos bo‘limida yo‘q).
      expect(find.byKey(const Key('guideline.addToCasebook.0')), findsNothing);
      final add = find.byKey(const Key('guideline.addToCasebook.1'));
      await tester.ensureVisible(add);
      await tester.pumpAndSettle();
      await tester.tap(add);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('casebook.choose.new')));
      await tester.pumpAndSettle();

      final saved = store.load().single;
      expect(saved.title, 'Sinov kartasi');
      final block = saved.blocks.single;
      expect(block.kind, CasebookBlockKind.limitation);
      expect(block.originTitle, 'Sinov kartasi');
      expect(block.sectionTitle, 'Cheklovlar');
      expect(block.text, 'Sinov cheklovi matni [1].');
      expect(block.citations.single.pages, '10-29');

      // Snackbar «Ochish» orqali daftar yozuviga o‘tiladi.
      await tester.tap(find.text('Ochish'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('casebook.block.0')), findsOne);
      expect(find.textContaining('Bo‘lim: Cheklovlar'), findsOne);
      expect(find.textContaining('Manba: Sinov kartasi'), findsOne);
      expect(find.textContaining('[1] Author A'), findsOne);

      // Ulashish: ogohlantirish + iqtibos + manba joyi.
      await tester.tap(find.byKey(const Key('casebook.share')));
      await tester.pumpAndSettle();
      final text = share.texts.single;
      expect(text, contains('ekspert xulosasi EMAS'));
      expect(text, contains('Sinov cheklovi matni [1].'));
      expect(text, contains('Bo‘lim: Cheklovlar'));
      expect(text, contains('[1] Author A'));
      expect(text, contains('10.0000/test'));

      // Blokni olib tashlash.
      await tester.ensureVisible(
        find.byKey(const Key('casebook.block.remove')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('casebook.block.remove')));
      await tester.pumpAndSettle();
      expect(store.load().single.blocks, isEmpty);
      expect(find.byKey(const Key('casebook.blocksEmpty')), findsOne);
    },
  );

  testWidgets('yozuv ichidan blok tanlash va ilova obyektini bog‘lash', (
    tester,
  ) async {
    final store = InMemoryCasebookStore();
    await pumpApp(
      tester,
      settings: completedSettings(lang: 'en'),
      initialLocation: Routes.casebookEntry('new'),
      overrides: [...overrides, casebookStoreProvider.overrideWithValue(store)],
    );
    await tester.enterText(
      find.byKey(const Key('casebook.field.title')),
      'Case X',
    );
    // Fokus maydonda qolsa, kursor ko‘rinishi sahifani qaytarib yuboradi.
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    // Blok tanlash.
    await tester.ensureVisible(find.byKey(const Key('casebook.addBlock')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('casebook.addBlock')));
    await tester.pumpAndSettle();
    // Faqat cheklov bo‘limi ro‘yxatda (asos bo‘limi emas).
    expect(
      find.byKey(const Key('casebook.pick.gl.test.limitations')),
      findsOne,
    );
    expect(find.byKey(const Key('casebook.pick.gl.test.basis')), findsNothing);
    await tester.tap(
      find.byKey(const Key('casebook.pick.gl.test.limitations')),
    );
    await tester.pumpAndSettle();
    expect(store.load().single.title, 'Case X');
    expect(store.load().single.blocks.single.text, 'Test limitation text [1].');
    expect(find.byKey(const Key('casebook.block.0')), findsOne);

    // Obyektni bog‘lash (lokal qidiruv).
    await tester.ensureVisible(find.byKey(const Key('casebook.addLink')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('casebook.addLink')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('casebook.linkSearch')),
      'Widmark',
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('casebook.linkResult.tool.tox.widmark')),
      findsOne,
    );
    await tester.tap(
      find.byKey(const Key('casebook.linkResult.tool.tox.widmark')),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('casebook.link.tool.tox.widmark')), findsOne);
    await tester.ensureVisible(find.byKey(const Key('casebook.save')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('casebook.save')));
    await tester.pumpAndSettle();
    expect(store.load().single.links.single.id, 'tool.tox.widmark');
  });

  testWidgets('yozuvni o‘chirish', (tester) async {
    final store = InMemoryCasebookStore();
    final c = await pumpApp(
      tester,
      settings: completedSettings(lang: 'ru'),
      initialLocation: Routes.casebook,
      overrides: [...overrides, casebookStoreProvider.overrideWithValue(store)],
    );
    final id = await c.read(casebookProvider.notifier).create(title: 'Удалить');
    await tester.pumpAndSettle();
    expect(find.text('Удалить'), findsOne);
    await tester.tap(find.byKey(Key('casebook.entry.$id')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('casebook.delete')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('casebook.deleteConfirm')));
    await tester.pumpAndSettle();
    expect(store.load(), isEmpty);
    expect(find.byKey(const Key('casebook.empty')), findsOne);
  });

  testWidgets('320 dp ekran, katta shrift: toshib ketmaydi', (tester) async {
    final store = InMemoryCasebookStore();
    final c = await pumpApp(
      tester,
      settings: completedSettings(lang: 'ru'),
      initialLocation: Routes.casebook,
      size: const Size(320, 640),
      textScale: 1.6,
      overrides: [...overrides, casebookStoreProvider.overrideWithValue(store)],
    );
    final id = await c
        .read(casebookProvider.notifier)
        .create(
          title: 'Очень длинное название записи рабочего журнала эксперта',
        );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.byKey(Key('casebook.entry.$id')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('casebook.entry.$id')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
