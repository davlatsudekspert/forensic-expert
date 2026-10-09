import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter/material.dart';

import '../../../core/design/theme.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../evidence/presentation/localized_content.dart';

/// Huquqiy hujjat nomi UI tilida: `titles[lang]` → rasmiy asl til
/// (`instrument.language`) → `en` → hujjat ID. Holat: rasmiy tildagi nom —
/// «Rasmiy nomi»; boshqa tildagisi — norasmiy tarjima (`translation_status`,
/// yo‘q bo‘lsa — tekshirilmagan).
LocalizedContent instrumentTitleOf(JurisdictionalInstrument i, String lang) =>
    resolveLocalizedMap(
      {
        for (final e in i.titles.entries)
          if (!e.key.startsWith('_')) e.key: e.value,
      },
      lang: lang,
      originalLang: i.language,
      translationStatus: i.translationStatus?.code,
      fallbackText: i.id,
    );

/// Idora nomi UI tilida; yo‘q bo‘lsa — mavjud nom + «asl tili: …».
String? authorityNameOf(
  AppLocalizations l,
  Map<String, String>? names,
  String lang,
) {
  if (names == null || names.isEmpty) return null;
  final r = resolveLocalizedMap(names, lang: lang);
  if (!r.missingTranslation) return r.text;
  return '${r.text} (${l.trInOriginalLanguage(contentLanguageName(l, r.originalLang))})';
}

/// Hujjat nomi + holati (rasmiy / norasmiy tarjima / UI tilida yo‘q).
class InstrumentTitle extends StatelessWidget {
  const InstrumentTitle({
    super.key,
    required this.instrument,
    this.style,
    this.showStatus = true,
  });

  final JurisdictionalInstrument instrument;
  final TextStyle? style;

  /// Holat qatorlari (ro‘yxatda o‘chirilishi mumkin).
  final bool showStatus;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final r = instrumentTitleOf(instrument, lang);
    final id = instrument.id;
    final muted = t.labelSmall?.copyWith(color: c.textSecondary);
    // Rasmiy til ma’lum bo‘lsa — asl nom «rasmiy».
    final officialKnown = instrument.language != null;
    return Column(
      key: Key('instrument.title.$id'),
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          r.text,
          key: Key('instrument.title.text.$id'),
          locale: Locale(r.textLang),
          style: style,
        ),
        if (showStatus) ...[
          if (r.isTranslation) ...[
            Text(
              r.status!.isHumanVerified
                  ? translationStatusLabel(l, r.status!)
                  : l.legalTitleUnofficial,
              key: Key('instrument.title.status.$id'),
              style: muted,
            ),
            Text(
              l.trOriginalTitle(r.original),
              key: Key('instrument.title.original.$id'),
              locale: Locale(r.originalLang),
              style: muted?.copyWith(fontStyle: FontStyle.italic),
            ),
          ] else ...[
            if (r.missingTranslation)
              NoTranslationNotice(
                key: Key('l10n.missing.instrument_title.$id'),
                originalLang: r.originalLang,
                title: true,
              ),
            if (officialKnown)
              Text(
                l.legalTitleOfficialIn(contentLanguageName(l, r.originalLang)),
                key: Key('instrument.title.status.$id'),
                style: muted,
              ),
          ],
        ],
      ],
    );
  }
}
