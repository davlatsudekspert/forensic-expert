import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../app/support.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/date_format.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/professional/professional_models.dart';
import '../../../domain/support/support_models.dart';
import '../../professional/professional_strings.dart';
import '../../support/presentation/support_screens.dart';
import '../../support/presentation/support_widgets.dart';
import '../../support/support_strings.dart';
import 'admin_gate.dart';

const _pageSize = 25;

/// Admin: murojaatlar qutisi — holat/turkum bo‘yicha saralash, qidiruv,
/// sahifalash («Yana yuklash»).
class AdminInboxScreen extends ConsumerStatefulWidget {
  const AdminInboxScreen({super.key});

  @override
  ConsumerState<AdminInboxScreen> createState() => _AdminInboxScreenState();
}

class _AdminInboxScreenState extends ConsumerState<AdminInboxScreen> {
  SupportInboxFilter _filter = const SupportInboxFilter(status: 'AWAITING');
  int _limit = _pageSize;
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _set(SupportInboxFilter f) => setState(() {
    _filter = f;
    _limit = _pageSize;
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    final page = ref.watch(adminInboxProvider((_filter, _limit)));
    final statuses = <(String?, String)>[
      ('AWAITING', l.admFilterAwaiting),
      (null, l.admFilterAll),
      for (final s in SupportStatus.values) (s.wire, l.supStatus(s)),
    ];
    return AdminGate(
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.admNavInbox),
          actions: [
            IconButton(
              tooltip: l.adminRefresh,
              icon: const Icon(Icons.refresh),
              onPressed: () => ref.invalidate(adminInboxProvider),
            ),
          ],
        ),
        body: SafeArea(
          child: ListView(
            key: const Key('adminInbox.list'),
            children: [
              FeContentFrame(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: FeSpace.sm),
                    TextField(
                      key: const Key('adminInbox.search'),
                      controller: _search,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: l.admInboxSearch,
                      ),
                      onSubmitted: (q) => _set(
                        SupportInboxFilter(
                          status: _filter.status,
                          category: _filter.category,
                          query: q.trim(),
                        ),
                      ),
                    ),
                    const SizedBox(height: FeSpace.xs),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final (wire, label) in statuses)
                            Padding(
                              padding: const EdgeInsetsDirectional.only(
                                end: FeSpace.xs,
                              ),
                              child: ChoiceChip(
                                key: Key('adminInbox.status.${wire ?? 'ALL'}'),
                                label: Text(label),
                                selected: _filter.status == wire,
                                onSelected: (_) => _set(
                                  SupportInboxFilter(
                                    status: wire,
                                    category: _filter.category,
                                    query: _filter.query,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: FeSpace.xs),
                    DropdownButtonFormField<SupportCategory?>(
                      key: const Key('adminInbox.category'),
                      initialValue: _filter.category,
                      isExpanded: true,
                      decoration: InputDecoration(labelText: l.supCategory),
                      items: [
                        DropdownMenuItem(child: Text(l.admAllCategories)),
                        for (final cat in SupportCategory.values)
                          DropdownMenuItem(
                            value: cat,
                            child: Text(l.supCategoryLabel(cat)),
                          ),
                      ],
                      onChanged: (v) => _set(
                        SupportInboxFilter(
                          status: _filter.status,
                          category: v,
                          query: _filter.query,
                        ),
                      ),
                    ),
                    const SizedBox(height: FeSpace.sm),
                    ...switch (page) {
                      AsyncData(:final value?) when value.items.isEmpty => [
                        FeEmptyState(
                          key: const Key('adminInbox.empty'),
                          icon: Icons.inbox_outlined,
                          body: l.admInboxEmpty,
                        ),
                      ],
                      AsyncData(:final value?) => [
                        Text(
                          l.admShown(value.items.length, value.total),
                          style: t.bodySmall?.copyWith(color: c.textSecondary),
                        ),
                        const SizedBox(height: FeSpace.xs),
                        for (final th in value.items)
                          SupportThreadCard(
                            thread: th,
                            showAuthor: true,
                            onTap: () async {
                              await context.push(Routes.adminThread(th.id));
                              ref.invalidate(adminInboxProvider);
                            },
                          ),
                        if (value.items.length < value.total)
                          OutlinedButton(
                            key: const Key('adminInbox.more'),
                            onPressed: () =>
                                setState(() => _limit += _pageSize),
                            child: Text(l.admLoadMore),
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
                          key: const Key('adminInbox.error'),
                          icon: Icons.cloud_off_outlined,
                          body: l.supLoadFailed,
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

/// Admin: bitta murojaat — chat, «Javob yozish», holatni o‘zgartirish.
class AdminThreadScreen extends ConsumerStatefulWidget {
  const AdminThreadScreen({super.key, required this.threadId});

  final String threadId;

  @override
  ConsumerState<AdminThreadScreen> createState() => _AdminThreadScreenState();
}

class _AdminThreadScreenState extends ConsumerState<AdminThreadScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(supportServiceProvider).markRead(widget.threadId),
    );
  }

  void _refresh() {
    ref.invalidate(supportThreadProvider(widget.threadId));
    ref.invalidate(adminStatsProvider);
  }

  Future<bool> _reply(String text) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final r = await ref
        .read(supportServiceProvider)
        .adminReply(widget.threadId, text);
    if (!mounted) return false;
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          r == SupportSendResult.sent ? l.admReplySent : l.supFailed,
        ),
      ),
    );
    if (r == SupportSendResult.sent) _refresh();
    return r == SupportSendResult.sent;
  }

  Future<void> _status(SupportStatus s) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final r = await ref
        .read(supportServiceProvider)
        .adminSetStatus(widget.threadId, s);
    if (!mounted) return;
    messenger.showSnackBar(
      SnackBar(content: Text(r != null ? l.admStatusChanged : l.supFailed)),
    );
    if (r != null) _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    final data = ref.watch(supportThreadProvider(widget.threadId));
    return AdminGate(
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.admNavInbox),
          actions: [
            PopupMenuButton<SupportStatus>(
              key: const Key('admin.status'),
              tooltip: l.admSetStatus,
              icon: const Icon(Icons.flag_outlined),
              onSelected: _status,
              itemBuilder: (_) => [
                for (final s in SupportStatus.values)
                  PopupMenuItem(
                    key: Key('admin.status.${s.wire}'),
                    value: s,
                    child: Row(
                      children: [
                        Icon(s.icon, size: 18, color: s.color(context)),
                        const SizedBox(width: FeSpace.xs),
                        Text(l.supStatus(s)),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
        body: SafeArea(
          child: switch (data) {
            AsyncData(:final value?) => SupportConversation(
              thread: value,
              adminView: true,
              header: value.authorEmail == null
                  ? null
                  : Padding(
                      padding: const EdgeInsets.only(top: FeSpace.xxs),
                      child: Text(
                        l.admAuthor(value.authorEmail!),
                        key: const Key('admin.threadAuthor'),
                        style: t.bodySmall?.copyWith(color: c.textSecondary),
                      ),
                    ),
              composer: SupportComposer(
                hint: l.admReply,
                sendLabel: l.admReplySend,
                fieldKey: const Key('admin.reply'),
                sendKey: const Key('admin.replySend'),
                onSend: _reply,
              ),
            ),
            AsyncLoading() => const Center(child: CircularProgressIndicator()),
            _ => FeEmptyState(icon: Icons.search_off, body: l.supNotFound),
          },
        ),
      ),
    );
  }
}

/// Admin: foydalanuvchilar — qidiruv, rol/tarif saralash, sahifalash.
class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  AdminUserFilter _f = const AdminUserFilter();
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    final page = ref.watch(adminUsersProvider(_f));
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
        appBar: AppBar(title: Text(l.admNavUsers)),
        body: SafeArea(
          child: ListView(
            key: const Key('adminUsers.list'),
            children: [
              FeContentFrame(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: FeSpace.sm),
                    FeBanner(
                      icon: Icons.lock_outline,
                      text: l.adminPrivacyNote,
                    ),
                    const SizedBox(height: FeSpace.sm),
                    TextField(
                      key: const Key('adminUsers.search'),
                      controller: _search,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: l.admUsersSearch,
                      ),
                      onSubmitted: (q) => setState(
                        () => _f = _f.copyWith(search: q.trim(), offset: 0),
                      ),
                    ),
                    const SizedBox(height: FeSpace.xs),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final (v, label) in [
                            (null, l.admRoleAny),
                            ('admin', l.admRoleAdmin),
                            ('moderator', l.admRoleModerator),
                          ])
                            chip(
                              'adminUsers.role.${v ?? 'any'}',
                              label,
                              _f.role == v,
                              () => setState(
                                () =>
                                    _f = _f.copyWith(role: () => v, offset: 0),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final (v, label) in [
                            (null, l.admTierAny),
                            ('free', l.admTierFree),
                            ('pro', l.admTierPro),
                          ])
                            chip(
                              'adminUsers.tier.${v ?? 'any'}',
                              label,
                              _f.tier == v,
                              () => setState(
                                () =>
                                    _f = _f.copyWith(tier: () => v, offset: 0),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: FeSpace.sm),
                    ...switch (page) {
                      AsyncData(:final value?) when value.items.isEmpty => [
                        FeEmptyState(
                          key: const Key('adminUsers.empty'),
                          icon: Icons.person_search_outlined,
                          body: l.admUsersEmpty,
                        ),
                      ],
                      AsyncData(:final value?) => [
                        Text(
                          l.admShown(
                            _f.offset + value.items.length,
                            value.total,
                          ),
                          style: t.bodySmall?.copyWith(color: c.textSecondary),
                        ),
                        const SizedBox(height: FeSpace.xs),
                        for (final u in value.items) _UserCard(u: u),
                        Row(
                          children: [
                            OutlinedButton(
                              key: const Key('adminUsers.prev'),
                              onPressed: _f.offset == 0
                                  ? null
                                  : () => setState(
                                      () => _f = _f.copyWith(
                                        offset:
                                            (_f.offset -
                                                    AdminUserFilter.pageSize)
                                                .clamp(0, 1 << 30),
                                      ),
                                    ),
                              child: Text(l.admPrev),
                            ),
                            const Spacer(),
                            OutlinedButton(
                              key: const Key('adminUsers.next'),
                              onPressed:
                                  _f.offset + value.items.length >= value.total
                                  ? null
                                  : () => setState(
                                      () => _f = _f.copyWith(
                                        offset:
                                            _f.offset +
                                            AdminUserFilter.pageSize,
                                      ),
                                    ),
                              child: Text(l.admNext),
                            ),
                          ],
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

class _UserCard extends StatelessWidget {
  const _UserCard({required this.u});

  final AdminUserSummary u;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    final (statusLabel, statusColor, statusIcon) = switch (u.status) {
      AdminAccountStatus.active => (
        l.admUserActive,
        c.verified,
        Icons.check_circle_outline,
      ),
      AdminAccountStatus.unconfirmed => (
        l.admUserUnconfirmed,
        c.warning,
        Icons.mark_email_unread_outlined,
      ),
      AdminAccountStatus.banned => (l.admUserBanned, c.danger, Icons.block),
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: FeSpace.xs),
      child: FeCard(
        key: Key('adminUsers.user.${u.email}'),
        padding: const EdgeInsets.all(FeSpace.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (u.displayName case final n? when n.isNotEmpty)
                        Text(n, style: t.titleSmall),
                      Text(
                        u.email,
                        style: u.displayName == null
                            ? t.titleSmall
                            : t.bodySmall?.copyWith(color: c.textSecondary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (u.isAdmin)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: FeSpace.xxs),
                    child: StatusChip(
                      icon: Icons.admin_panel_settings_outlined,
                      label: l.adminAdminBadge,
                      color: c.accent,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: FeSpace.xxs),
            Wrap(
              spacing: FeSpace.xs,
              runSpacing: FeSpace.xxs,
              children: [
                StatusChip(
                  icon: statusIcon,
                  label: statusLabel,
                  color: statusColor,
                ),
                StatusChip(
                  icon: Icons.workspace_premium_outlined,
                  label: l.admTierLabel(u.tier),
                  color: u.tier == null ? c.textSecondary : c.accent,
                ),
                // Admin’dan boshqa rollar (masalan, maqolalar moderatori —
                // admin huquqi YO‘Q).
                for (final r in u.roles)
                  if (r != 'identity_admin')
                    StatusChip(
                      icon: Icons.verified_user_outlined,
                      label: l.admRoleLabel(r),
                      color: c.textSecondary,
                    ),
              ],
            ),
            const SizedBox(height: FeSpace.xxs),
            Text(
              [
                if (u.createdAt != null)
                  l.admUserJoined(feDate(context, u.createdAt!.toLocal())),
                if (u.lastActivity != null)
                  l.admUserLastActive(
                    feDate(context, u.lastActivity!.toLocal()),
                  )
                else
                  l.admUserNoActivity,
                if (Specialty.values
                        .where((s) => s.name == u.specialty)
                        .firstOrNull
                    case final s?)
                  l.specialtyLabel(s),
                if (u.locale != null) u.locale!.toUpperCase(),
                if (u.platforms.isNotEmpty)
                  u.platforms.map(l.admPlatformLabel).join(' + '),
              ].join(FeGlyphs.middleDot),
              style: t.bodySmall?.copyWith(color: c.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

/// Admin: amallar jurnali (xabar matnisiz).
class AdminAuditScreen extends ConsumerWidget {
  const AdminAuditScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    final data = ref.watch(adminAuditProvider);
    return AdminGate(
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.admNavAudit),
          actions: [
            IconButton(
              tooltip: l.adminRefresh,
              icon: const Icon(Icons.refresh),
              onPressed: () => ref.invalidate(adminAuditProvider),
            ),
          ],
        ),
        body: SafeArea(
          child: switch (data) {
            AsyncData(:final value?) when value.isEmpty => FeEmptyState(
              key: const Key('adminAudit.empty'),
              icon: Icons.history,
              body: l.admAuditEmpty,
            ),
            AsyncData(:final value?) => ListView(
              key: const Key('adminAudit.list'),
              children: [
                FeContentFrame(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: FeSpace.sm),
                      for (final e in value)
                        Padding(
                          padding: const EdgeInsets.only(bottom: FeSpace.xs),
                          child: FeCard(
                            key: Key('adminAudit.entry.${e.id}'),
                            padding: const EdgeInsets.all(FeSpace.sm),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l.admAction(e.action),
                                  style: t.titleSmall,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  [
                                    e.actorEmail ?? l.admAuditSystem,
                                    supportTime(context, e.createdAt),
                                    if (e.detail['from'] != null &&
                                        e.detail['to'] != null)
                                      '${l.admAuditValue('${e.detail['from']}')} → '
                                          '${l.admAuditValue('${e.detail['to']}')}',
                                    if (e.detail['tier'] != null)
                                      l.admAuditValue('${e.detail['tier']}'),
                                    if (e.detail['role'] != null)
                                      l.admAuditValue('${e.detail['role']}'),
                                  ].where((x) => x.isNotEmpty).join(FeGlyphs.middleDot),
                                  style: t.bodySmall?.copyWith(
                                    color: c.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: FeSpace.xl),
                    ],
                  ),
                ),
              ],
            ),
            AsyncLoading() => Padding(
              padding: const EdgeInsets.all(FeSpace.md),
              child: FeListSkeleton(rows: 4, semanticLabel: l.loadingContent),
            ),
            _ => FeEmptyState(
              icon: Icons.cloud_off_outlined,
              body: l.adminFailed,
            ),
          },
        ),
      ),
    );
  }
}
