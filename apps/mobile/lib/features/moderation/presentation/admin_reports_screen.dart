import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/moderation.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/moderation/moderation_models.dart';
import '../../admin/presentation/admin_gate.dart';
import '../../support/presentation/support_widgets.dart';
import '../moderation_strings.dart';

/// Admin: shikoyatlar ro‘yxati — holat/tur bo‘yicha saralash, qidiruv
/// (`%`, `_`, `\` serverda ekranlanadi), izoh yozish va «hal qilindi».
/// Marshrut [AdminGate] bilan yopiq; har bir amalni server qayta tekshiradi.
class AdminReportsScreen extends ConsumerStatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  ConsumerState<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends ConsumerState<AdminReportsScreen> {
  AdminReportFilter _f = const AdminReportFilter();
  int _limit = AdminReportFilter.pageSize;
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _refresh() {
    ref.invalidate(adminReportsProvider);
    ref.invalidate(adminStatsExtProvider);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    final page = ref.watch(adminReportsProvider((_f, _limit)));
    Widget chip(String key, String label, bool selected, VoidCallback onTap) =>
        Padding(
          padding: const EdgeInsetsDirectional.only(end: FeSpace.xs),
          child: ChoiceChip(
            key: Key(key),
            label: Text(label),
            selected: selected,
            onSelected: (_) => onTap(),
          ),
        );
    return AdminGate(
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.admxReportsTitle),
          actions: [
            IconButton(
              key: const Key('adminReports.refresh'),
              tooltip: l.adminRefresh,
              icon: const Icon(Icons.refresh),
              onPressed: _refresh,
            ),
          ],
        ),
        body: SafeArea(
          child: ListView(
            key: const Key('adminReports.list'),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              FeContentFrame(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: FeSpace.sm),
                    FeBanner(
                      icon: Icons.privacy_tip_outlined,
                      text: l.adminPrivacyNote,
                    ),
                    const SizedBox(height: FeSpace.sm),
                    TextField(
                      onTapOutside: (_) => FocusScope.of(context).unfocus(),
                      key: const Key('adminReports.search'),
                      controller: _search,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: l.admxReportsSearch,
                      ),
                      // Xom matn yuboriladi: `%`, `_`, `\` ni server ekranlaydi.
                      onSubmitted: (q) => setState(() {
                        _f = _f.copyWith(query: q.trim());
                        _limit = AdminReportFilter.pageSize;
                      }),
                    ),
                    const SizedBox(height: FeSpace.xs),
                    SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final (v, label) in [
                            (AdminReportStatus.open, l.admxOpen),
                            (AdminReportStatus.resolved, l.admxResolvedFilter),
                            (AdminReportStatus.all, l.admxAll),
                          ])
                            chip(
                              'adminReports.status.${v.name}',
                              label,
                              _f.status == v,
                              () => setState(() {
                                _f = _f.copyWith(status: v);
                                _limit = AdminReportFilter.pageSize;
                              }),
                            ),
                        ],
                      ),
                    ),
                    SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          chip(
                            'adminReports.kind.any',
                            l.admxKindAny,
                            _f.kind == null,
                            () => setState(() {
                              _f = _f.copyWith(kind: () => null);
                              _limit = AdminReportFilter.pageSize;
                            }),
                          ),
                          for (final k in ReportKind.values)
                            chip(
                              'adminReports.kind.${k.wire}',
                              l.repKindLabel(k),
                              _f.kind == k,
                              () => setState(() {
                                _f = _f.copyWith(kind: () => k);
                                _limit = AdminReportFilter.pageSize;
                              }),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: FeSpace.xs),
                    // Savol-javob postiga shikoyat mavjud 3-kishilik oqim
                    // bilan boradi; moderatsiya navbati o‘sha yerda.
                    FeCard(
                      key: const Key('adminReports.qaLink'),
                      padding: const EdgeInsets.all(FeSpace.sm),
                      onTap: () => context.push(Routes.qaModeration),
                      child: Row(
                        children: [
                          Icon(Icons.forum_outlined, color: c.accent),
                          const SizedBox(width: FeSpace.sm),
                          Expanded(
                            child: Text(l.admxQaLink, style: t.bodyMedium),
                          ),
                          Icon(Icons.chevron_right, color: c.textSecondary),
                        ],
                      ),
                    ),
                    const SizedBox(height: FeSpace.sm),
                    ...switch (page) {
                      AsyncData(:final value?) when value.items.isEmpty => [
                        FeEmptyState(
                          key: const Key('adminReports.empty'),
                          icon: Icons.inbox_outlined,
                          body: l.admxReportsEmpty,
                        ),
                      ],
                      AsyncData(:final value?) => [
                        Text(
                          l.admShown(value.items.length, value.total),
                          style: t.bodySmall?.copyWith(color: c.textSecondary),
                        ),
                        const SizedBox(height: FeSpace.xs),
                        for (final r in value.items)
                          ReportCard(
                            key: ValueKey('${r.id}:${r.resolved}'),
                            report: r,
                            onChanged: _refresh,
                          ),
                        if (value.items.length < value.total)
                          OutlinedButton(
                            key: const Key('adminReports.more'),
                            onPressed: () => setState(
                              () => _limit += AdminReportFilter.pageSize,
                            ),
                            child: Text(l.admxLoadMore),
                          ),
                      ],
                      AsyncLoading() => [
                        FeListSkeleton(
                          rows: 3,
                          semanticLabel: l.loadingContent,
                        ),
                      ],
                      _ => [
                        FeEmptyState(
                          key: const Key('adminReports.failed'),
                          icon: Icons.cloud_off_outlined,
                          body: l.adminFailed,
                        ),
                      ],
                    },
                    const SizedBox(height: FeSpace.xl),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bitta shikoyat: matn, kim yuborgani, izoh maydoni va holat tugmasi.
class ReportCard extends ConsumerStatefulWidget {
  const ReportCard({super.key, required this.report, required this.onChanged});

  final AdminReport report;
  final VoidCallback onChanged;

  @override
  ConsumerState<ReportCard> createState() => _ReportCardState();
}

class _ReportCardState extends ConsumerState<ReportCard> {
  late final _note = TextEditingController(text: widget.report.adminNote);
  bool _busy = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  void _say(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> _saveNote() async {
    final l = AppLocalizations.of(context);
    if (_note.text.trim().isEmpty) return;
    setState(() => _busy = true);
    final ok = await ref
        .read(moderationServiceProvider)
        .adminReportNote(widget.report.id, _note.text);
    if (!mounted) return;
    setState(() => _busy = false);
    _say(ok ? l.admxNoteSaved : l.admxActionFailed);
    if (ok) widget.onChanged();
  }

  Future<void> _toggle() async {
    final l = AppLocalizations.of(context);
    final resolve = !widget.report.resolved;
    setState(() => _busy = true);
    final ok = await ref
        .read(moderationServiceProvider)
        .adminResolveReport(
          widget.report.id,
          resolved: resolve,
          note: _note.text,
        );
    if (!mounted) return;
    setState(() => _busy = false);
    _say(
      ok ? (resolve ? l.admxResolvedDone : l.admxReopened) : l.admxActionFailed,
    );
    if (ok) widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    final r = widget.report;
    return Padding(
      padding: const EdgeInsets.only(bottom: FeSpace.xs),
      child: FeCard(
        key: Key('adminReports.report.${r.id}'),
        padding: const EdgeInsets.all(FeSpace.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: FeSpace.xs,
              runSpacing: FeSpace.xxs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                StatusChip(
                  icon: r.kind.icon,
                  label: l.repKindLabel(r.kind),
                  color: c.accent,
                ),
                StatusChip(
                  icon: r.resolved
                      ? Icons.check_circle_outline
                      : Icons.hourglass_empty,
                  label: r.resolved ? l.repStatusResolved : l.repStatusOpen,
                  color: r.resolved ? c.verified : c.warning,
                ),
                if (r.createdAt != null)
                  Text(
                    supportTime(context, r.createdAt),
                    style: t.labelSmall?.copyWith(color: c.textSecondary),
                  ),
              ],
            ),
            const SizedBox(height: FeSpace.xs),
            SelectableText(r.body, style: t.bodyMedium),
            const SizedBox(height: FeSpace.xs),
            Text(
              [
                r.anonymous
                    ? l.admxAnonymous
                    : (r.reporterEmail ?? l.admxAnonymous),
                if ((r.contact ?? '').isNotEmpty) l.admxContact(r.contact!),
                if (r.targetType != null) l.admxTarget(r.targetType!),
              ].join(FeGlyphs.middleDot),
              style: t.bodySmall?.copyWith(color: c.textSecondary),
            ),
            const SizedBox(height: FeSpace.xs),
            TextField(
              onTapOutside: (_) => FocusScope.of(context).unfocus(),
              key: Key('adminReports.note.${r.id}'),
              controller: _note,
              minLines: 1,
              maxLines: 4,
              maxLength: 2000,
              decoration: InputDecoration(labelText: l.admxNoteLabel),
            ),
            Wrap(
              spacing: FeSpace.xs,
              children: [
                OutlinedButton(
                  key: Key('adminReports.saveNote.${r.id}'),
                  onPressed: _busy ? null : _saveNote,
                  child: Text(l.admxNoteSave),
                ),
                FilledButton(
                  key: Key('adminReports.toggle.${r.id}'),
                  onPressed: _busy ? null : _toggle,
                  child: Text(r.resolved ? l.admxReopen : l.admxResolve),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
