import 'package:flutter/material.dart';

import '../design/theme.dart';
import '../design/tokens.dart';
import '../l10n/generated/app_localizations.dart';

/// AppBar sarlavhasi: bir qatorga sig‘sa — odatdagi 20 sp serif; sig‘masa —
/// biroz kichikroq shrift bilan **ikki qator** (uzun modda/usul nomlari
/// «GC (gaz xromat…» bo‘lib kesilmasin). Ikki qatorga ham sig‘masa — oxiri
/// «…» bilan.
class FeAppBarTitle extends StatelessWidget {
  const FeAppBarTitle(this.text, {super.key});

  final String text;

  /// Ikki qatorli rejimdagi shrift (toolbar 60 dp ga 2 qator sig‘adi).
  static const double twoLineFontSize = 16.5;

  @override
  Widget build(BuildContext context) {
    final base = DefaultTextStyle.of(context).style;
    final scaler = MediaQuery.textScalerOf(context);
    final dir = Directionality.of(context);
    return LayoutBuilder(
      builder: (context, box) {
        final one = TextPainter(
          text: TextSpan(text: text, style: base),
          maxLines: 1,
          textDirection: dir,
          textScaler: scaler,
        )..layout(maxWidth: box.maxWidth);
        final fits = !one.didExceedMaxLines;
        one.dispose();
        if (fits) {
          return Text(text, maxLines: 1, overflow: TextOverflow.ellipsis);
        }
        return Text(
          text,
          maxLines: 2,
          softWrap: true,
          overflow: TextOverflow.ellipsis,
          style: base.copyWith(
            fontSize: twoLineFontSize,
            height: 1.15,
            letterSpacing: -0.1,
          ),
        );
      },
    );
  }
}

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
    // Jurnal uslubidagi bo‘lim sarlavhasi: serif matn + ostida qisqa
    // shampan-oltin chiziq (premium detal, ma’no tashimaydi).
    final heading = Semantics(
      header: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: t.titleMedium?.copyWith(
              color: c.textPrimary,
              fontSize: 19,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 6),
          ExcludeSemantics(
            child: Container(
              width: 24,
              height: 2,
              decoration: BoxDecoration(
                color: c.accent,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
        ],
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
          color: color.withValues(alpha: 0.10),
          border: Border.all(color: color.withValues(alpha: 0.28)),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
      // Mayin xavf foni (qattiq qizil ramka va KATTA HARF o‘rniga): daraja
      // ikonka shakli, qizil ikonka va ekran o‘quvchisi uchun nomi bilan
      // ajraladi.
      FeBannerTone.critical => (
        Color.alphaBlend(c.danger.withValues(alpha: 0.07), c.surface),
        c.textPrimary,
        c.danger.withValues(alpha: 0.35),
        1.0,
      ),
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
    final stripe = switch (tone) {
      FeBannerTone.critical => c.danger,
      FeBannerTone.warning => c.warning,
      FeBannerTone.info => c.borderStrong,
      FeBannerTone.review => c.reviewed,
    };
    final hc = FeTheme.isHighContrast(context);
    // Mayin tonal blok: yumaloq, chap chiziqsiz. Daraja ikonka shakli,
    // ikonka rangi va ekran o‘quvchisi uchun daraja nomi bilan ajraladi;
    // kritik daraja (va yuqori kontrast rejimi) — to‘liq chegara bilan.
    return Semantics(
      container: true,
      label: level,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tone == FeBannerTone.review ? c.surface : bg,
          borderRadius: BorderRadius.circular(FeRadius.md),
          border: hc || tone == FeBannerTone.critical
              ? Border.all(color: border, width: width)
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            FeSpace.sm,
            FeSpace.sm,
            FeSpace.md,
            FeSpace.sm,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 20,
                color: switch (tone) {
                  FeBannerTone.critical => c.danger,
                  FeBannerTone.review => c.reviewed,
                  FeBannerTone.info => stripe,
                  _ => fg,
                },
              ),
              const SizedBox(width: FeSpace.sm),
              Expanded(
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: fg,
                    height: 1.45,
                    fontWeight: tone == FeBannerTone.critical
                        ? FontWeight.w500
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
    this.actionLabel,
    this.actionIcon,
    this.onAction,
  });

  final IconData icon;
  final String? title;
  final String body;
  final bool compact;

  /// Ixtiyoriy keyingi qadam (bo‘sh holat «boshi berk» bo‘lmasin).
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final children = [
      if (compact)
        Icon(icon, size: 20, color: c.textSecondary)
      else
        DecoratedBox(
          decoration: BoxDecoration(
            color: c.accentContainer,
            shape: BoxShape.circle,
            border: Border.all(color: c.accentBorder),
          ),
          child: Padding(
            padding: const EdgeInsets.all(FeSpace.md + 2),
            child: Icon(icon, size: 30, color: c.accent),
          ),
        ),
      SizedBox(height: compact ? 0 : FeSpace.md, width: FeSpace.sm),
      if (title != null)
        Semantics(
          header: true,
          child: Text(title!, style: t.titleSmall, textAlign: TextAlign.center),
        ),
      if (title != null && !compact) const SizedBox(height: FeSpace.xxs),
      Flexible(
        child: Text(
          body,
          textAlign: compact ? TextAlign.start : TextAlign.center,
          style: (compact ? t.bodySmall : t.bodyMedium)?.copyWith(
            color: c.textSecondary,
          ),
        ),
      ),
      if (!compact && actionLabel != null && onAction != null) ...[
        const SizedBox(height: FeSpace.md),
        FilledButton.tonalIcon(
          onPressed: onAction,
          icon: Icon(actionIcon ?? Icons.arrow_forward, size: 20),
          label: Text(actionLabel!),
          style: FilledButton.styleFrom(
            backgroundColor: c.accentContainer,
            foregroundColor: c.onAccentContainer,
            minimumSize: const Size(0, FeTouch.minTarget),
          ),
        ),
      ],
    ];
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: compact ? FeSpace.xs : FeSpace.lg,
        horizontal: compact ? 0 : FeSpace.lg,
      ),
      child: compact
          ? Row(children: children)
          : Column(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}

/// Kartochka: oq/tonal sirt, nozik chegara, yorug‘ mavzuda yengil soya,
/// bosilganda sezilar-sezilmas kichrayish (reduced motion’da yo‘q).
class FeCard extends StatefulWidget {
  const FeCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(FeSpace.md),
    this.semanticLabel,
    this.color,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final String? semanticLabel;

  /// Maxsus fon (masalan, tonal holat kartasi).
  final Color? color;

  @override
  State<FeCard> createState() => _FeCardState();
}

class _FeCardState extends State<FeCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    final brightness = Theme.of(context).brightness;
    final hc = FeTheme.isHighContrast(context);
    final radius = BorderRadius.circular(FeRadius.card);
    return Semantics(
      button: widget.onTap != null,
      label: widget.semanticLabel,
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1,
        duration: FeMotion.of(context, FeMotion.fast),
        curve: FeMotion.curve,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            boxShadow: hc ? const [] : FeShadow.card(brightness),
          ),
          child: Material(
            color: widget.color ?? c.surfaceRaised,
            shape: RoundedRectangleBorder(
              borderRadius: radius,
              side: BorderSide(
                color: hc
                    ? c.borderStrong
                    : c.border.withValues(
                        alpha: brightness == Brightness.dark ? 0.9 : 0.55,
                      ),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: widget.onTap,
              onHighlightChanged: widget.onTap == null
                  ? null
                  : (v) => setState(() => _pressed = v),
              child: Padding(padding: widget.padding, child: widget.child),
            ),
          ),
        ),
      ),
    );
  }
}

/// Qidiruv maydoni ko‘rinishidagi tugma (Home, Library).
class FeSearchEntry extends StatelessWidget {
  const FeSearchEntry({
    super.key,
    required this.hint,
    required this.onTap,
    this.onDark = false,
    this.prominent = false,
  });

  final String hint;
  final VoidCallback onTap;

  /// Eski API (navy hero). Endi ranglar mavzu tokenlaridan olinadi; true
  /// bo‘lsa [prominent] bilan bir xil ko‘rinadi.
  final bool onDark;

  /// Home markazidagi «aqlli ilmiy qidiruv»: balandroq, ingichka oltin
  /// chegara va oltin ikonka.
  final bool prominent;

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    final hc = FeTheme.isHighContrast(context);
    final big = prominent || onDark;
    final radius = BorderRadius.circular(big ? FeRadius.lg : FeRadius.md);
    return Semantics(
      button: true,
      label: hint,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: big && !hc
              ? FeShadow.card(Theme.of(context).brightness)
              : const [],
        ),
        child: Material(
          color: c.surfaceRaised,
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: BorderSide(
              color: hc
                  ? c.borderStrong
                  : big
                  ? c.accentBorder
                  : c.border,
            ),
          ),
          child: InkWell(
            borderRadius: radius,
            onTap: onTap,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: big ? 58 : 52),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: FeSpace.md,
                  vertical: FeSpace.sm,
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: c.accent, size: big ? 24 : 22),
                    const SizedBox(width: FeSpace.sm),
                    Expanded(
                      child: Text(
                        hint,
                        // Katta shriftda ham ixcham; to‘liq matn semantik
                        // yorliqda o‘qiladi.
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
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
      ),
    );
  }
}

/// Asinxron yuklanayotgan ro‘yxat uchun umumiy skelet (kartochka qatorlari).
/// Statik — reduced motion uchun xavfsiz; ekran o‘quvchisiga bitta yorliq.
class FeListSkeleton extends StatelessWidget {
  const FeListSkeleton({super.key, this.rows = 3, required this.semanticLabel});

  final int rows;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    Widget bar(double widthFactor, double height) => FractionallySizedBox(
      alignment: AlignmentDirectional.centerStart,
      widthFactor: widthFactor,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: c.surfaceSunken,
          borderRadius: BorderRadius.circular(FeRadius.sm),
        ),
      ),
    );
    return Semantics(
      label: semanticLabel,
      liveRegion: true,
      excludeSemantics: true,
      child: Column(
        children: [
          for (var i = 0; i < rows; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: FeSpace.sm),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: c.surfaceRaised,
                  borderRadius: BorderRadius.circular(FeRadius.card),
                  border: Border.all(color: c.border),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(FeSpace.md),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: c.surfaceSunken,
                          borderRadius: BorderRadius.circular(FeRadius.md),
                        ),
                      ),
                      const SizedBox(width: FeSpace.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            bar(0.7, 14),
                            const SizedBox(height: FeSpace.xs),
                            bar(i.isEven ? 0.9 : 0.5, 10),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
