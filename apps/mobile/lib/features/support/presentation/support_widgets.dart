import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../app/support.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/date_format.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/support/support_models.dart';
import '../support_strings.dart';

class SupportStatusChip extends StatelessWidget {
  const SupportStatusChip({super.key, required this.status});

  final SupportStatus status;

  @override
  Widget build(BuildContext context) => StatusChip(
    icon: status.icon,
    label: AppLocalizations.of(context).supStatus(status),
    color: status.color(context),
  );
}

/// O‘qilmaganlar soni — shampan oltin belgi (rang yagona belgi emas: son).
class SupportUnreadBadge extends StatelessWidget {
  const SupportUnreadBadge({super.key, required this.count, this.label});

  final int count;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    return Semantics(
      label: label ?? AppLocalizations.of(context).supUnreadBadge(count),
      excludeSemantics: true,
      child: Container(
        constraints: const BoxConstraints(minWidth: 22),
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: c.accent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          '$count',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(color: c.onAccent, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

String supportTime(BuildContext context, DateTime? d) {
  if (d == null) return '';
  final x = d.toLocal();
  final hh = x.hour.toString().padLeft(2, '0');
  final mm = x.minute.toString().padLeft(2, '0');
  return '${feDate(context, x)}, $hh:$mm';
}

/// Murojaat kartasi (foydalanuvchi ro‘yxati va admin inbox).
class SupportThreadCard extends StatelessWidget {
  const SupportThreadCard({
    super.key,
    required this.thread,
    required this.onTap,
    this.showAuthor = false,
  });

  final SupportThread thread;
  final VoidCallback onTap;
  final bool showAuthor;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    final th = thread;
    return Padding(
      padding: const EdgeInsets.only(bottom: FeSpace.xs),
      child: FeCard(
        key: Key('support.thread.${th.id}'),
        padding: const EdgeInsets.all(FeSpace.sm),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(th.category.icon, size: 18, color: c.accent),
                const SizedBox(width: FeSpace.xs),
                Expanded(
                  child: Text(
                    l.supCategoryLabel(th.category),
                    style: t.labelMedium?.copyWith(color: c.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (th.unread > 0) ...[
                  SupportUnreadBadge(
                    count: th.unread,
                    label: showAuthor
                        ? l.admUnread(th.unread)
                        : l.supUnreadBadge(th.unread),
                  ),
                  const SizedBox(width: FeSpace.xs),
                ],
                SupportStatusChip(status: th.status),
              ],
            ),
            const SizedBox(height: FeSpace.xs),
            Text(
              th.subject,
              style: t.titleSmall?.copyWith(
                fontWeight: th.unread > 0 ? FontWeight.w700 : null,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (th.lastMessage case final m? when m.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                m,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: t.bodySmall?.copyWith(color: c.textSecondary),
              ),
            ],
            const SizedBox(height: FeSpace.xxs),
            Text(
              [
                if (showAuthor && th.authorEmail != null) th.authorEmail!,
                l.supMessages(th.messageCount),
                supportTime(context, th.updatedAt ?? th.createdAt),
              ].where((x) => x.isNotEmpty).join(FeGlyphs.middleDot),
              style: t.bodySmall?.copyWith(color: c.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

/// Chat pufakchasi. [mine] — o‘ng tomonda (shampan), boshqalar — chapda.
class SupportBubble extends ConsumerWidget {
  const SupportBubble({
    super.key,
    required this.message,
    required this.author,
    required this.mine,
  });

  final SupportMessage message;
  final String author;
  final bool mine;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    final bg = mine ? c.accentContainer : c.surfaceRaised;
    final fg = mine ? c.onAccentContainer : c.textPrimary;
    return Align(
      alignment: mine
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.8,
        ),
        child: Container(
          key: Key('support.msg.${message.id}'),
          margin: const EdgeInsets.only(bottom: FeSpace.xs),
          padding: const EdgeInsets.all(FeSpace.sm),
          decoration: BoxDecoration(
            color: bg,
            border: Border.all(color: mine ? c.accentBorder : c.border),
            borderRadius: BorderRadiusDirectional.only(
              topStart: const Radius.circular(FeRadius.lg),
              topEnd: const Radius.circular(FeRadius.lg),
              bottomStart: Radius.circular(mine ? FeRadius.lg : 4),
              bottomEnd: Radius.circular(mine ? 4 : FeRadius.lg),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (message.fromAdmin) ...[
                    Icon(Icons.verified_outlined, size: 14, color: c.accent),
                    const SizedBox(width: 4),
                  ],
                  Flexible(
                    child: Text(
                      author,
                      style: t.labelSmall?.copyWith(
                        color: fg,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: FeSpace.xxs),
              SelectableText(
                message.body,
                style: t.bodyMedium?.copyWith(color: fg),
              ),
              if (message.attachmentPath case final p?) ...[
                const SizedBox(height: FeSpace.xs),
                _AttachmentChip(path: p),
              ],
              const SizedBox(height: FeSpace.xxs),
              Text(
                supportTime(context, message.createdAt),
                style: t.labelSmall?.copyWith(color: c.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AttachmentChip extends ConsumerWidget {
  const _AttachmentChip({required this.path});

  final String path;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return ActionChip(
      key: const Key('support.attachment'),
      avatar: const Icon(Icons.image_outlined, size: 18),
      label: Text(l.supAttachment),
      onPressed: () async {
        final url = await ref.read(supportServiceProvider).attachmentUrl(path);
        if (url == null || !context.mounted) return;
        await showDialog<void>(
          context: context,
          builder: (c) => Dialog(
            child: InteractiveViewer(child: Image.network(url.toString())),
          ),
        );
      },
    );
  }
}

/// Javob maydoni: matn + yuborish tugmasi. [onSend] `true` qaytarsa tozalanadi.
class SupportComposer extends StatefulWidget {
  const SupportComposer({
    super.key,
    required this.onSend,
    required this.hint,
    this.sendLabel,
    this.fieldKey = const Key('support.reply'),
    this.sendKey = const Key('support.send'),
  });

  final Future<bool> Function(String text) onSend;
  final String hint;
  final String? sendLabel;
  final Key fieldKey;
  final Key sendKey;

  @override
  State<SupportComposer> createState() => _SupportComposerState();
}

class _SupportComposerState extends State<SupportComposer> {
  final _c = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _c.text.trim();
    if (text.isEmpty || _busy) return;
    setState(() => _busy = true);
    final ok = await widget.onSend(text);
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) _c.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(top: BorderSide(color: c.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          FeSpace.md,
          FeSpace.xs,
          FeSpace.xs,
          FeSpace.xs,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                key: widget.fieldKey,
                controller: _c,
                minLines: 1,
                maxLines: 5,
                maxLength: SupportLimits.body,
                buildCounter: (
                  _, {
                  required currentLength,
                  required isFocused,
                  maxLength,
                }) => null,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(hintText: widget.hint),
              ),
            ),
            const SizedBox(width: FeSpace.xs),
            IconButton.filled(
              key: widget.sendKey,
              tooltip: widget.sendLabel ?? l.supSend,
              onPressed: _busy ? null : _send,
              icon: _busy
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

class SupportSignInPrompt extends StatelessWidget {
  const SupportSignInPrompt({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FeEmptyState(
          key: const Key('support.signInRequired'),
          icon: Icons.login,
          body: l.supSignInRequired,
        ),
        FilledButton(
          key: const Key('support.signIn'),
          onPressed: () => context.push(Routes.accountEmailCode),
          child: Text(l.supSignIn),
        ),
      ],
    );
  }
}

/// Kontent sahifalari app bar’idagi «⋮» menyusi: «Xato haqida xabar berish».
/// Faqat backend ulangan yig‘mada ko‘rinadi (aks holda yuborib bo‘lmaydi).
class ReportErrorMenu extends ConsumerWidget {
  const ReportErrorMenu({
    super.key,
    required this.entityId,
    required this.title,
  });

  /// Masalan `substance:morphine`, `guideline:RG-25`.
  final String entityId;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(supportAvailableProvider)) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    return PopupMenuButton<int>(
      key: const Key('support.reportMenu'),
      tooltip: l.supMoreActions,
      onSelected: (_) => context.push(
        Routes.supportNewFor(
          category: SupportCategory.scientificError.wire,
          entity: sanitizeRelatedEntity(entityId),
          title: title,
        ),
      ),
      itemBuilder: (c) => [
        PopupMenuItem(
          key: const Key('support.reportError'),
          value: 0,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.flag_outlined),
            title: Text(l.supReportError),
          ),
        ),
      ],
    );
  }
}
