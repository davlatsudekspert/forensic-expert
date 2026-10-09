import 'package:flutter/material.dart';

import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/professional/professional_models.dart';
import '../professional_strings.dart';

/// Professional maqom chipi. «Tasdiqlangan» ko‘rinishi faqat server
/// bergan `VERIFIED_PROFESSIONAL` uchun.
class VerificationStatusChip extends StatelessWidget {
  const VerificationStatusChip({super.key, required this.status});

  final VerificationStatus status;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final (icon, color) = switch (status) {
      VerificationStatus.verifiedProfessional => (Icons.verified, c.verified),
      VerificationStatus.applicationPending => (
        Icons.hourglass_top,
        c.reviewed,
      ),
      VerificationStatus.changesRequested => (Icons.edit_note, c.warning),
      VerificationStatus.rejected => (Icons.cancel_outlined, c.danger),
      VerificationStatus.suspended => (Icons.pause_circle_outline, c.danger),
      VerificationStatus.unverified => (Icons.help_outline, c.textSecondary),
    };
    return StatusChip(
      key: Key('verif.chip.${status.name}'),
      icon: icon,
      label: l.verificationStatusLabel(status),
      color: color,
    );
  }
}

/// «✓ Tasdiqlangan mutaxassis» — faqat haqiqatan tasdiqlangan profil
/// uchun chiziladi; aks holda hech narsa ko‘rsatilmaydi.
class VerifiedProfessionalBadge extends StatelessWidget {
  const VerifiedProfessionalBadge({super.key, required this.status});

  final VerificationStatus status;

  @override
  Widget build(BuildContext context) {
    if (status != VerificationStatus.verifiedProfessional) {
      return const SizedBox.shrink();
    }
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    return Semantics(
      label: l.verifVerified,
      excludeSemantics: true,
      child: Row(
        key: const Key('badge.verifiedProfessional'),
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified, size: 16, color: c.verified),
          const SizedBox(width: FeSpace.xxs),
          Flexible(
            child: Text(
              l.verifVerified,
              style: Theme.of(context).textTheme.labelMedium
                  ?.copyWith(color: c.verified, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

/// Ochiq professional profil kartasi (faqat ochiq maydonlar).
class PublicProfessionalCard extends StatelessWidget {
  const PublicProfessionalCard({super.key, required this.profile});

  final PublicProfessionalProfile profile;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    return Card(
      key: Key('publicProfile.${profile.userId}'),
      child: Padding(
        padding: const EdgeInsets.all(FeSpace.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(profile.displayName, style: t.titleMedium),
            const SizedBox(height: FeSpace.xxs),
            VerifiedProfessionalBadge(status: profile.status),
            const SizedBox(height: FeSpace.xs),
            Text(l.specialtyLabel(profile.specialty), style: t.bodyMedium),
            if (profile.organization case final o?)
              Text(o, style: t.bodySmall?.copyWith(color: c.textSecondary)),
            Text(
              profile.country,
              style: t.bodySmall?.copyWith(color: c.textSecondary),
            ),
            if (profile.yearsExperience case final y?)
              Text(
                l.proYearsExperience(y),
                style: t.bodySmall?.copyWith(color: c.textSecondary),
              ),
            const SizedBox(height: FeSpace.xs),
            Text(
              l.proReviewCount(profile.reviewCount),
              style: t.bodySmall?.copyWith(color: c.textSecondary),
            ),
            if (profile.reviewScopes.isNotEmpty) ...[
              const SizedBox(height: FeSpace.xs),
              Wrap(
                spacing: FeSpace.xs,
                runSpacing: FeSpace.xxs,
                children: [
                  for (final s in profile.reviewScopes)
                    StatusChip(
                      icon: Icons.rate_review_outlined,
                      label: l.scopeLabel(s),
                      color: c.accent,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Yengil izoh qatori (katta ogohlantirish qutisi o‘rniga).
class FeNote extends StatelessWidget {
  const FeNote({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 16, color: c.textSecondary),
        ),
        const SizedBox(width: FeSpace.xs),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: c.textSecondary),
          ),
        ),
      ],
    );
  }
}

/// Sarlavha + izoh bilan tanlov kartasi (rejim, rol, hujjat turi).
class FeChoiceCard extends StatelessWidget {
  const FeChoiceCard({
    super.key,
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
    this.description,
  });

  final IconData icon;
  final String title;
  final String? description;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: Card(
        clipBehavior: Clip.antiAlias,
        color: selected ? c.accentContainer : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FeRadius.md),
          side: BorderSide(
            color: selected ? c.accent : c.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(FeSpace.md),
            child: Row(
              // Tavsifsiz kartada ikonka, sarlavha va belgi bir o‘qda.
              crossAxisAlignment: description == null
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: selected ? c.surface : c.accentContainer,
                    borderRadius: BorderRadius.circular(FeRadius.sm),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(FeSpace.xs),
                    child: Icon(icon, color: c.accent, size: 24),
                  ),
                ),
                const SizedBox(width: FeSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: t.titleMedium),
                      if (description case final d?) ...[
                        const SizedBox(height: FeSpace.xxs),
                        Text(
                          d,
                          style: t.bodyMedium?.copyWith(color: c.textSecondary),
                        ),
                      ],
                    ],
                  ),
                ),
                ExcludeSemantics(
                  child: Icon(
                    selected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: selected ? c.accent : c.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Majburiy maydon yorlig‘i («Nomi *»).
String requiredLabel(String label) => '$label *';
