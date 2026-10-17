import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/moderation.dart';
import '../../../app/providers.dart';
import '../../../app/support.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../domain/moderation/moderation_models.dart';
import '../../../domain/support/support_models.dart';
import '../moderation_strings.dart';

/// Admin: foydalanuvchi ustida amallar — maqola moderatori roli, adminlikni
/// olib tashlash, hisobni to‘xtatish/qayta yoqish. Hamma amal serverda
/// (`admin_set_role`, `admin_set_suspension`) tekshiriladi va jurnalga
/// yoziladi; bu varaq faqat qulaylik. Admin to‘xtatilmaydi, o‘zini
/// o‘zgartirib bo‘lmaydi, ilmiy reviewer roli bu yerdan berilmaydi.
Future<void> showUserActionsSheet(BuildContext context, AdminUserSummary user) {
  return showModalBottomSheet<void>(
    useRootNavigator: true,
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => UserActionsSheet(user: user),
  );
}

class UserActionsSheet extends ConsumerStatefulWidget {
  const UserActionsSheet({super.key, required this.user});

  final AdminUserSummary user;

  @override
  ConsumerState<UserActionsSheet> createState() => _UserActionsSheetState();
}

class _UserActionsSheetState extends ConsumerState<UserActionsSheet> {
  final _reason = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  bool get _reasonOk => _reason.text.trim().length >= 5;

  Future<bool> _confirm(String title, String body) async {
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            key: const Key('userActions.confirm.cancel'),
            onPressed: () => Navigator.pop(c, false),
            child: Text(l.admxCancel),
          ),
          FilledButton(
            key: const Key('userActions.confirm.ok'),
            onPressed: () => Navigator.pop(c, true),
            child: Text(l.admxConfirm),
          ),
        ],
      ),
    );
    return ok == true;
  }

  void _done(String text) {
    ref.invalidate(adminUsersProvider);
    ref.invalidate(adminStatsExtProvider);
    ref.invalidate(adminAuditProvider);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _role(ManagedRole role, {required bool grant}) async {
    final l = AppLocalizations.of(context);
    if (!_reasonOk) {
      setState(() => _error = l.admxReasonShort);
      return;
    }
    if (!grant &&
        role == ManagedRole.identityAdmin &&
        !await _confirm(l.admxRemoveAdminTitle, l.admxRemoveAdminBody)) {
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final r = await ref
        .read(moderationServiceProvider)
        .adminSetRole(widget.user.id, role, grant: grant, reason: _reason.text);
    if (!mounted) return;
    setState(() => _busy = false);
    final text = l.roleResultText(r) ?? l.admxActionFailed;
    if (r.ok) {
      _done(text);
    } else {
      setState(() => _error = text);
    }
  }

  Future<void> _suspend({required bool suspend}) async {
    final l = AppLocalizations.of(context);
    if (!_reasonOk) {
      setState(() => _error = l.admxReasonShort);
      return;
    }
    if (suspend &&
        !await _confirm(l.admxSuspendTitle, l.admxSuspendConfirmBody)) {
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final r = await ref
        .read(moderationServiceProvider)
        .adminSetSuspension(
          widget.user.id,
          suspend: suspend,
          reason: _reason.text,
        );
    if (!mounted) return;
    setState(() => _busy = false);
    final text = l.suspensionResultText(r) ?? l.admxActionFailed;
    if (r.ok) {
      _done(text);
    } else {
      setState(() => _error = text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    final u = widget.user;
    final selfId = ref.watch(authStateProvider).account?.userId;
    final isSelf = selfId != null && selfId == u.id;
    final isModerator = u.roles.contains('publication_moderator');
    final banned = u.status == AdminAccountStatus.banned;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: FeSpace.md,
          right: FeSpace.md,
          bottom: MediaQuery.viewInsetsOf(context).bottom + FeSpace.md,
        ),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            key: const Key('userActions.sheet'),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(u.email, style: t.titleMedium),
              const SizedBox(height: FeSpace.xxs),
              Text(
                l.admxActionsHint,
                style: t.bodySmall?.copyWith(color: c.textSecondary),
              ),
              const SizedBox(height: FeSpace.sm),
              TextField(
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
                key: const Key('userActions.reason'),
                controller: _reason,
                maxLength: 300,
                onChanged: (_) => setState(() => _error = null),
                decoration: InputDecoration(
                  labelText: l.admxReason,
                  helperText: l.admxReasonHint,
                  helperMaxLines: 2,
                  errorText: _error,
                ),
              ),
              if (isSelf)
                Padding(
                  padding: const EdgeInsets.only(bottom: FeSpace.xs),
                  child: Text(
                    l.admxSelfNote,
                    key: const Key('userActions.self'),
                    style: t.bodySmall?.copyWith(color: c.textSecondary),
                  ),
                )
              else ...[
                OutlinedButton.icon(
                  key: const Key('userActions.moderator'),
                  onPressed: _busy
                      ? null
                      : () => _role(
                          ManagedRole.publicationModerator,
                          grant: !isModerator,
                        ),
                  icon: const Icon(Icons.verified_user_outlined),
                  label: Text(
                    isModerator ? l.admxModeratorRemove : l.admxModeratorGrant,
                  ),
                ),
                if (u.isAdmin)
                  OutlinedButton.icon(
                    key: const Key('userActions.removeAdmin'),
                    onPressed: _busy
                        ? null
                        : () => _role(ManagedRole.identityAdmin, grant: false),
                    icon: const Icon(Icons.admin_panel_settings_outlined),
                    label: Text(l.admxRemoveAdmin),
                  ),
                const SizedBox(height: FeSpace.xs),
                if (u.isAdmin)
                  Text(
                    l.admxAdminNotSuspendable,
                    key: const Key('userActions.adminProtected'),
                    style: t.bodySmall?.copyWith(color: c.textSecondary),
                  )
                else
                  FilledButton.icon(
                    key: Key(
                      banned ? 'userActions.restore' : 'userActions.suspend',
                    ),
                    style: banned
                        ? null
                        : FilledButton.styleFrom(
                            backgroundColor: c.danger,
                            foregroundColor: Colors.white,
                          ),
                    onPressed: _busy ? null : () => _suspend(suspend: !banned),
                    icon: Icon(banned ? Icons.lock_open : Icons.block),
                    label: Text(banned ? l.admxRestore : l.admxSuspend),
                  ),
              ],
              const SizedBox(height: FeSpace.xs),
            ],
          ),
        ),
      ),
    );
  }
}
