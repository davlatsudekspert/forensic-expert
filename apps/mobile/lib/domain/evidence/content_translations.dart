import 'package:fe_content_schema/fe_content_schema.dart' show TextTranslation;
import 'package:flutter/foundation.dart';

/// Kontent tarjimalari — yagona o‘qish API’si (Phase C, 2026-10-09).
///
/// Qoidalar (egasi talabi «Uch tilli kontent», CLAUDE.md):
/// * foydalanuvchi **avval o‘z tilidagi** matnni ko‘radi; asl iqtibos/hujjat
///   «Asl matn» orqali ochiladi va hech qachon o‘zgartirilmaydi;
/// * tarjima holati shu tilda ko‘rsatiladi; faqat [ContentTranslationStatus.reviewed]
///   va [ContentTranslationStatus.official] «tekshirilmagan» belgisini olib
///   tashlay oladi — ilova kodi bu statuslarni **hech qachon o‘rnatmaydi**,
///   ular faqat paket ma’lumotidan keladi;
/// * tilda tarjima bo‘lmasa — bu ochiq aytiladi va asl matn ko‘rsatiladi
///   (inglizcha matn hech qachon UI tilidagi matn sifatida ko‘rsatilmaydi);
/// * tarjima qilingan paytdagi asl matn xeshi ([ContentTranslationRow.sourceSha256])
///   joriy asl matnga mos kelmasa — tarjima eskirgan va ishlatilmaydi;
/// * noma’lum tur (kind) yoki status — **xato emas**, shunchaki e’tiborsiz
///   (yangi paket eski ilovani yiqitmasligi kerak).
///
/// Ma’lumot shartnomasi (turlar, ID shakllari): `docs/L10N_DATA_CONTRACT.md`.
enum ContentTranslationStatus {
  machineDraft('machine_draft'),
  terminologyChecked('terminology_checked'),
  claimChecked('claim_checked'),
  reviewed('reviewed'),
  official('official');

  const ContentTranslationStatus(this.code);

  final String code;

  /// Noma’lum kod — `null` (qator e’tiborsiz qoldiriladi).
  static ContentTranslationStatus? tryParse(String? code) {
    for (final s in values) {
      if (s.code == code) return s;
    }
    return null;
  }

  /// Inson tekshirgan yoki rasmiy matn — «tekshirilmagan» belgisi kerak emas.
  bool get isHumanVerified => this == reviewed || this == official;
}

/// `text_translations.target_type` (va ixtiyoriy `localized_texts`) turlari.
///
/// Ilova o‘qiydigan turlar shu yerda; ro‘yxatda yo‘q tur ham saqlanadi
/// (`resolve` uni so‘ramaydi), lekin hech qachon xato tashlamaydi.
abstract final class ContentTextKind {
  // Mavjud sxema v7 (paketda bor; CHECK shu uchtasiga ruxsat beradi).
  static const claimExcerpt = 'claim_excerpt';
  static const ruleExcerpt = 'rule_excerpt';
  static const researchTitle = 'research_title';

  // Phase C — ilova o‘qishga tayyor; paketga yozish uchun sxema/CHECK
  // kengaytmasi kerak (docs/L10N_DATA_CONTRACT.md, «Yangi turlar»).
  static const sourceTitle = 'source_title';
  static const standardTitle = 'standard_title';
  static const standardNote = 'standard_note';

  /// ID: `<conflict_id>#question` yoki `<conflict_id>#note`.
  static const conflictText = 'conflict_text';
  static const contextText = 'context_text';
  static const listItem = 'list_item';
  static const metaboliteName = 'metabolite_name';
  static const screeningField = 'screening_field';
  static const entityNote = 'entity_note';
  static const ruleConvention = 'rule_convention';
  static const imageCaption = 'image_caption';
  static const aiChunk = 'ai_chunk';

  /// Mavzu kartasining qisqa tushuntirishi (manbali da’volardan olingan,
  /// `derived`); asl matn — kartadagi da’vo iqtibosi.
  static const topicBody = 'topic_body';

  /// Usul kartasining qisqa tushuntirishi (shartlari [topicBody] bilan bir xil).
  static const methodBody = 'method_body';

  /// Asl matnning tarjimasi emas, balki undan tuzilgan tushuntirish: asl
  /// matn bilan bir tilda ham ko‘rsatiladi (xesh baribir mos bo‘lishi shart).
  static const derived = {topicBody, methodBody};

  static const known = {
    claimExcerpt,
    ruleExcerpt,
    researchTitle,
    sourceTitle,
    standardTitle,
    standardNote,
    conflictText,
    topicBody,
    methodBody,
    contextText,
    listItem,
    metaboliteName,
    screeningField,
    entityNote,
    ruleConvention,
    imageCaption,
    aiChunk,
  };
}

/// UI tillari (tarjima shu tillarga bo‘ladi).
const contentLanguages = {'uz', 'ru', 'en'};

/// `en`, `EN`, `en-GB`, `eng` → `en`; bo‘sh → [fallback].
String normalizeLang(String? code, {String fallback = 'en'}) {
  final c = code?.trim().toLowerCase() ?? '';
  if (c.isEmpty) return fallback;
  return switch (c) {
    'eng' => 'en',
    'rus' => 'ru',
    'uzb' => 'uz',
    'deu' || 'ger' => 'de',
    _ => c.length > 2 ? c.substring(0, 2) : c,
  };
}

/// Bitta tarjima qatori (paketdan, tolerant o‘qilgan).
@immutable
class ContentTranslationRow {
  const ContentTranslationRow({
    required this.kind,
    required this.id,
    required this.lang,
    required this.sourceSha256,
    required this.text,
    required this.status,
    this.sourceClaims = const [],
  });

  final String kind;
  final String id;
  final String lang;
  final String sourceSha256;
  final String text;
  final ContentTranslationStatus status;

  /// Tuzilgan tushuntirish ([ContentTextKind.derived]) qaysi da’volardan
  /// olingani; asl matn — shu da’vo iqtiboslari shu tartibda, bo‘sh joy
  /// bilan qo‘shilgan.
  final List<String> sourceClaims;

  /// Xom qiymatlardan; yaroqsiz/noma’lum bo‘lsa — `null` (xato tashlamaydi).
  static ContentTranslationRow? tryParse({
    required Object? kind,
    required Object? id,
    required Object? lang,
    required Object? sourceSha256,
    required Object? text,
    required Object? status,
    Object? sourceClaims,
  }) {
    if (kind is! String || kind.isEmpty) return null;
    if (id is! String || id.isEmpty) return null;
    if (lang is! String || sourceSha256 is! String || text is! String) {
      return null;
    }
    final l = normalizeLang(lang, fallback: '');
    if (!contentLanguages.contains(l)) return null;
    if (sourceSha256.length != 64) return null;
    final st = ContentTranslationStatus.tryParse(status as String?);
    if (st == null) return null;
    final t = text.trim();
    if (t.isEmpty) return null;
    return ContentTranslationRow(
      kind: kind,
      id: id,
      lang: l,
      sourceSha256: sourceSha256.toLowerCase(),
      text: t,
      status: st,
      sourceClaims: [
        if (sourceClaims is List)
          for (final c in sourceClaims)
            if (c is String && c.isNotEmpty) c,
      ],
    );
  }
}

/// Ekranda ko‘rsatiladigan natija: avval [text] ([textLang] tilida), asl
/// matn — [original] ([originalLang]).
@immutable
class LocalizedContent {
  const LocalizedContent({
    required this.text,
    required this.textLang,
    required this.original,
    required this.originalLang,
    required this.requestedLang,
    this.status,
  });

  /// Tarjimasiz — asl matn.
  const LocalizedContent.original(
    String text, {
    required String originalLang,
    required String requestedLang,
  }) : this(
         text: text,
         textLang: originalLang,
         original: text,
         originalLang: originalLang,
         requestedLang: requestedLang,
       );

  /// Birinchi ko‘rsatiladigan matn.
  final String text;
  final String textLang;

  /// Asl (manba) matn — dalil, o‘zgartirilmaydi.
  final String original;
  final String originalLang;

  /// UI tili.
  final String requestedLang;

  /// Tarjima holati; `null` — [text] asl matnning o‘zi.
  final ContentTranslationStatus? status;

  bool get isTranslation => status != null;

  /// Matn UI tilida (tarjima yoki asl matn shu tilda).
  bool get inRequestedLanguage => textLang == requestedLang;

  /// UI tilida matn yo‘q — asl (boshqa til) ko‘rsatiladi; UI buni ochiq
  /// aytishi shart.
  bool get missingTranslation => !inRequestedLanguage;

  /// «tekshirilmagan» belgisi kerak.
  bool get needsReviewLabel => status != null && !status!.isHumanVerified;

  /// Bir nechta qismni bitta qatorga birlashtirish (masalan «holat ·
  /// populyatsiya · hajm»). Biror qism UI tilida bo‘lmasa — hammasi asl
  /// tilda (aralash tilli qator chiqmasligi uchun); holat — eng past.
  static LocalizedContent join(
    List<LocalizedContent> parts, {
    String separator = ' · ',
    required String requestedLang,
  }) {
    if (parts.isEmpty) {
      return LocalizedContent.original(
        '',
        originalLang: requestedLang,
        requestedLang: requestedLang,
      );
    }
    if (parts.length == 1) return parts.single;
    final original = parts.map((p) => p.original).join(separator);
    final origLang = parts.first.originalLang;
    if (parts.any((p) => p.missingTranslation)) {
      return LocalizedContent(
        text: original,
        textLang: origLang,
        original: original,
        originalLang: origLang,
        requestedLang: requestedLang,
      );
    }
    final statuses = [
      for (final p in parts)
        if (p.status != null) p.status!,
    ]..sort((a, b) => a.index.compareTo(b.index));
    return LocalizedContent(
      text: parts.map((p) => p.text).join(separator),
      textLang: requestedLang,
      original: original,
      originalLang: origLang,
      requestedLang: requestedLang,
      status: statuses.firstOrNull,
    );
  }
}

/// Tarjimalar indeksi: `(kind, id, lang)` → qator.
@immutable
class ContentTranslations {
  const ContentTranslations._(this._byKey, this._byHash);

  static const empty = ContentTranslations._({}, {});

  final Map<String, ContentTranslationRow> _byKey;

  /// `kind|sha256|lang` → qator (bir xil asl matn uchun zaxira qidiruv).
  final Map<String, ContentTranslationRow> _byHash;

  factory ContentTranslations.of(Iterable<ContentTranslationRow> rows) {
    final map = <String, ContentTranslationRow>{};
    final byHash = <String, ContentTranslationRow>{};
    void put(
      Map<String, ContentTranslationRow> m,
      String key,
      ContentTranslationRow r,
    ) {
      final prev = m[key];
      // Bir kalitda ikki manba bo‘lsa — yuqoriroq holat ustun.
      if (prev == null || r.status.index > prev.status.index) m[key] = r;
    }

    for (final r in rows) {
      put(map, _key(r.kind, r.id, r.lang), r);
      put(byHash, '${r.kind}|${r.sourceSha256}|${r.lang}', r);
    }
    return ContentTranslations._(map, byHash);
  }

  /// Ikki indeksni birlashtiradi (masalan, imzolangan paket + ilova
  /// asset’idagi yon fayl).
  ContentTranslations merge(ContentTranslations other) =>
      ContentTranslations.of([..._byKey.values, ...other._byKey.values]);

  /// `fe-localized-texts/1` yon fayli (`content/pilot/translations/
  /// localized_texts_d.json` → ilova asset’i). Imzolanmagan manba bo‘lgani
  /// uchun **faqat** avtomatik statuslar qabul qilinadi (`machine_draft`,
  /// `terminology_checked`, `claim_checked`); `reviewed`/`official` faqat
  /// imzolangan paketdan keladi. Noma’lum format/qator — e’tiborsiz.
  static List<ContentTranslationRow> rowsFromLocalizedTextsJson(Object? json) {
    if (json is! Map || json['format'] != 'fe-localized-texts/1') {
      return const [];
    }
    final records = json['records'];
    if (records is! List) return const [];
    final out = <ContentTranslationRow>[];
    for (final rec in records) {
      if (rec is! Map) continue;
      final status = ContentTranslationStatus.tryParse(
        rec['status'] as String?,
      );
      if (status == null || status.isHumanVerified) continue;
      final texts = rec['text'];
      if (texts is! Map) continue;
      for (final e in texts.entries) {
        final row = ContentTranslationRow.tryParse(
          kind: rec['target_type'],
          id: rec['target_id'],
          lang: e.key,
          sourceSha256: rec['source_sha256'],
          text: e.value,
          status: rec['status'],
          sourceClaims: rec['source_claims'],
        );
        if (row != null) out.add(row);
      }
    }
    return out;
  }

  static String _key(String kind, String id, String lang) => '$kind|$id|$lang';

  bool get isEmpty => _byKey.isEmpty;
  int get length => _byKey.length;

  /// Tuzilgan tushuntirishning manba da’volari (har qanday tildagi qatordan).
  List<String> sourceClaimsOf(String kind, String id) {
    for (final l in contentLanguages) {
      final r = _byKey[_key(kind, id, l)];
      if (r != null && r.sourceClaims.isNotEmpty) return r.sourceClaims;
    }
    return const [];
  }

  /// Shu turdagi qatorlar soni (diagnostika, test).
  int countOf(String kind) => _byKey.values.where((r) => r.kind == kind).length;

  /// [source] — ekrandagi asl matn; [originalLang] — uning tili.
  ///
  /// * `lang == originalLang` → asl matn;
  /// * mos (xeshi to‘g‘ri) tarjima bor → tarjima + status;
  /// * aks holda → asl matn, `missingTranslation == true`.
  LocalizedContent resolve(
    String kind,
    String id, {
    required String source,
    required String lang,
    String? originalLang,
    Set<String> sameTextKinds = const {},
  }) {
    final ui = normalizeLang(lang);
    final orig = normalizeLang(originalLang);
    final original = LocalizedContent.original(
      source,
      originalLang: orig,
      requestedLang: ui,
    );
    final derived = ContentTextKind.derived.contains(kind);
    if ((ui == orig && !derived) || source.trim().isEmpty) return original;
    final hash = TextTranslation.hashOf(source);
    var row = _byKey[_key(kind, id, ui)];
    if (row != null && row.sourceSha256 != hash) row = null;
    // Bir xil asl matn (masalan, metabolit nomi da’vo ro‘yxatida va
    // metabolit munosabatida) — boshqa ID’dagi tarjima ham to‘g‘ri:
    // xesh aynan mos bo‘lishi shart.
    if (row == null && sameTextKinds.isNotEmpty) {
      for (final k in [kind, ...sameTextKinds]) {
        row = _byHash['$k|$hash|$ui'];
        if (row != null) break;
      }
    }
    if (row == null) return original;
    if (!derived && row.text == source.trim()) return original;
    return LocalizedContent(
      text: row.text,
      textLang: ui,
      original: source,
      originalLang: orig,
      requestedLang: ui,
      status: row.status,
    );
  }

  /// Faqat tarjima matni (yoki `null`) — eski chaqiruvlar uchun.
  String? lookup(
    String kind,
    String id, {
    required String source,
    required String lang,
    String? originalLang,
  }) {
    final r = resolve(
      kind,
      id,
      source: source,
      lang: lang,
      originalLang: originalLang,
    );
    return r.isTranslation ? r.text : null;
  }
}

/// Muallif yozgan tilga bog‘liq xarita (`{uz, ru, en}`, masalan hujjat
/// nomi, idora nomi) uchun bir xil natija.
///
/// Tartib: [lang] → [originalLang] (asl/rasmiy) → `en` → birinchi qiymat.
/// [translationStatus] — xaritadagi tarjimalar holati (masalan instrument
/// `translation_status`); `null` yoki noma’lum bo‘lsa — `machine_draft`
/// deb olinadi (tekshirilmagan deb ko‘rsatiladi — hech qachon yuqoriroq emas).
final _cyrillic = RegExp('[Ѐ-ӿ]');

LocalizedContent resolveLocalizedMap(
  Map<String, String> values, {
  required String lang,
  String? originalLang,
  String? translationStatus,
  String fallbackText = '',
}) {
  final ui = normalizeLang(lang);
  String? pick(String l) {
    final v = values[l]?.trim();
    return v == null || v.isEmpty ? null : v;
  }

  final firstKey = values.keys.firstWhere(
    (k) => !k.startsWith('_') && pick(k) != null,
    orElse: () => '',
  );
  final orig = normalizeLang(
    originalLang != null && pick(normalizeLang(originalLang)) != null
        ? originalLang
        : (pick('en') != null ? 'en' : (firstKey.isEmpty ? 'en' : firstKey)),
  );
  final original = pick(orig) ?? fallbackText;
  final mine = pick(ui);
  if (mine == null || ui == orig) {
    // Kalit noto‘g‘ri bo‘lsa ham (masalan kirillcha nom `en` ostida),
    // «asl tili» yozuvi matnning haqiqiy yozuviga mos bo‘lsin.
    final shownLang = orig != 'ru' && _cyrillic.hasMatch(original)
        ? 'ru'
        : orig;
    return LocalizedContent.original(
      original,
      originalLang: shownLang,
      requestedLang: ui,
    );
  }
  return LocalizedContent(
    text: mine,
    textLang: ui,
    original: original,
    originalLang: orig,
    requestedLang: ui,
    status:
        ContentTranslationStatus.tryParse(translationStatus) ??
        ContentTranslationStatus.machineDraft,
  );
}

/// Bibliografik yozuvning (sud / yo‘riqnoma adabiyoti) ixtiyoriy tilga
/// bog‘liq nomlari: `titles: {uz, ru, en}` va `title_status: {uz: official |
/// unofficial_translation | machine_draft | reviewed}`. Asl `title` va
/// iqtibos o‘zgarmaydi. Noto‘g‘ri shakl — bo‘sh (xato emas).
@immutable
class ReferenceTitles {
  const ReferenceTitles({this.titles = const {}, this.status = const {}});

  factory ReferenceTitles.fromJson(Map<String, Object?> j) {
    Map<String, String> map(Object? v) => {
      if (v is Map)
        for (final e in v.entries)
          if (e.key is String &&
              e.value is String &&
              (e.value as String).trim().isNotEmpty)
            normalizeLang(e.key as String): (e.value as String).trim(),
    };
    return ReferenceTitles(
      titles: map(j['titles']),
      status: map(j['title_status']),
    );
  }

  static const empty = ReferenceTitles();

  final Map<String, String> titles;
  final Map<String, String> status;

  /// UI tilidagi nom (bo‘lmasa — `null`).
  String? titleIn(String lang) => titles[normalizeLang(lang)];

  /// UI tilidagi nom rasmiymi.
  bool isOfficialIn(String lang) => status[normalizeLang(lang)] == 'official';

  /// UI tilidagi nom inson tekshirgan tarjimami.
  bool isReviewedIn(String lang) => status[normalizeLang(lang)] == 'reviewed';
}
