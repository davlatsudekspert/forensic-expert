import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/theme.dart';
import '../../../core/l10n/generated/app_localizations.dart';

/// Tab yozuvlari uchun maksimal matn masshtabi: tor ekranda (< 360 dp)
/// 1.0, qolganida 1.15. Qiymatlar `test/l10n/nav_label_fit_test.dart` da
/// haqiqiy Inter metrikasi bilan tekshiriladi.
double navLabelMaxTextScale(double screenWidth) =>
    screenWidth < 360 ? 1.0 : 1.15;

/// Pastki navigatsiya: Home · Tools · Library · AI · Profile.
///
/// `StatefulShellRoute.indexedStack` har bir tab stack’ini xotirada saqlaydi
/// — tab almashganda ekran qayta qurilmaydi («instant» his).
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    // Android «Back»: boshqa tab ildizida — avval Asosiy tabga qaytadi,
    // ilovadan faqat Asosiy tabdan chiqiladi (tasodifiy chiqish yo‘q).
    return PopScope(
      canPop: shell.currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && shell.currentIndex != 0) shell.goBranch(0);
      },
      child: _scaffold(context, l),
    );
  }

  Widget _scaffold(BuildContext context, AppLocalizations l) {
    return Scaffold(
      body: shell,
      // Tab yozuvlari platforma konvensiyasiga ko‘ra cheklangan masshtabda
      // (iOS tab bar ham Dynamic Type bilan cheksiz kattalashmaydi).
      // Har bir tabda tooltip va semantik label to‘liq saqlanadi.
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: FeTheme.of(context).border)),
        ),
        child: MediaQuery.withClampedTextScaling(
          maxScaleFactor: navLabelMaxTextScale(
            MediaQuery.sizeOf(context).width,
          ),
          child: NavigationBar(
            selectedIndex: shell.currentIndex,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            onDestinationSelected: (i) =>
                shell.goBranch(i, initialLocation: i == shell.currentIndex),
            destinations: [
              NavigationDestination(
                key: const Key('nav.home'),
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home),
                label: l.navHome,
              ),
              NavigationDestination(
                key: const Key('nav.tools'),
                icon: const Icon(Icons.calculate_outlined),
                selectedIcon: const Icon(Icons.calculate),
                label: l.navTools,
              ),
              NavigationDestination(
                key: const Key('nav.library'),
                icon: const Icon(Icons.local_library_outlined),
                selectedIcon: const Icon(Icons.local_library),
                label: l.navLibrary,
              ),
              NavigationDestination(
                key: const Key('nav.ai'),
                icon: const Icon(Icons.auto_awesome_outlined),
                selectedIcon: const Icon(Icons.auto_awesome),
                label: l.navAi,
              ),
              NavigationDestination(
                key: const Key('nav.profile'),
                icon: const Icon(Icons.person_outline),
                selectedIcon: const Icon(Icons.person),
                label: l.navProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
