// REAL-ILOVA QA — Og‘zaki imtihon (bilet): MUTAXASSIS/USTOZ qo‘lida va TALABA
// uchun yopiqligi. Haqiqiy ilova (`bootstrap()`), haqiqiy savollar paketi,
// Linux desktop dvigateli, akkaunt MOCK, tarmoq o‘chirilgan.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/l10n/generated/app_localizations.dart';
import 'package:forensic_expert/domain/professional/professional_models.dart';
import 'package:forensic_expert/features/professional/professional_strings.dart';
import 'package:integration_test/integration_test.dart';

import 'qa/harness.dart';
import 'qa/qa_env.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('QA real app — SPE usuli (mutaxassis)', (tester) async {
    final net = NoNetworkOverrides();
    HttpOverrides.global = net;
    final l = lookupAppLocalizations(const Locale('uz'));
    final qa = await launchRealApp(tester, role: 'spe');

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
      await mockSignIn(qa, tester, 'qa.spe@example.test');
      goTo(tester, Routes.home);
      await qa.settle(maxMs: 8000);
      goTo(tester, Routes.knowledgeEntry('method-spe'));
      await qa.settle(maxMs: 6000);
      expect(find.byKey(const Key('method.spe')), findsOneWidget);
    });

    await qa.step('Usul sahifasi: sxema izohi va 6 qadam', (s) async {
      await qa.scrollUntil(find.byKey(const Key('method.spe.note')));
      qa.expectText('Sxema (original chizma)', s);
      qa.expectText('Kondisionlash:', s);
      await qa.scrollUntil(
        find.textContaining('Ekstraktni tahlilga tayyorlash:'),
      );
      qa.expectText('Ekstraktni tahlilga tayyorlash:', s);
    });

    await qa.step('Usul sahifasi: manbalar (Restek, LCGC, PubMed)', (s) async {
      await qa.scrollUntil(find.byKey(const Key('method.spe.source')));
      qa.expectText('Restek', s);
      qa.expectText('LCGC', s);
      qa.expectText('Walker V.', s);
    });

    await qa.step('Qurilma kartochkasi ochiladi (O‘zbekiston bloki)', (
      s,
    ) async {
      await qa.tapFinder(find.byKey(const Key('method.spe.device')));
      await qa.settle(maxMs: 4000);
      qa.expectText('Qattiq fazali ekstraksiya (SPE) qurilmasi', s);
      await qa.scrollUntil(find.byKey(const Key('equipment.national')));
      qa.expectText('Sud-kimyo bo‘limiga', s);
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
