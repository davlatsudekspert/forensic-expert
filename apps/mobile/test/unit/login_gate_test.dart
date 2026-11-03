import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/login_gate.dart';
import 'package:forensic_expert/app/routes.dart';

String? gate({
  bool enabled = true,
  bool onboardingDone = true,
  bool signedIn = false,
  bool hadSession = false,
  String location = '/home',
}) => loginGateRedirect(
  enabled: enabled,
  onboardingDone: onboardingDone,
  signedIn: signedIn,
  hadSession: hadSession,
  location: location,
);

void main() {
  test('kirmagan foydalanuvchi: har qanday sahifa → kirish ekrani', () {
    expect(gate(), Routes.welcomeAccount);
    expect(gate(location: Routes.lessons), Routes.welcomeAccount);
    expect(gate(location: '/library/substances'), Routes.welcomeAccount);
  });

  test('hisob ekranlari ochiq qoladi (aks holda kirib bo‘lmaydi)', () {
    expect(gate(location: Routes.welcomeAccount), isNull);
    expect(gate(location: Routes.welcomeEmailCode), isNull);
    expect(gate(location: Routes.accountSignIn), isNull);
    expect(gate(location: Routes.accountVerify), isNull);
  });

  test('kirgan foydalanuvchi: aralashmaydi, kirish ekranidan Asosiyga', () {
    expect(gate(signedIn: true), isNull);
    expect(gate(signedIn: true, location: Routes.lessons), isNull);
    expect(gate(signedIn: true, location: Routes.welcomeAccount), Routes.home);
  });

  test(
    'oflayn ochilgan, saqlangan sessiya bor — kirish ekraniga tushmaydi',
    () {
      expect(gate(hadSession: true), isNull);
    },
  );

  test('o‘chiq yoki onboarding tugamagan — aralashmaydi', () {
    expect(gate(enabled: false), isNull);
    expect(gate(onboardingDone: false), isNull);
  });
}
