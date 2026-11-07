import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

import 'results_table.dart';

/// Eng sodda, standart OOXML (.xlsx): bitta varaq, qalin sarlavha qatori,
/// qotirilgan birinchi qator, ustun kengligi. Raqamlar raqam sifatida
/// (saralash/formula uchun), qolgani matn (inlineStr) — formula bajarilmaydi.
abstract final class ResultsXlsx {
  static const mime =
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';

  static final _number = RegExp(r'^-?\d{1,15}(\.\d+)?$');

  static String _esc(String s) => s
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F]'), '');

  static String _col(int i) {
    var n = i;
    var s = '';
    do {
      s = String.fromCharCode(65 + n % 26) + s;
      n = n ~/ 26 - 1;
    } while (n >= 0);
    return s;
  }

  static String _cell(int r, int c, String v, {bool header = false}) {
    final ref = '${_col(c)}${r + 1}';
    if (!header && v.isNotEmpty && _number.hasMatch(v)) {
      return '<c r="$ref"><v>$v</v></c>';
    }
    final style = header ? ' s="1"' : '';
    if (v.isEmpty) return '<c r="$ref"$style/>';
    return '<c r="$ref"$style t="inlineStr"><is><t xml:space="preserve">'
        '${_esc(v)}</t></is></c>';
  }

  static Uint8List build(ResultsTable t, {String sheetName = 'Natijalar'}) {
    final widths = <int>[
      for (var c = 0; c < t.columns; c++)
        [
          t.header[c].length,
          for (final r in t.rows) r[c].length,
        ].reduce((a, b) => a > b ? a : b).clamp(8, 48),
    ];
    final b = StringBuffer(
      '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">'
      '<sheetViews><sheetView workbookViewId="0">'
      '<pane ySplit="1" topLeftCell="A2" activePane="bottomLeft" state="frozen"/>'
      '</sheetView></sheetViews><cols>',
    );
    for (var c = 0; c < widths.length; c++) {
      b.write(
        '<col min="${c + 1}" max="${c + 1}" width="${widths[c] + 2}" customWidth="1"/>',
      );
    }
    b.write('</cols><sheetData>');
    b.write('<row r="1">');
    for (var c = 0; c < t.columns; c++) {
      b.write(_cell(0, c, t.header[c], header: true));
    }
    b.write('</row>');
    for (var r = 0; r < t.rows.length; r++) {
      b.write('<row r="${r + 2}">');
      for (var c = 0; c < t.columns; c++) {
        b.write(_cell(r + 1, c, t.rows[r][c]));
      }
      b.write('</row>');
    }
    b.write('</sheetData></worksheet>');

    final a = Archive()
      ..addFile(
        ArchiveFile.string(
          '[Content_Types].xml',
          '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
              '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
              '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
              '<Default Extension="xml" ContentType="application/xml"/>'
              '<Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>'
              '<Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>'
              '<Override PartName="/xl/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"/>'
              '</Types>',
        ),
      )
      ..addFile(
        ArchiveFile.string(
          '_rels/.rels',
          '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
              '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
              '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>'
              '</Relationships>',
        ),
      )
      ..addFile(
        ArchiveFile.string(
          'xl/workbook.xml',
          '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
              '<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" '
              'xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">'
              '<sheets><sheet name="${_esc(sheetName.length > 31 ? sheetName.substring(0, 31) : sheetName)}" sheetId="1" r:id="rId1"/></sheets>'
              '</workbook>',
        ),
      )
      ..addFile(
        ArchiveFile.string(
          'xl/_rels/workbook.xml.rels',
          '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
              '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
              '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/>'
              '<Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>'
              '</Relationships>',
        ),
      )
      ..addFile(
        ArchiveFile.string(
          'xl/styles.xml',
          '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
              '<styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">'
              '<fonts count="2"><font><sz val="11"/><name val="Calibri"/></font>'
              '<font><b/><sz val="11"/><color rgb="FFFFFFFF"/><name val="Calibri"/></font></fonts>'
              '<fills count="3"><fill><patternFill patternType="none"/></fill>'
              '<fill><patternFill patternType="gray125"/></fill>'
              '<fill><patternFill patternType="solid"><fgColor rgb="FF0B1F3A"/><bgColor indexed="64"/></patternFill></fill></fills>'
              '<borders count="1"><border><left/><right/><top/><bottom/><diagonal/></border></borders>'
              '<cellStyleXfs count="1"><xf numFmtId="0" fontId="0" fillId="0" borderId="0"/></cellStyleXfs>'
              '<cellXfs count="2"><xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0"/>'
              '<xf numFmtId="0" fontId="1" fillId="2" borderId="0" xfId="0" applyFont="1" applyFill="1"/></cellXfs>'
              '</styleSheet>',
        ),
      )
      ..addFile(
        ArchiveFile.bytes(
          'xl/worksheets/sheet1.xml',
          utf8.encode(b.toString()),
        ),
      );
    return ZipEncoder().encodeBytes(a);
  }
}
