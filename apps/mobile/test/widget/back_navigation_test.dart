import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/router.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/features/home/presentation/home_screen.dart';
import 'package:forensic_expert/features/library/presentation/library_screen.dart';

import '../helpers/fake_store.dart';
import '../helpers/pilot_content.dart';
import '../helpers/pump_app.dart';

/// Har bir ochiladigan (push) ekranda aniq «Back» bor; ildiz tablarda
/// yo‘q; Android tizim «Back» to‘g‘ri ishlaydi; ro‘yxat holati saqlanadi.
void main() {
  late PilotContent pilot;
  setUpAll(() async => pilot = await loadPilotContent());

  Future<ProviderContainer> open(WidgetTester tester) => pumpApp(
    tester,
    settings: completedSettings(),
    testFixtures: false,
    overrides: [
      ...pilot.overrides,
      entitlementServiceProvider.overrideWithValue(FakeStore(owned: true)),
    ],
  );

  bool hasBack(WidgetTester tester) =>
      find.byType(BackButton).hitTestable().evaluate().isNotEmpty ||
      find.byTooltip('Back').hitTestable().evaluate().isNotEmpty;

  final pushed = [
    Routes.search,
    Routes.module('toxicology'),
    Routes.module('laboratory'),
    Routes.learn,
    Routes.research,
    Routes.disciplines,
    Routes.jurisdictions,
    Routes.jurisdictionSelect,
    Routes.knowledge('method'),
    Routes.knowledge('reagent'),
    Routes.knowledge('screeningTest'),
    Routes.forensicMedicine,
    Routes.biochemistry,
    Routes.histology,
    Routes.compare,
    Routes.librarySection('substances'),
    Routes.libraryEntry('morphine'),
    Routes.libraryStandards,
    Routes.specimens,
    Routes.specimen('serum-plasma'),
    Routes.conflicts,
    Routes.reviewStatus,
    Routes.tool('tool.lab.dilution'),
    Routes.profileEdit,
    Routes.verification,
    Routes.verificationDocuments,
    Routes.reviewDashboard,
    Routes.profileLanguage,
    Routes.profileMode,
    Routes.purchase,
    Routes.privacy,
    Routes.about,
  ];

  testWidgets('barcha ochiladigan ekranlarda Back bor va u oldingi '
      'ekranga qaytaradi', (tester) async {
    final c = await open(tester);
    final r = c.read(routerProvider);
    final missing = <String>[];
    for (final route in pushed) {
      r.go(Routes.home);
      await tester.pumpAndSettle();
      unawaited(r.push(route));
      await tester.pumpAndSettle();
      if (!hasBack(tester)) missing.add(route);
      expect(tester.takeException(), isNull, reason: route);
      // Android tizim «Back».
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(
        find.byType(HomeScreen).hitTestable(),
        findsOneWidget,
        reason: 'system back: $route',
      );
    }
    expect(missing, isEmpty, reason: missing.join('\n'));
  });

  testWidgets('ildiz tablarda ortiqcha Back yo‘q; boshqa tab ildizida '
      'tizim Back — Asosiyga', (tester) async {
    final c = await open(tester);
    final r = c.read(routerProvider);
    for (final tab in [
      Routes.home,
      Routes.tools,
      Routes.library,
      Routes.ai,
      Routes.profile,
    ]) {
      r.go(tab);
      await tester.pumpAndSettle();
      expect(hasBack(tester), isFalse, reason: tab);
      if (tab != Routes.home) {
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(find.byType(HomeScreen).hitTestable(), findsOneWidget);
      }
    }
  });

  testWidgets('ro‘yxat → tafsilot → Back: ro‘yxat va aylantirish holati '
      'saqlanadi', (tester) async {
    final c = await open(tester);
    final r = c.read(routerProvider);
    unawaited(r.push(Routes.librarySection('substances')));
    await tester.pumpAndSettle();
    final list = find.byType(Scrollable).hitTestable().first;
    await tester.drag(list, const Offset(0, -400));
    await tester.pumpAndSettle();
    final before = tester.state<ScrollableState>(list).position.pixels;
    expect(before, greaterThan(0));
    final tile = find.byWidgetPredicate(
      (w) =>
          w.key is ValueKey<String> &&
          (w.key! as ValueKey<String>).value.startsWith('library.entry.'),
    );
    await tester.tap(tile.hitTestable().first);
    await tester.pumpAndSettle();
    expect(hasBack(tester), isTrue);
    await tester.tap(find.byType(BackButton).hitTestable().first);
    await tester.pumpAndSettle();
    expect(find.byType(LibrarySectionScreen), findsOneWidget);
    final after = tester
        .state<ScrollableState>(find.byType(Scrollable).hitTestable().first)
        .position
        .pixels;
    expect(after, before);
  });

  testWidgets('qidiruv → natija → Back: qidiruv natijalariga qaytadi', (
    tester,
  ) async {
    final c = await open(tester);
    unawaited(c.read(routerProvider).push(Routes.searchWith('morphine')));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    final hit = find.byKey(const Key('search.hit.morphine'));
    final target = hit.evaluate().isNotEmpty
        ? hit
        : find.textContaining('orphine').hitTestable().last;
    await tester.tap(target.first);
    await tester.pumpAndSettle();
    expect(hasBack(tester), isTrue);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('search.field')).hitTestable(), findsOneWidget);
  });
}
