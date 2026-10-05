import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/core/design/theme.dart';
import 'package:forensic_expert/core/widgets/brand_mark.dart';

/// «Shield of Evidence» brend assetlari: yagona generatordan, eski belgi
/// qoldiqlarisiz, iOS ikonlarida alpha yo‘q, Android themed ikon bor.
void main() {
  int pngColorType(File f) => f.readAsBytesSync()[25];

  test('iOS AppIcon — barcha o‘lchamlar, alpha kanalsiz (RGB)', () {
    final dir = Directory('ios/Runner/Assets.xcassets/AppIcon.appiconset');
    final pngs = dir.listSync().whereType<File>().where(
      (f) => f.path.endsWith('.png'),
    );
    expect(pngs.length, greaterThanOrEqualTo(15));
    for (final f in pngs) {
      expect(pngColorType(f), 2, reason: '${f.path} must be RGB (no alpha)');
    }
  });

  test('Android: legacy, adaptive foreground, monochrome, splash', () {
    for (final d in ['mdpi', 'hdpi', 'xhdpi', 'xxhdpi', 'xxxhdpi']) {
      for (final n in [
        'ic_launcher',
        'ic_launcher_foreground',
        'ic_launcher_monochrome',
      ]) {
        expect(
          File('android/app/src/main/res/mipmap-$d/$n.png').existsSync(),
          isTrue,
          reason: '$d/$n',
        );
      }
    }
    final adaptive = File(
      'android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml',
    ).readAsStringSync();
    expect(adaptive, contains('<monochrome'));
    expect(
      File('android/app/src/main/res/drawable-nodpi/launch_mark.png')
          .existsSync(),
      isTrue,
    );
  });

  test('brend SVG manbalari: tashqi havola/rastr yo‘q, eski belgi yo‘q', () {
    final dir = Directory('../../design/brand/svg');
    final svgs = dir.listSync().whereType<File>().toList();
    expect(svgs.length, greaterThanOrEqualTo(20));
    for (final f in svgs) {
      final s = f.readAsStringSync();
      expect(s, isNot(contains('<image')), reason: f.path);
      expect(s, isNot(contains('href="http')), reason: f.path);
    }
    final names = svgs.map((f) => f.uri.pathSegments.last).toSet();
    for (final n in [
      'emblem-full-light.svg',
      'emblem-full-dark.svg',
      'emblem-full-mono-black.svg',
      'emblem-small-light.svg',
      'app-icon-dark.svg',
      'logo-horizontal-light.svg',
      'logo-stacked-dark.svg',
      'splash-mark.svg',
    ]) {
      expect(names, contains(n));
    }
    expect(File('lib/core/widgets/brand_mark_r2.g.dart').existsSync(), isFalse);
  });

  test('optik darajalar: kichik o‘lchamda kamroq detal', () {
    expect(BrandMark.tierFor(16), BrandTier.small);
    expect(BrandMark.tierFor(40), BrandTier.small);
    expect(BrandMark.tierFor(48), BrandTier.icon);
    expect(BrandMark.tierFor(128), BrandTier.full);
    expect(
      BrandEmblemPainter.elementCount(BrandTier.small),
      lessThan(BrandEmblemPainter.elementCount(BrandTier.icon)),
    );
    expect(
      BrandEmblemPainter.elementCount(BrandTier.icon),
      lessThan(BrandEmblemPainter.elementCount(BrandTier.full)),
    );
  });

  testWidgets('BrandMark ekran o‘quvchisidan yashirilgan, xatosiz chiziladi', (
    tester,
  ) async {
    for (final size in [16.0, 32.0, 72.0, 160.0]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: FeThemeBuilder.light(),
          home: Center(child: BrandMark(size: size)),
        ),
      );
      expect(tester.takeException(), isNull);
    }
  });
}
