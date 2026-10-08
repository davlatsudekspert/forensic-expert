/// Offline RAG qidiruvi uchun umumiy matn tahlili va relevantlik bahosi.
///
/// Oldingi muammo (BlueStacks, YuQX savoli): bitta umumiy so‘z ("sud")
/// ikki tomonlama prefiks bilan mos kelib, entomologiya va odontologiya
/// natijalarini chiqargan. Bu yerda:
/// * apostrofli o‘zbek so‘zlari bo‘linmaydi (`ko‘rsating` → `korsating`);
/// * umumiy/savol so‘zlari (sud, ekspertiza, ilmiy, manba, afzallik…)
///   relevantlikka hissa qo‘shmaydi;
/// * moslik bir tomonlama: hujjat so‘zi so‘rov so‘zi bilan boshlanadi yoki
///   so‘rovdagi qo‘shimchali so‘z hujjatdagi uzun o‘zakdan boshlanadi;
/// * kam uchraydigan so‘zlar og‘irroq (IDF), minimal bo‘sag‘a bor;
/// * asosiy ilmiy atamalar uchun UZ/RU → EN kengaytma (manbalar ko‘pincha
///   inglizcha).
library;

import 'dart:math' as math;

abstract final class RetrievalText {
  static final _split = RegExp(r'[^\p{L}\p{N}]+', unicode: true);
  static final _apostrophes = RegExp('[\'‘’ʻʼ`´]');

  /// Savol va umumiy soha so‘zlari — o‘zak prefikslari (≥3 belgi).
  static const _stopStems = [
    // umumiy
    'the', 'and', 'what', 'which', 'with', 'for', 'are', 'how', 'about',
    'please', 'show', 'list', 'explain', 'describe', 'give', 'their', 'from',
    'что', 'как', 'для', 'какие', 'каки', 'перечисл', 'объясн', 'покаж',
    'nima', 'qanday', 'qaysi', 'uchun', 'haqida', 'iborat', 'korsat',
    'keltir', 'tushuntir', 'aytib', 'bering', 'bilan', 'hamda', 'yoki',
    // soha bo‘yicha juda umumiy (deyarli har bir yozuvda bor)
    'sud', 'суд', 'forensic', 'ekspert', 'эксперт', 'expert', 'ilmiy',
    'научн', 'scientific', 'manba', 'источник', 'source', 'reference',
    'литератур', 'adabiyot', 'afzallik', 'преимуществ', 'advantage',
    'cheklov', 'огранич', 'limitation', 'kamchilik', 'недостат',
  ];

  /// Asosiy atamalar: o‘zak → qo‘shimcha (ko‘pincha inglizcha) o‘zaklar.
  static const _expansions = <String, List<String>>{
    'xromatograf': ['chromatograph'],
    'хроматограф': ['chromatograph'],
    'yupqa': ['thin'],
    'тонкосло': ['thin', 'layer'],
    'qatlam': ['layer'],
    'gaz': ['gas'],
    'газ': ['gas'],
    'massa': ['mass'],
    'масс': ['mass'],
    'spektr': ['spectr'],
    'спектр': ['spectr'],
    'etanol': ['ethanol', 'alcohol'],
    'этанол': ['ethanol', 'alcohol'],
    'spirt': ['ethanol', 'alcohol'],
    'спирт': ['ethanol', 'alcohol'],
    'alkogol': ['alcohol', 'ethanol'],
    'алкогол': ['alcohol', 'ethanol'],
    'qon': ['blood'],
    'кров': ['blood'],
    'siydik': ['urine'],
    'моч': ['urine'],
    'zahar': ['poison', 'toxic'],
    'отрав': ['poison', 'toxic'],
    'toksik': ['toxic'],
    'токсик': ['toxic'],
    'giyohvand': ['drug', 'narcotic'],
    'наркот': ['drug', 'narcotic'],
    'metabolit': ['metabolite'],
    'метаболит': ['metabolite'],
    'skrining': ['screen'],
    'скрининг': ['screen'],
    'immun': ['immunoassay'],
    'иммун': ['immunoassay'],
    'diatom': ['diatom'],
    'диатом': ['diatom'],
    'cho‘k': ['drown'],
    'chok': ['drown'],
    'утоп': ['drown'],
    'suyak': ['bone', 'skeletal'],
    'кост': ['bone', 'skeletal'],
    'gistolog': ['histolog'],
    'гистолог': ['histolog'],
    'murda': ['postmortem', 'cadaver'],
    'труп': ['postmortem', 'cadaver'],
    'olim': ['death'],
    'смерт': ['death'],
    'dnk': ['dna'],
    'днк': ['dna'],
  };

  static bool _isStop(String t) {
    for (final s in _stopStems) {
      if (t.startsWith(s)) return true;
    }
    return false;
  }

  /// Hujjat matnidan so‘zlar (stop-so‘zlar ham qoladi — so‘rov tomoni
  /// filtrlaydi).
  static Set<String> docTokens(String s) => {
    for (final t in s.toLowerCase().replaceAll(_apostrophes, '').split(_split))
      if (t.length >= 3) t,
  };

  /// So‘rovdan relevant so‘zlar va ularning kengaytmalari.
  static Set<String> queryTokens(String s) {
    final out = <String>{};
    for (final t
        in s.toLowerCase().replaceAll(_apostrophes, '').split(_split)) {
      if (t.length < 3 || _isStop(t)) continue;
      out.add(t);
      for (final e in _expansions.entries) {
        final stem = e.key.replaceAll(_apostrophes, '');
        if (t.startsWith(stem)) out.addAll(e.value);
      }
    }
    return out;
  }

  /// Bir tomonlama moslik.
  static bool matches(String queryToken, Set<String> doc) {
    for (final d in doc) {
      if (d.startsWith(queryToken)) return true;
      // So‘rovdagi qo‘shimchali shakl: "xromatografiyasining" ← "xromatografiya".
      if (d.length >= 5 && queryToken.startsWith(d)) return true;
    }
    return false;
  }
}

/// IDF og‘irlikli moslik bahosi va bo‘sag‘alar.
class RetrievalScorer {
  RetrievalScorer(Iterable<Set<String>> documents)
    : _docs = documents.toList(growable: false);

  final List<Set<String>> _docs;
  final Map<String, double> _idfCache = {};

  /// Absolyut minimal baho (0..1).
  static const minScore = 0.2;

  /// Eng yaxshi natijaga nisbatan minimal ulush.
  static const minRelative = 0.5;

  double _idf(String t) => _idfCache.putIfAbsent(t, () {
    var df = 0;
    for (final d in _docs) {
      if (RetrievalText.matches(t, d)) df++;
    }
    return math.log((_docs.length + 1) / (df + 1)) + 1;
  });

  /// Har bir hujjat uchun baho; mos kelmaganlar — `null`.
  List<double?> scores(Set<String> query) {
    if (query.isEmpty) return List.filled(_docs.length, null);
    final weights = {for (final t in query) t: _idf(t)};
    final total = weights.values.fold<double>(0, (a, b) => a + b);
    final out = <double?>[];
    for (final d in _docs) {
      var hit = 0.0;
      for (final e in weights.entries) {
        if (RetrievalText.matches(e.key, d)) hit += e.value;
      }
      out.add(hit == 0 ? null : hit / total);
    }
    final best = out.whereType<double>().fold<double>(0, math.max);
    return [
      for (final s in out)
        s != null && s >= minScore && s >= best * minRelative ? s : null,
    ];
  }
}
