import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/core/settings/app_settings.dart';
import 'package:forensic_expert/features/home/presentation/home_screen.dart';
import 'package:forensic_expert/features/library/presentation/library_screen.dart';

import '../helpers/pump_app.dart';

/// Ustoz bosh sahifasi: 8 kartali «Bo‘limlar» to‘ri o‘rniga bitta ixcham
/// «Ilmiy kutubxona» qatori (egasi qarori, 2026-11-04).
void main() {
  const tile = Key('home.teacherLibrary');

  for (final lang in ['uz', 'ru', 'en']) {
    for (final (w, scale) in [
      (320.0, 1.0),
      (360.0, 1.0),
      (390.0, 1.0),
      (320.0, 2.0),
      (390.0, 2.0),
    ]) {
      testWidgets('[$lang] $w dp ×$scale: qator sig‘adi, overflow yo‘q', (
        tester,
      ) async {
        await pumpApp(
          tester,
          size: Size(w, 844),
          textScale: scale,
          settings: completedSettings(lang: lang, mode: UserMode.teacher),
        );
        await tester.scrollUntilVisible(
          find.byKey(tile),
          200,
          scrollable: find.byType(Scrollable).hitTestable().first,
        );
        await tester.pumpAndSettle();
        expect(find.byKey(tile), findsOneWidget);
        expect(tester.takeException(), isNull);
        // Pastki menyu qatorni yopmasligi uchun oxirigacha aylantiriladi.
        await tester.drag(
          find.byType(Scrollable).hitTestable().first,
          const Offset(0, -3000),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('bosilganda Kutubxona ochiladi', (tester) async {
    await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz', mode: UserMode.teacher),
    );
    await tester.scrollUntilVisible(
      find.byKey(tile),
      200,
      scrollable: find.byType(Scrollable).hitTestable().first,
    );
    await tester.pumpAndSettle();
    expect(find.text('Ilmiy kutubxona'), findsOneWidget);
    await tester.tap(find.byKey(tile));
    await tester.pumpAndSettle();
    expect(find.byType(LibraryScreen), findsOneWidget);
  });

  for (final mode in [UserMode.student, UserMode.professional]) {
    testWidgets('${mode.name}: Ustoz qatori yo‘q', (tester) async {
      await pumpApp(
        tester,
        settings: completedSettings(lang: 'uz', mode: mode),
      );
      expect(find.byKey(tile, skipOffstage: false), findsNothing);
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  }
}
