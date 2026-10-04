import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_info.dart';
import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/perf/startup_metrics.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/settings/settings_controller.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/ports/backend_ports.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);
    final content = ref.watch(contentStatusProvider);
    final auth = ref.watch(authRepositoryProvider).current;
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
                  FeSectionHeader(l.profileSectionAccount),
                  _Row(
                    key: const Key('profile.subscription'),
                    icon: Icons.workspace_premium_outlined,
                    title: l.subscriptionTitle,
                    value: l.currentPlanFree,
                    onTap: () => context.go(Routes.subscription),
                  ),
                  _Row(
                    icon: Icons.person_outline,
                    title: l.profileTitle,
                    value: l.accountNone,
                  ),
                  // Akkaunt tizimi paydo bo‘lganda ko‘rinadi (Apple 5.1.1(v),
                  // Google Play account deletion).
                  if (auth.status == AuthStatus.signedIn)
                    _Row(
                      key: const Key('profile.deleteAccount'),
                      icon: Icons.delete_outline,
                      title: l.deleteAccount,
                      onTap: () {},
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
