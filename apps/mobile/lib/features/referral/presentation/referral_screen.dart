import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/referral.dart';
import '../../../app/routes.dart';
import '../../../app/share.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/referral/referral_models.dart';
import '../../professional/presentation/professional_widgets.dart';

/// «Hamkasbingizni taklif qiling»: o‘z kodi/havolasi, ulashish, agregat
/// statistika va FORENSIC Credits izohi. Hech qanday shaxsiy ma’lumot
/// (taklif qilinganlarning email/ismi) ko‘rsatilmaydi.
class ReferralScreen extends ConsumerWidget {
  const ReferralScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final result = ref.watch(referralDashboardProvider);
    final auth = ref.watch(authStateProvider);
    final configured = ref.watch(referralServiceProvider).isConfigured;
    final dashboard = result.value?.dashboard;

    final Widget body = switch (result) {
      AsyncData(:final value) when value.dashboard != null => _Dashboard(
        dashboard: value.dashboard!,
      ),
      AsyncData(:final value) => switch (value.failure) {
        ReferralFailure.notConfigured => FeNote(
          key: const Key('referral.notConfigured'),
          icon: Icons.cloud_off_outlined,
          text: l.referralNotConfigured,
        ),
        ReferralFailure.notSignedIn => const _SignInCard(),
        _ => _ErrorCard(
          onRetry: () => ref.invalidate(referralDashboardProvider),
        ),
      },
      AsyncError() => _ErrorCard(
        onRetry: () => ref.invalidate(referralDashboardProvider),
      ),
      _ => const _Skeleton(),
    };

    // Kod kiritish: kirmagan foydalanuvchi uchun lokal saqlanadi; kirgan va
    // hali taklif bog‘lanmagan yangi akkaunt uchun serverga yuboriladi.
    final showClaim =
        configured &&
        (!auth.signedIn || (dashboard != null && !dashboard.hasReferrer));

    return Scaffold(
      appBar: AppBar(title: Text(l.referralTitle)),
      body: SafeArea(
        child: ListView(
          key: const Key('referral.list'),
          padding: const EdgeInsets.only(bottom: FeSpace.xl),
          children: [
            FeContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _Header(),
                  const SizedBox(height: FeSpace.md),
                  AnimatedSwitcher(
                    duration: FeMotion.of(context, FeMotion.standard),
                    child: KeyedSubtree(
                      key: ValueKey(result.runtimeType),
                      child: body,
                    ),
                  ),
                  if (dashboard?.hasReferrer ?? false) ...[
                    const SizedBox(height: FeSpace.md),
                    FeNote(
                      key: const Key('referral.linked'),
                      icon: Icons.handshake_outlined,
                      text: l.referralLinkedNote,
                    ),
                  ],
                  if (showClaim) const _ClaimSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final stacked = MediaQuery.textScalerOf(context).scale(1) >= 1.6;
    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            l.referralTitle,
            // ×2 shriftda so‘z o‘rtasidan bo‘linmasin — sarlavha masshtabi
            // cheklanadi (baribir yirik).
            textScaler: MediaQuery.textScalerOf(context)
                .clamp(maxScaleFactor: 1.3),
            style: t.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: FeSpace.xxs),
        Text(
          l.referralLead,
          textScaler: MediaQuery.textScalerOf(context)
              .clamp(maxScaleFactor: 1.6),
          style: t.bodySmall?.copyWith(
            color: const Color(0xFFC9D2E0),
            height: 1.45,
          ),
        ),
      ],
    );
    return DecoratedBox(
      key: const Key('referral.header'),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F1E3D), Color(0xFF16324F)],
        ),
        borderRadius: BorderRadius.circular(FeRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(FeSpace.md),
        child: Flex(
          // Katta matnda belgi matn ustida — matn to‘liq kenglikni oladi.
          direction: stacked ? Axis.vertical : Axis.horizontal,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFC9A75E), width: 1.5),
              ),
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(
                  Icons.group_add_outlined,
                  color: Color(0xFFE6D3A3),
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: FeSpace.sm, height: FeSpace.sm),
            Flexible(fit: stacked ? FlexFit.loose : FlexFit.tight, child: text),
          ],
        ),
      ),
    );
  }
}

class _Dashboard extends ConsumerWidget {
  const _Dashboard({required this.dashboard});

  final ReferralDashboard dashboard;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    final links = ref.watch(referralLinksProvider);
    final link = links.inviteLink(dashboard.code)?.toString();
    final percent = dashboard.rewardPercent == dashboard.rewardPercent.round()
        ? dashboard.rewardPercent.round().toString()
        : dashboard.rewardPercent.toStringAsFixed(1);

    Future<void> copy(String text) async {
      await Clipboard.setData(ClipboardData(text: text));
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l.referralCopied)));
    }

    return Column(
      key: const Key('referral.dashboard'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FeCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.referralYourCode.toUpperCase(),
                style: t.labelSmall?.copyWith(
                  color: c.textSecondary,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: FeSpace.xs),
              Row(
                children: [
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart,
                      child: SelectableText(
                        dashboard.code,
                        key: const Key('referral.code'),
                        style: FeThemeBuilder.numeric(t.headlineSmall!)
                            .copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 4,
                              color: c.textPrimary,
                            ),
                      ),
                    ),
                  ),
                  IconButton(
                    key: const Key('referral.copyCode'),
                    tooltip: l.referralCopy,
                    icon: const Icon(Icons.copy_rounded),
                    onPressed: () => copy(dashboard.code),
                  ),
                ],
              ),
              const Divider(height: FeSpace.lg),
              if (link != null) ...[
                Text(
                  l.referralYourLink,
                  style: t.labelSmall?.copyWith(color: c.textSecondary),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        link,
                        key: const Key('referral.link'),
                        style: FeThemeBuilder.numeric(t.bodySmall!)
                            .copyWith(color: c.accent),
                      ),
                    ),
                    IconButton(
                      key: const Key('referral.copyLink'),
                      tooltip: l.referralCopy,
                      icon: const Icon(Icons.link_rounded),
                      onPressed: () => copy(link),
                    ),
                  ],
                ),
              ] else
                Text(
                  l.referralNoLinkNote,
                  key: const Key('referral.noLink'),
                  style: t.bodySmall?.copyWith(color: c.textSecondary),
                ),
              const SizedBox(height: FeSpace.md),
              Builder(
                builder: (bc) => FilledButton.icon(
                  key: const Key('referral.share'),
                  icon: const Icon(Icons.ios_share_rounded),
                  label: Text(l.referralShare),
                  onPressed: () => ref
                      .read(shareServiceProvider)
                      .shareText(
                        link != null
                            ? l.referralShareWithLink(link)
                            : l.referralShareWithCode(dashboard.code),
                        subject: l.referralShareSubject,
                        origin: shareOriginOf(bc),
                      ),
                ),
              ),
            ],
          ),
        ),
        FeSectionHeader(l.referralStatsTitle),
        _Stats(dashboard: dashboard),
        const SizedBox(height: FeSpace.sm),
        if (dashboard.creditsPendingMinor > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: FeSpace.xs),
            child: Text(
              l.referralCreditsPending(
                formatCredits(dashboard.creditsPendingMinor),
              ),
              style: t.bodySmall?.copyWith(color: c.textSecondary),
            ),
          ),
        FeNote(
          key: const Key('referral.creditsNote'),
          icon: Icons.workspace_premium_outlined,
          text: dashboard.rewardsEnabled
              ? l.referralCreditsActive(percent)
              : l.referralCreditsFuture(percent),
        ),
        const SizedBox(height: FeSpace.xs),
        FeNote(
          key: const Key('referral.privacy'),
          icon: Icons.lock_outline,
          text: l.referralPrivacyNote,
        ),
      ],
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats({required this.dashboard});

  final ReferralDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    final stats = <(String, String, bool)>[
      ('${dashboard.joined}', l.referralStatJoined, false),
      ('${dashboard.verified}', l.referralStatVerified, true),
      ('${dashboard.pending}', l.referralStatPending, false),
      (
        formatCredits(dashboard.creditsEarnedMinor),
        l.referralStatCredits,
        false,
      ),
    ];
    return LayoutBuilder(
      builder: (context, box) {
        final scale = MediaQuery.textScalerOf(context).scale(1);
        // So‘zlar bo‘linmasligi uchun telefonda 2×2; keng ekranda 4 ustun.
        final cols = box.maxWidth >= 520 && scale < 1.6 ? 4 : 2;
        const gap = FeSpace.xs;
        final w = (box.maxWidth - gap * (cols - 1)) / cols;
        return Wrap(
          key: const Key('referral.stats'),
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final (value, label, emphasis) in stats)
              SizedBox(
                width: w,
                child: Semantics(
                  label: [label, value].join(': '),
                  excludeSemantics: true,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: emphasis ? c.accentContainer : c.surface,
                      borderRadius: BorderRadius.circular(FeRadius.md),
                      border: Border.all(color: c.border),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: FeSpace.xs,
                        vertical: FeSpace.sm,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(
                              value,
                              style: FeThemeBuilder.numeric(t.titleLarge!)
                                  .copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: emphasis
                                        ? c.onAccentContainer
                                        : c.textPrimary,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            label,
                            style: t.labelSmall?.copyWith(
                              color: emphasis
                                  ? c.onAccentContainer
                                  : c.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SignInCard extends StatelessWidget {
  const _SignInCard();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    return FeCard(
      key: const Key('referral.signIn'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.referralSignInTitle, style: t.titleMedium),
          const SizedBox(height: FeSpace.xxs),
          Text(
            l.referralSignInBody,
            style: t.bodySmall?.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: FeSpace.md),
          FilledButton.icon(
            key: const Key('referral.signInAction'),
            icon: const Icon(Icons.mail_outline),
            label: Text(l.emailCodeTitle),
            onPressed: () => context.push(Routes.accountEmailCode),
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return FeCard(
      key: const Key('referral.error'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FeNote(icon: Icons.wifi_off_outlined, text: l.referralLoadError),
          const SizedBox(height: FeSpace.sm),
          OutlinedButton(onPressed: onRetry, child: Text(l.referralRetry)),
        ],
      ),
    );
  }
}

/// Yuklanish skeleti (spinner o‘rniga, sahifa tuzilishini saqlaydi).
class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    Widget bar(double w, double h) => Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: c.surfaceSunken,
        borderRadius: BorderRadius.circular(FeRadius.sm),
      ),
    );
    return FeCard(
      key: const Key('referral.loading'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          bar(120, 10),
          const SizedBox(height: FeSpace.sm),
          bar(200, 28),
          const SizedBox(height: FeSpace.md),
          bar(double.infinity, 44),
        ],
      ),
    );
  }
}

class _ClaimSection extends ConsumerStatefulWidget {
  const _ClaimSection();

  @override
  ConsumerState<_ClaimSection> createState() => _ClaimSectionState();
}

class _ClaimSectionState extends ConsumerState<_ClaimSection> {
  final _ctl = TextEditingController();
  String? _message;
  bool _ok = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _ctl.text = ref.read(pendingReferralProvider).code ?? '';
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  String _text(AppLocalizations l, ReferralClaimOutcome o) => switch (o) {
    ReferralClaimOutcome.valid => l.referralClaimValid,
    ReferralClaimOutcome.pendingVerification => l.referralClaimPending,
    ReferralClaimOutcome.invalidCode => l.referralClaimInvalid,
    ReferralClaimOutcome.selfReferral => l.referralClaimSelf,
    ReferralClaimOutcome.alreadyAttributed => l.referralClaimAlready,
    ReferralClaimOutcome.notEligible => l.referralClaimNotEligible,
    ReferralClaimOutcome.rateLimited => l.referralClaimRateLimited,
    ReferralClaimOutcome.notSignedIn => l.referralClaimSaved,
    ReferralClaimOutcome.offline => l.referralClaimOffline,
    ReferralClaimOutcome.notConfigured => l.referralNotConfigured,
    ReferralClaimOutcome.server => l.referralLoadError,
  };

  Future<void> _apply() async {
    final l = AppLocalizations.of(context);
    if (ReferralCode.normalize(_ctl.text) == null) {
      setState(() {
        _message = l.referralClaimFormat;
        _ok = false;
      });
      return;
    }
    setState(() => _busy = true);
    final ctl = ref.read(pendingReferralProvider.notifier);
    await ctl.remember(_ctl.text);
    if (!mounted) return;
    final signedIn = ref.read(authStateProvider).signedIn;
    final outcome = signedIn
        ? ref.read(pendingReferralProvider).lastOutcome
        : ReferralClaimOutcome.notSignedIn;
    setState(() {
      _busy = false;
      _ok =
          outcome == null ||
          outcome.accepted ||
          outcome == ReferralClaimOutcome.notSignedIn;
      _message = _text(l, outcome ?? ReferralClaimOutcome.notSignedIn);
    });
    if (outcome?.accepted ?? false) unawaited(HapticFeedback.lightImpact());
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    return Column(
      key: const Key('referral.claim'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FeSectionHeader(l.referralHaveCode),
        Text(
          l.referralHaveCodeHint,
          style: t.bodySmall?.copyWith(color: c.textSecondary),
        ),
        const SizedBox(height: FeSpace.sm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                key: const Key('referral.codeField'),
                controller: _ctl,
                textCapitalization: TextCapitalization.characters,
                autocorrect: false,
                enableSuggestions: false,
                maxLength: 9,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9 -]')),
                ],
                style: FeThemeBuilder.numeric(t.bodyLarge!)
                    .copyWith(letterSpacing: 2),
                decoration: InputDecoration(
                  labelText: l.referralCodeField,
                  counterText: '',
                ),
                onSubmitted: (_) => _apply(),
              ),
            ),
            const SizedBox(width: FeSpace.xs),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: FilledButton.tonal(
                key: const Key('referral.apply'),
                onPressed: _busy ? null : _apply,
                child: Text(l.referralApply),
              ),
            ),
          ],
        ),
        AnimatedSize(
          duration: FeMotion.of(context, FeMotion.fast),
          child: _message == null
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: const EdgeInsets.only(top: FeSpace.xs),
                  child: Row(
                    children: [
                      Icon(
                        _ok ? Icons.check_circle_outline : Icons.info_outline,
                        size: 18,
                        color: _ok ? c.verified : c.textSecondary,
                      ),
                      const SizedBox(width: FeSpace.xs),
                      Expanded(
                        child: Text(
                          _message!,
                          key: const Key('referral.claimMessage'),
                          style: t.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}
