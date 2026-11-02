import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/plan.dart';
import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../app/teacher_card.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../domain/catalog/catalog.dart';
import '../../../domain/teacher_card/teacher_card.dart';
import '../../catalog/presentation/catalog_widgets.dart';
import '../../pro/presentation/pro_gate.dart' show proPlanName;
import '../../teacher_card/presentation/teacher_card_widgets.dart';

/// Ustoz profili boshi (egasi so‘rovi, 2026-11-02; namuna — NFC profil):
/// o‘rtada katta dumaloq rasm, ostida ism, ish joyi, toifa, faol reja
/// belgisi, qisqa ma’lumot, tarmoqlar va «Profilni tahrirlash».
/// Ma’lumot «Ustoz kartasi»dan (server) olinadi.
class TeacherProfileHeader extends ConsumerWidget {
  const TeacherProfileHeader({super.key});

  static const photoSize = 128.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final card = ref.watch(myTeacherCardProvider).value?.value;
    final email = ref.watch(authStateProvider).account?.email ?? '';
    final ent = ref.watch(entitlementsProvider).value;
    final plan = ent?.activePlanAt(DateTime.now());
    final name = card?.displayName ?? (email.isEmpty ? '—' : email);

    const coverHeight = 112.0;
    final hasCover = card?.coverPath != null;
    return Container(
      key: const Key('profile.teacherHeader'),
      margin: const EdgeInsets.only(top: FeSpace.sm),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(FeRadius.card),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [c.surfaceSunken, c.surface],
        ),
        border: Border.all(color: c.border),
      ),
      child: Stack(
        children: [
          if (hasCover)
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: coverHeight,
              child: TeacherCoverLayer(
                path: card?.coverPath,
                fallback: const SizedBox.shrink(),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              FeSpace.md,
              FeSpace.lg,
              FeSpace.md,
              FeSpace.md,
            ),
            child: Column(
              children: [
                if (hasCover)
                  const SizedBox(
                    height: coverHeight - FeSpace.lg - (photoSize + 10) / 2,
                  ),
                // Rasm: oltin halqa, soya; bosilsa — tahrirlash.
                Semantics(
                  button: true,
                  label: l.profTeacherEdit,
                  child: GestureDetector(
                    onTap: () => context.push(Routes.teacherCard),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: c.surfaceRaised,
                        border: Border.all(color: c.accent, width: 2),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x2A000000),
                            blurRadius: 18,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: TeacherPhoto(
                        key: const Key('profile.teacherPhoto'),
                        name: name,
                        path: card?.photoPath,
                        size: photoSize,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: FeSpace.md),
                Text(
                  name,
                  key: const Key('profile.teacherName'),
                  textAlign: TextAlign.center,
                  style: t.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (card != null && card.founder) ...[
                  const SizedBox(height: FeSpace.xs),
                  const FounderBadge(),
                ],
                if (card != null && card.workplace.isNotEmpty) ...[
                  const SizedBox(height: FeSpace.xxs),
                  Text(
                    card.workplace,
                    key: const Key('profile.teacherWorkplace'),
                    textAlign: TextAlign.center,
                    style: t.bodyLarge?.copyWith(color: c.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (card?.category case final cat?
                    when cat != TeacherCategory.none)
                  Padding(
                    padding: const EdgeInsets.only(top: FeSpace.xxs),
                    child: Text(
                      teacherCategoryName(l, cat),
                      key: const Key('profile.teacherCategory'),
                      textAlign: TextAlign.center,
                      style: t.titleSmall?.copyWith(color: c.accent),
                    ),
                  ),
                if (plan != null) ...[
                  const SizedBox(height: FeSpace.sm),
                  _PlanBadge(label: proPlanName(l, plan)),
                ],
                if (card != null && card.bio.isNotEmpty) ...[
                  const SizedBox(height: FeSpace.sm),
                  Text(
                    card.bio,
                    key: const Key('profile.teacherBio'),
                    textAlign: TextAlign.center,
                    style: t.bodyMedium,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (card != null && card.socials.isNotEmpty) ...[
                  const SizedBox(height: FeSpace.sm),
                  TeacherSocialRow(card: card, size: 40),
                ],
                if (card == null) ...[
                  const SizedBox(height: FeSpace.xs),
                  Text(
                    l.profTeacherFillHint,
                    textAlign: TextAlign.center,
                    style: t.bodySmall?.copyWith(color: c.textSecondary),
                  ),
                ],
                const SizedBox(height: FeSpace.md),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    key: const Key('profile.teacherEdit'),
                    icon: const Icon(Icons.edit_outlined),
                    label: Text(
                      card == null ? l.profTeacherFill : l.profTeacherEdit,
                    ),
                    onPressed: () => context.push(Routes.teacherCard),
                  ),
                ),
                if (card != null) ...[
                  const SizedBox(height: FeSpace.sm),
                  const CatalogVisibilityTile(kind: CatalogKind.teacher),
                  const SizedBox(height: FeSpace.xs),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        card.visible && !card.hiddenByAdmin
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 16,
                        color: c.textSecondary,
                      ),
                      const SizedBox(width: FeSpace.xxs),
                      Text(
                        card.visible && !card.hiddenByAdmin
                            ? l.profTeacherVisibleOn
                            : l.profTeacherVisibleOff,
                        key: const Key('profile.teacherVisibility'),
                        style: t.bodySmall?.copyWith(color: c.textSecondary),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Faol reja belgisi (masalan, «Ustoz Pro»): qora–oltin kapsula.
class _PlanBadge extends StatelessWidget {
  const _PlanBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    return Container(
      key: const Key('profile.planBadge'),
      padding: const EdgeInsets.symmetric(
        horizontal: FeSpace.md,
        vertical: FeSpace.xs,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: LinearGradient(
          colors: [c.brand, Color.lerp(c.brand, c.accent, 0.7)!],
        ),
        boxShadow: [
          BoxShadow(
            color: c.accent.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.workspace_premium, size: 18, color: c.textOnBrand),
          const SizedBox(width: FeSpace.xs),
          Text(
            label.toUpperCase(),
            style: t.labelLarge?.copyWith(
              color: c.textOnBrand,
              letterSpacing: 1.4,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
