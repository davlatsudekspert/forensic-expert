import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/institutes.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/date_format.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/admin/institute_models.dart';
import 'admin_gate.dart';

/// Admin → «Tashkilotlar»: ro‘yxat (nomi, o‘rinlar, ishlatilgan, tugash sanasi)
/// va «Yangi tashkilot» / «Sovg‘a promokod».
/// Server har bir RPC’da identity_admin’ni tekshiradi.
class AdminInstitutesScreen extends ConsumerStatefulWidget {
  const AdminInstitutesScreen({super.key});

  @override
  ConsumerState<AdminInstitutesScreen> createState() =>
      _AdminInstitutesScreenState();
}

class _AdminInstitutesScreenState extends ConsumerState<AdminInstitutesScreen> {
  bool _showArchived = false;

  Widget _row(
    BuildContext context,
    InstituteSummary i,
    AppLocalizations l,
    FeColorTokens c,
    TextTheme t,
  ) {
    final muted = i.archived ? c.textSecondary : null;
    return Padding(
      padding: const EdgeInsets.only(bottom: FeSpace.xs),
      child: Opacity(
        opacity: i.archived ? 0.65 : 1,
        child: FeCard(
          key: Key('adminInst.row.${i.id}'),
          padding: const EdgeInsets.all(FeSpace.sm),
          onTap: () => context.push(Routes.adminInstitute(i.id)),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(i.name, style: t.titleSmall?.copyWith(color: muted)),
                    if (i.archived)
                      Text(
                        l.instArchivedBadge,
                        key: Key('adminInst.badge.${i.id}'),
                        style: t.labelMedium?.copyWith(color: c.textSecondary),
                      ),
                    Text(
                      l.instRowInfo(i.seats, i.redeemed),
                      style: t.bodySmall?.copyWith(color: c.textSecondary),
                    ),
                    if (i.termEnd != null)
                      Text(
                        l.instRowUntil(feDate(context, i.termEnd!)),
                        style: t.bodySmall?.copyWith(color: c.textSecondary),
                      ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: c.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final list = ref.watch(adminInstitutesProvider);
    return AdminGate(
      child: Scaffold(
        appBar: AppBar(
          title: FeAppBarTitle(l.instNavTitle),
          actions: [
            IconButton(
              tooltip: l.adminRefresh,
              icon: const Icon(Icons.refresh),
              onPressed: () => ref.invalidate(adminInstitutesProvider),
            ),
          ],
        ),
        body: SafeArea(
          child: ListView(
            key: const Key('adminInst.list'),
            children: [
              FeContentFrame(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: FeSpace.sm),
                    FilledButton.icon(
                      key: const Key('adminInst.new'),
                      onPressed: () => context.push(Routes.adminInstituteNew),
                      icon: const Icon(Icons.add_business_outlined),
                      label: Text(l.instNew),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, FeTouch.minTarget),
                      ),
                    ),
                    const SizedBox(height: FeSpace.xs),
                    OutlinedButton.icon(
                      key: const Key('adminInst.gift'),
                      onPressed: () => context.push(Routes.adminGiftCodes),
                      icon: const Icon(Icons.card_giftcard_outlined),
                      label: Text(l.instGift),
                    ),
                    const SizedBox(height: FeSpace.sm),
                    switch (list) {
                      AsyncData(:final value) when value == null => Text(
                        l.instLoadError,
                        key: const Key('adminInst.error'),
                        style: t.bodyMedium?.copyWith(color: c.danger),
                      ),
                      AsyncData(:final value) when value!.isEmpty => Text(
                        l.instEmpty,
                        key: const Key('adminInst.empty'),
                        style: t.bodyMedium?.copyWith(color: c.textSecondary),
                      ),
                      AsyncData(:final value) => Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final i in value!.where((x) => !x.archived))
                            _row(context, i, l, c, t),
                          if (value.any((x) => x.archived)) ...[
                            InkWell(
                              key: const Key('adminInst.archivedToggle'),
                              onTap: () => setState(
                                () => _showArchived = !_showArchived,
                              ),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  minHeight: FeTouch.minTarget,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        l.instArchivedSection(
                                          value.where((x) => x.archived).length,
                                        ),
                                        style: t.titleSmall,
                                      ),
                                    ),
                                    Icon(
                                      _showArchived
                                          ? Icons.expand_less
                                          : Icons.expand_more,
                                      color: c.textSecondary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (_showArchived)
                              for (final i in value.where((x) => x.archived))
                                _row(context, i, l, c, t),
                          ],
                        ],
                      ),
                      AsyncError() => Text(
                        l.instLoadError,
                        style: t.bodyMedium?.copyWith(color: c.danger),
                      ),
                      _ => FeListSkeleton(
                        rows: 3,
                        semanticLabel: l.loadingContent,
                      ),
                    },
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
