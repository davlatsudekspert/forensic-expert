import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/evidence/citation_format.dart';

/// «Iqtibosni nusxalash» — ixcham tugma (manba kartasi, adabiyot qatori).
///
/// [compact] — faqat belgi (tooltip bilan); aks holda yozuvli tugma.
class CiteButton extends StatelessWidget {
  const CiteButton({super.key, required this.citation, this.compact = true});

  final CitationData citation;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    void open() => showCitationSheet(context, [citation]);
    if (compact) {
      return IconButton(
        tooltip: l.citeCopy,
        icon: const Icon(Icons.format_quote_outlined, size: 20),
        onPressed: open,
      );
    }
    return TextButton.icon(
      icon: const Icon(Icons.format_quote_outlined, size: 18),
      label: Text(l.citeCopy),
      onPressed: open,
    );
  }
}

/// Uslub tanlash + ko‘rinish + nusxalash. Bitta manba — bitta yozuv;
/// [asList] — raqamlangan ro‘yxat (sahifadagi barcha manbalar).
Future<void> showCitationSheet(
  BuildContext context,
  List<CitationData> items, {
  bool asList = false,
}) {
  // Oldingi «nusxalandi» xabari «Nusxalash» tugmasini to‘sib qo‘ymasin.
  final messenger = ScaffoldMessenger.maybeOf(context)?..hideCurrentSnackBar();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) =>
        CitationSheet(items: items, asList: asList, messenger: messenger),
  );
}

/// Tor ekran / katta shriftda uslub nomi bo‘linmaydi — kichrayadi.
Widget _fit(String s) => FittedBox(
  fit: BoxFit.scaleDown,
  child: Text(s, maxLines: 1, softWrap: false),
);

class CitationSheet extends StatefulWidget {
  const CitationSheet({
    super.key,
    required this.items,
    this.asList = false,
    this.messenger,
  });

  final List<CitationData> items;
  final bool asList;
  final ScaffoldMessengerState? messenger;

  @override
  State<CitationSheet> createState() => _CitationSheetState();
}

class _CitationSheetState extends State<CitationSheet> {
  CitationStyle? _style;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final code = Localizations.localeOf(context).languageCode;
    final style = _style ?? defaultCitationStyle(code);
    final lang = citationLangOf(code);
    final text = widget.asList
        ? formatReferenceList(widget.items, style, lang: lang)
        : formatCitation(widget.items.single, style, lang: lang);
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        // Sarlavha, uslub va «Nusxalash» doim ko‘rinadi; uzun ro‘yxat
        // ko‘rinishi o‘rtada aylantiriladi.
        child: Padding(
          key: const Key('cite.sheet'),
          padding: const EdgeInsets.fromLTRB(
            FeSpace.md,
            0,
            FeSpace.md,
            FeSpace.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.asList
                    ? l.citeListTitle(widget.items.length)
                    : l.citeCopy,
                style: t.titleMedium,
              ),
              const SizedBox(height: FeSpace.sm),
              Text(
                l.citeStyleLabel,
                style: t.labelMedium?.copyWith(color: c.textSecondary),
              ),
              const SizedBox(height: FeSpace.xxs),
              SegmentedButton<CitationStyle>(
                key: const Key('cite.style'),
                showSelectedIcon: false,
                style: const ButtonStyle(
                  padding: WidgetStatePropertyAll(
                    EdgeInsets.symmetric(horizontal: FeSpace.xs),
                  ),
                ),
                segments: [
                  ButtonSegment(
                    value: CitationStyle.gost,
                    label: _fit(l.citeStyleGost),
                  ),
                  ButtonSegment(
                    value: CitationStyle.vancouver,
                    label: _fit(l.citeStyleVancouver),
                  ),
                  ButtonSegment(
                    value: CitationStyle.apa,
                    label: _fit(l.citeStyleApa),
                  ),
                ],
                selected: {style},
                onSelectionChanged: (s) => setState(() => _style = s.single),
              ),
              const SizedBox(height: FeSpace.sm),
              Flexible(
                child: FeCard(
                  padding: EdgeInsets.zero,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(FeSpace.sm),
                    child: SelectableText(
                      text,
                      key: const Key('cite.preview'),
                      style: t.bodySmall?.copyWith(height: 1.45),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: FeSpace.xs),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 14, color: c.textSecondary),
                  const SizedBox(width: FeSpace.xxs),
                  Expanded(
                    child: Text(
                      l.citeVerifyNote,
                      key: const Key('cite.note'),
                      style: t.labelSmall?.copyWith(color: c.textSecondary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: FeSpace.sm),
              FilledButton.icon(
                key: const Key('cite.copy'),
                icon: const Icon(Icons.copy, size: 18),
                label: Text(l.citeCopyButton),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: text));
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                  widget.messenger
                    ?..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text(
                          widget.asList
                              ? l.citeListCopied(widget.items.length)
                              : l.citeCopied,
                        ),
                      ),
                    );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
