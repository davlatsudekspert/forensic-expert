import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/dna.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/domain/dna/dna.dart';

import '../helpers/pump_app.dart';

/// DNK bo‘limi: manbasiz bayon/mavzu ko‘rsatilmaydi; hub → mavzu → savollar;
/// ru — «tarjima kutilmoqda»; paket yo‘q — Home kartasi ham yo‘q.
const _fixture = {
  'source_lang': 'uz',
  'sources': [
    {
      'id': 'isfg2006',
      'authors': 'Gill P. va boshq.',
      'title': 'DNA commission of the ISFG: mixture interpretation',
      'year': 2006,
      'doi': '10.1016/j.forsciint.2006.04.009',
    },
  ],
  'topics': [
    {
      'id': 'interpretation',
      'title': 'Aralash namunalarni talqin qilish',
      'statements': [
        {
          'uz': 'Aralash namunada ehtimollik nisbati (LR) ishlatiladi.',
          'quote': 'The likelihood ratio is the preferred approach.',
          'source_id': 'isfg2006',
          'locator': 'Recommendation 1',
        },
        {
          // Manbadagi joyi yo‘q — tashlanadi.
          'uz': 'Joyi ko‘rsatilmagan gap.',
          'source_id': 'isfg2006',
          'locator': '',
        },
      ],
    },
    {
      // Faqat manbasiz gap — mavzu ham ko‘rsatilmaydi.
      'id': 'empty',
      'title': 'Bo‘sh mavzu',
      'statements': [
        {'uz': 'Manbasiz.', 'source_id': 'missing', 'locator': 'x'},
      ],
    },
  ],
  'court_questions': [
    {
      'q': 'Namuna sudlanuvchiga tegishlimi?',
      'good_answer_uz': 'Ekspert ehtimollik nisbatini aytadi.',
      'boundary_uz': 'Aybdorlik haqida xulosa bermaydi.',
      'source_id': 'isfg2006',
      'locator': 'Recommendation 1',
    },
  ],
};

void main() {
  test('manbasiz bayon va mavzu tashlanadi', () {
    final b = DnaBundle.fromJson(
      (jsonDecode(jsonEncode(_fixture)) as Map).cast<String, Object?>(),
    );
    expect(b.topics.map((t) => t.id), ['interpretation']);
    expect(b.topics.single.statements, hasLength(1));
    expect(b.court, hasLength(1));
  });

  final overrides = [
    dnaLoaderProvider.overrideWithValue(() async => jsonEncode(_fixture)),
  ];

  testWidgets('hub → mavzu: bayon, manba va asl matn', (t) async {
    await pumpApp(
      t,
      settings: completedSettings(lang: 'uz'),
      initialLocation: Routes.dna,
      overrides: overrides,
    );
    await t.pumpAndSettle();
    expect(find.byKey(const Key('dna.topic.empty')), findsNothing);
    await t.tap(find.byKey(const Key('dna.topic.interpretation')));
    await t.pumpAndSettle();
    expect(
      find.byKey(const Key('dna.statement.interpretation.0')),
      findsOneWidget,
    );
    expect(find.textContaining('Recommendation 1'), findsOneWidget);
    expect(find.byKey(const Key('dna.translationPending')), findsNothing);
  });

  testWidgets('sudda so‘roq: javob va chegara; ru — tarjima kutilmoqda', (
    t,
  ) async {
    await pumpApp(
      t,
      settings: completedSettings(lang: 'ru'),
      initialLocation: Routes.dnaCourt,
      overrides: overrides,
    );
    await t.pumpAndSettle();
    expect(find.byKey(const Key('dna.q.0')), findsOneWidget);
    expect(find.text('Aybdorlik haqida xulosa bermaydi.'), findsOneWidget);
    expect(find.byKey(const Key('dna.translationPending')), findsOneWidget);
  });

  testWidgets('paket yo‘q — bosh sahifada DNK kartasi yo‘q', (t) async {
    await pumpApp(
      t,
      settings: completedSettings(lang: 'uz'),
      overrides: [
        dnaLoaderProvider.overrideWithValue(() async => throw Exception()),
      ],
    );
    await t.pumpAndSettle();
    expect(find.byKey(const Key('desk.dna')), findsNothing);
  });
}
