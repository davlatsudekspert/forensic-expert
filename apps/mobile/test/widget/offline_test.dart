import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/features/home/presentation/home_screen.dart';

import '../helpers/pump_app.dart';
import '../helpers/screens.dart';

/// Har qanday HttpClient yaratilishini xato qiladi.
class _NoNetwork extends HttpOverrides {
  int attempts = 0;

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    attempts++;
    throw const SocketException('Network access is forbidden in this test');
  }
}

/// Offline-first kafolati: onboarding, navigatsiya va barcha PHASE 1
/// ekranlari tarmoqsiz ishlaydi va startup’da tarmoq so‘rovi yo‘q.
void main() {
  testWidgets('startup va barcha ekranlar tarmoqqa murojaat qilmaydi', (
    tester,
  ) async {
    final guard = _NoNetwork();
    await HttpOverrides.runZoned(() async {
      await pumpApp(tester);
      await tester.tap(find.byKey(const Key('language.option.en')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('language.continue')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('disclaimer.accept')));
      await tester.tap(find.byKey(const Key('disclaimer.accept')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('mode.professional')));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);

      for (final route in shellScreens) {
        await pumpApp(
          tester,
          settings: completedSettings(),
          initialLocation: route,
        );
        expect(tester.takeException(), isNull, reason: route);
      }
    }, createHttpClient: guard.createHttpClient);
    expect(guard.attempts, 0);
  });
}
