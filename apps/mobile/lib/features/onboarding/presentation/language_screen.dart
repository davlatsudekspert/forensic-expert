import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/settings/settings_controller.dart';
import '../../../core/widgets/common.dart';

/// Birinchi ishga tushirishdagi **birinchi ekran** — til tanlash.
///
/// Login, reklama yoki boshqa ekran bundan oldin chiqmaydi. Foydalanuvchi
/// hali til tanlamagani uchun sarlavha va til nomlari har biri **o‘z
/// tilida** ko‘rsatiladi (barchasi ARB fayllaridan — hardcoded matn yo‘q).
class LanguageScreen extends ConsumerStatefulWidget {
  const LanguageScreen({super.key});

  @override
  ConsumerState<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends ConsumerState<LanguageScreen> {
  Locale? _selected;

  @override
  void initState() {
    super.initState();
    _selected = ref.read(settingsControllerProvider).locale;
  }

  Future<void> _continue() async {
    final locale = _selected;
    if (locale == null) return;
    await ref.read(settingsControllerProvider.notifier).setLocale(locale);
    if (mounted) context.go(Routes.disclaimer);
  }

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final selected = _selected;
    final continueLabel = lookupAppLocalizations(
      selected ?? Localizations.localeOf(context),
    ).actionContinue;

    return Scaffold(
      body: SafeArea(
        child: FeScrollableBody(
          padding: const EdgeInsets.symmetric(vertical: FeSpace.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const BrandHeader(markSize: 112),
              const SizedBox(height: FeSpace.xl),
              // «Choose your language» — har bir tilda, o‘z tili belgisi bilan.
              Semantics(
                header: true,
                child: Column(
                  children: [
                    for (final locale in SupportedLanguages.locales)
                      _LocalizedText(
                        lookupAppLocalizations(locale).chooseLanguageTitle,
                        locale: locale,
                        style: locale == SupportedLanguages.locales.first
                            ? t.titleMedium?.copyWith(color: c.textPrimary)
                            : t.bodyMedium?.copyWith(color: c.textSecondary),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: FeSpace.lg),
              for (final locale in SupportedLanguages.locales)
                Padding(
                  padding: const EdgeInsets.only(bottom: FeSpace.xs),
                  child: _LanguageOption(
                    locale: locale,
                    selected: selected == locale,
                    onTap: () => setState(() => _selected = locale),
                  ),
                ),
              const SizedBox(height: FeSpace.lg),
              FilledButton(
                key: const Key('language.continue'),
                onPressed: selected == null ? null : _continue,
                child: _LocalizedText(
                  continueLabel,
                  locale: selected ?? Localizations.localeOf(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.locale,
    required this.selected,
    required this.onTap,
  });

  final Locale locale;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    final name = lookupAppLocalizations(locale).languageNameNative;
    return Semantics(
      key: Key('language.option.${locale.languageCode}'),
      inMutuallyExclusiveGroup: true,
      selected: selected,
      button: true,
      attributedLabel: AttributedString(
        name,
        attributes: [
          LocaleStringAttribute(
            range: TextRange(start: 0, end: name.length),
            locale: locale,
          ),
        ],
      ),
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: selected ? c.accentContainer : c.surfaceRaised,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FeRadius.md),
          side: BorderSide(
            color: selected ? c.accent : c.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(FeRadius.md),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: FeSpace.md,
                vertical: FeSpace.sm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: selected ? c.onAccentContainer : c.textPrimary,
                      ),
                    ),
                  ),
                  Icon(
                    selected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: selected ? c.accent : c.borderStrong,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Matnni o‘z tili bilan belgilaydi — ekran o‘quvchisi to‘g‘ri talaffuz qiladi.
class _LocalizedText extends StatelessWidget {
  const _LocalizedText(this.text, {required this.locale, this.style});

  final String text;
  final Locale locale;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) =>
      Text(text, locale: locale, textAlign: TextAlign.center, style: style);
}
