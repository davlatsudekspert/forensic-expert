import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/class_quiz.dart';
import '../../../app/plan.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../domain/class_groups/class_groups_models.dart';
import '../../../domain/class_groups/group_results_csv.dart';
import '../../../domain/plan/plan_models.dart';
import '../../pro/presentation/pro_gate.dart';

/// Guruh testi natijalarini CSV (reestr: «Ball (100)», «Baho») sifatida
/// ulashish. Natijalar CSV — Ustoz Pro (tugma ko‘rinadi, qulfli), jonli sinf
/// CSV’i bilan bir xil qoida.
Future<void> exportGroupResultsCsv(
  BuildContext context,
  WidgetRef ref,
  GroupBoard board,
) async {
  if (!ref.read(proAllowedProvider(ProFeature.resultsCsv))) {
    openPro(context, Plan.teacher);
    return;
  }
  final l = AppLocalizations.of(context);
  await ref
      .read(classFileShareProvider)
      .shareCsv(
        fileName: GroupResultsCsv.fileName(DateTime.now()),
        content: GroupResultsCsv.build(
          board.ranked.map((x) => x.row),
          belowMinLabel: l.scoringGradeBelowMin,
        ),
        subject: l.classCsvSubject,
      );
}

/// «CSV» tugmasi (ustoz natijalar ekrani).
class GroupCsvButton extends ConsumerWidget {
  const GroupCsvButton({super.key, required this.board});

  final GroupBoard board;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return OutlinedButton.icon(
      key: const Key('grp.exportCsv'),
      onPressed: () => exportGroupResultsCsv(context, ref, board),
      icon: const ProIcon(
        feature: ProFeature.resultsCsv,
        icon: Icons.ios_share,
      ),
      label: Text(l.classExportCsv),
    );
  }
}
