import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/domain/lessons/lesson_models.dart';

import '../helpers/lesson_diagram_fixtures.dart';

String _long(int n) => 'a' * n;

Map<String, Object?> _col(String title, List<Object?> items) => {
  'title': title,
  'items': items,
};

void main() {
  group('LessonDiagram.tryParse — v2 turlari', () {
    test('har tur: limitdagi eng uzun to‘g‘ri kirish o‘qiladi', () {
      final all = maxDiagrams();
      for (final k in diagramKinds) {
        final d = LessonDiagram.tryParse(all[k]);
        expect(d, isNotNull, reason: k);
        expect(d!.kind.name, k);
        expect(d.caption, isNotEmpty);
      }
    });

    test('steps maydonlari', () {
      final d = LessonDiagram.tryParse({
        'kind': 'steps',
        'items': [
          {'title': 'A', 'text': 'x'},
          {'title': 'B'},
        ],
        'caption': 'izoh',
      })!;
      expect(d.kind, LessonDiagramKind.steps);
      expect(d.steps.map((e) => e.title), ['A', 'B']);
      expect(d.steps[1].text, '');
      expect(d.caption, 'izoh');
    });

    test('compare / tree / facts / reaction / cycle maydonlari', () {
      final c = LessonDiagram.tryParse({
        'kind': 'compare',
        'columns': [
          _col('A', ['1', '2']),
          _col('B', ['3']),
        ],
      })!;
      expect(c.columns[0].items, ['1', '2']);
      final t = LessonDiagram.tryParse({
        'kind': 'tree',
        'root': 'R',
        'children': [
          {
            'label': 'a',
            'items': ['x'],
          },
          {'label': 'b'},
        ],
      })!;
      expect(t.root, 'R');
      expect(t.children[0].items, ['x']);
      expect(t.children[1].items, isEmpty);
      final f = LessonDiagram.tryParse({
        'kind': 'facts',
        'items': [
          {'label': 'pH', 'value': 7.4, 'unit': ''},
          {'label': 'Rf', 'value': '0,5', 'unit': 'sm'},
        ],
      })!;
      expect(f.facts[0].value, '7.4');
      expect(f.facts[1].unit, 'sm');
      final r = LessonDiagram.tryParse({
        'kind': 'reaction',
        'reagents': ['A', 'B'],
        'products': ['C'],
        'conditions': 'isitish',
        'observation': 'rang',
      })!;
      expect(r.reagents, ['A', 'B']);
      expect(r.conditions, 'isitish');
      expect(r.observation, 'rang');
      final y = LessonDiagram.tryParse({
        'kind': 'cycle',
        'nodes': ['1', '2', '3'],
      })!;
      expect(y.nodes, hasLength(3));
    });

    test('noma’lum yoki yaroqsiz kind → null', () {
      expect(
        LessonDiagram.tryParse({
          'kind': 'pie',
          'nodes': ['a'],
        }),
        isNull,
      );
      expect(LessonDiagram.tryParse({'kind': 5}), isNull);
      expect(LessonDiagram.tryParse({'kind': 'steps'}), isNull);
    });

    test('buzuq/limitdan oshgan kirish → null (crash yo‘q)', () {
      Map<String, Object?> steps(List<Object?> items, [String? cap]) => {
        'kind': 'steps',
        'items': items,
        'caption': ?cap,
      };
      Map<String, Object?> compare(List<Object?> cols) => {
        'kind': 'compare',
        'columns': cols,
      };
      Map<String, Object?> tree(Object? root, List<Object?> kids) => {
        'kind': 'tree',
        'root': root,
        'children': kids,
      };
      Map<String, Object?> facts(List<Object?> items) => {
        'kind': 'facts',
        'items': items,
      };
      Map<String, Object?> reaction(
        Object? reagents,
        Object? products, {
        String? cond,
        String? obs,
      }) => {
        'kind': 'reaction',
        'reagents': reagents,
        'products': products,
        'conditions': ?cond,
        'observation': ?obs,
      };
      final ok1 = _col('x', ['y']);
      final bad = <Map<String, Object?>>[
        steps([
          for (var i = 0; i < 7; i++) {'title': 'a'},
        ]),
        steps([
          {'title': 'a'},
        ]),
        steps([
          {'title': _long(31)},
          {'title': 'b'},
        ]),
        steps([
          {'title': 'a', 'text': _long(81)},
          {'title': 'b'},
        ]),
        steps([
          {'title': ''},
          {'title': 'b'},
        ]),
        steps(['a', 'b']),
        steps([
          {'title': 'a'},
          {'title': 'b'},
        ], _long(81)),
        compare([ok1]),
        compare([ok1, ok1, ok1, ok1]),
        compare([ok1, _col('b', [])]),
        compare([
          ok1,
          _col(_long(25), ['y']),
        ]),
        compare([
          ok1,
          _col('b', [for (var i = 0; i < 6; i++) 'z']),
        ]),
        compare([
          ok1,
          _col('b', [_long(61)]),
        ]),
        tree(_long(31), [
          {'label': 'a'},
        ]),
        tree('r', []),
        tree('r', [
          for (var i = 0; i < 7; i++) {'label': 'a'},
        ]),
        tree('r', [
          {'label': _long(27)},
        ]),
        tree('r', [
          {
            'label': 'a',
            'items': ['1', '2', '3', '4'],
          },
        ]),
        tree('r', [
          {
            'label': 'a',
            'items': [_long(41)],
          },
        ]),
        tree(null, [
          {'label': 'a'},
        ]),
        facts([]),
        facts([
          for (var i = 0; i < 7; i++) {'label': 'a', 'value': '1'},
        ]),
        facts([
          {'label': 'a'},
        ]),
        facts([
          {'label': 'a', 'value': _long(21)},
        ]),
        facts([
          {'label': _long(25), 'value': '1'},
        ]),
        facts([
          {'label': 'a', 'value': '1', 'unit': _long(13)},
        ]),
        reaction([], ['p']),
        reaction(['a'], ['p'], cond: _long(41)),
        reaction(['a'], ['p'], obs: _long(61)),
        reaction(['a', 'b', 'c', 'd'], ['p']),
        reaction(['a'], [_long(41)]),
        reaction('a', ['p']),
        {
          'kind': 'cycle',
          'nodes': ['a', 'b'],
        },
        {
          'kind': 'cycle',
          'nodes': [for (var i = 0; i < 7; i++) 'a'],
        },
        {
          'kind': 'cycle',
          'nodes': ['a', 'b', _long(29)],
        },
        {
          'kind': 'cycle',
          'nodes': ['a', 'b', <int>[]],
        },
        {'kind': 'cycle', 'nodes': 'abc'},
      ];
      for (var i = 0; i < bad.length; i++) {
        expect(LessonDiagram.tryParse(bad[i]), isNull, reason: '#$i ${bad[i]}');
      }
      expect(LessonDiagram.tryParse('steps'), isNull);
      expect(LessonDiagram.tryParse(null), isNull);
    });

    test('buzuq diagramma slaydni yiqitmaydi: slayd diagrammasiz', () {
      final deck = LessonDeck.fromJson({
        'title': 'T',
        'deck': {
          'slides': [
            {
              'title': 'S',
              'bullets': ['a'],
              'diagram': {
                'kind': 'cycle',
                'nodes': ['a'],
              },
            },
          ],
        },
      });
      expect(deck.slides.single.diagram, isNull);
      expect(deck.slides.single.bullets, hasLength(1));
    });

    test('eski table/flow o‘zgarmagan (kind bilan ham, kindsiz ham)', () {
      final t = LessonDiagram.tryParse({
        'kind': 'table',
        'header': ['A', 'B'],
        'rows': [
          ['1'],
        ],
      })!;
      expect(t.kind, LessonDiagramKind.table);
      expect(t.rows.single, ['1', '']);
      final f = LessonDiagram.tryParse({
        'kind': 'flow',
        'nodes': ['a', 'b'],
      })!;
      expect(f.kind, LessonDiagramKind.flow);
      expect(
        LessonDiagram.tryParse({
          'nodes': ['a'],
        })!.kind,
        LessonDiagramKind.flow,
      );
      expect(
        LessonDiagram.tryParse({'kind': 'flow', 'nodes': <String>[]}),
        isNull,
      );
    });
  });
}
