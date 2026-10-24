/// Darslar v2 diagramma namunalari: limitdagi eng uzun matnlar (eng yomon holat).
/// Matn — ko‘p so‘zli, o‘zbekcha (bir so‘zli cho‘zma emas).
library;

String _fill(int n, [String seed = 'Moddaning organizmga ta’sir mexanizmi ']) {
  final b = StringBuffer();
  while (b.length < n) {
    b.write(seed);
  }
  return b.toString().substring(0, n).trim();
}

/// Limitdagi eng uzun (spec) diagramma JSONlari, tur nomi bo‘yicha.
Map<String, Map<String, Object?>> maxDiagrams() => {
  'steps': {
    'kind': 'steps',
    'items': [
      for (var i = 0; i < 6; i++)
        {'title': _fill(30, 'Namuna olish '), 'text': _fill(80)},
    ],
    'caption': _fill(80),
  },
  'compare': {
    'kind': 'compare',
    'columns': [
      for (var c = 0; c < 3; c++)
        {
          'title': _fill(24, 'Toksikokinetika '),
          'items': [for (var i = 0; i < 5; i++) _fill(60)],
        },
    ],
    'caption': _fill(80),
  },
  'tree': {
    'kind': 'tree',
    'root': _fill(30, 'Zaharlar tasnifi '),
    'children': [
      for (var i = 0; i < 6; i++)
        {
          'label': _fill(26, 'Uchuvchan zaharlar '),
          'items': [for (var j = 0; j < 3; j++) _fill(40)],
        },
    ],
    'caption': _fill(80),
  },
  'facts': {
    'kind': 'facts',
    'items': [
      for (var i = 0; i < 6; i++)
        {
          'label': _fill(24, 'O‘rtacha o‘ldiruvchi '),
          'value': '12 345,678 – 99,9'.padRight(20, '9').substring(0, 20),
          'unit': 'mg/kg tana',
        },
    ],
    'caption': _fill(80),
  },
  'reaction': {
    'kind': 'reaction',
    'reagents': [for (var i = 0; i < 3; i++) _fill(40)],
    'conditions': _fill(40, 'isitish, 5 daqiqa '),
    'products': [for (var i = 0; i < 3; i++) _fill(40)],
    'observation': _fill(60, 'Qizil-binafsha rangli cho‘kma hosil bo‘ladi '),
    'caption': _fill(80),
  },
  'cycle': {
    'kind': 'cycle',
    'nodes': [for (var i = 0; i < 6; i++) _fill(28, 'Biotransformatsiya ')],
    'caption': _fill(80),
  },
};

/// 2 ta qisqa band + diagramma.
Map<String, Object?> slideWith(String title, Map<String, Object?> diagram) => {
  'title': title,
  'bullets': [
    {
      'text': 'Namuna: diagramma slaydning asosiy fikrini ko‘rsatadi.',
      'source': {'author': 'Namuna A.', 'title': 'Demo darslik', 'page': '12'},
    },
    {
      'text': 'Ikkinchi band: izoh va misol.',
      'source': {'author': 'Namuna A.', 'title': 'Demo darslik', 'page': '13'},
    },
  ],
  'diagram': diagram,
};

const diagramKinds = ['steps', 'compare', 'tree', 'facts', 'reaction', 'cycle'];
