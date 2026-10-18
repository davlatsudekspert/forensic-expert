import 'dart:ui' show ImageFilter, lerpDouble;

import 'package:flutter/material.dart';

import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';

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

  /// Markaziy ajratilgan bo‘lim (AI) — pill’dan ko‘tarilgan aksent tugma.
  final bool emphasized;
}

/// Ekran chetidan masofa (dp) — spetsifikatsiya: 12–16.
const double kFloatingNavSideMargin = 16;

/// To‘liq / ixcham holat balandligi.
const double kFloatingNavFullHeight = 64;
const double kFloatingNavCompactHeight = 48;

/// Menyu bilan ekran pastki cheti orasidagi masofa (home indicator hisobga
/// olingan).
/// Markaziy (ajratilgan) tugma pill’dan yuqoriga chiqadigan balandlik (dp).
const double kFloatingNavRise = 14;

double floatingNavBottomOffset(double safeBottom) =>
    safeBottom > 0 ? safeBottom + 4 : 12;

/// Kontent menyu ostida qolmasligi uchun rezerv qilinadigan pastki balandlik:
/// menyu + masofa + kichik zaxira. Safe area ichida.
double floatingNavReservedHeight(double safeBottom) =>
    kFloatingNavFullHeight +
    kFloatingNavRise +
    floatingNavBottomOffset(safeBottom) +
    8;

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
      duration: FeMotion.of(context, duration),
      curve: FeMotion.curve,
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
          alpha: blur ? (dark ? 0.86 : 0.88) : 0.94,
        );
        Widget pill = DecoratedBox(
          decoration: BoxDecoration(
            color: fill,
            borderRadius: radius,
            border: Border.all(
              color: c.borderStrong.withValues(alpha: dark ? 0.45 : 0.28),
            ),
          ),
          // Chetki yorliqlar pill burchagiga tegmasin (320 dp, RU).
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                for (var i = 0; i < items.length; i++)
                  Expanded(
                    child: items[i].emphasized
                        ? _CenterSlot(
                            item: items[i],
                            selected: i == selected,
                            t: t,
                          )
                        : _NavItem(
                            item: items[i],
                            selected: i == selected,
                            t: t,
                            onTap: () => onSelect(i),
                          ),
                  ),
              ],
            ),
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
        final shadow = DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            boxShadow: FeShadow.floating(
              dark ? Brightness.dark : Brightness.light,
            ),
          ),
          child: SizedBox(
            key: const Key('nav.floating'),
            width: w,
            height: h,
            child: pill,
          ),
        );
        final ci = items.indexWhere((e) => e.emphasized);
        if (ci < 0) return shadow;
        final size = lerpDouble(42, 52, t)!;
        final top = h + lerpDouble(6, kFloatingNavRise, t)!;
        return SizedBox(
          width: w,
          height: h + kFloatingNavRise,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(left: 0, right: 0, bottom: 0, child: shadow),
              Positioned(
                left: w * (ci + 0.5) / items.length - size / 2,
                bottom: top - size,
                child: _CenterButton(
                  item: items[ci],
                  selected: ci == selected,
                  size: size,
                  onTap: () => onSelect(ci),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Markaziy bo‘lim uchun pill ichidagi o‘rin: faqat yorliq (tugmaning
/// o‘zi pill ustida alohida chiziladi).
class _CenterSlot extends StatelessWidget {
  const _CenterSlot({
    required this.item,
    required this.selected,
    required this.t,
  });

  final FloatingNavItem item;
  final bool selected;
  final double t;

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    final text = Theme.of(context).textTheme;
    return Align(
      alignment: Alignment.bottomCenter,
      child: ClipRect(
        child: Align(
          heightFactor: t,
          child: Opacity(
            opacity: t,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  item.label,
                  maxLines: 1,
                  style: text.labelMedium?.copyWith(
                    fontSize: 11,
                    letterSpacing: 0,
                    fontWeight: FontWeight.w600,
                    color: c.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Ko‘tarilgan markaziy aksent tugma: yumshoq soya, pill rangidagi halqa.
class _CenterButton extends StatelessWidget {
  const _CenterButton({
    required this.item,
    required this.selected,
    required this.size,
    required this.onTap,
  });

  final FloatingNavItem item;
  final bool selected;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      excludeSemantics: true,
      onTap: onTap,
      child: Tooltip(
        message: item.label,
        excludeFromSemantics: true,
        child: GestureDetector(
          key: item.itemKey,
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: c.accent,
              border: Border.all(color: c.surfaceRaised, width: 3),
              boxShadow: [
                BoxShadow(
                  color: c.accent.withValues(alpha: dark ? 0.35 : 0.30),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: IconTheme.merge(
              data: IconThemeData(color: c.onAccent, size: size * 0.46),
              child: selected ? item.selectedIcon : item.icon,
            ),
          ),
        ),
      ),
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
