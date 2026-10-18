import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// O‘zbekcha oy nomlari (lotin, kichik harf).
const _uzMonths = [
  'yanvar',
  'fevral',
  'mart',
  'aprel',
  'may',
  'iyun',
  'iyul',
  'avgust',
  'sentabr',
  'oktabr',
  'noyabr',
  'dekabr',
];

/// Sana — **har doim yil bilan** (huquqiy va ilmiy sanalar uchun muhim):
/// EN «Mar 1, 2018», RU «1 мар. 2018 г.», UZ «2018-yil 1-mart».
/// (MaterialLocalizations.formatMediumDate yilni ko‘rsatmaydi.)
String feDate(BuildContext context, DateTime d) {
  final locale = Localizations.localeOf(context);
  if (locale.languageCode == 'uz') return feDateUz(d);
  return DateFormat.yMMMd(locale.toLanguageTag()).format(d);
}

/// «2026-yil 4-oktabr» — o‘zbek adabiy yozuvi (CLDR formati o‘rniga).
String feDateUz(DateTime d) =>
    '${d.year}-yil ${d.day}-${_uzMonths[d.month - 1]}';

/// O‘zbekcha qisqa oy nomlari: «20-okt, 18:00».
const _uzMonthsShort = [
  'yan',
  'fev',
  'mar',
  'apr',
  'may',
  'iyn',
  'iyl',
  'avg',
  'sen',
  'okt',
  'noy',
  'dek',
];

/// Test muddati — qisqa, soat bilan, qurilma vaqt mintaqasida:
/// UZ «20-okt, 18:00», RU «20 окт., 18:00», EN «Oct 20, 18:00».
String feDueShort(BuildContext context, DateTime d) {
  final l = d.toLocal();
  final locale = Localizations.localeOf(context);
  final hm = DateFormat.Hm().format(l);
  if (locale.languageCode == 'uz') {
    return '${l.day}-${_uzMonthsShort[l.month - 1]}, $hm';
  }
  return '${DateFormat.MMMd(locale.toLanguageTag()).format(l)}, $hm';
}
