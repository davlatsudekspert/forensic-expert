import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/brand_mark.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/ports/billing_ports.dart';
import '../../../domain/ports/product_tiers.dart';
import 'subscription_ui.dart';

/// Obuna takliflari store’dan yuklanadi. Store ulanmagan bo‘lsa — bo‘sh.
final offersProvider = FutureProvider<List<Offer>>(
  (ref) => ref.watch(entitlementServiceProvider).offers(),
);

/// Paywall — Free / Student Pro / Professional Pro.
///
/// * Narx, valyuta va davr faqat store metadata’sidan ([Offer]); store
///   yo‘q bo‘lsa narx ko‘rsatilmaydi va xarid tugmalari o‘chiq.
/// * Soxta chegirma, taymer, sharh yoki manipulyativ pattern yo‘q.
/// * Xavfsizlik ogohlantirishlari va manbalar hech qachon to‘lov ortida emas.
/// * Institution ommaga ko‘rsatilmaydi.
class PaywallScreen extends ConsumerWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final billing = ref.watch(entitlementServiceProvider);
    final access = ref.watch(accessProvider);
    final offersAsync = ref.watch(offersProvider);
    final offers = offersAsync.value ?? const <Offer>[];
    final loading = offersAsync.isLoading;

    Future<void> buy(Offer o) async {
      final messenger = ScaffoldMessenger.of(context);
      final outcome = await billing.purchase(o.productId);
      final text = switch (outcome) {
        PurchaseOutcome.purchased => l.purchaseSuccess,
        PurchaseOutcome.pending => l.purchasePending,
        PurchaseOutcome.cancelled => l.purchaseCancelled,
        PurchaseOutcome.failed => l.purchaseFailed,
        PurchaseOutcome.unavailable => l.purchaseUnavailableSnack,
      };
      messenger.showSnackBar(SnackBar(content: Text(text)));
    }

    Future<void> restore() async {
      final messenger = ScaffoldMessenger.of(context);
      final e = await billing.restore();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            e.effectiveTier == PlanTier.free
                ? l.restoreNothing
                : l.purchaseOwned,
          ),
        ),
      );
    }

    List<String> features(PlanTier tier) => switch (tier) {
      PlanTier.free => [l.tierFreeF1, l.tierFreeF2, l.tierFreeF3],
      PlanTier.studentPro => [
        l.tierStudentF1,
        l.tierStudentF2,
        l.tierStudentF3,
      ],
      PlanTier.professionalPro => [
        l.tierProF1,
        l.tierProF2,
        l.tierProF3,
        l.tierProF4,
      ],
      PlanTier.institution => const [],
    };

    return Scaffold(
      appBar: AppBar(title: Text(l.purchaseTitle)),
      body: SafeArea(
        child: ListView(
          key: const Key('paywall.list'),
          children: [
            FeContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: FeSpace.sm),
                  const Center(child: BrandMark(size: 48)),
                  const SizedBox(height: FeSpace.md),
                  if (!loading && offers.isEmpty) ...[
                    FeBanner(
                      key: const Key('purchase.storeUnavailable'),
                      icon: Icons.storefront_outlined,
                      text: l.storeNotConnected,
                    ),
                    const SizedBox(height: FeSpace.sm),
                  ],
                  for (final def in ProductTiers.publicTiers)
                    _TierCard(
                      tier: def.tier,
                      current: access.effectiveTier == def.tier,
                      features: features(def.tier),
                      offers: [
                        for (final o in offers)
                          if (o.tier == def.tier) o,
                      ],
                      storeLoading: loading,
                      onBuy: buy,
                    ),
                  const SizedBox(height: FeSpace.sm),
                  OutlinedButton.icon(
                    key: const Key('purchase.restore'),
                    onPressed: restore,
                    icon: const Icon(Icons.restore),
                    label: Text(l.restorePurchases),
                  ),
                  if (access.effectiveTier != PlanTier.free)
                    TextButton(
                      key: const Key('purchase.manage'),
                      onPressed: () => openManageSubscription(
                        context,
                        productId: access.productId,
                      ),
                      child: Text(l.manageSubscription),
                    ),
                  const SizedBox(height: FeSpace.sm),
                  Text(
                    l.subscriptionTerms,
                    key: const Key('purchase.terms'),
                    style: t.bodySmall?.copyWith(color: c.textSecondary),
                  ),
                  Wrap(
                    spacing: FeSpace.sm,
                    children: [
                      TextButton(
                        onPressed: () => context.push(Routes.terms),
                        child: Text(l.termsOfUse),
                      ),
                      TextButton(
                        onPressed: () => context.push(Routes.privacy),
                        child: Text(l.privacyPolicy),
                      ),
                    ],
                  ),
                  FeBanner(
                    key: const Key('purchase.aiNote'),
                    icon: Icons.auto_awesome_outlined,
                    text: l.purchaseAiNote,
                  ),
                  const SizedBox(height: FeSpace.xs),
                  FeBanner(
                    icon: Icons.verified_user_outlined,
                    text: l.subscriptionSafetyNote,
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

class _TierCard extends StatelessWidget {
  const _TierCard({
    required this.tier,
    required this.current,
    required this.features,
    required this.offers,
    required this.storeLoading,
    required this.onBuy,
  });

  final PlanTier tier;
  final bool current;
  final List<String> features;
  final List<Offer> offers;
  final bool storeLoading;
  final Future<void> Function(Offer) onBuy;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final hc = FeTheme.isHighContrast(context);
    final paid = tier != PlanTier.free;
    return Padding(
      key: Key('paywall.tier.${tier.name}'),
      padding: const EdgeInsets.only(bottom: FeSpace.md),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: c.surfaceRaised,
          borderRadius: BorderRadius.circular(FeRadius.lg),
          border: Border.all(
            color: current ? c.accent : (hc ? c.borderStrong : c.border),
            width: current || hc ? 1.5 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(FeSpace.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: FeSpace.sm,
                runSpacing: FeSpace.xxs,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      tierLabel(l, tier),
                      style: t.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (current)
                    StatusChip(
                      key: Key('paywall.current.${tier.name}'),
                      label: l.tierCurrent,
                      icon: Icons.check_circle_outline,
                      color: c.accent,
                    ),
                ],
              ),
              const SizedBox(height: FeSpace.sm),
              for (final f in features)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check, size: 18, color: c.accent),
                      const SizedBox(width: FeSpace.xs),
                      Expanded(child: Text(f, style: t.bodyMedium)),
                    ],
                  ),
                ),
              if (paid) ...[
                const SizedBox(height: FeSpace.sm),
                if (offers.isEmpty)
                  Text(
                    storeLoading ? '…' : l.offerPriceFromStore,
                    key: Key('paywall.noPrice.${tier.name}'),
                    style: t.bodySmall?.copyWith(color: c.textSecondary),
                  ),
                for (final o in offers)
                  Padding(
                    padding: const EdgeInsets.only(top: FeSpace.xs),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 48),
                      child: FilledButton(
                        key: Key('paywall.buy.${o.productId}'),
                        onPressed: current ? null : () => onBuy(o),
                        child: Text(
                          l.offerPriceLine(
                            o.localizedPrice,
                            periodLabel(l, o.period),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                if (offers.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: FeSpace.xs),
                    child: FilledButton(
                      key: Key('paywall.buyDisabled.${tier.name}'),
                      onPressed: null,
                      child: Text(l.offerSubscribe),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
