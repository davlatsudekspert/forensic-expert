import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/plan.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/plan/plan_models.dart';
import 'pro_gate.dart';

/// Birinchi kirishdagi **bitta** yumshoq taklif (rejimga mos). Bir marta,
/// popup emas: Bosh sahifadagi yopiladigan karta (Apple 3.1.1 / 5.1.1).
class ProFirstOfferCard extends ConsumerWidget {
  const ProFirstOfferCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(proFirstOfferProvider)) return const SizedBox.shrink();
    final ent = ref.watch(entitlementsProvider);
    if (ent.isLoading && !ent.hasValue) return const SizedBox.shrink();
    if (ent.value?.isActive ?? false) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final plan = ref.watch(modePlanProvider);
    final (title, body) = switch (plan) {
      Plan.student => (l.proOfferStudentTitle, l.proOfferStudentBody),
      Plan.teacher => (l.proOfferTeacherTitle, l.proOfferTeacherBody),
      Plan.expert => (l.proOfferExpertTitle, l.proOfferExpertBody),
      Plan.premium => (l.proOfferExpertTitle, l.proOfferExpertBody),
    };
    return Padding(
      padding: const EdgeInsets.only(top: FeSpace.sm),
      child: FeCard(
        key: const Key('pro.firstOffer'),
        color: c.accentContainer,
        padding: const EdgeInsets.fromLTRB(
          FeSpace.md,
          FeSpace.sm,
          FeSpace.xxs,
          FeSpace.sm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(
                Icons.workspace_premium_outlined,
                color: c.onAccentContainer,
              ),
            ),
            const SizedBox(width: FeSpace.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: t.titleSmall?.copyWith(color: c.onAccentContainer),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    body,
                    style: t.bodySmall?.copyWith(color: c.onAccentContainer),
                  ),
                  const SizedBox(height: FeSpace.xs),
                  TextButton(
                    key: const Key('pro.firstOffer.open'),
                    onPressed: () {
                      ref.read(proFirstOfferProvider.notifier).dismiss();
                      openPro(context, plan);
                    },
                    child: Text(l.proOfferOpen),
                  ),
                ],
              ),
            ),
            IconButton(
              key: const Key('pro.firstOffer.dismiss'),
              tooltip: l.proOfferDismiss,
              icon: Icon(Icons.close, color: c.onAccentContainer),
              onPressed: () =>
                  ref.read(proFirstOfferProvider.notifier).dismiss(),
            ),
          ],
        ),
      ),
    );
  }
}
