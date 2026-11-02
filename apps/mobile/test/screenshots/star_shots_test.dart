@Tags(['screenshots'])
library;

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/core/design/theme.dart';
import 'package:forensic_expert/core/l10n/generated/app_localizations.dart';
import 'package:forensic_expert/domain/catalog/catalog.dart';
import 'package:forensic_expert/features/catalog/presentation/catalog_screen.dart';

import 'package:forensic_expert/core/settings/app_settings.dart';

import '../helpers/pump_app.dart';

/// SPE kartochkasi — haqiqiy shriftlar, PNG.
/// flutter test --tags screenshots test/screenshots/spe_shots_test.dart
Future<void> _loadFonts() async {
  Future<void> load(String family, List<String> files) async {
    final loader = FontLoader(family);
    for (final f in files) {
      final bytes = File(f).readAsBytesSync();
      loader.addFont(Future.value(ByteData.view(bytes.buffer)));
    }
    await loader.load();
  }

  await load('SourceSerif4', [
    'assets/fonts/source_serif_4/SourceSerif4-Regular.ttf',
    'assets/fonts/source_serif_4/SourceSerif4-SemiBold.ttf',
    'assets/fonts/source_serif_4/SourceSerif4-Bold.ttf',
  ]);
  await load('Inter', [
    'assets/fonts/inter/Inter-Regular.ttf',
    'assets/fonts/inter/Inter-Medium.ttf',
    'assets/fonts/inter/Inter-SemiBold.ttf',
    'assets/fonts/inter/Inter-Bold.ttf',
  ]);
  final flutterRoot = Platform.environment['FLUTTER_ROOT'] ?? '/opt/flutter';
  await load('MaterialIcons', [
    '$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  ]);
}

void main() {
  setUpAll(_loadFonts);
  final dir = Platform.environment['ASSESS_SHOT_DIR'] ?? '/tmp/star_shots';
  testWidgets('stars', (tester) async {
    CatalogEntry e(String id, int stars, bool starred) => CatalogEntry(
      id: id,
      kind: CatalogKind.teacher,
      name: id,
      stars: stars,
      starred: starred,
    );
    await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz', mode: UserMode.professional),
      size: const Size(390, 300),
      pixelRatio: 2,
      overrides: const [],
    );
    final ctx = tester.element(find.byType(MaterialApp));
    expect(ctx, isNotNull);
    final entries = [
      e('Bosilgan (ustoz)', 2, true),
      e('Bosilmagan (mutaxassis)', 1, false),
    ];
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('uz'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: FeThemeBuilder.light(),
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: RepaintBoundary(
              child: Column(
                children: [
                  for (final x in entries)
                    Row(
                      children: [
                        Expanded(child: Text(x.name)),
                        CatalogStarButton(entry: x, onTap: () {}),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byType(RepaintBoundary).first,
    );
    await tester.runAsync(() async {
      final img = await boundary.toImage(pixelRatio: 2);
      final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
      Directory(dir).createSync(recursive: true);
      File('$dir/stars.png').writeAsBytesSync(bytes!.buffer.asUint8List());
    });
  });
}
