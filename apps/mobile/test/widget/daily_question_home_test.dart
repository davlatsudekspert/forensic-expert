import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/class_quiz.dart' show ClassQuizBank;
import 'package:forensic_expert/core/settings/app_settings.dart';
import 'package:forensic_expert/domain/professional/professional_models.dart';
import 'package:forensic_expert/features/home/daily_question.dart';
import 'package:forensic_expert/features/home/workbench.dart';

import '../helpers/home_desk_world.dart';

/// Home «Bugungi savol»: standart — sud tibbiyoti savoli (sinf testlari
/// banki, mavzu nomi bilan); sud-kimyo mutaxassisida — toksikologiya.
void main() {
  Finder k(String key) => find.byKey(Key(key));

  final bank = ClassQuizBank.parse(
    File('assets/content/class_quiz/class_quiz_bank.json').readAsStringSync(),
  );
  final catalog = deskCatalog([
    for (var i = 1; i <= 4; i++) deskQuestionItem(i),
  ]);
  // Asosiy yo‘nalish kuni (ozchilik kuni emas).
  var day = DateTime(2026, 11, 2, 9);
  while (dayNumberOf(day) % dailyQuestionCycle == dailyQuestionMinorityDay) {
    day = day.add(const Duration(days: 1));
  }

  Future<String> sourceOf(WidgetTester t) async {
    await t.scrollUntilVisible(
      k('desk.dailyQuestion'),
      200,
      scrollable: find.byType(Scrollable).first,
      maxScrolls: 80,
    );
    await t.pumpAndSettle();
    return t.widget<Text>(k('desk.dailyQuestion.source')).data!;
  }

  for (final lang in ['uz', 'ru', 'en']) {
    testWidgets('talaba ($lang): standart — sud tibbiyoti savoli', (t) async {
      await pumpHome(
        t,
        mode: UserMode.student,
        lang: lang,
        catalog: catalog,
        quizBank: bank,
        now: day,
      );
      final expected = pickDailyQuestion(
        catalog: catalog,
        bank: bank,
        lang: lang,
        today: day,
      )!;
      expect(expected.item.deckId, startsWith(dailyBankDeckPrefix));
      final src = await sourceOf(t);
      expect(src, contains(expected.item.citations.single.title));
      expect(src, isNot(contains('Toksikologik kimyo (kitob)')));
      expect(
        find.text(expected.stem.resolve(lang)),
        findsOneWidget,
        reason: lang,
      );
      expect(t.takeException(), isNull);
    });
  }

  testWidgets('mutaxassis, mutaxassislik noma’lum — sud tibbiyoti', (t) async {
    await pumpHome(t, catalog: catalog, quizBank: bank, now: day);
    expect(await sourceOf(t), isNot(contains('Toksikologik kimyo (kitob)')));
  });

  testWidgets('sud-kimyo mutaxassisi — toksikologiya savoli', (t) async {
    await pumpHome(
      t,
      specialty: Specialty.forensicChemistry,
      catalog: catalog,
      quizBank: bank,
      now: day,
    );
    expect(await sourceOf(t), contains('Toksikologik kimyo (kitob)'));
  });
}
