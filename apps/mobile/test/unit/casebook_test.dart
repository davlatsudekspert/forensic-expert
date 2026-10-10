import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/casebook.dart';
import 'package:forensic_expert/data/local/casebook_store.dart';
import 'package:forensic_expert/domain/casebook/casebook_models.dart';
import 'package:forensic_expert/domain/guidelines/guideline_models.dart';
import 'package:forensic_expert/features/casebook/presentation/casebook_blocks.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// TEST kontenti — haqiqiy ilmiy da’vo emas (faqat tuzilma tekshiruvi).
final _bundle = GuidelineBundle.fromJson(
  jsonDecode(
    jsonEncode({
      'schema': 'fe-guidelines/1',
      'cards': [
        {
          'id': 'gl.test',
          'discipline_codes': ['forensic_chemistry'],
          'title': {'uz': 'Sinov kartasi', 'en': 'Test card'},
          'sections': [
            {
              'key': 'basis',
              'title': {'uz': 'Asos'},
              'body': {'uz': 'Asos matni.'},
              'citations': ['r1'],
            },
            {
              'key': 'limitations',
              'title': {'uz': 'Cheklovlar', 'en': 'Limitations'},
              'body': {
                'uz': 'Sinov cheklovi [r1] va [r2].',
                'en': 'Test limitation [r1] and [r2].',
              },
              'citations': ['r1', 'r2', 'yoq'],
            },
          ],
        },
      ],
      'references': [
        {
          'key': 'r1',
          'authors': ['Author A'],
          'title': 'First reference',
          'journal': 'Test Journal',
          'year': 2000,
          'pages': '10-29',
          'doi': '10.0000/test',
        },
        {
          'key': 'r2',
          'authors': ['Author B'],
          'title': 'Second',
          'year': 2001,
        },
      ],
    }),
  ) as Map<String, Object?>,
);

CasebookExportLabels get _labels => CasebookExportLabels(
  disclaimer: 'NOT AN EXPERT OPINION',
  caseRef: 'Case',
  date: 'Date',
  linksTitle: 'Links',
  blocksTitle: 'Statements',
  sourceLabel: 'Source',
  locationLabel: 'Section',
  pagesLabel: 'pp.',
  sourcesTitle: 'Sources',
  aiUnverified: 'AI-generated — unverified',
  untitled: 'Untitled',
  footer: 'FOOTER',
  dateText: (d) => '${d.year}-${d.month}-${d.day}',
);

void main() {
  final t0 = DateTime.utc(2026, 10, 10);

  CasebookEntry entry({List<CasebookBlock> blocks = const []}) => CasebookEntry(
    id: 'e1',
    title: 'Ish A',
    caseRef: 'N-12',
    date: DateTime(2026, 10, 9),
    body: 'Matn',
    links: const [
      CasebookLink(
        kind: CasebookLinkKind.tool,
        id: 'tool.tox.widmark',
        label: 'Widmark',
      ),
    ],
    blocks: blocks,
    createdAt: t0,
    updatedAt: t0,
  );

  test('kodek: aylanma saqlash va buzilgan ma’lumotga chidamlilik', () {
    final block = casebookBlockFromSection(
      bundle: _bundle,
      card: _bundle.cards.single,
      section: _bundle.cards.single.sections[1],
      lang: 'uz',
      id: 'b1',
      now: t0,
    );
    final raw = CasebookCodec.encode([
      entry(blocks: [block]),
    ]);
    final back = CasebookCodec.decode(raw).single;
    expect(back.title, 'Ish A');
    expect(back.caseRef, 'N-12');
    expect(back.links.single.kind, CasebookLinkKind.tool);
    expect(back.blocks.single.citations.length, 2);
    expect(back.blocks.single.sectionTitle, 'Cheklovlar');
    expect(CasebookCodec.decode('not json'), isEmpty);
    expect(CasebookCodec.decode(null), isEmpty);
    expect(
      CasebookCodec.decode('{"entries":[1,{"id":""},{"id":"x"}]}').length,
      1,
    );
  });

  test('cheklov bloki: manba, sahifa va joyi ko‘chiriladi; noma’lum manba to‘qilmaydi', () {
    final card = _bundle.cards.single;
    final b = casebookBlockFromSection(
      bundle: _bundle,
      card: card,
      section: card.sections[1],
      lang: 'en',
      id: 'b1',
      now: t0,
    );
    expect(b.kind, CasebookBlockKind.limitation);
    expect(b.text, 'Test limitation [1] and [2].');
    expect(b.originId, 'gl.test');
    expect(b.originTitle, 'Test card');
    expect(b.sectionTitle, 'Limitations');
    // «yoq» kaliti paketda yo‘q — tashlab ketiladi.
    expect(b.citations.length, 2);
    expect(b.citations.first.pages, '10-29');
    expect(b.citations.first.link, 'https://doi.org/10.0000/test');
    expect(b.isAiUnverified, isFalse);
  });

  test('AI bloki doim «tekshirilmagan»', () {
    final b = casebookBlockFromAi(
      text: ' Javob ',
      sourceIds: ['s1', 's1', 's2'],
      lang: 'uz',
      id: 'a1',
    );
    expect(b.kind, CasebookBlockKind.ai);
    expect(b.isAiUnverified, isTrue);
    expect(b.text, 'Javob');
    expect(b.citations.map((c) => c.text), ['s1', 's2']);
  });

  test('eksport: ogohlantirish, iqtibos, manba joyi, AI belgisi', () {
    final card = _bundle.cards.single;
    final lim = casebookBlockFromSection(
      bundle: _bundle,
      card: card,
      section: card.sections[1],
      lang: 'en',
      id: 'b1',
      now: t0,
    );
    final ai = casebookBlockFromAi(
      text: 'AI text',
      sourceIds: ['src.1'],
      lang: 'en',
      id: 'a1',
    );
    final text = CasebookExporter.text(entry(blocks: [lim, ai]), _labels);
    expect(text, startsWith('Ish A'));
    expect(text, contains('Case: N-12'));
    expect(text, contains('NOT AN EXPERT OPINION'));
    expect(text, contains('• Widmark'));
    expect(text, contains('1. Test limitation [1] and [2].'));
    expect(text, contains('Source: Test card; Section: Limitations'));
    expect(text, contains('[1] Author A'));
    expect(text, contains('10.0000/test'));
    expect(text, contains('2. AI text'));
    expect(text, contains('⚠ AI-generated — unverified'));
    expect(text, contains('[1] src.1'));
    expect(text.trimRight(), endsWith('FOOTER'));
    // Disclaimer matn boshida (sarlavhadan keyin), blokdan oldin.
    expect(text.indexOf('NOT AN EXPERT'), lessThan(text.indexOf('1. Test')));
  });

  test('eksport: sarlavhasiz yozuv va bo‘sh daftar', () {
    final e = CasebookEntry(
      id: 'x',
      title: '',
      date: DateTime(2026, 1, 2),
      createdAt: t0,
      updatedAt: t0,
    );
    final text = CasebookExporter.text(e, _labels);
    expect(text, startsWith('Untitled'));
    expect(text, contains('NOT AN EXPERT OPINION'));
    expect(text, isNot(contains('Statements')));
  });

  test('SharedPreferences ombori: saqlash, qayta yuklash, tozalash', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = SharedPrefsCasebookStore(prefs);
    expect(store.load(), isEmpty);
    await store.save([entry()]);
    expect(SharedPrefsCasebookStore(prefs).load().single.id, 'e1');
    await store.clear();
    expect(store.load(), isEmpty);
    expect(prefs.getKeys().where((k) => k.contains('casebook')), isEmpty);
  });

  test(
    'kontroller: yaratish, blok, o‘chirish va butun daftarni tozalash',
    () async {
      final store = InMemoryCasebookStore();
      final c = ProviderContainer(
        overrides: [casebookStoreProvider.overrideWithValue(store)],
      );
      addTearDown(c.dispose);
      final ctrl = c.read(casebookProvider.notifier);
      final id = await ctrl.create(title: ' Birinchi ', caseRef: 'A-1');
      final id2 = await ctrl.create(title: 'Ikkinchi');
      expect(c.read(casebookProvider).length, 2);
      expect(store.load().length, 2);
      expect(ctrl.byId(id)!.title, 'Birinchi');

      await ctrl.addBlock(
        id,
        casebookBlockFromAi(text: 'x', sourceIds: [], lang: 'uz', id: 'b1'),
      );
      expect(ctrl.byId(id)!.blocks.single.isAiUnverified, isTrue);
      // Yangilangan yozuv ro‘yxat boshiga chiqadi.
      expect(c.read(casebookProvider).first.id, id);
      await ctrl.removeBlock(id, 'b1');
      expect(ctrl.byId(id)!.blocks, isEmpty);

      await ctrl.delete(id2);
      expect(store.load().map((e) => e.id), [id]);

      await ctrl.clearAll();
      expect(c.read(casebookProvider), isEmpty);
      expect(store.load(), isEmpty);
    },
  );

  test('kontroller ombordan o‘qiydi (qayta ishga tushirishdan keyin)', () {
    final store = InMemoryCasebookStore([entry()]);
    final c = ProviderContainer(
      overrides: [casebookStoreProvider.overrideWithValue(store)],
    );
    addTearDown(c.dispose);
    expect(c.read(casebookProvider).single.title, 'Ish A');
  });
}
