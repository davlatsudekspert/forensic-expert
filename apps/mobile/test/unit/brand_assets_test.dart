import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/core/design/theme.dart';
import 'package:forensic_expert/core/l10n/generated/app_localizations.dart';
import 'package:forensic_expert/core/widgets/brand_mark.dart';

/// Premium logotip assetlari (`design/brand/tools/generate_brand.py`):
/// yagona manba, eski «Shield of Evidence» vektor qoldiqlarisiz, iOS
/// ikonlarida alpha yo‘q, Android adaptive + themed ikon, light/dark splash,
/// ilova ichida @1x/@2x/@3x kvadrat emblemalar.
void main() {
  Uint8List bytes(File f) => f.readAsBytesSync();
  int pngColorType(File f) => bytes(f)[25];
  (int, int) pngSize(File f) {
    final b = ByteData.sublistView(bytes(f));
    return (b.getUint32(16), b.getUint32(20));
  }

  test('manba logotip repoda (design/brand/source)', () {
    expect(
      File('../../design/brand/source/logo_original.webp').existsSync(),
      isTrue,
    );
  });

  test('iOS AppIcon — barcha o‘lchamlar, alpha kanalsiz (RGB)', () {
    final dir = Directory('ios/Runner/Assets.xcassets/AppIcon.appiconset');
    final pngs = dir.listSync().whereType<File>().where(
      (f) => f.path.endsWith('.png'),
    );
    expect(pngs.length, greaterThanOrEqualTo(15));
    for (final f in pngs) {
      expect(pngColorType(f), 2, reason: '${f.path} must be RGB (no alpha)');
      final (w, h) = pngSize(f);
      expect(w, h, reason: '${f.path} kvadrat');
    }
    final (w, _) = pngSize(
      File(
        'ios/Runner/Assets.xcassets/AppIcon.appiconset/'
        'Icon-App-1024x1024@1x.png',
      ),
    );
    expect(w, 1024);
  });

  test('iOS splash: light + dark appearance', () {
    final json = File(
      'ios/Runner/Assets.xcassets/LaunchImage.imageset/Contents.json',
    ).readAsStringSync();
    expect(json, contains('LaunchImageDark@3x.png'));
    expect(json, contains('"dark"'));
    expect(
      File('ios/Runner/Assets.xcassets/LaunchBackground.colorset/Contents.json')
          .existsSync(),
      isTrue,
    );
    expect(
      File('ios/Runner/Base.lproj/LaunchScreen.storyboard').readAsStringSync(),
      contains('name="LaunchBackground"'),
    );
  });

  test('Android: legacy, adaptive fg/bg, monochrome, light/dark splash', () {
    for (final d in ['mdpi', 'hdpi', 'xhdpi', 'xxhdpi', 'xxxhdpi']) {
      for (final n in [
        'ic_launcher',
        'ic_launcher_foreground',
        'ic_launcher_background',
        'ic_launcher_monochrome',
      ]) {
        expect(
          File('android/app/src/main/res/mipmap-$d/$n.png').existsSync(),
          isTrue,
          reason: '$d/$n',
        );
      }
      for (final dir in ['drawable-$d', 'drawable-night-$d']) {
        expect(
          File('android/app/src/main/res/$dir/launch_mark.png').existsSync(),
          isTrue,
          reason: '$dir/launch_mark',
        );
      }
    }
    final adaptive = File(
      'android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml',
    ).readAsStringSync();
    expect(adaptive, contains('<monochrome'));
    expect(adaptive, contains('@mipmap/ic_launcher_background'));
    // Eski (nodpi, piksel o‘lchamida chiziladigan) splash qolmagan.
    expect(
      File('android/app/src/main/res/drawable-nodpi/launch_mark.png')
          .existsSync(),
      isFalse,
    );
  });

  test('ilova emblemalari: @1x/@2x/@3x, kvadrat, shaffof', () {
    for (final a in BrandMark.allAssets) {
      final base = File(a);
      expect(base.existsSync(), isTrue, reason: a);
      final (w1, h1) = pngSize(base);
      expect(w1, h1, reason: '$a kvadrat (cho‘zilmaydi)');
      expect(pngColorType(base), 6, reason: '$a RGBA');
      final name = a.split('/').last;
      for (final (dir, k) in [('2.0x', 2), ('3.0x', 3)]) {
        final f = File('assets/brand/$dir/$name');
        expect(f.existsSync(), isTrue, reason: f.path);
        expect(pngSize(f).$1, w1 * k, reason: f.path);
      }
    }
  });

  test('eski vektor brend qoldiqlari yo‘q', () {
    expect(Directory('../../design/brand/svg').existsSync(), isFalse);
    expect(File('lib/core/widgets/brand_emblem.g.dart').existsSync(), isFalse);
  });

  test('optik darajalar: kichik o‘lchamda soddalashtirilgan variant', () {
    expect(BrandMark.tierFor(16), BrandTier.small);
    expect(BrandMark.tierFor(44), BrandTier.small);
    expect(BrandMark.tierFor(56), BrandTier.small);
    expect(BrandMark.tierFor(72), BrandTier.full);
    expect(BrandMark.tierFor(128), BrandTier.full);
    expect(
      BrandMark.assetFor(BrandTier.small, dark: true),
      'assets/brand/emblem_small_dark.png',
    );
  });

  testWidgets('BrandMark: kvadrat, ekran o‘quvchisidan yashirilgan', (
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
      expect(tester.getSize(find.byType(BrandMark)), Size.square(size));
      final img = tester.widget<Image>(find.byType(Image));
      expect(img.fit, BoxFit.contain);
      expect(img.excludeFromSemantics, isTrue);
    }
  });

  testWidgets('BrandLockup: mavzuga mos variant, 320 dp da overflow yo‘q', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    for (final (theme, dark) in [
      (FeThemeBuilder.light(), false),
      (FeThemeBuilder.dark(), true),
    ]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          locale: const Locale('uz'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: Center(child: BrandLockup())),
        ),
      );
      // Mavzu almashinuvi animatsiyali (AnimatedTheme).
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final img = tester.widget<Image>(find.byType(Image));
      expect(
        (img.image as AssetImage).assetName,
        BrandMark.assetFor(BrandTier.full, dark: dark),
      );
      expect(find.text('FORENSIC'), findsOneWidget);
      expect(find.text('EXPERT'), findsOneWidget);
    }
  });
}
