import 'dart:ui';

import 'package:forensic_expert/app/share.dart';
import 'package:forensic_expert/data/auth/mock_auth_repository.dart';
import 'package:forensic_expert/domain/ports/referral_ports.dart';
import 'package:forensic_expert/domain/referral/referral_models.dart';

/// Soxta referral xizmati (server javoblarini taqlid qiladi).
class FakeReferralService implements ReferralService {
  FakeReferralService({
    this.dashboard = const ReferralDashboard(code: 'K7QH2MPX'),
    this.claimOutcome = ReferralClaimOutcome.valid,
    this.configured = true,
  });

  ReferralDashboard dashboard;
  ReferralClaimOutcome claimOutcome;
  final bool configured;
  final claims = <String>[];
  int fetches = 0;

  @override
  bool get isConfigured => configured;

  @override
  Future<ReferralResult> fetch() async {
    fetches++;
    return ReferralResult.ok(dashboard);
  }

  @override
  Future<ReferralClaimOutcome> claim(String code) async {
    claims.add(code);
    return claimOutcome;
  }
}

/// Tizim share sheet’i o‘rniga — ulashilgan matnni yozib oladi.
class RecordingShareService implements ShareService {
  final shared = <(String, String?)>[];

  @override
  Future<void> shareText(String text, {String? subject, Rect? origin}) async {
    shared.add((text, subject));
  }
}

/// Email tasdiqlangan (kirgan) MOCK akkaunt.
Future<MockAuthRepository> signedInMockAuth([
  String email = 'expert@lab.uz',
]) async {
  final a = MockAuthRepository();
  await a.register(
    email: email,
    password: 'TestPassw0rd!',
    acceptedTermsVersion: 'v',
  );
  await a.verifyEmail(email: email, code: a.outbox.last.code!);
  return a;
}
