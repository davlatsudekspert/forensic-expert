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
import 'admin_gate.dart';

/// Admin → «Tashkilotlar»: ro‘yxat (nomi, o‘rinlar, ishlatilgan, tugash sanasi)
/// va «Yangi tashkilot» / «Sovg‘a promokod».
/// Server har bir RPC’da identity_admin’ni tekshiradi.
class AdminInstitutesScreen extends ConsumerWidget {
  const AdminInstitutesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                        children: [
                          for (final i in value!)
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: FeSpace.xs,
                              ),
                              child: FeCard(
                                key: Key('adminInst.row.${i.id}'),
                                padding: const EdgeInsets.all(FeSpace.sm),
                                onTap: () =>
                                    context.push(Routes.adminInstitute(i.id)),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(i.name, style: t.titleSmall),
                                          Text(
                                            l.instRowInfo(i.seats, i.redeemed),
                                            style: t.bodySmall?.copyWith(
                                              color: c.textSecondary,
                                            ),
                                          ),
                                          if (i.termEnd != null)
                                            Text(
                                              l.instRowUntil(
                                                feDate(context, i.termEnd!),
                                              ),
                                              style: t.bodySmall?.copyWith(
                                                color: c.textSecondary,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.chevron_right,
                                      color: c.textSecondary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
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
