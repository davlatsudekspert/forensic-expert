import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/router.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/data/auth/mock_auth_repository.dart';
import 'package:forensic_expert/features/account/presentation/auth_screens.dart';
import 'package:forensic_expert/features/home/presentation/home_screen.dart';
import 'package:forensic_expert/features/home/presentation/search_screen.dart';
import 'package:forensic_expert/features/library/presentation/entry_detail_screen.dart';

import '../helpers/fake_store.dart';
import '../helpers/pilot_content.dart';
import '../helpers/pump_app.dart';

/// TestFlight oldidan UX auditi: filtrlarni tozalash, xato sahifasi,
/// tasdiqlash ekranidan kirish, qidiruv natijasi Home tabida va bitta
/// «Kirish (email kod)» qatori.
void main() {
  late PilotContent pilot;
  setUpAll(() async => pilot = await loadPilotContent());

  Future<void> tapKey(WidgetTester tester, String key) async {
    final f = find.byKey(Key(key));
    await tester.ensureVisible(f);
    await tester.pumpAndSettle();
    await tester.tap(f);
    await tester.pumpAndSettle();
  }

  testWidgets('3: «Filtrlarni tozalash» matn va guruh filtrini tozalaydi', (
    tester,
  ) async {
    await pumpApp(
      tester,
      settings: completedSettings(),
      initialLocation: Routes.librarySection('substances'),
      testFixtures: false,
      overrides: pilot.overrides,
    );
    expect(find.byKey(const Key('library.entry.morphine')), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('library.filter')),
      'zzz-no-such-substance',
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('library.entry.morphine')), findsNothing);
    final clear = find.widgetWithText(OutlinedButton, 'Clear filters');
    await tester.ensureVisible(clear);
    await tester.pumpAndSettle();
    await tester.tap(clear);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('library.entry.morphine')), findsOneWidget);
    final field = tester.widget<TextField>(
      find.byKey(const Key('library.filter')),
    );
    expect(field.controller!.text, isEmpty);
  });

  group('4: noma’lum yo‘l — xato sahifasi', () {
    for (final path in [
      '/does/not/exist',
      '/home/knowledge/notAKind',
      '/home/area/notAnArea',
    ]) {
      testWidgets(path, (tester) async {
        final c = await pumpApp(
          tester,
          settings: completedSettings(lang: 'uz'),
          initialLocation: path,
        );
        expect(tester.takeException(), isNull);
        expect(find.byKey(const Key('router.notFound')), findsOneWidget);
        expect(find.text('Sahifa topilmadi'), findsOneWidget);
        await tester.tap(find.byKey(const Key('router.notFound.home')));
        await tester.pumpAndSettle();
        expect(find.byType(HomeScreen), findsOneWidget);
        expect(c.read(routerProvider).state.uri.path, Routes.home);
      });
    }
  });

  testWidgets('5: tasdiqlash — kirmagan foydalanuvchiga kirish tugmasi', (
    tester,
  ) async {
    final c = await pumpApp(
      tester,
      settings: completedSettings(),
      initialLocation: Routes.verification,
      overrides: [
        authRepositoryProvider.overrideWithValue(MockAuthRepository()),
      ],
    );
    await tapKey(tester, 'verification.signIn');
    expect(find.byType(EmailCodeScreen), findsOneWidget);
    expect(c.read(routerProvider).state.uri.path, Routes.accountEmailCode);
  });

  testWidgets('7: qidiruv natijasi Home tabida ochiladi, Back — natijalarga', (
    tester,
  ) async {
    final c = await pumpApp(
      tester,
      settings: completedSettings(),
      initialLocation: Routes.searchWith('morphine'),
      testFixtures: false,
      overrides: [
        ...pilot.overrides,
        entitlementServiceProvider.overrideWithValue(FakeStore(owned: true)),
      ],
    );
    await tapKey(tester, 'search.hit.morphine');
    expect(find.byType(EntryDetailScreen), findsOneWidget);
    final path = c.read(routerProvider).state.uri.path;
    expect(path, Routes.homeSubstance('morphine'));
    expect(path.startsWith(Routes.home), isTrue);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.byType(SearchScreen), findsOneWidget);
    expect(find.byKey(const Key('search.hit.morphine')), findsOneWidget);
  });

  testWidgets('18: profilda bitta «Kirish (email kod)» qatori', (tester) async {
    final c = await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz'),
      initialLocation: Routes.profile,
      overrides: [
        authRepositoryProvider.overrideWithValue(MockAuthRepository()),
      ],
    );
    final row = find.byKey(const Key('profile.emailCode'));
    await tester.scrollUntilVisible(
      row,
      300,
      scrollable: find.byType(Scrollable).hitTestable().first,
    );
    expect(find.text('Kirish (email kod)'), findsOneWidget);
    expect(find.byKey(const Key('profile.signIn')), findsNothing);
    expect(find.byKey(const Key('profile.register')), findsNothing);
    await tester.tap(row);
    await tester.pumpAndSettle();
    expect(c.read(routerProvider).state.uri.path, Routes.accountEmailCode);
  });
}
