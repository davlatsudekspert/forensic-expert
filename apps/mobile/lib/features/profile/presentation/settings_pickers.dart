import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/settings/settings_controller.dart';
import '../../../core/widgets/fe_components.dart';
import '../../onboarding/presentation/mode_screen.dart';

/// Profil → Til.
class LanguagePickerScreen extends ConsumerWidget {
  const LanguagePickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final current = ref.watch(settingsControllerProvider).locale;
    return Scaffold(
      appBar: AppBar(title: Text(l.settingsLanguage)),
      body: SafeArea(
        child: ListView(
          children: [
            FeContentFrame(
              child: Column(
                children: [
                  for (final locale in SupportedLanguages.locales)
                    ListTile(
                      key: Key('picker.language.${locale.languageCode}'),
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        lookupAppLocalizations(locale).languageNameNative,
                        locale: locale,
                      ),
                      selected: current == locale,
                      trailing: current == locale
                          ? const Icon(Icons.check)
                          : null,
                      onTap: () async {
                        // Avval yopiladi, keyin saqlanadi: sozlama o‘zgarishi
                        // router’ni yangilaydi va yopishdan oldin boshlangan
                        // yangilanish sahifani qaytarib qo‘ymasligi kerak.
                        final notifier = ref.read(
                          settingsControllerProvider.notifier,
                        );
                        if (context.canPop()) context.pop();
                        await notifier.setLocale(locale);
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Profil → Foydalanish rejimi.
class ModePickerScreen extends ConsumerWidget {
  const ModePickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final current = ref.watch(settingsControllerProvider).userMode;
    Future<void> choose(UserMode m) async {
      final notifier = ref.read(settingsControllerProvider.notifier);
      if (context.canPop()) context.pop();
      await notifier.setUserMode(m);
    }

    final options = [
      (
        UserMode.professional,
        Icons.biotech_outlined,
        l.modeProfessional,
        l.modeProfessionalDescription,
      ),
      (
        UserMode.student,
        Icons.school_outlined,
        l.modeStudent,
        l.modeStudentDescription,
      ),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l.settingsMode)),
      body: SafeArea(
        child: FeScrollableBody(
          padding: const EdgeInsets.symmetric(vertical: FeSpace.md),
          child: Column(
            children: [
              FeBanner(
                key: const Key('picker.mode.note'),
                icon: Icons.verified_user_outlined,
                text: l.modeSwitchNote,
              ),
              const SizedBox(height: FeSpace.sm),
              for (final (mode, icon, title, desc) in options) ...[
                ModeOptionCard(
                  key: Key('picker.mode.${mode.name}'),
                  icon: icon,
                  title: title,
                  description: desc,
                  selected: current == mode,
                  onTap: () => choose(mode),
                ),
                const SizedBox(height: FeSpace.sm),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
