import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/class_quiz.dart';
import 'package:forensic_expert/core/l10n/generated/app_localizations.dart';
import 'package:forensic_expert/features/results_export/presentation/results_export_sheet.dart';

class _Share implements ClassFileShare {
  final csv = <String>[];
  final files = <({String name, String mime, int size})>[];

  @override
  Future<void> shareCsv({
    required String fileName,
    required String content,
    String? subject,
  }) async => csv.add(fileName);

  @override
  Future<void> shareFile({
    required String fileName,
    required Uint8List bytes,
    required String mimeType,
    String? subject,
  }) async => files.add((name: fileName, mime: mimeType, size: bytes.length));
}

void main() {
  Future<_Share> open(WidgetTester tester, String choice) async {
    final share = _Share();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [classFileShareProvider.overrideWithValue(share)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('uz'),
          home: Consumer(
            builder: (c, ref, _) => Scaffold(
              body: TextButton(
                key: const Key('open'),
                onPressed: () => showResultsExportSheet(
                  c,
                  ref,
                  csvFileName: 'natija_1.csv',
                  csv: 'Ism,Ball\r\nAli,80.0\r\n',
                  title: 'Natijalar',
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('open')));
    await tester.pumpAndSettle();
    expect(find.text('Excel (.xlsx)'), findsOneWidget);
    expect(find.text('PDF'), findsOneWidget);
    expect(find.text('CSV'), findsOneWidget);
    await tester.tap(find.byKey(Key('results.export.$choice')));
    await tester.pumpAndSettle();
    return share;
  }

  testWidgets('Excel tanlansa .xlsx ulashiladi', (tester) async {
    final s = await open(tester, 'xlsx');
    expect(s.files.single.name, 'natija_1.xlsx');
    expect(s.files.single.mime, contains('spreadsheetml'));
    expect(s.files.single.size, greaterThan(500));
    expect(s.csv, isEmpty);
  });

  testWidgets('PDF tanlansa .pdf ulashiladi', (tester) async {
    final s = await open(tester, 'pdf');
    expect(s.files.single.name, 'natija_1.pdf');
    expect(s.files.single.mime, 'application/pdf');
  });

  testWidgets('CSV tanlansa avvalgidek CSV ulashiladi', (tester) async {
    final s = await open(tester, 'csv');
    expect(s.csv.single, 'natija_1.csv');
    expect(s.files, isEmpty);
  });
}
