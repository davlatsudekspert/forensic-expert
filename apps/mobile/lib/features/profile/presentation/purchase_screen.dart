import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/brand_mark.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/ports/billing_ports.dart';

/// Lifetime taklifi store’dan yuklanadi. Store ulanmagan bo‘lsa — bo‘sh.
final offersProvider = FutureProvider<List<Offer>>(
  (ref) => ref.watch(entitlementServiceProvider).offers(),
);

/// FORENSIC EXPERT Lifetime — bir martalik xarid ekrani.
///
/// * Narx store’dan ([Offer.localizedPrice]). Store yo‘q bo‘lsa —
///   [BillingConfig.referenceLifetimePrice] «reference» izohi bilan va
///   xarid tugmasi o‘chirilgan.
/// * Soxta chegirma, taymer, sharh yoki manipulyativ pattern yo‘q.
/// * Xavfsizlik ma’lumotlari va manbalar hech qachon to‘lov ortida emas.
class PurchaseScreen extends ConsumerWidget {
  const PurchaseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final billing = ref.watch(entitlementServiceProvider);
    final owned = ref.watch(accessProvider).hasFullAccess;
    final offers = ref.watch(offersProvider).value ?? const <Offer>[];
    Offer? lifetime;
    for (final o in offers) {
      if (o.productId == ProductIds.lifetime) lifetime = o;
    }
    final storePrice = lifetime?.localizedPrice;
    final price = storePrice ?? BillingConfig.referenceLifetimePrice;

    final values = [
      (Icons.menu_book_outlined, l.purchaseValueReference),
      (Icons.calculate_outlined, l.purchaseValueTools),
      (Icons.verified_outlined, l.purchaseValueSources),
      (Icons.offline_pin_outlined, l.purchaseValueOffline),
      (Icons.school_outlined, l.purchaseValueLearning),
      (Icons.update, l.purchaseValueUpdates),
    ];

    Future<void> buy() async {
      final messenger = ScaffoldMessenger.of(context);
      final outcome = await billing.purchase(ProductIds.lifetime);
      final text = switch (outcome) {
        PurchaseOutcome.purchased => l.purchaseSuccess,
        PurchaseOutcome.pending => l.purchasePending,
        PurchaseOutcome.cancelled => l.purchaseCancelled,
        PurchaseOutcome.failed => l.purchaseFailed,
        PurchaseOutcome.unavailable => l.purchaseUnavailableSnack,
      };
      messenger.showSnackBar(SnackBar(content: Text(text)));
    }

    return Scaffold(
      appBar: AppBar(title: Text(l.purchaseTitle)),
      body: SafeArea(
        child: ListView(
          children: [
            FeContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Hero(price: price, isReferencePrice: storePrice == null),
                  const SizedBox(height: FeSpace.lg),
                  for (final (icon, text) in values)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: c.accentContainer,
                              borderRadius: BorderRadius.circular(FeRadius.sm),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: Icon(
                                icon,
                                size: 20,
                                color: c.onAccentContainer,
                              ),
                            ),
                          ),
                          const SizedBox(width: FeSpace.sm),
                          Expanded(child: Text(text, style: t.bodyLarge)),
                        ],
                      ),
                    ),
                  const SizedBox(height: FeSpace.lg),
                  if (owned)
                    FeBanner(
                      key: const Key('purchase.owned'),
                      icon: Icons.check_circle_outline,
                      text: l.purchaseOwned,
                    )
                  else ...[
                    if (lifetime == null) ...[
                      FeBanner(
                        key: const Key('purchase.storeUnavailable'),
                        icon: Icons.storefront_outlined,
                        text: l.storeNotConnected,
                      ),
                      const SizedBox(height: FeSpace.sm),
                    ],
                    ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 52),
                      child: FilledButton(
                        key: const Key('purchase.cta'),
                        onPressed: lifetime == null ? null : buy,
                        child: Text(l.purchaseCta),
                      ),
                    ),
                    const SizedBox(height: FeSpace.xs),
                    Text(
                      l.purchaseFooter,
                      key: const Key('purchase.footer'),
                      textAlign: TextAlign.center,
                      style: t.bodySmall?.copyWith(color: c.textSecondary),
                    ),
                  ],
                  const SizedBox(height: FeSpace.xs),
                  TextButton(
                    key: const Key('purchase.restore'),
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final e = await billing.restore();
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            e.hasFullAccess
                                ? l.purchaseOwned
                                : l.restoreNothing,
                          ),
                        ),
                      );
                    },
                    child: Text(l.restorePurchases),
                  ),
                  FeSectionHeader(l.purchaseFreeTitle),
                  Text(
                    l.purchaseFreeBody,
                    style: t.bodyMedium?.copyWith(color: c.textSecondary),
                  ),
                  const SizedBox(height: FeSpace.md),
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

class _Hero extends StatelessWidget {
  const _Hero({required this.price, required this.isReferencePrice});

  final String price;
  final bool isReferencePrice;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final hc = FeTheme.isHighContrast(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.surfaceRaised,
        borderRadius: BorderRadius.circular(FeRadius.lg),
        border: Border.all(
          color: hc ? c.borderStrong : c.border,
          width: hc ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          FeSpace.lg,
          FeSpace.xl,
          FeSpace.lg,
          FeSpace.lg,
        ),
        child: Column(
          children: [
            const BrandMark(size: 56),
            const SizedBox(height: FeSpace.md),
            Text(
              l.appTitle,
              textAlign: TextAlign.center,
              style: t.labelLarge?.copyWith(
                letterSpacing: 2.4,
                fontWeight: FontWeight.w700,
                color: c.textSecondary,
              ),
            ),
            const SizedBox(height: FeSpace.xs),
            // Tor ekran / katta shriftda kichikroq uslub: so‘z bo‘linmaydi.
            LayoutBuilder(
              builder: (context, box) {
                final narrow =
                    box.maxWidth / MediaQuery.textScalerOf(context).scale(1) <
                    300;
                return Semantics(
                  header: true,
                  child: Text(
                    l.purchaseTitle,
                    textAlign: TextAlign.center,
                    style: (narrow ? t.headlineSmall : t.headlineMedium)
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                );
              },
            ),
            const SizedBox(height: FeSpace.sm),
            Text(
              l.purchasePriceLine(price),
              key: const Key('purchase.price'),
              textAlign: TextAlign.center,
              style: t.titleMedium?.copyWith(
                color: c.accent,
                fontWeight: FontWeight.w600,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            if (isReferencePrice) ...[
              const SizedBox(height: FeSpace.xs),
              Text(
                l.purchaseReferencePriceNote,
                key: const Key('purchase.referenceNote'),
                textAlign: TextAlign.center,
                style: t.bodySmall?.copyWith(color: c.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
