import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/core/design/theme.dart';
import 'package:forensic_expert/core/l10n/generated/app_localizations.dart';
import 'package:forensic_expert/data/lessons/fake_lessons_service.dart';
import 'package:forensic_expert/domain/lessons/lesson_models.dart';
import 'package:forensic_expert/features/lessons/presentation/lesson_canvas.dart';
import 'package:forensic_expert/features/lessons/presentation/lesson_slide_view.dart';

import '../helpers/lesson_diagram_fixtures.dart';

/// v2 diagramma turlari: telefon (390×844, 320×568) va proyektor kanvasida
/// (1280×720, 1920×1080) chiziladi, overflow yo‘q, limitdagi eng uzun matn
/// kanvasga ≥ 24 px da sig‘adi.
Future<void> _loadFonts() async {
  Future<void> load(String family, List<String> files) async {
    final loader = FontLoader(family);
    for (final f in files) {
      final bytes = File(f).readAsBytesSync();
      loader.addFont(Future.value(ByteData.view(bytes.buffer)));
    }
    await loader.load();
  }

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
  // Haqiqiy shrift (Ahem emas): sig‘ish o‘lchovi real matn kengligida tekshiriladi.
  setUpAll(_loadFonts);
  final l = lookupAppLocalizations(const Locale('uz'));

  LessonDeck deckOf(Map<String, Object?> slide) => LessonDeck.fromJson({
    'title': 'Sinov',
    'deck_id': 'x',
    'deck': {
      'slides': [slide],
    },
  });

  Future<void> pump(
    WidgetTester tester,
    Size size,
    LessonPage page, {
    bool projector = false,
    double textScale = 1,
    Brightness mode = Brightness.light,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: mode == Brightness.dark
            ? FeThemeBuilder.dark()
            : FeThemeBuilder.light(),
        locale: const Locale('uz'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (c, child) => MediaQuery(
          data: MediaQuery.of(c)
              .copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: Scaffold(
          body: LessonSlideView(
            page: page,
            projector: projector,
            counter: projector ? '1 / 1' : null,
          ),
        ),
      ),
    );
    await tester.pump();
  }

  final max = maxDiagrams();

  group('demo deck: har tur uchun slayd bor', () {
    test('sampleLessonDecks v2 turlarini o‘z ichiga oladi', () {
      final d = LessonDeck.fromJson(sampleLessonDecks['demo-toks']!);
      final kinds = {for (final s in d.slides) s.diagram?.kind};
      for (final k in LessonDiagramKind.values) {
        expect(kinds, contains(k), reason: k.name);
      }
    });
  });

  for (final k in diagramKinds) {
    group(k, () {
      for (final size in const [Size(390, 844), Size(320, 568)]) {
        for (final scale in const [1.0, 1.4]) {
          testWidgets('telefon ${size.width.toInt()}x${size.height.toInt()} '
              'x$scale: chiziladi, overflow yo‘q, kerak bo‘lsa siljiydi', (
            tester,
          ) async {
            final d = deckOf(slideWith('Sarlavha', max[k]!));
            final pages = buildLessonPages(d, l);
            await pump(
              tester,
              size,
              pages.firstWhere((p) => p.diagram != null),
              textScale: scale,
            );
            expect(tester.takeException(), isNull);
            expect(find.byKey(Key('lesson.diagram.$k')), findsOneWidget);
            expect(find.byType(SingleChildScrollView), findsWidgets);
            // Diagramma gorizontal sig‘adi.
            final r = tester.getRect(find.byKey(Key('lesson.diagram.$k')));
            expect(r.right, lessThanOrEqualTo(size.width + 0.5));
            // Pastigacha siljitib ham xato yo‘q.
            await tester.drag(
              find.byType(SingleChildScrollView).first,
              const Offset(0, -3000),
            );
            await tester.pump();
            expect(tester.takeException(), isNull);
          });
        }
      }

      testWidgets('telefon: qorong‘i rejim', (tester) async {
        final d = deckOf(slideWith('Sarlavha', max[k]!));
        await pump(
          tester,
          const Size(390, 844),
          buildLessonPages(d, l).firstWhere((p) => p.diagram != null),
          mode: Brightness.dark,
        );
        expect(tester.takeException(), isNull);
        expect(find.byKey(Key('lesson.diagram.$k')), findsOneWidget);
      });

      for (final size in const [
        Size(1280, 720),
        Size(1920, 1080),
        Size(844, 390),
      ]) {
        for (final withBullets in [true, false]) {
          testWidgets('kanvas ${size.width.toInt()}x${size.height.toInt()} '
              '${withBullets ? "bandlar bilan" : "faqat diagramma"}: '
              'sig‘adi, ≥ 24 px', (tester) async {
            final slide = withBullets
                ? slideWith('Sarlavha', max[k]!)
                : {'title': 'Sarlavha', 'diagram': max[k]};
            final pages = buildLessonPages(deckOf(slide), l);
            for (final page in pages) {
              await pump(tester, size, page, projector: true);
              expect(tester.takeException(), isNull, reason: page.title);
              expect(find.byType(SingleChildScrollView), findsNothing);
              final content = tester.widget<LessonCanvasContent>(
                find.byType(LessonCanvasContent),
              );
              expect(
                content.body,
                greaterThanOrEqualTo(LessonCanvasMetrics.minBody),
                reason: '$k: ${page.title}',
              );
              expect(
                tester.getSize(find.byType(LessonCanvasContent)).height,
                lessThanOrEqualTo(LessonCanvasMetrics.innerH + 0.5),
                reason: '$k kichraytirilmay sig‘adi',
              );
              if (page.diagram != null) {
                expect(find.byKey(Key('lesson.diagram.$k')), findsOneWidget);
              }
            }
          });
        }
      }
    });
  }

  testWidgets('buzuq diagramma: slayd diagrammasiz chiziladi', (tester) async {
    final d = deckOf(
      slideWith('Sarlavha', {
        'kind': 'cycle',
        'nodes': ['faqat bitta'],
      }),
    );
    final page = buildLessonPages(d, l).first;
    expect(page.diagram, isNull);
    await pump(tester, const Size(390, 844), page);
    expect(tester.takeException(), isNull);
    expect(find.text('Sarlavha'), findsOneWidget);
  });

  testWidgets('demo-toks barcha sahifalari (v2) kanvasda va telefonda', (
    tester,
  ) async {
    final pages = buildLessonPages(
      LessonDeck.fromJson(sampleLessonDecks['demo-toks']!),
      l,
    );
    for (final page in pages) {
      await pump(tester, const Size(1280, 720), page, projector: true);
      expect(tester.takeException(), isNull, reason: page.title);
      await pump(tester, const Size(390, 844), page);
      expect(tester.takeException(), isNull, reason: page.title);
    }
  });
}
