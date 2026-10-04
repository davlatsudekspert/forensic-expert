import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/design/theme.dart';
import '../core/l10n/generated/app_localizations.dart';
import '../core/settings/app_settings.dart';
import '../core/settings/settings_controller.dart';
import 'router.dart';

class ForensicExpertApp extends ConsumerWidget {
  const ForensicExpertApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(
      settingsControllerProvider.select((s) => s.locale),
    );
    final themeMode = ref.watch(
      settingsControllerProvider.select((s) => s.themeMode),
    );
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      routerConfig: router,
      locale: locale,
      supportedLocales: SupportedLanguages.locales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      localeResolutionCallback: (device, supported) {
        if (device != null) {
          for (final s in supported) {
            if (s.languageCode == device.languageCode) return s;
          }
        }
        return supported.first;
      },
      theme: FeThemeBuilder.light(),
      darkTheme: FeThemeBuilder.dark(),
      themeMode: themeMode,
    );
  }
}
