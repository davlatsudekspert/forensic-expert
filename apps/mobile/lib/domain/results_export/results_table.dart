/// Natijalar jadvali — CSV (mavjud eksport) dan Excel/PDF uchun umumiy shakl.
///
/// Ma’lumot manbasi o‘zgarmaydi: har eksport avval CSV yig‘adi (formula
/// in’yeksiyasidan himoya `ClassResultsCsv.cell` da), keyin shu jadvalga
/// o‘tkaziladi. Hech narsa hisoblanmaydi yoki o‘zgartirilmaydi.
library;

class ResultsTable {
  const ResultsTable({required this.header, required this.rows});

  final List<String> header;
  final List<List<String>> rows;

  int get columns => header.length;

  /// RFC 4180: qo‘shtirnoqli maydon, `""` — qo‘shtirnoq, ichida vergul/qator.
  factory ResultsTable.fromCsv(String csv) {
    final records = <List<String>>[];
    var field = StringBuffer();
    var row = <String>[];
    var quoted = false;
    var i = 0;
    var any = false;
    void endField() {
      row.add(field.toString());
      field = StringBuffer();
    }

    void endRow() {
      endField();
      if (row.length > 1 || row.first.isNotEmpty) records.add(row);
      row = <String>[];
    }

    while (i < csv.length) {
      final c = csv[i];
      any = true;
      if (quoted) {
        if (c == '"') {
          if (i + 1 < csv.length && csv[i + 1] == '"') {
            field.write('"');
            i++;
          } else {
            quoted = false;
          }
        } else {
          field.write(c);
        }
      } else if (c == '"') {
        quoted = true;
      } else if (c == ',') {
        endField();
      } else if (c == '\r') {
        // CRLF: '\n' qatorni tugatadi.
      } else if (c == '\n') {
        endRow();
      } else {
        field.write(c);
      }
      i++;
    }
    if (any && (field.isNotEmpty || row.isNotEmpty)) endRow();
    if (records.isEmpty) return const ResultsTable(header: [], rows: []);
    final n = records.first.length;
    return ResultsTable(
      header: records.first,
      rows: [
        for (final r in records.skip(1))
          [for (var k = 0; k < n; k++) k < r.length ? r[k] : ''],
      ],
    );
  }

  /// «Faylga mos» nom: `.csv` → [ext].
  static String fileNameWithExt(String csvName, String ext) =>
      csvName.toLowerCase().endsWith('.csv')
      ? '${csvName.substring(0, csvName.length - 4)}.$ext'
      : '$csvName.$ext';
}
