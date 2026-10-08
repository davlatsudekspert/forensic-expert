import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/professional.dart';
import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/ports/professional_ports.dart';
import '../../../domain/professional/professional_models.dart';
import '../../../domain/professional/review_models.dart';
import '../professional_strings.dart';
import 'professional_widgets.dart';

/// Tanlangan (hali yuborilmagan) hujjatlar — faqat xotirada, ilova
/// yopilganda yo‘qoladi. Diskka yozilmaydi.
final pendingCredentialsProvider =
    NotifierProvider<PendingCredentials, List<CredentialFile>>(
      PendingCredentials.new,
    );

class PendingCredentials extends Notifier<List<CredentialFile>> {
  @override
  List<CredentialFile> build() => const [];

  void add(CredentialFile f) => state = [...state, f];

  void removeAt(int i) => state = [...state]..removeAt(i);

  void clear() => state = const [];
}

/// Professional maqomni tasdiqlash: holat, jarayon, hujjatlar, ariza.
class VerificationScreen extends ConsumerWidget {
  const VerificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final service = ref.watch(professionalVerificationServiceProvider);
    final signedIn = ref.watch(authStateProvider.select((s) => s.signedIn));
    final snapshot =
        ref.watch(professionalSnapshotProvider).value ??
        ProfessionalSnapshot.empty;
    final status = snapshot.status;
    final pro = ref.watch(localProfileProvider).professional;
    final pending = ref.watch(pendingCredentialsProvider);
    final profileComplete =
        pro != null && ProfileValidation.professional(pro).isEmpty;
    final canSubmit =
        service.isConfigured &&
        signedIn &&
        profileComplete &&
        VerificationStateMachine.canSubmit(status);

    final steps = [
      (Icons.badge_outlined, l.verifStep1),
      (Icons.upload_file_outlined, l.verifStep2),
      (Icons.manage_accounts_outlined, l.verifStep3),
      (Icons.rule_outlined, l.verifStep4),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l.verifTitle)),
      body: SafeArea(
        child: ListView(
          key: const Key('verification.list'),
          padding: const EdgeInsets.symmetric(vertical: FeSpace.md),
          children: [
            FeContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    key: const Key('verification.statusCard'),
                    child: Padding(
                      padding: const EdgeInsets.all(FeSpace.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l.verifStatusLabel, style: t.labelMedium),
                          const SizedBox(height: FeSpace.xs),
                          VerificationStatusChip(status: status),
                          const SizedBox(height: FeSpace.sm),
                          Text(
                            switch (status) {
                              VerificationStatus.unverified =>
                                l.verifUnverifiedBody,
                              VerificationStatus.applicationPending =>
                                l.verifPendingBody,
                              VerificationStatus.verifiedProfessional =>
                                l.verifVerifiedBody,
                              VerificationStatus.changesRequested =>
                                l.verifChangesBody,
                              VerificationStatus.rejected =>
                                l.verifRejectedBody,
                              VerificationStatus.suspended =>
                                l.verifSuspendedBody,
                            },
                            style: t.bodyMedium?.copyWith(
                              color: c.textSecondary,
                            ),
                          ),
                          if (snapshot.application?.applicantMessage
                              case final m?) ...[
                            const SizedBox(height: FeSpace.sm),
                            FeNote(icon: Icons.mail_outline, text: m),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (!service.isConfigured) ...[
                    const SizedBox(height: FeSpace.sm),
                    FeBanner(
                      key: const Key('verification.notConnected'),
                      icon: Icons.cloud_off_outlined,
                      text: l.verifServiceNotConnected,
                    ),
                  ],
                  FeSectionHeader(l.verifHowTitle),
                  for (final (i, (icon, text)) in steps.indexed)
                    Padding(
                      padding: const EdgeInsets.only(bottom: FeSpace.sm),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: c.accentContainer,
                            child: Text(
                              '${i + 1}',
                              style: t.labelMedium?.copyWith(color: c.accent),
                            ),
                          ),
                          const SizedBox(width: FeSpace.sm),
                          Icon(icon, size: 20, color: c.textSecondary),
                          const SizedBox(width: FeSpace.xs),
                          Expanded(child: Text(text, style: t.bodyMedium)),
                        ],
                      ),
                    ),
                  FeNote(
                    key: const Key('verification.humanOnly'),
                    icon: Icons.policy_outlined,
                    text: l.verifHumanOnly,
                  ),
                  FeSectionHeader(l.verifApplication),
                  ListTile(
                    key: const Key('verification.profile'),
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.badge_outlined),
                    title: Text(l.profileProTitle),
                    subtitle: Text(
                      pro == null ? l.verifProfileMissing : pro.fullName,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(Routes.profileEdit),
                  ),
                  ListTile(
                    key: const Key('verification.documents'),
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.upload_file_outlined),
                    title: Text(l.credUploadTitle),
                    subtitle: Text(
                      pending.isEmpty
                          ? l.credOptional
                          : l.credSelectedCount(pending.length),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(Routes.verificationDocuments),
                  ),
                  const SizedBox(height: FeSpace.md),
                  FilledButton.icon(
                    key: const Key('verification.submit'),
                    onPressed: canSubmit
                        ? () async {
                            final messenger = ScaffoldMessenger.of(context);
                            final r = await service.submit(
                              profile: pro,
                              documents: pending,
                            );
                            if (r.ok) {
                              ref
                                  .read(pendingCredentialsProvider.notifier)
                                  .clear();
                              ref.invalidate(professionalSnapshotProvider);
                              if (context.mounted) {
                                await showApplicationReceived(context);
                              }
                            } else {
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    l.professionalFailureLabel(r.failure!),
                                  ),
                                ),
                              );
                            }
                          }
                        : null,
                    icon: const Icon(Icons.send_outlined),
                    label: Text(l.verifSubmit),
                  ),
                  const SizedBox(height: FeSpace.xs),
                  Text(
                    !service.isConfigured
                        ? l.verifSubmitUnavailable
                        : !signedIn
                        ? l.reviewPermSignIn
                        : !profileComplete
                        ? l.verifProfileMissing
                        : l.verifSubmitNote,
                    key: const Key('verification.submitNote'),
                    textAlign: TextAlign.center,
                    style: t.bodySmall?.copyWith(color: c.textSecondary),
                  ),
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

/// Malaka hujjatini yuklash (ixtiyoriy). Hujjat xususiy: hech qachon
/// ochiq ko‘rsatilmaydi; ochiq URL yo‘q; tarkibi jurnalga yozilmaydi.
class CredentialUploadScreen extends ConsumerStatefulWidget {
  const CredentialUploadScreen({super.key});

  @override
  ConsumerState<CredentialUploadScreen> createState() =>
      _CredentialUploadScreenState();
}

class _CredentialUploadScreenState
    extends ConsumerState<CredentialUploadScreen> {
  CredentialKind _kind = CredentialKind.qualificationCertificate;
  String? _error;

  Future<void> _pick() async {
    final l = AppLocalizations.of(context);
    final pending = ref.read(pendingCredentialsProvider);
    if (pending.length >= CredentialFilePolicy.maxFiles) {
      setState(() => _error = l.credErrorTooMany);
      return;
    }
    PickedFile? f;
    try {
      f = await ref.read(credentialFilePickerProvider).pick();
    } on Exception {
      setState(() => _error = l.credPickFailed);
      return;
    }
    if (f == null) return;
    final bytes = Uint8List.fromList(f.bytes);
    final e = CredentialFilePolicy.validate(bytes);
    if (e != null) {
      setState(() => _error = l.credentialFileErrorLabel(e));
      return;
    }
    ref
        .read(pendingCredentialsProvider.notifier)
        .add(CredentialFile(fileName: f.name, kind: _kind, bytes: bytes));
    setState(() => _error = null);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final configured = ref
        .watch(professionalVerificationServiceProvider)
        .isConfigured;
    final pending = ref.watch(pendingCredentialsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.credUploadTitle)),
      body: SafeArea(
        child: ListView(
          key: const Key('credentials.list'),
          padding: const EdgeInsets.symmetric(vertical: FeSpace.md),
          children: [
            FeContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l.credIntro,
                    style: t.bodyMedium?.copyWith(color: c.textSecondary),
                  ),
                  const SizedBox(height: FeSpace.md),
                  FeBanner(
                    key: const Key('credentials.privacy'),
                    icon: Icons.lock_outline,
                    text: l.credPrivacy,
                  ),
                  const SizedBox(height: FeSpace.sm),
                  FeBanner(
                    key: const Key('credentials.noCaseData'),
                    icon: Icons.report_gmailerrorred_outlined,
                    tone: FeBannerTone.warning,
                    text: l.credNoCaseData,
                  ),
                  FeSectionHeader(l.credKindTitle),
                  for (final k in CredentialKind.values)
                    Padding(
                      padding: const EdgeInsets.only(bottom: FeSpace.xs),
                      child: FeChoiceCard(
                        key: Key('credentials.kind.${k.name}'),
                        icon: Icons.description_outlined,
                        title: l.credentialKindLabel(k),
                        selected: _kind == k,
                        onTap: () => setState(() => _kind = k),
                      ),
                    ),
                  const SizedBox(height: FeSpace.sm),
                  FeNote(icon: Icons.info_outline, text: l.credFormats),
                  const SizedBox(height: FeSpace.md),
                  OutlinedButton.icon(
                    key: const Key('credentials.pick'),
                    onPressed: _pick,
                    icon: const Icon(Icons.attach_file),
                    label: Text(l.credChooseFile),
                  ),
                  if (_error case final e?) ...[
                    const SizedBox(height: FeSpace.xs),
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        e,
                        key: const Key('credentials.error'),
                        style: t.bodyMedium?.copyWith(color: c.danger),
                      ),
                    ),
                  ],
                  if (pending.isNotEmpty) ...[
                    FeSectionHeader(l.credSelectedTitle),
                    for (final (i, f) in pending.indexed)
                      ListTile(
                        key: Key('credentials.file.$i'),
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(switch (CredentialFilePolicy.detect(
                          f.bytes,
                        )) {
                          CredentialFileType.pdf =>
                            Icons.picture_as_pdf_outlined,
                          _ => Icons.image_outlined,
                        }),
                        title: Text(
                          f.fileName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${l.credentialKindLabel(f.kind)} · '
                          '${l.fileSizeKb((f.sizeBytes / 1024).ceil().toString())}',
                        ),
                        trailing: IconButton(
                          tooltip: l.actionRemove,
                          icon: const Icon(Icons.close),
                          onPressed: () => ref
                              .read(pendingCredentialsProvider.notifier)
                              .removeAt(i),
                        ),
                      ),
                    const SizedBox(height: FeSpace.xs),
                    FeNote(
                      key: const Key('credentials.notUploaded'),
                      icon: configured
                          ? Icons.schedule_send_outlined
                          : Icons.cloud_off_outlined,
                      text: configured
                          ? l.credWillSendOnSubmit
                          : l.credNotUploaded,
                    ),
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

/// «Arizangiz qabul qilindi» — server arizani avtomatik qabul qiladi
/// (APPLICATION_PENDING); maqomni faqat vakolatli shaxs tasdiqlaydi.
Future<void> showApplicationReceived(BuildContext context) {
  final l = AppLocalizations.of(context);
  final c = FeTheme.of(context);
  final t = Theme.of(context).textTheme;
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      key: const Key('verification.received'),
      icon: Icon(Icons.task_alt, color: c.verified, size: 40),
      title: Text(l.verifReceivedTitle, textAlign: TextAlign.center),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l.verifReceivedBody,
            textAlign: TextAlign.center,
            style: t.bodyLarge,
          ),
          const SizedBox(height: FeSpace.sm),
          Text(
            l.verifReceivedNote,
            textAlign: TextAlign.center,
            style: t.bodySmall?.copyWith(color: c.textSecondary),
          ),
        ],
      ),
      actions: [
        FilledButton(
          key: const Key('verification.receivedOk'),
          onPressed: () => Navigator.pop(ctx),
          child: Text(l.actionContinue),
        ),
      ],
    ),
  );
}
