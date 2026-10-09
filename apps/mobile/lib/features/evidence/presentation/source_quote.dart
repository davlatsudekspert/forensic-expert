import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';

/// Manba ichidagi bo‘lim kodini (PMC BioC: `DISCUSS`, `INTRO`…) tanlangan
/// tildagi nomga aylantiradi. Erkin matnli joylashuv (sarlavha, sahifa,
/// raqamli bo‘lim) o‘zgarmaydi.
String localizedSectionName(AppLocalizations l, String locator) {
  final trimmed = locator.trim();
  // Sarlavhasiz kirish qismi (manba pipeline’i yozgan inglizcha izoh).
  if (trimmed.toLowerCase().startsWith('(untitled opening section')) {
    return l.sectionIntroduction;
  }
  // «1. Introduction» → «Introduction» (raqamli prefiks faqat moslash uchun).
  final key = trimmed
      .replaceFirst(RegExp(r'^\d+(\.\d+)*\.?\s+'), '')
      .replaceAll(RegExp(r'[:.]$'), '')
      .toUpperCase();
  return switch (key) {
    'ABSTRACT' => l.sectionAbstract,
    'INTRO' || 'INTRODUCTION' => l.sectionIntroduction,
    'BACKGROUND' => l.sectionBackground,
    'METHODS' || 'MATERIALS AND METHODS' => l.sectionMethods,
    'RESULTS' => l.sectionResults,
    'DISCUSS' || 'DISCUSSION' => l.sectionDiscussion,
    'CONCL' || 'CONCLUSION' || 'CONCLUSIONS' => l.sectionConclusion,
    'CASE' || 'CASE REPORT' || 'CASE PRESENTATION' => l.sectionCaseReport,
    'FIG' => l.sectionFigure,
    'TABLE' => l.sectionTable,
    'SUPPL' => l.sectionSupplement,
    'TITLE' => l.sectionTitle,
    'COMPUTED PROPERTIES' => l.sectionComputedProperties,
    _ => locator,
  };
}

/// «§ Muhokama» — manba ichidagi joy havolasi.
String localizedSectionRef(AppLocalizations l, String locator) =>
    l.sourceSectionRef(localizedSectionName(l, locator));

/// Manbadan aynan iqtibos: asl (inglizcha) matn — dalil, birinchi va
/// o‘zgarmagan holda; tanlangan til uchun avtomatik tarjima bo‘lsa, uning
/// **ostida**, «Avtomatik tarjima · tekshirilmagan» belgisi bilan.
class SourceQuote extends ConsumerWidget {
  const SourceQuote({
    super.key,
    required this.target,
    required this.id,
    required this.text,
    this.label,
    this.originalLang = 'en',
    this.large = false,
  });

  final TextTranslationTarget target;
  final String id;

  /// Asl iqtibos matni.
  final String text;

  /// Iqtibos ustidagi yorliq (masalan «Manbadan iqtibos»).
  final String? label;
  final String originalLang;

  /// Provenance varag‘ida — kattaroq shrift.
  final bool large;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final translation = lang == originalLang
        ? null
        : ref
              .watch(machineTranslationsProvider)
              .lookup(target: target, id: id, source: text, lang: lang);
    final body = large ? t.bodyMedium : t.bodySmall;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Text(label!, style: t.labelSmall?.copyWith(color: c.textSecondary)),
        Text(
          text,
          locale: Locale(originalLang),
          style: body?.copyWith(fontStyle: FontStyle.italic),
        ),
        if (translation != null)
          Semantics(
            key: Key('quote.translation.${target.code}.$id'),
            container: true,
            label: l.quoteMachineTranslationSemantics,
            child: Padding(
              padding: const EdgeInsets.only(top: FeSpace.xs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.translate, size: 14, color: c.textSecondary),
                      const SizedBox(width: FeSpace.xxs),
                      Flexible(
                        child: Text(
                          l.quoteMachineTranslation,
                          style: t.labelSmall?.copyWith(color: c.textSecondary),
                        ),
                      ),
                    ],
                  ),
                  Text(translation, locale: Locale(lang), style: body),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Tadqiqot sarlavhasi: tanlangan tildagi avtomatik tarjima bo‘lsa — u
/// asosiy, asl sarlavha esa ostida ikkinchi darajali matn sifatida
/// («Asl sarlavha: …»). Tarjima bo‘lmasa yoki eskirgan bo‘lsa — faqat asl.
class TranslatedTitle extends ConsumerWidget {
  const TranslatedTitle({
    super.key,
    required this.id,
    required this.title,
    this.style,
    this.maxLines,
    this.selectable = false,
  });

  final String id;
  final String title;
  final TextStyle? style;
  final int? maxLines;
  final bool selectable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final translated = ref
        .watch(machineTranslationsProvider)
        .lookup(
          target: TextTranslationTarget.researchTitle,
          id: id,
          source: title,
          lang: lang,
        );
    Widget text(String s, TextStyle? st, Locale locale) => selectable
        ? SelectableText(s, style: st, maxLines: maxLines)
        : Text(
            s,
            locale: locale,
            style: st,
            maxLines: maxLines,
            overflow: maxLines == null ? null : TextOverflow.ellipsis,
          );
    if (translated == null) return text(title, style, const Locale('en'));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        text(translated, style, Locale(lang)),
        Text(
          l.quoteOriginalTitle(title),
          key: Key('research.originalTitle.$id'),
          locale: const Locale('en'),
          maxLines: maxLines,
          overflow: maxLines == null ? null : TextOverflow.ellipsis,
          style: t.bodySmall?.copyWith(color: c.textSecondary),
        ),
        Text(
          l.quoteMachineTranslation,
          style: t.labelSmall?.copyWith(color: c.textSecondary),
        ),
      ],
    );
  }
}
