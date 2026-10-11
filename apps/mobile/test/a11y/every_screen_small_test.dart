import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/account.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/domain/admin/admin_models.dart';
import 'package:forensic_expert/domain/ports/account_ports.dart';

import '../helpers/pump_app.dart';
import '../helpers/referral_fakes.dart';
import '../helpers/screens.dart';

/// Har bir ekran kichik telefonda (320 dp) va kattalashtirilgan shriftda
/// ochilishi kerak — overflow ham, boshqa layout xatosi ham bo‘lmasin.
///
/// Bu ro‘yxat **barcha** parametrsiz yo‘llarni qamraydi: admin paneli,
/// «Savol-javob», murojaatlar, sud tayyorgarligi, akkaunt ekranlari ham.
/// Avval faqat bir qismi sinalardi va shu sababli yangi ekranlardagi
/// kamchiliklar sezilmay qolardi.
class _AdminAccount implements AccountService {
  const _AdminAccount();

  @override
  bool get isConfigured => true;

  @override
  Future<ServerAccess?> myAccess() async => const ServerAccess(isAdmin: true);

  @override
  Future<void> registerDevice({
    required String platform,
    required String version,
    required String locale,
    String? region,
  }) async {}

  @override
  Future<AdminDashboard?> dashboard() async => null;

  @override
  Future<AdminGrantResult> setAccess(String email, String? tier) async =>
      AdminGrantResult.failed;
}

void main() {
  const small = Size(320, 568);

  // 1.3× — ko‘p ishlatiladigan kattalashtirish; 2.0× — Dynamic Type’ning
  // yuqori chegarasi. Ikkalasida ham ekran buzilmasligi kerak.
  for (final scale in [1.3, 2.0]) {
    for (final route in everyScreen) {
      testWidgets('320dp ×$scale · $route', (tester) async {
        await pumpApp(
          tester,
          size: small,
          textScale: scale,
          settings: completedSettings(lang: 'uz'),
          initialLocation: route,
          overrides: [
            accountServiceProvider.overrideWithValue(const _AdminAccount()),
            authRepositoryProvider.overrideWithValue(await signedInMockAuth()),
          ],
        );
        expect(tester.takeException(), isNull, reason: '$route ×$scale');
      });
    }
  }
}
