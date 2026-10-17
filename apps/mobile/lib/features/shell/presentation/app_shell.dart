import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../app/support.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/floating_nav_flag.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import 'floating_nav.dart';

/// Tab yozuvlari uchun maksimal matn masshtabi: tor ekranda (< 360 dp)
/// 1.0, qolganida 1.15. Qiymatlar `test/l10n/nav_label_fit_test.dart` da
/// haqiqiy Inter metrikasi bilan tekshiriladi.
double navLabelMaxTextScale(double screenWidth) =>
    screenWidth < 360 ? 1.0 : 1.15;

/// Pastki navigatsiya.
///
/// * `floatingNavEnabled` (standart): suzuvchi shisha menyu — Asosiy ·
///   Vositalar · AI · Profil. Kutubxona tab emas (Asosiy tepasidagi katta
///   tugma), lekin `/library` shell ichida qoladi (branch indeksi 2).
/// * aks holda: eski 5 tabli `NavigationBar` (Home · Tools · Library · AI ·
///   Profile).
///
/// `StatefulShellRoute.indexedStack` har bir tab stack’ini xotirada saqlaydi
/// — tab almashganda ekran qayta qurilmaydi («instant» his).
class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  /// Suzuvchi menyudagi bo‘limlar → shell branch indeksi (2 = Kutubxona,
  /// menyuda yo‘q).
  static const List<int> floatingBranches = [0, 1, 3, 4];

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  /// Skroll yo‘nalishiga qarab: true = ixcham (faqat ikonlar).
  final ValueNotifier<bool> _compact = ValueNotifier<bool>(false);

  StatefulNavigationShell get shell => widget.shell;

  @override
  void didUpdateWidget(covariant AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Tab almashganda menyu to‘liq qaytadi.
    if (oldWidget.shell.currentIndex != widget.shell.currentIndex) {
      _compact.value = false;
    }
  }

  @override
  void dispose() {
    _compact.dispose();
    super.dispose();
  }

  /// Instagram kabi: kontent pastga skrollda (barmoq yuqoriga) — ixcham,
  /// yuqoriga skrollda yoki tepada — to‘liq. Faqat vertikal skroll.
  bool _onScroll(ScrollNotification n) {
    if (n.metrics.axis != Axis.vertical) return false;
    if (n is UserScrollNotification) {
      switch (n.direction) {
        case ScrollDirection.reverse:
          _compact.value = true;
        case ScrollDirection.forward:
          _compact.value = false;
        case ScrollDirection.idle:
          break;
      }
    } else if ((n is ScrollUpdateNotification ||
            n is ScrollMetricsNotification) &&
        n.metrics.pixels <= n.metrics.minScrollExtent) {
      // Sahifa tepasida (yoki yangi sahifa ochilganda) — doim to‘liq.
      _compact.value = false;
    }
    return false;
  }

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
      child: floatingNavEnabled
          ? _floatingScaffold(context, l)
          : _scaffold(context, l),
    );
  }

  Widget _floatingScaffold(BuildContext context, AppLocalizations l) {
    final media = MediaQuery.of(context);
    // Klaviatura ochiq — menyu yashirinadi (matn maydonini yopmaydi).
    final keyboard = media.viewInsets.bottom > 0;
    final safeBottom = media.padding.bottom;
    final reserved = keyboard ? 0.0 : floatingNavReservedHeight(safeBottom);
    final slot = AppShell.floatingBranches.indexOf(shell.currentIndex);
    final items = [
      FloatingNavItem(
        itemKey: const Key('nav.home'),
        icon: const Icon(Icons.home_outlined),
        selectedIcon: const Icon(Icons.home),
        label: l.navHome,
      ),
      FloatingNavItem(
        itemKey: const Key('nav.tools'),
        icon: const Icon(Icons.calculate_outlined),
        selectedIcon: const Icon(Icons.calculate),
        label: l.navTools,
      ),
      FloatingNavItem(
        itemKey: const Key('nav.ai'),
        icon: const Icon(Icons.auto_awesome_outlined),
        selectedIcon: const Icon(Icons.auto_awesome),
        label: l.navAi,
        emphasized: true,
      ),
      FloatingNavItem(
        itemKey: const Key('nav.profile'),
        icon: const _ProfileNavIcon(selected: false),
        selectedIcon: const _ProfileNavIcon(selected: true),
        label: l.navProfile,
      ),
    ];
    final base = Theme.of(context);
    return Theme(
      // Snackbar suzuvchi menyuni yopib qo‘ymasligi uchun: ildiz Scaffold
      // (ScaffoldMessenger snackbar’ni shu yerda chizadi) snackbar’ni menyu
      // balandligicha yuqoriga suradi.
      data: base.copyWith(
        snackBarTheme: base.snackBarTheme.copyWith(
          insetPadding: EdgeInsets.fromLTRB(
            kFloatingNavSideMargin,
            0,
            kFloatingNavSideMargin,
            reserved + FeSpace.xxs,
          ),
        ),
      ),
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: NotificationListener<ScrollNotification>(
                onNotification: _onScroll,
                // Kontent menyu ostida to‘liq ko‘rinadi; SafeArea / ListView
                // pastki padding sifatida menyu balandligini hisobga oladi.
                child: Builder(
                  builder: (context) {
                    final m = MediaQuery.of(context);
                    return MediaQuery(
                      data: m.copyWith(
                        padding: m.padding.copyWith(bottom: reserved),
                        viewPadding: m.viewPadding.copyWith(bottom: reserved),
                      ),
                      child: shell,
                    );
                  },
                ),
              ),
            ),
            if (!keyboard)
              Positioned(
                left: 0,
                right: 0,
                bottom: floatingNavBottomOffset(safeBottom),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: kFloatingNavSideMargin,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(FeRadius.lg),
                        child: _SupportReplyBanner(
                          hidden: shell.currentIndex == 4,
                        ),
                      ),
                    ),
                    MediaQuery.withClampedTextScaling(
                      maxScaleFactor: navLabelMaxTextScale(media.size.width),
                      child: ValueListenableBuilder<bool>(
                        valueListenable: _compact,
                        builder: (context, compact, _) => FloatingNavBar(
                          items: items,
                          selected: slot,
                          compact: compact,
                          blur: floatingNavBlurEnabled,
                          onSelect: (i) {
                            final branch = AppShell.floatingBranches[i];
                            shell.goBranch(
                              branch,
                              initialLocation: branch == shell.currentIndex,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
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
