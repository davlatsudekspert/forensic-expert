import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/design/theme.dart';
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
                        await ref
                            .read(settingsControllerProvider.notifier)
                            .setLocale(locale);
                        if (context.mounted) context.pop();
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
      await ref.read(settingsControllerProvider.notifier).setUserMode(m);
      if (context.mounted) context.pop();
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
      (
        UserMode.research,
        Icons.menu_book_outlined,
        l.modeResearch,
        l.modeResearchDescription,
      ),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l.settingsMode)),
      body: SafeArea(
        child: FeScrollableBody(
          padding: const EdgeInsets.symmetric(vertical: FeSpace.md),
          child: Column(
            children: [
              for (final (mode, icon, title, desc) in options) ...[
                ModeOptionCard(
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

/// Profil → Yurisdiksiya. Faqat huquqiy/protsessual qatlamni tanlaydi;
/// ilmiy dalillar (Global Scientific Core) o‘zgarmaydi.
class JurisdictionPickerScreen extends ConsumerWidget {
  const JurisdictionPickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final current = ref.watch(settingsControllerProvider).jurisdictionId;
    final all = ref.watch(jurisdictionResolverProvider).jurisdictions;
    final global = [
      for (final j in all)
        if (j.level == JurisdictionLevel.international ||
            j.level == JurisdictionLevel.supranational)
          j,
    ];
    final countries = [
      for (final j in all)
        if (j.level == JurisdictionLevel.country) j,
    ]..sort((a, b) => a.name(lang).compareTo(b.name(lang)));

    Widget tile(Jurisdiction j) {
      final selected = j.id == current;
      return ListTile(
        key: Key('picker.jurisdiction.${j.id}'),
        contentPadding: EdgeInsets.zero,
        leading: SizedBox(
          width: 36,
          child: Text(
            j.iso3166 ?? j.id,
            style: FeThemeBuilder.numeric(
              Theme.of(context).textTheme.labelLarge!,
            ),
          ),
        ),
        title: Text(j.name(lang)),
        selected: selected,
        trailing: selected ? const Icon(Icons.check) : null,
        onTap: () async {
          await ref
              .read(settingsControllerProvider.notifier)
              .setJurisdiction(j.id);
          if (context.mounted) context.pop();
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l.settingsJurisdiction)),
      body: SafeArea(
        child: ListView(
          children: [
            FeContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FeBanner(
                    icon: Icons.layers_outlined,
                    text: l.jurisdictionPickerIntro,
                  ),
                  FeSectionHeader(l.jurisdictionGroupGlobal),
                  for (final j in global) tile(j),
                  FeSectionHeader(l.jurisdictionGroupCountries),
                  for (final j in countries) tile(j),
                  const SizedBox(height: FeSpace.md),
                  ListTile(
                    key: const Key('jurisdiction.compare'),
                    contentPadding: EdgeInsets.zero,
                    enabled: false,
                    leading: const Icon(Icons.compare_outlined),
                    title: Text(l.jurisdictionCompare),
                    subtitle: Text(l.jurisdictionCompareSoon),
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
