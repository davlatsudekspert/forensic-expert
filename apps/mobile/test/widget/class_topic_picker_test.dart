import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/class_quiz.dart';
import 'package:forensic_expert/app/router.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/l10n/generated/app_localizations.dart';
import 'package:forensic_expert/data/class_quiz/class_quiz_bank.dart';
import 'package:forensic_expert/data/class_quiz/fake_class_quiz_service.dart';
import 'package:forensic_expert/domain/class_quiz/class_quiz_models.dart';

import '../helpers/pump_app.dart';

/// Server `class_topics()` javobi (production nusxasi) bilan.
class _ServerTopicsService extends FakeClassQuizService {
  _ServerTopicsService(super.backend, this.list)
    : super(userId: 't1', demo: false);

  final List<ClassTopic> list;

  @override
  Future<ClassResult<List<ClassTopic>>> topics() async => ClassResult.ok(list);
}

/// «Test o‘tkazish»: mavzu tanlash ekrani — bitta ro‘yxat, har fakultet/fan
/// bir marta, «Boshqa mavzular» yo‘q, qidiruv maslahatida «kurs» yo‘q.
void main() {
  final raw = File(classQuizBankAsset).readAsStringSync();
  final server = [
    for (final j in jsonDecode(
      File('test/fixtures/class_topics_server.json').readAsStringSync(),
    ) as List)
      ClassTopic.fromJson((j as Map).cast<String, Object?>()),
  ];

  const expected = {
    'uz': [
      'Bioetika',
      'Davolash ishi',
      'Pediatriya',
      'Tibbiy profilaktika',
      'Stomatologiya',
      'Sud-tibbiy toksikologiya',
      'Toksikologik kimyo',
      'Apparatlar bilan ishlash',
    ],
    'ru': [
      'Биоэтика',
      'Лечебное дело',
      'Педиатрия',
      'Медико-профилактическое дело',
      'Стоматология',
      'Судебно-медицинская токсикология',
      'Токсикологическая химия',
      'Работа на приборах',
    ],
    'en': [
      'Bioethics',
      'General Medicine',
      'Paediatrics',
      'Preventive Medicine',
      'Dentistry',
      'Forensic toxicology',
      'Toxicological chemistry',
      'Working with instruments',
    ],
  };

  for (final lang in ['uz', 'ru', 'en']) {
    testWidgets('$lang: guruhlar bir martadan, «Boshqa» yo‘q', (tester) async {
      final backend = FakeClassQuizBackend(
        clock: () => DateTime(2026, 11, 7, 10),
        rng: Random(3),
        teachers: {'t1'},
        topics: const [],
      );
      final c = await pumpApp(
        tester,
        settings: completedSettings(lang: lang),
        overrides: [
          classQuizServiceProvider.overrideWithValue(
            _ServerTopicsService(backend, server),
          ),
          classQuizBankLoaderProvider.overrideWithValue(() async => raw),
          classScannerAvailableProvider.overrideWithValue(false),
          classLandscapePromptEnabledProvider.overrideWithValue(false),
        ],
      );
      c.read(routerProvider).go(Routes.classNew);
      await tester.pumpAndSettle();
      final l = lookupAppLocalizations(Locale(lang));
      for (final title in expected[lang]!) {
        expect(find.text(title), findsOneWidget, reason: title);
      }
      expect(find.text(l.classTopicGroupOther), findsNothing);
      final groups = tester
          .widgetList<ExpansionTile>(find.byType(ExpansionTile))
          .map((e) => (e.title as Text).data)
          .toList();
      expect(groups, expected[lang]);
      // Qidiruv maslahati: «kurs»/«курс»/«course» yo‘q.
      expect(l.classTopicSearchHint.toLowerCase(), isNot(contains('kurs')));
      expect(l.classTopicSearchHint.toLowerCase(), isNot(contains('курс')));
      expect(l.classTopicSearchHint.toLowerCase(), isNot(contains('course')));
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
    });
  }
}
