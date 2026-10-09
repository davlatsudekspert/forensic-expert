import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/account.dart';
import '../../../app/routes.dart';
import '../../../app/support.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/admin/admin_models.dart';
import 'admin_gate.dart';
import 'admin_widgets.dart';

/// Egasi uchun admin panel: bo‘limlar (murojaatlar, foydalanuvchilar,
/// jurnal, moderatsiya), agregat statistika (`admin_stats`), platformalar,
/// davlatlar, Pro berish. Ma’lumot faqat serverdan va faqat identity_admin
/// uchun; marshrut [AdminGate] bilan yopiq.
class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      const AdminGate(child: _AdminDashboard());
}

class _AdminDashboard extends ConsumerWidget {
  const _AdminDashboard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final data = ref.watch(adminDashboardProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.adminTitle),
        actions: [
          IconButton(
            key: const Key('admin.refresh'),
            tooltip: l.adminRefresh,
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(adminDashboardProvider);
              ref.invalidate(adminStatsProvider);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: switch (data) {
          AsyncData(:final value?) => _Body(d: value),
          AsyncData() || AsyncError() => FeEmptyState(
            key: const Key('admin.forbidden'),
            icon: Icons.admin_panel_settings_outlined,
            body: l.adminForbidden,
          ),
          _ => Padding(
            padding: const EdgeInsets.all(FeSpace.md),
            child: FeListSkeleton(rows: 4, semanticLabel: l.loadingContent),
          ),
        },
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.d});

  final AdminDashboard d;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    final stats = <(String, int)>[
      (l.adminUsers, d.total('users')),
      (l.adminConfirmed, d.total('confirmed')),
      (l.adminSignups7d, d.total('signups_7d')),
      (l.adminActive7d, d.total('active_7d')),
      (l.adminAndroid, d.total('android')),
      (l.adminIos, d.total('ios')),
      (l.adminAiRequests, d.total('ai_requests')),
      (l.adminReferrals, d.total('referrals')),
      (l.adminProGrants, d.total('pro_grants')),
    ];
    final maxDaily = d.daily.fold<int>(1, (m, e) => e.$2 > m ? e.$2 : m);
    return ListView(
      key: const Key('admin.list'),
      children: [
        FeContentFrame(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: FeSpace.sm),
              FeBanner(icon: Icons.lock_outline, text: l.adminPrivacyNote),
              const SizedBox(height: FeSpace.sm),
              const _AdminSections(),
              const _AdminOverview(),
              FeSectionHeader(l.adminTitle),
              LayoutBuilder(
                builder: (context, box) {
                  final scale = MediaQuery.textScalerOf(context).scale(1);
                  final cols = box.maxWidth >= 520 && scale < 1.6 ? 3 : 2;
                  const gap = FeSpace.xs;
                  final w = (box.maxWidth - gap * (cols - 1)) / cols;
                  return Wrap(
                    key: const Key('admin.stats'),
                    spacing: gap,
                    runSpacing: gap,
                    children: [
                      for (final (label, value) in stats)
                        SizedBox(
                          width: w,
                          child: FeCard(
                            padding: const EdgeInsets.all(FeSpace.sm),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$value',
                                  style: FeThemeBuilder.numeric(t.titleLarge!)
                                      .copyWith(fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  label,
                                  style: t.labelSmall?.copyWith(
                                    color: c.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: FeSpace.xs),
              Text(
                l.adminStoreNote,
                style: t.bodySmall?.copyWith(color: c.textSecondary),
              ),
              FeSectionHeader(l.adminRegions),
              for (final (region, users) in d.regions)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Text(
                    region == '??' ? '—' : region,
                    style: FeThemeBuilder.numeric(t.titleSmall!),
                  ),
                  title: Text(region == '??' ? l.adminUnknownRegion : region),
                  trailing: Text(users.toString(), style: t.titleSmall),
                ),
              FeSectionHeader(l.adminDaily),
              for (final (day, n) in d.daily)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 92,
                        child: Text(
                          day,
                          style: FeThemeBuilder.numeric(t.bodySmall!),
                        ),
                      ),
                      Expanded(
                        child: FractionallySizedBox(
                          alignment: AlignmentDirectional.centerStart,
                          widthFactor: n / maxDaily,
                          child: Container(
                            height: 10,
                            decoration: BoxDecoration(
                              color: c.accent,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: FeSpace.xs),
                      Text(n.toString(), style: t.bodySmall),
                    ],
                  ),
                ),
              const _GrantSection(),
              const SizedBox(height: FeSpace.xl),
            ],
          ),
        ),
      ],
    );
  }
}

/// Bo‘limlar: murojaatlar qutisi, foydalanuvchilar, jurnal, moderatsiya.
class _AdminSections extends ConsumerWidget {
  const _AdminSections();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final stats = ref.watch(adminStatsProvider).value;
    final support = ref.watch(supportAvailableProvider);
    final tiles = [
      if (support) ...[
        AdminNavTile(
          key: const Key('admin.nav.inbox'),
          icon: Icons.forum_outlined,
          title: l.admNavInbox,
          hint: l.admNavInboxHint(stats?.supportAwaiting ?? 0),
          badge: stats?.supportAwaiting ?? 0,
          onTap: () => context.push(Routes.adminInbox),
        ),
        AdminNavTile(
          key: const Key('admin.nav.users'),
          icon: Icons.group_outlined,
          title: l.admNavUsers,
          hint: l.admNavUsersHint,
          onTap: () => context.push(Routes.adminUsers),
        ),
        AdminNavTile(
          key: const Key('admin.nav.audit'),
          icon: Icons.history_edu_outlined,
          title: l.admNavAudit,
          hint: l.admNavAuditHint,
          onTap: () => context.push(Routes.adminAudit),
        ),
      ],
      AdminNavTile(
        key: const Key('admin.nav.moderation'),
        icon: Icons.fact_check_outlined,
        title: l.admNavModeration,
        hint: l.admNavModerationHint(stats?.publicationsAwaiting ?? 0),
        badge: stats?.publicationsAwaiting ?? 0,
        onTap: () => context.push(Routes.publicationsModeration),
      ),
    ];
    return LayoutBuilder(
      builder: (context, box) {
        final cols = box.maxWidth >= 640 ? 2 : 1;
        const gap = FeSpace.xs;
        final w = (box.maxWidth - gap * (cols - 1)) / cols;
        return Wrap(
          key: const Key('admin.sections'),
          spacing: gap,
          runSpacing: gap,
          children: [for (final t in tiles) SizedBox(width: w, child: t)],
        );
      },
    );
  }
}

/// `admin_stats()` — faqat agregat sonlar; ta’riflar izoh sifatida.
class _AdminOverview extends ConsumerWidget {
  const _AdminOverview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    if (!ref.watch(supportAvailableProvider)) return const SizedBox.shrink();
    final stats = ref.watch(adminStatsProvider);
    return switch (stats) {
      AsyncData(:final value?) => Column(
        key: const Key('admin.overview'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FeSectionHeader(l.admOverview),
          AdminStatGrid(
            items: [
              (Icons.group_outlined, '${value.usersTotal}', l.admStatUsers),
              (
                Icons.fiber_new_outlined,
                '${value.newToday}',
                l.admStatNewToday,
              ),
              (Icons.trending_up, '${value.new7d}', l.admStatNew7d),
              (
                Icons.calendar_month_outlined,
                '${value.new30d}',
                l.admStatNew30d,
              ),
              (Icons.bolt_outlined, '${value.active7d}', l.admStatActive7d),
              (
                Icons.insights_outlined,
                '${value.active30d}',
                l.admStatActive30d,
              ),
              (Icons.workspace_premium_outlined, '${value.pro}', l.admStatPro),
              (Icons.person_outline, '${value.free}', l.admStatFree),
              (
                Icons.badge_outlined,
                '${value.professionalProfiles}',
                l.admStatProfiles,
              ),
              (
                Icons.verified_outlined,
                '${value.verifiedProfessionals}',
                l.admStatVerified,
              ),
              (
                Icons.forum_outlined,
                '${value.supportAwaiting}',
                l.admStatAwaiting,
              ),
              (
                Icons.fact_check_outlined,
                '${value.publicationsAwaiting}',
                l.admStatPublications,
              ),
              (
                Icons.auto_awesome_outlined,
                '${value.aiTotal}',
                l.admStatAiTotal,
              ),
              (Icons.auto_awesome, '${value.ai7d}', l.admStatAi7d),
            ],
          ),
          const SizedBox(height: FeSpace.xs),
          for (final note in [l.admModesNote, l.admActiveNote, l.admProNote])
            Padding(
              padding: const EdgeInsets.only(bottom: FeSpace.xxs),
              child: Text(
                note,
                style: t.bodySmall?.copyWith(color: c.textSecondary),
              ),
            ),
          const SizedBox(height: FeSpace.xs),
          if (value.daily.isNotEmpty) AdminDailyChart(daily: value.daily),
          const SizedBox(height: FeSpace.xs),
          AdminCategoryBars(counts: value.supportByCategory),
        ],
      ),
      AsyncLoading() => Padding(
        padding: const EdgeInsets.symmetric(vertical: FeSpace.sm),
        child: FeListSkeleton(rows: 2, semanticLabel: l.loadingContent),
      ),
      _ => Padding(
        padding: const EdgeInsets.only(top: FeSpace.sm),
        child: FeEmptyState(
          key: const Key('admin.statsUnavailable'),
          compact: true,
          icon: Icons.cloud_off_outlined,
          body: l.admStatsUnavailable,
        ),
      ),
    };
  }
}

class _GrantSection extends ConsumerStatefulWidget {
  const _GrantSection();

  @override
  ConsumerState<_GrantSection> createState() => _GrantSectionState();
}

class _GrantSectionState extends ConsumerState<_GrantSection> {
  final _email = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _run(String? tier) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    final r = await ref
        .read(accountServiceProvider)
        .setAccess(_email.text, tier);
    if (!mounted) return;
    setState(() => _busy = false);
    messenger.showSnackBar(
      SnackBar(
        content: Text(switch (r) {
          AdminGrantResult.granted => l.adminGranted,
          AdminGrantResult.revoked => l.adminRevoked,
          AdminGrantResult.notFound => l.adminNotFound,
          _ => l.adminFailed,
        }),
      ),
    );
    if (r == AdminGrantResult.granted || r == AdminGrantResult.revoked) {
      ref.invalidate(adminDashboardProvider);
      ref.invalidate(serverAccessProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FeSectionHeader(l.adminGrantTitle),
        TextField(
          key: const Key('admin.grantEmail'),
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          decoration: InputDecoration(labelText: l.adminEmail),
        ),
        const SizedBox(height: FeSpace.xs),
        Wrap(
          spacing: FeSpace.xs,
          runSpacing: FeSpace.xs,
          children: [
            FilledButton(
              key: const Key('admin.grant'),
              onPressed: _busy ? null : () => _run('professionalPro'),
              child: Text(l.adminGrantPro),
            ),
            OutlinedButton(
              key: const Key('admin.revoke'),
              onPressed: _busy ? null : () => _run(null),
              child: Text(l.adminRevoke),
            ),
          ],
        ),
      ],
    );
  }
}
