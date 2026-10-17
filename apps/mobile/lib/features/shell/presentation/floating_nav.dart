import 'dart:ui' show ImageFilter, lerpDouble;

import 'package:flutter/material.dart';

import '../../../core/design/theme.dart';

/// Suzuvchi menyudagi bitta bo‘lim.
class FloatingNavItem {
  const FloatingNavItem({
    required this.itemKey,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.emphasized = false,
  });

  final Key itemKey;
  final Widget icon;
  final Widget selectedIcon;
  final String label;

  /// Markaziy ajratilgan bo‘lim (AI) — to‘ldirilgan aksent belgisi.
  final bool emphasized;
}

/// Ekran chetidan masofa (dp) — spetsifikatsiya: 12–16.
const double kFloatingNavSideMargin = 16;

/// To‘liq / ixcham holat balandligi.
const double kFloatingNavFullHeight = 64;
const double kFloatingNavCompactHeight = 48;

/// Menyu bilan ekran pastki cheti orasidagi masofa (home indicator hisobga
/// olingan).
double floatingNavBottomOffset(double safeBottom) =>
    safeBottom > 0 ? safeBottom + 4 : 12;

/// Kontent menyu ostida qolmasligi uchun rezerv qilinadigan pastki balandlik:
/// menyu + masofa + kichik zaxira. Safe area ichida.
double floatingNavReservedHeight(double safeBottom) =>
    kFloatingNavFullHeight + floatingNavBottomOffset(safeBottom) + 8;

/// Yumaloq (pill), yarim shaffof «shisha» pastki menyu.
///
/// [compact] = true — faqat ikonlar, tor va past; false — yorliqlar bilan
/// to‘liq. O‘tish 200 ms, `easeOutCubic`.
class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({
    super.key,
    required this.items,
    required this.selected,
    required this.compact,
    required this.onSelect,
    required this.blur,
  });

  final List<FloatingNavItem> items;

  /// Tanlangan bo‘lim indeksi; `-1` — hech biri (masalan, Kutubxona ichida).
  final int selected;
  final bool compact;
  final ValueChanged<int> onSelect;

  /// `BackdropFilter` yoqilganmi (`floatingNavBlurEnabled`).
  final bool blur;

  static const Duration duration = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final screenW = MediaQuery.sizeOf(context).width;
    final fullW = (screenW - 2 * kFloatingNavSideMargin).clamp(0.0, 440.0);
    final compactW = (items.length * 56.0 + 16).clamp(0.0, fullW);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: compact ? 0 : 1),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, t, _) {
        final w = lerpDouble(compactW, fullW, t)!;
        final h = lerpDouble(
          kFloatingNavCompactHeight,
          kFloatingNavFullHeight,
          t,
        )!;
        final radius = BorderRadius.circular(h / 2);
        // Yarim shaffof sirt: blur yoqilganda shaffofroq, o‘chiq bo‘lsa
        // matn o‘qilishi uchun zichroq.
        final fill = c.surfaceRaised.withValues(
          alpha: blur ? (dark ? 0.72 : 0.78) : 0.94,
        );
        Widget pill = DecoratedBox(
          decoration: BoxDecoration(
            color: fill,
            borderRadius: radius,
            border: Border.all(color: c.borderStrong.withValues(alpha: 0.55)),
          ),
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _NavItem(
                    item: items[i],
                    selected: i == selected,
                    t: t,
                    onTap: () => onSelect(i),
                  ),
                ),
            ],
          ),
        );
        pill = ClipRRect(
          borderRadius: radius,
          child: blur
              ? BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: pill,
                )
              : pill,
        );
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: dark ? 0.45 : 0.16),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: SizedBox(
            key: const Key('nav.floating'),
            width: w,
            height: h,
            child: pill,
          ),
        );
      },
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.item,
    required this.selected,
    required this.t,
    required this.onTap,
  });

  final FloatingNavItem item;
  final bool selected;

  /// 0 = ixcham, 1 = to‘liq.
  final double t;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    final text = Theme.of(context).textTheme;
    final emphasized = item.emphasized;
    final iconColor = emphasized
        ? c.onAccent
        : (selected ? c.onAccentContainer : c.textSecondary);
    final badgeColor = emphasized
        ? c.accent
        : (selected ? c.accentContainer : Colors.transparent);
    final iconBox = Container(
      width: 46,
      height: lerpDouble(34, 30, t),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: IconTheme.merge(
        data: IconThemeData(color: iconColor, size: 24),
        child: selected ? item.selectedIcon : item.icon,
      ),
    );
    final label = ClipRect(
      child: Align(
        heightFactor: t,
        child: Opacity(
          opacity: t,
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                item.label,
                maxLines: 1,
                style: text.labelMedium?.copyWith(
                  fontSize: 11,
                  letterSpacing: 0,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected || emphasized
                      ? c.textPrimary
                      : c.textSecondary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      excludeSemantics: true,
      onTap: onTap,
      child: Tooltip(
        message: item.label,
        excludeFromSemantics: true,
        child: InkResponse(
          key: item.itemKey,
          onTap: onTap,
          radius: 32,
          containedInkWell: false,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [iconBox, label],
            ),
          ),
        ),
      ),
    );
  }
}
