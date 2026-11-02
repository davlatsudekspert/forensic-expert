// REAL-ILOVA QA — TALABA: Og‘zaki imtihon (bilet) talabaga ko‘rinmaydi va
// to‘g‘ridan-to‘g‘ri havola bilan ham ochilmaydi (faqat mutaxassis bo‘limi).
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/l10n/generated/app_localizations.dart';
import 'package:integration_test/integration_test.dart';

import 'qa/harness.dart';
import 'qa/qa_env.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('QA real app — ORAL EXAM (talaba yopiq)', (tester) async {
    final net = NoNetworkOverrides();
    HttpOverrides.global = net;
    final l = lookupAppLocalizations(const Locale('uz'));
    final qa = await launchRealApp(tester, role: 'oralstudent');

    await qa.step('Onboarding → Talaba rejimi → Boshlash', (s) async {
      await qa.tapText('O‘zbekcha');
      await qa.tapText(l.actionContinue);
      await qa.tapText(l.disclaimerAccept);
      await qa.tapText(l.modeStudent);
      await qa.tapText(l.actionContinue);
      await qa.tapFinder(find.byKey(const Key('account.skip')));
      qa.expectText('Rejim: Talaba', s);
    }, shot: false);

    await qa.step('Talaba: Asosiyda «Bilim va malakani baholash» yo‘q', (
      s,
    ) async {
      qa.expectNoText(l.assessmentTitle, s);
      qa.expectNoText(l.oralExamStart, s);
    });

    await qa.step('Talaba: imtihon havolasi ochilmaydi', (s) async {
      goTo(tester, Routes.assessmentExam('sud_kimyo', 'c23'));
      await qa.settle();
      qa.expectNoText(l.oralExamNext, s);
      qa.expectNoText(l.oralExamTitle, s);
    });

    qa.restoreErrorHandler();
    qa.writeResults();
    printSummary(qa);
    HttpOverrides.global = null;
  });
}
