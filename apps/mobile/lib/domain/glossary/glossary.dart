/// «Ilmiy lug‘at» — paketdagi `term_translations` (uz/ru/en atamalar).
///
/// Tarjimalar holati ma’lumotdan olinadi: `machine_draft` hech qachon
/// tasdiqlangan deb ko‘rsatilmaydi. Atama → yo‘riqnoma kartasi bog‘lanishi
/// faqat kartadagi aniq `term_ids` ro‘yxatidan (matndan taxmin qilinmaydi).
library;

import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:fe_search_core/fe_search_core.dart';
import 'package:flutter/foundation.dart';

import '../guidelines/guideline_models.dart';

@immutable
class GlossaryTerm {
  const GlossaryTerm(this.translation, {this.cardIds = const []});

  /// Ko‘rsatish tartibi.
  static const languages = ['uz', 'ru', 'en'];

  final TermTranslation translation;

  /// Atama ishlatilgan yo‘riqnoma kartalari (kartadagi `term_ids` dan).
  final List<String> cardIds;

  String get id => translation.id;
  ScientificTermKind get kind => translation.kind;

  /// Tildagi atama; bo‘lmasa — kanonik (ingliz) atama.
  String textIn(String lang) {
    final v = translation.localized[lang]?.trim();
    if (v != null && v.isNotEmpty) return v;
    return translation.canonical;
  }

  /// Joriy tildan tashqari tillar (uz → ru → en tartibida), matni joriy
  /// tildagidan farq qiladiganlari (masalan «GC-MS» takrorlanmaydi).
  List<(String, String)> othersFor(String lang) {
    final main = textIn(lang).toLowerCase();
    final seen = <String>{main};
    return [
      for (final l in languages)
        if (l != lang && seen.add(textIn(l).toLowerCase())) (l, textIn(l)),
    ];
  }

  TranslationStatus? statusIn(String lang) => translation.status[lang];

  /// Kamida bitta til mashina tarjimasi (tekshirilmagan) bo‘lsa — true.
  bool get hasMachineDraft =>
      translation.status.isEmpty ||
      translation.status.values.contains(TranslationStatus.machineDraft);

  /// Barcha tillar terminolog tomonidan tekshirilgan.
  bool get isReviewed =>
      translation.status.isNotEmpty &&
      translation.status.values.every((s) => s == TranslationStatus.reviewed);

  /// Filtr va qidiruv uchun barcha ko‘rinishlar.
  Iterable<String> get searchTexts => {
    ...translation.localized.values,
    translation.canonical,
    translation.original,
  }.where((t) => t.trim().isNotEmpty);
}

@immutable
class Glossary {
  const Glossary._(this.terms, this._byId, this._cardTerms);

  factory Glossary.build(
    Iterable<TermTranslation> translations,
    GuidelineBundle guidelines,
  ) {
    final cardsOf = <String, List<String>>{};
    final cardTerms = <String, List<String>>{};
    final known = {for (final t in translations) t.id};
    for (final card in guidelines.cards) {
      for (final tid in card.termIds) {
        if (!known.contains(tid)) continue;
        cardsOf.putIfAbsent(tid, () => []).add(card.id);
        cardTerms.putIfAbsent(card.id, () => []).add(tid);
      }
    }
    final terms = [
      for (final t in translations)
        GlossaryTerm(t, cardIds: List.unmodifiable(cardsOf[t.id] ?? const [])),
    ];
    return Glossary._(List.unmodifiable(terms), {
      for (final t in terms) t.id: t,
    }, cardTerms);
  }

  static const empty = Glossary._([], {}, {});

  static const _normalizer = SearchNormalizer();

  final List<GlossaryTerm> terms;
  final Map<String, GlossaryTerm> _byId;
  final Map<String, List<String>> _cardTerms;

  bool get isEmpty => terms.isEmpty;

  GlossaryTerm? byId(String id) => _byId[id];

  /// Kartadagi atamalar (kartadagi tartibda).
  List<GlossaryTerm> termsOfCard(String cardId) => [
    for (final id in _cardTerms[cardId] ?? const <String>[]) ?_byId[id],
  ];

  /// Joriy tildagi atama bo‘yicha alifbo tartibi; [query] uchala tilda,
  /// kanonik va asl ko‘rinishda qidiriladi (registr/diakritikaga befarq).
  List<GlossaryTerm> list(String lang, {String query = ''}) {
    final key = _normalizer.searchKey(query);
    final out = [
      for (final t in terms)
        if (key.isEmpty ||
            t.searchTexts.any((s) => _normalizer.searchKey(s).contains(key)))
          t,
    ];
    String sortKey(GlossaryTerm t) => t.textIn(lang).toLowerCase();
    out.sort((a, b) => sortKey(a).compareTo(sortKey(b)));
    return out;
  }
}
