import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:fe_search_core/fe_search_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/publications.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/date_format.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/publications/publication_models.dart';
import '../../disciplines/discipline_strings.dart';
import '../publication_strings.dart';
import 'publication_widgets.dart';

/// Fan kodi → nom (noma’lum kod — kodning o‘zi).
String disciplineLabel(AppLocalizations l, String? code) {
  if (code == null) return '';
  final d = ForensicDiscipline.fromCode(code);
  return d == null ? code : l.disciplineName(d);
}

/// «Ekspert maqolalari»: nashr etilgan maqolalar ro‘yxati (o‘qish bepul),
/// qidiruv va fan bo‘yicha filtr.
class PublicationsScreen extends ConsumerStatefulWidget {
  const PublicationsScreen({super.key});

  @override
  ConsumerState<PublicationsScreen> createState() => _PublicationsScreenState();
}

class _PublicationsScreenState extends ConsumerState<PublicationsScreen> {
  static const _normalizer = SearchNormalizer();
  String _query = '';
  String? _discipline;

  bool _matches(Publication p) {
    if (_discipline != null && p.disciplineCode != _discipline) return false;
    final key = _normalizer.searchKey(_query);
    if (key.isEmpty) return true;
    return [
      p.title,
      p.abstract,
      ...p.keywords,
    ].any((s) => _normalizer.searchKey(s).contains(key));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final signedIn = ref.watch(authStateProvider).signedIn;
    final canModerate =
        ref.watch(canModeratePublicationsProvider).value ?? false;
    final data = ref.watch(publishedPublicationsProvider);
    return PublicationsGate(
      title: l.pubTitle,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.pubTitle),
          actions: [
            if (signedIn)
              IconButton(
                key: const Key('publications.mine'),
                tooltip: l.pubMine,
                icon: const Icon(Icons.folder_shared_outlined),
                onPressed: () => context.push(Routes.publicationsMine),
              ),
            if (canModerate)
              IconButton(
                key: const Key('publications.moderation'),
                tooltip: l.pubModeration,
                icon: const Icon(Icons.gavel_outlined),
                onPressed: () => context.push(Routes.publicationsModeration),
              ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          key: const Key('publications.submit'),
          onPressed: () => context.push(Routes.publicationSubmit),
          icon: const Icon(Icons.post_add),
          label: Text(l.pubSubmit),
        ),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () => ref.refresh(publishedPublicationsProvider.future),
            child: ListView(
              key: const Key('publications.list'),
              children: [
                FeContentFrame(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: FeSpace.sm),
                      Text(
                        l.pubIntro,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: FeTheme.of(context).textSecondary,
                        ),
                      ),
                      const SizedBox(height: FeSpace.xs),
                      const PublicationNotice(),
                      const SizedBox(height: FeSpace.sm),
                      ..._content(context, l, data),
                      const SizedBox(height: FeSpace.xxl),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _content(
    BuildContext context,
    AppLocalizations l,
    AsyncValue<List<Publication>?> data,
  ) {
    switch (data) {
      case AsyncLoading():
        return const [Center(child: CircularProgressIndicator())];
      case AsyncData(value: final all?):
        if (all.isEmpty) {
          return [
            FeEmptyState(
              key: const Key('publications.empty'),
              icon: Icons.article_outlined,
              body: l.pubEmpty,
            ),
          ];
        }
        final codes = {for (final p in all) ?p.disciplineCode}.toList()..sort();
        final shown = all.where(_matches).toList();
        return [
          TextField(
            key: const Key('publications.search'),
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: l.pubSearchHint,
              prefixIcon: const Icon(Icons.search),
              isDense: true,
            ),
          ),
          const SizedBox(height: FeSpace.xs),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final code in [null, ...codes])
                  Padding(
                    padding: const EdgeInsets.only(right: FeSpace.xs),
                    child: ChoiceChip(
                      key: Key('publications.discipline.${code ?? 'all'}'),
                      label: Text(
                        code == null
                            ? l.pubAllDisciplines
                            : disciplineLabel(l, code),
                      ),
                      selected: _discipline == code,
                      onSelected: (_) => setState(() => _discipline = code),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: FeSpace.sm),
          if (shown.isEmpty)
            FeEmptyState(
              key: const Key('publications.filterEmpty'),
              icon: Icons.filter_alt_off_outlined,
              body: l.pubFilterEmpty,
            ),
          for (final p in shown) _PublicationCard(p: p),
        ];
      default:
        return [
          FeEmptyState(
            key: const Key('publications.error'),
            icon: Icons.cloud_off_outlined,
            body: l.pubLoadFailed,
          ),
          TextButton(
            onPressed: () => ref.invalidate(publishedPublicationsProvider),
            child: Text(l.pubReload),
          ),
        ];
    }
  }
}

class _PublicationCard extends StatelessWidget {
  const _PublicationCard({required this.p});

  final Publication p;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: FeSpace.xs),
      child: FeCard(
        key: Key('publications.item.${p.id}'),
        onTap: () => context.push(Routes.publication(p.id)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(p.title, style: t.titleSmall),
            const SizedBox(height: FeSpace.xxs),
            Text(
              [
                if (p.disciplineCode != null)
                  disciplineLabel(l, p.disciplineCode),
                if (p.coauthors.isNotEmpty) p.coauthors.join(', '),
                if (p.publishedAt != null)
                  feDate(context, p.publishedAt!.toLocal()),
              ].join(' · '),
              style: t.bodySmall?.copyWith(color: c.textSecondary),
            ),
            if (p.abstract.isNotEmpty) ...[
              const SizedBox(height: FeSpace.xxs),
              Text(
                p.abstract,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: t.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Maqola sahifasi: ilmiy tasdiq emasligi haqida aniq ogohlantirish va
/// holat belgisi. Kirgan foydalanuvchi shikoyat yuborishi mumkin.
class PublicationDetailScreen extends ConsumerWidget {
  const PublicationDetailScreen({super.key, required this.publicationId});

  final String publicationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final data = ref.watch(publicationByIdProvider(publicationId));
    final signedIn = ref.watch(authStateProvider).signedIn;
    return PublicationsGate(
      title: l.pubTitle,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.pubTitle),
          actions: [
            if (signedIn && data.value?.status == PublicationStatus.published)
              IconButton(
                key: const Key('publication.report'),
                tooltip: l.pubReport,
                icon: const Icon(Icons.flag_outlined),
                onPressed: () => _report(context, ref),
              ),
          ],
        ),
        body: SafeArea(
          child: switch (data) {
            AsyncData(:final value?) => _Detail(p: value),
            AsyncData() || AsyncError() => FeEmptyState(
              key: const Key('publication.notFound'),
              icon: Icons.search_off,
              body: l.pubNotFound,
            ),
            _ => const Center(child: CircularProgressIndicator()),
          },
        ),
      ),
    );
  }

  Future<void> _report(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final picked = await showDialog<(ReportReason, String)>(
      context: context,
      builder: (_) => const _ReportDialog(),
    );
    if (picked == null) return;
    final r = await ref
        .read(publicationServiceProvider)
        .report(publicationId, picked.$1, picked.$2);
    messenger.showSnackBar(
      SnackBar(
        content: Text(switch (r) {
          ReportResult.reported => l.pubReported,
          ReportResult.alreadyReported => l.pubAlreadyReported,
          ReportResult.failed => l.pubActionFailed,
        }),
      ),
    );
  }
}

class _ReportDialog extends StatefulWidget {
  const _ReportDialog();

  @override
  State<_ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<_ReportDialog> {
  ReportReason _reason = ReportReason.plagiarism;
  final _details = TextEditingController();

  @override
  void dispose() {
    _details.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l.pubReportTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RadioGroup<ReportReason>(
              groupValue: _reason,
              onChanged: (v) => setState(() => _reason = v ?? _reason),
              child: Column(
                children: [
                  for (final r in ReportReason.values)
                    RadioListTile<ReportReason>(
                      key: Key('publication.reason.${r.name}'),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      value: r,
                      title: Text(l.pubReason(r)),
                    ),
                ],
              ),
            ),
            TextField(
              key: const Key('publication.reportDetails'),
              controller: _details,
              maxLines: 3,
              maxLength: 2000,
              decoration: InputDecoration(labelText: l.pubReportDetails),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.pubCancel),
        ),
        FilledButton(
          key: const Key('publication.reportSend'),
          onPressed: () =>
              Navigator.of(context).pop((_reason, _details.text.trim())),
          child: Text(l.pubReportSend),
        ),
      ],
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.p});

  final Publication p;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    Widget field(String label, String value) => Padding(
      padding: const EdgeInsets.only(top: FeSpace.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: t.labelMedium?.copyWith(color: c.textSecondary)),
          const SizedBox(height: 2),
          SelectableText(value, style: t.bodyMedium),
        ],
      ),
    );
    return ListView(
      key: const Key('publication.detail'),
      children: [
        FeContentFrame(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: FeSpace.sm),
              const PublicationNotice(),
              const SizedBox(height: FeSpace.sm),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: PublicationStatusBadge(
                  p.status,
                  key: const Key('publication.status'),
                ),
              ),
              const SizedBox(height: FeSpace.xs),
              Text(p.title, style: t.titleLarge),
              const SizedBox(height: FeSpace.xxs),
              Text(
                [
                  l.pubVersion(p.version),
                  l.pubLang(p.language),
                  if (p.publishedAt != null)
                    l.pubPublishedOn(feDate(context, p.publishedAt!.toLocal())),
                ].join(' · '),
                style: t.bodySmall?.copyWith(color: c.textSecondary),
              ),
              if (p.disciplineCode != null)
                field(l.pubDiscipline, disciplineLabel(l, p.disciplineCode)),
              if (p.coauthors.isNotEmpty)
                field(l.pubAuthors, p.coauthors.join('\n')),
              if (p.affiliation != null)
                field(l.pubAffiliation, p.affiliation!),
              if (p.abstract.isNotEmpty) field(l.pubAbstract, p.abstract),
              if (p.keywords.isNotEmpty)
                field(l.pubKeywords, p.keywords.join(', ')),
              if (p.doi != null) field(l.pubDoi, p.doi!),
              if (p.externalUrl != null)
                Padding(
                  padding: const EdgeInsets.only(top: FeSpace.sm),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.link),
                    title: Text(l.pubExternalUrl),
                    subtitle: Text(p.externalUrl!),
                    onTap: () =>
                        Clipboard.setData(ClipboardData(text: p.externalUrl!)),
                  ),
                ),
              if (p.referenceList != null)
                field(l.pubReferences, p.referenceList!),
              const SizedBox(height: FeSpace.xl),
            ],
          ),
        ),
      ],
    );
  }
}
