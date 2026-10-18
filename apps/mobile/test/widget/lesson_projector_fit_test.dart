import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/core/design/theme.dart';
import 'package:forensic_expert/core/l10n/generated/app_localizations.dart';
import 'package:forensic_expert/domain/lessons/lesson_models.dart';
import 'package:forensic_expert/features/lessons/presentation/lesson_canvas.dart';
import 'package:forensic_expert/features/lessons/presentation/lesson_slide_view.dart';

/// Proyektor (monitor/TV/telefon gorizontal): har sahifa 1280×720 kanvasda,
/// ekranga mutanosib; uzun slayd davom sahifalariga bo‘linadi, asosiy matn
/// ≥ 24 dizayn px, hech narsa kesilmaydi va kichraytirilmaydi.
void main() {
  final l = lookupAppLocalizations(const Locale('uz'));

  final longSlide = {
    'title': 'Bioetikaning ta’riflari: tor va keng ma’no',
    'teacher_notes': 'ESLATMA',
    'bullets': [
      for (var i = 0; i < 9; i++)
        {
          'text':
              'Keng ma’noda u inson va barcha tirik organizmlarga oid '
              'ijtimoiy, ekologik, tibbiy muammolarni o‘rganadi ($i).',
          'source': {
            'author': i < 5 ? 'Muallif A.' : 'Muallif B.',
            'title': i < 5 ? 'Bioetika darslik' : 'Boshqa kitob',
            'page': '${10 + i}',
          },
        },
    ],
    'diagram': {
      'header': ['Belgi', 'Tavsif', 'Ahamiyati'],
      'rows': [
        for (var r = 0; r < 7; r++)
          [
            'Belgi $r',
            'Murdaning tashqi ko‘rigida aniqlanadigan o‘zgarish $r',
            'Sud-tibbiy xulosada qayd etiladi',
          ],
      ],
      'caption': 'Jadval izohi',
    },
  };
  final hugeBullet = List.generate(
    14,
    (i) =>
        'Bu juda uzun bandning $i-jumlasi: ekspert tekshiruv natijalarini '
        'hujjatlashtiradi va xulosaga kiritadi.',
  ).join(' ');

  LessonDeck deck() => LessonDeck.fromJson({
    'title': 'Sinov',
    'deck_id': 'x',
    'deck': {
      'slides': [
        {
          'title': 'Qisqa slayd',
          'bullets': [
            {
              'text': 'Bitta qisqa fikr',
              'source': {'author': 'A', 'page': '1'},
            },
          ],
        },
        longSlide,
        {
          'title': 'Bitta uzun band',
          'bullets': [
            {'text': hugeBullet, 'uncertain': true},
          ],
        },
        {
          'title': 'Oqim',
          'bullets': [
            {'text': 'Ketma-ketlik'},
          ],
          'diagram': {
            'nodes': ['Ko‘rik', 'Namuna olish', 'Tahlil', 'Xulosa'],
          },
        },
      ],
      'extras': [
        {
          'text': 'Qiziqarli fakt',
          'source': {'author': 'C', 'page': '5'},
        },
      ],
      'sources': [
        for (var i = 0; i < 14; i++)
          {
            'author': 'Muallif $i',
            'title': 'Sud tibbiyoti bo‘yicha qo‘llanma, $i-nashr',
            'year': '20${10 + i}',
          },
      ],
    },
  });

  group('bo‘lish (buildLessonPages)', () {
    test('qisqa slayd — bitta sahifa, qism belgisisiz', () {
      final pages = buildLessonPages(deck(), l);
      final first = pages.first;
      expect(first.title, 'Qisqa slayd');
      expect(first.parts, 1);
      expect(pages.where((p) => p.group == 0), hasLength(1));
    });

    test(
      'uzun slayd — «Sarlavha · 2/N» davom sahifalari, tartib saqlanadi',
      () {
        final pages = buildLessonPages(deck(), l);
        final g = pages.where((p) => p.group == 1).toList();
        expect(g.length, greaterThan(1));
        for (var i = 0; i < g.length; i++) {
          expect(g[i].part, i + 1);
          expect(g[i].parts, g.length);
          expect(
            g[i].title,
            'Bioetikaning ta’riflari: tor va keng ma’no · ${i + 1}/${g.length}',
          );
          expect(g[i].baseTitle, 'Bioetikaning ta’riflari: tor va keng ma’no');
          expect(g[i].notes, 'ESLATMA');
        }
        // Bandlar tushib qolmaydi va tartibi o‘zgarmaydi.
        final texts = [for (final p in g) ...p.bullets.map((b) => b.text)];
        expect(texts, hasLength(9));
        for (var i = 0; i < 9; i++) {
          expect(texts[i], endsWith('($i).'));
        }
        // Jadval qatorlari to‘liq, sarlavha qatori har qismda.
        final tables = [
          for (final p in g)
            if (p.diagram != null) p.diagram!,
        ];
        expect(tables, isNotEmpty);
        expect(tables.fold<int>(0, (a, t) => a + t.rows.length), 7);
        for (final t in tables) {
          expect(t.header, ['Belgi', 'Tavsif', 'Ahamiyati']);
        }
        expect(tables.last.caption, 'Jadval izohi');
        // Har sahifa manbasi — o‘z bandlariniki.
        for (final p in g.where((p) => p.bullets.isNotEmpty)) {
          final own = {
            for (final b in p.bullets) '${b.source.author}|${b.source.page}',
          };
          final shown = {
            for (final s in p.sources)
              for (final pg in s.pages) '${s.author}|$pg',
          };
          expect(shown, own);
        }
        // Deterministik.
        final again = buildLessonPages(deck(), l);
        expect(
          [for (final p in again) p.title],
          [for (final p in pages) p.title],
        );
      },
    );

    test('bitta juda uzun band jumlalar bo‘yicha bo‘linadi', () {
      final pages = buildLessonPages(deck(), l);
      final g = pages.where((p) => p.group == 2).toList();
      expect(g.length, greaterThan(1));
      final joined = [for (final p in g) ...p.bullets.map((b) => b.text)]
          .join(' ');
      expect(joined, hugeBullet);
      expect(g.every((p) => p.bullets.every((b) => b.uncertain)), isTrue);
    });

    test('adabiyotlar ham bo‘linadi; manbali band — manba qatori', () {
      final pages = buildLessonPages(deck(), l);
      final refs = pages
          .where((p) => p.kind == LessonPageKind.references)
          .toList();
      expect(refs.fold<int>(0, (a, p) => a + p.bullets.length), 14);
      final extras = pages.firstWhere((p) => p.kind == LessonPageKind.extras);
      expect(lessonSourceLine(l, extras.sources), contains('C'));
    });
  });

  Future<void> pumpPage(
    WidgetTester tester,
    LessonPage page, {
    String? counter,
    Widget? action,
    double textScale = 1,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: FeThemeBuilder.dark(),
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
            projector: true,
            counter: counter,
            action: action,
          ),
        ),
      ),
    );
    await tester.pump();
  }

  for (final size in const [
    Size(1280, 720),
    Size(1920, 1080),
    Size(844, 390),
  ]) {
    testWidgets('har sahifa kanvasga sig‘adi, matn ≥ 24 px '
        '(${size.width.toInt()}x${size.height.toInt()})', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final pages = buildLessonPages(deck(), l);
      for (var i = 0; i < pages.length; i++) {
        final last = i == pages.length - 1;
        await pumpPage(
          tester,
          pages[i],
          counter: '${i + 1} / ${pages.length}',
          action: last
              ? FilledButton(onPressed: () {}, child: const Text('Q'))
              : null,
        );
        expect(tester.takeException(), isNull, reason: pages[i].title);
        expect(find.byType(SingleChildScrollView), findsNothing);
        final content = tester.widget<LessonCanvasContent>(
          find.byType(LessonCanvasContent),
        );
        expect(
          content.body,
          greaterThanOrEqualTo(LessonCanvasMetrics.minBody),
          reason: pages[i].title,
        );
        // Kichraytirilmagan: kontent dizayn balandligi ≤ kanvas ichi.
        expect(
          tester.getSize(find.byType(LessonCanvasContent)).height,
          lessThanOrEqualTo(LessonCanvasMetrics.innerH + 0.5),
          reason: pages[i].title,
        );
        // Kanvas ekran ichida (chetlari bo‘sh, hech narsa kesilmaydi).
        final canvas = tester.getRect(
          find.byKey(const Key('lesson.projectorFit')),
        );
        expect(canvas.left, greaterThanOrEqualTo(-0.5));
        expect(canvas.top, greaterThanOrEqualTo(-0.5));
        expect(canvas.right, lessThanOrEqualTo(size.width + 0.5));
        expect(canvas.bottom, lessThanOrEqualTo(size.height + 0.5));
        final src = find.byKey(const Key('lesson.source'));
        if (src.evaluate().isNotEmpty) {
          expect(
            tester.getRect(src).bottom,
            lessThanOrEqualTo(canvas.bottom + 0.5),
          );
        }
      }
    });
  }

  testWidgets('tizim matn masshtabi kanvasni buzmaydi', (tester) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final page = buildLessonPages(deck(), l).firstWhere((p) => p.group == 1);
    await pumpPage(tester, page, counter: '1 / 2');
    final a = tester
        .widget<LessonCanvasContent>(find.byType(LessonCanvasContent))
        .body;
    await pumpPage(tester, page, counter: '1 / 2', textScale: 2);
    expect(tester.takeException(), isNull);
    final b = tester
        .widget<LessonCanvasContent>(find.byType(LessonCanvasContent))
        .body;
    expect(b, a);
    expect(
      tester.getSize(find.byType(LessonCanvasContent)).height,
      lessThanOrEqualTo(LessonCanvasMetrics.innerH + 0.5),
    );
  });

  testWidgets('qisqa sahifa — eng katta shrift (34 px)', (tester) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpPage(tester, buildLessonPages(deck(), l).first, counter: '1');
    expect(
      tester.widget<LessonCanvasContent>(find.byType(LessonCanvasContent)).body,
      34,
    );
    expect(find.byKey(const Key('lesson.counter')), findsOneWidget);
  });
}
