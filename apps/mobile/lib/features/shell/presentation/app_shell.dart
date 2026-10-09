import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../app/support.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ilova ochilganda: admin javobi bo‘lsa — yengil banner (push/
            // email yo‘q). Profil tabida ko‘rsatilmaydi (u yerda o‘z kartasi).
            _SupportReplyBanner(hidden: shell.currentIndex == 4),
            MediaQuery.withClampedTextScaling(
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
                    icon: const _ProfileNavIcon(selected: false),
                    selectedIcon: const _ProfileNavIcon(selected: true),
                    label: l.navProfile,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Profil ikonkasi + o‘qilmagan admin javoblari belgisi.
class _ProfileNavIcon extends ConsumerWidget {
  const _ProfileNavIcon({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(supportUnreadProvider).value ?? 0;
    final icon = Icon(selected ? Icons.person : Icons.person_outline);
    if (unread <= 0) return icon;
    final c = FeTheme.of(context);
    return Badge(
      key: const Key('nav.profile.badge'),
      backgroundColor: c.accent,
      textColor: c.onAccent,
      label: Text(unread.toString()),
      child: icon,
    );
  }
}

class _SupportReplyBanner extends ConsumerStatefulWidget {
  const _SupportReplyBanner({required this.hidden});

  final bool hidden;

  @override
  ConsumerState<_SupportReplyBanner> createState() =>
      _SupportReplyBannerState();
}

class _SupportReplyBannerState extends ConsumerState<_SupportReplyBanner> {
  /// Yopilgan paytdagi son: yangi javob kelsa banner qaytadi.
  int _dismissedAt = 0;

  /// Ilova fondan qaytganda (push yo‘q) o‘qilmagan javoblar qayta so‘raladi —
  /// aks holda belgi/banner faqat ilova qayta ishga tushganda yangilanardi.
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onResume: () {
        if (mounted) ref.invalidate(supportUnreadProvider);
      },
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unread = ref.watch(supportUnreadProvider).value ?? 0;
    if (widget.hidden || unread <= 0 || unread <= _dismissedAt) {
      return const SizedBox.shrink();
    }
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    return Material(
      key: const Key('support.replyBanner'),
      color: c.accentContainer,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Padding(
          padding: const EdgeInsetsDirectional.only(
            start: FeSpace.md,
            end: FeSpace.xxs,
          ),
          child: Row(
            children: [
              Icon(
                Icons.mark_chat_unread_outlined,
                size: 20,
                color: c.onAccentContainer,
              ),
              const SizedBox(width: FeSpace.xs),
              Expanded(
                child: Text(
                  l.supBannerText,
                  style: t.bodySmall?.copyWith(color: c.onAccentContainer),
                ),
              ),
              TextButton(
                key: const Key('support.replyBanner.open'),
                onPressed: () {
                  setState(() => _dismissedAt = unread);
                  context.push(Routes.support);
                },
                child: Text(l.supBannerOpen),
              ),
              IconButton(
                key: const Key('support.replyBanner.dismiss'),
                tooltip: l.supBannerDismiss,
                icon: Icon(Icons.close, size: 18, color: c.onAccentContainer),
                onPressed: () => setState(() => _dismissedAt = unread),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
