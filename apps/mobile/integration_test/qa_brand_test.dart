// REAL-ILOVA QA — yangi brend (logotip) ko‘rinishi.
//
// Haqiqiy ilova (`bootstrap()`), haqiqiy router, Linux desktop dvigateli.
// Akkaunt MOCK, admin huquqi — soxta «server» javobi
// (`QaAccountService(admin: true)`), tarmoq o‘chirilgan.
//
// Har ekran: Yorug‘ va Qorong‘i × 390 dp va 320 dp, DPR 2 (telefonda
// ko‘rish uchun tiniq). Ekranlar: til (birinchi ishga tushirish, katta
// lockup), kirish (email kod), Asosiy sarlavha (talaba va mutaxassis),
// Admin panel sarlavhasi.
//
// Ishga tushirish: `tool/qa_real_app.sh brand`
// (QA_OUT=docs/brand/logo_preview_20261009/app).
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/account.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/l10n/generated/app_localizations.dart';
import 'package:forensic_expert/core/settings/app_settings.dart';
import 'package:forensic_expert/core/settings/settings_controller.dart';
import 'package:forensic_expert/core/widgets/brand_mark.dart';
import 'package:integration_test/integration_test.dart';

import 'qa/harness.dart';
import 'qa/qa_env.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('QA real app — BRAND', (tester) async {
    HttpOverrides.global = NoNetworkOverrides();
    final l = lookupAppLocalizations(const Locale('uz'));
    final qa = await launchRealApp(
      tester,
      role: 'brand',
      overrides: [
        accountServiceProvider.overrideWithValue(QaAccountService(admin: true)),
      ],
    );
    SettingsController settings() =>
        containerOf(tester).read(settingsControllerProvider.notifier);

    const dpr = 2.0;
    Future<void> size(Size s) async {
      tester.view.devicePixelRatio = dpr;
      tester.view.physicalSize = s * dpr;
      await qa.settle();
    }

    /// Ildiz qatlam PNG’i DPR 2 da (harness’dagi DPR 1 skrinshotdan tiniq).
    Future<void> shot(String name) async {
      // Emblema asseti dekodlanib bo‘lsin (birinchi kadrda bo‘sh qolmasin).
      await tester.runAsync(() async {
        for (final e in find.byType(Image).evaluate()) {
          await precacheImage((e.widget as Image).image, e);
        }
      });
      await qa.settle();
      final view = tester.binding.renderViews.first;
      final layer = view.debugLayer! as OffsetLayer;
      final image = await tester.runAsync(
        // Ildiz qatlamda DPR transformi bor: chegaralar fizik pikselda.
        () => layer.toImage(Offset.zero & (view.size * dpr), pixelRatio: 1),
      );
      final bytes = await tester.runAsync(
        () => image!.toByteData(format: ui.ImageByteFormat.png),
      );
      File('${qa.outDir.path}/$name.png')
          .writeAsBytesSync(bytes!.buffer.asUint8List());
    }

    /// Joriy ekranni 4 variantda: yorug‘/qorong‘i × 390/320.
    Future<void> matrix(String id, {bool w320 = true}) async {
      for (final (mode, tag) in [
        (ThemeMode.light, 'light'),
        (ThemeMode.dark, 'dark'),
      ]) {
        await settings().setThemeMode(mode);
        for (final w in [390.0, if (w320) 320.0]) {
          await size(Size(w, w == 390 ? 844 : 640));
          await qa.scrollToTop();
          await shot('${id}_${tag}_${w.toInt()}');
        }
      }
      await settings().setThemeMode(ThemeMode.light);
      await size(const Size(390, 844));
    }

    void expectMark(QaStep s, {required String why}) {
      final marks = find.byType(BrandMark).evaluate();
      if (marks.isEmpty) {
        s.passed = false;
        s.notes.add('BrandMark yo‘q ($why)');
      }
    }

    // ------------------------------------------------ til (birinchi ekran)
    await qa.step(
      'Til ekrani: lockup (emblema + wordmark + tagline)',
      (s) async {
        expectMark(s, why: 'til ekrani');
        if (find.byType(BrandLockup).evaluate().isEmpty) {
          s.passed = false;
          s.notes.add('BrandLockup yo‘q');
        }
        await matrix('b01_language');
      },
      langCheck: false,
      shot: false,
    );

    await qa.step('Onboarding → talaba, hisobsiz', (s) async {
      await qa.tapText('O‘zbekcha');
      await qa.tapText(l.actionContinue);
      await qa.tapText(l.disclaimerAccept);
      await qa.tapText(l.modeStudent);
      await qa.tapText(l.actionContinue);
      await qa.tapText(l.accountStartNow);
      qa.expectText(l.homeGreetingStudent, s);
    }, shot: false);

    // ----------------------------------------------------- Asosiy (talaba)
    await qa.step('Asosiy sarlavha (TALABA): kichik emblema', (s) async {
      expectMark(s, why: 'home header');
      final mark = tester.widget<BrandMark>(
        find.descendant(
          of: find.byKey(const Key('home.header')),
          matching: find.byType(BrandMark),
        ),
      );
      if (BrandMark.tierFor(mark.size) != BrandTier.small) {
        s.passed = false;
        s.notes.add('Home sarlavhasida soddalashtirilgan variant emas');
      }
      await matrix('b03_home_student');
    }, shot: false);

    // ------------------------------------------------------ kirish (OTP)
    await qa.step('Kirish ekrani: lockup (taglinesiz)', (s) async {
      goTo(tester, Routes.accountEmailCode);
      await qa.settle();
      if (find.byKey(const Key('auth.brand')).evaluate().isEmpty) {
        s.passed = false;
        s.notes.add('auth.brand yo‘q');
      }
      qa.expectText(l.emailCodeSend, s);
      await matrix('b02_login');
    }, shot: false);

    await qa.step('MOCK OTP bilan kirish (admin)', (s) async {
      await mockSignIn(qa, tester, 'qa.brand.admin@example.test');
      goTo(tester, Routes.profile);
      await qa.settle();
      qa.expectText('qa.brand.admin@example.test', s);
    }, shot: false);

    // -------------------------------------------------- Asosiy (ekspert)
    await qa.step('Asosiy sarlavha (MUTAXASSIS)', (s) async {
      await settings().setUserMode(UserMode.professional);
      goTo(tester, Routes.home);
      await qa.settle();
      qa.expectText(l.homeGreetingExpert, s);
      await matrix('b04_home_expert', w320: false);
    }, shot: false);

    // --------------------------------------------------------- admin
    await qa.step('Admin panel sarlavhasi (ADMIN)', (s) async {
      goTo(tester, Routes.admin);
      await qa.settle();
      if (find.byKey(const Key('admin.brand')).evaluate().isEmpty) {
        s.passed = false;
        s.notes.add('admin.brand yo‘q');
      }
      qa.expectText(l.adminTitle, s);
      await matrix('b05_admin');
    }, shot: false);

    // ------------------------------------------ katta shrift (×2), 320 dp
    await qa.step('320 dp, shrift ×2: lockup sig‘adi', (s) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      goTo(tester, Routes.accountEmailCode);
      await qa.settle();
      await size(const Size(320, 640));
      await shot('b06_login_320_x2');
      goTo(tester, Routes.home);
      await qa.settle();
      await shot('b06_home_320_x2');
      tester.platformDispatcher.clearTextScaleFactorTestValue();
      await size(const Size(390, 844));
    }, shot: false);

    qa.restoreErrorHandler();
    qa.writeResults();
    printSummary(qa);
    HttpOverrides.global = null;
  });
}
