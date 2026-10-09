import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../app/support.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/support/support_models.dart';
import '../../professional/presentation/professional_widgets.dart' show FeNote;
import '../support_image_picker.dart';
import '../support_strings.dart';
import 'support_widgets.dart';

/// Backend ulanmagan yig‘ma yoki kirmagan foydalanuvchi uchun umumiy darvoza.
class _SupportGate extends ConsumerWidget {
  const _SupportGate({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    if (!ref.watch(supportAvailableProvider)) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Center(
          child: FeEmptyState(
            key: const Key('support.unavailable'),
            icon: Icons.cloud_off_outlined,
            body: l.supUnavailable,
          ),
        ),
      );
    }
    if (!ref.watch(authStateProvider).signedIn) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: const Center(child: SupportSignInPrompt()),
      );
    }
    return child;
  }
}

/// Profil → «Taklif va murojaatlar»: o‘z murojaatlari ro‘yxati.
class SupportListScreen extends ConsumerWidget {
  const SupportListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final data = ref.watch(mySupportThreadsProvider);
    return _SupportGate(
      title: l.supTitle,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.supTitle),
          actions: [
            IconButton(
              tooltip: l.adminRefresh,
              icon: const Icon(Icons.refresh),
              onPressed: () {
                ref.invalidate(mySupportThreadsProvider);
                ref.invalidate(supportUnreadProvider);
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          key: const Key('support.new'),
          onPressed: () => context.push(Routes.supportNew),
          icon: const Icon(Icons.edit_outlined),
          label: Text(l.supNew),
        ),
        body: SafeArea(
          child: switch (data) {
            AsyncData(:final value?) when value.isEmpty => Center(
              child: Padding(
                padding: const EdgeInsets.all(FeSpace.md),
                child: FeEmptyState(
                  key: const Key('support.empty'),
                  icon: Icons.forum_outlined,
                  body: l.supEmpty,
                ),
              ),
            ),
            AsyncData(:final value?) => RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(supportUnreadProvider);
                return ref.refresh(mySupportThreadsProvider.future);
              },
              child: ListView(
                key: const Key('support.list'),
                children: [
                  FeContentFrame(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: FeSpace.sm),
                        for (final t in value)
                          SupportThreadCard(
                            thread: t,
                            onTap: () =>
                                context.push(Routes.supportThread(t.id)),
                          ),
                        const SizedBox(height: 88),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            AsyncLoading() => Padding(
              padding: const EdgeInsets.all(FeSpace.md),
              child: FeListSkeleton(rows: 3, semanticLabel: l.loadingContent),
            ),
            _ => FeEmptyState(
              key: const Key('support.error'),
              icon: Icons.cloud_off_outlined,
              body: l.supLoadFailed,
            ),
          },
        ),
      ),
    );
  }
}

/// Yangi murojaat formasi (turkum, mavzu, xabar, skrinshot, rozilik).
class NewSupportThreadScreen extends ConsumerStatefulWidget {
  const NewSupportThreadScreen({
    super.key,
    this.initialCategory,
    this.relatedEntity,
    this.relatedTitle,
  });

  final SupportCategory? initialCategory;
  final String? relatedEntity;
  final String? relatedTitle;

  @override
  ConsumerState<NewSupportThreadScreen> createState() =>
      _NewSupportThreadScreenState();
}

class _NewSupportThreadScreenState
    extends ConsumerState<NewSupportThreadScreen> {
  final _form = GlobalKey<FormState>();
  final _subject = TextEditingController();
  final _body = TextEditingController();
  late SupportCategory _category =
      widget.initialCategory ?? SupportCategory.suggestion;
  SupportAttachment? _attachment;
  bool _consent = false;
  bool _consentError = false;
  bool _busy = false;

  /// Birinchi «Yuborish»dan keyin maydonlar yozilganda qayta tekshiriladi —
  /// to‘ldirilgan maydon ostida eski xato qolmaydi.
  bool _validateOnInput = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final title = widget.relatedTitle;
    if (title != null && _subject.text.isEmpty) {
      final s = AppLocalizations.of(context).supReportErrorSubject(title);
      _subject.text = s.length > SupportLimits.subject
          ? s.substring(0, SupportLimits.subject)
          : s;
    }
  }

  @override
  void dispose() {
    _subject.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final r = await ref.read(supportImagePickerProvider).pick();
    if (!mounted || r == null) return;
    switch (r) {
      case PickedImageOk(:final attachment):
        setState(() => _attachment = attachment);
      case PickedImageRejected(:final error):
        messenger.showSnackBar(
          SnackBar(
            content: Text(switch (error) {
              PickedImageError.tooLarge => l.supAttachTooLarge,
              PickedImageError.wrongType => l.supAttachWrongType,
            }),
          ),
        );
    }
  }

  Future<void> _submit() async {
    final l = AppLocalizations.of(context);
    final valid = _form.currentState!.validate();
    setState(() {
      _consentError = !_consent;
      _validateOnInput = true;
    });
    if (!valid || !_consent) return;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    final r = await ref
        .read(supportServiceProvider)
        .createThread(
          SupportDraft(
            category: _category,
            subject: _subject.text,
            body: _body.text,
            consent: _consent,
            relatedEntity: widget.relatedEntity,
            attachment: _attachment,
          ),
        );
    if (!mounted) return;
    setState(() => _busy = false);
    messenger.showSnackBar(
      SnackBar(
        content: Text(switch (r.outcome) {
          SupportCreateOutcome.created => l.supSent,
          SupportCreateOutcome.consentRequired => l.supConsentRequired,
          SupportCreateOutcome.rateLimited => l.supRateLimited,
          _ => l.supFailed,
        }),
      ),
    );
    if (r.outcome == SupportCreateOutcome.created && r.id != null) {
      ref.invalidate(mySupportThreadsProvider);
      context.pushReplacement(Routes.supportThread(r.id!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    return _SupportGate(
      title: l.supNew,
      child: Scaffold(
        appBar: AppBar(title: Text(l.supNew)),
        body: SafeArea(
          child: Form(
            key: _form,
            autovalidateMode: _validateOnInput
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            child: ListView(
              key: const Key('supportNew.list'),
              children: [
                FeContentFrame(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: FeSpace.sm),
                      DropdownButtonFormField<SupportCategory>(
                        key: const Key('supportNew.category'),
                        initialValue: _category,
                        isExpanded: true,
                        decoration: InputDecoration(labelText: l.supCategory),
                        items: [
                          for (final cat in SupportCategory.values)
                            DropdownMenuItem(
                              value: cat,
                              child: Row(
                                children: [
                                  Icon(cat.icon, size: 18, color: c.accent),
                                  const SizedBox(width: FeSpace.xs),
                                  Flexible(
                                    child: Text(
                                      l.supCategoryLabel(cat),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                        onChanged: (v) => setState(
                          () => _category = v ?? SupportCategory.general,
                        ),
                      ),
                      if (widget.relatedEntity case final e?) ...[
                        const SizedBox(height: FeSpace.xs),
                        FeNote(
                          key: const Key('supportNew.related'),
                          icon: Icons.link,
                          text: l.supRelated(
                            widget.relatedTitle ??
                                relatedEntityName(
                                  ref,
                                  Localizations.localeOf(context).languageCode,
                                  e,
                                ) ??
                                l.supRelatedUnknown,
                          ),
                        ),
                      ],
                      const SizedBox(height: FeSpace.sm),
                      TextFormField(
                        key: const Key('supportNew.subject'),
                        controller: _subject,
                        maxLength: SupportLimits.subject,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(labelText: l.supSubject),
                        validator: (v) => (v ?? '').trim().isEmpty
                            ? l.supSubjectRequired
                            : null,
                      ),
                      const SizedBox(height: FeSpace.xs),
                      TextFormField(
                        key: const Key('supportNew.body'),
                        controller: _body,
                        minLines: 5,
                        maxLines: 12,
                        maxLength: SupportLimits.body,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          labelText: l.supMessage,
                          hintText: l.supMessageHint,
                          hintMaxLines: 3,
                          alignLabelWithHint: true,
                        ),
                        validator: (v) => (v ?? '').trim().isEmpty
                            ? l.supMessageRequired
                            : null,
                      ),
                      const SizedBox(height: FeSpace.xs),
                      if (_attachment case final a?)
                        FeCard(
                          key: const Key('supportNew.attachment'),
                          padding: const EdgeInsets.all(FeSpace.xs),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  FeRadius.sm,
                                ),
                                child: Image.memory(
                                  a.bytes,
                                  width: 56,
                                  height: 56,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => const SizedBox(
                                    width: 56,
                                    height: 56,
                                    child: Icon(Icons.image_outlined),
                                  ),
                                ),
                              ),
                              const SizedBox(width: FeSpace.sm),
                              Expanded(
                                child: Text(
                                  '${l.supAttachment} · '
                                  '${(a.bytes.length / 1024).ceil()} KB',
                                  style: t.bodySmall,
                                ),
                              ),
                              IconButton(
                                key: const Key('supportNew.removeAttachment'),
                                tooltip: l.supAttachRemove,
                                icon: const Icon(Icons.close),
                                onPressed: () =>
                                    setState(() => _attachment = null),
                              ),
                            ],
                          ),
                        )
                      else
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: OutlinedButton.icon(
                            key: const Key('supportNew.attach'),
                            onPressed: _pick,
                            icon: const Icon(
                              Icons.add_photo_alternate_outlined,
                            ),
                            label: Text(l.supAttach),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(top: FeSpace.xxs),
                        child: Text(
                          l.supAttachHint,
                          style: t.bodySmall?.copyWith(color: c.textSecondary),
                        ),
                      ),
                      const SizedBox(height: FeSpace.sm),
                      FeBanner(
                        key: const Key('supportNew.privacy'),
                        icon: Icons.lock_outline,
                        text: l.supPrivacyNote,
                      ),
                      CheckboxListTile(
                        key: const Key('supportNew.consent'),
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        value: _consent,
                        onChanged: (v) => setState(() {
                          _consent = v ?? false;
                          if (_consent) _consentError = false;
                        }),
                        title: Text(l.supConsent, style: t.bodyMedium),
                        subtitle: _consentError
                            ? Text(
                                l.supConsentRequired,
                                style: t.bodySmall?.copyWith(color: c.danger),
                              )
                            : null,
                      ),
                      const SizedBox(height: FeSpace.xs),
                      FilledButton.icon(
                        key: const Key('supportNew.send'),
                        onPressed: _busy ? null : _submit,
                        icon: _busy
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.send_rounded),
                        label: Text(_busy ? l.supSending : l.supSend),
                      ),
                      const SizedBox(height: FeSpace.xl),
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
}

/// Murojaat — chat ko‘rinishida (foydalanuvchi). Ochilganda o‘qilgan deb
/// belgilanadi.
class SupportThreadScreen extends ConsumerStatefulWidget {
  const SupportThreadScreen({super.key, required this.threadId});

  final String threadId;

  @override
  ConsumerState<SupportThreadScreen> createState() =>
      _SupportThreadScreenState();
}

class _SupportThreadScreenState extends ConsumerState<SupportThreadScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(supportServiceProvider).markRead(widget.threadId);
      if (mounted) ref.invalidate(supportUnreadProvider);
    });
  }

  Future<bool> _send(String text) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final r = await ref
        .read(supportServiceProvider)
        .sendMessage(widget.threadId, text);
    if (!mounted) return false;
    if (r == SupportSendResult.sent) {
      ref.invalidate(supportThreadProvider(widget.threadId));
      ref.invalidate(mySupportThreadsProvider);
      return true;
    }
    messenger.showSnackBar(
      SnackBar(
        content: Text(switch (r) {
          SupportSendResult.rateLimited => l.supRateLimited,
          SupportSendResult.closed => l.supClosedNote,
          _ => l.supFailed,
        }),
      ),
    );
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final data = ref.watch(supportThreadProvider(widget.threadId));
    return _SupportGate(
      title: l.supTitle,
      child: Scaffold(
        appBar: AppBar(title: Text(l.supTitle)),
        body: SafeArea(
          child: switch (data) {
            AsyncData(:final value?) => SupportConversation(
              thread: value,
              adminView: false,
              composer: value.status == SupportStatus.closed
                  ? Padding(
                      padding: const EdgeInsets.all(FeSpace.md),
                      child: FeNote(
                        key: const Key('support.closed'),
                        icon: Icons.lock_outline,
                        text: l.supClosedNote,
                      ),
                    )
                  : SupportComposer(hint: l.supReplyHint, onSend: _send),
            ),
            AsyncLoading() => const Center(child: CircularProgressIndicator()),
            _ => FeEmptyState(
              key: const Key('support.notFound'),
              icon: Icons.search_off,
              body: l.supNotFound,
            ),
          },
        ),
      ),
    );
  }
}

/// Sarlavha (mavzu, turkum, holat) + xabarlar + pastki panel.
class SupportConversation extends ConsumerWidget {
  const SupportConversation({
    super.key,
    required this.thread,
    required this.adminView,
    required this.composer,
    this.header,
  });

  final SupportThread thread;
  final bool adminView;
  final Widget composer;
  final Widget? header;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    final th = thread;
    return Column(
      children: [
        Expanded(
          child: ListView(
            key: const Key('support.conversation'),
            children: [
              FeContentFrame(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: FeSpace.sm),
                    Wrap(
                      spacing: FeSpace.xs,
                      runSpacing: FeSpace.xxs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Icon(th.category.icon, size: 18, color: c.accent),
                        Text(
                          l.supCategoryLabel(th.category),
                          style: t.labelLarge,
                        ),
                        SupportStatusChip(status: th.status),
                      ],
                    ),
                    const SizedBox(height: FeSpace.xs),
                    Semantics(
                      header: true,
                      child: Text(th.subject, style: t.titleLarge),
                    ),
                    if (th.relatedEntity case final e?)
                      Padding(
                        padding: const EdgeInsets.only(top: FeSpace.xxs),
                        child: Text(
                          l.supRelated(
                            relatedEntityName(
                                  ref,
                                  Localizations.localeOf(context).languageCode,
                                  e,
                                ) ??
                                l.supRelatedUnknown,
                          ),
                          style: t.bodySmall?.copyWith(color: c.textSecondary),
                        ),
                      ),
                    ?header,
                    const SizedBox(height: FeSpace.md),
                    for (final m in th.messages)
                      SupportBubble(
                        message: m,
                        mine: adminView ? m.fromAdmin : !m.fromAdmin,
                        author: m.fromAdmin
                            ? l.supTeam
                            : adminView
                            ? (th.authorEmail ?? l.supYou)
                            : l.supYou,
                      ),
                    const SizedBox(height: FeSpace.md),
                  ],
                ),
              ),
            ],
          ),
        ),
        composer,
      ],
    );
  }
}
