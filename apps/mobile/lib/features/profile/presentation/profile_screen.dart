import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_info.dart';
import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../app/user_data.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/perf/startup_metrics.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/settings/settings_controller.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/ports/billing_ports.dart';
import 'subscription_ui.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);
    final content = ref.watch(contentStatusProvider);
    final authRepo = ref.watch(authRepositoryProvider);
    final authState = ref.watch(authStateProvider);
    final access = ref.watch(accessProvider);
    final t = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final resolver = ref.watch(jurisdictionResolverProvider);
    final jurisdiction =
        resolver.byId(settings.jurisdictionId) ??
        resolver.byId(internationalJurisdictionId)!;

    String modeLabel(UserMode? m) => switch (m) {
      UserMode.professional => l.modeProfessional,
      UserMode.student => l.modeStudent,
      UserMode.research => l.modeResearch,
      null => '—',
    };

    return Scaffold(
      appBar: AppBar(title: Text(l.profileTitle)),
      body: SafeArea(
        child: ListView(
          children: [
            FeContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FeSectionHeader(
                    l.profileSectionPreferences,
                    padding: const EdgeInsets.only(bottom: FeSpace.xs),
                  ),
                  _Row(
                    key: const Key('profile.language'),
                    icon: Icons.language,
                    title: l.settingsLanguage,
                    value: l.languageNameNative,
                    onTap: () => context.go(Routes.profileLanguage),
                  ),
                  _Row(
                    key: const Key('profile.mode'),
                    icon: Icons.tune,
                    title: l.settingsMode,
                    value: modeLabel(settings.userMode),
                    onTap: () => context.go(Routes.profileMode),
                  ),
                  _Row(
                    key: const Key('profile.jurisdiction'),
                    icon: Icons.public,
                    title: l.settingsJurisdiction,
                    value: jurisdiction.name(lang),
                    onTap: () => context.go(Routes.profileJurisdiction),
                  ),
                  const SizedBox(height: FeSpace.sm),
                  Text(l.settingsTheme, style: t.titleSmall),
                  const SizedBox(height: FeSpace.xs),
                  SegmentedButton<ThemeMode>(
                    key: const Key('profile.theme'),
                    showSelectedIcon: false,
                    segments: [
                      ButtonSegment(
                        value: ThemeMode.system,
                        label: Text(l.themeSystem),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        label: Text(l.themeLight),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        label: Text(l.themeDark),
                      ),
                    ],
                    selected: {settings.themeMode},
                    onSelectionChanged: (s) =>
                        controller.setThemeMode(s.single),
                  ),
                  const SizedBox(height: FeSpace.md),
                  Text(l.settingsContrast, style: t.titleSmall),
                  const SizedBox(height: FeSpace.xs),
                  SegmentedButton<ContrastPreference>(
                    key: const Key('profile.contrast'),
                    showSelectedIcon: false,
                    segments: [
                      ButtonSegment(
                        value: ContrastPreference.system,
                        label: Text(l.themeSystem),
                      ),
                      ButtonSegment(
                        value: ContrastPreference.standard,
                        label: Text(l.contrastStandard),
                      ),
                      ButtonSegment(
                        value: ContrastPreference.high,
                        label: Text(l.contrastHigh),
                      ),
                    ],
                    selected: {settings.contrast},
                    onSelectionChanged: (s) => controller.setContrast(s.single),
                  ),
                  const SizedBox(height: FeSpace.xxs),
                  Text(
                    l.contrastSystemHint,
                    style: t.bodySmall?.copyWith(color: c.textSecondary),
                  ),
                  FeSectionHeader(l.accountSection),
                  if (!authState.signedIn) ...[
                    Text(
                      l.accountOptionalNote,
                      key: const Key('profile.accountOptional'),
                      style: t.bodyMedium?.copyWith(color: c.textSecondary),
                    ),
                    if (!authRepo.isConfigured) ...[
                      const SizedBox(height: FeSpace.xs),
                      FeBanner(
                        key: const Key('profile.accountNotConnected'),
                        icon: Icons.cloud_off_outlined,
                        text: l.accountNotConnected,
                      ),
                    ],
                    _Row(
                      key: const Key('profile.signIn'),
                      icon: Icons.login,
                      title: l.accountSignIn,
                      onTap: () => context.push(Routes.accountSignIn),
                    ),
                    _Row(
                      key: const Key('profile.register'),
                      icon: Icons.person_add_alt,
                      title: l.accountCreate,
                      onTap: () => context.push(Routes.accountRegister),
                    ),
                  ] else ...[
                    _Row(
                      key: const Key('profile.accountEmail'),
                      icon: Icons.person_outline,
                      title: authState.account!.email,
                      value: authState.account!.emailVerified
                          ? l.accountVerified
                          : l.accountNotVerified,
                    ),
                    if (!authState.account!.emailVerified)
                      _Row(
                        key: const Key('profile.verify'),
                        icon: Icons.mark_email_unread_outlined,
                        title: l.accountVerifyNow,
                        onTap: () => context.push(
                          Routes.accountVerify,
                          extra: authState.account!.email,
                        ),
                      ),
                    _Row(
                      key: const Key('profile.signOut'),
                      icon: Icons.logout,
                      title: l.accountSignOut,
                      onTap: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        await authRepo.signOut();
                        messenger.showSnackBar(
                          SnackBar(content: Text(l.accountSignedOut)),
                        );
                      },
                    ),
                    // Apple 5.1.1(v), Google Play account deletion.
                    _Row(
                      key: const Key('profile.deleteAccount'),
                      icon: Icons.person_remove_outlined,
                      title: l.deleteAccount,
                      onTap: () => context.push(Routes.accountDelete),
                    ),
                  ],
                  FeSectionHeader(l.subscriptionSection),
                  _Row(
                    key: const Key('profile.purchase'),
                    icon: Icons.workspace_premium_outlined,
                    title: l.planLabel,
                    value: tierLabel(l, access.effectiveTier),
                    onTap: () => context.push(Routes.purchase),
                  ),
                  _Row(
                    key: const Key('profile.subscriptionStatus'),
                    icon: Icons.event_repeat_outlined,
                    title: l.subscriptionStateLabel,
                    value: subscriptionStatusLabel(context, access),
                  ),
                  _Row(
                    key: const Key('profile.restore'),
                    icon: Icons.restore,
                    title: l.restorePurchases,
                    onTap: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final e = await ref
                          .read(entitlementServiceProvider)
                          .restore();
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            e.effectiveTier == PlanTier.free
                                ? l.restoreNothing
                                : l.purchaseOwned,
                          ),
                        ),
                      );
                    },
                  ),
                  if (access.effectiveTier != PlanTier.free)
                    _Row(
                      key: const Key('profile.manage'),
                      icon: Icons.open_in_new,
                      title: l.manageSubscription,
                      onTap: () => openManageSubscription(
                        context,
                        productId: access.productId,
                      ),
                    ),
                  FeSectionHeader(l.profileSectionAccount),
                  _Row(
                    key: const Key('profile.deleteLocalData'),
                    icon: Icons.delete_sweep_outlined,
                    title: l.deleteLocalData,
                    onTap: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(l.deleteLocalData),
                          content: Text(l.deleteLocalDataBody),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: Text(
                                MaterialLocalizations.of(ctx).cancelButtonLabel,
                              ),
                            ),
                            FilledButton(
                              key: const Key('profile.deleteLocalData.confirm'),
                              onPressed: () => Navigator.pop(ctx, true),
                              child: Text(l.deleteLocalDataConfirm),
                            ),
                          ],
                        ),
                      );
                      if (ok == true) {
                        await ref
                            .read(userDataProvider.notifier)
                            .deleteAllLocalData();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l.deleteLocalDataDone)),
                          );
                        }
                      }
                    },
                  ),
                  _Row(
                    icon: Icons.storage_outlined,
                    title: l.scientificDatabaseLabel,
                    value: content.when(
                      data: (s) =>
                          s.packVersion ?? l.scientificDatabaseNotInstalled,
                      loading: () => '…',
                      error: (_, _) => l.scientificDatabaseNotInstalled,
                    ),
                  ),
                  FeSectionHeader(l.profileSectionAbout),
                  _Row(
                    key: const Key('profile.privacy'),
                    icon: Icons.privacy_tip_outlined,
                    title: l.privacyPolicy,
                    onTap: () => context.go(Routes.privacy),
                  ),
                  _Row(
                    key: const Key('profile.terms'),
                    icon: Icons.description_outlined,
                    title: l.termsOfUse,
                    onTap: () => context.go(Routes.terms),
                  ),
                  _Row(
                    key: const Key('profile.disclaimer'),
                    icon: Icons.gavel_outlined,
                    title: l.scientificDisclaimerLink,
                    onTap: () => context.go(Routes.profileDisclaimer),
                  ),
                  _Row(
                    key: const Key('profile.aiDisclaimer'),
                    icon: Icons.auto_awesome_outlined,
                    title: l.aiDisclaimerLink,
                    onTap: () => context.go(Routes.aiDisclaimer),
                  ),
                  _Row(
                    key: const Key('profile.licenses'),
                    icon: Icons.code,
                    title: l.openSourceLicenses,
                    onTap: () => showLicensePage(
                      context: context,
                      applicationName: l.appTitle,
                      applicationVersion: AppInfo.version,
                    ),
                  ),
                  _Row(
                    key: const Key('profile.about'),
                    icon: Icons.info_outline,
                    title: l.aboutApp,
                    value: '${l.appVersionLabel} ${AppInfo.version}',
                    onTap: () => context.go(Routes.about),
                  ),
                  if (kDebugMode || kProfileMode) ...[
                    FeSectionHeader(l.diagnosticsSection),
                    _Diagnostics(color: c.textSecondary),
                    Text(
                      switch (ref.watch(accessProvider).verification) {
                        EntitlementVerification.none => l.diagPurchaseNone,
                        EntitlementVerification.storeConfirmed =>
                          l.diagPurchaseStore,
                        EntitlementVerification.serverVerified =>
                          l.diagPurchaseServer,
                      },
                      key: const Key('diag.purchase'),
                      style: t.bodySmall?.copyWith(color: c.textSecondary),
                    ),
                  ],
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

class _Row extends StatelessWidget {
  const _Row({
    super.key,
    required this.icon,
    required this.title,
    this.value,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      subtitle: value == null ? null : Text(value!),
      trailing: onTap == null ? null : const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _Diagnostics extends StatelessWidget {
  const _Diagnostics({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final m = StartupMetrics.instance;
    final style = FeThemeBuilder.numeric(
      Theme.of(context).textTheme.bodySmall!.copyWith(color: color),
    );
    final first = m[PerfMarks.firstFrame];
    final settings = m['${PerfMarks.settingsLoad}.duration'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          first == null
              ? l.diagnosticsNotMeasured
              : l.diagnosticsStartup(first.inMilliseconds),
          style: style,
        ),
        Text(
          settings == null
              ? l.diagnosticsNotMeasured
              : l.diagnosticsSettingsLoad(settings.inMilliseconds),
          style: style,
        ),
      ],
    );
  }
}
