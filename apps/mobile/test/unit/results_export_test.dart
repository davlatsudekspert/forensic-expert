import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/data/results_export/results_pdf.dart';
import 'package:forensic_expert/domain/results_export/results_table.dart';
import 'package:forensic_expert/domain/results_export/results_xlsx.dart';

void main() {
  const csv =
      'Ism,Holat,"To‘g‘ri, javoblar",Ball (100)\r\n'
      'Ali,Tugatdi,8,80.0\r\n'
      '"Vali ""Lola""",Yechmoqda,,\r\n'
      '\'=SUM(A1),Tugatdi,10,100.0\r\n';

  test('CSV → jadval: qo‘shtirnoq, vergul, bo‘sh maydon', () {
    final t = ResultsTable.fromCsv(csv);
    expect(t.header, ['Ism', 'Holat', 'To‘g‘ri, javoblar', 'Ball (100)']);
    expect(t.rows.length, 3);
    expect(t.rows[1], ['Vali "Lola"', 'Yechmoqda', '', '']);
    expect(t.rows[2][0], '\'=SUM(A1)'); // himoya belgisi saqlanadi
    expect(ResultsTable.fromCsv('').header, isEmpty);
  });

  test('fayl nomi kengaytmasi', () {
    expect(
      ResultsTable.fileNameWithExt('natija_2026.csv', 'xlsx'),
      'natija_2026.xlsx',
    );
    expect(ResultsTable.fileNameWithExt('natija', 'pdf'), 'natija.pdf');
  });

  test('xlsx: to‘g‘ri OOXML, raqam raqam, matn matn, formula bajarilmaydi', () {
    final bytes = ResultsXlsx.build(ResultsTable.fromCsv(csv));
    final z = ZipDecoder().decodeBytes(bytes);
    final names = z.files.map((f) => f.name).toSet();
    expect(
      names,
      containsAll([
        '[Content_Types].xml',
        '_rels/.rels',
        'xl/workbook.xml',
        'xl/worksheets/sheet1.xml',
        'xl/styles.xml',
      ]),
    );
    final sheet = String.fromCharCodes(
      z.files.firstWhere((f) => f.name == 'xl/worksheets/sheet1.xml').content
          as List<int>,
    );
    final xml = String.fromCharCodes(
      (z.files.firstWhere((f) => f.name == 'xl/worksheets/sheet1.xml').content
          as List<int>),
    );
    expect(xml.contains('<f>'), isFalse); // formula yo‘q
    expect(sheet, contains('<c r="C2"><v>8</v></c>'));
    expect(sheet, contains('<c r="D2"><v>80.0</v></c>'));
    expect(sheet, contains('Vali "Lola"'));
    expect(sheet, contains('pane ySplit="1"'));
  });

  test('xlsx: bo‘sh jadval ham ochiladi', () {
    final bytes = ResultsXlsx.build(
      const ResultsTable(header: ['A'], rows: []),
    );
    expect(ZipDecoder().decodeBytes(bytes).files, isNotEmpty);
  });

  test('pdf: %PDF sarlavha, o‘zbek harflari bilan, ko‘p sahifa', () async {
    final regular = File('assets/fonts/inter/Inter-Regular.ttf')
        .readAsBytesSync();
    final bold = File('assets/fonts/inter/Inter-Bold.ttf').readAsBytesSync();
    final rows = [
      for (var i = 0; i < 120; i++)
        ['Talaba $i oʻgʻil', 'Tugatdi', '$i', '${i % 100}.0'],
    ];
    final bytes = await ResultsPdf.build(
      table: ResultsTable(
        header: const ['Ism', 'Holat', 'To‘g‘ri', 'Ball'],
        rows: rows,
      ),
      title: 'Guruh testi natijalari',
      dateLabel: '07.11.2026',
      regular: regular,
      bold: bold,
    );
    expect(String.fromCharCodes(bytes.sublist(0, 5)), '%PDF-');
    expect(bytes.length, greaterThan(5000));
    // Bir nechta sahifa (Type /Page)
    final text = String.fromCharCodes(bytes);
    expect(
      '/Type /Page\n'.allMatches(text).length +
          '/Type/Page'.allMatches(text).length,
      greaterThan(1),
    );
  });
}
