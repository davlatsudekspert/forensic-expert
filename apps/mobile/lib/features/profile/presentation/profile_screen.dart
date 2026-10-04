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
import '../../../core/widgets/common.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);
    final content = ref.watch(contentStatusProvider);

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
                  _Row(
                    key: const Key('profile.language'),
                    icon: Icons.language,
                    title: l.settingsLanguage,
                    value: l.languageNameNative,
                    onTap: () => context.go(Routes.profileLanguage),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: FeSpace.sm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.settingsTheme,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
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
                      ],
                    ),
                  ),
                  const Divider(),
                  _Row(
                    key: const Key('profile.mode'),
                    icon: Icons.tune,
                    title: l.settingsMode,
                    value: modeLabel(settings.userMode),
                    onTap: () => context.go(Routes.profileMode),
                  ),
                  const Divider(),
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
                    icon: Icons.info_outline,
                    title: l.appVersionLabel,
                    value: AppInfo.version,
                  ),
                  SectionHeading(l.legalSection),
                  _Row(
                    key: const Key('profile.disclaimer'),
                    icon: Icons.gavel_outlined,
                    title: l.scientificDisclaimerLink,
                    onTap: () => context.go(Routes.profileDisclaimer),
                  ),
                  if (kDebugMode || kProfileMode) ...[
                    SectionHeading(l.diagnosticsSection),
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
