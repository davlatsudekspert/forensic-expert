import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/account.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/admin/admin_models.dart';

/// Egasi uchun admin panel: foydalanuvchilar, platformalar, davlatlar,
/// AI va takliflar soni, Pro berish. Ma’lumot faqat serverdan va faqat
/// identity_admin uchun (`admin_dashboard`).
class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

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
            onPressed: () => ref.invalidate(adminDashboardProvider),
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
          _ => const Center(child: CircularProgressIndicator()),
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
                  trailing: Text('$users', style: t.titleSmall),
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
                      Text('$n', style: t.bodySmall),
                    ],
                  ),
                ),
              const _GrantSection(),
              FeSectionHeader(l.adminUserList(d.users.length)),
              for (final u in d.users)
                FeCard(
                  key: Key('admin.user.${u.email}'),
                  padding: const EdgeInsets.all(FeSpace.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              u.email,
                              style: t.titleSmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (u.isAdmin)
                            StatusChip(
                              icon: Icons.admin_panel_settings_outlined,
                              label: l.adminAdminBadge,
                              color: c.accent,
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        [
                          if (u.platforms.isNotEmpty) u.platforms.join(' + '),
                          u.region ?? l.adminUnknownRegion,
                          if (u.tier != null) u.tier!,
                          if (u.createdAt != null)
                            u.createdAt!.toLocal().toString().substring(0, 16),
                        ].join(' · '),
                        style: t.bodySmall?.copyWith(color: c.textSecondary),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: FeSpace.xl),
            ],
          ),
        ),
      ],
    );
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
