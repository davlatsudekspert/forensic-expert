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
import 'package:forensic_expert/domain/lessons/lesson_models.dart';
import 'package:forensic_expert/features/lessons/presentation/lesson_image_view.dart';
import 'package:forensic_expert/features/lessons/presentation/lesson_slide_view.dart';

/// «Darslar» rasmli slayd skrinshotlari (proyektor 1920×1080, telefon 390×844/320×568; to‘liq ekran, xato holat). Haqiqiy shriftlar.
/// `LESSON_IMAGE_SHOT_DIR` papkasiga PNG.
///   flutter test --tags screenshots --run-skipped \
///     test/screenshots/lesson_image_shots_test.dart
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
  final l = lookupAppLocalizations(const Locale('uz'));
  final dir =
      Platform.environment['LESSON_IMAGE_SHOT_DIR'] ??
      '/tmp/claude-0/-home-user-forensic-expert/'
          '06d2c950-1e58-56ea-9182-1c3fb48b561e/scratchpad/image_slide_shots';

  Future<void> shot(
    WidgetTester tester,
    LessonPage page,
    Size size,
    String name, {
    required bool projector,
    Brightness mode = Brightness.light,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final key = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: mode == Brightness.dark
            ? FeThemeBuilder.dark()
            : FeThemeBuilder.light(),
        locale: const Locale('uz'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: RepaintBoundary(
          key: key,
          child: Scaffold(
            body: LessonSlideView(
              page: page,
              projector: projector,
              counter: projector ? '5 / 12' : null,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump();
    expect(tester.takeException(), isNull, reason: name);
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(key),
    );
    await tester.runAsync(() async {
      final img = await boundary.toImage(pixelRatio: 1);
      final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
      Directory(dir).createSync(recursive: true);
      File('$dir/$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
    });
  }

  const host = 'abc.supabase.co';
  late Uint8List png;
  late LessonPage page;

  Future<Uint8List> drawScheme() async {
    final rec = ui.PictureRecorder();
    final c = Canvas(rec);
    c.drawRect(
      const Rect.fromLTWH(0, 0, 900, 600),
      Paint()..color = const Color(0xFFF1F5F9),
    );
    final box = Paint()..color = const Color(0xFF3B6FB6);
    final line = Paint()
      ..color = const Color(0xFF1F2937)
      ..strokeWidth = 6;
    for (var i = 0; i < 3; i++) {
      c.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(60 + i * 290.0, 240, 220, 120),
          const Radius.circular(16),
        ),
        box,
      );
      if (i < 2) {
        c.drawLine(
          Offset(280 + i * 290.0, 300),
          Offset(350 + i * 290.0, 300),
          line,
        );
      }
    }
    final img = await rec.endRecording().toImage(900, 600);
    return (await img.toByteData(format: ui.ImageByteFormat.png))!.buffer
        .asUint8List();
  }

  setUpAll(() async {
    png = (await drawScheme());
  });
  LessonDeck mkDeck() => LessonDeck.fromJson({
    'title': 'Apparatlar',
    'deck_id': 'x',
    'deck': {
      'slides': [
        {
          'title': 'Gaz xromatograf-mass-spektrometr (GC-MS)',
          'bullets': [
            {
              'text':
                  'Namuna injektorda bug‘lanadi va tashuvchi gaz bilan '
                  'kapillyar ustunga o‘tadi.',
              'source': {
                'author': 'Muallif A.',
                'title': 'Qo‘llanma',
                'page': '41',
              },
            },
            {
              'text':
                  'Komponentlar ustunda ajraladi, mass-detektor ularni '
                  'ion massasi bo‘yicha qayd etadi.',
              'source': {
                'author': 'Muallif A.',
                'title': 'Qo‘llanma',
                'page': '42',
              },
            },
            {'text': 'Natija — xromatogramma va mass-spektr.'},
          ],
          'image': {
            'url':
                'https://$host/storage/v1/object/public/lesson-images/gcms.png',
            'caption': 'GC-MS blok-sxemasi: injektor, ustun, detektor',
            'credit': 'Muallif: A. Aliyev, CC BY-SA 4.0, Wikimedia Commons',
            'kind': 'scheme',
          },
        },
      ],
    },
  });

  setUp(() {
    LessonImage.backendHostOverride = host;
    lessonImageProviderOverride = (_) => MemoryImage(png);
    page = buildLessonPages(mkDeck(), l).first;
    expect(page.image, isNotNull);
  });
  tearDown(() {
    LessonImage.backendHostOverride = null;
    lessonImageProviderOverride = null;
  });

  testWidgets('rasmli slayd', (tester) async {
    await shot(
      tester,
      page,
      const Size(1920, 1080),
      'proj_1920x1080',
      projector: true,
    );
    await shot(
      tester,
      page,
      const Size(390, 844),
      'phone_390x844',
      projector: false,
    );
    await shot(
      tester,
      page,
      const Size(390, 844),
      'phone_390x844_dark',
      projector: false,
      mode: Brightness.dark,
    );
    await shot(
      tester,
      page,
      const Size(320, 568),
      'phone_320x568',
      projector: false,
    );
  });

  testWidgets('xato holat', (tester) async {
    lessonImageProviderOverride = (_) =>
        MemoryImage(Uint8List.fromList([1, 2]));
    await shot(
      tester,
      page,
      const Size(1920, 1080),
      'failed_proj',
      projector: true,
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump();
    await tester.pump();
    await shot(
      tester,
      page,
      const Size(390, 844),
      'failed_phone',
      projector: false,
    );
  });

  testWidgets('to‘liq ekran', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final key = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: MaterialApp(
          theme: FeThemeBuilder.light(),
          locale: const Locale('uz'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: LessonSlideView(page: page)),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('lesson.image.tap')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(key),
    );
    await tester.runAsync(() async {
      final img = await boundary.toImage(pixelRatio: 1);
      final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
      Directory(dir).createSync(recursive: true);
      File('$dir/fullscreen_phone.png')
          .writeAsBytesSync(bytes!.buffer.asUint8List());
    });
  });
}
