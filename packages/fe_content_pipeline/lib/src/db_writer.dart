import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart' as crypto;
import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:fe_database/fe_database.dart' as db;
import 'package:fe_search_core/fe_search_core.dart';

import 'bundle_codec.dart';

/// Tahlil qilingan to‘plamni `content.db` ga yozadi.
///
/// Drift’ning generatsiya qilingan klasslari `fe_content_schema` nomlari
/// bilan to‘qnashmasligi uchun parametrli SQL ishlatiladi; sxema
/// CHECK/FK cheklovlari baribir bazaning o‘zida ishlaydi (ikkinchi himoya
/// qatlami — validator’dan keyin).
class ContentDbWriter {
  ContentDbWriter(this._db);

  final db.ContentDatabase _db;

  /// Metabolit nomlaridan qidiruv termini yasalmaydigan umumiy so‘zlar.
  static const _genericItems = {
    'sulfate',
    'glucuronide',
    'acetate',
    'm2',
    'm5',
    'eme',
    'be',
  };

  static const _searchableFields = {
    'metabolites',
    'biomarker',
    'transformation_product',
  };

  Future<void> write(PipelineBundle b, {required DateTime builtAt}) async {
    await _db.customStatement('PRAGMA foreign_keys = ON');
    await _db.transaction(() async {
      final c = b.content;
      Future<void> run(String sql, List<Object?> args) =>
          _db.customStatement(sql, args);

      for (final m in {
        'pack_version': b.packVersion,
        'channel': b.channel.name,
        'schema_version': '${db.ContentDatabase.contentSchemaVersion}',
        'built_at': builtAt.toUtc().toIso8601String(),
        'bundle_format': BundleCodec.format,
        // Komponent versiyalari: ilova / ilmiy baza / yurisdiksiya alohida.
        for (final v in b.componentVersions.entries)
          'component_version.${v.key}': v.value,
      }.entries) {
        await run(
          'INSERT INTO content_meta (meta_key, meta_value) VALUES (?, ?)',
          [m.key, m.value],
        );
      }

      for (final s in c.sources) {
        await run(
          'INSERT INTO sources (source_id, source_type, title, authors_json, '
          'organization, journal, publication_year, edition, doi, pmid, '
          'official_url, accessed_date, tier, evidence_level, license_mode, '
          'identifier_verified, review_status, is_test_data) '
          'VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
          [
            s.sourceId,
            BundleCodec.sourceTypeCode(s.sourceType),
            s.title,
            jsonEncode(s.authors),
            s.organization,
            s.journal,
            s.publicationYear,
            s.edition,
            s.doi,
            s.pmid,
            s.officialUrl,
            _d(s.accessedDate),
            s.tier.index + 1,
            s.evidenceLevel.code,
            s.licenseMode.name,
            s.identifierVerified ? 1 : 0,
            ScientificStatus.needsReview.code,
            s.isTestData ? 1 : 0,
          ],
        );
      }

      for (final j in c.jurisdictions) {
        await run(
          'INSERT INTO jurisdictions (jurisdiction_id, level, parent_id, '
          'iso3166, names_json) VALUES (?,?,?,?,?)',
          [j.id, j.level.name, j.parentId, j.iso3166, jsonEncode(j.names)],
        );
      }
      for (final a in c.authorities) {
        await run(
          'INSERT INTO authorities (authority_id, jurisdiction_id, names_json) '
          'VALUES (?,?,?)',
          [a.id, a.jurisdictionId, jsonEncode(a.names)],
        );
      }
      for (final i in c.instruments) {
        await run(
          'INSERT INTO jurisdictional_instruments (instrument_id, '
          'jurisdiction_id, instrument_type, titles_json, official_source_id, '
          'official_reference, effective_from, effective_to, version, '
          'last_verified_at, review_status, is_test_data, authority_id, '
          'publication_date, last_amended_at, legal_status, language, '
          'translation_status) '
          'VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
          [
            i.id,
            i.jurisdictionId,
            BundleCodec.instrumentTypeCode(i.type),
            jsonEncode({
              ...i.titles,
              if (b.instrumentDatePrecision[i.id] != null)
                '_date_precision': b.instrumentDatePrecision[i.id],
            }),
            i.officialSourceId,
            i.officialReference,
            _d(i.effectiveFrom),
            _d(i.effectiveTo),
            i.version,
            _d(i.lastVerifiedAt),
            i.status.code,
            i.isTestData ? 1 : 0,
            i.authorityId,
            _d(i.publicationDate),
            _d(i.lastAmendedAt),
            BundleCodec.legalStatusCode(i.legalStatus),
            i.language,
            i.translationStatus?.code,
          ],
        );
      }
      for (final r in c.jurisdictionalRules) {
        await run(
          'INSERT INTO jurisdictional_rules (rule_id, instrument_id, '
          'rule_type, subject_type, subject_id, value_json, effective_from, '
          'effective_to, review_status, is_test_data, article_section, '
          'topic_key, applies_to_json, version) '
          'VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
          [
            r.id,
            r.instrumentId,
            BundleCodec.ruleTypeCode(r.ruleType),
            r.subjectType,
            r.subjectId,
            jsonEncode(r.value),
            _d(r.effectiveFrom),
            _d(r.effectiveTo),
            r.status.code,
            r.isTestData ? 1 : 0,
            r.articleSection,
            r.topicKey,
            r.appliesTo == null ? null : jsonEncode([...r.appliesTo!]..sort()),
            r.version,
          ],
        );
      }

      for (final s in b.substances) {
        await run(
          'INSERT INTO substances (substance_id, canonical_name, entity_kind, '
          'molecular_formula, tier_access, review_status, content_version, '
          'is_test_data, substance_group) VALUES (?,?,?,?,?,?,?,0,?)',
          [
            s.substanceId,
            s.canonicalName,
            s.entityKind,
            s.molecularFormula,
            s.tierAccess,
            ScientificStatus.needsReview.code,
            b.packVersion,
            s.group,
          ],
        );
        for (final n in s.names.entries) {
          await run(
            'INSERT INTO substance_i18n (substance_id, lang, name, '
            'translation_status) VALUES (?,?,?,?)',
            [s.substanceId, n.key, n.value, s.translationStatus[n.key]],
          );
        }
      }

      for (final e in _knowledgeRows(b)) {
        await run(
          'INSERT INTO knowledge_entities (entity_id, entity_type, area, '
          'subtype, names_json, tier_access, review_status, version, '
          'jurisdiction_id, organization, event_date, payload_json, '
          'content_version, is_test_data) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
          [
            e.id,
            e.type,
            e.area,
            e.subtype,
            jsonEncode(e.names),
            b.tierOf(e.tierKey ?? e.id),
            e.status.code,
            e.version,
            e.jurisdictionId,
            e.organization,
            _d(e.eventDate),
            jsonEncode(e.payload),
            b.packVersion,
            e.isTestData ? 1 : 0,
          ],
        );
        for (final sid in e.sourceIds.toSet()) {
          await run(
            'INSERT INTO entity_sources (entity_id, source_id) VALUES (?,?)',
            [e.id, sid],
          );
        }
      }

      for (final cl in c.claims) {
        await run(
          'INSERT INTO claims (claim_id, entity_type, entity_id, field, '
          'value_json, domain, review_status, evidence_level, preferred, '
          'preference_reason, version, updated_at, is_test_data, '
          'knowledge_layer, jurisdiction_id, instrument_id) '
          'VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
          [
            cl.claimId,
            cl.entityType.name,
            cl.entityId,
            cl.field,
            jsonEncode(cl.value),
            cl.domain.code,
            cl.declaredStatus.code,
            cl.evidenceLevel.code,
            cl.preferred ? 1 : 0,
            cl.preferenceReason,
            cl.version,
            _d(builtAt),
            cl.isTestData ? 1 : 0,
            cl.layer.code,
            cl.jurisdictionId,
            cl.instrumentId,
          ],
        );
      }
      for (final r in c.research) {
        await run(
          'INSERT INTO research_records (research_id, kind, title, '
          'authors_json, organization, container, pub_year, doi, pmid, pmcid, '
          'handle, url, degree, open_access, source_api, accessed_date, '
          'evidence_level, peer_reviewed, review_status, is_test_data, '
          'forensic_relevance, language) '
          'VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
          [
            r.id,
            r.kind.code,
            r.title,
            jsonEncode(r.authors),
            r.organization,
            r.container,
            r.year,
            r.doi,
            r.pmid,
            r.pmcid,
            r.handle,
            r.url,
            r.degree,
            r.openAccess,
            r.sourceApi,
            _d(r.accessedDate),
            r.evidenceLevel.code,
            r.kind.isPeerReviewedFullArticle ? 1 : 0,
            r.status.code,
            r.isTestData ? 1 : 0,
            r.forensicRelevance.code,
            r.language,
          ],
        );
      }
      for (final l in c.links) {
        await run(
          'INSERT OR IGNORE INTO entity_links (from_id, to_id, relation, basis) '
          'VALUES (?,?,?,?)',
          [l.fromId, l.toId, l.relation.code, l.basis],
        );
      }
      for (final im in c.images) {
        final bytes = await File('${b.imageRoot ?? '.'}/${im.file ?? ''}')
            .readAsBytes();
        final sha = crypto.sha256.convert(bytes).toString();
        if (im.sha256 != null && im.sha256 != sha) {
          throw StateError('Image hash mismatch: ${im.id}');
        }
        await run(
          'INSERT INTO images (image_id, kind, entity_id, mime_type, bytes, '
          'width, height, sha256, title_json, alt_json, caption_original, '
          'creator, source_name, source_url, doi, license, attribution, '
          'is_original_diagram, represents_real_data, graphic, accessed_date) '
          'VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
          [
            im.id,
            im.kind.code,
            im.entityId,
            (im.file ?? '').endsWith('.png') ? 'image/png' : 'image/jpeg',
            bytes,
            null,
            null,
            sha,
            jsonEncode(im.title),
            jsonEncode(im.alt),
            im.captionOriginal,
            im.creator,
            im.sourceName,
            im.sourceUrl,
            im.doi,
            im.license,
            im.attribution,
            im.isOriginalDiagram ? 1 : 0,
            im.representsRealData ? 1 : 0,
            im.graphic ? 1 : 0,
            _d(im.accessedDate),
          ],
        );
      }

      for (final ci in c.citations) {
        await run(
          'INSERT INTO citations (claim_id, source_id, locator) VALUES (?,?,?)',
          [ci.claimId, ci.sourceId, ci.locator],
        );
      }
    });

    await _db.insertSearchTerms(_searchTerms(b));
  }

  /// PHASE 4 bilim obyektlari → `knowledge_entities` qatorlari.
  static List<_KnowledgeRow> _knowledgeRows(PipelineBundle b) {
    final c = b.content;
    return [
      for (final t in c.topics)
        _KnowledgeRow(
          id: t.id,
          type: 'topic',
          area: t.area.name,
          subtype: t.forensicMedicineTopic?.name,
          names: t.names,
          // Mavzu — faqat taksonomiya yozuvi; mazmuni claim’larda, ularning
          // o‘z statusi bor. Mavzu o‘zi hech qachon «reviewed» emas.
          status: ScientificStatus.needsReview,
          version: 1,
          payload: KnowledgeJson.topic(t),
          sourceIds: const [],
          isTestData: t.isTestData,
        ),
      for (final r in c.recipes)
        _KnowledgeRow(
          id: r.reagentId,
          // Bundle’da kirish darajasi retsept ID’si bilan beriladi.
          tierKey: r.id,
          type: 'reagent',
          area: KnowledgeArea.reagents.name,
          names: r.names,
          status: r.status,
          version: r.version,
          payload: KnowledgeJson.recipe(r),
          sourceIds: r.sourceIds,
          isTestData: r.isTestData,
        ),
      for (final t in c.screeningTests)
        _KnowledgeRow(
          id: t.id,
          type: 'screening_test',
          area: KnowledgeArea.screening.name,
          organization: t.manufacturer,
          names: t.names,
          status: t.status,
          version: t.version,
          payload: KnowledgeJson.screening(t),
          sourceIds: t.sourceIds,
          isTestData: t.isTestData,
        ),
      for (final m in c.methods)
        _KnowledgeRow(
          id: m.id,
          type: 'method',
          area: KnowledgeArea.methods.name,
          subtype: m.kind.name,
          names: m.titles,
          status: m.status,
          version: m.version,
          jurisdictionId: m.jurisdictionId,
          organization: m.organization,
          eventDate: m.effectiveFrom,
          payload: KnowledgeJson.method(m),
          sourceIds: m.sourceIds,
          isTestData: m.isTestData,
        ),
      for (final e in c.emergingIssues)
        _KnowledgeRow(
          id: e.id,
          type: 'emerging_issue',
          area: KnowledgeArea.emergingIssues.name,
          subtype: e.category.name,
          names: e.titles,
          status: e.status,
          version: 1,
          jurisdictionId: e.scopeJurisdictionId,
          eventDate: e.date,
          payload: KnowledgeJson.emerging(e),
          sourceIds: e.sourceIds,
          isTestData: e.isTestData,
        ),
    ];
  }

  static SearchCategory _categoryOf(_KnowledgeRow e) => switch (e.type) {
    'reagent' => SearchCategory.reagent,
    'screening_test' => SearchCategory.screeningTest,
    'method' => SearchCategory.method,
    'emerging_issue' => SearchCategory.emergingIssue,
    _ when e.area == KnowledgeArea.forensicMedicine.name =>
      SearchCategory.forensicMedicineTopic,
    _ when e.area == KnowledgeArea.biochemistry.name =>
      SearchCategory.biochemistryTopic,
    _ => SearchCategory.topic,
  };

  List<SearchTerm> _searchTerms(PipelineBundle b) {
    final terms = <SearchTerm>[
      // Research: sarlavha bo‘yicha (EN).
      for (final r in b.content.research)
        SearchTerm(
          entityId: r.id,
          category: SearchCategory.reference,
          term: r.title,
          kind: TermKind.canonical,
          lang: 'en',
          weight: 0.4,
        ),
      for (final e in _knowledgeRows(b))
        for (final n in e.names.entries)
          SearchTerm(
            entityId: e.id,
            category: _categoryOf(e),
            term: n.value,
            kind: n.key == 'en' ? TermKind.canonical : TermKind.localized,
            lang: n.key,
          ),
    ];
    for (final s in b.substances) {
      final cat = s.entityKind == 'metabolite'
          ? SearchCategory.metabolite
          : SearchCategory.substance;
      for (final n in s.names.entries) {
        terms.add(
          SearchTerm(
            entityId: s.substanceId,
            category: cat,
            term: n.value,
            kind: n.key == 'en' ? TermKind.canonical : TermKind.localized,
            lang: n.key,
          ),
        );
      }
      for (final syn in s.synonyms) {
        terms.add(
          SearchTerm(
            entityId: s.substanceId,
            category: cat,
            term: syn,
            kind: TermKind.synonym,
          ),
        );
      }
      if (s.molecularFormula != null) {
        terms.add(
          SearchTerm(
            entityId: s.substanceId,
            category: cat,
            term: s.molecularFormula!,
            kind: TermKind.formula,
            weight: 0.5,
          ),
        );
      }
    }
    // Metabolit / biomarker nomi bo‘yicha ota moddani topish.
    for (final cl in b.content.claims) {
      if (!_searchableFields.contains(cl.field)) continue;
      for (final item in (cl.value['items'] as List? ?? const [])) {
        final t = item as String;
        if (_genericItems.contains(t.toLowerCase())) continue;
        terms.add(
          SearchTerm(
            entityId: cl.entityId,
            category: SearchCategory.substance,
            term: t,
            kind: TermKind.synonym,
            weight: 0.6,
          ),
        );
      }
    }
    return terms;
  }

  static String? _d(DateTime? d) => d?.toIso8601String().substring(0, 10);
}

class _KnowledgeRow {
  const _KnowledgeRow({
    required this.id,
    required this.type,
    required this.area,
    required this.names,
    required this.status,
    required this.version,
    required this.payload,
    required this.sourceIds,
    required this.isTestData,
    this.subtype,
    this.jurisdictionId,
    this.organization,
    this.eventDate,
    this.tierKey,
  });

  final String id;
  final String? tierKey;
  final String type;
  final String area;
  final String? subtype;
  final Map<String, String> names;
  final ScientificStatus status;
  final int version;
  final String? jurisdictionId;
  final String? organization;
  final DateTime? eventDate;
  final Map<String, Object?> payload;
  final List<String> sourceIds;
  final bool isTestData;
}
