import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/plan.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/date_format.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/plan/plan_models.dart';
import '../../../domain/ports/plan_ports.dart';
import '../../pro/presentation/pro_gate.dart' show proPlanName;
import 'admin_gate.dart';

/// Admin: «Pro berish» — email, reja, muddat; ro‘yxat; olib tashlash.
/// Server (`admin_set_plan`) faqat identity_admin’ni qabul qiladi va audit
/// jurnaliga yozadi; bu ekran qulaylik, xavfsizlik chegarasi emas.
class AdminPlansScreen extends ConsumerStatefulWidget {
  const AdminPlansScreen({super.key});

  @override
  ConsumerState<AdminPlansScreen> createState() => _AdminPlansScreenState();
}

/// Muddat tanlovi (kun); `null` — muddatsiz.
const _durations = <int?>[30, 90, 365, null];

class _AdminPlansScreenState extends ConsumerState<AdminPlansScreen> {
  final _email = TextEditingController();
  final _search = TextEditingController();
  Plan _plan = Plan.student;
  int? _days = 30;
  String _query = '';
  bool _busy = false;
  String? _message;

  @override
  void dispose() {
    _email.dispose();
    _search.dispose();
    super.dispose();
  }

  Future<void> _apply({required bool revoke, String? email}) async {
    final l = AppLocalizations.of(context);
    final target = (email ?? _email.text).trim();
    if (target.isEmpty || !target.contains('@')) {
      setState(() => _message = l.admProInvalid);
      return;
    }
    setState(() {
      _busy = true;
      _message = null;
    });
    final r = await ref
        .read(adminPlanServiceProvider)
        .setPlan(
          email: target,
          plan: revoke ? null : _plan,
          until: revoke || _days == null
              ? null
              : DateTime.now().toUtc().add(Duration(days: _days!)),
        );
    if (!mounted) return;
    final msg = switch (r.value) {
      AdminPlanResult.granted => l.admProGranted,
      AdminPlanResult.revoked => l.admProRevoked,
      AdminPlanResult.notFound => l.admProNotFound,
      AdminPlanResult.invalid => l.admProInvalid,
      null =>
        r.failure == PlanFailure.forbidden ? l.admNotAuthorized : l.admProError,
    };
    ref.invalidate(adminPlanListProvider);
    ref.invalidate(adminPlanStatsProvider);
    setState(() {
      _busy = false;
      _message = msg;
      if (r.value == AdminPlanResult.granted) _email.clear();
    });
  }

  static String _statLabel(String label, int n) => '$label: $n';

  String _daysLabel(AppLocalizations l, int? d) => switch (d) {
    30 => l.admProDays30,
    90 => l.admProDays90,
    365 => l.admProYear,
    _ => l.admProNoLimit,
  };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final list = ref.watch(adminPlanListProvider(_query));
    final stats = ref.watch(adminPlanStatsProvider).value;
    return AdminGate(
      child: Scaffold(
        appBar: AppBar(
          title: FeAppBarTitle(l.admProTitle),
          actions: [
            IconButton(
              tooltip: l.adminRefresh,
              icon: const Icon(Icons.refresh),
              onPressed: () {
                ref.invalidate(adminPlanListProvider);
                ref.invalidate(adminPlanStatsProvider);
              },
            ),
          ],
        ),
        body: SafeArea(
          child: ListView(
            key: const Key('adminPlans.list'),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              FeContentFrame(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: FeSpace.sm),
                    FeBanner(
                      icon: Icons.privacy_tip_outlined,
                      text: l.admProNote,
                    ),
                    if (stats != null) ...[
                      const SizedBox(height: FeSpace.sm),
                      Wrap(
                        key: const Key('adminPlans.stats'),
                        spacing: FeSpace.xs,
                        runSpacing: FeSpace.xs,
                        children: [
                          for (final (label, n) in [
                            (l.proPlanStudent, stats.student),
                            (l.proPlanTeacher, stats.teacher),
                            (l.proPlanExpert, stats.expert),
                            (l.proPlanPremium, stats.premium),
                            (l.proSourceStore, stats.storeActive),
                            (l.proSourceAdmin, stats.adminActive),
                            (l.proSourceTrial, stats.trialsActive),
                          ])
                            Chip(label: Text(_statLabel(label, n))),
                        ],
                      ),
                    ],
                    FeSectionHeader(l.admProGrantTitle),
                    TextField(
                      key: const Key('adminPlans.email'),
                      controller: _email,
                      onTapOutside: (_) => FocusScope.of(context).unfocus(),
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      decoration: InputDecoration(labelText: l.admProEmail),
                    ),
                    const SizedBox(height: FeSpace.sm),
                    Text(l.admProPlan, style: t.labelLarge),
                    const SizedBox(height: FeSpace.xxs),
                    Wrap(
                      spacing: FeSpace.xs,
                      children: [
                        for (final p in Plan.values)
                          ChoiceChip(
                            key: Key('adminPlans.plan.${p.name}'),
                            label: Text(proPlanName(l, p)),
                            selected: _plan == p,
                            onSelected: (_) => setState(() => _plan = p),
                          ),
                      ],
                    ),
                    const SizedBox(height: FeSpace.sm),
                    Text(l.admProUntil, style: t.labelLarge),
                    const SizedBox(height: FeSpace.xxs),
                    Wrap(
                      spacing: FeSpace.xs,
                      children: [
                        for (final d in _durations)
                          ChoiceChip(
                            key: Key('adminPlans.days.${d ?? 'none'}'),
                            label: Text(_daysLabel(l, d)),
                            selected: _days == d,
                            onSelected: (_) => setState(() => _days = d),
                          ),
                      ],
                    ),
                    const SizedBox(height: FeSpace.md),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                            key: const Key('adminPlans.grant'),
                            onPressed: _busy
                                ? null
                                : () => _apply(revoke: false),
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(0, FeTouch.minTarget),
                            ),
                            child: Text(l.admProGrant),
                          ),
                        ),
                        const SizedBox(width: FeSpace.xs),
                        Expanded(
                          child: OutlinedButton(
                            key: const Key('adminPlans.revoke'),
                            onPressed: _busy
                                ? null
                                : () => _apply(revoke: true),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, FeTouch.minTarget),
                            ),
                            child: Text(l.admProRevoke),
                          ),
                        ),
                      ],
                    ),
                    if (_message != null)
                      Padding(
                        padding: const EdgeInsets.only(top: FeSpace.xs),
                        child: Semantics(
                          liveRegion: true,
                          child: Text(
                            _message!,
                            key: const Key('adminPlans.message'),
                            style: t.bodyMedium,
                          ),
                        ),
                      ),
                    FeSectionHeader(l.admProListTitle),
                    TextField(
                      key: const Key('adminPlans.search'),
                      controller: _search,
                      onTapOutside: (_) => FocusScope.of(context).unfocus(),
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: l.admProSearch,
                      ),
                      onSubmitted: (q) => setState(() => _query = q.trim()),
                    ),
                    const SizedBox(height: FeSpace.xs),
                    switch (list) {
                      AsyncData(:final value?) when value.isEmpty =>
                        FeEmptyState(
                          key: const Key('adminPlans.empty'),
                          compact: true,
                          icon: Icons.inbox_outlined,
                          body: l.admProEmpty,
                        ),
                      AsyncData(:final value?) => Column(
                        children: [
                          for (final r in value)
                            ListTile(
                              key: Key('adminPlans.row.${r.email}'),
                              contentPadding: EdgeInsets.zero,
                              title: Text(r.email),
                              subtitle: Text(_rowDetail(context, l, r)),
                              trailing: IconButton(
                                key: Key('adminPlans.remove.${r.email}'),
                                tooltip: l.admProRevoke,
                                icon: Icon(
                                  Icons.remove_circle_outline,
                                  color: c.danger,
                                ),
                                onPressed: _busy
                                    ? null
                                    : () =>
                                          _apply(revoke: true, email: r.email),
                              ),
                            ),
                        ],
                      ),
                      AsyncLoading() => FeListSkeleton(
                        rows: 3,
                        semanticLabel: l.loadingContent,
                      ),
                      _ => FeEmptyState(
                        key: const Key('adminPlans.error'),
                        compact: true,
                        icon: Icons.cloud_off_outlined,
                        body: l.admProError,
                      ),
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

  String _rowDetail(BuildContext context, AppLocalizations l, AdminPlanRow r) {
    final plan = r.plan == null ? '—' : proPlanName(l, r.plan!);
    final src = switch (r.source) {
      PlanSource.store => l.proSourceStore,
      PlanSource.admin => l.proSourceAdmin,
      PlanSource.trial => l.proSourceTrial,
      null => '—',
    };
    final until = r.expiresAt == null
        ? l.admProNoLimit
        : feDate(context, r.expiresAt!.toLocal());
    return '$plan · $src · $until';
  }
}
