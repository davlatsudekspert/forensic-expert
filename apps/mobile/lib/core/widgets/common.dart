import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter/material.dart';

import '../design/theme.dart';
import '../design/tokens.dart';
import '../l10n/generated/app_localizations.dart';
import 'brand_mark.dart';

/// Brend sarlavhasi: belgi + «FORENSIC EXPERT» + tagline.
class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key, this.markSize = 72});

  final double markSize;

  @override
  Widget build(BuildContext context) {
    // Brend nomi va tagline barcha tillarda bir xil; manbasi — ARB.
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    return Semantics(
      container: true,
      header: true,
      child: Column(
        children: [
          BrandMark(size: markSize),
          const SizedBox(height: FeSpace.md),
          Text(
            l.appTitle,
            textAlign: TextAlign.center,
            style: t.titleLarge?.copyWith(
              letterSpacing: 2.4,
              fontWeight: FontWeight.w700,
              color: c.textPrimary,
            ),
          ),
          const SizedBox(height: FeSpace.xxs),
          Text(
            l.appTagline,
            textAlign: TextAlign.center,
            style: t.bodyMedium?.copyWith(
              color: c.textSecondary,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

/// Ilmiy review statusi belgisi — rang + ikonka + matn (faqat rangga
/// tayanmaydi: accessibility).
/// Ilmiy kontent tekshiruv holati. `compact` — ro‘yxatlar uchun ixcham
/// (✓ / ○ / ! / ×) belgi va xira matn; to‘liq izoh tafsilot/provenance
/// sahifasida. Hech qachon inson tasdig‘ini nazarda tutmaydi, agar u
/// bo‘lmasa.
class ReviewStatusBadge extends StatelessWidget {
  const ReviewStatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  final ScientificStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final (label, color, icon) = switch (status) {
      ScientificStatus.verified => (
        l.statusVerified,
        c.verified,
        Icons.verified_outlined,
      ),
      ScientificStatus.reviewed => (
        l.statusReviewed,
        c.reviewed,
        Icons.fact_check_outlined,
      ),
      ScientificStatus.needsReview => (
        l.statusNeedsReview,
        c.warning,
        Icons.pending_outlined,
      ),
      ScientificStatus.outdated => (
        l.statusOutdated,
        c.outdated,
        Icons.history,
      ),
      ScientificStatus.rejected => (l.statusRejected, c.danger, Icons.block),
      ScientificStatus.draft => (
        l.statusDraft,
        c.textSecondary,
        Icons.edit_note_outlined,
      ),
    };
    if (compact) {
      final glyph = switch (status) {
        ScientificStatus.verified || ScientificStatus.reviewed => Icons.check,
        ScientificStatus.needsReview => Icons.radio_button_unchecked,
        ScientificStatus.outdated => Icons.priority_high,
        ScientificStatus.rejected => Icons.close,
        ScientificStatus.draft => Icons.edit_outlined,
      };
      return Semantics(
        label: label,
        excludeSemantics: true,
        child: Row(
          key: Key('status.compact.${status.name}'),
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(glyph, size: 13, color: color),
            const SizedBox(width: 3),
            Flexible(
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelSmall
                    ?.copyWith(color: c.textSecondary),
              ),
            ),
          ],
        ),
      );
    }
    return Semantics(
      label: label,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: FeSpace.xxs),
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium
                  ?.copyWith(color: color, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

/// «MA’LUMOT TEKSHIRILMAGAN — EKSPERT TASDIG‘I KERAK» banneri.
class UnverifiedBanner extends StatelessWidget {
  const UnverifiedBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    return Semantics(
      container: true,
      liveRegion: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: c.warningContainer,
          borderRadius: BorderRadius.circular(FeRadius.sm),
          border: Border.all(color: c.warning),
        ),
        child: Padding(
          padding: const EdgeInsets.all(FeSpace.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.warning_amber_rounded, color: c.onWarningContainer),
              const SizedBox(width: FeSpace.xs),
              Expanded(
                child: Text(
                  AppLocalizations.of(context).unverifiedBanner,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: c.onWarningContainer,
                    fontWeight: FontWeight.w700,
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

/// Bo‘lim sarlavhasi (screen reader uchun header).
class SectionHeading extends StatelessWidget {
  const SectionHeading(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Semantics(
    header: true,
    child: Padding(
      padding: const EdgeInsets.only(top: FeSpace.lg, bottom: FeSpace.xs),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    ),
  );
}
