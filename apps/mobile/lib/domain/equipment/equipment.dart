/// «Asbob-uskunalar» bo‘limi (egasi talabi, 2026-11-01): laboratoriya
/// apparatlari va morg (yorib ko‘rish) asboblari — illyustratsiya, nima ekani,
/// nima uchun ishlatilishi, ehtiyot choralari va manbalar.
///
/// Matn asli o‘zbekcha (`source_lang: uz`); har gap manbaga tayanadi
/// (manbasiz gap paketga kiritilmaydi). Rasmlar — AI yordamida chizilgan
/// illyustratsiya, ekranda shunday deb yoziladi (haqiqiy apparat surati emas).
enum EquipmentGroup { lab, morgue }

class EquipmentSource {
  const EquipmentSource({
    required this.author,
    required this.title,
    required this.page,
    this.doi = '',
  });

  factory EquipmentSource.fromJson(Map<String, Object?> j) => EquipmentSource(
    author: (j['author'] as String? ?? '').trim(),
    title: (j['title'] as String? ?? '').trim(),
    page: (j['page'] as String? ?? '').trim(),
    doi: (j['doi'] as String? ?? '').trim(),
  );

  final String author;
  final String title;
  final String page;
  final String doi;

  bool get valid => author.isNotEmpty && title.isNotEmpty && page.isNotEmpty;
}

class EquipmentItem {
  const EquipmentItem({
    required this.id,
    required this.group,
    required this.name,
    required this.what,
    this.use = const [],
    this.care = const [],
    this.methods = const [],
    this.guides = const [],
    this.lessons = const [],
    this.sources = const [],
  });

  static EquipmentItem? fromJson(Map<String, Object?> j) {
    final id = (j['id'] as String? ?? '').trim();
    final group = EquipmentGroup.values.asNameMap()[j['group']];
    final name = (j['name'] as String? ?? '').trim();
    final what = (j['what'] as String? ?? '').trim();
    final sources = [
      for (final s in (j['sources'] as List? ?? const []))
        if (s is Map) EquipmentSource.fromJson(s.cast<String, Object?>()),
    ].where((s) => s.valid).toList();
    // Manbasiz yozuv ko‘rsatilmaydi (to‘qilgan matn yo‘q).
    if (id.isEmpty || group == null || name.isEmpty || what.isEmpty) {
      return null;
    }
    if (sources.isEmpty) return null;
    final links = (j['links'] as Map? ?? const {}).cast<String, Object?>();
    List<String> strs(Object? v) => [
      for (final x in (v as List? ?? const []))
        if (x is String && x.trim().isNotEmpty) x.trim(),
    ];
    return EquipmentItem(
      id: id,
      group: group,
      name: name,
      what: what,
      use: strs(j['use']),
      care: strs(j['care']),
      methods: strs(links['methods']),
      guides: strs(links['guides']),
      lessons: strs(links['lessons']),
      sources: sources,
    );
  }

  final String id;
  final EquipmentGroup group;
  final String name;
  final String what;
  final List<String> use;
  final List<String> care;
  final List<String> methods;
  final List<String> guides;
  final List<String> lessons;
  final List<EquipmentSource> sources;

  /// Illyustratsiya (ilova asseti). Fayl nomi = yozuv id’si.
  String get image => 'assets/images/instruments/$id.webp';
}

class EquipmentBundle {
  const EquipmentBundle({this.items = const [], this.sourceLang = 'uz'});

  factory EquipmentBundle.fromJson(Map<String, Object?> j) => EquipmentBundle(
    sourceLang: (j['source_lang'] as String?) ?? 'uz',
    items: [
      for (final x in (j['items'] as List? ?? const []))
        if (x is Map)
          if (EquipmentItem.fromJson(x.cast<String, Object?>()) case final i?)
            i,
    ],
  );

  static const empty = EquipmentBundle();

  final List<EquipmentItem> items;
  final String sourceLang;

  List<EquipmentItem> of(EquipmentGroup g) => [
    for (final i in items)
      if (i.group == g) i,
  ];

  EquipmentItem? byId(String id) => items.where((i) => i.id == id).firstOrNull;
}
