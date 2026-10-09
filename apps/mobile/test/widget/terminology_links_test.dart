import 'dart:convert';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/glossary.dart';
import 'package:forensic_expert/app/guidelines.dart';
import 'package:forensic_expert/app/routes.dart';

import '../helpers/pump_app.dart';

/// Yo‘riqnoma kartasidagi kanonik qisqartmalar — bosilganda lug‘atdagi
/// qisqa izoh varag‘i (uch tilda, machine_draft belgisi bilan).
final _bundle = jsonEncode({
  'schema': 'fe-guidelines/1',
  'cards': [
    {
      'id': 'gl.chem.terms',
      'discipline_codes': ['forensic_chemistry'],
      'status': 'NEEDS_REVIEW',
      'title': {'uz': 'Sinov', 'ru': 'Тест', 'en': 'Test'},
      'translation_status': {'uz': 'AUTHORED', 'ru': 'DRAFT', 'en': 'DRAFT'},
      'sections': [
        {
          'key': 'basis',
          'title': {'uz': 'Asos', 'ru': 'Основа', 'en': 'Basis'},
          'body': {
            'uz':
                'Natija TLC dan keyin GC-MS bilan tasdiqlanadi; GC-MS/MS ham.',
            'ru': 'Результат TLC подтверждают методом GC-MS.',
            'en': 'A TLC result is confirmed by GC-MS.',
          },
          'citations': <String>[],
        },
      ],
    },
  ],
  'references': <Object>[],
});

void main() {
  for (final (lang, header, needle) in const [
    ('uz', 'Qisqa izoh', 'Gaz xromatografiyasi'),
    ('ru', 'Краткое пояснение', 'Газовая хроматография'),
    ('en', 'Short explanation', 'Gas chromatography'),
  ]) {
    testWidgets('$lang: kartadagi GC-MS → qisqa izoh varag‘i (320 dp)', (
      tester,
    ) async {
      await pumpApp(
        tester,
        size: const Size(320, 640),
        settings: completedSettings(lang: lang),
        initialLocation: Routes.guideline('gl.chem.terms'),
        overrides: [
          guidelineBundleLoaderProvider.overrideWithValue(() async => _bundle),
          abbreviationNotesLoaderProvider.overrideWithValue(
            () async =>
                File('assets/content/terminology/abbreviation_glossary.json')
                    .readAsStringSync(),
          ),
        ],
      );
      final body = find.byKey(const Key('guideline.body.0'));
      expect(body, findsOne);
      final links = <String, TapGestureRecognizer>{};
      final rich = tester.widget<SelectableText>(
        find.descendant(of: body, matching: find.byType(SelectableText)),
      );
      rich.textSpan!.visitChildren((s) {
        if (s is TextSpan && s.recognizer is TapGestureRecognizer) {
          links[s.text!] = s.recognizer! as TapGestureRecognizer;
        }
        return true;
      });
      // GC-MS/MS havola emas (izohi yo‘q); TLC va GC-MS — havola.
      expect(links.keys.toSet(), {'TLC', 'GC-MS'});
      links['GC-MS']!.onTap!();
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('glossary.sheet')), findsOne);
      expect(find.text(header), findsOne);
      expect(find.textContaining(needle), findsWidgets);
      expect(find.byKey(const Key('glossary.badge.machineDraft')), findsOne);
      expect(tester.takeException(), isNull);
    });
  }
}
