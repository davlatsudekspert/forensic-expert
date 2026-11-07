import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/class_quiz.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/date_format.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../app/results_export.dart';
import '../../../domain/results_export/results_table.dart';
import '../../../domain/results_export/results_xlsx.dart';

/// Natijalarni Excel / PDF / CSV sifatida saqlash yoki ulashish (varaq).
///
/// [csv] — mavjud eksport (formula himoyasi bilan); Excel va PDF shu
/// ma’lumotdan quriladi, hech narsa qayta hisoblanmaydi.
Future<void> showResultsExportSheet(
  BuildContext context,
  WidgetRef ref, {
  required String csvFileName,
  required String csv,
  required String title,
}) async {
  final choice = await showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (c) {
      final l = AppLocalizations.of(c);
      Widget tile(String key, IconData icon, String t, String body) => ListTile(
        key: Key('results.export.$key'),
        leading: Icon(icon),
        title: Text(t),
        subtitle: Text(body),
        onTap: () => Navigator.of(c).pop(key),
      );
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: FeSpace.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              tile(
                'xlsx',
                Icons.table_chart_outlined,
                l.resultsExportExcel,
                l.resultsExportExcelBody,
              ),
              tile(
                'pdf',
                Icons.picture_as_pdf_outlined,
                l.resultsExportPdf,
                l.resultsExportPdfBody,
              ),
              tile(
                'csv',
                Icons.description_outlined,
                l.resultsExportCsv,
                l.resultsExportCsvBody,
              ),
            ],
          ),
        ),
      );
    },
  );
  if (choice == null || !context.mounted) return;
  final l = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final share = ref.read(classFileShareProvider);
  final dateLabel = feDate(context, DateTime.now());
  try {
    switch (choice) {
      case 'csv':
        await share.shareCsv(
          fileName: csvFileName,
          content: csv,
          subject: title,
        );
      case 'xlsx':
        await share.shareFile(
          fileName: ResultsTable.fileNameWithExt(csvFileName, 'xlsx'),
          bytes: ResultsXlsx.build(ResultsTable.fromCsv(csv)),
          mimeType: ResultsXlsx.mime,
          subject: title,
        );
      case 'pdf':
        final regular = (await rootBundle.load(
          'assets/fonts/inter/Inter-Regular.ttf',
        )).buffer.asUint8List();
        final bold = (await rootBundle.load(
          'assets/fonts/inter/Inter-Bold.ttf',
        )).buffer.asUint8List();
        final Uint8List bytes = await ResultsPdf.build(
          table: ResultsTable.fromCsv(csv),
          title: title,
          dateLabel: dateLabel,
          regular: regular,
          bold: bold,
        );
        await share.shareFile(
          fileName: ResultsTable.fileNameWithExt(csvFileName, 'pdf'),
          bytes: bytes,
          mimeType: ResultsPdf.mime,
          subject: title,
        );
    }
  } on Object {
    messenger.showSnackBar(SnackBar(content: Text(l.classErrServer)));
  }
}
