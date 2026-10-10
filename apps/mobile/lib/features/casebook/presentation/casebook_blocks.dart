import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/casebook.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/date_format.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/casebook/casebook_models.dart';
import '../../../domain/guidelines/guideline_models.dart';
import '../../guidelines/presentation/guidelines_screens.dart'
    show numberCitations;

/// Yo‘riqnoma bo‘limlaridan faqat shu kalitlar «cheklov bayoni» hisoblanadi.
const casebookSectionKeys = {'limitations', 'cautions'};

bool isCasebookSection(GuidelineSection s) =>
    casebookSectionKeys.contains(s.key);

/// Yo‘riqnoma kartasining «Cheklovlar» / «Ehtiyot choralari» bo‘limidan blok.
///
/// Matn, manba(lar) — to‘liq iqtibos va sahifalari bilan — hamda aniq joyi
/// (karta nomi + bo‘lim sarlavhasi) birga ko‘chiriladi. Hech narsa
/// to‘qilmaydi: manbasi paketda topilmagan kalit tashlab ketiladi.
CasebookBlock casebookBlockFromSection({
  required GuidelineBundle bundle,
  required GuidelineCard card,
  required GuidelineSection section,
  required String lang,
  required String id,
  DateTime? now,
}) {
  final refs = <GuidelineReference>[];
  for (final k in section.citations) {
    final r = bundle.references[k];
    if (r != null && !refs.contains(r)) refs.add(r);
  }
  final index = {for (var i = 0; i < refs.length; i++) refs[i].key: i + 1};
  return CasebookBlock(
    id: id,
    kind: section.key == 'cautions'
        ? CasebookBlockKind.caution
        : CasebookBlockKind.limitation,
    text: numberCitations(section.body.of(lang), section.citations, index),
    lang: section.body.pick(lang).lang,
    addedAt: now ?? DateTime.now(),
    originId: card.id,
    originTitle: card.title.of(lang),
    sectionTitle: section.title.of(lang),
    citations: [
      for (final r in refs)
        CasebookCitation(
          text: r.citation,
          pages: r.pages,
          link: r.link?.toString(),
        ),
    ],
  );
}

/// Foydalanuvchi o‘zi qo‘shgan AI javobi — doim «tekshirilmagan».
CasebookBlock casebookBlockFromAi({
  required String text,
  required Iterable<String> sourceIds,
  required String lang,
  required String id,
  DateTime? now,
}) => CasebookBlock(
  id: id,
  kind: CasebookBlockKind.ai,
  text: text.trim(),
  lang: lang,
  addedAt: now ?? DateTime.now(),
  citations: [
    for (final s in {...sourceIds}) CasebookCitation(text: s),
  ],
);

extension CasebookBlockKindL10n on CasebookBlockKind {
  String label(AppLocalizations l) => switch (this) {
    CasebookBlockKind.limitation => l.casebookKindLimitation,
    CasebookBlockKind.caution => l.casebookKindCaution,
    CasebookBlockKind.ai => l.casebookKindAi,
  };
}

/// Eksport matni yorliqlari (joriy til).
CasebookExportLabels casebookExportLabels(BuildContext context) {
  final l = AppLocalizations.of(context);
  return CasebookExportLabels(
    disclaimer: l.casebookExportDisclaimer,
    caseRef: l.casebookCaseRefField.replaceAll(RegExp(r'\s*\(.*\)'), ''),
    date: l.casebookDateField,
    linksTitle: l.casebookExportLinks,
    blocksTitle: l.casebookExportBlocks,
    sourceLabel: l.casebookSourceLabel,
    locationLabel: l.casebookLocationLabel,
    pagesLabel: l.casebookPagesLabel,
    sourcesTitle: l.casebookSourcesLabel,
    aiUnverified: l.casebookAiUnverified,
    untitled: l.casebookUntitled,
    footer: l.casebookExportFooter,
    dateText: (d) => feDate(context, d),
  );
}

/// «Qaysi yozuvga qo‘shamiz?» — mavjud yozuv ID’si yoki yangi yozuv
/// (`newTitle` bilan) yaratilib, shu ID qaytariladi. Bekor qilinsa — null.
Future<String?> chooseCasebookEntry(
  BuildContext context,
  WidgetRef ref, {
  required String newTitle,
  bool aiNote = false,
}) async {
  final l = AppLocalizations.of(context);
  final entries = ref.read(casebookProvider);
  final choice = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) {
      final t = Theme.of(ctx).textTheme;
      return SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(ctx).height * 0.75,
          ),
          child: ListView(
            key: const Key('casebook.choose'),
            padding: const EdgeInsets.symmetric(horizontal: FeSpace.md),
            shrinkWrap: true,
            children: [
              Text(l.casebookChooseEntry, style: t.titleMedium),
              if (aiNote) ...[
                const SizedBox(height: FeSpace.xs),
                FeBanner(
                  key: const Key('casebook.choose.aiNote'),
                  icon: Icons.smart_toy_outlined,
                  tone: FeBannerTone.warning,
                  text: l.casebookAiAddNote,
                ),
              ],
              const SizedBox(height: FeSpace.xs),
              ListTile(
                key: const Key('casebook.choose.new'),
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.add_circle_outline),
                title: Text(l.casebookChooseNew),
                onTap: () => Navigator.of(ctx).pop('\u0000new'),
              ),
              for (final e in entries)
                ListTile(
                  key: Key('casebook.choose.${e.id}'),
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.menu_book_outlined),
                  title: Text(
                    e.title.isEmpty ? l.casebookUntitled : e.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(feDate(ctx, e.date)),
                  onTap: () => Navigator.of(ctx).pop(e.id),
                ),
              const SizedBox(height: FeSpace.md),
            ],
          ),
        ),
      );
    },
  );
  if (choice == null) return null;
  if (choice == '\u0000new') {
    return ref.read(casebookProvider.notifier).create(title: newTitle);
  }
  return choice;
}

/// Blokni tanlangan yozuvga qo‘shadi va «Ochish» amali bilan xabar beradi.
Future<void> addBlockToCasebook(
  BuildContext context,
  WidgetRef ref, {
  required CasebookBlock block,
  required String newTitle,
}) async {
  final entryId = await chooseCasebookEntry(
    context,
    ref,
    newTitle: newTitle,
    aiNote: block.isAiUnverified,
  );
  if (entryId == null || !context.mounted) return;
  final ctrl = ref.read(casebookProvider.notifier);
  await ctrl.addBlock(entryId, block);
  if (!context.mounted) return;
  final l = AppLocalizations.of(context);
  final entry = ctrl.byId(entryId);
  final router = GoRouter.of(context);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        l.casebookAddedTo(
          (entry == null || entry.title.isEmpty)
              ? l.casebookUntitled
              : entry.title,
        ),
      ),
      action: SnackBarAction(
        label: l.casebookOpen,
        onPressed: () => router.push(Routes.casebookEntry(entryId)),
      ),
    ),
  );
}

/// Yo‘riqnoma bo‘limi sarlavhasi yonidagi «Ish daftariga qo‘shish».
class AddToCasebookButton extends ConsumerWidget {
  const AddToCasebookButton({
    super.key,
    required this.bundle,
    required this.card,
    required this.section,
  });

  final GuidelineBundle bundle;
  final GuidelineCard card;
  final GuidelineSection section;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final c = FeTheme.of(context);
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: TextButton.icon(
        icon: Icon(Icons.bookmark_add_outlined, size: 18, color: c.accent),
        label: Text(l.casebookAddToCasebook),
        onPressed: () => addBlockToCasebook(
          context,
          ref,
          block: casebookBlockFromSection(
            bundle: bundle,
            card: card,
            section: section,
            lang: lang,
            id: ref.read(casebookProvider.notifier).newId(),
          ),
          newTitle: card.title.of(lang),
        ),
      ),
    );
  }
}
