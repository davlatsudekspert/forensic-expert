// «Test o‘tkazish» mavzu ro‘yxati: bitta ro‘yxat, har fakultet/fan bir marta.
//
// Savollar banki (ilova asseti) va server (`class_topics`) mavzulari bir xil
// guruh kalitiga keltiriladi — «Darslar» (lesson_topics.course) kabi:
// Bioetika, Davolash ishi, Pediatriya, Tibbiy profilaktika, Stomatologiya,
// Sud tibbiyoti (umumiy mavzular), Sud-tibbiy toksikologiya, Toksikologik
// kimyo, Apparatlar bilan ishlash. Guruh nomida «kurs», «toifa», «KTP»/yil yo‘q.

import 'class_topic_duplicates.dart';

export 'class_topic_duplicates.dart' show classTopicCoveredBy;

/// Mavzular guruhi (fakultet yoki fan): barqaror kalit (savollar banki guruh
/// id’si bilan bir xil; faqat ichki kalit, ekranda ko‘rinmaydi), tartib, uch
/// tilli nom.
class ClassTopicGroupDef {
  const ClassTopicGroupDef(this.id, this.order, this.titles);

  final String id;
  final int order;
  final Map<String, String> titles;

  String title(String lang) => titles[lang] ?? titles['uz']!;
}

const classTopicGroupDefs = <ClassTopicGroupDef>[
  ClassTopicGroupDef('bioetika-2', 0, {
    'uz': 'Bioetika',
    'ru': 'Биоэтика',
    'en': 'Bioethics',
  }),
  ClassTopicGroupDef('sud-tibbiyoti-4-davolash', 1, {
    'uz': 'Davolash ishi',
    'ru': 'Лечебное дело',
    'en': 'General Medicine',
  }),
  ClassTopicGroupDef('sud-tibbiyoti-4-pediatriya', 2, {
    'uz': 'Pediatriya',
    'ru': 'Педиатрия',
    'en': 'Paediatrics',
  }),
  ClassTopicGroupDef('sud-tibbiyoti-5-tibbiy-profilaktika', 3, {
    'uz': 'Tibbiy profilaktika',
    'ru': 'Медико-профилактическое дело',
    'en': 'Preventive Medicine',
  }),
  ClassTopicGroupDef('ktp-2026-stomatologiya', 4, {
    'uz': 'Stomatologiya',
    'ru': 'Стоматология',
    'en': 'Dentistry',
  }),
  ClassTopicGroupDef('sud-tibbiyoti-ktp-2026', 5, {
    'uz': 'Sud tibbiyoti (umumiy mavzular)',
    'ru': 'Судебная медицина (общие темы)',
    'en': 'Forensic medicine (common topics)',
  }),
  ClassTopicGroupDef('sud-toksikologiya', 6, {
    'uz': 'Sud-tibbiy toksikologiya',
    'ru': 'Судебно-медицинская токсикология',
    'en': 'Forensic toxicology',
  }),
  ClassTopicGroupDef('toksikologik-kimyo', 7, {
    'uz': 'Toksikologik kimyo',
    'ru': 'Токсикологическая химия',
    'en': 'Toxicological chemistry',
  }),
  ClassTopicGroupDef('apparatlar', 8, {
    'uz': 'Apparatlar bilan ishlash',
    'ru': 'Работа на приборах',
    'en': 'Working with instruments',
  }),
];

ClassTopicGroupDef? classTopicGroupDef(String id) {
  for (final g in classTopicGroupDefs) {
    if (g.id == id) return g;
  }
  return null;
}

/// Mavzu id prefiksi → guruh (tools/class_quiz/import_quiz_bank.py bilan bir xil).
final _prefixRules = <(RegExp, String)>[
  (RegExp(r'^\d+-kurs-bioetika-'), 'bioetika-2'),
  (RegExp(r'^(\d+-kurs|ktp26)-davolash-'), 'sud-tibbiyoti-4-davolash'),
  (RegExp(r'^(\d+-kurs|ktp26)-pediatriya-'), 'sud-tibbiyoti-4-pediatriya'),
  (
    RegExp(r'^(\d+-kurs|ktp26)-tibbiy-profilaktika-'),
    'sud-tibbiyoti-5-tibbiy-profilaktika',
  ),
  (RegExp(r'^(\d+-kurs|ktp26)-stomatologiya-'), 'ktp-2026-stomatologiya'),
  (RegExp(r'^ktp26-u-'), 'sud-tibbiyoti-ktp-2026'),
  (RegExp(r'^sud-toks-'), 'sud-toksikologiya'),
  (RegExp(r'^toks-'), 'toksikologik-kimyo'),
  (RegExp(r'^instr-'), 'apparatlar'),
];

/// Server kursi (lesson_topics.course, masalan «Davolash ishi fakulteti») →
/// guruh. Tartib muhim: «Sud-tibbiy toksikologiya» «toksikologik»dan oldin.
const _courseKeywords = <(String, String)>[
  ('bioetik', 'bioetika-2'),
  ('davolash', 'sud-tibbiyoti-4-davolash'),
  ('pediatr', 'sud-tibbiyoti-4-pediatriya'),
  ('profilakt', 'sud-tibbiyoti-5-tibbiy-profilaktika'),
  ('stomatolog', 'ktp-2026-stomatologiya'),
  ('sud-tibbiy toksikolog', 'sud-toksikologiya'),
  ('toksikologik', 'toksikologik-kimyo'),
  ('apparat', 'apparatlar'),
  ('sud tibbiyoti', 'sud-tibbiyoti-ktp-2026'),
];

/// Mavzuning guruhi: id prefiksi → bank guruhi → server kursi. `null` —
/// noma’lum (chaqiruvchi kurs nomi yoki «Boshqa mavzular»ni qo‘llaydi).
String? classTopicGroupOf(
  String baseId, {
  String? bankGroupId,
  String course = '',
}) {
  for (final (rx, id) in _prefixRules) {
    if (rx.hasMatch(baseId)) return id;
  }
  // Bank guruh id’lari — shu ro‘yxatdagi id’lar (eski kalitlar saqlangan:
  // «Umumiy test»/«Oraliq nazorat» manba kalitlari o‘zgarmaydi).
  if (bankGroupId != null && classTopicGroupDef(bankGroupId) != null) {
    return bankGroupId;
  }
  final c = course.trim().toLowerCase();
  if (c.isEmpty) return null;
  for (final (kw, id) in _courseKeywords) {
    if (c.contains(kw)) return id;
  }
  return null;
}

/// Mavzu ro‘yxatda boshqa mavzu bilan takrorlanadimi («Darslar»da yashirin
/// takror yoki `ktp26-u-*` ning fakultetdagi nusxasi ro‘yxatda bor).
bool classTopicIsCovered(String baseId, Set<String> presentBaseIds) {
  final by = classTopicCoveredBy[baseId];
  return by != null && by.any(presentBaseIds.contains);
}

final _ktpRx = RegExp(r'^ktp26-[a-z-]+-([A-Za-z]*)(\d+)$');
final _leadRx = RegExp(r'^(?:toks|instr|sud-toks)-(\d+)');
final _tailRx = RegExp(r'(\d+)$');
const _ktpPart = {'M': 0, 'A': 100, 'MT': 200, 'MR': 300};

/// Guruh ichidagi tartib («Darslar» kabi): joriy reja (ma’ruza, amaliy,
/// mustaqil, qo‘shimcha), keyin eski rejadagi mavzular — raqami bo‘yicha.
int classTopicSortKey(String baseId) {
  final k = _ktpRx.firstMatch(baseId);
  if (k != null) {
    return int.parse(k.group(2)!) + (_ktpPart[k.group(1)] ?? 0);
  }
  final lead = _leadRx.firstMatch(baseId);
  if (lead != null) return int.parse(lead.group(1)!);
  final tail = _tailRx.firstMatch(baseId);
  final n = tail == null ? 0 : int.parse(tail.group(1)!);
  final kurs = RegExp(r'^(\d+)-kurs-').firstMatch(baseId);
  return kurs == null ? n : 1000 * int.parse(kurs.group(1)!) + n;
}

final _stubRx = RegExp(
  r'^\W*(amaliy\s+mashg.?ulot|ma.?ruza|seminar)\W*$',
  caseSensitive: false,
);
final _codeTailRx = RegExp(r'\s*\((?:[A-Z]{1,3}\d{1,3}|\d+-kurs[^)]*)\)\s*$');

/// Ko‘rsatiladigan mavzu nomi: serverdagi nomi faqat «Amaliy mashg‘ulot»
/// bo‘lsa — o‘quv rejadagi to‘liq nom; oxiridagi kod («(A7)», «(4-kurs, …)»)
/// olib tashlanadi — ro‘yxatda kod emas, mavzu nomi.
String classTopicDisplayTitle(String baseId, String title) {
  var t = title.trim();
  if (_stubRx.hasMatch(t)) t = classTopicPlanTitles[baseId] ?? t;
  final cleaned = t.replaceFirst(_codeTailRx, '').trim();
  return cleaned.isEmpty ? t : cleaned;
}

/// Bir xil mavzuni aniqlash uchun nom kaliti (tutuq belgilari, bo‘shliq,
/// oxirgi nuqta farqi hisobga olinmaydi).
String classTopicTitleKey(String title) => title
    .toLowerCase()
    .replaceAll(RegExp('[‘’ʻʼ`´\']'), "'")
    .replaceAll(RegExp(r'\s+'), ' ')
    .replaceAll(RegExp(r'[\s.…;:,]+$'), '')
    .trim();
