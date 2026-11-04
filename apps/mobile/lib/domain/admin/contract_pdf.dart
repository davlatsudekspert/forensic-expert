import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'contract_text.dart';

/// [blocks] ni A4 PDF’ga aylantiradi. Shrift — ilovadagi TTF (o‘zbekcha
/// ‘ ’ “ ” № « » belgilari uchun standart PDF shrifti yetmaydi).
Future<Uint8List> buildContractPdf(
  List<ContractBlock> blocks, {
  required ByteData regular,
  required ByteData bold,
  String? title,
}) async {
  final base = pw.Font.ttf(regular);
  final strong = pw.Font.ttf(bold);
  final doc = pw.Document(
    title: title,
    author: 'Forensic Expert',
    theme: pw.ThemeData.withFont(base: base, bold: strong),
  );
  const size = 11.0;
  const plain = pw.TextStyle(fontSize: size, lineSpacing: 1.5);
  const strongStyle = pw.TextStyle(
    fontSize: size,
    fontWeight: pw.FontWeight.bold,
    lineSpacing: 1.5,
  );

  pw.Widget cell(String t, {bool header = false}) => pw.Padding(
    padding: const pw.EdgeInsets.all(4),
    child: pw.Text(t, style: header ? strongStyle : plain),
  );

  final widgets = <pw.Widget>[];
  for (final b in blocks) {
    switch (b.kind) {
      case ContractBlockKind.title:
        widgets.add(
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 4),
            child: pw.Center(
              child: pw.Text(
                b.text,
                style: strongStyle,
                textAlign: pw.TextAlign.center,
              ),
            ),
          ),
        );
      case ContractBlockKind.subtitle:
        widgets.add(
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 8),
            child: pw.Center(
              child: pw.Text(
                b.text,
                style: plain,
                textAlign: pw.TextAlign.center,
              ),
            ),
          ),
        );
      case ContractBlockKind.spread:
        widgets.add(
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 8),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(b.text, style: plain),
                pw.Text(b.text2, style: plain),
              ],
            ),
          ),
        );
      case ContractBlockKind.heading:
        widgets.add(
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 4, bottom: 3),
            child: pw.Text(b.text, style: strongStyle),
          ),
        );
      case ContractBlockKind.paragraph:
      case ContractBlockKind.note:
        widgets.add(
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 4),
            child: pw.Text(
              b.text,
              style: plain,
              textAlign: b.kind == ContractBlockKind.paragraph
                  ? pw.TextAlign.justify
                  : pw.TextAlign.left,
            ),
          ),
        );
      case ContractBlockKind.signatures:
        widgets.add(
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 6, bottom: 4),
            child: pw.Text(b.text, style: plain),
          ),
        );
      case ContractBlockKind.labeled:
        widgets.add(
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 4),
            child: pw.RichText(
              text: pw.TextSpan(
                children: [
                  pw.TextSpan(text: '${b.text} ', style: strongStyle),
                  pw.TextSpan(text: b.text2, style: plain),
                ],
              ),
            ),
          ),
        );
      case ContractBlockKind.parties:
        final table = pw.Table(
          border: pw.TableBorder.all(width: 0.5),
          children: [
            pw.TableRow(
              verticalAlignment: pw.TableCellVerticalAlignment.top,
              children: [cell(b.text), cell(b.text2)],
            ),
          ],
        );
        widgets.add(table);
      case ContractBlockKind.table:
        if (b.rows.isEmpty) break;
        final cols = b.rows.first.length;
        widgets.add(
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 6),
            child: pw.Table(
              border: pw.TableBorder.all(width: 0.5),
              columnWidths: {
                0: const pw.FixedColumnWidth(32),
                for (var c = 1; c < cols; c++) c: const pw.FlexColumnWidth(),
              },
              children: [
                for (var r = 0; r < b.rows.length; r++)
                  pw.TableRow(
                    children: [
                      for (final v in b.rows[r]) cell(v, header: r == 0),
                    ],
                  ),
              ],
            ),
          ),
        );
      case ContractBlockKind.pageBreak:
        widgets.add(pw.NewPage());
    }
  }

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(71, 57, 43, 57),
      build: (_) => widgets,
      footer: (ctx) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          '${ctx.pageNumber} / ${ctx.pagesCount}',
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
        ),
      ),
    ),
  );
  return doc.save();
}

/// Matnda shriftda yo‘q belgilar (PDF’da bo‘sh kvadrat bo‘lib chiqadi)
/// bormi — sinov uchun.
Set<int> missingGlyphs(String text, ByteData fontData) {
  final map = TtfParser(fontData).charToGlyphIndexMap;
  return {
    for (final r in text.runes)
      if (r != 0x0A && r != 0x20 && !map.containsKey(r)) r,
  };
}
