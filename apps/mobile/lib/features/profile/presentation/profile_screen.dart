import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/account.dart';
import '../../../app/app_info.dart';
import '../../../app/professional.dart';
import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../app/support.dart';
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
import '../../../domain/ports/professional_ports.dart';
import '../../../domain/professional/professional_models.dart';
import '../../professional/presentation/professional_widgets.dart';
import '../../professional/presentation/verification_screens.dart';
import '../../professional/professional_strings.dart';
import '../../referral/presentation/invite_card.dart';
import '../../support/presentation/support_widgets.dart';
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
    final localProfile = ref.watch(localProfileProvider);
    final verification =
        ref.watch(professionalSnapshotProvider).value ??
        ProfessionalSnapshot.empty;
    final identity = verification.identity;
    final pendingDocs = ref.watch(pendingCredentialsProvider).length;
    final t = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final unread = ref.watch(supportUnreadProvider).value ?? 0;
    final resolver = ref.watch(jurisdictionResolverProvider);
    final jurisdiction =
        resolver.byId(settings.jurisdictionId) ??
        resolver.byId(internationalJurisdictionId)!;

    String modeLabel(UserMode? m) => switch (m) {
      UserMode.professional => l.modeProfessional,
      UserMode.student => l.modeStudent,
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
                  _IdentityCard(
                    mode: settings.userMode,
                    declaredRole: settings.declaredRole,
                    profile: localProfile,
                  ),
                  // Hisob — sarlavha kartasidan darhol keyin.
                  FeSectionHeader(l.accountSection),
                  if (!authState.signedIn) ...[
                    Text(
                      l.accountOptionalNote,
                      key: const Key('profile.accountOptional'),
                      style: t.bodyMedium?.copyWith(color: c.textSecondary),
                    ),
                    if (!authRepo.isConfigured) ...[
                      // Akkaunt xizmati ulanmagan: ishlamaydigan kirish
                      // tugmalari ko‘rsatilmaydi — faqat aniq izoh.
                      const SizedBox(height: FeSpace.xs),
                      FeBanner(
                        key: const Key('profile.accountNotConnected'),
                        icon: Icons.cloud_off_outlined,
                        text: l.accountNotConnected,
                      ),
                    ] else ...[
                      // Bitta kirish yo‘li: email kod (parol bilan kirish va
                      // ro‘yxatdan o‘tish qatorlari ko‘rsatilmaydi).
                      _Row(
                        key: const Key('profile.emailCode'),
                        icon: Icons.login,
                        title: l.accountSignInEmailCode,
                        value: l.emailCodeRowHint,
                        onTap: () => context.push(Routes.accountEmailCode),
                      ),
                    ],
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
                  if (ref.watch(supportAvailableProvider)) ...[
                    if (unread > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: FeSpace.xs),
                        child: FeCard(
                          key: const Key('profile.supportBanner'),
                          color: c.accentContainer,
                          padding: const EdgeInsets.all(FeSpace.sm),
                          onTap: () => context.push(Routes.support),
                          child: Row(
                            children: [
                              Icon(
                                Icons.mark_chat_unread_outlined,
                                color: c.onAccentContainer,
                              ),
                              const SizedBox(width: FeSpace.sm),
                              Expanded(
                                child: Text(
                                  l.supBannerText,
                                  style: t.bodyMedium?.copyWith(
                                    color: c.onAccentContainer,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: c.onAccentContainer,
                              ),
                            ],
                          ),
                        ),
                      ),
                    _Row(
                      key: const Key('profile.support'),
                      icon: Icons.forum_outlined,
                      title: l.supTitle,
                      value: unread > 0
                          ? l.supUnreadHint(unread)
                          : l.supProfileHint,
                      trailing: unread > 0
                          ? SupportUnreadBadge(count: unread)
                          : null,
                      onTap: () => context.push(Routes.support),
                    ),
                  ],
                  const SizedBox(height: FeSpace.sm),
                  const InviteColleagueCard(key: Key('profile.invite')),
                  if (ref.watch(serverAccessProvider).value?.isAdmin ?? false)
                    _Row(
                      key: const Key('profile.admin'),
                      icon: Icons.admin_panel_settings_outlined,
                      title: l.adminTitle,
                      value: l.adminProfileHint,
                      onTap: () => context.push(Routes.admin),
                    ),
                  FeSectionHeader(l.profileSectionVerification),
                  if (settings.userMode == UserMode.student)
                    Padding(
                      padding: const EdgeInsets.only(bottom: FeSpace.xs),
                      child: FeNote(
                        key: const Key('profile.studentNoVerification'),
                        icon: Icons.school_outlined,
                        text: l.profileStudentVerificationNote,
                      ),
                    ),
                  _Row(
                    key: const Key('profile.verification'),
                    icon: Icons.verified_user_outlined,
                    title: l.verifTitle,
                    valueWidget: VerificationStatusChip(
                      status: verification.status,
                    ),
                    onTap: () => context.push(Routes.verification),
                  ),
                  _Row(
                    key: const Key('profile.credentials'),
                    icon: Icons.upload_file_outlined,
                    title: l.credUploadTitle,
                    value: pendingDocs == 0
                        ? l.credOptional
                        : l.credSelectedCount(pendingDocs),
                    onTap: () => context.push(Routes.verificationDocuments),
                  ),
                  if (identity != null &&
                      identity.isVerifiedProfessional &&
                      identity.scopes.isNotEmpty)
                    _Row(
                      key: const Key('profile.reviewDashboard'),
                      icon: Icons.rate_review_outlined,
                      title: l.dashboardTitle,
                      onTap: () => context.push(Routes.reviewDashboard),
                    ),
                  FeSectionHeader(l.profileSectionPreferences),
                  _Row(
                    key: const Key('profile.language'),
                    icon: Icons.language,
                    title: l.settingsLanguage,
                    value: l.languageNameNative,
                    onTap: () => context.push(Routes.profileLanguage),
                  ),
                  _Row(
                    key: const Key('profile.mode'),
                    icon: Icons.tune,
                    title: l.settingsMode,
                    value: modeLabel(settings.userMode),
                    onTap: () => context.push(Routes.profileMode),
                  ),
                  _Row(
                    key: const Key('profile.jurisdiction'),
                    icon: Icons.public,
                    title: l.settingsJurisdiction,
                    value: jurisdiction.name(lang),
                    onTap: () => context.push(Routes.profileJurisdiction),
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
                  FeSectionHeader(l.profileSectionData),
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
                        await ref.read(localProfileProvider.notifier).clear();
                        ref.read(pendingCredentialsProvider.notifier).clear();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l.deleteLocalDataDone)),
                          );
                        }
                      }
                    },
                  ),
                  _Row(
                    key: const Key('profile.privacy'),
                    icon: Icons.privacy_tip_outlined,
                    title: l.privacyPolicy,
                    onTap: () => context.push(Routes.privacy),
                  ),
                  FeSectionHeader(l.profileSectionAbout),
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
                  _Row(
                    key: const Key('profile.terms'),
                    icon: Icons.description_outlined,
                    title: l.termsOfUse,
                    onTap: () => context.push(Routes.terms),
                  ),
                  _Row(
                    key: const Key('profile.disclaimer'),
                    icon: Icons.gavel_outlined,
                    title: l.scientificDisclaimerLink,
                    onTap: () => context.push(Routes.profileDisclaimer),
                  ),
                  _Row(
                    key: const Key('profile.aiDisclaimer'),
                    icon: Icons.auto_awesome_outlined,
                    title: l.aiDisclaimerLink,
                    onTap: () => context.push(Routes.aiDisclaimer),
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
                    onTap: () => context.push(Routes.about),
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
    this.valueWidget,
    this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String? value;
  final Widget? valueWidget;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      subtitle: switch (valueWidget) {
        final w? => Padding(
          padding: const EdgeInsets.only(top: FeSpace.xxs),
          child: Align(alignment: AlignmentDirectional.centerStart, child: w),
        ),
        null => value == null ? null : Text(value!),
      },
      trailing: switch ((trailing, onTap)) {
        (final w?, _) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [w, const Icon(Icons.chevron_right)],
        ),
        (null, null) => null,
        _ => const Icon(Icons.chevron_right),
      },
      onTap: onTap,
    );
  }
}

/// Profil kartasi: ism (bo‘lsa), foydalanish rejimi, rol. Professional
/// rejim — maqom emas; maqom alohida «Tasdiqlash» bo‘limida.
class _IdentityCard extends StatelessWidget {
  const _IdentityCard({
    required this.mode,
    required this.declaredRole,
    required this.profile,
  });

  final UserMode? mode;
  final String? declaredRole;
  final LocalUserProfile profile;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final isStudent = mode == UserMode.student;
    final name = isStudent
        ? profile.student?.fullName
        : profile.professional?.fullName;
    final role = isStudent
        ? switch (StudentRole.values.asNameMap()[declaredRole] ??
              profile.student?.role) {
            final r? => l.studentRoleLabel(r),
            null => null,
          }
        : switch (ProfessionalRole.values.asNameMap()[declaredRole] ??
              profile.professional?.role) {
            final r? => l.professionalRoleLabel(r),
            null => null,
          };
    final subtitle = [
      isStudent ? l.modeStudent : l.modeProfessional,
      ?role,
      if (!isStudent)
        if (profile.professional case final p?)
          l.specialtyLabel(p.primarySpecialty),
    ].join(' · ');
    final display = (name == null || name.isEmpty) ? null : name;
    final initials = display
        ?.trim()
        .split(RegExp(r'\s+'))
        .take(2)
        .map((w) => w.characters.first.toUpperCase())
        .join();
    const muted = Color(0xFFC9D2E0);
    return Padding(
      padding: const EdgeInsets.only(top: FeSpace.sm),
      child: Material(
        key: const Key('profile.identityCard'),
        borderRadius: BorderRadius.circular(FeRadius.lg),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0F1E3D), Color(0xFF17305A)],
            ),
          ),
          child: InkWell(
            onTap: () => context.push(Routes.profileEdit),
            child: Padding(
              padding: const EdgeInsets.all(FeSpace.md),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0x1AFFFFFF),
                      border: Border.all(
                        color: const Color(0xFFC9A75E),
                        width: 1.5,
                      ),
                    ),
                    child: initials != null
                        ? Text(
                            initials,
                            style: t.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          )
                        : Icon(
                            isStudent
                                ? Icons.school_outlined
                                : Icons.biotech_outlined,
                            color: muted,
                          ),
                  ),
                  const SizedBox(width: FeSpace.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          display ?? l.profileNotFilled,
                          style: t.titleMedium?.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: FeSpace.xxs),
                        Text(
                          subtitle,
                          style: t.bodySmall?.copyWith(color: muted),
                        ),
                        const SizedBox(height: FeSpace.xs),
                        Text(
                          name == null
                              ? l.profileFillAction
                              : l.profileEditAction,
                          style: t.labelMedium?.copyWith(
                            color: const Color(0xFF7FDDE6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: muted),
                ],
              ),
            ),
          ),
        ),
      ),
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
