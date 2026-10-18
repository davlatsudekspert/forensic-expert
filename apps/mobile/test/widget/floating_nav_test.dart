import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/core/floating_nav_flag.dart';
import 'package:forensic_expert/features/ai/presentation/ai_screen.dart';
import 'package:forensic_expert/features/home/presentation/home_screen.dart';
import 'package:forensic_expert/features/library/presentation/library_screen.dart';
import 'package:forensic_expert/features/profile/presentation/profile_screen.dart';
import 'package:forensic_expert/features/tools/presentation/tools_screen.dart';

import '../helpers/pump_app.dart';

/// Suzuvchi pastki menyu (`kFloatingNav`): 5 bo‘lim (markazda AI), skrollda ixchamlashish,
/// Kutubxona tugmasi Asosiy tepasida ham saqlanadi, bayroq o‘chiq — eski 5 tab.
void main() {
  final navBar = find.byKey(const Key('nav.floating'));

  setUp(() {
    floatingNavEnabled = true;
    floatingNavBlurEnabled = true;
  });
  tearDown(() {
    floatingNavEnabled = kFloatingNav;
    floatingNavBlurEnabled = kFloatingNavBlur;
  });

  testWidgets('menyu 5 ta bo‘lim: AI markazda, ko‘tarilgan', (tester) async {
    await pumpApp(tester, settings: completedSettings());
    expect(navBar, findsOneWidget);
    final keys = [
      'nav.home',
      'nav.library',
      'nav.ai',
      'nav.tools',
      'nav.profile',
    ];
    for (final k in keys) {
      expect(find.byKey(Key(k)), findsOneWidget, reason: k);
    }
    // Tartib chapdan o‘ngga; AI — pill markazida va pill tepasidan yuqorida.
    final xs = [for (final k in keys) tester.getCenter(find.byKey(Key(k))).dx];
    expect(xs, orderedEquals([...xs]..sort()));
    final pill = tester.getRect(navBar);
    final ai = tester.getRect(find.byKey(const Key('nav.ai')));
    expect(ai.center.dx, closeTo(pill.center.dx, 0.5));
    expect(ai.top, lessThan(pill.top));
    expect(ai.height, greaterThan(48));
    expect(find.byType(NavigationBar), findsNothing);
    for (final (key, type) in [
      ('nav.tools', ToolsScreen),
      ('nav.library', LibraryScreen),
      ('nav.ai', AiScreen),
      ('nav.profile', ProfileScreen),
      ('nav.home', HomeScreen),
    ]) {
      await tester.tap(find.byKey(Key(key)));
      await tester.pumpAndSettle();
      expect(find.byType(type), findsOneWidget, reason: key);
    }
  });

  testWidgets('menyu chetlardan 12–16 dp, suzuvchi, blur bayrog‘i ishlaydi', (
    tester,
  ) async {
    await pumpApp(tester, settings: completedSettings());
    final size = tester.view.physicalSize / tester.view.devicePixelRatio;
    final rect = tester.getRect(navBar);
    expect(rect.left, greaterThanOrEqualTo(12));
    expect(size.width - rect.right, greaterThanOrEqualTo(12));
    expect(size.height - rect.bottom, greaterThanOrEqualTo(12));
    expect(find.byType(BackdropFilter), findsOneWidget);

    floatingNavBlurEnabled = false;
    await pumpApp(tester, settings: completedSettings());
    expect(find.byType(BackdropFilter), findsNothing);
    expect(navBar, findsOneWidget);
  });

  testWidgets('pastga skroll → ixcham, yuqoriga skroll → to‘liq', (
    tester,
  ) async {
    await pumpApp(tester, settings: completedSettings());
    final fullW = tester.getSize(navBar).width;
    final fullH = tester.getSize(navBar).height;
    expect(find.text('Tools'), findsOneWidget);

    final list = find.byType(ListView).first;
    await tester.drag(list, const Offset(0, -400));
    await tester.pumpAndSettle();
    final compact = tester.getSize(navBar);
    expect(compact.width, lessThan(fullW));
    expect(compact.height, lessThan(fullH));
    // Yorliqlar ko‘rinmaydi (balandlik koeffitsienti 0), tugmalar bosiladi.
    expect(find.byKey(const Key('nav.tools')), findsOneWidget);

    await tester.drag(list, const Offset(0, 200));
    await tester.pumpAndSettle();
    expect(tester.getSize(navBar).width, fullW);
    expect(tester.getSize(navBar).height, fullH);
  });

  testWidgets('ixcham holatda ham tab almashadi va menyu qaytadi', (
    tester,
  ) async {
    await pumpApp(tester, settings: completedSettings());
    final fullW = tester.getSize(navBar).width;
    await tester.drag(find.byType(ListView).first, const Offset(0, -400));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('nav.tools')));
    await tester.pumpAndSettle();
    expect(find.byType(ToolsScreen), findsOneWidget);
    expect(tester.getSize(navBar).width, fullW);
  });

  testWidgets('snackbar suzuvchi menyuni yopmaydi (menyu ustida turadi)', (
    tester,
  ) async {
    await pumpApp(tester, settings: completedSettings());
    final ctx = tester.element(find.byType(HomeScreen));
    ScaffoldMessenger.of(
      ctx,
    ).showSnackBar(const SnackBar(content: Text('Hisobga kirdingiz — sinov')));
    await tester.pumpAndSettle();
    // Ko‘rinadigan snackbar yuzasi (tashqi masofa hisobga olinmaydi).
    final snack = tester.getRect(
      find
          .descendant(
            of: find.byType(SnackBar),
            matching: find.byType(Material),
          )
          .first,
    );
    final nav = tester.getRect(navBar);
    expect(snack.bottom, lessThanOrEqualTo(nav.top + 0.5));
    // AI tugmasi snackbar ostida emas — bosiladi.
    await tester.tap(find.byKey(const Key('nav.ai')));
    await tester.pumpAndSettle();
    expect(find.byType(AiScreen), findsOneWidget);
  });

  testWidgets('klaviatura ochilganda menyu yashirinadi', (tester) async {
    await pumpApp(tester, settings: completedSettings());
    expect(navBar, findsOneWidget);
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    expect(navBar, findsNothing);
    tester.view.resetViewInsets();
    await tester.pumpAndSettle();
    expect(navBar, findsOneWidget);
  });

  testWidgets('Kutubxona tugmasi Asosiy tepasida (qidiruvdan keyin, '
      'bo‘limlardan oldin) va Kutubxonani ochadi', (tester) async {
    await pumpApp(tester, settings: completedSettings());
    final cta = find.byKey(const Key('home.library'));
    expect(cta, findsOneWidget);
    expect(
      tester.getTopLeft(cta).dy,
      greaterThan(tester.getTopLeft(find.byKey(const Key('home.search'))).dy),
    );
    expect(
      tester.getTopLeft(cta).dy,
      lessThan(
        tester.getTopLeft(find.byKey(const Key('home.module.toxicology'))).dy,
      ),
    );
    expect(find.text('Library'), findsWidgets);
    await tester.tap(cta);
    await tester.pumpAndSettle();
    expect(find.byType(LibraryScreen), findsOneWidget);
    // Kutubxonada hech bir tab tanlanmagan, menyu esa joyida.
    expect(navBar, findsOneWidget);
    await tester.tap(find.byKey(const Key('nav.home')));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('bayroq false: eski 5 tabli menyu, Kutubxona tugmasi yo‘q', (
    tester,
  ) async {
    floatingNavEnabled = false;
    await pumpApp(tester, settings: completedSettings());
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(navBar, findsNothing);
    expect(find.byKey(const Key('home.library')), findsNothing);
    expect(find.byType(NavigationDestination), findsNWidgets(5));
    await tester.tap(find.byKey(const Key('nav.library')));
    await tester.pumpAndSettle();
    expect(find.byType(LibraryScreen), findsOneWidget);
  });

  testWidgets('320 dp, 1.15× shrift, qorong‘i: yorliqlar sig‘adi', (
    tester,
  ) async {
    await pumpApp(
      tester,
      settings: completedSettings(lang: 'ru', theme: ThemeMode.dark),
      size: const Size(320, 640),
      textScale: 1.15,
    );
    expect(tester.takeException(), isNull);
    expect(tester.getSize(navBar).width, 288);
    // Hamma 5 tugma pill ichida/ustida, ekrandan chiqmaydi.
    for (final k in ['home', 'library', 'ai', 'tools', 'profile']) {
      final r = tester.getRect(find.byKey(Key('nav.$k')));
      expect(r.left, greaterThanOrEqualTo(0), reason: k);
      expect(r.right, lessThanOrEqualTo(320), reason: k);
    }
  });

  testWidgets('390 dp, qorong‘i: overflow yo‘q, tab holati saqlanadi', (
    tester,
  ) async {
    await pumpApp(
      tester,
      settings: completedSettings(theme: ThemeMode.dark),
      size: const Size(390, 844),
    );
    await tester.tap(find.byKey(const Key('nav.tools')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('nav.ai')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('nav.tools')));
    await tester.pumpAndSettle();
    expect(find.byType(ToolsScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
