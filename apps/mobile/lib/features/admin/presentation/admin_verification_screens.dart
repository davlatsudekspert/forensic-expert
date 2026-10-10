import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/professional.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/date_format.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/ports/professional_ports.dart';
import '../../../domain/professional/professional_models.dart';
import '../../../domain/professional/review_models.dart';
import '../../../domain/professional/verification_inbox_models.dart';
import '../../professional/professional_strings.dart';
import 'admin_gate.dart';

/// Server rad etish sababi → tushunarli (lokalizatsiyalangan) xabar.
String identityFailureText(AppLocalizations l, IdentityDecisionFailure f) =>
    switch (f) {
      IdentityDecisionFailure.selfApproval => l.admVfErrSelf,
      IdentityDecisionFailure.forbidden => l.admVfErrForbidden,
      IdentityDecisionFailure.noCredentialChecked => l.admVfErrNoCredential,
      IdentityDecisionFailure.unknownCredential => l.admVfErrUnknownCredential,
      IdentityDecisionFailure.invalidTransition => l.admVfErrTransition,
      IdentityDecisionFailure.noApplication => l.admVfErrNoApplication,
      IdentityDecisionFailure.mfaRequired => l.admVfErrMfa,
      IdentityDecisionFailure.invalidInput => l.admVfReasonShort,
      IdentityDecisionFailure.notSignedIn => l.admVfErrSignIn,
      IdentityDecisionFailure.notConnected => l.admVfUnavailable,
      IdentityDecisionFailure.offline => l.admVfErrOffline,
      IdentityDecisionFailure.server => l.admVfErrServer,
    };

/// Admin: kutayotgan tasdiqlash arizalari ro‘yxati.
class AdminVerificationsScreen extends ConsumerWidget {
  const AdminVerificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    final data = ref.watch(pendingVerificationsProvider);
    return AdminGate(
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.admNavVerify),
          actions: [
            IconButton(
              key: const Key('adminVerify.refresh'),
              tooltip: l.adminRefresh,
              icon: const Icon(Icons.refresh),
              onPressed: () => ref.invalidate(pendingVerificationsProvider),
            ),
          ],
        ),
        body: SafeArea(
          child: ListView(
            key: const Key('adminVerify.list'),
            children: [
              FeContentFrame(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: FeSpace.sm),
                    FeBanner(
                      icon: Icons.info_outline,
                      text: l.admVfNoScientific,
                    ),
                    const SizedBox(height: FeSpace.sm),
                    ...switch (data) {
                      AsyncData(:final value?) when value.ok => [
                        if (value.value!.items.isEmpty)
                          FeEmptyState(
                            key: const Key('adminVerify.empty'),
                            icon: Icons.inbox_outlined,
                            body: l.admVfEmpty,
                          )
                        else ...[
                          Text(
                            l.admShown(
                              value.value!.items.length,
                              value.value!.total,
                            ),
                            style: t.bodySmall?.copyWith(
                              color: c.textSecondary,
                            ),
                          ),
                          const SizedBox(height: FeSpace.xs),
                          for (final a in value.value!.items)
                            _ApplicationCard(
                              application: a,
                              onTap: () async {
                                await context.push(
                                  Routes.adminVerification(a.applicantId),
                                );
                                ref.invalidate(pendingVerificationsProvider);
                              },
                            ),
                        ],
                      ],
                      AsyncData(:final value?) => [
                        FeEmptyState(
                          key: const Key('adminVerify.error'),
                          icon: Icons.cloud_off_outlined,
                          body:
                              value.failure ==
                                  ProfessionalFailure.serviceNotConnected
                              ? l.admVfUnavailable
                              : l.admVfLoadFailed,
                        ),
                        if (value.failure !=
                            ProfessionalFailure.serviceNotConnected)
                          OutlinedButton(
                            key: const Key('adminVerify.retry'),
                            onPressed: () =>
                                ref.invalidate(pendingVerificationsProvider),
                            child: Text(l.admRetry),
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
                          key: const Key('adminVerify.error'),
                          icon: Icons.cloud_off_outlined,
                          body: l.admVfLoadFailed,
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

class _ApplicationCard extends StatelessWidget {
  const _ApplicationCard({required this.application, required this.onTap});

  final PendingVerification application;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    final a = application;
    final sub = [
      a.position,
      a.organization,
    ].where((s) => s.trim().isNotEmpty).join(' · ');
    return Padding(
      padding: const EdgeInsets.only(bottom: FeSpace.xs),
      child: FeCard(
        key: Key('adminVerify.card.${a.applicantId}'),
        onTap: onTap,
        padding: const EdgeInsets.all(FeSpace.sm),
        child: Row(
          children: [
            Icon(Icons.how_to_reg_outlined, color: c.accent),
            const SizedBox(width: FeSpace.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    a.displayName.isEmpty ? '—' : a.displayName,
                    style: t.titleSmall,
                  ),
                  if (sub.isNotEmpty)
                    Text(
                      sub,
                      style: t.bodySmall?.copyWith(color: c.textSecondary),
                    ),
                  const SizedBox(height: FeSpace.xxs),
                  Text(
                    [
                      if (a.submittedAt != null)
                        l.admVfSubmitted(feDate(context, a.submittedAt!)),
                      l.admVfDocsCount(a.documents.length),
                    ].join(' · '),
                    style: t.labelSmall?.copyWith(color: c.textSecondary),
                  ),
                  if (a.isSelf)
                    Padding(
                      padding: const EdgeInsets.only(top: FeSpace.xxs),
                      child: Text(
                        l.admVfSelfBadge,
                        key: Key('adminVerify.self.${a.applicantId}'),
                        style: t.labelSmall?.copyWith(
                          color: c.accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: c.textSecondary),
          ],
        ),
      ),
    );
  }
}

/// Admin: bitta ariza — profil, hujjatlar, qaror.
class AdminVerificationDetailScreen extends ConsumerWidget {
  const AdminVerificationDetailScreen({super.key, required this.applicantId});

  final String applicantId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final data = ref.watch(pendingVerificationsProvider);
    final found = switch (data) {
      AsyncData(:final value?) when value.ok =>
        value.value!.items
            .where((a) => a.applicantId == applicantId)
            .firstOrNull,
      _ => null,
    };
    return AdminGate(
      child: Scaffold(
        appBar: AppBar(title: Text(l.admNavVerify)),
        body: SafeArea(
          child: switch (data) {
            AsyncLoading() => Padding(
              padding: const EdgeInsets.all(FeSpace.md),
              child: FeListSkeleton(rows: 3, semanticLabel: l.loadingContent),
            ),
            _ when found == null => FeEmptyState(
              key: const Key('adminVerify.notFound'),
              icon: Icons.search_off,
              body: l.admVfErrNoApplication,
            ),
            _ => _Detail(application: found),
          },
        ),
      ),
    );
  }
}

class _Detail extends ConsumerStatefulWidget {
  const _Detail({required this.application});

  final PendingVerification application;

  @override
  ConsumerState<_Detail> createState() => _DetailState();
}

class _DetailState extends ConsumerState<_Detail> {
  final _checked = <String>{};
  final _reason = TextEditingController();
  final _message = TextEditingController();
  ReviewerScope? _scope;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _scope = widget.application.suggestedScope;
    _reason.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _reason.dispose();
    _message.dispose();
    super.dispose();
  }

  bool get _reasonOk => IdentityDecisionRules.reasonOk(_reason.text);

  bool _canDecide(IdentityDecision d) =>
      !_busy &&
      _reasonOk &&
      _scope != null &&
      (d != IdentityDecision.verify || _checked.isNotEmpty);

  Future<void> _decide(IdentityDecision d) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    setState(() => _busy = true);
    final failure = await ref
        .read(identityAdminServiceProvider)
        .decide(
          applicantId: widget.application.applicantId,
          decision: d,
          scope: _scope!,
          checkedDocumentIds: d == IdentityDecision.verify
              ? _checked.toList()
              : const [],
          reason: _reason.text,
          applicantMessage: _message.text.trim().isEmpty ? null : _message.text,
        );
    if (!mounted) return;
    setState(() => _busy = false);
    if (failure != null) {
      messenger.showSnackBar(
        SnackBar(content: Text(identityFailureText(l, failure))),
      );
      // Qaror allaqachon qabul qilingan bo‘lishi mumkin — ro‘yxatni yangilash.
      if (failure == IdentityDecisionFailure.invalidTransition ||
          failure == IdentityDecisionFailure.noApplication) {
        ref.invalidate(pendingVerificationsProvider);
      }
      return;
    }
    messenger.showSnackBar(
      SnackBar(
        content: Text(switch (d) {
          IdentityDecision.verify => l.admVfDoneVerified,
          IdentityDecision.requestMoreInformation => l.admVfDoneInfo,
          _ => l.admVfDoneRejected,
        }),
      ),
    );
    ref.invalidate(pendingVerificationsProvider);
    if (router.canPop()) router.pop();
  }

  String _size(int bytes) => bytes >= 1024 * 1024
      ? '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB'
      : '${(bytes / 1024).ceil()} KB';

  String _mime(String m) => switch (m) {
    'application/pdf' => 'PDF',
    'image/jpeg' => 'JPEG',
    'image/png' => 'PNG',
    _ => m,
  };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    final a = widget.application;
    Widget field(String label, String value) => Padding(
      padding: const EdgeInsets.only(bottom: FeSpace.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: t.labelSmall?.copyWith(color: c.textSecondary)),
          Text(value, style: t.bodyMedium),
        ],
      ),
    );
    final sub = [
      a.position,
      a.organization,
    ].where((s) => s.trim().isNotEmpty).join(' · ');
    return ListView(
      key: const Key('adminVerify.detail'),
      children: [
        FeContentFrame(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FeSectionHeader(l.admVfApplicant),
              Text(
                a.displayName.isEmpty ? '—' : a.displayName,
                style: t.titleMedium,
              ),
              if (sub.isNotEmpty) Text(sub, style: t.bodyMedium),
              const SizedBox(height: FeSpace.xs),
              if (a.submittedAt != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: FeSpace.xxs),
                  child: Text(
                    l.admVfSubmitted(feDate(context, a.submittedAt!)),
                    style: t.bodySmall?.copyWith(color: c.textSecondary),
                  ),
                ),
              field(
                l.admVfFieldSpecialty,
                [
                  if (a.specialty != null) l.specialtyLabel(a.specialty!),
                  for (final s in a.additionalSpecialties) l.specialtyLabel(s),
                ].join(', ').ifEmpty('—'),
              ),
              if (a.yearsExperience != null)
                field(l.admVfFieldExperience, l.admVfYears(a.yearsExperience!)),
              field(l.admVfFieldEducation, a.education.ifEmpty('—')),
              field(l.admVfFieldCountry, a.country.ifEmpty('—')),
              FeSectionHeader(l.admVfDocs),
              Text(
                l.admVfDocsNote,
                style: t.bodySmall?.copyWith(color: c.textSecondary),
              ),
              const SizedBox(height: FeSpace.xs),
              if (a.documents.isEmpty)
                FeBanner(
                  key: const Key('adminVerify.noDocs'),
                  icon: Icons.warning_amber_outlined,
                  text: l.admVfDocsNone,
                  tone: FeBannerTone.warning,
                )
              else ...[
                if (!a.isSelf)
                  Padding(
                    padding: const EdgeInsets.only(bottom: FeSpace.xxs),
                    child: Text(l.admVfDocsHint, style: t.bodySmall),
                  ),
                for (final d in a.documents)
                  CheckboxListTile(
                    key: Key('adminVerify.doc.${d.documentId}'),
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    value: _checked.contains(d.documentId),
                    onChanged: a.isSelf || _busy
                        ? null
                        : (v) => setState(() {
                            if (v ?? false) {
                              _checked.add(d.documentId);
                            } else {
                              _checked.remove(d.documentId);
                            }
                          }),
                    title: Text(
                      d.kind == null ? '—' : l.credentialKindLabel(d.kind!),
                    ),
                    subtitle: Text(
                      l.admVfDocMeta(
                        _mime(d.mimeType),
                        _size(d.sizeBytes),
                        d.sha256.length >= 12
                            ? d.sha256.substring(0, 12)
                            : d.sha256,
                      ),
                    ),
                  ),
              ],
              FeSectionHeader(l.admVfDecision),
              if (a.isSelf)
                FeBanner(
                  key: const Key('adminVerify.selfNote'),
                  icon: Icons.block,
                  text: l.admVfSelfNote,
                  tone: FeBannerTone.warning,
                )
              else ...[
                DropdownButtonFormField<ReviewerScope>(
                  key: const Key('adminVerify.scope'),
                  initialValue: _scope,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: l.admVfScope,
                    helperText: _scope == null ? l.admVfScopeRequired : null,
                    helperMaxLines: 2,
                  ),
                  items: [
                    for (final s in ReviewerScope.values)
                      DropdownMenuItem(value: s, child: Text(l.scopeLabel(s))),
                  ],
                  onChanged: _busy ? null : (v) => setState(() => _scope = v),
                ),
                const SizedBox(height: FeSpace.xs),
                TextField(
                  key: const Key('adminVerify.reason'),
                  controller: _reason,
                  enabled: !_busy,
                  minLines: 2,
                  maxLines: 4,
                  maxLength: 500,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    labelText: l.admVfReason,
                    errorText: _reason.text.isNotEmpty && !_reasonOk
                        ? l.admVfReasonShort
                        : null,
                  ),
                ),
                const SizedBox(height: FeSpace.xs),
                TextField(
                  key: const Key('adminVerify.message'),
                  controller: _message,
                  enabled: !_busy,
                  minLines: 1,
                  maxLines: 3,
                  maxLength: 500,
                  decoration: InputDecoration(labelText: l.admVfMessage),
                ),
                const SizedBox(height: FeSpace.xs),
                FilledButton(
                  key: const Key('adminVerify.approve'),
                  onPressed: _canDecide(IdentityDecision.verify)
                      ? () => _decide(IdentityDecision.verify)
                      : null,
                  child: Text(l.admVfApprove),
                ),
                const SizedBox(height: FeSpace.xs),
                OutlinedButton(
                  key: const Key('adminVerify.requestInfo'),
                  onPressed: _canDecide(IdentityDecision.requestMoreInformation)
                      ? () => _decide(IdentityDecision.requestMoreInformation)
                      : null,
                  child: Text(l.admVfRequestInfo),
                ),
                const SizedBox(height: FeSpace.xs),
                OutlinedButton(
                  key: const Key('adminVerify.reject'),
                  onPressed: _canDecide(IdentityDecision.reject)
                      ? () => _decide(IdentityDecision.reject)
                      : null,
                  child: Text(l.admVfReject),
                ),
                const SizedBox(height: FeSpace.xs),
                Text(
                  l.admVfNoScientific,
                  style: t.bodySmall?.copyWith(color: c.textSecondary),
                ),
              ],
              const SizedBox(height: FeSpace.xl),
            ],
          ),
        ),
      ],
    );
  }
}

extension on String {
  String ifEmpty(String fallback) => trim().isEmpty ? fallback : this;
}
