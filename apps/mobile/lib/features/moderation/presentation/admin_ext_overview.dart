import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/moderation.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/moderation/moderation_models.dart';
import '../../admin/presentation/admin_widgets.dart';

/// `admin_stats_ext()`: rollar, shikoyatlar, Savol-javob obyektlari va serverga
/// ko‘rinmaydigan narsalar uchun HALOL izohlar (yuklab olish, sotuv, casebook,
/// «hozir tizimda»). O‘ylab topilgan son yo‘q.
class AdminExtOverview extends ConsumerWidget {
  const AdminExtOverview({super.key});

  Future<void> _open(BuildContext context, Uri uri) async {
    final messenger = ScaffoldMessenger.of(context);
    final failed = AppLocalizations.of(context).admxOpenFailed;
    var ok = false;
    try {
      ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Object {
      ok = false;
    }
    if (!ok) messenger.showSnackBar(SnackBar(content: Text(failed)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    if (!ref.watch(reportAvailableProvider)) return const SizedBox.shrink();
    final stats = ref.watch(adminStatsExtProvider);
    Widget note(Key key, IconData icon, String text) => Padding(
      padding: const EdgeInsets.only(bottom: FeSpace.xs),
      child: Row(
        key: key,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: c.textSecondary),
          const SizedBox(width: FeSpace.xs),
          Expanded(
            child: Text(
              text,
              style: t.bodySmall?.copyWith(color: c.textSecondary),
            ),
          ),
        ],
      ),
    );
    return Column(
      key: const Key('admin.ext'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FeSectionHeader(l.admxExtTitle),
        switch (stats) {
          AsyncData(:final value?) => AdminStatGrid(
            items: [
              (
                Icons.admin_panel_settings_outlined,
                '${value.admins}',
                l.admxStatAdmins,
              ),
              (
                Icons.verified_user_outlined,
                '${value.moderators}',
                l.admxStatModerators,
              ),
              (Icons.block, '${value.suspended}', l.admxStatSuspended),
              (
                Icons.report_gmailerrorred_outlined,
                '${value.reportsOpen}',
                l.admxStatReportsOpen,
              ),
              (
                Icons.task_alt_outlined,
                '${value.reportsResolved}',
                l.admxStatReportsResolved,
              ),
              (
                Icons.help_outline,
                '${value.qaQuestions}',
                l.admxStatQaQuestions,
              ),
              (
                Icons.question_answer_outlined,
                '${value.qaAnswers}',
                l.admxStatQaAnswers,
              ),
              (
                Icons.fact_check_outlined,
                '${value.qaInModeration}',
                l.admxStatQaModeration,
              ),
              (Icons.person_off_outlined, '${value.blocks}', l.admxStatBlocks),
            ],
          ),
          AsyncLoading() => FeListSkeleton(
            rows: 2,
            semanticLabel: l.loadingContent,
          ),
          _ => FeEmptyState(
            key: const Key('admin.extUnavailable'),
            compact: true,
            icon: Icons.cloud_off_outlined,
            body: l.admStatsUnavailable,
          ),
        },
        const SizedBox(height: FeSpace.sm),
        // Serverga ko‘rinmaydigan narsalar — halol izohlar.
        note(
          const Key('admin.ext.casebook'),
          Icons.phone_android,
          l.admxCasebookNote,
        ),
        note(const Key('admin.ext.online'), Icons.podcasts, l.admxOnlineNote),
        FeSectionHeader(l.admxStoresTitle),
        note(
          const Key('admin.ext.downloads'),
          Icons.download_outlined,
          l.admxDownloadsNote,
        ),
        note(
          const Key('admin.ext.sales'),
          Icons.payments_outlined,
          l.admxSalesNote,
        ),
        Wrap(
          spacing: FeSpace.xs,
          runSpacing: FeSpace.xs,
          children: [
            OutlinedButton.icon(
              key: const Key('admin.ext.asc'),
              onPressed: () => _open(context, AdminLinks.appStoreConnect),
              icon: const Icon(Icons.open_in_new),
              label: Text(l.admxOpenAsc),
            ),
            OutlinedButton.icon(
              key: const Key('admin.ext.play'),
              onPressed: () => _open(context, AdminLinks.playConsole),
              icon: const Icon(Icons.open_in_new),
              label: Text(l.admxOpenPlay),
            ),
          ],
        ),
      ],
    );
  }
}
