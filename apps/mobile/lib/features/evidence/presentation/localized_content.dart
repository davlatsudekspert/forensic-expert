import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../domain/evidence/content_translations.dart';

export '../../../domain/evidence/content_translations.dart';

/// Uch tilli kontent ko‘rsatish qatlami (Phase C).
///
/// Tartib (egasi): **UI tilidagi matn** → holat belgisi → «Asl matn»
/// (yig‘ilgan). UI tilida matn yo‘q bo‘lsa — buni shu tilda ochiq aytib,
/// asl matn ko‘rsatiladi. Asl matn har doim o‘z tilining `Locale`i bilan
/// chiziladi (shrift, defis, ekran o‘quvchi to‘g‘ri ishlashi uchun).

/// «ingliz» / «английский» / «English».
String contentLanguageName(AppLocalizations l, String code) =>
    l.trLanguageName(normalizeLang(code));

/// Holat matni (UI tilida).
String translationStatusLabel(AppLocalizations l, ContentTranslationStatus s) =>
    switch (s) {
      ContentTranslationStatus.machineDraft => l.trStatusMachineDraft,
      ContentTranslationStatus.terminologyChecked =>
        l.trStatusTerminologyChecked,
      ContentTranslationStatus.claimChecked => l.trStatusClaimChecked,
      ContentTranslationStatus.reviewed => l.trStatusReviewed,
      ContentTranslationStatus.official => l.trStatusOfficial,
    };

/// Ekranda ko‘rsatiladigan tarjimani topish (provider orqali).
LocalizedContent resolveContent(
  WidgetRef ref,
  BuildContext context,
  String kind,
  String id, {
  required String source,
  String? originalLang,
  Set<String> sameTextKinds = const {},
}) => ref
    .watch(contentTranslationsProvider)
    .resolve(
      kind,
      id,
      source: source,
      lang: Localizations.localeOf(context).languageCode,
      originalLang: originalLang,
      sameTextKinds: sameTextKinds,
    );

/// Tarjima holati belgisi: «Avtomatik tarjima — tekshirilmagan».
class TranslationStatusBadge extends StatelessWidget {
  const TranslationStatusBadge({super.key, required this.status});

  final ContentTranslationStatus status;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final verified = status.isHumanVerified;
    final color = verified ? c.verified : c.textSecondary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(
            verified ? Icons.verified_outlined : Icons.translate,
            size: 14,
            color: color,
          ),
        ),
        const SizedBox(width: FeSpace.xxs),
        Flexible(
          child: Text(
            translationStatusLabel(l, status),
            style: t.labelSmall?.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}

/// «Bu matnning o‘zbekcha tarjimasi hali tayyorlanmagan — asl tili: ingliz».
class NoTranslationNotice extends StatelessWidget {
  const NoTranslationNotice({
    super.key,
    required this.originalLang,
    this.title = false,
  });

  final String originalLang;

  /// Sarlavha uchun qisqaroq matn.
  final bool title;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final name = contentLanguageName(l, originalLang);
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(Icons.language, size: 14, color: c.textSecondary),
        ),
        const SizedBox(width: FeSpace.xxs),
        Flexible(
          child: Text(
            title ? l.trTitleNotTranslated(name) : l.trNotTranslated(name),
            style: t.labelSmall?.copyWith(
              color: c.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }
}

/// Yig‘iladigan «Asl matn» bloki: asl matn (o‘z tilida, kursiv) faqat
/// bosilganda ochiladi.
class OriginalTextToggle extends StatefulWidget {
  const OriginalTextToggle({
    super.key,
    required this.original,
    required this.originalLang,
    this.showLabel,
    this.toggleKey,
    this.originalKey,
    this.initiallyExpanded = false,
    this.style,
    this.selectable = false,
  });

  final String original;
  final String originalLang;

  /// Tugma matni (standart: «Asl matn»).
  final String? showLabel;
  final Key? toggleKey;
  final Key? originalKey;
  final bool initiallyExpanded;
  final TextStyle? style;
  final bool selectable;

  @override
  State<OriginalTextToggle> createState() => _OriginalTextToggleState();
}

class _OriginalTextToggleState extends State<OriginalTextToggle> {
  late bool _open = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final label = _open
        ? l.trOriginalHide
        : (widget.showLabel ?? l.trOriginalShow);
    final style = (widget.style ?? t.bodySmall)?.copyWith(
      fontStyle: FontStyle.italic,
      height: 1.45,
    );
    final locale = Locale(normalizeLang(widget.originalLang));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          button: true,
          expanded: _open,
          child: InkWell(
            key: widget.toggleKey,
            borderRadius: BorderRadius.circular(FeRadius.sm),
            onTap: () => setState(() => _open = !_open),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: FeTouch.minTarget),
              child: Row(
                children: [
                  Icon(
                    _open ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                    color: c.accent,
                  ),
                  const SizedBox(width: FeSpace.xxs),
                  Flexible(
                    child: Text(
                      label,
                      style: t.labelLarge?.copyWith(
                        color: c.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (!_open) ...[
                    const SizedBox(width: FeSpace.xs),
                    Text(
                      normalizeLang(widget.originalLang).toUpperCase(),
                      style: t.labelSmall?.copyWith(
                        color: c.textSecondary,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: FeMotion.of(context, FeMotion.standard),
          alignment: Alignment.topCenter,
          child: !_open
              ? const SizedBox(width: double.infinity)
              : DecoratedBox(
                  key: widget.originalKey,
                  decoration: BoxDecoration(
                    color: c.surfaceSunken,
                    borderRadius: BorderRadius.circular(FeRadius.sm),
                    border: BorderDirectional(
                      start: BorderSide(color: c.accentBorder, width: 2),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      FeSpace.sm,
                      FeSpace.xs,
                      FeSpace.sm,
                      FeSpace.xs,
                    ),
                    child: widget.selectable
                        ? SelectableText(widget.original, style: style)
                        : Text(widget.original, locale: locale, style: style),
                  ),
                ),
        ),
      ],
    );
  }
}

/// Tarjima → holat → «Asl matn» (yig‘ilgan); tarjima yo‘q bo‘lsa — halol
/// xabar + asl matn. Kalitlar: `l10n.text.<kind>.<id>`,
/// `quote.translation.<kind>.<id>` (tarjima bloki), `l10n.status.…`,
/// `l10n.originalToggle.…`, `l10n.original.…`, `l10n.missing.…`.
class LocalizedContentView extends StatelessWidget {
  const LocalizedContentView({
    super.key,
    required this.content,
    required this.kind,
    required this.id,
    this.style,
    this.quote = false,
    this.label,
    this.translatedLabel,
    this.originalShowLabel,
    this.maxLines,
    this.originalInitiallyExpanded = false,
  });

  final LocalizedContent content;
  final String kind;
  final String id;
  final TextStyle? style;

  /// Asl matn — manbadan aynan iqtibos (kursiv).
  final bool quote;

  /// Blok ustidagi yorliq (asl matn ko‘rsatilganda).
  final String? label;

  /// Tarjima ko‘rsatilganda yorliq (masalan «Manbadagi iqtibos (tarjima)»).
  final String? translatedLabel;
  final String? originalShowLabel;
  final int? maxLines;
  final bool originalInitiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final base = style ?? t.bodyMedium;
    final overflow = maxLines == null ? null : TextOverflow.ellipsis;
    final shownLabel = content.isTranslation
        ? (translatedLabel ?? label)
        : label;
    final children = <Widget>[
      if (shownLabel != null)
        Padding(
          padding: const EdgeInsets.only(bottom: FeSpace.xxs),
          child: Text(
            shownLabel,
            style: t.labelSmall?.copyWith(color: c.textSecondary),
          ),
        ),
    ];
    if (content.isTranslation) {
      children.add(
        Semantics(
          key: Key('quote.translation.$kind.$id'),
          container: true,
          label: l.trTranslationSemantics(
            translationStatusLabel(l, content.status!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                content.text,
                key: Key('l10n.text.$kind.$id'),
                locale: Locale(content.textLang),
                maxLines: maxLines,
                overflow: overflow,
                style: base?.copyWith(height: 1.45),
              ),
              const SizedBox(height: FeSpace.xxs),
              TranslationStatusBadge(
                key: Key('l10n.status.$kind.$id'),
                status: content.status!,
              ),
            ],
          ),
        ),
      );
      children.add(
        OriginalTextToggle(
          key: Key('l10n.originalBlock.$kind.$id'),
          original: content.original,
          originalLang: content.originalLang,
          showLabel: originalShowLabel,
          toggleKey: Key('l10n.originalToggle.$kind.$id'),
          originalKey: Key('l10n.original.$kind.$id'),
          initiallyExpanded: originalInitiallyExpanded,
          style: base,
        ),
      );
    } else {
      if (content.missingTranslation) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: FeSpace.xxs),
            child: NoTranslationNotice(
              key: Key('l10n.missing.$kind.$id'),
              originalLang: content.originalLang,
            ),
          ),
        );
      }
      children.add(
        Text(
          content.original,
          key: Key('l10n.text.$kind.$id'),
          locale: Locale(content.originalLang),
          maxLines: maxLines,
          overflow: overflow,
          style: base?.copyWith(
            fontStyle: quote ? FontStyle.italic : null,
            height: 1.45,
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}

/// [LocalizedContentView] + provider orqali qidirish.
class LocalizedContentText extends ConsumerWidget {
  const LocalizedContentText({
    super.key,
    required this.kind,
    required this.id,
    required this.source,
    this.originalLang,
    this.style,
    this.quote = false,
    this.label,
    this.translatedLabel,
    this.originalShowLabel,
    this.maxLines,
  });

  final String kind;
  final String id;
  final String source;
  final String? originalLang;
  final TextStyle? style;
  final bool quote;
  final String? label;
  final String? translatedLabel;
  final String? originalShowLabel;
  final int? maxLines;

  @override
  Widget build(BuildContext context, WidgetRef ref) => LocalizedContentView(
    content: resolveContent(
      ref,
      context,
      kind,
      id,
      source: source,
      originalLang: originalLang,
    ),
    kind: kind,
    id: id,
    style: style,
    quote: quote,
    label: label,
    translatedLabel: translatedLabel,
    originalShowLabel: originalShowLabel,
    maxLines: maxLines,
  );
}

/// Qisqa qiymat (nom, ro‘yxat elementi, skrining maydoni): tarjima bo‘lsa —
/// tarjima + kichik «tarjima» belgisi (ekran o‘quvchiga holat bilan); yo‘q
/// bo‘lsa — asl matn + «asl tili: ingliz» yorlig‘i.
class LocalizedInlineText extends ConsumerWidget {
  const LocalizedInlineText({
    super.key,
    required this.kind,
    required this.id,
    required this.source,
    this.originalLang,
    this.style,
    this.prefix,
    this.maxLines,
    this.sameTextKinds = const {},
  });

  final String kind;
  final String id;
  final String source;
  final String? originalLang;
  final TextStyle? style;

  /// Oldidan qo‘shiladigan matn (masalan «• »).
  final String? prefix;
  final int? maxLines;

  /// Shu ID’da tarjima bo‘lmasa — aynan shu asl matnning boshqa turdagi
  /// tarjimasi (masalan metabolit nomi ↔ da’vo ro‘yxati elementi).
  final Set<String> sameTextKinds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = resolveContent(
      ref,
      context,
      kind,
      id,
      source: source,
      originalLang: originalLang,
      sameTextKinds: sameTextKinds,
    );
    return LocalizedInlineView(
      key: Key('l10n.inline.$kind.$id'),
      content: r,
      style: style,
      prefix: prefix,
      maxLines: maxLines,
    );
  }
}

/// [LocalizedInlineText] ning provider’siz varianti (tayyor natija bilan).
class LocalizedInlineView extends StatelessWidget {
  const LocalizedInlineView({
    super.key,
    required this.content,
    this.style,
    this.prefix,
    this.maxLines,
  });

  final LocalizedContent content;
  final TextStyle? style;
  final String? prefix;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final base = style ?? t.bodyMedium;
    final tag = (base ?? const TextStyle()).copyWith(
      fontSize: (t.labelSmall?.fontSize ?? 11),
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.italic,
      color: c.textSecondary,
    );
    final spans = <InlineSpan>[
      if (prefix != null) TextSpan(text: prefix),
      TextSpan(text: content.text, locale: Locale(content.textLang)),
      if (content.isTranslation && content.needsReviewLabel)
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Semantics(
            label: translationStatusLabel(l, content.status!),
            child: Padding(
              padding: const EdgeInsetsDirectional.only(start: 4),
              child: Icon(Icons.translate, size: 12, color: c.textSecondary),
            ),
          ),
        ),
      if (content.missingTranslation)
        TextSpan(
          text:
              '  (${l.trInOriginalLanguage(contentLanguageName(l, content.originalLang))})',
          style: tag,
        ),
    ];
    return Text.rich(
      TextSpan(children: spans),
      style: base,
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
    );
  }
}

/// Tadqiqot / manba / standart sarlavhasi: tarjima bo‘lsa — u asosiy,
/// ostida «Asl nomi: …» va holat; bo‘lmasa — asl sarlavha va «nomning
/// tarjimasi hali yo‘q — asl tili: …». Bibliografiya (asl sarlavha) hech
/// qachon o‘zgartirilmaydi. Uzun sarlavhalar 320 dp da o‘raladi.
class TranslatedTitle extends ConsumerWidget {
  const TranslatedTitle({
    super.key,
    required this.id,
    required this.title,
    this.kind = ContentTextKind.researchTitle,
    this.originalLang,
    this.style,
    this.maxLines,
    this.selectable = false,
    this.showMissingNotice = true,
  });

  final String id;
  final String title;
  final String kind;

  /// Asl sarlavha tili (standart `en`).
  final String? originalLang;
  final TextStyle? style;
  final int? maxLines;
  final bool selectable;

  /// UI tilida tarjima yo‘qligi haqidagi qator (ro‘yxatlarda ham).
  final bool showMissingNotice;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final r = resolveContent(
      ref,
      context,
      kind,
      id,
      source: title,
      originalLang: originalLang,
    );
    final overflow = maxLines == null ? null : TextOverflow.ellipsis;
    Widget text(String s, TextStyle? st, Locale locale, {Key? key}) =>
        selectable
        ? SelectableText(s, key: key, style: st, maxLines: maxLines)
        : Text(
            s,
            key: key,
            locale: locale,
            style: st,
            maxLines: maxLines,
            overflow: overflow,
          );
    final secondary = t.bodySmall?.copyWith(color: c.textSecondary);
    if (!r.isTranslation) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          text(
            r.original,
            style,
            Locale(r.originalLang),
            key: Key('title.original.$kind.$id'),
          ),
          if (r.missingTranslation && showMissingNotice)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: NoTranslationNotice(
                key: Key('l10n.missing.$kind.$id'),
                originalLang: r.originalLang,
                title: true,
              ),
            ),
        ],
      );
    }
    return Column(
      key: Key('quote.translation.$kind.$id'),
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        text(
          r.text,
          style,
          Locale(r.textLang),
          key: Key('title.translated.$kind.$id'),
        ),
        const SizedBox(height: 2),
        Text(
          l.trOriginalTitle(r.original),
          key: Key('research.originalTitle.$id'),
          locale: Locale(r.originalLang),
          maxLines: maxLines,
          overflow: overflow,
          style: secondary?.copyWith(fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 2),
        TranslationStatusBadge(
          key: Key('l10n.status.$kind.$id'),
          status: r.status!,
        ),
      ],
    );
  }
}

/// Adabiyot yozuvi ustida UI tilidagi nom (bo‘lsa) va uning holati
/// («Rasmiy nomi (o‘zbek tilida)» / «Nomning norasmiy tarjimasi —
/// tekshirilmagan»). Asl bibliografik iqtibos ostida o‘zgarmay qoladi.
class LocalizedReferenceTitle extends StatelessWidget {
  const LocalizedReferenceTitle({
    super.key,
    required this.titles,
    required this.original,
  });

  final ReferenceTitles titles;

  /// Asl sarlavha (UI tilidagi nom u bilan bir xil bo‘lsa — ko‘rsatilmaydi).
  final String? original;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final title = titles.titleIn(lang);
    if (title == null || title == original?.trim()) {
      return const SizedBox.shrink();
    }
    final status = titles.isOfficialIn(lang)
        ? l.legalTitleOfficialIn(contentLanguageName(l, lang))
        : titles.isReviewedIn(lang)
        ? l.trStatusReviewed
        : l.legalTitleUnofficial;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            locale: Locale(normalizeLang(lang)),
            style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          Text(status, style: t.labelSmall?.copyWith(color: c.textSecondary)),
        ],
      ),
    );
  }
}
