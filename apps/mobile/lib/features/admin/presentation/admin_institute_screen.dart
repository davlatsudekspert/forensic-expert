import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/institutes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/date_format.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/admin/institute_models.dart';
import 'admin_codes_widgets.dart';
import 'admin_gate.dart';

/// Tashkilot sahifasi: ma’lumot, promokodlar jadvali (№, kod, holati) va
/// «Promokodni bekor qilish».
class AdminInstituteScreen extends ConsumerStatefulWidget {
  const AdminInstituteScreen({super.key, required this.instituteId});

  final String instituteId;

  @override
  ConsumerState<AdminInstituteScreen> createState() =>
      _AdminInstituteScreenState();
}

class _AdminInstituteScreenState extends ConsumerState<AdminInstituteScreen> {
  bool _busy = false;
  String? _message;

  Future<void> _revoke(InstituteCode code) async {
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (dc) => AlertDialog(
        title: Text(l.instRevokeTitle),
        content: Text(l.instRevokeBody(code.code)),
        actions: [
          TextButton(
            key: const Key('adminInst.revoke.no'),
            onPressed: () => Navigator.of(dc).pop(false),
            child: Text(l.instRevokeKeep),
          ),
          FilledButton(
            key: const Key('adminInst.revoke.yes'),
            onPressed: () => Navigator.of(dc).pop(true),
            child: Text(l.instRevoke),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _busy = true);
    final r = await ref
        .read(adminInstituteServiceProvider)
        .revokeCode(code.code);
    if (!mounted) return;
    ref.invalidate(adminInstituteProvider(widget.instituteId));
    ref.invalidate(adminInstitutesProvider);
    setState(() {
      _busy = false;
      _message = switch (r.value) {
        true => l.instRevokeDone,
        false => l.instRevokeNotFound,
        null => l.instLoadError,
      };
    });
  }

  Future<void> _archive(AppLocalizations l, bool archive) async {
    if (archive) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (dc) => AlertDialog(
          title: Text(l.instArchiveTitle),
          content: Text(l.instArchiveBody),
          actions: [
            TextButton(
              key: const Key('adminInst.archive.no'),
              onPressed: () => Navigator.of(dc).pop(false),
              child: Text(l.instDialogCancel),
            ),
            FilledButton(
              key: const Key('adminInst.archive.yes'),
              onPressed: () => Navigator.of(dc).pop(true),
              child: Text(l.instArchive),
            ),
          ],
        ),
      );
      if (ok != true || !mounted) return;
    }
    setState(() => _busy = true);
    final r = await ref
        .read(adminInstituteServiceProvider)
        .setArchived(widget.instituteId, archived: archive);
    if (!mounted) return;
    ref.invalidate(adminInstituteProvider(widget.instituteId));
    ref.invalidate(adminInstitutesProvider);
    setState(() {
      _busy = false;
      _message = r.value == null
          ? l.instActionError
          : (r.value! ? l.instArchiveDone : l.instRestoreDone);
    });
  }

  Future<void> _extend(AppLocalizations l) async {
    final months = await showDialog<int>(
      context: context,
      builder: (dc) {
        var sel = 1;
        return StatefulBuilder(
          builder: (dc, setS) => AlertDialog(
            title: Text(l.instExtendTitle),
            content: Wrap(
              spacing: FeSpace.xs,
              children: [
                for (final m in const [1, 3, 6, 12])
                  ChoiceChip(
                    key: Key('adminInst.extend.m.$m'),
                    label: Text(l.instExtendMonths(m)),
                    selected: sel == m,
                    onSelected: (_) => setS(() => sel = m),
                  ),
              ],
            ),
            actions: [
              TextButton(
                key: const Key('adminInst.extend.no'),
                onPressed: () => Navigator.of(dc).pop(),
                child: Text(l.instDialogCancel),
              ),
              FilledButton(
                key: const Key('adminInst.extend.yes'),
                onPressed: () => Navigator.of(dc).pop(sel),
                child: Text(l.instExtendYes),
              ),
            ],
          ),
        );
      },
    );
    if (months == null || !mounted) return;
    setState(() => _busy = true);
    final r = await ref
        .read(adminInstituteServiceProvider)
        .extend(widget.instituteId, months);
    if (!mounted) return;
    ref.invalidate(adminInstituteProvider(widget.instituteId));
    ref.invalidate(adminInstitutesProvider);
    final v = r.value;
    setState(() {
      _busy = false;
      _message = v == null
          ? l.instActionError
          : l.instExtendDone(feDate(context, v.termEnd), v.plansExtended);
    });
  }

  String _status(AppLocalizations l, InstituteCode c) => switch (c.status) {
    InstituteCodeStatus.free => l.instStatusFree,
    InstituteCodeStatus.redeemed => l.instStatusRedeemed(c.email ?? '—'),
    InstituteCodeStatus.revoked => l.instStatusRevoked,
  };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final data = ref.watch(adminInstituteProvider(widget.instituteId));
    final b = data.value;
    final listed = ref.watch(adminInstitutesProvider).value;
    final summary = listed
        ?.where((x) => x.id == widget.instituteId)
        .firstOrNull;
    final archived = summary?.archived ?? b?.detail.archived ?? false;
    return AdminGate(
      child: Scaffold(
        appBar: AppBar(title: FeAppBarTitle(b?.detail.name ?? l.instNavTitle)),
        body: SafeArea(
          child: ListView(
            key: const Key('adminInstDetail.list'),
            children: [
              FeContentFrame(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: FeSpace.sm),
                    if (b == null && data.isLoading)
                      FeListSkeleton(rows: 3, semanticLabel: l.loadingContent)
                    else if (b == null)
                      Text(
                        l.instLoadError,
                        key: const Key('adminInstDetail.error'),
                        style: t.bodyMedium?.copyWith(color: c.danger),
                      )
                    else ...[
                      if (b.detail.termStart != null &&
                          b.detail.termEnd != null)
                        Text(
                          l.instDetailTerm(
                            feDate(context, b.detail.termStart!),
                            feDate(context, b.detail.termEnd!),
                          ),
                          style: t.bodyMedium,
                        ),
                      Text(
                        l.instDetailSeats(
                          b.detail.seats,
                          b.codes
                              .where(
                                (x) => x.status == InstituteCodeStatus.redeemed,
                              )
                              .length,
                          b.codes.where((x) => x.revoked).length,
                        ),
                        key: const Key('adminInstDetail.seats'),
                        style: t.bodyMedium,
                      ),
                      if (archived) ...[
                        const SizedBox(height: FeSpace.xs),
                        FeBanner(
                          key: const Key('adminInstDetail.archivedNote'),
                          icon: Icons.inventory_2_outlined,
                          text: l.instArchivedNote,
                          tone: FeBannerTone.warning,
                        ),
                      ],
                      const SizedBox(height: FeSpace.sm),
                      FilledButton.icon(
                        key: const Key('adminInstDetail.extend'),
                        onPressed: _busy ? null : () => _extend(l),
                        icon: const Icon(Icons.event_repeat_outlined),
                        label: Text(l.instExtend),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(0, FeTouch.minTarget),
                        ),
                      ),
                      const SizedBox(height: FeSpace.xs),
                      OutlinedButton.icon(
                        key: Key(
                          archived
                              ? 'adminInstDetail.restore'
                              : 'adminInstDetail.archive',
                        ),
                        onPressed: _busy ? null : () => _archive(l, !archived),
                        icon: Icon(
                          archived
                              ? Icons.unarchive_outlined
                              : Icons.archive_outlined,
                        ),
                        label: Text(archived ? l.instRestore : l.instArchive),
                      ),
                      if (_message != null)
                        Padding(
                          padding: const EdgeInsets.only(top: FeSpace.xs),
                          child: Semantics(
                            liveRegion: true,
                            child: Text(
                              _message!,
                              key: const Key('adminInstDetail.message'),
                              style: t.bodyMedium,
                            ),
                          ),
                        ),
                      FeSectionHeader(l.instCodesTitle),
                      FeBanner(
                        icon: Icons.lock_outline,
                        text: l.instCodesNote,
                        tone: FeBannerTone.warning,
                      ),
                      const SizedBox(height: FeSpace.xs),
                      OutlinedButton.icon(
                        key: const Key('adminInstDetail.copyAll'),
                        onPressed: () => copyCodes(context, [
                          for (final x in b.codes)
                            if (x.status == InstituteCodeStatus.free) x.code,
                        ]),
                        icon: const Icon(Icons.copy_all_outlined),
                        label: Text(l.instCopyAll),
                      ),
                      const SizedBox(height: FeSpace.xs),
                      Row(
                        children: [
                          SizedBox(
                            width: 32,
                            child: Text(l.instColNo, style: t.labelMedium),
                          ),
                          Expanded(
                            child: Text(l.instColCode, style: t.labelMedium),
                          ),
                          Expanded(
                            child: Text(l.instColStatus, style: t.labelMedium),
                          ),
                        ],
                      ),
                      const Divider(height: FeSpace.xs),
                      for (final x in b.codes)
                        Padding(
                          key: Key('adminInstDetail.code.${x.n}'),
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(width: 32, child: Text(x.n.toString())),
                              Expanded(
                                child: SelectableText(
                                  x.code,
                                  style: FeThemeBuilder.numeric(t.bodyMedium!),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  _status(l, x),
                                  style: t.bodySmall?.copyWith(
                                    color:
                                        x.status == InstituteCodeStatus.revoked
                                        ? c.danger
                                        : c.textSecondary,
                                  ),
                                ),
                              ),
                              IconButton(
                                key: Key('adminInstDetail.copy.${x.n}'),
                                tooltip: l.instCopy,
                                icon: const Icon(Icons.copy_outlined, size: 18),
                                onPressed: () => copyCodes(context, [x.code]),
                              ),
                              if (x.status == InstituteCodeStatus.free)
                                IconButton(
                                  key: Key('adminInstDetail.revoke.${x.n}'),
                                  tooltip: l.instRevoke,
                                  icon: Icon(
                                    Icons.block_outlined,
                                    size: 18,
                                    color: c.danger,
                                  ),
                                  onPressed: _busy ? null : () => _revoke(x),
                                ),
                            ],
                          ),
                        ),
                    ],
                    const SizedBox(height: FeSpace.lg),
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
