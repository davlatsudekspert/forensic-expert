import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/core/floating_nav_flag.dart';
import 'package:forensic_expert/features/ai/presentation/ai_screen.dart';
import 'package:forensic_expert/features/home/presentation/home_screen.dart';
import 'package:forensic_expert/features/library/presentation/library_screen.dart';
import 'package:forensic_expert/features/profile/presentation/profile_screen.dart';
import 'package:forensic_expert/features/tools/presentation/tools_screen.dart';

import '../helpers/pump_app.dart';

/// Suzuvchi pastki menyu (`kFloatingNav`): 4 bo‘lim, skrollda ixchamlashish,
/// Kutubxona tugmasi Asosiy tepasida, bayroq o‘chiq — eski 5 tab.
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

  testWidgets('menyu 4 ta bo‘lim: Kutubxona tab emas', (tester) async {
    await pumpApp(tester, settings: completedSettings());
    expect(navBar, findsOneWidget);
    for (final k in ['nav.home', 'nav.tools', 'nav.ai', 'nav.profile']) {
      expect(find.byKey(Key(k)), findsOneWidget, reason: k);
    }
    expect(find.byKey(const Key('nav.library')), findsNothing);
    expect(find.byType(NavigationBar), findsNothing);
    for (final (key, type) in [
      ('nav.tools', ToolsScreen),
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
  });
}
