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

/// Fayl nomi uchun xavfsiz qism: lotin harf/raqam, qolgani `_`.
String fileSlug(String name) {
  final s = name
      .replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');
  return s.isEmpty ? 'institut' : s;
}

/// Institut sahifasi: ma’lumot, kodlar jadvali (№, kod, holati), «Kodni bekor
/// qilish» va «Shartnoma PDF» (+ alohida «Kodlar varag‘i»).
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

  Future<void> _pdf(InstituteBundle b) async {
    final l = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final svc = ref.read(contractPdfServiceProvider);
      final contract = await svc.contract(
        b.detail,
        ref.read(licensorProfileProvider),
      );
      final sheet = await svc.codesSheet(b.detail, [
        for (final c in b.codes)
          if (c.status != InstituteCodeStatus.revoked) c,
      ]);
      final slug = fileSlug(b.detail.name);
      await ref.read(contractFileShareProvider).sharePdfs([
        PdfAttachment('Shartnoma_$slug.pdf', contract),
        PdfAttachment('Kodlar_varagi_$slug.pdf', sheet),
      ]);
      if (mounted) setState(() => _busy = false);
    } on Object {
      if (mounted) {
        setState(() {
          _busy = false;
          _message = l.instPdfError;
        });
      }
    }
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
                      Text(
                        l.instFTotal(formatSom(b.detail.total)),
                        style: t.bodyMedium,
                      ),
                      const SizedBox(height: FeSpace.sm),
                      FilledButton.icon(
                        key: const Key('adminInstDetail.pdf'),
                        onPressed: _busy ? null : () => _pdf(b),
                        icon: const Icon(Icons.picture_as_pdf_outlined),
                        label: Text(l.instPdf),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(0, FeTouch.minTarget),
                        ),
                      ),
                      const SizedBox(height: FeSpace.xs),
                      Text(
                        l.instPdfNote,
                        style: t.bodySmall?.copyWith(color: c.textSecondary),
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
