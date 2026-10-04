import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/ports/billing_ports.dart';

/// Takliflar store’dan yuklanadi; yuklanmaguncha yoki store ulanmagan
/// bo‘lsa — «Narx mavjud emas». **Narxlar hech qachon kodda yo‘q.**
final offersProvider = FutureProvider<List<Offer>>(
  (ref) => ref.watch(entitlementServiceProvider).offers(),
);

enum _Cell { no, yes, limited, basic, extended, full }

/// Tariflarni taqqoslash (Free · Student Pro · Professional Pro).
class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final billing = ref.watch(entitlementServiceProvider);
    final current = billing.current.tier;
    final offers = ref.watch(offersProvider).value ?? const <Offer>[];

    String? priceFor(PlanTier tier) {
      for (final o in offers) {
        if (o.tier == tier) return o.localizedPrice;
      }
      return null;
    }

    final rows = <(String, List<_Cell>)>[
      (l.featLibrary, const [_Cell.limited, _Cell.extended, _Cell.full]),
      (l.featLabTools, const [_Cell.basic, _Cell.basic, _Cell.full]),
      (l.featLearning, const [_Cell.limited, _Cell.full, _Cell.basic]),
      (l.featAdvancedTools, const [_Cell.no, _Cell.no, _Cell.yes]),
      (l.featAi, const [_Cell.limited, _Cell.limited, _Cell.extended]),
      (l.featOffline, const [_Cell.yes, _Cell.yes, _Cell.yes]),
      (l.featSafety, const [_Cell.yes, _Cell.yes, _Cell.yes]),
    ];

    final plans = [
      (PlanTier.free, l.planFree),
      (PlanTier.studentPro, l.planStudentPro),
      (PlanTier.professionalPro, l.planProfessionalPro),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l.subscriptionTitle)),
      body: SafeArea(
        child: ListView(
          children: [
            FeContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (offers.isEmpty)
                    FeBanner(
                      key: const Key('subscription.storeUnavailable'),
                      icon: Icons.storefront_outlined,
                      text: l.storeNotConnected,
                    ),
                  for (var p = 0; p < plans.length; p++) ...[
                    const SizedBox(height: FeSpace.md),
                    _PlanCard(
                      key: Key('plan.${plans[p].$1.name}'),
                      title: plans[p].$2,
                      isCurrent: current == plans[p].$1,
                      price: plans[p].$1 == PlanTier.free
                          ? null
                          : (priceFor(plans[p].$1) ?? l.priceUnavailable),
                      canSubscribe:
                          plans[p].$1 != PlanTier.free &&
                          priceFor(plans[p].$1) != null,
                      features: [
                        for (final (name, cells) in rows) (name, cells[p]),
                      ],
                    ),
                  ],
                  const SizedBox(height: FeSpace.md),
                  FeBanner(
                    icon: Icons.verified_user_outlined,
                    text: l.subscriptionSafetyNote,
                  ),
                  const SizedBox(height: FeSpace.md),
                  OutlinedButton.icon(
                    key: const Key('subscription.restore'),
                    icon: const Icon(Icons.restore),
                    label: Text(l.restorePurchases),
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      await billing.restore();
                      messenger.showSnackBar(
                        SnackBar(content: Text(l.restoreNothing)),
                      );
                    },
                  ),
                  TextButton(
                    key: const Key('subscription.manage'),
                    onPressed: null,
                    child: Text(l.manageSubscription),
                  ),
                  Text(
                    l.storeNotConnected,
                    style: t.bodySmall?.copyWith(color: c.textSecondary),
                  ),
                  const SizedBox(height: FeSpace.xl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    super.key,
    required this.title,
    required this.isCurrent,
    required this.price,
    required this.canSubscribe,
    required this.features,
  });

  final String title;
  final bool isCurrent;
  final String? price;
  final bool canSubscribe;
  final List<(String, _Cell)> features;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;

    (IconData, String, Color) cell(_Cell v) => switch (v) {
      _Cell.no => (Icons.remove, l.valueNotIncluded, c.textSecondary),
      _Cell.yes => (Icons.check, l.valueIncluded, c.verified),
      _Cell.limited => (Icons.check, l.valueLimited, c.textPrimary),
      _Cell.basic => (Icons.check, l.valueBasic, c.textPrimary),
      _Cell.extended => (Icons.check, l.valueExtended, c.textPrimary),
      _Cell.full => (Icons.check, l.valueFull, c.verified),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.surfaceRaised,
        borderRadius: BorderRadius.circular(FeRadius.md),
        border: Border.all(
          color: isCurrent ? c.accent : c.border,
          width: isCurrent ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(FeSpace.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: FeSpace.xs,
              runSpacing: FeSpace.xxs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Semantics(
                  header: true,
                  child: Text(title, style: t.titleMedium),
                ),
                if (isCurrent)
                  StatusChip(
                    icon: Icons.check_circle_outline,
                    label: l.planCurrent,
                    color: c.accent,
                  ),
              ],
            ),
            if (price != null) ...[
              const SizedBox(height: FeSpace.xxs),
              Text(
                price!,
                key: Key('plan.price.$title'),
                style: t.bodyMedium?.copyWith(color: c.textSecondary),
              ),
            ],
            const SizedBox(height: FeSpace.sm),
            for (final (name, v) in features)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: LayoutBuilder(
                  builder: (context, box) {
                    final value = Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(cell(v).$1, size: 16, color: cell(v).$3),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            cell(v).$2,
                            style: t.bodySmall?.copyWith(color: cell(v).$3),
                          ),
                        ),
                      ],
                    );
                    // Tor ekran / katta shrift: qiymat nom ostida (so‘zlar
                    // bo‘linmasligi uchun).
                    final narrow =
                        box.maxWidth /
                            MediaQuery.textScalerOf(context).scale(1) <
                        260;
                    if (narrow) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: t.bodyMedium),
                          Padding(
                            padding: const EdgeInsets.only(left: FeSpace.sm),
                            child: value,
                          ),
                        ],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: Text(name, style: t.bodyMedium)),
                        const SizedBox(width: FeSpace.xs),
                        Flexible(child: value),
                      ],
                    );
                  },
                ),
              ),
            if (price != null) ...[
              const SizedBox(height: FeSpace.sm),
              FilledButton(
                onPressed: canSubscribe ? () {} : null,
                child: Text(l.subscribeAction),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
