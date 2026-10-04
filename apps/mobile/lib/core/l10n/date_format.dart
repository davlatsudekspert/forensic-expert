import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// Sana — **har doim yil bilan** (huquqiy va ilmiy sanalar uchun muhim):
/// EN «Mar 1, 2018», RU «1 мар. 2018 г.», UZ mahalliy CLDR formati.
/// (MaterialLocalizations.formatMediumDate yilni ko‘rsatmaydi.)
String feDate(BuildContext context, DateTime d) =>
    DateFormat.yMMMd(Localizations.localeOf(context).toLanguageTag()).format(d);
