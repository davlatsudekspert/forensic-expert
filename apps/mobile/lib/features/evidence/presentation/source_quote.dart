import 'package:flutter/material.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import 'localized_content.dart';

export 'localized_content.dart';

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

/// Manbadan aynan iqtibos (egasi talabi, 2026-10-09): UI tilidagi
/// tarjima **birinchi**, ostida holat belgisi («Avtomatik tarjima —
/// tekshirilmagan»), asl iqtibos esa «Asl matn» orqali ochiladi (dalil —
/// o‘zgartirilmaydi). Tarjima bo‘lmasa — bu ochiq aytiladi va asl iqtibos
/// ko‘rsatiladi.
class SourceQuote extends StatelessWidget {
  const SourceQuote({
    super.key,
    required this.kind,
    required this.id,
    required this.text,
    this.label,
    this.originalLang = 'en',
    this.large = false,
  });

  /// `text_translations.target_type` (masalan [ContentTextKind.claimExcerpt]).
  final String kind;
  final String id;

  /// Asl iqtibos matni.
  final String text;

  /// Iqtibos ustidagi yorliq (masalan «Manbadan iqtibos»).
  final String? label;
  final String originalLang;

  /// Provenance varag‘ida — kattaroq shrift.
  final bool large;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return LocalizedContentText(
      kind: kind,
      id: id,
      source: text,
      originalLang: originalLang,
      quote: true,
      label: label,
      // Tarjima ko‘rsatilganda yorliq buni aytadi.
      translatedLabel: label == null
          ? null
          : AppLocalizations.of(context).trQuoteTranslatedLabel,
      style: large ? t.bodyMedium : t.bodySmall,
    );
  }
}
