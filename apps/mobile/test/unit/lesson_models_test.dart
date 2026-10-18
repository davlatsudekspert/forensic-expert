import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/data/lessons/fake_lessons_service.dart';
import 'package:forensic_expert/domain/lessons/lesson_models.dart';

void main() {
  test('lesson_get: ixtiyoriy maydonlar yo‘q bo‘lsa ham yiqilmaydi', () {
    final d = LessonDeck.fromJson({
      'ok': true,
      'topic_id': 't1',
      'deck': {
        'topic': 'Mavzu',
        'slides': [
          {'title': 'A'},
          {
            'title': 'B',
            'bullets': [
              'oddiy satr',
              {'text': 'x'},
              {'text': ''},
              {
                'text': 'y',
                'source': {'author': 'Muallif'},
                'uncertain': true,
              },
            ],
            'diagram': {'nodes': <String>[]},
          },
          'noto‘g‘ri',
        ],
      },
    });
    expect(d.title, 'Mavzu');
    expect(d.sourceLang, 'uz');
    expect(d.deckId, '');
    expect(d.slides.length, 3);
    expect(d.slides[0].bullets, isEmpty);
    expect(d.slides[0].teacherNotes, '');
    expect(d.slides[1].bullets.length, 3);
    expect(d.slides[1].bullets[2].uncertain, isTrue);
    expect(d.slides[1].diagram, isNull);
    expect(d.slides[1].sources.length, 1);
    expect(d.extras, isEmpty);
    expect(d.references, isEmpty);
  });

  test('diagramma: jadval qatorlari sarlavhaga moslanadi, flow tugunlari', () {
    final t = LessonDiagram.tryParse({
      'header': ['A', 'B'],
      'rows': [
        ['1'],
        ['1', '2', '3'],
      ],
    })!;
    expect(t.kind, LessonDiagramKind.table);
    expect(t.rows, [
      ['1', ''],
      ['1', '2'],
    ]);
    final f = LessonDiagram.tryParse({
      'nodes': ['x', 'y'],
      'caption': 'c',
    })!;
    expect(f.kind, LessonDiagramKind.flow);
    expect(LessonDiagram.tryParse(null), isNull);
    expect(LessonDiagram.tryParse({'x': 1}), isNull);
  });

  test('ro‘yxat: bo‘sh maydonlar, guruhlash tartibi va filtr', () {
    expect(LessonSummary.fromJson(const {}).slides, 0);
    final all = [
      const LessonSummary(
        topicId: 'a',
        deckId: 'a',
        course: '4-kurs',
        title: 'Toksikologiya',
        slides: 5,
      ),
      const LessonSummary(
        topicId: 'b',
        deckId: 'b',
        course: '5-kurs',
        title: 'Travmatologiya',
        slides: 7,
      ),
      const LessonSummary(
        topicId: 'c',
        deckId: 'c',
        course: '4-kurs',
        title: 'Asfiksiya',
        slides: 3,
      ),
    ];
    final g = LessonGrouping.group(all);
    expect(g.map((e) => e.course), ['4-kurs', '5-kurs']);
    expect(g.first.items.map((e) => e.topicId), ['a', 'c']);
    expect(LessonGrouping.filter(all, 'TOKS').map((e) => e.topicId), ['a']);
    expect(LessonGrouping.filter(all, '5-kurs').length, 1);
    expect(LessonGrouping.filter(all, '  ').length, 3);
  });

  test('Fake: qidiruv slayd matni bo‘yicha, ustoz emas — forbidden', () async {
    final s = FakeLessonsService();
    final r = await s.list(query: 'jadvalda');
    expect(r.value!.length, 1);
    expect((await s.list(query: 'yo‘q-yo‘q')).value, isEmpty);
    expect((await s.get('nope')).ok, isFalse);
    final no = await FakeLessonsService(isTeacher: false).list();
    expect(no.ok, isFalse);
  });

  test('adabiyot qatorida yil takrorlanmaydi', () {
    const twice = LessonReference(
      author: 'Muhamedova Z.M.',
      title: 'Bioetika, Toshkent, 2006',
      year: '2006',
      pages: 'b. 5',
    );
    expect(
      twice.line,
      'Muhamedova Z.M.. Bioetika, Toshkent, 2006. b. 5'.replaceAll('M..', 'M.'),
    );
    const once = LessonReference(author: 'A', title: 'Kitob', year: '2019');
    expect(once.line, 'A. Kitob. 2019');
  });
}
