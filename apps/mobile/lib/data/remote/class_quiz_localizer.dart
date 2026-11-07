import '../../domain/ports/backend_ports.dart';
import 'supabase_rest.dart';

/// Sinf testi / guruh testi savollarini ilova tilida (ru/en) ko‘rsatadi:
/// serverdagi `class_quiz_question_translations` asl o‘zbekcha savol ustiga
/// qo‘yiladi (savol, variantlar, izoh). Tarjima yo‘q yoki mos kelmasa — asl
/// matn qoladi (to‘qilmaydi). To‘g‘ri javob indeksi va variant id’lari
/// o‘zgarmaydi: faqat matnlar almashtiriladi, variantlar tartibi saqlanadi.
///
/// Ikki yo‘l:
/// * [localizeBankRows] — asl tartibdagi bank yozuvlari (`id` bilan, mashq):
///   tarjima jadvali bitta so‘rov bilan (`question_id=in.(…)`) o‘qiladi;
/// * [localizeTree] — sessiya/guruh RPC javobidagi nusxa savollar (variantlari
///   aralashgan): `class_quiz_localize` RPC (migratsiya
///   `20261107010000_class_quiz_localize.sql`); serverda hali yo‘q bo‘lsa
///   (404) — asl matn, keyin qayta so‘ralmaydi.
///
/// Natijalar xotirada keshlanadi (polling har 2 s — tarmoq so‘rovi faqat
/// yangi savolda).
class ClassQuizLocalizer {
  ClassQuizLocalizer({
    required SupabaseConfig config,
    required this.auth,
    required RestTransport transport,
    required this.lang,
  }) : _cfg = config,
       _http = transport;

  final SupabaseConfig _cfg;
  final AuthRepository auth;
  final RestTransport _http;
  /// Ilova tili (har chaqiruvda o‘qiladi).
  final String Function() lang;

  static const _batch = 60;

  /// `null` qiymat — tarjima yo‘q (qayta so‘ralmaydi).
  final _cache = <String, _Loc?>{};
  bool _rpcMissing = false;
  bool _titlesMissing = false;
  final _titles = <String, Map<String, String>>{};

  /// Faqat ru/en; o‘zbekcha (asl) yoki boshqa til — `null`.
  String? get targetLang {
    final l = lang();
    return (l == 'ru' || l == 'en') ? l : null;
  }

  Future<Map<String, String>> _headers() async {
    final token = await auth.accessToken();
    return {
      'apikey': _cfg.anonKey,
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Mashq savollari (`id`, `question`, `options` asl tartibda,
  /// `explanation`) — joyida yangilanadi.
  Future<void> localizeBankRows(List<Map<String, Object?>> rows) async {
    final lang = targetLang;
    if (lang == null || rows.isEmpty) return;
    final ids = <String>{
      for (final r in rows)
        if (r['id'] case final String id when _uuid.hasMatch(id)) id,
    };
    if (ids.isEmpty) return;
    final Object? json;
    try {
      final r = await _http.send(
        'GET',
        _cfg.url.resolve(
          'rest/v1/class_quiz_question_translations'
          '?select=question_id,question,options,explanation'
          '&lang=eq.$lang&question_id=in.(${ids.join(',')})',
        ),
        headers: await _headers(),
      );
      if (!r.ok) return;
      json = r.json;
    } on Object {
      // Tarmoq/format xatosi: asl matn qoladi.
      return;
    }
    if (json is! List) return;
    final byId = <String, Map<Object?, Object?>>{
      for (final t in json)
        if (t is Map && t['question_id'] is String)
          t['question_id']! as String: t,
    };
    for (final row in rows) {
      final t = byId[row['id']];
      if (t == null) continue;
      final orig = row['options'];
      final opts = t['options'];
      final q = t['question'];
      if (orig is! List || opts is! List || q is! String || q.trim().isEmpty) {
        continue;
      }
      if (opts.length != orig.length || opts.any((o) => o is! String)) {
        continue;
      }
      row['question'] = q;
      row['options'] = [for (final o in opts) o as String];
      final ex = t['explanation'];
      if (ex is String && ex.trim().isNotEmpty) row['explanation'] = ex;
    }
  }

  /// RPC javobidagi barcha savol tugunlarini (`text` + 4 ta `options` —
  /// matn yoki `{id,text}`) joyida tarjima qiladi. `explanation` o‘sha
  /// tugunda yoki qo‘shni `reveal` obyektida bo‘lishi mumkin (talaba holati).
  Future<void> localizeTree(Object? json) async {
    final lang = targetLang;
    if (lang == null || _rpcMissing) return;
    final nodes = <_Node>[];
    _collect(json, null, nodes);
    if (nodes.isEmpty) return;
    final pending = <String, _Node>{};
    for (final n in nodes) {
      final key = n.key(lang);
      if (!_cache.containsKey(key)) pending.putIfAbsent(key, () => n);
    }
    if (pending.isNotEmpty) await _fetch(lang, pending);
    for (final n in nodes) {
      final loc = _cache[n.key(lang)];
      if (loc == null) continue;
      try {
        n.apply(loc);
      } on UnsupportedError {
        // O‘zgarmas (const) JSON — asl matn qoladi.
      }
    }
  }

  Future<void> _fetch(String lang, Map<String, _Node> pending) async {
    final entries = pending.entries.toList();
    for (var i = 0; i < entries.length; i += _batch) {
      final part = entries.sublist(i, (i + _batch).clamp(0, entries.length));
      final Object? json;
      try {
        final r = await _http.send(
          'POST',
          _cfg.url.resolve('rest/v1/rpc/class_quiz_localize'),
          headers: await _headers(),
          jsonBody: {
            'p_lang': lang,
            'p_items': [for (final e in part) e.value.request()],
          },
        );
        if (r.status == 404) {
          _rpcMissing = true;
          return;
        }
        if (!r.ok) return;
        json = r.json;
      } on Object {
        // Tarmoq/format xatosi: asl matn qoladi.
        return;
      }
      final items = json is Map ? json['items'] : null;
      if (items is! List || items.length != part.length) return;
      for (final (j, e) in part.indexed) {
        _cache[e.key] = _Loc.tryParse(items[j], e.value.options.length);
      }
    }
  }

  /// Mavzu nomlari tarjimasi (`class_topic_titles`: ma’ruza tarjimasidagi
  /// `topic` bo‘lagi), deck id → nom. Yo‘q/xato — bo‘sh (o‘zbekcha nom qoladi).
  Future<Map<String, String>> topicTitles() async {
    final lang = targetLang;
    if (lang == null || _titlesMissing) return const {};
    final cached = _titles[lang];
    if (cached != null) return cached;
    try {
      final r = await _http.send(
        'POST',
        _cfg.url.resolve('rest/v1/rpc/class_topic_titles'),
        headers: await _headers(),
        jsonBody: {'p_lang': lang},
      );
      if (r.status == 404) {
        _titlesMissing = true;
        return const {};
      }
      if (!r.ok) return const {};
      final out = <String, String>{
        for (final e in r.map.entries)
          if (e.value case final String v when v.trim().isNotEmpty)
            e.key: v.trim(),
      };
      return _titles[lang] = out;
    } on Object {
      // Tarmoq/format xatosi: asl matn qoladi.
      return const {};
    }
  }

  static void _collect(
    Object? v,
    Map<Object?, Object?>? reveal,
    List<_Node> out,
  ) {
    if (v is List) {
      for (final e in v) {
        _collect(e, null, out);
      }
      return;
    }
    if (v is! Map) return;
    final node = _Node.tryOf(v, reveal);
    if (node != null) {
      out.add(node);
      return;
    }
    final r = v['reveal'];
    for (final e in v.entries) {
      _collect(e.value, e.key == 'question' && r is Map ? r : null, out);
    }
  }
}

final _uuid = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
  caseSensitive: false,
);

/// Javobdagi bitta savol tuguni.
class _Node {
  _Node(this.map, this.options, this.explanationHolder);

  final Map<Object?, Object?> map;
  final List<String> options;
  final Map<Object?, Object?>? explanationHolder;

  static _Node? tryOf(Map<Object?, Object?> m, Map<Object?, Object?>? reveal) {
    final text = m['text'];
    final opts = m['options'];
    if (text is! String || text.isEmpty || opts is! List || opts.length != 4) {
      return null;
    }
    final texts = <String>[];
    for (final o in opts) {
      final t = o is String ? o : (o is Map ? o['text'] : null);
      if (t is! String) return null;
      texts.add(t);
    }
    final holder = m['explanation'] is String
        ? m
        : (reveal != null && reveal['explanation'] is String ? reveal : null);
    return _Node(m, texts, holder);
  }

  String get text => map['text']! as String;
  String get explanation =>
      (explanationHolder?['explanation'] as String?) ?? '';
  String? get id => switch (map['id']) {
    final String s when _uuid.hasMatch(s) => s,
    _ => null,
  };

  String key(String lang) =>
      [lang, id ?? '', text, ...options, explanation].join('\u0001');

  Map<String, Object?> request() => {
    if (id != null) 'id': id,
    'question': text,
    'options': options,
    if (explanation.isNotEmpty) 'explanation': explanation,
  };

  void apply(_Loc loc) {
    map['text'] = loc.question;
    final opts = map['options']! as List;
    for (var i = 0; i < opts.length; i++) {
      final o = opts[i];
      if (o is Map) {
        o['text'] = loc.options[i];
      } else {
        opts[i] = loc.options[i];
      }
    }
    final ex = loc.explanation;
    if (ex != null && explanationHolder != null) {
      explanationHolder!['explanation'] = ex;
    }
  }
}

class _Loc {
  const _Loc(this.question, this.options, this.explanation);

  final String question;
  final List<String> options;
  final String? explanation;

  static _Loc? tryParse(Object? v, int count) {
    if (v is! Map) return null;
    final q = v['question'];
    final o = v['options'];
    if (q is! String || q.trim().isEmpty || o is! List || o.length != count) {
      return null;
    }
    if (o.any((x) => x is! String || x.trim().isEmpty)) return null;
    final ex = v['explanation'];
    return _Loc(q, [for (final x in o) x as String], ex is String ? ex : null);
  }
}
