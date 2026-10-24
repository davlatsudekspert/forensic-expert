import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/plan.dart';
import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/date_format.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/plan/plan_models.dart';
import '../../../domain/ports/plan_ports.dart';
import 'pro_gate.dart';

/// Pro sahifasi (bitta joy): rejimga mos reja, narx (faqat do‘kondan),
/// muddat, sinov, avto-uzayish, bekor qilish yo‘li, «Xaridlarni tiklash»,
/// Shartlar va Maxfiylik (Apple 3.1.1 / 3.1.2).
class ProScreen extends ConsumerStatefulWidget {
  const ProScreen({super.key, this.plan});

  /// Ko‘rsatiladigan reja; `null` — joriy rejimga mos reja.
  final Plan? plan;

  @override
  ConsumerState<ProScreen> createState() => _ProScreenState();
}

class _ProScreenState extends ConsumerState<ProScreen> {
  /// Foydalanuvchi tanlagan ko‘rinish: `true` — Premium (hammasi ochiq).
  late bool _premium = widget.plan == Plan.premium;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final Plan modePlan = widget.plan == Plan.premium || widget.plan == null
        ? ref.watch(modePlanProvider)
        : widget.plan!;
    final Plan shown = _premium ? Plan.premium : modePlan;
    final signedIn = ref.watch(authStateProvider).signedIn;
    final ent = ref.watch(entitlementsProvider);
    final value = ent.value ?? Entitlements.none;
    return Scaffold(
      appBar: AppBar(title: FeAppBarTitle(l.proTitle)),
      body: SafeArea(
        child: ListView(
          key: const Key('pro.list'),
          children: [
            FeContentFrame(
              child: Padding(
                padding: const EdgeInsets.only(bottom: FeSpace.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: FeSpace.sm),
                    _StatusCard(ent: value, loading: ent.isLoading),
                    _Includes(plan: shown),
                    _PremiumSwitch(
                      premium: _premium,
                      onChanged: (v) => setState(() => _premium = v),
                    ),
                    if (!signedIn)
                      const _GuestCard()
                    else ...[
                      _Purchase(plan: shown, ent: value),
                      const _FlowMessage(),
                    ],
                    const _SubscriptionTerms(),
                    FeBanner(
                      key: const Key('pro.freeAlways'),
                      icon: Icons.health_and_safety_outlined,
                      text: l.proFreeAlways,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Joriy holat: bepul / sinov / faol (muddati).
class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.ent, required this.loading});

  final Entitlements ent;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final active = ent.isActive;
    final plan = ent.plan;
    final String title;
    final String? detail;
    final Key key;
    if (!active || plan == null) {
      key = const Key('pro.state.free');
      title = l.proStateFree;
      detail = loading ? null : l.proStateFreeBody;
    } else if (ent.isTrial) {
      key = const Key('pro.state.trial');
      title = l.proStateTrial(proPlanName(l, plan));
      detail = ent.expiresAt == null
          ? null
          : l.proStateUntil(feDate(context, ent.expiresAt!.toLocal()));
    } else {
      key = const Key('pro.state.active');
      title = l.proStateActive(proPlanName(l, plan));
      detail = ent.expiresAt == null
          ? l.proStateNoEnd
          : '${l.proStateUntil(feDate(context, ent.expiresAt!.toLocal()))}'
                ' · ${ent.autoRenew ? l.proAutoRenewOn : l.proAutoRenewOff}';
    }
    return FeCard(
      key: key,
      color: active ? c.accentContainer : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            active ? Icons.workspace_premium : Icons.workspace_premium_outlined,
            color: active ? c.onAccentContainer : c.accent,
          ),
          const SizedBox(width: FeSpace.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: t.titleSmall?.copyWith(
                    color: active ? c.onAccentContainer : null,
                  ),
                ),
                if (detail != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    detail,
                    style: t.bodySmall?.copyWith(
                      color: active ? c.onAccentContainer : c.textSecondary,
                    ),
                  ),
                ],
                if (active && ent.source != null) ...[
                  const SizedBox(height: FeSpace.xxs),
                  Text(
                    switch (ent.source!) {
                      PlanSource.store => l.proSourceStore,
                      PlanSource.admin => l.proSourceAdmin,
                      PlanSource.trial => l.proSourceTrial,
                    },
                    key: const Key('pro.state.source'),
                    style: t.labelSmall?.copyWith(color: c.onAccentContainer),
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

/// Reja nimalarni ochadi (faqat o‘z rejimidagi funksiyalar).
class _Includes extends StatelessWidget {
  const _Includes({required this.plan});

  final Plan plan;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final items = switch (plan) {
      Plan.student => [
        l.proIncludesStudent1,
        l.proIncludesStudent2,
        l.proIncludesStudent3,
        l.proIncludesStudent4,
      ],
      Plan.teacher => [
        l.proIncludesTeacher1,
        l.proIncludesTeacher2,
        l.proIncludesTeacher3,
        l.proIncludesTeacher4,
      ],
      Plan.expert => [
        l.proIncludesExpert1,
        l.proIncludesExpert2,
        l.proIncludesExpert3,
        l.proIncludesExpert4,
      ],
      Plan.premium => [
        l.proIncludesPremium1,
        l.proIncludesPremium2,
        l.proIncludesPremium3,
      ],
    };
    return Column(
      key: Key('pro.includes.${plan.name}'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FeSectionHeader(proPlanName(l, plan)),
        for (final s in items)
          Padding(
            padding: const EdgeInsets.only(bottom: FeSpace.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_circle_outline, size: 20, color: c.verified),
                const SizedBox(width: FeSpace.xs),
                Expanded(child: Text(s, style: t.bodyMedium)),
              ],
            ),
          ),
        const SizedBox(height: FeSpace.xxs),
        if (plan != Plan.premium)
          Text(
            l.proOwnModeNote,
            key: const Key('pro.ownModeNote'),
            style: t.bodySmall?.copyWith(color: c.textSecondary),
          ),
        if (plan == Plan.teacher) ...[
          const SizedBox(height: FeSpace.xxs),
          Text(
            l.proTeacherRoleNote,
            key: const Key('pro.teacherRoleNote'),
            style: t.bodySmall?.copyWith(color: c.textSecondary),
          ),
        ],
      ],
    );
  }
}

/// «Eng qulay: Premium» kartasi / o‘z rejaga qaytish.
class _PremiumSwitch extends StatelessWidget {
  const _PremiumSwitch({required this.premium, required this.onChanged});

  final bool premium;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: FeSpace.sm),
      child: premium
          ? TextButton(
              key: const Key('pro.premium.back'),
              onPressed: () => onChanged(false),
              child: Text(l.proPremiumBack),
            )
          : FeCard(
              key: const Key('pro.premium.card'),
              color: c.accentContainer,
              onTap: () => onChanged(true),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l.proPremiumBest, style: t.titleSmall),
                        const SizedBox(height: FeSpace.xxs),
                        Text(
                          l.proPremiumBody,
                          style: t.bodySmall?.copyWith(
                            color: c.onAccentContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                  FilledButton.tonal(
                    key: const Key('pro.premium.see'),
                    onPressed: () => onChanged(true),
                    child: Text(l.proPremiumSee),
                  ),
                ],
              ),
            ),
    );
  }
}

/// Mehmon: Pro uchun hisob kerak (reja serverda hisobga bog‘lanadi).
class _GuestCard extends StatelessWidget {
  const _GuestCard();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: FeSpace.md),
      child: FeCard(
        key: const Key('pro.guest'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l.proGuestTitle,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: FeSpace.xxs),
            Text(l.proGuestBody),
            const SizedBox(height: FeSpace.sm),
            FilledButton(
              key: const Key('pro.guest.signIn'),
              onPressed: () => context.push(Routes.accountEmailCode),
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, FeTouch.minTarget),
              ),
              child: Text(l.proGuestSignIn),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mahsulotlar (narx do‘kondan), sinov, sotib olish, tiklash.
class _Purchase extends ConsumerWidget {
  const _Purchase({required this.plan, required this.ent});

  final Plan plan;
  final Entitlements ent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final flow = ref.watch(proFlowProvider);
    final busy = flow == ProFlow.working;
    final products = ref.watch(storeProductsProvider(plan));
    final storeOk = ref.watch(storeAvailableProvider).value ?? false;
    final list = products.value ?? const <StoreProduct>[];
    final hasThis =
        ent.isActive && (ent.plan == plan || ent.plan == Plan.premium);
    final trialOk =
        ent.trialAvailable && !ent.isActive && ent.source != PlanSource.trial;
    final controller = ref.read(proFlowProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FeSectionHeader(l.proChoose),
        if (hasThis)
          Text(
            l.proAlreadyActive,
            key: const Key('pro.alreadyActive'),
            style: t.bodyMedium,
          )
        else if (products.isLoading)
          FeListSkeleton(rows: 2, semanticLabel: l.loadingContent)
        else if (list.isEmpty)
          FeBanner(
            key: const Key('pro.storeUnavailable'),
            icon: Icons.storefront_outlined,
            tone: FeBannerTone.warning,
            text: storeOk ? l.proStoreNoProducts : l.proStoreUnavailable,
          )
        else
          for (final p in list)
            Padding(
              padding: const EdgeInsets.only(bottom: FeSpace.xs),
              child: FeCard(
                key: Key('pro.product.${p.period.name}'),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.period == PlanPeriod.monthly
                                ? l.proMonthly
                                : l.proYearly,
                            style: t.titleSmall,
                          ),
                          Text(
                            p.price,
                            key: Key('pro.price.${p.period.name}'),
                            style: t.bodyMedium?.copyWith(
                              color: c.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FilledButton(
                      key: Key('pro.buy.${p.period.name}'),
                      onPressed: busy ? null : () => controller.buy(p),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, FeTouch.minTarget),
                      ),
                      child: Text(l.proBuy),
                    ),
                  ],
                ),
              ),
            ),
        if (trialOk) ...[
          const SizedBox(height: FeSpace.xs),
          OutlinedButton.icon(
            key: const Key('pro.trial'),
            onPressed: busy ? null : () => controller.claimTrial(plan),
            icon: const Icon(Icons.card_giftcard_outlined),
            label: Text(l.proTrialButton),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, FeTouch.minTarget),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: FeSpace.xxs),
            child: Text(
              l.proTrialNote,
              key: const Key('pro.trialNote'),
              style: t.bodySmall?.copyWith(color: c.textSecondary),
            ),
          ),
        ],
        const SizedBox(height: FeSpace.xs),
        TextButton.icon(
          key: const Key('pro.restore'),
          onPressed: busy ? null : controller.restore,
          icon: const Icon(Icons.restore),
          label: Text(l.proRestore),
        ),
      ],
    );
  }
}

/// Oxirgi amal natijasi (halol holat matni).
class _FlowMessage extends ConsumerWidget {
  const _FlowMessage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final flow = ref.watch(proFlowProvider);
    if (flow == ProFlow.idle) return const SizedBox.shrink();
    if (flow == ProFlow.working) {
      return Padding(
        padding: const EdgeInsets.only(top: FeSpace.xs),
        child: Row(
          key: const Key('pro.flow.working'),
          children: [
            const SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: FeSpace.xs),
            Expanded(child: Text(l.proFlowWorking)),
          ],
        ),
      );
    }
    final (icon, text, tone) = switch (flow) {
      ProFlow.success => (
        Icons.check_circle_outline,
        l.proFlowSuccess,
        FeBannerTone.info,
      ),
      ProFlow.pending => (
        Icons.hourglass_empty,
        l.proFlowPending,
        FeBannerTone.info,
      ),
      ProFlow.canceled => (
        Icons.info_outline,
        l.proFlowCanceled,
        FeBannerTone.info,
      ),
      ProFlow.storeNotConfigured => (
        Icons.build_circle_outlined,
        l.proFlowStoreNotConfigured,
        FeBannerTone.warning,
      ),
      ProFlow.invalid => (
        Icons.error_outline,
        l.proFlowInvalid,
        FeBannerTone.warning,
      ),
      ProFlow.offline => (
        Icons.wifi_off_rounded,
        l.proFlowOffline,
        FeBannerTone.warning,
      ),
      ProFlow.restoreNothing => (
        Icons.info_outline,
        l.proFlowRestoreNothing,
        FeBannerTone.info,
      ),
      ProFlow.trialUsedDevice => (
        Icons.info_outline,
        l.proTrialUsedDevice,
        FeBannerTone.info,
      ),
      ProFlow.trialUsedAccount => (
        Icons.info_outline,
        l.proTrialUsedAccount,
        FeBannerTone.info,
      ),
      ProFlow.trialHasPlan => (
        Icons.info_outline,
        l.proTrialHasPlan,
        FeBannerTone.info,
      ),
      ProFlow.trialUnavailable => (
        Icons.info_outline,
        l.proTrialUnavailable,
        FeBannerTone.info,
      ),
      _ => (Icons.error_outline, l.proFlowError, FeBannerTone.warning),
    };
    return Padding(
      padding: const EdgeInsets.only(top: FeSpace.xs),
      child: FeBanner(
        key: Key('pro.flow.${flow.name}'),
        icon: icon,
        text: text,
        tone: tone,
      ),
    );
  }
}

/// Obuna shartlari (Apple 3.1.2): davr, narx do‘kondan, avto-uzayish,
/// bekor qilish yo‘li, Shartlar va Maxfiylik.
class _SubscriptionTerms extends StatelessWidget {
  const _SubscriptionTerms();

  static final _appleManage = Uri.parse(
    'https://apps.apple.com/account/subscriptions',
  );
  static final _playManage = Uri.parse(
    'https://play.google.com/store/account/subscriptions',
  );

  Future<void> _open(BuildContext context, Uri uri) async {
    final messenger = ScaffoldMessenger.of(context);
    final failed = AppLocalizations.of(context).proManageFailed;
    var ok = false;
    try {
      ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Object {
      ok = false;
    }
    if (!ok) messenger.showSnackBar(SnackBar(content: Text(failed)));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final ios = defaultTargetPlatform == TargetPlatform.iOS;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FeSectionHeader(l.proTermsTitle),
        Text(
          l.proTermsBody,
          key: const Key('pro.terms'),
          style: t.bodySmall?.copyWith(color: c.textSecondary),
        ),
        const SizedBox(height: FeSpace.xs),
        Text(
          ios ? l.proCancelHowIos : l.proCancelHowAndroid,
          key: const Key('pro.cancelHow'),
          style: t.bodySmall?.copyWith(color: c.textSecondary),
        ),
        const SizedBox(height: FeSpace.xs),
        OutlinedButton.icon(
          key: const Key('pro.manage'),
          onPressed: () => _open(context, ios ? _appleManage : _playManage),
          icon: const Icon(Icons.open_in_new, size: 18),
          label: Text(l.proManage),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, FeTouch.minTarget),
          ),
        ),
        Wrap(
          alignment: WrapAlignment.start,
          children: [
            TextButton(
              key: const Key('pro.termsLink'),
              onPressed: () => context.push(Routes.terms),
              child: Text(l.proTermsLink),
            ),
            TextButton(
              key: const Key('pro.privacyLink'),
              onPressed: () => context.push(Routes.privacy),
              child: Text(l.proPrivacyLink),
            ),
          ],
        ),
        const SizedBox(height: FeSpace.xs),
      ],
    );
  }
}
