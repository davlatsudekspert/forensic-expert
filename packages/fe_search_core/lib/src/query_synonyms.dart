import 'normalizer.dart';

/// Qidiruv so‘rovi uchun ko‘p tilli (UZ/RU/EN) **lingvistik** ekvivalentlar.
///
/// Faqat bir xil narsani bildiradigan so‘z va qisqartmalar: kundalik nom
/// (`alkogol`, `spirt`), boshqa tildagi nom (`qon` / `кровь` / `blood`) va
/// metod qisqartmasining tarjimasi (`YuQX` / `ТСХ` / `TLC`). Bu yerda hech
/// qanday ilmiy fakt (konsentratsiya, bog‘liqlik, diagnostik qoida) yo‘q —
/// yangi guruh qo‘shishda shu qoida saqlanadi.
///
/// AI retrieval (`RetrievalText.queryTokens`) ham shu ro‘yxatdan
/// foydalanadi — ikkinchi nusxa yuritilmaydi.
const List<List<String>> standardSynonymGroups = [
  // Etil spirti: «alkogol» / «spirt» kundalik nutqda etanolni bildiradi.
  [
    'ethanol',
    'etanol',
    'этанол',
    'ethyl alcohol',
    'etil spirti',
    'этиловый спирт',
    'alcohol',
    'alkogol',
    'алкоголь',
    'spirt',
    'спирт',
  ],
  [
    'methanol',
    'metanol',
    'метанол',
    'methyl alcohol',
    'metil spirti',
    'метиловый спирт',
  ],
  ['blood', 'qon', 'кровь'],
  ['urine', 'siydik', 'моча'],
  ['liver', 'jigar', 'печень'],
  ['DNA', 'DNK', 'ДНК'],
  [
    'thin-layer chromatography',
    'TLC',
    'yupqa qatlamli xromatografiya',
    'YuQX',
    'тонкослойная хроматография',
    'ТСХ',
  ],
  [
    'gas chromatography',
    'GC',
    'gaz xromatografiyasi',
    'GX',
    'газовая хроматография',
    'ГХ',
  ],
  [
    'gas chromatography–mass spectrometry',
    'GC-MS',
    'GX-MS',
    'ГХ-МС',
    'XMS',
    'ХМС',
  ],
];

/// So‘rov so‘zi yoki iborasini ekvivalentlar guruhiga bog‘laydi.
///
/// Qisqa shakllar (kaliti ≤ [shortKeyLength] belgi: `GC`, `ТСХ`, `DNK`)
/// yozuv tizimini saqlagan holda solishtiriladi — aks holda kirill `ТСХ`
/// va o‘zbekcha `SX` (suyuqlik xromatografiyasi) bir xil `sx` kalitiga
/// tushib, noto‘g‘ri sinonim hosil bo‘lardi. Uzunroq shakllar tillararo
/// [SearchNormalizer.searchKey] bo‘yicha solishtiriladi.
class QuerySynonyms {
  QuerySynonyms(
    this.groups, {
    SearchNormalizer normalizer = const SearchNormalizer(),
  }) : _normalizer = normalizer {
    for (var i = 0; i < groups.length; i++) {
      for (final member in groups[i]) {
        _byForm.putIfAbsent(compactForm(member), () => i);
        final key = normalizer.searchKey(member);
        if (key.length > shortKeyLength) _byKey.putIfAbsent(key, () => i);
      }
    }
  }

  /// Ilovadagi standart ro‘yxat.
  static final QuerySynonyms standard = QuerySynonyms(standardSynonymGroups);

  /// Sinonimsiz (faqat so‘rovning o‘zi).
  static final QuerySynonyms none = QuerySynonyms(const []);

  /// Shu uzunlikkacha (kalit bo‘yicha) shakl «qisqa» hisoblanadi.
  static const shortKeyLength = 3;

  final List<List<String>> groups;
  final SearchNormalizer _normalizer;
  final Map<String, int> _byForm = {};
  final Map<String, int> _byKey = {};

  /// Qo‘shimchali shakl (`qondagi`, `крови`, `spirtli`) uchun ruxsat
  /// etilgan qo‘shimcha uzunligi. Faqat kaliti kamida
  /// [_minStemForSuffix] belgili a’zolarga qo‘llanadi (`qon` → `qonun`
  /// kabi tasodifiy moslik bo‘lmasligi uchun).
  static const _maxSuffix = 3;
  static const _minStemForSuffix = 4;

  /// Yozuv tizimini saqlagan ixcham shakl (registr, apostrof, bo‘shliq
  /// va defislarsiz).
  String compactForm(String s) =>
      _normalizer.normalize(s).replaceAll(' ', '').replaceAll("'", '');

  /// [phrase] ning guruhdoshlari (o‘zi kirmaydi). Guruhda bo‘lmasa — bo‘sh.
  ///
  /// [allowSuffix] — bitta so‘z uchun qisqa qo‘shimchaga ruxsat.
  List<String> equivalentsOf(String phrase, {bool allowSuffix = false}) {
    final form = compactForm(phrase);
    if (form.isEmpty) return const [];
    final key = _normalizer.searchKey(phrase);
    var group =
        _byForm[form] ?? (key.length > shortKeyLength ? _byKey[key] : null);
    if (group == null && allowSuffix) {
      for (final e in _byKey.entries) {
        if (e.key.length >= _minStemForSuffix &&
            key.length > e.key.length &&
            key.length - e.key.length <= _maxSuffix &&
            key.startsWith(e.key)) {
          group = e.value;
          break;
        }
      }
    }
    if (group == null) return const [];
    return [
      for (final m in groups[group])
        if (compactForm(m) != form) m,
    ];
  }
}
