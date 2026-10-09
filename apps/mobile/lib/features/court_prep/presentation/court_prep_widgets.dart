import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/guidelines.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/catalog/tools_catalog.dart';
import '../../../domain/court_prep/court_prep_models.dart';
import '../../../domain/guidelines/guideline_models.dart';
import '../../guidelines/presentation/guidelines_screens.dart'
    show numberCitations;
import '../../tools/tool_strings.dart';

IconData courtTopicIcon(String name) => switch (name) {
  'badge' => Icons.badge_outlined,
  'inventory' => Icons.inventory_2_outlined,
  'science' => Icons.science_outlined,
  'fingerprint' => Icons.fingerprint,
  'verified' => Icons.verified_outlined,
  'insights' => Icons.insights_outlined,
  'description' => Icons.description_outlined,
  'forum' => Icons.forum_outlined,
  'gavel' => Icons.gavel_outlined,
  'biotech' => Icons.biotech_outlined,
  _ => Icons.help_outline,
};

/// Manbadagi joyni foydalanuvchi tilida yozadi.
String courtLocatorLabel(AppLocalizations l, CourtLocator loc) =>
    switch (loc.kind) {
      'art' when loc.part.isNotEmpty => l.courtLocArticlePart(
        loc.value,
        loc.part,
      ),
      'art' => l.courtLocArticle(loc.value),
      'sec' => l.courtLocSection(loc.value),
      'pdfp' => l.courtLocPdfPage(loc.value),
      'pp' => l.courtLocPages(loc.value.replaceAll('-', '–')),
      'rec' => l.courtLocRecommendation(loc.value),
      'gn' => l.courtLocGuidanceNote(loc.value),
      'abstract' => l.courtLocAbstract,
      'scope' => l.courtLocScope,
      'title' => l.courtLocTitle,
      'glossary' => l.courtLocGlossary,
      _ => loc.kind,
    };

String _bracket(int n) => '[$n]';

/// Iqtibos raqamlari bilan matn ([kalit] → [n]).
String courtCite(Tri text, String lang, Map<String, int> index) =>
    numberCitations(text.of(lang), const [], index);

Map<String, int> courtRefIndex(CourtPrepBundle bundle, CourtSourced item) {
  final refs = bundle.referencesOf(item);
  return {for (var i = 0; i < refs.length; i++) refs[i].key: i + 1};
}

/// Bitta manba uchun eksport matni (joylari bilan).
String courtSourceLine(
  AppLocalizations l,
  int n,
  CourtReference r,
  List<CourtLocator>? locs,
) {
  if (locs == null) return '[$n] ${l.courtSourceUnverified}: ${r.title}';
  final where = locs.map((x) => courtLocatorLabel(l, x)).join('; ');
  final id = r.doi != null
      ? ' https://doi.org/${r.doi}'
      : r.pmid != null
      ? ' PMID ${r.pmid}'
      : r.url != null
      ? ' ${r.url}'
      : '';
  return '[$n] ${r.citation}$id — $where';
}

/// Har ekranning yuqorisidagi sokin ogohlantirish.
class CourtDisclaimer extends StatelessWidget {
  const CourtDisclaimer({super.key});

  @override
  Widget build(BuildContext context) => FeBanner(
    key: const Key('court.disclaimer'),
    icon: Icons.balance_outlined,
    text: AppLocalizations.of(context).courtDisclaimer,
  );
}

/// Pro taklifi — faqat kengaytirilgan mashg‘ulotlar uchun (savol-javob
/// kartalari va manbalar hamma uchun bepul). Soxta shoshirish yoki
/// chegirmasiz, mavjud tariflar sahifasiga olib boradi.
class CourtProCard extends StatelessWidget {
  const CourtProCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    return FeCard(
      key: const Key('court.locked'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.workspace_premium_outlined, color: c.accent),
              const SizedBox(width: FeSpace.xs),
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    l.courtProTitle(l.tierProfessionalPro),
                    style: t.titleSmall,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: FeSpace.xs),
          Text(
            l.courtProBody,
            style: t.bodySmall?.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: FeSpace.sm),
          FilledButton(
            key: const Key('court.unlock'),
            onPressed: () => context.push(Routes.purchase),
            child: Text(l.purchaseCta),
          ),
        ],
      ),
    );
  }
}

/// Belgilanadigan ro‘yxat (faqat shu ekranda; hech qayerga saqlanmaydi).
class CourtChecklist extends StatefulWidget {
  const CourtChecklist({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
    required this.keyPrefix,
  });

  final String title;
  final IconData icon;
  final Color color;
  final List<String> items;
  final String keyPrefix;

  @override
  State<CourtChecklist> createState() => _CourtChecklistState();
}

class _CourtChecklistState extends State<CourtChecklist> {
  final _done = <int>{};

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: FeSpace.sm),
      child: FeCard(
        key: Key(widget.keyPrefix),
        padding: const EdgeInsets.fromLTRB(
          FeSpace.sm,
          FeSpace.sm,
          FeSpace.sm,
          FeSpace.xs,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _GroupTitle(
              title: widget.title,
              icon: widget.icon,
              color: widget.color,
            ),
            const SizedBox(height: FeSpace.xxs),
            for (final (i, text) in widget.items.indexed)
              CheckboxListTile(
                key: Key('${widget.keyPrefix}.$i'),
                value: _done.contains(i),
                onChanged: (v) =>
                    setState(() => v == true ? _done.add(i) : _done.remove(i)),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                dense: true,
                visualDensity: VisualDensity.compact,
                title: Text(text, style: t.bodyMedium?.copyWith(height: 1.45)),
              ),
          ],
        ),
      ),
    );
  }
}

/// Belgisiz nuqtali ro‘yxat (ilmiy asos, cheklovlar).
class CourtBulletGroup extends StatelessWidget {
  const CourtBulletGroup({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
  });

  final String title;
  final IconData icon;
  final Color color;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: FeSpace.sm),
      child: FeCard(
        padding: const EdgeInsets.all(FeSpace.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _GroupTitle(title: title, icon: icon, color: color),
            const SizedBox(height: FeSpace.xs),
            for (final text in items)
              Padding(
                padding: const EdgeInsets.only(bottom: FeSpace.xs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8, right: FeSpace.xs),
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: c.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Expanded(
                      child: SelectableText(
                        text,
                        style: t.bodyMedium?.copyWith(height: 1.5),
                      ),
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

class _GroupTitle extends StatelessWidget {
  const _GroupTitle({
    required this.title,
    required this.icon,
    required this.color,
  });

  final String title;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 20, color: color),
      const SizedBox(width: FeSpace.xs),
      Expanded(
        child: Semantics(
          header: true,
          child: Text(title, style: Theme.of(context).textTheme.titleSmall),
        ),
      ),
    ],
  );
}

/// D. «Qaysi manbada yozilgan?» va H. manbalarni nusxalash.
///
/// Joy tasdiqlanmagan manba uchun bibliografik qator o‘rniga «Manba
/// tekshirilmagan» ko‘rsatiladi.
class CourtSourcesSection extends StatelessWidget {
  const CourtSourcesSection({
    super.key,
    required this.item,
    required this.bundle,
    this.showExport = true,
    this.showList = true,
  });

  final CourtSourced item;
  final CourtPrepBundle bundle;
  final bool showExport;
  final bool showList;

  Future<void> _copy(BuildContext context, String text) async {
    final l = AppLocalizations.of(context);
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.courtExportCopied)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final refs = bundle.referencesOf(item);
    if (refs.isEmpty) return const SizedBox.shrink();
    final text = [
      for (var i = 0; i < refs.length; i++)
        courtSourceLine(l, i + 1, refs[i], item.locatorsOf(refs[i].key)),
    ].join('\n');
    final bib = [for (final r in refs) r.toBibtex()].join('\n\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showList) ...[
          FeSectionHeader(l.courtWhereWritten),
          for (var i = 0; i < refs.length; i++)
            CourtReferenceTile(
              number: i + 1,
              reference: refs[i],
              locators: item.locatorsOf(refs[i].key),
            ),
        ],
        if (showExport) ...[
          FeSectionHeader(l.courtExport),
          Wrap(
            key: const Key('court.export'),
            spacing: FeSpace.xs,
            runSpacing: FeSpace.xs,
            children: [
              OutlinedButton.icon(
                key: const Key('court.export.text'),
                onPressed: () => _copy(context, text),
                icon: const Icon(Icons.copy_all_outlined, size: 18),
                label: Text(l.courtExportText),
              ),
              OutlinedButton.icon(
                key: const Key('court.export.bibtex'),
                onPressed: () => _copy(context, bib),
                icon: const Icon(Icons.data_object, size: 18),
                label: Text(l.courtExportBibtex),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class CourtReferenceTile extends StatelessWidget {
  const CourtReferenceTile({
    super.key,
    required this.number,
    required this.reference,
    required this.locators,
  });

  final int number;
  final CourtReference reference;

  /// `null` — joy tasdiqlanmagan.
  final List<CourtLocator>? locators;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final locs = locators;
    final link = reference.link;
    return Padding(
      key: Key('court.ref.${reference.key}'),
      padding: const EdgeInsets.only(bottom: FeSpace.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 32,
            child: Text(_bracket(number), style: t.bodySmall),
          ),
          Expanded(
            child: locs == null
                ? Column(
                    key: Key('court.unverified.${reference.key}'),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.help_outline, size: 16, color: c.warning),
                          const SizedBox(width: FeSpace.xxs),
                          Text(
                            l.courtSourceUnverified,
                            style: t.labelLarge?.copyWith(color: c.warning),
                          ),
                        ],
                      ),
                      Text(
                        l.courtSourceUnverifiedNote,
                        style: t.bodySmall?.copyWith(color: c.textSecondary),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SelectableText(reference.citation, style: t.bodySmall),
                      Text(
                        locs.map((x) => courtLocatorLabel(l, x)).join('; '),
                        key: Key('court.loc.${reference.key}'),
                        style: t.labelMedium?.copyWith(
                          color: c.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (reference.isLaw && reference.verifiedOn != null)
                        Text(
                          l.courtLawNote(reference.verifiedOn!),
                          style: t.labelSmall?.copyWith(color: c.textSecondary),
                        ),
                      if (reference.isTeacherBook)
                        Text(
                          l.courtBookNote,
                          style: t.labelSmall?.copyWith(color: c.textSecondary),
                        ),
                      if (reference.doi != null || reference.pmid != null)
                        Text(
                          [
                            if (reference.doi != null) 'DOI ${reference.doi}',
                            if (reference.pmid != null)
                              'PMID ${reference.pmid}',
                          ].join(' · '),
                          style: t.labelSmall,
                        ),
                      Wrap(
                        spacing: FeSpace.xs,
                        children: [
                          if (link != null)
                            TextButton.icon(
                              onPressed: () => launchUrl(
                                link,
                                mode: LaunchMode.externalApplication,
                              ),
                              icon: const Icon(Icons.open_in_new, size: 16),
                              label: Text(l.guidelineOpenReference),
                            ),
                          TextButton.icon(
                            key: Key('court.copy.${reference.key}'),
                            onPressed: () async {
                              await Clipboard.setData(
                                ClipboardData(
                                  text: courtSourceLine(
                                    l,
                                    number,
                                    reference,
                                    locs,
                                  ),
                                ),
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(l.courtCitationCopied),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.copy, size: 16),
                            label: Text(l.courtCopyCitation),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

/// Ilovadagi bog‘liq materiallar (yo‘riqnoma, vosita, sahifa).
class CourtRelatedLinks extends ConsumerWidget {
  const CourtRelatedLinks({super.key, required this.links});

  final List<CourtLink> links;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final guidelines =
        ref.watch(guidelinesProvider).value ?? GuidelineBundle.empty;
    final chips = <(String, IconData, String)>[];
    for (final link in links) {
      switch (link.kind) {
        case 'guideline':
          if (guidelines.byId(link.id) case final card?) {
            chips.add((
              card.title.of(lang),
              Icons.assignment_outlined,
              Routes.guideline(card.id),
            ));
          }
        case 'tool':
          if (ToolsCatalog.byId(link.id) case final tool?) {
            chips.add((
              l.toolName(tool),
              Icons.calculate_outlined,
              Routes.tool(tool.id),
            ));
          }
        case 'page':
          final page = switch (link.id) {
            'sources' => (
              l.libraryReferences,
              Icons.menu_book_outlined,
              Routes.sources,
            ),
            'specimens' => (
              l.librarySpecimens,
              Icons.water_drop_outlined,
              Routes.specimens,
            ),
            'standards' => (
              l.libraryStandards,
              Icons.rule_folder_outlined,
              Routes.libraryStandards,
            ),
            'conflicts' => (
              l.libraryConflicts,
              Icons.compare_arrows,
              Routes.conflicts,
            ),
            _ => null,
          };
          if (page != null) chips.add(page);
      }
    }
    if (chips.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FeSectionHeader(l.courtRelated),
        Wrap(
          key: const Key('court.related'),
          spacing: FeSpace.xs,
          runSpacing: FeSpace.xs,
          children: [
            for (final (label, icon, route) in chips)
              ActionChip(
                avatar: Icon(icon, size: 16),
                label: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 260),
                  child: Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                tooltip: label,
                onPressed: () => context.push(route),
              ),
          ],
        ),
      ],
    );
  }
}

/// Kartaning to‘liq tanasi (savol sahifasi va mashq rejimi uchun):
/// sud nimani tekshiradi → B qisqa javob → C asos + D manbalar → E/F
/// qo‘shimcha savollar → G cheklovlar → tayyorgarlik → bog‘liq → H eksport.
class CourtQuestionBody extends StatelessWidget {
  const CourtQuestionBody({
    super.key,
    required this.question,
    required this.bundle,
  });

  final CourtPrepQuestion question;
  final CourtPrepBundle bundle;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final index = courtRefIndex(bundle, question);
    String cite(Tri x) => courtCite(x, lang, index);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FeSectionHeader(l.courtTests),
        FeCard(
          key: const Key('court.tests'),
          color: c.surface,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.gavel_outlined, color: c.accent, size: 20),
              const SizedBox(width: FeSpace.sm),
              Expanded(
                child: SelectableText(
                  cite(question.tests),
                  style: t.bodyMedium?.copyWith(height: 1.5),
                ),
              ),
            ],
          ),
        ),
        FeSectionHeader(l.courtShortAnswer),
        DecoratedBox(
          key: const Key('court.shortAnswer'),
          decoration: BoxDecoration(
            color: c.accentContainer,
            borderRadius: BorderRadius.circular(FeRadius.card),
            border: Border.all(color: c.accentBorder),
          ),
          child: Padding(
            padding: const EdgeInsets.all(FeSpace.md),
            child: SelectableText(
              cite(question.shortAnswer),
              style: t.bodyMedium?.copyWith(
                height: 1.55,
                color: c.onAccentContainer,
              ),
            ),
          ),
        ),
        FeSectionHeader(l.courtBasisHeader),
        CourtBulletGroup(
          key: const Key('court.block.explain'),
          title: l.courtBasis,
          icon: Icons.account_balance_outlined,
          color: c.reviewed,
          items: [
            for (final it in question.block(CourtPrepBlock.explain)) cite(it),
          ],
        ),
        CourtSourcesSection(
          key: const Key('court.sources'),
          item: question,
          bundle: bundle,
          showExport: false,
        ),
        if (question.followups.isNotEmpty) ...[
          FeSectionHeader(l.courtFollowups),
          for (final (i, f) in question.followups.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: FeSpace.xs),
              child: FeCard(
                padding: EdgeInsets.zero,
                child: Theme(
                  data: Theme.of(context)
                      .copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    key: Key('court.followup.$i'),
                    leading: Icon(
                      Icons.question_answer_outlined,
                      color: c.accent,
                    ),
                    title: Text(f.question.of(lang), style: t.bodyMedium),
                    childrenPadding: const EdgeInsets.fromLTRB(
                      FeSpace.md,
                      0,
                      FeSpace.md,
                      FeSpace.sm,
                    ),
                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SelectableText(
                        cite(f.answer),
                        style: t.bodyMedium?.copyWith(height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
        if (question.limitations.isNotEmpty) ...[
          const SizedBox(height: FeSpace.sm),
          CourtBulletGroup(
            key: const Key('court.limitations'),
            title: l.courtLimitations,
            icon: Icons.report_gmailerrorred_outlined,
            color: c.warning,
            items: [for (final it in question.limitations) cite(it)],
          ),
        ],
        FeSectionHeader(l.courtPrepare),
        CourtChecklist(
          keyPrefix: 'court.block.documents',
          title: l.courtBlockDocuments,
          icon: Icons.folder_open_outlined,
          color: c.accent,
          items: [
            for (final it in question.block(CourtPrepBlock.documents)) cite(it),
          ],
        ),
        CourtChecklist(
          keyPrefix: 'court.block.pitfalls',
          title: l.courtBlockPitfalls,
          icon: Icons.do_not_disturb_on_outlined,
          color: c.warning,
          items: [
            for (final it in question.block(CourtPrepBlock.pitfalls)) cite(it),
          ],
        ),
        CourtRelatedLinks(links: question.links),
        CourtSourcesSection(
          key: const Key('court.exportSection'),
          item: question,
          bundle: bundle,
          showList: false,
        ),
      ],
    );
  }
}
