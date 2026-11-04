// PROMO qo‘shimcha sahnalar (REVISION 2): languages (Profil → Til: ru → en →
// uz) va future (Asosiy → «Yangi bo‘limlar»). PROMO_MODE=teacher|student,
// PROMO_NAME=<ustoz_extra|talaba_extra>.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:integration_test/integration_test.dart';

import 'promo_rec.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('promo extra', (tester) async {
    final mode = Platform.environment['PROMO_MODE'] ?? 'student';
    final p = Promo(tester, Platform.environment['PROMO_NAME'] ?? 'extra');
    await p.launch(mode: mode);

    Future<void> pick(String code) async {
      await p.tapKey('profile.language', after: 1000);
      await p.tapKey('picker.language.$code', after: 1000);
    }

    await p.scene('languages', () async {
      await p.go(Routes.profile, after: 900);
      await pick('ru');
      p.screen('ru');
      await p.wait(1500);
      await pick('en');
      p.screen('en');
      await p.wait(1500);
      await pick('uz');
      p.screen('uz');
    });

    await p.scene('future', () async {
      await p.go(Routes.home, after: 1500);
      await p.scroll(260, ms: 2200);
      await p.wait(500);
      await p.scrollTop();
    });
    await p.wait(2500); // yozuv oxiri kesilib qolmasin
    p.finish();
  });
}
