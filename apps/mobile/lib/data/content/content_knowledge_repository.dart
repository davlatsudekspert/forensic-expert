import 'dart:convert';

import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:fe_database/fe_database.dart' show ContentDatabase;
import 'package:flutter/foundation.dart';

import '../../domain/knowledge/knowledge_models.dart';
import '../../domain/library/library_models.dart';
import 'content_provenance.dart';

/// Bilim sohalari — `knowledge_entities` (+ `entity_sources`, `claims`).
///
/// `payload_json` pipeline’da validator’dan o‘tgan; bu yerda faqat
/// `KnowledgeJson` bilan o‘qiladi. Noma’lum yozuv turi — o‘tkazib
/// yuboriladi (yangi paket eski ilovada xato bermaydi), lekin hech narsa
/// taxmin qilinmaydi.
abstract final class ContentKnowledgeLoader {
  static Future<KnowledgeRepository> load(
    ContentDatabase db, {
    ContentProvenance? provenance,
  }) async {
    final prov = provenance ?? await ContentProvenance.load(db);
    final packVersion = await db.metaValue('pack_version');

    final entitySources = <String, List<SourceView>>{};
    for (final r
        in await db.customSelect('SELECT * FROM entity_sources').get()) {
      entitySources
          .putIfAbsent(r.read<String>('entity_id'), () => [])
          .add(
            prov.source(
              r.read<String>('source_id'),
              r.readNullable<String>('locator'),
            ),
          );
    }

    final entries = <KnowledgeEntry>[];
    for (final r
        in await db
            .customSelect('SELECT * FROM knowledge_entities ORDER BY entity_id')
            .get()) {
      final id = r.read<String>('entity_id');
      final payload = jsonDecode(r.read<String>('payload_json'));
      final kind = switch (r.read<String>('entity_type')) {
        'topic' => KnowledgeKind.topic,
        'reagent' => KnowledgeKind.reagent,
        'screening_test' => KnowledgeKind.screeningTest,
        'method' => KnowledgeKind.method,
        'emerging_issue' => KnowledgeKind.emergingIssue,
        _ => null,
      };
      if (kind == null) continue;
      final claims = prov.claimsByEntity[id] ?? const <ClaimView>[];
      final ownStatus = ScientificStatus.fromCode(
        r.read<String>('review_status'),
      );
      final topic = kind == KnowledgeKind.topic
          ? KnowledgeJson.topicFrom(payload)
          : null;
      entries.add(
        KnowledgeEntry(
          id: id,
          kind: kind,
          area: KnowledgeArea.values.byName(r.read<String>('area')),
          name: LocalizedText(
            (jsonDecode(r.read<String>('names_json')) as Map)
                .cast<String, String>(),
          ),
          // Yozuv statusi claim’larnikidan yuqori ko‘rsatilmaydi.
          status: aggregateStatus([
            ownStatus,
            for (final c in claims) c.status,
          ]),
          access: r.read<String>('tier_access') == 'free'
              ? EntryAccess.free
              : EntryAccess.lifetime,
          isTestData: r.read<int>('is_test_data') == 1,
          version: r.read<int>('version'),
          packVersion: packVersion,
          claims: claims,
          sources: entitySources[id] ?? const [],
          forensicMedicineTopic: topic?.forensicMedicineTopic,
          discipline: topic?.discipline,
          recipe: kind == KnowledgeKind.reagent
              ? KnowledgeJson.recipeFrom(payload)
              : null,
          screening: kind == KnowledgeKind.screeningTest
              ? KnowledgeJson.screeningFrom(payload)
              : null,
          method: kind == KnowledgeKind.method
              ? KnowledgeJson.methodFrom(payload)
              : null,
          emerging: kind == KnowledgeKind.emergingIssue
              ? KnowledgeJson.emergingFrom(payload)
              : null,
        ),
      );
    }
    return ListKnowledgeRepository(entries);
  }
}

/// Yurisdiksiya qatlami — kontent paketidagi rasmiy hujjat va qoidalar.
@immutable
class ContentLegalData {
  const ContentLegalData({
    required this.jurisdictions,
    required this.instruments,
    required this.rules,
    required this.catalog,
  });

  final List<Jurisdiction> jurisdictions;
  final List<JurisdictionalInstrument> instruments;
  final List<JurisdictionalRule> rules;
  final LegalCatalog catalog;

  static Future<ContentLegalData> load(
    ContentDatabase db, {
    ContentProvenance? provenance,
  }) async {
    final prov = provenance ?? await ContentProvenance.load(db);
    Map<String, String> names(String json) =>
        (jsonDecode(json) as Map).cast<String, String>();
    DateTime? d(Object? v) => ContentProvenance.date(v);

    final jurisdictions = [
      for (final r
          in await db.customSelect('SELECT * FROM jurisdictions').get())
        Jurisdiction(
          id: r.read<String>('jurisdiction_id'),
          level: JurisdictionLevel.values.byName(r.read<String>('level')),
          parentId: r.readNullable<String>('parent_id'),
          iso3166: r.readNullable<String>('iso3166'),
          names: names(r.read<String>('names_json')),
        ),
    ];
    final authorities = <String, LocalizedText>{
      for (final r in await db.customSelect('SELECT * FROM authorities').get())
        r.read<String>('authority_id'): LocalizedText(
          names(r.read<String>('names_json')),
        ),
    };
    final instrumentSources = <String, SourceView>{};
    final precision = <String, String>{};
    final instruments = <JurisdictionalInstrument>[];
    for (final r
        in await db
            .customSelect('SELECT * FROM jurisdictional_instruments')
            .get()) {
      final id = r.read<String>('instrument_id');
      final titles = jsonDecode(r.read<String>('titles_json')) as Map;
      if (titles.remove('_date_precision') case final String p) {
        precision[id] = p;
      }
      instrumentSources[id] = prov.source(
        r.read<String>('official_source_id'),
        r.readNullable<String>('official_reference'),
      );
      instruments.add(
        JurisdictionalInstrument(
          id: id,
          jurisdictionId: r.read<String>('jurisdiction_id'),
          type: _instrumentType(r.read<String>('instrument_type')),
          titles: titles.cast<String, String>(),
          officialSourceId: r.read<String>('official_source_id'),
          officialReference: r.readNullable<String>('official_reference'),
          effectiveFrom: d(r.data['effective_from'])!,
          effectiveTo: d(r.data['effective_to']),
          version: r.read<String>('version'),
          lastVerifiedAt: d(r.data['last_verified_at']),
          status: ScientificStatus.fromCode(r.read<String>('review_status')),
          isTestData: r.read<int>('is_test_data') == 1,
          authorityId: r.readNullable<String>('authority_id'),
          publicationDate: d(r.data['publication_date']),
          lastAmendedAt: d(r.data['last_amended_at']),
          legalStatus: switch (r.read<String>('legal_status')) {
            'amended' => InstrumentLegalStatus.amended,
            'superseded' => InstrumentLegalStatus.superseded,
            'repealed' => InstrumentLegalStatus.repealed,
            _ => InstrumentLegalStatus.inForce,
          },
          language: r.readNullable<String>('language'),
        ),
      );
    }
    final rules = [
      for (final r
          in await db.customSelect('SELECT * FROM jurisdictional_rules').get())
        JurisdictionalRule(
          id: r.read<String>('rule_id'),
          instrumentId: r.read<String>('instrument_id'),
          ruleType: switch (r.read<String>('rule_type')) {
            'control_status' => JurisdictionalRuleType.controlStatus,
            'procedure_requirement' =>
              JurisdictionalRuleType.procedureRequirement,
            _ => JurisdictionalRuleType.legalThreshold,
          },
          subjectType: r.read<String>('subject_type'),
          subjectId: r.read<String>('subject_id'),
          value: (jsonDecode(r.read<String>('value_json')) as Map)
              .cast<String, Object?>(),
          effectiveFrom: d(r.data['effective_from'])!,
          effectiveTo: d(r.data['effective_to']),
          status: ScientificStatus.fromCode(r.read<String>('review_status')),
          isTestData: r.read<int>('is_test_data') == 1,
          articleSection: r.readNullable<String>('article_section'),
          version: r.read<int>('version'),
          topicKey: r.readNullable<String>('topic_key'),
          appliesTo: switch (r.readNullable<String>('applies_to_json')) {
            final j? => {...(jsonDecode(j) as List).cast<String>()},
            null => null,
          },
        ),
    ];
    final versions = <String, String>{
      for (final r
          in await db
              .customSelect(
                'SELECT meta_key, meta_value FROM content_meta '
                "WHERE meta_key LIKE 'component_version.%'",
              )
              .get())
        r.read<String>('meta_key').substring('component_version.'.length): r
            .read<String>('meta_value'),
    };
    return ContentLegalData(
      jurisdictions: jurisdictions,
      instruments: instruments,
      rules: rules,
      catalog: LegalCatalog(
        authorities: authorities,
        instrumentSources: instrumentSources,
        componentVersions: versions,
        instrumentDatePrecision: precision,
      ),
    );
  }

  static InstrumentType _instrumentType(String code) => switch (code) {
    'law' => InstrumentType.law,
    'regulation' => InstrumentType.regulation,
    'controlled_substance_schedule' =>
      InstrumentType.controlledSubstanceSchedule,
    'standard' => InstrumentType.standard,
    'national_method' => InstrumentType.nationalMethod,
    'official_guideline' => InstrumentType.officialGuideline,
    _ => InstrumentType.internationalConvention,
  };
}
