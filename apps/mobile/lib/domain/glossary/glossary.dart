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

/// Qisqartmaning qisqa izohi (`content/terminology/abbreviation_glossary.json`).
///
/// Tahririy ta’rif — terminolog tekshirmaguncha `machine_draft`
/// ([TranslationStatus]); hech qachon tasdiqlangan deb ko‘rsatilmaydi.
@immutable
class AbbreviationNote {
  const AbbreviationNote({
    required this.id,
    required this.abbreviation,
    required this.expansion,
    required this.explanation,
    required this.status,
    this.relatedTermId,
  });

  static AbbreviationNote? fromJson(Object? j) {
    if (j is! Map) return null;
    Map<String, String> tri(Object? v) => {
      if (v is Map)
        for (final e in v.entries)
          if ('${e.value}'.trim().isNotEmpty) '${e.key}': '${e.value}'.trim(),
    };
    final id = '${j['id'] ?? ''}'.trim();
    final abbr = '${j['abbreviation'] ?? ''}'.trim();
    if (id.isEmpty || abbr.isEmpty) return null;
    return AbbreviationNote(
      id: id,
      abbreviation: abbr,
      expansion: tri(j['expansion']),
      explanation: tri(j['explanation']),
      status: {
        for (final e in tri(j['status']).entries)
          e.key: switch (e.value) {
            'reviewed' => TranslationStatus.reviewed,
            'translated' => TranslationStatus.translated,
            _ => TranslationStatus.machineDraft,
          },
      },
      relatedTermId: (j['related_term_id'] as String?)?.trim(),
    );
  }

  static List<AbbreviationNote> listFromJson(Object? j) => [
    if (j is Map)
      for (final t in (j['terms'] as List? ?? const [])) ?fromJson(t),
  ];

  final String id;
  final String abbreviation;
  final Map<String, String> expansion;
  final Map<String, String> explanation;
  final Map<String, TranslationStatus> status;
  final String? relatedTermId;

  /// Lug‘at yozuvi: «PMI — o‘limdan keyin o‘tgan vaqt oralig‘i».
  TermTranslation toTranslation() => TermTranslation(
    id: id,
    kind: ScientificTermKind.abbreviation,
    original: abbreviation,
    originalLang: 'en',
    canonical: abbreviation,
    localized: {
      for (final e in expansion.entries) e.key: '$abbreviation — ${e.value}',
    },
    status: status,
  );
}

@immutable
class GlossaryTerm {
  const GlossaryTerm(this.translation, {this.cardIds = const [], this.note});

  /// Ko‘rsatish tartibi.
  static const languages = ['uz', 'ru', 'en'];

  final TermTranslation translation;

  /// Atama ishlatilgan yo‘riqnoma kartalari (kartadagi `term_ids` dan).
  final List<String> cardIds;

  /// Qisqartma bo‘lsa — qisqa izoh (uch tilda).
  final AbbreviationNote? note;

  /// Tildagi qisqa izoh, bo‘lsa.
  String? explanationIn(String lang) =>
      note?.explanation[lang] ?? note?.explanation['en'];

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
  const Glossary._(
    this.terms,
    this._byId,
    this._cardTerms, [
    this._byAbbreviation = const {},
  ]);

  factory Glossary.build(
    Iterable<TermTranslation> translations,
    GuidelineBundle guidelines, {
    Iterable<AbbreviationNote> abbreviations = const [],
  }) {
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
    final abbr = [
      for (final n in abbreviations)
        if (!known.contains(n.id))
          GlossaryTerm(
            n.toTranslation(),
            note: n,
            cardIds: List.unmodifiable(
              cardsOf[n.relatedTermId] ?? const <String>[],
            ),
          ),
    ];
    final terms = [
      for (final t in translations)
        GlossaryTerm(t, cardIds: List.unmodifiable(cardsOf[t.id] ?? const [])),
      ...abbr,
    ];
    return Glossary._(
      List.unmodifiable(terms),
      {for (final t in terms) t.id: t},
      cardTerms,
      {for (final t in abbr) t.note!.abbreviation: t},
    );
  }

  static const empty = Glossary._([], {}, {});

  static const _normalizer = SearchNormalizer();

  final List<GlossaryTerm> terms;
  final Map<String, GlossaryTerm> _byId;
  final Map<String, List<String>> _cardTerms;
  final Map<String, GlossaryTerm> _byAbbreviation;

  /// Izohi bor qisqartmalar (matnda bosiladigan havola uchun).
  Iterable<String> get abbreviations => _byAbbreviation.keys;

  GlossaryTerm? byAbbreviation(String abbr) => _byAbbreviation[abbr];

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
