import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/moderation.dart';
import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/date_format.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/moderation/moderation_models.dart';
import '../../professional/presentation/professional_widgets.dart';
import '../moderation_strings.dart';
import 'moderation_widgets.dart';

/// Shikoyat/murojaat: nomaqbul kontent, xato, reklama va boshqa. Kirmagan
/// foydalanuvchi ham yuboradi; soatiga 5 tagacha (server cheklaydi).
/// Foydalanuvchi faqat O‘Z shikoyatlarini (tur + holat) ko‘radi.
class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key, this.initialKind, this.target, this.targetId});

  final ReportKind? initialKind;
  final ReportTarget? target;
  final String? targetId;

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  late ReportKind _kind = widget.initialKind ?? ReportKind.complaint;
  final _body = TextEditingController();
  final _contact = TextEditingController();
  bool _busy = false;
  bool _showErrors = false;

  @override
  void dispose() {
    _body.dispose();
    _contact.dispose();
    super.dispose();
  }

  ReportDraft get _draft => ReportDraft(
    kind: _kind,
    body: _body.text,
    contact: _contact.text,
    target: widget.target,
    targetId: widget.targetId,
  );

  String? _errorText(AppLocalizations l) => switch (_draft.error) {
    ReportDraftError.bodyTooShort => l.repBodyShort(ReportLimits.bodyMin),
    ReportDraftError.bodyTooLong => l.repInvalid,
    ReportDraftError.contactTooLong => l.repInvalid,
    null => null,
  };

  Future<void> _send() async {
    final l = AppLocalizations.of(context);
    setState(() => _showErrors = true);
    if (_draft.error != null) return;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    final r = await ref.read(moderationServiceProvider).submitReport(_draft);
    if (!mounted) return;
    setState(() => _busy = false);
    messenger.showSnackBar(SnackBar(content: Text(l.repResultText(r))));
    if (r == ReportResult.created) {
      ref.invalidate(myReportsProvider);
      _body.clear();
      _contact.clear();
      setState(() => _showErrors = false);
      if (context.canPop()) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final available = ref.watch(reportAvailableProvider);
    final signedIn = ref.watch(authStateProvider).signedIn;
    final mine = signedIn ? ref.watch(myReportsProvider).value : null;
    return Scaffold(
      appBar: AppBar(title: Text(l.repTitle)),
      body: SafeArea(
        child: ListView(
          key: const Key('report.list'),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            FeContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: FeSpace.sm),
                  if (!available) ...[
                    FeEmptyState(
                      key: const Key('report.unavailable'),
                      icon: Icons.cloud_off_outlined,
                      body: l.repUnavailable,
                    ),
                    const Center(child: SupportContactLine()),
                  ] else ...[
                    Text(l.repIntro, style: t.bodyMedium),
                    const SizedBox(height: FeSpace.sm),
                    DropdownButtonFormField<ReportKind>(
                      style: Theme.of(context).textTheme.bodyLarge,
                      key: const Key('report.kind'),
                      initialValue: _kind,
                      isExpanded: true,
                      decoration: InputDecoration(labelText: l.repKindField),
                      items: [
                        for (final k in ReportKind.values)
                          DropdownMenuItem(
                            value: k,
                            child: Row(
                              children: [
                                Icon(k.icon, size: 18, color: c.accent),
                                const SizedBox(width: FeSpace.xs),
                                Flexible(
                                  child: Text(
                                    l.repKindLabel(k),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                      onChanged: (v) =>
                          setState(() => _kind = v ?? ReportKind.other),
                    ),
                    const SizedBox(height: FeSpace.sm),
                    TextField(
                      onTapOutside: (_) => FocusScope.of(context).unfocus(),
                      key: const Key('report.body'),
                      controller: _body,
                      minLines: 5,
                      maxLines: 12,
                      maxLength: ReportLimits.bodyMax,
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: l.repBody,
                        helperText: l.repBodyHint,
                        helperMaxLines: 3,
                        alignLabelWithHint: true,
                        errorText: _showErrors ? _errorText(l) : null,
                      ),
                    ),
                    const SizedBox(height: FeSpace.xs),
                    TextField(
                      onTapOutside: (_) => FocusScope.of(context).unfocus(),
                      key: const Key('report.contact'),
                      controller: _contact,
                      maxLength: ReportLimits.contactMax,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: l.repContact,
                        helperText: l.repContactHint,
                        helperMaxLines: 3,
                      ),
                    ),
                    const SizedBox(height: FeSpace.xs),
                    FeNote(
                      key: const Key('report.privacy'),
                      icon: Icons.lock_outline,
                      text: l.repPrivacy,
                    ),
                    const SizedBox(height: FeSpace.sm),
                    FilledButton(
                      key: const Key('report.send'),
                      onPressed: _busy ? null : _send,
                      child: _busy
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l.repSend),
                    ),
                    const SizedBox(height: FeSpace.xs),
                    const Center(child: SupportContactLine()),
                    if (mine != null && mine.isNotEmpty) ...[
                      FeSectionHeader(l.repMine),
                      for (final r in mine)
                        Padding(
                          padding: const EdgeInsets.only(bottom: FeSpace.xs),
                          child: FeCard(
                            key: Key('report.mine.${r.id}'),
                            padding: const EdgeInsets.all(FeSpace.sm),
                            child: Row(
                              children: [
                                Icon(r.kind.icon, color: c.textSecondary),
                                const SizedBox(width: FeSpace.sm),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l.repKindLabel(r.kind),
                                        style: t.titleSmall,
                                      ),
                                      if (r.createdAt case final d?)
                                        Text(
                                          feDate(context, d.toLocal()),
                                          style: t.bodySmall?.copyWith(
                                            color: c.textSecondary,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                StatusChip(
                                  icon: r.resolved
                                      ? Icons.check_circle_outline
                                      : Icons.hourglass_empty,
                                  label: r.resolved
                                      ? l.repStatusResolved
                                      : l.repStatusOpen,
                                  color: r.resolved ? c.verified : c.warning,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ],
                  const SizedBox(height: FeSpace.xl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Profil qatori: shikoyat yuborish (kirmagan foydalanuvchi ham ko‘radi).
void openReport(BuildContext context, {ReportKind? kind}) => context.push(
  kind == null ? Routes.report : '${Routes.report}?kind=${kind.wire}',
);
