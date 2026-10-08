import 'package:meta/meta.dart';

import 'models.dart';
import 'normalizer.dart';
import 'query_synonyms.dart';
import 'ranker.dart';

/// So‘rovning bitta qismi (so‘z yoki sinonimlar ro‘yxatidagi ibora) va
/// uning muqobil shakllari.
@immutable
class QuerySlot {
  const QuerySlot(this.text, {this.equivalents = const []});

  /// Foydalanuvchi yozgan shakl.
  final String text;

  /// [QuerySynonyms] dagi guruhdoshlar (o‘zi kirmaydi).
  final List<String> equivalents;

  @override
  String toString() => equivalents.isEmpty ? text : '$text=$equivalents';
}

/// Ilova uchun asosiy offline indeks: ko‘p so‘zli so‘rov va sinonimlar.
///
/// [InMemorySearchIndex] dan farqi:
/// * so‘rov so‘zlarga bo‘linadi; har bir so‘z terminning istalgan so‘ziga
///   (nafaqat boshiga) mos kelishi mumkin. Yozuv barcha so‘zlarga mos
///   kelsa, faqat bittasiga mos kelgan yozuvdan **har doim** yuqori
///   turadi (ball darajalari ajratilgan); to‘liq ibora uchramasa ham
///   natija bo‘sh qolmaydi.
/// * so‘z yoki ibora [QuerySynonyms] guruhida bo‘lsa, guruhdoshlari ham
///   qidiriladi (`alkogol` → `ethanol`, `etanol`, `spirt`…), biroz past
///   og‘irlik bilan.
///
/// [InMemorySearchIndex] o‘zgarmaydi — u FTS5 indeksi uchun «oracle»
/// bo‘lib qoladi.
class MultiTokenSearchIndex implements SearchIndex {
  MultiTokenSearchIndex(
    Iterable<SearchTerm> terms, {
    this.ranker = const SearchRanker(),
    QuerySynonyms? synonyms,
  }) : synonyms = synonyms ?? QuerySynonyms.standard,
       _terms = [for (final t in terms) _PreparedTerm.of(t, ranker.normalizer)];

  final SearchRanker ranker;
  final QuerySynonyms synonyms;
  final List<_PreparedTerm> _terms;

  SearchNormalizer get _normalizer => ranker.normalizer;

  /// Sinonim kengaytmasi og‘irligi (foydalanuvchi yozgan shakl — 1.0).
  static const equivalentWeight = 0.9;

  /// Termin ichidagi (boshidan boshqa) so‘zga moslik og‘irligi.
  static const innerWordWeight = 0.85;

  /// Eng uzun sinonim iborasi (so‘zlar soni).
  static const _maxPhraseWords = 6;

  /// Ahamiyatsiz yordamchi so‘zlar (normalizatsiyadan keyingi shakl).
  /// Faqat boshqa so‘zlar ham bo‘lsa tashlanadi.
  static const _stopWords = {
    'a', 'an', 'the', 'of', 'in', 'on', 'for', 'and', 'or', 'by', 'with', //
    'to', 'и', 'в', 'во', 'на', 'по', 'для', 'с', 'со', 'из', 'от', 'или', //
    'va', 'bilan', 'uchun', 'yoki',
  };

  /// So‘rov rejasi: so‘zlar va sinonim iboralari.
  List<QuerySlot> plan(String text) {
    final all = _normalizer
        .normalize(text)
        .split(' ')
        .where((w) => _normalizer.searchKey(w).isNotEmpty)
        .toList();
    final words = all.length > 1
        ? all.where((w) => !_stopWords.contains(w)).toList()
        : all;
    final tokens = words.isEmpty ? all : words;
    final slots = <QuerySlot>[];
    var i = 0;
    while (i < tokens.length) {
      var taken = 1;
      var eq = const <String>[];
      final maxJ = (i + _maxPhraseWords).clamp(0, tokens.length);
      for (var j = maxJ; j > i; j--) {
        final phrase = tokens.sublist(i, j).join(' ');
        final found = synonyms.equivalentsOf(phrase, allowSuffix: j == i + 1);
        if (found.isNotEmpty || j == i + 1) {
          taken = j - i;
          eq = found;
          break;
        }
      }
      slots.add(
        QuerySlot(tokens.sublist(i, i + taken).join(' '), equivalents: eq),
      );
      i += taken;
    }
    return slots;
  }

  @override
  Future<SearchResults> search(SearchQuery query) async {
    final slots = [for (final s in plan(query.text)) _Slot.of(s, this)];
    if (slots.isEmpty) return const SearchResults({});
    final n = slots.length;
    final aggs = <String, _Aggregate>{};
    for (final p in _terms) {
      List<_SlotMatch?>? matches;
      for (var i = 0; i < n; i++) {
        final m = slots[i].best(p, this, query.preferredLang);
        if (m == null) continue;
        (matches ??= List<_SlotMatch?>.filled(n, null))[i] = m;
      }
      if (matches == null) continue;
      aggs
          .putIfAbsent(
            '${p.term.category.name}:${p.term.entityId}',
            () => _Aggregate(p.term, n),
          )
          .add(p.term, matches);
    }
    final hits = [for (final a in aggs.values) a.toHit()];
    return ranker.group(hits, query.limitPerCategory);
  }

  /// Bitta so‘rov qismi va bitta termin orasidagi eng yaxshi moslik.
  _SlotMatch? _matchAlt(_Alt alt, _PreparedTerm p, String? preferredLang) {
    _SlotMatch? best;
    void offer(MatchType type, double quality, double factor) {
      final s =
          ranker.weigh(type, quality, p.term, preferredLang: preferredLang) *
          alt.weight *
          factor;
      if (best == null || s > best!.score) best = _SlotMatch(type, s);
    }

    if (alt.short) {
      // Qisqa sinonim (GC, ТСХ, DNK) — yozuv tizimi saqlangan aniq moslik.
      if (p.compact == alt.form) {
        offer(MatchType.exact, 1, 1);
      } else if (p.forms.contains(alt.form)) {
        offer(MatchType.exact, 1, innerWordWeight);
      }
      return best;
    }

    final full = ranker.match(
      p.key,
      alt.key,
      fuzzy: alt.original,
      minPrefix: alt.original ? 2 : 4,
    );
    if (full != null) offer(full.type, full.quality, 1);

    if (alt.words.length == 1) {
      if (p.words.length > 1) {
        for (var w = 0; w < p.words.length; w++) {
          final m = ranker.match(
            p.words[w],
            alt.key,
            fuzzy: alt.original && alt.key.length >= 5,
            minPrefix: alt.original ? 3 : 4,
          );
          if (m != null) {
            offer(m.type, m.quality, w == 0 ? 1 : innerWordWeight);
          }
        }
      }
    } else if (full == null) {
      // Ibora termin ichida ketma-ket so‘zlar sifatida (oxirgisi prefiks).
      final at = _indexOfWords(p.words, alt.words);
      if (at >= 0) {
        offer(MatchType.prefix, 1, at == 0 ? 1 : innerWordWeight);
      }
    }
    return best;
  }

  static int _indexOfWords(List<String> hay, List<String> needle) {
    for (var s = 0; s + needle.length <= hay.length; s++) {
      var ok = true;
      for (var k = 0; k < needle.length && ok; k++) {
        final last = k == needle.length - 1;
        ok = last ? hay[s + k].startsWith(needle[k]) : hay[s + k] == needle[k];
      }
      if (ok) return s;
    }
    return -1;
  }
}

class _PreparedTerm {
  _PreparedTerm(this.term, this.key, this.words, this.compact, this.forms);

  factory _PreparedTerm.of(SearchTerm t, SearchNormalizer n) {
    final normalized = n.normalize(t.term);
    final parts = normalized.split(' ').where((w) => w.isNotEmpty).toList();
    return _PreparedTerm(
      t,
      n.searchKey(t.term),
      [
        for (final w in parts)
          if (n.searchKey(w) case final k when k.isNotEmpty) k,
      ],
      normalized.replaceAll(' ', '').replaceAll("'", ''),
      {for (final w in parts) w.replaceAll("'", '')},
    );
  }

  final SearchTerm term;

  /// To‘liq kalit (bo‘shliqsiz).
  final String key;

  /// Har bir so‘z kaliti (tartib saqlangan).
  final List<String> words;

  /// Yozuv tizimi saqlangan ixcham shakl va so‘zlar (qisqa sinonimlar uchun).
  final String compact;
  final Set<String> forms;
}

/// So‘rov qismining bitta muqobil shakli.
class _Alt {
  _Alt(this.key, this.words, this.form, this.weight, {required this.original})
    : short = !original && key.length <= QuerySynonyms.shortKeyLength;

  final String key;
  final List<String> words;
  final String form;
  final double weight;
  final bool original;
  final bool short;
}

class _Slot {
  _Slot(this.alts);

  factory _Slot.of(QuerySlot s, MultiTokenSearchIndex index) {
    final n = index._normalizer;
    _Alt alt(String text, {required bool original}) {
      final parts = n.normalize(text).split(' ');
      return _Alt(
        n.searchKey(text),
        [
          for (final w in parts)
            if (n.searchKey(w) case final k when k.isNotEmpty) k,
        ],
        index.synonyms.compactForm(text),
        original ? 1 : MultiTokenSearchIndex.equivalentWeight,
        original: original,
      );
    }

    return _Slot([
      alt(s.text, original: true),
      for (final e in s.equivalents) alt(e, original: false),
    ]);
  }

  final List<_Alt> alts;

  _SlotMatch? best(
    _PreparedTerm p,
    MultiTokenSearchIndex index,
    String? preferredLang,
  ) {
    _SlotMatch? best;
    for (final a in alts) {
      final m = index._matchAlt(a, p, preferredLang);
      if (m != null && (best == null || m.score > best.score)) best = m;
    }
    return best;
  }
}

class _SlotMatch {
  const _SlotMatch(this.type, this.score);

  final MatchType type;
  final double score;
}

/// Bitta yozuv (kategoriya + ID) bo‘yicha qismlar mosligi.
class _Aggregate {
  _Aggregate(this._display, int slots)
    : _best = List<_SlotMatch?>.filled(slots, null);

  final List<_SlotMatch?> _best;
  SearchTerm _display;
  int _displayCount = 0;
  double _displaySum = 0;
  MatchType _displayType = MatchType.fuzzy;

  void add(SearchTerm term, List<_SlotMatch?> matches) {
    var count = 0;
    var sum = 0.0;
    _SlotMatch? top;
    for (var i = 0; i < matches.length; i++) {
      final m = matches[i];
      if (m == null) continue;
      count++;
      sum += m.score;
      if (top == null || m.score > top.score) top = m;
      final cur = _best[i];
      if (cur == null || m.score > cur.score) _best[i] = m;
    }
    // Ko‘rsatiladigan termin: eng ko‘p qismga mos kelgani, so‘ng eng
    // yuqori ball.
    if (count > _displayCount ||
        (count == _displayCount && sum > _displaySum)) {
      _display = term;
      _displayCount = count;
      _displaySum = sum;
      _displayType = top!.type;
    }
  }

  /// Ball darajalari: `k` ta qism mos kelgan yozuv `((k−1)/n, k/n)`
  /// oralig‘ida — ko‘proq qismga mos kelgan yozuv doim yuqori.
  SearchHit toHit() {
    final matched = _best.whereType<_SlotMatch>().toList();
    final k = matched.length;
    final mean = matched.fold<double>(0, (a, m) => a + m.score) / k;
    final score = (k - 1 + mean / (1 + mean)) / _best.length;
    return SearchHit(
      entityId: _display.entityId,
      category: _display.category,
      matchedTerm: _display.term,
      matchType: _displayType,
      score: score,
    );
  }
}
