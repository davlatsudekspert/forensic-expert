import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../domain/results_export/results_table.dart';

/// Natijalar jadvali PDF (A4). Shrift ilovaga o‘rnatilgan Inter (o‘zbek
/// lotin/kirill, ʻ ʼ ‘ ’ belgilari bor) — PDF ichiga joylanadi (offline).
/// Imzo, muhr, logotip qo‘yilmaydi (egasi qarori).
abstract final class ResultsPdf {
  static const mime = 'application/pdf';

  static Future<Uint8List> build({
    required ResultsTable table,
    required String title,
    required String dateLabel,
    required Uint8List regular,
    required Uint8List bold,
  }) async {
    final base = pw.Font.ttf(ByteData.sublistView(regular));
    final strong = pw.Font.ttf(ByteData.sublistView(bold));
    final doc = pw.Document(
      title: title,
      theme: pw.ThemeData.withFont(base: base, bold: strong),
    );
    final wide = table.columns > 6;
    const navy = PdfColor.fromInt(0xFF0B1F3A);
    doc.addPage(
      pw.MultiPage(
        pageFormat: wide ? PdfPageFormat.a4.landscape : PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        header: (c) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              title,
              style: pw.TextStyle(font: strong, fontSize: 15, color: navy),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              dateLabel,
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 10),
          ],
        ),
        footer: (c) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            '${c.pageNumber} / ${c.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
          ),
        ),
        build: (c) => [
          pw.TableHelper.fromTextArray(
            headers: table.header,
            data: table.rows,
            headerStyle: pw.TextStyle(
              font: strong,
              fontSize: 9,
              color: PdfColors.white,
            ),
            headerDecoration: const pw.BoxDecoration(color: navy),
            cellStyle: const pw.TextStyle(fontSize: 9),
            cellPadding: const pw.EdgeInsets.symmetric(
              horizontal: 4,
              vertical: 3,
            ),
            border: const pw.TableBorder(
              horizontalInside: pw.BorderSide(
                color: PdfColors.grey300,
                width: 0.4,
              ),
              bottom: pw.BorderSide(color: PdfColors.grey400, width: 0.6),
            ),
            oddRowDecoration: const pw.BoxDecoration(
              color: PdfColor.fromInt(0xFFF3F6FA),
            ),
            cellAlignment: pw.Alignment.centerLeft,
            headerAlignment: pw.Alignment.centerLeft,
          ),
        ],
      ),
    );
    return Uint8List.fromList(await doc.save());
  }
}
