import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/login_gate.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/data/auth/mock_auth_repository.dart';
import 'package:forensic_expert/features/professional/presentation/account_choice_screen.dart';

import '../helpers/pump_app.dart';
import '../helpers/referral_fakes.dart' show signedInMockAuth;

void main() {
  testWidgets('majburiy kirish: kirmagan — kirish ekrani, «Boshlash» yo‘q', (
    tester,
  ) async {
    await pumpApp(
      tester,
      settings: completedSettings(),
      initialLocation: Routes.lessons,
      overrides: [
        loginGateEnabledProvider.overrideWithValue(true),
        authRepositoryProvider.overrideWithValue(MockAuthRepository()),
      ],
    );
    await tester.pumpAndSettle();
    expect(find.byType(AccountChoiceScreen), findsOneWidget);
    expect(find.byKey(const Key('account.create')), findsOneWidget);
    // Kirmasdan o‘tib ketadigan tugma yo‘q.
    expect(find.byKey(const Key('account.skip')), findsNothing);
  });

  testWidgets('majburiy kirish: kirgan foydalanuvchi to‘siqsiz kiradi', (
    tester,
  ) async {
    final auth = await signedInMockAuth();
    await pumpApp(
      tester,
      settings: completedSettings(),
      overrides: [
        loginGateEnabledProvider.overrideWithValue(true),
        authRepositoryProvider.overrideWithValue(auth),
      ],
    );
    await tester.pumpAndSettle();
    expect(find.byType(AccountChoiceScreen), findsNothing);
  });

  testWidgets('qoida o‘chiq (sinov/oflayn): hech narsa o‘zgarmaydi', (
    tester,
  ) async {
    await pumpApp(tester, settings: completedSettings());
    await tester.pumpAndSettle();
    expect(find.byType(AccountChoiceScreen), findsNothing);
  });
}
