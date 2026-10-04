import 'package:flutter/material.dart';

import '../design/theme.dart';
import '../design/tokens.dart';
import '../l10n/generated/app_localizations.dart';

/// Bo‘lim sarlavhasi (header semantikasi bilan) va ixtiyoriy amal.
class FeSectionHeader extends StatelessWidget {
  const FeSectionHeader(
    this.title, {
    super.key,
    this.actionLabel,
    this.onAction,
    this.padding = const EdgeInsets.only(top: FeSpace.lg, bottom: FeSpace.xs),
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    final heading = Semantics(
      header: true,
      child: Text(
        title.toUpperCase(),
        style: t.labelMedium?.copyWith(
          color: c.textSecondary,
          letterSpacing: 1.1,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
    if (actionLabel == null || onAction == null) {
      return Padding(
        padding: padding,
        child: SizedBox(width: double.infinity, child: heading),
      );
    }
    // Tor ekran / katta shriftda amal tugmasi keyingi qatorga o‘tadi.
    return Padding(
      padding: padding,
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: FeSpace.xs,
        children: [
          heading,
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}

/// «TEST DATA» belgisi — fixture yozuvlari har doim shu bilan.
class TestDataBadge extends StatelessWidget {
  const TestDataBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    final label = AppLocalizations.of(context).testDataBadge;
    return Semantics(
      label: label,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: c.warning),
          borderRadius: BorderRadius.circular(4),
          color: c.warningContainer,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.science_outlined,
                size: 12,
                color: c.onWarningContainer,
              ),
              const SizedBox(width: 3),
              Flexible(
                child: Text(
                  label,
                  style:
                      FeThemeBuilder.numeric(
                        Theme.of(context).textTheme.labelSmall!,
                      ).copyWith(
                        color: c.onWarningContainer,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Holat chipi: ikonka + matn (faqat rangga tayanmaydi).
class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.6)),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall
                      ?.copyWith(color: color, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Ogohlantirish ierarxiyasi: CRITICAL > WARNING > INFO > REVIEW.
///
/// Rang yagona belgi emas: har bir daraja o‘z ikonkasi shakli, chegara
/// qalinligi va ekran o‘quvchisi uchun daraja nomi bilan ajraladi.
enum FeBannerTone {
  /// Noto‘g‘ri talqin xavfli (skrining ≠ tasdiq; konsentratsiya ≠ chegara).
  critical,

  /// Tekshirilmagan ma’lumot, cheklov.
  warning,

  /// Kontekst, tushuntirish.
  info,

  /// Review holati / provenance eslatmasi.
  review,
}

class FeBanner extends StatelessWidget {
  const FeBanner({
    super.key,
    required this.icon,
    required this.text,
    this.tone = FeBannerTone.info,
  });

  final IconData icon;
  final String text;
  final FeBannerTone tone;

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    final (bg, fg, border, width) = switch (tone) {
      FeBannerTone.critical => (c.surface, c.textPrimary, c.danger, 2.0),
      FeBannerTone.warning => (
        c.warningContainer,
        c.onWarningContainer,
        c.warning,
        1.0,
      ),
      FeBannerTone.info => (c.surface, c.textSecondary, c.border, 1.0),
      FeBannerTone.review => (c.background, c.textSecondary, c.border, 1.0),
    };
    final l = AppLocalizations.of(context);
    final level = switch (tone) {
      FeBannerTone.critical => l.severityCritical,
      FeBannerTone.warning => l.severityWarning,
      FeBannerTone.info => l.severityInfo,
      FeBannerTone.review => l.severityReview,
    };
    return Semantics(
      container: true,
      label: level,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(FeRadius.sm),
          // Bir xil kenglik: borderRadius bilan notekis chegara ruxsat etilmaydi.
          border: Border.all(color: border, width: width),
        ),
        child: Padding(
          padding: const EdgeInsets.all(FeSpace.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 20,
                color: tone == FeBannerTone.critical ? c.danger : fg,
              ),
              const SizedBox(width: FeSpace.xs),
              Expanded(
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: fg,
                    height: 1.4,
                    fontWeight: tone == FeBannerTone.critical
                        ? FontWeight.w600
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bo‘sh holat — sun’iy statistika yoki to‘ldiruvchi raqam o‘rniga.
class FeEmptyState extends StatelessWidget {
  const FeEmptyState({
    super.key,
    required this.icon,
    required this.body,
    this.title,
    this.compact = false,
  });

  final IconData icon;
  final String? title;
  final String body;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final children = [
      Icon(icon, size: compact ? 20 : 36, color: c.textSecondary),
      SizedBox(height: compact ? 0 : FeSpace.sm, width: FeSpace.sm),
      if (title != null)
        Semantics(
          header: true,
          child: Text(title!, style: t.titleSmall, textAlign: TextAlign.center),
        ),
      Flexible(
        child: Text(
          body,
          textAlign: compact ? TextAlign.start : TextAlign.center,
          style: t.bodySmall?.copyWith(color: c.textSecondary),
        ),
      ),
    ];
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: compact ? FeSpace.xs : FeSpace.lg,
      ),
      child: compact
          ? Row(children: children)
          : Column(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}

/// Chegarali, bosiladigan kartochka.
class FeCard extends StatelessWidget {
  const FeCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(FeSpace.md),
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label: semanticLabel,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Qidiruv maydoni ko‘rinishidagi tugma (Home, Library).
class FeSearchEntry extends StatelessWidget {
  const FeSearchEntry({super.key, required this.hint, required this.onTap});

  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    return Semantics(
      button: true,
      label: hint,
      excludeSemantics: true,
      child: Material(
        color: c.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FeRadius.md),
          side: BorderSide(
            color: FeTheme.isHighContrast(context) ? c.borderStrong : c.border,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(FeRadius.md),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 52),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: FeSpace.md,
                vertical: FeSpace.sm,
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: c.accent),
                  const SizedBox(width: FeSpace.sm),
                  Expanded(
                    child: Text(
                      hint,
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: c.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
