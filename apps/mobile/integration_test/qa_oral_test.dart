// REAL-ILOVA QA — Og‘zaki imtihon (bilet): MUTAXASSIS/USTOZ qo‘lida va TALABA
// uchun yopiqligi. Haqiqiy ilova (`bootstrap()`), haqiqiy savollar paketi,
// Linux desktop dvigateli, akkaunt MOCK, tarmoq o‘chirilgan.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/assessment.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/l10n/generated/app_localizations.dart';
import 'package:forensic_expert/domain/professional/professional_models.dart';
import 'package:forensic_expert/features/professional/professional_strings.dart';
import 'package:integration_test/integration_test.dart';

import 'qa/harness.dart';
import 'qa/qa_env.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('QA real app — ORAL EXAM (mutaxassis)', (tester) async {
    final net = NoNetworkOverrides();
    HttpOverrides.global = net;
    final l = lookupAppLocalizations(const Locale('uz'));
    final qa = await launchRealApp(tester, role: 'oral');

    await qa.step('Onboarding → Mutaxassis rejimi', (s) async {
      await qa.tapText('O‘zbekcha');
      await qa.tapText(l.actionContinue);
      await qa.tapText(l.disclaimerAccept);
      await qa.tapText(l.modeProfessional);
      await qa.tapText(l.modeRoleExpand);
      await qa.tapText(
        l.professionalRoleLabel(ProfessionalRole.forensicToxicologist),
      );
      await qa.tapText(l.actionContinue);
      await qa.tapText('Hisob yaratish / Kirish');
      qa.expectText(l.emailCodeSend, s);
    }, shot: false);

    await qa.step('MOCK OTP bilan kirish', (s) async {
      await mockSignIn(qa, tester, 'qa.oral@example.test');
      goTo(tester, Routes.assessmentSpecialty('sud_kimyo'));
      await qa.settle();
      qa.expectText(l.oralExamStart, s);
    });

    await qa.step('«Og‘zaki imtihon (bilet)» ochiladi', (s) async {
      await qa.tapFinder(find.byKey(const Key('assessment.oralExam')));
      qa.expectText(l.oralExamNext, s);
      qa.expectText('Ishlatilgan savollar: 0 /', s);
    });

    await qa.step(
      'Bilet chiqadi: 5 savol, ball qo‘yilmagan, saqlab bo‘lmaydi',
      (s) async {
        await qa.tapFinder(find.byKey(const Key('oral.draw')));
        qa.expectText(l.oralExamTicketNo(1), s);
        qa.expectText(l.oralExamTotal(0), s);
        expect(find.byKey(const Key('oral.q.4')), findsOneWidget);
        final save = tester.widget<FilledButton>(
          find.byKey(const Key('oral.save')),
        );
        expect(save.onPressed, isNull);
      },
    );

    await qa.step('Slayder bilan 5 savolga ball qo‘yiladi', (s) async {
      await qa.tapFinder(find.byKey(const Key('oral.name')));
      await qa.enterText(find.byKey(const Key('oral.name')), 'QA Talaba');
      for (var i = 0; i < 5; i++) {
        final f = find.byKey(Key('oral.slider.$i'));
        await qa.tapFinder(f);
      }
      final st = containerOf(tester).read(oralExamProvider);
      expect(st.allScored, isTrue, reason: 'hamma savolga ball qo‘yildi');
      s.notes.add('Jami: ${st.total} / 100');
    });

    await qa.step('Natija saqlanadi, tarixda ko‘rinadi', (s) async {
      await qa.tapFinder(find.byKey(const Key('oral.save')));
      qa.expectText('Natija saqlandi:', s);
      qa.expectText('QA Talaba', s);
      expect(find.byKey(const Key('oral.draw')), findsOneWidget);
    });

    await qa.step('Keyingi talaba: boshqa bilet (takrorlanmaydi)', (s) async {
      final first = containerOf(tester)
          .read(oralExamProvider)
          .data
          .usedFor('sud_kimyo', 'c23')
          .toSet();
      await qa.tapFinder(find.byKey(const Key('oral.draw')));
      final st = containerOf(tester).read(oralExamProvider);
      qa.expectText(l.oralExamTicketNo(2), s);
      expect(
        st.questionIds.toSet().intersection(first),
        isEmpty,
        reason: 'ikkinchi bilet birinchisi bilan takrorlanmaydi',
      );
      expect(first.length, 5);
      expect(
        st.data.usedFor('sud_kimyo', 'c23').length,
        10,
        reason: 'ikkinchi bilet 5 ta yangi savol',
      );
    });

    await qa.step('Javob kaliti ochiladi (ustoz uchun)', (s) async {
      await qa.tapFinder(find.byKey(const Key('oral.key.0')));
      final soon = find.byKey(const Key('assessment.answerSoon'));
      final ans = find.byKey(const Key('assessment.answer'));
      expect(
        soon.evaluate().isNotEmpty || ans.evaluate().isNotEmpty,
        isTrue,
        reason: 'javob kaliti yoki «tez kunda»',
      );
    });

    await qa.step('Tarmoq o‘chiq: oflayn ishladi', (s) async {
      s.notes.add('Bloklangan HTTP urinishlari: ${net.attempts}');
    }, shot: false);

    qa.restoreErrorHandler();
    qa.writeResults();
    printSummary(qa);
    HttpOverrides.global = null;
  });
}
