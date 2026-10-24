import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/core/design/theme.dart';
import 'package:forensic_expert/core/l10n/generated/app_localizations.dart';
import 'package:forensic_expert/domain/lessons/lesson_models.dart';
import 'package:forensic_expert/features/lessons/presentation/lesson_canvas.dart';
import 'package:forensic_expert/features/lessons/presentation/lesson_image_view.dart';
import 'package:forensic_expert/features/lessons/presentation/lesson_slide_view.dart';

/// Slayd rasmi: telefon/proyektor, yuklanmagan holat, to‘liq ekran,
/// ishonchli host, rasm + diagramma ajratilishi.
void main() {
  final l = lookupAppLocalizations(const Locale('uz'));
  const host = 'abc.supabase.co';
  const url = 'https://$host/storage/v1/object/public/lesson-images/gc.png';
  final png1x1 = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA'
    '60e6kgAAAABJRU5ErkJggg==',
  );

  setUp(() {
    LessonImage.backendHostOverride = host;
    lessonImageProviderOverride = (_) => MemoryImage(png1x1);
  });
  tearDown(() {
    LessonImage.backendHostOverride = null;
    lessonImageProviderOverride = null;
  });

  Map<String, Object?> imageJson() => {
    'url': url,
    'caption': 'GC-MS qurilmasi umumiy ko‘rinishi',
    'credit': 'Muallif: A. Aliyev, CC BY-SA 4.0, Wikimedia Commons',
    'kind': 'photo',
  };

  LessonDeck deck(List<Map<String, Object?>> slides) => LessonDeck.fromJson({
    'title': 'Sinov',
    'deck_id': 'x',
    'deck': {'slides': slides},
  });

  Map<String, Object?> slide({bool diagram = false, int bullets = 2}) => {
    'title': 'GC-MS tuzilishi',
    'bullets': [
      for (var i = 0; i < bullets; i++)
        {
          'text': 'Gaz xromatografi namunani ustunda ajratadi ($i).',
          'source': {'author': 'A', 'page': '${i + 1}'},
        },
    ],
    'image': imageJson(),
    if (diagram)
      'diagram': {
        'nodes': ['Namuna', 'Ustun', 'Detektor'],
      },
  };

  Future<void> pump(
    WidgetTester tester,
    LessonPage page, {
    required bool projector,
    Size size = const Size(390, 844),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: FeThemeBuilder.light(),
        locale: const Locale('uz'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: LessonSlideView(
            page: page,
            projector: projector,
            counter: projector ? '1 / 3' : null,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  testWidgets('telefon: rasm bandlar ostida, caption va credit bor', (
    tester,
  ) async {
    final page = buildLessonPages(deck([slide()]), l).first;
    expect(page.image, isNotNull);
    await pump(tester, page, projector: false);
    expect(tester.takeException(), isNull);
    final pic = find.byKey(const Key('lesson.image.picture'));
    expect(pic, findsOneWidget);
    expect(find.byKey(const Key('lesson.image.caption')), findsOneWidget);
    expect(find.byKey(const Key('lesson.image.credit')), findsOneWidget);
    expect(find.textContaining('CC BY-SA 4.0'), findsOneWidget);
    final lastBullet = tester.getRect(find.textContaining('(1)'));
    expect(tester.getRect(pic).top, greaterThan(lastBullet.bottom));
    expect(find.byKey(const Key('lesson.image.failed')), findsNothing);
  });

  for (final size in const [
    Size(1280, 720),
    Size(1920, 1080),
    Size(844, 390),
  ]) {
    testWidgets('proyektor: rasm bandlarning o‘ng tomonida, sig‘adi '
        '(${size.width.toInt()}x${size.height.toInt()})', (tester) async {
      final pages = buildLessonPages(deck([slide(bullets: 4)]), l);
      expect(pages.where((p) => p.image != null), hasLength(1));
      final page = pages.firstWhere((p) => p.image != null);
      await pump(tester, page, projector: true, size: size);
      expect(tester.takeException(), isNull);
      final content = tester.widget<LessonCanvasContent>(
        find.byType(LessonCanvasContent),
      );
      expect(content.body, greaterThanOrEqualTo(LessonCanvasMetrics.minBody));
      expect(
        tester.getSize(find.byType(LessonCanvasContent)).height,
        lessThanOrEqualTo(LessonCanvasMetrics.innerH + 0.5),
      );
      final pic = tester.getRect(find.byKey(const Key('lesson.image.picture')));
      final b = tester.getRect(find.textContaining('(0)'));
      expect(pic.left, greaterThan(b.right - 1));
      expect(find.byKey(const Key('lesson.image.caption')), findsOneWidget);
      expect(find.byKey(const Key('lesson.image.credit')), findsOneWidget);
    });
  }

  testWidgets('yuklanmagan rasm: joy egallovchi, crash yo‘q', (tester) async {
    lessonImageProviderOverride = (_) =>
        MemoryImage(Uint8List.fromList([1, 2, 3, 4]));
    final page = buildLessonPages(deck([slide()]), l).first;
    await pump(tester, page, projector: false);
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump();
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('lesson.image.failed')), findsOneWidget);
    expect(find.text('Rasm yuklanmadi'), findsOneWidget);
    // Caption/credit saqlanadi.
    expect(find.byKey(const Key('lesson.image.caption')), findsOneWidget);
  });

  testWidgets('proyektorda xato holat ham crashsiz', (tester) async {
    lessonImageProviderOverride = (_) =>
        MemoryImage(Uint8List.fromList([9, 9, 9]));
    final page = buildLessonPages(deck([slide()]), l).first;
    await pump(tester, page, projector: true, size: const Size(1280, 720));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump();
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('Rasm yuklanmadi'), findsOneWidget);
  });

  for (final projector in [false, true]) {
    testWidgets('bosilganda to‘liq ekran (zoom) ochiladi va yopiladi '
        '(${projector ? 'proyektor' : 'telefon'})', (tester) async {
      final page = buildLessonPages(deck([slide()]), l).first;
      await pump(
        tester,
        page,
        projector: projector,
        size: projector ? const Size(1280, 720) : const Size(390, 844),
      );
      await tester.tap(find.byKey(const Key('lesson.image.tap')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byKey(const Key('lesson.image.fullscreen')), findsOneWidget);
      expect(find.byKey(const Key('lesson.image.viewer')), findsOneWidget);
      expect(find.byType(InteractiveViewer), findsOneWidget);
      await tester.tap(find.byKey(const Key('lesson.image.close')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byKey(const Key('lesson.image.fullscreen')), findsNothing);
    });
  }

  test('rasm + diagramma — alohida sahifalar (rasm bandlar bilan)', () {
    final pages = buildLessonPages(deck([slide(diagram: true)]), l);
    final withImage = pages.where((p) => p.image != null).toList();
    expect(withImage, hasLength(1));
    expect(withImage.first.diagram, isNull);
    expect(pages.where((p) => p.diagram != null), hasLength(1));
    expect(pages.where((p) => p.diagram != null).first.image, isNull);
    // Bandlar tushib qolmaydi.
    expect(pages.fold<int>(0, (a, p) => a + p.bullets.length), 2);
  });

  test('uzun bandlar + rasm: har sahifa sig‘adi, rasm bitta', () {
    final pages = buildLessonPages(deck([slide(bullets: 12)]), l);
    expect(pages.length, greaterThan(1));
    expect(pages.where((p) => p.image != null), hasLength(1));
    final m = LessonCanvasMeasurer();
    for (final p in pages) {
      expect(
        LessonCanvasLayout.fitsAt(p, LessonCanvasMetrics.minBody, '', m),
        isTrue,
        reason: p.title,
      );
    }
  });

  test('ishonchsiz host — rasm sahifaga kirmaydi', () {
    const evil = LessonSlide(
      title: 'X',
      bullets: [LessonBullet(text: 'matn')],
      image: LessonImage(url: 'https://evil.example.com/a.png'),
    );
    const http = LessonSlide(
      title: 'Y',
      bullets: [LessonBullet(text: 'matn')],
      image: LessonImage(url: 'http://$host/a.png'),
    );
    const d = LessonDeck(
      topicId: 't',
      title: 't',
      course: '',
      deckId: 'd',
      sourceLang: 'uz',
      slides: [evil, http],
    );
    final pages = buildLessonPages(d, l);
    expect(pages.where((p) => p.image != null), isEmpty);
  });
}
