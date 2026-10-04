import 'dart:convert';

import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:meta/meta.dart';

/// Kutubxona yozuvi (modda, metabolit, transformatsiya mahsuloti).
@immutable
class SubstanceRecord {
  const SubstanceRecord({
    required this.substanceId,
    required this.canonicalName,
    required this.entityKind,
    required this.tierAccess,
    required this.names,
    required this.translationStatus,
    this.molecularFormula,
    this.synonyms = const [],
  });

  final String substanceId;
  final String canonicalName;
  final String entityKind;

  /// `free` — bepul demo; `pro` — Lifetime.
  final String tierAccess;
  final String? molecularFormula;
  final Map<String, String> names;
  final Map<String, String> translationStatus;
  final List<String> synonyms;
}

/// Manba bilan birga keladigan, domen modelida bo‘lmagan qo‘shimcha
/// ma’lumot (reviewer uchun izohlar).
@immutable
class SourceExtras {
  const SourceExtras({this.notes});

  final String? notes;
}

/// `content/pilot/bundle.json` — to‘liq tahlil qilingan ko‘rinish.
@immutable
class PipelineBundle {
  const PipelineBundle({
    required this.packVersion,
    required this.channel,
    required this.content,
    required this.substances,
    required this.sourceExtras,
    required this.claimValues,
    required this.instrumentDatePrecision,
    this.componentVersions = const {},
    this.entityTiers = const {},
  });

  final String packVersion;
  final BundleChannel channel;
  final ContentBundle content;
  final List<SubstanceRecord> substances;
  final Map<String, SourceExtras> sourceExtras;

  /// claim_id → value (JSON) — `Claim.value` bilan bir xil, qulaylik uchun.
  final Map<String, Map<String, Object?>> claimValues;
  final Map<String, String> instrumentDatePrecision;

  /// Komponent versiyalari (`scientific`, `jurisdiction`) — ilova versiyasi
  /// bilan aralashtirilmaydi (`content_meta` ga yoziladi).
  final Map<String, String> componentVersions;

  /// Bilim obyekti ID → `free` / `student` / `pro`.
  final Map<String, String> entityTiers;

  /// Bilim obyektining kirish darajasi (berilmasa — `pro`).
  String tierOf(String entityId) => entityTiers[entityId] ?? 'pro';

  /// Boshqa kanal uchun nusxa (masalan, production’ga urinish testi).
  PipelineBundle withChannel(BundleChannel c) => PipelineBundle(
    packVersion: packVersion,
    channel: c,
    content: ContentBundle(
      channel: c,
      sources: content.sources,
      claims: content.claims,
      citations: content.citations,
      groups: content.groups,
      reviewers: content.reviewers,
      reviews: content.reviews,
      authorships: content.authorships,
      jurisdictions: content.jurisdictions,
      instruments: content.instruments,
      jurisdictionalRules: content.jurisdictionalRules,
      authorities: content.authorities,
      recipes: content.recipes,
      screeningTests: content.screeningTests,
      methods: content.methods,
      emergingIssues: content.emergingIssues,
      topics: content.topics,
    ),
    substances: substances,
    sourceExtras: sourceExtras,
    claimValues: claimValues,
    instrumentDatePrecision: instrumentDatePrecision,
    componentVersions: componentVersions,
    entityTiers: entityTiers,
  );
}

class BundleFormatException implements Exception {
  BundleFormatException(this.message);

  final String message;

  @override
  String toString() => 'BundleFormatException: $message';
}

/// `fe-bundle/2` (va eski `fe-bundle/1`) formatini o‘qiydi. Noma’lum enum
/// qiymati yoki yetishmayotgan majburiy maydon — xato (jim o‘tkazib yuborish
/// yo‘q).
///
/// `/2` qo‘shimchalari: `authorities`, `topics`, `recipes`,
/// `screening_tests`, `methods`, `emerging_issues`, `component_versions`,
/// instrument/rule kengaytirilgan maydonlari, `source_class`.
abstract final class BundleCodec {
  static const format = 'fe-bundle/2';
  static const supportedFormats = {'fe-bundle/1', format};

  static PipelineBundle decode(String json) {
    final root = jsonDecode(json);
    if (root is! Map<String, Object?>) {
      throw BundleFormatException('root must be an object');
    }
    if (!supportedFormats.contains(root['format'])) {
      throw BundleFormatException('unsupported format ${root['format']}');
    }
    final channel = BundleChannel.values.byName(_str(root, 'channel'));

    final sourceExtras = <String, SourceExtras>{};
    final sources = [
      for (final s in _list(root, 'sources'))
        () {
          final id = _str(s, 'source_id');
          sourceExtras[id] = SourceExtras(notes: s['notes'] as String?);
          return Source(
            sourceId: id,
            sourceType: _sourceType(_str(s, 'source_type')),
            title: _str(s, 'title'),
            authors: [...?(s['authors'] as List?)?.cast<String>()],
            organization: s['organization'] as String?,
            journal: s['journal'] as String?,
            publicationYear: s['publication_year'] as int?,
            edition: s['edition'] as String?,
            doi: s['doi'] as String?,
            pmid: s['pmid'] as String?,
            officialUrl: s['official_url'] as String?,
            accessedDate: _date(s['accessed_date']),
            tier: SourceTier.values.byName(_str(s, 'tier')),
            evidenceLevel: _evidence(_str(s, 'evidence_level')),
            licenseMode: SourceLicenseMode.values.byName(
              _str(s, 'license_mode'),
            ),
            identifierVerified: s['identifier_verified'] == true,
            isTestData: s['is_test_data'] == true,
            sourceClass: s['source_class'] == null
                ? null
                : SourceClass.values.byName(s['source_class']! as String),
          );
        }(),
    ];

    final claimValues = <String, Map<String, Object?>>{};
    final claims = [
      for (final c in _list(root, 'claims'))
        () {
          final id = _str(c, 'claim_id');
          final value = (c['value']! as Map).cast<String, Object?>();
          claimValues[id] = value;
          return Claim(
            claimId: id,
            entityType: EntityType.values.byName(_str(c, 'entity_type')),
            entityId: _str(c, 'entity_id'),
            field: _str(c, 'field'),
            value: value,
            domain: ContentDomain.values.firstWhere(
              (d) => d.code == _str(c, 'domain'),
            ),
            declaredStatus: ScientificStatus.fromCode(
              _str(c, 'declared_status'),
            ),
            evidenceLevel: _evidence(_str(c, 'evidence_level')),
            isStructuredValue: c['is_structured_value'] == true,
            isTestData: c['is_test_data'] == true,
            version: (c['version'] as int?) ?? 1,
            layer: KnowledgeLayer.values.firstWhere(
              (l) => l.code == _str(c, 'layer'),
            ),
            jurisdictionId: c['jurisdiction_id'] as String?,
            instrumentId: c['instrument_id'] as String?,
          );
        }(),
    ];

    final citations = [
      for (final c in _list(root, 'citations'))
        Citation(
          claimId: _str(c, 'claim_id'),
          sourceId: _str(c, 'source_id'),
          locator: c['locator'] as String?,
        ),
    ];

    final jurisdictions = [
      for (final j in _list(root, 'jurisdictions'))
        Jurisdiction(
          id: _str(j, 'jurisdiction_id'),
          level: JurisdictionLevel.values.byName(_str(j, 'level')),
          parentId: j['parent_id'] as String?,
          iso3166: j['iso3166'] as String?,
          names: (j['names'] as Map? ?? const {}).cast<String, String>(),
        ),
    ];

    final precision = <String, String>{};
    final instruments = [
      for (final i in _list(root, 'instruments'))
        () {
          final id = _str(i, 'instrument_id');
          if (i['date_precision'] != null) {
            precision[id] = i['date_precision']! as String;
          }
          return JurisdictionalInstrument(
            id: id,
            jurisdictionId: _str(i, 'jurisdiction_id'),
            type: _instrumentType(_str(i, 'instrument_type')),
            titles: (i['titles']! as Map).cast<String, String>(),
            officialSourceId: _str(i, 'official_source_id'),
            officialReference: i['official_reference'] as String?,
            effectiveFrom: _date(i['effective_from'])!,
            effectiveTo: _date(i['effective_to']),
            version: _str(i, 'version'),
            lastVerifiedAt: _date(i['last_verified_at']),
            status: ScientificStatus.fromCode(_str(i, 'review_status')),
            isTestData: i['is_test_data'] == true,
            authorityId: i['authority_id'] as String?,
            publicationDate: _date(i['publication_date']),
            lastAmendedAt: _date(i['last_amended_at']),
            legalStatus: i['legal_status'] == null
                ? InstrumentLegalStatus.inForce
                : _legalStatus(i['legal_status']! as String),
            language: i['language'] as String?,
            translationStatus: i['translation_status'] == null
                ? null
                : TranslationStatus.values.firstWhere(
                    (t) => t.code == i['translation_status'],
                    orElse: () => throw BundleFormatException(
                      'unknown translation_status ${i['translation_status']}',
                    ),
                  ),
          );
        }(),
    ];

    final authorities = [
      for (final a in _list(root, 'authorities'))
        Authority(
          id: _str(a, 'authority_id'),
          jurisdictionId: _str(a, 'jurisdiction_id'),
          names: (a['names']! as Map).cast<String, String>(),
        ),
    ];

    final rules = [
      for (final r in _list(root, 'rules'))
        JurisdictionalRule(
          id: _str(r, 'rule_id'),
          instrumentId: _str(r, 'instrument_id'),
          ruleType: _ruleType(_str(r, 'rule_type')),
          subjectType: _str(r, 'subject_type'),
          subjectId: _str(r, 'subject_id'),
          value: (r['value']! as Map).cast<String, Object?>(),
          effectiveFrom: _date(r['effective_from'])!,
          effectiveTo: _date(r['effective_to']),
          status: ScientificStatus.fromCode(_str(r, 'review_status')),
          isTestData: r['is_test_data'] == true,
          articleSection: r['article_section'] as String?,
          version: (r['version'] as int?) ?? 1,
          topicKey: r['topic_key'] as String?,
          appliesTo: r['applies_to'] == null
              ? null
              : {...(r['applies_to']! as List).cast<String>()},
        ),
    ];

    // PHASE 4 bilim obyektlari — KnowledgeJson (DB payload bilan bir xil).
    final tiers = <String, String>{};
    T entity<T>(
      Map<String, Object?> m,
      String idKey,
      T Function(Object?) parse,
    ) {
      final id = _str(m, idKey);
      final tier = m['tier_access'] as String?;
      if (tier != null) {
        if (!const {'free', 'student', 'pro'}.contains(tier)) {
          throw BundleFormatException('unknown tier_access $tier for $id');
        }
        tiers[id] = tier;
      }
      try {
        return parse(m);
      } on FormatException catch (e) {
        throw BundleFormatException('$id: ${e.message}');
      }
    }

    final topics = [
      for (final t in _list(root, 'topics'))
        entity(t, 'topic_id', KnowledgeJson.topicFrom),
    ];
    final recipes = [
      for (final r in _list(root, 'recipes'))
        entity(r, 'recipe_id', KnowledgeJson.recipeFrom),
    ];
    final screeningTests = [
      for (final t in _list(root, 'screening_tests'))
        entity(t, 'screening_id', KnowledgeJson.screeningFrom),
    ];
    final methods = [
      for (final m in _list(root, 'methods'))
        entity(m, 'method_id', KnowledgeJson.methodFrom),
    ];
    final emerging = [
      for (final e in _list(root, 'emerging_issues'))
        entity(e, 'issue_id', KnowledgeJson.emergingFrom),
    ];

    final substances = [
      for (final s in _list(root, 'substances'))
        SubstanceRecord(
          substanceId: _str(s, 'substance_id'),
          canonicalName: _str(s, 'canonical_name'),
          entityKind: _str(s, 'entity_kind'),
          tierAccess: _str(s, 'tier_access'),
          molecularFormula: s['molecular_formula'] as String?,
          names: (s['names']! as Map).cast<String, String>(),
          translationStatus: (s['translation_status']! as Map)
              .cast<String, String>(),
          synonyms: [...?(s['synonyms'] as List?)?.cast<String>()],
        ),
    ];

    if ((root['reviews'] as List? ?? const []).isNotEmpty ||
        (root['reviewers'] as List? ?? const []).isNotEmpty) {
      // Review yozuvlari CMS/PR orqali keladi — format keyingi bosqichda.
      throw BundleFormatException(
        'reviews/reviewers are not supported in fe-bundle/1 yet',
      );
    }

    return PipelineBundle(
      packVersion: _str(root, 'pack_version'),
      channel: channel,
      content: ContentBundle(
        channel: channel,
        sources: sources,
        claims: claims,
        citations: citations,
        jurisdictions: jurisdictions,
        instruments: instruments,
        jurisdictionalRules: rules,
        authorities: authorities,
        topics: topics,
        recipes: recipes,
        screeningTests: screeningTests,
        methods: methods,
        emergingIssues: emerging,
      ),
      substances: substances,
      sourceExtras: sourceExtras,
      claimValues: claimValues,
      instrumentDatePrecision: precision,
      componentVersions: (root['component_versions'] as Map? ?? const {})
          .cast<String, String>(),
      entityTiers: tiers,
    );
  }

  static InstrumentLegalStatus _legalStatus(String code) => switch (code) {
    'in_force' => InstrumentLegalStatus.inForce,
    'amended' => InstrumentLegalStatus.amended,
    'superseded' => InstrumentLegalStatus.superseded,
    'repealed' => InstrumentLegalStatus.repealed,
    _ => throw BundleFormatException('unknown legal_status $code'),
  };

  static String legalStatusCode(InstrumentLegalStatus s) => switch (s) {
    InstrumentLegalStatus.inForce => 'in_force',
    _ => s.name,
  };

  static List<Map<String, Object?>> _list(Map<String, Object?> m, String k) => [
    for (final e in (m[k] as List? ?? const [])) (e as Map).cast(),
  ];

  static String _str(Map<String, Object?> m, String k) {
    final v = m[k];
    if (v is! String || v.isEmpty) {
      throw BundleFormatException('missing "$k"');
    }
    return v;
  }

  static DateTime? _date(Object? v) =>
      v == null ? null : DateTime.parse(v as String);

  static EvidenceLevel _evidence(String code) =>
      EvidenceLevel.values.firstWhere((e) => e.code == code);

  static SourceType _sourceType(String code) => switch (code) {
    'journal_article' => SourceType.journalArticle,
    'book' => SourceType.book,
    'book_chapter' => SourceType.bookChapter,
    'guideline' => SourceType.guideline,
    'standard' => SourceType.standard,
    'database' => SourceType.database,
    'legislation' => SourceType.legislation,
    'report' => SourceType.report,
    'website' => SourceType.website,
    _ => throw BundleFormatException('unknown source_type $code'),
  };

  static InstrumentType _instrumentType(String code) => switch (code) {
    'law' => InstrumentType.law,
    'regulation' => InstrumentType.regulation,
    'controlled_substance_schedule' =>
      InstrumentType.controlledSubstanceSchedule,
    'standard' => InstrumentType.standard,
    'national_method' => InstrumentType.nationalMethod,
    'official_guideline' => InstrumentType.officialGuideline,
    'international_convention' => InstrumentType.internationalConvention,
    _ => throw BundleFormatException('unknown instrument_type $code'),
  };

  static JurisdictionalRuleType _ruleType(String code) => switch (code) {
    'control_status' => JurisdictionalRuleType.controlStatus,
    'procedure_requirement' => JurisdictionalRuleType.procedureRequirement,
    'legal_threshold' => JurisdictionalRuleType.legalThreshold,
    _ => throw BundleFormatException('unknown rule_type $code'),
  };

  /// DB’dagi kodlar (drift sxemasidagi CHECK’lar bilan bir xil).
  static String sourceTypeCode(SourceType t) => switch (t) {
    SourceType.journalArticle => 'journal_article',
    SourceType.bookChapter => 'book_chapter',
    _ => t.name,
  };

  static String instrumentTypeCode(InstrumentType t) => switch (t) {
    InstrumentType.controlledSubstanceSchedule =>
      'controlled_substance_schedule',
    InstrumentType.nationalMethod => 'national_method',
    InstrumentType.officialGuideline => 'official_guideline',
    InstrumentType.internationalConvention => 'international_convention',
    _ => t.name,
  };

  static String ruleTypeCode(JurisdictionalRuleType t) => switch (t) {
    JurisdictionalRuleType.controlStatus => 'control_status',
    JurisdictionalRuleType.procedureRequirement => 'procedure_requirement',
    JurisdictionalRuleType.legalThreshold => 'legal_threshold',
  };
}
